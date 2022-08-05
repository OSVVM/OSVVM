--
--  File Name:         MemorySupportPkg.vhd
--  Design Unit Name:  MemorySupportPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
--  Contributor(s):            
--     Jim Lewis      email:  jim@synthworks.com   
--
--  Description
--      Package defines a protected type, MemoryPType, and methods  
--      for efficiently implementing memory data structures
--    
--  Developed for: 
--        SynthWorks Design Inc. 
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
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

  subtype MemoryBaseType_Original is integer ; 
  function ToMemoryBaseType  (Slv  : std_logic_vector) return MemoryBaseType_Original ;
  function FromMemoryBaseType(Mem  : MemoryBaseType_Original ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType(Size : integer) return MemoryBaseType_Original ; 

  type MemoryBaseType_X is array (integer range <>) of integer ;
  function ToMemoryBaseType  (Slv  : std_logic_vector) return MemoryBaseType_X ;
  function FromMemoryBaseType(Mem  : MemoryBaseType_X ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType(Size : integer) return MemoryBaseType_X ; 

  type MemoryBaseType_NoX is array (integer range <>) of integer ;
  function ToMemoryBaseType  (Slv  : std_logic_vector) return MemoryBaseType_NoX ;
  function FromMemoryBaseType(Mem  : MemoryBaseType_NoX ; Size : integer) return std_logic_vector ;
  function InitMemoryBaseType(Size : integer) return MemoryBaseType_NoX ; 

end MemorySupportPkg ;

package body MemorySupportPkg is 

  ------------------------------------------------------------
  function ToMemoryBaseType(Slv : std_logic_vector) return MemoryBaseType_Original is 
  ------------------------------------------------------------
    variable result : MemoryBaseType_Original ; 
  begin
    if (Is_X(Slv)) then 
      result := -1 ;
    else
      result := to_integer( Slv ) ;
    end if ;
    return result ; 
  end function ToMemoryBaseType ; 
  
  ------------------------------------------------------------
  function FromMemoryBaseType(Mem : MemoryBaseType_Original ; Size : integer) return std_logic_vector is 
  ------------------------------------------------------------
    variable Data : std_logic_vector(Size-1 downto 0) ; 
  begin
    if Mem >= 0 then 
      -- Get the Word from the Array
      Data := to_slv(Mem, Size) ;
    elsif Mem = -1 then 
     -- X in Word, return all X
      Data := (Data'range => 'X') ;
    else 
     -- Location Uninitialized, return all X
      Data := (Data'range => 'U') ;
    end if ;
    return Data ; 
  end function FromMemoryBaseType ; 
  
  ------------------------------------------------------------
  function InitMemoryBaseType(Size : integer) return MemoryBaseType_Original is  
  ------------------------------------------------------------
--    constant Result : std_logic_vector := (Size-1 downto 0 => 'U') ; 
  begin
--    return ToMemoryBaseType(Result) ; 
    return integer'left ; 
  end function InitMemoryBaseType ; 
  
  
  ------------------------------------------------------------
  function ToMemoryBaseType(Slv : std_logic_vector) return MemoryBaseType_X is 
  ------------------------------------------------------------
    constant Size          : integer := Slv'length ;
    constant NumIntegers   : integer := integer(Ceil(real(Size)/16.0)) ; 
    variable NormalizedSlv : std_logic_vector(NumIntegers*16-1 downto 0) ;
    variable Bits16        : std_logic_vector(15 downto 0) ;
    variable BitIsX        : std_logic_vector(15 downto 0) ; 
    variable BitVal        : std_logic_vector(15 downto 0) ;
    variable result        : MemoryBaseType_X (NumIntegers-1 downto 0) ; 
  begin
    NormalizedSlv := Resize(Slv, NumIntegers*16) ; 
    for MemIndex in 0 to NumIntegers-1 loop 
      Bits16 := NormalizedSlv(16*MemIndex + 15 downto 16*MemIndex) ;
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
  end function ToMemoryBaseType ; 
  
  ------------------------------------------------------------
  function FromMemoryBaseType(Mem : MemoryBaseType_X ; Size : integer) return std_logic_vector is 
  ------------------------------------------------------------
    constant NumIntegers   : integer := integer(Ceil(real(Size)/16.0)) ; 
    alias    NormalizedMem : MemoryBaseType_X(NumIntegers-1 downto 0) is Mem ; 
    variable NormalizedSlv : std_logic_vector(NumIntegers*16-1 downto 0) ;
    variable Bits16        : std_logic_vector(15 downto 0) ;
    variable BitIsX        : std_logic_vector(15 downto 0) ; 
    variable BitVal        : std_logic_vector(15 downto 0) ;

  begin
    if Mem'length /= NumIntegers then 
      AlertIfNotEqual(Mem'length, NumIntegers, "MemoryPkg.FromMemoryBaseType Size: " & to_string(Size) & " does not match MemBaseType length") ; 
    end if ; 
    for MemIndex in 0 to NumIntegers-1 loop 
      (BitIsX, BitVal) := std_logic_vector(to_signed(NormalizedMem(MemIndex), 32)) ;
      for BitIndex in 0 to 15 loop
        if BitIsX(BitIndex) = '1' then 
          Bits16(BitIndex) := 'U' when BitVal(BitIndex) = '1' else 'X' ;
        else
          Bits16(BitIndex) := BitVal(BitIndex) ; 
        end if ;      
      end loop ;
      NormalizedSlv(16*MemIndex + 15 downto 16*MemIndex) := Bits16 ;
    end loop ; 
    return NormalizedSlv(Size-1 downto 0) ; 
  end function FromMemoryBaseType ; 
  
  ------------------------------------------------------------
  function InitMemoryBaseType(Size : integer) return MemoryBaseType_X is  
  ------------------------------------------------------------
    constant Result : std_logic_vector := (Size-1 downto 0 => 'U') ; 
  begin
    return ToMemoryBaseType(Result) ; 
  end function InitMemoryBaseType ; 

  ------------------------------------------------------------
  function ToMemoryBaseType(Slv : std_logic_vector) return MemoryBaseType_NoX is 
  ------------------------------------------------------------
    constant Size          : integer := Slv'length ;
    constant NumIntegers   : integer := integer(Ceil(real(Size)/32.0)) ; 
    variable NormalizedSlv : std_logic_vector(NumIntegers*32-1 downto 0) ;
    variable Bits32        : std_logic_vector(31 downto 0) ;
    variable BitVal        : std_logic_vector(31 downto 0) ;
    variable result        : MemoryBaseType_NoX (NumIntegers-1 downto 0) ; 
  begin
    NormalizedSlv := Resize(Slv, NumIntegers*32) ; 
    for MemIndex in 0 to NumIntegers-1 loop 
      Bits32 := NormalizedSlv(32*MemIndex + 31 downto 32*MemIndex) ;
      for BitIndex in 0 to 31 loop
        if Is_X(Bits32(BitIndex)) then 
          BitVal(BitIndex) := '0' ;
        else 
          BitVal(BitIndex) := Bits32(BitIndex) ;
        end if ; 
      end loop ; 
      result(MemIndex) := to_integer(signed(Bits32)) ; 
    end loop ;
    return result ; 
  end function ToMemoryBaseType ; 
  
  ------------------------------------------------------------
  function FromMemoryBaseType(Mem : MemoryBaseType_NoX ; Size : integer) return std_logic_vector is 
  ------------------------------------------------------------
    constant NumIntegers   : integer := integer(Ceil(real(Size)/32.0)) ; 
    alias    NormalizedMem : MemoryBaseType_NoX(NumIntegers-1 downto 0) is Mem ; 
    variable NormalizedSlv : std_logic_vector(NumIntegers*32-1 downto 0) ;
    variable Bits32        : std_logic_vector(31 downto 0) ;
    variable BitVal        : std_logic_vector(31 downto 0) ;

  begin
    if Mem'length /= NumIntegers then 
      AlertIfNotEqual(Mem'length, NumIntegers, "MemoryPkg.FromMemoryBaseType Size: " & to_string(Size) & " does not match MemBaseType length") ; 
    end if ; 
    for MemIndex in 0 to NumIntegers-1 loop 
      Bits32 := std_logic_vector(to_signed(NormalizedMem(MemIndex), 32)) ;
      NormalizedSlv(32*MemIndex + 31 downto 32*MemIndex) := Bits32 ;
    end loop ; 
    return NormalizedSlv(Size-1 downto 0) ; 
  end function FromMemoryBaseType ; 
  
  ------------------------------------------------------------
  function InitMemoryBaseType(Size : integer) return MemoryBaseType_NoX is  
  ------------------------------------------------------------
    constant Result : std_logic_vector := (Size-1 downto 0 => 'U') ; 
  begin
    return ToMemoryBaseType(Result) ; 
  end function InitMemoryBaseType ; 

end MemorySupportPkg ;