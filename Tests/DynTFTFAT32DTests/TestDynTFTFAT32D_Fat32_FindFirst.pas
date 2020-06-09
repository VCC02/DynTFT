unit TestDynTFTFAT32D_Fat32_FindFirst;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_FindFirst_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_FindFirst_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_FindFirst_ShouldFindAnItem;
    procedure Lib_1_Fat32_FindFirst_ShouldFindADirectory;
    procedure Lib_1_Fat32_FindFirst_ShouldReturnFalseInAnEmptyDirectory;

    procedure Lib_1_Fat32_FindFirst_ShouldFindAnItemByExtension;
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


procedure TTestDynTFTFAT32D_Fat32_FindFirst_Tests.TearDown;
begin
  Fat32_FindClose;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_FindFirst_Tests.Lib_1_Fat32_FindFirst_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_FindFirst_FN function.';
begin
  SetFirstBaseDir;

  Fat32_FindFirst(faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_FindFirst_Tests.Lib_1_Fat32_FindFirst_ShouldFindAnItem;
const
  CExpectedErrorMessage = '';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindFirst');

  FindResult := Fat32_FindFirst(faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FindResult, 'At least an item has to be found.');
  Assert(Fat32_DirItem.FileName = 'SingleFile.txt', FormatTestResultMessage('SingleFile.txt', Fat32_DirItem.FileName));
end;


procedure TTestDynTFTFAT32D_Fat32_FindFirst_Tests.Lib_1_Fat32_FindFirst_ShouldFindADirectory;
const
  CExpectedErrorMessage = '';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindFirst');

  FindResult := Fat32_FindFirst(faDirectory);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FindResult, 'At least an item has to be found.');
  Assert(Fat32_DirItem.FileName = '.', FormatTestResultMessage('.', Fat32_DirItem.FileName));
end;


procedure TTestDynTFTFAT32D_Fat32_FindFirst_Tests.Lib_1_Fat32_FindFirst_ShouldReturnFalseInAnEmptyDirectory;
const
  CExpectedErrorMessage = 'FAT32_FindFirst_FN: There are no more files';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindFirst');
  Fat32_ChDir('EmptyDir');

  FindResult := Fat32_FindFirst(faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(not FindResult, 'No item should be found in an empty directory.');
  Assert(Fat32_DirItem.FileName = '', FormatTestResultMessage('', Fat32_DirItem.FileName));
end;


procedure TTestDynTFTFAT32D_Fat32_FindFirst_Tests.Lib_1_Fat32_FindFirst_ShouldFindAnItemByExtension;
const
  CExpectedErrorMessage = '';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindFirst_FN');

  FindResult := Fat32_FindFirst_FN('*.bmp', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FindResult, 'At least an item has to be found.');
  Assert(Fat32_DirItem.FileName = 'SingleFile.bmp', FormatTestResultMessage('SingleFile.bmp', Fat32_DirItem.FileName));
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_FindFirst_Tests.Suite);

end.
