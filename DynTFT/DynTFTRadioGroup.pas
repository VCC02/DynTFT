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

unit DynTFTRadioGroup;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTRadioButton
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  {$IFDEF UseExternalRadioGroupStringLength}
    {$IFDEF ExternalRadioGroupStringLengthAtProjectLevel}
      {$I ExternalRadioGroupStringLength.inc}
    {$ELSE}
      {$I ..\ExternalRadioGroupStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxRadioGroupStringLength = 19; //n * 4 - 1
  {$ENDIF}

  CMaxRadioGroupButtonCount = 20;

type
  TOnRadioGroupSelectionChangedEvent = procedure(AComp: PPtrRec);
  POnRadioGroupSelectionChangedEvent = ^TOnRadioGroupSelectionChangedEvent;
  
  TDynTFTRadioGroup = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //RadioGroup properties
    ItemIndex, OldItemIndex: LongInt;
    ButtonCount: LongInt;
    Caption: string[CMaxRadioGroupStringLength];
    Color: TColor;
    Font_Color: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}

    Buttons: array[0..CMaxRadioGroupButtonCount - 1] of PDynTFTRadioButton;
    OnSelectionChanged: POnRadioGroupSelectionChangedEvent;
  end;
  PDynTFTRadioGroup = ^TDynTFTRadioGroup;

procedure DynTFTDrawRadioGroup(ARadioGroup: PDynTFTRadioGroup; FullRedraw: Boolean);
function DynTFTRadioGroup_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTRadioGroup;
procedure DynTFTRadioGroup_Destroy(var ARadioGroup: PDynTFTRadioGroup);
procedure DynTFTRadioGroup_DestroyAndPaint(var ARadioGroup: PDynTFTRadioGroup);

function DynTFTAddRadioButtonToRadioGroup(ARadioGroup: PDynTFTRadioGroup; ARadioButton: PDynTFTRadioButton): Byte; //returns button index

procedure DynTFTRadioGroupSetEnabledState(ARadioGroup: PDynTFTRadioGroup; NewState: Byte);
procedure DynTFTEnableRadioGroup(ARadioGroup: PDynTFTRadioGroup);
procedure DynTFTDisableRadioGroup(ARadioGroup: PDynTFTRadioGroup);

procedure DynTFTRegisterRadioGroupEvents;
function DynTFTGetRadioGroupComponentType: TDynTFTComponentType;
  

implementation

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetRadioGroupComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawRadioGroup(ARadioGroup: PDynTFTRadioGroup; FullRedraw: Boolean);
var
  i: Integer;
  x1, y1, x2, y2: TSInt;
  TextWidth, TextHeight: Word;
  ACol: TColor;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(ARadioGroup))) then
    Exit;

  if FullRedraw then
  begin
    x1 := ARadioGroup^.BaseProps.Left;
    y1 := ARadioGroup^.BaseProps.Top;
    x2 := x1 + ARadioGroup^.BaseProps.Width;
    y2 := y1 + ARadioGroup^.BaseProps.Height;

    DynTFT_Set_Pen(ARadioGroup^.Color, 1);
    DynTFT_Set_Brush(1, ARadioGroup^.Color, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);

    for i := 0 to ARadioGroup^.ButtonCount - 1 do
    begin
      ARadioGroup^.Buttons[i]^.Checked := i = ARadioGroup^.ItemIndex;
      DynTFTDrawRadioButton(ARadioGroup^.Buttons[i], False); //call without full redraw, because the radio group paints the background
    end;

    if ARadioGroup^.BaseProps.Enabled and CENABLED = CENABLED then
      ACol := ARadioGroup^.Font_Color
    else
      ACol := CL_DynTFTRadioGroup_DisabledFont;

    DynTFT_Set_Brush(0, ACol, 0, 0, 0, 0);
    {$IFDEF DynTFTFontSupport}
      DynTFT_Set_Font(ARadioGroup^.ActiveFont, ACol, FO_HORIZONTAL);
    {$ELSE}
      DynTFT_Set_Font(@TFT_defaultFont, ACol, FO_HORIZONTAL);
    {$ENDIF}
    DynTFT_Write_Text(ARadioGroup^.Caption, x1 + 7, y1 + 1);

    GetTextWidthAndHeight(ARadioGroup^.Caption, TextWidth, TextHeight);

    DynTFT_Set_Pen(CL_DynTFTRadioGroup_Border, 1);
    y1 := y1 + 6;
    x1 := x1 + 1;
    x2 := x2 - 2;
    y2 := y2 - 2;

    DynTFT_H_Line(x1, x1 + 4, y1);
    DynTFT_H_Line(x1 + 10 + TSInt(TextWidth), x2, y1);

    DynTFT_V_Line(y1, y2, x1);
    DynTFT_V_Line(y1, y2, x2);
    DynTFT_H_Line(x1, x2, y2);
  end
  else
  begin
    for i := 0 to ARadioGroup^.ButtonCount - 1 do
    begin
      if ARadioGroup^.Buttons[i]^.Checked then
      begin
        ARadioGroup^.Buttons[i]^.Checked := False;
        DynTFTDrawRadioButton(ARadioGroup^.Buttons[i], True);
      end;

      if i = ARadioGroup^.ItemIndex then
      begin
        ARadioGroup^.Buttons[i]^.Checked := True;
        DynTFTDrawRadioButton(ARadioGroup^.Buttons[i], True);  //let the radio buttons themselves draw their background
      end;
    end;
  end;
end;


procedure DynTFTRadioGroupSetEnabledState(ARadioGroup: PDynTFTRadioGroup; NewState: Byte);
var
  n, i: Integer;
begin
  ARadioGroup^.BaseProps.Enabled := NewState;
  n := ARadioGroup^.ButtonCount - 1;
  for i := 0 to n do
  begin
    ARadioGroup^.Buttons[i]^.BaseProps.Enabled := NewState;
    DynTFTDrawRadioButton(ARadioGroup^.Buttons[i], True);
  end;
end;


procedure DynTFTEnableRadioGroup(ARadioGroup: PDynTFTRadioGroup);
begin
  DynTFTRadioGroupSetEnabledState(ARadioGroup, CENABLED);
end;


procedure DynTFTDisableRadioGroup(ARadioGroup: PDynTFTRadioGroup);
begin
  DynTFTRadioGroupSetEnabledState(ARadioGroup, CDISABLED);
end;


procedure TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  ARadioGroup: PDynTFTRadioGroup;
begin
  ARadioGroup := PDynTFTRadioGroup(TPtrRec(PDynTFTRadioButton(TPtrRec(ABase))^.BaseProps.Parent));
  ARadioGroup^.ItemIndex := PDynTFTRadioButton(TPtrRec(ABase))^.ButtonIndex;
  //DrawRadioGroup(ARadioGroup, True);
  DynTFTDrawRadioGroup(ARadioGroup, False);
end;


procedure TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  ARadioGroup: PDynTFTRadioGroup;
begin
  ARadioGroup := PDynTFTRadioGroup(TPtrRec(PDynTFTRadioButton(TPtrRec(ABase))^.BaseProps.Parent));

  if ARadioGroup^.OldItemIndex <> ARadioGroup^.ItemIndex then
  begin
    ARadioGroup^.OldItemIndex := ARadioGroup^.ItemIndex;
    {$IFDEF IsDesktop}
      if Assigned(ARadioGroup^.OnSelectionChanged) then
        if Assigned(ARadioGroup^.OnSelectionChanged^) then
    {$ELSE}
      if ARadioGroup^.OnSelectionChanged <> nil then
    {$ENDIF}
        ARadioGroup^.OnSelectionChanged^(PPtrRec(TPtrRec(ARadioGroup)));
  end;
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalClick(ABase: PDynTFTBaseComponent);
  var
    ARadioGroup: PDynTFTRadioGroup;
  begin
    ARadioGroup := PDynTFTRadioGroup(TPtrRec(PDynTFTRadioButton(TPtrRec(ABase))^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      if Assigned(ARadioGroup^.BaseProps.OnClickUser) then
        if Assigned(ARadioGroup^.BaseProps.OnClickUser^) then
    {$ELSE}
      if ARadioGroup^.BaseProps.OnClickUser <> nil then
    {$ENDIF}
        ARadioGroup^.BaseProps.OnClickUser^(PPtrRec(TPtrRec(ARadioGroup)));
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalDoubleClick(ABase: PDynTFTBaseComponent);
  var
    ARadioGroup: PDynTFTRadioGroup;
  begin
    ARadioGroup := PDynTFTRadioGroup(TPtrRec(PDynTFTRadioButton(TPtrRec(ABase))^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      if Assigned(ARadioGroup^.BaseProps.OnDoubleClickUser) then
        if Assigned(ARadioGroup^.BaseProps.OnDoubleClickUser^) then
    {$ELSE}
      if ARadioGroup^.BaseProps.OnDoubleClickUser <> nil then
    {$ENDIF}
        ARadioGroup^.BaseProps.OnDoubleClickUser^(PPtrRec(TPtrRec(ARadioGroup)));
  end;
{$ENDIF}


procedure TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalBeforeDestroy(ABase: PDynTFTBaseComponent);
var
  ARadioGroup: PDynTFTRadioGroup;
  i, AButtonIndex: Integer;
begin
  ARadioGroup := PDynTFTRadioGroup(TPtrRec(PDynTFTRadioButton(TPtrRec(ABase))^.BaseProps.Parent));
  AButtonIndex := PDynTFTRadioButton(TPtrRec(ABase))^.ButtonIndex;

  if ARadioGroup^.ItemIndex = AButtonIndex then
    ARadioGroup^.ItemIndex := -1;

  //defragment:
  for i := AButtonIndex to ARadioGroup^.ButtonCount - 2 do
  begin
    ARadioGroup^.Buttons[i] := ARadioGroup^.Buttons[i + 1];
    Dec(ARadioGroup^.Buttons[i]^.ButtonIndex);
  end;

  Dec(ARadioGroup^.ButtonCount);
  if ARadioGroup^.ItemIndex > AButtonIndex then
    Dec(ARadioGroup^.ItemIndex);

  DynTFTDrawRadioGroup(ARadioGroup, True);
end;


function DynTFTRadioGroup_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTRadioGroup;
var
  i: Byte;
begin
  Result := PDynTFTRadioGroup(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTRadioGroup was not registered. Please call RegisterRadioGroupEvents before creating a PDynTFTRadioGroup. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, False, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.ButtonCount := 0;
  Result^.ItemIndex := -1;
  Result^.OldItemIndex := -1;
  for i := 0 to CMaxRadioGroupButtonCount - 1 do
    Result^.Buttons[i] := nil;

  Result^.Color := CL_DynTFTRadioGroup_Background;
  Result^.Font_Color := CL_DynTFTRadioGroup_EnabledFont;
  Result^.Caption := '';

  {$IFDEF IsDesktop}
    New(Result^.OnSelectionChanged);
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.OnSelectionChanged^ := nil;
  {$ELSE}
    Result^.OnSelectionChanged := nil;
  {$ENDIF}

  {$IFDEF DynTFTFontSupport}
    Result^.ActiveFont := @TFT_defaultFont;
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxRadioGroupStringLength, 'PDynTFTRadioGroup');
  {$ENDIF}
end;


function DynTFTRadioGroup_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTRadioGroup_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTRadioGroup_Destroy(var ARadioGroup: PDynTFTRadioGroup);
var
  i: Byte;
  {$IFNDEF IsDesktop}
    ATemp: PDynTFTBaseComponent;
  {$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(ARadioGroup^.OnSelectionChanged);
    ARadioGroup^.OnSelectionChanged := nil;
  {$ENDIF}

  for i := 0 to ARadioGroup^.ButtonCount - 1 do
  begin
    {$IFDEF IsDesktop}
      ARadioGroup^.Buttons[i]^.OnOwnerInternalBeforeDestroy^ := nil; //prevent the button from calling the parent's OnOwnerInternalBeforeDestroy event
    {$ELSE}
      ARadioGroup^.Buttons[i]^.OnOwnerInternalBeforeDestroy := nil;  //prevent the button from calling the parent's OnOwnerInternalBeforeDestroy event
    {$ENDIF}

    DynTFTRadioButton_Destroy(ARadioGroup^.Buttons[i]);
  end;
  
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(ARadioGroup)), SizeOf(ARadioGroup^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(ARadioGroup));
    DynTFTComponent_Destroy(ATemp, SizeOf(ARadioGroup^));
    ARadioGroup := PDynTFTRadioGroup(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTRadioGroup_DestroyAndPaint(var ARadioGroup: PDynTFTRadioGroup);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(ARadioGroup)));
  DynTFTRadioGroup_Destroy(ARadioGroup);
end;


procedure DynTFTRadioGroup_BaseDestroyAndPaint(var ARadioGroup: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTRadioGroup;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTRadioGroup_DestroyAndPaint(PDynTFTRadioGroup(TPtrRec(ARadioGroup)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTRadioGroup(TPtrRec(ARadioGroup));
    DynTFTRadioGroup_DestroyAndPaint(ATemp);
    ARadioGroup := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


function DynTFTAddRadioButtonToRadioGroup(ARadioGroup: PDynTFTRadioGroup; ARadioButton: PDynTFTRadioButton): Byte; //returns button index
begin
  if ARadioGroup^.ButtonCount >= CMaxRadioGroupButtonCount then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('Reached CMaxRadioGroupButtonCount. Can''t create more radio buttons.');
    {$ELSE}
      Result := 255;
      Exit;
    {$ENDIF}
  end;
  
  ARadioGroup^.Buttons[ARadioGroup^.ButtonCount] := ARadioButton;
  Result := ARadioGroup^.ButtonCount;            //Result := ButtonCount, then Inc it
  ARadioButton^.ButtonIndex := Result;
  Inc(ARadioGroup^.ButtonCount);
  ARadioButton^.BaseProps.Parent := PPtrRec(TPtrRec(ARadioGroup));
  ARadioButton^.Color := ARadioGroup^.Color;

  {$IFDEF IsDesktop}
    ARadioButton^.OnOwnerInternalMouseDown^ := TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseDown;
    ARadioButton^.OnOwnerInternalMouseMove^ := TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseMove;
    ARadioButton^.OnOwnerInternalMouseUp^ := TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ARadioButton^.OnOwnerInternalClick^ := TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ARadioButton^.OnOwnerInternalDoubleClick^ := TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalDoubleClick;
    {$ENDIF}
    ARadioButton^.OnOwnerInternalBeforeDestroy^ := TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalBeforeDestroy;
  {$ELSE}
    ARadioButton^.OnOwnerInternalMouseDown := @TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseDown;
    ARadioButton^.OnOwnerInternalMouseMove := @TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseMove;
    ARadioButton^.OnOwnerInternalMouseUp := @TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ARadioButton^.OnOwnerInternalClick := @TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ARadioButton^.OnOwnerInternalDoubleClick := @TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalDoubleClick;
    {$ENDIF}
    ARadioButton^.OnOwnerInternalBeforeDestroy := @TDynTFTRadioGroup_OnDynTFTChildRadioButtonInternalBeforeDestroy;
  {$ENDIF}
end;


procedure TDynTFTRadioGroup_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if RadioGroup can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTRadioGroup_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if RadioGroup can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTRadioGroup_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if RadioGroup can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTRadioGroup_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if RadioGroup can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
    *)
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTRadioGroup_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    (* implement these if RadioGroup can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTRadioGroup(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
    *)
  end;
{$ENDIF}


procedure TDynTFRadioGroup_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
var
  i, n: Integer;
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CCLEARAREAREPAINT then
  begin
    DynTFTClearComponentArea(ComponentFromArea, PDynTFTRadioGroup(TPtrRec(ABase))^.Color);
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    n := PDynTFTRadioGroup(TPtrRec(ABase))^.ButtonCount - 1;
    for i := 0 to n do
    begin
      //HideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTRadioGroup(TPtrRec(ABase))^.Buttons[i])));
      PDynTFTRadioGroup(TPtrRec(ABase))^.Buttons[i]^.BaseProps.Visible := CHIDDEN;  //use direct assignment instead of calling HideComponent, to avoid repainting the RadioGroup background over screen background
    end;

    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    n := PDynTFTRadioGroup(TPtrRec(ABase))^.ButtonCount - 1;
    for i := 0 to n do
    begin
      //ShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTRadioGroup(TPtrRec(ABase))^.Buttons[i])));
      PDynTFTRadioGroup(TPtrRec(ABase))^.Buttons[i]^.BaseProps.Visible := CVISIBLE; //use direct assignment instead of calling ShowComponent. No benefit in using ShowComponent this time.
    end;

    Exit;
  end;

  if (Options = CAFTERDISABLEREPAINT) or (Options = CAFTERENABLEREPAINT) then
  begin
    n := PDynTFTRadioGroup(TPtrRec(ABase))^.ButtonCount - 1;
    for i := 0 to n do
      PDynTFTRadioGroup(TPtrRec(ABase))^.Buttons[i]^.BaseProps.Enabled := ABase^.BaseProps.Enabled;

    //Exit;
  end;
                      
  DynTFTDrawRadioGroup(PDynTFTRadioGroup(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterRadioGroupEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTRadioGroup_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTRadioGroup_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTRadioGroup_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTRadioGroup_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent^ := TDynTFTRadioGroup_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFRadioGroup_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTRadioGroup_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTRadioGroup_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTRadioGroup_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTRadioGroup_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTRadioGroup_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTRadioGroup_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent := @TDynTFTRadioGroup_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFRadioGroup_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTRadioGroup_Create;
      ABaseEventReg.CompDestroy := @DynTFTRadioGroup_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTRadioGroup); 
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
