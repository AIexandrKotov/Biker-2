{$apptype console}
{$product Biker 2 Installer}
{$company Kotov Projects}

{$copyright Alexandr Kotov}

{$resource 'interface.dat'}
{$resource 'help.dat'}
{$resource 'map.dat'}
{$resource 'items.dat'}
{$resource 'quest.dat'}
{$resource 'shop.dat'}
{$resource 'mapview.exe'}
{$resource 'game.exe'}
{$resource 'bike.dat'}
{$resource 'map.png'}
{$resource 'version.dat'}

uses System;

const
  version: record Major, Minor, Build: integer; end = (Major: 0; Minor: 9; Build: 34);
  LANGS = 2;
  
type
  LANG = (RUS, ENG);
  
function IntToLang(a: integer): LANG := LANG(a);

function LangToInt(a: LANG): integer := Ord(a);

procedure Change(var a: boolean);
begin
  if a then a:=false
  else a:=true;
end;

procedure Resource(ResName, Outputfilename: string);
begin
  var f := System.IO.File.Create(Outputfilename);
  GetResourceStream(ResName).CopyTo(f);
  f.Flush;
  f.Close;
end;

var

  CurrentLang: LANG = RUS;

  Res: array of string = Arr(
  'game.exe',
  'mapview.exe',
  'map.dat',
  'interface.dat',
  'bike.dat',
  'shop.dat',
  'items.dat',
  'quest.dat',
  'help.dat',//8 0
  'map.png',//9 1
  'version.dat'//10 2
  );
  
  License: array[LANG] of string =(
    #10'[RUS]'
    #10'--- Лицензионное соглашение ---'
    #10''
    #10'Что можно:'
    #10' - Использовать'
    #10' - Распространять под изначальным именем с указанием автора и следующих ссылок:'
    #10'     vk.com/id219453333 (Александр Котов)'
    #10'     vk.com/ktvprj (Kotov Projects)'
    #10'     Электронной почты kotov.tv20012@gmail.com',
    #10'[ENG]'
    #10'--- License agreement ---'
    #10''
    #10'What can:'
    #10' - Use'
    #10' - Distribute under the original name with the author and the links:'
    #10'    vk.com/id219453333 (Alexandr Kotov)'
    #10'    vk.com/ktvprj (Kotov Projects)'
    #10'    E-mail kotov.tv20012@gmail.com');

  IFace: array[LANG] of array of string =(
  ('RUS',
    'Мастер установки Biker 2',
    'Версия',
    'Да','Нет',//3,4
    'Установить',
    'Лицензия',
    'Отмена',
    'Параметры установки',
    'Установить справку по игре',
    'Карта мира (.png)',
    'Список обновлений'
  ),
  ('ENG',
    'Biker 2 Installer',
    'Version',
    'Yes','No',//3,4
    'Install',
    'License',
    'Cancel',
    'Installation settings',
    'Install more information on the game',
    'World Map (.png)',
    'Update list'
  )
  );

begin  
  var status: boolean = true;
  var arr:= new boolean[3];
  arr[0]:=true;
  arr[1]:=true;
  arr[2]:=false;
  Console.BackgroundColor:=consolecolor.White;
  Console.ForegroundColor:=consolecolor.Black;
  Console.SetWindowSize(1,1);
  Console.SetBufferSize(100,30);
  Console.SetWindowSize(100,30);
  while status do
  begin
    var YES := IFace[CurrentLang][3];
    var NO  := IFace[CurrentLang][4];
    if Console.Title<>IFace[CurrentLang][1] then Console.Title:=IFace[CurrentLang][1];
    if ((Console.WindowWidth<>100) or (Console.WindowHeight<>30)) then
    begin
      Console.Clear;
      if (console.WindowHeight>30) or (console.WindowWidth>100) then Console.SetWindowSize(1,1);
      Console.SetBufferSize(100,30);
      Console.SetWindowSize(100,30);
    end;
    Console.Clear;
    
    var aaa: string = $'(-) {IFace[CurrentLang][0]}';
    Console.SetCursorPosition(99-aaa.Length,29);write(aaa);
    
    Console.SetCursorPosition(1,1);write('Biker 2 (',IFace[CurrentLang][2],' ',Version.Major,'.',Version.Minor,'.',Version.Build,')');
    
    Console.SetCursorPosition(1,3);write('(1) ',IFace[CurrentLang][5]);
    Console.SetCursorPosition(1,4);write('(2) ',IFace[CurrentLang][6]);
    Console.SetCursorPosition(1,5);write('(0) ',IFace[CurrentLang][7]);
    
    Console.SetCursorPosition(48,1);write(IFace[CurrentLang][8],': ');
    Console.SetCursorPosition(50,2);write('(-1) ',IFace[CurrentLang][9],': ');
    if arr[0] then
    begin
      Console.ForegroundColor:=ConsoleColor.DarkGreen;
      write(YES);
      Console.ForegroundColor:=ConsoleColor.Black;
    end
    else
    begin
      Console.ForegroundColor:=ConsoleColor.Red;
      write(NO);
      Console.ForegroundColor:=ConsoleColor.Black;
    end;
    Console.SetCursorPosition(50,3);write('(-2) ',IFace[CurrentLang][10],': ');
    if arr[1] then
    begin
      Console.ForegroundColor:=ConsoleColor.DarkGreen;
      write(YES);
      Console.ForegroundColor:=ConsoleColor.Black;
    end
    else
    begin
      Console.ForegroundColor:=ConsoleColor.Red;
      write(NO);
      Console.ForegroundColor:=ConsoleColor.Black;
    end;
    Console.SetCursorPosition(50,4);write('(-3) ',IFace[CurrentLang][11],': ');
    if arr[2] then
    begin
      Console.ForegroundColor:=ConsoleColor.DarkGreen;
      write(YES);
      Console.ForegroundColor:=ConsoleColor.Black;
    end
    else
    begin
      Console.ForegroundColor:=ConsoleColor.Red;
      write(NO);
      Console.ForegroundColor:=ConsoleColor.Black;
    end;
    
    var input: string = '';
    while (input='') and ((Console.WindowWidth=100) and (Console.WindowHeight=30)) do
    begin
      Console.SetCursorPosition(1,28);write(': ');
      input:=ReadLnString;
    end;
    
    if input='-1' then Change(arr[0]);
    if input='-2' then Change(arr[1]);
    if input='-3' then Change(arr[2]);
    if input='-' then
    begin
      CurrentLang:=(IntToLang(LangToInt(CurrentLang)+1));
      if LangToInt(CurrentLang)>=Langs then CurrentLang:=IntToLang(0);
    end;
    if input='0' then status:=false;
    if input='2' then
    begin
      Console.Clear;write(License[CurrentLang]);Console.CursorVisible:=false;
      Console.ReadKey;;Console.CursorVisible:=true;
    end;
    if input.ToLower='1' then
    begin
      MkDir('Biker 2');
      for var i:=0 to Res.Length-1 do
      begin
        if (not ((i=8) and (not arr[0])))
        and (not ((i=9) and (not arr[1])))
        and (not ((i=10) and (not arr[2]))) then
        begin
          Resource(Res[i],string.Format('Biker 2\{0}',Res[i]));
        end;
      end;
      //end;
      status:=false;
    end;
  end;
end.