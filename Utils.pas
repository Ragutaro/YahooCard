unit Utils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, System.StrUtils,
  Vcl.ComCtrls;

  procedure DrawListItemBkColor(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState);
  function ut_CreateDetailFilePath(const S: String): String;

implementation

uses
  HideUtils,
  Main;

procedure DrawListItemBkColor(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState);
begin
  with Sender.Canvas do
  begin
    Brush.Style := bsSolid;
    if cdsHot in State then
    begin
      Brush.Color := clHover;
      Font.Color  := clWindowText;
      Font.Style  := [fsUnderline];
    end
    else
      Brush.Color := IfThenColor(Odd(Item.Index), clWindow, $00FEFAF8);
  end;
end;

function ut_CreateDetailFilePath(const S: String): String;
begin
  Result := av.sDetailPath + LeftStr(ReplaceText(S, '/', ''), 6) + '.txt';
end;

end.
