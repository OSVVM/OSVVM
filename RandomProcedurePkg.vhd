--
--  File Name :         RandomProcedurePkg.vhd
--  Design Unit Name :  RandomProcedurePkg
--  Revision :          STANDARD VERSION
--
--  Maintainer :        Jim Lewis      email :  jim@synthworks.com
--  Contributor(s) :
--     Jim Lewis      email:  jim@synthworks.com
--     Lars Asplund   email:  lars.anders.asplund@gmail.com - RandBool, RandSl, RandBit, DistBool, DistSl, DistBit
--     *
--
--   * In writing procedures normal, poisson, the following sources were referenced :
--     Wikipedia
--     package rnd2 written by John Breen and Ken Christensen
--     package RNG written by Gnanasekaran Swaminathan
--
--
--  Description :
--    A minimal randomization package using procedures that
--    supports CoveragePkg.vhd.
--    Does not use protected types.   
--    Does not use VHDL-2019.     
--
--  Developed for :
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http ://www.SynthWorks.com
--
--  Revision History :
--    Date       Version    Description
--    05/2021    2021/05    Refactored from RandomPkg.vhd
--                          Needed minimal set of procedures to support randomization in CoveragePkg
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2006 - 2021 by SynthWorks Design Inc.  
--  Copyright (C) 2021 by OSVVM Authors   
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

use work.OsvvmGlobalPkg.all ; 
use work.AlertLogPkg.all ; 
use work.RandomBasePkg.all ;
use work.SortListPkg_int.all ;

use std.textio.all ;

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.numeric_std_unsigned.all ;
use ieee.math_real.all ;


package RandomProcedurePkg is
  ------------------------------------------------------------
  --
  -- Uniform
  -- Generate a random number with a Uniform distribution
  --
  ------------------------------------------------------------
  procedure Uniform (RandomSeed : inout RandomSeedType; R : out integer; Min, Max : integer) ;
  procedure Uniform (RandomSeed : inout RandomSeedType; R : out integer; Min, Max : integer ; Exclude : integer_vector) ;
  alias RandInt is Uniform [RandomSeedType, integer, integer, integer] ;
  alias RandInt is Uniform [RandomSeedType, integer, integer, integer, integer_vector] ;

  --- ///////////////////////////////////////////////////////////////////////////
  --
  --  Basic Discrete Distributions
  --    Always uses Uniform
  --
  --- ///////////////////////////////////////////////////////////////////////////
  -----------------------------------------------------------------
  procedure DistInt (RandomSeed : inout RandomSeedType; R : out integer; Weight : integer_vector) ;


end RandomProcedurePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body RandomProcedurePkg is
  ------------------------------------------------------------
  --
  -- Uniform
  -- Generate a random number with a Uniform distribution
  --
  ------------------------------------------------------------
  procedure Uniform (RandomSeed : inout RandomSeedType; R : out integer; Min, Max : integer) is
  ------------------------------------------------------------
    variable rRandomVal : real ;
  begin
-- Checks done in CoveragePkg
--    AlertIf (OSVVM_RANDOM_ALERTLOG_ID, Max < Min, "RandomPkg.Uniform: Max < Min", FAILURE) ;
    Uniform(rRandomVal, RandomSeed) ;
    R := scale(rRandomVal, Min, Max) ;
  end procedure Uniform ;

  ------------------------------------------------------------
  procedure Uniform (RandomSeed : inout RandomSeedType; R : out integer; Min, Max : integer ; Exclude : integer_vector) is
  ------------------------------------------------------------
    variable iRandomVal : integer ;
    variable ExcludeList : SortListPType ;
    variable count : integer ;
  begin
    ExcludeList.add(Exclude, Min, Max) ;
    count := ExcludeList.count ;
    Uniform(RandomSeed, iRandomVal, Min, Max - count) ;
    -- adjust count, note iRandomVal changes while checking.
    for i in 1 to count loop
      exit when iRandomVal < ExcludeList.Get(i) ;
      iRandomVal := iRandomVal + 1 ;
    end loop ;
    ExcludeList.erase ;
    R := iRandomVal ;
  end procedure Uniform ;


  --- ///////////////////////////////////////////////////////////////////////////
  --
  --  Basic Discrete Distributions
  --    Always uses Uniform
  --
  --- ///////////////////////////////////////////////////////////////////////////
  -----------------------------------------------------------------
  procedure DistInt (RandomSeed : inout RandomSeedType; R : out integer; Weight : integer_vector) is
  -----------------------------------------------------------------
    variable DistArray : integer_vector(weight'range) ;
    variable sum : integer ;
    variable iRandomVal : integer ;
  begin
    DistArray := Weight ;
    sum := 0 ;
    for i in DistArray'range loop
      DistArray(i) := DistArray(i) + sum ;
      if DistArray(i) < sum then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.DistInt: negative weight or sum > 31 bits", FAILURE) ;
        R := DistArray'low ; -- allows debugging vs integer'low, out of range
      end if ;
      sum := DistArray(i) ;
    end loop ;
    if sum >= 1 then
      Uniform(RandomSeed, iRandomVal, 1, sum) ;
      for i in DistArray'range loop
        if iRandomVal <= DistArray(i) then
          R := i ;
          return ; 
        end if ;
      end loop ;
      Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.DistInt: randomization failed", FAILURE) ;
    else
      Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.DistInt: No randomization weights", FAILURE) ;
    end if ;
    R := DistArray'low ; -- allows debugging vs integer'low, out of range
  end procedure DistInt ;

end RandomProcedurePkg ;
