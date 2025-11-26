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
   
unit DynTFTItems;

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
  CMaxItemItemCount = 16;
  {$IFDEF UseExternalItemsStringLength}
    {$IFDEF ExternalItemsStringLengthAtProjectLevel}
      {$I ExternalItemsStringLength.inc}
    {$ELSE}
      {$I ..\ExternalItemsStringLength.inc}
    {$ENDIF}
  {$ELSE}
    CMaxItemsStringLength = 19; //n * 4 - 1
  {$ENDIF}

  {$IFDEF ListIcons}
    {$IFDEF UseExternalItemsIconIndent}
      {$IFDEF ExternalItemsIconIndentAtProjectLevel}
        {$I ExternalItemsIconIndent.inc}
      {$ELSE}
        {$I ..\ExternalItemsIconIndent.inc}
      {$ENDIF}
    {$ELSE}
      CIconIndent = 3;   //If the compiler reports that this constant is not found, then please enable ListIcons at project level. 
    {$ENDIF}  
  {$ENDIF}

type
  TItemsString = string[CMaxItemsStringLength];

  {$IFDEF IsMCU}
    PBoolean = ^Boolean;
  {$ENDIF}

  TOnGetItemEvent = procedure(AItems: PPtrRec; Index: LongInt; var ItemText: string);
  POnGetItemEvent = ^TOnGetItemEvent;

  TOnGetItemVisibilityEvent = procedure(AItems: PPtrRec; Index: LongInt; var ItemText: string {$IFDEF ItemsVisibility}; IsVisible: PBoolean {$ENDIF} {$IFDEF ItemsEnabling}; IsEnabled: PBoolean {$ENDIF});
  POnGetItemVisibilityEvent = ^TOnGetItemVisibilityEvent;

  TOnDrawIconEvent = procedure(AItems: PPtrRec; Index, ItemY: LongInt; var ItemText: string {$IFDEF ItemsEnabling}; IsEnabled: Boolean {$ENDIF});
  POnDrawIconEvent = ^TOnDrawIconEvent;

  TDynTFTItems = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    FirstDisplayablePosition, Count, ItemIndex: LongInt;   //FirstDisplayablePosition is the position of the first item, displayed on the screen

    //Items properties
    Font_Color, BackgroundColor: TColor;
    {$IFDEF DynTFTFontSupport}
      ActiveFont: PByte;
    {$ENDIF}

    ItemHeight: Word; //no TSInt allowed :(
    {$IFNDEF AppArch16}
      Dummy: Word; //keep alignment to 4 bytes   (<ArrowDir> + <DummyByte> + <Dummy>)
    {$ENDIF}

    {$IFDEF ItemsVisibility}
      TotalVisibleCount: LongInt;
    {$ENDIF}

    {$IFDEF ListIcons}
      VisibleIcons: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}
    {$ENDIF}
    
    //these events are set by an owner component, e.g. a list box, and called by Items
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
      OnGetItem: POnGetItemEvent;
      OnGetItemVisibility: POnGetItemVisibilityEvent;
    {$ELSE}
      Strings: array[0..CMaxItemItemCount - 1] of string[CMaxItemsStringLength];
      {$IFDEF ItemsVisibility}
        ItemsVisible: array[0..CMaxItemItemCount - 1] of {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}
      {$ENDIF}
      {$IFDEF ItemsEnabling}
        ItemsEnabled: array[0..CMaxItemItemCount - 1] of {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}
      {$ENDIF}
    {$ENDIF}

    {$IFDEF ListIcons}
      OnDrawIcon: POnDrawIconEvent;
    {$ENDIF}
  end;
  PDynTFTItems = ^TDynTFTItems;  

procedure DynTFTDrawItems(AItems: PDynTFTItems; FullRedraw: Boolean);
function DynTFTItems_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTItems;
procedure DynTFTItems_Destroy(var AItems: PDynTFTItems);
procedure DynTFTItems_DestroyAndPaint(var AItems: PDynTFTItems);

function DynTFTGetNumberOfItemsToDraw(AItems: PDynTFTItems): LongInt;
procedure DynTFTItemsGetItemText(AItems: PDynTFTItems; Index: LongInt; var ItemText: string);

function GetIndexOfFirstDrawingItem(AItems: PDynTFTItems; var VisibleCount: LongInt; var ItemText: string): Longint;
function GetMaxDrawingPosition(AItems: PDynTFTItems): Longint;
function GoToNextVisibleItemFromIndex(AItems: PDynTFTItems; IndexOfDrawingItem: LongInt; var ItemText: string {$IFDEF ItemsVisibility}; IsVisible: PBoolean {$ENDIF} {$IFDEF ItemsEnabling}; IsEnabled: PBoolean {$ENDIF}): LongInt;

procedure DynTFTRegisterItemsEvents;
function DynTFTGetItemsComponentType: TDynTFTComponentType;

{$IFDEF ItemsEnabling}
  function DynTFTItemsGetItemEnabling(AItems: PDynTFTItems; Index: LongInt; var ItemText: string): Boolean;
{$ENDIF}  

implementation

var
  ComponentType: TDynTFTComponentType;

function DynTFTGetItemsComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


function DynTFTGetNumberOfItemsToDraw(AItems: PDynTFTItems): LongInt;   // Do not calculate based on Items.Count !!!
begin                     //bug for height < 3                 // Do not calculate based on Items.Count !!!
  Result := (AItems^.BaseProps.Height - 3) div AItems^.ItemHeight;  //Add one more pixel between rows.
end;


procedure DynTFTItemsGetItemText(AItems: PDynTFTItems; Index: LongInt; var ItemText: string);
begin
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      if Assigned(AItems^.OnGetItem) then
        if Assigned(AItems^.OnGetItem^) then
    {$ELSE}
      if AItems^.OnGetItem <> nil then
    {$ENDIF}
        AItems^.OnGetItem^(PPtrRec(TPtrRec(AItems)), Index, ItemText)
      {else
        ItemText := 'OnGetItem is nil'};
  {$ELSE}
    ItemText := AItems^.Strings[Index];
  {$ENDIF}
end;


{$IFDEF ItemsVisibility}
  function DynTFTItemsGetItemVisibility(AItems: PDynTFTItems; Index: LongInt; var ItemText: string): Boolean;
  {$IFDEF UseExternalItems}
    {$IFDEF ItemsEnabling}
      var
        IsEnabled: Boolean;
    {$ENDIF}
  {$ENDIF}
  begin
    {$IFDEF UseExternalItems}
      Result := True;
      {$IFDEF ItemsEnabling}
        IsEnabled := True;
      {$ENDIF}

      {$IFDEF IsDesktop}
        if Assigned(AItems^.OnGetItemVisibility) then
          if Assigned(AItems^.OnGetItemVisibility^) then
      {$ELSE}
        if AItems^.OnGetItemVisibility <> nil then
      {$ENDIF}
          AItems^.OnGetItemVisibility^(PPtrRec(TPtrRec(AItems)), Index, ItemText, @Result {$IFDEF ItemsEnabling}, @IsEnabled {$ENDIF})
        {else
          ItemText := 'OnGetItem is nil'};
    {$ELSE}
      Result := AItems^.ItemsVisible[Index];
    {$ENDIF}
  end;
{$ENDIF}


{$IFDEF ItemsEnabling}
  function DynTFTItemsGetItemEnabling(AItems: PDynTFTItems; Index: LongInt; var ItemText: string): Boolean;
  {$IFDEF UseExternalItems}
    {$IFDEF ItemsVisibility}
      var
        IsVisible: Boolean;
    {$ENDIF}
  {$ENDIF}
  begin
    {$IFDEF UseExternalItems}
      Result := True;
      {$IFDEF ItemsVisibility}
        IsVisible := True;
      {$ENDIF}

      {$IFDEF IsDesktop}
        if Assigned(AItems^.OnGetItemVisibility) then
          if Assigned(AItems^.OnGetItemVisibility^) then
      {$ELSE}
        if AItems^.OnGetItemVisibility <> nil then           //OnGetItemVisibility also used for Enabling
      {$ENDIF}
          AItems^.OnGetItemVisibility^(PPtrRec(TPtrRec(AItems)), Index, ItemText, {$IFDEF ItemsVisibility} @IsVisible, {$ENDIF} @Result)
        {else
          ItemText := 'OnGetItem is nil'};
    {$ELSE}
      Result := AItems^.ItemsEnabled[Index];
    {$ENDIF}
  end;
{$ENDIF}


function GoToNextVisibleItemFromIndex(AItems: PDynTFTItems; IndexOfDrawingItem: LongInt; var ItemText: string {$IFDEF ItemsVisibility}; IsVisible: PBoolean {$ENDIF} {$IFDEF ItemsEnabling}; IsEnabled: PBoolean {$ENDIF}): LongInt;
var
  NewIndexOfDrawingItem: LongInt;
begin
  NewIndexOfDrawingItem := IndexOfDrawingItem;
  repeat
    DynTFTItemsGetItemText(AItems, NewIndexOfDrawingItem, ItemText);

    {$IFDEF ItemsVisibility}
      IsVisible^ := DynTFTItemsGetItemVisibility(AItems, NewIndexOfDrawingItem, ItemText);
    {$ENDIF}
    {$IFDEF ItemsEnabling}
      IsEnabled^ := DynTFTItemsGetItemEnabling(AItems, NewIndexOfDrawingItem, ItemText);
    {$ENDIF}

    Inc(NewIndexOfDrawingItem);
  until {$IFDEF ItemsVisibility}IsVisible^ or (NewIndexOfDrawingItem >= AItems^.Count) {$ELSE} True {$ENDIF};

  Result := NewIndexOfDrawingItem;
end;


{$IFDEF ItemsVisibility}
  function GetIndexOfVisibleItemFromDisplayablePosition(AItems: PDynTFTItems; var VisibleCount: LongInt; var ItemText: string): LongInt;
  var
    IsVisible: Boolean;
    {$IFDEF ItemsEnabling}
      IsEnabled: Boolean;
    {$ENDIF}
    i: LongInt;
    IndexOfDrawingItem: LongInt;
  begin
    IndexOfDrawingItem := 0;
    i := 0;
    while i < AItems^.FirstDisplayablePosition do
    begin
      IndexOfDrawingItem := GoToNextVisibleItemFromIndex(AItems, IndexOfDrawingItem, ItemText, @IsVisible {$IFDEF ItemsEnabling}, @IsEnabled {$ENDIF});

      if IsVisible then
        Inc(VisibleCount);

      if IndexOfDrawingItem >= AItems^.Count then
        Break;

      Inc(i);
    end;

    Result := IndexOfDrawingItem;
  end;


  function GetRemainingVisibleCount(AItems: PDynTFTItems; IndexOfDrawingItemStart: LongInt; var ItemText: string): LongInt;
  var
    IsVisible: Boolean;
    {$IFDEF ItemsEnabling}
      IsEnabled: Boolean;
    {$ENDIF}
    IndexOfDrawingItem: LongInt;
  begin
    Result := 0;
    IndexOfDrawingItem := IndexOfDrawingItemStart;
    repeat
      IndexOfDrawingItem := GoToNextVisibleItemFromIndex(AItems, IndexOfDrawingItem, ItemText, @IsVisible {$IFDEF ItemsEnabling}, @IsEnabled {$ENDIF});

      if IsVisible then
        Inc(Result);

      if IndexOfDrawingItem >= AItems^.Count then
        Break;
    until not IsVisible;
  end;
{$ENDIF}


function GetIndexOfFirstDrawingItem(AItems: PDynTFTItems; var VisibleCount: LongInt; var ItemText: string): Longint;
begin
  {$IFDEF ItemsVisibility}
    Result := GetIndexOfVisibleItemFromDisplayablePosition(AItems, VisibleCount, ItemText);
  {$ELSE}
    Result := AItems^.FirstDisplayablePosition;
  {$ENDIF}
end;


function GetMaxDrawingPosition(AItems: PDynTFTItems): Longint;    //seems weird
begin
  Result := DynTFTGetNumberOfItemsToDraw(AItems);
  if Result > AItems^.Count then
  begin
    Result := AItems^.Count;
    AItems^.FirstDisplayablePosition := 0;
  end;

  Result := Result - 1;
end;


{$IFDEF ListIcons}
  procedure DynTFTItemsDrawIcon(AItems: PDynTFTItems; Index, ItemY: LongInt; var ItemText: string {$IFDEF ItemsEnabling}; IsEnabled: Boolean {$ENDIF});
  begin
    {$IFDEF IsDesktop}
      if Assigned(AItems^.OnDrawIcon) then
        if Assigned(AItems^.OnDrawIcon^) then
    {$ELSE}
      if AItems^.OnDrawIcon <> nil then
    {$ENDIF}
        AItems^.OnDrawIcon^(PPtrRec(TPtrRec(AItems)), Index, ItemY, ItemText {$IFDEF ItemsEnabling}, IsEnabled {$ENDIF})
  end;
{$ENDIF}


procedure DynTFTDrawItems(AItems: PDynTFTItems; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
  i: LongInt;
  MaxDrawingPosition: LongInt;
  IndexOfDrawingItem: LongInt;
  {$IFDEF ListIcons}
    OldIndexOfDrawingItem: LongInt;
  {$ENDIF}
  
  VisibleCount: LongInt;

  FocusRectangleY, ItemY: LongInt;
  FontCol: TColor;
  ATempString: string {$IFDEF IsMCU}[CMaxItemsStringLength] {$ENDIF};

  {$IFDEF ItemsVisibility}
    IsVisible: Boolean;
  {$ENDIF}
  {$IFDEF ItemsEnabling}
    IsEnabled: Boolean;
  {$ENDIF}

  {$IFDEF ItemsEnabling}
    EnabledFontCol: TColor;
  {$ENDIF}

  {$IFDEF ItemsTextCrop}
    TextWidth, TextHeight: Word;
    TextSpace: TSInt;
  {$ENDIF}
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AItems))) then
    Exit;

  x1 := AItems^.BaseProps.Left;
  y1 := AItems^.BaseProps.Top;
  x2 := x1 + AItems^.BaseProps.Width;
  y2 := y1 + AItems^.BaseProps.Height;

  if FullRedraw then
  begin
    DynTFT_Set_Pen(CL_DynTFTItems_Border, 1);
    DynTFT_Set_Brush(1, AItems^.BackgroundColor, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;
          
  //lines
  DynTFT_Set_Pen(CL_DynTFTItems_DarkEdge, 1);
  DynTFT_V_Line(y1, y2, x1); //vert
  DynTFT_H_Line(x1, x2, y1); //horiz

  FocusRectangleY := -1;

  if AItems^.BaseProps.Enabled and CENABLED = CENABLED then
    FontCol := AItems^.Font_Color
  else
    FontCol := CL_DynTFTItems_DisabledFont;

  VisibleCount := 0;

  {$IFDEF IsDesktop}
    ATempString := 'OnGetItem is nil';
  {$ENDIF}

  IndexOfDrawingItem := GetIndexOfFirstDrawingItem(AItems, VisibleCount, ATempString);
  MaxDrawingPosition := GetMaxDrawingPosition(AItems);

  {$IFDEF ItemsVisibility}
    IsVisible := False;
  {$ENDIF}
  {$IFDEF ItemsEnabling}
    IsEnabled := False;
  {$ENDIF}

  for i := 0 to MaxDrawingPosition do
  begin
    if IndexOfDrawingItem >= AItems^.Count then
      Break;

    {$IFDEF ListIcons}
      OldIndexOfDrawingItem := IndexOfDrawingItem;
    {$ENDIF}

    IndexOfDrawingItem := GoToNextVisibleItemFromIndex(AItems, IndexOfDrawingItem, ATempString {$IFDEF ItemsVisibility}, @IsVisible {$ENDIF} {$IFDEF ItemsEnabling}, @IsEnabled {$ENDIF});

    ItemY := y1 + i * AItems^.ItemHeight + 1;
    {$IFDEF ItemsVisibility}
      if IsVisible then
    {$ENDIF}
      begin
        Inc(VisibleCount);
        if IndexOfDrawingItem - 1 = AItems^.ItemIndex then     //Selected item - rectangle
        begin
          {$IFDEF DynTFTFontSupport}
            DynTFT_Set_Font(AItems^.ActiveFont, AItems^.BackgroundColor, FO_HORIZONTAL);
          {$ELSE}
            DynTFT_Set_Font(@TFT_defaultFont, AItems^.BackgroundColor, FO_HORIZONTAL);
          {$ENDIF}
          DynTFT_Set_Brush(1, CL_DynTFTItems_SelectedItem, 0, 0, 0, 0);                    //selected
          FocusRectangleY := ItemY;

          DynTFT_Set_Pen(CL_DynTFTItems_SelectedItem, 1);
          DynTFT_Rectangle(x1 + 1, ItemY, x2 - 2, ItemY + AItems^.ItemHeight);
          DynTFT_Set_Brush(0, CL_DynTFTItems_SelectedItem, 0, 0, 0, 0);
        end
        else
        begin
          {$IFDEF ItemsEnabling}
            if IsEnabled then
              EnabledFontCol := FontCol
            else
              EnabledFontCol := CL_DynTFTItems_DisabledFont;

            {$IFDEF DynTFTFontSupport}
              DynTFT_Set_Font(AItems^.ActiveFont, EnabledFontCol, FO_HORIZONTAL);
            {$ELSE}
              DynTFT_Set_Font(@TFT_defaultFont, EnabledFontCol, FO_HORIZONTAL);
            {$ENDIF}
          {$ELSE}
            {$IFDEF DynTFTFontSupport}
              DynTFT_Set_Font(AItems^.ActiveFont, FontCol, FO_HORIZONTAL);
            {$ELSE}
              DynTFT_Set_Font(@TFT_defaultFont, FontCol, FO_HORIZONTAL);
            {$ENDIF}
          {$ENDIF}
          DynTFT_Set_Brush(1, AItems^.BackgroundColor, 0, 0, 0, 0);
        end;

        {$IFDEF ItemsTextCrop}
          TextSpace := AItems^.BaseProps.Width - 3 {$IFDEF ListIcons} - CIconIndent {$ENDIF};
          {$IFDEF ListIcons}
            if AItems^.VisibleIcons then
              TextSpace := TextSpace - AItems^.ItemHeight;
          {$ENDIF}

          repeat
            if Length(ATempString) = 0 then
              Break;
              
            GetTextWidthAndHeight(ATempString, TextWidth, TextHeight);

            if TSInt(TextWidth) > TextSpace then
              {$IFDEF IsDesktop}
                ATempString := Copy(ATempString, 1, Length(ATempString) - 1)   //A very inneficient way of making the string shorter.
              {$ELSE}
                ATempString[Length(ATempString) - 1] := #0
              {$ENDIF}  
            else
              Break;  
          until Length(ATempString) = 0;
        {$ENDIF}

        {$IFDEF ListIcons}
          if AItems^.VisibleIcons then
          begin
            DynTFT_Write_Text(ATempString, x1 + 3 + CIconIndent + AItems^.ItemHeight, ItemY);
            DynTFTItemsDrawIcon(AItems, OldIndexOfDrawingItem, ItemY + 2, ATempString {$IFDEF ItemsEnabling}, IsEnabled {$ENDIF});
          end
          else
            DynTFT_Write_Text(ATempString, x1 + 3, ItemY);
        {$ELSE}
          DynTFT_Write_Text(ATempString, x1 + 3, ItemY);
        {$ENDIF}  

        {$IFDEF IsDesktop}
          //DynTFT_TestConsole(ATempString);
        {$ENDIF}
      end; //if IsVisible then
  end;

  {$IFDEF ItemsVisibility}
    if IsVisible then
      VisibleCount := VisibleCount + GetRemainingVisibleCount(AItems, IndexOfDrawingItem - 1, ATempString) - 1;

    AItems^.TotalVisibleCount := VisibleCount;  
    //DynTFT_TestConsole('VisibleCount=' + IntToStr(VisibleCount));
  {$ENDIF}
  
  //Draw focus rectangle from lines
  if AItems^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    DynTFT_Set_Pen(CL_DynTFTItems_FocusRectangle, 1)
  else 
    DynTFT_Set_Pen(CL_DynTFTItems_UnFocusRectangle, 1);

  if FocusRectangleY <> -1 then
  begin
    Inc(x1);
    y2 := FocusRectangleY + AItems^.ItemHeight;
    DynTFT_V_Line(FocusRectangleY, y2, x1); //vert
    DynTFT_H_Line(x1, x2 - 1, FocusRectangleY); //horiz
    DynTFT_V_Line(FocusRectangleY, y2, x2 - 1); //vert
    DynTFT_H_Line(x1, x2 - 1, y2); //horiz
  end;
end;
          

function DynTFTItems_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTItems;
var
  DummyTextWidth: Word;
  {$IFNDEF UseExternalItems}
    i: Word;
  {$ENDIF}
//  TempStr: string[3];
begin
  Result := PDynTFTItems(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTItems was not registered. Please call RegisterItemsEvents before creating a PDynTFTItems. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, True, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

//  TempStr := 'fp';
//  GetTextWidthAndHeight(TempStr, DummyTextWidth, Result^.ItemHeight);    //fp is a text with great height
//  Result^.ItemHeight := Result^.ItemHeight + 3;
  Result^.ItemHeight := 16; //Using GetTextWidthAndHeight is unreliable, because the font is not set yet. It will be set later, after assigning the ActiveFont property.

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
      Result^.OnGetItem^ := nil;
    {$ENDIF}
    {$IFDEF ListIcons}
      New(Result^.OnDrawIcon);
      Result^.OnDrawIcon^ := nil;
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
    {$IFDEF UseExternalItems}
      Result^.OnGetItem := nil;
    {$ENDIF}
    {$IFDEF ListIcons}
      Result^.OnDrawIcon := nil;
    {$ENDIF}

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

  Result^.ItemIndex := -1;
  Result^.Count := 0;
  Result^.FirstDisplayablePosition := 0;
  Result^.BackgroundColor := CL_DynTFTItems_Background;
  Result^.Font_Color := CL_DynTFTItems_EnabledFont;

  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      New(Result^.OnGetItemVisibility);
      Result^.OnGetItemVisibility^ := nil;
    {$ELSE}
      Result^.OnGetItemVisibility := nil;
    {$ENDIF}
  {$ELSE}
    for i := 0 to CMaxItemItemCount - 1 do
    begin
      Result^.Strings[i] := '';
      {$IFDEF ItemsVisibility}
        Result^.ItemsVisible[i] := True;
      {$ENDIF}
      {$IFDEF ItemsEnabling}
        Result^.ItemsEnabled[i] := True;
      {$ENDIF}
    end;
  {$ENDIF}

  {$IFDEF ItemsVisibility}
    Result^.TotalVisibleCount := 0;
  {$ENDIF}

  {$IFDEF ListIcons}
    Result^.VisibleIcons := False;
  {$ENDIF}

  {$IFDEF UseExternalItemsStringLength}
    {$IFDEF IsDesktop}
      //DynTFT_DebugConsole('Using ExternalItemsStringLength. CMaxItemsStringLength = ' + IntToStr(CMaxItemsStringLength));
    {$ENDIF}
  {$ENDIF}

  {$IFDEF DynTFTFontSupport}
    Result^.ActiveFont := @TFT_defaultFont;
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTDisplayErrorOnStringConstLength(CMaxItemsStringLength, 'PDynTFTItems');
  {$ENDIF}
end;


function DynTFTItems_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTItems_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTItems_Destroy(var AItems: PDynTFTItems);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AItems^.OnOwnerInternalMouseDown);
    Dispose(AItems^.OnOwnerInternalMouseMove);
    Dispose(AItems^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      Dispose(AItems^.OnOwnerInternalClick);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Dispose(AItems^.OnOwnerInternalDoubleClick);
    {$ENDIF}

    AItems^.OnOwnerInternalMouseDown := nil;
    AItems^.OnOwnerInternalMouseMove := nil;
    AItems^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      AItems^.OnOwnerInternalClick := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      AItems^.OnOwnerInternalDoubleClick := nil;
    {$ENDIF}
  {$ENDIF}
  
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      Dispose(AItems^.OnGetItem);
      Dispose(AItems^.OnGetItemVisibility);

      {$IFDEF ListIcons}
        Dispose(AItems^.OnDrawIcon);
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AItems)), SizeOf(AItems^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AItems));
    DynTFTComponent_Destroy(ATemp, SizeOf(AItems^));
    AItems := PDynTFTItems(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTItems_DestroyAndPaint(var AItems: PDynTFTItems);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AItems)));
  DynTFTItems_Destroy(AItems);
end;


procedure DynTFTItems_BaseDestroyAndPaint(var AItems: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTItems;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTItems_DestroyAndPaint(PDynTFTItems(TPtrRec(AItems)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTItems(TPtrRec(AItems));
    DynTFTItems_DestroyAndPaint(ATemp);
    AItems := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTItems_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTItems_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTItems_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTItems_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTItems_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTItems(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
  end;
{$ENDIF}


procedure TDynTFTItems_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin                                     
  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
    Exit;

  if Options = CREPAINTONMOUSEUP then
    Exit;

  DynTFTDrawItems(PDynTFTItems(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterItemsEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTItems_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTItems_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTItems_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := TDynTFTItems_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent^ := TDynTFTItems_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTItems_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTItems_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTItems_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTItems_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTItems_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTItems_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := @TDynTFTItems_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := @TDynTFTItems_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTItems_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTItems_Create;
      ABaseEventReg.CompDestroy := @DynTFTItems_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTItems); 
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