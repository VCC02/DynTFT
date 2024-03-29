{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017, 2022 VCC
    initial release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this file,
    You can obtain one at https://mozilla.org/MPL/2.0/.

    Copyright (c) 2022, VCC  https://github.com/VCC02

    Alternatively, the contents of this file may be used under the terms
    of the GNU Lesser General Public License Version 3, as described below:

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

unit TFT;

{ - VCC -
2017.11.28 - Made sure the unit can be compiled by Turbo Delphi 2006
2017.11.05 - Creating file with a few procedures: TFT_Color16bitToRGB, TFT_Set_Pen, TFT_Set_Font, TFT_Write_Text, TFT_Line  etc

This unit emulates VTFT functions, used in a FreePascal/Delphi project. It should not be compiled for microcontroller.
}

{$H+}

interface

uses
  Classes, SysUtils, Graphics;
  
type
  PByte = System.PByte;
  DWord = Cardinal;

  TDynTFTFontSettings = record
    FontName: string;
    IdentifierName: string;
    FontSize: Integer;
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
    StrikeOut: Boolean;
    Charset: Integer;
    Pitch: TFontPitch;
  end;
  PDynTFTFontSettings = ^TDynTFTFontSettings;

procedure TFT_Init(display_width, display_height: Word);
procedure TFT_Set_Pen(pen_color: TColor; pen_width: Byte);
procedure TFT_Set_Brush(brush_enabled: Byte; brush_color: TColor; gradient_enabled, gradient_orientation: Byte; gradient_color_from, gradient_color_to: TColor);
procedure TFT_Set_Font(activeFont: PByte; font_color: TColor; font_orientation: Word);
procedure TFT_Set_Ext_Font(activeFont: {$IFDEF CPU64} QWord; {$ELSE} DWord; {$ENDIF} font_color: TColor; font_orientation: Word);
procedure TFT_Write_Text(AText: string; x, y: Word);
procedure TFT_Line(x1, y1, x2, y2: Integer);
procedure TFT_H_Line(x_start, x_end, y_pos: Integer);
procedure TFT_V_Line(y_start, y_end, x_pos: Integer);
procedure TFT_Dot(x, y: Integer; Color: TColor);
procedure TFT_Fill_Screen(color: TColor);
procedure TFT_Rectangle(x_upper_left, y_upper_left, x_bottom_right, y_bottom_right: Integer);
procedure TFT_Circle(x_center, y_center, radius: Integer);

function RGB(R, G, B: Byte): Integer;  //define a function for RGB, to avoid using compiler directives. Since Windows unit is not included, exposing this function will be useful.
procedure TrueColorToRGB(AColor: TColor; var R, G, B: Byte);
procedure TFT_Color16bitToRGB(color: Word; rgb_red, rgb_green, rgb_blue: PByte; IncreasedBrightness: Boolean = False);
function TrueColorTo16bitColor(ATrueColor: TColor): Word;
function U16bitColorToTrueColor(A16bitColor: Word; IncreasedBrightness: Boolean = False): TColor;
procedure TFT_Write_Text_Return_Pos(AString: string; x, y: Word);


var
  GCanvas: TCanvas; // global variable, used as TFT screen
  TFT_DISP_WIDTH: Word;
  TFT_DISP_HEIGHT: Word;

  caption_length: Word;
  caption_height: Word;

  UseTFTTrueColor: Boolean;

implementation

uses
  DynTFTConsts;

var
  FCurrentPenColor: TColor; //used to restore the color
  FGradientEnabled: Byte;
  FGradientOrientation: Byte;
  FGradientColorFrom, FGradientColorTo: TColor;


procedure TFT_Init(display_width, display_height: Word);
begin
  TFT_DISP_WIDTH := display_width;
  TFT_DISP_HEIGHT := display_height;
end;


function TFT_RGBToColor16bit(rgb_red, rgb_green, rgb_blue: Byte): Word;
var
  R, G, B: DWord;
begin
  B := (rgb_blue shr 3) and $1F;
  G := ((rgb_green shr 2) and $3F) shl 5;
  R := ((rgb_red shr 3) and $1F) shl 11;
  Result := R or B or G;
end;


procedure TFT_Color16bitToRGB(color: Word; rgb_red, rgb_green, rgb_blue: PByte; IncreasedBrightness: Boolean = False);
begin
  rgb_red^ := (color shr 11) shl 3;
  rgb_green^ := (color shr 5) shl 2;
  rgb_blue^ := (color and $1F) shl 3;

  if IncreasedBrightness then
  begin
    if rgb_red^ > 0 then
      rgb_red^ := rgb_red^ or $07;

    if rgb_green^ > 0 then
      rgb_green^ := rgb_green^ or $03;

    if rgb_blue^ > 0 then
      rgb_blue^ := rgb_blue^ or $07;
  end;
end;


function TrueColorTo16bitColor(ATrueColor: TColor): Word;
var
  R, G, B: Byte;
begin
  R := ATrueColor and $FF;
  G := (ATrueColor shr 8) and $FF;
  B := (ATrueColor shr 16) and $FF;
  Result := TFT_RGBToColor16bit(R, G, B);
end;


function RGB(R, G, B: Byte): Integer;  //define a function for RGB, to avoid using compiler directives 
begin
  Result := DWord(B) shl 16 + DWord(G) shl 8 + R;
end;


procedure TrueColorToRGB(AColor: TColor; var R, G, B: Byte);
begin
  R := AColor and $FF;
  AColor := AColor shr 8;

  G := AColor and $FF;
  AColor := AColor shr 8;

  B := AColor and $FF;
end;


function U16bitColorToTrueColor(A16bitColor: Word; IncreasedBrightness: Boolean = False): TColor;
var
  R, G, B: Byte;
begin
  TFT_Color16bitToRGB(A16bitColor, @R, @G, @B, IncreasedBrightness);
  Result := RGB(R, G, B);
end;


procedure TFT_Set_Pen(pen_color: TColor; pen_width: Byte);
begin
  if not UseTFTTrueColor then
    GCanvas.Pen.Color := U16bitColorToTrueColor(pen_color, True)
  else
    GCanvas.Pen.Color := pen_color;

  FCurrentPenColor := pen_color;

  GCanvas.Pen.Width := pen_width;
end;


function AvgTwo16bitColors(Color1, Color2: Word): Word;
var
  R1, G1, B1: Word;
  R2, G2, B2: Word;
  R, G, B: Byte;
begin
  TFT_Color16bitToRGB(Color1, @R1, @G1, @B1, False);
  TFT_Color16bitToRGB(Color2, @R2, @G2, @B2, False);

  R := Word(R1 + R2) shr 1;
  G := Word(G1 + G2) shr 1;
  B := Word(B1 + B2) shr 1;

  Result := R shl 11 + G shl 5 + B;
end;


function AvgTwoTrueColors(Color1, Color2: TColor): TColor;
var
  R1, G1, B1: Word;
  R2, G2, B2: Word;
  R, G, B: Byte;
begin
  R1 := Color1 and $FF;
  R2 := Color2 and $FF;

  G1 := (Color1 shr 8) and $FF;
  G2 := (Color2 shr 8) and $FF;

  B1 := (Color1 shr 16) and $FF;
  B2 := (Color2 shr 16) and $FF;

  R := Word(R1 + R2) shr 1;
  G := Word(G1 + G2) shr 1;
  B := Word(B1 + B2) shr 1;

  Result := B shl 16 + G shl 8 + R;
end;


procedure TFT_Set_Brush(brush_enabled: Byte; brush_color: TColor; gradient_enabled, gradient_orientation: Byte; gradient_color_from, gradient_color_to: TColor);
begin
  //GCanvas.GradientFill();
  if not UseTFTTrueColor then
  begin
    if gradient_enabled = 1 then
      brush_color := AvgTwo16bitColors(gradient_color_from, gradient_color_to);

    GCanvas.Brush.Color := U16bitColorToTrueColor(brush_color, True);
  end
  else
  begin
    if gradient_enabled = 1 then
      brush_color := AvgTwoTrueColors(gradient_color_from, gradient_color_to);

    GCanvas.Brush.Color := brush_color;
  end;

  FGradientEnabled := gradient_enabled;
  FGradientOrientation := gradient_orientation;
  FGradientColorFrom := gradient_color_from;
  FGradientColorTo := gradient_color_to;

  if brush_enabled = 0 then
    GCanvas.Brush.Style := bsClear
  else
    GCanvas.Brush.Style := bsSolid;
    
  //MessageBox(0, PChar('brush_color = ' + IntToStr(brush_color) + #13#10 + 'GCanvas.Brush.Color = ' + IntToStr(GCanvas.Brush.Color)), PChar(ApplicationName), MB_ICONINFORMATION);
end;


procedure TFT_Set_Font(activeFont: PByte; font_color: TColor; font_orientation: Word);
var
  AFontSetting: PDynTFTFontSettings;
begin
  if activeFont = nil then
    raise Exception.Create('Please call TFT_Set_Font with @TFT_defaultFont or assign a valid font to component.');

  AFontSetting := PDynTFTFontSettings(activeFont);
  GCanvas.Font.Name := AFontSetting^.FontName;
  GCanvas.Font.Size := AFontSetting^.FontSize;

  GCanvas.Font.Style := [];
  if AFontSetting^.Bold then
    GCanvas.Font.Style := GCanvas.Font.Style + [fsBold];

  if AFontSetting^.Italic then
    GCanvas.Font.Style := GCanvas.Font.Style + [fsItalic];

  if AFontSetting^.Underline then
    GCanvas.Font.Style := GCanvas.Font.Style + [fsUnderline];

  if AFontSetting^.StrikeOut then
    GCanvas.Font.Style := GCanvas.Font.Style + [fsStrikeOut];

  GCanvas.Font.Charset := AFontSetting^.Charset;
  GCanvas.Font.Pitch := AFontSetting^.Pitch;

  if not UseTFTTrueColor then
    GCanvas.Font.Color := U16bitColorToTrueColor(font_color, True)
  else
    GCanvas.Font.Color := font_color;
end;


procedure TFT_Set_Ext_Font(activeFont: {$IFDEF CPU64} QWord; {$ELSE} DWord; {$ENDIF} font_color: TColor; font_orientation: Word);
begin
  TFT_Set_Font(PByte(activeFont), font_color, font_orientation); // use the same function on desktop
end;


procedure TFT_Write_Text(AText: string; x, y: Word);
var
  StyleBkp: TBrushStyle;
begin
  StyleBkp := GCanvas.Brush.Style;
  GCanvas.Brush.Style := bsClear;
  GCanvas.TextOut(x, y, AText);
  GCanvas.Brush.Style := StyleBkp;
end;


procedure TFT_Line(x1, y1, x2, y2: Integer);
begin
  //FreePascal has a GCanvas.Line method, but it does not exist in Delphi, so use MoveTo and LineTo.
  GCanvas.MoveTo(x1, y1);
  GCanvas.LineTo(x2, y2);
  GCanvas.Pixels[x2, y2] := GCanvas.Pen.Color;  //missing pixel
end;


procedure TFT_H_Line(x_start, x_end, y_pos: Integer);
begin
  TFT_Line(x_start, y_pos, x_end, y_pos); //call TFT_Line to get the missing pixel
end;


procedure TFT_V_Line(y_start, y_end, x_pos: Integer);
begin
  TFT_Line(x_pos, y_start, x_pos, y_end); //call TFT_Line to get the missing pixel
end;


procedure TFT_Dot(x, y: Integer; Color: TColor);
begin
  GCanvas.Pixels[x, y] := Color;
end;



procedure TFT_Fill_Screen(color: TColor);
begin
  if not UseTFTTrueColor then
    GCanvas.Pen.Color := U16bitColorToTrueColor(color, True)
  else
    GCanvas.Pen.Color := color;

  GCanvas.Brush.Color := GCanvas.Pen.Color;
  GCanvas.Rectangle(0, 0, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);
end;


procedure TFT_Rectangle(x_upper_left, y_upper_left, x_bottom_right, y_bottom_right: Integer);
var
  i: Integer;
  R1, R2, G1, G2, B1, B2: Byte;
  RDiff, GDiff, BDiff: Integer;
  RColorScale, GColorScale, BColorScale: Double;
  CurrentColor, RCurrentColor, GCurrentColor, BCurrentColor: TColor;
  Distance: Integer;
begin
  //if GCanvas.Brush.Style = bsSolid then
  begin
    if FGradientEnabled = 0 then
      GCanvas.Rectangle(x_upper_left, y_upper_left, x_bottom_right + 1, y_bottom_right + 1)
    else
    begin
      try
        TrueColorToRGB(FGradientColorFrom, R1, G1, B1);
        TrueColorToRGB(FGradientColorTo, R2, G2, B2);
        RDiff := R2 - R1;
        GDiff := G2 - G1;
        BDiff := B2 - B1;

        if FGradientOrientation = TOP_TO_BOTTOM then
        begin
          Distance := y_bottom_right - y_upper_left;
          if Distance = 0 then
            Distance := 1;

          RColorScale := RDiff / Distance;
          GColorScale := GDiff / Distance;
          BColorScale := BDiff / Distance;

          for i := y_upper_left to y_bottom_right do
          begin
            RCurrentColor := Round(R1 + (i - y_upper_left) * RColorScale);
            GCurrentColor := Round(G1 + (i - y_upper_left) * GColorScale);
            BCurrentColor := Round(B1 + (i - y_upper_left) * BColorScale);
            CurrentColor := RGB(RCurrentColor, GCurrentColor, BCurrentColor);
            TFT_Set_Pen(CurrentColor, 1);
            TFT_H_Line(x_upper_left, x_bottom_right, i);
          end;
        end
        else
          if FGradientOrientation = LEFT_TO_RIGHT then
          begin
            Distance := x_bottom_right - x_upper_left;
            if Distance = 0 then
              Distance := 1;

            RColorScale := RDiff / Distance;
            GColorScale := GDiff / Distance;
            BColorScale := BDiff / Distance;

            for i := x_upper_left to x_bottom_right do
            begin
              RCurrentColor := Round(R1 + (i - x_upper_left) * RColorScale);
              GCurrentColor := Round(G1 + (i - x_upper_left) * GColorScale);
              BCurrentColor := Round(B1 + (i - x_upper_left) * BColorScale);
              CurrentColor := RGB(RCurrentColor, GCurrentColor, BCurrentColor);
              TFT_Set_Pen(CurrentColor, 1);
              TFT_V_Line(y_upper_left, y_bottom_right, i);
            end;
          end;
      finally
        TFT_Set_Pen(FCurrentPenColor, 1);
      end;
    end;
  end;
  {else
  begin
    TFT_Line(x_upper_left, y_upper_left, x_bottom_right, y_upper_left);
    TFT_Line(x_upper_left, y_bottom_right, x_bottom_right, y_bottom_right);

    TFT_Line(x_upper_left, y_upper_left, x_upper_left, y_bottom_right);
    TFT_Line(x_bottom_right, y_upper_left, x_bottom_right, y_bottom_right);
  end; }
end;


procedure TFT_Circle(x_center, y_center, radius: Integer);
var
  x_upper_left, y_upper_left, x_bottom_right, y_bottom_right: Integer;
begin
  x_upper_left := x_center - radius;
  y_upper_left := y_center - radius;
  x_bottom_right := x_center + radius;
  y_bottom_right := y_center + radius;

  GCanvas.Ellipse(x_upper_left, y_upper_left, x_bottom_right, y_bottom_right);
end;


procedure TFT_Write_Text_Return_Pos(AString: string; x, y: Word);
begin
  caption_length := GCanvas.TextWidth(AString);
  caption_height := GCanvas.TextHeight(AString);
end;


initialization
  UseTFTTrueColor := False;
  FGradientEnabled := 0;
  FCurrentPenColor := clRed;
  
end.

