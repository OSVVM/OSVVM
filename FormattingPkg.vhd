library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.TextUtilPkg.all;
  use std.textio.all;

package FormattingPkg is

  constant LINE_PREFIX: string := "%%";
  constant COLUMN_COUNT: integer := 6;
  constant INVISIBLE: integer := 0;
  constant DONT_CARE: integer := 0;

  type ColumnTypeT is (LogTime, LogErrorCnt, LogKind, LogLevel, LogIdName, LogMessage);
  type ColumnVisibilityT is (Enabled, Disabled, WhitespaceOnly);

  type ColumnEnabledT is array(columnTypeT) of ColumnVisibilityT;
  
  type ColumnRecT is record
    columnType: ColumnTypeT;
    prefix: string;
    postfix: string;
    index: integer;
    minWidth, maxWidth: integer;
    alignment: AlignType;
  end record;

  type ColumnRecPtrT is access ColumnRecT;

  type ColumnsArrayT is array(1 to COLUMN_COUNT) of ColumnRecPtrT;

  shared variable Columns: ColumnsArrayT := (
    new ColumnRecT'(LogTime,     "",    " ",  1,        19,        19, RIGHT),
    new ColumnRecT'(LogErrorCnt, "",    " ",  2,         5,         5, RIGHT),
    new ColumnRecT'(LogKind,     "",    " ",  3,         6,         6, RIGHT),
    new ColumnRecT'(LogLevel,    "",    " ",  4,        10,        10, RIGHT),
    new ColumnRecT'(LogIdName,   "in ", ": ", 5,        25,        25, RIGHT),
    new ColumnRecT'(LogMessage,  "",    "",   6, DONT_CARE, DONT_CARE, LEFT)
  );

  function ToColumnVisibility(val: boolean; vis: ColumnVisibilityT := Enabled) return ColumnVisibilityT;
    
  procedure FormatOutput(
    buf: inout line; 
    prefix, logName, alertName, origin, message: string;
    msgPrefix, msgSuffix: inout line;
    errorCnt: integer;
    showColumn: ColumnEnabledT
  );

end package;

package body FormattingPkg is

  function ToColumnVisibility(val: boolean; vis: ColumnVisibilityT := Enabled) return ColumnVisibilityT is
  begin
    if val then
      if vis = Enabled then
        return Enabled;
      else
        return WhitespaceOnly;
      end if;
    end if;
    return Disabled;
  end function;

  function IsVisible(val: ColumnVisibilityT) return boolean is
  begin
    return val = Enabled or val = WhitespaceOnly;
  end function;

  function Trim(str: string) return string is
    variable min: integer := 0;
    variable max: integer := str'length + 1;
  begin
    for i in 1 to str'length loop
      min := i;
      if str(i) /= ' ' then
        exit;
      end  if;
    end loop;
    for i in str'length downto 1 loop
      max := i;
      if str(i) /= ' ' then
        exit;
      end if;
    end loop;
    if max > min and min > 0 and max <= str'length then
      return str(min to max);
    end if;
    return str;
  end function;

  function Fill(cnt: integer) return string is
    constant RET: string(1 to cnt) := (others => ' ');
  begin
    return RET;
  end function;

  procedure Justify(buf: inout line; msg: string; align: AlignType; minWidth, maxWidth: integer) is
    variable tmp1, tmp2, tmp3: line;
    variable min, max, fill, fillHalf: integer;
  begin
    min := 0 when minWidth < 0 else minWidth;
    max := integer'high when maxWidth <  0 else maxWidth;
    fill := min - msg'length;
    fillHalf := fill / 2;
    write(tmp1, string'(""));
    write(tmp2, string'(""));
    write(tmp3, string'(""));
    for i in 1 to fillHalf loop
      write(tmp1, string'(" "));
    end loop;
    for i in 1 to fill - fillHalf loop
      write(tmp2, string'(" "));
    end loop;
    if msg'length > max and max > 3 then
      write(tmp3, msg(1 to max - 3) & "...");
    else
      write(tmp3, msg);
    end if;
    case align is
      when RIGHT =>
        write(buf, tmp1.all);
        write(buf, tmp2.all);
        write(buf, tmp3.all);
      when LEFT =>
        write(buf, tmp3.all);
        write(buf, tmp1.all);
        write(buf, tmp2.all);
      when CENTER =>
        write(buf, tmp1.all);
        write(buf, tmp3.all);
        write(buf, tmp2.all);
    end case;
    deallocate(tmp1);
    deallocate(tmp2);
    deallocate(tmp3);
  end procedure;
  
  procedure FormatField(buf: inout line; visibility: ColumnVisibilityT; msg: string; info: ColumnRecT) is
  begin
    if visibility = WhitespaceOnly then
      write(buf, Fill(info.prefix'length));
      write(buf, Fill(info.minWidth));
      write(buf, Fill(info.postfix'length));
    else
      write(buf, info.prefix);
      Justify(buf, msg, info.alignment, info.minWidth, info.maxWidth);
      write(buf, info.postfix);
    end if;
  end procedure;

  pure function TimeToString(t: time) return string is
  begin
    return to_string(t, 1 ns);
  end function;

  procedure FormatOutput(
    buf: inout line; 
    prefix, logName, alertName, origin, message: string;
    msgPrefix, msgSuffix: inout line;
    errorCnt: integer;
    showColumn: ColumnEnabledT
  ) is
    variable column: ColumnRecPtrT := null;
    variable pre, suf: line;
  begin
    if msgPrefix /= null then
      write(pre, msgPrefix.all);
    else
      write(pre, string'(""));
    end if;
    if msgSuffix /= null then
      write(suf, msgSuffix.all);
    else
      write(suf, string'(""));
    end if;
    write(buf, prefix);
    for i in 1 to COLUMN_COUNT loop
      -- Find the column with the corresponding index
      for j in 1 to COLUMN_COUNT loop
        if Columns(j).index = i then
          column := Columns(j);
          exit;
        end if;
      end loop;
      if column /= null then
        case column.columnType is
          
          when LogTime =>
            if IsVisible(showColumn(LogTime)) then
              FormatField(buf, showColumn(LogTime), TimeToString(now), column.all);
            end if;
          when LogKind =>
            if IsVisible(showColumn(LogKind)) then
              FormatField(buf, showColumn(LogKind), Trim(logName), column.all);
            end if;
          when LogLevel =>
            if IsVisible(showColumn(LogLevel)) then
              FormatField(buf, showColumn(LogLevel), Trim(alertName), column.all);
            end if;
          when LogIdName =>
            if IsVisible(showColumn(LogIdName)) then
              FormatField(buf, showColumn(LogIdName), Trim(origin), column.all);
            end if;
          when LogMessage =>
            if IsVisible(showColumn(LogMessage)) then
              FormatField(buf, showColumn(LogMessage), pre.all & message & suf.all, column.all);
            end if;
          when LogErrorCnt =>
            if IsVisible(showColumn(LogErrorCnt)) then
              FormatField(buf, showColumn(LogErrorCnt), to_string(errorCnt), column.all);
            end if;
          when others =>
            null;
        end case;
      end if;
    end loop;
  end procedure;

end package body;