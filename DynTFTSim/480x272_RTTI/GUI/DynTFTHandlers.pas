
{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

unit DynTFTHandlers;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  {$IFDEF UseSmallMM}
    DynTFTSmallMM,
  {$ELSE}
    {$IFDEF IsDesktop}
      MemManager,
    {$ENDIF}  
  {$ENDIF} //this must be the first unit, at least in Delphi, because it exports GetMem.

  DynTFTTypes, DynTFTConsts, DynTFTUtils, DynTFTBaseDrawing, DynTFTControls,
  DynTFTGUIObjects,


//<DynTFTComponents>
  DynTFTButton,
  DynTFTArrowButton,
  DynTFTPanel,
  DynTFTCheckBox,
  DynTFTScrollBar,
  DynTFTItems,
  DynTFTListBox,
  DynTFTLabel,
  DynTFTRadioButton,
  DynTFTRadioGroup,
  DynTFTTabButton,
  DynTFTPageControl,
  DynTFTEdit,
  DynTFTKeyButton,
  DynTFTVirtualKeyboard,
  DynTFTComboBox,
  DynTFTTrackBar,
  DynTFTProgressBar,
  DynTFTMessageBox
//<EndOfDynTFTComponents> - Do not remove or modify this line!

  {$IFDEF IsDesktop}
    ,SysUtils, Forms
    {$IFDEF DynTFTFontSupport}, DynTFTFonts {$ENDIF}
  {$ENDIF}

  {$IFNDEF UserTFTCommands}
    {$IFDEF IsDesktop} , TFT {$ENDIF}
  {$ELSE}
    , {$I UserDrawingUnits.inc}
  {$ENDIF}

  {$I DynTFTHandlersAdditionalUnits.inc}
  ;

//CodegenSym:GroupsBegin
procedure CreateGUIGrp_First;
procedure DestroyGUIGrp_First;
procedure CreateGUIGrp_Second;
procedure DestroyGUIGrp_Second;
procedure CreateGUIGrp_Third;
procedure DestroyGUIGrp_Third;
procedure CreateGUIGrp_Fourth;
procedure DestroyGUIGrp_Fourth;
procedure CreateGUIGrp_Fifth;
procedure DestroyGUIGrp_Fifth;
procedure CreateGUIGrp_Sixth;
procedure DestroyGUIGrp_Sixth;
//CodegenSym:GroupsEnd

procedure VirtualKeyboard_OnCharKey(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr); //CodegenSym:header
procedure VirtualKeyboard_OnSpecialKey(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr); //CodegenSym:header
procedure ListBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:header
procedure ComboBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:header
procedure btnShowMessageBox_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header
procedure PageControl1_OnChange(Sender: PPtrRec); //CodegenSym:header
procedure TrackBar1_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:header
procedure TrackBar2_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:header
procedure DynTFTButton0_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:header

//CodegenSym:AllBinHandlersBegin

{$IFDEF RTTIREG}

  procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);   //If a compiler complains about missing implementation, probably regenerating the output files from DynTFTCodeGen, will fix the issue.
  procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);  //If a compiler complains about missing implementation, probably regenerating the output files from DynTFTCodeGen, will fix the issue.

  {$IFDEF IsDesktop} {$IFDEF DesktopApp_D2006} // Profile: "DesktopApp_D2006"
    // No handlers are used in the array of handlers for profile "DesktopApp_D2006".
    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsDesktop

  {$IFDEF IsMCU} {$IFDEF PIC32App} // Profile: "PIC32App"
    // No handlers are used in the array of handlers for profile "PIC32App".
    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsMCU

  {$IFDEF IsDesktop} {$IFDEF DesktopApp_D10_2} // Profile: "DesktopApp_D10_2"
    // No handlers are used in the array of handlers for profile "DesktopApp_D10_2".
    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsDesktop

  {$IFDEF IsDesktop} {$IFDEF DesktopApp_FP} // Profile: "DesktopApp_FP"
    // No handlers are used in the array of handlers for profile "DesktopApp_FP".
    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsDesktop

  {$IFDEF IsMCU} {$IFDEF PIC32AppAddrArr} // Profile: "PIC32AppAddrArr"
      var
        AllBinHandlers: array[0..6] of TPtr;

      procedure UpdateAllBinHandlerAddressArray;

    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsMCU

  {$IFDEF IsMCU} {$IFDEF PIC32AppWithSDCard} // Profile: "PIC32AppWithSDCard"
    // No handlers are used in the array of handlers for profile "PIC32AppWithSDCard".
    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsMCU

  {$IFDEF IsMCU} {$IFDEF PIC32AppDWithSDCard} // Profile: "PIC32AppDWithSDCard"
    // No handlers are used in the array of handlers for profile "PIC32AppDWithSDCard".
    procedure LinkHandlers;
  {$ENDIF} {$ENDIF} // IsMCU

  {$IFDEF IsDesktop}
      var
        AllBinHandlersStr: array[0..5] of string;
        AllBinHandlersAddresses: array[0..5] of TPtr;

        AllBinIdentifiersStr: array[0..0] of string;
        AllBinIdentifiersAddresses: array[0..0] of TPtr;

      procedure UpdateAllBinHandlerStrArray;
  {$ENDIF}
{$ENDIF} // RTTIREG

//CodegenSym:AllBinHandlersEnd

implementation

//CodegenSym:UpdateBinHandlersProcBegin
{$IFDEF RTTIREG}
  {$IFDEF IsDesktop} {$IFDEF DesktopApp_D2006} // Profile: "DesktopApp_D2006"
    // No handlers are used in the array of handlers for profile "DesktopApp_D2006".
    // It means that all handlers, fonts etc, have addresses in C_RTTI_CreateInstructionData from lst file.

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTICreateCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTIDestroyCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsDesktop {$IFDEF DesktopApp_D2006}

  {$IFDEF IsMCU} {$IFDEF PIC32App} // Profile: "PIC32App"
    // No handlers are used in the array of handlers for profile "PIC32App".
    // It means that all handlers, fonts etc, have addresses in C_RTTI_CreateInstructionData from lst file.

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
    begin
      GetDataCallback := nil;  // no data provider callback is used. ExecuteRTTIInstructions expects that "C_RTTI_CreateInstructionData" holds all instructions.
      ExecuteRTTIInstructions(@C_RTTI_CreateInstructionData, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
    begin
      GetDataCallback := nil;  // no data provider callback is used. ExecuteRTTIInstructions expects that "C_RTTI_DestroyInstructionData" holds all instructions.
      ExecuteRTTIInstructions(@C_RTTI_DestroyInstructionData, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsMCU {$IFDEF PIC32App}

  {$IFDEF IsDesktop} {$IFDEF DesktopApp_D10_2} // Profile: "DesktopApp_D10_2"
    // No handlers are used in the array of handlers for profile "DesktopApp_D10_2".
    // It means that all handlers, fonts etc, have addresses in C_RTTI_CreateInstructionData from lst file.

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
    begin
      GetDataCallback := nil;  // no data provider callback is used. ExecuteRTTIInstructions expects that "C_RTTI_CreateInstructionData" holds all instructions.
      ExecuteRTTIInstructions(@C_RTTI_CreateInstructionData, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
    begin
      GetDataCallback := nil;  // no data provider callback is used. ExecuteRTTIInstructions expects that "C_RTTI_DestroyInstructionData" holds all instructions.
      ExecuteRTTIInstructions(@C_RTTI_DestroyInstructionData, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsDesktop {$IFDEF DesktopApp_D10_2}

  {$IFDEF IsDesktop} {$IFDEF DesktopApp_FP} // Profile: "DesktopApp_FP"
    // No handlers are used in the array of handlers for profile "DesktopApp_FP".
    // It means that all handlers, fonts etc, have addresses in C_RTTI_CreateInstructionData from lst file.

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTICreateCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTIDestroyCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsDesktop {$IFDEF DesktopApp_FP}

  {$IFDEF IsMCU} {$IFDEF PIC32AppAddrArr} // Profile: "PIC32AppAddrArr"
      procedure UpdateAllBinHandlerAddressArray;
      begin
        AllBinHandlers[0] := TPtr(@Verdana29x32_ItalicUnderLine);
        AllBinHandlers[1] := TPtr(@DynTFTButton0_OnMouseUpUser);
        AllBinHandlers[2] := TPtr(@VirtualKeyboard_OnCharKey);
        AllBinHandlers[3] := TPtr(@VirtualKeyboard_OnSpecialKey);
        AllBinHandlers[4] := TPtr(@TrackBar1_OnTrackBarChange);
        AllBinHandlers[5] := TPtr(@TrackBar2_OnTrackBarChange);
        AllBinHandlers[6] := TPtr(@btnShowMessageBox_OnMouseUpUser);
      end;

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
    begin
      GetDataCallback := nil;  // no data provider callback is used. ExecuteRTTIInstructions expects that "C_RTTI_CreateInstructionData" holds all instructions.
      ExecuteRTTIInstructions(@C_RTTI_CreateInstructionData, @CAllCreatedBinComponents, @AllBinHandlers, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
    begin
      GetDataCallback := nil;  // no data provider callback is used. ExecuteRTTIInstructions expects that "C_RTTI_DestroyInstructionData" holds all instructions.
      ExecuteRTTIInstructions(@C_RTTI_DestroyInstructionData, @CAllCreatedBinComponents, @AllBinHandlers, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsMCU {$IFDEF PIC32AppAddrArr}

  {$IFDEF IsMCU} {$IFDEF PIC32AppWithSDCard} // Profile: "PIC32AppWithSDCard"
    // No handlers are used in the array of handlers for profile "PIC32AppWithSDCard".
    // It means that all handlers, fonts etc, have addresses in C_RTTI_CreateInstructionData from lst file.

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTICreateCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTIDestroyCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsMCU {$IFDEF PIC32AppWithSDCard}

  {$IFDEF IsMCU} {$IFDEF PIC32AppDWithSDCard} // Profile: "PIC32AppDWithSDCard"
    // No handlers are used in the array of handlers for profile "PIC32AppDWithSDCard".
    // It means that all handlers, fonts etc, have addresses in C_RTTI_CreateInstructionData from lst file.

    procedure ExecuteDesignRTTIInstructions_Create(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTICreateCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure ExecuteDesignRTTIInstructions_Destroy(Filter: Byte);
    var
      GetDataCallback: {$IFDEF IsDesktop} TDynTFTExecRTTIInstructionCallback {$ELSE} PDynTFTExecRTTIInstructionCallback {$ENDIF};
      InstructionBuffer: array[0..255] of Byte;
    begin
      GetDataCallback := {$IFDEF IsMCU} @ {$ENDIF} RTTIDestroyCallback;  //user defined callback (see TDynTFTExecRTTIInstructionCallback from DynTFTTypes.pas)
      ExecuteRTTIInstructions(@InstructionBuffer, @CAllCreatedBinComponents, nil, Filter, GetDataCallback);
    end;

    procedure LinkHandlers;
    {$IFDEF IsMCU}
      var
        Dummy: DWord; volatile;
    {$ENDIF}
    begin
      SetFuncCall(DynTFTButton0_OnMouseUpUser);
      SetFuncCall(VirtualKeyboard_OnCharKey);
      SetFuncCall(VirtualKeyboard_OnSpecialKey);
      SetFuncCall(TrackBar1_OnTrackBarChange);
      SetFuncCall(TrackBar2_OnTrackBarChange);
      SetFuncCall(btnShowMessageBox_OnMouseUpUser);
      {$IFDEF IsMCU}
        Dummy := DWord(@(Verdana29x32_ItalicUnderLine));  // If identifier is not found, please add its unit to DynTFTHandlersAdditionalUnits.inc, using "{$IFDEF IsMCU}" compiler directive.
      {$ENDIF}
    end;
  {$ENDIF} {$ENDIF} // IsMCU {$IFDEF PIC32AppDWithSDCard}


  {$IFDEF IsDesktop}
      procedure UpdateAllBinHandlerStrArray;
      begin
        AllBinHandlersStr[0] := '_DynTFTButton0_OnMouseUpUser';
        AllBinHandlersStr[1] := '_VirtualKeyboard_OnCharKey';
        AllBinHandlersStr[2] := '_VirtualKeyboard_OnSpecialKey';
        AllBinHandlersStr[3] := '_TrackBar1_OnTrackBarChange';
        AllBinHandlersStr[4] := '_TrackBar2_OnTrackBarChange';
        AllBinHandlersStr[5] := '_btnShowMessageBox_OnMouseUpUser';

        AllBinHandlersAddresses[0] := TPtr(@DynTFTButton0_OnMouseUpUser);
        AllBinHandlersAddresses[1] := TPtr(@VirtualKeyboard_OnCharKey);
        AllBinHandlersAddresses[2] := TPtr(@VirtualKeyboard_OnSpecialKey);
        AllBinHandlersAddresses[3] := TPtr(@TrackBar1_OnTrackBarChange);
        AllBinHandlersAddresses[4] := TPtr(@TrackBar2_OnTrackBarChange);
        AllBinHandlersAddresses[5] := TPtr(@btnShowMessageBox_OnMouseUpUser);

        AllBinIdentifiersStr[0] := '_Verdana29x32_ItalicUnderLine';

        AllBinIdentifiersAddresses[0] := TPtr(@CAllFontSettings[0]);
      end;
  {$ENDIF}
{$ENDIF} // RTTIREG

//CodegenSym:UpdateBinHandlersProcEnd

//CodegenSym:CreationGroups
procedure CreateGUIGrp_First;
begin


  {$IFDEF RTTIREG}
    //Group "First"   at index: 0
    ExecuteDesignRTTIInstructions_Create(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 0);
  {$ENDIF}
end;

procedure DestroyGUIGrp_First;
begin


  {$IFDEF RTTIREG}
    //Group "First"   at index: 0
    ExecuteDesignRTTIInstructions_Destroy(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 0);
  {$ENDIF}
end;


procedure CreateGUIGrp_Second;
begin


  {$IFDEF RTTIREG}
    //Group "Second"   at index: 1
    ExecuteDesignRTTIInstructions_Create(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 1);
  {$ENDIF}
end;

procedure DestroyGUIGrp_Second;
begin


  {$IFDEF RTTIREG}
    //Group "Second"   at index: 1
    ExecuteDesignRTTIInstructions_Destroy(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 1);
  {$ENDIF}
end;


procedure CreateGUIGrp_Third;
begin

  rdgrpTest := DynTFTRadioGroup_Create(3, 9, 93, 160, 160);
  PDynTFTRadioGroup_CreateAllRadioButtons(9 + 5, 93 + 17 +  - 1, 160 - 5 - 6, 17, 8, rdgrpTest, CrdgrpTest_Captions);
  {$DEFINE rdgrpTest_Enabled_1}
  {$IFDEF rdgrpTest_Enabled_0}
    DynTFTDisableRadioGroup(rdgrpTest);
  {$ENDIF}
  rdgrpTest^.Caption := C_rdgrpTest_Caption; //'Radio Group 1'
  rdgrpTest^.ItemIndex := 2;

  rdgrpTest1 := DynTFTRadioGroup_Create(3, 249, 93, 160, 160);
  PDynTFTRadioGroup_CreateAllRadioButtons(249 + 5, 93 + 17 +  - 1, 160 - 5 - 6, 17, 8, rdgrpTest1, CrdgrpTest1_Captions);
  {$DEFINE rdgrpTest1_Enabled_1}
  {$IFDEF rdgrpTest1_Enabled_0}
    DynTFTDisableRadioGroup(rdgrpTest1);
  {$ENDIF}
  rdgrpTest1^.Caption := C_rdgrpTest1_Caption; //'Radio Group 2'
  rdgrpTest1^.ItemIndex := 2;

  {$IFDEF RTTIREG}
    //Group "Third"   at index: 2
    ExecuteDesignRTTIInstructions_Create(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 2);
  {$ENDIF}
end;

procedure DestroyGUIGrp_Third;
begin
  DynTFTRadioGroup_Destroy(rdgrpTest);
  DynTFTRadioGroup_Destroy(rdgrpTest1);

  {$IFDEF RTTIREG}
    //Group "Third"   at index: 2
    ExecuteDesignRTTIInstructions_Destroy(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 2);
  {$ENDIF}
end;


procedure CreateGUIGrp_Fourth;
begin


  {$IFDEF RTTIREG}
    //Group "Fourth"   at index: 3
    ExecuteDesignRTTIInstructions_Create(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 3);
  {$ENDIF}
end;

procedure DestroyGUIGrp_Fourth;
begin


  {$IFDEF RTTIREG}
    //Group "Fourth"   at index: 3
    ExecuteDesignRTTIInstructions_Destroy(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 3);
  {$ENDIF}
end;


procedure CreateGUIGrp_Fifth;
begin


  {$IFDEF RTTIREG}
    //Group "Fifth"   at index: 4
    ExecuteDesignRTTIInstructions_Create(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 4);
  {$ENDIF}
end;

procedure DestroyGUIGrp_Fifth;
begin


  {$IFDEF RTTIREG}
    //Group "Fifth"   at index: 4
    ExecuteDesignRTTIInstructions_Destroy(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 4);
  {$ENDIF}
end;


procedure CreateGUIGrp_Sixth;
begin


  {$IFDEF RTTIREG}
    //Group "Sixth"   at index: 5
    ExecuteDesignRTTIInstructions_Create(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 5);
  {$ENDIF}
end;

procedure DestroyGUIGrp_Sixth;
begin


  {$IFDEF RTTIREG}
    //Group "Sixth"   at index: 5
    ExecuteDesignRTTIInstructions_Destroy(CDynTFT_InstructionFilter_CreateSingleGroup_BitMask or 5);
  {$ENDIF}
end;



//CodegenSym:HandlersImplementation

procedure VirtualKeyboard_OnCharKey(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr); //CodegenSym:handler
var
  AText: string {$IFNDEF IsDesktop}[CMaxKeyButtonStringLength] {$ENDIF};
begin //CodegenSym:handler:begin
  if PDynTFTVirtualKeyboard(TPtrRec(Sender))^.ShiftState and CDYNTFTSS_CTRL = CDYNTFTSS_CTRL then
    Exit;

  if PDynTFTVirtualKeyboard(TPtrRec(Sender))^.ShiftState and CDYNTFTSS_ALT = CDYNTFTSS_ALT then
    Exit;

  AText := PressedChar;
  DynTFTEditInsertTextAtCaret(Edit1, AText);

  if Edit1^.BaseProps.Focused and CFOCUSED <> CFOCUSED then
    DynTFTFocusComponent(PDynTFTBaseComponent(TPtrRec(Edit1)));
end; //CodegenSym:handler:end


procedure VirtualKeyboard_OnSpecialKey(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr); //CodegenSym:handler
begin //CodegenSym:handler:begin
  case SpecialKey of
    VK_BACK : DynTFTEditBackspaceAtCaret(Edit1);

    VK_DELETE :
    begin
      if CurrentShiftState and CDYNTFTSS_CTRL_ALT = CDYNTFTSS_CTRL_ALT then  
        {$IFNDEF IsDesktop}
          Reset;
        {$ELSE}
          Application.MainForm.Close;
        {$ENDIF}
      DynTFTEditDeleteAtCaret(Edit1);
    end;

    VK_LEFT: DynTFTMoveEditCaretToLeft(Edit1, 1);

    VK_RIGHT: DynTFTMoveEditCaretToRight(Edit1, 1);

    VK_HOME: DynTFTMoveEditCaretToHome(Edit1);

    VK_END: DynTFTMoveEditCaretToEnd(Edit1);
  end;
end; //CodegenSym:handler:end


procedure ListBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:handler
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    ItemText := IntToStr(Index);
  {$ELSE}
    IntToStr(Index, ItemText);
  {$ENDIF}
end; //CodegenSym:handler:end


procedure ComboBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string); //CodegenSym:handler
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    ItemText := IntToStr(Index);
  {$ELSE}
    IntToStr(Index, ItemText);
  {$ENDIF}
end; //CodegenSym:handler:end


procedure btnShowMessageBox_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
var
  AButton: PDynTFTButton;
  Res: Integer;                                
  MBMsg: string {$IFNDEF IsDesktop}[CMaxMessageBoxTextLength] {$ENDIF};
  MBTitle: string {$IFNDEF IsDesktop}[CMaxMessageBoxTitleLength] {$ENDIF};
begin //CodegenSym:handler:begin
  AButton := PDynTFTButton(TPtrRec(Sender));
  MBMsg := 'This is a very long messagebox.';
  MBTitle := 'MB Title fp';

  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('AButton $' + IntToHex(DWord(AButton), 8) + ' before showing Messagebox');
  {$ENDIF}

  ProgressBar1^.Position := 1;
  ProgressBar2^.Position := 1;
  DynTFTDrawProgressBar(ProgressBar1, False);
  DynTFTDrawProgressBar(ProgressBar2, False);

  Res := DynTFTShowMessageBox(6, MBMsg, MBTitle, CDynTFT_MB_OKCANCEL);
  //Res := DynTFTShowMessageBox(6, MBMsg, MBTitle, CDynTFT_MB_YESNO);

  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('AButton $' + IntToHex(DWord(AButton), 8) + ' after closing Messagebox: ' + IntToStr(Res));
    DynTFT_DebugConsole('');
  {$ENDIF}

  ProgressBar1^.Position := Res * 3;
  ProgressBar2^.Position := Res * 3;
  DynTFTDrawProgressBar(ProgressBar1, False);
  DynTFTDrawProgressBar(ProgressBar2, False);

  TrackBar1^.Position := ProgressBar1^.Position;
  TrackBar2^.Position := ProgressBar2^.Position;

  DynTFTDrawTrackBar(TrackBar1, False);
  DynTFTDrawTrackBar(TrackBar2, False);
end; //CodegenSym:handler:end


procedure PageControl1_OnChange(Sender: PPtrRec); //CodegenSym:handler
var
  i: Integer;
begin //CodegenSym:handler:begin
  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('--------------------------- changing tab to ' + IntToStr(PageControl1^.ActiveIndex + 1));
  {$ENDIF}

  case PageControl1^.OldActiveIndex of            //PageControl1^.ActiveIndex is not the same as the active screen index
    -1, 0: DestroyGUIGrp_First;
    1: DestroyGUIGrp_Second;
    2: DestroyGUIGrp_Third;
    3: DestroyGUIGrp_Fourth;
    4: DestroyGUIGrp_Fifth;
    5: DestroyGUIGrp_Sixth;
  end;

  case PageControl1^.ActiveIndex of            //PageControl1^.ActiveIndex is not the same as the active screen index
    0: CreateGUIGrp_First;
    1: CreateGUIGrp_Second;
    2: CreateGUIGrp_Third;
    3: CreateGUIGrp_Fourth;
    4: CreateGUIGrp_Fifth;
    5: CreateGUIGrp_Sixth;
  end;

  DynTFT_Set_Pen(DynTFTAllComponentsContainer[PageControl1^.ActiveIndex + 1].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[PageControl1^.ActiveIndex + 1].ScreenColor, 0, 0, 0, 0);
  DynTFT_Rectangle(0, 21, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);

  for i := 1 to PageControl1^.PageCount {- 1} do
  begin
    DynTFTAllComponentsContainer[i].Active := PageControl1^.ActiveIndex = i - 1;
    if DynTFTAllComponentsContainer[i].Active then
      DynTFTRepaintScreenComponents(i, CREPAINTONSTARTUP, nil);
  end;

  if PageControl1^.ActiveIndex = 0 then
  begin
    lblRTTIDataSrcInfo^.Caption := 'DataSrc ';
    
    {$IFDEF UseSDCard}
      if (C_CreateDynTFTUI_DataSourceOption and C_DestroyDynTFTUI_DataSourceOption) = 1 then
        lblRTTIDataSrcInfo^.Caption := lblRTTIDataSrcInfo^.Caption + '.dyntftui'
      else
    {$ENDIF}
      lblRTTIDataSrcInfo^.Caption := lblRTTIDataSrcInfo^.Caption + 'CodeConst';

    DynTFTDrawLabel(lblRTTIDataSrcInfo, True);  
  end;
end; //CodegenSym:handler:end


procedure TrackBar1_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  ProgressBar1^.Position := TrackBar1^.Position;
  DynTFTDrawProgressBar(ProgressBar1, False);
end; //CodegenSym:handler:end


procedure TrackBar2_OnTrackBarChange(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  ProgressBar2^.Position := TrackBar2^.Position;
  DynTFTDrawProgressBar(ProgressBar2, False);
end; //CodegenSym:handler:end


procedure DynTFTButton0_OnMouseUpUser(Sender: PPtrRec); //CodegenSym:handler
begin //CodegenSym:handler:begin
  if ListBox3^.Items^.ItemIndex < ListBox3^.Items^.Count then
    ListBox3^.Items^.ItemIndex := ListBox3^.Items^.ItemIndex + 1
  else
    ListBox3^.Items^.ItemIndex := 0;

  DynTFTDrawListBox(ListBox3, False);
  DynTFTDrawItems(ListBox3^.Items, True);
end; //CodegenSym:handler:end



end.
