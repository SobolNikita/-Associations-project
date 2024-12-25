unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.ListBox, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Objects, FMX.Layouts,
  FMX.TreeView;

const
  MaxPlayers = 5;
  wordsSize = 110;

type
  TPlayer = record
    Name: string;
    Points: Integer;
  end;

  ThreeWords = array [1 .. 3] of string;
  Mattrix = array [1 .. 3] of ThreeWords;
  Tmas = array [1 .. MaxPlayers] of Mattrix;
  Tmas2 = array [1 .. MaxPlayers] of string;
  TPlasyers = array [1 .. MaxPlayers] of TPlayer;

var
  Players: array [1 .. MaxPlayers] of TPlayer;
  PlayersWords: Tmas;
  NumPlayers: Integer;
  Round: Integer = 1;
  IndexPlayer: Integer;
  Words: Tmas2;
  Guess: string;
  CountWrong: Integer = 0;
  used: array [1 .. wordsSize] of boolean;
  InputFlag: boolean;
  IsNameWrite: boolean;
  InputPlayersCnt, l, r: Integer;
  CurInput: string[255];
  InputWordsCnt: Integer;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    ButtonStart: TButton;
    InitializePlayersPanel: TPanel;
    Label2: TLabel;
    WriteAssotPanel: TPanel;
    Adj: TMemo;
    ButtonDone: TButton;
    Verb: TMemo;
    Noun: TMemo;
    NamesMemo: TMemo;
    NamesLabel: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    PlayerGuessWords: TLabel;
    GuessingPanel: TPanel;
    WhoGuessLabel: TLabel;
    MemoAdjGuess: TMemo;
    MemoVerbGuess: TMemo;
    MemoNounGuess: TMemo;
    AdjGuess: TLabel;
    VerbGuess: TLabel;
    NounGuess: TLabel;
    IsRight: TLabel;
    GuessEdit: TEdit;
    EditButtonOk: TEditButton;
    ResultsPanel: TPanel;
    NameRound: TLabel;
    MemoResults: TMemo;
    WinnerLabel: TLabel;
    MemoWinner: TMemo;
    ButtomNextRound: TButton;
    ButtonNextPlayer: TButton;
    HandOverPanel: TPanel;
    LabelHandOver: TLabel;
    ButtonHandOver: TButton;
    LabelRound: TLabel;
    ComboBox1: TComboBox;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonDoneClick(Sender: TObject);
    procedure EditButtonOkClick(Sender: TObject);
    procedure ButtomNextRoundClick(Sender: TObject);
    procedure ButtonNextPlayerClick(Sender: TObject);
    procedure ButtonHandOverClick(Sender: TObject);
    procedure ComboBox1ClosePopup(Sender: TObject);
    procedure AdjChange(Sender: TObject);
    procedure NounChange(Sender: TObject);
    procedure VerbChange(Sender: TObject);
   
  private
    { Private declarations }
    procedure RandomWord;
    procedure NewWriteAdj;
    procedure ShowResults;
    procedure NewWordsSave;
    procedure NewWordsWriteField;
    procedure ClearGuessing;
    procedure InitializePlayers;
    procedure CheckAnswer(var IsEndOne: boolean);

    // function  CheckAnswer;
  public
    { Public declarations }
    function getThreeWords(var S: string): ThreeWords;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.ComboBox1ClosePopup(Sender: TObject);// ����� ���-�� �������, ��������� ���� ��� ����� ����
begin
  if ComboBox1.Text <> '' then
  begin
    NumPlayers := StrToInt(ComboBox1.Text);
    NamesLabel.Visible := true;
    NamesMemo.Visible := true;
  end;
end;

procedure TForm1.InitializePlayers;  // ���������� �����, ����. ������� used
var
  i: Integer;
begin
  for i := 1 to wordsSize do
  begin
    used[i] := false;
  end;
  IsNameWrite := true;
  if NamesMemo.Text = '' then
    IsNameWrite := false
  else
    InputPlayersCnt := 0;
    i := 0;
    while i < NamesMemo.Lines.Count do
    begin
      NamesMemo.Lines[i] := Trim(NamesMemo.Lines[i]);
      l := 1;
      while l <= Length(NamesMemo.Lines[i]) do
      begin
        CurInput := NamesMemo.Lines[i][l];
        r := l;
        while (r + 1 <= Length(NamesMemo.Lines[i]))
              and (NamesMemo.Lines[i][r] <> ' ')
        do
        begin
          r := r + 1;
          CurInput := CurInput + NamesMemo.Lines[i][r];
        end;
        while (r + 1 <= Length(NamesMemo.Lines[i]))
              and (NamesMemo.Lines[i][r + 1] = ' ')
        do
        begin
          r := r + 1;
        end;
        l := r + 1;
        if (InputPlayersCnt < NumPlayers) then
        begin
          Players[InputPlayersCnt + 1].Name := CurInput;
          Players[InputPlayersCnt + 1].Points := 0;
        end;
        InputPlayersCnt := InputPlayersCnt + 1;
      end;
      i := i + 1;
    end;
    if not IsNameWrite then
      ShowMessage
      ('��� ������ ��������� �� ����� ����� ����� ��� �����! ��������� ���� �����!');
    if InputPlayersCnt < NumPlayers then
    begin
      ShowMessage
      ('�� ����� ������������ ���! ��������� ����!');
      IsNameWrite := false;
    end;
    if InputPlayersCnt > NumPlayers then
    begin
      ShowMessage
      ('������� ������� ����� ���! ������ ���� ���������������!');
    end;
end;

procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  if ComboBox1.Text = '' then
    ShowMessage('�������� ���������� �������')
  else
  begin
    InitializePlayers;
    if IsNameWrite then
      NewWordsWriteField;   //� ����� �����������
  end;
end;

function getWord(const ind: Integer; const maxSiz: Integer): string;
var
  f: TextFile;
  i: Integer;
begin
  AssignFile(f, '..\..\words.txt', CP_UTF8);
  Reset(f);
  i := 1;
  Result := '';
  while (i <= ind) and (not Eof(f)) do
  begin
    readln(f, Result);
    i := i + 1;
  end;
  CloseFile(f);
end;

procedure TForm1.RandomWord;
var
  WordIndex: Integer;
begin
  Randomize;
  WordIndex := Random(wordsSize) + 1;
  while used[WordIndex] do
    WordIndex := Random(wordsSize) + 1;
  used[WordIndex] := true;
  Words[IndexPlayer] := AnsiLowerCase(getWord(WordIndex, wordsSize));
  PlayerGuessWords.Text := ('�����, ' + Players[IndexPlayer].Name +
    ', ��� ����� �������� ���������� � ����� ''''' + Words[IndexPlayer]
    + '''''');
end;

procedure TForm1.NewWordsWriteField;
begin
  InitializePlayersPanel.Visible := false;
  WriteAssotPanel.Visible := true;
  LabelRound.Text := '����� ' + IntToStr(Round);
  IndexPlayer := 1;
  RandomWord;
end;

procedure TForm1.NewWordsSave; //���������� � ������ ��������� ����, ������� ����� � ����. ������
var
  S: string;
begin
  ResultsPanel.Visible := false;
  S := Adj.Text;
  PlayersWords[IndexPlayer][1] := getThreeWords(S);
  S := Verb.Text;
  PlayersWords[IndexPlayer][2] := getThreeWords(S);
  S := Noun.Text;
  PlayersWords[IndexPlayer][3] := getThreeWords(S);
  if InputFlag then
  begin
    Inc(IndexPlayer);
    Adj.Lines.Clear; // ������� ����� �����
    Verb.Lines.Clear;
    Noun.Lines.Clear;
    if IndexPlayer <= NumPlayers then
      RandomWord;
  end
  else
    ShowMessage('������� ����������� ����������!');
end;

procedure TForm1.ButtonHandOverClick(Sender: TObject);
begin
  HandOverPanel.Visible := false;
end;

procedure TForm1.ButtonDoneClick(Sender: TObject);
begin
  InputFlag := true;
  NewWordsSave;
  if (IndexPlayer < NumPlayers) and InputFlag then
    HandOverPanel.Visible := true
  else if IndexPlayer > NumPlayers then
  begin
    WriteAssotPanel.Visible := false;
    GuessingPanel.Visible := true;
    IndexPlayer := 0;
    NewWriteAdj;
  end;
end;

procedure TForm1.NewWriteAdj; // ���������� ����� (1 ����)
var
  k, j: Integer;
begin
  IndexPlayer := IndexPlayer + 1;
  j := IndexPlayer + 1;
  if j > NumPlayers then
    j := 1;
  WhoGuessLabel.Text := ('����� ' + Players[IndexPlayer].Name +
    ', ��� ����� ������� �����');
  MemoAdjGuess.Text := '';
  // Attempt 1
  VerbGuess.Visible := false;
  NounGuess.Visible := false;
  for k := 1 to 3 do
    MemoAdjGuess.Lines.Add(PlayersWords[j][1][k]); //����� ��������������
end;

procedure TForm1.NounChange(Sender: TObject);
var
  i: Integer;
begin
  if Noun.Text = '' then
    IsNameWrite := false
  else
    InputWordsCnt := 0;
  i := 0;
  while i < Noun.Lines.Count do
  begin
    Noun.Lines[i] := Trim(Noun.Lines[i]);
    l := 1;
    while l <= Length(Noun.Lines[i]) do
    begin
      CurInput := Noun.Lines[i][l];
      r := l;
      while (r + 1 <= Length(Noun.Lines[i]))
            and (Noun.Lines[i][r] <> ' ')
      do
      begin
        r := r + 1;
        CurInput := CurInput + Noun.Lines[i][r];
      end;
      while (r + 1 <= Length(Noun.Lines[i]))
            and (Noun.Lines[i][r + 1] = ' ')
      do
      begin
        r := r + 1;
      end;
      l := r + 1;
      InputWordsCnt := InputWordsCnt + 1;
    end;
    i := i + 1;
  end;
  if InputWordsCnt > 3 then
  begin
    ShowMessage
    ('������� ������� ����� ����! ������ ����� ���������������!');
  end;
end;

procedure TForm1.EditButtonOkClick(Sender: TObject);
var
  k: Integer;
  IsEndOne: boolean;
begin
  IsEndOne := false;
  Guess := Trim(AnsiLowerCase(GuessEdit.Text));
  if Guess <> '' then
  begin
    if not ButtonNextPlayer.Visible then
      CheckAnswer(IsEndOne);
    IsRight.Visible := true;
    if IsEndOne then
      ButtonNextPlayer.Visible := true;
  end
  else if not ButtonNextPlayer.Visible then
    ShowMessage('������� ��� �����!');
end;

function TForm1.getThreeWords(var S: string): ThreeWords;
var
  curS: string;
  cnt, l, r: Integer;
  res: ThreeWords;
begin
  cnt := 0;
  S := Trim(S);
  l := 1;
  while l <= Length(S) do
  begin
    r := l;
    curS := S[l];
    while (r + 1 <= Length(S)) and (S[r + 1] <> ' ') and (S[r + 1] <> #$D) and
      (S[r + 1] <> #$A) do
    begin
      r := r + 1;
      curS := curS + S[r];
    end;
    cnt := cnt + 1;
    if cnt <= 3 then
    begin
      res[cnt] := curS;
    end;
    l := r + 1;
    while (l <= Length(S)) and ((S[l] = ' ') or (S[l] = #$D) or (S[l] = #$A)) do
    begin
      l := l + 1;
    end;
  end;
  if cnt < 3 then
    InputFlag := false;
  Result := res;
  (* if cnt > 3 then
    ShowMessage('��� ����� ����� �������� ���� ���������������.'); *)
end;

procedure TForm1.CheckAnswer(var IsEndOne: boolean);
var
  k, NextPlayer: Integer;
begin
if IndexPlayer<NumPlayers then
 NextPlayer:= IndexPlayer+1
 else
 NextPlayer:=1;
  if Guess <> Words[NextPlayer] then
  begin
    CountWrong := CountWrong + 1;
    case CountWrong of
      1:
        begin
          IsRight.Text := '�����������!';
          VerbGuess.Visible := true;
          for k := 1 to 3 do
            MemoVerbGuess.Lines.Add(PlayersWords[NextPlayer][2][k]);
        end;
      2:
        begin
          IsRight.Text := '�����������!';
          NounGuess.Visible := true;
          for k := 1 to 3 do
            MemoNounGuess.Lines.Add(PlayersWords[NextPlayer][3][k]);
        end;
      3:
        begin
          IsRight.Text := '�����������! ������������ ����� ������ 1 ����.';
          Players[NextPlayer].Points := Players[NextPlayer].Points - 1;
          IsEndOne := true;
        end;
    end;
    GuessEdit.Text := '';
  end
  else
  begin
    case CountWrong of
      0:
        begin
          IsRight.Text := '���������! �� ��������� 3 ����.';
          Players[IndexPlayer].Points := Players[IndexPlayer].Points + 3;
        end;
      1:
        begin
          IsRight.Text := '���������! �� ��������� 2 ����.';
          Players[IndexPlayer].Points := Players[IndexPlayer].Points + 2;
        end;
      2:
        begin
          IsRight.Text :=
            '���������! �� � ������������ ����� ��������� �� 1 ����.';
          Players[IndexPlayer].Points := Players[IndexPlayer].Points + 1;
          Players[NextPlayer].Points := Players[NextPlayer].Points + 1;
        end;
    end;
    IsEndOne := true;
  end;
  if IsEndOne then
  begin
    GuessEdit.Text := '';
    CountWrong := 0;
  end;
end;

procedure TForm1.ClearGuessing;     //������� ������ ����� ����������
begin
  MemoAdjGuess.Text := '';
  MemoVerbGuess.Text := '';
  MemoNounGuess.Text := '';
  VerbGuess.Visible := false;
  NounGuess.Visible := false;
  IsRight.Visible := false;
end;

procedure TForm1.ButtonNextPlayerClick(Sender: TObject);
begin
  ClearGuessing;
  if IndexPlayer < NumPlayers then
    NewWriteAdj
  else if IndexPlayer = NumPlayers then
    ShowResults;
  ButtonNextPlayer.Visible := false;
end;

procedure TForm1.AdjChange(Sender: TObject);
var
  i: Integer;
begin
  if Adj.Text = '' then
    IsNameWrite := false
  else
    InputWordsCnt := 0;
  i := 0;
  while i < Adj.Lines.Count do
  begin
    Adj.Lines[i] := Trim(Adj.Lines[i]);
    l := 1;
    while l <= Length(Adj.Lines[i]) do
    begin
      CurInput := Adj.Lines[i][l];
      r := l;
      while (r + 1 <= Length(Adj.Lines[i]))
            and (Adj.Lines[i][r] <> ' ')
      do
      begin
        r := r + 1;
        CurInput := CurInput + Adj.Lines[i][r];
      end;
      while (r + 1 <= Length(Adj.Lines[i]))
            and (Adj.Lines[i][r + 1] = ' ')
      do
      begin
        r := r + 1;
      end;
      l := r + 1;
      InputWordsCnt := InputWordsCnt + 1;
    end;
    i := i + 1;
  end;
  if InputWordsCnt > 3 then
  begin
    ShowMessage
    ('������� ������� ����� ����! ������ ����� ���������������!');
  end;
end;

procedure TForm1.ButtomNextRoundClick(Sender: TObject);
begin
  ResultsPanel.Visible := false;
  NewWordsWriteField;
end;

procedure TForm1.ShowResults;
var
  i, winners: Integer;
  GameOver: boolean;
begin
  GameOver := false;
  GuessingPanel.Visible := false;
  ResultsPanel.Visible := true;
  MemoResults.Text := '';
  winners := 0;
  NameRound.Text := '���������� ' + IntToStr(Round) + '-�� ������';
  for i := 1 to NumPlayers do
    MemoResults.Lines.Add(Players[i].Name + ': ' + IntToStr(Players[i].Points) +
      ' �����');
  Round := Round + 1;
  for i := 1 to NumPlayers do
  begin
    if Players[i].Points >= 15 then
    begin
      winners := winners + 1;
      ButtomNextRound.Visible := false;
      MemoWinner.Visible := true;
      WinnerLabel.Visible := true;
      MemoWinner.Lines.Add(Players[i].Name);
    end;
  end;
  if winners > 1 then
    WinnerLabel.Text := '����������';
  if not GameOver then
    IndexPlayer := 1;
end;

procedure TForm1.VerbChange(Sender: TObject);
var
  i: Integer;
begin
  if Verb.Text = '' then
    IsNameWrite := false
  else
    InputWordsCnt := 0;
  i := 0;
  while i < Verb.Lines.Count do
  begin
    Verb.Lines[i] := Trim(Verb.Lines[i]);
    l := 1;
    while l <= Length(Verb.Lines[i]) do
    begin
      CurInput := Verb.Lines[i][l];
      r := l;
      while (r + 1 <= Length(Verb.Lines[i]))
            and (Verb.Lines[i][r] <> ' ')
      do
      begin
        r := r + 1;
        CurInput := CurInput + Verb.Lines[i][r];
      end;
      while (r + 1 <= Length(Verb.Lines[i]))
            and (Verb.Lines[i][r + 1] = ' ')
      do
      begin
        r := r + 1;
      end;
      l := r + 1;
      InputWordsCnt := InputWordsCnt + 1;
    end;
    i := i + 1;
  end;
  if InputWordsCnt > 3 then
  begin
    ShowMessage
    ('������� ������� ����� ����! ������ ����� ���������������!');
  end;
end;

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.

//'D:\����\Projects\words.txt'
