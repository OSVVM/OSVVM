--
--  File Name:         MemorySupportPkg.vhd
--  Design Unit Name:  MemorySupportPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--    Jim Lewis      email:  jim@synthworks.com
--
--  Description
--    Defines the storage policies: UX01, 01, and orig
--      Policy X is now an alias to UX01 and policy NoX is now an alias to 01
--    Supports MemoryGenericPkg
--    Policies are implemented in instances in MemoryPkg
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    08/2026   2026.08    Updating naming
--    10/2022   2022.10    Minor changes
--    08/2022   2022.08    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2022 to 2026 by SynthWorks Design Inc.
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

library IEEE ;
  use IEEE.std_logic_1164.all ;
  use IEEE.numeric_std.all ;
  use IEEE.numeric_std_unsigned.all ;
  use IEEE.math_real.all ;

  use work.AlertLogPkg.all ;
  use work.LanguageSupport2019Pkg.all ;

package MemorySupportPkg is

  subtype MemoryBaseType is integer_vector ;

  -- -----------------------------------------------
  -- Memory Storage Policy UX01
  --   Memory supports values UX01 and maintains fidelity of X and U
  --   Each integer value stores HALF_WORD_WIDTH bits of data and HALF_WORD_WIDTH bits of X and U
  --   Bit size unlimited
  --
  subtype  MemoryBaseType_UX01 is integer_vector ;
  function SizeMemoryBaseType_UX01(Size : integer) return integer ;
  function ToMemoryBaseType_UX01  (Slv  : std_logic_vector ; Size : integer) return integer_vector ;
  function FromMemoryBaseType_UX01(Mem  : integer_vector   ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType_UX01(Size : integer) return integer_vector ;

  -- _X is deprecated and is now an alias to _UX01
  subtype  MemoryBaseType_X is integer_vector ;
  alias SizeMemoryBaseType_X  is SizeMemoryBaseType_UX01[integer return integer] ;
  alias ToMemoryBaseType_X    is ToMemoryBaseType_UX01  [std_logic_vector, integer return integer_vector] ;
  alias FromMemoryBaseType_X  is FromMemoryBaseType_UX01[integer_vector,   integer return std_logic_vector] ;
  alias InitMemoryBaseType_X  is InitMemoryBaseType_UX01[integer return integer_vector] ;

  -- -----------------------------------------------
  -- Memory Storage Policy 01
  --   Memory only stores 0 and 1.  X and U are stored as a 0
  --   Each integer value stores WORD_WIDTH bits of data
  --   Bit size unlimited
  --   For larger word widths, uses half storage as UX01
  --
  subtype  MemoryBaseType_01 is integer_vector ;
  function SizeMemoryBaseType_01(Size : integer) return integer ;
  function ToMemoryBaseType_01  (Slv  : std_logic_vector ; Size : integer) return integer_vector ;
  function FromMemoryBaseType_01(Mem  : integer_vector   ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType_01(Size : integer) return integer_vector ;

  -- _NoX is deprecated and is an alias to _01
  subtype  MemoryBaseType_NoX is integer_vector ;
  alias SizeMemoryBaseType_NoX  is SizeMemoryBaseType_01[integer return integer] ;
  alias ToMemoryBaseType_NoX    is ToMemoryBaseType_01  [std_logic_vector, integer return integer_vector] ;
  alias FromMemoryBaseType_NoX  is FromMemoryBaseType_01[integer_vector,   integer return std_logic_vector] ;
  alias InitMemoryBaseType_NoX  is InitMemoryBaseType_01[integer return integer_vector] ;


  -- -----------------------------------------------
  -- Memory policy orig
  --   For backward compatibility only
  --   upto 31 bits of data
  --   X or U in any bit and the word becomes X
  --
  subtype  MemoryBaseType_orig is integer_vector ;
  function SizeMemoryBaseType_orig(Size : integer) return integer ;
  function ToMemoryBaseType_orig  (Slv  : std_logic_vector ; Size : integer) return integer_vector ;
  function FromMemoryBaseType_orig(Mem  : integer_vector   ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType_orig(Size : integer) return integer_vector ;

end MemorySupportPkg ;

package body MemorySupportPkg is

  constant WORD_WIDTH       : integer := INTEGER_WIDTH ;
  constant HALF_WORD_WIDTH  : integer := WORD_WIDTH / 2 ;

  ------------------------------------------------------------
  -- Memory Policy X
  --   Maintains fidelity of X and U
  --   Each integer value stores HALF_WORD_WIDTH bits of data and HALF_WORD_WIDTH bits o X and U
  ------------------------------------------------------------
  ------------------------------------------------------------
  function SizeMemoryBaseType_UX01(Size : integer) return integer is
  ------------------------------------------------------------
  begin
    return integer(Ceil(real(Size)/real(HALF_WORD_WIDTH))) ;
  end function SizeMemoryBaseType_UX01 ;

  ------------------------------------------------------------
  function ToMemoryBaseType_UX01(Slv : std_logic_vector ; Size : integer) return integer_vector is
  ------------------------------------------------------------
    variable NormalizedSlv : std_logic_vector(Size*HALF_WORD_WIDTH-1 downto 0) ;
    variable BitsToEncode  : std_logic_vector((HALF_WORD_WIDTH -1) downto 0) ;
    variable BitIsX        : std_logic_vector((HALF_WORD_WIDTH -1) downto 0) ;
    variable BitVal        : std_logic_vector((HALF_WORD_WIDTH -1) downto 0) ;
    variable result        : integer_vector (Size-1 downto 0) ;
  begin
    NormalizedSlv := Resize(Slv, Size*HALF_WORD_WIDTH) ;
    for MemIndex in result'reverse_range loop
      BitsToEncode := NormalizedSlv(HALF_WORD_WIDTH*MemIndex+(HALF_WORD_WIDTH-1) downto HALF_WORD_WIDTH*MemIndex) ;
      for BitIndex in 0 to (HALF_WORD_WIDTH-1) loop
        if Is_X(BitsToEncode(BitIndex)) then
          BitIsX(BitIndex) := '1' ;
          BitVal(BitIndex) := '1' when BitsToEncode(BitIndex) = 'U' else '0' ;
        else
          BitIsX(BitIndex) := '0' ;
          BitVal(BitIndex) := BitsToEncode(BitIndex) ;
        end if ;
      end loop ;
      result(MemIndex) := to_integer(signed(BitIsX & BitVal)) ;
    end loop ;
    return result ;
  end function ToMemoryBaseType_UX01 ;

  ------------------------------------------------------------
  function FromMemoryBaseType_UX01(Mem : integer_vector ; Size : integer) return std_logic_vector is
  ------------------------------------------------------------
    constant NumIntegers   : integer := Mem'length ;
    alias    NormalizedMem : integer_vector(NumIntegers-1 downto 0) is Mem ;
    variable NormalizedSlv : std_logic_vector(NumIntegers*HALF_WORD_WIDTH-1 downto 0) ;
    variable BitsToDecode  : std_logic_vector((HALF_WORD_WIDTH-1) downto 0) ;
    variable BitIsX        : std_logic_vector((HALF_WORD_WIDTH-1) downto 0) ;
    variable BitVal        : std_logic_vector((HALF_WORD_WIDTH-1) downto 0) ;
  begin
    for MemIndex in NormalizedMem'reverse_range loop
      (BitIsX, BitVal) := std_logic_vector(to_signed(NormalizedMem(MemIndex), WORD_WIDTH)) ;
      for BitIndex in 0 to (HALF_WORD_WIDTH-1) loop
        if BitIsX(BitIndex) = '1' then
          BitsToDecode(BitIndex) := 'U' when BitVal(BitIndex) = '1' else 'X' ;
        else
          BitsToDecode(BitIndex) := BitVal(BitIndex) ;
        end if ;
      end loop ;
      NormalizedSlv(HALF_WORD_WIDTH*MemIndex+(HALF_WORD_WIDTH-1) downto HALF_WORD_WIDTH*MemIndex) := BitsToDecode ;
    end loop ;
    return NormalizedSlv(Size-1 downto 0) ;
  end function FromMemoryBaseType_UX01 ;

  ------------------------------------------------------------
  function InitMemoryBaseType_UX01(Size : integer) return integer_vector is
  ------------------------------------------------------------
    constant BaseU : integer_vector(0 to Size-1)  := (others => -1) ;
  begin
    return BaseU ;
  end function InitMemoryBaseType_UX01 ;


  ------------------------------------------------------------
  -- Memory Policy NoX
  --   X and U are stored as a 0
  --   Each integer value stores WORD_WIDTH bits of data
  ------------------------------------------------------------
  ------------------------------------------------------------
  function SizeMemoryBaseType_01(Size : integer) return integer is
  ------------------------------------------------------------
  begin
    return integer(Ceil(real(Size)/real(WORD_WIDTH))) ;
  end function SizeMemoryBaseType_01 ;

  ------------------------------------------------------------
  function ToMemoryBaseType_01(Slv : std_logic_vector ; Size : integer) return integer_vector is
  ------------------------------------------------------------
    variable NormalizedSlv : std_logic_vector(Size*WORD_WIDTH-1 downto 0) ;
    variable BitsToEncode  : std_logic_vector((WORD_WIDTH-1) downto 0) ;
    variable BitVal        : std_logic_vector((WORD_WIDTH-1) downto 0) ;
    variable result        : integer_vector (Size-1 downto 0) ;
  begin
    NormalizedSlv := Resize(Slv, Size*WORD_WIDTH) ;
    for MemIndex in result'reverse_range loop
      BitsToEncode := NormalizedSlv(WORD_WIDTH*MemIndex+(WORD_WIDTH-1) downto WORD_WIDTH*MemIndex) ;
      for BitIndex in 0 to (WORD_WIDTH-1) loop
        if Is_X(BitsToEncode(BitIndex)) then
          BitVal(BitIndex) := '0' ;
        else
          BitVal(BitIndex) := BitsToEncode(BitIndex) ;
        end if ;
      end loop ;
      result(MemIndex) := to_integer(signed(BitVal)) ;
    end loop ;
    return result ;
  end function ToMemoryBaseType_01 ;

  ------------------------------------------------------------
  function FromMemoryBaseType_01(Mem : integer_vector ; Size : integer) return std_logic_vector is
  ------------------------------------------------------------
    constant NumIntegers   : integer := Mem'length ;
    alias    NormalizedMem : integer_vector(NumIntegers-1 downto 0) is Mem ;
    variable NormalizedSlv : std_logic_vector(NumIntegers*WORD_WIDTH-1 downto 0) ;
    variable BitsToDecode  : std_logic_vector((WORD_WIDTH-1) downto 0) ;
    variable BitVal        : std_logic_vector((WORD_WIDTH-1) downto 0) ;
  begin
    for MemIndex in NormalizedMem'reverse_range loop
      BitsToDecode := std_logic_vector(to_signed(NormalizedMem(MemIndex), WORD_WIDTH)) ;
      NormalizedSlv(WORD_WIDTH*MemIndex+(WORD_WIDTH-1) downto WORD_WIDTH*MemIndex) := BitsToDecode ;
    end loop ;
    return NormalizedSlv(Size-1 downto 0) ;
  end function FromMemoryBaseType_01 ;

  ------------------------------------------------------------
  function InitMemoryBaseType_01(Size : integer) return integer_vector is
  ------------------------------------------------------------
    constant BaseU : integer_vector(0 to Size-1)  := (others => 0) ;
  begin
    return BaseU ;
  end function InitMemoryBaseType_01 ;


  ------------------------------------------------------------
  -- Memory policy orig
  --   For backward compatibility only
  --   upto 31 bits of data
  --   X or U in any bit and the word becomes X
  ------------------------------------------------------------
  ------------------------------------------------------------
  function SizeMemoryBaseType_orig(Size : integer) return integer is
  ------------------------------------------------------------
  begin
    -- would be better as an alert, but not worth the pain since this is deprecated
    assert Size < WORD_WIDTH report "MemoryPkg.MemInit/NewID.  DataWidth = " & to_string(Size) & " must be < WORD_WIDTH " severity FAILURE ;
    return 1 ;
  end function SizeMemoryBaseType_orig ;

  ------------------------------------------------------------
  function ToMemoryBaseType_orig(Slv : std_logic_vector ; Size : integer) return integer_vector is
  ------------------------------------------------------------
    variable result : integer ;
  begin
    if (Is_X(Slv)) then
      result := -1 ;
    else
      result := to_integer( Slv ) ;
    end if ;
    return (1 => result) ;
  end function ToMemoryBaseType_orig ;

  ------------------------------------------------------------
  function FromMemoryBaseType_orig(Mem : integer_vector ; Size : integer) return std_logic_vector is
  ------------------------------------------------------------
    variable Data : std_logic_vector(Size-1 downto 0) ;
  begin
    if Mem(Mem'left) >= 0 then
      -- Get the Word from the Array
      Data := to_slv(Mem(Mem'left), Size) ;
    elsif Mem(Mem'left) = -1 then
     -- X in Word, return all X
      Data := (Data'range => 'X') ;
    else
     -- Location Uninitialized, return all X
      Data := (Data'range => 'U') ;
    end if ;
    return Data ;
  end function FromMemoryBaseType_orig ;

  ------------------------------------------------------------
  function InitMemoryBaseType_orig(Size : integer) return integer_vector is
  ------------------------------------------------------------
  begin
    return (1 => integer'low) ;
  end function InitMemoryBaseType_orig ;

end MemorySupportPkg ;