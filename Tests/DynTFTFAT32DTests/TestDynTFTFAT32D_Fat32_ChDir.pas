unit TestDynTFTFAT32D_Fat32_ChDir;

interface

uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_ChDir_Tests = class(TTestTDynTFTFAT32DTests)
  published
    procedure Lib_1_Fat32_ChDir_ShouldReturnFalseIfFAT32NotInitialized;
    procedure Lib_1_Fat32_ChDir_ShouldReturnFalseIfProvidingAPathWithBackslash;
    procedure Lib_1_Fat32_ChDir_ShouldReturnFalseIfProvidingEmpryPath;
    procedure Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingToRootAndAlreadyAtRoot;
    procedure Lib_1_Fat32_ChDir_ShouldReturnFalseIfProvidingANonExistentDirectory;
    procedure Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingToAValidDirectory;
    procedure Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingToAValidSubDirectory;
    procedure Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingOneDirectoryUp;
    procedure Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingOneDirectoryUpFromRoot;
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
  CExpectedToLeaveDirUnchangedWhenError = 'Expected Fat32_ChDir to leave current directory unchanged in case of an error.';
  CExpectedToLeaveDirUnchangedWhenRoot = 'Expected Fat32_ChDir to leave current directory unchanged when at root.';
  CExpectedToChangeDirectory = 'Expected Fat32_ChDir to change current directory.';


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnFalseIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_ChDir function.';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;

  TempRes := Fat32_ChDir('dummy');

  Assert(not TempRes, 'Expected Fat32_ChDir to be False if FAT32 is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnFalseIfProvidingAPathWithBackslash;
const
  CExpectedErrorMessage = 'Fat32_ChDir: No "\" allowed in provided directory name, only to change directory to root.';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  TempRes := Fat32_ChDir('path\with\backslash');
  Fat32_Curdir(AfterDir);

  Assert(not TempRes, 'Expected Fat32_ChDir to be False if provided with a path containing "\".');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, CExpectedToLeaveDirUnchangedWhenError);
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnFalseIfProvidingEmpryPath;
const
  CExpectedErrorMessage = 'Fat32_ChDir: LongFn cannot be empty.';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  TempRes := Fat32_ChDir('');
  Fat32_Curdir(AfterDir);

  Assert(not TempRes, 'Expected Fat32_ChDir to be False if provided with empty path.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, CExpectedToLeaveDirUnchangedWhenError);
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingToRootAndAlreadyAtRoot;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  TempRes := Fat32_ChDir('\');
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to root and already at root.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, CExpectedToLeaveDirUnchangedWhenRoot);
  Assert(AfterDir = '\', 'Root should be ''\'', but it was: ' + AfterDir);
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnFalseIfProvidingANonExistentDirectory;
const
  CExpectedErrorMessage = 'Fat32_ChDir: Cannot change to a non-existent directory.';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  TempRes := Fat32_ChDir('Non-existent directory');
  Fat32_Curdir(AfterDir);

  Assert(not TempRes, 'Expected Fat32_ChDir to be False if provided with a non-existent directory.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, CExpectedToLeaveDirUnchangedWhenError);
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingToAValidDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  TempRes := Fat32_ChDir('Folder1');
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to valid directory.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir <> AfterDir, CExpectedToChangeDirectory);
  Assert(AfterDir = 'Folder1', FormatTestResultMessage('Folder1', AfterDir));
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingToAValidSubDirectory;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  {TempRes :=} Fat32_ChDir('Folder1');
  TempRes := Fat32_ChDir('SubFolder1');
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to valid directory.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir <> AfterDir, CExpectedToChangeDirectory);
  Assert(AfterDir = 'SubFolder1', FormatTestResultMessage('SubFolder1', AfterDir));
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingOneDirectoryUp;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  {TempRes :=} Fat32_ChDir('Folder1');
  TempRes := Fat32_ChDir('..');
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path to valid directory.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, CExpectedToChangeDirectory);
  Assert(AfterDir = '\', FormatTestResultMessage('\', AfterDir));
end;


procedure TTestDynTFTFAT32D_Fat32_ChDir_Tests.Lib_1_Fat32_ChDir_ShouldReturnTrueIfChangingOneDirectoryUpFromRoot;
const
  CExpectedErrorMessage = 'Fat32_ChDir: Already at root.';
var
  TempRes: Boolean;
  BeforeDir, AfterDir: TLongFileName;
begin
  InitTests;

  Fat32_Curdir(BeforeDir);
  TempRes := Fat32_ChDir('..');
  Fat32_Curdir(AfterDir);

  Assert(TempRes, 'Expected Fat32_ChDir to be True if changing path from root to root.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(BeforeDir = AfterDir, CExpectedToChangeDirectory);
  Assert(AfterDir = '\', FormatTestResultMessage('\', AfterDir));
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_ChDir_Tests.Suite);
  
end.
