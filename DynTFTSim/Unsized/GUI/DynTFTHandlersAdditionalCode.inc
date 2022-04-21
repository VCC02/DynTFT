var
  OldListOfFilesItemIndexStack: array of LongInt;

function ListBoxItemIsVisible({$IFDEF IsMCU}var{$ENDIF} ItemText, SearchText: string): Boolean;
begin
  Result := (SearchText = '') or (Pos(UpperCase(SearchText), UpperCase(ItemText)) > 0);
end;


procedure GetSearchedListBoxItemByIndex(var ItemText: string; Index: LongInt);
begin
  {$IFDEF IsDesktop}
    if Index < 0 then
      raise Exception.Create('ListBox index is negative.');
  {$ENDIF}

  case Index of
    0: ItemText := '0   zero';
    1: ItemText := '1   one';
    2: ItemText := '2   two';
    3: ItemText := '3   three';
    4: ItemText := '4   four';
    5: ItemText := '5   five';
    6: ItemText := '6   six';
    7: ItemText := '7   seven';
    8: ItemText := '8   eight';
    9: ItemText := '9   nine';
    10: ItemText := '10 ten';
    11: ItemText := '11 eleven';
    12: ItemText := '12 twelve';
    13: ItemText := '13 thirteen';
    14: ItemText := '14 fourteen';
    15: ItemText := '15 fifteen - fpWgJj';

    16: ItemText := '----';
    17: ItemText := 'abcdefghijklmnopqrstuvwxyz';
    18: ItemText := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ'
  else
    ItemText := 'Unknown index ' + IntToStr(Index);
  end;
end;


procedure TriggerListBoxItemSearch(AListBox: PDynTFTListBox);
begin
  {$IFDEF ItemsVisibility}
    AListBox^.Items^.FirstDisplayablePosition := 0;
    AListBox^.VertScrollBar^.Position := -1; // this will cause a repaint later in SetScrollBarMaxBasedOnVisibility, because the position is out of bounds
    DynTFTDrawItems(AListBox^.Items, True);
    SetScrollBarMaxBasedOnVisibility(AListBox);
  {$ENDIF}
end;  


procedure DisplayItemIndexForListBox(AListBox: PDynTFTListBox; ALabel: PDynTFTLabel);
begin
  ALabel^.Caption := 'ItemIndex: ' + IntToStr(AListBox^.Items^.ItemIndex);
  DynTFTDrawLabel(ALabel, True);
end;


procedure RepaintListOfFiles(DispPos: LongInt);
begin
  lstFileExplorer^.Items^.Count := Length(ListOfFiles);

  lstFileExplorer^.VertScrollBar^.Position := DispPos;
  if lstFileExplorer^.VertScrollBar^.Position > lstFileExplorer^.VertScrollBar^.Max then
    lstFileExplorer^.VertScrollBar^.Position := lstFileExplorer^.VertScrollBar^.Max;

  lstFileExplorer^.Items^.FirstDisplayablePosition := lstFileExplorer^.VertScrollBar^.Position;

  DynTFTDrawListBox(lstFileExplorer, True);
  DynTFTDrawItems(lstFileExplorer^.Items, True);
end;


procedure ScanDir;
var
  Res: Integer;
  SearchRec: TSearchRec;
begin
  SetLength(ListOfFiles, 0);
  Res := FindFirst(CurrentDir + '\*', faAnyFile, SearchRec);
  try
    while Res = 0 do
    begin
      if SearchRec.Name <> '.' then   // '..' should be in the list
      begin
        SetLength(ListOfFiles, Length(ListOfFiles) + 1);
        if SearchRec.Attr and faDirectory = faDirectory then
          ListOfFiles[Length(ListOfFiles) - 1].FileType := ftDir
        else
          ListOfFiles[Length(ListOfFiles) - 1].FileType := ftFile;

        ListOfFiles[Length(ListOfFiles) - 1].Name := SearchRec.Name;
      end;

      Res := FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;
end;


procedure PushItemIndexToStack(AItemIndex: Integer);
begin
  SetLength(OldListOfFilesItemIndexStack, Length(OldListOfFilesItemIndexStack) + 1);
  OldListOfFilesItemIndexStack[Length(OldListOfFilesItemIndexStack) - 1] := AItemIndex;
end;


function PopItemIndexFromStack: Integer;
begin
  Result := OldListOfFilesItemIndexStack[Length(OldListOfFilesItemIndexStack) - 1];
  SetLength(OldListOfFilesItemIndexStack, Length(OldListOfFilesItemIndexStack) - 1);
end;


procedure ClearItemIndexStack;
begin
  SetLength(OldListOfFilesItemIndexStack, 0);
end;


procedure GetDrives;
begin
  cmbFileExplorerDrives^.ListBox^.Items^.Count := 26;
end;


procedure DrawFileIcon(Fn: string; DestCanvas: TCanvas; X, Y: Integer; IconWidth: Integer = 32; IconHeight: Integer = 32);
var
  IconIndex: Word;
  Buffer: array[0..131072] of Char;
  IconHandle: LongWord; //HIcon;
  AnIcon: TIcon;
  Cnv_FontSize: Integer;
  Cnv_FontColor: TColor;
  Cnv_PenColor: TColor;
  Cnv_BrushColor: TColor;
  DestRect, TempRect: TRect;
  TempBmp: TBitmap;
begin
  StrPCopy(@Buffer, Fn);
  IconIndex := 0;
  {$IFDEF FPC}
    IconHandle := ExtractAssociatedIcon(HInstance, Buffer, @IconIndex);
  {$ELSE}
    IconHandle := ExtractAssociatedIcon(HInstance, Buffer, IconIndex);
  {$ENDIF}

  AnIcon := TIcon.Create;
  try
    if IconHandle > 0 then
    begin
      AnIcon.Width := IconWidth;
      AnIcon.Height := IconHeight;
      AnIcon.Handle := IconHandle;

      DestRect.Left := X;
      DestRect.Top := Y;
      DestRect.Right := X + IconWidth;
      DestRect.Bottom := Y + IconHeight;

      TempBmp := TBitmap.Create;
      try
        TempBmp.Width := AnIcon.Width;
        TempBmp.Height := AnIcon.Height;
        TempRect.Left := 0;
        TempRect.Top := 0;
        TempRect.Right := TempBmp.Width - 1;
        TempRect.Bottom := TempBmp.Height - 1;
        TempBmp.PixelFormat := pf24bit;

        TempBmp.Canvas.StretchDraw(TempRect, AnIcon);
        DestCanvas.StretchDraw(DestRect, TempBmp);
      finally
        TempBmp.Free;
      end;
    end
    else
    begin
      Cnv_FontSize := DestCanvas.Font.Size;
      Cnv_FontColor := DestCanvas.Font.Color;
      Cnv_PenColor := DestCanvas.Pen.Color;
      Cnv_BrushColor := DestCanvas.Brush.Color;

      DestCanvas.Font.Size := Round((IconWidth - 2) / 1.625) - 2;
      DestCanvas.Font.Color := clYellow;
      DestCanvas.Pen.Color := $00F47A5B;
      DestCanvas.Brush.Color := clBlack;

      DestCanvas.Rectangle(X, Y, X + IconWidth - 1, Y + IconHeight - 1);
      DestCanvas.TextOut(X + 3, Y + 2, '?');

      DestCanvas.Font.Size := Cnv_FontSize;
      DestCanvas.Font.Color := Cnv_FontColor;
      DestCanvas.Pen.Color := Cnv_PenColor;
      DestCanvas.Brush.Color := Cnv_BrushColor;
    end;
  finally
    AnIcon.Free;
  end;
end;
