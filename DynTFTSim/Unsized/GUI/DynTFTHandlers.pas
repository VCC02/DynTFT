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

unit DynTFTHandlers;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  {$IFDEF UseSmallMM}
    DynTFTSmallMM,
  {$ELSE}
    {$IFDEF IsDesktop}
      MemManager,
    {$ENDIF}  
  {$ENDIF} //this must be the first unit, at least in Delphi, because it exports GetMem.
  
  DynTFTTypes, DynTFTConsts, DynTFTUtils, DynTFTBaseDrawing, DynTFTControls,
  DynTFTGUIObjects,
  
  DynTFTButton, DynTFTArrowButton, DynTFTPanel, DynTFTCheckBox, DynTFTScrollBar,
  DynTFTItems, DynTFTListBox, DynTFTLabel, DynTFTRadioButton, DynTFTRadioGroup,
  DynTFTTabButton, DynTFTPageControl, DynTFTEdit, DynTFTKeyButton,
  DynTFTVirtualKeyboard, DynTFTComboBox, DynTFTTrackBar, DynTFTProgressBar,
  DynTFTMessageBox

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  {$I DynTFTHandlersAdditionalUnits.inc}
  ;

procedure Default_OnMouseDownUser(Sender: PPtrRec);
procedure Default_OnMouseMoveUser(Sender: PPtrRec);
procedure Default_OnMouseUpUser(Sender: PPtrRec);

procedure SetAllHandlersToDefault(ABase: PDynTFTBaseComponent);

procedure CreateNewButton_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure TestScrollBarChange(Sender: PPtrRec); //CodegenSym:header

procedure MoveCarretLeft(Sender: PPtrRec); //CodegenSym:header
procedure MoveCarretRight(Sender: PPtrRec); //CodegenSym:header

procedure TestShapes_OnMouseDownUser(Sender: PPtrRec); //CodegenSym:header

procedure CheckPasswordChar_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CheckTestVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CheckTestEnabling_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CheckTestRdBtnVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CheckTestLstBoxVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CheckTestRdGrpVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CheckTestPagVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure CreateNewKeyButtons_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure DestroyTab_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure DestroyPage_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure DestroyRdBtn_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure DestroyRdGrp_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure SelfDestroy_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure ToggleCmbEditable_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header

procedure HorizTrackBar_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:header
procedure VertTrackBar_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:header

procedure ListBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:header
procedure ComboBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:header

procedure btnMsgBox_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header

procedure ATestRadioGroup1_OnSelectionChanged(Sender: PPtrRec); //CodegenSym:header




implementation


procedure ATestRadioGroup1_OnSelectionChanged(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('ATestRadioGroup1.ItemIndex: ' + IntToStr(PDynTFTRadioGroup(TPtrRec(Sender))^.ItemIndex));
  {$ENDIF}
end; //CodegenSym:handler:end


//Default handlers
procedure Default_OnMouseDownUser(Sender: PPtrRec);
begin
  {$IFDEF IsDesktop}
    {$IFDEF ComponentsHaveName}
      DynTFT_DebugConsole(PDynTFTBaseComponent(Sender)^.BaseProps.Name^ + ' down ' + inttostr(Random(10)));
    {$ENDIF}

    if PDynTFTBaseComponent(Sender)^.BaseProps.ComponentType = DynTFTGetItemsComponentType then
    begin
      DynTFT_DebugConsole('ItemIndex = ' + IntToStr(PDynTFTItems(TPtrRec(Sender))^.ItemIndex));
      DynTFT_DebugConsole('FirstVisibleIndex = ' + IntToStr(PDynTFTItems(TPtrRec(Sender))^.FirstVisibleIndex));
    end
    else
      if PDynTFTBaseComponent(Sender)^.BaseProps.ComponentType = DynTFTGetButtonComponentType then
        DynTFT_DebugConsole('... ' + PDynTFTButton(TPtrRec(Sender))^.Caption + ' down ' + IntToStr(Random(10)));
  {$ENDIF}
end;


procedure Default_OnMouseMoveUser(Sender: PPtrRec);
begin
  {$IFDEF IsDesktop}
    {$IFDEF ComponentsHaveName}
      DynTFT_DebugConsole(PDynTFTBaseComponent(Sender)^.BaseProps.Name^ + ' move ' + inttostr(Random(10)));
    {$ENDIF}

    if PDynTFTBaseComponent(Sender)^.BaseProps.ComponentType = DynTFTGetButtonComponentType then
      DynTFT_DebugConsole('... ' + PDynTFTButton(TPtrRec(Sender))^.Caption + ' move ' + IntToStr(Random(10)));
  {$ENDIF}
end;


procedure Default_OnMouseUpUser(Sender: PPtrRec);
begin
  {$IFDEF IsDesktop}
    {$IFDEF ComponentsHaveName}
      DynTFT_DebugConsole(PDynTFTBaseComponent(Sender)^.BaseProps.Name^ + ' up ' + inttostr(Random(10)));
    {$ENDIF}

    if PDynTFTBaseComponent(Sender)^.BaseProps.ComponentType = DynTFTGetButtonComponentType then
      DynTFT_DebugConsole('... ' + PDynTFTButton(TPtrRec(Sender))^.Caption + ' up ' + IntToStr(Random(10)));
  {$ENDIF}
end;


procedure SetAllHandlersToDefault(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    ABase^.BaseProps.OnMouseDownUser^ := Default_OnMouseDownUser;
    ABase^.BaseProps.OnMouseMoveUser^ := Default_OnMouseMoveUser;
    ABase^.BaseProps.OnMouseUpUser^ := Default_OnMouseUpUser;
  {$ELSE}
    ABase^.BaseProps.OnMouseDownUser := @Default_OnMouseDownUser;
    ABase^.BaseProps.OnMouseMoveUser := @Default_OnMouseMoveUser;
    ABase^.BaseProps.OnMouseUpUser := @Default_OnMouseUpUser;
  {$ENDIF}
end;


procedure CreateNewButton_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
var
  AButton: PDynTFTButton;
begin //CodegenSym:handler:begin
  AButton := DynTFTButton_Create(0, 430, 20, 120, 20);
  SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(AButton)));
  {$IFDEF ComponentsHaveName}
    AButton^.BaseProps.Name^ := 'NewButton';
  {$ENDIF}

  AButton^.Caption := 'My new button';
  {$IFDEF IsDesktop}
    DynTFT_DebugConsole(PDynTFTButton(TPtrRec(Sender))^.Caption + ' up ' + IntToStr(Random(10)));
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AButton)));
  DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(Sender)));
end; //CodegenSym:handler:end


procedure TestScrollBarChange(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    {$IFDEF ComponentsHaveName}
      DynTFT_DebugConsole(PDynTFTBaseComponent(Sender)^.BaseProps.Name^ + ' change ' + IntToStr(Random(10)));
    {$ELSE}
      DynTFT_DebugConsole('TestScroll change ' + IntToStr(PDynTFTScrollBar(TPtrRec(Sender))^.Position));
    {$ENDIF}
  {$ENDIF}
end; //CodegenSym:handler:end


procedure MoveCarretLeft(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTMoveEditCaretToLeft(ATestEdit2, 1);
  //ATestEdit^.BaseProps.Focused := CFOCUSED;
end; //CodegenSym:handler:end


procedure MoveCarretRight(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTMoveEditCaretToRight(ATestEdit2, 1);
  //ATestEdit^.BaseProps.Focused := CFOCUSED;
end; //CodegenSym:handler:end


procedure TestShapes_OnMouseDownUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFT_Set_Pen(CL_BLACK, 1);
  DynTFT_Set_Brush(0, CL_WHITE, 0, 0, 0, 0);

  DynTFT_Rectangle(20, 120, 90, 190);
  DynTFT_Rectangle(40, 145, 42, 147);
  DynTFT_Rectangle(40, 150, 43, 153);
  DynTFT_Rectangle(40, 160, 44, 164);

  DynTFT_Dot(40, 140, CL_BLACK);
  DynTFT_Dot(41, 141, CL_BLACK);
  DynTFT_Dot(42, 140, CL_BLACK);
  DynTFT_Dot(43, 141, CL_BLACK);

  DynTFT_Set_Pen(CL_RED, 1);
  DynTFT_Line(44, 140, 45, 141);
  DynTFT_Line(46, 140, 48, 142);

  DynTFT_Set_Pen(CL_RED, 1);
  DynTFT_Set_Brush(1, CL_BLUE, 0, 0, 0, 0);
  DynTFT_Rectangle(50, 145, 52, 147);
  DynTFT_Rectangle(50, 150, 53, 153);
  DynTFT_Rectangle(50, 160, 54, 164);
end; //CodegenSym:handler:end


procedure CheckPasswordChar_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  ATestEdit2^.PasswordText := PDynTFTCheckBox(TPtrRec(Sender))^.Checked;
  DynTFTEditAfterTypingText(ATestEdit2);
end; //CodegenSym:handler:end


procedure CheckTestVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(ATestScrollBar2)))
  else
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(ATestScrollBar2)));
end; //CodegenSym:handler:end


procedure CheckTestEnabling_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(ATestScrollBar3)))
  else
    DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(ATestScrollBar3)));

  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(ATestListBox)))
  else
    DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(ATestListBox)));
end; //CodegenSym:handler:end


procedure CheckTestRdBtnVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(ATestRadioGroup1^.Buttons[2])))
  else
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(ATestRadioGroup1^.Buttons[2])));
end; //CodegenSym:handler:end


procedure CheckTestLstBoxVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(ATestListBox)))
  else
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(ATestListBox)));
end; //CodegenSym:handler:end


procedure CheckTestRdGrpVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(ATestRadioGroup1)))
  else
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(ATestRadioGroup1)));
end; //CodegenSym:handler:end


procedure CheckTestPagVisibility_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if PDynTFTCheckBox(TPtrRec(Sender))^.Checked then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(ATestPageControl1)))
  else
  begin
    ATestPageControl1^.BaseProps.Visible := 0;
    //DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(ATestPageControl))); //if calling DynTFTHideComponent, the area is going to be repainted later, after the execution of DynTFTRepaintScreenComponentsFromArea
    OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(ATestPageControl1)), True, CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT, nil);
    DynTFTRepaintScreenComponentsFromArea(PDynTFTBaseComponent(TPtrRec(ATestPageControl1)));
  end;
end; //CodegenSym:handler:end


procedure Edit_OnMouseDownUser(Sender: PPtrRec);
begin
  DynTFTFocusComponent(PDynTFTBaseComponent(TPtrRec(Sender)));
end;


procedure DestroyKeyButtons_OnMouseUpUser(Sender: PPtrRec);
{$IFNDEF IsDesktop}
  var
    ABtnTemp: PDynTFTButton;
{$ENDIF}
begin
  //DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard^.FirstCreatedKey)), PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard^.LastCreatedKey)));
  //DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard)), PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard^.LastCreatedKey)));
  DynTFTVirtualKeyboard_DestroyAndPaint(AVirtualKeyboard);
  {$IFDEF IsDesktop}
    DynTFTButton_DestroyAndPaint(PDynTFTButton(TPtrRec(Sender)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ABtnTemp := PDynTFTButton(TPtrRec(Sender));
    DynTFTButton_DestroyAndPaint(ABtnTemp);
    Sender := PPtrRec(TPtrRec(ABtnTemp));
  {$ENDIF}
  
  DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(btnCreateKeyboard)));
end;


procedure VirtualKeyboard_OnCharKey(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr);
var
  AText: string {$IFNDEF IsDesktop}[CMaxKeyButtonStringLength] {$ENDIF};
begin
  if PDynTFTVirtualKeyboard(TPtrRec(Sender))^.ShiftState and CDYNTFTSS_CTRL = CDYNTFTSS_CTRL then
    Exit;

  if PDynTFTVirtualKeyboard(TPtrRec(Sender))^.ShiftState and CDYNTFTSS_ALT = CDYNTFTSS_ALT then
    Exit;
    
  AText := PressedChar;
  DynTFTEditInsertTextAtCaret(ATestEdit2, AText);

  if ATestEdit2^.BaseProps.Focused and CFOCUSED <> CFOCUSED then
    Edit_OnMouseDownUser(PPtrRec(TPtrRec(ATestEdit2)));
end;


procedure VirtualKeyboard_OnSpecialKey(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr);
begin
  case SpecialKey of
    VK_BACK : DynTFTEditBackspaceAtCaret(ATestEdit2);

    VK_DELETE :
    begin
      if CurrentShiftState and CDYNTFTSS_CTRL_ALT = CDYNTFTSS_CTRL_ALT then  
        {$IFNDEF IsDesktop}
          Reset;
        {$ELSE}
          Application.MainForm.Close;
        {$ENDIF}
      DynTFTEditDeleteAtCaret(ATestEdit2);
    end;

    VK_LEFT: DynTFTMoveEditCaretToLeft(ATestEdit2, 1);

    VK_RIGHT: DynTFTMoveEditCaretToRight(ATestEdit2, 1);

    VK_HOME: DynTFTMoveEditCaretToHome(ATestEdit2);

    VK_END: DynTFTMoveEditCaretToEnd(ATestEdit2);
  end;
end;


procedure CreateNewKeyButtons_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(Sender)));

  AVirtualKeyboard := DynTFTVirtualKeyboard_Create(0, 1, 646, 318, 182);
  AVirtualKeyboard^.Color := CL_HIGHLIGHT;
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard)));

  {$IFDEF IsDesktop}
    AVirtualKeyboard^.OnCharKey^ := VirtualKeyboard_OnCharKey;
    AVirtualKeyboard^.OnSpecialKey^ := VirtualKeyboard_OnSpecialKey;
  {$ELSE}
    AVirtualKeyboard^.OnCharKey := @VirtualKeyboard_OnCharKey;
    AVirtualKeyboard^.OnSpecialKey := @VirtualKeyboard_OnSpecialKey;
  {$ENDIF}

  ATestButton := DynTFTButton_Create(0, 340, 614, 130, 20);
  ATestButton^.Caption := 'Destroy Keyboard';
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := DestroyKeyButtons_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @DestroyKeyButtons_OnMouseUpUser;
  {$ENDIF}

  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(ATestButton)));
  DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(btnCreateKeyboard)));
end; //CodegenSym:handler:end


procedure DestroyTab_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTTabButton_DestroyAndPaint(ATestPageControl1^.TabButtons[2]);

  PDynTFTButton(TPtrRec(Sender))^.Font_Color := CL_RED;
  OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(Sender)), False, CNORMALREPAINT, nil);
end; //CodegenSym:handler:end


procedure DestroyPage_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTPageControl_DestroyAndPaint(ATestPageControl1);

  PDynTFTButton(TPtrRec(Sender))^.Font_Color := CL_RED;
  OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(Sender)), False, CNORMALREPAINT, nil);
end; //CodegenSym:handler:end


procedure DestroyRdBtn_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTRadioButton_DestroyAndPaint(ATestRadioGroup1^.Buttons[2]);

  PDynTFTButton(TPtrRec(Sender))^.Font_Color := CL_RED;
  OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(Sender)), False, CNORMALREPAINT, nil);
end; //CodegenSym:handler:end


procedure DestroyRdGrp_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  DynTFTRadioGroup_DestroyAndPaint(ATestRadioGroup1);

  PDynTFTButton(TPtrRec(Sender))^.Font_Color := CL_RED;
  OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(Sender)), False, CNORMALREPAINT, nil);
end; //CodegenSym:handler:end


procedure SelfDestroy_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
{$IFNDEF IsDesktop}
  var
    ABtnTemp: PDynTFTButton;
{$ENDIF}
begin //CodegenSym:handler:begin
  DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(Sender)), nil); //simply call this proc, to make sure it doesn't crash

  {$IFDEF IsDesktop}
    DynTFTButton_DestroyAndPaint(PDynTFTButton(TPtrRec(Sender)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ABtnTemp := PDynTFTButton(TPtrRec(Sender));
    DynTFTButton_DestroyAndPaint(ABtnTemp);
    Sender := PPtrRec(TPtrRec(ABtnTemp));
  {$ENDIF}
end; //CodegenSym:handler:end


procedure ToggleCmbEditable_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  AComboBox1^.Editable := not AComboBox1^.Editable;

  if AComboBox1^.Editable then
    PDynTFTButton(TPtrRec(Sender))^.Font_Color := CL_TEAL
  else
    PDynTFTButton(TPtrRec(Sender))^.Font_Color := CL_DynTFTButton_EnabledFont;

  OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(Sender)), False, CNORMALREPAINT, nil);
end; //CodegenSym:handler:end


procedure HorizTrackBar_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:handler
var
  APos: LongInt;
begin //CodegenSym:handler:begin
  APos := PDynTFTTrackBar(TPtrRec(Sender))^.Position;
  {$IFDEF IsDesktop}
    ALabelH^.Caption := IntToStr(APos);
  {$ELSe}
    IntToStr(APos, ALabelH^.Caption);
  {$ENDIF}
  DynTFTDrawLabel(ALabelH, True);

  AProgressBarH^.Position := APos;
  DynTFTDrawProgressBar(AProgressBarH, True);
end; //CodegenSym:handler:end


procedure VertTrackBar_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:handler
var
  APos: LongInt;
begin //CodegenSym:handler:begin
  APos := PDynTFTTrackBar(TPtrRec(Sender))^.Position;
  {$IFDEF IsDesktop}
    ALabelV^.Caption := IntToStr(APos);
  {$ELSe}
    IntToStr(APos, ALabelV^.Caption);
  {$ENDIF}
  DynTFTDrawLabel(ALabelV, True);

  AProgressBarV^.Position := APos;
  DynTFTDrawProgressBar(AProgressBarV, True);
end; //CodegenSym:handler:end


procedure ListBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:handler
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    ItemText := IntToStr(Index);
  {$ELSE}
    IntToStr(Index, ItemText);
  {$ENDIF}
end; //CodegenSym:handler:end


procedure ComboBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:handler
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    ItemText := IntToStr(Index);
  {$ELSE}
    IntToStr(Index, ItemText);
  {$ENDIF}
end; //CodegenSym:handler:end


procedure btnMsgBox_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
var
  AButton: PDynTFTButton;
  Res: Integer;
  MBMsg, MBTitle: string;
begin //CodegenSym:handler:begin
  AButton := PDynTFTButton(TPtrRec(Sender));
  MBMsg := 'This is a very long messagebox';
  MBTitle := 'MB Title fp';

  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('AButton $' + IntToHex(DWord(AButton), 8) + ' before showing Messagebox');
  {$ENDIF}

  Res := DynTFTShowMessageBox(0, MBMsg, MBTitle, CDynTFT_MB_OKCANCEL);
  //Res := DynTFTShowMessageBox(1, MBMsg, MBTitle, CDynTFT_MB_YESNO);

  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('AButton $' + IntToHex(DWord(AButton), 8) + ' after closing Messagebox: ' + IntToStr(Res));
    DynTFT_DebugConsole('');
  {$ENDIF}
end; //CodegenSym:handler:end

end.
