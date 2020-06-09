unit TestDynTFTFAT32D_Fat32_FindNext;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_FindNext_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_FindNext_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_FindNext_ShouldFindNextItem;
    procedure Lib_1_Fat32_FindNext_ShouldReturnFalseIfNoMoreItems;
    procedure Lib_1_Fat32_FindNext_ShouldFindNextItemByExtension;
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


procedure TTestDynTFTFAT32D_Fat32_FindNext_Tests.TearDown;
begin
  Fat32_FindClose;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_FindNext_Tests.Lib_1_Fat32_FindNext_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_FindNext_FN function.';
begin
  SetFirstBaseDir;

  Fat32_FindNext(faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_FindNext_Tests.Lib_1_Fat32_FindNext_ShouldFindNextItem;
const
  CExpectedErrorMessage = '';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindNext');

  Fat32_FindFirst(faArchive);
  Assert(Fat32_DirItem.FileName = 'FirstFile.txt', FormatTestResultMessage('FirstFile.txt', Fat32_DirItem.FileName));
  
  FindResult := Fat32_FindNext(faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FindResult, 'At least an item has to be found.');
  Assert(Fat32_DirItem.FileName = 'SecondFile.txt', FormatTestResultMessage('SecondFile.txt', Fat32_DirItem.FileName));
end;


procedure TTestDynTFTFAT32D_Fat32_FindNext_Tests.Lib_1_Fat32_FindNext_ShouldReturnFalseIfNoMoreItems;
const
  CExpectedErrorMessage = 'Fat32_FindNext_FN: There are no more files';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindNext');
  Fat32_FindFirst(faArchive);  //FirstFile.txt
  Fat32_FindNext(faArchive);   //SecondFile.txt
  
  FindResult := Fat32_FindNext(faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(not FindResult, 'At least an item has to be found.');
  Assert(Fat32_DirItem.FileName = '', FormatTestResultMessage('', Fat32_DirItem.FileName));
end;


procedure TTestDynTFTFAT32D_Fat32_FindNext_Tests.Lib_1_Fat32_FindNext_ShouldFindNextItemByExtension;
const
  CExpectedErrorMessage = '';
var
  FindResult: Boolean;
begin
  InitTests;
  Fat32_ChDir('TestFindNext_FN');

  Fat32_FindFirst_FN('*.bmp', faArchive);
  Assert(Fat32_DirItem.FileName = 'FirstFile.bmp', FormatTestResultMessage('FirstFile.bmp', Fat32_DirItem.FileName));
  
  FindResult := Fat32_FindNext_FN('*.bmp', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FindResult, 'At least an item has to be found.');
  Assert(Fat32_DirItem.FileName = 'SecondFile.bmp', FormatTestResultMessage('SecondFile.bmp', Fat32_DirItem.FileName));
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_FindNext_Tests.Suite);

end.
