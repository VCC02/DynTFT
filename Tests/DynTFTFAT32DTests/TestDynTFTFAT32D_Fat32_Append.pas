unit TestDynTFTFAT32D_Fat32_Append;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Append_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Append_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_Append_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_Append_ShouldReturnErrorIfFileNotFound;
    procedure Lib_1_Fat32_Append_ShouldAppendFile;
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


procedure TTestDynTFTFAT32D_Fat32_Append_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_Append_Tests.Lib_1_Fat32_Append_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Append procedure.';
begin
  SetFirstBaseDir;

  Fat32_Append;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Append_Tests.Lib_1_Fat32_Append_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_Append: file not assigned.';
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Append;

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Append_Tests.Lib_1_Fat32_Append_ShouldReturnErrorIfFileNotFound;
const
  CExpectedErrorMessage = 'Fat32_Append: file not found.';
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Assign(CNonExistentFileName, faCreate);
  DeleteFile(FAT32_GetFullPathFileName(CNonExistentFileName));  //Do not use FAT32_Delete here, because it Appends the internal state of "assigned" flag, required to trigger "file not found" error in FAT32_Append.
  Fat32_Append;                                            //"file not found" can be returned if the file is externally deleted, between Fat32_Assign and Fat32_Append

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Append_Tests.Lib_1_Fat32_Append_ShouldAppendFile;
const
  CExpectedErrorMessage = '';
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Assign('TestAppend.txt', faArchive);
  Fat32_Append;
         
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Fat32_FilePointer > 0, 'Expected file position to be greater than 0 after a call to Fat32_Append.');
  Assert(Fat32_Get_File_Size > 0, 'Expected file size to be greater than 0 after a call to Fat32_Append (content is still there).');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Append_Tests.Suite);

end.
