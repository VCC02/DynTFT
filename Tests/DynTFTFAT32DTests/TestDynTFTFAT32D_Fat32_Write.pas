unit TestDynTFTFAT32D_Fat32_Write;

interface


uses
  TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_Write_Tests = class(TTestTDynTFTFAT32DTests)
  public
    procedure TearDown; override;
  published
    procedure Lib_1_Fat32_Write_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_Write_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_Write_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_Write_ShouldWriteContent;

    procedure Lib_1_Fat32_WriteBuffer_ShouldReturnErrorIfFAT32NotInitialized;
    procedure Lib_1_Fat32_WriteBuffer_ShouldReturnErrorIfFileIsNotAssigned;
    procedure Lib_1_Fat32_WriteBuffer_ShouldReturnErrorIfFileIsNotOpen;
    procedure Lib_1_Fat32_WriteBuffer_ShouldWriteContent;

    procedure Lib_1_Fat32_WriteConstBuffer_ShouldWriteContent;
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


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.TearDown;
begin
  Fat32_Close;
  inherited TearDown;
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_Write_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_Write function.';
var
  AData: Byte;
begin
  SetFirstBaseDir;
  AData := 40; //some dummy value

  Fat32_Write(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_Write_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_Write: file not assigned.';
var
  AData: Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  AData := 40; //some dummy value

  Fat32_Write(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_Write_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_Write: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
var
  AData: Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestWrite.txt', faArchive);
  AData := 40; //some dummy value

  Fat32_Write(AData);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_Write_ShouldWriteContent;
const
  CExpectedErrorMessage = '';
var
  AData: Byte;
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestWrite.txt', faArchive);
  Fat32_Reset(Size);
  Fat32_Read(AData);
  Fat32_Seek(0);

  Fat32_Write(AData + 1);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Fat32_Seek(0);
  Fat32_Read(AData);
  Assert(AData = Ord('1'), FormatTestResultMessage('1', IntToStr(AData)));

  Fat32_Seek(0);
  Fat32_Write(AData - 1);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Fat32_Seek(0);
  Fat32_Read(AData);
  Assert(AData = Ord('0'), FormatTestResultMessage('1', IntToStr(AData)));

  Fat32_Seek(0);
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_WriteBuffer_ShouldReturnErrorIfFAT32NotInitialized;
const
  CExpectedErrorMessage = 'FAT32 not initialized in Fat32_WriteBuffer function.';
var
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;

  Fat32_WriteBuffer(Buffer, 0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_WriteBuffer_ShouldReturnErrorIfFileIsNotAssigned;
const
  CExpectedErrorMessage = 'Fat32_WriteBuffer: file not assigned.';
var
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;

  Fat32_WriteBuffer(Buffer, 0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_WriteBuffer_ShouldReturnErrorIfFileIsNotOpen;
const
  CExpectedErrorMessage = 'Fat32_WriteBuffer: file not open for reading or writing (see Fat32_Reset, Fat32_Rewrite, Fat32_Append).';
var
  Buffer: TArr4096Byte;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestWrite.txt', faArchive);

  Fat32_WriteBuffer(Buffer, 0);

  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));
end;


procedure PrepareBuffer_Set1(var Buffer: TArr4096Byte);
begin
  Buffer[0] := Ord('A');
  Buffer[1] := Ord('B');
  Buffer[2] := Ord('C');
  Buffer[3] := Ord('D');
end;


procedure PrepareBuffer_Set2(var Buffer: TArr4096Byte);
begin
  Buffer[0] := Ord('4');
  Buffer[1] := Ord('5');
  Buffer[2] := Ord('6');
  Buffer[3] := Ord('7');
end;


procedure ClearBuffer(var Buffer: TArr4096Byte);
var
  i: Integer;
begin
  for i := 0 to 4095 do
    Buffer[i] := 0;
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_WriteBuffer_ShouldWriteContent;
const
  CExpectedErrorMessage = '';
var
  Buffer: TArr4096Byte;
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestWrite.txt', faArchive);
  Fat32_Reset(Size);
  
  Fat32_Seek(4);
  PrepareBuffer_Set1(Buffer);
  Fat32_WriteBuffer(Buffer, 4);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Fat32_Seek(4);
  ClearBuffer(Buffer);
  Fat32_ReadBuffer(Buffer, 4);
  AssertContent(Buffer, 'ABCD');

  Fat32_Seek(4);
  PrepareBuffer_Set2(Buffer);
  Fat32_WriteBuffer(Buffer, 4);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Fat32_Seek(4);
  ClearBuffer(Buffer);
  Fat32_ReadBuffer(Buffer, 4);
  AssertContent(Buffer, '4567');

  Fat32_Seek(0);
end;


procedure TTestDynTFTFAT32D_Fat32_Write_Tests.Lib_1_Fat32_WriteConstBuffer_ShouldWriteContent;
const
  CExpectedErrorMessage = '';
var
  Buffer: TArr4096Byte;
  Size: DWord;
begin
  SetFirstBaseDir;
  Fat32_Init;
  Fat32_Assign('TestWrite.txt', faArchive);
  Fat32_Reset(Size);
  
  Fat32_Seek(4);
  PrepareBuffer_Set1(Buffer);
  Fat32_Write_Const_Buffer(@Buffer, 4);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Fat32_Seek(4);
  ClearBuffer(Buffer);
  Fat32_ReadBuffer(Buffer, 4);
  AssertContent(Buffer, 'ABCD');

  Fat32_Seek(4);
  PrepareBuffer_Set2(Buffer);
  Fat32_Write_Const_Buffer(@Buffer, 4);
  Assert(GetTestResultErr = CExpectedErrorMessage, FormatTestResultMessage(CExpectedErrorMessage, GetTestResultErr));

  Fat32_Seek(4);
  ClearBuffer(Buffer);
  Fat32_ReadBuffer(Buffer, 4);
  AssertContent(Buffer, '4567');

  Fat32_Seek(0);
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_Write_Tests.Suite);
  
end.
