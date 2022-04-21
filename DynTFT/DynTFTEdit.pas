{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017, 2022 VCC
    initial release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this file,
    You can obtain one at https://mozilla.org/MPL/2.0/.

    Copyright (c) 2022, VCC  https://github.com/VCC02

    Alternatively, the contents of this file may be used under the terms
    of the GNU Lesser General Public License Version 3, as described below:

    DynTFT is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, version 3 of the License.

    DynTFT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with DynTFT, in COPYING.LESSER file.
    If not, see <http://www.gnu.org/licenses/>.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

unit DynTFTEdit;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils
  {$IFDEF IsDesktop}
    ,SysUtils, Forms, Math
  {$ENDIF}
  ;

const
  CEditSpacing = 4; //px
  CEditTotalSpacing = CEditSpacing * 2;

  {$IFDEF UseExternalEditStringLength}
    {$IFDEF ExternalEditStringLengthAtProjectLevel}
      {$I ExternalEditStringLength.inc}
    {$ELSE}
      {$I ..\ExternalEditStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxEditStringLength = 159; //n * 4 - 1
  {$ENDIF}

  CDynTFTEditDrawCaret_Color_Hide = 0;
  CDynTFTEditDrawCaret_Color_Show = 1;
  CDynTFTEditDrawCaret_Color_Blink = 2;
  CDynTFTEditDrawCaret_Color_Error = 3;

type
  TEditTextString = string[CMaxEditStringLength];

  TDynTFTEdit = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //Edit properties
    Color: TColor;
    Font_Color: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}
    
    FirstDispChIndex: Integer;  //starts at 1  (if 1, the displayed text should start with the first character in string)
    DisplayableLength: Integer; //this has to be computed at every content change or FirstDispChIndex change. It is updated by DisplayableLength function.
    CaretPosCh: Integer;  //draw the caret before the character of this index, relative to the first character in string.  Starts at 1 (Delphi string)
    CaretPosPx: Integer;  //draw the caret at this x position //this value is just a cache
    CaretBlinkStatus: Word; //keeps track of whether the caret is visible or not while blinking

    {$IFNDEF AppArch16}
      Dummy: Word; //keep alignment to 4 bytes   (<ArrowDir> + <DummyByte> + <Dummy>)
    {$ENDIF}

    PasswordText: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF} //when true, it displays a '*' for every character
    Readonly: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF} //prevents adding or deleting, but does not prevent directly modifying Text property

    //these events are set by an owner component, e.g. a ComboBox
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    {$IFDEF MouseClickSupport}
      OnOwnerInternalClick: PDynTFTGenericEventHandler;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      OnOwnerInternalDoubleClick: PDynTFTGenericEventHandler;
    {$ENDIF}

    Text: TEditTextString;
  end;
  PDynTFTEdit = ^TDynTFTEdit;

procedure DynTFTDrawEditWithoutCaret(APDynTFTEdit: PDynTFTEdit; FullRedraw: Boolean);
procedure DynTFTDrawEdit(APDynTFTEdit: PDynTFTEdit; FullRedraw: Boolean);
function DynTFTEdit_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTEdit;
procedure DynTFTEdit_Destroy(var AEdit: PDynTFTEdit);
procedure DynTFTEdit_DestroyAndPaint(var AEdit: PDynTFTEdit);

procedure DynTFTBlinkEditCaretState(APDynTFTEdit: PDynTFTEdit);
procedure DynTFTMoveEditCaretToRight(APDynTFTEdit: PDynTFTEdit; Amount: Integer);
procedure DynTFTMoveEditCaretToLeft(APDynTFTEdit: PDynTFTEdit; Amount: Integer);
procedure DynTFTMoveEditCaretToEnd(APDynTFTEdit: PDynTFTEdit);
procedure DynTFTMoveEditCaretToHome(APDynTFTEdit: PDynTFTEdit);
procedure DynTFTEditResetViewAndCaret(APDynTFTEdit: PDynTFTEdit);
procedure DynTFTEditAfterTypingText(APDynTFTEdit: PDynTFTEdit);  //call this after modifying the Text property
procedure DynTFTEditAfterSetText(APDynTFTEdit: PDynTFTEdit);  //call this after modifying the Text property, not by typing (adding or deleting)
procedure DynTFTEditDeleteAtCaret(APDynTFTEdit: PDynTFTEdit); //delete one character after the caret  (like pressing Delete key)
procedure DynTFTEditBackspaceAtCaret(APDynTFTEdit: PDynTFTEdit); //delete one character before the caret  (like pressing Backspace key)
procedure DynTFTEditInsertTextAtCaret(APDynTFTEdit: PDynTFTEdit; var NewText: string);   // insert a text after the caret (like typing or pasting text)
procedure DynTFTDrawEditCaret(APDynTFTEdit: PDynTFTEdit; ColorMode: Word);

procedure DynTFTRegisterEditEvents;
function DynTFTGetEditComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;
  

function DynTFTGetEditComponentType: TDynTFTComponentType; 
begin
  Result := ComponentType;
end;


type
  TSearchSubstringState = record
    OldTestedLength, TestedLength: Integer;
    TextWidth, TextHeight: Word;
    SubString: TEditTextString;
  end;
  PSearchSubstringState = ^TSearchSubstringState;


{$IFDEF IsDesktop}
  function GeneratePasswordAsterisks(Count: Integer): string;
  var
    i: Integer;
  begin
    SetLength(Result, Count);
    for i := 1 to Count do
      Result[i] := '*';
  end;
{$ELSE}
  procedure GeneratePasswordAsterisks(Count: Integer; var Result: string);
  var
    i, Count1: Integer;
  begin
    Count1 := Count - 1;
    for i := 0 to Count1 do
      Result[i] := '*';

    Result[Count] := #0; 
  end;
{$ENDIF}


//this procedure would normally be a subprocedure of GetSubstringFittingTheEdit, but this is not supported by mikroPascal  
procedure GetEditSubstringAndItsWidth(APDynTFTEdit: PDynTFTEdit; AState: PSearchSubstringState);
begin
  {$IFDEF IsDesktop}
    AState^.SubString := Copy(APDynTFTEdit^.Text, APDynTFTEdit^.FirstDispChIndex, AState^.TestedLength);

    if APDynTFTEdit^.PasswordText then
      AState^.SubString := GeneratePasswordAsterisks(Length(AState^.SubString));
  {$ELSE}
    DynTFTCopyStr(APDynTFTEdit^.Text, APDynTFTEdit^.FirstDispChIndex - 1, AState^.TestedLength, AState^.SubString);

    if APDynTFTEdit^.PasswordText then
      GeneratePasswordAsterisks(Length(AState^.SubString), AState^.SubString);
  {$ENDIF}

  GetTextWidthAndHeight(AState^.SubString, AState^.TextWidth, AState^.TextHeight);
end;


//this procedure would normally be a subprocedure of GetSubstringFittingTheEdit, but this is not supported by mikroPascal
procedure FindLongestSubstringFittingTheEdit(APDynTFTEdit: PDynTFTEdit; AState: PSearchSubstringState; DisplayableWidth, TotalLength, Step, SafeCounterLimit: Integer);
var
  SafeCounter: Integer;
begin
  SafeCounter := 0;
  while AState^.TextWidth < DisplayableWidth do
  begin
    Inc(SafeCounter);
    if SafeCounter > SafeCounterLimit then
      Break;

    AState^.OldTestedLength := AState^.TestedLength;
    AState^.TestedLength := Min(AState^.TestedLength + Step, TotalLength - APDynTFTEdit^.FirstDispChIndex + 1);

    GetEditSubstringAndItsWidth(APDynTFTEdit, AState);

    if AState^.TestedLength = AState^.OldTestedLength then
      Break;
  end;
end;


//not a nice design with so many state variables, but it should work fine on a microcontroller
//ToDo: redesign the whole algorithm (including FindLongestSubstringFittingTheEdit and GetEditSubstringAndItsWidth procedures). Binary search can also be a mess.
procedure GetSubstringFittingTheEdit(APDynTFTEdit: PDynTFTEdit; DisplayableWidth: Integer; var ResultedSubstring: TEditTextString);
var
  TotalLength: Integer;
  Step: Integer;
  AState: TSearchSubstringState;
begin
  if DisplayableWidth < 2 then
  begin
    ResultedSubstring := '';
    Exit;
  end;

  Step := 5;
  AState.TestedLength := Step;
  GetEditSubstringAndItsWidth(APDynTFTEdit, @AState);

  if AState.TextWidth > DisplayableWidth then
  begin
    Step := 1;
    AState.TestedLength := Step;
    GetEditSubstringAndItsWidth(APDynTFTEdit, @AState);
  end;

  TotalLength := Length(APDynTFTEdit^.Text);
  AState.TestedLength := Min(Step, TotalLength - APDynTFTEdit^.FirstDispChIndex + 1);
  AState.OldTestedLength := AState.TestedLength;

  //For SafeCounterLimit, assume the thinest character is 2px wide and the step is 4 ch long, so only TotalLength/2 characters may fit into view
  FindLongestSubstringFittingTheEdit(APDynTFTEdit, @AState, DisplayableWidth, TotalLength, Step, DisplayableWidth shr 3);

  if AState.TextWidth > DisplayableWidth then
  begin
    AState.TestedLength := AState.OldTestedLength;
    GetEditSubstringAndItsWidth(APDynTFTEdit, @AState);

    //For SafeCounterLimit, use step from previous computation
    FindLongestSubstringFittingTheEdit(APDynTFTEdit, @AState, DisplayableWidth, TotalLength, 1, AState.TestedLength + Step + 1);

    if AState.TextWidth > DisplayableWidth then
    begin
      {$IFDEF IsDesktop}
        AState.SubString := Copy(APDynTFTEdit^.Text, APDynTFTEdit^.FirstDispChIndex, AState.OldTestedLength);

        if APDynTFTEdit^.PasswordText then
          AState.SubString := GeneratePasswordAsterisks(Length(AState.SubString));
      {$ELSE}
        DynTFTCopyStr(APDynTFTEdit^.Text, APDynTFTEdit^.FirstDispChIndex - 1, AState.OldTestedLength, AState.SubString);

        if APDynTFTEdit^.PasswordText then
          GeneratePasswordAsterisks(Length(AState.SubString), AState.SubString);
      {$ENDIF}
    end;
  end;

  ResultedSubstring := AState.SubString;
end;


procedure UpdateEditWithFittingSubstring(APDynTFTEdit: PDynTFTEdit; var ResultedSubstring: TEditTextString);
var
  DisplayableWidth: Integer;
begin
  DisplayableWidth := APDynTFTEdit^.BaseProps.Width - CEditTotalSpacing;

  GetSubstringFittingTheEdit(APDynTFTEdit, DisplayableWidth, ResultedSubstring);
  APDynTFTEdit^.DisplayableLength := Length(ResultedSubstring); //cache the length to avoid calling this function on every caret repaint
end;


function CaretPosPxToCaretPosCh(APDynTFTEdit: PDynTFTEdit; CaretPosPx: Integer): Integer;
var
  StringBeforeCaret: TEditTextString;
begin
  GetSubstringFittingTheEdit(APDynTFTEdit, CaretPosPx + 1, StringBeforeCaret);
  Result := Length(StringBeforeCaret);

  //Debug code:
  {
  DynTFT_Set_Pen(CL_RED, 1);
  CaretPosPx := CaretPosPx + APDynTFTEdit^.BaseProps.Left + CEditSpacing;
  DynTFT_Line(CaretPosPx, APDynTFTEdit^.BaseProps.Top - 2, CaretPosPx, APDynTFTEdit^.BaseProps.Top + APDynTFTEdit^.BaseProps.Height + 2);
  }
end;


function CaretPosChToCaretPosPx(APDynTFTEdit: PDynTFTEdit; CaretPosCh: Integer): Integer; //uses the passed CaretPosCh, not the one from edit
var
  StringBeforeCaret: TEditTextString;
  TextWidth, TextHeight: Word;
begin
  if CaretPosCh < APDynTFTEdit^.FirstDispChIndex then
  begin
    Result := -2;
    Exit;
  end;

  {$IFDEF IsDesktop}
    StringBeforeCaret := Copy(APDynTFTEdit^.Text, APDynTFTEdit^.FirstDispChIndex, CaretPosCh - APDynTFTEdit^.FirstDispChIndex);

    if APDynTFTEdit^.PasswordText then
      StringBeforeCaret := GeneratePasswordAsterisks(Length(StringBeforeCaret));
  {$ELSE}
    DynTFTCopyStr(APDynTFTEdit^.Text, APDynTFTEdit^.FirstDispChIndex - 1, CaretPosCh - APDynTFTEdit^.FirstDispChIndex, StringBeforeCaret);

    if APDynTFTEdit^.PasswordText then
      GeneratePasswordAsterisks(Length(StringBeforeCaret), StringBeforeCaret);
  {$ENDIF}  
  GetTextWidthAndHeight(StringBeforeCaret, TextWidth, TextHeight);
  Result := TextWidth;
end;


procedure ComputeEditCaretPos(APDynTFTEdit: PDynTFTEdit);
begin
  APDynTFTEdit^.CaretPosPx := CaretPosChToCaretPosPx(APDynTFTEdit, APDynTFTEdit^.CaretPosCh);
end;


procedure DynTFTDrawEditCaret(APDynTFTEdit: PDynTFTEdit; ColorMode: Word);
var
  x, y1, y2: Integer;
  CaretColor: TColor;
begin
  case ColorMode of
    CDynTFTEditDrawCaret_Color_Hide : //no caret
      CaretColor := APDynTFTEdit^.Color;

    CDynTFTEditDrawCaret_Color_Show : //draw caret
    begin
      if APDynTFTEdit^.BaseProps.Focused and CFOCUSED = CFOCUSED then
        CaretColor := APDynTFTEdit^.Font_Color
      else
        CaretColor := APDynTFTEdit^.Color; //clear caret if unfocused
    end;

    CDynTFTEditDrawCaret_Color_Blink : //use CaretBlinkStatus
    begin
      if (APDynTFTEdit^.CaretBlinkStatus = 1) and (APDynTFTEdit^.BaseProps.Focused and CFOCUSED = CFOCUSED) then
        CaretColor := APDynTFTEdit^.Font_Color
      else
        CaretColor := APDynTFTEdit^.Color;
    end;

    CDynTFTEditDrawCaret_Color_Error : //error   (e.g. max number of characters reached)
      CaretColor := CL_RED
  else
    CaretColor := CL_LIME; //unusual color, to show that it is an unhandled case
  end; //case
  
  DynTFT_Set_Pen(CaretColor, 1);

  if APDynTFTEdit^.CaretBlinkStatus <> CDynTFTEditDrawCaret_Color_Error then  //no draw
  begin
    x := APDynTFTEdit^.BaseProps.Left + 3 + APDynTFTEdit^.CaretPosPx;

    if x > APDynTFTEdit^.BaseProps.Left + APDynTFTEdit^.BaseProps.Width - 2 then
      Exit;

    y1 := APDynTFTEdit^.BaseProps.Top + 2;
    y2 := APDynTFTEdit^.BaseProps.Top + APDynTFTEdit^.BaseProps.Height - 2;

    DynTFT_V_Line(y1, y2, x);
  end;
end;


procedure DynTFTDrawEditWithoutCaret(APDynTFTEdit: PDynTFTEdit; FullRedraw: Boolean);
var
  DisplayableString: TEditTextString;
  TextColor: TColor;
begin
  DynTFT_Set_Pen(CL_DynTFTEdit_Border, 1);
  DynTFT_Set_Brush(1, APDynTFTEdit^.Color, 0, 0, 0, 0);

  if APDynTFTEdit^.BaseProps.Enabled and CENABLED = CENABLED then
    TextColor := APDynTFTEdit^.Font_Color
  else
    TextColor := CL_DynTFTEdit_DisabledFont;

  {$IFDEF DynTFTFontSupport}
    DynTFT_Set_Font(APDynTFTEdit^.ActiveFont, TextColor, FO_HORIZONTAL);
  {$ELSE}
    DynTFT_Set_Font(@TFT_defaultFont, TextColor, FO_HORIZONTAL);
  {$ENDIF}

  DynTFT_Rectangle(APDynTFTEdit^.BaseProps.Left, APDynTFTEdit^.BaseProps.Top, APDynTFTEdit^.BaseProps.Left + APDynTFTEdit^.BaseProps.Width, APDynTFTEdit^.BaseProps.Top + APDynTFTEdit^.BaseProps.Height);

  UpdateEditWithFittingSubstring(APDynTFTEdit, DisplayableString);
  DynTFT_Write_Text(DisplayableString, APDynTFTEdit^.BaseProps.Left + CEditSpacing, APDynTFTEdit^.BaseProps.Top + 2);
end;


procedure DynTFTDrawEdit(APDynTFTEdit: PDynTFTEdit; FullRedraw: Boolean);
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(APDynTFTEdit))) then
    Exit;
    
  DynTFTDrawEditWithoutCaret(APDynTFTEdit, FullRedraw);
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Blink);
end;


procedure DynTFTBlinkEditCaretState(APDynTFTEdit: PDynTFTEdit);
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(APDynTFTEdit))) then
    Exit;
    
  APDynTFTEdit^.CaretBlinkStatus := not APDynTFTEdit^.CaretBlinkStatus;

  //{$DEFINE TextRedrawNoCaret}
  {$IFDEF TextRedrawNoCaret}
    if APDynTFTEdit^.CaretBlinkStatus = 1 then
      DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Blink)
    else
      DynTFTDrawTFTEditWithoutCaret(APDynTFTEdit); //Redraw the text only, if the caret is erasing pixels from text. It might be a bit of overhead to a microcontroller.
  {$ELSE}
    DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Blink);
  {$ENDIF}
end;


procedure DynTFTMoveEditCaretToRight(APDynTFTEdit: PDynTFTEdit; Amount: Integer);
var
  NewX, TextLen: Integer;
begin
  if Amount = 0 then
    Exit;

  TextLen := Length(APDynTFTEdit^.Text);
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Hide);
  if APDynTFTEdit^.CaretPosCh < TextLen - Amount + 1 + 1 then    //+2, to allow the caret to go after the last character in string
    APDynTFTEdit^.CaretPosCh := APDynTFTEdit^.CaretPosCh + Amount;

  if APDynTFTEdit^.CaretPosCh > TextLen + 1 then
    APDynTFTEdit^.CaretPosCh := TextLen + 1;

  if APDynTFTEdit^.CaretPosCh > APDynTFTEdit^.FirstDispChIndex + APDynTFTEdit^.DisplayableLength - Amount + 1 then
  begin
    //APDynTFTEdit^.FirstDispChIndex := APDynTFTEdit^.FirstDispChIndex + 1;     //not sure why this is here, but it is buggy with it

    NewX := CaretPosChToCaretPosPx(APDynTFTEdit, APDynTFTEdit^.CaretPosCh);
    while NewX > APDynTFTEdit^.BaseProps.Width - CEditTotalSpacing do
    begin
      if APDynTFTEdit^.FirstDispChIndex >= Length(APDynTFTEdit^.Text) - 1 then
        Break;

      APDynTFTEdit^.FirstDispChIndex := APDynTFTEdit^.FirstDispChIndex + 1;
      NewX := CaretPosChToCaretPosPx(APDynTFTEdit, APDynTFTEdit^.CaretPosCh);
    end;

    APDynTFTEdit^.CaretBlinkStatus := 3; //draw without old caret
    DynTFTDrawEdit(APDynTFTEdit, False);
  end;

  ComputeEditCaretPos(APDynTFTEdit);
  APDynTFTEdit^.CaretBlinkStatus := CDynTFTEditDrawCaret_Color_Show;
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Show);
end;


procedure DynTFTMoveEditCaretToLeft(APDynTFTEdit: PDynTFTEdit; Amount: Integer);
begin
  if Amount = 0 then
    Exit;

  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Hide);
  if APDynTFTEdit^.CaretPosCh > 1 + Amount - 1 then //1, because it is 1-indexed
    APDynTFTEdit^.CaretPosCh := APDynTFTEdit^.CaretPosCh - Amount;

  if APDynTFTEdit^.CaretPosCh < 1 then
    APDynTFTEdit^.CaretPosCh := 1;

  if APDynTFTEdit^.CaretPosCh < APDynTFTEdit^.FirstDispChIndex then
    if APDynTFTEdit^.FirstDispChIndex > 1 then
    begin
      APDynTFTEdit^.FirstDispChIndex := APDynTFTEdit^.CaretPosCh;
      APDynTFTEdit^.CaretBlinkStatus := 3; //draw without old caret
      DynTFTDrawEdit(APDynTFTEdit, False);
    end;

  ComputeEditCaretPos(APDynTFTEdit);
  APDynTFTEdit^.CaretBlinkStatus := CDynTFTEditDrawCaret_Color_Show;
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Show);
end;


procedure DynTFTMoveEditCaretToEnd(APDynTFTEdit: PDynTFTEdit);
var
  Amount: Integer;
begin
  Amount := Length(APDynTFTEdit^.Text) - APDynTFTEdit^.CaretPosCh + 1;
  DynTFTMoveEditCaretToRight(APDynTFTEdit, Amount);
end;


procedure DynTFTMoveEditCaretToHome(APDynTFTEdit: PDynTFTEdit);
var
  Amount: Integer;
begin
  Amount := APDynTFTEdit^.CaretPosCh - 1;
  DynTFTMoveEditCaretToLeft(APDynTFTEdit, Amount);
end;


procedure DynTFTEditResetViewAndCaret(APDynTFTEdit: PDynTFTEdit);
begin
  APDynTFTEdit^.FirstDispChIndex := 1;
  APDynTFTEdit^.CaretPosCh := 1;
end;


procedure DynTFTEditAfterTypingText(APDynTFTEdit: PDynTFTEdit);  //call this after modifying the Text property
begin
  APDynTFTEdit^.CaretBlinkStatus := 3; //draw without old caret
  DynTFTDrawEdit(APDynTFTEdit, False);

  ComputeEditCaretPos(APDynTFTEdit);

  APDynTFTEdit^.CaretBlinkStatus := CDynTFTEditDrawCaret_Color_Show;
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Show);
end;


procedure DynTFTEditAfterSetText(APDynTFTEdit: PDynTFTEdit);  //call this after modifying the Text property, not by typing (adding or deleting)
begin
  DynTFTEditResetViewAndCaret(APDynTFTEdit);
  DynTFTEditAfterTypingText(APDynTFTEdit);
end;


procedure DynTFTEditDeleteAtCaret(APDynTFTEdit: PDynTFTEdit); //delete one character after the caret  (like pressing Delete key)
begin
  if APDynTFTEdit^.CaretPosCh > Length(APDynTFTEdit^.Text) then
    Exit;

  if APDynTFTEdit^.Readonly then
    Exit;

  {$IFDEF IsDesktop}
    Delete(APDynTFTEdit^.Text, APDynTFTEdit^.CaretPosCh, 1);
  {$ELSE}
    DynTFTDelete(APDynTFTEdit^.Text, APDynTFTEdit^.CaretPosCh - 1, 1);
  {$ENDIF}
  DynTFTDrawEdit(APDynTFTEdit, False);
end;


procedure DynTFTEditBackspaceAtCaret(APDynTFTEdit: PDynTFTEdit); //delete one character before the caret  (like pressing Backspace key)
begin
  if APDynTFTEdit^.CaretPosCh <= 1 then
    Exit;

  if APDynTFTEdit^.Readonly then
    Exit;  

  {$IFDEF IsDesktop}
    Delete(APDynTFTEdit^.Text, APDynTFTEdit^.CaretPosCh - 1, 1);
  {$ELSE}
    DynTFTDelete(APDynTFTEdit^.Text, APDynTFTEdit^.CaretPosCh - 2, 1);
  {$ENDIF}
  DynTFTMoveEditCaretToLeft(APDynTFTEdit, 1);
  DynTFTDrawEdit(APDynTFTEdit, False);
end;


procedure DynTFTEditInsertTextAtCaret(APDynTFTEdit: PDynTFTEdit; var NewText: string);   // insert a text after the caret (like typing or pasting text)
begin
  if APDynTFTEdit^.Readonly then
    Exit;
    
  if Length(APDynTFTEdit^.Text) + Length(NewText) > CMaxEditStringLength then
  begin
    DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Error);
    Exit;
  end;

  {$IFDEF IsDesktop}
    Insert(NewText, APDynTFTEdit^.Text, APDynTFTEdit^.CaretPosCh);
  {$ELSE}
    DynTFTInsert(NewText, APDynTFTEdit^.Text, APDynTFTEdit^.CaretPosCh - 1);
  {$ENDIF}
  DynTFTEditAfterTypingText(APDynTFTEdit);
  DynTFTMoveEditCaretToRight(APDynTFTEdit, Length(NewText));
end;


procedure DynTFTEditSetCaretByMouse(APDynTFTEdit: PDynTFTEdit; GlobalMouseX: Integer);
var
  TextLen: Integer;
begin
  APDynTFTEdit^.CaretPosCh := APDynTFTEdit^.FirstDispChIndex + CaretPosPxToCaretPosCh(APDynTFTEdit, GlobalMouseX);

  TextLen := Length(APDynTFTEdit^.Text);
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Hide);
  
  if APDynTFTEdit^.CaretPosCh > TextLen + 1 then
    APDynTFTEdit^.CaretPosCh := TextLen + 1;

  if APDynTFTEdit^.CaretPosCh < 1 then
    APDynTFTEdit^.CaretPosCh := 1;

  ComputeEditCaretPos(APDynTFTEdit);
  APDynTFTEdit^.CaretBlinkStatus := CDynTFTEditDrawCaret_Color_Show;
  DynTFTDrawEditCaret(APDynTFTEdit, CDynTFTEditDrawCaret_Color_Show);
end;


function DynTFTEdit_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTEdit;
begin
  Result := PDynTFTEdit(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTEdit was not registered. Please call RegisterEditEvents before creating a PDynTFTEdit. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));
 
  Result^.Color := CL_DynTFTEdit_Background;
  Result^.Font_Color := CL_DynTFTEdit_EnabledFont;
         
  Result^.Text := '';
  Result^.FirstDispChIndex := 1;
  Result^.CaretPosCh := 1;
  Result^.CaretPosPx := 0;
  Result^.CaretBlinkStatus := 0;
  Result^.Readonly := False;
  Result^.PasswordText := False;

  {$IFDEF DynTFTFontSupport}
    Result^.ActiveFont := @TFT_defaultFont;
  {$ENDIF}

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      New(Result^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      New(Result^.OnOwnerInternalDoubleClick);
    {$ENDIF}

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    {$IFDEF MouseClickSupport}
      Result^.OnOwnerInternalClick^ := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Result^.OnOwnerInternalDoubleClick^ := nil;
    {$ENDIF}
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      Result^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Result^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxEditStringLength, 'PDynTFTEdit');
  {$ENDIF}
end;


function DynTFTEdit_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTEdit_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTEdit_Destroy(var AEdit: PDynTFTEdit);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AEdit^.OnOwnerInternalMouseDown);
    Dispose(AEdit^.OnOwnerInternalMouseMove);
    Dispose(AEdit^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      Dispose(AEdit^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Dispose(AEdit^.OnOwnerInternalDoubleClick);
    {$ENDIF}
    
    AEdit^.OnOwnerInternalMouseDown := nil;
    AEdit^.OnOwnerInternalMouseMove := nil;
    AEdit^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      AEdit^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AEdit^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AEdit)), SizeOf(AEdit^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AEdit));
    DynTFTComponent_Destroy(ATemp, SizeOf(AEdit^));
    AEdit := PDynTFTEdit(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTEdit_DestroyAndPaint(var AEdit: PDynTFTEdit);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AEdit)));
  DynTFTEdit_Destroy(AEdit);
end;


procedure DynTFTEdit_BaseDestroyAndPaint(var AEdit: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTEdit;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTEdit_DestroyAndPaint(PDynTFTEdit(TPtrRec(AEdit)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTEdit(TPtrRec(AEdit));
    DynTFTEdit_DestroyAndPaint(ATemp);
    AEdit := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTEdit_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  APDynTFTEdit: PDynTFTEdit;
begin
  APDynTFTEdit := PDynTFTEdit(TPtrRec(ABase));
  DynTFTEditSetCaretByMouse(APDynTFTEdit, DynTFTMCU_XMouse - CEditSpacing - APDynTFTEdit^.BaseProps.Left);

  {$IFDEF IsDesktop}
    if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTEdit_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTEdit_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTEdit_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTEdit_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTEdit(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
  end;
{$ENDIF}


procedure TDynTFTEdit_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTDrawEdit(PDynTFTEdit(TPtrRec(ABase)), FullRepaint);
end;


procedure TDynTFTEdit_OnDynTFTBaseInternalBlinkCaretState(ABase: PDynTFTBaseComponent);
begin
  DynTFTBlinkEditCaretState(PDynTFTEdit(TPtrRec(ABase)));
end;


procedure DynTFTRegisterEditEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTEdit_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTEdit_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTEdit_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := TDynTFTEdit_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent^ := TDynTFTEdit_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTEdit_OnDynTFTBaseInternalRepaint;
    ABaseEventReg.BlinkCaretState^ := TDynTFTEdit_OnDynTFTBaseInternalBlinkCaretState;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTEdit_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTEdit_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTEdit_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTEdit_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTEdit_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := @TDynTFTEdit_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := @TDynTFTEdit_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTEdit_OnDynTFTBaseInternalRepaint;
    ABaseEventReg.BlinkCaretState := @TDynTFTEdit_OnDynTFTBaseInternalBlinkCaretState;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTEdit_Create;
      ABaseEventReg.CompDestroy := @DynTFTEdit_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTEdit); 
  {$ENDIF}

  ComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}
end;

{$IFDEF IsDesktop}
begin
  ComponentType := -1;
{$ENDIF}

end.
