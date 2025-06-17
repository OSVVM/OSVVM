--
--  File Name:         TextUtilPkg.vhd
--  Design Unit Name:  TextUtilPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Shared Utilities for handling text files
--
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    02/2025   2025.02    Fixed bug in RemoveCrLf when only Cr/LF in line and no other characters.
--    09/2024   2024.09    Added to_string_max, RemoveSpace, RemoveCrLf, GetLine
--    12/2023   2024.03    SkipWhiteSpace now treats LF and CR as blank space - if a tool leaves them
--                         ReadUntilDelimiterOrEOL now treats LF and CR as end of line indication
--                         These updates are only so OSVVM can work with non-compilant (1076) tools.
--                         IfElse function moved to IfElsePkg
--    08/2022   2022.08    Added IsHexOrStdLogic.  Updated ReadHexToken to support reading "UWLH-"
--    02/2022   2022.02    Updated to_hxstring to print U, X, Z, W, - when there are 4 in a row and ? for mixed meta
--                         Added Justify that aligns LEFT, RIGHT, and CENTER with parameters in a sensible order.
--    01/2022   2022.01    Added to_hxstring - based on hxwrite (in TbUtilPkg prior to release)
--    08/2020   2020.08    Added ReadUntilDelimiterOrEOL and FindDelimiter
--    01/2020   2020.01    Updated Licenses to Apache
--    11/2016   2016.11    Added IsUpper, IsLower, to_upper, to_lower
--    01/2016   2016.01    Update for L.all(L'left)
--    01/2015   2015.05    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2015 - 2024 by SynthWorks Design Inc.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

use std.textio.all ;
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

package TextUtilPkg is
  ------------------------------------------------------------
  -- Character tests
  function IsUpper  (constant Char : character ) return boolean ;
  function IsLower  (constant Char : character ) return boolean ;
  function IsWhiteSpace (constant Char : character ) return boolean ;
  function IsHex (constant Char : character ) return boolean ;
  function IsHexOrStdLogic (constant Char : character ) return boolean ;
  function IsNumber (constant Char : character ) return boolean ;
  function IsNumber (Name : string ) return boolean ;
  function isstd_logic (constant Char : character ) return boolean ;

  -- Conversions
  function to_lower (constant Char : character ) return character ;
  function to_lower (constant Str  : string ) return string ;
  function to_upper (constant Char : character ) return character ;
  function to_upper (constant Str  : string ) return string ;

  ------------------------------------------------------------
  procedure RemoveSpace (variable S : inout string ; variable Len : InOut integer) ;
  
  -- Only needed for non-compliant simulators -- X
  procedure RemoveCrLf (S : string ; variable Len : out integer) ;
  function  RemoveCrLf( S : string ) return string ;
  alias StripCrLf is RemoveCrLf[ string return string ] ;

  ------------------------------------------------------------
  -- to_hxstring
  --   print in hex.  If string contains X, then also print in binary
  ------------------------------------------------------------
  function to_hxstring ( A : std_ulogic_vector) return string ;
  function to_hxstring ( A : unsigned) return string ;
  function to_hxstring ( A : signed) return string ;

  ------------------------------------------------------------
  -- to_string_max
  --   If value is integer'high or integer'low, return that instead of the string
  ------------------------------------------------------------
  function to_string_max ( I : integer) return string ;

  ------------------------------------------------------------
  -- Justify
  --   w/ Fill Character
  --   w/o Fill character, Parameter order & names sensible
  ------------------------------------------------------------
  type AlignType is (RIGHT, LEFT, CENTER) ;

  function Justify (
    S       : string ;
    Amount  : natural ;
    Align   : AlignType := LEFT
  ) return string ;

  function Justify (
    S       : string ;
    Fill    : character ;
    Amount  : natural ;
    Align   : AlignType := LEFT
  ) return string ;

  ------------------------------------------------------------
  procedure GetLine(
  ------------------------------------------------------------
    File     FileId           :       text ;
    variable Buf              : inout line ;
    variable LineCount        : inout integer ;
    variable EndOfFile        : out   boolean ;
    constant IgnoreEmptyLines : in    boolean
  ) ;

  ------------------------------------------------------------
  procedure SkipWhiteSpace (
  ------------------------------------------------------------
    variable L     : InOut line ;
    variable Empty : out   boolean
  ) ;
  procedure SkipWhiteSpace (variable L : InOut line) ;

  ------------------------------------------------------------
  procedure IsWhiteSpaceOrEmpty (
  ------------------------------------------------------------
    variable L                : InOut  line ;
    variable Empty            : Out    boolean
  ) ;

  ------------------------------------------------------------
  procedure EmptyOrCommentLine (
  ------------------------------------------------------------
    variable L                : InOut  line ;
    variable Empty            : InOut  boolean ;
    variable MultiLineComment : inout  boolean
  ) ;

  ------------------------------------------------------------
  procedure FindDelimiter(
  ------------------------------------------------------------
    variable L                : InOut line ;
    constant Delimiter        : In    character ;
    variable Found            : Out   boolean
  ) ;

  ------------------------------------------------------------
  procedure ReadUntilDelimiterOrEOL(
  ------------------------------------------------------------
    variable L         : InOut line ;
    variable Name      : InOut line ;
    constant Delimiter : In    character ;
    variable ReadValid : Out   boolean
  ) ;

  ------------------------------------------------------------
  procedure ReadHexToken (
  -- Reads Upto Result'length values, less is ok.
  -- Does not skip white space
  ------------------------------------------------------------
    variable L      : InOut line ;
    variable Result : Out   std_logic_vector ;
    variable StrLen : Out   integer
  ) ;

  ------------------------------------------------------------
  procedure ReadBinaryToken (
  -- Reads Upto Result'length values, less is ok.
  -- Does not skip white space
  ------------------------------------------------------------
    variable L      : InOut line ;
    variable Result : Out   std_logic_vector ;
    variable StrLen : Out   integer
  ) ;

  ------------------------------------------------------------
  procedure sread_c (
  -- sread for Xilinx tools
  ------------------------------------------------------------
    variable L          : InOut line ;
    variable Name       : Out   string ;
    variable NameLength : Out   integer
  ) ;

end TextUtilPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body TextUtilPkg is
  type stdulogic_indexby_stdulogic is array (std_ulogic) of std_ulogic;

  constant LOWER_TO_UPPER_OFFSET : integer := character'POS('a') - character'POS('A') ;

  ------------------------------------------------------------
  function "-" (R : character ; L : integer ) return character is
  ------------------------------------------------------------
  begin
    return character'VAL(character'pos(R) - L) ;
  end function "-" ;

  ------------------------------------------------------------
  function "+" (R : character ; L : integer ) return character is
  ------------------------------------------------------------
  begin
    return character'VAL(character'pos(R) + L) ;
  end function "+" ;

  ------------------------------------------------------------
  function IsUpper (constant Char : character ) return boolean is
  ------------------------------------------------------------
  begin
    if Char >= 'A' and Char <= 'Z' then
      return TRUE ;
    else
      return FALSE ;
    end if ;
  end function IsUpper ;

  ------------------------------------------------------------
  function IsLower (constant Char : character ) return boolean is
  ------------------------------------------------------------
  begin
    if Char >= 'a' and Char <= 'z' then
      return TRUE ;
    else
      return FALSE ;
    end if ;
  end function IsLower ;

  ------------------------------------------------------------
  function to_lower (constant Char : character ) return character is
  ------------------------------------------------------------
  begin
    if IsUpper(Char) then
      return Char + LOWER_TO_UPPER_OFFSET ;
    else
      return Char ;
    end if ;
  end function to_lower ;

  ------------------------------------------------------------
  function to_lower (constant Str : string ) return string is
  ------------------------------------------------------------
    variable result : string(Str'range) ;
  begin
    for i in Str'range loop
      result(i) := to_lower(Str(i)) ;
    end loop ;
    return result ;
  end function to_lower ;

  ------------------------------------------------------------
  function to_upper (constant Char : character ) return character is
  ------------------------------------------------------------
  begin
    if IsLower(Char) then
      return Char - LOWER_TO_UPPER_OFFSET ;
    else
      return Char ;
    end if ;
  end function to_upper ;

  ------------------------------------------------------------
  function to_upper (constant Str : string ) return string is
  ------------------------------------------------------------
    variable result : string(Str'range) ;
  begin
    for i in Str'range loop
      result(i) := to_upper(Str(i)) ;
    end loop ;
    return result ;
  end function to_upper ;

  ------------------------------------------------------------
  function IsWhiteSpace (constant Char : character ) return boolean is
  ------------------------------------------------------------
    constant NBSP  : CHARACTER := CHARACTER'val(160);  -- space character
  begin
--x Note that LF and CR were added for Xilinx
--x    return (Char = ' ' or Char = NBSP or Char = HT) ;
    return (Char = ' ' or Char = HT or Char = LF or Char = CR or Char = NBSP) ;
  end function IsWhiteSpace ;

  ------------------------------------------------------------
  function IsHex (constant Char : character ) return boolean is
  ------------------------------------------------------------
  begin
    case Char is
      when '0' to '9' =>   return TRUE ;
      when 'a' to 'f' =>   return TRUE ;
      when 'A' to 'F' =>   return TRUE ;
      when others     =>   return FALSE ;
    end case ;
  end function IsHex ;

  ------------------------------------------------------------
  function IsHexOrStdLogic (constant Char : character ) return boolean is
  ------------------------------------------------------------
  begin
    case Char is
      when '0' to '9' =>   return TRUE ;
      when 'a' to 'f' =>   return TRUE ;
      when 'A' to 'F' =>   return TRUE ;
      when 'U' | 'X' | 'Z' | 'W' | 'L' | 'H' | '-' => return TRUE ;
      when others     =>   return FALSE ;
    end case ;
  end function IsHexOrStdLogic ;

  ------------------------------------------------------------
  function IsNumber (constant Char : character ) return boolean is
  ------------------------------------------------------------
  begin
    return Char >= '0' and Char <= '9' ;
  end function IsNumber ;

  ------------------------------------------------------------
  function IsNumber (Name : string ) return boolean is
  ------------------------------------------------------------
  begin
    for i in Name'range loop
      if not IsNumber(Name(i)) then
        return FALSE ;
      end if ;
    end loop ;
    return TRUE ;
  end function IsNumber ;

  ------------------------------------------------------------
  function isstd_logic (constant Char : character ) return boolean is
  ------------------------------------------------------------
  begin
    case Char is
      when 'U' | 'X' | '0' | '1' | 'Z' | 'W' | 'L' | 'H' | '-' =>
        return TRUE ;
      when others =>
        return FALSE ;
    end case ;
  end function isstd_logic ;

--  ------------------------------------------------------------
--  function iscomment (constant Char : character ) return boolean is
--  ------------------------------------------------------------
--  begin
--    case Char is
--      when '#' | '/' | '-'  =>
--        return TRUE ;
--      when others =>
--        return FALSE ;
--    end case ;
--  end function iscomment ;

  ------------------------------------------------------------
  procedure RemoveCrLf (S : string ; variable Len : out integer) is
  ------------------------------------------------------------
    alias aS : string (1 to S'length) is S ;
  begin
    Len := 0 ; 
    for i in aS'reverse_range loop
      if not  (aS(i) = CR or aS(i) = LF) then 
        Len := i ;
        exit ; 
      end if ; 
    end loop ;
  end procedure RemoveCrLf ;

  ------------------------------------------------------------
  function RemoveCrLf( S : string ) return string is
  ------------------------------------------------------------
    alias aS : string(1 to S'length) is S ;
    variable Len : integer := 0 ;
  begin
    RemoveCrLf(aS, Len) ; 
    return aS(1 to Len) ;
  end function RemoveCrLf ;

  ------------------------------------------------------------
  procedure RemoveSpace (variable S : inout string ; variable Len : InOut integer) is
  ------------------------------------------------------------
    alias aS : string (1 to S'length) is S ;
  begin
    Len := 0 ;
    for i in aS'range loop
      if not IsWhiteSpace(aS(i)) then
        Len := Len + 1 ;
        aS(Len) := aS(i) ;
      end if ;
    end loop ;
  end procedure RemoveSpace ;

  ------------------------------------------------------------
  -- RemoveHLTable
  --   Convert L to 0 and H to 1, and nothing else
  ------------------------------------------------------------
  constant RemoveHLTable : stdulogic_indexby_stdulogic := (
      'U'   => 'U',
      'X'   => 'X',
      '0'   => '0',
      '1'   => '1',
      'Z'   => 'Z',
      'W'   => 'W',
      'L'   => '0',
      'H'   => '1',
      '-'   => '-'
  );

  ------------------------------------------------------------
  -- local
  function RemoveHL(A : std_ulogic_vector) return std_ulogic_vector is
  ------------------------------------------------------------
--    variable result : A'subtype ;
    variable result : std_ulogic_vector(A'range) ;
  begin
    for i in result'range loop
      result(i) := RemoveHLTable(A(i)) ;
    end loop ;
    return result ;
  end function RemoveHL ;

  ------------------------------------------------------------
  -- local_to_hxstring
  function local_to_hxstring ( A : std_ulogic_vector; IsSigned : Boolean := TRUE ) return string is
  -- Code based on to_hstring from std_logic_1164-body.vhd
  -- Copyright 2019 IEEE P1076 WG Authors
  -- License:  Apache License 2.0 - same as this package
  ------------------------------------------------------------
    constant STRING_LEN   : integer := (A'length+3)/4;
    variable result       : string(1 to STRING_LEN);
    constant EXTEND_A_LEN : integer := STRING_LEN*4 ;
    variable ExtendedA    : std_ulogic_vector(1 to EXTEND_A_LEN) ;
    variable PadA         : std_ulogic_vector(1 to EXTEND_A_LEN - A'length) ;
    variable HexVal       : std_ulogic_vector(1 to 4) ;
    variable PrintBinary  : boolean := FALSE ;
  begin
    if A'length = 0 then
      return "" ;
    end if ;
    if IsSigned or is_x(A(A'left)) then
      PadA := (others => A(A'left)) ;
    else
      PadA := (others => '0') ;
    end if ;
    ExtendedA := RemoveHL(PadA & A) ;
    for i in result'range loop
      HexVal := ExtendedA(4*i-3 to 4*i);
      case HexVal is
        when X"0"   => result(i) := '0';
        when X"1"   => result(i) := '1';
        when X"2"   => result(i) := '2';
        when X"3"   => result(i) := '3';
        when X"4"   => result(i) := '4';
        when X"5"   => result(i) := '5';
        when X"6"   => result(i) := '6';
        when X"7"   => result(i) := '7';
        when X"8"   => result(i) := '8';
        when X"9"   => result(i) := '9';
        when X"A"   => result(i) := 'A';
        when X"B"   => result(i) := 'B';
        when X"C"   => result(i) := 'C';
        when X"D"   => result(i) := 'D';
        when X"E"   => result(i) := 'E';
        when X"F"   => result(i) := 'F';
        when "UUUU" => result(i) := 'U';
        when "XXXX" => result(i) := 'X';
        when "ZZZZ" => result(i) := 'Z';
        when "WWWW" => result(i) := 'W';
        when "----" => result(i) := '-';
        when others => result(i) := '?';  PrintBinary := TRUE ;
      end case;
    end loop;
    if PrintBinary then
      return result & " (" & to_string(A) & ")" ;
    else
      return result ;
    end if ;
  end function local_to_hxstring;

  ------------------------------------------------------------
  -- to_hxstring
  function to_hxstring ( A : std_ulogic_vector) return string is
  ------------------------------------------------------------
  begin
    return local_to_hxstring(A, IsSigned => FALSE) ;
  end function to_hxstring ;

  ------------------------------------------------------------
  -- to_hxstring
  function to_hxstring ( A : unsigned) return string is
  ------------------------------------------------------------
  begin
    return local_to_hxstring(std_ulogic_vector(A), IsSigned => FALSE) ;
  end function to_hxstring ;

  ------------------------------------------------------------
  -- to_hxstring
  function to_hxstring (A : signed) return string is
  ------------------------------------------------------------
  begin
    return local_to_hxstring(std_ulogic_vector(A), IsSigned => TRUE) ;
  end function to_hxstring ;

  ------------------------------------------------------------
  -- to_string_max
  --   If value is integer'high or integer'low, return that instead of the string
  ------------------------------------------------------------
  function to_string_max ( I : integer) return string is
  begin
    if I = integer'high then 
      return "integer'high" ; 
    elsif I = integer'low then 
      return "integer'low" ; 
    else 
      return to_string(I) ;
    end if ; 
  end function to_string_max ;

  ------------------------------------------------------------
  -- Justify
  --   w/ Fill Character
  --   w/o Fill character, Parameter order & names sensible
  ------------------------------------------------------------
  function Justify (
    S       : string ;
    Fill    : character ;
    Amount  : natural ;
    Align   : AlignType := LEFT
  ) return string is
    constant FillLen     : integer := maximum(1, Amount - S'length) ;
    constant HalfFillLen : integer := (FillLen+1)/2 ;
    constant FillString  : string(1 to  FillLen) := (others => FILL) ;
  begin
    if S'length >= Amount then
      return S ;
    end if ;

    case Align is
      when LEFT   =>  return S & FillString ;
      when RIGHT  =>  return FillString & S ;
      when CENTER =>  return FillString(1 to HalfFillLen) & S & FillString(HalfFillLen+1 to FillLen) ;
    end case ;
  end function Justify ;

  function Justify (
    S       : string ;
    Amount  : natural ;
    Align   : AlignType := LEFT
  ) return string is
  begin
    return Justify(S, ' ', Amount, Align) ;
  end function Justify ;

  ------------------------------------------------------------
  procedure GetLine(
  ------------------------------------------------------------
    File     FileId           :       text ;
    variable Buf              : inout line ;
    variable LineCount        : inout integer ;
    variable EndOfFile        : out   boolean ;
    constant IgnoreEmptyLines : in    boolean
  ) is
    variable Empty : boolean ;
  begin
    EndOfFile := FALSE ;
    loop
      if EndFile(FileId) then
        EndOfFile := TRUE ;
        exit ;
      end if ;
      LineCount := LineCount + 1 ;
      ReadLine(FileId, Buf) ;
      exit when not IgnoreEmptyLines ;
      IsWhiteSpaceOrEmpty(Buf, Empty) ;
      exit when not Empty ;
      deallocate(Buf) ; -- It was blank, try again
    end loop ;
  end procedure GetLine ;

  ------------------------------------------------------------
  procedure IsWhiteSpaceOrEmpty (
  ------------------------------------------------------------
    variable L                : InOut  line ;
    variable Empty            : Out    boolean
  ) is
  begin
    Empty := TRUE ;
    for i in L'range loop
      if not IsWhiteSpace(L(i)) then
        Empty := FALSE ;
        exit ;
      end if ;
    end loop ;
  end procedure IsWhiteSpaceOrEmpty ;

  ------------------------------------------------------------
  procedure SkipWhiteSpace (
  ------------------------------------------------------------
    variable L     : InOut line ;
    variable Empty : out   boolean
  ) is
    variable Valid : boolean ;
    variable Char  : character ;
  begin
    Empty := TRUE ;
    WhiteSpLoop : while L /= null and L.all'length > 0 loop
      if IsWhiteSpace(L.all(L'left)) then
        read (L, Char, Valid) ;
        exit when not Valid ;
      else
        Empty := FALSE ;
        return ;
      end if ;
    end loop WhiteSpLoop ;
  end procedure SkipWhiteSpace ;

  ------------------------------------------------------------
  procedure SkipWhiteSpace (
  ------------------------------------------------------------
    variable L     : InOut line
  ) is
    variable Empty : boolean ;
  begin
    SkipWhiteSpace(L, Empty) ;
  end procedure SkipWhiteSpace ;

  ------------------------------------------------------------
  -- Package Local
  procedure FindCommentEnd (
  ------------------------------------------------------------
    variable L     : InOut line ;
    variable Empty : out   boolean ;
    variable MultiLineComment : inout boolean
  ) is
    variable Valid : boolean ;
    variable Char  : character ;
  begin
    MultiLineComment := TRUE ;
    Empty            := TRUE ;
    FindEndOfCommentLoop : while L /= null and L.all'length > 1 loop
      read(L, Char, Valid) ;
      if Char = '*' and L.all(L'left) = '/' then
        read(L, Char, Valid) ;
        Empty            := FALSE ;
        MultiLineComment := FALSE ;
        exit FindEndOfCommentLoop ;
      end if ;
    end loop ;
  end procedure FindCommentEnd ;

  ------------------------------------------------------------
  procedure EmptyOrCommentLine (
  ------------------------------------------------------------
    variable L                : InOut  line ;
    variable Empty            : InOut  boolean ;
    variable MultiLineComment : inout  boolean
  ) is
    variable Valid : boolean ;
    variable Next2Char  : string(1 to 2) ;
    constant NBSP  : CHARACTER := CHARACTER'val(160);  -- space character
  begin
    if MultiLineComment then
      FindCommentEnd(L, Empty, MultiLineComment) ;
    end if ;

    EmptyCheckLoop : while not MultiLineComment loop
      SkipWhiteSpace(L, Empty) ;
      exit when Empty ; -- line null or 0 in length detected by SkipWhite

      Empty := TRUE ;

      exit when L.all(L'left) = '#' ; -- shell style comment

      if L.all'length >= 2 then
        if L'ascending then
          Next2Char := L.all(L'left to L'left+1) ;
        else
          Next2Char := L.all(L'left downto L'left-1) ;
        end if;
        exit when Next2Char = "//" ; -- C style comment
        exit when Next2Char = "--" ; -- VHDL style comment

        if Next2Char = "/*" then   -- C style multi line comment
          FindCommentEnd(L, Empty, MultiLineComment) ;
          exit when Empty ;
          next EmptyCheckLoop ; -- Found end of comment, restart processing line
        end if ;
      end if ;

      Empty := FALSE ;
      exit ;
    end loop EmptyCheckLoop ;
  end procedure EmptyOrCommentLine ;

  ------------------------------------------------------------
  procedure ReadUntilDelimiterOrEOL(
  ------------------------------------------------------------
    variable L         : InOut line ;
    variable Name      : InOut line ;
    constant Delimiter : In    character ;
    variable ReadValid : Out   boolean
  ) is
    variable NameStr   : string(1 to L'length) ;
    variable ReadLen   : integer := 1 ;
    variable Good      : boolean ;
  begin
    ReadValid := TRUE ;
    for i in NameStr'range loop
      Read(L, NameStr(i), Good) ;
      ReadValid := ReadValid and Good ;
--      if NameStr(i) = Delimiter then
      if NameStr(i) = Delimiter or NameStr(i) = CR or NameStr(i) = LF then
        -- Read(L, NameStr(1 to i), ReadValid) ;
        Name := new string'(NameStr(1 to i-1)) ;
        exit ;
      elsif i = NameStr'length then
        -- Read(L, NameStr(1 to i), ReadValid) ;
        Name := new string'(NameStr(1 to i)) ;
        exit ;
      end if ;
    end loop ;
  end procedure ReadUntilDelimiterOrEOL ;

  ------------------------------------------------------------
  procedure FindDelimiter(
  ------------------------------------------------------------
    variable L                : InOut line ;
    constant Delimiter        : In    character ;
    variable Found            : Out   boolean
  ) is
    variable Char       : Character ;
    variable ReadValid  : boolean ;
  begin
    Found := FALSE ;
    ReadLoop : loop
      -- Skip White Space unless it is the delimiter.   
      if Delimiter /= ' ' then
        SkipWhiteSpace(L) ;
      end if ;

      -- read the character - which is expected to be the delimiter.
      Read(L, Char, ReadValid) ;
      exit when ReadValid = FALSE or Char /= Delimiter ;  -- Fail if not delimiter
      Found := TRUE ;
      exit ;
    end loop ;
  end procedure FindDelimiter ;

  ------------------------------------------------------------
  procedure ReadHexToken (
  -- Reads Upto Result'length values, less is ok.
  -- Does not skip white space
  ------------------------------------------------------------
    variable L      : InOut line ;
    variable Result : Out   std_logic_vector ;
    variable StrLen : Out   integer
  ) is
    constant NumHexChars   : integer := (Result'length+3)/4 ;
    constant ResultNormLen : integer := NumHexChars * 4 ;
    variable NextChar      : character ;
    variable CharCount     : integer ;
    variable ReturnVal     : std_logic_vector(ResultNormLen-1 downto 0) ;
    variable ReadVal       : std_logic_vector(3 downto 0) ;
    variable ReadValSl     : std_logic ;
    variable ReadValid     : boolean ;
  begin
    ReturnVal := (others => '0') ;
    CharCount := 0 ;

    ReadLoop : while L /= null and L.all'length > 0 loop
      NextChar := L.all(L'left) ;
--      if ishex(NextChar) or NextChar = 'X' or NextChar = 'Z' then
      if IsHexOrStdLogic(NextChar) then
        -- Currently hread only handles X or Z
        if IsHex(NextChar) then
          hread(L, ReadVal, ReadValid) ;
        else
          read(L, ReadValSl, ReadValid) ;
          ReadVal := ReadValSl & ReadValSl & ReadValSl & ReadValSl ;
        end if ;
        ReturnVal := ReturnVal(ResultNormLen-5 downto 0) & ReadVal ;
        CharCount := CharCount + 1 ;
        exit ReadLoop when CharCount >= NumHexChars ;
      elsif NextChar = '_' then
        read(L, NextChar, ReadValid) ;
      else
        exit ;
      end if ;
    end loop ReadLoop ;

    if CharCount >= NumHexChars then
      StrLen := Result'length ;
    else
      StrLen := CharCount * 4 ;
    end if ;

    Result := ReturnVal(Result'length-1 downto 0) ;
  end procedure ReadHexToken ;

  ------------------------------------------------------------
  procedure ReadBinaryToken (
  -- Reads Upto Result'length values, less is ok.
  -- Does not skip white space
  ------------------------------------------------------------
    variable L      : InOut line ;
    variable Result : Out   std_logic_vector ;
    variable StrLen : Out   integer
  ) is
    variable NextChar       : character ;
    variable CharCount      : integer ;
    variable ReadVal        : std_logic ;
    variable ReturnVal      : std_logic_vector(Result'length-1 downto 0) ;
    variable ReadValid      : boolean ;
  begin
    ReturnVal := (others => '0') ;
    CharCount := 0 ;

    ReadLoop : while L /= null and L.all'length > 0 loop
      NextChar := L.all(L'left) ;
      if isstd_logic(NextChar) then
        read(L, ReadVal, ReadValid) ;
        ReturnVal := ReturnVal(Result'length-2 downto 0) & ReadVal ;
        CharCount := CharCount + 1 ;
        exit ReadLoop when CharCount >= Result'length ;
      elsif NextChar = '_' then
        read(L, NextChar, ReadValid) ;
      else
        exit ;
      end if ;
    end loop ReadLoop ;

    StrLen := CharCount ;
    Result := ReturnVal ;
  end procedure ReadBinaryToken ;

  ------------------------------------------------------------
  procedure sread_c (
  ------------------------------------------------------------
    variable L          : InOut line ;
    variable Name       : Out   string ;
    variable NameLength : Out   integer
  ) is
    variable NameStr   : string(1 to Name'length) ;
    variable ReadValid : boolean ;
    variable Empty     : boolean ;
  begin
    SkipWhiteSpace(L, Empty) ;
    if Empty then
      NameLength := 0 ;
      return ;
    end if ;
    NameLength := NameStr'length ;
    for i in NameStr'range loop
      Read(L, NameStr(i), ReadValid) ;
      if not ReadValid or IsWhiteSpace(NameStr(i)) then
        NameLength := i - 1 ;
        exit ;
      end if ;
    end loop ;
    Name := NameStr ;
  end procedure sread_c ;

end package body TextUtilPkg ;