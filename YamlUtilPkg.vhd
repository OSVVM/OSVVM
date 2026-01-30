--
--  File Name:         YamlUtilPkg.vhd
--  Design Unit Name:  YamlUtilPkg
--
--  Description:
--    YAML formatting/writing utilities used by OSVVM reporting.
--

use std.textio.all ;

package YamlUtilPkg is

  -- Write a YAML key/value pair as a double-quoted scalar.
  procedure WriteYamlDoubleQuotedScalar(
    file TestFile : text ;
    Prefix        : string ;
    KeyName       : string ;
    YamlText      : string
  ) ;

  -- Write a YAML key/value pair as a literal block scalar (|).
  procedure WriteYamlLiteralBlockScalar(
    file TestFile : text ;
    Prefix        : string ;
    KeyName       : string ;
    YamlText      : string
  ) ;

  -- Write a YAML value as a double-quoted string to an existing line buffer.
  procedure WriteYamlDoubleQuotedValue(
    Buf      : inout line ;
    YamlText : string
  ) ;

  -- Write a YAML inline tag record (used by test description/tag reporting).
  -- Output format:
  --   "<TagName>": {Value: <Value>, Type: "<TypeText>", Visibility: {Summary: true|false}}
  procedure WriteYamlInlineTagRecord(
    file TestFile      : text ;
    Prefix             : string ;
    TagName            : string ;
    ValueText          : string ;
    ValueIsDoubleQuoted: boolean ;
    ValueIsYamlNull    : boolean ;
    TypeText           : string ;
    ShowInSummary      : boolean
  ) ;

end package YamlUtilPkg ;

package body YamlUtilPkg is

  constant DEL : character := character'val(127) ;

  ------------------------------------------------------------
  -- YAML helper
  procedure WriteYamlDoubleQuotedScalar(
  ------------------------------------------------------------
    file TestFile : text ;
    Prefix        : string ;
    KeyName       : string ;
    YamlText      : string
  ) is
    variable localBuf : line ;
  begin
    write(localBuf, Prefix & KeyName & ": """) ;
    for i in YamlText'range loop
      case YamlText(i) is
        when '"' =>
          swrite(localBuf, "\""") ;
        when '\' =>
          swrite(localBuf, "\\") ;
        when LF =>
          swrite(localBuf, "\n") ; 
        when CR =>
          swrite(localBuf, "\r") ; 
        when HT =>
          swrite(localBuf, "\t") ; 
        when others =>
          -- Remove other control chars that can break YAML/HTML tooling
          if (character'pos(YamlText(i)) < 32) or (YamlText(i) = DEL) then
            write(localBuf, ' ') ;
          else
            write(localBuf, YamlText(i)) ;
          end if ;
      end case ;
    end loop ;
    write(localBuf, '"') ;
    writeline(TestFile, localBuf) ;
  end procedure WriteYamlDoubleQuotedScalar ;

  ------------------------------------------------------------
  -- YAML helper
  procedure WriteYamlLiteralBlockScalar_WriteOneLine(
  ------------------------------------------------------------
    file TestFile : text ;
    Prefix        : string ;
    YamlText      : string ;
    StartIndex    : integer ;
    EndIndex      : integer
  ) is
    variable lineBuf : line ;
    variable FirstNonSpace : integer ;
    constant BACKSLASH : character := character'val(92) ;
  begin
    write(lineBuf, Prefix & "  ") ;

    -- Some Tcl YAML parsers strip comment lines that start with '#'
    -- even inside literal block scalars.  To keep markdown headings
    -- (##, ###, etc.) lossless, prefix a single backslash before a leading '#'.
    FirstNonSpace := StartIndex ;
    if StartIndex <= EndIndex then
      while FirstNonSpace <= EndIndex loop
        exit when (YamlText(FirstNonSpace) /= ' ') and (YamlText(FirstNonSpace) /= HT) ;
        FirstNonSpace := FirstNonSpace + 1 ;
      end loop ;
    end if ;

    if StartIndex <= EndIndex then
      for j in StartIndex to EndIndex loop
        -- For block scalars, no escaping needed.  Replace control chars.
        if (j = FirstNonSpace) and (YamlText(j) = '#') then
          write(lineBuf, BACKSLASH) ;
          write(lineBuf, '#') ;
        elsif (YamlText(j) = HT) then
          write(lineBuf, ' ') ;
        elsif (character'pos(YamlText(j)) < 32) or (YamlText(j) = DEL) then
          write(lineBuf, ' ') ;
        else
          write(lineBuf, YamlText(j)) ;
        end if ;
      end loop ;
    end if ;
    writeline(TestFile, lineBuf) ;
  end procedure WriteYamlLiteralBlockScalar_WriteOneLine ;

  ------------------------------------------------------------
  -- YAML helper
  procedure WriteYamlLiteralBlockScalar(
  ------------------------------------------------------------
    file TestFile : text ;
    Prefix        : string ;
    KeyName       : string ;
    YamlText      : string
  ) is
    variable localBuf  : line ;
    variable LineStart : integer ;
    variable LineEnd   : integer ;
    variable Index     : integer ;
  begin
    -- YAML literal block scalar (|) keeps newlines and is readable in YAML.
    write(localBuf, Prefix & KeyName & ": |") ;
    writeline(TestFile, localBuf) ;

    LineStart := YamlText'low ;
    Index := YamlText'low ;
    while Index <= YamlText'high loop
      if (YamlText(Index) = LF) or (YamlText(Index) = CR) then
        LineEnd := Index - 1 ;
        WriteYamlLiteralBlockScalar_WriteOneLine(TestFile, Prefix, YamlText, LineStart, LineEnd) ;
        -- Handle CRLF as a single newline
        if (YamlText(Index) = CR) and (Index < YamlText'high) and (YamlText(Index+1) = LF) then
          Index := Index + 1 ;
        end if ;
        LineStart := Index + 1 ;
      end if ;
      Index := Index + 1 ;
    end loop ;
    if LineStart <= YamlText'high then
      WriteYamlLiteralBlockScalar_WriteOneLine(TestFile, Prefix, YamlText, LineStart, YamlText'high) ;
    elsif (YamlText'length > 0) and ((YamlText(YamlText'high) = LF) or (YamlText(YamlText'high) = CR)) then
      -- Value ended with newline: preserve trailing blank line in the block
      WriteYamlLiteralBlockScalar_WriteOneLine(TestFile, Prefix, YamlText, 1, 0) ;
    end if ;
  end procedure WriteYamlLiteralBlockScalar ;

  ------------------------------------------------------------
  -- YAML helper
  procedure WriteYamlDoubleQuotedValue(
  ------------------------------------------------------------
    Buf      : inout line ;
    YamlText : string
  ) is
  begin
    write(Buf, '"') ;
    for i in YamlText'range loop
      case YamlText(i) is
        when '"' =>
          swrite(Buf, "\""") ;
        when '\' =>
          swrite(Buf, "\\") ;
        when LF =>
          swrite(Buf, "\n") ; 
        when CR =>
          swrite(Buf, "\r") ; 
        when HT =>
          swrite(Buf, "\t") ; 
        when others =>
          if (character'pos(YamlText(i)) < 32) or (YamlText(i) = DEL) then
            write(Buf, ' ') ;
          else
            write(Buf, YamlText(i)) ;
          end if ;
      end case ;
    end loop ;
    write(Buf, '"') ;
  end procedure WriteYamlDoubleQuotedValue ;

  ------------------------------------------------------------
  -- YAML helper
  procedure WriteYamlInlineTagRecord(
  ------------------------------------------------------------
    file TestFile       : text ;
    Prefix              : string ;
    TagName             : string ;
    ValueText           : string ;
    ValueIsDoubleQuoted : boolean ;
    ValueIsYamlNull     : boolean ;
    TypeText            : string ;
    ShowInSummary       : boolean
  ) is
    variable localBuf : line ;
  begin
    -- Always quote the key to support spaces/special chars.
    write(localBuf, Prefix & "  ") ;
    WriteYamlDoubleQuotedValue(localBuf, TagName) ;

    swrite(localBuf, ": {Value: ") ;
    if ValueIsYamlNull then
      write(localBuf, string'("null")) ;
    elsif ValueIsDoubleQuoted then
      WriteYamlDoubleQuotedValue(localBuf, ValueText) ;
    else
      -- For YAML booleans/numbers we want unquoted output.
      write(localBuf, ValueText) ;
    end if ;

    write(localBuf, string'(", Type: ")) ;
    WriteYamlDoubleQuotedValue(localBuf, TypeText) ;

    write(localBuf, string'(", Visibility: {Summary: ")) ;
    if ShowInSummary then
      write(localBuf, string'("true")) ;
    else
      write(localBuf, string'("false")) ;
    end if ;
    write(localBuf, string'("}}")) ;

    writeline(TestFile, localBuf) ;
  end procedure WriteYamlInlineTagRecord ;

end package body YamlUtilPkg ;
