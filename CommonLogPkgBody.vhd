use work.OsvvmGlobalPkg.all;
use work.TextUtilPkg.all;
use work.TranscriptPkg.all;

package body CommonLogPkg is
  constant IsOriginalPkg : boolean := true;

  procedure WriteToLog(
    file LogDestination : text;
    Msg : string := "";
    LogTime : time := NoTime;
    LogLevel : string := "";
    LogSourceName : string := "";
    Str1, Str2, Str3, Str4, Str5, Str6, Str7, Str8, Str9, Str10 : string := "";
    Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9, Val10 : integer := NoVal) is
      alias WritePrefix is Str1;
      alias WriteErrorCount is Str2;
      alias LogOrAlert is Str3;
      alias Prefix is Str4;
      alias Suffix is Str5;

      alias AlertLogJustifyAmount is Val1;
      constant WriteLevel : boolean := Val2 = 1;
      constant WriteTimeFirst : boolean := Val3 = 1;
      constant WriteTimeLast : boolean := Val4 = 1;
      alias TimeJustifyAmount is Val5;

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
      if LogSourceName /= "" then
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
