unit TestDynTFTFAT32D_Fat32_FilePointer;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_FilePointer_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_FilePointer_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_FilePointer_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_FilePointer_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_FilePointer_ShouldReturnFilePosition0InAValidFile;
    procedure Lib_1_Fat32_FilePointer_ShouldReturnFilePosition8InAValidFile;
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


procedure TTestDynTFTFAT32D_Fat32_FilePointer_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_FilePointer_Tests.Lib_1_Fat32_FilePointer_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_FilePointer function.';
begin
  SetFirstBaseDir;

  Fat32_FilePointer;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_FilePointer_Tests.Lib_1_Fat32_FilePointer_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_FilePointer: file not assigned.';
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_FilePointer;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_FilePointer_Tests.Lib_1_Fat32_FilePointer_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_FilePointer: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestSeek.txt', faArchive);

  Fat32_FilePointer;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_FilePointer_Tests.Lib_1_Fat32_FilePointer_ShouldReturnFilePosition0InAValidFile;
const
  CExpectedErrorMessage = '';
var
  Size, Position: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestSeek.txt', faArchive);
  Fat32_Reset(Size);
  Fat32_Seek(0);

  Position := Fat32_FilePointer;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Position = 0, 'Expected file position to be 0 if seeking at 0.');
end;


procedure TTestDynTFTFAT32D_Fat32_FilePointer_Tests.Lib_1_Fat32_FilePointer_ShouldReturnFilePosition8InAValidFile;
const
  CExpectedErrorMessage = '';
var
  Size, Position: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestSeek.txt', faArchive);
  Fat32_Reset(Size);
  Fat32_Seek(8);

  Position := Fat32_FilePointer;
  
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Position = 8, 'Expected file position to be 8 if seeking at 8.');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_FilePointer_Tests.Suite);

end.

