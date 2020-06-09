unit TestDynTFTFAT32D_Fat32_Reset;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Reset_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Reset_ShouldReturnSize0IfFAT32NotInitialized;
    procedure Lib_1_Fat32_Reset_ShouldReturnSize0IfFileIsNotAssigned;
    procedure Lib_1_Fat32_Reset_ShouldReturnSize0IfFileNotFound;
    procedure Lib_1_Fat32_Reset_ShouldResetFile;
    procedure Lib_1_Fat32_Reset_ShouldReturnSize0ForAnEmptyFile;
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


procedure TTestDynTFTFAT32D_Fat32_Reset_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_Reset_Tests.Lib_1_Fat32_Reset_ShouldReturnSize0IfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Reset procedure.';
var
  Size: DWord;
begin
  SetFirstBaseDir;
  Size := MaxInt;

  Fat32_Reset(Size);

  Assert(Size = 0, 'Expected Size to be 0 if Fat32 is not initialized.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Reset_Tests.Lib_1_Fat32_Reset_ShouldReturnSize0IfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_Reset: file not assigned.';
var
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Size := MaxInt;

  Fat32_Reset(Size);

  Assert(Size = 0, 'Expected Size to be 0 if file is not assigned.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Reset_Tests.Lib_1_Fat32_Reset_ShouldReturnSize0IfFileNotFound;
const
  CExpectedErrorMessage = 'Fat32_Reset: file not found.';
var
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Size := MaxInt;

  Fat32_Assign(CNonExistentFileName, faCreate);
  DeleteFile(FAT32_GetFullPathFileName(CNonExistentFileName));  //Do not use FAT32_Delete here, because it resets the internal state of "assigned" flag, required to trigger "file not found" error in FAT32_Reset.
  Fat32_Reset(Size);                                            //"file not found" can be returned if the file is externally deleted, between Fat32_Assign and Fat32_Reset

  Assert(Size = 0, 'Expected Size to be 0 if file is not found.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Reset_Tests.Lib_1_Fat32_Reset_ShouldResetFile;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Assign('TestReset.txt', faArchive);
  Fat32_Reset(Size);
         
  Assert(Size > 0, 'Expected Size to be greater than 0 if file is successfully reset.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Fat32_FilePointer = 0, 'Expected file position to be 0 after a call to Fat32_Reset.');
end;


procedure TTestDynTFTFAT32D_Fat32_Reset_Tests.Lib_1_Fat32_Reset_ShouldReturnSize0ForAnEmptyFile;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Assign('Empty.txt', faArchive);
  Fat32_Reset(Size);
         
  Assert(Size = 0, 'Expected Size to be 0 if file is empty.');
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Fat32_FilePointer = 0, 'Expected file position to be 0 after a call to Fat32_Reset.');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Reset_Tests.Suite);

end.
