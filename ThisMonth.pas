unit ThisMonth;
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils, IniFilesDX, System.IOUtils, System.Types,
  Vcl.Filectrl, Vcl.ComCtrls, HideListView;

type
  TfrmThisMonth = class(TForm)
    lvwList: THideListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure lvwListCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private 宣言 }
    procedure _LoadSettings;
    procedure _SaveSettings;
  public
    { Public 宣言 }
    procedure _LoadData;
  end;

var
  frmThisMonth: TfrmThisMonth;

implementation

{$R *.dfm}

uses
  HideUtils,
  dp,
  Main,
  Utils;

procedure TfrmThisMonth.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  _SaveSettings;
  Release;
  frmThisMonth := nil;   //フォーム名に変更する
end;

procedure TfrmThisMonth.FormCreate(Sender: TObject);
begin
//  if IsDebugMode then
//     Self.Caption := 'Debug Mode - ' + Self.Caption;
  DisableVclStyles(Self, '');
  _LoadSettings;
  _LoadData;
end;

procedure TfrmThisMonth._LoadData;
var
  slGroup : TStringList;
  item, itemAdd : TListItem;
  gr : TListGroup;
  i, idx : Integer;
  s1, s2 : String;
begin
  slGroup := TStringList.Create;
  lvwList.Items.BeginUpdate;
  lvwList.Items.Clear;
  lvwList.Groups.BeginUpdate;
  lvwList.Groups.Clear;
  try
    //グループヘッダーのリスト作成
    slGroup.Sorted := True;
    for i := 0 to frmMain.lvwMonthly.Items.Count-2 do
    begin
      item := frmMain.lvwMonthly.Items[i];
      if slGroup.IndexOf(item.SubItems[0]) = -1 then
        slGroup.Add(item.SubItems[0]);
    end;
    //グループヘッダーの作成
    for i := 0 to slGroup.Count-1 do
    begin
      gr := lvwList.Groups.Add;
      gr.Header := slGroup[i];
      gr.Subtitle := '0 / 0';
      gr.GroupID  := i;
      gr.State    := [lgsCollapsed, lgsCollapsible];
      gr.HeaderAlign := taCenter;
      gr.FooterAlign := taRightJustify;
    end;
    //アイテム追加
    for i := 0 to frmMain.lvwMonthly.Items.Count-2 do
    begin
      item := frmMain.lvwMonthly.Items[i];
      idx := slGroup.IndexOf(item.SubItems[0]);
      itemAdd := lvwList.Items.Add;
      itemAdd.Caption := item.Caption;
      itemAdd.SubItems.Add(item.SubItems[1]);
      itemAdd.GroupID := idx;
      SplitStringsToAandB(lvwList.Groups[idx].Subtitle, ' / ', s1, s2);
      s1 := FormatFloat('#,###', StrToIntDefEx(s1, 0) + StrToIntDefEx(item.SubItems[1], 0));
      s2 := IntToStr(StrToIntDefEx(s2, 0) + 1);
      lvwList.Groups[idx].Subtitle := s1 + ' / ' + s2 + '回';
    end;
  finally
    slGroup.Free;
    lvwList.Groups.EndUpdate;
    lvwList.Items.EndUpdate;
  end;
end;

procedure TfrmThisMonth._LoadSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.ReadWindowPosition(Self.Name, Self);
    Self.Font.Name := ini.ReadString('General', 'FontName', '游ゴシック Medium');
    Self.Font.Size := ini.ReadInteger('General', 'FontSize', 10);
  finally
    ini.Free;
  end;
end;

procedure TfrmThisMonth._SaveSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.WriteWindowPosition(Self.Name, Self);
    ini.WriteString('General', 'FontName', Self.Font.Name);
    ini.WriteInteger('General', 'FontSize', Self.Font.Size);
  finally
    ini.UpdateFile;
    ini.Free;
  end;
end;

procedure TfrmThisMonth.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case key of
    char(VK_ESCAPE) :
      begin
        Key := char(0);
        Close;
      end;
  end;
end;

procedure TfrmThisMonth.lvwListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  DefaultDraw := True;
  with Sender.Canvas do
  begin
    Brush.Style := bsSolid;
    if cdsHot in State then
    begin
      Brush.Color := clHover;
      Font.Color  := clWindowText;
      Font.Style  := [fsUnderline];
    end;
  end;
end;

end.

