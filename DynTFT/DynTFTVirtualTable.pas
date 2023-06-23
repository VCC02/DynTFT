{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017, 2024 VCC
    DynTFT initial release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this file,
    You can obtain one at https://mozilla.org/MPL/2.0/.

    Copyright (c) 2023, VCC  https://github.com/VCC02

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

unit DynTFTVirtualTable;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTScrollBar, DynTFTItems, DynTFTListBox, DynTFTPanel,
  DynArrays

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
//  TDynTFTVirtualTableColumn = record
//    HeaderItem: PDynTFTPanel;
//    List: PDynTFTListBox;
//  end;

  TDynTFTVirtualTable = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    HeaderItems: TDynArrayOfPtrUInt;  // this is an array of PDynTFTPanel
    Columns: TDynArrayOfPtrUInt;      // this is an array of PDynTFTListBox   //these two arrays have to be kept in sync

    VertScrollBar: PDynTFTScrollBar;  //replaces all scrollbar ListBoxes
    HorizScrollBar: PDynTFTScrollBar; //sets ListBoxes visibility

    //these events are set by an owner component, e.g. a combo box, and called by ListBox
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
  PDynTFTVirtualTable = ^TDynTFTVirtualTable;

procedure DynTFTDrawVirtualTable(AVirtualTable: PDynTFTVirtualTable; FullRedraw: Boolean);
function DynTFTVirtualTable_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualTable;
procedure DynTFTVirtualTable_Destroy(var AVirtualTable: PDynTFTVirtualTable);
procedure DynTFTVirtualTable_DestroyAndPaint(var AVirtualTable: PDynTFTVirtualTable);

procedure SetVirtualTableScrollBarMaxBasedOnVisibility(AVirtualTable: PDynTFTVirtualTable);
procedure DynTFTUpdateVirtualTableEventHandlers(AVirtualTable: PDynTFTVirtualTable);
                                                                     
procedure DynTFTRegisterVirtualTableEvents;
function DynTFTGetVirtualTableComponentType: TDynTFTComponentType;

function AddColumnToVirtualTable(AVirtualTable: PDynTFTVirtualTable): PDynTFTListBox;



{ToDo

 - implement internal handlers
 - selecting an item on one listbox should select all the others
 - create an event for AfterDrawing
 - the horizontal scrollbar should set column visibility
 - procedure for deleting columns (should not be able to delete the first one)
 - misc
}

implementation


var
  ComponentType: TDynTFTComponentType;


function DynTFTGetVirtualTableComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawVirtualTable(AVirtualTable: PDynTFTVirtualTable; FullRedraw: Boolean);
var
  i, n: Integer;
  TempPanel: PDynTFTPanel;
  TempListBox: PDynTFTListBox;
  ComponentPos: Integer;
begin
  n := AVirtualTable^.Columns.Len - 1;
  ComponentPos := AVirtualTable^.BaseProps.Left;

  for i := 0 to n do
  begin
    TempPanel := PDynTFTPanel(TPtrRec(AVirtualTable^.HeaderItems.Content^[i]));
    TempListBox := PDynTFTListBox(TPtrRec(AVirtualTable^.Columns.Content^[i]));

    TempPanel.BaseProps.Top := AVirtualTable^.BaseProps.Top + 1;  // + 1, to leave room for a rectangle
    TempPanel.BaseProps.Left := ComponentPos;
    TempListBox.BaseProps.Top := TempPanel.BaseProps.Top + TempPanel.BaseProps.Height + 1;

    ComponentPos := ComponentPos + TempPanel.BaseProps.Width;
    TempPanel^.BaseProps.Left := ComponentPos;
    TempListBox^.BaseProps.Left := ComponentPos;

    DynTFTDrawPanel(TempPanel, FullRedraw);
    DynTFTDrawListBox(TempListBox, FullRedraw);
  end;
end;


procedure TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseDown(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseUp(ABase: PDynTFTBaseComponent);
begin

end;


procedure SetInternalHandlersToPanel(APanel: PDynTFTPanel);
begin
  {$IFDEF IsDesktop}
    APanel^.OnOwnerInternalMouseDown^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseDown;
    APanel^.OnOwnerInternalMouseMove^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseMove;
    APanel^.OnOwnerInternalMouseUp^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseUp;
    {$IFDEF MouseClickSupport}
      APanel^.OnOwnerInternalClick^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      APanel^.OnOwnerInternalDoubleClick^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalDoubleClick;
    {$ENDIF}
  {$ELSE}
    APanel^.OnOwnerInternalMouseDown := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseDown;
    APanel^.OnOwnerInternalMouseMove := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseMove;
    APanel^.OnOwnerInternalMouseUp := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseUp;
    {$IFDEF MouseClickSupport}
      APanel^.OnOwnerInternalClick := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      APanel^.OnOwnerInternalDoubleClick := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalDoubleClick;
    {$ENDIF}
  {$ENDIF}
end;


procedure SetInternalHandlersToListBox(AListBox: PDynTFTListBox);
begin
  {$IFDEF IsDesktop}
    AListBox^.OnOwnerInternalMouseDown^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseDown;
    AListBox^.OnOwnerInternalMouseMove^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseMove;
    AListBox^.OnOwnerInternalMouseUp^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseUp;
    {$IFDEF MouseClickSupport}
      AListBox^.OnOwnerInternalClick^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AListBox^.OnOwnerInternalDoubleClick^ := TDynTFTVirtualTable_OnDynTFTChildItemsInternalDoubleClick;
    {$ENDIF}
  {$ELSE}
    AListBox^.OnOwnerInternalMouseDown := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseDown;
    AListBox^.OnOwnerInternalMouseMove := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseMove;
    AListBox^.OnOwnerInternalMouseUp := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalMouseUp;
    {$IFDEF MouseClickSupport}
      AListBox^.OnOwnerInternalClick := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AListBox^.OnOwnerInternalDoubleClick := @TDynTFTVirtualTable_OnDynTFTChildItemsInternalDoubleClick;
    {$ENDIF}
  {$ENDIF}
end;


function AddColumn(AVirtualTable: PDynTFTVirtualTable; AIsFirstColumn: Boolean): PDynTFTListBox;
var
  TempPanel: PDynTFTPanel;
  TempListBox: PDynTFTListBox;
  Left, Top, Width, Height: TSInt;
begin
  Left := AVirtualTable^.BaseProps.Left;
  Top := AVirtualTable^.BaseProps.Top;
  Width := AVirtualTable^.BaseProps.Width;
  Height := AVirtualTable^.BaseProps.Height;

  TempPanel := DynTFTPanel_Create(AVirtualTable^.BaseProps.ScreenIndex, Left + 1, Top + 1, Width - 1, 20);
  TempListBox := DynTFTListBox_Create(AVirtualTable^.BaseProps.ScreenIndex, Left + 1, Top + 21, Width - 1, Height - 20 - 1);

  AddPtrUIntToDynArraysOfPtrUInt(AVirtualTable^.HeaderItems, PtrUInt(TempPanel));     //main column, this should always exist
  AddPtrUIntToDynArraysOfPtrUInt(AVirtualTable^.Columns, PtrUInt(TempListBox));       //main column, this should always exist

  SetInternalHandlersToPanel(TempPanel);
  SetInternalHandlersToListBox(TempListBox);

  Result := TempListBox;

  if not AIsFirstColumn then
  begin
    DynTFTScrollBar_Destroy(TempListBox^.VertScrollBar);
    TempListBox^.Items.BaseProps.Width := TempListBox^.BaseProps.Width - 2;
  end;
end;


function AddColumnToVirtualTable(AVirtualTable: PDynTFTVirtualTable): PDynTFTListBox;
begin
  Result := AddColumn(AVirtualTable, False);
end;


function DynTFTVirtualTable_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualTable;
var
  TempListBox: PDynTFTListBox;
begin
  Result := PDynTFTVirtualTable(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTVirtualTable was not registered. Please call RegisterVirtualTableEvents before creating a PDynTFTVirtualTable. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;   //Allow events to be processed by subcomponents.
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, False, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  InitDynArrayOfPtrUIntToEmpty(Result^.HeaderItems);
  InitDynArrayOfPtrUIntToEmpty(Result^.Columns);

  TempListBox := AddColumn(Result, True);

  Result^.VertScrollBar := TempListBox^.VertScrollBar;
end;


procedure DynTFTVirtualTable_Destroy(var AVirtualTable: PDynTFTVirtualTable);
var
{$IFNDEF IsDesktop}
  ATemp: PDynTFTBaseComponent;
{$ENDIF}
  i: Integer;
begin
  for i := 0 to LongInt(AVirtualTable^.Columns.Len) - 1 do
  begin
    DynTFTPanel_Destroy(PDynTFTPanel(AVirtualTable^.Columns.Content^[i]));            /////////////////////////////// may require two types of typecasts
    DynTFTListBox_Destroy(PDynTFTListBox(AVirtualTable^.HeaderItems.Content^[i]));    /////////////////////////////// may require two types of typecasts
  end;

  {$IFDEF IsDesktop}
    Dispose(AVirtualTable^.OnOwnerInternalMouseDown);
    Dispose(AVirtualTable^.OnOwnerInternalMouseMove);
    Dispose(AVirtualTable^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      Dispose(AVirtualTable^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Dispose(AVirtualTable^.OnOwnerInternalDoubleClick);
    {$ENDIF}

    AVirtualTable^.OnOwnerInternalMouseDown := nil;
    AVirtualTable^.OnOwnerInternalMouseMove := nil;
    AVirtualTable^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      AVirtualTable^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AVirtualTable^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}

    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AVirtualTable)), SizeOf(AVirtualTable^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AVirtualTable));
    DynTFTComponent_Destroy(ATemp, SizeOf(AVirtualTable^));
    AVirtualTable := PDynTFTVirtualTable(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTVirtualTable_DestroyAndPaint(var AVirtualTable: PDynTFTVirtualTable);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AVirtualTable)));
  DynTFTVirtualTable_Destroy(AVirtualTable);
end;


procedure DynTFTVirtualTable_BaseDestroyAndPaint(var AVirtualTable: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTVirtualTable;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTVirtualTable_DestroyAndPaint(PDynTFTVirtualTable(TPtrRec(AVirtualTable)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTVirtualTable(TPtrRec(AVirtualTable));
    DynTFTVirtualTable_DestroyAndPaint(ATemp);
    AVirtualTable := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;



procedure TDynTFTVirtualTable_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (* implement these if VirtualTable can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTVirtualTable_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (* implement these if VirtualTable can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTVirtualTable_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (* implement these if VirtualTable can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTVirtualTable_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTVirtualTable_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTVirtualTable(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
  end;
{$ENDIF}



procedure SetVirtualTableScrollBarMaxBasedOnVisibility(AVirtualTable: PDynTFTVirtualTable);
begin

end;


procedure DynTFTUpdateVirtualTableEventHandlers(AVirtualTable: PDynTFTVirtualTable);
begin

end;


procedure HideSubComponents(AVirtualTable: PDynTFTVirtualTable);
var
  i, n: Integer;
begin
  n := AVirtualTable^.HeaderItems.Len - 1;

  for i := 0 to n do
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HeaderItems.Content^[i])));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.Columns.Content^[i])));
  end;

  DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.VertScrollBar)));
  DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HorizScrollBar)));
end;


procedure ShowSubComponents(AVirtualTable: PDynTFTVirtualTable);
var
  i, n: Integer;
begin
  n := AVirtualTable^.HeaderItems.Len - 1;

  for i := 0 to n do
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HeaderItems.Content^[i])));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.Columns.Content^[i])));
  end;

  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.VertScrollBar)));
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HorizScrollBar)));
end;


procedure TDynTFTVirtualTable_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    HideSubComponents(PDynTFTVirtualTable(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    ShowSubComponents(PDynTFTVirtualTable(TPtrRec(ABase)));
    Exit;
  end;  
    
  DynTFTDrawVirtualTable(PDynTFTVirtualTable(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterVirtualTableEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTVirtualTable_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTVirtualTable_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTVirtualTable_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := TDynTFTVirtualTable_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent^ := TDynTFTVirtualTable_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTVirtualTable_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTVirtualTable_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTVirtualTable_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTVirtualTable_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTVirtualTable_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTVirtualTable_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := @TDynTFTVirtualTable_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := @TDynTFTVirtualTable_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTVirtualTable_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTVirtualTable_Create;
      ABaseEventReg.CompDestroy := @DynTFTVirtualTable_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTVirtualTable); 
  {$ENDIF}

  ComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}
end;


end.
