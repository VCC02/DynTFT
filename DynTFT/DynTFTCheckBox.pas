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
   
unit DynTFTCheckBox;

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
  {$IFDEF UseExternalCheckBoxStringLength}
    {$IFDEF ExternalCheckBoxStringLengthAtProjectLevel}
      {$I ExternalCheckBoxStringLength.inc}
    {$ELSE}
      {$I ..\ExternalCheckBoxStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxCheckBoxStringLength = 19; //n * 4 - 1
  {$ENDIF}

type
  TDynTFTCheckBox = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //CheckBox properties
    Checked: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}
    Caption: string[CMaxCheckBoxStringLength];
    Color: TColor;
    Font_Color: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}
  end;
  PDynTFTCheckBox = ^TDynTFTCheckBox;

procedure DynTFTDrawCheckBox(ACheckBox: PDynTFTCheckBox; FullRedraw: Boolean);
function DynTFTCheckBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTCheckBox;
procedure DynTFTCheckBox_Destroy(var ACheckBox: PDynTFTCheckBox);
procedure DynTFTCheckBox_DestroyAndPaint(var ACheckBox: PDynTFTCheckBox);

procedure DrawTick(Left, Top: Integer); //available for use by other components

procedure DynTFTRegisterCheckBoxEvents;
function DynTFTGetCheckBoxComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetCheckBoxComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DrawTick(Left, Top: Integer);
var
  x1, y1, x2, y2: TSInt;
begin
  x1 := Left + 3;
  y1 := Top + 5;
  x2 := Left + 5;
  y2 := Top + 7;
  DynTFT_Line(x1, y1, x2, y2);
  DynTFT_Line(x1, y1 + 1, x2, y2 + 1);
  DynTFT_Line(x1, y1 + 2, x2, y2 + 2);

  x1 := Left + 9;   //9
  y1 := Top + 3;    //3
  x2 := Left + 5;   //5
  y2 := Top + 7;    //7

  DynTFT_Line(x1, y1, x2, y2);
  DynTFT_Line(x1, y1 + 1, x2, y2 + 1);
  DynTFT_Line(x1, y1 + 2, x2, y2 + 2);
end;  


procedure DynTFTDrawCheckBox(ACheckBox: PDynTFTCheckBox; FullRedraw: Boolean);
var
  BoxColor, BkCol: TColor;
  x1, y1, x2, y2, x3, y3: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(ACheckBox))) then
    Exit;

  x1 := ACheckBox^.BaseProps.Left;
  y1 := ACheckBox^.BaseProps.Top;
  x2 := x1 + 12;
  y2 := y1 + 12;
  x3 := x1 + ACheckBox^.BaseProps.Width;
  y3 := y1 + ACheckBox^.BaseProps.Height;  

  if ACheckBox^.BaseProps.Enabled and CENABLED = CDISABLED then
    BoxColor := CL_DynTFTCheckBox_DisabledBox
  else
    BoxColor := CL_DynTFTCheckBox_EnabledBox;

  if FullRedraw then
  begin
    DynTFT_Set_Pen(ACheckBox^.Color, 1);
    DynTFT_Set_Brush(1, ACheckBox^.Color, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x3, y3);

    DynTFT_Set_Brush(1, BoxColor, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;

  //Draw focus rectangle from lines
  if ACheckBox^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    BkCol := CL_DynTFTCheckBox_FocusRectangle
  else
    BkCol := ACheckBox^.Color;

  //Focus rectangle  
  Dec(y3);
  DynTFT_Set_Pen(BkCol, 1);
  DynTFT_V_Line(y1, y3, x2 + 2); //vert
  DynTFT_H_Line(x2 + 2, x3 - 2, y1); //horiz
  DynTFT_V_Line(y1, y3, x3 - 2); //vert
  DynTFT_H_Line(x2 + 2, x3 - 2, y3); //horiz

  //tickbox lines  (lowered rectangle)
  DynTFT_Set_Pen(CL_DynTFTCheckBox_DarkEdge, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  DynTFT_Set_Pen(CL_DynTFTCheckBox_LightEdge, 1);
  DynTFT_V_Line(y1, y2, x2); //vert
  DynTFT_H_Line(x1, x2, y2); //horiz

  Inc(x1);
  Dec(x2);
  Inc(y1);
  Dec(y2);
  DynTFT_Set_Pen(CL_DynTFTCheckBox_DarkDarkEdge, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  x1 := ACheckBox^.BaseProps.Left;
  y1 := ACheckBox^.BaseProps.Top;
  x2 := x1 + 12;
  y2 := y1 + 12;

  Inc(x1);
  Dec(x2);
  Inc(y1);
  Dec(y2);
  DynTFT_Set_Pen(CL_DynTFTCheckBox_LightDarkEdge, 1);
  DynTFT_V_Line(y1, y2, x2); //vert
  DynTFT_H_Line(x1, x2, y2); //horiz

  //tick
  if ACheckBox^.Checked then
    DynTFT_Set_Pen(CL_DynTFTCheckBox_Tick, 1)
  else
    DynTFT_Set_Pen(BoxColor, 1);

  DrawTick(ACheckBox^.BaseProps.Left, ACheckBox^.BaseProps.Top);

  if FullRedraw then
  begin
    //Caption
    if ACheckBox^.BaseProps.Enabled = 0 then
      {$IFDEF DynTFTFontSupport}
        DynTFT_Set_Font(ACheckBox^.ActiveFont, CL_DynTFTCheckBox_DisabledFont, FO_HORIZONTAL)
      {$ELSE}
        DynTFT_Set_Font(@TFT_defaultFont, CL_DynTFTCheckBox_DisabledFont, FO_HORIZONTAL)
      {$ENDIF}
    else
      {$IFDEF DynTFTFontSupport}
        DynTFT_Set_Font(ACheckBox^.ActiveFont, ACheckBox^.Font_Color, FO_HORIZONTAL);
      {$ELSE}
        DynTFT_Set_Font(@TFT_defaultFont, ACheckBox^.Font_Color, FO_HORIZONTAL);
      {$ENDIF}
        
    DynTFT_Write_Text(ACheckBox^.Caption, ACheckBox^.BaseProps.Left + 16, ACheckBox^.BaseProps.Top + 1);
  end;
end;


function DynTFTCheckBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTCheckBox;
begin
  Result := PDynTFTCheckBox(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTCheckBox was not registered. Please call RegisterCheckBoxEvents before creating a PDynTFTCheckBox. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Checked := False;
  Result^.Color := CL_DynTFTCheckBox_Background;
  Result^.Font_Color := CL_DynTFTCheckBox_EnabledFont;
  Result^.Caption := '';

  {$IFDEF DynTFTFontSupport}
    Result^.ActiveFont := @TFT_defaultFont;
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxCheckBoxStringLength, 'PDynTFTCheckBox');
  {$ENDIF}
end;


function DynTFTCheckBox_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTCheckBox_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTCheckBox_Destroy(var ACheckBox: PDynTFTCheckBox);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ACheckBox)), SizeOf(ACheckBox^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(ACheckBox));
    DynTFTComponent_Destroy(ATemp, SizeOf(ACheckBox^));
    ACheckBox := PDynTFTCheckBox(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTCheckBox_DestroyAndPaint(var ACheckBox: PDynTFTCheckBox);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(ACheckBox)));
  DynTFTCheckBox_Destroy(ACheckBox);
end;


procedure DynTFTCheckBox_BaseDestroyAndPaint(var ACheckBox: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTCheckBox;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTCheckBox_DestroyAndPaint(PDynTFTCheckBox(TPtrRec(ACheckBox)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTCheckBox(TPtrRec(ACheckBox));
    DynTFTCheckBox_DestroyAndPaint(ATemp);
    ACheckBox := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTCheckBox_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if checkbox can be part of another component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTCheckBox_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if checkbox can be part of another component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTCheckBox_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  if ABase^.BaseProps.Visible > 0 then
    if ABase^.BaseProps.Enabled > 0 then
      if DynTFTMouseOverComponent(ABase) then
        PDynTFTCheckBox(TPtrRec(ABase))^.Checked := not PDynTFTCheckBox(TPtrRec(ABase))^.Checked;  //move this to OnDynTFTBaseInternalClick when implemented  (without the three checks) 

  DynTFTDrawCheckBox(PDynTFTCheckBox(TPtrRec(ABase)), False);
  
  (* implement these if checkbox can be part of another component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)    
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTCheckBox_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if checkbox can be part of another component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
    *)
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTCheckBox_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if checkbox can be part of another component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTCheckBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
    *)
  end;
{$ENDIF}


procedure TDynTFTCheckBox_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTDrawCheckBox(PDynTFTCheckBox(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterCheckBoxEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTCheckBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTCheckBox_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTCheckBox_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTCheckBox_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent^ := TDynTFTCheckBox_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTCheckBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTCheckBox_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTCheckBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTCheckBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTCheckBox_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTCheckBox_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTCheckBox_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent := @TDynTFTCheckBox_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTCheckBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTCheckBox_BaseCreate;
      ABaseEventReg.CompDestroy := @DynTFTCheckBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTCheckBox);
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
