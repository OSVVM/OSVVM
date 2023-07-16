package body CommonLogPkg is
  constant IsOriginalPkg : boolean := true;

  procedure WriteToLog(
    file LogDestination : text;
    LogDestinationPath : string := NoString;
    Msg : string := NoString;
    LogTime : time := NoTime;
    LogLevel : string := NoString;
    LogSourceName : string := NoString;

    Str1, Str2, Str3, Str4, Str5, Str6, Str7, Str8, Str9, Str10 : string := "";
    Int1, Int2, Int3, Int4, Int5, Int6, Int7, Int8, Int9, Int10 : integer := 0;
    Bool1, Bool2, Bool3, Bool4, Bool5, Bool6, Bool7, Bool8, Bool9, Bool10 : boolean := false
  ) is
  begin
  end;

end package body;
