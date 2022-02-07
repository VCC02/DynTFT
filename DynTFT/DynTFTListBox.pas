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

unit DynTFTListBox;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTScrollBar, DynTFTItems

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

{$IFDEF ItemsVisibility}
  {$DEFINE ItemsVisibility_Or_UseExternalItems}
{$ENDIF}

{$IFDEF UseExternalItems}
  {$DEFINE ItemsVisibility_Or_UseExternalItems}
{$ENDIF}

type
  TDynTFTListBox = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ListBox properties
    Items: PDynTFTItems;
    VertScrollBar: PDynTFTScrollBar;

    //these events are set by an owner component, e.g. a combo box, and called by ListBox
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    {$IFDEF MouseClickSupport}
      OnOwnerInternalClick: PDynTFTGenericEventHandler;
    {$ENDIF}
  end;
  PDynTFTListBox = ^TDynTFTListBox;

procedure DynTFTDrawListBox(AListBox: PDynTFTListBox; FullRedraw: Boolean);
function DynTFTListBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTListBox;
procedure DynTFTListBox_Destroy(var AListBox: PDynTFTListBox);
procedure DynTFTListBox_DestroyAndPaint(var AListBox: PDynTFTListBox);

procedure SetScrollBarMaxBasedOnVisibility(AListBox: PDynTFTListBox);
procedure DynTFTUpdateListBoxEventHandlers(AListBox: PDynTFTListBox);
                                                                     
procedure DynTFTRegisterListBoxEvents;
function DynTFTGetListBoxComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetListBoxComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawListBox(AListBox: PDynTFTListBox; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
  NumberOfItemsToDraw: LongInt;
  AItems: PDynTFTItems;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AListBox))) then
    Exit;

  AItems := AListBox^.Items;
  NumberOfItemsToDraw := DynTFTGetNumberOfItemsToDraw(AItems);

  if NumberOfItemsToDraw < AItems^.Count then
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar^.BtnScroll)))
  else
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar^.BtnScroll)));

  if AListBox^.BaseProps.Enabled and CENABLED = CENABLED then
  begin
    if AItems^.BaseProps.Enabled and CENABLED <> CENABLED then
      DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(AItems)));

    if AListBox^.VertScrollBar^.BaseProps.Enabled and CENABLED <> CENABLED then
      DynTFTEnableComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar)));
  end
  else
  begin
    if AItems^.BaseProps.Enabled and CENABLED = CENABLED then
      DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(AItems)));

    if AListBox^.VertScrollBar^.BaseProps.Enabled and CENABLED = CENABLED then
      DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(AListBox^.VertScrollBar)));
  end;
    
  if FullRedraw then
  begin
    x1 := AListBox^.BaseProps.Left;
    y1 := AListBox^.BaseProps.Top;
    x2 := x1 + AListBox^.BaseProps.Width;
    y2 := y1 + AListBox^.BaseProps.Height;

    DynTFT_Set_Pen(CL_DynTFTListBox_Border, 1);
    DynTFT_H_Line(x1, x2, y1);
    DynTFT_H_Line(x1, x2, y2);
    DynTFT_V_Line(y1, y2, x1);
    DynTFT_V_Line(y1, y2, x2);

    DynTFTDrawScrollBar(AListBox^.VertScrollBar, FullRedraw);
    //DynTFTDrawItems(AListBox^.Items, FullRedraw);
  end;
end;


procedure SetScrollBarMaxBasedOnVisibility(AListBox: PDynTFTListBox);
var
  AScrBar: PDynTFTScrollBar;
begin
  AScrBar := PDynTFTScrollBar(AListBox^.VertScrollBar);
  AScrBar^.Max := {$IFDEF ItemsVisibility} AListBox^.Items^.TotalVisibleCount {$ELSE} AListBox^.Items^.Count {$ENDIF} - DynTFTGetNumberOfItemsToDraw(AListBox^.Items);

  if AScrBar^.Max < 0 then
    AScrBar^.Max := 0;

  if ConstrainPositionToBounds(AScrBar) then
    DynTFTDrawScrollBar(AScrBar, True);
end;


procedure DynTFTUpdateListBoxEventHandlers(AListBox: PDynTFTListBox);
begin
  {$IFDEF IsDesktop}
    AListBox^.Items^.BaseProps.OnMouseDownUser^ := AListBox^.BaseProps.OnMouseDownUser^;     // content := content, not pointer !!!
    AListBox^.Items^.BaseProps.OnMouseMoveUser^ := AListBox^.BaseProps.OnMouseMoveUser^;
    AListBox^.Items^.BaseProps.OnMouseUpUser^ := AListBox^.BaseProps.OnMouseUpUser^;
    {$IFDEF MouseClickSupport}
      AListBox^.Items^.BaseProps.OnClickUser^ := AListBox^.BaseProps.OnClickUser^;
    {$ENDIF}

    AListBox^.VertScrollBar^.BaseProps.OnMouseDownUser^ := AListBox^.BaseProps.OnMouseDownUser^;     // content := content, not pointer !!!
    AListBox^.VertScrollBar^.BaseProps.OnMouseMoveUser^ := AListBox^.BaseProps.OnMouseMoveUser^;
    AListBox^.VertScrollBar^.BaseProps.OnMouseUpUser^ := AListBox^.BaseProps.OnMouseUpUser^;
  {$ELSE}
    AListBox^.Items^.BaseProps.OnMouseDownUser := AListBox^.BaseProps.OnMouseDownUser;       // pointer := pointer, not content !!!
    AListBox^.Items^.BaseProps.OnMouseMoveUser := AListBox^.BaseProps.OnMouseMoveUser;
    AListBox^.Items^.BaseProps.OnMouseUpUser := AListBox^.BaseProps.OnMouseUpUser;
    {$IFDEF MouseClickSupport}
      AListBox^.Items^.BaseProps.OnClickUser := AListBox^.BaseProps.OnClickUser;
    {$ENDIF}

    AListBox^.VertScrollBar^.BaseProps.OnMouseDownUser := AListBox^.BaseProps.OnMouseDownUser;       // pointer := pointer, not content !!!
    AListBox^.VertScrollBar^.BaseProps.OnMouseMoveUser := AListBox^.BaseProps.OnMouseMoveUser;
    AListBox^.VertScrollBar^.BaseProps.OnMouseUpUser := AListBox^.BaseProps.OnMouseUpUser;
  {$ENDIF}
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalAdjust(AScrollBar: PDynTFTBaseComponent);
begin
  if PDynTFTBaseComponent(TPtrRec(AScrollBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a listbox
    SetScrollBarMaxBasedOnVisibility(PDynTFTListBox(TPtrRec(AScrollBar^.BaseProps.Parent)));
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalAfterAdjust(AScrollBar: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
  AListBox: PDynTFTListBox;
  NewFirstDisplayableIndex: Longint;
begin
  if PDynTFTBaseComponent(TPtrRec(AScrollBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a listbox
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(AScrollBar));
    AListBox := PDynTFTListBox(TPtrRec(AScrollBar^.BaseProps.Parent));

    if AScrBar^.Position < 0 then
    begin
      AScrBar^.Position := 0;
      DynTFTDrawScrollBar(AScrBar, True);
    end;

    NewFirstDisplayableIndex := AListBox^.Items^.FirstDisplayablePosition;
    if NewFirstDisplayableIndex <> AScrBar^.Position then
    begin
      NewFirstDisplayableIndex := AScrBar^.Position;
      if NewFirstDisplayableIndex > AScrBar^.Max then
        NewFirstDisplayableIndex := AScrBar^.Max;
      if NewFirstDisplayableIndex < 0 then
        NewFirstDisplayableIndex := 0;

      AListBox^.Items^.FirstDisplayablePosition := NewFirstDisplayableIndex;
      DynTFTDrawItems(AListBox^.Items, True);
    end;
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
  AListBox: PDynTFTListBox;
  MaxFirstDisplayableIndex, NewFirstDisplayableIndex: Longint;
begin
  AScrBar := PDynTFTScrollBar(TPtrRec(ABase));
  if PDynTFTBaseComponent(TPtrRec(AScrBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a listbox
  begin
    AListBox := PDynTFTListBox(TPtrRec(AScrBar^.BaseProps.Parent));
    SetScrollBarMaxBasedOnVisibility(AListBox);

    MaxFirstDisplayableIndex := AScrBar^.Max;

    NewFirstDisplayableIndex := AListBox^.Items^.FirstDisplayablePosition;
    if NewFirstDisplayableIndex <> AScrBar^.Position then
    begin
      NewFirstDisplayableIndex := AScrBar^.Position;
      if NewFirstDisplayableIndex > MaxFirstDisplayableIndex then
        NewFirstDisplayableIndex := MaxFirstDisplayableIndex;
      if NewFirstDisplayableIndex < 0 then
        NewFirstDisplayableIndex := 0;

      AListBox^.Items^.FirstDisplayablePosition := NewFirstDisplayableIndex;

      DynTFTDrawItems(AListBox^.Items, True);
    end;
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


function GetNewItemIndexBasedOnVisibility(AItems: PDynTFTItems; ClickedItemPositionOnScreen: LongInt; var ATempString: string {$IFDEF ItemsEnabling}; IsEnabled: PBoolean {$ENDIF}): LongInt;
var
  MaxDrawingPosition, IndexOfDrawingItem, i: LongInt;

  {$IFDEF ItemsVisibility}
    IsVisible: Boolean;
  {$ENDIF}
  VisibleCount: LongInt;
begin
  Result := -1;

  VisibleCount := 0;

  IndexOfDrawingItem := GetIndexOfFirstDrawingItem(AItems, VisibleCount, ATempString);
  MaxDrawingPosition := GetMaxDrawingPosition(AItems);

  {$IFDEF ItemsVisibility}
    IsVisible := True;
  {$ENDIF}  

  for i := 0 to MaxDrawingPosition do
  begin
    if IndexOfDrawingItem >= AItems^.Count then
      Break;

    IndexOfDrawingItem := GoToNextVisibleItemFromIndex(AItems, IndexOfDrawingItem, ATempString {$IFDEF ItemsVisibility}, @IsVisible {$ENDIF} {$IFDEF ItemsEnabling}, IsEnabled {$ENDIF});

    {$IFDEF ItemsVisibility}
      if IsVisible then
    {$ENDIF}  
      if i = ClickedItemPositionOnScreen then
      begin
        Result := IndexOfDrawingItem - 1;
        Break;
      end;
  end;
end;


{$IFDEF ItemsEnabling}
  var
    ClickedItem_IsEnabled: Boolean;  //yes, it's ugly, but it is better than having multiple instances of this variable for every listbox, used only one at a time
{$ENDIF}


procedure TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AListBox: PDynTFTListBox;
  NewItemIndex, ClickedItemPositionOnScreen: LongInt;
  {$IFDEF ItemsEnabling}
    //ClickedItem_IsEnabled: Boolean;  //made global, to be available in TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp
  {$ENDIF}

  {$IFDEF ItemsVisibility_Or_UseExternalItems}
    ATempString: string {$IFDEF IsMCU}[CMaxItemsStringLength] {$ENDIF};
  {$ENDIF}
begin
  if PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AListBox := PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent));
    ClickedItemPositionOnScreen := (DynTFTMCU_YMouse - AListBox^.Items^.BaseProps.Top) div AListBox^.Items^.ItemHeight;

    {$IFDEF ItemsVisibility}  
      NewItemIndex := GetNewItemIndexBasedOnVisibility(AListBox^.Items, ClickedItemPositionOnScreen, ATempString {$IFDEF ItemsEnabling}, @ClickedItem_IsEnabled {$ENDIF});
    {$ELSE}
      NewItemIndex := AListBox^.Items^.FirstDisplayablePosition + ClickedItemPositionOnScreen;

      if NewItemIndex > AListBox^.Items^.Count - 1 then
        NewItemIndex := -1;

      {$IFDEF ItemsEnabling}
        if NewItemIndex = -1 then
          ClickedItem_IsEnabled := True
        else
        begin
          {$IFDEF UseExternalItems}
            ClickedItem_IsEnabled := DynTFTItemsGetItemEnabling(AListBox^.Items, NewItemIndex, ATempString);
          {$ELSE}
            ClickedItem_IsEnabled := AListBox^.Items^.ItemsEnabled[NewItemIndex];
          {$ENDIF}
        end;
      {$ENDIF}
    {$ENDIF}
      
    if AListBox^.Items^.ItemIndex <> NewItemIndex then
    begin
      {$IFDEF ItemsEnabling}
        if ClickedItem_IsEnabled then
        begin
      {$ENDIF}

          AListBox^.Items^.ItemIndex := NewItemIndex;
          DynTFTDrawItems(AListBox^.Items, True);
          
      {$IFDEF ItemsEnabling}
        end;
      {$ENDIF}  
    end
    else
      if AListBox^.Items^.BaseProps.Focused and CPAINTAFTERFOCUS <> CPAINTAFTERFOCUS then
      begin
        AListBox^.Items^.BaseProps.Focused := AListBox^.Items^.BaseProps.Focused or CPAINTAFTERFOCUS;
        DynTFTDrawItems(AListBox^.Items, True);
      end;

    {$IFDEF IsDesktop}
      if Assigned(AListBox^.BaseProps.OnMouseDownUser) then
        if Assigned(AListBox^.BaseProps.OnMouseDownUser^) then
    {$ELSE}
      if AListBox^.BaseProps.OnMouseDownUser <> nil then
    {$ENDIF}
        AListBox^.BaseProps.OnMouseDownUser^(PPtrRec(TPtrRec(AListBox)));
  end;
end;


procedure TDynTFTListBox_OnDynTFTChildItemsInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseMoveUser) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseMoveUser^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseMoveUser <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseMoveUser^(PPtrRec(TPtrRec(ABase^.BaseProps.Parent)));
end;


procedure TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF ItemsEnabling}
    if ClickedItem_IsEnabled then  //requires TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown to be used
    begin
  {$ENDIF}

      {$IFDEF IsDesktop}
        if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp) then
          if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp^) then
      {$ELSE}
        if PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp <> nil then
      {$ENDIF}
          PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalMouseUp^(PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent)));

  {$IFDEF ItemsEnabling}
    end;
  {$ENDIF}

  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseUpUser) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseUpUser^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseUpUser <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnMouseUpUser^(PPtrRec(TPtrRec(ABase^.BaseProps.Parent)));
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTListBox_OnDynTFTChildItemsInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF ItemsEnabling}
      if ClickedItem_IsEnabled then  //requires TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown to be used
      begin
    {$ENDIF}

        {$IFDEF IsDesktop}
          if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalClick) then
            if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalClick^) then
        {$ELSE}
          if PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalClick <> nil then
        {$ENDIF}
            PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.OnOwnerInternalClick^(PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent)));

    {$IFDEF ItemsEnabling}
      end;
    {$ENDIF}

    {$IFDEF IsDesktop}
      if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnClickUser) then
        if Assigned(PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnClickUser^) then
    {$ELSE}
      if PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnClickUser <> nil then
    {$ENDIF}
        PDynTFTListBox(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.OnClickUser^(PPtrRec(TPtrRec(ABase^.BaseProps.Parent)));
  end;
{$ENDIF}


function DynTFTListBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTListBox;
begin                         
  Result := PDynTFTListBox(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTListBox was not registered. Please call RegisterListBoxEvents before creating a PDynTFTListBox. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;   //Allow events to be processed by subcomponents.
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, False, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Items := DynTFTItems_Create(ScreenIndex, Left + 1, Top + 1, Width - CScrollBarArrBtnWidthHeight - 1, Height - 2);

  {$IFDEF IsDesktop}
    Result^.Items^.OnOwnerInternalMouseDown^ := TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown;
    Result^.Items^.OnOwnerInternalMouseMove^ := TDynTFTListBox_OnDynTFTChildItemsInternalMouseMove;
    Result^.Items^.OnOwnerInternalMouseUp^ := TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp;
    {$IFDEF MouseClickSupport}
      Result^.Items^.OnOwnerInternalClick^ := TDynTFTListBox_OnDynTFTChildItemsInternalClick;
    {$ENDIF}
  {$ELSE}
    Result^.Items^.OnOwnerInternalMouseDown := @TDynTFTListBox_OnDynTFTChildItemsInternalMouseDown;
    Result^.Items^.OnOwnerInternalMouseMove := @TDynTFTListBox_OnDynTFTChildItemsInternalMouseMove;
    Result^.Items^.OnOwnerInternalMouseUp := @TDynTFTListBox_OnDynTFTChildItemsInternalMouseUp;
    {$IFDEF MouseClickSupport}
      Result^.Items^.OnOwnerInternalClick := @TDynTFTListBox_OnDynTFTChildItemsInternalClick;
    {$ENDIF}
  {$ENDIF}

  Result^.VertScrollBar := DynTFTScrollBar_Create(ScreenIndex, Left + Width - CScrollBarArrBtnWidthHeight + 1, Top + 1, CScrollBarArrBtnWidthHeight - 2, Height - 2);  // Screen: DynTFTDev - Inactive at startup
  Result^.VertScrollBar^.Max := 10;  //this will be automatically set later
  Result^.VertScrollBar^.Min := 0;
  Result^.VertScrollBar^.Position := Result^.VertScrollBar^.Min;
  Result^.VertScrollBar^.Direction := CScrollBarVertDir;

  {$IFDEF IsDesktop}
    Result^.VertScrollBar^.OnOwnerInternalMouseDown^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseDown;
    Result^.VertScrollBar^.OnOwnerInternalMouseMove^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseMove;
    Result^.VertScrollBar^.OnOwnerInternalMouseUp^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseUp;
    Result^.VertScrollBar^.OnOwnerInternalAdjustScrollBar^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalAdjust;
    Result^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar^ := TDynTFTListBox_OnDynTFTChildScrollBarInternalAfterAdjust;
  {$ELSE}
    Result^.VertScrollBar^.OnOwnerInternalMouseDown := @TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseDown;
    Result^.VertScrollBar^.OnOwnerInternalMouseMove := @TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseMove;
    Result^.VertScrollBar^.OnOwnerInternalMouseUp := @TDynTFTListBox_OnDynTFTChildScrollBarInternalMouseUp;
    Result^.VertScrollBar^.OnOwnerInternalAdjustScrollBar := @TDynTFTListBox_OnDynTFTChildScrollBarInternalAdjust;
    Result^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar := @TDynTFTListBox_OnDynTFTChildScrollBarInternalAfterAdjust;
  {$ENDIF}

  Result^.VertScrollBar^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.Items^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      Result^.VertScrollBar^.BaseProps.Name := 'cmb.VertScrollBar';
      Result^.Items^.BaseProps.Name := 'cmb.Items';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      New(Result^.OnOwnerInternalClick);
    {$ENDIF}

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    {$IFDEF MouseClickSupport}
      Result^.OnOwnerInternalClick^ := nil;
    {$ENDIF}
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      Result^.OnOwnerInternalClick := nil;
    {$ENDIF}
  {$ENDIF}

  Result^.Items^.FirstDisplayablePosition := 0;
  Result^.Items^.ItemIndex := -1;
  Result^.Items^.Count := 0;

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
        {DynTFT_DebugConsole('--- Allocating user event handlers of list box $' + IntToHex(TPTr(Result), 8) +
                            '  Addr(Down) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseDown), 8) +
                            '  Addr(Move) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseMove), 8) +
                            '  Addr(Up) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseUp), 8)
                            );}
    {$ENDIF}
  {$ENDIF}

  //DynTFTUpdateListBoxEventHandlers(Result);
end;


function DynTFTListBox_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTListBox_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTListBox_Destroy(var AListBox: PDynTFTListBox);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      AListBox^.VertScrollBar^.BaseProps.Name := AListBox^.BaseProps.Name + '.VertScrollBar';
      AListBox^.Items^.BaseProps.Name := AListBox^.BaseProps.Name + '.Items';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      {DynTFT_DebugConsole('/// Disposing internal event handlers of list box: ' + AListBox^.BaseProps.Name +
                          '  Addr(Down) = $' + IntToHex(TPTr(AListBox^.OnOwnerInternalMouseDown), 8) +
                          '  Addr(Move) = $' + IntToHex(TPTr(AListBox^.OnOwnerInternalMouseMove), 8) +
                          '  Addr(Up) = $' + IntToHex(TPTr(AListBox^.OnOwnerInternalMouseUp), 8)
                          );}
    {$ENDIF}
  {$ENDIF}

  DynTFTItems_Destroy(AListBox^.Items);
  DynTFTScrollBar_Destroy(AListBox^.VertScrollBar);

  {$IFDEF IsDesktop}
    Dispose(AListBox^.OnOwnerInternalMouseDown);
    Dispose(AListBox^.OnOwnerInternalMouseMove);
    Dispose(AListBox^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      Dispose(AListBox^.OnOwnerInternalClick);
    {$ENDIF}

    AListBox^.OnOwnerInternalMouseDown := nil;
    AListBox^.OnOwnerInternalMouseMove := nil;
    AListBox^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      AListBox^.OnOwnerInternalClick := nil;
    {$ENDIF}

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AListBox)), SizeOf(AListBox^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AListBox));
    DynTFTComponent_Destroy(ATemp, SizeOf(AListBox^));
    AListBox := PDynTFTListBox(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTListBox_DestroyAndPaint(var AListBox: PDynTFTListBox);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AListBox)));
  DynTFTListBox_Destroy(AListBox);
end;


procedure DynTFTListBox_BaseDestroyAndPaint(var AListBox: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTListBox;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTListBox_DestroyAndPaint(PDynTFTListBox(TPtrRec(AListBox)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTListBox(TPtrRec(AListBox));
    DynTFTListBox_DestroyAndPaint(ATemp);
    AListBox := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ListBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ListBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTListBox_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if ListBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTListBox_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTListBox(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
{$ENDIF}


procedure TDynTFTListBox_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.Items)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.VertScrollBar)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.Items)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.VertScrollBar)));
    Exit;
  end;  
    
  DynTFTDrawListBox(PDynTFTListBox(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterListBoxEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTListBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTListBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTListBox_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := TDynTFTListBox_OnDynTFTBaseInternalClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTListBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTListBox_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTListBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTListBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTListBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTListBox_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := @TDynTFTListBox_OnDynTFTBaseInternalClick;
    {$ENDIF}                     
    ABaseEventReg.Repaint := @TDynTFTListBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTListBox_Create;
      ABaseEventReg.CompDestroy := @DynTFTListBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTListBox); 
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
