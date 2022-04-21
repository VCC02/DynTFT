type
  TFileType = (ftFile, ftDir);

  TLstFile = record
    FileType: TFileType;
    Name: string;
  end;

  TLstFileArr = array of TLstFile;

var
  ListOfFiles: TLstFileArr;
  CurrentDir: string;

procedure ScanDir;
procedure RepaintListOfFiles(DispPos: LongInt);
procedure GetDrives;
