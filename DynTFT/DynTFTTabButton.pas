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

unit DynTFTTabButton;

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
  {$IFDEF UseExternalTabButtonStringLength}
    {$IFDEF ExternalTabButtonStringLengthAtProjectLevel}
      {$I ExternalTabButtonStringLength.inc}
    {$ELSE}
      {$I ..\ExternalTabButtonStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxTabButtonStringLength = 19; //n * 4 - 1
  {$ENDIF}

type
  TDynTFTTabButton = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //TabButton properties
    Caption: string[CMaxTabButtonStringLength];
    SelectedColor, UnselectedColor: TColor;
    Font_Color: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}
    TabIndex: LongInt;  //button number inside PageControl

    //these events are set by an owner component, e.g. a page control, and called by a tab button
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    {$IFDEF MouseClickSupport}
      //OnOwnerInternalClick: PDynTFTGenericEventHandler;    //Uncomment if needed. See further in code.
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //OnOwnerInternalDoubleClick: PDynTFTGenericEventHandler;    //Uncomment if needed. See further in code.
    {$ENDIF}
    OnOwnerInternalBeforeDestroy: PDynTFTGenericEventHandler;
  end;
  PDynTFTTabButton = ^TDynTFTTabButton;

procedure DynTFTDrawTabButton(ATabButton: PDynTFTTabButton; FullRedraw: Boolean);
function DynTFTTabButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTTabButton;
procedure DynTFTTabButton_Destroy(var ATabButton: PDynTFTTabButton);
procedure DynTFTTabButton_DestroyAndPaint(var ATabButton: PDynTFTTabButton);

procedure DynTFTRegisterTabButtonEvents;
function DynTFTGetTabButtonComponentType: TDynTFTComponentType;

implementation

{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetTabButtonComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawTabButton(ATabButton: PDynTFTTabButton; FullRedraw: Boolean);
var
  Col1, Col2, ACol: TColor;
  x1, y1, x2, y2: TSInt;
  HalfWidth, HalfHeight: TSInt;
  Pressed: Boolean;

  {$IFDEF CenterTextOnComponent}
    TextXOffset: TSInt; //used to compute the X coord of text on button to make the text centered
    TextYOffset: TSInt; //used to compute the Y coord of text on button to make the text centered
    TextWidth, TextHeight: Word;
  {$ENDIF}
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(ATabButton))) then
    Exit;

  Pressed := ATabButton^.BaseProps.CompState and CPRESSED <> CPRESSED;

  x1 := ATabButton^.BaseProps.Left;
  y1 := ATabButton^.BaseProps.Top;
  x2 := x1 + ATabButton^.BaseProps.Width;
  y2 := y1 + ATabButton^.BaseProps.Height;

  HalfWidth := ATabButton^.BaseProps.Width shr 1;
  HalfHeight := ATabButton^.BaseProps.Height shr 1;

  if FullRedraw then      
  begin
    if Pressed then
      ACol := ATabButton^.UnselectedColor
    else
      ACol := ATabButton^.SelectedColor;

    DynTFT_Set_Pen(ACol, 1);
    DynTFT_Set_Brush(1, ACol, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;

  if Pressed then
  begin
    Col2 := CL_DynTFTTabButton_LightEdge;
    Col1 := CL_DynTFTTabButton_DarkEdge;
  end
  else
  begin
    Col1 := CL_DynTFTTabButton_LightEdge;
    Col2 := CL_DynTFTTabButton_DarkEdge;
  end;

  //lines
  DynTFT_Set_Pen(Col1, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  DynTFT_Set_Pen(Col2, 1);
  DynTFT_V_Line(y1, y2, x2); //vert
  DynTFT_H_Line(x1, x2, y2); //horiz

  //draw text
  if ATabButton^.BaseProps.Enabled and CENABLED = CENABLED then
    ACol := ATabButton^.Font_Color
  else
    ACol := CL_DynTFTTabButton_DisabledFont;

  {$IFDEF DynTFTFontSupport}
    DynTFT_Set_Font(ATabButton^.ActiveFont, ACol, FO_HORIZONTAL);
  {$ELSE}
    DynTFT_Set_Font(@TFT_defaultFont, ACol, FO_HORIZONTAL);
  {$ENDIF}

  {$IFDEF CenterTextOnComponent}
    GetTextWidthAndHeight(ATabButton^.Caption, TextWidth, TextHeight);
    TextXOffset := HalfWidth - TSInt(TextWidth shr 1);
    if TextXOffset < 0 then
      TextXOffset := 0;

    TextYOffset := HalfHeight - TSInt(TextHeight shr 1);
    if TextYOffset < 0 then
      TextYOffset := 0;

    DynTFT_Write_Text(ATabButton^.Caption, x1 + TextXOffset, y1 + TextYOffset);
  {$ELSE}
    DynTFT_Write_Text(ATabButton^.Caption, x1 + 4, y1 + HalfHeight - 6);
  {$ENDIF}
end;


function DynTFTTabButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTTabButton;
begin
  Result := PDynTFTTabButton(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTTabButton was not registered. Please call RegisterTabButtonEvents before creating a PDynTFTTabButton. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.SelectedColor := CL_DynTFTTabButton_SelectedBackground;
  Result^.UnselectedColor := CL_DynTFTTabButton_UnselectedBackground;
  Result^.Font_Color := CL_DynTFTTabButton_EnabledFont;
  Result^.Caption := '';
  Result^.TabIndex := -1;

  {$IFDEF DynTFTFontSupport}
    Result^.ActiveFont := @TFT_defaultFont;
  {$ENDIF}

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      //New(Result^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //New(Result^.OnOwnerInternalDoubleClick);
    {$ENDIF}
    New(Result^.OnOwnerInternalBeforeDestroy);

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    {$IFDEF MouseClickSupport}
      //Result^.OnOwnerInternalClick^ := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //Result^.OnOwnerInternalDoubleClick^ := nil;
    {$ENDIF}
    Result^.OnOwnerInternalBeforeDestroy^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      //Result^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //Result^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
    Result^.OnOwnerInternalBeforeDestroy := nil;
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxTabButtonStringLength, 'PDynTFTTabButton');
  {$ENDIF}
end;


function DynTFTTabButton_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTTabButton_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTTabButton_Destroy(var ATabButton: PDynTFTTabButton);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    if Assigned(ATabButton^.OnOwnerInternalBeforeDestroy) then
      if Assigned(ATabButton^.OnOwnerInternalBeforeDestroy^) then
  {$ELSE}
    if ATabButton^.OnOwnerInternalBeforeDestroy <> nil then
  {$ENDIF}
      ATabButton^.OnOwnerInternalBeforeDestroy^(PDynTFTBaseComponent(TPtrRec(ATabButton)));  //tell the PageControl to do some cleanup (like defragmentation)

  {$IFDEF IsDesktop}
    Dispose(ATabButton^.OnOwnerInternalMouseDown);
    Dispose(ATabButton^.OnOwnerInternalMouseMove);
    Dispose(ATabButton^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      //Dispose(ATabButton^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //Dispose(ATabButton^.OnOwnerInternalDoubleClick);
    {$ENDIF}
    Dispose(ATabButton^.OnOwnerInternalBeforeDestroy);

    ATabButton^.OnOwnerInternalMouseDown := nil;
    ATabButton^.OnOwnerInternalMouseMove := nil;
    ATabButton^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      //ATabButton^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ATabButton^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
    ATabButton^.OnOwnerInternalBeforeDestroy := nil;
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ATabButton)), SizeOf(ATabButton^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(ATabButton));
    DynTFTComponent_Destroy(ATemp, SizeOf(ATabButton^));
    ATabButton := PDynTFTTabButton(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTTabButton_DestroyAndPaint(var ATabButton: PDynTFTTabButton);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(ATabButton)));
  DynTFTTabButton_Destroy(ATabButton);
end;


procedure DynTFTTabButton_BaseDestroyAndPaint(var ATabButton: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTTabButton;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTTabButton_DestroyAndPaint(PDynTFTTabButton(TPtrRec(ATabButton)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTTabButton(TPtrRec(ATabButton));
    DynTFTTabButton_DestroyAndPaint(ATemp);
    ATabButton := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTTabButton_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTTabButton_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if TabButton can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTTabButton_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if TabButton can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTTabButton_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if TabButton can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
    *)
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTTabButton_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if TabButton can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTTabButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
    *)
  end;
{$ENDIF}


procedure TDynTFTabButton_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CREPAINTONSTARTUP then
    Exit;
    
  DynTFTDrawTabButton(PDynTFTTabButton(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterTabButtonEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTTabButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTTabButton_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTTabButton_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTTabButton_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent^ := TDynTFTTabButton_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTabButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTTabButton_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTTabButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTTabButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTTabButton_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTTabButton_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTTabButton_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent := @TDynTFTTabButton_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTabButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTTabButton_Create;
      ABaseEventReg.CompDestroy := @DynTFTTabButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTTabButton); 
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
