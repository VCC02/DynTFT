unit TestDynTFTFAT32D_Fat32_Assign;

interface

uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Assign_Tests = class(TTestTDynTFTFAT32DTests)
  private
    procedure InitTwoDevices;
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Assign_ShouldReturnFalseIfFAT32IsNotInitialized;
    procedure Lib_1_Fat32_Assign_ShouldReturnFalseIfCannotAssignFile;
    procedure Lib_1_Fat32_Assign_ShouldReturnTrueIfFileDoesNotExistAndIsCreatedByAssign;
    procedure Lib_1_Fat32_Assign_ShouldReturnTrueIfFileExists;
    procedure Lib_1_Fat32_Assign_ShouldReturnTrueIfFileExistsInSubDirectory;

    procedure Lib_2_And_MD_Fat32_Assign_ShouldReturnFalseIfFileVarIsNotInitialized;
    procedure Lib_2_And_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignFile;
    procedure Lib_2_And_MD_Fat32_Assign_ShouldReturnTrueIfFileDoesNotExistAndIsCreatedByAssign;
    procedure Lib_2_And_MD_Fat32_Assign_ShouldReturnTrueIfFileExists;
    procedure Lib_2_And_MD_Fat32_Assign_ShouldReturnTrueIfFileExistsInSubDirectory;

    procedure Lib_1_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignFile;
    procedure Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfFileDoesNotExistAndIsCreatedByAssign;
    procedure Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfFileExists;
    procedure Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfFileExistsInSubDirectory;

    procedure Lib_1_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignTwoFilesOnTwoDevices;
    procedure Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesDoNotExistAndAreCreatedByAssign;
    procedure Lib_1_MD_Fat32_Assign_ShouldReturnTrueForTwoExistentFilesOnTwoDevices;
    procedure Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesExistInSubDirectoriesOnTwoDevices;

    procedure Lib_2_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignTwoFilesOnTwoDevices;
    procedure Lib_2_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesDoNotExistAndAreCreatedByAssign;
    procedure Lib_2_MD_Fat32_Assign_ShouldReturnTrueForTwoExistentFilesOnTwoDevices;
    procedure Lib_2_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesExistInSubDirectoriesOnTwoDevices;

    procedure Lib_2_Fat32_Assign_ShouldReturnTrueIfTwoFilesExistInSubDirectoriesOnSameDevice;
  end;


implementation

uses
  DynTFTFAT32D

{$IFDEF UNIX}
  ;
{$ELSE}
  , Windows
{$ENDIF}
  , SysUtils;

const
  CNonExistentFileName = 'Non-existent.txt';


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.TearDown;
var
  AFileVar: PFileVar;
  i: Integer;
begin
  AFileVar := FAT32_GetAssignedFile(0);

  try
    try
      if FileExists(FAT32_GetBaseDirectory + CNonExistentFileName) then
        DeleteFile(FAT32_GetBaseDirectory + CNonExistentFileName);

      if FileExists(FAT32_GetBaseDirectory + AFileVar.CurrentDir + CNonExistentFileName) then
        DeleteFile(FAT32_GetBaseDirectory + AFileVar.CurrentDir + CNonExistentFileName);
    finally
      inherited TearDown;
    end;
  except
    RaiseLastOSError;  //Nothing to do here. The file may not be open or it may not exist at all.
  end;

  for i := 0 to NrOfFat32Devices - 1 do
  begin
    AFileVar := FAT32_GetAssignedFile(0);
    
    try
      try
        if FileExists(FAT32_GetBaseDirectory(i) + CNonExistentFileName) then
          DeleteFile(FAT32_GetBaseDirectory(i) + CNonExistentFileName);

        if FileExists(FAT32_GetBaseDirectory(i) + AFileVar.CurrentDir + CNonExistentFileName) then
          DeleteFile(FAT32_GetBaseDirectory(i) + AFileVar.CurrentDir + CNonExistentFileName);
      finally
        inherited TearDown;
      end;
    except
      RaiseLastOSError;  //Nothing to do here. The file may not be open or it may not exist at all.
    end;
  end;
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_Fat32_Assign_ShouldReturnFalseIfFAT32IsNotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Assign function.';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;

  TempRes := Fat32_Assign(CNonExistentFileName, faArchive);

  Assert(not TempRes, 'Expected Fat32_Assign to be False if FAT32 is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_Fat32_Assign_ShouldReturnFalseIfCannotAssignFile;
const
  CExpectedErrorMessage = 'File not found.';
var
  TempRes: Boolean;
begin
  InitTests;

  TempRes := Fat32_Assign(CNonExistentFileName, faArchive);

  Assert(not TempRes, 'Expected Fat32_Assign to be False if file cannot be assigned.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_Fat32_Assign_ShouldReturnTrueIfFileDoesNotExistAndIsCreatedByAssign;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  InitTests;

  TempRes := Fat32_Assign(CNonExistentFileName, faCreate);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_Fat32_Assign_ShouldReturnTrueIfFileExists;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  InitTests;

  TempRes := Fat32_Assign('SomeFile.txt', faArchive);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file exists.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_Fat32_Assign_ShouldReturnTrueIfFileExistsInSubDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  InitTests;
  Fat32_ChDir('Folder1');

  TempRes := Fat32_Assign('AnotherFile.txt', faArchive);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file exists.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;

///

procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_And_MD_Fat32_Assign_ShouldReturnFalseIfFileVarIsNotInitialized;
const
  CExpectedErrorMessage = 'FileVar not initialized in Fat32_Assign function. Please call Fat32_FileVar_Init.';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  InitTests;

  AFileVar.Device := 0; //the test should not now about the internals of TFileVar, but at the same time, it is possible that the Device field of this variable would be out of range at this point, triggering a different error
  TempRes := Fat32_Assign(AFileVar, CNonExistentFileName, faArchive);

  Assert(not TempRes, 'Expected Fat32_Assign to be False if FAT32 is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_And_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignFile;
const
  CExpectedErrorMessage = 'File not found.';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  InitTests;
  Fat32_FileVar_Init(AFileVar);

  TempRes := Fat32_Assign(AFileVar, CNonExistentFileName, faArchive);

  Assert(not TempRes, 'Expected Fat32_Assign to be False if file cannot be assigned.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_And_MD_Fat32_Assign_ShouldReturnTrueIfFileDoesNotExistAndIsCreatedByAssign;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  InitTests;
  Fat32_FileVar_Init(AFileVar);

  TempRes := Fat32_Assign(AFileVar, CNonExistentFileName, faCreate);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_And_MD_Fat32_Assign_ShouldReturnTrueIfFileExists;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  InitTests;
  Fat32_FileVar_Init(AFileVar);

  TempRes := Fat32_Assign(AFileVar, 'SomeFile.txt', faArchive);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file exists.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_And_MD_Fat32_Assign_ShouldReturnTrueIfFileExistsInSubDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  InitTests;
  Fat32_FileVar_Init(AFileVar);
  Fat32_ChDir(AFileVar, 'Folder1');

  TempRes := Fat32_Assign(AFileVar, 'AnotherFile.txt', faArchive);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file exists.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignFile;
const
  CExpectedErrorMessage = 'File not found.';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init(0);

  TempRes := Fat32_Assign(0, CNonExistentFileName, faArchive);

  Assert(not TempRes, 'Expected Fat32_Assign to be False if file cannot be assigned.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfFileDoesNotExistAndIsCreatedByAssign;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init(0);

  TempRes := Fat32_Assign(0, CNonExistentFileName, faCreate);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfFileExists;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init(0);

  TempRes := Fat32_Assign(0, 'SomeFile.txt', faArchive);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file exists.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfFileExistsInSubDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init(0);
  Fat32_ChDir(0, 'Folder1');

  TempRes := Fat32_Assign(0, 'AnotherFile.txt', faArchive);

  Assert(TempRes, 'Expected Fat32_Assign to be True if file exists.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


//multi device tests

procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.InitTwoDevices;
begin
  SetFirstBaseDir;
  SetSecondBaseDir;
  Fat32_Init(0);
  Fat32_Init(1);
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignTwoFilesOnTwoDevices;
const
  CExpectedErrorMessage = 'File not found.';
var
  TempRes1, TempRes2: Boolean;
begin
  InitTwoDevices;

  TempRes1 := Fat32_Assign(0, CNonExistentFileName, faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(1, CNonExistentFileName, faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(not TempRes1, 'Expected Fat32_Assign to be False if file cannot be assigned.');
  Assert(not TempRes2, 'Expected Fat32_Assign to be False if file cannot be assigned.');
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesDoNotExistAndAreCreatedByAssign;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
begin
  InitTwoDevices;

  TempRes1 := Fat32_Assign(0, CNonExistentFileName, faCreate);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(1, CNonExistentFileName, faCreate);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnTrueForTwoExistentFilesOnTwoDevices;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
begin
  InitTwoDevices;

  TempRes1 := Fat32_Assign(0, 'SomeFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(1, 'SomeFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file exists.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file exists.');
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_1_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesExistInSubDirectoriesOnTwoDevices;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
begin
  InitTwoDevices;
  Fat32_ChDir(0, 'Folder1');
  Fat32_ChDir(1, 'Folder2');

  TempRes1 := Fat32_Assign(0, 'AnotherFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(1, 'AnotherSecondFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file exists.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file exists.');
end;


procedure InitTwoFileVarsOnTwoDevices(var AFileVar1, AFileVar2: TFileVar);
begin
  Fat32_FileVar_Init(AFileVar1, 0);
  Fat32_FileVar_Init(AFileVar2, 1);
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_MD_Fat32_Assign_ShouldReturnFalseIfCannotAssignTwoFilesOnTwoDevices;
const
  CExpectedErrorMessage = 'File not found.';
var
  TempRes1, TempRes2: Boolean;
  AFileVar1, AFileVar2: TFileVar;
begin
  InitTwoDevices;
  InitTwoFileVarsOnTwoDevices(AFileVar1, AFileVar2);

  TempRes1 := Fat32_Assign(AFileVar1, CNonExistentFileName, faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(AFileVar2, CNonExistentFileName, faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(not TempRes1, 'Expected Fat32_Assign to be False if file cannot be assigned.');
  Assert(not TempRes2, 'Expected Fat32_Assign to be False if file cannot be assigned.');
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesDoNotExistAndAreCreatedByAssign;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
  AFileVar1, AFileVar2: TFileVar;
begin
  InitTwoDevices;
  InitTwoFileVarsOnTwoDevices(AFileVar1, AFileVar2);

  TempRes1 := Fat32_Assign(AFileVar1, CNonExistentFileName, faCreate);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(AFileVar2, CNonExistentFileName, faCreate);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file does not exist and it is created by Assign function.');
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_MD_Fat32_Assign_ShouldReturnTrueForTwoExistentFilesOnTwoDevices;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
  AFileVar1, AFileVar2: TFileVar;
begin
  InitTwoDevices;
  InitTwoFileVarsOnTwoDevices(AFileVar1, AFileVar2);

  TempRes1 := Fat32_Assign(AFileVar1, 'SomeFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(AFileVar2, 'SomeFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file exists.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file exists.');
end;


procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_MD_Fat32_Assign_ShouldReturnTrueIfTwoFilesExistInSubDirectoriesOnTwoDevices;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
  AFileVar1, AFileVar2: TFileVar;
begin
  InitTwoDevices;
  InitTwoFileVarsOnTwoDevices(AFileVar1, AFileVar2);
  Fat32_ChDir(AFileVar1, 'Folder1');
  Fat32_ChDir(AFileVar2, 'Folder2');

  TempRes1 := Fat32_Assign(AFileVar1, 'AnotherFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(AFileVar2, 'AnotherSecondFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file exists.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file exists.');
end;


//ToDo  two file vars on the same device
procedure TTestDynTFTFAT32D_Fat32_Assign_Tests.Lib_2_Fat32_Assign_ShouldReturnTrueIfTwoFilesExistInSubDirectoriesOnSameDevice;
const
  CExpectedErrorMessage = '';
var
  TempRes1, TempRes2: Boolean;
  AFileVar1, AFileVar2: TFileVar;
begin
  SetFirstBaseDir;
  Fat32_Init(0);
  Fat32_FileVar_Init(AFileVar1, 0);
  Fat32_FileVar_Init(AFileVar2, 0);
  Fat32_ChDir(AFileVar1, 'Folder1');
  Fat32_ChDir(AFileVar2, 'Folder10');

  TempRes1 := Fat32_Assign(AFileVar1, 'AnotherFile.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  TempRes2 := Fat32_Assign(AFileVar2, 'AnotherFile10.txt', faArchive);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Assert(TempRes1, 'Expected Fat32_Assign to be True if file exists.');
  Assert(TempRes2, 'Expected Fat32_Assign to be True if file exists.');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Assign_Tests.Suite);

end.
