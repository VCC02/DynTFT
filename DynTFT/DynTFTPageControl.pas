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

unit DynTFTPageControl;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTTabButton
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  CMaxPageControlPageCount = 20;

type
  TOnPageControlChangeEvent = procedure(AComp: PPtrRec);
  POnPageControlChangeEvent = ^TOnPageControlChangeEvent;

  TDynTFTPageControl = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //PageControl properties
    TabButtons: array[0..CMaxPageControlPageCount - 1] of PDynTFTTabButton;
    PageCount: LongInt;
    ActiveIndex, OldActiveIndex: LongInt;
    
    OnChange: POnPageControlChangeEvent;
  end;
  PDynTFTPageControl = ^TDynTFTPageControl;

procedure DynTFTDrawPageControl(APageControl: PDynTFTPageControl; FullRedraw: Boolean);
function DynTFTPageControl_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTPageControl;
procedure DynTFTPageControl_Destroy(var APageControl: PDynTFTPageControl);
procedure DynTFTPageControl_DestroyAndPaint(var APageControl: PDynTFTPageControl);

function DynTFTAddTabButtonToPageControl(APageControl: PDynTFTPageControl; ATabButton: PDynTFTTabButton): LongInt; //returns button index  

procedure DynTFTPageControlSetEnabledState(APageControl: PDynTFTPageControl; NewState: Byte);
procedure DynTFTEnablePageControl(ARadioGroup: PDynTFTPageControl);
procedure DynTFTDisablePageControl(ARadioGroup: PDynTFTPageControl);

procedure DynTFTRegisterPageControlEvents;
function DynTFTGetPageControlComponentType: TDynTFTComponentType;

implementation

{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetPageControlComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawPageControl(APageControl: PDynTFTPageControl; FullRedraw: Boolean);
var
  i: Integer;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(APageControl))) then
    Exit;

  if FullRedraw then
  begin
    for i := 0 to APageControl^.PageCount - 1 do
    begin
      if i = APageControl^.ActiveIndex then
        APageControl^.TabButtons[i]^.BaseProps.CompState := CPRESSED
      else
        APageControl^.TabButtons[i]^.BaseProps.CompState := CRELEASED;

      DynTFTDrawTabButton(APageControl^.TabButtons[i], True);
    end;
  end
  else
  begin
    APageControl^.TabButtons[APageControl^.OldActiveIndex]^.BaseProps.CompState := CRELEASED;
    APageControl^.TabButtons[APageControl^.ActiveIndex]^.BaseProps.CompState := CPRESSED;
    
    DynTFTDrawTabButton(APageControl^.TabButtons[APageControl^.OldActiveIndex], True);
    DynTFTDrawTabButton(APageControl^.TabButtons[APageControl^.ActiveIndex], True);
  end;
end;


procedure DynTFTPageControlSetEnabledState(APageControl: PDynTFTPageControl; NewState: Byte);
var
  n, i: Integer;
begin
  APageControl^.BaseProps.Enabled := NewState;
  n := APageControl^.PageCount - 1;
  for i := 0 to n do
  begin
    APageControl^.TabButtons[i]^.BaseProps.Enabled := NewState;
    DynTFTDrawTabButton(APageControl^.TabButtons[i], True);
  end;
end;


procedure DynTFTEnablePageControl(ARadioGroup: PDynTFTPageControl);
begin
  DynTFTPageControlSetEnabledState(ARadioGroup, CENABLED);
end;


procedure DynTFTDisablePageControl(ARadioGroup: PDynTFTPageControl);
begin
  DynTFTPageControlSetEnabledState(ARadioGroup, CDISABLED);
end;


procedure TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  APageControl: PDynTFTPageControl;
begin
  APageControl := PDynTFTPageControl(TPtrRec(PDynTFTTabButton(TPtrRec(ABase))^.BaseProps.Parent));
  APageControl^.ActiveIndex := PDynTFTTabButton(TPtrRec(ABase))^.TabIndex;

  DynTFTDrawPageControl(APageControl, APageControl^.OldActiveIndex = -1);

  if APageControl^.OldActiveIndex <> APageControl^.ActiveIndex then
  begin
    {$IFDEF IsDesktop}
      if Assigned(APageControl^.OnChange) then
        if Assigned(APageControl^.OnChange^) then
    {$ELSE}
      if APageControl^.OnChange <> nil then
    {$ENDIF}
        APageControl^.OnChange^(PPtrRec(TPtrRec(APageControl)));

    APageControl^.OldActiveIndex := APageControl^.ActiveIndex;
  end;
end;


procedure TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseUp(ABase: PDynTFTBaseComponent);
begin

end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTPageControl_OnDynTFTChildTabButtonInternalClick(ABase: PDynTFTBaseComponent);
  begin

  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTPageControl_OnDynTFTChildTabButtonInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin

  end;
{$ENDIF}


procedure TDynTFTPageControl_OnDynTFTChildTabButtonInternalBeforeDestroy(ABase: PDynTFTBaseComponent);
var
  APageControl: PDynTFTPageControl;
  i, AButtonIndex: Integer;
begin
  APageControl := PDynTFTPageControl(TPtrRec(PDynTFTTabButton(TPtrRec(ABase))^.BaseProps.Parent));
  AButtonIndex := PDynTFTTabButton(TPtrRec(ABase))^.TabIndex;

  if APageControl^.ActiveIndex = AButtonIndex then
    APageControl^.ActiveIndex := -1;

  //defragment:
  for i := AButtonIndex to APageControl^.PageCount - 2 do
  begin
    APageControl^.TabButtons[i] := APageControl^.TabButtons[i + 1];
    Dec(APageControl^.TabButtons[i]^.TabIndex);
  end;

  Dec(APageControl^.PageCount);
  if APageControl^.ActiveIndex > AButtonIndex then
    Dec(APageControl^.ActiveIndex);

  DynTFTDrawPageControl(APageControl, True);
end;


function DynTFTPageControl_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTPageControl;
var
  i: Byte;
begin
  Result := PDynTFTPageControl(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTPageControl was not registered. Please call RegisterPageControlEvents before creating a PDynTFTPageControl. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, False, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.PageCount := 0;
  Result^.ActiveIndex := 0;
  Result^.OldActiveIndex := -1;
  for i := 0 to CMaxPageControlPageCount - 1 do
    Result^.TabButtons[i] := nil;

  {$IFDEF IsDesktop}
    New(Result^.OnChange);
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.OnChange^ := nil;
  {$ELSE}
    Result^.OnChange := nil;
  {$ENDIF}
end;


function DynTFTPageControl_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTPageControl_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTPageControl_Destroy(var APageControl: PDynTFTPageControl);
var
  i: Byte;
  {$IFNDEF IsDesktop}
    ATemp: PDynTFTBaseComponent;
  {$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(APageControl^.OnChange);
    APageControl^.OnChange := nil;
  {$ENDIF}
  
  for i := 0 to APageControl^.PageCount - 1 do
  begin
    {$IFDEF IsDesktop}
      APageControl^.TabButtons[i]^.OnOwnerInternalBeforeDestroy^ := nil; //prevent the button from calling the parent's OnOwnerInternalBeforeDestroy event
    {$ELSE}
      APageControl^.TabButtons[i]^.OnOwnerInternalBeforeDestroy := nil;  //prevent the button from calling the parent's OnOwnerInternalBeforeDestroy event
    {$ENDIF}
    
    DynTFTTabButton_Destroy(APageControl^.TabButtons[i]);
  end;

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(APageControl)), SizeOf(APageControl^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(APageControl));
    DynTFTComponent_Destroy(ATemp, SizeOf(APageControl^));
    APageControl := PDynTFTPageControl(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTPageControl_DestroyAndPaint(var APageControl: PDynTFTPageControl);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(APageControl)));
  DynTFTPageControl_Destroy(APageControl);
end;


procedure DynTFTPageControl_BaseDestroyAndPaint(var APageControl: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTPageControl;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTPageControl_DestroyAndPaint(PDynTFTPageControl(TPtrRec(APageControl)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTPageControl(TPtrRec(APageControl));
    DynTFTPageControl_DestroyAndPaint(ATemp);
    APageControl := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


function DynTFTAddTabButtonToPageControl(APageControl: PDynTFTPageControl; ATabButton: PDynTFTTabButton): LongInt; //returns button index
begin
  if APageControl^.PageCount >= CMaxPageControlPageCount then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('Reached CMaxPageControlPageCount. Can''t create more tab buttons.');
    {$ELSE}
      Result := 255;
      Exit;
    {$ENDIF}
  end;
  
  APageControl^.TabButtons[APageControl^.PageCount] := ATabButton;
  Result := APageControl^.PageCount;            //Result := PageCount, then Inc it
  ATabButton^.TabIndex := Result;
  Inc(APageControl^.PageCount);
  ATabButton^.BaseProps.Parent := PPtrRec(TPtrRec(APageControl));
                             
  {$IFDEF IsDesktop}
    ATabButton^.OnOwnerInternalMouseDown^ := TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseDown;
    ATabButton^.OnOwnerInternalMouseMove^ := TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseMove;
    ATabButton^.OnOwnerInternalMouseUp^ := TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ATabButton^.OnOwnerInternalClick^ := TDynTFTPageControl_OnDynTFTChildTabButtonInternalClick;  //uncomment if needed
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ATabButton^.OnOwnerInternalDoubleClick^ := TDynTFTPageControl_OnDynTFTChildTabButtonInternalDoubleClick;  //uncomment if needed
    {$ENDIF}
    ATabButton^.OnOwnerInternalBeforeDestroy^ := TDynTFTPageControl_OnDynTFTChildTabButtonInternalBeforeDestroy;
  {$ELSE}
    ATabButton^.OnOwnerInternalMouseDown := @TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseDown;
    ATabButton^.OnOwnerInternalMouseMove := @TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseMove;
    ATabButton^.OnOwnerInternalMouseUp := @TDynTFTPageControl_OnDynTFTChildTabButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ATabButton^.OnOwnerInternalClick := @TDynTFTPageControl_OnDynTFTChildTabButtonInternalClick;  //uncomment if needed
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ATabButton^.OnOwnerInternalDoubleClick := @TDynTFTPageControl_OnDynTFTChildTabButtonInternalDoubleClick;  //uncomment if needed
    {$ENDIF}
    ATabButton^.OnOwnerInternalBeforeDestroy := @TDynTFTPageControl_OnDynTFTChildTabButtonInternalBeforeDestroy;
  {$ENDIF}
end;


procedure TDynTFTPageControl_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if PageControl can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTPageControl_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if PageControl can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTPageControl_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if PageControl can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTPageControl_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if PageControl can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
    *)
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTPageControl_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if PageControl can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTPageControl(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
    *)
  end;
{$ENDIF}


procedure TDynTFPageControl_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
var
  i, n: Integer;
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    n := PDynTFTPageControl(TPtrRec(ABase))^.PageCount - 1;
    for i := 0 to n do
    begin
      //HideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTPageControl(TPtrRec(ABase))^.TabButtons[i])));
      PDynTFTPageControl(TPtrRec(ABase))^.TabButtons[i]^.BaseProps.Visible := CHIDDEN;  //use direct assignment instead of calling HideComponent, to avoid repainting the PageControl background over screen background
    end;

    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    n := PDynTFTPageControl(TPtrRec(ABase))^.PageCount - 1;
    for i := 0 to n do
    begin
      //ShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTPageControl(TPtrRec(ABase))^.TabButtons[i])));
      PDynTFTPageControl(TPtrRec(ABase))^.TabButtons[i]^.BaseProps.Visible := CVISIBLE; //use direct assignment instead of calling ShowComponent. No benefit in using ShowComponent this time.
    end;

    Exit;
  end;

  if (Options = CAFTERDISABLEREPAINT) or (Options = CAFTERENABLEREPAINT) then
  begin
    n := PDynTFTPageControl(TPtrRec(ABase))^.PageCount - 1;
    for i := 0 to n do
      PDynTFTPageControl(TPtrRec(ABase))^.TabButtons[i]^.BaseProps.Enabled := ABase^.BaseProps.Enabled;

    //Exit;
  end;

  DynTFTDrawPageControl(PDynTFTPageControl(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterPageControlEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTPageControl_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTPageControl_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTPageControl_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTPageControl_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent^ := TDynTFTPageControl_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFPageControl_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTPageControl_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTPageControl_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTPageControl_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTPageControl_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTPageControl_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTPageControl_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent := @TDynTFTPageControl_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFPageControl_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTPageControl_Create;
      ABaseEventReg.CompDestroy := @DynTFTPageControl_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTPageControl); 
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
