{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017, 2023 VCC
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

type
  TOnGetVTItemEvent = procedure(AItems: PPtrRec; Index, Column: LongInt; var ItemText: string);
  POnGetVTItemEvent = ^TOnGetVTItemEvent;

  TOnDrawVTIconEvent = procedure(AItems: PPtrRec; Index, Column, ItemY: LongInt; var ItemText: string {$IFDEF ItemsEnabling}; IsEnabled: Boolean {$ENDIF});
  POnDrawVTIconEvent = ^TOnDrawVTIconEvent;

  TDynTFTVirtualTable = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //Ideally, these two arrays should be TDynArrayOfPtrUInt instead of PDynArrayOfPtrUInt,
    //but Delphi and FP require the strings (see 'Initialized' field) to be long strings, in order to be automatically initialized.
    //When using TDynArrayOfPtrUInt, the 'Initialized' field becomes allocated by mP's memory manager, which is not managed by the compiler, resulting in access violations when using it.
    //Because of this difference, these two arrays will be allocated using two difference memory managers (on desktop only).
    //As a result, the total reported memory usage will be smaller on desktop than on MCU (about SizeOf(PtrUInt) * NumberOfColumns).
    //So, on a 4-column table, on 32-bit, SizeOf(PtrUInt) * 4 = 16 bytes  (difference of reported memory usage).
    HeaderItems: PDynArrayOfPtrUInt;   // this is an array of PDynTFTPanel
    Columns: PDynArrayOfPtrUInt;       // this is an array of PDynTFTListBox   //these two arrays have to be kept in sync

    VertScrollBar: PDynTFTScrollBar;  //replaces all scrollbar ListBoxes
    HorizScrollBar: PDynTFTScrollBar; //sets ListBoxes visibility

    //these events are set by an owner component, e.g. a combo box, and called by VirtualTable
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    {$IFDEF MouseClickSupport}
      OnOwnerInternalClick: PDynTFTGenericEventHandler;
    {$ENDIF}

    {$IFDEF MouseDoubleClickSupport}
      OnOwnerInternalDoubleClick: PDynTFTGenericEventHandler;
    {$ENDIF}

    {$IFDEF UseExternalItems}
      OnGetItem: POnGetVTItemEvent;
      OnGetItemVisibility: POnGetItemVisibilityEvent;
    {$ENDIF}

    {$IFDEF ListIcons}
      OnDrawIcon: POnDrawVTIconEvent;
    {$ENDIF}

    //The main ScrollBar will not call its ListBox handlers anymore. They are redirected to these ones, then the events are sent to all handlers.
    OnRedirectScrollBarInternalMouseMove: PDynTFTGenericEventHandler;
    OnRedirectScrollBarInternalAdjustScrollBar: POnOwnerInternalAdjustScrollBar;
    OnRedirectScrollBarInternalAfterAdjustScrollBar: POnOwnerInternalAdjustScrollBar;
  end;
  PDynTFTVirtualTable = ^TDynTFTVirtualTable;

procedure DynTFTDrawVirtualTable(AVirtualTable: PDynTFTVirtualTable; FullRedraw: Boolean);
function DynTFTVirtualTable_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualTable;
procedure DynTFTVirtualTable_Destroy(var AVirtualTable: PDynTFTVirtualTable);
procedure DynTFTVirtualTable_DestroyAndPaint(var AVirtualTable: PDynTFTVirtualTable);

procedure DynTFTSetVirtualTableScrollBarMaxBasedOnVisibility(AVirtualTable: PDynTFTVirtualTable);
procedure DynTFTUpdateVirtualTableEventHandlers(AVirtualTable: PDynTFTVirtualTable);
                                                                     
procedure DynTFTRegisterVirtualTableEvents;
function DynTFTGetVirtualTableComponentType: TDynTFTComponentType;

function DynTFTAddColumnToVirtualTable(AVirtualTable: PDynTFTVirtualTable): PDynTFTListBox;

//should not be called by user code (it is used internally and by DynTFTCodeGen plugins)
procedure DynTFTDestroyAllVirtualTableColumns(AVirtualTable: PDynTFTVirtualTable);
function DynTFTCreateFirstVirtualTableColumn(AVirtualTable: PDynTFTVirtualTable; {$IFDEF IsDesktop} AForCGPlugin: Boolean = False {$ENDIF}): PDynTFTListBox;  


{ToDo

[in work] - implement internal handlers
 - create an event for AfterDrawingItem  -requires implementation in DynTTFItems and DynTFTListBox (under compiler directive)/
   Only the last created ListBox should have this set, because it is the last to be painted.
 - the last column should fill the space
 - procedure for deleting columns (should not be able to delete the first one)
 - ("nice to have" task) - hide horizontal scrollbar if all columns fit the total table width
 - ("nice to have" task) - the total scroll amount of the horizontal scrollbar should be computed based on total column width vs. table width
 - verify if there is an AV, if the "Initialized" field from the dyn array, is changed to a static string and the HeaderItems and Columns are allocated in DynTFT's mm. Eventually, that should be the case, to accurately measure memory usage from the simulator. However, a static string is still not automatically initialized by compiler (it may actually have a random length).
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
  TempListBox, LastVisibleListBox: PDynTFTListBox;
  ComponentPos: Integer;
  LastColumnRight, VirtualTableRight, VirtualTableBottom, VertScrollBarLeft: Integer;
  ColumnIsVisible: Boolean;
  DrawingWidth: Integer;
begin
  n := AVirtualTable^.Columns^.Len - 1;
  ComponentPos := AVirtualTable^.BaseProps.Left + 1;
  VirtualTableBottom := AVirtualTable^.BaseProps.Top + AVirtualTable^.BaseProps.Height;
  VirtualTableRight := AVirtualTable^.BaseProps.Left + AVirtualTable^.BaseProps.Width;
  VertScrollBarLeft := VirtualTableRight - AVirtualTable^.VertScrollBar^.BaseProps.Width;   //AVirtualTable^.VertScrollBar^.BaseProps.Left is not always available

  DynTFT_Set_Pen(CL_LIGHTGRAY, 1);
  DynTFT_Line(ComponentPos - 1, AVirtualTable^.BaseProps.Top, ComponentPos + AVirtualTable^.BaseProps.Width - 2, AVirtualTable^.BaseProps.Top);  //to be replaced
  DynTFT_Line(ComponentPos - 1, AVirtualTable^.BaseProps.Top, ComponentPos - 1, VirtualTableBottom);

  TempListBox := nil;
  LastVisibleListBox := nil;

  for i := 0 to n do
  begin
    TempPanel := PDynTFTPanel(TPtrRec(AVirtualTable^.HeaderItems^.Content^[i]));
    TempListBox := PDynTFTListBox(TPtrRec(AVirtualTable^.Columns^.Content^[i]));

    TempPanel^.BaseProps.Left := ComponentPos;
    DrawingWidth := VertScrollBarLeft - (TempPanel^.BaseProps.Left + TempPanel^.BaseProps.Width);
    ColumnIsVisible := DrawingWidth > 0;

    if not ColumnIsVisible and (VertScrollBarLeft - TempPanel^.BaseProps.Left > TempListBox^.Items^.ItemHeight + 4) then   //20 = 16 + 4.  16 is the usual icon width.   4 is the spacing
    begin
      ColumnIsVisible := True;
      DrawingWidth := TempPanel^.BaseProps.Width;
      TempPanel^.BaseProps.Width := VertScrollBarLeft - TempPanel^.BaseProps.Left;

      if TempPanel^.BaseProps.Left + TempPanel^.BaseProps.Width > VertScrollBarLeft then
        TempPanel^.BaseProps.Width := VertScrollBarLeft - TempPanel^.BaseProps.Left;
    end
    else
      DrawingWidth := -1; //set to -1, to know if the panel width should be restored

    TempPanel^.BaseProps.Visible := Ord(Char((i >= AVirtualTable^.HorizScrollBar^.Position) and ColumnIsVisible));   //The Char typecasting is required by mP.
    TempListBox^.Items^.BaseProps.Visible := TempPanel^.BaseProps.Visible;
    TempListBox^.VertScrollBar^.BaseProps.Visible := TempPanel^.BaseProps.Visible;

    if TempPanel^.BaseProps.Visible = 1 then
    begin
      LastVisibleListBox := TempListBox;
      TempPanel^.BaseProps.Top := AVirtualTable^.BaseProps.Top + 1;  // + 1, to leave room for a rectangle

      TempListBox^.BaseProps.Left := ComponentPos;
      TempListBox^.BaseProps.Top := TempPanel^.BaseProps.Top + TempPanel^.BaseProps.Height;
      TempListBox^.BaseProps.Height := AVirtualTable^.BaseProps.Height - TempPanel^.BaseProps.Height - AVirtualTable^.HorizScrollBar^.BaseProps.Height - 3;
      TempListBox^.BaseProps.Width := TempPanel^.BaseProps.Width;

      if FullRedraw then
      begin
        TempListBox^.Items^.BaseProps.Height := TempListBox^.BaseProps.Height {- 1};
        TempListBox^.Items^.BaseProps.Left := ComponentPos;
        TempListBox^.Items^.BaseProps.Top := TempListBox^.BaseProps.Top;
        TempListBox^.Items^.BaseProps.Width := TempPanel^.BaseProps.Width;

        if i = 0 then //the VertScrollBar should exist for the first column only
          TempListBox^.VertScrollBar^.BaseProps.Height := TempListBox^.BaseProps.Height - 2;
      end;

      TempListBox^.BaseProps.Left := ComponentPos;

      if ColumnIsVisible then
      begin
        DynTFTDrawPanel(TempPanel, FullRedraw);
        //DynTFTDrawListBox(TempListBox, False); // - not required //set to False on all columns, to avoid drawing ListBox border
        DynTFTDrawItems(TempListBox^.Items, FullRedraw);
      end;

      if i > 0 then
      begin
        TempListBox^.VertScrollBar^.BtnInc^.BaseProps.Visible := 0;
        TempListBox^.VertScrollBar^.BtnDec^.BaseProps.Visible := 0;
        TempListBox^.VertScrollBar^.BtnScroll^.BaseProps.Visible := 0;
        TempListBox^.VertScrollBar^.BaseProps.Visible := 0;
        //Hiding the scrollbar with DynTFTHideComponent, leaves an "erased" rectangle. That's why the following line has to stay commented.
        //DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));  //the ScrollBar is displayed in DynTFTDrawListBox, based on the number of visible items

        DynTFT_Set_Pen(CL_DynTFTItems_Border, 1);
        DynTFT_Line(ComponentPos, AVirtualTable^.BaseProps.Top, ComponentPos, VirtualTableBottom - AVirtualTable^.HorizScrollBar^.BaseProps.Height - 1);
      end;

      if ColumnIsVisible then
      begin
//        if DrawingWidth <> -1 then
//          ComponentPos := ComponentPos + DrawingWidth
//        else
        ComponentPos := ComponentPos + TempPanel^.BaseProps.Width;
      end;
      //end;
    end
    else
    begin  //the column is not visible
      //TempListBox points to a column which will not be displayed. However, that area has to be cleared.

      if i > 0 then
        TempListBox := LastVisibleListBox //PDynTFTListBox(TPtrRec(AVirtualTable^.Columns.Content^[i - 1]))
      else
        TempListBox := nil;// prevent further section of the code, to run, if the column is hidden
    end;

    if DrawingWidth <> -1 then
      TempPanel^.BaseProps.Width := DrawingWidth;

    TempPanel^.BaseProps.Visible := 0; //prevent auto drawing from DynTFTRepaintScreenComponents
  end;

  if FullRedraw then
  begin
    AVirtualTable^.HorizScrollBar^.BaseProps.Left := AVirtualTable^.BaseProps.Left + 1;
    AVirtualTable^.HorizScrollBar^.BaseProps.Top := VirtualTableBottom - AVirtualTable^.HorizScrollBar^.BaseProps.Height - 1;
    AVirtualTable^.HorizScrollBar^.BaseProps.Width := AVirtualTable^.BaseProps.Width - AVirtualTable^.VertScrollBar^.BaseProps.Width - 3;
    DynTFTDrawScrollBar(AVirtualTable^.HorizScrollBar, FullRedraw);

    if TempListBox <> nil then     //this section should be replaced by something which extends the last listbox to the visible area and aligns its scrollbar to the right
    begin
      LastColumnRight := TempListBox^.BaseProps.Left + TempListBox^.BaseProps.Width;
      if LastColumnRight > VertScrollBarLeft then
        LastColumnRight := VertScrollBarLeft;

      if VirtualTableRight - LastColumnRight > 2 then
      begin
        DynTFT_Set_Pen(CL_DynTFTItems_Background, 1);
        DynTFT_Set_Brush(1, CL_DynTFTItems_Background, 0, 0, 0, 0);
        DynTFT_Rectangle(LastColumnRight + 1, AVirtualTable^.BaseProps.Top + 1, VertScrollBarLeft, AVirtualTable^.HorizScrollBar^.BaseProps.Top - 1);
      end;
    end;

    TempListBox := PDynTFTListBox(TPtrRec(AVirtualTable^.Columns^.Content^[0]));  //First
    if TempListBox <> nil then //this should always be the case
    begin               //align the vertical scrollbar to the right
      TempListBox^.VertScrollBar^.BaseProps.Left := VertScrollBarLeft;
      DynTFTDrawScrollBar(TempListBox^.VertScrollBar, True);
    end;

    DynTFT_Set_Pen(CL_DynTFTItems_Background, 1);
    DynTFT_Set_Brush(1, CL_DynTFTItems_Background, 0, 0, 0, 0);

    DynTFT_Rectangle(VirtualTableRight - AVirtualTable^.HorizScrollBar^.BaseProps.Height + 1,
                     VirtualTableBottom - AVirtualTable^.HorizScrollBar^.BaseProps.Height - 1,
                     VirtualTableRight,
                     VirtualTableBottom);
  end;
end;




procedure TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


procedure TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
  AVirtualTable: PDynTFTVirtualTable;
  TempListBox: PDynTFTListBox;
  i, n: Integer;
begin
  AScrBar := PDynTFTScrollBar(TPtrRec(ABase));
  //if PDynTFTBaseComponent(TPtrRec(AScrBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a VirtualTable
  begin
    TempListBox := PDynTFTListBox(TPtrRec(AScrBar^.BaseProps.Parent));
    AVirtualTable := PDynTFTVirtualTable(TPtrRec(TempListBox^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      AVirtualTable^.OnRedirectScrollBarInternalMouseMove^(ABase);
    {$ELSE}
      AVirtualTable^.OnRedirectScrollBarInternalMouseMove(ABase);
    {$ENDIF}

    n := AVirtualTable^.Columns^.Len - 1;
    for i := 1 to n do
    begin
      TempListBox := PDynTFTListBox(TPtrRec(AVirtualTable^.Columns^.Content^[i]));
      TempListBox^.VertScrollBar^.Position := AScrBar^.Position;
      {$IFDEF IsDesktop}
        TempListBox^.VertScrollBar^.OnOwnerInternalMouseMove^(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));
      {$ELSE}
        TempListBox^.VertScrollBar^.OnOwnerInternalMouseMove(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));
      {$ENDIF}
    end;
  end;
end;


procedure TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  //nothing here
end;


procedure TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalAdjust(AScrollBar: PDynTFTBaseComponent);
var
  AVirtualTable: PDynTFTVirtualTable;
  TempListBox: PDynTFTListBox;
  i, n: Integer;
begin
  //if PDynTFTBaseComponent(TPtrRec(AScrollBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a VirtualTable
  begin
    TempListBox := PDynTFTListBox(TPtrRec(AScrollBar^.BaseProps.Parent));
    AVirtualTable := PDynTFTVirtualTable(TPtrRec(TempListBox^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      AVirtualTable^.OnRedirectScrollBarInternalAdjustScrollBar^(AScrollBar);
    {$ELSE}
      AVirtualTable^.OnRedirectScrollBarInternalAdjustScrollBar(AScrollBar);
    {$ENDIF}

    n := AVirtualTable^.Columns^.Len - 1;
    for i := 1 to n do
    begin
      TempListBox := PDynTFTListBox(TPtrRec(AVirtualTable^.Columns^.Content^[i]));
      {$IFDEF IsDesktop}
        TempListBox^.VertScrollBar^.OnOwnerInternalAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));
      {$ELSE}
        TempListBox^.VertScrollBar^.OnOwnerInternalAdjustScrollBar(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));
      {$ENDIF}
    end;
  end;
end;


procedure TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalAfterAdjust(AScrollBar: PDynTFTBaseComponent);
var
  AVirtualTable: PDynTFTVirtualTable;
  TempListBox: PDynTFTListBox;
  i, n: Integer;
begin
  //if PDynTFTBaseComponent(TPtrRec(AScrollBar^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then //scroll bar belongs to a VirtualTable
  begin
    TempListBox := PDynTFTListBox(TPtrRec(AScrollBar^.BaseProps.Parent));
    AVirtualTable := PDynTFTVirtualTable(TPtrRec(TempListBox^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      AVirtualTable^.OnRedirectScrollBarInternalAfterAdjustScrollBar^(AScrollBar);
    {$ELSE}
      AVirtualTable^.OnRedirectScrollBarInternalAfterAdjustScrollBar(AScrollBar);
    {$ENDIF}

    n := AVirtualTable^.Columns^.Len - 1;
    for i := 1 to n do
    begin
      TempListBox := PDynTFTListBox(TPtrRec(AVirtualTable^.Columns^.Content^[i]));
      TempListBox^.VertScrollBar^.Position := PDynTFTScrollBar(TPtrRec(AScrollBar))^.Position;
      {$IFDEF IsDesktop}
        TempListBox^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));
      {$ELSE}
        TempListBox^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));
      {$ENDIF}  
    end;
  end;
end;


procedure TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalChange(AComp: PPtrRec);
var
  AVirtualTable: PDynTFTVirtualTable;
begin
  AVirtualTable := PDynTFTVirtualTable(TPtrRec(PDynTFTScrollBar(TPtrRec(AComp))^.BaseProps.Parent));
  DynTFTDrawVirtualTable(AVirtualTable, True);
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


{$IFDEF MouseClickSupport}
  procedure TDynTFTVirtualTable_OnDynTFTChildItemsInternalClick(ABase: PDynTFTBaseComponent);
  begin

  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTVirtualTable_OnDynTFTChildItemsInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin

  end;
{$ENDIF}


function GetVirtualTableColumnIndexFromItems(AItems: PPtrRec; var AVirtualTable: PDynTFTVirtualTable): LongInt;
var
  TempListBox: PDynTFTListBox;
  TempItems: PDynTFTItems;
begin
  TempItems := PDynTFTItems(TPtrRec(AItems));
  TempListBox := PDynTFTListBox(TPtrRec(TempItems^.BaseProps.Parent));
  AVirtualTable := PDynTFTVirtualTable(TPtrRec(TempListBox^.BaseProps.Parent));

  if TempListBox^.VertScrollBar^.BtnScroll^.DummyByte = 0 then //using 0 for the first column
    Result := 0
  else
    Result := TempListBox^.VertScrollBar^.BtnScroll^.Color; //this is set to "AVirtualTable^.Columns.Len - 1" when adding columns
end;


procedure TDynTFTVirtualTable_OnDynTFTChildItemsGetItemEvent(AItems: PPtrRec; Index: LongInt; var ItemText: string);
{$IFDEF UseExternalItems}
  var
    TempVirtualTable: PDynTFTVirtualTable;
    ColumnIndex: LongInt;
{$ENDIF}
begin
  {$IFDEF UseExternalItems}
    ColumnIndex := GetVirtualTableColumnIndexFromItems(AItems, TempVirtualTable);
    {$IFDEF IsDesktop}
      if Assigned(TempVirtualTable^.OnGetItem) then
        if Assigned(TempVirtualTable^.OnGetItem^) then
    {$ELSE}
      if TempVirtualTable^.OnGetItem <> nil then
    {$ENDIF}
        TempVirtualTable^.OnGetItem^(AItems, Index, ColumnIndex, ItemText);
  {$ELSE}
    ItemText := PDynTFTItems(TPtrRec(AItems))^.Strings[Index];
  {$ENDIF}
end;


{$IFDEF UseExternalItems}
  procedure TDynTFTVirtualTable_OnDynTFTChildItemsGetItemVisibility(AItems: PPtrRec; Index: LongInt; var ItemText: string {$IFDEF ItemsVisibility}; IsVisible: PBoolean {$ENDIF} {$IFDEF ItemsEnabling}; IsEnabled: PBoolean {$ENDIF});
  var
    TempVirtualTable: PDynTFTVirtualTable;
  begin
    GetVirtualTableColumnIndexFromItems(AItems, TempVirtualTable); //inefficient, because it ges the table at every item call

    {$IFDEF IsDesktop}
      if Assigned(TempVirtualTable^.OnGetItemVisibility) then
        if Assigned(TempVirtualTable^.OnGetItemVisibility^) then
    {$ELSE}
      if TempVirtualTable^.OnGetItemVisibility <> nil then
    {$ENDIF}
      TempVirtualTable^.OnGetItemVisibility^(AItems, Index, ItemText {$IFDEF ItemsVisibility}, IsVisible {$ENDIF} {$IFDEF ItemsEnabling}, IsEnabled {$ENDIF});
  end;
{$ENDIF}


procedure TDynTFTVirtualTable_OnDynTFTChildItemsDrawIcon(AItems: PPtrRec; Index, ItemY: LongInt; var ItemText: string {$IFDEF ItemsEnabling}; IsEnabled: Boolean {$ENDIF});
{$IFDEF ListIcons}
  var
    TempVirtualTable: PDynTFTVirtualTable;
    ColumnIndex: LongInt;
{$ENDIF}
begin
  {$IFDEF ListIcons}
    ColumnIndex := GetVirtualTableColumnIndexFromItems(AItems, TempVirtualTable);
    {$IFDEF IsDesktop}
      if Assigned(TempVirtualTable^.OnDrawIcon) then
        if Assigned(TempVirtualTable^.OnDrawIcon^) then
    {$ELSE}
      if TempVirtualTable^.OnDrawIcon <> nil then
    {$ENDIF}
        TempVirtualTable^.OnDrawIcon^(AItems, Index, ColumnIndex, ItemY, ItemText {$IFDEF ItemsEnabling}, IsEnabled {$ENDIF});
  {$ENDIF}
end;


procedure TDynTFTVirtualTable_OnDynTFTChildListBoxMouseDownEvent(Sender: PPtrRec);
var
  i, n: Integer;
  TempVirtualTable: PDynTFTVirtualTable;
  TempListBox, CurrentListBox: PDynTFTListBox;
begin
  CurrentListBox := PDynTFTListBox(TPtrRec(Sender));
  TempVirtualTable := PDynTFTVirtualTable(TPtrRec(CurrentListBox^.BaseProps.Parent));

  n := TempVirtualTable^.Columns^.Len - 1;
  for i := 0 to n do
  begin
    TempListBox := PDynTFTListBox(TPtrRec(TempVirtualTable^.Columns^.Content^[i]));
    if TempListBox <> CurrentListBox then
    begin
      TempListBox^.Items^.ItemIndex := CurrentListBox^.Items^.ItemIndex;
      DynTFTDrawItems(TempListBox^.Items, True);
    end;
  end;
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

  {$IFDEF IsDesktop}
    {$IFDEF UseExternalItems}
      AListBox^.Items^.OnGetItem^ := TDynTFTVirtualTable_OnDynTFTChildItemsGetItemEvent;
      AListBox^.Items^.OnGetItemVisibility^ := TDynTFTVirtualTable_OnDynTFTChildItemsGetItemVisibility;
    {$ENDIF}
    {$IFDEF ListIcons}
      AListBox^.Items^.OnDrawIcon^ := TDynTFTVirtualTable_OnDynTFTChildItemsDrawIcon;
    {$ENDIF}
    AListBox^.BaseProps.OnMouseDownUser^ := TDynTFTVirtualTable_OnDynTFTChildListBoxMouseDownEvent;  //a bit different, by using the User event, but this should also be fine
  {$ELSE}
    {$IFDEF UseExternalItems}
      AListBox^.Items^.OnGetItem := @TDynTFTVirtualTable_OnDynTFTChildItemsGetItemEvent;
      AListBox^.Items^.OnGetItemVisibility := @TDynTFTVirtualTable_OnDynTFTChildItemsGetItemVisibility;
    {$ENDIF}
    {$IFDEF ListIcons}
      AListBox^.Items^.OnDrawIcon := @TDynTFTVirtualTable_OnDynTFTChildItemsDrawIcon;
    {$ENDIF}
    AListBox^.BaseProps.OnMouseDownUser := @TDynTFTVirtualTable_OnDynTFTChildListBoxMouseDownEvent;  //a bit different, by using the User event, but this should also be fine
  {$ENDIF}
end;


function AddColumn(AVirtualTable: PDynTFTVirtualTable; AIsFirstColumn: Boolean; {$IFDEF IsDesktop} AForCGPlugin: Boolean = False {$ENDIF}): PDynTFTListBox;
var
  TempPanel: PDynTFTPanel;
  TempListBox: PDynTFTListBox;
  Left, Top, Height: TSInt;
begin
  Left := AVirtualTable^.BaseProps.Left;
  Top := AVirtualTable^.BaseProps.Top;
  Height := AVirtualTable^.BaseProps.Height;

  TempPanel := DynTFTPanel_Create(AVirtualTable^.BaseProps.ScreenIndex, Left + 1, Top + 1, 70, 20);
  TempListBox := DynTFTListBox_Create(AVirtualTable^.BaseProps.ScreenIndex, Left + 1, Top + 21, 70, Height - CScrollBarArrBtnWidthHeight - 1);

  if not AddPtrUIntToDynArraysOfPtrUInt(AVirtualTable^.HeaderItems^, PtrUInt(TempPanel)) then     //main column, this should always exist
  begin
    {$IFDEF IsDesktop}
      DynTFT_DebugConsole(COUTOFMEMORYMESSAGE + '  Cannot add column header to VirtualTable.');
    {$ELSE}
      DynTFT_DebugConsole(COUTOFMEMORYMESSAGE_MCU);
    {$ENDIF}

    Result := nil;
    Exit;
  end;

  if not AddPtrUIntToDynArraysOfPtrUInt(AVirtualTable^.Columns^, PtrUInt(TempListBox)) then      //main column, this should always exist
  begin
    {$IFDEF IsDesktop}
      DynTFT_DebugConsole(COUTOFMEMORYMESSAGE + '  Cannot add column to VirtualTable.');
    {$ELSE}
      DynTFT_DebugConsole(COUTOFMEMORYMESSAGE_MCU);
    {$ENDIF}

    Result := nil;
    Exit;
  end;

  SetInternalHandlersToPanel(TempPanel);
  SetInternalHandlersToListBox(TempListBox);

  TempPanel^.BaseProps.Parent := PPtrRec(TPtrRec(AVirtualTable));
  TempListBox^.BaseProps.Parent := PPtrRec(TPtrRec(AVirtualTable));

  TempPanel^.Caption := 'Col';

  Result := TempListBox;

  if not AIsFirstColumn then
  begin
    //DynTFTScrollBar_Destroy(TempListBox^.VertScrollBar); ////////////////////////// Do not destroy it. Not only that listbox requires a valid ScrollBar on drawing, but the VirtualTable uses the scrollbar for indexing.
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(TempListBox^.VertScrollBar)));  //at least it can be hidden  (not for long, see DynTFTDrawListBox ).

    TempListBox^.Items^.BaseProps.Width := TempListBox^.BaseProps.Width - 2;
  end;

  if AVirtualTable^.Columns^.Len = 1 then //this is the first column
    TempListBox^.VertScrollBar^.BtnScroll^.DummyByte := 0 //Using DummyByte, to indicate that the Color field should not be modified. It's the first column.
  else
  begin
    TempListBox^.VertScrollBar^.BtnScroll^.Color := AVirtualTable^.Columns^.Len - 1;    //this would have to be adjusted when deleting columns
    TempListBox^.VertScrollBar^.BtnScroll^.DummyByte := 1;
  end;

  AVirtualTable^.HorizScrollBar^.Max := LongInt(AVirtualTable^.Columns^.Len) - 1;

  //Hide the listbox here, so it is not automatically displayed. It will be set to visibile when needed.
  TempListBox^.BaseProps.Visible := 0;
  TempListBox^.Items^.BaseProps.Visible := 0;
end;


function DynTFTAddColumnToVirtualTable(AVirtualTable: PDynTFTVirtualTable): PDynTFTListBox;
begin
  Result := AddColumn(AVirtualTable, False);
end;


function DynTFTCreateFirstVirtualTableColumn(AVirtualTable: PDynTFTVirtualTable; {$IFDEF IsDesktop} AForCGPlugin: Boolean = False {$ENDIF}): PDynTFTListBox;  //should not be called by user code (it is used internally and by DynTFTCodeGen plugins)
var
  TempListBox: PDynTFTListBox;
begin
 {$IFDEF IsDesktop}
   try
     InitDynArrayOfPtrUIntToEmpty(AVirtualTable^.HeaderItems^);
     InitDynArrayOfPtrUIntToEmpty(AVirtualTable^.Columns^);
   except
     on E: Exception do
     begin
       DynTFTVirtualTable_Destroy(AVirtualTable);
       raise Exception.Create(E.Message + '  on initializing dyn arrays in DynTFTCreateFirstVirtualTableColumn');
     end;
   end;
 {$ELSE}
   InitDynArrayOfPtrUIntToEmpty(AVirtualTable^.HeaderItems^);
   InitDynArrayOfPtrUIntToEmpty(AVirtualTable^.Columns^);
 {$ENDIF}

  TempListBox := AddColumn(AVirtualTable, True {$IFDEF IsDesktop}, AForCGPlugin {$ENDIF});
  AVirtualTable^.VertScrollBar := TempListBox^.VertScrollBar;
  //AVirtualTable^.VertScrollBar^.BaseProps.Parent := PPtrRec(TPtrRec(AVirtualTable));  //Do not change the parent! The internal handlers assume that scrollbars belong to listboxes.

  //backup the pointers
  {$IFDEF IsDesktop}
    AVirtualTable^.OnRedirectScrollBarInternalMouseMove^ := AVirtualTable^.VertScrollBar^.OnOwnerInternalMouseMove^;
    AVirtualTable^.OnRedirectScrollBarInternalAdjustScrollBar^ := AVirtualTable^.VertScrollBar^.OnOwnerInternalAdjustScrollBar^;
    AVirtualTable^.OnRedirectScrollBarInternalAfterAdjustScrollBar^ := AVirtualTable^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar^;
  {$ELSE}
    AVirtualTable^.OnRedirectScrollBarInternalMouseMove := AVirtualTable^.VertScrollBar^.OnOwnerInternalMouseMove;
    AVirtualTable^.OnRedirectScrollBarInternalAdjustScrollBar := AVirtualTable^.VertScrollBar^.OnOwnerInternalAdjustScrollBar;
    AVirtualTable^.OnRedirectScrollBarInternalAfterAdjustScrollBar := AVirtualTable^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar;
  {$ENDIF}

      //Set the scrollbar handlers to the VirtualTable ones.
  {$IFDEF IsDesktop}
    TempListBox^.VertScrollBar^.OnOwnerInternalMouseMove^ := TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalMouseMove;
    TempListBox^.VertScrollBar^.OnOwnerInternalAdjustScrollBar^ := TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalAdjust;
    TempListBox^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar^ := TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalAfterAdjust;
  {$ELSE}
    TempListBox^.VertScrollBar^.OnOwnerInternalMouseMove := @TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalMouseMove;
    TempListBox^.VertScrollBar^.OnOwnerInternalAdjustScrollBar := @TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalAdjust;
    TempListBox^.VertScrollBar^.OnOwnerInternalAfterAdjustScrollBar := @TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalAfterAdjust;
  {$ENDIF}

  Result := TempListBox;
end;


procedure DynTFTDestroyAllVirtualTableColumns(AVirtualTable: PDynTFTVirtualTable);
var
  i: Integer;
  TempPanel: PDynTFTPanel;
  TempListBox: PDynTFTListBox;
begin
  {$IFDEF IsDesktop}
    if (AVirtualTable^.Columns.Initialized = '') or (AVirtualTable^.HeaderItems.Initialized = '') then //these may be '', if this call comes from DynTFTCreateFirstVirtualTableColumn
      Exit;
  {$ENDIF}

  for i := 0 to LongInt(AVirtualTable^.Columns^.Len) - 1 do
  begin
    TempPanel := PDynTFTPanel(AVirtualTable^.HeaderItems^.Content^[i]);
    DynTFTPanel_Destroy(TempPanel);
    AVirtualTable^.HeaderItems^.Content^[i] := 0;//nil;

    TempListBox := PDynTFTListBox(AVirtualTable^.Columns^.Content^[i]);
    DynTFTListBox_Destroy(TempListBox);
    AVirtualTable^.Columns^.Content^[i] := 0;//nil;
  end;

  FreeDynArrayOfPtrUInt(AVirtualTable^.HeaderItems^);
  FreeDynArrayOfPtrUInt(AVirtualTable^.Columns^);
end;


function DynTFTVirtualTable_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualTable;
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

  Result^.HorizScrollBar := DynTFTScrollBar_Create(ScreenIndex, 1, Top + Height - CScrollBarArrBtnWidthHeight - 1, Width - 2, CScrollBarArrBtnWidthHeight);  // Screen: DynTFTDev - Inactive at startup
  Result^.HorizScrollBar^.Max := 0;  //this will be automatically set later
  Result^.HorizScrollBar^.Min := 0;
  Result^.HorizScrollBar^.Position := Result^.HorizScrollBar^.Min;
  Result^.HorizScrollBar^.Direction := CScrollBarHorizDir;

  {$IFDEF IsDesktop}
    Result^.HorizScrollBar^.OnScrollBarChange^ := TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalChange;
  {$ELSE}
    Result^.HorizScrollBar^.OnScrollBarChange := @TDynTFTVirtualTable_OnDynTFTChildScrollBarInternalChange;
  {$ENDIF}

  Result^.HorizScrollBar^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      Result^.HorizScrollBar^.BaseProps.Name := 'cmb.HorizScrollBar';
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
    {$IFDEF MouseDoubleClickSupport}
      New(Result^.OnOwnerInternalDoubleClick);
    {$ENDIF}
    {$IFDEF UseExternalItems}
      New(Result^.OnGetItem);
      New(Result^.OnGetItemVisibility);
    {$ENDIF}
    {$IFDEF ListIcons}
      New(Result^.OnDrawIcon);
    {$ENDIF}

    New(Result^.OnRedirectScrollBarInternalMouseMove);
    New(Result^.OnRedirectScrollBarInternalAdjustScrollBar);
    New(Result^.OnRedirectScrollBarInternalAfterAdjustScrollBar);

    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    {$IFDEF MouseClickSupport}
      Result^.OnOwnerInternalClick^ := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Result^.OnOwnerInternalDoubleClick^ := nil;
    {$ENDIF}
    {$IFDEF UseExternalItems}
      Result^.OnGetItem^ := nil;
      Result^.OnGetItemVisibility^ := nil;
    {$ENDIF}
    {$IFDEF ListIcons}
      Result^.OnDrawIcon^ := nil;
    {$ENDIF}

    Result^.OnRedirectScrollBarInternalMouseMove^ := nil;
    Result^.OnRedirectScrollBarInternalAdjustScrollBar^ := nil;
    Result^.OnRedirectScrollBarInternalAfterAdjustScrollBar^ := nil;
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
    {$IFDEF UseExternalItems}
      Result^.OnGetItem := nil;
      Result^.OnGetItemVisibility := nil;
    {$ENDIF}
    {$IFDEF ListIcons}
      Result^.OnDrawIcon := nil;
    {$ENDIF}

    Result^.OnRedirectScrollBarInternalMouseMove := nil;
    Result^.OnRedirectScrollBarInternalAdjustScrollBar := nil;
    Result^.OnRedirectScrollBarInternalAfterAdjustScrollBar := nil;
  {$ENDIF}

  {$IFDEF IsDesktop}
    New(Result^.HeaderItems);  //Allocating with System's procedure, to avoid being allocated in DynTFT mm var.
    New(Result^.Columns);      //Allocating with System's procedure, to avoid being allocated in DynTFT mm var.
  {$ELSE}                          //on MCU, there is no "Initialized" field, so it doesn't need anything special.
    GetMem(Result^.HeaderItems, SizeOf(Result^.HeaderItems^));
    GetMem(Result^.Columns, SizeOf(Result^.Columns^));
  {$ENDIF}

  DynTFTCreateFirstVirtualTableColumn(Result);
end;


procedure DynTFTVirtualTable_Destroy(var AVirtualTable: PDynTFTVirtualTable);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  DynTFTDestroyAllVirtualTableColumns(AVirtualTable);
  DynTFTScrollBar_Destroy(AVirtualTable^.HorizScrollBar);

  {$IFDEF IsDesktop}
    Dispose(AVirtualTable^.HeaderItems);  //Deallocating with System's procedure, to avoid being deallocated from DynTFT mm var.
    Dispose(AVirtualTable^.Columns);      //Deallocating with System's procedure, to avoid being deallocated from DynTFT mm var.
  {$ELSE}                                      //on MCU, there is no "Initialized" field, so it doesn't need anything special.
    FreeMem(AVirtualTable^.HeaderItems, SizeOf(AVirtualTable^.HeaderItems^));
    FreeMem(AVirtualTable^.Columns, SizeOf(AVirtualTable^.Columns^));
  {$ENDIF}

  {$IFDEF IsDesktop}
    AVirtualTable^.HeaderItems.Initialized := '';  //set Initialized to '', because the string pointer is allocated in DynTFT's mm variable.
    AVirtualTable^.Columns.Initialized := '';
  {$ENDIF}


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
    {$IFDEF UseExternalItems}
      Dispose(AVirtualTable^.OnGetItem);
      Dispose(AVirtualTable^.OnGetItemVisibility);
    {$ENDIF}
    {$IFDEF ListIcons}
      Dispose(AVirtualTable^.OnDrawIcon);
    {$ENDIF}

    Dispose(AVirtualTable^.OnRedirectScrollBarInternalMouseMove);
    Dispose(AVirtualTable^.OnRedirectScrollBarInternalAdjustScrollBar);
    Dispose(AVirtualTable^.OnRedirectScrollBarInternalAfterAdjustScrollBar);

    AVirtualTable^.OnOwnerInternalMouseDown := nil;
    AVirtualTable^.OnOwnerInternalMouseMove := nil;
    AVirtualTable^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      AVirtualTable^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AVirtualTable^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AVirtualTable^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
    {$IFDEF UseExternalItems}
      AVirtualTable^.OnGetItem := nil;
      AVirtualTable^.OnGetItemVisibility := nil;
    {$ENDIF}
    {$IFDEF ListIcons}
      AVirtualTable^.OnDrawIcon := nil;
    {$ENDIF}

    AVirtualTable^.OnRedirectScrollBarInternalMouseMove := nil;
    AVirtualTable^.OnRedirectScrollBarInternalAdjustScrollBar := nil;
    AVirtualTable^.OnRedirectScrollBarInternalAfterAdjustScrollBar := nil;

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



procedure DynTFTSetVirtualTableScrollBarMaxBasedOnVisibility(AVirtualTable: PDynTFTVirtualTable);
begin

end;


procedure DynTFTUpdateVirtualTableEventHandlers(AVirtualTable: PDynTFTVirtualTable);
begin

end;


procedure HideSubComponents(AVirtualTable: PDynTFTVirtualTable);
var
  i, n: Integer;
begin
  n := AVirtualTable^.HeaderItems^.Len - 1;

  for i := 0 to n do
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HeaderItems^.Content^[i])));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.Columns^.Content^[i])));
  end;

  DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.VertScrollBar)));
  DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HorizScrollBar)));
end;


procedure ShowSubComponents(AVirtualTable: PDynTFTVirtualTable);
var
  i, n: Integer;
begin
  n := AVirtualTable^.HeaderItems^.Len - 1;

  for i := 0 to n do
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.HeaderItems^.Content^[i])));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AVirtualTable^.Columns^.Content^[i])));
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
