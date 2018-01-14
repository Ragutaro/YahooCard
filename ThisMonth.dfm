object frmThisMonth: TfrmThisMonth
  Left = 318
  Top = 529
  BorderIcons = [biSystemMenu]
  Caption = #20170#26376#12398#21033#29992#29366#27841
  ClientHeight = 200
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #12513#12452#12522#12458
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  Scaled = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 18
  object lvwList: THideListView
    Left = 0
    Top = 0
    Width = 400
    Height = 200
    Align = alClient
    Columns = <
      item
        Caption = #21033#29992#26085
        Width = 150
      end
      item
        Alignment = taRightJustify
        Caption = #21033#29992#37329#38989
        Width = 150
      end>
    GroupView = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawItem = lvwListCustomDrawItem
    SortOrder = soAscending
    WrapAround = False
    DefaultSortOrder = soAscending
  end
end
