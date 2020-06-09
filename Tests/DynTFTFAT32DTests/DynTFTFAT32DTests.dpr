{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    DynTFT is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, version 3 of the License.

    DynTFT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with DynTFT, in COPYING.LESSER file.
    If not, see <http://www.gnu.org/licenses/>.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}


program DynTFTFAT32DTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options 
  to use the console test runner.  Otherwise the GUI test runner will be used by 
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestDynTFTFAT32D_Fat32_Init in 'TestDynTFTFAT32D_Fat32_Init.pas',
  TestDynTFTFAT32D_Fat32_FileExists in 'TestDynTFTFAT32D_Fat32_FileExists.pas',
  DynTFTFAT32DTestClass in 'DynTFTFAT32DTestClass.pas',
  DynTFTUtils in 'D:\DynTFT\DynTFTUtils.pas',
  DynTFTTypes in 'D:\DynTFT\DynTFTTypes.pas',
  DynTFTConsts in 'D:\DynTFT\DynTFTConsts.pas',
  TFT in 'D:\DynTFT\TFT.pas',
  DynTFTFAT32D in 'D:\DynTFT\DynTFTFAT32D.pas',
  DebugConsoleForm in 'DebugConsoleForm.pas' {frmDebugConsole},
  TestDynTFTFAT32D_Fat32_FileVar_Init in 'TestDynTFTFAT32D_Fat32_FileVar_Init.pas',
  TestDynTFTFAT32D_Fat32_Assign in 'TestDynTFTFAT32D_Fat32_Assign.pas',
  TestDynTFTFAT32D_Fat32_ChDir in 'TestDynTFTFAT32D_Fat32_ChDir.pas',
  TestDynTFTFAT32D_Fat32_PrevDir in 'TestDynTFTFAT32D_Fat32_PrevDir.pas',
  TestDynTFTFAT32D_Fat32_Reset in 'TestDynTFTFAT32D_Fat32_Reset.pas',
  TestDynTFTFAT32D_Fat32_Rewrite in 'TestDynTFTFAT32D_Fat32_Rewrite.pas',
  TestDynTFTFAT32D_Fat32_Append in 'TestDynTFTFAT32D_Fat32_Append.pas',
  TestDynTFTFAT32D_Fat32_Seek in 'TestDynTFTFAT32D_Fat32_Seek.pas',
  TestDynTFTFAT32D_Fat32_FilePointer in 'TestDynTFTFAT32D_Fat32_FilePointer.pas',
  TestDynTFTFAT32D_Fat32_Get_File_Size in 'TestDynTFTFAT32D_Fat32_Get_File_Size.pas',
  TestDynTFTFAT32D_Fat32_Read in 'TestDynTFTFAT32D_Fat32_Read.pas',
  TestDynTFTFAT32D_Fat32_Write in 'TestDynTFTFAT32D_Fat32_Write.pas',
  TestDynTFTFAT32D_Fat32_FindFirst in 'TestDynTFTFAT32D_Fat32_FindFirst.pas',
  TestDynTFTFAT32D_Fat32_FindNext in 'TestDynTFTFAT32D_Fat32_FindNext.pas';

{$R *.RES}

begin
  Application.Initialize;

  Application.CreateForm(TfrmDebugConsole, frmDebugConsole);
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

