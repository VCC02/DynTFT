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

unit DynTFTVirtualKeyboard;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTKeyButton
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  //Shift State constants
  CDYNTFTSS_NONE = 0;
  CDYNTFTSS_SHIFT = 1;
  CDYNTFTSS_ALT = 2;
  CDYNTFTSS_CTRL = 4;
  CDYNTFTSS_CAPS = 8;

  CDYNTFTSS_ALT_SHIFT = 3;
  CDYNTFTSS_CTRL_ALT = 6;
  CDYNTFTSS_CTRL_SHIFT = 5;
  CDYNTFTSS_CTRL_ALT_SHIFT = 7;

type
  TVKPressedChar = string[CMaxKeyButtonStringLength]; //reserve at least 4 bytes for unicode support

  TOnVirtualKeyboardCharKeyPressedEvent = procedure(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr);
  POnVirtualKeyboardCharKeyPressedEvent = ^TOnVirtualKeyboardCharKeyPressedEvent;

  TOnVirtualKeyboardSpecialKeyPressedEvent = procedure(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr);
  POnVirtualKeyboardSpecialKeyPressedEvent = ^TOnVirtualKeyboardSpecialKeyPressedEvent;

  TDynTFTVirtualKeyboard = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //keyboard properties
    FirstCreatedKey: PDynTFTBaseComponent;
    LastCreatedKey: PDynTFTBaseComponent;
    Color: TColor;
    
    ShiftState: TPtr;
    
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}

    OnCharKey: POnVirtualKeyboardCharKeyPressedEvent;
    OnSpecialKey: POnVirtualKeyboardSpecialKeyPressedEvent;
  end;
  PDynTFTVirtualKeyboard = ^TDynTFTVirtualKeyboard;

  TVKIteratorCallback = procedure(AVirtualKeyboard: PDynTFTVirtualKeyboard; ABase: PDynTFTBaseComponent);
  PVKIteratorCallback = ^TVKIteratorCallback;

procedure DynTFTDrawVirtualKeyboard(AVirtualKeyboard: PDynTFTVirtualKeyboard; FullRedraw: Boolean);
function DynTFTVirtualKeyboard_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualKeyboard;
procedure DynTFTVirtualKeyboard_Destroy(var AVirtualKeyboard: PDynTFTVirtualKeyboard);
procedure DynTFTVirtualKeyboard_DestroyAndPaint(var AVirtualKeyboard: PDynTFTVirtualKeyboard);

procedure DynTFTRegisterVirtualKeyboardEvents;
function DynTFTGetVirtualKeyboardComponentType: TDynTFTComponentType;

procedure DynTFTIterateThroughKeys(AVirtualKeyboard: PDynTFTVirtualKeyboard; ACallback: {$IFDEF IsDesktop} TVKIteratorCallback {$ELSE} PVKIteratorCallback {$ENDIF});

{$IFDEF DynTFTFontSupport}
  procedure DynTFTSetVirtualKeyboardActiveFont(AVirtualKeyboard: PDynTFTVirtualKeyboard);
{$ENDIF}


implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetVirtualKeyboardComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTIterateThroughKeys(AVirtualKeyboard: PDynTFTVirtualKeyboard; ACallback: {$IFDEF IsDesktop} TVKIteratorCallback {$ELSE} PVKIteratorCallback {$ENDIF});
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
  ScreenIndex: Byte;
  FirstFound: Boolean;
begin
  ScreenIndex := AVirtualKeyboard^.BaseProps.ScreenIndex;
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  FirstFound := False;
  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase = AVirtualKeyboard^.FirstCreatedKey then
      FirstFound := True;

    if FirstFound then
    begin
      ACallback {$IFnDEF IsDesktop}^{$ENDIF}(AVirtualKeyboard, ABase);
      //ABase^.BaseProps.Enabled := CDISABLED;  //for debugging only - to verify if the proper components are disabled
    end;

    if ABase = AVirtualKeyboard^.LastCreatedKey then
      Break;

    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;


procedure DrawKeyButtonCallback(AVirtualKeyboard: PDynTFTVirtualKeyboard; ABase: PDynTFTBaseComponent);
begin
  DynTFTShowComponent(ABase);
end;


procedure DrawAllKeys(AVirtualKeyboard: PDynTFTVirtualKeyboard);
begin
  DynTFTIterateThroughKeys(AVirtualKeyboard, {$IFnDEF IsDesktop}@{$ENDIF}DrawKeyButtonCallback);
end;

        
{$IFDEF DynTFTFontSupport}
  procedure SetKeyButtonActiveFontCallback(AVirtualKeyboard: PDynTFTVirtualKeyboard; ABase: PDynTFTBaseComponent);
  begin
    PDynTFTKeyButton(TPtrRec(ABase))^.ActiveFont := AVirtualKeyboard^.ActiveFont;
  end;


  procedure DynTFTSetVirtualKeyboardActiveFont(AVirtualKeyboard: PDynTFTVirtualKeyboard);
  begin
    DynTFTIterateThroughKeys(AVirtualKeyboard, {$IFnDEF IsDesktop}@{$ENDIF}SetKeyButtonActiveFontCallback);
  end;
{$ENDIF}


procedure DynTFTDrawVirtualKeyboard(AVirtualKeyboard: PDynTFTVirtualKeyboard; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard))) then
    Exit;

  if FullRedraw then
  begin
    x1 := AVirtualKeyboard^.BaseProps.Left;
    y1 := AVirtualKeyboard^.BaseProps.Top;
    x2 := x1 + AVirtualKeyboard^.BaseProps.Width;
    y2 := y1 + AVirtualKeyboard^.BaseProps.Height;

    DynTFT_Set_Pen(CL_DynTFTVirtualKeyboard_Border, 1);
    DynTFT_Set_Brush(1, AVirtualKeyboard^.Color, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);

    DrawAllKeys(AVirtualKeyboard);
  end;
end;


procedure SetDrawingColorForKeyButton(ABase: PDynTFTBaseComponent);
begin
  if ABase^.BaseProps.Enabled and CENABLED = CENABLED then
    DynTFT_Set_Pen(CL_DynTFTVirtualKeyboard_EnabledKeyDrawing, 1)
  else
    DynTFT_Set_Pen(CL_DynTFTVirtualKeyboard_DisabledKeyDrawing, 1);
end;


procedure ToggleKeyInShiftState(AKey: PPtrRec; NewShiftState: TPtr);
var
  PShiftState: PPtr;
begin
  PShiftState := @PDynTFTVirtualKeyboard(TPtrRec(PDynTFTBaseComponent(TPtrRec(AKey))^.BaseProps.Parent))^.ShiftState;
  PShiftState^ := PShiftState^ xor NewShiftState;
end;


procedure SetSpecialKeyColor(AKey: PPtrRec; ExpectedShiftState: TPtr);
var
  PShiftState: PPtr;
begin
  PShiftState := @PDynTFTVirtualKeyboard(TPtrRec(PDynTFTBaseComponent(TPtrRec(AKey))^.BaseProps.Parent))^.ShiftState;
  if PShiftState^ and ExpectedShiftState = ExpectedShiftState then
    PDynTFTKeyButton(TPtrRec(AKey))^.Color := CL_DynTFTKeyButton_SpecialKeyActiveBackground
  else
    PDynTFTKeyButton(TPtrRec(AKey))^.Color := CL_DynTFTKeyButton_Background;

  DynTFTDrawKeyButton(PDynTFTKeyButton(TPtrRec(AKey)), True);
end;


type
  TDrawLineCmd = record
    LineType: Byte;
    X1_Offset: Byte;
    Y1_Offset: Byte;
    X2_Offset: Byte;
    Y2_Offset: Byte;
  end;

  TDrawLineCmdArr = array[1..1] of TDrawLineCmd;
  PDrawLineCmdArr = ^TDrawLineCmdArr;

const
  C_NormLine = 0;
  C_HorzLine = 1;
  C_VertLine = 2;


procedure DrawKeyLines(x1, y1: Integer; ListOfLines: PDrawLineCmdArr; LineCount: Integer);
var
  i: Integer;
begin
  for i := 1 to LineCount do
  begin
    case ListOfLines^[i].LineType of
      C_NormLine : DynTFT_Line(x1 + ListOfLines^[i].X1_Offset, y1 + ListOfLines^[i].Y1_Offset, x1 + ListOfLines^[i].X2_Offset, y1 + ListOfLines^[i].Y2_Offset);
      C_HorzLine : DynTFT_H_Line(x1 + ListOfLines^[i].X1_Offset, x1 + ListOfLines^[i].X2_Offset, y1 + ListOfLines^[i].Y1_Offset);
      C_VertLine : DynTFT_V_Line(y1 + ListOfLines^[i].Y1_Offset, y1 + ListOfLines^[i].Y2_Offset, x1 + ListOfLines^[i].X1_Offset);
    end;
  end;
end;


procedure DrawTabArrows_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const  
  C_TabArrows_Lines: array[1..10] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_VertLine; X1_Offset: 2; Y1_Offset: 4; X2_Offset: 2; Y2_Offset: 12),
      (LineType: C_HorzLine; X1_Offset: 9; Y1_Offset: 8; X2_Offset: 26; Y2_Offset: 8),
      (LineType: C_NormLine; X1_Offset: 3; Y1_Offset: 8; X2_Offset: 9; Y2_Offset: 5),
      (LineType: C_NormLine; X1_Offset: 3; Y1_Offset: 8; X2_Offset: 9; Y2_Offset: 11),
      (LineType: C_VertLine; X1_Offset: 9; Y1_Offset: 5; X2_Offset: 9; Y2_Offset: 11),
      (LineType: C_VertLine; X1_Offset: 27; Y1_Offset: 20; X2_Offset: 27; Y2_Offset: 28),
      (LineType: C_HorzLine; X1_Offset: 3; Y1_Offset: 24; X2_Offset: 20; Y2_Offset: 24),
      (LineType: C_NormLine; X1_Offset: 21; Y1_Offset: 27; X2_Offset: 26; Y2_Offset: 24),
      (LineType: C_NormLine; X1_Offset: 21; Y1_Offset: 21; X2_Offset: 26; Y2_Offset: 24),
      (LineType: C_VertLine; X1_Offset: 20; Y1_Offset: 21; X2_Offset: 20; Y2_Offset: 27)
    {$ELSE}
      (C_VertLine, 2, 4, 2, 12),
      (C_HorzLine, 9, 8, 26, 8),
      (C_NormLine, 3, 8, 9, 5),
      (C_NormLine, 3, 8, 9, 11),
      (C_VertLine, 9, 5, 9, 11),
      (C_VertLine, 27, 20, 27, 28),
      (C_HorzLine, 3, 24, 20, 24),
      (C_NormLine, 21, 27, 26, 24),
      (C_NormLine, 21, 21, 26, 24),
      (C_VertLine, 20, 21, 20, 27)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_V_Line(y1 + 4, y1 + 12, x1 + 2);
  DynTFT_H_Line(x1 + 9, x1 + 26, y1 + 8);
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, y1 + 5);   //up
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, y1 + 11);  //down
  DynTFT_V_Line(y1 + 5, y1 + 11, x1 + 9);  //vertical

  DynTFT_V_Line(y1 + 20, y1 + 28, x1 + 27);
  DynTFT_H_Line(x1 + 3, x1 + 20, y1 + 24);
  DynTFT_Line(x1 + 21, y1 + 27, x1 + 26, y1 + 24);  //up
  DynTFT_Line(x1 + 21, y1 + 21, x1 + 26, y1 + 24);  //down
  DynTFT_V_Line(y1 + 21, y1 + 27, x1 + 20);  //vertical
  }
  
  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_TabArrows_Lines, 10);
end;


procedure DrawBackSpaceArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const  
  C_BackSpaceArrow_Lines: array[1..4] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_HorzLine; X1_Offset: 9; Y1_Offset: 8; X2_Offset: 26; Y2_Offset: 8),
      (LineType: C_NormLine; X1_Offset: 3; Y1_Offset: 8; X2_Offset: 9; Y2_Offset: 3),
      (LineType: C_NormLine; X1_Offset: 3; Y1_Offset: 8; X2_Offset: 9; Y2_Offset: 13),
      (LineType: C_VertLine; X1_Offset: 9; Y1_Offset: 4; X2_Offset: 9; Y2_Offset: 12)
    {$ELSE}
      (C_HorzLine, 9, 8, 26, 8),
      (C_NormLine, 3, 8, 9, 3),
      (C_NormLine, 3, 8, 9, 13),
      (C_VertLine, 9, 4, 9, 12)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_H_Line(x1 + 9, x1 + 26, y1 + 8);
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, y1 + 3);   //up
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, y1 + 13);  //down
  DynTFT_V_Line(y1 + 4, y1 + 12, x1 + 9);  //vertical
  }
  
  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_BackSpaceArrow_Lines, 4);
end;


procedure DrawApps_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const  
  C_Apps_Lines: array[1..3] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_HorzLine; X1_Offset: 5; Y1_Offset: 11; X2_Offset: 11; Y2_Offset: 11),
      (LineType: C_HorzLine; X1_Offset: 5; Y1_Offset: 14; X2_Offset: 11; Y2_Offset: 14),
      (LineType: C_HorzLine; X1_Offset: 5; Y1_Offset: 17; X2_Offset: 11; Y2_Offset: 17)
    {$ELSE}
      (C_HorzLine, 5, 11, 11, 11),
      (C_HorzLine, 5, 14, 11, 14),
      (C_HorzLine, 5, 17, 11, 17)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  DynTFT_Set_Brush(0, CL_DynTFTVirtualKeyboard_Border, 0, 0, 0, 0);
  DynTFT_Rectangle(ABase^.BaseProps.Left + 3, ABase^.BaseProps.Top + 7, ABase^.BaseProps.Left + 13, ABase^.BaseProps.Top + 21);

  {DynTFT_H_Line(x1 + 5, x1 + 11, y1 + 11);  //horiz 1
  DynTFT_H_Line(x1 + 5, x1 + 11, y1 + 14);  //horiz 2
  DynTFT_H_Line(x1 + 5, x1 + 11, y1 + 17);  //horiz 3
  }
  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_Apps_Lines, 3);
end;


procedure DrawLeftArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const  
  C_LeftArrow_Lines: array[1..4] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_HorzLine; X1_Offset: 9; Y1_Offset: 8; X2_Offset: 18; Y2_Offset: 8),
      (LineType: C_NormLine; X1_Offset: 3; Y1_Offset: 8; X2_Offset: 9; Y2_Offset: 3),
      (LineType: C_NormLine; X1_Offset: 3; Y1_Offset: 8; X2_Offset: 9; Y2_Offset: 13),
      (LineType: C_VertLine; X1_Offset: 9; Y1_Offset: 4; X2_Offset: 9; Y2_Offset: 12)
    {$ELSE}
      (C_HorzLine, 9, 8, 18, 18),
      (C_NormLine, 3, 8, 9, 3),
      (C_NormLine, 3, 8, 9, 13),
      (C_VertLine, 9, 4, 9, 12)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_H_Line(x1 + 9, x1 + 18, y1 + 8);
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, y1 + 3);   //up
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, y1 + 13);  //down
  DynTFT_V_Line(y1 + 4, y1 + 12, x1 + 9);  //vertical
  }

  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_LeftArrow_Lines, 4);
end;


procedure DrawRightArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const
  C_RightArrow_Lines: array[1..4] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_HorzLine; X1_Offset: 7; Y1_Offset: 8; X2_Offset: 16; Y2_Offset: 8),
      (LineType: C_NormLine; X1_Offset: 16; Y1_Offset: 13; X2_Offset: 22; Y2_Offset: 8),
      (LineType: C_NormLine; X1_Offset: 16; Y1_Offset: 3; X2_Offset: 22; Y2_Offset: 8),
      (LineType: C_VertLine; X1_Offset: 16; Y1_Offset: 4; X2_Offset: 16; Y2_Offset: 12)
    {$ELSE}
      (C_HorzLine, 7, 8, 16, 18),
      (C_NormLine, 16, 13, 22, 8),
      (C_NormLine, 16, 3, 22, 8),
      (C_VertLine, 16, 4, 16, 12)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_H_Line(x1 + 7, x1 + 16, y1 + 8);
  DynTFT_Line(x1 + 16, y1 + 13, x1 + 22, y1 + 8);  //up
  DynTFT_Line(x1 + 16, y1 + 3, x1 + 22, y1 + 8);   //down
  DynTFT_V_Line(y1 + 4, y1 + 12, x1 + 16);  //vertical
  }

  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_RightArrow_Lines, 4);
end;


procedure DrawUpArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const
  C_UpArrow_Lines: array[1..4] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_VertLine; X1_Offset: 13; Y1_Offset: 8; X2_Offset: 13; Y2_Offset: 13),
      (LineType: C_HorzLine; X1_Offset: 9; Y1_Offset: 8; X2_Offset: 17; Y2_Offset: 8),
      (LineType: C_NormLine; X1_Offset: 9; Y1_Offset: 8; X2_Offset: 13; Y2_Offset: 2),
      (LineType: C_NormLine; X1_Offset: 13; Y1_Offset: 2; X2_Offset: 17; Y2_Offset: 8)
    {$ELSE}
      (C_VertLine, 13, 8, 13, 13),
      (C_HorzLine, 9, 8, 17, 8),
      (C_NormLine, 9, 8, 13, 2),
      (C_NormLine, 13, 2, 17, 8)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_V_Line(y1 + 8, y1 + 13, x1 + 13); //vertical
  DynTFT_H_Line(x1 + 9, x1 + 17, y1 + 8);   //horizontal
  DynTFT_Line(x1 + 9, y1 + 8, x1 + 13, y1 + 2);   //up
  DynTFT_Line(x1 + 13, y1 + 2, x1 + 17, y1 + 8);  //down
  }

  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_UpArrow_Lines, 4);
end;


procedure DrawDownArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const
  C_DownArrow_Lines: array[1..4] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_VertLine; X1_Offset: 13; Y1_Offset: 2; X2_Offset: 13; Y2_Offset: 7),
      (LineType: C_HorzLine; X1_Offset: 9; Y1_Offset: 7; X2_Offset: 17; Y2_Offset: 7),
      (LineType: C_NormLine; X1_Offset: 13; Y1_Offset: 13; X2_Offset: 17; Y2_Offset: 7),
      (LineType: C_NormLine; X1_Offset: 9; Y1_Offset: 7; X2_Offset: 13; Y2_Offset: 13)
    {$ELSE}
      (C_VertLine, 13, 2, 13, 7),
      (C_HorzLine, 9, 7, 17, 7),
      (C_NormLine, 13, 13, 17, 7),
      (C_NormLine, 9, 7, 13, 13)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_V_Line(y1 + 2, y1 + 7, x1 + 13);   //vertical
  DynTFT_H_Line(x1 + 9, x1 + 17, y1 + 7);    //horizontal
  DynTFT_Line(x1 + 13, y1 + 13, x1 + 17, y1 + 7);  //up
  DynTFT_Line(x1 + 9, y1 + 7, x1 + 13, y1 + 13);   //down
  }

  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_DownArrow_Lines, 4);
end;


procedure DrawEnterArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const
  C_EnterArrow_Lines: array[1..5] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_VertLine; X1_Offset: 20; Y1_Offset: 10; X2_Offset: 20; Y2_Offset: 21),
      (LineType: C_HorzLine; X1_Offset: 12; Y1_Offset: 21; X2_Offset: 20; Y2_Offset: 21),
      (LineType: C_VertLine; X1_Offset: 12; Y1_Offset: 17; X2_Offset: 12; Y2_Offset: 25),
      (LineType: C_NormLine; X1_Offset: 7; Y1_Offset: 21; X2_Offset: 12; Y2_Offset: 16),
      (LineType: C_NormLine; X1_Offset: 7; Y1_Offset: 21; X2_Offset: 12; Y2_Offset: 26)
    {$ELSE}
      (C_VertLine, 20, 10, 20, 21),
      (C_HorzLine, 12, 21, 20, 21),
      (C_VertLine, 12, 17, 12, 25),
      (C_NormLine, 7, 21, 12, 16),
      (C_NormLine, 7, 21, 12, 26)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_V_Line(y1 + 10, y1 + 21, x1 + 20);  //vertical
  DynTFT_H_Line(x1 + 12, x1 + 20, y1 + 21);  //horizontal
  DynTFT_V_Line(y1 + 17, y1 + 25, x1 + 12);  //vertical (arrow)
  DynTFT_Line(x1 + 7, y1 + 21, x1 + 12, y1 + 16);   //up (arrow)
  DynTFT_Line(x1 + 7, y1 + 21, x1 + 12, y1 + 26);   //down (arrow)
  }

  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_EnterArrow_Lines, 5);
end;


procedure DrawShift_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
const
  C_Shift_Lines: array[1..7] of TDrawLineCmd = (
    {$IFDEF IsDesktop}
      (LineType: C_VertLine; X1_Offset: 19; Y1_Offset: 18; X2_Offset: 19; Y2_Offset: 24),
      (LineType: C_VertLine; X1_Offset: 23; Y1_Offset: 18; X2_Offset: 23; Y2_Offset: 24),
      (LineType: C_HorzLine; X1_Offset: 19; Y1_Offset: 24; X2_Offset: 23; Y2_Offset: 24),
      (LineType: C_HorzLine; X1_Offset: 15; Y1_Offset: 18; X2_Offset: 19; Y2_Offset: 18),
      (LineType: C_HorzLine; X1_Offset: 23; Y1_Offset: 18; X2_Offset: 27; Y2_Offset: 18),
      (LineType: C_NormLine; X1_Offset: 15; Y1_Offset: 17; X2_Offset: 21; Y2_Offset: 9),
      (LineType: C_NormLine; X1_Offset: 21; Y1_Offset: 9; X2_Offset: 27; Y2_Offset: 17)
    {$ELSE}
      (C_VertLine, 19, 18, 19, 24),
      (C_VertLine, 23, 18, 23, 24),
      (C_HorzLine, 19, 24, 23, 24),
      (C_HorzLine, 15, 18, 19, 18),
      (C_HorzLine, 23, 18, 27, 18),
      (C_NormLine, 15, 17, 21, 9),
      (C_NormLine, 21, 9, 27, 17)
    {$ENDIF}
  );
begin
  SetDrawingColorForKeyButton(ABase);

  {DynTFT_V_Line(y1 + 18, y1 + 24, x1 + 19);  //vertical l
  DynTFT_V_Line(y1 + 18, y1 + 24, x1 + 23);  //vertical r
  DynTFT_H_Line(x1 + 19, x1 + 23, y1 + 24);  //horizontal bottom
  DynTFT_H_Line(x1 + 15, x1 + 19, y1 + 18);  //horizontal l
  DynTFT_H_Line(x1 + 23, x1 + 27, y1 + 18);  //horizontal r
  DynTFT_Line(x1 + 15, y1 + 17, x1 + 21, y1 + 9);   //up
  DynTFT_Line(x1 + 21, y1 + 9, x1 + 27, y1 + 17);   //down
  }

  DrawKeyLines(ABase^.BaseProps.Left, ABase^.BaseProps.Top, @C_Shift_Lines, 7);
end;


function IsCaps(AVK: PDynTFTVirtualKeyboard): Boolean;
begin
  Result := (AVK^.ShiftState and CDYNTFTSS_SHIFT = CDYNTFTSS_SHIFT) xor (AVK^.ShiftState and CDYNTFTSS_CAPS = CDYNTFTSS_CAPS);
end;


procedure TwoRowsKey_OnMouseDownUser(Sender: PPtrRec);
var
  AText: TVKPressedChar;
  AVK: PDynTFTVirtualKeyboard;
begin
  AVK := PDynTFTVirtualKeyboard(TPtrRec(PDynTFTKeyButton(TPtrRec(Sender))^.BaseProps.Parent));

  if AVK^.ShiftState and CDYNTFTSS_SHIFT = CDYNTFTSS_SHIFT then
    AText := PDynTFTKeyButton(TPtrRec(Sender))^.UpCaption
  else
    AText := PDynTFTKeyButton(TPtrRec(Sender))^.DownCaption;
    
  {$IFDEF IsDesktop}
    if Assigned(AVK^.OnCharKey) then
      if Assigned(AVK^.OnCharKey^) then
  {$ELSE}
    if AVK^.OnCharKey <> nil then
  {$ENDIF}
      AVK^.OnCharKey^(PPtrRec(TPtrRec(AVK)), AText, AVK^.ShiftState);
end;


procedure OneRowKey_OnMouseDownUser(Sender: PPtrRec);
var
  AText: TVKPressedChar;
  AVK: PDynTFTVirtualKeyboard;
begin
  AVK := PDynTFTVirtualKeyboard(TPtrRec(PDynTFTKeyButton(TPtrRec(Sender))^.BaseProps.Parent));
  AText := PDynTFTKeyButton(TPtrRec(Sender))^.UpCaption;
  
  if not IsCaps(AVK) then
  {$IFDEF IsDesktop}
    AText[1] := AnsiChar(Chr(Ord(AText[1]) + 32));       //not sure how to do this for unicode
  {$ELSE}
    AText[0] := Chr(Ord(AText[0]) + 32);
  {$ENDIF}

  {$IFDEF IsDesktop}
    if Assigned(AVK^.OnCharKey) then
      if Assigned(AVK^.OnCharKey^) then
  {$ELSE}
    if AVK^.OnCharKey <> nil then
  {$ENDIF}
      AVK^.OnCharKey^(PPtrRec(TPtrRec(AVK)), AText, AVK^.ShiftState);
end;


procedure SpecialKey_OnMouseDownUser(Sender: PPtrRec; ASpecialKey: Integer);
var
  AVK: PDynTFTVirtualKeyboard;
begin
  AVK := PDynTFTVirtualKeyboard(TPtrRec(PDynTFTKeyButton(TPtrRec(Sender))^.BaseProps.Parent));

  {$IFDEF IsDesktop}
    if Assigned(AVK^.OnSpecialKey) then
      if Assigned(AVK^.OnSpecialKey^) then
  {$ELSE}
    if AVK^.OnSpecialKey <> nil then
  {$ENDIF}
      AVK^.OnSpecialKey^(PPtrRec(TPtrRec(AVK)), ASpecialKey, AVK^.ShiftState);
end;


procedure TabKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_TAB);
end;


procedure CapsKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_CAPS);
  SetSpecialKeyColor(Sender, CDYNTFTSS_CAPS);
  SpecialKey_OnMouseDownUser(Sender, VK_CAPITAL);
end;


procedure EnterKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_RETURN);
end;


procedure ShiftKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_SHIFT);
  SetSpecialKeyColor(Sender, CDYNTFTSS_SHIFT);
  SpecialKey_OnMouseDownUser(Sender, VK_SHIFT);
end;


procedure BackSpaceKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_BACK);
end;


procedure DeleteKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_DELETE);
end;


procedure ControlKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_CTRL);
  SetSpecialKeyColor(Sender, CDYNTFTSS_CTRL);
  SpecialKey_OnMouseDownUser(Sender, VK_CONTROL);
end;


procedure AltKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_ALT);
  SetSpecialKeyColor(Sender, CDYNTFTSS_ALT);
  SpecialKey_OnMouseDownUser(Sender, VK_MENU);
end;


procedure SpaceKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_SPACE);
  TwoRowsKey_OnMouseDownUser(Sender);
end;


procedure PageUpKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_PRIOR);
end;


procedure PageDownKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_NEXT);
end;


procedure HomeKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_HOME);
end;


procedure EndKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_END);
end;


procedure LeftArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_LEFT);
end;


procedure RightArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_RIGHT);
end;


procedure UpArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_UP);
end;


procedure DownArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_DOWN);
end;


procedure AppsKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_APPS);
end;


function CreateSpecialKey(LeftOffset, TopOffset, Width, Height: Integer;
                          MouseDownHandler: {$IFDEF IsMCU} PDynTFTGenericHandlerProc {$ELSE} TDynTFTGenericHandlerProc {$ENDIF};
                          DrawingHandler: {$IFDEF IsMCU} PDynTFTGenericEventHandler {$ELSE} TDynTFTGenericEventHandler {$ENDIF};
                          {$IFDEF IsMCU} var {$ENDIF} AUpCaption: string;
                          {$IFDEF IsMCU} var {$ENDIF} ADownCaption: string;
                          AVK: PDynTFTVirtualKeyboard): PDynTFTKeyButton;
begin
  Result := DynTFTKeyButton_Create(AVK^.BaseProps.ScreenIndex, AVK^.BaseProps.Left + LeftOffset, AVK^.BaseProps.Top + TopOffset, Width, Height);
  {$IFDEF IsDesktop}
    Result^.BaseProps.OnMouseDownUser^ := MouseDownHandler;
    Result^.OnGenerateDrawingUser^ := DrawingHandler;
  {$ELSE}
    Result^.BaseProps.OnMouseDownUser := MouseDownHandler;  //without @
    Result^.OnGenerateDrawingUser := DrawingHandler; //without @
  {$ENDIF}

  Result^.UpCaption := AUpCaption;
  Result^.DownCaption := ADownCaption;
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(Result)));
  Result^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));
end;


procedure CreateTwoRowKeys(AVK: PDynTFTVirtualKeyboard; var Row1_Text, Row2_Text: string; XOffset, YOffset: Integer; MouseDownHandler: {$IFDEF IsMCU} PDynTFTGenericHandlerProc {$ELSE} TDynTFTGenericHandlerProc {$ENDIF});
const
  CKeyWidth = 16;
  CKeyHeight = 34;
var
  i, n: Integer;
  AKeyButton: PDynTFTKeyButton;
begin
  XOffset := XOffset + AVK^.BaseProps.Left;
  YOffset := YOffset + AVK^.BaseProps.Top;

  n := Length(Row1_Text);
{$IFDEF IsDesktop}
  for i := 1 to n do
{$ELSE}
  Dec(n);
  for i := 0 to n do
{$ENDIF}
  begin
    AKeyButton := DynTFTKeyButton_Create(AVK^.BaseProps.ScreenIndex, XOffset + ((CKeyWidth + 2) * (i - {$IFDEF IsDesktop} 1 {$ELSE} 0 {$ENDIF})), YOffset, CKeyWidth, CKeyHeight);

    {$IFDEF IsDesktop}
      AKeyButton^.BaseProps.OnMouseDownUser^ := MouseDownHandler;
    {$ELSE}
      AKeyButton^.BaseProps.OnMouseDownUser := MouseDownHandler;  //without @
    {$ENDIF}

    {$IFDEF IsDesktop}
      if Row1_Text <> '' then
        AKeyButton^.UpCaption := Row1_Text[i]
      else
        AKeyButton^.UpCaption := '';

      if Row2_Text <> '' then
        AKeyButton^.DownCaption := Row2_Text[i]
      else
        AKeyButton^.DownCaption := '';
    {$ELSE}
      if Length(Row1_Text) > 0 then
        AKeyButton^.UpCaption[0] := Row1_Text[i]
      else
        AKeyButton^.UpCaption[0] := #0;

      if Length(Row2_Text) > 0 then
        AKeyButton^.DownCaption[0] := Row2_Text[i]
      else
        AKeyButton^.DownCaption[0] := #0;

      AKeyButton^.UpCaption[1] := #0;
      AKeyButton^.DownCaption[1] := #0;
    {$ENDIF}

    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
    AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));
  end;
end;


const
  CNumbersRow1   = '~!@#$%^&*()_+';
  CNumbersRow2   = '`1234567890-=';
  CLettersRow1   = 'QWERTYUIOP';
  CLettersRow2   = 'ASDFGHJKL';
  CLettersRow3   = 'ZXCVBNM';
  CSpecialChars1 = '{}|';
  CSpecialChars2 = '[]\';
  CColonRow1     = ':"';
  CColonRow2     = ';' + #39;
  CDotRow1       = '<>?';
  CDotRow2       = ',./';
  CKeyDelText    = 'Del';
  CKeyCapsText   = 'Caps';
  CKeyCtrlText   = 'Ctrl';
  CKeyAltText    = 'Alt';
  CKeyPgText     = 'Pg';
  CKeyUpText     = 'Up';
  CKeyDnText     = 'Dn';
  CKeyHomeText   = 'Home';
  CKeyEndText    = 'End';

  CNullString    = '';
  CSpaceString   = ' ';


type
  TSpecialKeyInfo = record
    LeftOffset, TopOffset, Width, Height: Integer;
    MouseDownHandler: {$IFDEF IsMCU} PDynTFTGenericHandlerProc {$ELSE} TDynTFTGenericHandlerProc {$ENDIF};
    DrawingHandler: {$IFDEF IsMCU} PDynTFTGenericEventHandler {$ELSE} TDynTFTGenericEventHandler {$ENDIF};
    AUpCaption, ADownCaption: string[4];
  end;


const
  CMaxSpecialKeys = 20;
  C_Special_Keys: array[1..CMaxSpecialKeys] of TSpecialKeyInfo = (
    {$IFDEF IsDesktop}
      (LeftOffset: 280; TopOffset: 110; Width: 36; Height: 34; MouseDownHandler: DeleteKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyDelText; ADownCaption: CNullString),
      (LeftOffset: 2; TopOffset: 74; Width: 38; Height: 34; MouseDownHandler: CapsKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyCapsText; ADownCaption: CNullString),
      (LeftOffset: 240; TopOffset: 74; Width: 38; Height: 34; MouseDownHandler: EnterKey_OnMouseDownUser; DrawingHandler: DrawEnterArrow_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 2; TopOffset: 110; Width: 47; Height: 34; MouseDownHandler: ShiftKey_OnMouseDownUser; DrawingHandler: DrawShift_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 231; TopOffset: 110; Width: 47; Height: 34; MouseDownHandler: ShiftKey_OnMouseDownUser; DrawingHandler: DrawShift_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 2; TopOffset: 146; Width: 30; Height: 34; MouseDownHandler: ControlKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyCtrlText; ADownCaption: CNullString),
      (LeftOffset: 199; TopOffset: 146; Width: 30; Height: 34; MouseDownHandler: ControlKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyCtrlText; ADownCaption: CNullString),
      (LeftOffset: 34; TopOffset: 146; Width: 23; Height: 34; MouseDownHandler: AltKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyAltText; ADownCaption: CNullString),
      (LeftOffset: 153; TopOffset: 146; Width: 23; Height: 34; MouseDownHandler: AltKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyAltText; ADownCaption: CNullString),
      (LeftOffset: 59; TopOffset: 146; Width: 92; Height: 34; MouseDownHandler: SpaceKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CSpaceString; ADownCaption: CSpaceString),
      (LeftOffset: 178; TopOffset: 146; Width: 19; Height: 34; MouseDownHandler: AppsKey_OnMouseDownUser; DrawingHandler: DrawApps_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 269; TopOffset: 2; Width: 22; Height: 34; MouseDownHandler: PageUpKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyPgText; ADownCaption: CKeyUpText),
      (LeftOffset: 294; TopOffset: 2; Width: 22; Height: 34; MouseDownHandler: PageDownKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyPgText; ADownCaption: CKeyDnText),
      (LeftOffset: 269; TopOffset: 38; Width: 47; Height: 34; MouseDownHandler: HomeKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyHomeText; ADownCaption: CNullString),
      (LeftOffset: 280; TopOffset: 74; Width: 36; Height: 34; MouseDownHandler: EndKey_OnMouseDownUser; DrawingHandler: nil; AUpCaption: CKeyEndText; ADownCaption: CNullString),
      (LeftOffset: 231; TopOffset: 164; Width: 27; Height: 16; MouseDownHandler: LeftArrowKey_OnMouseDownUser; DrawingHandler: DrawLeftArrow_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 289; TopOffset: 164; Width: 27; Height: 16; MouseDownHandler: RightArrowKey_OnMouseDownUser; DrawingHandler: DrawRightArrow_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 260; TopOffset: 146; Width: 27; Height: 16; MouseDownHandler: UpArrowKey_OnMouseDownUser; DrawingHandler: DrawUpArrow_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 260; TopOffset: 164; Width: 27; Height: 16; MouseDownHandler: DownArrowKey_OnMouseDownUser; DrawingHandler: DrawDownArrow_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString),
      (LeftOffset: 236; TopOffset: 2; Width: 31; Height: 34; MouseDownHandler: BackSpaceKey_OnMouseDownUser; DrawingHandler: DrawBackSpaceArrow_OnGenerateDrawingUser; AUpCaption: CNullString; ADownCaption: CNullString)
    {$ELSE}
      (280, 110, 36, 34, @DeleteKey_OnMouseDownUser, nil, CKeyDelText, CNullString),
      (2, 74, 38, 34, @CapsKey_OnMouseDownUser, nil, CKeyCapsText, CNullString),
      (240, 74, 38, 34, @EnterKey_OnMouseDownUser, @DrawEnterArrow_OnGenerateDrawingUser, CNullString, CNullString),
      (2, 110, 47, 34, @ShiftKey_OnMouseDownUser, @DrawShift_OnGenerateDrawingUser, CNullString, CNullString),
      (231, 110, 47, 34, @ShiftKey_OnMouseDownUser, @DrawShift_OnGenerateDrawingUser, CNullString, CNullString),
      (2, 146, 30, 34, @ControlKey_OnMouseDownUser, nil, CKeyCtrlText, CNullString),
      (199, 146, 30, 34, @ControlKey_OnMouseDownUser, nil, CKeyCtrlText, CNullString),
      (34, 146, 23, 34, @AltKey_OnMouseDownUser, nil, CKeyAltText, CNullString),
      (153, 146, 23, 34, @AltKey_OnMouseDownUser, nil, CKeyAltText, CNullString),
      (59, 146, 92, 34, @SpaceKey_OnMouseDownUser, nil, CSpaceString, CSpaceString),
      (178, 146, 19, 34, @AppsKey_OnMouseDownUser, @DrawApps_OnGenerateDrawingUser, CNullString, CNullString),
      (269, 2, 22, 34, @PageUpKey_OnMouseDownUser, nil, CKeyPgText, CKeyUpText),
      (294, 2, 22, 34, @PageDownKey_OnMouseDownUser, nil, CKeyPgText, CKeyDnText),
      (269, 38, 47, 34, @HomeKey_OnMouseDownUser, nil, CKeyHomeText, CNullString),
      (280, 74, 36, 34, @EndKey_OnMouseDownUser, nil, CKeyEndText, CNullString),
      (231, 164, 27, 16, @LeftArrowKey_OnMouseDownUser, @DrawLeftArrow_OnGenerateDrawingUser, CNullString, CNullString),
      (289, 164, 27, 16, @RightArrowKey_OnMouseDownUser, @DrawRightArrow_OnGenerateDrawingUser, CNullString, CNullString),
      (260, 146, 27, 16, @UpArrowKey_OnMouseDownUser, @DrawUpArrow_OnGenerateDrawingUser, CNullString, CNullString),
      (260, 164, 27, 16, @DownArrowKey_OnMouseDownUser, @DrawDownArrow_OnGenerateDrawingUser, CNullString, CNullString),
      (236, 2, 31, 34, @BackSpaceKey_OnMouseDownUser, @DrawBackSpaceArrow_OnGenerateDrawingUser, CNullString, CNullString)
    {$ENDIF}
  );

function CreateRemainingSpecialKeys(AVK: PDynTFTVirtualKeyboard): PDynTFTKeyButton;
var
  i: Integer;
  UpCaption, DownCaption: string[4];
begin
  for i := 1 to CMaxSpecialKeys do
  begin
    UpCaption := C_Special_Keys[i].AUpCaption;
    DownCaption := C_Special_Keys[i].ADownCaption;
    
    Result := CreateSpecialKey(C_Special_Keys[i].LeftOffset, C_Special_Keys[i].TopOffset, C_Special_Keys[i].Width, C_Special_Keys[i].Height,
                               C_Special_Keys[i].MouseDownHandler,
                               C_Special_Keys[i].DrawingHandler,
                               UpCaption, 
                               DownCaption,
                               AVK);
  end;
end;


procedure CreateKeyboardKeys(AVK: PDynTFTVirtualKeyboard);
var
  AKeyButton: PDynTFTKeyButton;
  ANumbersRow1: string{$IFNDEF IsDesktop}[13]{$ENDIF};
  ANumbersRow2: string{$IFNDEF IsDesktop}[13]{$ENDIF};
  ALettersRow1: string{$IFNDEF IsDesktop}[10]{$ENDIF};
  ALettersRow2: string{$IFNDEF IsDesktop}[9]{$ENDIF};
  ALettersRow3: string{$IFNDEF IsDesktop}[7]{$ENDIF};

  ASquareBracketsRow1: string{$IFNDEF IsDesktop}[3]{$ENDIF};
  ASquareBracketsRow2: string{$IFNDEF IsDesktop}[3]{$ENDIF};

  AColonRow1: string{$IFNDEF IsDesktop}[2]{$ENDIF};
  AColonRow2: string{$IFNDEF IsDesktop}[2]{$ENDIF};

  ADotRow1: string{$IFNDEF IsDesktop}[3]{$ENDIF};
  ADotRow2: string{$IFNDEF IsDesktop}[3]{$ENDIF};

  ANullString: string{$IFNDEF IsDesktop}[1]{$ENDIF};
begin
  ANumbersRow1 := CNumbersRow1; //'~!@#$%^&*()_+';
  ANumbersRow2 := CNumbersRow2; //'`1234567890-=';
  ALettersRow1 := CLettersRow1; //'QWERTYUIOP';
  ALettersRow2 := CLettersRow2; //'ASDFGHJKL';
  ALettersRow3 := CLettersRow3; //'ZXCVBNM';

  ASquareBracketsRow1 := CSpecialChars1; //'{}|';
  ASquareBracketsRow2 := CSpecialChars2; //'[]\';

  AColonRow1 := CColonRow1; //':"';
  AColonRow2 := CColonRow2; //';' + #39;

  ADotRow1 := CDotRow1; //'<>?';
  ADotRow2 := CDotRow2; //',./';

  ANullString := '';

  //This must be the first component of the keyboard - Tab:

  AKeyButton := CreateSpecialKey(2, 38, 31, 34, {$IFDEF IsMCU}@{$ENDIF}TabKey_OnMouseDownUser, {$IFDEF IsMCU}@{$ENDIF}DrawTabArrows_OnGenerateDrawingUser, ANullString, ANullString, AVK);
  AVK^.FirstCreatedKey := PDynTFTBaseComponent(TPtrRec(AKeyButton));

  //"middle-created" components
  CreateTwoRowKeys(AVK, ANumbersRow1, ANumbersRow2, 2, 2, {$IFDEF IsMCU}@{$ENDIF}TwoRowsKey_OnMouseDownUser);
  CreateTwoRowKeys(AVK, ALettersRow1, ANullString, 35, 38, {$IFDEF IsMCU}@{$ENDIF}OneRowKey_OnMouseDownUser);
  CreateTwoRowKeys(AVK, ALettersRow2, ANullString, 42, 74, {$IFDEF IsMCU}@{$ENDIF}OneRowKey_OnMouseDownUser);
  CreateTwoRowKeys(AVK, ALettersRow3, ANullString, 51, 110, {$IFDEF IsMCU}@{$ENDIF}OneRowKey_OnMouseDownUser);

  CreateTwoRowKeys(AVK, ASquareBracketsRow1, ASquareBracketsRow2, 215, 38, {$IFDEF IsMCU}@{$ENDIF}TwoRowsKey_OnMouseDownUser);
  CreateTwoRowKeys(AVK, AColonRow1, AColonRow2, 204, 74, {$IFDEF IsMCU}@{$ENDIF}TwoRowsKey_OnMouseDownUser);
  CreateTwoRowKeys(AVK, ADotRow1, ADotRow2, 177, 110, {$IFDEF IsMCU}@{$ENDIF}TwoRowsKey_OnMouseDownUser);

  AKeyButton := CreateRemainingSpecialKeys(AVK);

  //This must be the last component of the keyboard:
  AVK^.LastCreatedKey := PDynTFTBaseComponent(TPtrRec(AKeyButton));
end;


function DynTFTVirtualKeyboard_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualKeyboard;
begin
  Result := PDynTFTVirtualKeyboard(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTVirtualKeyboard was not registered. Please call RegisterVirtualKeyboardEvents before creating a PDynTFTVirtualKeyboard. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Color := CL_DynTFTVirtualKeyboard_Background;
  Result^.ShiftState := 0;
  Result^.BaseProps.Focused := CREJECTFOCUS;
  Result^.BaseProps.CanHandleMessages := False;

  {$IFDEF IsDesktop}
    New(Result^.OnCharKey);
    New(Result^.OnSpecialKey);

    Result^.OnCharKey^ := nil;
    Result^.OnSpecialKey^ := nil;
  {$ELSE}
    Result^.OnCharKey := nil;
    Result^.OnSpecialKey := nil;
  {$ENDIF}

  CreateKeyboardKeys(Result);
end;


function DynTFTVirtualKeyboard_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTVirtualKeyboard_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTVirtualKeyboard_Destroy(var AVirtualKeyboard: PDynTFTVirtualKeyboard);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AVirtualKeyboard^.OnCharKey);
    Dispose(AVirtualKeyboard^.OnSpecialKey);

    AVirtualKeyboard^.OnCharKey := nil;
    AVirtualKeyboard^.OnSpecialKey := nil;
  {$ENDIF}

  DynTFTComponent_DestroyMultiple(AVirtualKeyboard^.FirstCreatedKey, AVirtualKeyboard^.LastCreatedKey, SizeOf(TDynTFTKeyButton));

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard)), SizeOf(AVirtualKeyboard^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard));
    DynTFTComponent_Destroy(ATemp, SizeOf(AVirtualKeyboard^));
    AVirtualKeyboard := PDynTFTVirtualKeyboard(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTVirtualKeyboard_DestroyAndPaint(var AVirtualKeyboard: PDynTFTVirtualKeyboard);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard)));
  DynTFTVirtualKeyboard_Destroy(AVirtualKeyboard);
end;


procedure DynTFTVirtualKeyboard_BaseDestroyAndPaint(var AVirtualKeyboard: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTVirtualKeyboard;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTVirtualKeyboard_DestroyAndPaint(PDynTFTVirtualKeyboard(TPtrRec(AVirtualKeyboard)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTVirtualKeyboard(TPtrRec(AVirtualKeyboard));
    DynTFTVirtualKeyboard_DestroyAndPaint(ATemp);
    AVirtualKeyboard := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
 
end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    //HideComponent(PDynTFTBaseComponent(TPtrRec(...)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    //ShowComponent(PDynTFTBaseComponent(TPtrRec(...)));
    Exit;
  end;
  
  DynTFTDrawVirtualKeyboard(PDynTFTVirtualKeyboard(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterVirtualKeyboardEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalRepaint;
    
    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTVirtualKeyboard_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTVirtualKeyboard_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTVirtualKeyboard_Create;
      ABaseEventReg.CompDestroy := @DynTFTVirtualKeyboard_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTVirtualKeyboard); 
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
