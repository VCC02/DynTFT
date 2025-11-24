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

unit DynTFTBaseDrawing;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

{$IFNDEF UserTFTCommands}  //this can be a project-level definition
  {$DEFINE mikroTFT}
{$ENDIF}

uses
  DynTFTTypes, DynTFTConsts,
  {$IFDEF IsDesktop}
    SysUtils,
  {$ENDIF}

  {$IFDEF UseSmallMM}
    DynTFTSmallMM,
  {$ELSE}
    {$IFDEF IsDesktop}
      MemManager,
    {$ENDIF}
  {$ENDIF}

  {$IFDEF mikroTFT}
    {$IFDEF IsDesktop}
      TFT,
    {$ENDIF}  
  {$ELSE}
    {$INCLUDE UserDrawingUnits.inc}
    ,
  {$ENDIF}

  DynTFTUtils;

  
{$IFDEF IsDesktop}
  procedure DynTFTInitBaseHandlersAndProperties(ABase: PDynTFTBaseComponent);
  procedure DynTFTFreeBaseHandlersAndProperties(ABase: PDynTFTBaseComponent);
{$ENDIF}

procedure DynTFTInitBaseHandlersToNil(ABase: PDynTFTBaseComponent);
procedure DynTFTInitBasicStatePropertiesToDefault(AComp: PDynTFTBaseComponent);
//procedure DynTFTInitComponentDimensions(AComp: PDynTFTBaseComponent; AComponentType: TDynTFTComponentType; ACanHandleMessages: Boolean; Left, Top, Width, Height: TSInt);

function DynTFTComponent_Create(ScreenIndex: Byte; SizeOfComponent: TPtr): PDynTFTBaseComponent;
procedure DynTFTComponent_Destroy(var AComp: PDynTFTBaseComponent; SizeOfComponent: TPtr);
procedure DynTFTComponent_DestroyMultiple(var AFirstComp, ALastComp: PDynTFTBaseComponent; SizeOfComponent: TPtr); //pass nil to ALastComp to destroy only a single component, i.e. AFirstComp. This is what DynTFTComponent_Destroy does.


{$IFDEF RTTIREG}
  //Generic "constructor" and "destructor", which use the registered component type information to obtain component size.
  //Different component types can be created and destroyed using these.

  function DynTFTComponent_CreateFromReg(AComponentType: TDynTFTComponentType; ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
  procedure DynTFTComponent_DestroyFromReg(var AComp: PDynTFTBaseComponent);
  procedure ExecuteRTTIInstructions(ABinaryComponentsData: PDWordArray; AllCreatedComponents: PAllCreatedDynTFTComponents; HandlerAddresses: PTPtrArray; Filter: Byte; GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF});
{$ENDIF}


procedure DynTFTComponent_BringMultipleComponentsToFront(AFirstComp, ALastComp: PDynTFTBaseComponent);   //pass nil to ALastComp to move only a single component, i.e. AFirstComp

procedure DynTFTAllocateInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
{$IFDEF IsDesktop}
  procedure DynTFTDisposeInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
{$ENDIF}

procedure DynTFTInitComponentTypeRegistration; //must be called before initializing component base owners (screens)
procedure DynTFTFreeComponentTypeRegistration;


function DynTFTSetComponentTypeInRegistry(ABaseEventReg: PDynTFTBaseEventReg; Index: Integer): Integer; //use this only if you can reuse elements of the RegisteredComponents array (component type registry) and want to keep its size limited. All component of the reused type (index) must be destroyed before registering a new component (at the same index).
function DynTFTRegisterComponentType(ABaseEventReg: PDynTFTBaseEventReg): Integer;  //returns > -1 for success
function DynTFTComponentsAreRegistered: Boolean;
procedure DynTFTClearComponentRegistration;

procedure DynTFTClearComponentArea(ComponentFromArea: PDynTFTBaseComponent; AColor: TColor);
procedure DynTFTClearComponentAreaWithScreenColor(ComponentFromArea: PDynTFTBaseComponent);
procedure DynTFTRepaintScreenComponentsFromArea(ComponentFromArea: PDynTFTBaseComponent);

procedure DynTFTInitComponentContainers;
procedure DynTFTInitInputDevStateFlags;

function DynTFTPointOverComponent(AComp: PDynTFTBaseComponent; X, Y: Integer): Boolean;
function DynTFTMouseOverComponent(AComp: PDynTFTBaseComponent): Boolean;
function DynTFTIsDrawableComponent(AComp: PDynTFTBaseComponent): Boolean;

procedure OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
procedure DynTFTBlinkCaretsForScreenComponents(ScreenIndex: Byte);
procedure DynTFTProcessComponentVisualState(ScreenIndex: Byte);

procedure DynTFTRepaintScreenComponents(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);
procedure DynTFTRepaintScreen(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);


procedure DynTFTShowComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTHideComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTShowComponentWithDelay(AComp: PDynTFTBaseComponent);
procedure DynTFTHideComponentWithDelay(AComp: PDynTFTBaseComponent);
procedure DynTFTEnableComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTDisableComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTFocusComponent(AComp: PDynTFTBaseComponent);
procedure DynTFTUnfocusComponent(AComp: PDynTFTBaseComponent);

function DynTFTGetComponentContainerComponentType: TDynTFTComponentType;

function DynTFTPositiveLimit(ANumber: LongInt): LongInt; //returns 0 for negative "ANumber", and returns "ANumber" for positive "ANumber"
function DynTFTOrdBoolWord(ABool: Boolean): Word;

procedure DynTFTChangeComponentPosition(AComp: PDynTFTBaseComponent; NewLeft, NewTop: TSInt);

procedure DynTFTDisplayErrorMessage({$IFDEF IsMCU}var{$ENDIF} AMessage: string; TextColor: DWord);


{$IFDEF IsDesktop}
  procedure DynTFTDisplayErrorOnStringConstLength(AStringConstLength: Integer; ComponentDataTypeName: string);
{$ENDIF}

const
  //Component state constants (defined here, not in DynTFTConsts.pas)

  CNORMALREPAINT = $0000; //this should simply repaint the component
  CREPAINTONSTARTUP = $0001; //some components cancel the repaint process if calling Repaint with this option
  CCLEARAREAREPAINT = $0002; //use this to make the component clear an area after hiding a subcomponent from that area
  CAFTERENABLEREPAINT = $0003; //use this to make the component set additional internal state on repaint
  CAFTERDISABLEREPAINT = $0004; //use this to make the component set additional internal state on repaint
  CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT = $0005; //subcomponents might be repainted on losing focus, so use this to set them to invisible
  CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT = $0006; //call repaint with this constant, to set subcomponents to visible before calling normal repaint
  CREPAINTONMOUSEUP = $FFFF; //some components cancel the repaint process if calling Repaint with this option


  //Visible property
  CHIDDEN = 0;
  CVISIBLE = 1;
  CWILLHIDE = 2;
  CWILLSHOW = 4;
  CWILLHIDELATER = 8;  //one full list traversal delay
  CWILLSHOWLATER = 16; //one full list traversal delay

  //Enabled property
  CDISABLED = 0;
  CENABLED = 1;
  CWILLDISABLE = 2;
  CWILLENABLE = 4;

  //CompState property
  CRELEASED = 0;
  CPRESSED = 1;
  CCHANGEDNOTIFY = 2;  //reserved
  CDISABLEPRESSING = 4;

  //Focused property
  CUNFOCUSED = 0;
  CFOCUSED = 1;
  CWILLFOCUS = 2;
  CWILLUNFOCUS = 4;
  CPAINTAFTERFOCUS = 8;
  CWILLDESTROY = 64; //$40
  CREJECTFOCUS = 128; //$80

  {$IFDEF IsDesktop}
    COUTOFMEMORYMESSAGE = 'Out of dynamic memory. If possible, please increase memory size from HEAP_SIZE constant in MemManager.';
  {$ENDIF}

  COUTOFMEMORYMESSAGE_MCU = 'Out of dynamic memory.';

  {$IFDEF RTTIREG}
    CHANDLERSARRAYNOTSET = 'Handlers array not set';                    //Display an error even on MCU, to detect a bad setting (or bug). This happens when the instruction is set to use handler indexes instead of addresses (bit "IsIndex" is 1), but there is no array of addresses to be indexed.  The "IsIndex" bit is usually set if no .lst file is provided when generating the instructions (either code or .dyntftui file).
    CRTTIFILEPOINTERNOTSETTOINSTRUCTION = 'RTTI file pointer not set';  //in case of this error, you have to use FAT32_Seek or a similar function to set the file pointer to the first instruction (usually in data provider callbacks)
    CRTTIDATAOUTOFDATE = 'Binary data out of date';                     //requires regeneration or dyntftui files from SDCard/USBDrive were not updated
    CRTTIBADINTEGERSIZE = 'Bad Int Size';                               //the profile setting for integer size does not match compiler / architecture integer size
    CRTTIBADIPOINTERSIZE = 'Bad Pointer Size';                          //the profile setting for pointer size does not match compiler / architecture pointer size
    CRTTIDATAPROVIDERREADERR = 'DataProv Read Err';                     //maybe FAT32 is not initialized, or file not found, or SDCard/USBDrive not found, or other read error  (used in data provider callbacks). It is also possible that, in DynTFTCodeGen (in Project settings), "Data provider callback" editboxes are set to some callback names and no external files are used (*.dyntftui).
  {$ENDIF}

  CDynTFTUnrecognizedInstructionError = $FFFFFFFF;
  CDynTFTHasVarInGUIObjects_BitMask = $40;
  CDynTFTCreatedAtStartup_BitMask = $20;
  CDynTFTIndexSecondDWordOnDestroy_BitMask = $80;
  CDynTFTPropertyIsIndex_BitMask = $80;
  CDynTFTPropertyIsString_BitMask = $80;

  CDynTFT_InstructionFilter_CreateStartupOnly_BitMask = $20;
  CDynTFT_InstructionFilter_CreateSingleGroup_BitMask = $40;
  CDynTFT_InstructionFilter_CreateAll_BitMask = $80;
  CDynTFT_InstructionFilter_GroupNumber_BitMask = $5F;  //$40 + $1F

  CRTTIInstruction_StopExecution = 0;  //executed as nop
  CRTTIInstruction_CreateComponent = 1;
  CRTTIInstruction_DestroyComponent = 2;
  CRTTIInstruction_SetProperty = 3;
  CRTTIInstruction_BuildVersion = 4; //Used to check if the build number of instructions array, match a constant in code. It stops execution on mismatch. Used for instructions generated based on lst files.
  CRTTIInstruction_Header = 5; //This should be present in dyntftui files only. Headers start with this (reserved) value, to signal that the file pointer was not set to the first instruction. See CRTTIFILEPOINTERNOTSETTOINSTRUCTION constant.

  //DataCallBack args are 0 or negative:
  CRTTI_DataCallBackArg_ResetFilePointer = 0;
  CRTTI_DataCallBackArg_GetDataBuildNumber = 32767; //-1;

var
  DynTFTReceivedMouseDown: Boolean;
  DynTFTReceivedMouseUp: Boolean;
  DynTFTReceivedComponentVisualStateChange: Boolean;
  DynTFTAllComponentsContainer: TDynTFTComponentsContainer; //this is an array of screens

  DynTFTMCU_XMouse, DynTFTMCU_YMouse: Integer;      //Directly used by some components
  DynTFTMCU_OldXMouse, DynTFTMCU_OldYMouse: Integer;
  DynTFTDragOffsetX, DynTFTDragOffsetY: LongInt;
  DynTFTGBlinkingCaretStatus, DynTFTGOldBlinkingCaretStatus: Boolean;

  DynTFTRegisteredComponents: array[0..CDynTFTMaxRegisteredComponentTypes - 1] of TDynTFTBaseEventReg;
  DynTFTRegisteredComponentCount: Integer; //number of component types in an application

  {$IFDEF MouseDoubleClickSupport}
    DynTFTGetTickCount, DynTFTOldGetTickCount: DWord;     //DynTFTGetTickCount will have to be updated by a timer in user application
                                                          //It can be the OS's GetTickCount function on Desktop.
  {$ENDIF}

implementation

//uses DynTFTUtils; //added automatically by Delphi (probably a Delphi bug causes this, because the unit is already in the uses section from interface, mixed with compiler directives)


type
  TWordArray = array[0..16383] of Word;
  PWordArray = ^TWordArray;


{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

{$IFDEF IsDesktop}
  procedure DynTFTInitBaseHandlersAndProperties(ABase: PDynTFTBaseComponent); //Desktop only
  begin
    New(ABase^.BaseProps.OnMouseDownUser);
    New(ABase^.BaseProps.OnMouseMoveUser);
    New(ABase^.BaseProps.OnMouseUpUser);
    {$IFDEF MouseClickSupport}
      New(ABase^.BaseProps.OnClickUser);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      New(ABase^.BaseProps.OnDoubleClickUser);
    {$ENDIF}

    {$IFDEF ComponentsHaveName}
      ABase^.BaseProps.Name := '';
    {$ENDIF}

    {$IFDEF ComponentsHaveName}
      {$IFDEF IsDesktop}
        {DynTFT_DebugConsole('--- Allocating user event handlers of component $' + IntToHex(TPTr(ABase), 8) +
                            '  Addr(Down) = $' + IntToHex(TPTr(ABase^.BaseProps.OnMouseDownUser), 8) +
                            '  Addr(Move) = $' + IntToHex(TPTr(ABase^.BaseProps.OnMouseMoveUser), 8) +
                            '  Addr(Up) = $' + IntToHex(TPTr(ABase^.BaseProps.OnMouseUpUser), 8)
                            );}
      {$ENDIF}
    {$ENDIF}
  end;


  procedure DynTFTFreeBaseHandlersAndProperties(ABase: PDynTFTBaseComponent); //Desktop only
  begin
    try
      {$IFDEF ComponentsHaveName}
        {$IFDEF IsDesktop}
          {DynTFT_DebugConsole('--- Disposing user event handlers of component $' + IntToHex(TPTr(ABase), 8) +  ': ' + ABase^.BaseProps.Name +
                              '  Addr(Down) = $' + IntToHex(TPTr(ABase^.BaseProps.OnMouseDownUser), 8) +
                              '  Addr(Move) = $' + IntToHex(TPTr(ABase^.BaseProps.OnMouseMoveUser), 8) +
                              '  Addr(Up) = $' + IntToHex(TPTr(ABase^.BaseProps.OnMouseUpUser), 8)
                              );}
        {$ENDIF}
      {$ENDIF}

      Dispose(ABase^.BaseProps.OnMouseDownUser);
      Dispose(ABase^.BaseProps.OnMouseMoveUser);
      Dispose(ABase^.BaseProps.OnMouseUpUser);
      {$IFDEF MouseClickSupport}
        Dispose(ABase^.BaseProps.OnClickUser);
      {$ENDIF}
      {$IFDEF MouseDoubleClickSupport}
        Dispose(ABase^.BaseProps.OnDoubleClickUser);
      {$ENDIF}

      {$IFDEF ComponentsHaveName}
        ABase^.BaseProps.Name := ''; //ABase^.BaseProps.Name := nil;
      {$ENDIF}

      ABase^.BaseProps.OnMouseDownUser := nil;
      ABase^.BaseProps.OnMouseMoveUser := nil;
      ABase^.BaseProps.OnMouseUpUser := nil;
      {$IFDEF MouseClickSupport}
        ABase^.BaseProps.OnClickUser := nil;
      {$ENDIF}
      {$IFDEF MouseDoubleClickSupport}
        ABase^.BaseProps.OnDoubleClickUser := nil;
      {$ENDIF}
    except
      on E: Exception do
        raise Exception.Create('DynTFTFreeBaseHandlersAndProperties: ' + E.Message);
    end;
  end;
{$ENDIF}

var
  ContainerComponentType: TDynTFTComponentType;

function DynTFTGetComponentContainerComponentType: TDynTFTComponentType;
begin
  Result := ContainerComponentType;
end;  


procedure DynTFTInitBaseHandlersToNil(ABase: PDynTFTBaseComponent);  //requires InitBaseHandlers to be called in advance
begin
  {$IFDEF IsDesktop}
    ABase^.BaseProps.OnMouseDownUser^ := nil;
    ABase^.BaseProps.OnMouseMoveUser^ := nil;
    ABase^.BaseProps.OnMouseUpUser^ := nil;
    {$IFDEF MouseClickSupport}
      ABase^.BaseProps.OnClickUser^ := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABase^.BaseProps.OnDoubleClickUser^ := nil;
    {$ENDIF}
  {$ELSE}
    ABase^.BaseProps.OnMouseDownUser := nil;
    ABase^.BaseProps.OnMouseMoveUser := nil;
    ABase^.BaseProps.OnMouseUpUser := nil;
    {$IFDEF MouseClickSupport}
      ABase^.BaseProps.OnClickUser := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABase^.BaseProps.OnDoubleClickUser := nil;
    {$ENDIF}
  {$ENDIF}
end;


procedure DynTFTInitBasicStatePropertiesToDefault(AComp: PDynTFTBaseComponent);
begin
  AComp^.BaseProps.Enabled := CENABLED;
  AComp^.BaseProps.Visible := CVISIBLE;
  AComp^.BaseProps.Focused := CUNFOCUSED; 
  AComp^.BaseProps.CompState := CRELEASED; //not pressed, no notification
end;


procedure DynTFTInitBasicStatePropertiesToEmpty(AComp: PDynTFTBaseComponent);
begin
  AComp^.BaseProps.Enabled := CDISABLED;
  AComp^.BaseProps.Visible := CHIDDEN;
  AComp^.BaseProps.Focused := CUNFOCUSED; 
  AComp^.BaseProps.CompState := CRELEASED; //not pressed, no notification
end;


{procedure DynTFTInitComponentDimensions(AComp: PDynTFTBaseComponent; AComponentType: TDynTFTComponentType; ACanHandleMessages: Boolean; Left, Top, Width, Height: TSInt);
begin
  AComp^.BaseProps.ComponentType := AComponentType;
  AComp^.BaseProps.CanHandleMessages := ACanHandleMessages;
  AComp^.BaseProps.Left := Left;
  AComp^.BaseProps.Top := Top;
  AComp^.BaseProps.Width := Width;
  AComp^.BaseProps.Height := Height;
end;}


procedure DynTFTDisplayErrorMessage({$IFDEF IsMCU}var{$ENDIF} AMessage: string; TextColor: DWord);
begin
  DynTFT_Set_Pen(CL_RED, 1);
  DynTFT_Set_Brush(1, $88FF88, 0, 0, 0, 0);
  DynTFT_Rectangle(10, 42, 300, 70);

  DynTFT_Set_Font(@TFT_defaultFont, TextColor, 0);

  DynTFT_Write_Text(AMessage, 12, 44);
end;


procedure DynTFTDisplayErrorMessageAtPos({$IFDEF IsMCU}var{$ENDIF} AMessage: string; TextColor: DWord; X, Y: Integer);
var
  TextWidth, TextHeight: Word;
begin
  GetTextWidthAndHeight(AMessage, TextWidth, TextHeight);
  
  DynTFT_Set_Pen(CL_MAROON, 1);
  DynTFT_Set_Brush(1, $FFFFFF, 0, 0, 0, 0);
  DynTFT_Rectangle(X, Y, X + TextWidth + 4, Y + TextHeight + 4);

  DynTFT_Set_Font(@TFT_defaultFont, TextColor, 0);

  DynTFT_Write_Text(AMessage, X + 2, Y + 2);
end;


procedure DisplayOutOfMemory(TextColor: DWord);
var
  TempStr: string[23];
begin
  TempStr := COUTOFMEMORYMESSAGE_MCU;
  DynTFTDisplayErrorMessage(TempStr, TextColor);

  {if MM_error then //See MemManager
  begin
    DynTFT_Set_Brush(1, $FFFFFF, 0, 0, 0, 0);
    DynTFT_Rectangle(10, 20, 300, 20);

    DynTFT_Set_Font(@TFT_defaultFont, TextColor, 0);  

    TempStr := 'Memory Eror';
    DynTFT_Write_Text(TempStr, 10, 20);
  end;}
end;


{Adds a component (the Result variable) to the linked list without initializing component data (pointed to by Component field)}
function AddComponentPointer(ComponentInChain: PDynTFTComponent): PDynTFTComponent;
begin //chain means linked list
  if ComponentInChain = nil then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('AddComponentPointer requires a valid pointer as argument.');
    {$ENDIF}
  end;

  while ComponentInChain^.NextSibling <> nil do   //added to the end of list
    ComponentInChain := PDynTFTComponent(TPtrRec(ComponentInChain^.NextSibling));
       
  {$IFDEF IsMCU}
    GetMem(Result, SizeOf(TDynTFTComponent));           //"component in chain"
    if Result = nil then
      DisplayOutOfMemory(CL_RED);
  {$ELSE}
    GetMem(TPtrRec(Result), SizeOf(TDynTFTComponent));  //"component in chain"    //without TPtrRec, it doesn't work in mikroPascal:  340 341 Operator "@" not applicable to these operands "?T227"
    if Result = nil then
      raise Exception.Create(COUTOFMEMORYMESSAGE + #13#10 + 'CL_RED');
  {$ENDIF}
  
  ComponentInChain^.NextSibling := PPtrRec(TPtrRec(Result));

  Result^.NextSibling := nil;
  Result^.BaseComponent := nil;
end;


procedure InitComponentPointer(var AComp, Parent: PDynTFTComponent; ScreenIndex: Byte);
begin
  //assume Parent <> nil
  Parent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  AComp := AddComponentPointer(PDynTFTComponent(TPtrRec(Parent)));
end;


function DynTFTComponent_Create(ScreenIndex: Byte; SizeOfComponent: TPtr): PDynTFTBaseComponent;   //something like TObject.Create
var
  AComp: PDynTFTComponent;
  Parent: PDynTFTComponent;
begin
  InitComponentPointer(AComp, Parent, ScreenIndex);

  {$IFDEF IsMCU}
    GetMem(AComp^.BaseComponent, SizeOfComponent);   //allocate button, panel, edit, etc
    if AComp^.BaseComponent = nil then
      DisplayOutOfMemory(CL_GREEN);
  {$ELSE}
    GetMem(TPtrRec(AComp^.BaseComponent), SizeOfComponent);   //allocate button, panel, edit, etc

    if AComp^.BaseComponent = nil then
      raise Exception.Create(COUTOFMEMORYMESSAGE + #13#10 + 'CL_GREEN');
  {$ENDIF}

  Result := PDynTFTBaseComponent(TPtrRec(AComp^.BaseComponent));

  Result^.BaseProps.ScreenIndex := ScreenIndex;
  Result^.BaseProps.Parent := PPtrRec(TPtrRec(Parent));

  {$IFDEF IsDesktop}
    DynTFTInitBaseHandlersAndProperties(Result); //Delphi only
  {$ENDIF}
  DynTFTInitBaseHandlersToNil(Result);
end;


//This function assumes that ALastComp was allocated after AFirstComp and they belong to the same list (same ScreenContainer).
procedure DynTFTComponent_DestroyMultiple(var AFirstComp, ALastComp: PDynTFTBaseComponent; SizeOfComponent: TPtr);   //something like TObject.Destroy, but for more identical components, allocated one after the other
var
  CurrentComp, NextComp, NextNextComp: PDynTFTComponent;
  FirstFound, LastFound: Boolean;

  //x1, y1, x2, y2: Integer; //debug only
begin //chain means linked list
  if AFirstComp = nil then
    Exit;

  {$IFDEF IsDesktop}
    if ALastComp <> nil then
      if AFirstComp^.BaseProps.ScreenIndex <> ALastComp^.BaseProps.ScreenIndex then
        raise Exception.Create('First and Last components do not belong to the same screen.  (DynTFTComponent_DestroyMultiple)');
  {$ENDIF}

  CurrentComp := DynTFTAllComponentsContainer[AFirstComp^.BaseProps.ScreenIndex].ScreenContainer;  //start at first component (a.k.a Parent)

  if CurrentComp^.NextSibling = nil then
    Exit;
                                  
  FirstFound := False;
  LastFound := False;

  repeat
    NextComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));
      
    if PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = ALastComp then
      LastFound := True;

    if NextComp <> nil then
      if FirstFound or (PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = AFirstComp) then
      begin
        FirstFound := True; //force the execution to enter here again
        {$IFDEF IsDesktop}
          DynTFTFreeBaseHandlersAndProperties(PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent)));
        {$ENDIF}

        //Prevent repaint from dangling pointers
        DynTFTInitBasicStatePropertiesToEmpty(PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent)));

        //Debug code  -  draw a red rectange over the destroyed component
        {
        DynTFT_Set_Brush(1, 255, 0, 0, 0, 0);
        x1 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Left;
        y1 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Top;
        x2 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Width + x1;
        y2 := PDynTFTBaseComponent(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent))^.BaseProps.Height + y1;
        DynTFT_Rectangle(x1, y1, x2, y2);
        }

        //Free user component (payload)
        {$IFDEF IsMCU}
          FreeMem(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent, SizeOfComponent);  //Free payload
        {$ELSE}
          FreeMem(TPtrRec(PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling))^.BaseComponent), SizeOfComponent);  //Free payload
        {$ENDIF}

        NextNextComp := PDynTFTComponent(TPtrRec(NextComp^.NextSibling));
        CurrentComp^.NextSibling := PPtrRec(TPtrRec(NextNextComp)); //either nil or a valid component

        //free container component (component in chain)
        {$IFDEF IsMCU}
          FreeMem(NextComp, SizeOf(TDynTFTComponent));  //Free "component in chain"
        {$ELSE}
          FreeMem(TPtrRec(NextComp), SizeOf(TDynTFTComponent));  //Free "component in chain"
        {$ENDIF}

        if ALastComp = nil then
          Break;
      end;

    if LastFound then
      Break;

    if not FirstFound then
      CurrentComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));
  until PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling)) = nil;  //do not use NextComp here, it is a dangling pointer

  AFirstComp := nil; //like FreeAndNil
  ALastComp := nil; //like FreeAndNil
end;


procedure DynTFTComponent_Destroy(var AComp: PDynTFTBaseComponent; SizeOfComponent: TPtr);   //something like TObject.Destroy
var
  ALastComp: PDynTFTBaseComponent;
begin
  ALastComp := nil;
  DynTFTComponent_DestroyMultiple(AComp, ALastComp, SizeOfComponent);
end;


{$IFDEF RTTIREG}
  {
    The purpose of DynTFTComponent_CreateFromReg and DynTFTComponent_DestroyFromReg is to create and destroy a component,
    without directly calling its "constructor" and "destructor". They are called via function/procedure pointers.

    This is useful to automate creation and destruction of components, based on their ComponentType information,
    using commands stored externally (SD card, USB drive etc).

    If various components are registered in a predefined order, all their instances can be created using this "constructor".

    The initial values of the "properties" of these components, can be set by writing data to memory at an address,
    computed from component address and offset of the "property" (like what compiler does when accessing a structure field).

    "Property" addresses can be obtained by looking at the component's data structure (at design time).

    Event handlers can be assigned in the same way. Their addresses can be obtained from a .lst file after compilation.
    Just make sure they are linked (perhaps creating function pointers or using orgall, will link them).

    Creating components in this manner, allows storing the UI exernally, not in code.


    RTTI Instruction format (architecture independent):
                     ____________________________________________________________________________________________________________________________________
  Array DWords:     |                                  DWord 0                                       |        DWord 1         |         DWord 2          |
  Array Bytes:      |    Byte 0             Byte 1           Byte 2              Byte 3              |Byte4 Byte5 Byte6 Byte7 |Byte8 Byte9 Byte10 Byte11 |
                    |________________________________________________________________________________|________________________|__________________________|
                    |Instruction number  | | Component type |      Options 1    |    Options 2       |         Data           |          Data            |
                    |____________________|_|________________|___________________|____________________|                        |                          |
Stop execution:     |          0         |        ////      |        ////       |       ////         |                        |                          |
                    |____________________|__________________|___________________|____________________|____________ ___________|__________________________|____________
Create component:   |          1         | | Component type | CreateCompOptions | Screen index       |    Top     |   Left    |   Height   |    Width    |         maybe comp index (lower word)
                    |____________________|_|________________|___________________|____________________|_____|______|_____|_____|_____|______|______|______|_________in AllComponents array
Destroy component:  |          2         | | Component type |      Options 1    |    Options 2       | CompIndex (optional)   |
                    |____________________|_|________________|___________________|____________________|________________________|___________________________________
Set property:       |          3         | | Component type |  Property options | Data length[bytes] |  <Property data> ...   |  <Property data> ...     |  <Property data> ...
                    |____________________|_|________________|___________________|____________________|________________________|__________________________|________
Check build version |          4         |         0        |              Build number              |
                    |____________________|__________________|___________________|____________________|
Header              |          5         |                           0                               |
                    |____________________|___________________________________________________________|


     Create component "CreateCompOptions" (one byte):
     bit7       - reserved - HasIndexField (may be possibly used in next versions of the protocol, to extend the instruction by one DWord, containing component index)
     bit6       - HasVarInGUIObjects
     bit5       - CreateAtStartup
     bit4..bit0 - GroupIndex  -  31 available groups (0 - 30).  Group number 31 ($1F) means "no group used"

     Create component "Component type"
     bit7       - Reserved
     bit6..bit0 - the component type as it is registered at runtime (see RegisterAllComponentsEvents from DynTFTGUI unit) e.g.  0 = Screen, 1 = Button, 2 = Label etc


     Destroy component "Options 1" (one byte):
     bit7       - if bit7 = 1 use a second DWord (DWord1) to index more components. If bit7 = 0, use a single DWord instruction (DWord0). Set this to 0 for the first 256 components, then set it to 1 for the rest of them.
     bit6       - HasVarInGUIObjects
     bit5       - Reserved
     bit4..bit0 - GroupIndex  -  31 available groups (0 - 30).  Group number 31 ($1F) means "no group used"   - used for filtering, to destroy only some components, which match the group index

     Destroy component "Options 2" (one byte):  if Options1.bit7 is 0, this is Component index in AllComponents array. Else, Component index would be on the next DWord.


     Set property "Options 1" (one byte)
     bit7       - IsString  (1 = IsString, 0 = other data)  - required on PC (not on MCU) to set the string length  (overwrites first byte of a shortstring with length)
     bit6..bit0 - Property index (at most 128 possible properties of a component)
                  This index has to match the generated code from DynTFT<Comp>_GetPropertyAddress functions (See DynTFTRegisteredComponents[].CompGetPropertyAddress).

     Set property "Options 2" Data length [bytes] - at least one byte of length (at least one "Property data" DWord, at most 256/4=64 DWords).
                  If length is 4 or less, only one "Property data" DWord is used. If length is 5 to 8 bytes, two "Property data" DWords are used etc.
                  Because of endianess, array[7] will be the first data byte, array[6] will be the second, array[5] will be the third, array[4] will be the fourth
                                        array[11] will be the fifth, array[10] will be the sixth, array[9] will be the seventh, etc

     Set property  "Component type"
     bit7       - IsIndex (1 = data represents an index in the array of handlers/fonts, 0 = data is updated with a value from that array)  - See SetDataFromIndex instruction
                  It is used when the property value represents the address of an event handler or font, which cannot be determined at compile time.
                  The data length of the property has to match the pointer size in bytes for addresses.
     bit6..bit0 - the component type as it is registered at runtime


     Check build number  "Build number"
     bit15..bit0- Build number  Can be 0 only to explicitly mark a file as out of date. Otherwise, it represents build number.
     


 Example of AllCreatedComponents array content:
    CLabels_InstructionData: array[0..23] of DWord = (
      17195010, $0023013B, $000D0012,  //create first label  (PDynTFTLabel is registed as the sixth item in this example)
      $03060104, $0083FFB3,            //set color to $B3FF83
      $0306800B, $20202031, $33322020, $00003534,//set Caption to '1     2345'#0
      17195010, $004B013B, $000D0012,  //create second label
      $03060104, $0083FFB3,            //set color to $B3FF83
      $03068002, $00000030,            //set Caption to '0'
      17195010, $0073013B, $000D0012,  //create third label
      $03060104, $0083FFB3,            //set color to $B3FF83
      $03068002, $00000030,            //set Caption to '0'
      0                                //stop execution                //always required
    );
                                        

  }
  function DynTFTComponent_CreateFromReg(AComponentType: TDynTFTComponentType; ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
  begin
    {$IFDEF IsDesktop}
      if (AComponentType >= DynTFTRegisteredComponentCount) or (AComponentType < 0) then
        raise Exception.Create('(RTTI) ComponentType is out of range in DynTFTComponent_CreateFromReg.   AComponentType = ' + IntToStr(AComponentType) + '   RegisteredComponentCount = ' + IntToStr(DynTFTRegisteredComponentCount) + '. Either the instructions are out of date or they contain bad data.');
    {$ENDIF}

    Result := nil;

    {$IFDEF IsDesktop}
      if Assigned(DynTFTRegisteredComponents[AComponentType].CompCreate) then
        if Assigned(DynTFTRegisteredComponents[AComponentType].CompCreate^) then
    {$ELSE}
      if DynTFTRegisteredComponents[AComponentType].CompCreate <> nil then
    {$ENDIF}
        Result := DynTFTRegisteredComponents[AComponentType].CompCreate^(ScreenIndex, Left, Top, Width, Height);
  end;

  
  procedure DynTFTComponent_DestroyFromReg(var AComp: PDynTFTBaseComponent);
  begin
    if AComp = nil then
      Exit;

    {$IFDEF IsDesktop}
      if (AComp^.BaseProps.ComponentType >= DynTFTRegisteredComponentCount) or (AComp^.BaseProps.ComponentType < 0) then
        raise Exception.Create('(RTTI) ComponentType is out of range in DynTFTComponent_DestroyFromReg.   AComponentType = ' + IntToStr(AComp^.BaseProps.ComponentType) + '   RegisteredComponentCount = ' + IntToStr(DynTFTRegisteredComponentCount) + '. Either the instructions are out of date or they contain bad data.');
    {$ENDIF}

    {$IFDEF IsDesktop}
      if Assigned(DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy) then
        if Assigned(DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy^) then
    {$ELSE}
      if DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy <> nil then
    {$ENDIF}
        DynTFTRegisteredComponents[AComp^.BaseProps.ComponentType].CompDestroy^(AComp);
  end;


  {$IFDEF FPC}
    function LoByte(x: DWord): Byte;
    begin
      Result := x and $FF;
    end;

    function HiByte(x: DWord): Byte;
    begin
      Result := (x shr 8) and $FF;
    end;
  {$ENDIF}

  //PropertyMetadata constains Instruction:PropertyIndex:PropertyLength:PropertyValue
  //Returns PropertyLength in bytes
  function DynTFTComponent_SetProperty(PropertyMetadata: PDWordArray; AComp: PDynTFTBaseComponent; HandlerAddresses: PTPtrArray): Byte;
  var
    FirstDWord: DWord;
    PropertyIndex, PropertyLength: Byte;
    PropertyContent: PByteArray;         //Property value can be a Byte, a Word, a DWord, a QWord or an array of bytes encoded as DWords
    PropertyAddress: PPtrRec;
    ComponentType: TDynTFTComponentType;
    IsString: Boolean;   //  use MSB of PropertyIndex to decide if this is a string or some other array of bytes
    GetPropertyAddress_Proc: {$IFDEF IsMCU} PDynTFTGetPropertyAddressProc {$ELSE} TDynTFTGetPropertyAddressProc {$ENDIF};
    IsIndex: Boolean;
    TempBuffer: TPtr;  //pointer size (2, 4, or 8 bytes)
    IndexOfHandlerOrFont: Byte;

    {$IFNDEF IsDesktop}
      TempStr: string[23];
    {$ENDIF}  
  begin
    FirstDWord := PropertyMetadata^[0]; //DWord(PropertyMetadata^);

    PropertyLength := {$IFDEF FPC} LoByte {$ELSE} Lo {$ENDIF}(FirstDWord);
    Result := PropertyLength;

    if AComp = nil then  //this can happen on components which are not created at startup
      Exit;              //anyway, return a valid PropertyLength

    //Highest(FirstDWord) is the instruction
    ComponentType := Higher(FirstDWord);
    IsIndex := ComponentType and CDynTFTPropertyIsIndex_BitMask = CDynTFTPropertyIsIndex_BitMask;
    ComponentType := ComponentType and $7F; //clear IsIndex information

    PropertyIndex := {$IFDEF IsDesktop} HiByte {$ELSE} Hi {$ENDIF}(FirstDWord);

    IsString := PropertyIndex and CDynTFTPropertyIsString_BitMask = CDynTFTPropertyIsString_BitMask;
    PropertyIndex := PropertyIndex and $7F; //clear IsString information

    GetPropertyAddress_Proc := DynTFTRegisteredComponents[ComponentType].CompGetPropertyAddress;
    PropertyAddress := GetPropertyAddress_Proc(AComp, PropertyIndex);  //call DynTFTButton_GetPropertyAddress or DynTFTLabel_GetPropertyAddress etc

    if IsString then
    begin
      {$IFDEF IsDesktop}
        memcpy(PByte(TPtr(PropertyAddress) - 1), @PropertyLength, 1);  // write a single byte, since constrained strings on PC, are short strings
      {$ELSE}
        TempBuffer := 0;
        memcpy(PByte(DWord(PropertyAddress) + PropertyLength), @TempBuffer, 1);  // write #0 to MyString[Length(MyString)] as null terminator  (MCU only, because on desktop, short strings are not null terminated)
      {$ENDIF}
    end;


    PropertyContent := PByteArray(TPtr(PropertyMetadata));

    if IsIndex then
    begin
      if HandlerAddresses = nil then
      begin
        {$IFDEF IsDesktop}
          DynTFT_DebugConsole('Expected an array of handlers (and/or fonts) to be provided to ExecuteRTTIInstructions procedure. This handler or font is not set.');
        {$ELSE}
          TempStr := CHANDLERSARRAYNOTSET;
          DynTFTDisplayErrorMessage(TempStr, CL_RED); //Display an error even on MCU, to detect a bad setting (or bug). This happens when the instruction is set to use handler indexes instead of addresses (bit "IsIndex" is 1), but there is no array of addresses to be indexed.  The "IsIndex" bit is usually set if no .lst file is provided when generating the instructions (either code or .dyntftui file).
        {$ENDIF}
        Exit;
      end;

      memcpy(PByte(@TempBuffer), @PropertyContent^[4], PropertyLength);   //in case of an index, PropertyLength cannot be more than 8 (i.e. data would be no longer than 8 bytes)

      // replace index with address:
      IndexOfHandlerOrFont := TempBuffer; //Lo(TempBuffer);
      TempBuffer := HandlerAddresses^[IndexOfHandlerOrFont];
      memcpy(PByte(PropertyAddress), PByte(@TempBuffer), PropertyLength);
    end
    else
      memcpy(PByte(PropertyAddress), @PropertyContent^[4], PropertyLength);
  end;


  function DynTFTCCreate_Component_FromData(AData: PDWordArray): PDynTFTBaseComponent;
  var
    ScreenIndex: Byte;
    Left, Top, Width, Height: TSInt;
    ComponentType: TDynTFTComponentType;
  begin
    ScreenIndex := {$IFDEF IsDesktop} LoByte {$ELSE} Lo {$ENDIF}(AData^[0]);
    ComponentType := Higher(AData^[0]) and $7F;

    Left := LoWord(AData^[1]);
    Top := HiWord(AData^[1]);
    Width := LoWord(AData^[2]);
    Height := HiWord(AData^[2]);

    Result := DynTFTComponent_CreateFromReg(ComponentType, ScreenIndex, Left, Top, Width, Height);
  end;


  function InstructionAllowed(Filter, InstructionOptions: Byte): Boolean;
  begin
    Result := False;
    if Filter = CDynTFT_InstructionFilter_CreateStartupOnly_BitMask then  //direct comparison is ok, because there is no other option to verify
      if InstructionOptions and CDynTFTCreatedAtStartup_BitMask = CDynTFTCreatedAtStartup_BitMask then
      begin
        Result := True;
        Exit;
      end;

    if Filter and CDynTFT_InstructionFilter_CreateSingleGroup_BitMask = CDynTFT_InstructionFilter_CreateSingleGroup_BitMask then
      if Filter and CDynTFT_InstructionFilter_GroupNumber_BitMask = InstructionOptions and CDynTFT_InstructionFilter_GroupNumber_BitMask then
      begin
        Result := True;
        Exit;
      end;

    if (Filter and CDynTFT_InstructionFilter_CreateAll_BitMask) = CDynTFT_InstructionFilter_CreateAll_BitMask then
    begin
      Result := True;
      //Exit;
    end;
  end;


  procedure ExecuteRTTIInstructions(ABinaryComponentsData: PDWordArray; AllCreatedComponents: PAllCreatedDynTFTComponents; HandlerAddresses: PTPtrArray; Filter: Byte; GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF});
  var
    NextComponentIndex: Integer;
    NextInstruction: PDWordArray;
    IsLastInstruction: Boolean;
    UseSecondDWordToIndexDestroy: Boolean;
    InstructionSize, IndexOfComponentToDestroy: DWord;
    CreatedComp, DestroyingComp: PDynTFTBaseComponent;
    InstructionCode, InstructionOptions: Byte;
    PropertyLength: Byte;
    //ConvRes: string[20]; //for debugging only
    TempStr: string[26];
  begin
    NextComponentIndex := -1;
    InstructionSize := 0;
    NextInstruction := ABinaryComponentsData;  //point to the first instruction in ABinaryComponentsData

    if {$IFDEF IsDesktop} Assigned(GetDataCallback) {$ELSE} GetDataCallback <> nil {$ENDIF} then
      GetDataCallback(nil, CRTTI_DataCallBackArg_ResetFilePointer);

    CreatedComp := nil;
    repeat
      if {$IFDEF IsDesktop} not Assigned(GetDataCallback) {$ELSE} GetDataCallback = nil {$ENDIF} then //no callback
        NextInstruction := PDWordArray(TPtr(NextInstruction) + InstructionSize shl 2)  //(InstructionSize [DWords]) shl 2  means Bytes
      else
      begin
        NextInstruction := ABinaryComponentsData;   //reset pointer to data whenever there is a callback, because the buffer is the same (ABinaryComponentsData)
        GetDataCallback(ABinaryComponentsData, 4); //read instruction
      end;

      InstructionCode := Highest(NextInstruction^[0]);
      InstructionOptions := {$IFDEF IsDesktop} HiByte {$ELSE} Hi {$ENDIF}(NextInstruction^[0]);
      InstructionSize := CDynTFTUnrecognizedInstructionError; //default  - will cause execution to stop
      IsLastInstruction := False;
      
      case InstructionCode of
        CRTTIInstruction_StopExecution :
        begin
          IsLastInstruction := True;
          InstructionSize := 1; //header only
        end;

        CRTTIInstruction_CreateComponent : 
        begin
          if {$IFDEF IsDesktop} Assigned(GetDataCallback) {$ELSE} GetDataCallback <> nil {$ENDIF} then
            GetDataCallback(PDWordArray(TPtr(ABinaryComponentsData) + 4), 8);  //two DWords

          if InstructionAllowed(Filter, InstructionOptions) then
            CreatedComp := DynTFTCCreate_Component_FromData(NextInstruction)
          else
            CreatedComp := nil; //if not created, because of filtering, then set to nil, to tell DynTFTComponent_SetProperty that it has to ignore setting properties

          if InstructionOptions and CDynTFTHasVarInGUIObjects_BitMask = CDynTFTHasVarInGUIObjects_BitMask then
          begin
            Inc(NextComponentIndex);  //increment this even if CreatedComp is not created, even if an instruction is ignored

            if CreatedComp <> nil then //verify if CreatedComp <> nil, to prevent setting components to nil, simply because they were not created, based on filtering rules
              if AllCreatedComponents <> nil then  //expected to be nil, if no components with global vars are found in the list of binary components
              begin
                {$IFDEF IsDesktop}
                  if AllCreatedComponents^[NextComponentIndex]^ <> nil then
                    DynTFT_DebugConsole('Error: Recreating component from instruction (maybe it was already created on startup).  IndexOfComponent: ' + IntToStr(NextComponentIndex) + '   Comptype: ' + IntToStr(AllCreatedComponents^[NextComponentIndex]^^.BaseProps.ComponentType) + '  ScreenIndex: ' + IntToStr(AllCreatedComponents^[NextComponentIndex]^^.BaseProps.ScreenIndex) + '  Left: ' + IntToStr(AllCreatedComponents^[NextComponentIndex]^^.BaseProps.Left) + '  Top: ' + IntToStr(AllCreatedComponents^[NextComponentIndex]^^.BaseProps.Top));
                {$ENDIF}

                {$IFDEF IsDesktop}
                  //debug code
                  //if AllCreatedComponents^[NextComponentIndex]^ = nil then
                  //  DynTFT_DebugConsole('... Creating component from instruction.  IndexOfComponent: ' + IntToStr(NextComponentIndex) + '   Comptype: ' + IntToStr(CreatedComp^.BaseProps.ComponentType) + '  ScreenIndex: ' + IntToStr(CreatedComp^.BaseProps.ScreenIndex) + '  Left: ' + IntToStr(CreatedComp^.BaseProps.Left) + '  Top: ' + IntToStr(CreatedComp^.BaseProps.Top));
                  //end of debug code
                {$ENDIF}

                AllCreatedComponents^[NextComponentIndex]^ := CreatedComp;
              end;
          end
          {$IFDEF IsDesktop}
            else
            begin
              //if CreatedComp <> nil then
              //  DynTFT_DebugConsole('Created component from instruction, without var in GUI object. Comptype: ' + IntToStr(CreatedComp^.BaseProps.ComponentType) + '  Left: ' + IntToStr(CreatedComp^.BaseProps.Left) + '  Top: ' + IntToStr(CreatedComp^.BaseProps.Top));
            end
          {$ENDIF};

          InstructionSize := 3 {+ Options shr 7};       //header + top_left + height_width  // + (1 if bit 7 is set in Options)
        end;

        CRTTIInstruction_DestroyComponent :
        begin
          UseSecondDWordToIndexDestroy := {$IFDEF IsDesktop} HiByte {$ELSE} Hi {$ENDIF}(NextInstruction^[0]) and CDynTFTIndexSecondDWordOnDestroy_BitMask = CDynTFTIndexSecondDWordOnDestroy_BitMask;

          if not UseSecondDWordToIndexDestroy then
          begin
            IndexOfComponentToDestroy := {$IFDEF IsDesktop} LoByte {$ELSE} Lo {$ENDIF}(NextInstruction^[0]);
            InstructionSize := 1;       //header
          end
          else
          begin
            if {$IFDEF IsDesktop} Assigned(GetDataCallback) {$ELSE} GetDataCallback <> nil {$ENDIF} then
              GetDataCallback(PDWordArray(TPtr(ABinaryComponentsData) + 4), 4);  //one DWord

            IndexOfComponentToDestroy := NextInstruction^[1];  //full DWord for now
            InstructionSize := 2;       //header + Index
          end;

          if InstructionAllowed(Filter, InstructionOptions) then
            if AllCreatedComponents <> nil then  //expected to be nil, if no components with global vars are found in the list of binary components
            begin
              DestroyingComp := AllCreatedComponents^[IndexOfComponentToDestroy]^;

              {$IFDEF IsDesktop}
                //DynTFT_DebugConsole('Destroying component from instruction.  IndexOfComponent: ' + IntToStr(IndexOfComponentToDestroy) + '   Comptype: ' + IntToStr(DestroyingComp^.BaseProps.ComponentType) + '  ScreenIndex: ' + IntToStr(DestroyingComp^.BaseProps.ScreenIndex) + '  Left: ' + IntToStr(DestroyingComp^.BaseProps.Left) + '  Top: ' + IntToStr(DestroyingComp^.BaseProps.Top));
              {$ENDIF}

              DynTFTComponent_DestroyFromReg(DestroyingComp); //if destroyed successfully, DestroyingComp should be nil at this point          (a DWord is used even on 16-bit architectures to store this pointer)

              {$IFDEF IsDesktop}
                //debug code
                //if DestroyingComp <> nil then
                //  DynTFT_DebugConsole('!!! Failed to destroy component from instruction.  IndexOfComponent: ' + IntToStr(IndexOfComponentToDestroy))
                //else
                //  DynTFT_DebugConsole('Successfully destroyed component from instruction.  IndexOfComponent: ' + IntToStr(IndexOfComponentToDestroy));
                //end of debug code
              {$ENDIF}

              AllCreatedComponents^[IndexOfComponentToDestroy]^ := DestroyingComp;  //updating to nil
              //DestroyingComp should point to a label, a button etc., which are made nil after calling destroy.
            end;
        end;

        CRTTIInstruction_SetProperty :
        begin                                  //filtering should work also here, because CreatedComp is nil for skipped CRTTIInstruction_CreateComponent instructions
          PropertyLength := {$IFDEF IsDesktop} LoByte {$ELSE} Lo {$ENDIF}(NextInstruction^[0]);
          InstructionSize := 1 + PropertyLength shr 2;  //header + number of DWords               //this is 1 + Ceil(PropertyLength / 4)
          if PropertyLength and $03 > 0 then            //a partial DWord    (i.e. length is not 0, 4, 8 or 12)
            InstructionSize := InstructionSize + 1;     //so add that partial DWord to count

          if {$IFDEF IsDesktop} Assigned(GetDataCallback) {$ELSE} GetDataCallback <> nil {$ENDIF} then
            GetDataCallback(PDWordArray(TPtr(ABinaryComponentsData) + 4), (InstructionSize - 1) shl 2);  //multiple DWords    ("discount" header and convert to bytes)    -  max 256 bytes

          DynTFTComponent_SetProperty(NextInstruction, CreatedComp, HandlerAddresses);
        end;

        CRTTIInstruction_BuildVersion :
        begin
          InstructionSize := 1;
          if {$IFDEF IsDesktop} Assigned(GetDataCallback) {$ELSE} GetDataCallback <> nil {$ENDIF} then
          begin
            ABinaryComponentsData^[1] := 0; //init value
            GetDataCallback(PDWordArray(TPtr(ABinaryComponentsData) + 4), CRTTI_DataCallBackArg_GetDataBuildNumber);  //one DWord

            (*
            {$IFDEF IsDesktop} ConvRes := IntToHex(ABinaryComponentsData^[0], 8); {$ELSE} DWordToHexStr(ABinaryComponentsData^[0], ConvRes); {$ENDIF}
            DynTFTDisplayErrorMessageAtPos(ConvRes, CL_FUCHSIA, 291, 26);
            {$IFDEF IsDesktop} ConvRes := IntToHex(ABinaryComponentsData^[1], 8); {$ELSE} DWordToHexStr(ABinaryComponentsData^[1], ConvRes); {$ENDIF}
            DynTFTDisplayErrorMessageAtPos(ConvRes, CL_FUCHSIA, 291, 56);
            *)

            if (ABinaryComponentsData^[1] and $0000FFFF) <> (ABinaryComponentsData^[0] and $0000FFFF) then      // [0] is the current instruction,  [1] is callback result
            begin
              TempStr := CRTTIDATAOUTOFDATE;
              DynTFTDisplayErrorMessage(TempStr, CL_RED);
              {$IFDEF IsDesktop}
                raise Exception.Create(CRTTIDATAOUTOFDATE + '.   The .dyntftui build number does not match the generated code. Please regenerate the code and .dyntftui files.  Const BuildNumber: ' + IntToStr(ABinaryComponentsData^[1] and $FFFF) + '  .dyntftui BuildNumber: ' + IntToStr(ABinaryComponentsData^[0] and $FFFF));
              {$ELSE}
                IsLastInstruction := True;
              {$ENDIF}
            end;
          end;
        end;

        CRTTIInstruction_Header :
        begin
          InstructionSize := 1;
          TempStr := CRTTIFILEPOINTERNOTSETTOINSTRUCTION;
          DynTFTDisplayErrorMessage(TempStr, CL_RED);
          {$IFDEF IsDesktop}
            DynTFT_DebugConsole(CRTTIFILEPOINTERNOTSETTOINSTRUCTION + '.   The file pointer in .dyntftui file has to be set to the first instruction, before starting the RTTI instruction execution, i.e. before calling DynTFT_GUI_Start.');
          {$ENDIF}
        end;
      end; //case

    until IsLastInstruction or (InstructionSize = CDynTFTUnrecognizedInstructionError);

    {$IFDEF IsDesktop}
      if InstructionSize = CDynTFTUnrecognizedInstructionError then
        raise Exception.Create('RTTI execution stopped because of unrecognized instruction: ' + IntToStr(Highest(NextInstruction^[0])));
    {$ENDIF}
  end;
{$ENDIF} //RTTIREG



procedure DynTFTAllocateInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
begin
 {$IFDEF IsDesktop}
    New(ABaseEventReg.MouseDownEvent);
    New(ABaseEventReg.MouseMoveEvent);
    New(ABaseEventReg.MouseUpEvent);
    {$IFDEF MouseClickSupport}
      New(ABaseEventReg.ClickEvent);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      New(ABaseEventReg.DoubleClickEvent);
    {$ENDIF}
    New(ABaseEventReg.Repaint);
    New(ABaseEventReg.BlinkCaretState);

    {$IFDEF RTTIREG}
      New(ABaseEventReg.CompCreate);
      New(ABaseEventReg.CompDestroy);
    {$ENDIF}

    ABaseEventReg.MouseDownEvent^ := nil;
    ABaseEventReg.MouseMoveEvent^ := nil;
    ABaseEventReg.MouseUpEvent^ := nil;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent^ := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent^ := nil;
    {$ENDIF}
    ABaseEventReg.Repaint^ := nil;
    ABaseEventReg.BlinkCaretState^ := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := nil;
      ABaseEventReg.CompDestroy^ := nil;
      ABaseEventReg.CompSize := 0; //just in case
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := nil;
    ABaseEventReg.MouseMoveEvent := nil;
    ABaseEventReg.MouseUpEvent := nil;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := nil;
    {$ENDIF}
    ABaseEventReg.Repaint := nil;
    ABaseEventReg.BlinkCaretState := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := nil;
      ABaseEventReg.CompDestroy := nil;
      ABaseEventReg.CompSize := 0; //just in case
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompGetPropertyAddress := nil;
  {$ENDIF}  
end;


{$IFDEF IsDesktop}
  procedure DynTFTDisposeInternalHandlers(var ABaseEventReg: TDynTFTBaseEventReg);
  begin
    Dispose(ABaseEventReg.MouseDownEvent);
    Dispose(ABaseEventReg.MouseMoveEvent);
    Dispose(ABaseEventReg.MouseUpEvent);
    {$IFDEF MouseClickSupport}
      Dispose(ABaseEventReg.ClickEvent);
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      Dispose(ABaseEventReg.DoubleClickEvent);
    {$ENDIF}
    Dispose(ABaseEventReg.Repaint);
    Dispose(ABaseEventReg.BlinkCaretState);

    {$IFDEF RTTIREG}
      Dispose(ABaseEventReg.CompCreate);
      Dispose(ABaseEventReg.CompDestroy);
    {$ENDIF}

    ABaseEventReg.MouseDownEvent := nil;
    ABaseEventReg.MouseMoveEvent := nil;
    ABaseEventReg.MouseUpEvent := nil;
    {$IFDEF MouseClickSupport}
      ABaseEventReg.ClickEvent := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      ABaseEventReg.DoubleClickEvent := nil;
    {$ENDIF}
    ABaseEventReg.Repaint := nil;
    ABaseEventReg.BlinkCaretState := nil;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := nil;
      ABaseEventReg.CompDestroy := nil;
      ABaseEventReg.CompGetPropertyAddress := nil;
    {$ENDIF}
  end;
{$ENDIF}

//This function assumes that ALastComp was allocated after AFirstComp and they belong to the same list (same ScreenContainer).
procedure DynTFTComponent_BringMultipleComponentsToFront(AFirstComp, ALastComp: PDynTFTBaseComponent);   //pass nil to ALastComp to move only a single component, i.e. AFirstComp
var
  CurrentComp, NextComp, TempComp: PDynTFTComponent;
  First, Last, BeforeFirst: PDynTFTComponent;
begin //chain means linked list
  if AFirstComp = nil then
    Exit;

  {$IFDEF IsDesktop}
    if ALastComp <> nil then
      if AFirstComp^.BaseProps.ScreenIndex <> ALastComp^.BaseProps.ScreenIndex then
        raise Exception.Create('First and Last components do not belong to the same screen.  (DynTFTComponent_BringMultipleComponentsToFront)');
  {$ENDIF}

  CurrentComp := DynTFTAllComponentsContainer[AFirstComp^.BaseProps.ScreenIndex].ScreenContainer;  //start at first component (a.k.a Parent)

  if CurrentComp^.NextSibling = nil then
    Exit;
                                  
  TempComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));  //this is where the last component will point to

  if PDynTFTBaseComponent(TPtrRec(TempComp^.BaseComponent)) = AFirstComp then
    Exit; //nothing to move

  First := nil;
  Last := nil;
  BeforeFirst := nil;

  repeat
    NextComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));

    if NextComp <> nil then
    begin
      if PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = AFirstComp then
      begin
        First := NextComp;
        BeforeFirst := CurrentComp;

        if ALastComp = nil then
        begin
          Last := NextComp;
          Break;
        end;
      end;

      if PDynTFTBaseComponent(TPtrRec(NextComp^.BaseComponent)) = ALastComp then
      begin
        Last := NextComp;
        Break;
      end;
    end;

    CurrentComp := PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling));
  until PDynTFTComponent(TPtrRec(CurrentComp^.NextSibling)) = nil;  //do not use NextComp here, it is a dangling pointer

  {$IFDEF IsDesktop}
    if Last = nil then
      raise Exception.Create('The last component, provided to DynTFTComponent_BringMultipleComponentsToFront, can''t be found.');
  {$ENDIF}

  if (First <> nil) and (Last <> nil) then
  begin
    DynTFTAllComponentsContainer[AFirstComp^.BaseProps.ScreenIndex].ScreenContainer^.NextSibling := PPtrRec(TPtrRec(First));   //step1
    BeforeFirst^.NextSibling := PPtrRec(TPtrRec(Last^.NextSibling)); //step2
    Last^.NextSibling := PPtrRec(TPtrRec(TempComp)); //step3
  end;
end;


procedure DynTFTInitComponentTypeRegistration;
var
  i: Integer;
begin
  DynTFTRegisteredComponentCount := 0;

  for i := 0 to CDynTFTMaxRegisteredComponentTypes - 1 do
    DynTFTAllocateInternalHandlers(DynTFTRegisteredComponents[i]);
end;


procedure DynTFTFreeComponentTypeRegistration;
{$IFDEF IsDesktop}
  var
    i: Integer;
{$ENDIF}
begin
  DynTFTRegisteredComponentCount := 0;

  {$IFDEF IsDesktop}
    for i := 0 to CDynTFTMaxRegisteredComponentTypes - 1 do
      DynTFTDisposeInternalHandlers(DynTFTRegisteredComponents[i]);
  {$ENDIF}
end;


//When reusing a component type, i.e. index, make sure there are no instances of the old component type using that index. Memory corruption will occur if not used properly.
function DynTFTSetComponentTypeInRegistry(ABaseEventReg: PDynTFTBaseEventReg; Index: Integer): Integer;  //returns > -1 for success
begin
  if (Index < 0) or (Index >= CDynTFTMaxRegisteredComponentTypes - 1) then
  begin
    Result := -1; //
    {$IFDEF IsDesktop}
      DynTFT_DebugConsole('Entering DynTFTSetComponentTypeInRegistry with invalid registry index: ' + IntToStr(Index) + '. Skipping registration.');
    {$ENDIF}  
    Exit;
  end;

  {$IFDEF IsDesktop}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseDownEvent^ := ABaseEventReg^.MouseDownEvent^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseMoveEvent^ := ABaseEventReg^.MouseMoveEvent^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseUpEvent^ := ABaseEventReg^.MouseUpEvent^;
    {$IFDEF MouseClickSupport}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].ClickEvent^ := ABaseEventReg^.ClickEvent^;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].DoubleClickEvent^ := ABaseEventReg^.DoubleClickEvent^;
    {$ENDIF}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].Repaint^ := ABaseEventReg^.Repaint^;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].BlinkCaretState^ := ABaseEventReg^.BlinkCaretState^;

    {$IFDEF RTTIREG}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompCreate^ := ABaseEventReg^.CompCreate^;
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompDestroy^ := ABaseEventReg^.CompDestroy^;
    {$ENDIF}  
  {$ELSE}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseDownEvent := ABaseEventReg^.MouseDownEvent;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseMoveEvent := ABaseEventReg^.MouseMoveEvent;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].MouseUpEvent := ABaseEventReg^.MouseUpEvent;
    {$IFDEF MouseClickSupport}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].ClickEvent := ABaseEventReg^.ClickEvent;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].DoubleClickEvent := ABaseEventReg^.DoubleClickEvent;
    {$ENDIF}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].Repaint := ABaseEventReg^.Repaint;
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].BlinkCaretState := ABaseEventReg^.BlinkCaretState;

    {$IFDEF RTTIREG}
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompCreate := ABaseEventReg^.CompCreate;
      DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompDestroy := ABaseEventReg^.CompDestroy;
    {$ENDIF} 
  {$ENDIF}

  {$IFDEF RTTIREG}
    DynTFTRegisteredComponents[DynTFTRegisteredComponentCount].CompSize := ABaseEventReg^.CompSize;
  {$ENDIF}

  Result := Index;
end;


function DynTFTRegisterComponentType(ABaseEventReg: PDynTFTBaseEventReg): Integer;  //returns > -1 for success
begin
  if DynTFTRegisteredComponentCount >= CDynTFTMaxRegisteredComponentTypes - 1 then
  begin
    Result := -1; //
    {$IFDEF IsDesktop}
      DynTFT_DebugConsole('No room left for registering more component types. Please increase CDynTFTMaxRegisteredComponentTypes constant.');
    {$ENDIF}
    Exit;
  end;

  Result := DynTFTSetComponentTypeInRegistry(ABaseEventReg, DynTFTRegisteredComponentCount);
  if Result > -1 then
    Inc(DynTFTRegisteredComponentCount);
end;


function DynTFTComponentsAreRegistered: Boolean;
begin
  Result := DynTFTRegisteredComponentCount > 0;
end;


procedure DynTFTClearComponentRegistration;
begin
  DynTFTRegisteredComponentCount := 0;
end;


procedure DynTFTClearComponentArea(ComponentFromArea: PDynTFTBaseComponent; AColor: TColor);
var
  x1, y1, x2, y2: Integer;
begin
  if ComponentFromArea = nil then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('ComponentFromArea is nil in DynTFTClearComponentArea.');
    {$ENDIF}
    Exit;
  end;
  
  DynTFT_Set_Pen(AColor, 1);
  DynTFT_Set_Brush(1, AColor, 0, 0, 0, 0);

  x1 := ComponentFromArea^.BaseProps.Left;
  y1 := ComponentFromArea^.BaseProps.Top;

  x2 := x1 + ComponentFromArea^.BaseProps.Width;
  y2 := y1 + ComponentFromArea^.BaseProps.Height;
  DynTFT_Rectangle(x1, y1, x2, y2);
end;


procedure DynTFTClearComponentAreaWithScreenColor(ComponentFromArea: PDynTFTBaseComponent);
begin
  if ComponentFromArea = nil then
  begin
    {$IFDEF IsDesktop}
      raise Exception.Create('ComponentFromArea is nil in ClearComponentAreaWithScreenColor. Are you destroying an already destroyed component?');
    {$ENDIF}
    Exit;
  end;
  DynTFTClearComponentArea(ComponentFromArea, DynTFTAllComponentsContainer[ComponentFromArea^.BaseProps.ScreenIndex].ScreenColor);
end;


procedure TDynTFTComponentContainer_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if ComponentFromArea = nil then
    Exit;

  //AComp := PDynTFTComponent(TPtrRec(ABase));
  if Options = CCLEARAREAREPAINT then
    DynTFTClearComponentAreaWithScreenColor(ComponentFromArea);
end;


procedure RegisterComponentContainerEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //The following assignments, which are commented, are not used, because these fields are initialized in InitComponentTypeRegistration (see DynTFTAllocateInternalHandlers).

    //ABaseEventReg.MouseDownEvent^ := nil;
    //ABaseEventReg.MouseMoveEvent^ := nil;
    //ABaseEventReg.MouseUpEvent^ := nil;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent^ := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent^ := nil;
    {$ENDIF}
    ABaseEventReg.Repaint^ := TDynTFTComponentContainer_OnDynTFTBaseInternalRepaint;
    //ABaseEventReg.BlinkCaretState^ := nil;

    {$IFDEF RTTIREG}
      //ABaseEventReg.CompCreate^ := nil;
      //ABaseEventReg.CompDestroy^ := nil;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := nil;
    //ABaseEventReg.MouseMoveEvent := nil;
    //ABaseEventReg.MouseUpEvent := nil;
    {$IFDEF MouseClickSupport}
      //ABaseEventReg.ClickEvent := nil;
    {$ENDIF}
    {$IFDEF MouseDoubleClickSupport}
      //ABaseEventReg.DoubleClickEvent := nil;
    {$ENDIF}
    ABaseEventReg.Repaint := @TDynTFTComponentContainer_OnDynTFTBaseInternalRepaint;
    //ABaseEventReg.BlinkCaretState := nil;
    {$IFDEF RTTIREG}
      //ABaseEventReg.CompCreate := nil;
      //ABaseEventReg.CompDestroy := nil;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    //ABaseEventReg.CompSize := 0; //change this when allocating extra component on a screen container
  {$ENDIF}

  ContainerComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}
end;


procedure DynTFTInitComponentContainers;
var
  i, n: Integer;
begin
  RegisterComponentContainerEvents;  {$IFDEF IsDesktop}DynTFT_DebugConsole('ComponentContainer type: ' + IntToStr(DynTFTGetComponentContainerComponentType));{$ENDIF}

  n := Integer(CDynTFTMaxComponentsContainer) - 1;
  for i := 0 to n do
  begin
    DynTFTAllComponentsContainer[i].PressedComponent := nil;
    DynTFTAllComponentsContainer[i].SomeButtonDownScr := False;
    DynTFTAllComponentsContainer[i].Active := True;

    {$IFDEF IsMCU}
      GetMem(DynTFTAllComponentsContainer[i].ScreenContainer, SizeOf(TDynTFTComponent));
      if DynTFTAllComponentsContainer[i].ScreenContainer = nil then
      begin
        DisplayOutOfMemory(CL_BLUE);
        Exit;
      end;  
    {$ELSE}
      GetMem(TPtr(DynTFTAllComponentsContainer[i].ScreenContainer), SizeOf(TDynTFTComponent));

      if DynTFTAllComponentsContainer[i].ScreenContainer = nil then
        raise Exception.Create(COUTOFMEMORYMESSAGE + #13#10 + 'CL_BLUE');
    {$ENDIF}

    DynTFTAllComponentsContainer[i].ScreenContainer^.BaseComponent := nil;
    DynTFTAllComponentsContainer[i].ScreenContainer^.NextSibling := nil;

    DynTFTAllComponentsContainer[i].ScreenColor := 0;
  end;
end;  


procedure DynTFTInitInputDevStateFlags;
begin
  DynTFTReceivedMouseDown := False;
  DynTFTReceivedMouseUp := False;
  DynTFTReceivedComponentVisualStateChange := False;
  
  DynTFTGBlinkingCaretStatus := False;
  DynTFTGOldBlinkingCaretStatus := False;
end;

///=======================

function DynTFTPointOverComponent(AComp: PDynTFTBaseComponent; X, Y: Integer): Boolean;
begin
  Result := True;
                   //mikroPascal PRO for IsMCU v3.3.3 does not have a "complete boolean eval" option to be turned off, so make individual evaluations
  if X < AComp^.BaseProps.Left then
  begin
    Result := False;
    Exit;
  end;

  if Y < AComp^.BaseProps.Top then
  begin
    Result := False;
    Exit;
  end;

  if X > AComp^.BaseProps.Left + AComp^.BaseProps.Width then
  begin
    Result := False;
    Exit;
  end;

  if Y > AComp^.BaseProps.Top + AComp^.BaseProps.Height then
  begin
    Result := False;
    Exit;
  end;
end;


function DynTFTMouseOverComponent(AComp: PDynTFTBaseComponent): Boolean;
begin
  Result := DynTFTPointOverComponent(AComp, DynTFTMCU_XMouse, DynTFTMCU_YMouse);
end;


//verifies for partial overlapping
function ComponentOverlapsComponent(OverlappingComp, OverlappedComp: PDynTFTBaseComponent): Boolean;
var
  x1, y1, x2, y2: Integer;
begin
  Result := False;
  //A component overlaps another if at least one of its corners is above the area defined by the overlapped.

  x1 := OverlappingComp^.BaseProps.Left;
  y1 := OverlappingComp^.BaseProps.Top;
  x2 := x1 + OverlappingComp^.BaseProps.Width;
  y2 := y1 + OverlappingComp^.BaseProps.Height;
  
  if DynTFTPointOverComponent(OverlappedComp, x1, y1) then
  begin
    Result := True;
    Exit;
  end;

  if DynTFTPointOverComponent(OverlappedComp, x2, y1) then
  begin
    Result := True;
    Exit;
  end;

  if DynTFTPointOverComponent(OverlappedComp, x1, y2) then
  begin
    Result := True;
    Exit;
  end;

  if DynTFTPointOverComponent(OverlappedComp, x2, y2) then
  begin
    Result := True;
    Exit;
  end;
end;


function DynTFTIsDrawableComponent(AComp: PDynTFTBaseComponent): Boolean;
begin
  Result := True;

  if not DynTFTAllComponentsContainer[AComp^.BaseProps.ScreenIndex].Active then
  begin
    Result := False;
    Exit;
  end;

  if AComp^.BaseProps.Visible = CHIDDEN then
  begin
    Result := False;
    Exit;
  end;

  if (AComp^.BaseProps.Width = 0) or (AComp^.BaseProps.Height = 0) then
  begin
    Result := False;
    Exit;
  end;
end;



procedure OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].Repaint) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].Repaint^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].Repaint <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].Repaint^(ABase, FullRepaint, Options, ComponentFromArea);       
  //debug code for Delphi on else case ... because the repaint handler must be assigned /////////////////////////////////////////////////////////
end;


procedure OnDynTFTBaseInternalBlinkCaretState(ABase: PDynTFTBaseComponent);
var
  ComponentTypeIndex: Integer;
begin
  ComponentTypeIndex := ABase^.BaseProps.ComponentType;

  //Internal handler
  {$IFDEF IsDesktop}
    if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState) then
      if Assigned(DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState^) then
  {$ELSE}
    if DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState <> nil then
  {$ENDIF}
      DynTFTRegisteredComponents[ComponentTypeIndex].BlinkCaretState^(ABase);
end;


procedure DynTFTShowComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLSHOW;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTHideComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLHIDE;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTShowComponentWithDelay(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLSHOWLATER;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTHideComponentWithDelay(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Visible := AComp^.BaseProps.Visible or CWILLHIDELATER;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTEnableComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Enabled := AComp^.BaseProps.Enabled or CWILLENABLE;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTDisableComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Enabled := AComp^.BaseProps.Enabled or CWILLDISABLE;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTFocusComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Focused := AComp^.BaseProps.Focused or CWILLFOCUS;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure DynTFTUnfocusComponent(AComp: PDynTFTBaseComponent);
begin
  if AComp = nil then
    Exit;
    
  AComp^.BaseProps.Focused := AComp^.BaseProps.Focused or CWILLUNFOCUS;
  DynTFTReceivedComponentVisualStateChange := True;
end;


procedure SetComponentVisualState(ABase: PDynTFTBaseComponent);
begin
  if ABase = nil then
    Exit;

  if ABase^.BaseProps.Visible and CWILLHIDE = CWILLHIDE then
  begin
    ABase^.BaseProps.Visible := CHIDDEN;
    OnDynTFTBaseInternalRepaint(ABase, True, CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT, nil);
    OnDynTFTBaseInternalRepaint(PDynTFTBaseComponent(TPtrRec(ABase^.BaseProps.Parent)), True, CCLEARAREAREPAINT, ABase);
  end;

  if ABase^.BaseProps.Visible and CWILLSHOW = CWILLSHOW then
  begin
    ABase^.BaseProps.Visible := CVISIBLE;
    OnDynTFTBaseInternalRepaint(ABase, True, CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT, nil);
    OnDynTFTBaseInternalRepaint(ABase, True, CNORMALREPAINT, nil);
  end;

  if ABase^.BaseProps.Visible and CWILLHIDELATER = CWILLHIDELATER then
  begin
    ABase^.BaseProps.Visible := ABase^.BaseProps.Visible xor CWILLHIDELATER;
    DynTFTHideComponent(ABase);
  end;

  if ABase^.BaseProps.Visible and CWILLSHOWLATER = CWILLSHOWLATER then
  begin
    ABase^.BaseProps.Visible := ABase^.BaseProps.Visible xor CWILLSHOWLATER;
    DynTFTShowComponent(ABase);
  end;
  

  if ABase^.BaseProps.Enabled and CWILLDISABLE = CWILLDISABLE then
  begin
    ABase^.BaseProps.Enabled := CDISABLED;
    OnDynTFTBaseInternalRepaint(ABase, True, CAFTERDISABLEREPAINT, nil);
  end;

  if ABase^.BaseProps.Enabled and CWILLENABLE = CWILLENABLE then
  begin
    ABase^.BaseProps.Enabled := CENABLED;
    OnDynTFTBaseInternalRepaint(ABase, True, CAFTERENABLEREPAINT, nil);
  end;

  if ABase^.BaseProps.Focused and CWILLFOCUS = CWILLFOCUS then
  begin
    ABase^.BaseProps.Focused := CFOCUSED;
    OnDynTFTBaseInternalRepaint(ABase, True, CREPAINTONSTARTUP, nil);   /////////// use CREPAINTONSTARTUP until proper implementation 
  end;

  if ABase^.BaseProps.Focused and CWILLUNFOCUS = CWILLUNFOCUS then
  begin
    ABase^.BaseProps.Focused := CUNFOCUSED;
    OnDynTFTBaseInternalRepaint(ABase, True, CREPAINTONSTARTUP, nil);   /////////// use CREPAINTONSTARTUP until proper implementation
  end;

  {$IFDEF RTTIREG}
    if ABase^.BaseProps.Focused and CWILLDESTROY = CWILLDESTROY then
      DynTFTComponent_DestroyFromReg(ABase);
  {$ENDIF}  
end;


procedure DynTFTProcessComponentVisualState(ScreenIndex: Byte);
var
  ParentComponent: PDynTFTComponent;
begin
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  repeat
    SetComponentVisualState(PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent)));
          
    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;


procedure DynTFTBlinkCaretsForScreenComponents(ScreenIndex: Byte);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
begin
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase^.BaseProps.Visible = CVISIBLE then
      if ABase^.BaseProps.Focused and CFOCUSED = CFOCUSED then
        OnDynTFTBaseInternalBlinkCaretState(ABase);
          
    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;


procedure DynTFTRepaintScreenComponents(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
begin
  {$IFDEF IsDesktop}
    if DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer = nil then
    begin
      DynTFT_DebugConsole('DynTFT is not initialized. Make sure the simulation is running. It should have called DynTFT_GUI_Start on start.');
      Exit;
    end;
  {$ENDIF}

  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase^.BaseProps.Visible = CVISIBLE then
    begin
      if ComponentAreaOnly = nil then
        OnDynTFTBaseInternalRepaint(ABase, True, PaintOptions, nil)
      else
        if ComponentOverlapsComponent(ABase, ComponentAreaOnly) then
          if ABase <> ComponentAreaOnly then
            OnDynTFTBaseInternalRepaint(ABase, True, PaintOptions, nil);
    end;

    SetComponentVisualState(ABase);  
    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;                                                         
end;


procedure DynTFTRepaintScreen(ScreenIndex: Byte; PaintOptions: TPtr; ComponentAreaOnly: PDynTFTBaseComponent);
begin
  {$IFDEF IsDesktop}
    if DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer = nil then
    begin
      DynTFT_DebugConsole('DynTFT is not initialized. Make sure the simulation is running. It should have called DynTFT_GUI_Start on start.');
      Exit;
    end;
  {$ENDIF}

  DynTFT_Set_Pen(DynTFTAllComponentsContainer[ScreenIndex].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[ScreenIndex].ScreenColor, 0, 0, 0, 0);

  DynTFT_Rectangle(0, 0, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);
  DynTFTRepaintScreenComponents(ScreenIndex, PaintOptions, ComponentAreaOnly);
end;


procedure DynTFTRepaintScreenComponentsFromArea(ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTClearComponentAreaWithScreenColor(ComponentFromArea);
  DynTFTRepaintScreenComponents(ComponentFromArea^.BaseProps.ScreenIndex, CNORMALREPAINT, ComponentFromArea);
end;


function DynTFTPositiveLimit(ANumber: LongInt): LongInt;
begin
  if ANumber < 0 then
    Result := 0
  else
    Result := ANumber;
end;


function DynTFTOrdBoolWord(ABool: Boolean): Word;
begin
  if ABool then
    Result := 1
  else
    Result := 0;
end;


procedure DynTFTChangeComponentPosition(AComp: PDynTFTBaseComponent; NewLeft, NewTop: TSInt);
begin
  DynTFTClearComponentAreaWithScreenColor(AComp);
  AComp^.BaseProps.Left := NewLeft;
  AComp^.BaseProps.Top := NewTop;
  //DynTFTRepaintScreenComponentsFromArea(AComp);
  OnDynTFTBaseInternalRepaint(AComp, True, CNORMALREPAINT, nil);
end;



{$IFDEF IsDesktop}
  procedure DynTFTDisplayErrorOnStringConstLength(AStringConstLength: Integer; ComponentDataTypeName: string);
  var
    SizeOfPointer: Integer;
    Example: string;
  begin
    SizeOfPointer := SizeOf(TPtr);
    if (AStringConstLength + 1) mod 4 {SizeOfPointer} <> 0 then       // SizeOfPointer will be 8 on 64-bit, which will cause these warnings to appear. Missaligned 64-bit pointes on desktop might still work.
    begin
      Example := IntToStr(2 * SizeOfPointer - 1) + ', ' + IntToStr(3 * SizeOfPointer - 1) + ', ' + IntToStr(4 * SizeOfPointer - 1);
      DynTFT_DebugConsole('The length of a string constant might cause misaligned pointers in ' + ComponentDataTypeName + ' structure. Currently, it is ' + IntToStr(AStringConstLength) + '.');
      DynTFT_DebugConsole('This string length may need to be of "n * SizeOf(TPtr) - 1" format, e.g.: ' + Example + ' etc.');
      DynTFT_DebugConsole('The structure members, defined after the string, will be allocated at missaligned addresses.');
      DynTFT_DebugConsole('');
    end;
  end;
{$ENDIF}


{$IFDEF IsDesktop}
  var
    iii: Integer;
  begin
    for iii := 0 to CDynTFTMaxComponentsContainer - 1 do
      DynTFTAllComponentsContainer[iii].ScreenContainer := nil;

    {$IFDEF MouseDoubleClickSupport}
      DynTFTGetTickCount := 100;
      DynTFTOldGetTickCount := 0;
    {$ENDIF}
{$ENDIF}

end.