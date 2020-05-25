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

unit DynTFTFAT32;

{
  This file is a "Desktop" replacement for some of the functions in the mikroe's FAT32 library.
  It should be compiled for desktop only.
  This library can be used in desktop applications in a similar way the FAT32
  library is used on a microcontroller.
}

interface

uses
  Classes, SysUtils, DynTFTTypes, DynTFTUtils;

type
  int8 = ShortInt;
  uint8 = Byte;
  uint16 = Word;
  uint32 = DWord;
  __HANDLE = int8;

  __DIR = record
    NameExt: array[0..253] of Char; // file/directory name
    Attrib: uint8;               // file/directory attribute

    Size: uint32;              // file/directory size
    SearchRec: TSearchRec;
  end;
  P__DIR = ^__DIR;


const
  FAT32_MAX_FILES = 3;

const
  FILE_READ_F32   = $01;
  FILE_WRITE_F32  = $02;
  FILE_APPEND_F32 = $04;

  OK_F32 = 0;
  ERROR_F32 = -1;
  FOUND_F32 = 1;

  ATTR_ARCHIVE_F32 = $00000020;

var
  fat32_fdesc: array[0..FAT32_MAX_FILES - 1] of FILE;
  fat32_filename: array[0..FAT32_MAX_FILES - 1] of string;


function FAT32_Dev_Init: int8;
function FAT32_Init: int8;
function FAT32_Exists(name: string): int8;
function FAT32_Open(fn: string; mode: uint8): int8;
function FAT32_Close(fHandle: ShortInt): int8;
function FAT32_Read(fHandle: ShortInt; rdBuf: PByteArray; len: uint16): int8;
function FAT32_Write(fHandle: ShortInt; wrBuf: PByteArray; len: uint16): int8;
function FAT32_Seek(fHandle: ShortInt; position: uint32): int8;
function FAT32_Size(fname: string; var pSize: uint32): int8;
function FAT32_GetError: int8;
function FAT32_FindFirst(pD: P__DIR): int8;
function FAT32_FindNext(pD: P__DIR): int8;
function FAT32_FindClose(pD: P__DIR): int8; //see Delphi help for FindClose

procedure FAT32_SetBaseDirectory(ABaseDirectory: string);  //required on desktop, to set the path to the folder, which simulates the root of storage


implementation

const
  CUnsetBaseDir = '?'; //something not allowed on FAT32


var
  Initialized: Boolean;
  OpenFilesCount: Integer;
  BaseDirectory: string;


function FAT32_Dev_Init: int8;
begin
  DynTFT_DebugConsole('Calling FAT32_Dev_Init. Result 0');
  OpenFilesCount := 0;
  Result := 0;
end;


function FAT32_Init: int8;
begin
  Result := FAT32_Dev_Init;
  if Result = 0 then
    Initialized := True;
end;


function FAT32_Exists(name: string): int8;
begin
  if not Initialized then
  begin
    Result := -1;
    DynTFT_DebugConsole('FAT32 not initialized in FAT32_Exists function.');
    Exit;
  end;

  if FileExists(name) then
    Result := 1
  else
    Result := 0;
end;


function GetFirstAvailableFileSlot: int8;
var
  i: int8;
begin
  Result := -1;
  for i := 0 to FAT32_MAX_FILES - 1 do
    if fat32_filename[i] = '' then
    begin
      Result := i;
      Exit;
    end;
end;


function FAT32_Open(fn: string; mode: uint8): int8;
begin
  Result := -1;

  if not Initialized then
  begin
    DynTFT_DebugConsole('FAT32 not initialized in FAT32_Open function.');
    Exit;
  end;

  if BaseDirectory = CUnsetBaseDir then
  begin
    DynTFT_DebugConsole('... FAT32: Base directory not set. Please call FAT32_SetBaseDirectory with a path to a directory on your disk, simulating the root of storage media (e.g. SD card).');
    Exit;
  end;

  fn := BaseDirectory + fn;

  if not FileExists(fn) and (mode = FILE_READ_F32) then
  begin
    DynTFT_DebugConsole('File ' + fn + ' does not exist.');
    Exit;
  end;

  if OpenFilesCount < FAT32_MAX_FILES then
  begin
    Inc(OpenFilesCount);
    Result := GetFirstAvailableFileSlot;

    if Result = -1 then
    begin
      DynTFT_DebugConsole('No more available file slots. Please increase the value of FAT32_MAX_FILES constant.');
      Exit;
    end;

    AssignFile(fat32_fdesc[Result], fn);
    fat32_filename[Result] := fn;

    DynTFT_DebugConsole('Opening file: "' + fn + '" at handle ' + IntToStr(Result));

    case mode of
      FILE_READ_F32 :
      begin
        Filemode := fmOpenRead;
        Reset(fat32_fdesc[Result], 1);
      end;

      FILE_WRITE_F32 :
      begin
        if not FileExists(fn) then
          Rewrite(fat32_fdesc[Result], 1)
        else
        begin
          Filemode := fmOpenWrite;
          Reset(fat32_fdesc[Result], 1);
        end;
      end;

      FILE_APPEND_F32 :
      begin
        if not FileExists(fn) then
          Rewrite(fat32_fdesc[Result], 1)
        else
        begin
          Filemode := fmOpenWrite;
          Reset(fat32_fdesc[Result], 1);
        end;

        Seek(fat32_fdesc[Result], FileSize(fat32_fdesc[Result]));
      end;
    end; //case
  end
  else
    DynTFT_DebugConsole('Cannot open more files. Please increase the value of FAT32_MAX_FILES constant.');
end;


function FAT32_Close(fHandle: ShortInt): int8;
begin
  if not Initialized then
  begin
    Result := -1;
    DynTFT_DebugConsole('FAT32 not initialized in FAT32_Close function.');
    Exit;
  end;

  if (fHandle < 0) or (fHandle > FAT32_MAX_FILES - 1) then
  begin
    DynTFT_DebugConsole('File handle (' + IntToStr(fHandle) + ') is out of bounds in FAT32_Close. OpenFilesCount = ' + IntToStr(OpenFilesCount) + '  fHandle = ' + IntToStr(fHandle));
    Result := -1;
    Exit;
  end;

  if fat32_filename[fHandle] = '' then
  begin
    Result := -1;
    DynTFT_DebugConsole('File handle (' + IntToStr(fHandle) + ') is invalid in FAT32_Close. The file may already be closed.');
    Exit;
  end;

  CloseFile(fat32_fdesc[fHandle]);
  fat32_filename[fHandle] := '';
  Dec(OpenFilesCount);
  Result := 0;
end;


function FAT32_Read(fHandle: ShortInt; rdBuf: PByteArray; len: uint16): int8;
begin
  if not Initialized then
  begin
    Result := -1;
    DynTFT_DebugConsole('FAT32 not initialized in FAT32_Read function.');
    Exit;
  end;

  if (fHandle < 0) or (fHandle > OpenFilesCount - 1) then
  begin
    DynTFT_DebugConsole('File handle is out of bounds in FAT32_Read. OpenFilesCount = ' + IntToStr(OpenFilesCount) + '  fHandle = ' + IntToStr(fHandle) + '.  Make sure FAT32_Open returned a valid result.');
    Result := -1;
    Exit;
  end;

  try
    BlockRead(fat32_fdesc[fHandle], rdBuf^, len);
    Result := 0;
  except
    on E: EInOutError do
    begin
      DynTFT_DebugConsole('Exception in FAT32_Read. E = ' + E.Message + '       File: ' + fat32_filename[fHandle]);
      DynTFT_DebugConsole('File position: ' + IntToStr(FilePos(fat32_fdesc[fHandle])) + '  FileSize: ' + IntToStr(FileSize(fat32_fdesc[fHandle])));
      Result := -1;
    end;

    on
    E: Exception do
    begin
      DynTFT_DebugConsole('Exception in FAT32_Read. E = ' + E.Message + '       File: ' + fat32_filename[fHandle]);
      Result := -1;
    end;
  end;
end;


function FAT32_Write(fHandle: ShortInt; wrBuf: PByteArray; len: uint16): int8;
begin
  if not Initialized then
  begin
    Result := -1;
    DynTFT_DebugConsole('FAT32 not initialized in FAT32_Write function.');
    Exit;
  end;

  if (fHandle < 0) or (fHandle > OpenFilesCount - 1) then
  begin
    DynTFT_DebugConsole('File handle is out of bounds in FAT32_Write. OpenFilesCount = ' + IntToStr(OpenFilesCount) + '  fHandle = ' + IntToStr(fHandle) + '.  Make sure FAT32_Open returned a valid result.');
    Result := -1;
    Exit;
  end;

  try
    BlockWrite(fat32_fdesc[fHandle], wrBuf^, len);
    Result := 0;
  except
    on E: Exception do
    begin
      DynTFT_DebugConsole('Exception in FAT32_Write. E = ' + E.Message);
      Result := -1;
    end;
  end;
end;


function FAT32_Seek(fHandle: ShortInt; position: uint32): int8;
begin
  if not Initialized then
  begin
    Result := -1;
    DynTFT_DebugConsole('FAT32 not initialized in FAT32_Seek function.');
    Exit;
  end;

  if (fHandle < 0) or (fHandle > OpenFilesCount - 1) then
  begin
    DynTFT_DebugConsole('File handle is out of bounds in FAT32_Seek. OpenFilesCount = ' + IntToStr(OpenFilesCount) + '  fHandle = ' + IntToStr(fHandle) + '.  Make sure FAT32_Open returned a valid result.');
    Result := -1;
    Exit;
  end;

  Result := 0;
  try
    Seek(fat32_fdesc[fHandle], position);
  except
    on E: Exception do
    begin
      DynTFT_DebugConsole('Exception in FAT32_Seek. E = ' + E.Message);
      Result := -1;
    end;
  end;
end;


function FAT32_Size(fname: string; var pSize: uint32): int8;
var
  f: File;
begin
  try
    AssignFile(f, fname);
    Reset(f, 1);
    pSize := FileSize(f);
    Result := 0;
    CloseFile(f);
  except
    Result := -1;
  end;
end;


function FAT32_GetError: int8;
begin
  Result := 0;
  DynTFT_DebugConsole('FAT32_GetError is not implemented.');
end;


function FAT32_GetFileHandle(fname: string; var handle: __HANDLE): int8;
var
  i: Integer;
begin
  for i := 0 to FAT32_MAX_FILES - 1 do
    if fat32_filename[i] = fname then
    begin
      Result := 0;
      handle := i;
      Exit;
    end;
  Result := -1;
end;


function FAT32_FindFirst(pD: P__DIR): int8;
var
  FFResult: Integer;
  FileName: string;
begin
  if pd = nil then
  begin
    Result := ERROR_F32;
    Exit;
  end;

  if BaseDirectory = CUnsetBaseDir then
    DynTFT_DebugConsole('FindFirst in ' + BaseDirectory + ' will not work. Please call FAT32_SetBaseDirectory.');
                     
  FFResult := FindFirst(BaseDirectory + '*.*', faAnyFile, pd^.SearchRec);
  if FFResult = 0 then
  begin
    FileName := Copy(pd^.SearchRec.Name, 1, 253);

    Move(FileName[1], pd^.NameExt[0], Length(FileName) + 1);     // +1, to copy the null char
    pd^.Attrib := pd^.SearchRec.Attr;
    pd^.Size := pd^.SearchRec.Size;

    Result := FOUND_F32;
  end
  else
  begin
    Result := OK_F32; //no file found

    try
      RaiseLastOSError(FFResult);
    except
      on E: Exception do
        DynTFT_DebugConsole('FAT32_FindFirst: ' + E.Message + '    Searched as "' + BaseDirectory + '*.*' + '"');
    end;
  end;
end;


function FAT32_FindNext(pD: P__DIR): int8;
var
  FFResult: Integer;
  FileName: string;
begin
  if pd = nil then
  begin
    Result := ERROR_F32;
    Exit;
  end;

  FFResult := FindNext(pd^.SearchRec);
  if FFResult = 0 then
  begin
    FileName := Copy(pd^.SearchRec.Name, 1, 253);

    Move(FileName[1], pd^.NameExt[0], Length(FileName) + 1);     // +1, to copy the null char
    pd^.Attrib := pd^.SearchRec.Attr;
    pd^.Size := pd^.SearchRec.Size;

    Result := FOUND_F32;
  end
  else
    Result := OK_F32;
end;


function FAT32_FindClose(pD: P__DIR): int8;
begin
  if pd = nil then
  begin
    Result := ERROR_F32;
    Exit;
  end;
  
  FindClose(pd^.SearchRec);
  if (pd^.SearchRec.FindHandle = $FFFFFFFF) or (pd^.SearchRec.FindHandle = 0) then  //see FindClose from SysUtils
    Result := OK_F32
  else
    Result := ERROR_F32;
end;



procedure InitFileNames;
var
  i: Integer;
begin
  for i := 0 to FAT32_MAX_FILES - 1 do
    fat32_filename[i] := '';   //It is important to reset internal names to '', because FAT32_Open relies on these names, to keep track of available slots. 
end;


procedure FAT32_SetBaseDirectory(ABaseDirectory: string);
begin
  BaseDirectory := ABaseDirectory;
  if BaseDirectory > '' then
    if BaseDirectory[Length(BaseDirectory)] <> '\' then
      BaseDirectory := BaseDirectory + '\';
end;


begin
  Initialized := False;
  OpenFilesCount := 100; //a value outside the array of files
  InitFileNames;
  BaseDirectory := CUnsetBaseDir;
end.

