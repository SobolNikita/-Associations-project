﻿program Associations;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils;

const
  MaxPlayers = 5;
  wordsSize = 110;

type
  TPlayer = record
    Name: string;
    Points: Integer;
  end;

type ThreeWords = array[1..3] of string[255];
     Mattrix = array[1..3] of ThreeWords;
     Tmas = array[1..MaxPlayers] of Mattrix;
     Tmas2 = array[1..MaxPlayers] of String;
     TPlasyers = array[1..MaxPlayers] of TPlayer;
     
var
  Players: TPlasyers;
  NumPlayersInput : string[255];
  NumPlayers: Integer;
  Round: Integer;
  used: array[1..wordsSize] of boolean;
  InputFlag: boolean;

procedure InitializePlayers;
var
  i: Integer;
begin
  for i := 1 to wordsSize do
  begin
    used[i] := false;
  end;
  Write('Введите количество игроков (от 2 до 5): ');
  ReadLn(NumPlayersInput);
  NumPlayersInput := Trim(NumPlayersInput);
  InputFlag := false;
  while (not InputFlag) do
  begin
    InputFlag := true;
    if (NumPlayersInput <> '2') and (NumPlayersInput <> '3') and
       (NumPlayersInput <> '4') and (NumPlayersInput <> '5') then
    begin
      writeln('Неверный ввод. Введите количество игроков (от 2 до 5): ');
      ReadLn(NumPlayersInput);
      NumPlayersInput := Trim(NumPlayersInput);
      InputFlag := false;
    end;
  end;
  NumPlayers := StrToInt(NumPlayersInput);

  for i := 1 to NumPlayers do
  begin
    Write('Введите имя игрока ', i, ': ');
    ReadLn(Players[i].Name);
    Players[i].Name := Trim(Players[i].Name);
    while Length(Players[i].Name) = 0 do
    begin
      writeln('Имя должно содержать не менее одной буквы или цифры! Повторите ввод имени игрока ', i, ': ');
      ReadLn(Players[i].Name);
      Players[i].Name := Trim(Players[i].Name);
    end;
    Players[i].Points := 0;
  end;
end;

function getThreeWords : ThreeWords;
var s, curS: string[255];
    cnt, l, r: integer;
    res: ThreeWords;
begin
  cnt := 0;
  while cnt < 3 do
  begin
    readln(s);
    s := Trim(s);
    l := 1;
    while l <= Length(s) do
    begin
      r := l;
      curS := s[l];
      while (r+1<=Length(s)) and (s[r+1]<>' ') do
      begin
        r := r + 1;
        curS := curS + s[r];
      end;
      cnt := cnt + 1;
      if cnt <= 3 then
      begin
        res[cnt] := curS;
      end;
      l := r + 1;
      while (l <= Length(s)) and (s[l] = ' ') do
      begin
        l := l + 1;
      end;
    end;
  end;
  if cnt > 3 then
  begin
    writeln('Все слова после третьего были проигнорированы.')
  end;
  Result := res;
end;

function getWord(const ind: integer; const maxSiz: integer): string;
var f: TextFile;
    i: integer;
begin

  AssignFile(F, '../../words.txt', CP_UTF8);
  Reset(f);
  i:=1;
  Result := '';
  while (i<=ind) and (not Eof(f)) do
  begin
    readln(f, Result);
    i := i + 1;
  end;
  CloseFile(f);
end;

procedure PlayRound;
var
  i, j, k: Integer;
  WordIndex: Integer;
  Words : Tmas2;
  Guess: string;
  PlayersWords : TMas;
  Correct: Boolean;
  flag: boolean;
begin
  for i := 1 to NumPlayers do
  begin
    // Wondering
    WordIndex := Random(wordsSize) + 1;
    
    while used[WordIndex] do
    begin
      WordIndex := Random(wordsSize) + 1; 
    end;
    used[WordIndex] := true;

    Words[i] := AnsiLowerCase(getWord(WordIndex, wordsSize));
    WriteLn('Игрок ', Players[i].Name, ', вам нужно загадать слово.');

    Write('Введите 3 прилагательных к слову "', Words[i], '": ');
    PlayersWords[i][1] := getThreeWords;

    Write('Введите 3 глагола к слову "', Words[i], '": ');
    PlayersWords[i][2] := getThreeWords;

    Write('Введите 3 существительных к слову "', Words[i], '": ');
    PlayersWords[i][3] := getThreeWords;

  end;
  
  // Guessing
  for i := 1 to NumPlayers do
  begin
    flag := false;
    j := i + 1;
    if j > NumPlayers then
    begin
      j := 1;
    end;
    WriteLn('Игрок ', Players[i].Name, ', вам нужно угадать слово.');
    
    // Attempt 1
    WriteLn('Прилагательные: ');
    for k := 1 to 2 do
    begin
      Write(PlayersWords[j][1][k], ', ');
    end;
    Writeln(PlayersWords[j][1][3]);

    Write('Ваш ответ: ');
    ReadLn(Guess);
    Guess := AnsiLowerCase(Trim(Guess));
    while Length(Guess) = 0 do
    begin
      writeln('Ответ должен содержать как минимум одну букву или цифру. Повторите ввод: ');
      ReadLn(Guess);
      Guess := AnsiLowerCase(Trim(Guess));
    end;
    Writeln;
    if Guess = Words[j] then
    begin
      Players[j].Points := Players[j].Points + 1;
      Players[i].Points := Players[i].Points + 3;
      WriteLn('Правильно! Вы получаете 3 очка. Загадывающий игрок получает 1 очко.');
      flag := true;
    end;

    if not flag then
    begin
      // Attempt 2
      WriteLn('Неверно. Глаголы: ');
      for k := 1 to 2 do
      begin
        Write(PlayersWords[j][2][k], ', ');
      end;
      Writeln(PlayersWords[j][2][3]);

      Write('Ваш ответ: ');
      ReadLn(Guess);
      Guess := AnsiLowerCase(Trim(Guess));
      while Length(Guess) = 0 do
      begin
        writeln('Ответ должен содержать как минимум одну букву или цифру. Повторите ввод: ');
        ReadLn(Guess);
        Guess := AnsiLowerCase(Trim(Guess));
      end;
      Writeln;
      if Guess = Words[j] then
      begin
        Players[j].Points := Players[j].Points + 1;
        Players[i].Points := Players[i].Points + 2;
        WriteLn('Правильно! Вы получаете 2 очка. Загадывающий игрок получает 1 очко.');
        flag := true;
      end;
    end;
    if not flag then
    begin
      // Attempt 3
      WriteLn('Неверно. Существительные: ');
      for k := 1 to 2 do
      begin
        Write(PlayersWords[j][3][k], ', ');
      end;
      Writeln(PlayersWords[j][3][3]);

      Write('Ваш ответ: ');
      ReadLn(Guess);
      Guess := AnsiLowerCase(Trim(Guess));
      while Length(Guess) = 0 do
      begin
        writeln('Ответ должен содержать как минимум одну букву или цифру. Повторите ввод: ');
        ReadLn(Guess);
        Guess := AnsiLowerCase(Trim(Guess));
      end;
      Writeln;
      if Guess = Words[j] then
      begin
        Players[j].Points := Players[j].Points + 1;
        Players[i].Points := Players[i].Points + 1;
        WriteLn('Правильно! Вы и загадывающий игрок получаете по 1 очку.');
        flag := true;
      end
      else
      begin
        Players[j].Points := Players[j].Points - 1;
        WriteLn('Неправильно. Загадывающий игрок теряет 1 очко.');
      end;
    end;
  end;
end;

procedure ShowResults;
var
  i: Integer;
begin
  WriteLn('Результаты текущего раунда:');
  for i := 1 to NumPlayers do
    WriteLn(Players[i].Name, ': ', Players[i].Points, ' очков');
end;

function GameOver(var Players: TPlasyers; const MaxPlayers: integer): Boolean;
var
  i: Integer;
  winners: Integer;
begin
  Result := False;
  winners := 0;
  for i := 1 to NumPlayers do
  begin
    if Players[i].Points >= 15 then
    begin
      Result := True;
      winners := winners + 1;
    end;
  end;

  if Result then
  begin
    if winners = 1 then
    begin
      writeln('Победитель:');
    end
    else
    begin
      writeln('Победители:');
    end;

    for i := 1 to NumPlayers do
    begin
      if Players[i].Points >= 15 then
      begin
        WriteLn(Players[i].Name);
      end;
    end;

  end;
end;

begin
  Randomize;
  InitializePlayers;

  Round := 0;
  repeat
    Round := Round + 1;
    WriteLn('Раунд ', Round);
    PlayRound;
    ShowResults;
    Writeln;
  until GameOver(Players, MaxPlayers);

  WriteLn('Игра окончена.');
  ReadLn;
end.
