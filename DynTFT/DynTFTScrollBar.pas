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

unit DynTFTScrollBar;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTArrowButton

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  CScrollBarHorizDir = 0;
  CScrollBarVertDir = 1;
  CScrollBarArrBtnWidthHeight = 20; //pixels
  CScrollBarArrBtnWidthHeightDbl = CScrollBarArrBtnWidthHeight * 2;
  CScrollBarArrBtnWidthHeightTrpl = CScrollBarArrBtnWidthHeight * 3;

type
  TOnScrollBarChangeEvent = procedure(AComp: PPtrRec);
  POnScrollBarChangeEvent = ^TOnScrollBarChangeEvent;

  TOnOwnerInternalAdjustScrollBar = procedure(AScrollBar: PDynTFTBaseComponent);
  POnOwnerInternalAdjustScrollBar = ^TOnOwnerInternalAdjustScrollBar;

  TDynTFTScrollBar = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //ScrollBar properties
    BtnInc, BtnDec: PDynTFTArrowButton;
    BtnScroll: PDynTFTArrowButton; 
    Min, Max, Position, OldPosition: LongInt;
    Direction: Byte; //0 = horizontal, 1 = vertical
    PnlDragging: Byte; //dragging (internal state) 0 = not dragging, 1 = dragging
    
    {$IFNDEF AppArch16}
      Dummy: Word; //keep alignment to 4 bytes
    {$ENDIF}

    //these events are set by an owner component, e.g. a list box, and called by scrollbar
    OnOwnerInternalMouseDown: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseMove: PDynTFTGenericEventHandler;
    OnOwnerInternalMouseUp: PDynTFTGenericEventHandler;
    {$IFDEF MouseClickSupport}
      //OnOwnerInternalClick: PDynTFTGenericEventHandler; //Uncomment if really needed.   Also, see further in code, to uncomment.
    {$ENDIF}
    OnOwnerInternalAdjustScrollBar: POnOwnerInternalAdjustScrollBar;
    OnOwnerInternalAfterAdjustScrollBar: POnOwnerInternalAdjustScrollBar;
    
    OnScrollBarChange: POnScrollBarChangeEvent;
  end;
  PDynTFTScrollBar = ^TDynTFTScrollBar;

procedure DynTFTDrawScrollBar(AScrollBar: PDynTFTScrollBar; FullRedraw: Boolean);
procedure DynTFTDrawScrollBarWithButtons(AScrollBar: PDynTFTScrollBar; FullRedraw, RedrawButtons: Boolean);
function DynTFTScrollBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; ScrDir: Byte): PDynTFTScrollBar;
function DynTFTScrollBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTScrollBar;
procedure DynTFTScrollBar_Destroy(var AScrollBar: PDynTFTScrollBar);
procedure DynTFTScrollBar_DestroyAndPaint(var AScrollBar: PDynTFTScrollBar);
                                                                            
procedure DynTFTUpdateScrollbarEventHandlers(AScrBar: PDynTFTScrollBar);
procedure DynTFTEnableScrollBar(AScrollBar: PDynTFTScrollBar);
procedure DynTFTDisableScrollBar(AScrollBar: PDynTFTScrollBar);
function ConstrainPositionToBounds(AScrollBar: PDynTFTScrollBar): Boolean; //Returns True if Position is adjusted

procedure DynTFTRegisterScrollBarEvents;
function DynTFTGetScrollBarComponentType: TDynTFTComponentType;

implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetScrollBarComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


function ScrBarPosToPnlPos(ScrBar: PDynTFTScrollBar): Word;
var
  TotalPanelSpace: TSInt;
  TotalPositionSpace: LongInt;
begin
  if ScrBar^.Direction = CScrollBarHorizDir then
    TotalPanelSpace := ScrBar^.BaseProps.Width
  else
    TotalPanelSpace := ScrBar^.BaseProps.Height;

  TotalPanelSpace := TotalPanelSpace - CScrollBarArrBtnWidthHeightTrpl - 2;
  TotalPositionSpace := ScrBar^.Max - ScrBar^.Min;

  if TotalPositionSpace = 0 then
  begin
    Result := 1;
    Exit;
  end;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(TotalPanelSpace) * (ScrBar^.Position - ScrBar^.Min) / TotalPositionSpace);
  {$ELSE}
    Result := Word(Real(Real(LongInt(TotalPanelSpace)) * Real(ScrBar^.Position - ScrBar^.Min) / Real(TotalPositionSpace)));
  {$ENDIF}

  Result := Result + 1;  
end;


function PnlPosToScrBarPos(ScrBar: PDynTFTScrollBar; PnlPos: LongInt): LongInt;
var
  TotalPanelSpace: TSInt;
  TotalPositionSpace: LongInt;
begin
  if ScrBar^.Direction = CScrollBarHorizDir then
  begin
    TotalPanelSpace := ScrBar^.BaseProps.Width;
    PnlPos := PnlPos - ScrBar^.BaseProps.Left - CScrollBarArrBtnWidthHeight;
  end
  else
  begin
    TotalPanelSpace := ScrBar^.BaseProps.Height;
    PnlPos := PnlPos - ScrBar^.BaseProps.Top - CScrollBarArrBtnWidthHeight;
  end;

  TotalPanelSpace := TotalPanelSpace - CScrollBarArrBtnWidthHeightTrpl - 2;
  TotalPositionSpace := ScrBar^.Max - ScrBar^.Min;

  PnlPos := PnlPos - 1;

  {$IFDEF IsDesktop}
    Result := Round(LongInt(PnlPos) * TotalPositionSpace / LongInt(TotalPanelSpace));
  {$ELSE}
    Result := LongInt(Real(Real(LongInt(PnlPos)) * Real(TotalPositionSpace) / Real(LongInt(TotalPanelSpace))));
  {$ENDIF}

  Result := Result + ScrBar^.Min;
end;


procedure DynTFTDrawScrollBarWithButtons(AScrollBar: PDynTFTScrollBar; FullRedraw, RedrawButtons: Boolean);
var
  BkCol: TColor;
  x1, y1, x2, y2: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AScrollBar))) then
    Exit;

  x1 := AScrollBar^.BaseProps.Left;
  y1 := AScrollBar^.BaseProps.Top;
  x2 := x1 + AScrollBar^.BaseProps.Width;
  y2 := y1 + AScrollBar^.BaseProps.Height;

  if FullRedraw then        //commented for debug 2014.01.27
  begin
    if AScrollBar^.BaseProps.Enabled and CENABLED = CDISABLED then
      BkCol := CL_DynTFTScrollBar_DisabledBackground
    else
      BkCol := CL_DynTFTScrollBar_EnabledBackground;

    DynTFT_Set_Pen(BkCol, 1);
    DynTFT_Set_Brush(1, BkCol, 0, 0, 0, 0);

    if AScrollBar^.Direction = CScrollBarHorizDir then
    begin
      AScrollBar^.BtnInc^.BaseProps.Left := AScrollBar^.BaseProps.Left + AScrollBar^.BaseProps.Width - CScrollBarArrBtnWidthHeight;       //right button
      AScrollBar^.BtnInc^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnInc^.BaseProps.Width := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnInc^.BaseProps.Height := AScrollBar^.BaseProps.Height;
      AScrollBar^.BtnInc^.ArrowDir := CRightArrow;

      AScrollBar^.BtnDec^.BaseProps.Left := AScrollBar^.BaseProps.Left;                                //left button
      AScrollBar^.BtnDec^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnDec^.BaseProps.Width := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnDec^.BaseProps.Height := AScrollBar^.BaseProps.Height;
      AScrollBar^.BtnDec^.ArrowDir := CLeftArrow;

      AScrollBar^.BtnScroll^.BaseProps.Left := AScrollBar^.BaseProps.Left + CScrollBarArrBtnWidthHeight + ScrBarPosToPnlPos(AScrollBar);  //panel
      AScrollBar^.BtnScroll^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnScroll^.BaseProps.Width := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnScroll^.BaseProps.Height := AScrollBar^.BaseProps.Height;

      //DynTFT_Rectangle(x1 + CScrollBarArrBtnWidthHeight + 1, y1, x2 - CScrollBarArrBtnWidthHeight - 1, y2);
      DynTFT_Rectangle(x1 + CScrollBarArrBtnWidthHeight + 1, y1, AScrollBar^.BtnScroll^.BaseProps.Left, y2);
      DynTFT_Rectangle(AScrollBar^.BtnScroll^.BaseProps.Left + CScrollBarArrBtnWidthHeight + 1, y1, x2 - CScrollBarArrBtnWidthHeight - 1, y2);
    end
    else
    begin         
      AScrollBar^.BtnInc^.BaseProps.Left := AScrollBar^.BaseProps.Left;                                //down button
      AScrollBar^.BtnInc^.BaseProps.Top := AScrollBar^.BaseProps.Top + AScrollBar^.BaseProps.Height - CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnInc^.BaseProps.Width := AScrollBar^.BaseProps.Width;
      AScrollBar^.BtnInc^.BaseProps.Height := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnInc^.ArrowDir := CDownArrow;

      AScrollBar^.BtnDec^.BaseProps.Left := AScrollBar^.BaseProps.Left;       //up button
      AScrollBar^.BtnDec^.BaseProps.Top := AScrollBar^.BaseProps.Top;
      AScrollBar^.BtnDec^.BaseProps.Width := AScrollBar^.BaseProps.Width;
      AScrollBar^.BtnDec^.BaseProps.Height := CScrollBarArrBtnWidthHeight;
      AScrollBar^.BtnDec^.ArrowDir := CUpArrow;

      AScrollBar^.BtnScroll^.BaseProps.Left := AScrollBar^.BaseProps.Left;  //panel
      AScrollBar^.BtnScroll^.BaseProps.Top := AScrollBar^.BaseProps.Top + CScrollBarArrBtnWidthHeight + ScrBarPosToPnlPos(AScrollBar);
      AScrollBar^.BtnScroll^.BaseProps.Width := AScrollBar^.BaseProps.Width;
      AScrollBar^.BtnScroll^.BaseProps.Height := CScrollBarArrBtnWidthHeight;

      //DynTFT_Rectangle(x1, y1 + CScrollBarArrBtnWidthHeight + 1, x2, y2 - CScrollBarArrBtnWidthHeight - 1);
      DynTFT_Rectangle(x1, y1 + CScrollBarArrBtnWidthHeight + 1, x2, AScrollBar^.BtnScroll^.BaseProps.Top);
      DynTFT_Rectangle(x1, AScrollBar^.BtnScroll^.BaseProps.Top + CScrollBarArrBtnWidthHeight + 1, x2, y2 - CScrollBarArrBtnWidthHeight - 1);
    end;
  end;

  if RedrawButtons then
  begin
    DynTFTDrawArrowButton(AScrollBar^.BtnInc, FullRedraw);
    DynTFTDrawArrowButton(AScrollBar^.BtnDec, FullRedraw);
  end;

  if AScrollBar^.BtnScroll^.BaseProps.Visible > CHIDDEN then
    DynTFTDrawArrowButton(AScrollBar^.BtnScroll, True); //always full redraw
end;


procedure DynTFTDrawScrollBar(AScrollBar: PDynTFTScrollBar; FullRedraw: Boolean);
begin
  DynTFTDrawScrollBarWithButtons(AScrollBar, FullRedraw, FullRedraw);
end;


procedure DynTFTEnableScrollBar(AScrollBar: PDynTFTScrollBar);
begin
  AScrollBar^.BaseProps.Enabled := CENABLED;
  AScrollBar^.BtnScroll^.BaseProps.Enabled := CENABLED;
  AScrollBar^.BtnScroll^.Color := CL_DynTFTScrollBar_PanelBackground;
  AScrollBar^.BtnInc^.BaseProps.Enabled := CENABLED;
  AScrollBar^.BtnDec^.BaseProps.Enabled := CENABLED;
  DynTFTDrawScrollBarWithButtons(AScrollBar, False, True);
end;


procedure DynTFTDisableScrollBar(AScrollBar: PDynTFTScrollBar);
begin
  AScrollBar^.BaseProps.Enabled := CDISABLED;
  AScrollBar^.BtnScroll^.BaseProps.Enabled := CDISABLED;
  AScrollBar^.BtnScroll^.Color := CL_DynTFTScrollBar_DisabledBackground;
  AScrollBar^.BtnInc^.BaseProps.Enabled := CDISABLED;
  AScrollBar^.BtnDec^.BaseProps.Enabled := CDISABLED;
  DynTFTDrawScrollBarWithButtons(AScrollBar, False, True);
end;


function ConstrainPositionToBounds(AScrollBar: PDynTFTScrollBar): Boolean;
begin
  Result := False;
  if AScrollBar^.Position < AScrollBar^.Min then
  begin
    AScrollBar^.Position := AScrollBar^.Min;
    Result := True;
  end;
    
  if (AScrollBar^.Position > AScrollBar^.Max) and (AScrollBar^.Min <= AScrollBar^.Max) then
  begin
    AScrollBar^.Position := AScrollBar^.Max;
    Result := True;
  end;
end;


procedure DynTFTUpdateScrollbarEventHandlers(AScrBar: PDynTFTScrollBar);
begin
  {$IFDEF IsDesktop}
    AScrBar^.BtnInc^.BaseProps.OnMouseDownUser^ := AScrBar^.BaseProps.OnMouseDownUser^;      // content := content, not pointer !!!
    AScrBar^.BtnInc^.BaseProps.OnMouseMoveUser^ := AScrBar^.BaseProps.OnMouseMoveUser^;
    AScrBar^.BtnInc^.BaseProps.OnMouseUpUser^ := AScrBar^.BaseProps.OnMouseUpUser^;
    {$IFDEF MouseClickSupport}
      AScrBar^.BtnInc^.BaseProps.OnClickUser^ := AScrBar^.BaseProps.OnClickUser^;
    {$ENDIF}

    AScrBar^.BtnDec^.BaseProps.OnMouseDownUser^ := AScrBar^.BaseProps.OnMouseDownUser^;
    AScrBar^.BtnDec^.BaseProps.OnMouseMoveUser^ := AScrBar^.BaseProps.OnMouseMoveUser^;
    AScrBar^.BtnDec^.BaseProps.OnMouseUpUser^ := AScrBar^.BaseProps.OnMouseUpUser^;
    {$IFDEF MouseClickSupport}
      AScrBar^.BtnDec^.BaseProps.OnClickUser^ := AScrBar^.BaseProps.OnClickUser^;
    {$ENDIF}

    AScrBar^.BtnScroll^.BaseProps.OnMouseDownUser^ := AScrBar^.BaseProps.OnMouseDownUser^;
    AScrBar^.BtnScroll^.BaseProps.OnMouseMoveUser^ := AScrBar^.BaseProps.OnMouseMoveUser^;
    AScrBar^.BtnScroll^.BaseProps.OnMouseUpUser^ := AScrBar^.BaseProps.OnMouseUpUser^;
  {$ELSE}
    AScrBar^.BtnInc^.BaseProps.OnMouseDownUser := AScrBar^.BaseProps.OnMouseDownUser;      // pointer := pointer, not content !!!
    AScrBar^.BtnInc^.BaseProps.OnMouseMoveUser := AScrBar^.BaseProps.OnMouseMoveUser;
    AScrBar^.BtnInc^.BaseProps.OnMouseUpUser := AScrBar^.BaseProps.OnMouseUpUser;
    {$IFDEF MouseClickSupport}
      AScrBar^.BtnInc^.BaseProps.OnClickUser := AScrBar^.BaseProps.OnClickUser;
    {$ENDIF}

    AScrBar^.BtnDec^.BaseProps.OnMouseDownUser := AScrBar^.BaseProps.OnMouseDownUser;
    AScrBar^.BtnDec^.BaseProps.OnMouseMoveUser := AScrBar^.BaseProps.OnMouseMoveUser;
    AScrBar^.BtnDec^.BaseProps.OnMouseUpUser := AScrBar^.BaseProps.OnMouseUpUser;
    {$IFDEF MouseClickSupport}
      AScrBar^.BtnDec^.BaseProps.OnClickUser := AScrBar^.BaseProps.OnClickUser;
    {$ENDIF}

    AScrBar^.BtnScroll^.BaseProps.OnMouseDownUser := AScrBar^.BaseProps.OnMouseDownUser;
    AScrBar^.BtnScroll^.BaseProps.OnMouseMoveUser := AScrBar^.BaseProps.OnMouseMoveUser;
    AScrBar^.BtnScroll^.BaseProps.OnMouseUpUser := AScrBar^.BaseProps.OnMouseUpUser;
  {$ENDIF}
end;


procedure TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent));
    AScrBar^.PnlDragging := 1;

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.OnOwnerInternalAdjustScrollBar) then
        if Assigned(AScrBar^.OnOwnerInternalAdjustScrollBar^) then
    {$ELSE}
      if AScrBar^.OnOwnerInternalAdjustScrollBar <> nil then
    {$ENDIF}
        AScrBar^.OnOwnerInternalAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(AScrBar)));

    DynTFTDragOffsetX := DynTFTMCU_XMouse - PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Left;
    DynTFTDragOffsetY := DynTFTMCU_YMouse - PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Top;

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.OnOwnerInternalAfterAdjustScrollBar) then
        if Assigned(AScrBar^.OnOwnerInternalAfterAdjustScrollBar^) then
    {$ELSE}
      if AScrBar^.OnOwnerInternalAfterAdjustScrollBar <> nil then
    {$ENDIF}
        AScrBar^.OnOwnerInternalAfterAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(AScrBar)));

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.BaseProps.OnMouseDownUser) then
        if Assigned(AScrBar^.BaseProps.OnMouseDownUser^) then
    {$ELSE}
      if AScrBar^.BaseProps.OnMouseDownUser <> nil then
    {$ENDIF}
        AScrBar^.BaseProps.OnMouseDownUser^(PPtrRec(TPtrRec(AScrBar)));    
  end
  else
    DynTFTDrawArrowButton(PDynTFTArrowButton(TPtrRec(ABase)), False);  //line added 2017.11.30  (to repaint the panel on focus change)
end;


procedure TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseMove(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent));

    ///
    ///  DragOffsetX := IsMCU_XMouse - PDynTFTPanel(TPtrRec(ABase))^.Left;
    ///  DragOffsetY := IsMCU_YMouse - PDynTFTPanel(TPtrRec(ABase))^.Top;

    //PDynTFTPanel(TPtrRec(ABase))^.Left := PIC_XMouse - DragOffsetX;
    //PDynTFTPanel(TPtrRec(ABase))^.Top := PIC_YMouse - DragOffsetY;

    if AScrBar^.PnlDragging = 1 then
    begin
      if AScrBar^.Direction = CScrollBarHorizDir then
        AScrBar^.Position := PnlPosToScrBarPos(AScrBar, DynTFTMCU_XMouse - DynTFTDragOffsetX)
      else
        AScrBar^.Position := PnlPosToScrBarPos(AScrBar, DynTFTMCU_YMouse - DynTFTDragOffsetY);

      {$IFDEF IsDesktop}
        //DebugText(IntToStr(IsMCU_XMouse) + ' : ' + IntToStr(IsMCU_YMouse) + '   Position = ' + IntToStr(AScrBar^.Position) + '   diff = ' + IntToStr(IsMCU_XMouse - DragOffsetX));
      {$ENDIF}

      if AScrBar^.Position > AScrBar^.Max then
        AScrBar^.Position := AScrBar^.Max;

      if AScrBar^.Position < AScrBar^.Min then
        AScrBar^.Position := AScrBar^.Min;

      if AScrBar^.Position <> AScrBar^.OldPosition then
      begin
        AScrBar^.OldPosition := AScrBar^.Position;

        DynTFTDrawScrollBarWithButtons(AScrBar, True, False); ///draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnScrollBarChange) then
            if Assigned(AScrBar^.OnScrollBarChange^) then
        {$ELSE}
          if AScrBar^.OnScrollBarChange <> nil then
        {$ENDIF}
            AScrBar^.OnScrollBarChange^(PPtrRec(TPtrRec(AScrBar)));


        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnOwnerInternalMouseMove) then
            if Assigned(AScrBar^.OnOwnerInternalMouseMove^) then
        {$ELSE}
          if AScrBar^.OnOwnerInternalMouseMove <> nil then
        {$ENDIF}
            AScrBar^.OnOwnerInternalMouseMove^(PDynTFTBaseComponent(TPtrRec(AScrBar)));
      end;
    end; //dragging

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.BaseProps.OnMouseMoveUser) then
        if Assigned(AScrBar^.BaseProps.OnMouseMoveUser^) then
    {$ELSE}
      if AScrBar^.BaseProps.OnMouseMoveUser <> nil then
    {$ENDIF}
        AScrBar^.BaseProps.OnMouseMoveUser^(PPtrRec(TPtrRec(AScrBar)));    

    //DrawPanel(PDynTFTPanel(TPtrRec(ABase)), True);  //for debug only
  end;
end;


procedure TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseUp(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent));
    AScrBar^.PnlDragging := 0;

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.BaseProps.OnMouseUpUser) then
        if Assigned(AScrBar^.BaseProps.OnMouseUpUser^) then
    {$ELSE}
      if AScrBar^.BaseProps.OnMouseUpUser <> nil then
    {$ENDIF}
        AScrBar^.BaseProps.OnMouseUpUser^(PPtrRec(TPtrRec(AScrBar)));
  end;
end;


procedure TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown(ABase: PDynTFTBaseComponent);
var
  AScrBar: PDynTFTScrollBar;
begin
  if PDynTFTBaseComponent(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent))^.BaseProps.ComponentType = ComponentType then
  begin
    AScrBar := PDynTFTScrollBar(TPtrRec(PDynTFTArrowButton(TPtrRec(ABase))^.BaseProps.Parent));

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.OnOwnerInternalAdjustScrollBar) then
        if Assigned(AScrBar^.OnOwnerInternalAdjustScrollBar^) then
    {$ELSE}
      if AScrBar^.OnOwnerInternalAdjustScrollBar <> nil then
    {$ENDIF}
        AScrBar^.OnOwnerInternalAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(AScrBar)));

    //These two "if"-s are identical for the two types of scrollbars H / V.
    if PDynTFTArrowButton(TPtrRec(ABase)) = AScrBar^.BtnInc then
    begin
      Inc(AScrBar^.Position);
      if AScrBar^.Position > AScrBar^.Max then
        AScrBar^.Position := AScrBar^.Max
      else
      begin
        DynTFTDrawScrollBarWithButtons(AScrBar, True, False); //draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnScrollBarChange) then
            if Assigned(AScrBar^.OnScrollBarChange^) then
        {$ELSE}
          if AScrBar^.OnScrollBarChange <> nil then
        {$ENDIF}  
            AScrBar^.OnScrollBarChange^(PPtrRec(TPtrRec(AScrBar)));
      end;
    end;

    if PDynTFTArrowButton(TPtrRec(ABase)) = AScrBar^.BtnDec then
    begin
      Dec(AScrBar^.Position);
      if AScrBar^.Position < AScrBar^.Min then
        AScrBar^.Position := AScrBar^.Min
      else
      begin
        DynTFTDrawScrollBarWithButtons(AScrBar, True, False); //draw only if changed
        {$IFDEF IsDesktop}
          if Assigned(AScrBar^.OnScrollBarChange) then
            if Assigned(AScrBar^.OnScrollBarChange^) then
        {$ELSE}
          if AScrBar^.OnScrollBarChange <> nil then
        {$ENDIF} 
          AScrBar^.OnScrollBarChange^(PPtrRec(TPtrRec(AScrBar)));        
      end;
    end;

    {$IFDEF IsDesktop}
      if Assigned(AScrBar^.OnOwnerInternalAfterAdjustScrollBar) then
        if Assigned(AScrBar^.OnOwnerInternalAfterAdjustScrollBar^) then
    {$ELSE}
      if AScrBar^.OnOwnerInternalAfterAdjustScrollBar <> nil then
    {$ENDIF}
        AScrBar^.OnOwnerInternalAfterAdjustScrollBar^(PDynTFTBaseComponent(TPtrRec(AScrBar)));
  end; //if is scroll bar
end;


procedure TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
                                                                                 
end;


procedure TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp(ABase: PDynTFTBaseComponent);
begin

end;


function DynTFTScrollBar_CreateWithDir(ScreenIndex: Byte; Left, Top, Width, Height: TSInt; ScrDir: Byte): PDynTFTScrollBar;
begin
  Result := PDynTFTScrollBar(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTScrollBar was not registered. Please call RegisterScrollBarEvents before creating a PDynTFTScrollBar. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := False;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  //DynTFTInitComponentDimensions(PDynTFTBaseComponent(TPtrRec(Result)), ComponentType, False, Left, Top, Width, Height);
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Direction := ScrDir;
  Result^.PnlDragging := 0; //not dragging

  Result^.BtnInc := DynTFTArrowButton_Create(ScreenIndex, 500, 280, 0, 0);   //Button dimensions are set to 0, to avoid drawing until properly positioned.
  Result^.BtnDec := DynTFTArrowButton_Create(ScreenIndex, 500, 280, 0, 0);
  Result^.BtnScroll := DynTFTArrowButton_Create(ScreenIndex, 500, 280, 0, 0);
  Result^.BtnScroll^.Color := CL_DynTFTScrollBar_PanelBackground;
  Result^.BtnScroll^.ArrowDir := CNoArrow;
  Result^.BtnScroll^.BaseProps.CompState := CDISABLEPRESSING;

  {$IFDEF IsDesktop}
    New(Result^.OnOwnerInternalMouseDown);
    New(Result^.OnOwnerInternalMouseMove);
    New(Result^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      //New(Result^.OnOwnerInternalClick);
    {$ENDIF}
    New(Result^.OnScrollBarChange);
    New(Result^.OnOwnerInternalAdjustScrollBar);
    New(Result^.OnOwnerInternalAfterAdjustScrollBar);
  {$ENDIF}

  Result^.BtnInc^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.BtnDec^.BaseProps.Parent := PPtrRec(TPtrRec(Result));
  Result^.BtnScroll^.BaseProps.Parent := PPtrRec(TPtrRec(Result));

  {$IFDEF IsDesktop}
    Result^.BtnInc^.OnOwnerInternalMouseDown^ := TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnInc^.OnOwnerInternalMouseMove^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnInc^.OnOwnerInternalMouseUp^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //user event is used
    {$ENDIF}
  {$ELSE}
    Result^.BtnInc^.OnOwnerInternalMouseDown := @TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnInc^.OnOwnerInternalMouseMove := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnInc^.OnOwnerInternalMouseUp := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //user event is used
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.BtnDec^.OnOwnerInternalMouseDown^ := TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnDec^.OnOwnerInternalMouseMove^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnDec^.OnOwnerInternalMouseUp^ := nil; //TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //user event is used
    {$ENDIF}
  {$ELSE}
    Result^.BtnDec^.OnOwnerInternalMouseDown := @TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseDown;
    Result^.BtnDec^.OnOwnerInternalMouseMove := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseMove;
    Result^.BtnDec^.OnOwnerInternalMouseUp := nil; //@TDynTFTScrollBar_OnDynTFTChildArrowButtonInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //user event is used
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    Result^.BtnScroll^.OnOwnerInternalMouseDown^ := TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseDown;
    Result^.BtnScroll^.OnOwnerInternalMouseMove^ := TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseMove;
    Result^.BtnScroll^.OnOwnerInternalMouseUp^ := TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseUp;
  {$ELSE}
    Result^.BtnScroll^.OnOwnerInternalMouseDown := @TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseDown;
    Result^.BtnScroll^.OnOwnerInternalMouseMove := @TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseMove;
    Result^.BtnScroll^.OnOwnerInternalMouseUp := @TDynTFTScrollBar_OnDynTFTChildPanelInternalMouseUp;
  {$ENDIF}

  Result^.Min := 0;
  Result^.Max := 10;
  Result^.Position := 0;
  Result^.OldPosition := -1;

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      Result^.BtnInc^.BaseProps.Name := 'scrbar.BtnInc';
      Result^.BtnDec^.BaseProps.Name := 'scrbar.BtnDec';
      Result^.BtnScroll^.BaseProps.Name := 'scrbar.BtnScroll';
    {$ENDIF}
  {$ENDIF}
                                              
  //these event handlers will be set by a listbox if the scrollbar belongs to that listbox:
  {$IFDEF IsDesktop}
    Result^.OnOwnerInternalMouseDown^ := nil;
    Result^.OnOwnerInternalMouseMove^ := nil;
    Result^.OnOwnerInternalMouseUp^ := nil;
    {$IFDEF MouseClickSupport}
      //Result^.OnOwnerInternalClick^ := nil;
    {$ENDIF}
    Result^.OnScrollBarChange^ := nil;
    Result^.OnOwnerInternalAdjustScrollBar^ := nil;
    Result^.OnOwnerInternalAfterAdjustScrollBar^ := nil;
  {$ELSE}
    Result^.OnOwnerInternalMouseDown := nil;
    Result^.OnOwnerInternalMouseMove := nil;
    Result^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      //Result^.OnOwnerInternalClick := nil;
    {$ENDIF}
    Result^.OnScrollBarChange := nil;
    Result^.OnOwnerInternalAdjustScrollBar := nil;
    Result^.OnOwnerInternalAfterAdjustScrollBar := nil;
  {$ENDIF}

  DynTFTUpdateScrollbarEventHandlers(Result);

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
        {DynTFT_DebugConsole('--- Allocating user event handlers of scroll bar $' + IntToHex(TPTr(Result), 8) +
                            '  Addr(Down) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseDown), 8) +
                            '  Addr(Move) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseMove), 8) +
                            '  Addr(Up) = $' + IntToHex(TPTr(Result^.OnOwnerInternalMouseUp), 8) +
                            '  Addr(Change) = $' + IntToHex(TPTr(Result^.OnScrollBarChange), 8) +
                            '  Addr(Adjust) = $' + IntToHex(TPTr(Result^.OnOwnerInternalAdjustScrollBar), 8) +
                            '  Addr(AfterAdjust) = $' + IntToHex(TPTr(Result^.OnOwnerInternalAfterAdjustScrollBar), 8)
                            );}
    {$ENDIF}
  {$ENDIF}
end;


function DynTFTScrollBar_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTScrollBar;
begin
  Result := DynTFTScrollBar_CreateWithDir(ScreenIndex, Left, Top, Width, Height, CScrollBarHorizDir);
end;


function DynTFTScrollBar_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTScrollBar_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTScrollBar_Destroy(var AScrollBar: PDynTFTScrollBar);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      AScrollBar^.BtnInc^.BaseProps.Name := AScrollBar^.BaseProps.Name + '.BtnInc';
      AScrollBar^.BtnDec^.BaseProps.Name := AScrollBar^.BaseProps.Name + '.BtnDec';
      AScrollBar^.BtnScroll^.BaseProps.Name := AScrollBar^.BaseProps.Name + '.BtnScroll';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF ComponentsHaveName}
    {$IFDEF IsDesktop}
      {DynTFT_DebugConsole('/// Disposing internal event handlers of scroll bar: ' + AScrollBar^.BaseProps.Name +
                          '  Addr(Down) = $' + IntToHex(TPTr(AScrollBar^.OnOwnerInternalMouseDown), 8) +
                          '  Addr(Move) = $' + IntToHex(TPTr(AScrollBar^.OnOwnerInternalMouseMove), 8) +
                          '  Addr(Up) = $' + IntToHex(TPTr(AScrollBar^.OnOwnerInternalMouseUp), 8) +
                          '  Addr(Change) = $' + IntToHex(TPTr(AScrollBar^.OnScrollBarChange), 8) +
                          '  Addr(Adjust) = $' + IntToHex(TPTr(AScrollBar^.OnOwnerInternalAdjustScrollBar), 8) +
                          '  Addr(AfterAdjust) = $' + IntToHex(TPTr(AScrollBar^.OnOwnerInternalAfterAdjustScrollBar), 8)
                          );}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF IsDesktop}
    Dispose(AScrollBar^.OnOwnerInternalMouseDown);
    Dispose(AScrollBar^.OnOwnerInternalMouseMove);
    Dispose(AScrollBar^.OnOwnerInternalMouseUp);
    {$IFDEF MouseClickSupport}
      //Dispose(AScrollBar^.OnOwnerInternalClick);
    {$ENDIF}
    Dispose(AScrollBar^.OnScrollBarChange);
    Dispose(AScrollBar^.OnOwnerInternalAdjustScrollBar);
    Dispose(AScrollBar^.OnOwnerInternalAfterAdjustScrollBar);

    AScrollBar^.OnOwnerInternalMouseDown := nil;
    AScrollBar^.OnOwnerInternalMouseMove := nil;
    AScrollBar^.OnOwnerInternalMouseUp := nil;
    {$IFDEF MouseClickSupport}
      //AScrollBar^.OnOwnerInternalClick := nil;
    {$ENDIF}
    AScrollBar^.OnScrollBarChange := nil;
    AScrollBar^.OnOwnerInternalAdjustScrollBar := nil;
    AScrollBar^.OnOwnerInternalAfterAdjustScrollBar := nil;
  {$ENDIF}

  DynTFTArrowButton_Destroy(AScrollBar^.BtnInc);
  DynTFTArrowButton_Destroy(AScrollBar^.BtnDec);
  DynTFTArrowButton_Destroy(AScrollBar^.BtnScroll);

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AScrollBar)), SizeOf(AScrollBar^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AScrollBar));
    DynTFTComponent_Destroy(ATemp, SizeOf(AScrollBar^));
    AScrollBar := PDynTFTScrollBar(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTScrollBar_DestroyAndPaint(var AScrollBar: PDynTFTScrollBar);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AScrollBar)));
  DynTFTScrollBar_Destroy(AScrollBar);
end;


procedure DynTFTScrollBar_BaseDestroyAndPaint(var AScrollBar: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTScrollBar;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTScrollBar_DestroyAndPaint(PDynTFTScrollBar(TPtrRec(AScrollBar)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTScrollBar(TPtrRec(AScrollBar));
    DynTFTScrollBar_DestroyAndPaint(ATemp);
    AScrollBar:= PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown) then
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^) then
  {$ELSE}
    if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown <> nil then
  {$ENDIF}
      PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseDown^(ABase);
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove) then
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^) then
  {$ELSE}
    if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove <> nil then
  {$ENDIF}
      PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseMove^(ABase);
end;


procedure TDynTFTScrollBar_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp) then
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^) then
  {$ELSE}
    if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp <> nil then
  {$ENDIF}
      PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalMouseUp^(ABase);
end;


{$IFDEF MouseClickSupport}
  (*
  procedure TDynTFTScrollBar_OnDynTFTBaseInternalClick(ABase: PDynTFTBaseComponent);
  begin
    {$IFDEF IsDesktop}
      if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalClick) then
        if Assigned(PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalClick^) then
    {$ELSE}
      if PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalClick <> nil then
    {$ENDIF}
        PDynTFTScrollBar(TPtrRec(ABase))^.OnOwnerInternalClick^(ABase);
  end;
  *)
{$ENDIF}


procedure TDynTFTScrollBar_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CAFTERENABLEREPAINT then
  begin
    DynTFTEnableScrollBar(PDynTFTScrollBar(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CAFTERDISABLEREPAINT then
  begin
    DynTFTDisableScrollBar(PDynTFTScrollBar(TPtrRec(ABase)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnInc)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnDec)));
    DynTFTHideComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnScroll)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnInc)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnDec)));
    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(PDynTFTScrollBar(TPtrRec(ABase))^.BtnScroll)));
    Exit;
  end;

  DynTFTDrawScrollBarWithButtons(PDynTFTScrollBar(TPtrRec(ABase)), FullRepaint, FullRepaint);
end;
                               

procedure DynTFTRegisterScrollBarEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := TDynTFTScrollBar_OnDynTFTBaseInternalClick; //uncomment if needed
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTScrollBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTScrollBar_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTScrollBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalMouseDown;
    ABaseEventReg.MouseMoveEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalMouseUp;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := @TDynTFTScrollBar_OnDynTFTBaseInternalClick; //uncomment if needed
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTScrollBar_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTScrollBar_Create;
      ABaseEventReg.CompDestroy := @DynTFTScrollBar_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTScrollBar); 
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
