object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 332
  ClientWidth = 587
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 587
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnGerarToken: TBitBtn
      Left = 24
      Top = 10
      Width = 100
      Height = 25
      Caption = 'GERAR TOKEN'
      TabOrder = 0
      OnClick = btnGerarTokenClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 291
    Width = 587
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 10
      Width = 35
      Height = 13
      Caption = 'TOKEN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTokenExpira: TLabel
      Left = 448
      Top = 10
      Width = 35
      Height = 13
      Caption = 'TOKEN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 369
      Top = 10
      Width = 63
      Height = 13
      Caption = 'EXPIRA EM:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object editToken: TEdit
      Left = 88
      Top = 6
      Width = 257
      Height = 21
      TabOrder = 0
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 587
    Height = 250
    Align = alClient
    TabOrder = 2
  end
end
