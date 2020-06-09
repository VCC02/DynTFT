unit TestDynTFTFAT32D_Fat32_Get_File_Size;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Get_File_Size_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_Get_File_Size_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_Get_File_Size_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_Get_File_Size_ShouldReturn0ForEmptyFile;
    procedure Lib_1_Fat32_Get_File_Size_ShouldReturnGreaterThan0ForFileWithContent;
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


procedure TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.Lib_1_Fat32_Get_File_Size_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Get_File_Size function.';
begin
  SetFirstBaseDir;

  Fat32_Get_File_Size;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.Lib_1_Fat32_Get_File_Size_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_Get_File_Size: file not assigned.';
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Get_File_Size;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.Lib_1_Fat32_Get_File_Size_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_Get_File_Size: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestSeek.txt', faArchive);

  Fat32_Get_File_Size;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.Lib_1_Fat32_Get_File_Size_ShouldReturn0ForEmptyFile;
const
  CExpectedErrorMessage = '';
var
  Size, FileSize: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('Empty.txt', faArchive);
  Fat32_Reset(Size);

  FileSize := Fat32_Get_File_Size;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FileSize = 0, 'Expected file size to be 0 for an empty file.');
  Assert(FileSize = Size, 'Extra file size validation for an empty file.');
end;


procedure TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.Lib_1_Fat32_Get_File_Size_ShouldReturnGreaterThan0ForFileWithContent;
const
  CExpectedErrorMessage = '';
var
  Size, FileSize: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestSeek.txt', faArchive);
  Fat32_Reset(Size);

  FileSize := Fat32_Get_File_Size;
  
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(FileSize = 10, 'Expected file size to be 8 for this test file.');
  Assert(FileSize = Size, 'Extra file size validation for an empty file.');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Get_File_Size_Tests.Suite);

end.
