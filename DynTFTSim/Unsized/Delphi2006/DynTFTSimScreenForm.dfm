object frmDynTFTSimScreen: TfrmDynTFTSimScreen
  Left = 0
  Top = 32
  Caption = 'DynTFT SimScreen'
  ClientHeight = 984
  ClientWidth = 798
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    798
    984)
  PixelsPerInch = 96
  TextHeight = 13
  object lblScreenWidth: TLabel
    Left = 160
    Top = 2
    Width = 68
    Height = 13
    Caption = 'Screen Width:'
  end
  object lblScreenHeight: TLabel
    Left = 486
    Top = 2
    Width = 71
    Height = 13
    Caption = 'Screen Height:'
  end
  object pnlCoords: TPanel
    Left = 8
    Top = 7
    Width = 137
    Height = 27
    Caption = 'pnlCoords'
    TabOrder = 0
  end
  object trbScreenWidth: TTrackBar
    Left = 272
    Top = 8
    Width = 177
    Height = 26
    Max = 1024
    TabOrder = 1
    OnChange = trbScreenWidthChange
  end
  object trbScreenHeight: TTrackBar
    Left = 616
    Top = 8
    Width = 177
    Height = 26
    Max = 1024
    TabOrder = 2
    OnChange = trbScreenHeightChange
  end
  object chkShowWidthLine: TCheckBox
    Left = 160
    Top = 21
    Width = 113
    Height = 17
    Caption = 'Show Width Line'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = chkShowWidthLineClick
  end
  object chkShowHeightLine: TCheckBox
    Left = 486
    Top = 21
    Width = 113
    Height = 17
    Caption = 'Show Height Line'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = chkShowHeightLineClick
  end
  object ScrollBox1: TScrollBox
    Left = 8
    Top = 44
    Width = 785
    Height = 932
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    object imgScreen: TImage
      Left = 0
      Top = 0
      Width = 782
      Height = 929
      OnMouseDown = imgScreenMouseDown
      OnMouseEnter = imgScreenMouseEnter
      OnMouseMove = imgScreenMouseMove
      OnMouseUp = imgScreenMouseUp
    end
    object lblHeight: TLabel
      Left = 564
      Top = 44
      Width = 52
      Height = 14
      AutoSize = False
      Color = clRed
      ParentColor = False
      Visible = False
    end
    object lblWidth: TLabel
      Left = 193
      Top = 44
      Width = 10
      Height = 41
      AutoSize = False
      Color = clRed
      ParentColor = False
      Visible = False
    end
  end
  object tmrStartup: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrStartupTimer
    Left = 632
    Top = 160
  end
end
