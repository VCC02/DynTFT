unit TestDynTFTFAT32D_Fat32_PrevDir;

interface

uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_PrevDir_Tests = class(TTestTDynTFTFAT32DTests)
  published
    procedure Lib_1_Fat32_PrevDir_ShouldReturnPrevDirIfSuccessfullyChangedToValidDirectory;
    procedure Lib_1_Fat32_PrevDir_ShouldReturnToRootIfAlreadyAtRoot;
    procedure Lib_1_Fat32_PrevDir_ShouldReturnPrevDirIfSuccessfullyChangedToASecondValidDirectory;
    procedure Lib_1_Fat32_PrevDir_ShouldReturnPrevDirIfSuccessfullyChangedToTwoValidDirectories;
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


procedure TTestDynTFTFAT32D_Fat32_PrevDir_Tests.Lib_1_Fat32_PrevDir_ShouldReturnPrevDirIfSuccessfullyChangedToValidDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;
  TempRes := Fat32_ChDir('Folder1');
  
  Fat32_Curdir(BeforeDir);
  Fat32_PrevDir;
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to valid directory before going to previous.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir <> AfterDir, 'Expected previous directory to be different than root.');
  Assert(AfterDir = '\', FormatTestResultMessage('\', AfterDir));
end;


procedure TTestDynTFTFAT32D_Fat32_PrevDir_Tests.Lib_1_Fat32_PrevDir_ShouldReturnToRootIfAlreadyAtRoot;
const
  CExpectedErrorMessage = '';
var
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  Fat32_PrevDir;
  Fat32_Curdir(AfterDir);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, 'Expected previous directory to root.');
  Assert(AfterDir = '\', FormatTestResultMessage('\', AfterDir));
end;


procedure TTestDynTFTFAT32D_Fat32_PrevDir_Tests.Lib_1_Fat32_PrevDir_ShouldReturnPrevDirIfSuccessfullyChangedToASecondValidDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;
  Fat32_ChDir('Folder1');
  TempRes := Fat32_ChDir('SubFolder1');
  
  Fat32_Curdir(BeforeDir);
  Fat32_PrevDir;
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to valid directory before going to previous.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir <> AfterDir, 'Expected previous directory to be different than root.');
  Assert(AfterDir = 'Folder1', FormatTestResultMessage('Folder1', AfterDir));
end;


procedure TTestDynTFTFAT32D_Fat32_PrevDir_Tests.Lib_1_Fat32_PrevDir_ShouldReturnPrevDirIfSuccessfullyChangedToTwoValidDirectories;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;
  Fat32_ChDir('Folder1');
  TempRes := Fat32_ChDir('SubFolder1');

  Fat32_Curdir(BeforeDir);
  Fat32_PrevDir;
  Fat32_PrevDir;
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to valid directory before going to previous.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, 'Expected the second previous directory to the same.');
  Assert(AfterDir = 'SubFolder1', FormatTestResultMessage('SubFolder1', AfterDir));
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_PrevDir_Tests.Suite);  

end.
