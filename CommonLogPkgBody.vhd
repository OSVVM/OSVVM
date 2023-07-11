use work.OsvvmGlobalPkg.all;
use work.TextUtilPkg.all;
use work.TranscriptPkg.all;

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
      alias WritePrefix is Str1;
      alias WriteErrorCount is Str2;
      alias LogOrAlert is Str3;
      alias Prefix is Str4;
      alias Suffix is Str5;

      alias AlertLogJustifyAmount is Int1;
      alias TimeJustifyAmount is Int2;

      alias WriteLevel is Bool1;
      alias WriteTimeFirst is Bool2;
      alias WriteTimeLast is Bool3;

      variable buf : line ;
      ------------------------------------------------------------
      -- Package Local
      function LeftJustify(A : String;  Amount : integer) return string is
      ------------------------------------------------------------
        constant Spaces : string(1 to  maximum(1, Amount)) := (others => ' ') ;
      begin
        if A'length >= Amount then
          return A ;
        else
          return A & Spaces(1 to Amount - A'length) ;
        end if ;
      end function LeftJustify ;
  begin
      write(buf, WritePrefix) ; -- Print
      -- Debug Mode
      write(buf, WriteErrorCount) ;
      -- Write Time
      if WriteTimeFirst then
        write(buf, justify(to_string(LogTime, GetOsvvmDefaultTimeUnits), TimeJustifyAmount, RIGHT) & "    ") ;
      end if ;
      -- Alert or Log
      write(buf, LogOrAlert) ;
      -- Level Name, when enabled (default)
      if WriteLevel then
        write(buf, "  " & LogLevel) ;
      end if ;
      -- AlertLog Name
      if LogSourceName /= NoString then
        write(buf, "   in " & LeftJustify(LogSourceName & ',', AlertLogJustifyAmount) ) ;
      end if ;
      -- Spacing before message
      swrite(buf, "  ") ;
      -- Prefix
      if Prefix /= "" then
        write(buf, ' ' & Prefix) ;
      end if ;
      -- Message
      write(buf, " " & Msg) ;
      -- Suffix
      if Suffix /= "" then
        write(buf, ' ' & Suffix) ;
      end if ;
      -- Time Last
      if WriteTimeLast then
        write(buf, " at " & to_string(LogTime, GetOsvvmDefaultTimeUnits)) ;
      end if ;
      WriteLine(buf) ;
  end;

end package body;
