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
   
unit DynTFTComboBox;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTArrowButton, DynTFTScrollBar, DynTFTItems, DynTFTListBox, DynTFTEdit,
  DynTFTLabel

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

type
  TOnComboBoxCloseUpEvent = procedure(AComp: PPtrRec);
  POnComboBoxCloseUpEvent = ^TOnComboBoxCloseUpEvent;

  TDynTFTComboBox = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ComboBox properties
    Edit: PDynTFTEdit;
    ExteriorLabel: PDynTFTLabel;
    ListBox: PDynTFTListBox;
    ArrowButton: PDynTFTArrowButton; //this should be the last created item in the combo box, for an easy bringing these to front
    DroppedDown: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}
    Editable: {$IFDEF IsDesktop} LongBool; {$ELSE} Boolean; {$ENDIF}

    OnComboBoxCloseUp: POnComboBoxCloseUpEvent;
  end;
  PDynTFTComboBox = ^TDynTFTComboBox;

procedure DynTFTDrawComboBox(AComboBox: PDynTFTComboBox; FullRedraw: Boolean);
function DynTFTComboBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTComboBox;
procedure DynTFTComboBox_Destroy(var AComboBox: PDynTFTComboBox);
procedure DynTFTComboBox_DestroyAndPaint(var AComboBox: PDynTFTComboBox);

procedure DynTFTComboBoxSetEnabledState(AComboBox: PDynTFTComboBox; NewState: Byte);
procedure DynTFTEnableComboBox(AComboBox: PDynTFTComboBox);
procedure DynTFTDisableComboBox(AComboBox: PDynTFTComboBox);

procedure DynTFTRegisterComboBoxEvents;
function DynTFTGetComboBoxComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetComboBoxComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawComboBox(AComboBox: PDynTFTComboBox; FullRedraw: Boolean);
begin
  DynTFTDrawEdit(AComboBox^.Edit, FullRedraw);
  DynTFTDrawArrowButton(AComboBox^.ArrowButton, FullRedraw);

  if AComboBox^.DroppedDown then
    DynTFTDrawListBox(AComboBox^.ListBox, FullRedraw);
end;


procedure DynTFTComboBoxSetEnabledState(AComboBox: PDynTFTComboBox; NewState: Byte);
begin
  AComboBox^.BaseProps.Enabled := NewState;
  AComboBox^.Edit^.BaseProps.Enabled := NewState;
  AComboBox^.ListBox^.BaseProps.Enabled := NewState;
  AComboBox^.ArrowButton^.BaseProps.Enabled := NewState;
  DynTFTDrawComboBox(AComboBox, True);
end;


procedure DynTFTEnableComboBox(AComboBox: PDynTFTComboBox);
begin
  DynTFTComboBoxSetEnabledState(AComboBox, CENABLED);
end;


procedure DynTFTDisableComboBox(AComboBox: PDynTFTComboBox);
begin
  DynTFTComboBoxSetEnabledState(AComboBox, CDISABLED);
end;


procedure SetEditReadonlyState(AComboBox: PDynTFTComboBox);
begin
  if AComboBox^.Edit^.Readonly = AComboBox^.Editable then
    AComboBox^.Edit^.Readonly := not AComboBox^.Editable;

  if AComboBox^.Edit^.Readonly then
    DynTFTUnfocusComponent(PDynTFTBaseComponent(TPtrRec(AComboBox^.Edit)));
end;


procedure HideListBoxAndRepaintUnderIt(AComboBox: PDynTFTComboBox);
begin
  DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(AComboBox^.ListBox)));
  DynTFTRepaintScreenComponentsFromArea(PDynTFTBaseComponent(TPtrRec(AComboBox^.ListBox)));

  {$IFDEF IsDesktop}
    if Assigned(AComboBox^.OnComboBoxCloseUp) then
      if Assigned(AComboBox^.OnComboBoxCloseUp^) then
  {$ELSE}
    if AComboBox^.OnComboBoxCloseUp <> nil then
  {$ENDIF}
      AComboBox^.OnComboBoxCloseUp^(PPtrRec(TPtrRec(AComboBox)));
end;


procedure ShowListBoxAndBringToFront(AComboBox: PDynTFTComboBox);
begin
  DynTFTShowComponentWithDelay(PDynTFTBaseComponent(TPtrRec(AComboBox^.ListBox)));
  DynTFTComponent_BringMultipleComponentsToFront(PDynTFTBaseComponent(TPtrRec(AComboBox^.Edit)), PDynTFTBaseComponent(TPtrRec(AComboBox^.ExteriorLabel)));
end;


procedure TDynTFTComboBox_OnDynTFTChildEditInternalMouseDown(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTComboBox_OnDynTFTChildEditInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
                                                                                 
end;


procedure TDynTFTComboBox_OnDynTFTChildEditInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  AComboBox: PDynTFTComboBox;
begin
  if PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AComboBox := PDynTFTComboBox(TPtrRec(ABase^.BaseProps.Parent));
    SetEditReadonlyState(AComboBox);

    if AComboBox^.Edit^.Readonly then
    begin
      AComboBox^.DroppedDown := not AComboBox^.DroppedDown;
      
      if AComboBox^.DroppedDown then
        ShowListBoxAndBringToFront(AComboBox)
      else
        HideListBoxAndRepaintUnderIt(AComboBox);
    end
    else
      if AComboBox^.DroppedDown then
      begin
        AComboBox^.DroppedDown := False;
        HideListBoxAndRepaintUnderIt(AComboBox);
      end;

    AComboBox^.ExteriorLabel^.BaseProps.Visible := AComboBox^.ListBox^.BaseProps.Visible;
  end; //if is ComboBox
end;

///

procedure TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseDown(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  AComboBox: PDynTFTComboBox;
  {$IFDEF IsDesktop}
    ATempString: string;
  {$ENDIF}
begin
  if PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AComboBox := PDynTFTComboBox(TPtrRec(ABase^.BaseProps.Parent));
    SetEditReadonlyState(AComboBox);

    AComboBox^.DroppedDown := False;

    HideListBoxAndRepaintUnderIt(AComboBox);

    if AComboBox^.ListBox^.Items^.ItemIndex > -1 then
    begin
      {$IFDEF IsDesktop}
        DynTFTItemsGetItemText(AComboBox^.ListBox^.Items, AComboBox^.ListBox^.Items^.ItemIndex, ATempString);
        AComboBox^.Edit^.Text := ATempString;
      {$ELSE}
        DynTFTItemsGetItemText(AComboBox^.ListBox^.Items, AComboBox^.ListBox^.Items^.ItemIndex, AComboBox^.Edit^.Text);
      {$ENDIF}
      //AComboBox^.Edit^.Text := AComboBox^.ListBox^.Items^.Strings[AComboBox^.ListBox^.Items^.ItemIndex];
      DynTFTEditAfterSetText(AComboBox^.Edit);
    end;

    AComboBox^.ExteriorLabel^.BaseProps.Visible := AComboBox^.ListBox^.BaseProps.Visible;
  end; //if is ComboBox
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTComboBox_OnDynTFTChildListBoxInternalClick(ABase: PDynTFTBaseComponent);
  var
    AComboBox: PDynTFTComboBox;
  begin
    if PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
    begin
      AComboBox := PDynTFTComboBox(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.BaseProps.Parent));

      {$IFDEF IsDesktop}
        if Assigned(AComboBox^.BaseProps.OnClickUser) then
          if Assigned(AComboBox^.BaseProps.OnClickUser^) then
      {$ELSE}
        if AComboBox^.BaseProps.OnClickUser <> nil then
      {$ENDIF}
          AComboBox^.BaseProps.OnClickUser^(PPtrRec(TPtrRec(AComboBox)));
    end;
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTComboBox_OnDynTFTChildListBoxInternalDoubleClick(ABase: PDynTFTBaseComponent);
  var
    AComboBox: PDynTFTComboBox;
  begin
    if PDynTFTBaseComponent(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
    begin
      AComboBox := PDynTFTComboBox(TPtrRec(PDynTFTListBox(TPtrRec(ABase))^.BaseProps.Parent));

      {$IFDEF IsDesktop}
        if Assigned(AComboBox^.BaseProps.OnDoubleClickUser) then
          if Assigned(AComboBox^.BaseProps.OnDoubleClickUser^) then
      {$ELSE}
        if AComboBox^.BaseProps.OnDoubleClickUser <> nil then
      {$ENDIF}
          AComboBox^.BaseProps.OnDoubleClickUser^(PPtrRec(TPtrRec(AComboBox)));
    end;
  end;
{$ENDIF}

///

procedure TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseDown(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
                                                                                 
end;


procedure TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  AComboBox: PDynTFTComboBox;
begin
  if PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AComboBox := PDynTFTComboBox(TPtrRec(ABase^.BaseProps.Parent));
    SetEditReadonlyState(AComboBox);

    AComboBox^.DroppedDown := not AComboBox^.DroppedDown;

    if AComboBox^.DroppedDown then
      ShowListBoxAndBringToFront(AComboBox)
    else
      HideListBoxAndRepaintUnderIt(AComboBox);  

    AComboBox^.ExteriorLabel^.BaseProps.Visible := AComboBox^.ListBox^.BaseProps.Visible;
  end; //if is ComboBox
end;

///

procedure TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AComboBox: PDynTFTComboBox;
begin
  if PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AComboBox := PDynTFTComboBox(TPtrRec(ABase^.BaseProps.Parent));
    SetEditReadonlyState(AComboBox);

    AComboBox^.DroppedDown := False;
    HideListBoxAndRepaintUnderIt(AComboBox);

    AComboBox^.ExteriorLabel^.BaseProps.Visible := AComboBox^.ListBox^.BaseProps.Visible;
  end; //if is ComboBox
end;


procedure TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
                                                                                 
end;


procedure TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseUp(ABase: PDynTFTBaseComponent);
begin

end;


function DynTFTComboBox_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTComboBox;
begin
  Result := PDynTFTComboBox(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTComboBox was not registered. Please call RegisterComboBoxEvents before creating a PDynTFTComboBox. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;   //Allow events to be processed by subcomponents.
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, False, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Edit := DynTFTEdit_Create(ScreenIndex, Left, Top, Width - Height, Height);
  Result^.ListBox := DynTFTListBox_Create(ScreenIndex, Left, Top + Height + 1, Width, 100);    //all these dimensions and positions can be changed by user
  Result^.ArrowButton := DynTFTArrowButton_Create(ScreenIndex, Left + Width - Height + 1, Top + 1, Height - 1, Height - 1);
  Result^.ExteriorLabel := DynTFTLabel_Create(ScreenIndex, 0, 0, 32767, 32767);     //bigger than any screen

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      Result^.Edit^.BaseProps.Name := 'cmb.Edit';
      Result^.ListBox^.BaseProps.Name := 'cmb.ListBox';
      Result^.ArrowButton^.BaseProps.Name := 'cmb.ArrowButton';
      Result^.ExteriorLabel^.BaseProps.Name := 'cmb.ExteriorLabel';
    {$ENDIF}
  {$ENDIF}

  Result^.ArrowButton^.ArrowDir := CDownArrow;

  {$IFDEF IsDesktop}
    New(Result^.OnComboBoxCloseUp);
  {$ENDIF}
  
  Result^.Edit^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.ListBox^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.ArrowButton^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.ExteriorLabel^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF IsDesktop}
    //Result^.Edit^.OnOwnerInternalMouseDown^ := nil; //TDynTFTComboBox_OnDynTFTChildEditInternalMouseDown;
    //Result^.Edit^.OnOwnerInternalMouseMove^ := nil; //TDynTFTComboBox_OnDynTFTChildEditInternalMouseMove;
    Result^.Edit^.OnOwnerInternalMouseUp^ := TDynTFTComboBox_OnDynTFTChildEditInternalMouseUp;
  {$ELSE}
    //Result^.Edit^.OnOwnerInternalMouseDown := nil; //@TDynTFTComboBox_OnDynTFTChildEditInternalMouseDown;
    //Result^.Edit^.OnOwnerInternalMouseMove := nil; //@TDynTFTComboBox_OnDynTFTChildEditInternalMouseMove;
    Result^.Edit^.OnOwnerInternalMouseUp := @TDynTFTComboBox_OnDynTFTChildEditInternalMouseUp;
  {$ENDIF}

  {$IFDEF IsDesktop}
    //Result^.ListBox^.OnOwnerInternalMouseDown^ := nil; //TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseDown;
    //Result^.ListBox^.OnOwnerInternalMouseMove^ := nil; //TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseMove;
    Result^.ListBox^.OnOwnerInternalMouseUp^ := TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseUp;
    {$IFDEF MouseClickSupport}
      Result^.ListBox^.OnOwnerInternalClick^ := TDynTFTComboBox_OnDynTFTChildListBoxInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Result^.ListBox^.OnOwnerInternalDoubleClick^ := TDynTFTComboBox_OnDynTFTChildListBoxInternalDoubleClick;
    {$ENDIF}
  {$ELSE}
    //Result^.ListBox^.OnOwnerInternalMouseDown := nil; //@TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseDown;
    //Result^.ListBox^.OnOwnerInternalMouseMove := nil; //@TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseMove;
    Result^.ListBox^.OnOwnerInternalMouseUp := @TDynTFTComboBox_OnDynTFTChildListBoxInternalMouseUp;
    {$IFDEF MouseClickSupport}
      Result^.ListBox^.OnOwnerInternalClick := @TDynTFTComboBox_OnDynTFTChildListBoxInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Result^.ListBox^.OnOwnerInternalDoubleClick := @TDynTFTComboBox_OnDynTFTChildListBoxInternalDoubleClick;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    //Result^.ArrowButton^.OnOwnerInternalMouseDown^ := nil; //TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseDown;
    //Result^.ArrowButton^.OnOwnerInternalMouseMove^ := nil; //TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.ArrowButton^.OnOwnerInternalMouseUp^ := TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseUp;
  {$ELSE}
    //Result^.ArrowButton^.OnOwnerInternalMouseDown := nil; //@TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseDown;
    //Result^.ArrowButton^.OnOwnerInternalMouseMove := nil; //@TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.ArrowButton^.OnOwnerInternalMouseUp := @TDynTFTComboBox_OnDynTFTChildArrowButtonInternalMouseUp;
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.ExteriorLabel^.OnOwnerInternalMouseDown^ := TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseDown;
    //Result^.ExteriorLabel^.OnOwnerInternalMouseMove^ := nil; //TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseMove;
    //Result^.ExteriorLabel^.OnOwnerInternalMouseUp^ := nil; //TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseUp;
  {$ELSE}
    Result^.ExteriorLabel^.OnOwnerInternalMouseDown := @TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseDown;
    //Result^.ExteriorLabel^.OnOwnerInternalMouseMove := nil; //@TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseMove;
    //Result^.ExteriorLabel^.OnOwnerInternalMouseUp := nil; //@TDynTFTComboBox_OnDynTFTChildExteriorLabelInternalMouseUp;
  {$ENDIF}

  Result^.DroppedDown := False;
  Result^.Editable := True;

  Result^.Edit^.BaseProps.Visible := CVISIBLE;
  Result^.ListBox^.BaseProps.Visible := CHIDDEN;
  Result^.ListBox^.Items^.BaseProps.Visible := CHIDDEN;
  Result^.ListBox^.VertScrollBar^.BaseProps.Visible := CHIDDEN;
  Result^.ArrowButton^.BaseProps.Visible := CVISIBLE;
  Result^.ExteriorLabel^.BaseProps.Visible := CHIDDEN;
  Result^.ExteriorLabel^.Color := -1;

  {$IFDEF IsDesktop}
    Result^.OnComboBoxCloseUp^ := nil;
  {$ELSE}
    Result^.OnComboBoxCloseUp := nil;
  {$ENDIF}
end;


function DynTFTComboBox_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTComboBox_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTComboBox_Destroy(var AComboBox: PDynTFTComboBox);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AComboBox^.OnComboBoxCloseUp);
    AComboBox^.OnComboBoxCloseUp := nil;
  {$ENDIF}

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      AComboBox^.Edit^.BaseProps.Name := AComboBox^.BaseProps.Name + '.Edit';
      AComboBox^.ListBox^.BaseProps.Name := AComboBox^.BaseProps.Name + '.ListBox';
      AComboBox^.ArrowButton^.BaseProps.Name := AComboBox^.BaseProps.Name + '.ArrowButton';
      AComboBox^.ExteriorLabel^.BaseProps.Name := AComboBox^.BaseProps.Name + '.ExteriorLabel';
    {$ENDIF}
  {$ENDIF}

  DynTFTEdit_Destroy(AComboBox^.Edit);
  DynTFTListBox_Destroy(AComboBox^.ListBox);
  DynTFTArrowButton_Destroy(AComboBox^.ArrowButton);
  DynTFTLabel_Destroy(AComboBox^.ExteriorLabel);
  
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AComboBox)), SizeOf(AComboBox^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"

    ATemp := PDynTFTBaseComponent(TPtrRec(AComboBox));
    DynTFTComponent_Destroy(ATemp, SizeOf(AComboBox^));
    AComboBox := PDynTFTComboBox(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTComboBox_DestroyAndPaint(var AComboBox: PDynTFTComboBox);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AComboBox)));
  DynTFTComboBox_Destroy(AComboBox);
end;


procedure DynTFTComboBox_BaseDestroyAndPaint(var AComboBox: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTComboBox;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTComboBox_DestroyAndPaint(PDynTFTComboBox(TPtrRec(AComboBox)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTComboBox(TPtrRec(AComboBox));
    DynTFTComboBox_DestroyAndPaint(ATemp);
    AComboBox := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTComboBox_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  (*  implement these if ComboBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
  *)
end;


procedure TDynTFTComboBox_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  (*  implement these if ComboBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
  *)
end;


procedure TDynTFTComboBox_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  (*  implement these if ComboBox can be part of a more complex component
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
  *)
end;


{$IFDEF MouseClickSupport}
  procedure TDynTFTComboBox_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    (*  implement these if ComboBox can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
    *)
  end;
{$ENDIF}


{$IFDEF MouseDoubleClickSupport}
  procedure TDynTFTComboBox_OnDynTFTBaseInternalDoubleClick(ABase: PDynTFTBaseComponent);
  begin
    (*  implement these if ComboBox can be part of a more complex component
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick) then
        if Assigned(PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^) then
    {$ELSE}
      if PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick <> nil then
    {$ENDIF}
        PDynTFTComboBox(TPtrRec(ABase))^.OnOwnerInternalDoubleClick^(ABase);
    *)
  end;
{$ENDIF}


procedure TDynTFTComboBox_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
{var
  AComboBox: PDynTFTComboBox;}
begin
  if Options = CREPAINTONMOUSEUP then
  begin
    {AComboBox := PDynTFTComboBox(TPtrRec(ABase));
    SetEditReadonlyState(AComboBox);

    AComboBox^.DroppedDown := False;

    HideComponent(PDynTFTBaseComponent(TPtrRec(AComboBox^.ListBox)));
    RepaintScreenComponentsFromArea(PDynTFTBaseComponent(TPtrRec(AComboBox^.ListBox)));
    AComboBox^.ExteriorLabel^.BaseProps.Visible := AComboBox^.ListBox^.BaseProps.Visible;
               }
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTComboBox(TPtrRec(ABase))^.Edit)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTComboBox(TPtrRec(ABase))^.ArrowButton)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTComboBox(TPtrRec(ABase))^.ListBox)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTComboBox(TPtrRec(ABase))^.Edit)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTComboBox(TPtrRec(ABase))^.ArrowButton)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTComboBox(TPtrRec(ABase))^.ListBox)));
    Exit;
  end;  
    
  DynTFTDrawComboBox(PDynTFTComboBox(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterComboBoxEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTComboBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTComboBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTComboBox_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTComboBox_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent^ := TDynTFTComboBox_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTComboBox_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTComboBox_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTComboBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTComboBox_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTComboBox_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTComboBox_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTComboBox_OnDynTFTBaseInternalClick;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent := @TDynTFTComboBox_OnDynTFTBaseInternalDoubleClick;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTComboBox_OnDynTFTBaseInternalRepaint;
    
    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTComboBox_Create;
      ABaseEventReg.CompDestroy := @DynTFTComboBox_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTComboBox); 
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
