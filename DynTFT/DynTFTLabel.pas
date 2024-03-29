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

unit DynTFTLabel;

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
  {$IFDEF UseExternalLabelStringLength}
    {$IFDEF ExternalLabelStringLengthAtProjectLevel}
      {$I ExternalLabelStringLength.inc}
    {$ELSE}
      {$I ..\ExternalLabelStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxLabelStringLength = 19; //n * 4 - 1
  {$ENDIF}

type
  TDynTFTLabel = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //Label properties
    Caption: string[CMaxLabelStringLength];
    Color: TColor;      //When negative values, it means transparent. If changing from color to transparent on run time, call ClearComponentAreaWithScreenColor or RepaintScreenComponentsFromArea to repaint the background under the label.  
    Font_Color: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}

    //these events are set by an owner component, e.g. a combo box
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
  PDynTFTLabel = ^TDynTFTLabel;

procedure DynTFTDrawLabel(ALabel: PDynTFTLabel; FullRedraw: Boolean);
function DynTFTLabel_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTLabel;
procedure DynTFTLabel_Destroy(var ALabel: PDynTFTLabel);
procedure DynTFTLabel_DestroyAndPaint(var ALabel: PDynTFTLabel);

procedure DynTFTLabel_UpdateCaption(ALabel: PDynTFTLabel; {$IFDEF IsMCU} var {$ENDIF} NewCaption: string);  //reduced flicker - caption update

procedure DynTFTRegisterLabelEvents;
function DynTFTGetLabelComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetLabelComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;
                   

procedure DynTFTDrawLabel(ALabel: PDynTFTLabel; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
  AColor: TColor;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(ALabel))) then
    Exit;
    
  x1 := ALabel^.BaseProps.Left;
  y1 := ALabel^.BaseProps.Top;
  x2 := x1 + ALabel^.BaseProps.Width;
  y2 := y1 + ALabel^.BaseProps.Height;

  if FullRedraw then
    if ALabel^.Color > -1 then
    begin
      DynTFT_Set_Pen(ALabel^.Color, 1);
      DynTFT_Set_Brush(1, ALabel^.Color, 0, 0, 0, 0);
      DynTFT_Rectangle(x1, y1, x2, y2);
    end;

  if Length(ALabel^.Caption) > 0 then
  begin
    if ALabel^.BaseProps.Enabled and CENABLED = CENABLED then
      AColor := ALabel^.Font_Color
    else
      AColor := CL_DynTFTLabel_DisabledFont;

    {$IFDEF DynTFTFontSupport}
      DynTFT_Set_Font(ALabel^.ActiveFont, AColor, FO_HORIZONTAL);
    {$ELSE}
      DynTFT_Set_Font(@TFT_defaultFont, AColor, FO_HORIZONTAL);
    {$ENDIF}

    DynTFT_Write_Text(ALabel^.Caption, x1 + 1, y1 + 1);
  end;
end;


function DynTFTLabel_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTLabel;
begin
  Result := PDynTFTLabel(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTLabel was not registered. Please call RegisterLabelEvents before creating a PDynTFTLabel. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Font_Color := CL_DynTFTLabel_EnabledFont;
  Result^.Color := CL_DynTFTLabel_Background;
  Result^.Caption := '';

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

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
        {DynTFT_DebugConsole('--- Allocating user event handlers of label $' + IntToHex(TPTr(Result), 8) +
                            '  Addr(Down) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseDown), 8) +
                            '  Addr(Move) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseMove), 8) +
                            '  Addr(Up) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseUp), 8)
                            );}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxLabelStringLength, 'PDynTFTLabel');
  {$ENDIF}
end;


function DynTFTLabel_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTLabel_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTLabel_Destroy(var ALabel: PDynTFTLabel);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      {DynTFT_DebugConsole('/// Disposing internal event handlers of label: ' + ALabel^.BaseProps.Name +
                          '  Addr(Down) = $' + IntToHex(TPTr(ALabel^.OnOwnerInternalMouseDown), 8) +
                          '  Addr(Move) = $' + IntToHex(TPTr(ALabel^.OnOwnerInternalMouseMove), 8) +
                          '  Addr(Up) = $' + IntToHex(TPTr(ALabel^.OnOwnerInternalMouseUp), 8)
                          );}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    Dispose(ALabel^.OnOwnerInternalMouseDown);
    Dispose(ALabel^.OnOwnerInternalMouseMove);
    Dispose(ALabel^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      Dispose(ALabel^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Dispose(ALabel^.OnOwnerInternalDoubleClick);
    {$ENDIF}

    ALabel^.OnOwnerInternalMouseDown := nil;
    ALabel^.OnOwnerInternalMouseMove := nil;
    ALabel^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      ALabel^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ALabel^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ALabel)), SizeOf(ALabel^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(ALabel));
    DynTFTComponent_Destroy(ATemp, SizeOf(ALabel^));
    ALabel := PDynTFTLabel(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTLabel_DestroyAndPaint(var ALabel: PDynTFTLabel);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(ALabel)));
  DynTFTLabel_Destroy(ALabel);
end;


procedure DynTFTLabel_UpdateCaption(ALabel: PDynTFTLabel; {$IFDEF IsMCU} var {$ENDIF} NewCaption: string);
var
  TempColor: TColor;
begin
  TempColor := ALabel^.Font_Color;

  ALabel^.Font_Color := ALabel^.Color;
  DynTFTDrawLabel(ALabel, False);

  if Length(NewCaption) > CMaxLabelStringLength then
  begin
    {$IFDEF IsDesktop}
      ALabel^.Caption := Copy(NewCaption, 1, CMaxLabelStringLength);
    {$ELSE}
      DynTFTCopyStr(NewCaption, 0, CMaxLabelStringLength, ALabel^.Caption);
    {$ENDIF}
  end
  else
    ALabel^.Caption := NewCaption;

  ALabel^.Font_Color := TempColor;
  DynTFTDrawLabel(ALabel, False);
end;


procedure DynTFTLabel_BaseDestroyAndPaint(var ALabel: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTLabel;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTLabel_DestroyAndPaint(PDynTFTLabel(TPtrRec(ALabel)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTLabel(TPtrRec(ALabel));
    DynTFTLabel_DestroyAndPaint(ATemp);
    ALabel := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTLabel_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTLabel_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if Label can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTLabel_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if Label can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTLabel_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTLabel_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTLabel(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
  end;
{$ENDIF}


procedure TDynTFTLabel_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;
    
  DynTFTDrawLabel(PDynTFTLabel(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterLabelEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTLabel_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTLabel_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTLabel_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := TDynTFTLabel_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent^ := TDynTFTLabel_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTLabel_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTLabel_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTLabel_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTLabel_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTLabel_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTLabel_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := @TDynTFTLabel_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := @TDynTFTLabel_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTLabel_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTLabel_Create;
      ABaseEventReg.CompDestroy := @DynTFTLabel_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTLabel); 
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
