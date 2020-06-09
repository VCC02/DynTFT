unit TestDynTFTFAT32D_Fat32_Init;

interface


uses
  SysUtils, TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_FAT32_Init_Tests = class(TTestTDynTFTFAT32DTests)
  published
    procedure Lib_1_2_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsNotSet;
    procedure Lib_1_2_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsSetToNonExistentDirectory;
    procedure Lib_1_2_Fat32_Init_ShouldReturnTrueIfAllIsWell;

    procedure Lib_1_2_MD_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsNotSet;
    procedure Lib_1_2_MD_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsSetToNonExistentDirectory;
    procedure Lib_1_2_MD_Fat32_Init_ShouldReturnTrueIfAllIsWell;
  end;


implementation


uses
  DynTFTFAT32D;


procedure TTestDynTFTFAT32D_FAT32_Init_Tests.Lib_1_2_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsNotSet;
const
  CExpectedErrorMessage = '... Fat32_Init: Base directory not set. Please call FAT32_SetBaseDirectory with a path to a directory on your disk, simulating the root of storage media (e.g. SD card).';
var
  TempRes: Boolean;
begin
  TempRes := Fat32_Init;

  Assert(not TempRes, 'Expected Fat32_Init to be False if Base directory is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_Init_Tests.Lib_1_2_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsSetToNonExistentDirectory;
const
  CExpectedErrorMessage = '... Fat32_Init: Base directory is set to a non-existing or unaccessible directory on your disk.';
var
  TempRes: Boolean;
begin
  FAT32_SetBaseDirectory(ExtractFilePath(ParamStr(0)) + 'Non-ExistentBaseDirectory');
  TempRes := Fat32_Init;

  Assert(not TempRes, 'Expected Fat32_Init to be False if Base directory is set to an invalid value.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_Init_Tests.Lib_1_2_Fat32_Init_ShouldReturnTrueIfAllIsWell;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  TempRes := Fat32_Init;

  Assert(TempRes, 'Expected Fat32_FileExists to be True if all went well.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_Init_Tests.Lib_1_2_MD_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsNotSet;
const
  CExpectedErrorMessage = '... Fat32_Init: Base directory not set. Please call FAT32_SetBaseDirectory with a path to a directory on your disk, simulating the root of storage media (e.g. SD card).';
var
  TempRes: Boolean;
begin
  TempRes := Fat32_Init(0);

  Assert(not TempRes, 'Expected Fat32_Init to be False if Base directory is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_Init_Tests.Lib_1_2_MD_Fat32_Init_ShouldReturnErrorIfBaseDirectoryIsSetToNonExistentDirectory;
const
  CExpectedErrorMessage = '... Fat32_Init: Base directory is set to a non-existing or unaccessible directory on your disk.';
var
  TempRes: Boolean;
begin
  FAT32_SetBaseDirectory(ExtractFilePath(ParamStr(0)) + 'Non-ExistentBaseDirectory', 0);
  TempRes := Fat32_Init(0);

  Assert(not TempRes, 'Expected Fat32_Init to be False if Base directory is set to an invalid value.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_Init_Tests.Lib_1_2_MD_Fat32_Init_ShouldReturnTrueIfAllIsWell;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  TempRes := Fat32_Init(0);

  Assert(TempRes, 'Expected Fat32_FileExists to be True if all went well.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;

    
initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_FAT32_Init_Tests.Suite);

end.
