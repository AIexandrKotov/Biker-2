{$apptype windows}
{$product Biker 2 Map Viewer}
{$version 1.0}
{$company Kotov Projects}

{$copyright Alexandr Kotov}

//todo fixme

uses GraphWPF, System;
 
type
  tpmap = record
    name: string;
    sort: integer;
    x,y: real;
    road: array of record
      id: integer;
      tp: char;
    end;
  end;
 
var
  types: array of string;
  map: array of tpmap;
 
procedure AddTypes(t : String);
begin
  var L := types.Count;
  SetLength(types, L+1);
  types[L] := t;
end;
  
procedure ReadMap(fName : String);
begin
  if Not IO.File.Exists(fName)=true then Exit;
  var txt := ReadAllText(fName, Encoding.UTF8).ToWords(#13#10.toArray);
  var (mapid1, mapid2) := (0, 0);
  foreach var s in txt do
    if s.IndexOf('=') > 0 then
      begin
        var p := s.ToWords('=');
        case p[0] of
          'towns' : SetLength(map, p[1].ToInteger);
          'newtype' : AddTypes(p[1]);
          'town' : (mapid1, mapid2) := (StrToInt(p[1]), 0);
          'name' : map[mapid1].name := p[1];
          'type' : map[mapid1].sort := StrToInt(p[1]);
          'posx' : map[mapid1].x := StrToFloat(p[1]);
          'posy' : map[mapid1].y := StrToFloat(p[1]);
          'road' : begin
                     SetLength(map[mapid1].road, mapid2 + 1);
                     map[mapid1].road[mapid2].id := StrToInt(p[1].ToWords(' ')[0]) - 1;
                     map[mapid1].road[mapid2].tp := char.Parse(p[1].ToWords(' ')[1]);
                     mapid2 += 1;
                   end;
        end;
      end;
  var maxy: real;
  for var i:=0 to map.Length-1 do if maxy<map[i].y then maxy:=map[i].y;
  for var i:=0 to map.Length-1 do map[i].y:=maxy-map[i].y;
end;
 
function Xcoord(X : Real; Town0, Town1 : tpmap; Scale : Real) := X + (Town1.x - Town0.x) * Scale;
function Ycoord(Y : Real; Town0, Town1 : tpmap; Scale : Real) := Y + (Town1.y - Town0.y) * Scale;
 
var Lout, Lwait : List<integer>; // out - отрисованные, wait - ожидающие отрисовки
 
procedure DrawRoads(X, Y : Real; Town : tpmap; Scale : Real);
begin
  foreach var over in Town.road do
    begin
      case over.tp of
        'B' : Pen.Color := Color.FromRgb(85,107,47);
        'G' : Pen.Color := Color.FromRgb(255, 165, 0);
      end;
      Line(X, Y, Xcoord(X, Town, map[over.id], Scale), Ycoord(Y, Town, map[over.id], Scale));
      if Not Lout.Contains(over.id) and Not Lwait.Contains(over.id) then Lwait.Add(over.id);
    end;
end;
 
procedure DrawTown(X, Y : Real; DrawType : Integer; Town : tpmap; Scale : Real);
begin
  case DrawType of
    0 : begin
          DrawRoads(X, Y, Town, Scale);
          Brush.Color := rgb(128, 128, 192);
          Pen.Color := rgb(0, 0, 0);
        end;
    1 : begin
          DrawRoads(X, Y, Town, Scale);
          Brush.Color := rgb(128, 192, 128);
          Pen.Color := rgb(0, 0, 0);
        end;
    2 : begin
          DrawRoads(X, Y, Town, Scale);
          Brush.Color := rgb(192, 128, 128);
          Pen.Color := rgb(0, 0, 0);
        end;
    3 : begin // центральная точка
          DrawRoads(X, Y, Town, Scale);
          Brush.Color := rgb(255, 255, 0);
          Pen.Color := rgb(255, 0, 0);
          case Town.sort of
            0: Circle(Round(X), Round(Y), 5);
            1: Circle(Round(X), Round(Y), 8);
            2: Circle(Round(X), Round(Y), 14);
          end;
          GraphWPF.TextOut(X, Y - 10 - TextHeight(Town.Name), Town.Name);
          //DrawTextCentered(Round(X), Round(Y) - 10 - TextHeight(Town.Name), Town.Name);
          Exit;
        end;
  end;
  case Town.sort of
    0: Circle(Round(X), Round(Y), 5);
    1: Circle(Round(X), Round(Y), 8);
    2: Circle(Round(X), Round(Y), 14);
  end;
  GraphWPF.TextOut(X, Y - 5 - TextHeight(Town.Name), Town.Name);
end;
 
procedure DrawMap(Center : Integer; Scale : Real);
begin
  Window.Clear;
  Lout := New List<integer>;
  Lwait := New List<integer>;
  DrawTown(Window.Center.X, Window.Center.Y, 3, map[Center], Scale); Lout.Add(Center);
  while Lwait.Count > 0 do
    begin
      var cur := Lwait.First;
      if (Xcoord(Window.Center.X, map[Center], map[cur], Scale)>=0) and (Xcoord(Window.Center.X, map[Center], map[cur], Scale)<=window.Width)
      and (Ycoord(Window.Center.Y, map[Center], map[cur], Scale)>=0) and (Ycoord(Window.Center.Y, map[Center], map[cur], Scale)<=window.Height) then
      DrawTown(Xcoord(Window.Center.X, map[Center], map[cur], Scale), Ycoord(Window.Center.Y, map[Center], map[cur], Scale), map[cur].sort, map[cur], Scale);
      Lout.Add(cur); Lwait.Remove(cur);
    end;
  Lout := nil;
  Lwait := nil;
end;

var
    minsc, maxsc, stepsc: real;
    sc: real;
    current: integer;
    mxed: boolean;

procedure MouseDown(x,y: real; n: integer);
begin
  if (n=1) and (sc<maxsc) then
  begin
    sc+=stepsc;
    DrawMap(current, sc);
  end;
  if (n=2) and (sc>minsc) then
  begin
    sc-=stepsc;
    DrawMap(current, sc);
  end;
end;

procedure KeyPress(c : Char);
begin
  case c of
     #27,'0' : Window.Close;
     '1':
      begin
        if (sc<maxsc) then
        begin
          sc+=stepsc;
          DrawMap(current, sc);
        end;
      end;
     '2':
      begin
        if (sc>minsc) then
        begin
          sc-=stepsc;
          DrawMap(current, sc);
        end;
      end;
     '3':
      begin
        if mxed then
        begin
          window.Normalize;
          mxed:=false;
        end
        else
        begin
          window.Maximize;
          mxed:=true;
        end;
      end;
  end;
end;

procedure KeyDown(k: key);
begin
  case k of
    key.Escape, key.NumPad0: Window.Close;
    key.NumPad1, key.Z:
      begin
        if (sc<maxsc) then
        begin
          sc+=stepsc;
          DrawMap(current, sc);
        end;
      end;
    key.NumPad2, key.X:
      begin
        if (sc>minsc) then
        begin
          sc-=stepsc;
          DrawMap(current, sc);
        end;
      end;
    key.C:
      begin
        if mxed then
        begin
          window.Normalize;
          mxed:=false;
        end
        else
        begin
          window.Maximize;
          mxed:=true;
        end;
      end;
  end;
end;

procedure _Res := DrawMap(current, sc);

 
begin
  GraphWPF.Font.Name:='Arial';
  if CommandLineArgs.Length=0 then
  begin
    window.Close;exit;
  end
  else if not (System.IO.File.Exists('map.dat')) then
  begin
    window.Close;exit;
  end;
  try
    //current:=StrToInt(CommandLineArgs[0]);
    var s:=CommandLineArgs;
    current:=StrToInt(s[0]);
    minsc:=StrToFloat(s[1]);
    maxsc:=StrToFloat(s[2]);
    stepsc:=StrToFloat(s[3]);
  except
    on e: System.Exception do
    begin
      window.Close;exit;
    end;
  end;
  window.SetSize(500,500);
  window.Title:='Biker 2 Map Viewer';
  window.CenterOnScreen;
  //window.IsFixedSize:=true;
  //DrawInBuffer:=true;
  SetLength(types, 0);
  ReadMap('map.dat');
  sc:=5;
  //PABCSystem.CommandLineArgs
  DrawMap(current, sc);
  GraphWPF.OnMouseDown:=MouseDown;
  GraphWPF.OnKeyPress:=KeyPress;
  GraphWPF.OnKeyDown:=KeyDown;
  GraphWPF.OnResize:=_Res;
end.