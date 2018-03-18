unit Main;
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils, IniFilesDX, System.IOUtils, System.Types,
  Vcl.Filectrl, Vcl.ComCtrls, HideListView, Vcl.StdCtrls, Vcl.ExtCtrls,
  HideTreeView, System.ImageList, Vcl.ImgList, Vcl.Menus, TB2Item, SpTBXItem,
  TB2Dock, TB2Toolbar, System.Win.Registry, Winapi.shellapi;

type
  TfrmMain = class(TForm)
    Splitter1: TSplitter;
    panRight: TPanel;
    img16: TImageList;
    popMonths: TPopupMenu;
    panLvw: TPanel;
    lvwList: THideListView;
    tvwMonth: THideTreeView;
    panInfo: TPanel;
    SpTBXDock1: TSpTBXDock;
    img24: TImageList;
    tbrDock1: TSpTBXToolWindow;
    cmbMonth: TComboBox;
    Label1: TLabel;
    btnGetMonthlydata: TButton;
    tbrDock4: TSpTBXToolbar;
    panMonthly: TPanel;
    lvwMonthly: THideListView;
    splMonthly: TSplitter;
    tbrIsGroup: TSpTBXItem;
    tbrDock2: TSpTBXToolWindow;
    Label2: TLabel;
    cmbYear: TComboBox;
    tbrIsExpand: TSpTBXItem;
    btnYahoo: TSpTBXItem;
    tbrGraph: TSpTBXItem;
    SpTBXSeparatorItem1: TSpTBXSeparatorItem;
    popShowDetail: TPopupMenu;
    N1: TMenuItem;
    panMonthlyGoods: TPanel;
    lvwGoods: THideListView;
    lvwPayment: THideListView;
    splGoods: TSplitter;
    popDetail: TPopupMenu;
    popDetail_ShowHeader: TMenuItem;
    tbrDock3: TSpTBXToolWindow;
    lblUpdated: TLabel;
    timLoaded: TTimer;
    popThisMonth: TPopupMenu;
    popShowThisMonth: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lvwListColumnClick(Sender: TObject; Column: TListColumn);
    procedure tvwMonthClick(Sender: TObject);
    procedure tvwMonthKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvwMonthlyColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvwMonthlyDblClick(Sender: TObject);
    procedure lvwMonthlyCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure btnGetMonthlydataClick(Sender: TObject);
    procedure lvwListCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvwPaymentCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure tbrIsGroupClick(Sender: TObject);
    procedure cmbYearClick(Sender: TObject);
    procedure tbrIsExpandClick(Sender: TObject);
    procedure btnYahooClick(Sender: TObject);
    procedure lvwPaymentColumnClick(Sender: TObject; Column: TListColumn);
    procedure tbrGraphClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure lvwMonthlyMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvwMonthlyKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvwGoodsCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure popDetail_ShowHeaderClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure timLoadedTimer(Sender: TObject);
    procedure popShowThisMonthClick(Sender: TObject);
    procedure tvwMonthCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private 宣言 }
    procedure _LoadSettings;
    procedure _SaveSettings;
    procedure _LoadHistory;
    procedure _SaveHistory;
    procedure _GetHtmlData;
    procedure _GetHtmlData_OldData(sl: TStringList);
    procedure _GetHtmlData_NewData(sl: TStringList);
    procedure _LoadTreeview;
    procedure _LoadTreeview_DailyData;
    procedure _LoadTreeview_MonthlyData;
    procedure _CreateMonthList;
    procedure _CreatePayment;
    procedure _LoadYearList;
    procedure _LoadDatFile(sFilename: String);
    procedure _LoadDatFile_lvwList(sl: TStringList);
    procedure _LoadDatFile_tvwMonthly(sl: TStringList);
    procedure _ShowInfomationPanel(const sDefaultStr: String);
    procedure _LoadGoods;
    procedure _ClearMonthlyData;
    procedure _GetDataWhenFirstLoaded;
  public
    { Public 宣言 }
  end;

  TApplicationValues = record
    sAppPath, sHtmlPath, sCachePath, sDatPath, sDetailPath : String;
    sHistoryFile, sAllDataFile, sPaymentFile, sTvwFile : String;
    clTitleBar, clTitleText : TColor;
  end;

  TMonthlyTotal = record
    sMonth : String;
    iTotal, iCount : Integer;
  end;

var
  av : TApplicationValues;
  frmMain: TfrmMain;
  slData, slPay : TStringList;
  sl2016, sl2017, sl2018, sl2019, sl2020 : TStringList;

implementation

{$R *.dfm}

uses
  HideUtils,
  DateUtils,
  Colors,
  Graph,
  Detail,
  Utils,
  ThisMonth,
  dp;

type
  TGroupData = record
    iAmount, iCount : Integer;
  end;

const
  ICO_FOLDER_CLOSE = 0;
  ICO_FOLDER_OPEN  = 1;
  ICO_FILE         = 2;
  ICO_ROOT         = 3;

procedure TfrmMain.btnGetMonthlydataClick(Sender: TObject);
var
  sl : TStringList;
  ms : TMemoryStream;
  sDate : String;
begin
  sDate := ReplaceText(cmbMonth.Text, '/', '');;
  sl := TStringList.Create;
  ms := TMemoryStream.Create;
  try
    _ShowInfomationPanel('取得中...');
    DownloadHttp('https://member1.card.yahoo.co.jp/usage/detail/' + sDate, ms);
    ms.SetSize(ms.Size-106);
    sl.LoadFromStream(ms, TEncoding.UTF8);
    //メンテナンス中の場合
    if ContainsText(sl.Text, 'システムメンテナンスをしています') then
      MessageDlg('システムメンテナンス中のため、データを取得できませんでした。',
                 'システムメンテナンス中', mtWarning, [mbOK])
    else
      sl.SaveToFile(av.sHtmlPath + sDate + '.html');
  finally
    sl.Free;
    ms.Free;
  end;
  _GetHtmlData;
  _LoadDatFile(Format('%s%s.dat', [av.sDatPath, cmbYear.Text]));
  panInfo.Visible := False;
  lblUpdated.Caption := '最終更新日時:' + FormatDateTime('YYYY/MM/DD HH:NN:SS', Now);
end;

procedure TfrmMain.btnYahooClick(Sender: TObject);
var
  s : String;
begin
  s := 'https://member1.card.yahoo.co.jp/usage/detail';
  ShellExecuteW(Self.Handle, 'open', 'iexplore.exe', pwidechar(s), nil, SW_NORMAL);
end;

procedure TfrmMain.cmbYearClick(Sender: TObject);
begin
  _ShowInfomationPanel('');
  _LoadDatFile(Format('%s%s.dat', [av.sDatPath, cmbYear.Text]));
  panInfo.Visible := False;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  _SaveHistory;
  _SaveSettings;
  Release;
  frmMain := nil;   //フォーム名に変更する
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DisableVclStyles(Self, '');
  _LoadSettings;
  _LoadYearList;
  _LoadHistory;
  if FileExists(av.sTvwFile) then
  	tvwMonth.LoadFromFileEx(av.sTvwFile)
  else
    _LoadTreeview;
  _CreateMonthList;
end;

procedure TfrmMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case key of
    char(VK_ESCAPE) :
      begin
        Key := char(0);
        Close;
      end;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  timLoaded.Enabled := True;
end;

procedure TfrmMain.lvwPaymentColumnClick(Sender: TObject; Column: TListColumn);
var
  sArray : array[0..5] of String;
  item : TListItem;
  i : Integer;
begin
  item := lvwPayment.Items[lvwPayment.Items.Count-1];
  sArray[0] := item.Caption;
  for i := 1 to 5 do
    sArray[i] := item.SubItems[i-1];

  lvwPayment.Items.BeginUpdate;
  try
    lvwPayment.Items[lvwPayment.Items.Count-1].Delete;
    lvwPayment.ColumnClickEx(Column, False);
    item := lvwPayment.Items.Add;
    item.Caption := sArray[0];
    for i := 1 to 5 do
      item.SubItems.Add(sArray[i]);
  finally
    lvwPayment.Items.EndUpdate;
  end;
end;

procedure TfrmMain.lvwPaymentCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  lvwPayment.ColorizeLines(Item, State, DefaultDraw);
  if Item.Caption = '合計額' then
  begin
    with Sender.Canvas do
    begin
    	Brush.Style := bsSolid;
      Brush.Color := av.clTitleBar;// $00B43668;
      Font.Color  := av.clTitleText // clWhite;
    end;
  end;
end;

procedure TfrmMain.N1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmDetail, frmDetail);
  frmDetail.ShowModal;
end;

procedure TfrmMain.popDetail_ShowHeaderClick(Sender: TObject);
begin
  lvwGoods.ShowColumnHeaders := Not lvwGoods.ShowColumnHeaders;
end;

procedure TfrmMain.popShowThisMonthClick(Sender: TObject);
begin
  if FindWindowW('TfrmThisMonth', '今月の利用状況') <> 0 then
  begin
    //既に存在する場合
    frmThisMonth._LoadData;
  end
  else
  begin
    Application.CreateForm(TfrmThisMonth, frmThisMonth);
    frmThisMonth.Show;
  end;
end;

procedure TfrmMain.lvwGoodsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  lvwGoods.ColorizeLines(Item, State, DefaultDraw);
end;

procedure TfrmMain.lvwListColumnClick(Sender: TObject; Column: TListColumn);
begin
  Case Column.Index of
    0..2 : lvwList.ColumnClickEx(Column, True);
    3..7 : lvwList.ColumnClickEx(Column, False);
  end;
end;

procedure TfrmMain.lvwListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  lvwList.ColorizeLines(Item, State, DefaultDraw);
end;

procedure TfrmMain.lvwMonthlyColumnClick(Sender: TObject; Column: TListColumn);
var
  item : TListItem;
  s1, s2 : String;
begin
  lvwMonthly.Items.BeginUpdate;
  try
    item := lvwMonthly.Items[lvwMonthly.Items.Count-1];
    s1 := item.Caption;
    s2 := item.SubItems[1];
    item.Delete;
    Case Column.Index of
      0, 1 : lvwMonthly.ColumnClickEx(Column, True);
      2    : lvwMonthly.ColumnClickEx(Column, False);
    end;
    item := lvwMonthly.Items.Add;
    item.Caption := s1;
    item.SubItems.Add('');
    item.SubItems.Add(s2);
    item.ImageIndex := -1;
  finally
    lvwMonthly.Items.EndUpdate;
  end;
end;

procedure TfrmMain.lvwMonthlyCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  lvwMonthly.ColorizeLines(Item, State, DefaultDraw);
  if (Item.Caption = '今月の合計') or (Item.Caption = '今日の合計') then
  begin
    with lvwMonthly.Canvas do
    begin
    	Brush.Style := bsSolid;
      Brush.Color := av.clTitleBar;
      Font.Color  := av.clTitleText;
    end;
  end;
end;

procedure TfrmMain.lvwMonthlyDblClick(Sender: TObject);
var
  item, dstItem : TListItem;
  i, iY : Integer;
begin
  item := lvwMonthly.Selected;
  if item = nil then Exit;

  lvwList.Items.BeginUpdate;
  dstItem := nil;
  try
    for i := 0 to lvwList.Items.Count-1 do
    begin
      dstItem := lvwList.Items[i];
      if (item.Caption = dstItem.Caption) and (item.SubItems[1] = dstItem.SubItems[3]) then
      begin
        lvwList.Groups.Items[dstItem.GroupID].State := [lgsNormal, lgsCollapsible];
        dstItem.Selected := True;
        dstItem.MakeVisible(False);
        Break;
      end;
    end;
  finally
    lvwList.Items.EndUpdate;
  end;
  iY := dstItem.Top - (lvwList.Height div 2);
  if iY > 0 then
  begin
    lvwList.Scroll(0, iY);
  end;
  lvwList.SetFocus;
end;

procedure TfrmMain.lvwMonthlyKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  _LoadGoods;
end;

procedure TfrmMain.lvwMonthlyMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  _LoadGoods;
end;

procedure TfrmMain.tbrGraphClick(Sender: TObject);
begin
  Application.CreateForm(TfrmGraph, frmGraph);
  frmGraph.Show;
end;

procedure TfrmMain.tbrIsExpandClick(Sender: TObject);
var
  gr : TListGroup;
  i : Integer;
begin
  _ShowInfomationPanel('グループを開閉中...');
  lvwList.Items.BeginUpdate;
  for i := 0 to lvwList.Groups.Count-1 do
  begin
    gr := lvwList.Groups[i];
    if lgsNormal in gr.State then
      gr.State := [lgsCollapsed, lgsCollapsible]
    else
      gr.State := [lgsNormal, lgsCollapsible];
  end;
  lvwList.Items.EndUpdate;
  panInfo.Visible := False;
end;

procedure TfrmMain.tbrIsGroupClick(Sender: TObject);
begin
  lvwList.GroupView := Not lvwList.GroupView;
end;

procedure TfrmMain.timLoadedTimer(Sender: TObject);
begin
  _GetDataWhenFirstLoaded;
end;

procedure TfrmMain.tvwMonthClick(Sender: TObject);
var
  n : TTreeNode;
begin
  n := tvwMonth.Selected;
  if n = nil then Exit;

  Case n.ImageIndex of
    0 : _LoadTreeview_MonthlyData;
    2 : _LoadTreeview_DailyData;
    3 : _ClearMonthlyData;
  end;
end;

procedure TfrmMain.tvwMonthCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  tvwMonth.ColorizeNodes(Node, State, DefaultDraw, [fsUnderline]);
end;

procedure TfrmMain.tvwMonthKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  tvwMonthClick(nil);
end;

procedure TfrmMain._ClearMonthlyData;
begin
  lvwMonthly.Items.BeginUpdate;
  lvwMonthly.Items.Clear;
  lvwMonthly.Items.EndUpdate;
  lvwGoods.Items.BeginUpdate;
  lvwGoods.Items.Clear;
  lvwGoods.Items.EndUpdate;
end;

procedure TfrmMain._CreateMonthList;
var
  dMonth : TDate;
  sMax, sNow : String;
  i : Integer;
begin
  sMax := FormatDateTime('YYYY/MM', IncMonth(Now, 1));
  dMonth := StrToDate('2016/03/01');
  for i := 1 to 100 do
  begin
    dMonth := IncMonth(dMonth, 1);
    sNow := FormatDateTime('YYYY/MM', dMonth);
    if sNow > sMax then
      break
    else
    begin
      cmbMonth.Items.Add(sNow);
    end;
  end;
  if FormatDateTime('dd hh', Now) > '12 23' then
    cmbMonth.ItemIndex := cmbMonth.Items.Count-1
  else
    cmbMonth.ItemIndex := cmbMonth.Items.Count-2;
end;

procedure TfrmMain._CreatePayment;
var
  sl, sm : TStringList;
  item : TListItem;
  s : String;
  i, iUsed, iPay, iPaid, iBensai, iChousei : Integer;
begin
  if Not FileExists(av.sPaymentFile) then Exit;

  sl := TStringList.Create;
  sm := TStringList.Create;
  lvwPayment.Items.BeginUpdate;
  lvwPayment.Items.Clear;
  try
    sl.LoadFromFile(av.sPaymentFile, TEncoding.UTF8);
    sl.Sort;
    iUsed := 0;
    iPay  := 0;
    iPaid := 0;
    iBensai := 0;
    iChousei := 0;
    for s in sl do
    begin
      sm.CommaText := s;
      if sm[0] = 'Payment' then
      begin
        if (cmbYear.Text = 'All') or (cmbYear.Text = LeftStr(sm[1], 4)) then
        begin
          item := lvwPayment.Items.Add;
          item.Caption := sm[1];
          item.SubItems.Add('*');
          item.SubItems.Add(sm[2]);
          item.SubItems.Add(sm[3]);
          item.SubItems.Add(sm[4]);
          item.SubItems.Add(sm[5]);
        end;
      end
      else
      begin
        for i := 0 to lvwPayment.Items.Count-1 do
        begin
          item := lvwPayment.Items[i];
          if item.Caption = sm[1] then
          begin
            item.SubItems[0] := FormatFloat('#,###', StrToIntDefEx(item.SubItems[0], 0) + StrToIntEx(sm[2]));
            Break;
          end;
        end;
      end;
    end;

    //合計額の作成
    for i := 0 to lvwPayment.Items.Count-1 do
    begin
      item := lvwPayment.Items[i];
      iUsed     := iUsed + StrToIntDefEx(item.SubItems[0], 0);
      iPay      := iPay  + StrToIntDefEx(item.SubItems[1], 0);
      iPaid     := iPaid + StrToIntDefEx(item.SubItems[2], 0);
      iBensai   := iBensai + StrToIntDefEx(item.SubItems[3], 0);
      iChousei  := iChousei + StrToIntDefEx(item.SubItems[4], 0);
    end;
    item := lvwPayment.Items.Add;
    item.Caption := '合計額';
    item.SubItems.Add(FormatFloat('#,###', iUsed));
    item.SubItems.Add(FormatFloat('#,###', iPay));
    item.SubItems.Add(FormatFloat('#,###', iPaid));
    item.SubItems.Add(FormatFloat('#,##0', iBensai));
    item.SubItems.Add(FormatFloat('#,##0', iChousei));
  finally
    sl.Free;
    sm.Free;
    lvwPayment.Items.EndUpdate;
  end;

end;

procedure TfrmMain._GetDataWhenFirstLoaded;
var
  ini : TMemIniFile;
  sDate : String;
begin
  timLoaded.Enabled := False;
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    sDate := ini.ReadString(Self.Name, 'NextDate', DateToStr(Today));
    if (sDate = DateToStr(Now)) and (HourOf(Now) > 6) then
    begin
      btnGetMonthlydataClick(nil);
      ini.WriteString(Self.Name, 'NextDate', DateToStr(Today + 1));
    end;
  finally
    ini.UpdateFile;
    ini.Free;
  end;
end;

procedure TfrmMain._GetHtmlData;
var
  sDyn : TStringDynArray;
  sl : TStringList;
  sFile : String;
begin
  sDyn   := TDirectory.GetFiles(av.sHtmlPath);
  sl     := TStringList.Create;
  slData := TStringList.Create;
  slPay  := TStringList.Create;
  sl2016 := TStringList.Create;
  sl2017 := TStringList.Create;
  sl2018 := TStringList.Create;
  sl2019 := TStringList.Create;
  sl2020 := TStringList.Create;
  try
    slPay.Add('Payment,2016/03,*,*,*,*');
    for sFile in sDyn do
    begin
      panInfo.Caption := ExtractFileName(sFile) + 'を読み込み中...';
      Application.ProcessMessages;
      sl.LoadFromFile(sFile, TEncoding.UTF8);
      //ログインしてない場合
      if Pos('ログインしたままにする', sl.Text) > 0 then
      begin
        MessageDlg('ログアウトしていますので、IEでログインしてください。',
                   'ログアウトしています。', mtWarning, [mbOK]);
        DeleteFileW(pwidechar(sFile));
        Exit;
      end;

      //古いデータが最新のデータかを判別し、処理を振り分ける。
      if Pos('<td class="small first">', sl.Text) > 0 then
        //古いデータ
        _GetHtmlData_OldData(sl)
      else
        //最新データ
        _GetHtmlData_NewData(sl);
    end;
    slData.SaveToFile(av.sAllDataFile, TEncoding.UTF8);
    slPay.SaveToFile(av.sPaymentFile, TEncoding.UTF8);
    //年別に保存する
    if sl2016.Count > 0 then sl2016.SaveToFile(av.sDatPath + '2016.dat', TEncoding.UTF8);
    if sl2017.Count > 0 then sl2017.SaveToFile(av.sDatPath + '2017.dat', TEncoding.UTF8);
    if sl2018.Count > 0 then sl2018.SaveToFile(av.sDatPath + '2018.dat', TEncoding.UTF8);
    if sl2019.Count > 0 then sl2019.SaveToFile(av.sDatPath + '2019.dat', TEncoding.UTF8);
    if sl2020.Count > 0 then sl2020.SaveToFile(av.sDatPath + '2020.dat', TEncoding.UTF8);
  finally
    sl.Free;
    slData.Free;
    slPay.Free;
    sl2016.Free;
    sl2017.Free;
    sl2018.Free;
    sl2019.Free;
    sl2020.Free;
  end;
end;

procedure TfrmMain._GetHtmlData_NewData(sl: TStringList);
var
  Buf : array [0 .. 1023] of Char;
  sm : TStringList;
  sDate, sName, sWho, sCount, sAmount, sCost, sTotal, sMonthTotal, sNextMonth, sTmp : String;
  i : Integer;
begin
  //月が変わっても、12日頃までは再新月に切り替わらないため、
  //ここで判断して抜ける。
  if ContainsText(sl.Text, 'ご利用明細はありません') then
    Exit;

  sm := TStringList.Create;
  try
    for i := 0 to sl.Count-1 do
    begin
      if ContainsText(sl[i], '<td class="small gray">') then
      begin
        sDate := RemoveHTMLTags(sl[i]);
        if sDate <> '' then
        begin
          sDate := FormatDateTime('YYYY/MM/DD', StrToDate(sDate));
          //使用場所
          sName   := RemoveHTMLTags(sl[i+1]);
          LCMapString(GetUserDefaultLCID, LCMAP_FULLWIDTH, PChar(sName), Length(sName)+1, Buf, 1024);
          sName := ConvertMBENtoSBENW(String(Buf));
          //使用者
          sWho    := RemoveHTMLTags(sl[i+2]);
          //支払い回数
          sCount  := RemoveHTMLTags(sl[i+4]);
          //利用金額
          sAmount := RemoveRight(RemoveHTMLTags(sl[i+3]), 1);
          //手数料
          sCost   := '*';
          //支払総額　
          sTotal  := '*';
          //当月支払総額
          sMonthTotal := '*';
          //繰り越し
          sNextMonth  := '*';

          sm.Clear;
          sm.Add(sDate);
          sm.Add(sName);
          sm.Add(sWho);
          sm.Add(sCount);
          sm.Add(sAmount);
          sm.Add(sCost);
          sm.Add(sTotal);
          sm.Add(sMonthTotal);
          sm.Add(sNextMonth);
          slData.Add(sm.CommaText);

          sTmp := LeftStr(sDate, 4);
          if sTmp = '2016' then
            sl2016.Add(sm.CommaText)
          else if sTmp = '2017' then
            sl2017.Add(sm.CommaText)
          else if sTmp = '2018' then
            sl2018.Add(sm.CommaText)
          else if sTmp = '2019' then
            sl2019.Add(sm.CommaText)
          else if sTmp = '2020' then
            sl2020.Add(sm.CommaText);

          //利用額
          sm.Clear;
          sm.Add('Used');
          sm.Add(RemoveRight(sDate, 3));
          sm.Add(sAmount);
          slPay.Add(sm.CommaText);
        end;
      end;
    end;
    //再新月を追加
    sTmp := CopyStr(sl.Text, '<div class="mainTab"', '</div>');
    sTmp := RemoveHTMLTags(CopyStr(sTmp, '<li class', '月'));
    sTmp := FormatFloat('0#', StrToInt(sTmp));
//    if sTmp = '01' then
//      sDate := FormatDateTime('YYYY/', IncYear(Now, 1)) + sTmp
//    else
      sDate := FormatDateTime('YYYY/', Now) + sTmp;
    sm.Clear;
    sm.Add('Payment');
    sm.Add(sDate);
    sm.Add('*');
    sm.Add('*');
    sm.Add('*');
    sm.Add('*');
    slPay.Add(sm.CommaText);
  finally
    sm.Free;
  end;
end;

procedure TfrmMain._GetHtmlData_OldData(sl: TStringList);
var
  Buf : array [0 .. 1023] of Char;
  sm : TStringList;
  sDate, sName, sWho, sCount, sAmount, sCost, sTotal, sMonthTotal, sNextMonth, sTmp : String;
  sPaid, sBensai, sChousei : String;
  i : Integer;
  d : TDate;
begin
  sm := TStringList.Create;
  try
    for i := 0 to sl.Count-1 do
    begin
      if ContainsText(sl[i], '<td class="small first">') then
      begin
        sDate := RemoveHTMLTags(ReplaceText(sl[i+1], '<br>', '/'));
        if sDate <> '' then
        begin
          sDate := FormatDateTime('YYYY/MM/DD', StrToDate(sDate));
          //使用場所
          sName   := RemoveHTMLTags(sl[i+2]);
          LCMapString(GetUserDefaultLCID, LCMAP_FULLWIDTH, PChar(sName), Length(sName)+1, Buf, 1024);
          sName := ConvertMBENtoSBENW(String(Buf));
          //使用者
          sWho    := RemoveHTMLTags(sl[i+3]);
          //支払い回数
          sCount  := RemoveHTMLTags(sl[i+4]);
          //利用金額
          sAmount := RemoveHTMLTags(sl[i+5]);
          //手数料
          sCost   := RemoveHTMLTags(sl[i+6]);
          //支払総額　
          sTotal  := RemoveHTMLTags(sl[i+7]);
          //当月支払総額
          sMonthTotal := RemoveHTMLTags(sl[i+8]);
          //繰り越し
          sNextMonth  := RemoveHTMLTags(sl[i+9]);

          sm.Clear;
          sm.Add(sDate);
          sm.Add(sName);
          sm.Add(sWho);
          sm.Add(sCount);
          sm.Add(sAmount);
          sm.Add(sCost);
          sm.Add(sTotal);
          sm.Add(sMonthTotal);
          sm.Add(sNextMonth);
          slData.Add(sm.CommaText);

          sTmp := LeftStr(sDate, 4);
          if sTmp = '2016' then
            sl2016.Add(sm.CommaText)
          else if sTmp = '2017' then
            sl2017.Add(sm.CommaText)
          else if sTmp = '2018' then
            sl2018.Add(sm.CommaText)
          else if sTmp = '2019' then
            sl2019.Add(sm.CommaText)
          else if sTmp = '2020' then
            sl2020.Add(sm.CommaText);

          //利用額
          sm.Clear;
          sm.Add('Used');
          sm.Add(RemoveRight(sDate, 3));
          sm.Add(sAmount);
          slPay.Add(sm.CommaText);
        end;
      end;
    end;
    //当月請求金額の取得
    sTmp := CopyStr(sl.Text, '<td class="center">', '</td>');
    sDate := RemoveHTMLTags(sTmp) + '/1';
    d := StrToDate(sDate);
    sDate := FormatDateTime('YYYY/MM', d);
    sTmp := CopyStr(sl.Text, '<!-- ご利用総合可能枠 -->', '</table>');
    sAmount := RemoveHTMLTags(CopyStr(sTmp, '<td class="last right">', '円'));
    sPaid   := RemoveHTMLTags(CopyStrFromN(sTmp, '<td class="last right">', '円', 2));
    sBensai := RemoveHTMLTags(CopyStrFromN(sTmp, '<td class="last right">', '円', 3));
    sChousei:= RemoveHTMLTags(CopyStrFromN(sTmp, '<td class="last right">', '円', 4));
    sm.Clear;
    sm.Add('Payment');
    sm.Add(sDate);
    sm.Add(sAmount);
    sm.Add(sPaid);
    sm.Add(sBensai);
    sm.Add(sChousei);
    slPay.Add(sm.CommaText);
  finally
    sm.Free;
  end;
end;

procedure TfrmMain._LoadDatFile(sFilename: String);
var
  sl : TStringList;
begin
  lvwList.Items.BeginUpdate;
  lvwList.Items.Clear;
  lvwList.Groups.BeginUpdate;
  lvwList.Groups.Clear;
  tvwMonth.Items.BeginUpdate;
  tvwMonth.Items.Clear;
  lvwMonthly.Items.BeginUpdate;
  lvwMonthly.Items.Clear;
  lvwPayment.Items.BeginUpdate;
  lvwPayment.Items.Clear;
  sl := TStringList.Create;
  try
    sl.LoadFromFile(sFilename, TEncoding.UTF8);
    _LoadDatFile_lvwList(sl);
    _LoadDatFile_tvwMonthly(sl);
    _CreatePayment;
  finally
    sl.Free;
    lvwMonthly.ShowLastItem;
    lvwPayment.ShowLastItem;
    lvwList.Items.EndUpdate;
    tvwMonth.Items.EndUpdate;
    lvwMonthly.Items.EndUpdate;
    lvwPayment.Items.EndUpdate;
  end;
end;

procedure TfrmMain._LoadDatFile_lvwList(sl: TStringList);
var
  gd : array of TGroupData;
  gr : TListGroup;
  item : TListItem;
  sm, slGroup : TStringList;
  i, iGroupID : Integer;
begin
  panInfo.Caption := 'リストビューを作成中...';
  Application.ProcessMessages;
  sm := TStringList.Create;
  slGroup := TStringList.Create;
  try
    //まずはグループリストを作成し、ソートする
    for i := 0 to sl.Count-1 do
    begin
      sm.CommaText := sl[i];
      if slGroup.IndexOf(sm[1]) = -1 then
      	slGroup.Add(sm[1]);
    end;
    slGroup.Sort;
    SetLength(gd, slGroup.Count);
    //次に、Group を作成する
    for i := 0 to slGroup.Count-1 do
    begin
      gr := lvwList.Groups.Add;
      gr.Header   := slGroup[i];
      gr.Subtitle := '';
      gr.GroupID  := i;
      gr.State    := [lgsCollapsed, lgsCollapsible];
      gr.HeaderAlign := taCenter;
      gr.FooterAlign := taRightJustify;
    end;
    //次に、ListItemを追加していく
    for i := 0 to sl.Count-1 do
    begin
      sm.CommaText := sl[i];
      iGroupID := slGroup.IndexOf(sm[1]);
      item := lvwList.Items.Add;
      item.Caption := sm[0];
      item.SubItems.Add(sm[1]);
      item.SubItems.Add(sm[2]);
      item.SubItems.Add(sm[3]);
      item.SubItems.Add(sm[4]);
      item.SubItems.Add(sm[5]);
      item.SubItems.Add(sm[6]);
      item.SubItems.Add(sm[7]);
      item.SubItems.Add(sm[8]);
      item.GroupID := iGroupID;
      gd[iGroupID].iAmount := gd[iGroupID].iAmount + StrToIntDefEx(sm[4], 0);
      gd[iGroupID].iCount  := gd[iGroupID].iCount + 1;
    end;
    //Groupに情報を付加する
    for i := 0 to high(gd) do
    begin
      gr := lvwList.Groups[i];
      gr.Header := ConvertSBJPtoMBJP(gr.Header);
      gr.Subtitle := FormatFloat('#,###', gd[i].iAmount) + ' / ' + IntToStr(gd[i].iCount) + '回';
    end;
  finally
    sm.Free;
    slGroup.Free;
  end;
end;

procedure TfrmMain._LoadDatFile_tvwMonthly(sl: TStringList);
var
  node : TTreeNode;
  sm, slNode : TStringList;
  s, sDate : String;
  iNode, i : Integer;
begin
  panInfo.Caption := '年月ツリーを作成中...';
  Application.ProcessMessages;
  sm := TStringList.Create;
  slNode := TStringList.Create;
  try
    for s in sl do
    begin
      sm.CommaText := s;
      if slNode.IndexOf(LeftStr(sm[0], 7)) = -1 then
        slNode.Add(sm[0]);
    end;

    //Treeviewに追加
    node := tvwMonth.Items.Add(nil, '年月日');
    node.ImageIndex := ICO_ROOT;
    node.SelectedIndex := ICO_ROOT;

    for s in slNode do
    begin
      sDate := LeftStr(s, 7);
      iNode := tvwMonth.IndexofSameNode(tvwMonth.Items[0], sDate);
      if iNode = -1 then
      begin
        node := tvwMonth.Items.AddChild(tvwMonth.Items[0], sDate);
        node.ImageIndex    := ICO_FOLDER_CLOSE;
        node.SelectedIndex := ICO_FOLDER_OPEN;
        node := tvwMonth.Items.AddChild(node, RightStr(s, 2));
        node.ImageIndex    := ICO_FILE;
        node.SelectedIndex := ICO_FILE;
      end else
      begin
        for i := 0 to tvwMonth.Items.Count-1 do
        begin
          node := tvwMonth.Items[i];
          if (node.Text = sDate) and (Not tvwMonth.IsExistSameNode(node, RightStr(s, 2))) then
          begin
            node := tvwMonth.Items.AddChild(node, RightStr(s, 2));
            node.ImageIndex    := ICO_FILE;
            node.SelectedIndex := ICO_FILE;
            Break;
          end;
        end;
      end;
    end;
    tvwMonth.Items[0].Expanded := True;
  finally
    sm.Free;
    slNode.Free;
  end;
end;

procedure TfrmMain._LoadGoods;
var
  item : TListItem;
  sl, sm : TStringList;
  sFileName, sTmp, sDate, sShop, sPrice : String;
begin
  item := lvwMonthly.Selected;
  if item = nil then Exit;

  sDate := item.Caption;
  sShop := item.SubItems[0];
  sPrice:= item.SubItems[1];
  sl := TStringList.Create;
  sm := TStringList.Create;
  lvwGoods.Items.BeginUpdate;
  lvwGoods.Items.Clear;
  try
    sFileName := ut_CreateDetailFilePath(sDate);
    if FileExists(sFileName) then
    begin
    	sl.LoadFromFile(sFileName, TEncoding.UTF8);
      for sTmp in sl do
      begin
        sm.CommaText := sTmp;
        if (sDate = sm[0]) and (sShop = sm[1]) and (sPrice = sm[2]) then
        begin
          item := lvwGoods.Items.Add;
          item.Caption := sm[3];
          item.SubItems.Add(sm[4]);
          item.SubItems.Add(sm[5]);
        end;
      end;
    end;
  finally
    sl.Free;
    sm.Free;
    lvwGoods.Items.EndUpdate;
  end;
end;

procedure TfrmMain._LoadHistory;
var
  sl, sm : TStringList;
  item : TListItem;
  gr : TListGroup;
  i : Integer;
begin
  if Not FileExists(av.sHistoryFile) then Exit;

  sl := TStringList.Create;
  sm := TStringList.Create;
  try
    sl.LoadFromFile(av.sHistoryFile, TEncoding.UTF8);
    for i := 0 to sl.Count-1 do
    begin
      sm.CommaText := sl[i];
      if sm[0] = 'Group' then
      begin
        gr := lvwList.Groups.Add;
        gr.Header := sm[2];
        gr.Subtitle := sm[3];
        gr.GroupID := StrToInt(sm[1]);
        gr.HeaderAlign := taCenter;
        if sm[5] = 'Expanded' then
          gr.State := [lgsNormal, lgsCollapsible]
        else
          gr.State := [lgsCollapsed, lgsCollapsible];
      end
      else if sm[0] = 'ListItem' then
      begin
        item := lvwList.Items.Add;
        item.Caption := sm[2];
        item.SubItems.Add(sm[3]);
        item.SubItems.Add(sm[4]);
        item.SubItems.Add(sm[5]);
        item.SubItems.Add(sm[6]);
        item.SubItems.Add(sm[7]);
        item.SubItems.Add(sm[8]);
        item.SubItems.Add(sm[9]);
        item.SubItems.Add(sm[10]);
        item.GroupID := StrToInt(sm[1]);
      end
      else if sm[0] = 'Monthly' then
      begin
        item := lvwMonthly.Items.Add;
        item.Caption := sm[1];
        item.SubItems.Add(sm[2]);
        item.SubItems.Add(sm[3]);
        item.ImageIndex := StrToInt(sm[4]);
      end
      else if sm[0] = 'Payment' then
      begin
        item := lvwPayment.Items.Add;
        item.Caption := sm[1];
        item.SubItems.Add(sm[2]);
        item.SubItems.Add(sm[3]);
        item.SubItems.Add(sm[4]);
        item.SubItems.Add(sm[5]);
        item.SubItems.Add(sm[6]);
      end;
    end;
    lvwMonthly.ShowLastItem;
    lvwPayment.ShowLastItem;
  finally
    sl.Free;
    sm.Free;
  end;
end;

procedure TfrmMain._LoadSettings;
var
  ini : TMemIniFile;
  i : Integer;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.ReadWindowPosition(Self.Name, Self);
    panLvw.Width := ini.ReadInteger(Self.Name, 'panLvw.Width', panLvw.Width);
    for i := 0 to 8 do
    begin
    	lvwList.Column[i].Width := ini.ReadInteger(Self.Name,
                                                 Format('lvwList.Column[%d].width', [i]),
                                                 lvwList.Column[i].Width);
    end;
    for i := 0 to 2 do
    begin
    	lvwMonthly.Column[i].Width := ini.ReadInteger(Self.Name,
                                                    Format('lvwMonthly.Column[%d].width', [i]),
                                                    lvwMonthly.Column[i].Width);
    end;
    lvwMonthly.Height := ini.ReadInteger(Self.Name, 'lvwMonthly.Height', lvwMonthly.Height);
    for i := 0 to 5 do
    begin
    	lvwPayment.Column[i].Width := ini.ReadInteger(Self.Name,
                                                    Format('lvwPayment.Column[%d].width', [i]),
                                                    lvwPayment.Column[i].Width);
    end;
    lvwGoods.Height := ini.ReadInteger(Self.Name, 'lvwGoods.Height', lvwGoods.Height);
    for i := 0 to 2 do
    begin
    	lvwGoods.Column[i].Width := ini.ReadInteger(Self.Name,
                                                  Format('lvwGoods.Column[%d].width', [i]),
                                                  lvwGoods.Column[i].Width);
    end;
    lvwGoods.ShowColumnHeaders := ini.ReadBool(Self.Name, 'lvwGoods.ShowColumnHeader', True);
    tbrDock1.DockPos := ini.ReadInteger(Self.Name, 'tbrDock1.DockPos', tbrDock1.DockPos);
    tbrDock2.DockPos := ini.ReadInteger(Self.Name, 'tbrDock2.DockPos', tbrDock2.DockPos);
    tbrDock3.DockPos := ini.ReadInteger(Self.Name, 'tbrDock3.DockPos', tbrDock3.DockPos);
    tbrDock4.DockPos := ini.ReadInteger(Self.Name, 'tbrDock4.DockPos', tbrDock4.DockPos);
    lblUpdated.Caption := ini.ReadString(Self.Name, 'lblUpdated.Caption', '最終更新日時:');
    Self.Font.Name := ini.ReadString('General', 'FontName', '游ゴシック Medium');
    Self.Font.Size := ini.ReadInteger('General', 'FontSize', 10);
  finally
    ini.Free;
  end;
  av.sAppPath     := ExtractFilePath(Application.ExeName);
  av.sHtmlPath    := av.sAppPath + 'html\';
  av.sCachePath   := av.sAppPath + 'cache\';
  av.sDatPath     := av.sAppPath + 'dat\';
  av.sDetailPath  := av.sAppPath + 'detail\';
  av.sHistoryFile := av.sCachePath + 'History.txt';
  av.sAllDataFile := av.sDatPath   + 'All.dat';
  av.sPaymentFile := av.sCachePath + 'PaymentData.txt';
  av.sTvwFile     := av.sCachePath + 'tvwData.txt';
  av.clTitleBar   := GetTitlebarColor;
  av.clTitleText  := SetTitlebarCaptionColor(av.clTitleBar);
end;

procedure TfrmMain._LoadTreeview;
var
  node : TTreeNode;
  sl, sm, slNode : TStringList;
  s, sDate : String;
  iNode, i : Integer;
begin
  tvwMonth.Items.BeginUpdate;
  tvwMonth.Items.Clear;
  sl := TStringList.Create;
  sm := TStringList.Create;
  slNode := TStringList.Create;
  try
    sl.LoadFromFile(av.sAllDataFile, TEncoding.UTF8);
    for s in sl do
    begin
      sm.CommaText := s;
      if slNode.IndexOf(LeftStr(sm[0], 7)) = -1 then
        slNode.Add(sm[0]);
    end;

    //Treeviewに追加
    node := tvwMonth.Items.Add(nil, '年月日');
    node.ImageIndex := ICO_ROOT;
    node.SelectedIndex := ICO_ROOT;

    for s in slNode do
    begin
      sDate := LeftStr(s, 7);
      iNode := tvwMonth.IndexofSameNode(tvwMonth.Items[0], sDate);
      if iNode = -1 then
      begin
        node := tvwMonth.Items.AddChild(tvwMonth.Items[0], sDate);
        node.ImageIndex    := ICO_FOLDER_CLOSE;
        node.SelectedIndex := ICO_FOLDER_OPEN;
        node := tvwMonth.Items.AddChild(node, RightStr(s, 2));
        node.ImageIndex    := ICO_FILE;
        node.SelectedIndex := ICO_FILE;
      end else
      begin
        for i := 0 to tvwMonth.Items.Count-1 do
        begin
          node := tvwMonth.Items[i];
          if (node.Text = sDate) and (Not tvwMonth.IsExistSameNode(node, RightStr(s, 2))) then
          begin
            node := tvwMonth.Items.AddChild(node, RightStr(s, 2));
            node.ImageIndex    := ICO_FILE;
            node.SelectedIndex := ICO_FILE;
            Break;
          end;
        end;
      end;
    end;
    tvwMonth.Items[0].Expanded := True;
  finally
    sl.Free;
    sm.Free;
    slNode.Free;
    tvwMonth.Items.EndUpdate;
  end;
end;

procedure TfrmMain._LoadTreeview_DailyData;
var
  n : TTreeNode;
  item : TListItem;
  sl, sm, sn, so : TStringList;
  s, sFile, sFileDetail : String;
  iAmount : Integer;
begin
  n := tvwMonth.Selected;
  if n = nil then Exit;

  iAmount := 0;
  lvwMonthly.Items.BeginUpdate;
  lvwMonthly.Items.Clear;
  lvwGoods.Items.BeginUpdate;
  lvwGoods.Items.Clear;
  sl := TStringList.Create;
  sm := TStringList.Create;
  sn := TStringList.Create;
  so := TStringList.Create;
  try
    if cmbYear.Text = 'All' then
      sFile := av.sDatPath + 'All.dat'
    else
      sFile := Format('%s%s.dat', [av.sDatPath, cmbYear.Text]);

    sFileDetail := ut_CreateDetailFilePath(tvwMonth.Selected.Parent.Text);
    if FileExists(sFileDetail) then
      sn.LoadFromFile(sFileDetail, TEncoding.UTF8);

    sl.LoadFromFile(sFile, TEncoding.UTF8);
    for s in sl do
    begin
      sm.CommaText := s;
      if sm[0] = n.Parent.Text + '/' + n.Text then
      begin
        item := lvwMonthly.Items.Add;
        item.Caption := sm[0];
        item.SubItems.Add(sm[1]);
        item.SubItems.Add(sm[4]);
        iAmount := iAmount + StrToIntEx(sm[4]);
        item.ImageIndex := -1;

        so.Clear;
        so.Add(sm[0]);
        so.Add(sm[1]);
        so.Add(sm[4]);
        if Pos(so.CommaText, sn.Text) > 0 then
          item.ImageIndex := 4;
      end;
    end;
    item := lvwMonthly.Items.Add;
    item.Caption := '今日の合計';
    item.SubItems.Add('');
    item.SubItems.Add(FormatFloat('#,###', iAmount));
    item.ImageIndex := -1;
  finally
    sl.Free;
    sm.Free;
    sn.Free;
    so.Free;
    lvwMonthly.Items.EndUpdate;
    lvwGoods.Items.EndUpdate;
  end;
end;

procedure TfrmMain._LoadTreeview_MonthlyData;
var
  n : TTreeNode;
  item : TListItem;
  sl, sm, sn, so : TStringList;
  s, sFile, sFileDetail : String;
  iAmount : Integer;
begin
  n := tvwMonth.Selected;
  if n = nil then Exit;

  iAmount := 0;
  lvwMonthly.Items.BeginUpdate;
  lvwMonthly.Items.Clear;
  lvwGoods.Items.BeginUpdate;
  lvwGoods.Items.Clear;
  sl := TStringList.Create;
  sm := TStringList.Create;
  sn := TStringList.Create;
  so := TStringList.Create;
  try
    if cmbYear.Text = 'All' then
      sFile := av.sDatPath + 'All.dat'
    else
      sFile := Format('%s%s.dat', [av.sDatPath, cmbYear.Text]);

    //購入商品記録ファイルを読み込む
    sFileDetail := ut_CreateDetailFilePath(tvwMonth.Selected.Text);

    if FileExists(sFileDetail) then
      sn.LoadFromFile(sFileDetail, TEncoding.UTF8);

    sl.LoadFromFile(sFile, TEncoding.UTF8);
    for s in sl do
    begin
      sm.CommaText := s;
      if LeftStr(sm[0], 7) = n.Text then
      begin
        item := lvwMonthly.Items.Add;
        item.Caption := sm[0];
        item.SubItems.Add(sm[1]);
        item.SubItems.Add(sm[4]);
        item.ImageIndex := -1;
        iAmount := iAmount + StrToIntEx(sm[4]);

        so.Clear;
        so.Add(sm[0]);
        so.Add(sm[1]);
        so.Add(sm[4]);
        if Pos(so.CommaText, sn.Text) > 0 then
          item.ImageIndex := 4;
      end;
    end;
    item := lvwMonthly.Items.Add;
    item.Caption := '今月の合計';
    item.SubItems.Add(Format('利用回数: %d回', [lvwMonthly.items.count-1]));
    item.SubItems.Add(FormatFloat('#,###', iAmount));
    item.ImageIndex := -1;
  finally
    sl.Free;
    sm.Free;
    sn.Free;
    so.Free;
    lvwMonthly.ShowLastItem;
    lvwMonthly.Items.EndUpdate;
    lvwGoods.Items.EndUpdate;
  end;
end;

procedure TfrmMain._LoadYearList;
var
  ini : TMemIniFile;
  sDyn : TStringDynArray;
  s : String;
begin
  sDyn := TDirectory.GetFiles(av.sDatPath);
  for s in sDyn do
  begin
    cmbYear.Items.Add(ExtractFileBody(s));
  end;
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    cmbYear.ItemIndex := ini.ReadInteger(Self.Name, 'cmbYear.ItemIndex', cmbYear.Items.Count-1);
  finally
    ini.Free;
  end;
end;

procedure TfrmMain._SaveHistory;
var
  item : TListItem;
  gr : TListGroup;
  sl, sm : TStringList;
  i : Integer;
begin
  sl := TStringList.Create;
  sm := TStringList.Create;
  try
    //グループの保存
    for i := 0 to lvwList.Groups.Count-1 do
    begin
      gr := lvwList.Groups[i];
      sl.Clear;
      sl.Add('Group');
      sl.Add(IntToStr(gr.GroupID));
      sl.Add(gr.Header);
      sl.Add(gr.Subtitle);
      sl.Add(gr.Footer);
      if lgsCollapsed in gr.State then
        sl.Add('Closed')
      else
        sl.Add('Expanded');
      sm.Add(sl.CommaText);
    end;
    //リストの保存
    for i := 0 to lvwList.Items.Count-1 do
    begin
      item := lvwList.Items[i];
      sl.Clear;
      sl.Add('ListItem');
      sl.Add(IntToStr(item.GroupID));
      sl.Add(item.Caption);
      sl.Add(item.SubItems[0]);
      sl.Add(item.SubItems[1]);
      sl.Add(item.SubItems[2]);
      sl.Add(item.SubItems[3]);
      sl.Add(item.SubItems[4]);
      sl.Add(item.SubItems[5]);
      sl.Add(item.SubItems[6]);
      sl.Add(item.SubItems[7]);
      sm.Add(sl.CommaText);
    end;
    //Payment
    for i := 0 to lvwPayment.Items.Count-1 do
    begin
      item := lvwPayment.Items[i];
      sl.Clear;
      sl.Add('Payment');
      sl.Add(item.Caption);
      sl.Add(item.SubItems[0]);
      sl.Add(item.SubItems[1]);
      sl.Add(item.SubItems[2]);
      sl.Add(item.SubItems[3]);
      sl.Add(item.SubItems[4]);
      sm.Add(sl.CommaText);
    end;
    //Monthly
    for i := 0 to lvwMonthly.Items.Count-1 do
    begin
      item := lvwMonthly.Items[i];
      sl.Clear;
      sl.Add('Monthly');
      sl.Add(item.Caption);
      sl.Add(item.SubItems[0]);
      sl.Add(item.SubItems[1]);
      sl.Add(IntToStr(item.ImageIndex));
      sm.Add(sl.CommaText);
    end;
    sm.SaveToFile(av.sHistoryFile, TEncoding.UTF8);
  finally
    sl.Free;
    sm.Free;
  end;
  tvwMonth.SaveToFileEx(av.sTvwFile);
end;

procedure TfrmMain._SaveSettings;
var
  ini : TMemIniFile;
  i : Integer;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.WriteWindowPosition(Self.Name, Self);
    ini.WriteInteger(Self.Name, 'panLvw.Width', panLvw.Width);
    ini.WriteInteger(Self.Name, 'lvwMonthly.Height', lvwMonthly.Height);
    ini.WriteInteger(Self.Name, 'lvwGoods.Height', lvwGoods.Height);
    for i := 0 to 8 do
      ini.WriteInteger(Self.Name, Format('lvwList.Column[%d].width', [i]), lvwList.Column[i].Width);
    for i := 0 to 2 do
      ini.WriteInteger(Self.Name, Format('lvwMonthly.Column[%d].width', [i]), lvwMonthly.Column[i].Width);
    for i := 0 to 5 do
      ini.WriteInteger(Self.Name, Format('lvwPayment.Column[%d].width', [i]), lvwPayment.Column[i].Width);
    for i := 0 to 2 do
      ini.WriteInteger(Self.Name, Format('lvwGoods.Column[%d].width', [i]), lvwGoods.Column[i].Width);
    ini.WriteBool(Self.Name, 'lvwGoods.ShowColumnHeader', lvwGoods.ShowColumnHeaders);
    ini.WriteInteger(Self.Name, 'cmbYear.ItemIndex', cmbYear.ItemIndex);
    ini.WriteString(Self.Name, 'lblUpdated.Caption', lblUpdated.Caption);
    ini.WriteInteger(Self.Name, 'tbrDock1.DockPos', tbrDock1.DockPos);
    ini.WriteInteger(Self.Name, 'tbrDock2.DockPos', tbrDock2.DockPos);
    ini.WriteInteger(Self.Name, 'tbrDock3.DockPos', tbrDock3.DockPos);
    ini.WriteInteger(Self.Name, 'tbrDock4.DockPos', tbrDock4.DockPos);
    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

procedure TfrmMain._ShowInfomationPanel(const sDefaultStr: String);
begin
  with panInfo do
  begin
  	Top := (Self.Height div 2) - (Height div 2);
    Left:= (Self.Width  div 2) - (Width  div 2);
    Caption := sDefaultStr;
    Visible := True;
  end;
  Application.ProcessMessages;
end;

end.
