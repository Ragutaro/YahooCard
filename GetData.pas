unit GetData;
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils, IniFilesDX, System.IOUtils, System.Types,
  Vcl.Filectrl, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmGetData = class(TForm)
    btnGet: TButton;
    lblInfo: TLabel;
    MonthCalendar: TMonthCalendar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
  private
    { Private 宣言 }
    procedure _LoadSettings;
    procedure _SaveSettings;
  public
    { Public 宣言 }
  end;

var
  frmGetData: TfrmGetData;

implementation

{$R *.dfm}

uses
  Main,
  HideUtils,
  dp;

procedure TfrmGetData.btnGetClick(Sender: TObject);
var
  sl : TStringList;
  ms : TMemoryStream;
  sDate : String;
begin
  sDate := FormatDateTime('YYYYMM', MonthCalendar.Date);
  sl := TStringList.Create;
  ms := TMemoryStream.Create;
  try
    lblInfo.Caption := '取得中...';
    Application.ProcessMessages;
    DownloadHttp('https://member1.card.yahoo.co.jp/usage/detail/' + sDate, ms);
    ms.SetSize(ms.Size-100);
    sl.LoadFromStream(ms, TEncoding.UTF8);
    sl.SaveToFile(av.sDataPath + sDate + '.html');
    lblInfo.Caption := '取得しました。';
  finally
    sl.Free;
    ms.Free;
  end;
end;

procedure TfrmGetData.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  _SaveSettings;
  Release;
  frmGetData := nil;   //フォーム名に変更する
end;

procedure TfrmGetData.FormCreate(Sender: TObject);
begin
  _LoadSettings;
end;

procedure TfrmGetData._LoadSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.ReadWindow(Self.Name, Self);
  finally
    ini.Free;
  end;
  MonthCalendar.StyleElements := [];
  btnGet.StyleElements := [];
end;

procedure TfrmGetData._SaveSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.WriteWindow(Self.Name, Self);
    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

end.
