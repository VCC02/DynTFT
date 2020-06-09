unit TestDynTFTFAT32D_Fat32_Read;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Read_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Read_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_Read_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_Read_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_Read_ShouldReturn0ForEmptyFile;
    procedure Lib_1_Fat32_Read_ShouldReturnContent;

    procedure Lib_1_Fat32_ReadBuffer_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_ReadBuffer_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_ReadBuffer_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_ReadBuffer_ShouldReturn0ForEmptyFile;
    procedure Lib_1_Fat32_ReadBuffer_ShouldReturn0ForReadingBeyondEndOfFile;
    procedure Lib_1_Fat32_ReadBuffer_ShouldReturnNumberOfReadBytesForFullReading;
    procedure Lib_1_Fat32_ReadBuffer_ShouldReturnNumberOfReadBytesForPartialReading;
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


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_Read_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Read function.';
var
  AData: Byte;
begin
  SetFirstBaseDir;

  Fat32_Read(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_Read_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_Read: file not assigned.';
var
  AData: Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_Read(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_Read_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_Read: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
var
  AData: Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestRead.txt', faArchive);

  Fat32_Read(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_Read_ShouldReturn0ForEmptyFile;
const
  CExpectedErrorMessage = 'Fat32_Read: reached end of file.';
var
  Size: DWord;
  AData: Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('Empty.txt', faArchive);
  Fat32_Reset(Size);

  Fat32_Read(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(AData = 0, 'Expected returned data to be 0 for an empty file.');
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_Read_ShouldReturnContent;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;
  AData: Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestRead.txt', faArchive);
  Fat32_Reset(Size);

  Fat32_Read(AData);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(AData = Ord('0'), FormatTestResultMessage('0', IntToStr(AData)));

  Fat32_Read(AData);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(AData = Ord('1'), FormatTestResultMessage('1', IntToStr(AData)));

  Fat32_Read(AData);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(AData = Ord('2'), FormatTestResultMessage('2', IntToStr(AData)));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_ReadBuffer function.';
var
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;

  Fat32_ReadBuffer(Buffer, 0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_ReadBuffer: file not assigned.';
var
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_ReadBuffer(Buffer, 0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_ReadBuffer: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
var
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestRead.txt', faArchive);

  Fat32_ReadBuffer(Buffer, 0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturn0ForEmptyFile;
const
  CExpectedErrorMessage = 'Fat32_ReadBuffer: reached end of file.';
var
  Size: DWord;
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('Empty.txt', faArchive);
  Fat32_Reset(Size);
  Buffer[0] := 255;

  Fat32_ReadBuffer(Buffer, 10);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Buffer[0] = 255, 'Expected returned data to be unmodified for an empty file.');
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturn0ForReadingBeyondEndOfFile;
const
  CExpectedErrorMessage = 'Fat32_ReadBuffer: reached end of file.';
var
  Size: DWord;
  Buffer: TArr4096Byte;
  ActualBytesRead: Word;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestRead.txt', faArchive);
  Fat32_Reset(Size);
  Buffer[0] := 255;
  Fat32_Seek(Fat32_Get_File_Size);

  ActualBytesRead := Fat32_ReadBuffer(Buffer, 10);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  Assert(Buffer[0] = 255, 'Expected returned data to be unmodified if reading beyond end of file.');
  Assert(ActualBytesRead = 0, FormatTestResultMessage('0', IntToStr(ActualBytesRead)));
end;


procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturnNumberOfReadBytesForFullReading;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;
  Buffer: TArr4096Byte;
  ActualBytesRead: Word;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestRead.txt', faArchive);
  Fat32_Reset(Size);
  Buffer[0] := 255;

  ActualBytesRead := Fat32_ReadBuffer(Buffer, 10);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  AssertContent(Buffer, '0123456789');
  Assert(ActualBytesRead = 10, FormatTestResultMessage('0', IntToStr(ActualBytesRead)));
end;


//partial reading because of EOF
procedure TTestDynTFTFAT32D_Fat32_Read_Tests.Lib_1_Fat32_ReadBuffer_ShouldReturnNumberOfReadBytesForPartialReading;
const
  CExpectedErrorMessage = '';
var
  Size: DWord;
  Buffer: TArr4096Byte;
  ActualBytesRead: Word;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestRead.txt', faArchive);
  Fat32_Reset(Size);
  Buffer[0] := 255;
  Fat32_Seek(10);

  ActualBytesRead := Fat32_ReadBuffer(Buffer, 10);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
  AssertContent(Buffer, 'ABCDEF');
  Assert(ActualBytesRead = 6, FormatTestResultMessage('0', IntToStr(ActualBytesRead)));
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Read_Tests.Suite);

end.
