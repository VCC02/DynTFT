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

unit DynTFTButton;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  {$IFDEF UseExternalButtonStringLength}
    {$IFDEF ExternalButtonStringLengthAtProjectLevel}
      {$I ExternalButtonStringLength.inc}
    {$ELSE}
      {$I ..\ExternalButtonStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxButtonStringLength = 19; //n * 4 - 1
  {$ENDIF}

type
  TDynTFTButton = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //button properties
    Caption: string[CMaxButtonStringLength];
    Color: TColor;
    Font_Color: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}
  end;
  PDynTFTButton = ^TDynTFTButton;

procedure DynTFTDrawButton(AButton: PDynTFTButton; FullRedraw: Boolean);
function DynTFTButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTButton;
procedure DynTFTButton_Destroy(var AButton: PDynTFTButton);
procedure DynTFTButton_DestroyAndPaint(var AButton: PDynTFTButton);

procedure DynTFTRegisterButtonEvents;
function DynTFTGetButtonComponentType: TDynTFTComponentType;


implementation

var
  ComponentType: TDynTFTComponentType;

{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

function DynTFTGetButtonComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawButton(AButton: PDynTFTButton; FullRedraw: Boolean);
var
  Col1, Col2, BkCol: TColor;
  x1, y1, x2, y2: TSInt;
  HalfWidth, HalfHeight: TSInt;
  TextWidth, TextHeight: Word;

  {$IFDEF CenterTextOnComponent}
    TextXOffset: TSInt; //used to compute the X coord of text on button to make the text centered
    TextYOffset: TSInt; //used to compute the Y coord of text on button to make the text centered
  {$ENDIF}
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AButton))) then
    Exit;

  x1 := AButton^.BaseProps.Left;
  y1 := AButton^.BaseProps.Top;
  x2 := x1 + AButton^.BaseProps.Width;
  y2 := y1 + AButton^.BaseProps.Height;

  BkCol := AButton^.Color;

  if FullRedraw then        //commented for debug 2014.01.27
  begin
    DynTFT_Set_Pen(BkCol, 1);
    DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;

  //Draw focus rectangle from lines
  if AButton^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    BkCol := CL_DynTFTButton_FocusRectangle
  else
    BkCol := AButton^.Color;

  DynTFT_Set_Pen(BkCol, 1);

  DynTFT_V_Line(y1 + 3, y2 - 3, x1 + 3); //vert
  DynTFT_H_Line(x1 + 3, x2 - 3, y1 + 3); //horiz
  DynTFT_V_Line(y1 + 3, y2 - 3, x2 - 3); //vert
  DynTFT_H_Line(x1 + 3, x2 - 3, y2 - 3); //horiz

  if AButton^.BaseProps.CompState and CPRESSED = CPRESSED then
  begin
    Col2 := CL_DynTFTButton_LightEdge;
    Col1 := CL_DynTFTButton_DarkEdge;
  end
  else
  begin
    Col1 := CL_DynTFTButton_LightEdge;
    Col2 := CL_DynTFTButton_DarkEdge;
  end;

  //border lines
  DynTFT_Set_Pen(Col1, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  DynTFT_Set_Pen(Col2, 1);
  DynTFT_V_Line(y1, y2, x2); //vert
  DynTFT_H_Line(x1, x2, y2); //horiz

  if Length(AButton^.Caption) > 0 then
  begin
    //draw text
    if AButton^.BaseProps.Enabled and CENABLED = CDISABLED then
      {$IFDEF DynTFTFontSupport}
        DynTFT_Set_Font(AButton^.ActiveFont, CL_DynTFTButton_DisabledFont, FO_HORIZONTAL)
      {$ELSE}
        DynTFT_Set_Font(@TFT_defaultFont, CL_DynTFTButton_DisabledFont, FO_HORIZONTAL)
      {$ENDIF}
    else
      {$IFDEF DynTFTFontSupport}
        DynTFT_Set_Font(AButton^.ActiveFont, AButton^.Font_Color, FO_HORIZONTAL);
      {$ELSE}
        DynTFT_Set_Font(@TFT_defaultFont, AButton^.Font_Color, FO_HORIZONTAL);
      {$ENDIF}

    {$IFDEF CenterTextOnComponent}
      HalfWidth := AButton^.BaseProps.Width shr 1;
      HalfHeight := AButton^.BaseProps.Height shr 1;
  
      GetTextWidthAndHeight(AButton^.Caption, TextWidth, TextHeight);
      TextXOffset := HalfWidth - TSInt(TextWidth shr 1);
      if TextXOffset < 0 then
        TextXOffset := 0;

      TextYOffset := HalfHeight - TSInt(TextHeight shr 1);
      if TextYOffset < 0 then
        TextYOffset := 0;

      DynTFT_Write_Text(AButton^.Caption, x1 + TextXOffset, y1 + TextYOffset);
    {$ELSE}
      DynTFT_Write_Text(AButton^.Caption, x1 + 4, y1 + HalfHeight - 6);
    {$ENDIF}
  end;
end;


function DynTFTButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTButton;
begin
  Result := PDynTFTButton(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTButton was not registered. Please call RegisterButtonEvents before creating a PDynTFTButton. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));
 
  Result^.Color := CL_DynTFTButton_Background;
  Result^.Font_Color := CL_DynTFTButton_EnabledFont;
  Result^.Caption := '';

  {$IFDEF DynTFTFontSupport}
    Result^.ActiveFont := @TFT_defaultFont;
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxButtonStringLength, 'PDynTFTButton');
  {$ENDIF}
end;


function DynTFTButton_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTButton_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTButton_Destroy(var AButton: PDynTFTButton);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AButton)), SizeOf(AButton^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AButton));
    DynTFTComponent_Destroy(ATemp, SizeOf(AButton^));
    AButton := PDynTFTButton(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTButton_DestroyAndPaint(var AButton: PDynTFTButton);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AButton)));
  //RepaintScreenComponentsFromArea(PDynTFTBaseComponent(TPtrRec(AButton)));   //use this if the button overlaps other components
  DynTFTButton_Destroy(AButton);
end;


procedure DynTFTButton_BaseDestroyAndPaint(var AButton: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTButton;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTButton_DestroyAndPaint(PDynTFTButton(TPtrRec(AButton)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTButton(TPtrRec(AButton));
    DynTFTButton_DestroyAndPaint(ATemp);
    AButton := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTButton_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawButton(PDynTFTButton(TPtrRec(ABase)), ABase^.BaseProps.Focused and CFOCUSED = CFOCUSED);
end;


procedure TDynTFTButton_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTButton_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawButton(PDynTFTButton(TPtrRec(ABase)), False);
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTButton_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin

  end;
{$ENDIF}


procedure TDynTFTButton_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTDrawButton(PDynTFTButton(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterButtonEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}

    ABaseEventReg.MouseDownEvent^ := TDynTFTButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTButton_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTButton_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTButton_OnDynTFTBaseInternalClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTButton_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTButton_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTButton_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTButton_OnDynTFTBaseInternalClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTButton_Create;
      ABaseEventReg.CompDestroy := @DynTFTButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTButton); 
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
