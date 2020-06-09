{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

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

unit DynTFTFAT32D;

{
  This file is a "Desktop" replacement for some of the functions from Dany's FAT32 library.
  Original implementation for MCU (by Dany Rosseel):
    https://libstock.mikroe.com/projects/view/58/fat
    http://wwww.rosseeld.be/DRO/PIC/Fat32_1.htm
    http://wwww.rosseeld.be/DRO/PIC/Fat32_2.htm
    http://wwww.rosseeld.be/DRO/PIC/Fat32.pdf


  The implementation is high level, i.e. it does not deal with FAT32 specifics.
  The library makes use of Delphi's built in file-related functions.
  It should be compiled for desktop only (no MCU).
  This library can be used in desktop applications in a similar way the FAT32
  library is used on a microcontroller.

  Portions of this file are copied from Dany's FAT32 library,
  for datatype and header compatiblity !!!
  Some of the headers are adapted to Delphi's syntax.

  Low level functions are not implemented.

  The main difference comes from the uses of strings, i.e. 0-indexed (as in MCU) vs. 1-indexed (as for desktop)

  Using Version 3.1 of FAT32 library.
}

interface

{$DEFINE IsDesktop}


uses
  DynTFTTypes, SysUtils, DynTFTUtils;


type
  TString11 = string[11];
  TArr4096Byte = array[0..4095] of Byte;
  TString4095 = string; //[4095];
  TArr512Byte = array[0..511] of Byte;

const
  LongFnLength  = 255; // length of a long filename

  faArchive   = $20;
  faCreate    = $80; // bit 7, special attribute to create files

type TLongFileName  = string[LongFnLength];
     TShortFileName = string[12]; // length of a short filename

     TFat32DirItem  =
     record
       FileName      : TLongFileName;  // longfilename if "LongFileNamePresent" is true, else "FileName" (short FileName)
       ShortFileName : TShortFileName; // short filename                        //  obtained using ExtractShortPathName(FileName), which may not always be available
       FileAttr      : byte;           // file attributes
       FileSize      : DWord;          // FileSize in bytes
       //FindDirEntry  : DWord;          // for internal usage only
     end;
       

  // FileVar type, an instance of it is needed for each simultaneous open file
Type TFileVar =
     record
       // device information
       Device                            : byte;                // device number for this file                           //also used for single device version of the library

       // -------------------------------------------------------------------------------------------------
       // -------- This variable contains the result of Fat32_FindFirst/Fat32_FindNext calls --------------
       Fat32_DirItem                     : TFat32DirItem;
       // -------------------------------------------------------------------------------------------------
       
       //Desktop specific fields, not available in the original structure
       FileVarInitialized: string; //use string instead of Boolean, because its uninitialized value is always ''
       SearchRec: TSearchRec;  // used for FindFirst and FindNext
       CurrentDir: string; // used for concatenating with BaseDirectory, to get the path to the file
       PreviousDir: string;  //used for Fat32_PrevDir function
       AssignedFileName: string; //'' if not assigned, and a valid full path filename if assigned
       FileIsOpen: Boolean;
       AFile: File;
     end;

     PFileVar = ^TFileVar;


const
  NrOfFat32Devices = 2;


function Fat32_Init: boolean; overload;
function Fat32_Init(Device: byte): boolean; overload;

function Fat32_QuickFormat(var VolumeLabel: TString11): boolean; overload;               //not implmemented for safety reasons  (so you don't format a partition on your hard drive)
function Fat32_QuickFormat(Device: byte; var VolumeLabel: TString11): boolean; overload; //not implmemented for safety reasons  (so you don't format a partition on your hard drive)

function Fat32_Format(var VolumeLabel: TString11): boolean; overload;                    //not implmemented for safety reasons  (so you don't format a partition on your hard drive)
function Fat32_Format(Device: byte; var VolumeLabel: TString11): boolean; overload;      //not implmemented for safety reasons  (so you don't format a partition on your hard drive)

procedure Fat32_VolumeLabel(var _Label: string); overload;
procedure Fat32_VolumeLabel(Device: byte; var _Label: string); overload;


procedure Fat32_FileVar_Init(var FileVar: TFilevar); overload;
procedure Fat32_FileVar_Init(var FileVar: TFilevar; Device_: byte); overload;


function Fat32_Assign({var} LongFn: TLongFileName; file_cre_attr: byte): boolean; overload;
function Fat32_Assign(var FileVar: TFilevar; {var} LongFn: TLongFileName; file_cre_attr: byte): boolean; overload;
function Fat32_Assign(Device: byte; {var} LongFn: TLongFileName; file_cre_attr: byte): boolean; overload;


procedure Fat32_Close; overload;
procedure Fat32_Close(var FileVar: TFilevar); overload;
procedure Fat32_Close(Device: byte); overload;

procedure Fat32_Reset(var _Size: DWord); overload;
procedure Fat32_Reset(var FileVar: TFilevar; var _Size: DWord); overload;
procedure Fat32_Reset(Device: byte; var _Size: DWord); overload;

procedure Fat32_Append; overload;
procedure Fat32_Append(var FileVar: TFilevar); overload;
procedure Fat32_Append(Device: byte); overload;

procedure Fat32_Rewrite; overload;
procedure Fat32_Rewrite(var FileVar: TFilevar); overload;
procedure Fat32_Rewrite(Device: byte); overload;

function Fat32_Rename(var OldName, NewName: TLongFileName): boolean; overload;
function Fat32_Rename(var FileVar: TFilevar; var OldName, NewName: TLongFileName): boolean; overload;
function Fat32_Rename(Device: byte; var OldName, NewName: TLongFileName): boolean; overload;

procedure Fat32_Flush; overload;
procedure Fat32_Flush(var FileVar: TFilevar); overload;
procedure Fat32_Flush(Device: byte); overload;

procedure Fat32_Seek(Position: DWord); overload;
procedure Fat32_Seek(var FileVar: TFilevar; Position: DWord); overload;
procedure Fat32_Seek(Device: byte; Position: DWord); overload;

function Fat32_FilePointer: DWord; overload;
function Fat32_FilePointer(var FileVar: TFilevar): DWord; overload;
function Fat32_FilePointer(Device: byte): DWord; overload;

function Fat32_EOF: boolean; overload;
function Fat32_EOF(var FileVar: TFilevar): boolean; overload;
function Fat32_EOF(Device: byte): boolean; overload;

function Fat32_Get_File_Size: DWord; overload;
function Fat32_Get_File_Size(var FileVar: TFilevar): DWord; overload;
function Fat32_Get_File_Size(Device: byte): DWord; overload;

function Fat32_Get_File_Size_Sectors: DWord; overload;
function Fat32_Get_File_Size_Sectors(var FileVar: TFilevar): DWord; overload;
function Fat32_Get_File_Size_Sectors(Device: byte): DWord; overload;

procedure Fat32_Get_File_Date(var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
procedure Fat32_Get_File_Date(var FileVar: TFilevar; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
procedure Fat32_Get_File_Date(Device: byte; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;

procedure Fat32_Set_File_Date(Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
procedure Fat32_Set_File_Date(var FileVar: TFilevar; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
procedure Fat32_Set_File_Date(Device: byte; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;

procedure Fat32_Get_File_Date_Modified(var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
procedure Fat32_Get_File_Date_Modified(var FileVar: TFilevar; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
procedure Fat32_Get_File_Date_Modified(Device: byte; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;

procedure Fat32_Set_File_Date_Modified(Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
procedure Fat32_Set_File_Date_Modified(var FileVar: TFilevar; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
procedure Fat32_Set_File_Date_Modified(Device: byte; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;

function Fat32_GetAttr: byte; overload;
function Fat32_GetAttr(var FileVar: TFilevar): byte; overload;
function Fat32_GetAttr(Device: byte): byte; overload;

procedure Fat32_SetAttr(Attr: byte); overload;
procedure Fat32_SetAttr(var FileVar: TFilevar; Attr: byte); overload;
procedure Fat32_SetAttr(Device: byte; Attr: byte); overload;

procedure Fat32_ClearArchiveAttr; overload;
procedure Fat32_ClearArchiveAttr(var FileVar: TFilevar); overload;
procedure Fat32_ClearArchiveAttr(Device: byte); overload;

procedure Fat32_SetArchiveAttr; overload;
procedure Fat32_SetArchiveAttr(var FileVar: TFilevar); overload;
procedure Fat32_SetArchiveAttr(Device: byte); overload;

procedure Fat32_Read(var _Data: byte); overload;
procedure Fat32_Read(var FileVar: TFilevar; var _Data: byte); overload;
procedure Fat32_Read(Device: byte; var _Data: byte); overload;

function Fat32_ReadBuffer(var Buffer: TArr4096Byte; DataLen: Word): word; overload;
function Fat32_ReadBuffer(var FileVar: TFilevar; var Buffer: TArr4096Byte; DataLen: Word): word; overload;
function Fat32_ReadBuffer(Device: byte; var Buffer: TArr4096Byte; DataLen: Word): word; overload;

procedure Fat32_Write(_Data: byte); overload;
procedure Fat32_Write(var FileVar: TFilevar; _Data: byte); overload;
procedure Fat32_Write(Device: byte; _Data: byte); overload;

procedure Fat32_Write_Const_Buffer(const _Data: PByte; Len: word); overload;
procedure Fat32_Write_Const_Buffer(var FileVar: TFilevar; const _Data: PByte; Len: word); overload;
procedure Fat32_Write_Const_Buffer(Device: byte; const _Data: PByte; Len: word); overload;

procedure Fat32_WriteBuffer(var Buffer: TArr4096Byte; DataLen: Word); overload;
procedure Fat32_WriteBuffer(var FileVar: TFilevar; var Buffer: TArr4096Byte; DataLen: Word); overload;
procedure Fat32_WriteBuffer(Device: byte; var Buffer: TArr4096Byte; DataLen: Word); overload;

procedure Fat32_WriteText(var S: TString4095); overload;
procedure Fat32_WriteText(var FileVar: TFilevar; var S: TString4095); overload;
procedure Fat32_WriteText(Device: byte; var S: TString4095); overload;

procedure Fat32_WriteLine(var S: TString4095); overload;
procedure Fat32_WriteLine(var FileVar: TFilevar; var S: TString4095); overload;
procedure Fat32_WriteLine(Device: byte; var S: TString4095); overload;

procedure Fat32_Truncate; overload;
procedure Fat32_Truncate(var FileVar: TFilevar); overload;
procedure Fat32_Truncate(Device: byte); overload;

procedure Fat32_Seek_Sector(Sector: DWord); overload;
procedure Fat32_Seek_Sector(var FileVar: TFileVar;Sector: DWord); overload;
procedure Fat32_Seek_Sector(Device: byte; Sector: DWord); overload;

procedure Fat32_Write_Sector(var Buffer: TArr512Byte); overload;
procedure Fat32_Write_Sector(var FileVar: TFileVar; var Buffer: TArr512Byte); overload;
procedure Fat32_Write_Sector(Device: byte; var Buffer: TArr512Byte); overload;

function Fat32_Read_Sector(var Buffer: TArr512Byte): DWord; overload;
function Fat32_Read_Sector(var FileVar: TFileVar; var Buffer: TArr512Byte): DWord; overload;
function Fat32_Read_Sector(Device: byte; var Buffer: TArr512Byte): DWord; overload;

procedure Fat32_Append_Sector; overload;
procedure Fat32_Append_Sector(var FileVar: TFileVar); overload;
procedure Fat32_Append_Sector(Device: byte); overload;


function Fat32_Delete({var} Name: TLongFileName): boolean; overload;
function Fat32_Delete(var FileVar: TFilevar; {var} Name: TLongFileName): boolean; overload;
function Fat32_Delete(Device: byte; {var} Name: TLongFileName): boolean; overload;

procedure Fat32_Delete_Files; overload;
procedure Fat32_Delete_Files(var FileVar: TFileVar); overload;
procedure Fat32_Delete_Files(Device: byte); overload;

function Fat32_ChDir({var} LongFn: TLongFileName): boolean; overload;
function Fat32_ChDir(var FileVar: TFilevar; {var} LongFn: TLongFileName): boolean; overload;
function Fat32_ChDir(Device: byte; {var} LongFn: TLongFileName): boolean; overload;

function Fat32_ChDir_FP(var LongFn: TLongFileName): boolean; overload;
function Fat32_ChDir_FP(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
function Fat32_ChDir_FP(Device: byte; var LongFn: TLongFileName): boolean; overload;

function Fat32_MkDir_ChDir_FP(var LongFn: TLongFileName): boolean; overload;
function Fat32_MkDir_ChDir_FP(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
function Fat32_MkDir_ChDir_FP(Device: byte; var LongFn: TLongFileName): boolean; overload;

procedure Fat32_PushDir; overload;
procedure Fat32_PushDir(var FileVar: TFilevar); overload;
procedure Fat32_PushDir(Device: byte); overload;

procedure Fat32_PopDir; overload;
procedure Fat32_PopDir(var FileVar: TFilevar); overload;
procedure Fat32_PopDir(Device: byte); overload;

procedure Fat32_PrevDir; overload;
procedure Fat32_PrevDir(var FileVar: TFilevar); overload;
procedure Fat32_PrevDir(Device: byte); overload;

function Fat32_MkDir(var LongFn: TLongFileName): boolean; overload;
function Fat32_MkDir(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
function Fat32_MkDir(Device: byte; var LongFn: TLongFileName): boolean; overload;

function Fat32_MkDir_ChDir(var LongFn: TLongFileName): boolean; overload;
function Fat32_MkDir_ChDir(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
function Fat32_MkDir_ChDir(Device: byte; var LongFn: TLongFileName): boolean; overload;

function Fat32_RmDir(var LongFn: TLongFileName): boolean; overload;
function Fat32_RmDir(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
function Fat32_RmDir(Device: byte; var LongFn: TLongFileName): boolean; overload;

function Fat32_RmDir_All(var Fn: string): boolean; overload;
function Fat32_RmDir_All(var FileVar: TFilevar; var Fn: string): boolean; overload;
function Fat32_RmDir_All(Device: byte; var Fn: string): boolean; overload;

function Fat32_Delete_All: boolean; overload;
function Fat32_Delete_All(var FileVar: TFileVar): boolean; overload;
function Fat32_Delete_All(Device: byte): boolean; overload;

procedure Fat32_Curdir(var CurrentDir: TLongFileName); overload;
procedure Fat32_Curdir(var FileVar: TFilevar; var CurrentDir: TLongFileName); overload;
procedure Fat32_Curdir(Device: byte; var CurrentDir: TLongFileName); overload;

procedure Fat32_Curdir_FP(var CurrentDir: TLongFileName); overload;
procedure Fat32_Curdir_FP(var FileVar: TFilevar; var CurrentDir: TLongFileName); overload;
procedure Fat32_Curdir_FP(Device: byte; var CurrentDir: TLongFileName); overload;

procedure Fat32_CleanDir; overload;
procedure Fat32_CleanDir(var FileVar: TFilevar); overload;
procedure Fat32_CleanDir(Device: byte); overload;

procedure Fat32_DefragDir; overload;
procedure Fat32_DefragDir(var FileVar: TFilevar); overload;
procedure Fat32_DefragDir(Device: byte); overload;

function Fat32_FindFirst(FileAttr: byte): boolean; overload;
function Fat32_FindFirst(var FileVar: TFilevar; FileAttr: byte): boolean; overload;
function Fat32_FindFirst(Device: byte; FileAttr: byte): boolean; overload;

function Fat32_FindNext(FileAttr: byte): boolean; overload;
function Fat32_FindNext(var FileVar: TFilevar; FileAttr: byte): boolean; overload;
function Fat32_FindNext(Device: byte; FileAttr: byte): boolean; overload;

function Fat32_FindFirst_FN({var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
function Fat32_FindFirst_FN(var FileVar: TFilevar; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
function Fat32_FindFirst_FN(Device: byte; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;

function Fat32_FindNext_FN(var FileVar: TFilevar; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
function Fat32_FindNext_FN({var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
function Fat32_FindNext_FN(Device: byte; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;

function Fat32_FileExists({var} LongFn: TLongFileName; FAttr: byte): boolean; overload;
function Fat32_FileExists(var FileVar: TFilevar; {var} LongFn: TLongFileName; FAttr: byte): boolean; overload;
function Fat32_FileExists(Device: byte; {var} LongFn: TLongFileName; FAttr: byte): boolean; overload;

function Fat32_Get_Swap_File(NoSectors: dword; var filename : TLongFileName; Attr : byte) : Dword; overload;
function Fat32_Get_Swap_File(var FileVar: TFilevar; NoSectors: dword; var filename : TLongFileName; Attr : byte) : Dword; overload;
function Fat32_Get_Swap_File(Device: byte; NoSectors: dword; var filename : TLongFileName; Attr : byte) : Dword; overload;

procedure Fat32_MakeDirFile(var DirFileName: TLongFileName); overload;
procedure Fat32_MakeDirFile(var FileVar: TFilevar; var DirFileName: TLongFileName); overload;
procedure Fat32_MakeDirFile(Device: byte; var DirFileName: TLongFileName); overload;

procedure Fat32_MakeDirFileHtm(var DirFileName: TLongFileName); overload;
procedure Fat32_MakeDirFileHtm(var FileVar: TFilevar; var DirFileName: TLongFileName); overload;
procedure Fat32_MakeDirFileHtm(Device: byte; var DirFileName: TLongFileName); overload;

procedure Fat32_CopyFile(var SourceFileName: string; var DestinationFileName: string); overload;
procedure Fat32_CopyFile(var SourceFile: TFileVar; var SourceFileName: string; var DestinationFile: TFileVar; var DestinationFileName: string); overload;
procedure Fat32_CopyFile(SourceDevice: byte; var SourceFileName: string; DestinationDevice: byte; var DestinationFileName: string); overload;

function Fat32_FileCount(var Names: ShortString; Attr: byte): DWord; overload;
function Fat32_FileCount(var FileVar: TFilevar; var Names: ShortString; Attr: byte): DWord; overload;
function Fat32_FileCount(Device: byte; var Names: ShortString; Attr: byte): DWord; overload;


function Fat32_TotalSpace: DWord; overload;
function Fat32_TotalSpace(Device: byte): DWord; overload;

function Fat32_FreeSpace: DWord; overload;
function Fat32_FreeSpace(Device: byte): DWord; overload;

function Fat32_UsedSpace: DWord; overload;
function Fat32_UsedSpace(Device: byte): DWord; overload;

function Fat32_TotalSpace_KB: DWord; overload;
function Fat32_TotalSpace_KB(Device: byte): DWord; overload;

function Fat32_FreeSpace_KB: DWord; overload;
function Fat32_FreeSpace_KB(Device: byte): DWord; overload;

function Fat32_UsedSpace_KB: DWord; overload;
function Fat32_UsedSpace_KB(Device: byte): DWord; overload;

function Fat32_TotalSpace_MB: DWord; overload;
function Fat32_TotalSpace_MB(Device: byte): DWord; overload;

function Fat32_FreeSpace_MB: DWord; overload;
function Fat32_FreeSpace_MB(Device: byte): DWord; overload;

function Fat32_UsedSpace_MB: DWord; overload;
function Fat32_UsedSpace_MB(Device: byte): DWord; overload;

function Fat32_TotalSpace_GB: real; overload;
function Fat32_TotalSpace_GB(Device: byte): real; overload;

function Fat32_FreeSpace_GB: Real; overload;
function Fat32_FreeSpace_GB(Device: byte): Real; overload;

function Fat32_UsedSpace_GB: Real; overload;
function Fat32_UsedSpace_GB(Device: byte): Real; overload;



//desktop specific routines:
procedure ResetInitialization;  //required for testing

procedure FAT32_SetBaseDirectory(ABaseDirectory: string); overload; //required on desktop, to set the path to the folder, which simulates the root of storage
procedure FAT32_SetBaseDirectory(ABaseDirectory: string; Device: byte); overload; //required on desktop, to set the path to the folder, which simulates the root of storage

function FAT32_GetBaseDirectory: string; overload;
function FAT32_GetBaseDirectory(Device: byte): string; overload;

procedure FAT32_GetAssignedFile(out AFileVar: TFileVar; Device: Byte); overload;
function FAT32_GetAssignedFile(Device: Byte): PFileVar; overload;

function FAT32IsInitialized(FileVar: TFilevar): Boolean;

function FAT32_GetFullPathFileName(Name: string): string; overload;                           //exposed for testing
function FAT32_GetFullPathFileName(var FileVar: TFileVar; Name: string): string; overload;    //exposed for testing
function FAT32_GetFullPathFileName(Device: byte; Name: string): string; overload;             //exposed for testing

procedure Fat32_FindClose; overload;                                                  //to be called for desktop only  (there is no FindClose on MCU)
procedure Fat32_FindClose(var FileVar: TFilevar); overload;                           //to be called for desktop only  (there is no FindClose on MCU)
procedure Fat32_FindClose(Device: byte); overload;                                    //to be called for desktop only  (there is no FindClose on MCU)

function Fat32_DirItem: TFat32DirItem; overload;                                      //Fat32_DirItem is a function on desktop, to avoid accidentally modifying it
function Fat32_DirItem(var FileVar: TFilevar): TFat32DirItem; overload;               //Fat32_DirItem is a function on desktop, to avoid accidentally modifying it
function Fat32_DirItem(Device: byte): TFat32DirItem; overload;                        //Fat32_DirItem is a function on desktop, to avoid accidentally modifying it


implementation

{$IFDEF UNIX}
  //uses
{$ELSE}
  uses
    Windows;
{$ENDIF}


const
  CUnsetBaseDir = '?'; //something not allowed on FAT32

var
  Fat32_Initialized: array[0..NrOfFat32Devices - 1] of Boolean;  //renamed from Fat32_Initialised
  BaseDirArr: array[0..NrOfFat32Devices - 1] of string;  //directory on the PC filesystem, which is used as the root of this library's filesystem  (e.g. C:\MyFolder\SDCard is equivalent to the physical SD card's root directory).  Also for all available devices  (multiple directories on your PC)
  LocalVarFiles: array[0..NrOfFat32Devices - 1] of TFileVar;


procedure Fat32_FileVar_Init_WithoutInitializedFlag(var FileVar: TFilevar; Device_: byte); overload;
begin
  FileVar.Device := Device_;
  FileVar.CurrentDir := '\';
  FileVar.PreviousDir := '\';
  FileVar.AssignedFileName := '';
  FileVar.FileIsOpen := False;
  FileVar.FileVarInitialized := ''; // set to '', i.e. not initialized !!!

  FileVar.Fat32_DirItem.FileName := '';
  FileVar.Fat32_DirItem.ShortFileName := '';
  FileVar.Fat32_DirItem.FileAttr := 0;
  FileVar.Fat32_DirItem.FileSize := 0;
end;  


function Fat32_Init: boolean; overload;
begin
  Result := Fat32_Init(0);
end;


function Fat32_Init(Device: byte): boolean; overload;
begin
  if Device > NrOfFat32Devices - 1 then
  begin
    Result := False;
    DynTFT_DebugConsole('Fat32_Init: Devices var is out of range.');
    Exit;
  end;

  if BaseDirArr[Device] = CUnsetBaseDir then
  begin
    DynTFT_DebugConsole('... Fat32_Init: Base directory not set. Please call FAT32_SetBaseDirectory with a path to a directory on your disk, simulating the root of storage media (e.g. SD card).');
    Result := False;
    Exit;
  end;

  if not DirectoryExists(BaseDirArr[Device]) then
  begin
    DynTFT_DebugConsole('... Fat32_Init: Base directory is set to a non-existing or unaccessible directory on your disk.');
    Result := False;
    Exit;
  end;

  Fat32_Initialized[Device] := True;
  Fat32_FileVar_Init_WithoutInitializedFlag(LocalVarFiles[Device], Device);

  Result := True;
end;


function Fat32_QuickFormat(var VolumeLabel: TString11): boolean; overload;               //not implmemented for safety reasons  (so you don't format a partition on your hard drive)
begin
  Result := Fat32_QuickFormat(0, VolumeLabel);
end;


function Fat32_QuickFormat(Device: byte; var VolumeLabel: TString11): boolean; overload; //not implmemented for safety reasons  (so you don't format a partition on your hard drive)
begin
  DynTFT_DebugConsole('Fat32_QuickFormat not implemented for safety reasons');
  Result := True;
end;


function Fat32_Format(var VolumeLabel: TString11): boolean; overload;                    //not implmemented for safety reasons  (so you don't format a partition on your hard drive)
begin
  Result := Fat32_Format(0, VolumeLabel);
end;

function Fat32_Format(Device: byte; var VolumeLabel: TString11): boolean; overload;      //not implmemented for safety reasons  (so you don't format a partition on your hard drive)
begin
  DynTFT_DebugConsole('Fat32_Format not implemented for safety reasons');
  Result := True;
end;


procedure Fat32_VolumeLabel(var _Label: string); overload;
begin
  Fat32_VolumeLabel(0, _Label);
end;

procedure Fat32_VolumeLabel(Device: byte; var _Label: string); overload;
begin
  DynTFT_DebugConsole('Fat32_VolumeLabel not implemented');
end;



procedure Fat32_FileVar_Init(var FileVar: TFilevar); overload;
begin
  Fat32_FileVar_Init(FileVar, 0);
end;


procedure Fat32_FileVar_Init(var FileVar: TFilevar; Device_: byte); overload;
begin
  Fat32_FileVar_Init_WithoutInitializedFlag(FileVar, Device_);
  FileVar.FileVarInitialized := 'initialized'; // just a string, different than ''
end;


function CreateFromAssignFunc(AFileName: string; Attributes: Byte): Integer;
var
  FileHandle: Integer;
begin
  Result := 0;
  if FileExists(AFileName) then
    Exit;

  if Attributes and faCreate = faCreate then
  begin
    FileHandle := FileCreate(AFileName);
    if FileHandle > -1 then
      FileClose(FileHandle)
    else
      Result := FileHandle;
  end;
end;


function Fat32_Assign({var} LongFn: TLongFileName; file_cre_attr: byte): boolean; overload;
begin
  Result := Fat32_Assign(0, LongFn, file_cre_attr);
end;


function Fat32_Assign(var FileVar: TFilevar; {var} LongFn: TLongFileName; file_cre_attr: byte): boolean; overload;
var
  Fnm: string;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    Result := False;
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Assign function.');
    Exit;
  end;

  if FileVar.FileVarInitialized = '' then
  begin
    Result := False;
    DynTFT_DebugConsole('FileVar not initialized in Fat32_Assign function. Please call Fat32_FileVar_Init.');
    Exit;
  end;

  Fnm := BaseDirArr[FileVar.Device] + FileVar.CurrentDir + LongFn;
  if CreateFromAssignFunc(Fnm, file_cre_attr) < 0 then
  begin
    Result := False;
    DynTFT_DebugConsole('Fat32_Assign: cannot assign file.');
    Exit;
  end;
                                            
  if FileExists(Fnm) then
  begin
    AssignFile(FileVar.AFile, Fnm);
    FileVar.AssignedFileName := Fnm;
    Result := True;
  end
  else
  begin
    Result := False;
    DynTFT_DebugConsole('File not found.');
  end;
end;


function Fat32_Assign(Device: byte; {var} LongFn: TLongFileName; file_cre_attr: byte): boolean; overload;
begin
  LocalVarFiles[Device].FileVarInitialized := 'initialized'; // just a string, different than ''    //autoinitialize for Lib_1 and Lib_1_MD
  Result := Fat32_Assign(LocalVarFiles[Device], LongFn, file_cre_attr);
end;



procedure Fat32_Close; overload;
begin
  Fat32_Close(0);
end;


procedure Fat32_Close(var FileVar: TFilevar); overload;
begin
  try
    if FileVar.AssignedFileName <> '' then
      FileVar.AssignedFileName := '';

    if FileVar.FileIsOpen then
    begin
      FileVar.FileIsOpen := False;
      CloseFile(FileVar.AFile);
    end;
  except
  end;
end;


procedure Fat32_Close(Device: byte); overload;
begin
  Fat32_Close(LocalVarFiles[Device]);
end;


procedure Fat32_Reset(var _Size: DWord); overload;
begin
  Fat32_Reset(0, _Size);
end;


procedure Fat32_Reset(var FileVar: TFilevar; var _Size: DWord); overload;
begin
  _Size := 0;
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Reset procedure.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Reset: file not assigned.');
    Exit;
  end;

  if not FileExists(FileVar.AssignedFileName) then
  begin
    DynTFT_DebugConsole('Fat32_Reset: file not found.');
    Exit;
  end;

  Reset(FileVar.AFile, 1);
  _Size := FileSize(FileVar.AFile);
  FileVar.FileIsOpen := True;
end;


procedure Fat32_Reset(Device: byte; var _Size: DWord); overload;
begin
  Fat32_Reset(LocalVarFiles[Device], _Size);
end;


procedure Fat32_Append; overload;
begin
  Fat32_Append(0);
end;


procedure Fat32_Append(var FileVar: TFilevar); overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Append procedure.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Append: file not assigned.');
    Exit;
  end;

  if not FileExists(FileVar.AssignedFileName) then
  begin
    DynTFT_DebugConsole('Fat32_Append: file not found.');
    Exit;
  end;

  Reset(FileVar.AFile, 1);
  FileVar.FileIsOpen := True; //call this before seek
  Seek(FileVar.AFile, FileSize(FileVar.AFile));
end;


procedure Fat32_Append(Device: byte); overload;
begin
  Fat32_Append(LocalVarFiles[Device]);
end;


procedure Fat32_Rewrite; overload;
begin
  Fat32_Rewrite(0);
end;


procedure Fat32_Rewrite(var FileVar: TFilevar); overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Rewrite procedure.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Rewrite: file not assigned.');
    Exit;
  end;

  if not FileExists(FileVar.AssignedFileName) then
  begin
    DynTFT_DebugConsole('Fat32_Rewrite: file not found.');
    Exit;
  end;

  Rewrite(FileVar.AFile, 1);
  FileVar.FileIsOpen := True;
end;


procedure Fat32_Rewrite(Device: byte); overload;
begin
  Fat32_Rewrite(LocalVarFiles[Device]);
end;


function Fat32_Rename(var OldName, NewName: TLongFileName): boolean; overload;
begin
  Result := Fat32_Rename(0, OldName, NewName);
end;

function Fat32_Rename(var FileVar: TFilevar; var OldName, NewName: TLongFileName): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_Rename not implemented');
  Result := True;
end;

function Fat32_Rename(Device: byte; var OldName, NewName: TLongFileName): boolean; overload;
begin
  Result := Fat32_Rename(LocalVarFiles[Device], OldName, NewName);
end;


procedure Fat32_Flush; overload;
begin
  Fat32_Flush(0);
end;

procedure Fat32_Flush(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_Flush not implemented');
end;

procedure Fat32_Flush(Device: byte); overload;
begin
  Fat32_Flush(LocalVarFiles[Device]);
end;


procedure Fat32_Seek(Position: DWord); overload;
begin
  Fat32_Seek(0, Position);
end;


procedure Fat32_Seek(var FileVar: TFilevar; Position: DWord); overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Seek procedure.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Seek: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_Seek: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  if Position > DWord(FileSize(FileVar.AFile)) then
    Position := DWord(FileSize(FileVar.AFile));
  
  Seek(FileVar.AFile, Position);
end;


procedure Fat32_Seek(Device: byte; Position: DWord); overload;
begin
  Fat32_Seek(LocalVarFiles[Device], Position);
end;


function Fat32_FilePointer: DWord; overload;
begin
  Result := Fat32_FilePointer(0);
end;


function Fat32_FilePointer(var FileVar: TFilevar): DWord; overload;
begin
  Result := 0;
  
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_FilePointer function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_FilePointer: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_FilePointer: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  Result := FilePos(FileVar.AFile);
end;


function Fat32_FilePointer(Device: byte): DWord; overload;
begin
  Result := Fat32_FilePointer(LocalVarFiles[Device]);
end;


function Fat32_EOF: boolean; overload;
begin
  Result := Fat32_EOF(0);
end;


function Fat32_EOF(var FileVar: TFilevar): boolean; overload;
begin
  Result := True;

  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_EOF function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_EOF: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_EOF: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  Result := Fat32_FilePointer >= Fat32_Get_File_Size;
end;


function Fat32_EOF(Device: byte): boolean; overload;
begin
  Result := Fat32_EOF(LocalVarFiles[Device]);
end;


function Fat32_Get_File_Size: DWord; overload;
begin
  Result := Fat32_Get_File_Size(0);
end;


function Fat32_Get_File_Size(var FileVar: TFilevar): DWord; overload;
begin
  Result := 0;
  
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Get_File_Size function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Get_File_Size: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_Get_File_Size: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;
  
  Result := FileSize(FileVar.AFile);
end;


function Fat32_Get_File_Size(Device: byte): DWord; overload;
begin
  Result := Fat32_Get_File_Size(LocalVarFiles[Device]);
end;


function Fat32_Get_File_Size_Sectors: DWord; overload;
begin
  Result := Fat32_Get_File_Size_Sectors(0);
end;

function Fat32_Get_File_Size_Sectors(var FileVar: TFilevar): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_Get_File_Size_Sectors not implemented');
  Result := 0;
end;

function Fat32_Get_File_Size_Sectors(Device: byte): DWord; overload;
begin
  Result := Fat32_Get_File_Size_Sectors(LocalVarFiles[Device]);
end;


procedure Fat32_Get_File_Date(var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
begin
  Fat32_Get_File_Date(0, Year, Month, Day, Hours, Mins);
end;

procedure Fat32_Get_File_Date(var FileVar: TFilevar; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
begin
  DynTFT_DebugConsole('Fat32_Get_File_Date not implemented');
end;

procedure Fat32_Get_File_Date(Device: byte; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
begin
  Fat32_Get_File_Date(LocalVarFiles[Device], Year, Month, Day, Hours, Mins);
end;


procedure Fat32_Set_File_Date(Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
begin
  Fat32_Set_File_Date(0, Year, Month, Day, Hours, Mins);
end;

procedure Fat32_Set_File_Date(var FileVar: TFilevar; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
begin
  DynTFT_DebugConsole('Fat32_Set_File_Date not implemented');
end;

procedure Fat32_Set_File_Date(Device: byte; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
begin
  Fat32_Set_File_Date(LocalVarFiles[Device], Year, Month, Day, Hours, Mins);
end;


procedure Fat32_Get_File_Date_Modified(var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
begin
  Fat32_Get_File_Date_Modified(0, Year, Month, Day, Hours, Mins);
end;

procedure Fat32_Get_File_Date_Modified(var FileVar: TFilevar; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
begin
  DynTFT_DebugConsole('Fat32_Get_File_Date_Modified not implemented');
end;

procedure Fat32_Get_File_Date_Modified(Device: byte; var Year: word; var Month: byte; var Day: byte; var Hours: byte; var Mins: byte); overload;
begin
  Fat32_Get_File_Date_Modified(LocalVarFiles[Device], Year, Month, Day, Hours, Mins);
end;


procedure Fat32_Set_File_Date_Modified(Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
begin
  Fat32_Set_File_Date_Modified(0, Year, Month, Day, Hours, Mins);
end;

procedure Fat32_Set_File_Date_Modified(var FileVar: TFilevar; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
begin
  DynTFT_DebugConsole('Fat32_Set_File_Date_Modified not implemented');
end;

procedure Fat32_Set_File_Date_Modified(Device: byte; Year: word; Month: byte; Day: byte; Hours: byte; Mins: byte); overload;
begin
  Fat32_Set_File_Date_Modified(LocalVarFiles[Device], Year, Month, Day, Hours, Mins);
end;


function Fat32_GetAttr: byte; overload;
begin
  Result := Fat32_GetAttr(0);
end;

function Fat32_GetAttr(var FileVar: TFilevar): byte; overload;
begin
  DynTFT_DebugConsole('Fat32_GetAttr not implemented');
  Result := 0;
end;

function Fat32_GetAttr(Device: byte): byte; overload;
begin
  Result := Fat32_GetAttr(LocalVarFiles[Device]);
end;


procedure Fat32_SetAttr(Attr: byte); overload;
begin
  Fat32_SetAttr(0, Attr);
end;

procedure Fat32_SetAttr(var FileVar: TFilevar; Attr: byte); overload;
begin
  DynTFT_DebugConsole('Fat32_SetAttr not implemented');
end;

procedure Fat32_SetAttr(Device: byte; Attr: byte); overload;
begin
  Fat32_SetAttr(LocalVarFiles[Device], Attr);
end;


procedure Fat32_ClearArchiveAttr; overload;
begin
  Fat32_ClearArchiveAttr(0);
end;

procedure Fat32_ClearArchiveAttr(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_ClearArchiveAttr not implemented');
end;

procedure Fat32_ClearArchiveAttr(Device: byte); overload;
begin
  Fat32_ClearArchiveAttr(LocalVarFiles[Device]);
end;


procedure Fat32_SetArchiveAttr; overload;
begin
  Fat32_SetArchiveAttr(0);
end;

procedure Fat32_SetArchiveAttr(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_SetArchiveAttr not implemented');
end;

procedure Fat32_SetArchiveAttr(Device: byte); overload;
begin
  Fat32_SetArchiveAttr(LocalVarFiles[Device]);
end;


procedure Fat32_Read(var _Data: byte); overload;
begin
  Fat32_Read(0, _Data);
end;


procedure Fat32_Read(var FileVar: TFilevar; var _Data: byte); overload;
begin
  _Data := 0;
  
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Read function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Read: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_Read: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  if Fat32_FilePointer(FileVar) = Fat32_Get_File_Size(FileVar) then
  begin
    DynTFT_DebugConsole('Fat32_Read: reached end of file.');
    Exit;
  end;

  BlockRead(FileVar.AFile, _Data, 1);
end;


procedure Fat32_Read(Device: byte; var _Data: byte); overload;
begin
  Fat32_Read(LocalVarFiles[Device], _Data);
end;


function Fat32_ReadBuffer(var Buffer: TArr4096Byte; DataLen: Word): word; overload;
begin
  Result := Fat32_ReadBuffer(0, Buffer, DataLen);
end;


function Fat32_ReadBuffer(var FileVar: TFilevar; var Buffer: TArr4096Byte; DataLen: Word): word; overload;
var
  ActualBytesRead: Integer;
begin
  Result := 0;

  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_ReadBuffer function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_ReadBuffer: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_ReadBuffer: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  if Fat32_FilePointer(FileVar) = Fat32_Get_File_Size(FileVar) then
  begin
    DynTFT_DebugConsole('Fat32_ReadBuffer: reached end of file.');
    Exit;
  end;

  BlockRead(FileVar.AFile, Buffer, DataLen, ActualBytesRead);
  Result := ActualBytesRead;
end;


function Fat32_ReadBuffer(Device: byte; var Buffer: TArr4096Byte; DataLen: Word): word; overload;
begin
  Result := Fat32_ReadBuffer(LocalVarFiles[Device], Buffer, DataLen);
end;


procedure Fat32_Write(_Data: byte); overload;
begin
  Fat32_Write(0, _Data);
end;


procedure Fat32_Write(var FileVar: TFilevar; _Data: byte); overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Write function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_Write: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_Write: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  BlockWrite(FileVar.AFile, _Data, 1);
end;


procedure Fat32_Write(Device: byte; _Data: byte); overload;
begin
  Fat32_Write(LocalVarFiles[Device], _Data);
end;


procedure Fat32_Write_Const_Buffer(const _Data: PByte; Len: word); overload;
begin
  Fat32_Write_Const_Buffer(0, _Data, Len);
end;


procedure Fat32_Write_Const_Buffer(var FileVar: TFilevar; const _Data: PByte; Len: word); overload;
var
  Buffer: TArr4096Byte;
begin
  memcpy(@Buffer, _Data, Len);
  Fat32_WriteBuffer(FileVar, Buffer, Len);
end;


procedure Fat32_Write_Const_Buffer(Device: byte; const _Data: PByte; Len: word); overload;
begin
  Fat32_Write_Const_Buffer(LocalVarFiles[Device], _Data, Len);
end;


procedure Fat32_WriteBuffer(var Buffer: TArr4096Byte; DataLen: Word); overload;
begin
  Fat32_WriteBuffer(0, Buffer, DataLen);
end;


procedure Fat32_WriteBuffer(var FileVar: TFilevar; var Buffer: TArr4096Byte; DataLen: Word); overload;
var
  ActualBytesWritten: Integer;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_WriteBuffer function.');
    Exit;
  end;

  if FileVar.AssignedFileName = '' then
  begin
    DynTFT_DebugConsole('Fat32_WriteBuffer: file not assigned.');
    Exit;
  end;

  if not FileVar.FileIsOpen then
  begin
    DynTFT_DebugConsole('Fat32_WriteBuffer: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).');
    Exit;
  end;

  BlockWrite(FileVar.AFile, Buffer, DataLen, ActualBytesWritten);

  if ActualBytesWritten <> DataLen then
    DynTFT_DebugConsole('Fat32_WriteBuffer: not all bytes were written. The disk may be full.');
end;


procedure Fat32_WriteBuffer(Device: byte; var Buffer: TArr4096Byte; DataLen: Word); overload;
begin
  Fat32_WriteBuffer(LocalVarFiles[Device], Buffer, DataLen);
end;


procedure Fat32_WriteText(var S: TString4095); overload;
begin
  Fat32_WriteText(0, S);
end;

procedure Fat32_WriteText(var FileVar: TFilevar; var S: TString4095); overload;
begin
  DynTFT_DebugConsole('Fat32_WriteText not implemented');
end;

procedure Fat32_WriteText(Device: byte; var S: TString4095); overload;
begin
  Fat32_WriteText(LocalVarFiles[Device], S);
end;


procedure Fat32_WriteLine(var S: TString4095); overload;
begin
  Fat32_WriteLine(0, S);
end;

procedure Fat32_WriteLine(var FileVar: TFilevar; var S: TString4095); overload;
begin
  DynTFT_DebugConsole('Fat32_WriteLine not implemented');
end;

procedure Fat32_WriteLine(Device: byte; var S: TString4095); overload;
begin
  Fat32_WriteLine(LocalVarFiles[Device], S);
end;


procedure Fat32_Truncate; overload;
begin
  Fat32_Truncate(0);
end;

procedure Fat32_Truncate(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_Truncate not implemented');
end;

procedure Fat32_Truncate(Device: byte); overload;
begin
  Fat32_Truncate(LocalVarFiles[Device]);
end;


procedure Fat32_Seek_Sector(Sector: DWord); overload;
begin
  Fat32_Seek_Sector(0, Sector);
end;

procedure Fat32_Seek_Sector(var FileVar: TFileVar;Sector: DWord); overload;
begin
  DynTFT_DebugConsole('Fat32_Seek_Sector not implemented');
end;

procedure Fat32_Seek_Sector(Device: byte; Sector: DWord); overload;
begin
  Fat32_Seek_Sector(LocalVarFiles[Device], Sector);
end;


procedure Fat32_Write_Sector(var Buffer: TArr512Byte); overload;
begin
  Fat32_Write_Sector(0, Buffer);
end;

procedure Fat32_Write_Sector(var FileVar: TFileVar; var Buffer: TArr512Byte); overload;
begin
  DynTFT_DebugConsole('Fat32_Write_Sector not implemented');
end;

procedure Fat32_Write_Sector(Device: byte; var Buffer: TArr512Byte); overload;
begin
  Fat32_Write_Sector(LocalVarFiles[Device], Buffer);
end;


function Fat32_Read_Sector(var Buffer: TArr512Byte): DWord; overload;
begin
  Result := Fat32_Read_Sector(0, Buffer);
end;

function Fat32_Read_Sector(var FileVar: TFileVar; var Buffer: TArr512Byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_Read_Sector not implemented');
  Result := 0;
end;

function Fat32_Read_Sector(Device: byte; var Buffer: TArr512Byte): DWord; overload;
begin
  Result := Fat32_Read_Sector(LocalVarFiles[Device], Buffer);
end;


procedure Fat32_Append_Sector; overload;
begin
  Fat32_Append_Sector(0);
end;

procedure Fat32_Append_Sector(var FileVar: TFileVar); overload;
begin
  DynTFT_DebugConsole('Fat32_Append_Sector not implemented');
end;

procedure Fat32_Append_Sector(Device: byte); overload;
begin
  Fat32_Append_Sector(LocalVarFiles[Device]);
end;



function Fat32_Delete({var} Name: TLongFileName): boolean; overload;
begin
  Result := Fat32_Delete(0, Name);
end;

function Fat32_Delete(var FileVar: TFilevar; {var} Name: TLongFileName): boolean; overload;
var
  Fnm: string;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Delete procedure.');
    Result := False;
    Exit;
  end;

  if Name = '' then
  begin
    DynTFT_DebugConsole('Fat32_Delete: Name cannot be an empty string.');
    Result := False;
    Exit;
  end;

  Fat32_Close(FileVar);

  Fnm := BaseDirArr[FileVar.Device] + FileVar.CurrentDir + Name;
  if FileExists(Fnm) then
  begin
    SysUtils.DeleteFile(Fnm);
    Result := True;
  end
  else
  begin
    Result := False;
    DynTFT_DebugConsole('Fat32_Delete: file not found.');
  end;
end;

function Fat32_Delete(Device: byte; {var} Name: TLongFileName): boolean; overload;
begin
  Result := Fat32_Delete(LocalVarFiles[Device], Name);
end;


procedure Fat32_Delete_Files; overload;
begin
  Fat32_Delete_Files(0);
end;

procedure Fat32_Delete_Files(var FileVar: TFileVar); overload;
begin
  DynTFT_DebugConsole('Fat32_Delete_Files not implemented');
end;

procedure Fat32_Delete_Files(Device: byte); overload;
begin
  Fat32_Delete_Files(LocalVarFiles[Device]);
end;


function Fat32_ChDir({var} LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_ChDir(0, LongFn);
end;


function Fat32_ChDir(var FileVar: TFilevar; {var} LongFn: TLongFileName): boolean; overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    Result := False;
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_ChDir function.');
    Exit;
  end;

  if (LongFn = '') then
  begin
    Result := False;
    DynTFT_DebugConsole('Fat32_ChDir: LongFn cannot be empty.');
    Exit;
  end;

  if (Pos('\', LongFn) > 0) and (LongFn <> '\') then
  begin
    Result := False;
    DynTFT_DebugConsole('Fat32_ChDir: No "\" allowed in provided directory name, only to change directory to root.');
    Exit;
  end;

  Fat32_Close(FileVar);

  if LongFn = '\' then
  begin
    FileVar.PreviousDir := FileVar.CurrentDir;
    FileVar.CurrentDir := '\';
    Result := True;
    Exit;
  end;

  if LongFn = '..' then
  begin
    if FileVar.CurrentDir = '\' then  
    begin
      Result := True;
      DynTFT_DebugConsole('Fat32_ChDir: Already at root.');  //not anerror this time
      Exit;

      //This operation would be successful on desktop,
      //but should it should replicate the MCU implementation.
      //It uses FindFirst to search for '..', which doesn't exist on root.
    end;
    
    FileVar.PreviousDir := FileVar.CurrentDir;

    if FileVar.CurrentDir[Length(FileVar.CurrentDir)] = '\' then
      Delete(FileVar.CurrentDir, Length(FileVar.CurrentDir), 1);   //required by ExtractFileDir
      
    FileVar.CurrentDir := ExtractFileDir(FileVar.CurrentDir);

    //if FileVar.CurrentDir <> '' then
      //FileVar.CurrentDir := FileVar.CurrentDir + '\';

    Result := True;
    Exit;
  end;

  if not DirectoryExists(BaseDirArr[FileVar.Device] + FileVar.CurrentDir + LongFn) then
  begin
    Result := False;
    DynTFT_DebugConsole('Fat32_ChDir: Cannot change to a non-existent directory.');
    Exit;
  end;

  FileVar.PreviousDir := FileVar.CurrentDir;
  FileVar.CurrentDir := FileVar.CurrentDir + LongFn + '\';

  Result := True;
end;


function Fat32_ChDir(Device: byte; {var} LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_ChDir(LocalVarFiles[Device], LongFn);
end;


function Fat32_ChDir_FP(var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_ChDir_FP(0, LongFn);
end;

function Fat32_ChDir_FP(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_ChDir_FP not implemented');
  Result := True;
end;

function Fat32_ChDir_FP(Device: byte; var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_ChDir_FP(LocalVarFiles[Device], LongFn);
end;


function Fat32_MkDir_ChDir_FP(var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_MkDir_ChDir_FP(0, LongFn);
end;

function Fat32_MkDir_ChDir_FP(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_MkDir_ChDir_FP not implemented');
  Result := True;
end;

function Fat32_MkDir_ChDir_FP(Device: byte; var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_MkDir_ChDir_FP(LocalVarFiles[Device], LongFn);
end;


procedure Fat32_PushDir; overload;
begin
  
end;

procedure Fat32_PushDir(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_PushDir not implemented');
end;

procedure Fat32_PushDir(Device: byte); overload;
begin
  Fat32_PushDir(LocalVarFiles[Device]);
end;


procedure Fat32_PopDir; overload;
begin
  Fat32_PopDir(0);
end;

procedure Fat32_PopDir(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_PopDir not implemented');
end;

procedure Fat32_PopDir(Device: byte); overload;
begin
  Fat32_PopDir(LocalVarFiles[Device]);
end;


procedure Fat32_PrevDir; overload;
begin
  Fat32_PrevDir(0);
end;


procedure Fat32_PrevDir(var FileVar: TFilevar); overload;
var
  s: string;
  Temp: string;
begin
  s := FileVar.PreviousDir;
  if (Length(s) > 1) and (s[Length(s)] = '\') then
    Delete(s, Length(s), 1);

  {if s = '\' then
    Fat32_ChDir(FileVar, s)
  else
    Fat32_ChDir(FileVar, ExtractFileName(s));}

  Temp := FileVar.CurrentDir;
  FileVar.CurrentDir := FileVar.PreviousDir;
  FileVar.PreviousDir := Temp;
end;


procedure Fat32_PrevDir(Device: byte); overload;
begin
  Fat32_PrevDir(LocalVarFiles[Device]);
end;


function Fat32_MkDir(var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_MkDir(0, LongFn);
end;

function Fat32_MkDir(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_MkDir not implemented');
  Result := True;
end;

function Fat32_MkDir(Device: byte; var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_MkDir(LocalVarFiles[Device], LongFn);
end;


function Fat32_MkDir_ChDir(var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_MkDir_ChDir(0, LongFn);
end;

function Fat32_MkDir_ChDir(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_MkDir_ChDir not implemented');
  Result := True;
end;

function Fat32_MkDir_ChDir(Device: byte; var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_MkDir_ChDir(LocalVarFiles[Device], LongFn);
end;


function Fat32_RmDir(var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_RmDir(0, LongFn);
end;

function Fat32_RmDir(var FileVar: TFilevar; var LongFn: TLongFileName): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_RmDir not implemented');
  Result := True;
end;

function Fat32_RmDir(Device: byte; var LongFn: TLongFileName): boolean; overload;
begin
  Result := Fat32_RmDir(LocalVarFiles[Device], LongFn);
end;


function Fat32_RmDir_All(var Fn: string): boolean; overload;
begin
  Result := Fat32_RmDir_All(0, Fn);
end;

function Fat32_RmDir_All(var FileVar: TFilevar; var Fn: string): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_RmDir_All not implemented');
  Result := True;
end;

function Fat32_RmDir_All(Device: byte; var Fn: string): boolean; overload;
begin
  Result := Fat32_RmDir_All(LocalVarFiles[Device], Fn);
end;


function Fat32_Delete_All: boolean; overload;
begin
  Result := Fat32_Delete_All(0);
end;

function Fat32_Delete_All(var FileVar: TFileVar): boolean; overload;
begin
  DynTFT_DebugConsole('Fat32_Delete_All not implemented');
  Result := True;
end;

function Fat32_Delete_All(Device: byte): boolean; overload;
begin
  Result := Fat32_Delete_All(LocalVarFiles[Device]);
end;


procedure Fat32_Curdir(var CurrentDir: TLongFileName); overload;
begin
  Fat32_Curdir(0, CurrentDir);
end;

procedure Fat32_Curdir(var FileVar: TFilevar; var CurrentDir: TLongFileName); overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_Curdir function.');
    CurrentDir := ''; //empty string for not initialized, else '\' for root
    Exit;
  end;

  Fat32_Close(FileVar);
  
  CurrentDir := FileVar.CurrentDir;

  if CurrentDir = '\' then
    Exit;
    
  if Length(CurrentDir) > 1 then
    if CurrentDir[Length(CurrentDir)] = '\' then
      Delete(CurrentDir, Length(CurrentDir), 1);

  CurrentDir := ExtractFileName(CurrentDir);    
end;

procedure Fat32_Curdir(Device: byte; var CurrentDir: TLongFileName); overload;
begin
  Fat32_Curdir(LocalVarFiles[Device], CurrentDir);
end;


procedure Fat32_Curdir_FP(var CurrentDir: TLongFileName); overload;
begin
  Fat32_Curdir_FP(0, CurrentDir);
end;

procedure Fat32_Curdir_FP(var FileVar: TFilevar; var CurrentDir: TLongFileName); overload;
begin
  DynTFT_DebugConsole('Fat32_Curdir_FP not implemented');
end;

procedure Fat32_Curdir_FP(Device: byte; var CurrentDir: TLongFileName); overload;
begin
  Fat32_Curdir_FP(LocalVarFiles[Device], CurrentDir);
end;


procedure Fat32_CleanDir; overload;
begin
  Fat32_CleanDir(0);
end;

procedure Fat32_CleanDir(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_CleanDir not implemented');
end;

procedure Fat32_CleanDir(Device: byte); overload;
begin
  Fat32_CleanDir(LocalVarFiles[Device]);
end;


procedure Fat32_DefragDir; overload;
begin
  Fat32_DefragDir(0);
end;

procedure Fat32_DefragDir(var FileVar: TFilevar); overload;
begin
  DynTFT_DebugConsole('Fat32_DefragDir not implemented');
end;

procedure Fat32_DefragDir(Device: byte); overload;
begin
  Fat32_DefragDir(LocalVarFiles[Device]);
end;


function Fat32_FindFirst(FileAttr: byte): boolean; overload;
begin
  Result := Fat32_FindFirst(0, FileAttr);
end;


function Fat32_FindFirst(var FileVar: TFilevar; FileAttr: byte): boolean; overload;
begin
  Result := Fat32_FindFirst_FN(FileVar, '*', FileAttr);
end;


function Fat32_FindFirst(Device: byte; FileAttr: byte): boolean; overload;
begin
  Result := Fat32_FindFirst(LocalVarFiles[Device], FileAttr);
end;


function Fat32_FindNext(FileAttr: byte): boolean; overload;
begin
  Result := Fat32_FindNext(0, FileAttr);
end;


function Fat32_FindNext(var FileVar: TFilevar; FileAttr: byte): boolean; overload;
begin
  Result := Fat32_FindNext_FN(FileVar, '*', FileAttr);
end;


function Fat32_FindNext(Device: byte; FileAttr: byte): boolean; overload;
begin
  Result := Fat32_FindNext(LocalVarFiles[Device], FileAttr);
end;


function Fat32_FindFirst_FN({var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
begin
  Result := Fat32_FindFirst_FN(0, LongFN, FAttr);
end;


function Fat32_FindFirst_FN(var FileVar: TFilevar; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
var
  FFResult: Integer;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_FindFirst_FN function.');
    Result := False;
    Exit;
  end;

  FFResult := FindFirst(BaseDirArr[FileVar.Device] + FileVar.CurrentDir + LongFN, FAttr, FileVar.SearchRec);
  if FFResult = 0 then
  begin
    FileVar.Fat32_DirItem.FileName := Copy(FileVar.SearchRec.Name, 1, 253);
    FileVar.Fat32_DirItem.ShortFileName := ExtractShortPathName(FileVar.Fat32_DirItem.FileName); //Warning! Sometimes, the short filename will not be available, resulting in ''.
    FileVar.Fat32_DirItem.FileAttr := FileVar.SearchRec.Attr;
    FileVar.Fat32_DirItem.FileSize := FileVar.SearchRec.Size;

    Result := True;
  end
  else
  begin
    Result := False; //no file found

    FileVar.Fat32_DirItem.FileName := '';
    FileVar.Fat32_DirItem.ShortFileName := '';
    FileVar.Fat32_DirItem.FileAttr := 0;
    FileVar.Fat32_DirItem.FileSize := 0;

    DynTFT_DebugConsole('FAT32_FindFirst_FN: ' + SysErrorMessage(GetLastError));
  end;
end;


function Fat32_FindFirst_FN(Device: byte; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
begin
  Result := Fat32_FindFirst_FN(LocalVarFiles[Device], LongFN, FAttr);
end;


function Fat32_FindNext_FN({var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
begin
  Result := Fat32_FindNext_FN(0, LongFn, FAttr);
end;


function Fat32_FindNext_FN(var FileVar: TFilevar; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
var
  FFResult: Integer;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_FindNext_FN function.');
    Result := False;
    Exit;
  end;

  FFResult := FindNext(FileVar.SearchRec);
  if FFResult = 0 then
  begin
    FileVar.Fat32_DirItem.FileName := Copy(FileVar.SearchRec.Name, 1, 253);
    FileVar.Fat32_DirItem.ShortFileName := ExtractShortPathName(FileVar.Fat32_DirItem.FileName); //Warning! Sometimes, the short filename will not be available, resulting in ''.
    FileVar.Fat32_DirItem.FileAttr := FileVar.SearchRec.Attr;
    FileVar.Fat32_DirItem.FileSize := FileVar.SearchRec.Size;

    Result := True;
  end
  else
  begin
    Result := False; //no file found

    FileVar.Fat32_DirItem.FileName := '';
    FileVar.Fat32_DirItem.ShortFileName := '';
    FileVar.Fat32_DirItem.FileAttr := 0;
    FileVar.Fat32_DirItem.FileSize := 0;

    DynTFT_DebugConsole('Fat32_FindNext_FN: ' + SysErrorMessage(GetLastError));
  end;
end;


function Fat32_FindNext_FN(Device: byte; {var} LongFN: TLongFileName; FAttr: byte): boolean; overload;
begin
  Result := Fat32_FindNext_FN(LocalVarFiles[Device], LongFn, FAttr);
end;


function FileExistsCommon(ABaseDir: string; LongFn: TLongFileName; FAttr: byte): Boolean;
var
  DirRequired: Boolean;
begin
  DirRequired := FAttr and faDirectory = 1;
  Result := (FileExists(ABaseDir + LongFn) and not DirRequired) or (DirectoryExists(ABaseDir + LongFn) or DirRequired);
end;


function Fat32_FileExists({var} LongFn: TLongFileName; FAttr: byte): boolean; overload;
begin
  Result := Fat32_FileExists(0, LongFn, FAttr);
end;


function Fat32_FileExists(var FileVar: TFilevar; {var} LongFn: TLongFileName; FAttr: byte): boolean; overload;
begin
  if not FAT32IsInitialized(FileVar) then
  begin
    Result := False;
    DynTFT_DebugConsole('FAT32 not initialized in Fat32_FileExists function.');
    Exit;
  end;

  Result := FileExistsCommon(BaseDirArr[FileVar.Device], FileVar.CurrentDir + LongFn, FAttr);
end;


function Fat32_FileExists(Device: byte; {var} LongFn: TLongFileName; FAttr: byte): boolean; overload;
begin
  Result := Fat32_FileExists(LocalVarFiles[Device], LongFn, FAttr);
end;


function Fat32_Get_Swap_File(NoSectors: dword; var filename : TLongFileName; Attr : byte) : Dword; overload;
begin
  Result := Fat32_Get_Swap_File(0, NoSectors, filename, Attr);
end;

function Fat32_Get_Swap_File(var FileVar: TFilevar; NoSectors: dword; var filename : TLongFileName; Attr : byte) : Dword; overload;
begin
  DynTFT_DebugConsole('Fat32_Get_Swap_File not implemented');
  Result := 0;
end;

function Fat32_Get_Swap_File(Device: byte; NoSectors: dword; var filename : TLongFileName; Attr : byte) : Dword; overload;
begin
  Result := Fat32_Get_Swap_File(LocalVarFiles[Device], NoSectors, filename, Attr);
end;


procedure Fat32_MakeDirFile(var DirFileName: TLongFileName); overload;
begin
  Fat32_MakeDirFile(0, DirFileName);
end;

procedure Fat32_MakeDirFile(var FileVar: TFilevar; var DirFileName: TLongFileName); overload;
begin
  DynTFT_DebugConsole('Fat32_MakeDirFile not implemented');
end;

procedure Fat32_MakeDirFile(Device: byte; var DirFileName: TLongFileName); overload;
begin
  Fat32_MakeDirFile(LocalVarFiles[Device], DirFileName);
end;


procedure Fat32_MakeDirFileHtm(var DirFileName: TLongFileName); overload;
begin
  Fat32_MakeDirFileHtm(0, DirFileName);
end;

procedure Fat32_MakeDirFileHtm(var FileVar: TFilevar; var DirFileName: TLongFileName); overload;
begin
  DynTFT_DebugConsole('Fat32_MakeDirFileHtm not implemented');
end;

procedure Fat32_MakeDirFileHtm(Device: byte; var DirFileName: TLongFileName); overload;
begin
  Fat32_MakeDirFileHtm(LocalVarFiles[Device], DirFileName);
end;


procedure Fat32_CopyFile(var SourceFileName: string; var DestinationFileName: string); overload;
begin
  Fat32_CopyFile(0, SourceFileName, 0, DestinationFileName);
end;

procedure Fat32_CopyFile(var SourceFile: TFileVar; var SourceFileName: string; var DestinationFile: TFileVar; var DestinationFileName: string); overload;
begin
  DynTFT_DebugConsole('Fat32_CopyFile not implemented');
end;

procedure Fat32_CopyFile(SourceDevice: byte; var SourceFileName: string; DestinationDevice: byte; var DestinationFileName: string); overload;
begin
  Fat32_CopyFile(LocalVarFiles[SourceDevice], SourceFileName, LocalVarFiles[DestinationDevice], DestinationFileName);
end;


function Fat32_FileCount(var Names: ShortString; Attr: byte): DWord; overload;
begin
  Result := Fat32_FileCount(0, Names, Attr);
end;

function Fat32_FileCount(var FileVar: TFilevar; var Names: ShortString; Attr: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_FileCount not implemented');
  Result := 0;
end;

function Fat32_FileCount(Device: byte; var Names: ShortString; Attr: byte): DWord; overload;
begin
  Result := Fat32_FileCount(LocalVarFiles[Device], Names, Attr);
end;



function Fat32_TotalSpace: DWord; overload;
begin
  Result := Fat32_TotalSpace(0);
end;

function Fat32_TotalSpace(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_TotalSpace not implemented');
  Result := 0;
end;


function Fat32_FreeSpace: DWord; overload;
begin
  Result := Fat32_FreeSpace(0);
end;

function Fat32_FreeSpace(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_FreeSpace not implemented');
  Result := 0;
end;


function Fat32_UsedSpace: DWord; overload;
begin
  Result := Fat32_UsedSpace(0);
end;

function Fat32_UsedSpace(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_UsedSpace not implemented');
  Result := 0;
end;


function Fat32_TotalSpace_KB: DWord; overload;
begin
  Result := Fat32_TotalSpace_KB(0);
end;

function Fat32_TotalSpace_KB(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_TotalSpace_KB not implemented');
  Result := 0;
end;


function Fat32_FreeSpace_KB: DWord; overload;
begin
  Result := Fat32_FreeSpace_KB(0);
end;

function Fat32_FreeSpace_KB(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_FreeSpace_KB not implemented');
  Result := 0;
end;


function Fat32_UsedSpace_KB: DWord; overload;
begin
  Result := Fat32_UsedSpace_KB(0);
end;

function Fat32_UsedSpace_KB(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_UsedSpace_KB not implemented');
  Result := 0;
end;


function Fat32_TotalSpace_MB: DWord; overload;
begin
  Result := Fat32_TotalSpace_MB(0);
end;

function Fat32_TotalSpace_MB(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_TotalSpace_MB not implemented');
  Result := 0;
end;


function Fat32_FreeSpace_MB: DWord; overload;
begin
  Result := Fat32_FreeSpace_MB(0);
end;

function Fat32_FreeSpace_MB(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_FreeSpace_MB not implemented');
  Result := 0;
end;


function Fat32_UsedSpace_MB: DWord; overload;
begin
  Result := Fat32_UsedSpace_MB(0);
end;

function Fat32_UsedSpace_MB(Device: byte): DWord; overload;
begin
  DynTFT_DebugConsole('Fat32_UsedSpace_MB not implemented');
  Result := 0;
end;


function Fat32_TotalSpace_GB: real; overload;
begin
  Result := Fat32_TotalSpace_GB(0);
end;

function Fat32_TotalSpace_GB(Device: byte): real; overload;
begin
  DynTFT_DebugConsole('Fat32_TotalSpace_GB not implemented');
  Result := 0;
end;


function Fat32_FreeSpace_GB: Real; overload;
begin
  Result := Fat32_FreeSpace_GB(0);
end;

function Fat32_FreeSpace_GB(Device: byte): Real; overload;
begin
  DynTFT_DebugConsole('Fat32_FreeSpace_GB not implemented');
  Result := 0;
end;


function Fat32_UsedSpace_GB: Real; overload;
begin
  Result := Fat32_UsedSpace_GB(0);
end;

function Fat32_UsedSpace_GB(Device: byte): Real; overload;
begin
  DynTFT_DebugConsole('Fat32_UsedSpace_GB not implemented');
  Result := 0;
end;


procedure ResetInitialization;  //used also for testing
var
  i: Integer;
begin
  for i := 0 to NrOfFat32Devices - 1 do
  begin
    BaseDirArr[i] := CUnsetBaseDir;
    Fat32_Initialized[i] := False;

    LocalVarFiles[i].Device := i; //255;
    LocalVarFiles[i].CurrentDir := '';
  end;
end;


procedure FAT32_SetBaseDirectory(ABaseDirectory: string); overload; //required on desktop, to set the path to the folder, which simulates the root of storage
begin
  FAT32_SetBaseDirectory(ABaseDirectory, 0);
end;


procedure FAT32_SetBaseDirectory(ABaseDirectory: string; Device: byte); overload; //required on desktop, to set the path to the folder, which simulates the root of storage
begin
  BaseDirArr[Device] := ABaseDirectory;
  if Length(BaseDirArr[Device]) > 1 then
    if BaseDirArr[Device][Length(BaseDirArr[Device])] = '\' then
      Delete(BaseDirArr[Device], Length(BaseDirArr[Device]), 1);
end;


function FAT32_GetBaseDirectory: string; overload;
begin
  Result := FAT32_GetBaseDirectory(0);
end;


function FAT32_GetBaseDirectory(Device: byte): string; overload;
begin
  Result := BaseDirArr[Device]
end;


procedure FAT32_GetAssignedFile(out AFileVar: TFileVar; Device: Byte); overload;
begin
  AFileVar := LocalVarFiles[Device];
end;


function FAT32_GetAssignedFile(Device: Byte): PFileVar; overload;
begin
  Result := @LocalVarFiles[Device];
end;


function FAT32IsInitialized(FileVar: TFilevar): Boolean;
begin
  if FileVar.Device > NrOfFat32Devices - 1 then
  begin
    DynTFT_DebugConsole('FileVar.Device is out of range when verifying if initialized.');
    Result := False;
  end
  else
    Result := Fat32_Initialized[FileVar.Device];
end;


function FAT32_GetFullPathFileName(Name: string): string; overload;
begin
  Result := FAT32_GetFullPathFileName(0, Name);
end;


function FAT32_GetFullPathFileName(var FileVar: TFileVar; Name: string): string; overload;
begin
  Result := BaseDirArr[FileVar.Device] + FileVar.CurrentDir + Name;
end;


function FAT32_GetFullPathFileName(Device: byte; Name: string): string; overload;
begin
  Result := FAT32_GetFullPathFileName(LocalVarFiles[Device], Name);
end;


procedure Fat32_FindClose; overload;
begin
  Fat32_FindClose(0);
end;


procedure Fat32_FindClose(var FileVar: TFilevar); overload;
begin
  SysUtils.FindClose(FileVar.SearchRec);
end;


procedure Fat32_FindClose(Device: byte); overload;
begin
  Fat32_FindClose(LocalVarFiles[Device]);
end;


function Fat32_DirItem: TFat32DirItem; overload;
begin
  Result := Fat32_DirItem(0);
end;


function Fat32_DirItem(var FileVar: TFilevar): TFat32DirItem; overload;
begin
  Result := FileVar.Fat32_DirItem;
end;


function Fat32_DirItem(Device: byte): TFat32DirItem; overload;
begin
  Result := Fat32_DirItem(LocalVarFiles[Device]);
end;


begin
  ResetInitialization;
end.
