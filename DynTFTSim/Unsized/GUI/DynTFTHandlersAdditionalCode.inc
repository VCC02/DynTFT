
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
    15: ItemText := '15 fifteen - fpWgJj'
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
