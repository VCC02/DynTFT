unit TestDynTFTFAT32D_Fat32_Seek;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Seek_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Seek_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_Seek_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_Seek_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_Seek_ShouldChangeFilePositionTo0InAValidFile;
    procedure Lib_1_Fat32_Seek_ShouldChangeFilePositionTo8InAValidFile;
    procedure Lib_1_Fat32_Seek_ShouldChangeFilePositionToOutsideOfAValidFile;
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


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.Lib_1_Fat32_Seek_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Seek procedure.';
begin
  SetFirstBaseDir;

  Fat32_Seek(0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.Lib_1_Fat32_Seek_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_Seek: file not assigned.';
begin
  InitTests;

  Fat32_Seek(0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.Lib_1_Fat32_Seek_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_Seek: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
begin
  InitTests;
  Fat32_Assign('TestSeek.txt', faArchive);

  Fat32_Seek(0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.Lib_1_Fat32_Seek_ShouldChangeFilePositionTo0InAValidFile;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;
begin
  InitTests;
  Fat32_Assign('TestSeek.txt', faArchive);
  Fat32_Reset(Size);

  Fat32_Seek(0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Fat32_FilePointer = 0, 'Expected file position to be 0 if called with 0.');
end;


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.Lib_1_Fat32_Seek_ShouldChangeFilePositionTo8InAValidFile;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;  
begin
  InitTests;
  Fat32_Assign('TestSeek.txt', faArchive);
  Fat32_Reset(Size);

  Fat32_Seek(8);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Fat32_FilePointer = 8, 'Expected file position to be 8 if called with 8.');
end;


procedure TTestDynTFTFAT32D_Fat32_Seek_Tests.Lib_1_Fat32_Seek_ShouldChangeFilePositionToOutsideOfAValidFile;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;  
begin
  InitTests;
  Fat32_Assign('TestSeek.txt', faArchive);
  Fat32_Reset(Size);

  Fat32_Seek(2000);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Fat32_FilePointer = Fat32_Get_File_Size, 'Expected file position to be filesize if called with greater than size.');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Seek_Tests.Suite);

end.
