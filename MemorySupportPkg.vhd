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
--    Defines the storage policies: X, NoX, and orig 
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
--    10/2022   2022.10    Minor changes
--    08/2022   2022.08    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2022 by SynthWorks Design Inc.  
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
  
package MemorySupportPkg is

  subtype MemoryBaseType is integer_vector ; 

  -- -----------------------------------------------
  -- Memory Policy X
  --   Maintains fidelity of X and U
  --   Each integer value stores 16 bits of data and 16 bits o X and U
  --   Bit size unlimited
  -- 
  subtype  MemoryBaseType_X is integer_vector ;
  function SizeMemoryBaseType_X(Size : integer) return integer ;  
  function ToMemoryBaseType_X  (Slv  : std_logic_vector ; Size : integer) return integer_vector ;
  function FromMemoryBaseType_X(Mem  : integer_vector   ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType_X(Size : integer) return integer_vector ; 

  -- -----------------------------------------------
  -- Memory Policy NoX
  --   X and U are stored as a 0
  --   Each integer value stores 32 bits of data
  --   Bit size unlimited
  --   For larger word widths, uses half storage as X
  -- 
  subtype  MemoryBaseType_NoX is integer_vector ;
  function SizeMemoryBaseType_NoX(Size : integer) return integer ;  
  function ToMemoryBaseType_NoX  (Slv  : std_logic_vector ; Size : integer) return integer_vector ;
  function FromMemoryBaseType_NoX(Mem  : integer_vector   ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType_NoX(Size : integer) return integer_vector ; 

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

  ------------------------------------------------------------
  -- Memory Policy X
  --   Maintains fidelity of X and U
  --   Each integer value stores 16 bits of data and 16 bits o X and U
  ------------------------------------------------------------
  ------------------------------------------------------------
  function SizeMemoryBaseType_X(Size : integer) return integer is  
  ------------------------------------------------------------
  begin
    return integer(Ceil(real(Size)/16.0)) ; 
  end function SizeMemoryBaseType_X ; 
  
  ------------------------------------------------------------
  function ToMemoryBaseType_X(Slv : std_logic_vector ; Size : integer) return integer_vector is 
  ------------------------------------------------------------
    variable NormalizedSlv : std_logic_vector(Size*16-1 downto 0) ;
    variable Bits16        : std_logic_vector(15 downto 0) ;
    variable BitIsX        : std_logic_vector(15 downto 0) ; 
    variable BitVal        : std_logic_vector(15 downto 0) ;
    variable result        : integer_vector (Size-1 downto 0) ; 
  begin
    NormalizedSlv := Resize(Slv, Size*16) ; 
    for MemIndex in result'reverse_range loop 
      Bits16 := NormalizedSlv(16*MemIndex+15 downto 16*MemIndex) ;
      for BitIndex in 0 to 15 loop
        if Is_X(Bits16(BitIndex)) then 
          BitIsX(BitIndex) := '1' ; 
          BitVal(BitIndex) := '1' when Bits16(BitIndex) = 'U' else '0' ;
        else 
          BitIsX(BitIndex) := '0' ; 
          BitVal(BitIndex) := Bits16(BitIndex) ;
        end if ; 
      end loop ; 
      result(MemIndex) := to_integer(signed(BitIsX & BitVal)) ; 
    end loop ;
    return result ; 
  end function ToMemoryBaseType_X ; 
  
  ------------------------------------------------------------
  function FromMemoryBaseType_X(Mem : integer_vector ; Size : integer) return std_logic_vector is 
  ------------------------------------------------------------
    constant NumIntegers   : integer := Mem'length ; 
    alias    NormalizedMem : integer_vector(NumIntegers-1 downto 0) is Mem ; 
    variable NormalizedSlv : std_logic_vector(NumIntegers*16-1 downto 0) ;
    variable Bits16        : std_logic_vector(15 downto 0) ;
    variable BitIsX        : std_logic_vector(15 downto 0) ; 
    variable BitVal        : std_logic_vector(15 downto 0) ;
  begin
    for MemIndex in NormalizedMem'reverse_range loop 
      (BitIsX, BitVal) := std_logic_vector(to_signed(NormalizedMem(MemIndex), 32)) ;
      for BitIndex in 0 to 15 loop
        if BitIsX(BitIndex) = '1' then 
          Bits16(BitIndex) := 'U' when BitVal(BitIndex) = '1' else 'X' ;
        else
          Bits16(BitIndex) := BitVal(BitIndex) ; 
        end if ;      
      end loop ;
      NormalizedSlv(16*MemIndex+15 downto 16*MemIndex) := Bits16 ;
    end loop ; 
    return NormalizedSlv(Size-1 downto 0) ; 
  end function FromMemoryBaseType_X ; 
  
  ------------------------------------------------------------
  function InitMemoryBaseType_X(Size : integer) return integer_vector is  
  ------------------------------------------------------------
    constant BaseU : integer_vector(0 to Size-1)  := (others => -1) ;
  begin
    return BaseU ; 
  end function InitMemoryBaseType_X ; 
  

  ------------------------------------------------------------
  -- Memory Policy NoX
  --   X and U are stored as a 0
  --   Each integer value stores 32 bits of data
  ------------------------------------------------------------
  ------------------------------------------------------------
  function SizeMemoryBaseType_NoX(Size : integer) return integer is  
  ------------------------------------------------------------
  begin
    return integer(Ceil(real(Size)/32.0)) ; 
  end function SizeMemoryBaseType_NoX ; 
  
  ------------------------------------------------------------
  function ToMemoryBaseType_NoX(Slv : std_logic_vector ; Size : integer) return integer_vector is 
  ------------------------------------------------------------
    variable NormalizedSlv : std_logic_vector(Size*32-1 downto 0) ;
    variable Bits32        : std_logic_vector(31 downto 0) ;
    variable BitVal        : std_logic_vector(31 downto 0) ;
    variable result        : integer_vector (Size-1 downto 0) ; 
  begin
    NormalizedSlv := Resize(Slv, Size*32) ; 
    for MemIndex in result'reverse_range loop 
      Bits32 := NormalizedSlv(32*MemIndex+31 downto 32*MemIndex) ;
      for BitIndex in 0 to 31 loop
        if Is_X(Bits32(BitIndex)) then 
          BitVal(BitIndex) := '0' ;
        else 
          BitVal(BitIndex) := Bits32(BitIndex) ;
        end if ; 
      end loop ; 
      result(MemIndex) := to_integer(signed(BitVal)) ; 
    end loop ;
    return result ; 
  end function ToMemoryBaseType_NoX ; 
  
  ------------------------------------------------------------
  function FromMemoryBaseType_NoX(Mem : integer_vector ; Size : integer) return std_logic_vector is 
  ------------------------------------------------------------
    constant NumIntegers   : integer := Mem'length ; 
    alias    NormalizedMem : integer_vector(NumIntegers-1 downto 0) is Mem ; 
    variable NormalizedSlv : std_logic_vector(NumIntegers*32-1 downto 0) ;
    variable Bits32        : std_logic_vector(31 downto 0) ;
    variable BitVal        : std_logic_vector(31 downto 0) ;
  begin
    for MemIndex in NormalizedMem'reverse_range loop 
      Bits32 := std_logic_vector(to_signed(NormalizedMem(MemIndex), 32)) ;
      NormalizedSlv(32*MemIndex+31 downto 32*MemIndex) := Bits32 ;
    end loop ; 
    return NormalizedSlv(Size-1 downto 0) ; 
  end function FromMemoryBaseType_NoX ; 
  
  ------------------------------------------------------------
  function InitMemoryBaseType_NoX(Size : integer) return integer_vector is  
  ------------------------------------------------------------
    constant BaseU : integer_vector(0 to Size-1)  := (others => 0) ;
  begin
    return BaseU ; 
  end function InitMemoryBaseType_NoX ; 


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
    assert Size < 32 report "MemoryPkg.MemInit/NewID.  DataWidth = " & to_string(Size) & " must be < 32 " severity FAILURE ; 
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