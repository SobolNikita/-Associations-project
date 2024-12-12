program Associations;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils;

const
  MaxPlayers = 5;

  // TODO import words from file
  Dictionary: array[1..10] of string = (
    'яблоко', 'банан', 'вишня', 'виноград', 'ананас',
    'груша', 'слива', 'мёд', 'киви', 'лемон'
  );

type
  TPlayer = record
    Name: string;
    Points: Integer;
  end;

type Mattrix = array[1..3] of array[1..3] of string;
type Tmas = array[1..MaxPlayers] of Mattrix;
type Tmas2 = array[1..MaxPlayers] of String;

var
  Players: array[1..MaxPlayers] of TPlayer;
  NumPlayers: Integer;
  Round: Integer;

procedure InitializePlayers;
var
  i: Integer;
begin
  Write('Введите количество игроков (от 2 до 5): ');
  ReadLn(NumPlayers);

  //TODO Validation
  if NumPlayers < 2 then NumPlayers := 2;
  if NumPlayers > 5 then NumPlayers := 5;
  //TODO Validation

  for i := 1 to NumPlayers do
  begin
    Write('Введите имя игрока ', i, ': ');
    ReadLn(Players[i].Name);
    Players[i].Points := 0;
  end;
end;

procedure PlayRound;
//TODO make more functions
var
  i, j, k: Integer;
  WordIndex: Integer;
  Words : Tmas2;
  Guess: string;
  PlayersWords : TMas;
  Correct: Boolean;
begin
  for i := 1 to NumPlayers do
  begin
    // Wondering
    WordIndex := Random(Length(Dictionary)) + 1;
    //TODO Check if !used[wordIndex]

    Words[i] := Dictionary[WordIndex];
    WriteLn('Игрок ', Players[i].Name, ', вам нужно загадать слово.');

    Write('Введите 3 прилагательных к слову "', Words[i], '": ');
    for j := 1 to 3 do
      ReadLn(PlayersWords[i][1][j]);

    Write('Введите 3 глагола к слову "', Words[i], '": ');
    for j := 1 to 3 do
      ReadLn(PlayersWords[i][2][j]);

    Write('Введите 3 существительных к слову "', Words[i], '": ');
    for j := 1 to 3 do
      ReadLn(PlayersWords[i][3][j]);
  end;

  // Guessing
  for i := 1 to NumPlayers do
  begin
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
    Writeln(PlayersWords[j][1][3], ', ');

    Write('Ваш ответ: ');
    ReadLn(Guess);
    Writeln;
    if Guess = Words[j] then
    begin
      Players[i].Points := Players[i].Points + 3;
      WriteLn('Правильно! Вы получаете 3 очка.');
      //TODO remove continue
      Continue;
    end;

    // Attempt 2
    WriteLn('Неверно. Глаголы: ');
    for k := 1 to 2 do
    begin
      Write(PlayersWords[j][2][k], ', ');
    end;
    Writeln(PlayersWords[j][2][3], ', ');

    Write('Ваш ответ: ');
    ReadLn(Guess);
    Writeln;
    if Guess = Words[j] then
    begin
      Players[i].Points := Players[i].Points + 2;
      WriteLn('Правильно! Вы получаете 2 очка.');
      //TODO remove continue
      Continue;
    end;

    // Attempt 3
    WriteLn('Неверно. Существительные: ');
    for k := 1 to 2 do
    begin
      Write(PlayersWords[j][3][k], ', ');
    end;
    Writeln(PlayersWords[j][3][3], ', ');

    Write('Ваш ответ: ');
    ReadLn(Guess);
    Writeln;
    if Guess = Words[j] then
    begin
      Players[j].Points := Players[j].Points + 1;
      Players[i].Points := Players[i].Points + 1;
      WriteLn('Правильно! Вы и загадывающий игрок получаете по 1 очку.');
    end
    else
    begin
      Players[j].Points := Players[j].Points - 1;
      WriteLn('Неправильно. Загадывающий игрок теряет 1 очко.');
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

function GameOver: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to NumPlayers do
  begin
    if Players[i].Points >= 15 then
    begin
      Result := True;
      WriteLn('Победитель: ', Players[i].Name);
      //TODO remove exit
      Exit;
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
  until GameOver;

  WriteLn('Игра окончена.');
  ReadLn;
end.

//TODO The winner is the FIRST person to score 15.
//TODO Words can be entered through a space without a line break
//TODO Case validation

{

! 1. База данных слов и чтение из файла
! 2. Валидация введенных данных
! 3. Разбить на чуть большее количество функций
! 4. Проверка на повторное использование слов (нельзя)
! 5. Убрать continue и exit (она их не любит)
! 6. Делать победителем ПЕРВОГО, кто набрал 15, сейчас он берет рандомного, если 15 баллов набрали несколько человек в одном раунде
! 7. Сделать возможность вводить слова через пробел, а не только через знак ввода
! 8. Валидация на регистр букв

}