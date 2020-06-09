unit TestDynTFTFAT32D_Fat32_FileVar_Init;

interface

uses
  SysUtils, TestFramework, DynTFTFAT32DTestClass;

type
  TTestDynTFTFAT32D_Fat32_FileVar_Init_Tests = class(TTestTDynTFTFAT32DTests)
  published
    procedure Lib_2_Fat32_FileVar_Init_ShouldReturnSetDeviceTo0;
    procedure Lib_2_And_MD_Fat32_FileVar_Init_ShouldReturnSetDeviceTo0;
  end;
  

implementation

uses
  DynTFTFAT32D;


procedure TTestDynTFTFAT32D_Fat32_FileVar_Init_Tests.Lib_2_Fat32_FileVar_Init_ShouldReturnSetDeviceTo0;
var
  FileVar: TFilevar;
begin
  FileVar.Device := 255; //just a value, different than expected
  FileVar.CurrentDir := 'dummy';
  Fat32_FileVar_Init(FileVar);

  Assert(FileVar.Device = 0, 'Expected FileVar.Device to be 0.');
  Assert(FileVar.CurrentDir = '\', 'Expected FileVar.CurrentDir to be ''''.');
end;


procedure TTestDynTFTFAT32D_Fat32_FileVar_Init_Tests.Lib_2_And_MD_Fat32_FileVar_Init_ShouldReturnSetDeviceTo0;
var
  FileVar: TFilevar;
begin
  FileVar.Device := 255; //just a value, different than expected
  FileVar.CurrentDir := 'dummy';
  Fat32_FileVar_Init(FileVar, 1);

  Assert(FileVar.Device = 1, 'Expected FileVar.Device to be 0.');
  Assert(FileVar.CurrentDir = '\', 'Expected FileVar.CurrentDir to be ''''.');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TTestDynTFTFAT32D_Fat32_FileVar_Init_Tests.Suite);

end.
