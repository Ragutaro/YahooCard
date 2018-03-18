unit Detail;
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils, IniFilesDX, System.IOUtils, System.Types,
  Vcl.Filectrl, Vcl.ExtCtrls, Vcl.ComCtrls, HideListView, Vcl.StdCtrls,
  HideComboBox;

type
  TfrmDetail = class(TForm)
    lvwAllItem: THideListView;
    splVert: TSplitter;
    panRight: TPanel;
    lvwList: THideListView;
    panEdit: TPanel;
    lblUsedPlace: TLabel;
    Label4: TLabel;
    cmbType: THideComboBox;
    Label5: TLabel;
    edtName: TEdit;
    Label6: TLabel;
    edtPrice: TEdit;
    btnAdd: TButton;
    btnUpdate: TButton;
    btnDelete: TButton;
    lblDate: TLabel;
    lblShop: TLabel;
    Label2: TLabel;
    lblAmount: TLabel;
    Label7: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lvwAllItemCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvwListCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvwAllItemMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvwAllItemKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvwListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnAddClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    { Private 宣言 }
    procedure _LoadSettings;
    procedure _SaveSettings;
    procedure _LoadAllItems;
    procedure _LoadDetail;
    procedure _LoadDetailToLvwList(sFileName, sDate, sShop, sAmount: String);
  public
    { Public 宣言 }
  end;

var
  frmDetail: TfrmDetail;

implementation

{$R *.dfm}

uses
  HideUtils,
  Main,
  Utils,
  dp;

procedure TfrmDetail.btnAddClick(Sender: TObject);
var
  item : TListItem;
  sl, sm : TStringList;
  sFileName :  String;
begin
  item := lvwList.Items.Add;
  item.Caption := Trim(cmbType.Text);
  item.SubItems.Add(Trim(edtName.Text));
  item.SubItems.Add(FormatNumber(edtPrice.Text));
  frmMain.lvwMonthly.Selected.ImageIndex := 4;

  sl := TStringList.Create;
  sm := TStringList.Create;
  try
    sFileName := ut_CreateDetailFilePath(lblDate.Caption);
    if FileExists(sFileName) then
      sl.LoadFromFile(sFileName, TEncoding.UTF8);
    sm.Add(lblDate.Caption);
    sm.Add(lblShop.Caption);
    sm.Add(lblAmount.Caption);
    sm.Add(Trim(cmbType.Text));
    sm.Add(Trim(edtName.Text));
    sm.Add(FormatNumber(edtPrice.Text));
    sl.Add(sm.CommaText);
    sl.SaveToFile(sFileName, TEncoding.UTF8);
  finally
    sl.Free;
    sm.Free;
  end;
end;

procedure TfrmDetail.btnDeleteClick(Sender: TObject);
var
  item : TListItem;
  sl, sm : TStringList;
  sType, sGoods, sPrice, sFileName :  String;
  i : Integer;
begin
  item := lvwList.Selected;
  if item <> nil then
  begin
    //現在のデータを取得
    sType := item.Caption;
    sGoods:= item.SubItems[0];
    sPrice:= item.SubItems[1];

    sl := TStringList.Create;
    sm := TStringList.Create;
    try
      sFileName := ut_CreateDetailFilePath(lblDate.Caption);
      sl.LoadFromFile(sFileName, TEncoding.UTF8);
      for i := 0 to sl.Count-1 do
      begin
        sm.CommaText := sl[i];
        if (lblDate.Caption = sm[0]) and (lblShop.Caption = sm[1]) and (lblAmount.Caption = sm[2]) and
           (sType = sm[3]) and (sGoods = sm[4]) and (sPrice = sm[5]) then
        begin
          sl.Delete(i);
          Break;
        end;
      end;
      sl.SaveToFile(sFileName, TEncoding.UTF8);
    finally
      sl.Free;
      sm.Free;
    end;

    //リストから削除
    lvwList.Items.Delete(lvwList.Selected.Index);
    frmMain.lvwMonthly.Selected.ImageIndex := -1;
  end;
end;

procedure TfrmDetail.btnUpdateClick(Sender: TObject);
var
  item : TListItem;
  sl, sm : TStringList;
  sType, sGoods, sPrice, sFileName :  String;
  i : Integer;
begin
  item := lvwList.Selected;
  if item <> nil then
  begin
    //更新前のデータを取得
    sType := item.Caption;
    sGoods:= item.SubItems[0];
    sPrice:= item.SubItems[1];

    sl := TStringList.Create;
    sm := TStringList.Create;
    try
      sFileName := ut_CreateDetailFilePath(lblDate.Caption);
      sl.LoadFromFile(sFileName, TEncoding.UTF8);
      for i := 0 to sl.Count-1 do
      begin
        sm.CommaText := sl[i];
        if (lblDate.Caption = sm[0]) and (lblShop.Caption = sm[1]) and (lblAmount.Caption = sm[2]) and
           (sType = sm[3]) and (sGoods = sm[4]) and (sPrice = sm[5]) then
        begin
          sm.Clear;
          sm.Add(lblDate.Caption);
          sm.Add(lblShop.Caption);
          sm.Add(lblAmount.Caption);
          sm.Add(Trim(cmbType.Text));
          sm.Add(Trim(edtName.Text));
          sm.Add(FormatNumber(edtPrice.Text));
          sl[i] := sm.CommaText;
          Break;
        end;
      end;
      sl.SaveToFile(sFileName, TEncoding.UTF8);
    finally
      sl.Free;
      sm.Free;
    end;

    //リストを更新
    item.Caption := Trim(cmbType.Text);
    item.SubItems[0] := Trim(edtName.Text);
    item.SubItems[1] := FormatNumber(edtPrice.Text);
  end;
end;

procedure TfrmDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  _SaveSettings;
  Release;
  frmDetail := nil;   //フォーム名に変更する
end;

procedure TfrmDetail.FormCreate(Sender: TObject);
begin
  DisableVclStyles(Self);
  _LoadSettings;
  _LoadAllItems;
  _LoadDetail;
end;

procedure TfrmDetail.lvwAllItemCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  lvwAllItem.ColorizeLines(Item, State, DefaultDraw);
end;

procedure TfrmDetail.lvwAllItemKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  lvwAllItemMouseUp(Sender, mbLeft, Shift, 0, 0);
end;

procedure TfrmDetail.lvwAllItemMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  item : TListItem;
  sDate, sShop, sAmount, sFile : String;
begin
  item := lvwAllItem.Selected;
  if item <> nil then
  begin
    lvwList.Items.BeginUpdate;
    lvwList.Items.Clear;
    try
      sDate := item.Caption;
      sShop := item.SubItems[0];
      sAmount := item.SubItems[1];
      //利用日等を表示する
      lblDate.Caption := sDate;
      lblShop.Caption := sShop;
      lblAmount.Caption := sAmount;
      cmbType.Text := '';
      edtName.Text := '';
      edtPrice.Text := '';
      //入力済みのデータを読み込む
      sFile := ut_CreateDetailFilePath(sDate);
      _LoadDetailToLvwList(sFile, sDate, sShop, sAmount);
    finally
      lvwList.Items.EndUpdate;
    end;
  end;
end;

procedure TfrmDetail.lvwListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  lvwList.ColorizeLines(Item, State, DefaultDraw);
end;

procedure TfrmDetail.lvwListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  cmbType.Text := item.Caption;
  edtName.Text := item.SubItems[0];
  edtPrice.Text:= item.SubItems[1];
end;

procedure TfrmDetail._LoadAllItems;
var
  sl, sm : TStringList;
  item : TListItem;
  i : Integer;
begin
  sl := TStringList.Create;
  sm := TStringList.Create;
  try
    sl.LoadFromFile(av.sAllDataFile, TEncoding.UTF8);
    for i := 0 to sl.Count-1 do
    begin
    	sm.CommaText := sl[i];
      item := lvwAllItem.Items.Add;
      item.Caption := sm[0];
      item.SubItems.Add(sm[1]);
      item.SubItems.Add(sm[4]);
    end;
  finally
    sl.Free;
    sm.Free;
  end;
end;

procedure TfrmDetail._LoadDetail;
var
  item : TListItem;
  sDate, sShop, sAmount, sFile : String;
begin
  item := frmMain.lvwMonthly.Selected;
  sDate := item.Caption;
  sShop := item.SubItems[0];
  sAmount := item.SubItems[1];
  //利用日等を表示する
  lblDate.Caption := sDate;
  lblShop.Caption := sShop;
  lblAmount.Caption := sAmount;
  edtPrice.Text := sAmount;
  //入力済みのデータを読み込む
  sFile := ut_CreateDetailFilePath(sDate);
  _LoadDetailToLvwList(sFile, sDate, sShop, sAmount);
end;

procedure TfrmDetail._LoadDetailToLvwList(sFileName, sDate, sShop,
  sAmount: String);
var
  item : TListItem;
  sl, sm : TStringList;
  i : Integer;
begin
  if FileExists(sFileName) then
  begin
    sl := TStringList.Create;
    sm := TStringList.Create;
    try
      sl.LoadFromFile(sFileName, TEncoding.UTF8);
      for i := 0 to sl.Count-1 do
      begin
      	sm.CommaText := sl[i];
        if (sDate = sm[0]) and (sShop = sm[1]) and (sAmount = sm[2]) then
        begin
          item := lvwList.Items.Add;
          item.Caption := sm[3];
          item.SubItems.Add(sm[4]);
          item.SubItems.Add(sm[5]);
        end;
      end;
    finally
      sl.Free;
      sm.Free;
    end;
  end;
end;

procedure TfrmDetail._LoadSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.ReadWindowPosition(Self.Name, Self);
    lvwAllItem.Width := ini.ReadInteger(Self.Name, 'lvwAllItem.Width', lvwAllItem.Width);
    lvwAllItem.Column[0].Width := ini.ReadInteger(Self.Name, 'lvwAllItem.Column[0].Width', lvwAllItem.Column[0].Width);
    lvwAllItem.Column[1].Width := ini.ReadInteger(Self.Name, 'lvwAllItem.Column[1].Width', lvwAllItem.Column[1].Width);
    lvwAllItem.Column[2].Width := ini.ReadInteger(Self.Name, 'lvwAllItem.Column[2].Width', lvwAllItem.Column[2].Width);
    lvwList.Column[0].Width := ini.ReadInteger(Self.Name, 'lvwList.Column[0].Width', lvwList.Column[0].Width);
    lvwList.Column[1].Width := ini.ReadInteger(Self.Name, 'lvwList.Column[1].Width', lvwList.Column[1].Width);
    lvwList.Column[2].Width := ini.ReadInteger(Self.Name, 'lvwList.Column[2].Width', lvwList.Column[2].Width);
    Self.Font.Name := ini.ReadString('General', 'FontName', '游ゴシック Medium');
    Self.Font.Size := ini.ReadInteger('General', 'FontSize', 10);
  finally
    ini.Free;
  end;
end;

procedure TfrmDetail._SaveSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.WriteWindowPosition(Self.Name, Self);
    ini.WriteInteger(Self.Name, 'lvwAllItem.Width', lvwAllItem.Width);
    ini.WriteInteger(Self.Name, 'lvwAllItem.Column[0].Width', lvwAllItem.Column[0].Width);
    ini.WriteInteger(Self.Name, 'lvwAllItem.Column[1].Width', lvwAllItem.Column[1].Width);
    ini.WriteInteger(Self.Name, 'lvwAllItem.Column[2].Width', lvwAllItem.Column[2].Width);
    ini.WriteInteger(Self.Name, 'lvwList.Column[0].Width', lvwList.Column[0].Width);
    ini.WriteInteger(Self.Name, 'lvwList.Column[1].Width', lvwList.Column[1].Width);
    ini.WriteInteger(Self.Name, 'lvwList.Column[2].Width', lvwList.Column[2].Width);
    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

end.
