--
--  File Name:         ResizePkg.vhd
--  Design Unit Name:  ResizePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@SynthWorks.com 
--  Contributor(s):            
--     Jim Lewis      email:  jim@SynthWorks.com   
--
--  Package Defines
--      Resizing for transaction records
--    
--  Developed for: 
--        SynthWorks Design Inc. 
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    06/2021   2021.06    Refactored from ResolutionPkg
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2005 - 2021 by SynthWorks Design Inc.  
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


library ieee ; 
use ieee.std_logic_1164.all ; 
use ieee.numeric_std.all ; 

use work.AlertLogPkg.all ; 
use work.ResolutionPkg.all ; 

package ResizePkg is 
  --
  -- ToTransaction and FromTransaction
  -- Convert from Common types to their corresponding _max_c type
  --
  function Extend(A: std_logic_vector; Size : natural) return std_logic_vector ;
  function Reduce(A: std_logic_vector; Size : natural) return std_logic_vector ;

  impure function SafeResize(A : std_logic_vector; Size : natural) return std_logic_vector ;
  impure function SafeResize(A : std_logic_vector; Size : natural) return std_logic_vector_max_c ;
  impure function SafeResize(A : std_logic_vector_max_c; Size : natural) return std_logic_vector ;

  function        ToTransaction(A : std_logic_vector) return std_logic_vector_max_c ;
  impure function ToTransaction(A : std_logic_vector ; Size : natural) return std_logic_vector_max_c ;
  function        ToTransaction(A : integer; Size : natural) return std_logic_vector_max_c ;
  function        FromTransaction (A: std_logic_vector_max_c) return std_logic_vector ;
  impure function FromTransaction (A: std_logic_vector_max_c ; Size : natural) return std_logic_vector ;
  function        FromTransaction (A: std_logic_vector_max_c) return integer ;
  
  --
  -- ToTransaction and FromTransaction for _max provided to support a 
  -- common methodology, conversions are not needed
  function        ToTransaction(A : std_logic_vector) return std_logic_vector_max ;
  impure function ToTransaction(A : std_logic_vector ; Size : natural) return std_logic_vector_max ;
  function        ToTransaction(A : integer; Size : natural) return std_logic_vector_max ;
  function        FromTransaction (A: std_logic_vector_max) return std_logic_vector ;
  impure function FromTransaction (A: std_logic_vector_max ; Size : natural) return std_logic_vector ;
  function        FromTransaction (A: std_logic_vector_max) return integer ;    
  
end package ResizePkg ;
package body ResizePkg is 

  --
  -- ToTransaction and FromTransaction
  -- Convert from Common types to their corresponding _max_c type
  --
  function Extend(A: std_logic_vector; Size : natural) return std_logic_vector is
    variable extA : std_logic_vector(Size downto 1) := (others => '0') ;
  begin
    extA(A'length downto 1) := A ;
    return extA ;
  end function Extend ;

  function Reduce(A: std_logic_vector; Size : natural) return std_logic_vector is
    alias aA : std_logic_vector(A'length-1 downto 0) is A ;
  begin
    return aA(Size-1 downto 0) ;
  end function Reduce ;
  
  -- SafeResize - handles std_logic_vector as unsigned
  impure function LocalSafeResize(A : std_logic_vector; Size : natural) return std_logic_vector is
    variable Result : std_logic_vector(Size-1 downto 0) := (others => '0') ;
    alias aA : std_logic_vector(A'length-1 downto 0) is A ;
  begin
    if A'length <= Size then
      -- Extend A
      Result(A'length-1 downto 0) := aA ;
    else
      -- Reduce A and Error if any extra bits of A are a '1'
      AlertIf((OR aA(A'length-1 downto Size) = '1'), "ToTransaction/FromTransaction, threw away a 1") ;
      Result := aA(Size-1 downto 0) ;
    end if ;    
    return Result ;
  end function LocalSafeResize ;
 
  impure function SafeResize(A : std_logic_vector; Size : natural) return std_logic_vector is
  begin
    return LocalSafeResize(A, Size) ;
  end function SafeResize ;

 
  impure function SafeResize(A : std_logic_vector; Size : natural) return std_logic_vector_max_c is
  begin
    return std_logic_vector_max_c(LocalSafeResize(A, Size)) ;
  end function SafeResize ;

  impure function SafeResize(A : std_logic_vector_max_c; Size : natural) return std_logic_vector is
  begin
    return LocalSafeResize(std_logic_vector(A), Size) ;
  end function SafeResize ;


  function ToTransaction(A : std_logic_vector) return std_logic_vector_max_c is
  begin
    return std_logic_vector_max_c(A) ;
  end function ToTransaction ;

  impure function ToTransaction(A : std_logic_vector ; Size : natural) return std_logic_vector_max_c is
  begin
    return std_logic_vector_max_c(LocalSafeResize(A, Size)) ;
  end function ToTransaction ;

  function ToTransaction(A : integer; Size : natural) return std_logic_vector_max_c is
  begin
    return std_logic_vector_max_c(to_signed(A, Size)) ;
  end function ToTransaction ;

  function FromTransaction (A: std_logic_vector_max_c) return std_logic_vector is
  begin
    return std_logic_vector(A) ;
  end function FromTransaction ;

  impure function FromTransaction (A: std_logic_vector_max_c ; Size : natural) return std_logic_vector is
  begin
    return LocalSafeResize(std_logic_vector(A), Size) ;
  end function FromTransaction ;

  function FromTransaction (A: std_logic_vector_max_c) return integer is
  begin
    return to_integer(signed(A)) ;
  end function FromTransaction ;
  
  ----------------------
  -- Support for _max provided to support a common methodology, 
  -- conversions are not needed
  function ToTransaction(A : std_logic_vector) return std_logic_vector_max is
  begin
    return A ;
  end function ToTransaction ;

  impure function ToTransaction(A : std_logic_vector ; Size : natural) return std_logic_vector_max is
  begin
    return LocalSafeResize(A, Size) ;
  end function ToTransaction ;

  function ToTransaction(A : integer; Size : natural) return std_logic_vector_max is
  begin
    return std_logic_vector_max(to_signed(A, Size)) ;
  end function ToTransaction ;

  function FromTransaction (A: std_logic_vector_max) return std_logic_vector is
  begin
    return A ;
  end function FromTransaction ;

  impure function FromTransaction (A: std_logic_vector_max ; Size : natural) return std_logic_vector is
  begin
    return LocalSafeResize(A, Size) ;
  end function FromTransaction ;

  function FromTransaction (A: std_logic_vector_max) return integer is
  begin
    return to_integer(signed(A)) ;
  end function FromTransaction ;  
  
end package body ResizePkg ;
