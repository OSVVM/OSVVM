package body CommonLogPkg is
  constant IsOriginalPkg : boolean := true;

  procedure WriteToLog(
    file LogDestination : text;
    LogDestinationPath : string := NoString;
    Msg : string := NoString;
    LogTime : time := NoTime;
    LogLevel : string := NoString;
    LogSourceName : string := NoString
  ) is
  begin
  end;

end package body;
