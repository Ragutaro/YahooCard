unit Graph;
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils, IniFilesDX, System.IOUtils, System.Types,
  Vcl.Filectrl, Vcl.OleCtrls, SHDocVw, Vcl.ComCtrls, HideListView;

type
  TfrmGraph = class(TForm)
    web: TWebBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
    procedure _LoadSettings;
    procedure _SaveSettings;
    procedure _CreateGraph;
  public
    { Public 宣言 }
  end;

var
  frmGraph: TfrmGraph;

implementation

{$R *.dfm}

uses
  HideUtils,
  Main,
  dp;

procedure TfrmGraph.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  _SaveSettings;
  Release;
  FreeAndNil(frmGraph);
end;

procedure TfrmGraph.FormCreate(Sender: TObject);
begin
  DisableVclStyles(Self);
  _LoadSettings;
  _CreateGraph;
end;

procedure TfrmGraph._CreateGraph;
const
  C_GRAPH_BLUE = '<img src="img/blue_cap.png" height="16px" align="middle">' +
                 '<img src="img/blue.png" width="%dpx" height="16px" align="middle">' +
                 '<img src="img/blue_cap.png" height="16px" align="middle"> ';
  C_GRAPH_RED  = '<img src="img/red_cap.png" height="16px" align="middle">' +
                 '<img src="img/red.png" width="%dpx" height="16px" align="middle">' +
                 '<img src="img/red_cap.png" height="16px" align="middle"> ';
var
  sl, sm : TStringList;
  gr : TListGroup;
  i, iLen : Integer;
  sShop, sAmount, sCount, sGraphA, sGraphC : String;
begin
  sl := TStringList.Create;
  sm := TStringList.Create;
  try
    sm.LoadFromFile(av.sAppPath + 'graph\prototype.html', TEncoding.Unicode);
    sl.Add(#9'<tr>');
    sl.Add(#9'<th class="{sorter:''metadata''}" style="vertical-align:middle;">利用店</th>');
    sl.Add(#9'<th class="{sorter:''metadata''}" style="vertical-align:middle;">利用金額</th>');
    sl.Add(#9'<th class="{sorter:''metadata''}" style="vertical-align:middle;">利用回数</th>');
    sl.Add(#9'</tr>');
    sm.Text := ReplaceText(sm.Text, '%Header%', sl.Text);
    sl.Clear;
    for i := 0 to frmMain.lvwList.Groups.Count-1 do
    begin
      gr := frmMain.lvwList.Groups[i];
      sShop := gr.Header;
      SplitStringsToAandB(gr.Subtitle, '/', sAmount, sCount);
      //グラフの設定
      iLen := Trunc(StrToIntEx(sAmount) / 300);
      sGraphA := Format(C_GRAPH_BLUE, [iLen]);
      sCount := RemoveRight(sCount, 1);
      iLen := StrToIntEx(sCount) * 3;
      sGraphC := Format(C_GRAPH_RED, [iLen]);

      sl.Add(#9'<tr class="Row" onDblClick="Click_Sub(this)">');
      sl.Add(Format(#9#9'<td style="vertical-align:middle;">%s</td>',
            [sShop]));
      sl.Add(Format(#9#9'<td class="{sortValue: %s}" style="vertical-align:middle;">%s%s</td>',
            [ExtractNumber(sAmount), sGraphA, sAmount]));
      sl.Add(Format(#9#9'<td class="{sortValue: %s}" style="vertical-align:middle;">%s%s</td>',
            [Trim(sCount), sGraphC, sCount]));
      sl.Add(#9'</tr>');

    end;
    sm.Text := ReplaceText(sm.Text, '%Body%', sl.Text);
    sm.SaveToFile(av.sAppPath + 'graph\ViewGraph.html', TEncoding.Unicode);
  finally
    sl.Free;
  end;
  web.Silent := True;
  web.Navigate(av.sAppPath + 'graph\ViewGraph.html');
end;

procedure TfrmGraph._LoadSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.ReadWindowPosition(Self.Name, Self);
  finally
    ini.Free;
  end;
end;

procedure TfrmGraph._SaveSettings;
var
  ini : TMemIniFile;
begin
  ini := TMemIniFile.Create(GetIniFileName, TEncoding.Unicode);
  try
    ini.WriteWindowPosition(Self.Name, Self);
    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

end.
