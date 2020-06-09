
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

unit RTTIDataProvider;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTGUIObjects, DynTFTUtils, DynTFTBaseDrawing

  {$IFDEF IsDesktop}
    , {$IFDEF UseFAT32D} 
        DynTFTFAT32D
      {$ELSE}
        DynTFTFAT32
      {$ENDIF}
  {$ENDIF}
  ;

{$IFDEF UseSDCard}
  procedure OpenRTTIFiles;
  procedure CloseRTTIFiles;
  procedure RTTICreateCallback(ABinaryComponentsData: PDWordArray; ByteCount: TSInt);
  procedure RTTIDestroyCallback(ABinaryComponentsData: PDWordArray; ByteCount: TSInt);

  var
    {$IFDEF UseFAT32D}
      RTTI_Create_FileVar: TFileVar;
      RTTI_Destroy_FileVar: TFileVar;
    {$ELSE}
      RTTI_Create_Handle: Integer;  {$IFDEF IsMCU} external; {$ENDIF} //please initialize to -1 in your code  (before calling OpenRTTIFiles)
      RTTI_Destroy_Handle: Integer; {$IFDEF IsMCU} external; {$ENDIF} //please initialize to -1 in your code  (before calling OpenRTTIFiles)
    {$ENDIF}
{$ENDIF}

implementation


{$IFDEF UseSDCard}
  procedure OpenRTTIFiles;
  var
    FileName: string[50];
    {$IFDEF UseFAT32D} Size: DWord; {$ENDIF}
  begin
    FileName := C_CreateDynTFTUI_FileName;

    {$IFDEF UseFAT32D}
      Fat32_FileVar_Init(RTTI_Create_FileVar);
      Fat32_Assign(RTTI_Create_FileVar, {$IFDEF IsMCU}@{$ENDIF} FileName, faArchive);
      Fat32_Reset(RTTI_Create_FileVar, Size);
    {$ELSE}
      RTTI_Create_Handle := FAT32_Open({$IFDEF IsMCU}@{$ENDIF} FileName, FILE_READ_F32);
    {$ENDIF}

    FileName := C_DestroyDynTFTUI_FileName;

    {$IFDEF UseFAT32D}
      Fat32_FileVar_Init(RTTI_Destroy_FileVar);
      Fat32_Assign(RTTI_Destroy_FileVar, {$IFDEF IsMCU}@{$ENDIF} FileName, faArchive);
      Fat32_Reset(RTTI_Destroy_FileVar, Size);
    {$ELSE}
      RTTI_Destroy_Handle := FAT32_Open({$IFDEF IsMCU}@{$ENDIF} FileName, FILE_READ_F32);
    {$ENDIF}
  end;


  procedure CloseRTTIFiles;
  begin
    {$IFDEF UseFAT32D}
      Fat32_Close(RTTI_Create_FileVar);
      Fat32_Close(RTTI_Destroy_FileVar);
    {$ELSE}
      FAT32_Close(RTTI_Create_Handle);
      FAT32_Close(RTTI_Destroy_Handle);
    {$ENDIF}
  end;


  {$IFDEF UseFAT32D}
    procedure RTTICreateCallback(ABinaryComponentsData: PDWordArray; ByteCount: TSInt);
    {$IFDEF IsDesktop}
      var
        TempBuffer: TArr4096Byte;
    {$ENDIF}
    begin
      case ByteCount of
        CRTTI_DataCallBackArg_ResetFilePointer :
          //Reset to the first instruction! (can be > 0 if using header)
          FAT32_Seek(RTTI_Create_FileVar, 0);

        CRTTI_DataCallBackArg_GetDataBuildNumber :
          ABinaryComponentsData^[0] := C_DynTFTUI_BuildNumber
        else
        begin
          {$IFDEF IsDesktop}
            if Fat32_ReadBuffer(RTTI_Create_FileVar,
                                TempBuffer,
                                ByteCount) <= 0 then
          {$ELSE}
            if Fat32_ReadBuffer(RTTI_Create_FileVar,
                                PByte(TPtr(ABinaryComponentsData)),
                                ByteCount) <= 0 then
          {$ENDIF}
          begin
            //stops execution, if this is the first DWord of an instruction
            ABinaryComponentsData^[0] := 0;
            {$IFDEF IsDesktop}
              DynTFT_DebugConsole('Reached end of file, or file not found in RTTI create.');
            {$ELSE}
              //make sure FAT32 is initialized
              DynTFTDisplayErrorMessage(CRTTIDATAPROVIDERREADERR, CL_RED);
            {$ENDIF}
          end
          else
          {$IFDEF IsDesktop}
            memcpy(PByte(TPtr(ABinaryComponentsData)), @TempBuffer, ByteCount);
          {$ENDIF}
        end;
      end; //case
    end;
  {$ELSE}
    procedure RTTICreateCallback(ABinaryComponentsData: PDWordArray; ByteCount: TSInt);
    begin
      case ByteCount of
        CRTTI_DataCallBackArg_ResetFilePointer :
          //Reset to the first instruction! (can be > 0 if using header)
          FAT32_Seek(RTTI_Create_Handle, 0);

        CRTTI_DataCallBackArg_GetDataBuildNumber :
          ABinaryComponentsData^[0] := C_DynTFTUI_BuildNumber

        else
          if FAT32_Read(RTTI_Create_Handle,
                        PByteArray(TPtr(ABinaryComponentsData)),
                        ByteCount) = -1 then
          begin
            //stops execution, if this is the first DWord of an instruction
            ABinaryComponentsData^[0] := 0;
            {$IFDEF IsDesktop}
              DynTFT_DebugConsole('Reached end of file, or file not found in RTTI create.');
            {$ELSE}
              //make sure FAT32 is initialized
              DynTFTDisplayErrorMessage(CRTTIDATAPROVIDERREADERR, CL_RED);
            {$ENDIF}
          end;
      end; //case
    end;
  {$ENDIF}


  {$IFDEF UseFAT32D}
    procedure RTTIDestroyCallback(ABinaryComponentsData: PDWordArray; ByteCount: TSInt);
    {$IFDEF IsDesktop}
      var
        TempBuffer: TArr4096Byte;
    {$ENDIF}
    begin
      case ByteCount of
        CRTTI_DataCallBackArg_ResetFilePointer :
        //Reset to the first instruction! (can be > 0 if using header)
          FAT32_Seek(RTTI_Destroy_FileVar, 0);

        CRTTI_DataCallBackArg_GetDataBuildNumber :
          ABinaryComponentsData^[0] := C_DynTFTUI_BuildNumber

        else
        begin
          {$IFDEF IsDesktop}
            if Fat32_ReadBuffer(RTTI_Destroy_FileVar,
                                TempBuffer,
                                ByteCount) <= 0 then
          {$ELSE}
            if Fat32_ReadBuffer(RTTI_Destroy_FileVar,
                                PByte(TPtr(ABinaryComponentsData)),
                                ByteCount) <= 0 then
          {$ENDIF}
          begin
            //stops execution, if this is the first DWord of an instruction
            ABinaryComponentsData^[0] := 0;
            {$IFDEF IsDesktop}
              DynTFT_DebugConsole('Reached end of file, or file not found in RTTI destroy.');
            {$ELSE}
              //make sure FAT32 is initialized
              DynTFTDisplayErrorMessage(CRTTIDATAPROVIDERREADERR, CL_RED);
            {$ENDIF}
          end
          else
          {$IFDEF IsDesktop}
            memcpy(PByte(TPtr(ABinaryComponentsData)), @TempBuffer, ByteCount);
          {$ENDIF}
        end;
      end; //case
    end;
  {$ELSE}
    procedure RTTIDestroyCallback(ABinaryComponentsData: PDWordArray; ByteCount: TSInt);
    begin
      case ByteCount of
        CRTTI_DataCallBackArg_ResetFilePointer :
          //Reset to the first instruction! (can be > 0 if using header)
          FAT32_Seek(RTTI_Destroy_Handle, 0);

        CRTTI_DataCallBackArg_GetDataBuildNumber :
          ABinaryComponentsData^[0] := C_DynTFTUI_BuildNumber

        else
          if FAT32_Read(RTTI_Destroy_Handle,
                        PByteArray(TPtr(ABinaryComponentsData)),
                        ByteCount) = -1 then
          begin
            //stops execution, if this is the first DWord of an instruction
            ABinaryComponentsData^[0] := 0;
            {$IFDEF IsDesktop}
              DynTFT_DebugConsole('Reached end of file, or file not found in RTTI destroy.');
            {$ELSE}
              //make sure FAT32 is initialized
              DynTFTDisplayErrorMessage(CRTTIDATAPROVIDERREADERR, CL_RED);
            {$ENDIF}
          end;
      end; //case
    end;
  {$ENDIF}
{$ENDIF}

end.