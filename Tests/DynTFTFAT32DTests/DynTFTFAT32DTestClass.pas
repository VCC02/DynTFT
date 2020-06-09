unit DynTFTFAT32DTestClass;

interface

uses
  SysUtils, TestFramework, StdCtrls, DebugConsoleForm, DynTFTFAT32D;

type
  TDynTFTFAT32DTests = class(TObject)
  public
    procedure ClearDebugConsole;
    function GetFirstDebugConsoleLine: string;

    constructor Create;
    destructor Destroy; override;
  end;


  TTestTDynTFTFAT32DTests = class(TTestCase)
  strict private
    FDynTFTFAT32DTests: TDynTFTFAT32DTests;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    function GetTestResultErr: string;
    function FormatTestResultMessage(ExpectedMessage, TestResultMessage: string): string;

    procedure SetFirstBaseDir;
    procedure SetSecondBaseDir;
    procedure InitTests;
    procedure AssertContent(var Buffer: TArr4096Byte; ExpectedContent: string);
  end;

  
implementation

uses
  Forms, DynTFTUtils, Controls;


procedure TDynTFTFAT32DTests.ClearDebugConsole;
begin
  frmDebugConsole.ClearDebugConsole;
end;


function TDynTFTFAT32DTests.GetFirstDebugConsoleLine: string;
begin
  Result := frmDebugConsole.GetFirstDebugConsoleLine;
end;


constructor TDynTFTFAT32DTests.Create;
begin
  inherited Create;
  DynTFT_AssignDebugConsole(frmDebugConsole.memDebugConsole);
end;


destructor TDynTFTFAT32DTests.Destroy;
begin
  inherited Destroy;
end;



procedure TTestTDynTFTFAT32DTests.SetUp;
begin
  FDynTFTFAT32DTests := TDynTFTFAT32DTests.Create;
  FDynTFTFAT32DTests.ClearDebugConsole;
  ResetInitialization; //resets FAT32 init
end;


procedure TTestTDynTFTFAT32DTests.TearDown;
begin
  FDynTFTFAT32DTests.Free;
  FDynTFTFAT32DTests := nil;
end;


function TTestTDynTFTFAT32DTests.FormatTestResultMessage(ExpectedMessage, TestResultMessage: string): string;
begin
  Result := 'Returned message : "' + TestResultMessage + '"' + #13#10 +
            'was expected to be: "' + ExpectedMessage + '".';
end;


function TTestTDynTFTFAT32DTests.GetTestResultErr: string;
begin
  Result := FDynTFTFAT32DTests.GetFirstDebugConsoleLine;
end;


procedure TTestTDynTFTFAT32DTests.SetFirstBaseDir;
begin
  FAT32_SetBaseDirectory(ExtractFilePath(ParamStr(0)) + 'TestData', 0);
end;


procedure TTestTDynTFTFAT32DTests.SetSecondBaseDir;
begin
  FAT32_SetBaseDirectory(ExtractFilePath(ParamStr(0)) + 'SecondTestData', 1);
end;


procedure TTestTDynTFTFAT32DTests.InitTests;
begin
  SetFirstBaseDir;
  Fat32_Init;
end;


procedure TTestTDynTFTFAT32DTests.AssertContent(var Buffer: TArr4096Byte; ExpectedContent: string);
var
  i: Integer;
  MismatchFound: Integer;
begin
  MismatchFound := -1;
  for i := 1 to Length(ExpectedContent) do
    if Chr(Buffer[i - 1]) <> ExpectedContent[i] then
    begin
      MismatchFound := i;
      Break;
    end;

  Assert(MismatchFound = -1, 'Content mismatch at index ' + IntToStr(MismatchFound) + '. Expected "' + ExpectedContent[i] + '", but found "' + Chr(Buffer[i - 1]) + '"');  
end;

end.