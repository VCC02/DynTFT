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

unit DynTFTArrowButton;

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
  //arrow types
  CUpArrow = 0;
  CDownArrow = 1;
  CLeftArrow = 2;
  CRightArrow = 3;
  CUndefinedArrow = 4;
  CNoArrow = 255;

  //arrow size (15px � 15px)
  //CArrowSize = 14;
  //CHalfArrowSize = 7;
  //arrow size (15px � 15px)
  CArrowSize = 10;
  CHalfArrowSize = 5;   //define half arrow as constant to avoid dividing in code every time it's needed
  CQuarterArrowSize = 2;

type
  TDynTFTArrowButton = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ArrowButton properties
    Color: TColor;      //this field might be repurposed by parent components, if the button is not visible
    ArrowDir: Byte;
    DummyByte: Byte;    //since this field is mostly used for alignment, it might be repurposed by parent components

    {$IFNDEF AppArch16}
      Dummy: Word; //keep alignment to 4 bytes   (<ArrowDir> + <DummyByte> + <Dummy>)
    {$ENDIF}

    //these events are set by an owner component, e.g. a scroll bar
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    {$IFDEF MouseClickSupport}
      OnOwnerInternalClick: PDynTFTGenericEventHandler;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      OnOwnerInternalDoubleClick: PDynTFTGenericEventHandler;
    {$ENDIF}
  end;
  PDynTFTArrowButton = ^TDynTFTArrowButton;  

procedure DynTFTDrawArrowButton(AArrowButton: PDynTFTArrowButton; FullRedraw: Boolean);
function DynTFTArrowButton_CreateWithArrow(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; ArrowDir: Byte): PDynTFTArrowButton;
function DynTFTArrowButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTArrowButton;
procedure DynTFTArrowButton_Destroy(var AArrowButton: PDynTFTArrowButton);
procedure DynTFTArrowButton_DestroyAndPaint(var AArrowButton: PDynTFTArrowButton);

procedure DynTFTRegisterArrowButtonEvents;
function DynTFTGetArrowButtonComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;

{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

function DynTFTGetArrowButtonComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DrawTrianglePartForArrow(x1, y1, x2, y2, x3, y3: TSInt);
begin
  DynTFT_Line(x1, y1, x2, y2);
  DynTFT_Line(x1, y1, x3, y3);

  DynTFT_Line(x1, y1 + 1, x2, y2 + 1);
  DynTFT_Line(x1, y1 + 1, x3, y3 + 1);

  DynTFT_Line(x1, y1 + 2, x2, y2 + 2);
  DynTFT_Line(x1, y1 + 2, x3, y3 + 2);
end;


procedure DrawArrow(x, y: TSInt; Dir: Byte);
var
  x1, y1, x2, y2, x3, y3: TSInt;
begin
  {case Dir of
    CUpArrow :
      DrawTrianglePartForArrow(x + CHalfArrowSize, y, x, y + CHalfArrowSize, x + CArrowSize, y + CHalfArrowSize);

    CDownArrow :
      DrawTrianglePartForArrow(x + CHalfArrowSize, y + CArrowSize, x, y + CHalfArrowSize, x + CArrowSize, y + CHalfArrowSize);

    CLeftArrow :
      DrawTrianglePartForArrow(x, y + CHalfArrowSize, x + CHalfArrowSize, y, x + CHalfArrowSize, y + CArrowSize);

    CRightArrow :
      DrawTrianglePartForArrow(x + CArrowSize, y + CHalfArrowSize, x + CHalfArrowSize, y, x + CHalfArrowSize, y + CArrowSize);

    CUndefinedArrow :
    begin
      DrawTrianglePartForArrow(x, y + CHalfArrowSize, x + CHalfArrowSize, y, x + CHalfArrowSize, y + CArrowSize);
      DrawTrianglePartForArrow(x + CArrowSize, y + CHalfArrowSize, x + CHalfArrowSize, y, x + CHalfArrowSize, y + CArrowSize);
    end;
  end;}

  x1 := x;
  y1 := y;
  x2 := x;
  y2 := y;
  //x3 := x;
  //y3 := y;

  case Dir of
    CUpArrow :
    begin
      x1 := x + CHalfArrowSize;
      //y1 := y;
      //x2 := x;
      y2 := y + CHalfArrowSize;
      x3 := x + CArrowSize;
      y3 := y + CHalfArrowSize;
    end;

    CDownArrow :
    begin
      x1 := x + CHalfArrowSize;
      y1 := y + CArrowSize;
      //x2 := x;
      y2 := y + CHalfArrowSize;
      x3 := x + CArrowSize;
      y3 := y + CHalfArrowSize;
    end;

    CLeftArrow :
    begin
      //x1 := x;
      y1 := y + CHalfArrowSize;
      x2 := x + CHalfArrowSize;
      //y2 := y;
      x3 := x + CHalfArrowSize;
      y3 := y + CArrowSize;
    end;

    CRightArrow :
    begin
      x1 := x + CArrowSize;
      y1 := y + CHalfArrowSize;
      x2 := x + CHalfArrowSize;
      //y2 := y;
      x3 := x + CHalfArrowSize;
      y3 := y + CArrowSize;
    end;

    CUndefinedArrow :
    begin
      DrawArrow(x, y, CLeftArrow);
      DrawArrow(x, y, CRightArrow);
      Exit;
    end
  else
    Exit;  
  end;

  DrawTrianglePartForArrow(x1, y1, x2, y2, x3, y3);
end;


procedure DynTFTDrawArrowButton(AArrowButton: PDynTFTArrowButton; FullRedraw: Boolean);
var
  Col1, Col2: TColor;
  XRef, YRef: TSInt;
  x1, y1, x2, y2: TSInt;
  HalfWidth, HalfHeight, PressOffset: TSInt;
  Pressed: Boolean;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AArrowButton))) then
    Exit;

  Pressed := AArrowButton^.BaseProps.CompState and (CPRESSED xor CDISABLEPRESSING) = CPRESSED;

  x1 := AArrowButton^.BaseProps.Left;
  y1 := AArrowButton^.BaseProps.Top;
  x2 := x1 + AArrowButton^.BaseProps.Width;
  y2 := y1 + AArrowButton^.BaseProps.Height;

  HalfWidth := AArrowButton^.BaseProps.Width shr 1;
  HalfHeight := AArrowButton^.BaseProps.Height shr 1;

  if FullRedraw then        //commented for debug 2014.01.27
  begin
    DynTFT_Set_Pen(AArrowButton^.Color, 1);    //debug color: $003380FF
    DynTFT_Set_Brush(1, AArrowButton^.Color, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;

  if Pressed then
  begin
    Col2 := CL_DynTFTArrowButton_LightEdge;
    Col1 := CL_DynTFTArrowButton_DarkEdge;
  end
  else
  begin
    Col1 := CL_DynTFTArrowButton_LightEdge;
    Col2 := CL_DynTFTArrowButton_DarkEdge;
  end;

  //border lines
  DynTFT_Set_Pen(Col1, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  DynTFT_Set_Pen(Col2, 1);
  DynTFT_V_Line(y1, y2, x2); //vert
  DynTFT_H_Line(x1, x2, y2); //horiz

  //set arrow size
  XRef := x1 + HalfWidth - CHalfArrowSize;
  YRef := y1 + HalfHeight - CHalfArrowSize - 1;
      
  case AArrowButton^.ArrowDir of
    CUpArrow :
      YRef := YRef + CQuarterArrowSize;

    CDownArrow :
      YRef := YRef - CQuarterArrowSize; //CHalfArrowSize;

    CLeftArrow :
      XRef := XRef + CQuarterArrowSize;

    CRightArrow :
      XRef := XRef - CQuarterArrowSize;
  end;

  //clear arrow
  PressOffset := DynTFTOrdBoolWord(not Pressed);
  DynTFT_Set_Pen(AArrowButton^.Color, 1);
  DrawArrow(XRef + PressOffset, YRef + PressOffset, AArrowButton^.ArrowDir);

  //Draw focus rectangle from lines
  if AArrowButton^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    Col1 := CL_DynTFTArrowButton_FocusRectangle
  else
    Col1 := AArrowButton^.Color;

  DynTFT_Set_Pen(Col1, 1);  

  DynTFT_V_Line(y1 + 3, y2 - 3, x1 + 3); //vert
  DynTFT_H_Line(x1 + 3, x2 - 3, y1 + 3); //horiz
  DynTFT_V_Line(y1 + 3, y2 - 3, x2 - 3); //vert
  DynTFT_H_Line(x1 + 3, x2 - 3, y2 - 3); //horiz

  //draw arrow
  PressOffset := DynTFTOrdBoolWord(Pressed);
  
  if AArrowButton^.BaseProps.Enabled and CENABLED = CDISABLED then
    Col1 := CL_DynTFTArrowButton_DisabledArrow
  else
    Col1 := CL_DynTFTArrowButton_EnabledArrow;

  DynTFT_Set_Pen(Col1, 1);  
    
  DrawArrow(XRef + PressOffset, YRef + PressOffset, AArrowButton^.ArrowDir);
end;


function DynTFTArrowButton_CreateWithArrow(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; ArrowDir: Byte): PDynTFTArrowButton;
begin
  Result := PDynTFTArrowButton(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTArrowButton was not registered. Please call RegisterArrowButtonEvents before creating a PDynTFTArrowButton. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.ArrowDir := ArrowDir;
  Result^.Color := CL_DynTFTArrowButton_Background;

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

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
        {DynTFT_DebugConsole('--- Allocating user event handlers of arrow button $' + IntToHex(TPTr(Result), 8) +
                            '  Addr(Down) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseDown), 8) +
                            '  Addr(Move) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseMove), 8) +
                            '  Addr(Up) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseUp), 8)
                            );}
    {$ENDIF}
  {$ENDIF}
end;


function DynTFTArrowButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTArrowButton;
begin
  Result := DynTFTArrowButton_CreateWithArrow(ScreenIndex, Left, Top, Width, Height, CUpArrow);
end;


function DynTFTArrowButton_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTArrowButton_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTArrowButton_Destroy(var AArrowButton: PDynTFTArrowButton);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      {DynTFT_DebugConsole('/// Disposing internal event handlers of arrow button: ' + AArrowButton^.BaseProps.Name +
                          '  Addr(Down) = $' + IntToHex(TPTr(AArrowButton^.OnOwnerInternalMouseDown), 8) +
                          '  Addr(Move) = $' + IntToHex(TPTr(AArrowButton^.OnOwnerInternalMouseMove), 8) +
                          '  Addr(Up) = $' + IntToHex(TPTr(AArrowButton^.OnOwnerInternalMouseUp), 8)
                          );}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    Dispose(AArrowButton^.OnOwnerInternalMouseDown);
    Dispose(AArrowButton^.OnOwnerInternalMouseMove);
    Dispose(AArrowButton^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      Dispose(AArrowButton^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Dispose(AArrowButton^.OnOwnerInternalDoubleClick);
    {$ENDIF}

    AArrowButton^.OnOwnerInternalMouseDown := nil;
    AArrowButton^.OnOwnerInternalMouseMove := nil;
    AArrowButton^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      AArrowButton^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AArrowButton^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AArrowButton)), SizeOf(AArrowButton^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AArrowButton));
    DynTFTComponent_Destroy(ATemp, SizeOf(AArrowButton^));
    AArrowButton := PDynTFTArrowButton(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTArrowButton_DestroyAndPaint(var AArrowButton: PDynTFTArrowButton);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AArrowButton)));
  DynTFTArrowButton_Destroy(AArrowButton);
end;


procedure DynTFTArrowButton_BaseDestroyAndPaint(var AArrowButton: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTArrowButton;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTArrowButton_DestroyAndPaint(PDynTFTArrowButton(TPtrRec(AArrowButton)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTArrowButton(TPtrRec(AArrowButton));
    DynTFTArrowButton_DestroyAndPaint(ATemp);
    AArrowButton := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTArrowButton_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawArrowButton(PDynTFTArrowButton(TPtrRec(ABase)), ABase^.BaseProps.Focused and CFOCUSED = CFOCUSED);

  //e.g. scrollbar buttons:
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTArrowButton_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTArrowButton_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawArrowButton(PDynTFTArrowButton(TPtrRec(ABase)), False);

  {$IFDEF IsDesktop}
    if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTArrowButton_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTArrowButton_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTArrowButton(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
  end;
{$ENDIF}


procedure TDynTFTArrowButton_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTDrawArrowButton(PDynTFTArrowButton(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterArrowButtonEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTArrowButton_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTArrowButton_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTArrowButton_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := TDynTFTArrowButton_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent^ := TDynTFTArrowButton_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTArrowButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTArrowButton_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTArrowButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTArrowButton_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTArrowButton_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTArrowButton_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := @TDynTFTArrowButton_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := @TDynTFTArrowButton_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTArrowButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTArrowButton_BaseCreate;
      ABaseEventReg.CompDestroy := @DynTFTArrowButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTArrowButton);
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
