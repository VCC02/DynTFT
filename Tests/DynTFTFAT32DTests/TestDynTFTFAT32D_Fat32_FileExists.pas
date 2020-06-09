unit TestDynTFTFAT32D_Fat32_FileExists;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  SysUtils, TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_FAT32_FileExists_Tests = class(TTestTDynTFTFAT32DTests)
  published
    procedure Lib_1_Fat32_FileExists_ShouldReturnErrorIfFAT32IsNotInitialized;
    procedure Lib_1_Fat32_FileExists_ShouldReturnFalseIfSearchedFileDoesNotExist;
    procedure Lib_1_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExists;

    procedure Lib_1_MD_Fat32_FileExists_ShouldReturnErrorIfFAT32IsNotInitialized;
    procedure Lib_1_MD_Fat32_FileExists_ShouldReturnFalseIfSearchedFileDoesNotExist;
    procedure Lib_1_MD_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExists;

    procedure Lib_2_And_MD_Fat32_FileExists_ShouldReturnErrorIfFAT32IsNotInitialized;
    procedure Lib_2_And_MD_Fat32_FileExists_ShouldReturnFalseIfSearchedFileDoesNotExist;
    procedure Lib_2_And_MD_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExists;
    procedure Lib_2_And_MD_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExistsInSubFolder;
  end;

  
implementation


uses
  DynTFTFAT32D;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_1_Fat32_FileExists_ShouldReturnErrorIfFAT32IsNotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_FileExists function.';
var
  TempRes: Boolean;
begin
  TempRes := Fat32_FileExists('Dummy filename', faArchive);

  Assert(not TempRes, 'Expected Fat32_FileExists to be False if library is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_1_Fat32_FileExists_ShouldReturnFalseIfSearchedFileDoesNotExist;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init;

  TempRes := Fat32_FileExists('Non-existent filename', faArchive);

  Assert(not TempRes, 'Expected Fat32_FileExists to be False if file does not exist.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_1_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExists;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init;

  TempRes := Fat32_FileExists('SomeFile.txt', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(TempRes, 'Expected Fat32_FileExists to be True if file exists.');
end;



procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_1_MD_Fat32_FileExists_ShouldReturnErrorIfFAT32IsNotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_FileExists function.';
var
  TempRes: Boolean;
begin
  TempRes := Fat32_FileExists(0, 'Dummy filename', faArchive);

  Assert(not TempRes, 'Expected Fat32_FileExists to be False if library is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_1_MD_Fat32_FileExists_ShouldReturnFalseIfSearchedFileDoesNotExist;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init(0);

  TempRes := Fat32_FileExists(0, 'Non-existent filename', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(not TempRes, 'Expected Fat32_FileExists to be False if file does not exist.');
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_1_MD_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExists;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
begin
  SetFirstBaseDir;
  Fat32_Init(0);

  TempRes := Fat32_FileExists(0, 'SomeFile.txt', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(TempRes, 'Expected Fat32_FileExists to be True if file exists.');
end;



procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_2_And_MD_Fat32_FileExists_ShouldReturnErrorIfFAT32IsNotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_FileExists function.';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  AFileVar.Device := 0; //set to 0 for this test
  TempRes := Fat32_FileExists(AFileVar, 'Dummy filename', faArchive);

  Assert(not TempRes, 'Expected Fat32_FileExists to be False if library is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_2_And_MD_Fat32_FileExists_ShouldReturnFalseIfSearchedFileDoesNotExist;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  SetFirstBaseDir;
  Fat32_Init(0);
  Fat32_FileVar_Init(AFileVar, 0);

  TempRes := Fat32_FileExists(AFileVar, 'Non-existent filename', faArchive);

  Assert(not TempRes, 'Expected Fat32_FileExists to be False if file does not exist.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_2_And_MD_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExists;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  SetFirstBaseDir;
  Fat32_Init(0);
  Fat32_FileVar_Init(AFileVar, 0);

  TempRes := Fat32_FileExists(AFileVar, 'SomeFile.txt', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(TempRes, 'Expected Fat32_FileExists to be True if file exists.');
end;


procedure TTestDynTFTFAT32D_FAT32_FileExists_Tests.Lib_2_And_MD_Fat32_FileExists_ShouldReturnTrueIfSearchedFileExistsInSubFolder;
const
  CExpectedErrorMessage = '';
var
  TempRes: Boolean;
  AFileVar: TFileVar;
begin
  SetFirstBaseDir;
  Fat32_Init(0);
  Fat32_FileVar_Init(AFileVar, 0);
  Fat32_ChDir(AFileVar, 'Folder1');

  TempRes := Fat32_FileExists(AFileVar, 'AnotherFile.txt', faArchive);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(TempRes, 'Expected Fat32_FileExists to be True if file exists.');
end;




initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_FAT32_FileExists_Tests.Suite);
end.

