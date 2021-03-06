{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

//Generated by DynTFTCodeGen.


unit DynTFTGUI;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF} 

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTConsts, DynTFTUtils, DynTFTBaseDrawing,
  DynTFTGUIObjects, DynTFTHandlers,

//<DynTFTComponents>
  DynTFTButton,
  DynTFTArrowButton,
  DynTFTPanel,
  DynTFTCheckBox,
  DynTFTScrollBar,
  DynTFTItems,
  DynTFTListBox,
  DynTFTLabel,
  DynTFTRadioButton,
  DynTFTRadioGroup,
  DynTFTTabButton,
  DynTFTPageControl,
  DynTFTEdit,
  DynTFTKeyButton,
  DynTFTVirtualKeyboard,
  DynTFTComboBox,
  DynTFTTrackBar,
  DynTFTProgressBar,
  DynTFTMessageBox
//<EndOfDynTFTComponents> - Do not remove or modify this line!

  
  {$IFDEF IsDesktop}
    , SysUtils
    {$IFDEF DynTFTFontSupport}, DynTFTFonts {$ENDIF}
  {$ENDIF}

  {$I DynTFTGUIAdditionalUnits.inc}
  ;


procedure DynTFT_GUI_Start;
procedure DrawGUI; //Made available for debugging or various performance improvements. Called by DynTFT_GUI_Start.


implementation


// Project name: GUI_Example_320x240.dyntftcg //Do not delete or modify this line!

procedure SetScreenActivity;
var
  i: Integer;
begin
  DynTFTAllComponentsContainer[0].Active := True;
  DynTFTAllComponentsContainer[1].Active := True;
  DynTFTAllComponentsContainer[2].Active := False;
  DynTFTAllComponentsContainer[3].Active := False;
  DynTFTAllComponentsContainer[4].Active := False;
  DynTFTAllComponentsContainer[5].Active := False;
  DynTFTAllComponentsContainer[6].Active := False;

  DynTFTAllComponentsContainer[0].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[1].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[2].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[3].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[4].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[5].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[6].ScreenColor := CL_DynTFTScreen_Background;

  for i := 7 to CDynTFTMaxComponentsContainer - 1 do
    DynTFTAllComponentsContainer[i].Active := False;

  DynTFT_Set_Pen(DynTFTAllComponentsContainer[0].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[0].ScreenColor, 0, 0, 0, 0);
  DynTFT_Rectangle(0, 0, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);
end;

procedure RegisterAllComponentsEvents;
begin
  DynTFTRegisterButtonEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTButton type: ' + IntToStr(DynTFTGetButtonComponentType));{$ENDIF}
  DynTFTRegisterArrowButtonEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTArrowButton type: ' + IntToStr(DynTFTGetArrowButtonComponentType));{$ENDIF}
  DynTFTRegisterPanelEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTPanel type: ' + IntToStr(DynTFTGetPanelComponentType));{$ENDIF}
  DynTFTRegisterCheckBoxEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTCheckBox type: ' + IntToStr(DynTFTGetCheckBoxComponentType));{$ENDIF}
  DynTFTRegisterScrollBarEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTScrollBar type: ' + IntToStr(DynTFTGetScrollBarComponentType));{$ENDIF}
  DynTFTRegisterItemsEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTItems type: ' + IntToStr(DynTFTGetItemsComponentType));{$ENDIF}
  DynTFTRegisterListBoxEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTListBox type: ' + IntToStr(DynTFTGetListBoxComponentType));{$ENDIF}
  DynTFTRegisterLabelEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTLabel type: ' + IntToStr(DynTFTGetLabelComponentType));{$ENDIF}
  DynTFTRegisterRadioButtonEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTRadioButton type: ' + IntToStr(DynTFTGetRadioButtonComponentType));{$ENDIF}
  DynTFTRegisterRadioGroupEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTRadioGroup type: ' + IntToStr(DynTFTGetRadioGroupComponentType));{$ENDIF}
  DynTFTRegisterTabButtonEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTTabButton type: ' + IntToStr(DynTFTGetTabButtonComponentType));{$ENDIF}
  DynTFTRegisterPageControlEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTPageControl type: ' + IntToStr(DynTFTGetPageControlComponentType));{$ENDIF}
  DynTFTRegisterEditEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTEdit type: ' + IntToStr(DynTFTGetEditComponentType));{$ENDIF}
  DynTFTRegisterKeyButtonEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTKeyButton type: ' + IntToStr(DynTFTGetKeyButtonComponentType));{$ENDIF}
  DynTFTRegisterVirtualKeyboardEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTVirtualKeyboard type: ' + IntToStr(DynTFTGetVirtualKeyboardComponentType));{$ENDIF}
  DynTFTRegisterComboBoxEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTComboBox type: ' + IntToStr(DynTFTGetComboBoxComponentType));{$ENDIF}
  DynTFTRegisterTrackBarEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTTrackBar type: ' + IntToStr(DynTFTGetTrackBarComponentType));{$ENDIF}
  DynTFTRegisterProgressBarEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTProgressBar type: ' + IntToStr(DynTFTGetProgressBarComponentType));{$ENDIF}
  DynTFTRegisterMessageBoxEvents;        {$IFDEF IsDesktop}DynTFT_DebugConsole('DynTFTMessageBox type: ' + IntToStr(DynTFTGetMessageBoxComponentType));{$ENDIF}
end;

procedure CreateGUI_Screen_0; //Tabs
begin
  PageControl1 := DynTFTPageControl_Create(0, 0, 1, 284, 25);
  {$DEFINE PageControl1_CHorizontal}
  {$IFDEF PageControl1_CVertical}
    PDynTFTPageControl_CreateAllTabButtonsAsVertical(0, 1, 284, 20, 6, PageControl1, CPageControl1_Captions);
  {$ELSE}
    PDynTFTPageControl_CreateAllTabButtonsAsHorizontal(0, 1, 25, 6, CPageControl1_ButtonLefts, CPageControl1_ButtonWidths, PageControl1, CPageControl1_Captions);
  {$ENDIF}
  {$DEFINE PageControl1_Enabled_1}
  {$IFDEF PageControl1_Enabled_0}
    DynTFTDisablePageControl(PageControl1);
  {$ENDIF}
  {$IFDEF IsDesktop}
    PageControl1^.OnChange^ := PageControl1_OnChange;
  {$ELSE}
    PageControl1^.OnChange := @PageControl1_OnChange;
  {$ENDIF}
end;

procedure CreateGUI_Screen_1; //Tab1
var
  Local_DynTFTPanel: PDynTFTPanel;
begin
  btn1 := DynTFTButton_Create(1, 9, 29, 75, 33);
  btn1^.Caption := C_btn1_Caption; //'Button 1'
  btn1^.Font_Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  btn2 := DynTFTButton_Create(1, 241, 29, 75, 33);
  btn2^.Caption := C_btn2_Caption; //'Button 2'
  btn2^.Font_Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow1 := DynTFTArrowButton_CreateWithArrow(1, 97, 34, 20, 20, CLeftArrow);
  Arrow1^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow2 := DynTFTArrowButton_CreateWithArrow(1, 121, 34, 20, 20, CRightArrow);
  Arrow2^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow3 := DynTFTArrowButton_CreateWithArrow(1, 185, 34, 20, 20, CUpArrow);
  Arrow3^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow4 := DynTFTArrowButton_CreateWithArrow(1, 209, 34, 20, 20, CDownArrow);
  Arrow4^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Local_DynTFTPanel := DynTFTPanel_Create(1, 65, 69, 194, 82);
  Local_DynTFTPanel^.BaseProps.CanHandleMessages := False;
  Local_DynTFTPanel^.Caption := C_Panel1_Caption; //'Panel 1'
  Local_DynTFTPanel^.Color := {$IFDEF IsDesktop} $006FAD6F {$ELSE} $6D6D {$ENDIF};
  Local_DynTFTPanel^.Font_Color := CL_BLACK;

  Arrow5 := DynTFTArrowButton_CreateWithArrow(1, 17, 157, 32, 36, CUpArrow);
  Arrow5^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  Arrow6 := DynTFTArrowButton_CreateWithArrow(1, 17, 197, 32, 36, CDownArrow);
  Arrow6^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  Arrow7 := DynTFTArrowButton_CreateWithArrow(1, 281, 157, 32, 36, CLeftArrow);
  Arrow7^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  Arrow8 := DynTFTArrowButton_CreateWithArrow(1, 281, 197, 32, 36, CRightArrow);
  Arrow8^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  btn3 := DynTFTButton_Create(1, 89, 165, 148, 25);
  btn3^.BaseProps.Enabled := 0;
  btn3^.BaseProps.CanHandleMessages := False;
  btn3^.Caption := C_btn3_Caption; //'Disabled Button 3'

  btn4 := DynTFTButton_Create(1, 89, 205, 148, 25);
  btn4^.BaseProps.Enabled := 0;
  btn4^.BaseProps.CanHandleMessages := False;
  btn4^.Caption := C_btn4_Caption; //'Disabled Button 4'
end;

procedure CreateGUI_Screen_2; //Tab2
var
  Local_DynTFTCheckBox: PDynTFTCheckBox;
  Local_DynTFTScrollBar: PDynTFTScrollBar;
  Local_DynTFTListBox: PDynTFTListBox;
begin
  Local_DynTFTCheckBox := DynTFTCheckBox_Create(2, 25, 29, 110, 21);
  Local_DynTFTCheckBox^.Caption := C_CheckBox1_Caption; //'CheckBox 1'
  Local_DynTFTCheckBox^.Color := {$IFDEF IsDesktop} $00BE8296 {$ELSE} $9417 {$ENDIF};
  Local_DynTFTCheckBox^.Font_Color := CL_BLACK;

  Local_DynTFTCheckBox := DynTFTCheckBox_Create(2, 25, 61, 110, 21);
  Local_DynTFTCheckBox^.Caption := C_CheckBox2_Caption; //'CheckBox 2'
  Local_DynTFTCheckBox^.Color := {$IFDEF IsDesktop} $00BE8296 {$ELSE} $9417 {$ENDIF};
  Local_DynTFTCheckBox^.Font_Color := CL_BLACK;

  Local_DynTFTCheckBox := DynTFTCheckBox_Create(2, 153, 29, 110, 21);
  Local_DynTFTCheckBox^.BaseProps.Enabled := 0;
  Local_DynTFTCheckBox^.Caption := C_CheckBox3_Caption; //'CheckBox 3'
  Local_DynTFTCheckBox^.Color := {$IFDEF IsDesktop} $00BE8296 {$ELSE} $9417 {$ENDIF};
  Local_DynTFTCheckBox^.Font_Color := CL_BLACK;

  Local_DynTFTScrollBar := DynTFTScrollBar_CreateWithDir(2, 25, 205, 233, 20, CScrollBarHorizDir);
  {$DEFINE ScrollBar1_Enabled_1}
  {$IFDEF ScrollBar1_Enabled_0}
    DynTFTDisableScrollBar(ScrollBar1);
  {$ENDIF}

  Local_DynTFTScrollBar := DynTFTScrollBar_CreateWithDir(2, 289, 45, 20, 168, CScrollBarVertDir);
  {$DEFINE ScrollBar2_Enabled_1}
  {$IFDEF ScrollBar2_Enabled_0}
    DynTFTDisableScrollBar(ScrollBar2);
  {$ENDIF}

  Local_DynTFTListBox := DynTFTListBox_Create(2, 25, 85, 100, 112);
  Local_DynTFTListBox^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00FAAFBE {$ELSE} $BD7F {$ENDIF};
  {$IFNDEF UseExternalItems} 
    Local_DynTFTListBox^.Items^.Strings[0] := C_ListBox1_Items_Strings_Item_0; //'one'
    Local_DynTFTListBox^.Items^.Strings[1] := C_ListBox1_Items_Strings_Item_1; //'two'
    Local_DynTFTListBox^.Items^.Strings[2] := C_ListBox1_Items_Strings_Item_2; //'three'
    Local_DynTFTListBox^.Items^.Strings[3] := C_ListBox1_Items_Strings_Item_3; //'four'
    Local_DynTFTListBox^.Items^.Strings[4] := C_ListBox1_Items_Strings_Item_4; //'five'
    Local_DynTFTListBox^.Items^.Strings[5] := C_ListBox1_Items_Strings_Item_5; //'six'
    Local_DynTFTListBox^.Items^.Strings[6] := C_ListBox1_Items_Strings_Item_6; //'seven'
    Local_DynTFTListBox^.Items^.Strings[7] := C_ListBox1_Items_Strings_Item_7; //'eight'
    Local_DynTFTListBox^.Items^.Strings[8] := C_ListBox1_Items_Strings_Item_8; //'nine'
    Local_DynTFTListBox^.Items^.Strings[9] := C_ListBox1_Items_Strings_Item_9; //'ten'
  {$ENDIF} 
  Local_DynTFTListBox^.Items^.ItemHeight := 15;
  Local_DynTFTListBox^.Items^.Count := 10;
  {$IFDEF ItemsVisibility} 
    Local_DynTFTListBox^.Items^.TotalVisibleCount := 10;
  {$ENDIF} 
  {$IFDEF UseExternalItems} 
    {$IFDEF IsDesktop}
      Local_DynTFTListBox^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      Local_DynTFTListBox^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ENDIF} 

  Local_DynTFTListBox := DynTFTListBox_Create(2, 153, 85, 100, 112);
  {$IFNDEF UseExternalItems} 
    Local_DynTFTListBox^.Items^.Strings[0] := C_ListBox3_Items_Strings_Item_0; //'one'
    Local_DynTFTListBox^.Items^.Strings[1] := C_ListBox3_Items_Strings_Item_1; //'two'
    Local_DynTFTListBox^.Items^.Strings[2] := C_ListBox3_Items_Strings_Item_2; //'three'
    Local_DynTFTListBox^.Items^.Strings[3] := C_ListBox3_Items_Strings_Item_3; //'four'
    Local_DynTFTListBox^.Items^.Strings[4] := C_ListBox3_Items_Strings_Item_4; //'five'
    Local_DynTFTListBox^.Items^.Strings[5] := C_ListBox3_Items_Strings_Item_5; //'six'
    Local_DynTFTListBox^.Items^.Strings[6] := C_ListBox3_Items_Strings_Item_6; //'seven'
    Local_DynTFTListBox^.Items^.Strings[7] := C_ListBox3_Items_Strings_Item_7; //'eight'
    Local_DynTFTListBox^.Items^.Strings[8] := C_ListBox3_Items_Strings_Item_8; //'nine'
    Local_DynTFTListBox^.Items^.Strings[9] := C_ListBox3_Items_Strings_Item_9; //'ten'
  {$ENDIF} 
  Local_DynTFTListBox^.Items^.ItemHeight := 15;
  Local_DynTFTListBox^.Items^.Count := 10;
  {$IFDEF ItemsVisibility} 
    Local_DynTFTListBox^.Items^.TotalVisibleCount := 10;
  {$ENDIF} 
  {$IFDEF UseExternalItems} 
    {$IFDEF IsDesktop}
      Local_DynTFTListBox^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      Local_DynTFTListBox^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ENDIF} 
end;

procedure CreateGUI_Screen_3; //Tab3
var
  Local_DynTFTLabel: PDynTFTLabel;
  Local_DynTFTRadioGroup: PDynTFTRadioGroup;
begin
  Local_DynTFTLabel := DynTFTLabel_Create(3, 9, 29, 60, 17);
  Local_DynTFTLabel^.Caption := C_lbl1_Caption; //'Label 1'
  Local_DynTFTLabel^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};

  Local_DynTFTLabel := DynTFTLabel_Create(3, 89, 29, 60, 17);
  Local_DynTFTLabel^.Caption := C_lbl2_Caption; //'Label 2'
  Local_DynTFTLabel^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};

  Local_DynTFTLabel := DynTFTLabel_Create(3, 169, 29, 60, 17);
  Local_DynTFTLabel^.Caption := C_lbl3_Caption; //'Label 3'
  Local_DynTFTLabel^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};

  Local_DynTFTLabel := DynTFTLabel_Create(3, 249, 29, 60, 17);
  Local_DynTFTLabel^.Caption := C_lbl4_Caption; //'Label 4'
  Local_DynTFTLabel^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};

  Local_DynTFTRadioGroup := DynTFTRadioGroup_Create(3, 9, 69, 136, 150);
  PDynTFTRadioGroup_CreateAllRadioButtons(9 + 5, 69 + 15 + 4 - 1, 136 - 5 - 6, 15, 8, Local_DynTFTRadioGroup, CrdgrpTest_Captions);
  {$DEFINE rdgrpTest_Enabled_1}
  {$IFDEF rdgrpTest_Enabled_0}
    DynTFTDisableRadioGroup(rdgrpTest);
  {$ENDIF}
  Local_DynTFTRadioGroup^.Caption := C_rdgrpTest_Caption; //'Radio Group 1'
  Local_DynTFTRadioGroup^.ItemIndex := 2;

  Local_DynTFTRadioGroup := DynTFTRadioGroup_Create(3, 177, 69, 136, 150);
  PDynTFTRadioGroup_CreateAllRadioButtons(177 + 5, 69 + 15 + 4 - 1, 136 - 5 - 6, 15, 8, Local_DynTFTRadioGroup, CrdgrpTest1_Captions);
  {$DEFINE rdgrpTest1_Enabled_1}
  {$IFDEF rdgrpTest1_Enabled_0}
    DynTFTDisableRadioGroup(rdgrpTest1);
  {$ENDIF}
  Local_DynTFTRadioGroup^.Caption := C_rdgrpTest1_Caption; //'Radio Group 2'
  Local_DynTFTRadioGroup^.ItemIndex := 2;
end;

procedure CreateGUI_Screen_4; //Tab4
begin
  vkTest := DynTFTVirtualKeyboard_Create(4, 1, 55, 318, 184);
  {$IFDEF IsDesktop}
    vkTest^.OnCharKey^ := VirtualKeyboard_OnCharKey;
  {$ELSE}
    vkTest^.OnCharKey := @VirtualKeyboard_OnCharKey;
  {$ENDIF}
  {$IFDEF IsDesktop}
    vkTest^.OnSpecialKey^ := VirtualKeyboard_OnSpecialKey;
  {$ELSE}
    vkTest^.OnSpecialKey := @VirtualKeyboard_OnSpecialKey;
  {$ENDIF}

  Edit1 := DynTFTEdit_Create(4, 9, 27, 200, 24);
  Edit1^.Text := C_Edit1_Text; //'Edit1'
end;

procedure CreateGUI_Screen_5; //Tab5
var
  Local_DynTFTLabel: PDynTFTLabel;
begin
  ComboBox1 := DynTFTComboBox_Create(5, 9, 29, 120, 22);
  {$DEFINE ComboBox1_Enabled_1}
  {$IFDEF ComboBox1_Enabled_0}
    DynTFTDisableComboBox(ComboBox1);
  {$ENDIF}
  ComboBox1^.ListBox^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00FAFA6E {$ELSE} $6FDF {$ENDIF};
  {$IFNDEF UseExternalItems} 
    ComboBox1^.ListBox^.Items^.Strings[0] := C_ComboBox1_ListBox_Items_Strings_Item_0; //'one'
    ComboBox1^.ListBox^.Items^.Strings[1] := C_ComboBox1_ListBox_Items_Strings_Item_1; //'two'
    ComboBox1^.ListBox^.Items^.Strings[2] := C_ComboBox1_ListBox_Items_Strings_Item_2; //'three'
    ComboBox1^.ListBox^.Items^.Strings[3] := C_ComboBox1_ListBox_Items_Strings_Item_3; //'four'
    ComboBox1^.ListBox^.Items^.Strings[4] := C_ComboBox1_ListBox_Items_Strings_Item_4; //'five'
    ComboBox1^.ListBox^.Items^.Strings[5] := C_ComboBox1_ListBox_Items_Strings_Item_5; //'six'
    ComboBox1^.ListBox^.Items^.Strings[6] := C_ComboBox1_ListBox_Items_Strings_Item_6; //'seven'
    ComboBox1^.ListBox^.Items^.Strings[7] := C_ComboBox1_ListBox_Items_Strings_Item_7; //'eight'
    ComboBox1^.ListBox^.Items^.Strings[8] := C_ComboBox1_ListBox_Items_Strings_Item_8; //'nine'
    ComboBox1^.ListBox^.Items^.Strings[9] := C_ComboBox1_ListBox_Items_Strings_Item_9; //'ten'
  {$ENDIF} 
  ComboBox1^.ListBox^.Items^.ItemHeight := 15;
  ComboBox1^.Edit^.Color := {$IFDEF IsDesktop} $00FAFA6E {$ELSE} $6FDF {$ENDIF};
  ComboBox1^.Editable := False;
  ComboBox1^.ListBox^.Items^.Count := 10;
  {$IFDEF ItemsVisibility} 
    ComboBox1^.ListBox^.Items^.TotalVisibleCount := 10;
  {$ENDIF} 
  {$IFDEF UseExternalItems} 
    {$IFDEF IsDesktop}
      ComboBox1^.ListBox^.Items^.OnGetItem^ := ComboBoxItemsGetItemText;
    {$ELSE}
      ComboBox1^.ListBox^.Items^.OnGetItem := @ComboBoxItemsGetItemText;
    {$ENDIF}
  {$ENDIF} 

  ComboBox2 := DynTFTComboBox_Create(5, 9, 77, 120, 24);
  {$DEFINE ComboBox2_Enabled_1}
  {$IFDEF ComboBox2_Enabled_0}
    DynTFTDisableComboBox(ComboBox2);
  {$ENDIF}
  ComboBox2^.ListBox^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00FAFA6E {$ELSE} $6FDF {$ENDIF};
  {$IFNDEF UseExternalItems} 
    ComboBox2^.ListBox^.Items^.Strings[0] := C_ComboBox2_ListBox_Items_Strings_Item_0; //'one'
    ComboBox2^.ListBox^.Items^.Strings[1] := C_ComboBox2_ListBox_Items_Strings_Item_1; //'two'
    ComboBox2^.ListBox^.Items^.Strings[2] := C_ComboBox2_ListBox_Items_Strings_Item_2; //'three'
    ComboBox2^.ListBox^.Items^.Strings[3] := C_ComboBox2_ListBox_Items_Strings_Item_3; //'four'
    ComboBox2^.ListBox^.Items^.Strings[4] := C_ComboBox2_ListBox_Items_Strings_Item_4; //'five'
    ComboBox2^.ListBox^.Items^.Strings[5] := C_ComboBox2_ListBox_Items_Strings_Item_5; //'six'
    ComboBox2^.ListBox^.Items^.Strings[6] := C_ComboBox2_ListBox_Items_Strings_Item_6; //'seven'
    ComboBox2^.ListBox^.Items^.Strings[7] := C_ComboBox2_ListBox_Items_Strings_Item_7; //'eight'
    ComboBox2^.ListBox^.Items^.Strings[8] := C_ComboBox2_ListBox_Items_Strings_Item_8; //'nine'
    ComboBox2^.ListBox^.Items^.Strings[9] := C_ComboBox2_ListBox_Items_Strings_Item_9; //'ten'
  {$ENDIF} 
  ComboBox2^.ListBox^.Items^.ItemHeight := 15;
  ComboBox2^.ListBox^.Items^.Count := 10;
  {$IFDEF ItemsVisibility} 
    ComboBox2^.ListBox^.Items^.TotalVisibleCount := 10;
  {$ENDIF} 
  {$IFDEF UseExternalItems} 
    {$IFDEF IsDesktop}
      ComboBox2^.ListBox^.Items^.OnGetItem^ := ComboBoxItemsGetItemText;
    {$ELSE}
      ComboBox2^.ListBox^.Items^.OnGetItem := @ComboBoxItemsGetItemText;
    {$ENDIF}
  {$ENDIF} 

  Local_DynTFTLabel := DynTFTLabel_Create(5, 153, 77, 61, 20);
  Local_DynTFTLabel^.BaseProps.CanHandleMessages := False;
  Local_DynTFTLabel^.Caption := C_Label4_Caption; //'Editable'
  Local_DynTFTLabel^.Color := {$IFDEF IsDesktop} $00C8C800 {$ELSE} $0659 {$ENDIF};
  Local_DynTFTLabel^.Font_Color := CL_WHITE;

  Local_DynTFTLabel := DynTFTLabel_Create(5, 153, 29, 120, 20);
  Local_DynTFTLabel^.BaseProps.CanHandleMessages := False;
  Local_DynTFTLabel^.Caption := C_Label5_Caption; //'Selectable only'
  Local_DynTFTLabel^.Color := {$IFDEF IsDesktop} $00C8C800 {$ELSE} $0659 {$ENDIF};
  Local_DynTFTLabel^.Font_Color := CL_WHITE;

  ListBox2 := DynTFTListBox_Create(5, 9, 149, 100, 80);
  ListBox2^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00F0F000 {$ELSE} $079E {$ENDIF};
  {$IFNDEF UseExternalItems} 
    ListBox2^.Items^.Strings[0] := C_ListBox2_Items_Strings_Item_0; //'one'
    ListBox2^.Items^.Strings[1] := C_ListBox2_Items_Strings_Item_1; //'two'
    ListBox2^.Items^.Strings[2] := C_ListBox2_Items_Strings_Item_2; //'three'
    ListBox2^.Items^.Strings[3] := C_ListBox2_Items_Strings_Item_3; //'four'
    ListBox2^.Items^.Strings[4] := C_ListBox2_Items_Strings_Item_4; //'five'
    ListBox2^.Items^.Strings[5] := C_ListBox2_Items_Strings_Item_5; //'six'
    ListBox2^.Items^.Strings[6] := C_ListBox2_Items_Strings_Item_6; //'seven'
    ListBox2^.Items^.Strings[7] := C_ListBox2_Items_Strings_Item_7; //'eight'
    ListBox2^.Items^.Strings[8] := C_ListBox2_Items_Strings_Item_8; //'nine'
    ListBox2^.Items^.Strings[9] := C_ListBox2_Items_Strings_Item_9; //'ten'
  {$ENDIF} 
  ListBox2^.Items^.ItemHeight := 15;
  ListBox2^.Items^.Count := 10;
  {$IFDEF ItemsVisibility} 
    ListBox2^.Items^.TotalVisibleCount := 10;
  {$ENDIF} 
  {$IFDEF UseExternalItems} 
    {$IFDEF IsDesktop}
      ListBox2^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ListBox2^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ENDIF} 

  ListBox4 := DynTFTListBox_Create(5, 177, 149, 100, 80);
  ListBox4^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00F0F000 {$ELSE} $079E {$ENDIF};
  {$IFNDEF UseExternalItems} 
    ListBox4^.Items^.Strings[0] := C_ListBox4_Items_Strings_Item_0; //'one'
    ListBox4^.Items^.Strings[1] := C_ListBox4_Items_Strings_Item_1; //'two'
    ListBox4^.Items^.Strings[2] := C_ListBox4_Items_Strings_Item_2; //'three'
    ListBox4^.Items^.Strings[3] := C_ListBox4_Items_Strings_Item_3; //'four'
    ListBox4^.Items^.Strings[4] := C_ListBox4_Items_Strings_Item_4; //'five'
    ListBox4^.Items^.Strings[5] := C_ListBox4_Items_Strings_Item_5; //'six'
    ListBox4^.Items^.Strings[6] := C_ListBox4_Items_Strings_Item_6; //'seven'
    ListBox4^.Items^.Strings[7] := C_ListBox4_Items_Strings_Item_7; //'eight'
    ListBox4^.Items^.Strings[8] := C_ListBox4_Items_Strings_Item_8; //'nine'
    ListBox4^.Items^.Strings[9] := C_ListBox4_Items_Strings_Item_9; //'ten'
  {$ENDIF} 
  ListBox4^.Items^.ItemHeight := 15;
  ListBox4^.Items^.Count := 10;
  {$IFDEF ItemsVisibility} 
    ListBox4^.Items^.TotalVisibleCount := 10;
  {$ENDIF} 
  {$IFDEF UseExternalItems} 
    {$IFDEF IsDesktop}
      ListBox4^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ListBox4^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ENDIF} 

  DynTFTButton0 := DynTFTButton_Create(5, 177, 105, 140, 38);
  DynTFTButton0^.Caption := C_DynTFTButton0_Caption; //'btn0'
  {$IFDEF DynTFTFontSupport} 
    DynTFTButton0^.ActiveFont := {$IFDEF IsDesktop} PByte(@CAllFontSettings[0]) {$ELSE} @Verdana29x32_ItalicUnderLine {$ENDIF};
  {$ENDIF} 
end;

procedure CreateGUI_Screen_6; //Tab6
var
  Local_DynTFTButton: PDynTFTButton;
begin
  TrackBar1 := DynTFTTrackBar_CreateWithDir(6, 9, 33, 132, 24, CTrackBarHorizDir);
  {$DEFINE TrackBar1_Enabled_1}
  {$IFDEF TrackBar1_Enabled_0}
    DynTFTDisableTrackBar(TrackBar1);
  {$ENDIF}
  TrackBar1^.Position := 3;
  {$IFDEF IsDesktop}
    TrackBar1^.OnTrackBarChange^ := TrackBar1_OnTrackBarChange;
  {$ELSE}
    TrackBar1^.OnTrackBarChange := @TrackBar1_OnTrackBarChange;
  {$ENDIF}

  TrackBar2 := DynTFTTrackBar_CreateWithDir(6, 25, 93, 24, 132, CTrackBarVertDir);
  {$DEFINE TrackBar2_Enabled_1}
  {$IFDEF TrackBar2_Enabled_0}
    DynTFTDisableTrackBar(TrackBar2);
  {$ENDIF}
  TrackBar2^.Position := 7;
  {$IFDEF IsDesktop}
    TrackBar2^.OnTrackBarChange^ := TrackBar2_OnTrackBarChange;
  {$ELSE}
    TrackBar2^.OnTrackBarChange := @TrackBar2_OnTrackBarChange;
  {$ENDIF}

  ProgressBar1 := DynTFTProgressBar_CreateWithDir(6, 185, 45, 100, 20, CProgressBarHorizDir);
  ProgressBar1^.BaseProps.CanHandleMessages := False;
  ProgressBar1^.Position := 3;

  ProgressBar2 := DynTFTProgressBar_CreateWithDir(6, 185, 93, 24, 132, CProgressBarVertDir);
  ProgressBar2^.BaseProps.CanHandleMessages := False;
  ProgressBar2^.Position := 7;

  Local_DynTFTButton := DynTFTButton_Create(6, 73, 200, 104, 25);
  Local_DynTFTButton^.Caption := C_btnShowMessageBox_Caption; //'Message Box'
  {$IFDEF IsDesktop}
    Local_DynTFTButton^.BaseProps.OnMouseUpUser^ := btnShowMessageBox_OnMouseUpUser;
  {$ELSE}
    Local_DynTFTButton^.BaseProps.OnMouseUpUser := @btnShowMessageBox_OnMouseUpUser;
  {$ENDIF}
end;

procedure DrawGUI;
begin
  CreateGUI_Screen_0;
  CreateGUI_Screen_1;
  CreateGUI_Screen_2;
  CreateGUI_Screen_3;
  CreateGUI_Screen_4;
  CreateGUI_Screen_5;
  CreateGUI_Screen_6;
  DynTFTRepaintScreenComponents(0, CREPAINTONSTARTUP, nil);
  DynTFTRepaintScreenComponents(1, CREPAINTONSTARTUP, nil);
end;


procedure DynTFT_GUI_Start;
begin
  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('Entering DynTFT_GUI_Start');
  {$ENDIF}

  DynTFTInitInputDevStateFlags;

  DynTFTInitComponentTypeRegistration;
  DynTFTInitComponentContainers;    //must be called after InitComponentTypeRegistration
  RegisterAllComponentsEvents;

  SetScreenActivity;
  DrawGUI;
end;

end.
