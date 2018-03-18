object frmDetail: TfrmDetail
  Left = 324
  Top = 549
  Caption = #36092#20837#21830#21697
  ClientHeight = 310
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #12513#12452#12522#12458
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object splVert: TSplitter
    Left = 149
    Top = 0
    Width = 4
    Height = 310
    ExplicitHeight = 191
  end
  object lvwAllItem: THideListView
    Left = 0
    Top = 0
    Width = 149
    Height = 310
    Align = alLeft
    Columns = <
      item
        Caption = #21033#29992#26085
        Width = 75
      end
      item
        Caption = #21033#29992#24215
        Width = 100
      end
      item
        Alignment = taRightJustify
        Caption = #21033#29992#37329#38989
        Width = 75
      end>
    HideSelection = False
    HotTrackStyles = [htHandPoint, htUnderlineHot]
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawItem = lvwAllItemCustomDrawItem
    OnKeyUp = lvwAllItemKeyUp
    OnMouseUp = lvwAllItemMouseUp
    SortOrder = soAscending
    WrapAround = False
    DefaultSortOrder = soAscending
    HoverColor = 16774117
    HoverFontColor = clTeal
    UnevenColor = 16710392
    EvenColor = clWindow
  end
  object panRight: TPanel
    Left = 153
    Top = 0
    Width = 331
    Height = 310
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object lvwList: THideListView
      Left = 0
      Top = 0
      Width = 331
      Height = 83
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = #31185#30446
          Width = 75
        end
        item
          Caption = #21830#21697#21517
          Width = 100
        end
        item
          Alignment = taRightJustify
          Caption = #20385#26684
          Width = 75
        end>
      HideSelection = False
      HotTrackStyles = [htHandPoint, htUnderlineHot]
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnCustomDrawItem = lvwListCustomDrawItem
      OnSelectItem = lvwListSelectItem
      SortOrder = soAscending
      WrapAround = False
      DefaultSortOrder = soAscending
      HoverColor = 16774117
      HoverFontColor = clTeal
      UnevenColor = 16710392
      EvenColor = clWindow
    end
    object panEdit: TPanel
      Left = 0
      Top = 83
      Width = 331
      Height = 227
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        331
        227)
      object lblUsedPlace: TLabel
        Left = 24
        Top = 16
        Width = 41
        Height = 18
        Caption = #21033#29992#26085':'
      end
      object Label4: TLabel
        Left = 36
        Top = 97
        Width = 29
        Height = 18
        Caption = #31185#30446':'
      end
      object Label5: TLabel
        Left = 24
        Top = 130
        Width = 41
        Height = 18
        Caption = #21830#21697#21517':'
      end
      object Label6: TLabel
        Left = 36
        Top = 164
        Width = 29
        Height = 18
        Caption = #20385#26684':'
      end
      object lblDate: TLabel
        Left = 73
        Top = 16
        Width = 41
        Height = 18
        Caption = 'lblDate'
      end
      object lblShop: TLabel
        Left = 73
        Top = 40
        Width = 42
        Height = 18
        Caption = 'lblShop'
      end
      object Label2: TLabel
        Left = 24
        Top = 40
        Width = 41
        Height = 18
        Caption = #21033#29992#24215':'
      end
      object lblAmount: TLabel
        Left = 73
        Top = 64
        Width = 42
        Height = 18
        Caption = 'lblShop'
      end
      object Label7: TLabel
        Left = 12
        Top = 64
        Width = 53
        Height = 18
        Caption = #21033#29992#37329#38989':'
      end
      object cmbType: THideComboBox
        Left = 73
        Top = 94
        Width = 136
        Height = 26
        AutoComplete = False
        TabOrder = 0
      end
      object edtName: TEdit
        Left = 73
        Top = 126
        Width = 246
        Height = 26
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object edtPrice: TEdit
        Left = 73
        Top = 158
        Width = 69
        Height = 26
        NumbersOnly = True
        TabOrder = 2
      end
      object btnAdd: TButton
        Left = 72
        Top = 194
        Width = 75
        Height = 25
        Anchors = [akLeft]
        Caption = #36861#21152
        TabOrder = 3
        OnClick = btnAddClick
      end
      object btnUpdate: TButton
        Left = 149
        Top = 194
        Width = 75
        Height = 25
        Anchors = [akLeft]
        Caption = #26356#26032
        TabOrder = 4
        OnClick = btnUpdateClick
      end
      object btnDelete: TButton
        Left = 242
        Top = 194
        Width = 75
        Height = 25
        Anchors = [akLeft]
        Caption = #21066#38500
        TabOrder = 5
        OnClick = btnDeleteClick
      end
    end
  end
end
