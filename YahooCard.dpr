program YahooCard;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles,
  Graph in 'Graph.pas' {frmGraph},
  Detail in 'Detail.pas' {frmDetail},
  Utils in 'Utils.pas',
  ThisMonth in 'ThisMonth.pas' {frmThisMonth};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
