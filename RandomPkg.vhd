--
--  File Name :         RandomPkg.vhd
--  Design Unit Name :  RandomPkg
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
--    RandomPType, a protected type, defined to hold randomization RandomSeeds and
--    function methods to facilitate randomization with uniform and weighted
--    distributions
--
--  Developed for :
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http ://www.SynthWorks.com
--
--  Revision History :
--    Date       Version    Description
--    11/2024    2024.11    Added Scalar Exclude values to most (except RandIntV without unique value) 
--    05/2024    2024.05    Update to address if max < min sometimes multiple errors were generated
--    03/2024    2024.03    Added RandInt that randomly selects a value in the entire integer range
--    09/2023    2023.09    Added control of UseNewSeedMethods from OsvvmSettingsPkg.RANDOM_USE_NEW_SEED_METHODS
--    06/2023    2023.06    Updated InitSeed for type time to do (T mod 2**30*std.env.resolution_limit)
--    06/2021    2021.06    Updated InitSeed, moved shared stuff to RandomBasePkg
--    08/2020    2020.08    RandBool, RandSl, RandBit, DistBool, DistSl, DistBit (from Lars)
--    01/2020    2020.01    Updated Licenses to Apache
--    11/2016    2016.11    No changes.  Updated release numbers to make documentation and
--                          package have consistent release identifiers.
--    5/2015     2015.06    Revised Alerts to Alert(OSVVM_ALERTLOG_ID, ...) ;
--    1/2015     2015.01    Changed Assert/Report to Alert
--    1/2014     2014.01    Added RandTime, RandReal(set), RandIntV, RandRealV, RandTimeV
--                          Made sort, revsort from SortListPkg_int visible via aliases
--    5/2013     2013.05    Big vector randomization added overloading RandUnsigned, RandSlv, and RandSigned
--                          Added NULL_RANGE_TYPE to minimize null range warnings
--    5/2013     -          Removed extra variable declaration in functions RandInt and RandReal
--    04/2013    2013.04    Changed DistInt.  Return array indices now match input
--                          Better Min, Max error handling in Uniform, FavorBig, FavorSmall, Normal, Poisson
--    06/2012    2.2        Removed '_' in the name of subprograms FavorBig and FavorSmall
--    07/2011    2.1        Bug fix to convenience functions for slv, unsigned, and signed.
--    03/2011    2.0        Major clean-up. Moved RandomParamType and control to here
--    06/2010    1.2        Added Normal and Poisson distributions
--    02/2009 :  1.0        First Public Released Version
--    02/25/2009 1.1        Replaced reference to std_2008 with a reference to
--                          ieee_proposed.standard_additions.all ;
--                          Numerous revisions for SynthWorks' Advanced VHDL Testbenches and Verification
--    12/2006 :  0.1        Initial revision
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
use work.OsvvmSettingsPkg.all ;
use work.OsvvmTypesPkg.all ;

use std.textio.all ;

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.numeric_std_unsigned.all ;
use ieee.math_real.all ;

-- comment out following 3 lines with VHDL-2008.  Leave in for VHDL-2002
-- library ieee_proposed ;						               -- remove with VHDL-2008
-- use ieee_proposed.standard_additions.all ;        -- remove with VHDL-2008
-- use ieee_proposed.standard_textio_additions.all ; -- remove with VHDL-2008


package RandomPkg is

  -- make things from SortListPkg_int visible
--  alias sort    is work.SortListPkg_int.sort   [integer_vector return integer_vector] ;
--  alias revsort is work.SortListPkg_int.revsort[integer_vector return integer_vector] ;

  -- Supports DistValInt functionality
  type DistRecType is record
    Value  : integer ;
    Weight : integer ;
  end record ;
  type DistType is array (natural range <>) of DistRecType ;

  -- Weight vectors not indexed by integers
  type NaturalVBoolType is array (boolean range <>) of natural;
  type NaturalVSlType   is array (std_logic range <>) of natural;
  type NaturalVBitType  is array (bit range <>) of natural;
  

  --- ///////////////////////////////////////////////////////////////////////////
  --- ///////////////////////////////////////////////////////////////////////////
  ---   
  ---  RandomPType
  ---   
  --- ///////////////////////////////////////////////////////////////////////////
  --- ///////////////////////////////////////////////////////////////////////////
  type RandomPType is protected
  
    --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Parameter Settings
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    --  Seed Manipulation
    ------------------------------------------------------------
    -- Known ambiguity between InitSeed with string and integer_vector
    -- Recommendation, use :  RV.InitSeed(RV'instance_path) ;
    -- For integer_vector use either : RV.InitSeed(IV => (1,5)) ;
    --   or : RV.InitSeed(integer_vector'(1,5)) ;
    -- Initialize Seeds
    procedure InitSeed         ( S : string ;  UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) ;
    procedure InitSeed         ( I : integer ; UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) ;
    procedure InitSeed         ( T : time ;    UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) ;
    procedure InitSeed         ( IV : integer_vector ; UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) ;
    -- Save and restore seed values
    procedure       SetSeed    (RandomSeedIn : RandomSeedType ) ;
    impure function GetSeed    return RandomSeedType ;
    procedure       SeedRandom (RandomSeedIn : RandomSeedType ) ;
    impure function SeedRandom return RandomSeedType ;
    -- alias SeedRandom is SetSeed [RandomSeedType] ;
    -- alias SeedRandom is GetSeed [return RandomSeedType] ;

    ------------------------------------------------------------
    --  Setting Randomization Parameters
    ------------------------------------------------------------
    procedure SetRandomParm (RandomParmIn : RandomParamType) ;
    procedure SetRandomParm (
      Distribution : RandomDistType ;
      Mean         : Real := 0.0 ;
      Deviation    : Real := 0.0
    ) ;
    impure function GetRandomParm return RandomParamType ;
    impure function GetRandomParm return RandomDistType ;
    -- For compatibility with previous version - replace with alias
    procedure SetRandomMode (RandomDistIn : RandomDistType) ;
    -- alias SetRandomMode is SetRandomParm [RandomDistType, Real, Real] ;

    --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Base Randomization Distributions
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    --
    -- Uniform
    -- Generate a random number with a Uniform distribution
    --
    ------------------------------------------------------------
    impure function Uniform (Min, Max : in real) return real ;
    impure function Uniform (Min, Max : integer) return integer ;
    impure function Uniform (Min, Max : integer ; Exclude : integer_vector) return integer ;

    ------------------------------------------------------------
    --
    -- FavorSmall
    --   Generate random numbers with a greater number of small
    --   values than large values
    --
    ------------------------------------------------------------
    impure function FavorSmall (Min, Max : real) return real ;
    impure function FavorSmall (Min, Max : integer) return integer ;
    impure function FavorSmall (Min, Max : integer ; Exclude : integer_vector) return integer ;

    ------------------------------------------------------------
    --
    -- FavorBig
    --   Generate random numbers with a greater number of large
    --   values than small values
    --
    ------------------------------------------------------------
    impure function FavorBig (Min, Max : real) return real ;
    impure function FavorBig (Min, Max : integer) return integer ;
    impure function FavorBig (Min, Max : integer ; Exclude : integer_vector) return integer ;

    -----------------------------------------------------------------
    --
    -- Normal
    --   Generate a random number with a normal distribution
    --   Uses Box Muller, per Wikipedia
    --
    ------------------------------------------------------------
    impure function Normal (Mean, StdDeviation : real) return real ;
    impure function Normal (Mean, StdDeviation, Min, Max : real) return real ;
    impure function Normal (
      Mean          : real ;
      StdDeviation  : real ;
      Min           : integer ;
      Max           : integer ;
      Exclude       : integer_vector := NULL_INTV
    ) return integer ;

    -----------------------------------------------------------------
    -- Poisson
    --   Generate a random number with a poisson distribution
    --   Discrete distribution = only generates integral values
    --   Uses knuth method, per Wikipedia
    --
    ------------------------------------------------------------
    impure function Poisson (Mean : real) return real ;
    impure function Poisson (Mean, Min, Max : real) return real ;
    impure function Poisson (
      Mean          : real ;
      Min           : integer ;
      Max           : integer ;
      Exclude       : integer_vector := NULL_INTV
    ) return integer ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomization with range.
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt      (Min, Max : integer) return integer ;
    impure function RandReal     (Min, Max : Real) return real ;
    impure function RandTime     (Min, Max : time ; Unit : time := ns) return time ;
    impure function RandSlv      (Min, Max, Size : natural) return std_logic_vector ;
    impure function RandUnsigned (Min, Max, Size : natural) return Unsigned ;
    impure function RandSigned   (Min, Max : integer ; Size   : natural) return Signed ;
    impure function RandIntV     (Min, Max : integer ; Size   : natural) return integer_vector ;
    impure function RandIntV     (Min, Max : integer ; Unique : natural ; Size : natural) return integer_vector ;
    impure function RandRealV    (Min, Max : real ;    Size   : natural) return real_vector ;
    impure function RandTimeV    (Min, Max : time ;    Size   : natural ; Unit : time := ns) return time_vector ;
    impure function RandTimeV    (Min, Max : time ;    Unique : natural ; Size : natural ; Unit : time := ns) return time_vector ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomization with range and exclude vector.
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt      (Min, Max : integer ; Exclude : integer_vector ) return integer ;
    impure function RandTime     (Min, Max : time ;    Exclude : time_vector ;    Unit   : time := ns) return time ;
    impure function RandSlv      (Min, Max : natural ; Exclude : integer_vector ; Size   : natural) return std_logic_vector ;
    impure function RandUnsigned (Min, Max : natural ; Exclude : integer_vector ; Size   : natural) return Unsigned ;
    impure function RandSigned   (Min, Max : integer ; Exclude : integer_vector ; Size   : natural) return Signed ;
    impure function RandIntV     (Min, Max : integer ; Exclude : integer_vector ; Size   : natural) return integer_vector ;
    impure function RandIntV     (Min, Max : integer ; Exclude : integer_vector ; Unique : natural ; Size : natural) return integer_vector ;
    impure function RandTimeV    (Min, Max : time ;    Exclude : time_vector ;    Size   : natural ; Unit : in time := ns) return time_vector ;
    impure function RandTimeV    (Min, Max : time ;    Exclude : time_vector ;    Unique : natural ; Size : natural ; Unit : in time := ns) return time_vector ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomly select a value within a set of values
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt      (A : integer_vector ) return integer ;
    impure function RandReal     (A : real_vector    ) return real ;
    impure function RandTime     (A : time_vector    ) return time ;
    impure function RandSlv      (A : integer_vector ; Size : natural) return std_logic_vector  ;
    impure function RandUnsigned (A : integer_vector ; Size : natural) return Unsigned ;
    impure function RandSigned   (A : integer_vector ; Size : natural) return Signed ;
    impure function RandIntV     (A : integer_vector ; Size : natural) return integer_vector ;
    impure function RandIntV     (A : integer_vector ; Unique : natural ; Size : natural) return integer_vector ;
    impure function RandRealV    (A : real_vector ;    Size   : natural) return real_vector ;
    impure function RandRealV    (A : real_vector ;    Unique : natural ; Size : natural) return real_vector ;
    impure function RandTimeV    (A : time_vector ;    Size   : natural) return time_vector ;
    impure function RandTimeV    (A : time_vector ;    Unique : natural ; Size : natural) return time_vector ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomly select a value within a set of values with exclude values (so can skip last or last n)
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt      (A, Exclude : integer_vector   ) return integer ;
    impure function RandReal     (A, Exclude : real_vector      ) return real ;
    impure function RandTime     (A, Exclude : time_vector      ) return time ;
    impure function RandSlv      (A, Exclude : integer_vector ; Size : natural) return std_logic_vector  ;
    impure function RandUnsigned (A, Exclude : integer_vector ; Size : natural) return Unsigned ;
    impure function RandSigned   (A, Exclude : integer_vector ; Size : natural ) return Signed ;
    impure function RandIntV     (A, Exclude : integer_vector ; Size : natural) return integer_vector ;
    impure function RandIntV     (A, Exclude : integer_vector ; Unique : natural ; Size : natural) return integer_vector ;
    impure function RandRealV    (A, Exclude : real_vector ;    Size : natural) return real_vector ;
    impure function RandRealV    (A, Exclude : real_vector ;    Unique : natural ; Size : natural) return real_vector ;
    impure function RandTimeV    (A, Exclude : time_vector ;    Size : natural) return time_vector ;
    impure function RandTimeV    (A, Exclude : time_vector ;    Unique : natural ; Size : natural) return time_vector ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Basic Discrete Distributions
    --    Randomly select between 0 and N-1 based on the specified weight.
    --    where N = number values in weight array
    --    Always uses Uniform
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistInt      (Weight : integer_vector   ) return integer ;
    impure function DistSlv      (Weight : integer_vector ; Size  : natural ) return std_logic_vector ;
    impure function DistUnsigned (Weight : integer_vector ; Size  : natural ) return unsigned ;
    impure function DistSigned   (Weight : integer_vector ; Size  : natural ) return signed ;
    impure function DistBool     (Weight : NaturalVBoolType ) return boolean ;
    impure function DistSl       (Weight : NaturalVSlType   ) return std_logic ;
    impure function DistBit      (Weight : NaturalVBitType  ) return bit ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Basic Distributions with exclude values (so can skip last or last n)
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistInt      (Weight : integer_vector ; Exclude : integer_vector ) return integer ;
    impure function DistSlv      (Weight : integer_vector ; Exclude : integer_vector ; Size  : natural ) return std_logic_vector ;
    impure function DistUnsigned (Weight : integer_vector ; Exclude : integer_vector ; Size  : natural ) return unsigned ;
    impure function DistSigned   (Weight : integer_vector ; Exclude : integer_vector ; Size  : natural ) return signed ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Distribution for sparse values
    --    Specify weight and value
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistValInt      (A : DistType ) return integer ;
    impure function DistValSlv      (A : DistType ; Size  : natural) return std_logic_vector ;
    impure function DistValUnsigned (A : DistType ; Size  : natural) return unsigned ;
    impure function DistValSigned   (A : DistType ; Size  : natural) return signed ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Distribution for sparse values with exclude values (so can skip last or last n)
    --    Specify weight and value
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistValInt      (A : DistType ; Exclude : integer_vector ) return integer ;
    impure function DistValSlv      (A : DistType ; Exclude : integer_vector ; Size  : natural) return std_logic_vector ;
    impure function DistValUnsigned (A : DistType ; Exclude : integer_vector ; Size  : natural) return unsigned ;
    impure function DistValSigned   (A : DistType ; Exclude : integer_vector ; Size  : natural) return signed ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    -- Large vector handling.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandUnsigned (Size : natural) return unsigned ;
    impure function RandSlv      (Size : natural) return std_logic_vector ;
    impure function RandSigned   (Size : natural) return signed ;
    impure function RandUnsigned (Max : Unsigned) return unsigned ;
    impure function RandSlv      (Max : std_logic_vector) return std_logic_vector ;
    impure function RandSigned   (Max : signed) return signed ;
    impure function RandUnsigned (Min, Max : unsigned) return unsigned ;
    impure function RandSlv      (Min, Max : std_logic_vector) return std_logic_vector ;
    impure function RandSigned   (Min, Max : signed) return signed ;
    
    --- ///////////////////////////////////////////////////////////////////////////
    --
    -- Large vector handling with Exclude
    --
    --- ///////////////////////////////////////////////////////////////////////////
    impure function RandUnsigned (Size : natural ; Exclude : uv_vector) return unsigned ;
--!!    impure function RandUnsigned (Size : natural ; Exclude : unsigned) return unsigned ;
    impure function RandSlv      (Size : natural ; Exclude : slv_vector) return std_logic_vector ;
--!!    impure function RandSlv      (Size : natural ; Exclude : std_logic_vector) return std_logic_vector ;
    impure function RandSigned   (Size : natural ; Exclude : sv_vector) return signed ;
--!!    impure function RandSigned   (Size : natural ; Exclude : signed) return signed ;

    impure function RandUnsigned ( Min, Max : unsigned ; Exclude : uv_vector)  return unsigned ;
--!!    impure function RandUnsigned ( Min, Max : unsigned ; Exclude : unsigned)  return unsigned ;
    impure function RandSlv ( Min, Max : std_logic_vector ; Exclude : slv_vector) return std_logic_vector ;
--!!    impure function RandSlv ( Min, Max : std_logic_vector ; Exclude : std_logic_vector) return std_logic_vector ;
    impure function RandSigned ( Min, Max : signed ; Exclude : sv_vector) return signed ;
--!!    impure function RandSigned ( Min, Max : signed ; Exclude : signed) return signed ;
    
    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Convenience Functions.  Resolve into calls into the other functions
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandReal     return real ; -- 0.0 to 1.0
    impure function RandReal     (Max : Real) return real ; -- 0.0 to Max
    impure function RandInt      return integer ;
    impure function RandInt      (Max : integer) return integer ;
    impure function RandSlv      (Max, Size : natural) return std_logic_vector ;
    impure function RandUnsigned (Max, Size : natural) return Unsigned ;
    impure function RandSigned   (Max : integer ; Size : natural ) return Signed ;
    impure function RandBool     return boolean;
    impure function RandSl       return std_logic;
    impure function RandBit      return bit;
    
    
    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Convenience Functions with Exclude as an scalar rather than a _vector
    --    Calls the version with _vector
    --
    --- ///////////////////////////////////////////////////////////////////////////
    --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Base Randomization Distributions
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    impure function Uniform    (Min, Max : integer ; Exclude : integer) return integer ;
    impure function FavorSmall (Min, Max : integer ; Exclude : integer) return integer ;
    impure function FavorBig   (Min, Max : integer ; Exclude : integer) return integer ;
    impure function Normal (Mean, StdDeviation : real; Min, Max, Exclude : integer) return integer ;
    impure function Poisson (Mean : real; Min, Max, Exclude : integer) return integer ;
  
    
    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomization with range and exclude
    --
    --- ///////////////////////////////////////////////////////////////////////////
    impure function RandInt      (Min, Max : integer ; Exclude : integer ) return integer ;
-- ambiguous if Unit has a default
--    impure function RandTime     (Min, Max : time ;    Exclude : time ;    Unit   : time := ns) return time ;
    impure function RandTime     (Min, Max : time ;    Exclude : time ;    Unit   : time) return time ;
    impure function RandSlv      (Min, Max : natural ; Exclude : integer ; Size   : natural) return std_logic_vector ;
    impure function RandUnsigned (Min, Max : natural ; Exclude : integer ; Size   : natural) return Unsigned ;
    impure function RandSigned   (Min, Max : integer ; Exclude : integer ; Size   : natural) return Signed ;
-- ambiguous with RandIntV(Min, Max, Unique, Size) return integer_vector ;
--    impure function RandIntV     (Min, Max : integer ; Exclude : integer ; Size   : natural) return integer_vector ;
    impure function RandIntV     (Min, Max : integer ; Exclude : integer ; Unique : natural ; Size : natural) return integer_vector ;
    impure function RandTimeV    (Min, Max : time ;    Exclude : time ;    Size   : natural ; Unit : in time := ns) return time_vector ;
    impure function RandTimeV    (Min, Max : time ;    Exclude : time ;    Unique : natural ; Size : natural ; Unit : in time := ns) return time_vector ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomly select a value within a set of values with exclude values (so can skip last or last n)
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt      (A : integer_vector ; Exclude : integer  ) return integer ;
    impure function RandReal     (A : real_vector    ; Exclude : real     ) return real ;
    impure function RandTime     (A : time_vector    ; Exclude : time     ) return time ;
    impure function RandSlv      (A : integer_vector ; Exclude : integer ; Size : natural) return std_logic_vector  ;
    impure function RandUnsigned (A : integer_vector ; Exclude : integer ; Size : natural) return Unsigned ;
    impure function RandSigned   (A : integer_vector ; Exclude : integer ; Size : natural ) return Signed ;
-- ambiguous with RandIntV(A, Unique, Size) return integer_vector ;
--    impure function RandIntV     (A : integer_vector ; Exclude : integer ; Size : natural) return integer_vector ;
    impure function RandIntV     (A : integer_vector ; Exclude : integer ; Unique : natural ; Size : natural) return integer_vector ;
    impure function RandRealV    (A : real_vector    ; Exclude : real    ; Size : natural) return real_vector ;
    impure function RandRealV    (A : real_vector    ; Exclude : real    ; Unique : natural ; Size : natural) return real_vector ;
    impure function RandTimeV    (A : time_vector    ; Exclude : time    ; Size : natural) return time_vector ;
    impure function RandTimeV    (A : time_vector    ; Exclude : time    ; Unique : natural ; Size : natural) return time_vector ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Basic Distributions with exclude values (so can skip last or last n)
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    impure function DistInt      (Weight : integer_vector ; Exclude : integer ) return integer ;
    impure function DistSlv      (Weight : integer_vector ; Exclude : integer ; Size  : natural ) return std_logic_vector ;
    impure function DistUnsigned (Weight : integer_vector ; Exclude : integer ; Size  : natural ) return unsigned ;
    impure function DistSigned   (Weight : integer_vector ; Exclude : integer ; Size  : natural ) return signed ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Distribution for sparse values with exclude values (so can skip last or last n)
    --    Specify weight and value
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistValInt      (A : DistType ; Exclude : integer ) return integer ;
    impure function DistValSlv      (A : DistType ; Exclude : integer ; Size  : natural) return std_logic_vector ;
    impure function DistValUnsigned (A : DistType ; Exclude : integer ; Size  : natural) return unsigned ;
    impure function DistValSigned   (A : DistType ; Exclude : integer ; Size  : natural) return signed ;
    
  end protected RandomPType ;

end RandomPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body RandomPkg is

  -----------------------------------------------------------------
  --  Local Randomization Support
  -----------------------------------------------------------------
  constant NULL_SLV : std_logic_vector (NULL_RANGE_TYPE) := (others => '0') ;
  constant NULL_UV  : unsigned (NULL_RANGE_TYPE) := (others => '0') ;
  constant NULL_SV  : signed   (NULL_RANGE_TYPE) := (others => '0') ;


  --- ///////////////////////////////////////////////////////////////////////////
  --- RandomPType Body
  --- ///////////////////////////////////////////////////////////////////////////
  type RandomPType is protected body
  
    variable RandomSeed : RandomSeedType := OldGenRandSeed(integer_vector'(1,7)) ;

    --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Base Call to Uniform.   Use this one rather than RandomBasePkg
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    -----------------------------------------------------------------
    impure function Uniform return real is 
    -----------------------------------------------------------------
      variable rRandom : real ; 
    begin
      ieee.math_real.Uniform (RandomSeed(RandomSeed'left), RandomSeed(RandomSeed'right), rRandom) ;
      return rRandom ; 
    end function Uniform ;

    --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Seed Manipulation
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    procedure InitSeed (S : string ; UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) is
    ------------------------------------------------------------
    begin
      if UseNewSeedMethods then
        RandomSeed := GenRandSeed(S) ;
      else
        RandomSeed := OldGenRandSeed(S) ;
      end if ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    procedure InitSeed (I : integer ; UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) is
    ------------------------------------------------------------
    begin
      if UseNewSeedMethods then
        RandomSeed := GenRandSeed(I) ;
      else
        RandomSeed := OldGenRandSeed(I) ;
      end if ;
    end procedure InitSeed ;
    
    ------------------------------------------------------------
    procedure InitSeed (T : time ; UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) is
    ------------------------------------------------------------
    begin
      RandomSeed := GenRandSeed(T) ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    procedure InitSeed (IV : integer_vector ; UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) is
    ------------------------------------------------------------
    begin
      if UseNewSeedMethods then
        RandomSeed := GenRandSeed(IV) ;
      else
        RandomSeed := OldGenRandSeed(IV) ;
      end if ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    procedure SetSeed (RandomSeedIn : RandomSeedType ) is
    ------------------------------------------------------------
    begin
      RandomSeed := RandomSeedIn ;
    end procedure SetSeed ;

    ------------------------------------------------------------
    procedure SeedRandom (RandomSeedIn : RandomSeedType ) is
    ------------------------------------------------------------
    begin
      RandomSeed := RandomSeedIn ;
    end procedure SeedRandom ;

    ------------------------------------------------------------
    impure function GetSeed return RandomSeedType is
    ------------------------------------------------------------
    begin
      return RandomSeed ;
    end function GetSeed ;

    ------------------------------------------------------------
    impure function SeedRandom return RandomSeedType is
    ------------------------------------------------------------
    begin
      return RandomSeed ;
    end function SeedRandom ;


    --- ///////////////////////////////////////////////////////////////////////////
    ---
    ---   Setting Randomization Parameters
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    variable RandomParm : RandomParamType ; -- left most values ok for init

    ------------------------------------------------------------
    procedure SetRandomParm (RandomParmIn : RandomParamType) is
    ------------------------------------------------------------
    begin
      RandomParm := RandomParmIn ;
    end procedure SetRandomParm ;

    ------------------------------------------------------------
    procedure SetRandomParm (
    ------------------------------------------------------------
      Distribution : RandomDistType ;
      Mean         : Real := 0.0 ;
      Deviation    : Real := 0.0
    ) is
    begin
      RandomParm := RandomParamType'(Distribution, Mean, Deviation) ;
    end procedure SetRandomParm ;


    ------------------------------------------------------------
    impure function GetRandomParm return RandomParamType is
    ------------------------------------------------------------
    begin
      return RandomParm ;
    end function GetRandomParm ;


    ------------------------------------------------------------
    impure function GetRandomParm return RandomDistType is
    ------------------------------------------------------------
    begin
      return RandomParm.Distribution ;
    end function GetRandomParm ;


    ------------------------------------------------------------
    -- Deprecated.  For compatibility with previous version
    procedure SetRandomMode (RandomDistIn : RandomDistType) is
    ------------------------------------------------------------
    begin
      SetRandomParm(RandomDistIn) ;
    end procedure SetRandomMode ;

    --- ///////////////////////////////////////////////////////////////////////////
    ---
    ---  Check ranges for Randomization and Generate FAILURE
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    -- PT Local
    impure function CheckMinMax(
    ------------------------------------------------------------
      constant Name  : in string ;
      constant Min   : in real ;
      constant Max   : in real
    ) return real is
    begin
      if Min > Max then
        Alert(OSVVM_RANDOM_ALERTLOG_ID,
          "RandomPkg." & Name &
               ": Min: " & to_string(Min, 2) &
               " >  Max: " & to_string(Max, 2),
          FAILURE ) ;
        return Min ;
      else
        return Max ;
      end if;
    end function CheckMinMax ;

    ------------------------------------------------------------
    -- PT Local
    impure function CheckMinMax(
    ------------------------------------------------------------
      constant Name  : in string ;
      constant Min   : in integer ;
      constant Max   : in integer
    ) return integer is
    begin
      if Min > Max then
        Alert(OSVVM_RANDOM_ALERTLOG_ID,
          "RandomPkg." & Name &
               ": Min: " & to_string(Min) &
               " >  Max: " & to_string(Max),
          FAILURE ) ;
        return Min ;
      else
        return Max ;
      end if;
    end function CheckMinMax ;

    ------------------------------------------------------------
    -- PT Local
    impure function CheckMinMax(
    ------------------------------------------------------------
      constant Name  : in string ;
      constant Min   : in time ;
      constant Max   : in time
    ) return time is
    begin
      if Min > Max then
        Alert(OSVVM_RANDOM_ALERTLOG_ID,
          "RandomPkg." & Name &
               ": Min: " & to_string(Min, ns) &
               " >  Max: " & to_string(Max, ns),
          FAILURE ) ;
        return Min ;
      else
        return Max ;
      end if;
    end function CheckMinMax ;
    
    --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Base Randomization Distributions
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    --
    -- Uniform
    -- Generate a random number with a Uniform distribution
    --
    ------------------------------------------------------------
    impure function LocalUniform (Min, Max : in real) return real is
    ------------------------------------------------------------
    begin
      return scale(Uniform, Min, Max) ;
    end function LocalUniform ;

    ------------------------------------------------------------
    impure function Uniform (Min, Max : in real) return real is
    ------------------------------------------------------------
      constant CkMax      : real := CheckMinMax("Uniform", Min, Max) ;
    begin
      return LocalUniform(Min, CkMax) ;
    end function Uniform ;

    ------------------------------------------------------------
    impure function LocalUniform (Min, Max : integer) return integer is
    ------------------------------------------------------------
    begin
      return scale(Uniform, Min, Max) ;
    end function LocalUniform ;

    ------------------------------------------------------------
    impure function Uniform (Min, Max : integer) return integer is
    ------------------------------------------------------------
      constant CkMax      : integer := CheckMinMax("Uniform", Min, Max) ;
    begin
      return LocalUniform(Min, CkMax) ;
    end function Uniform ;

    ------------------------------------------------------------
    impure function LocalUniform (Min, Max : integer ; Exclude : integer_vector) return integer is
    ------------------------------------------------------------
      variable iRandomVal  : integer ;
      variable ExcludeList : SortListPType ;
      variable count       : integer ;
    begin
      ExcludeList.add(Exclude, Min, Max) ;
      count := ExcludeList.count ;
      iRandomVal := Uniform(Min, Max - count) ;
      -- adjust count, note iRandomVal changes while checking.
      for i in 1 to count loop
        exit when iRandomVal < ExcludeList.Get(i) ;
        iRandomVal := iRandomVal + 1 ;
      end loop ;
      ExcludeList.erase ;
      return iRandomVal ;
    end function LocalUniform ;

    ------------------------------------------------------------
    impure function Uniform (Min, Max : integer ; Exclude : integer_vector) return integer is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("Uniform", Min, Max) ;
    begin
      return LocalUniform (Min, CkMax, Exclude) ;
    end function Uniform ;


    ------------------------------------------------------------
    --
    -- FavorSmall
    --   Generate random numbers with a greater number of small
    --   values than large values
    --
    ------------------------------------------------------------
    impure function FavorSmall (Min, Max : real) return real is
    ------------------------------------------------------------
      constant CkMax      : real := CheckMinMax("FavorSmall", Min, Max) ;
    begin
      return scale(FavorSmall(Uniform), Min, CkMax) ; -- real
    end function FavorSmall ;

    ------------------------------------------------------------
    impure function FavorSmall (Min, Max : integer) return integer is
    ------------------------------------------------------------
      constant CkMax      : integer := CheckMinMax("FavorSmall", Min, Max) ;
    begin
      return scale(FavorSmall(Uniform), Min, CkMax) ; -- integer
    end function FavorSmall ;

    ------------------------------------------------------------
    impure function FavorSmall (Min, Max : integer ; Exclude : integer_vector) return integer is
    ------------------------------------------------------------
      variable iRandomVal  : integer ;
      variable ExcludeList : SortListPType ;
      variable count       : integer ;
      constant CkMax       : integer := CheckMinMax("FavorSmall", Min, Max) ;
    begin
      ExcludeList.add(Exclude, Min, CkMax) ;
      count := ExcludeList.count ;
      iRandomVal := FavorSmall(Min, CkMax - count) ;
      -- adjust count, note iRandomVal changes while checking.
      for i in 1 to count loop
        exit when iRandomVal < ExcludeList.Get(i) ;
        iRandomVal := iRandomVal + 1 ;
      end loop ;
      ExcludeList.erase ;
      return iRandomVal ;
    end function FavorSmall ;


    ------------------------------------------------------------
    --
    -- FavorBig
    --   Generate random numbers with a greater number of large
    --   values than small values
    --
    ------------------------------------------------------------
    impure function FavorBig (Min, Max : real) return real is
    ------------------------------------------------------------
      constant CkMax      : real := CheckMinMax("FavorBig", Min, Max) ;
    begin
      return scale(FavorBig(Uniform), Min, CkMax) ; -- real
    end function FavorBig ;

    ------------------------------------------------------------
    impure function FavorBig (Min, Max : integer) return integer is
    ------------------------------------------------------------
      constant CkMax      : integer := CheckMinMax("FavorBig", Min, Max) ;
    begin
      return scale(FavorBig(Uniform), Min, CkMax) ; -- integer
    end function FavorBig ;

    ------------------------------------------------------------
    impure function FavorBig (Min, Max : integer ; Exclude : integer_vector) return integer is
    ------------------------------------------------------------
      variable iRandomVal  : integer ;
      variable ExcludeList : SortListPType ;
      variable count       : integer ;
      constant CkMax       : integer := CheckMinMax("FavorBig", Min, Max) ;
    begin
      ExcludeList.add(Exclude, Min, CkMax) ;
      count := ExcludeList.count ;
      iRandomVal := FavorBig(Min, CkMax - count) ;
      -- adjust count, note iRandomVal changes while checking.
      for i in 1 to count loop
        exit when iRandomVal < ExcludeList.Get(i) ;
        iRandomVal := iRandomVal + 1 ;
      end loop ;
      ExcludeList.erase ;
      return iRandomVal ;
    end function FavorBig ;


    -----------------------------------------------------------------
    --
    --  Normal
    --    Generate a random number with a normal distribution
    --
    --  Use Box Muller, per Wikipedia :
    --     http ://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
    --
    ------------------------------------------------------------
    impure function Normal (Mean, StdDeviation : real) return real is
    ------------------------------------------------------------
      variable x01, y01 : real ;
      variable StdNormalDist : real ; -- mean 0, variance 1
    begin
      -- add this check to set parameters?
      if StdDeviation < 0.0 then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.Normal: Standard deviation must be >= 0.0", FAILURE) ;
        return -1.0 ;
      end if ;

      -- Box Muller
--      Uniform (x01, RandomSeed) ;
--      Uniform (y01, RandomSeed) ;
      x01 := Uniform ;
      y01 := Uniform ;
      StdNormalDist := sqrt(-2.0 * log(x01)) * cos(math_2_pi*y01) ;

      -- Polar form rejected due to mean 50.0, std deviation = 5 resulted
      -- in a median of 49
      -- -- find two Uniform distributed values with range -1 to 1
      -- -- that satisify S = X **2 + Y**2 < 1.0
      -- loop
        -- Uniform (x01, RandomSeed) ;
        -- Uniform (y01, RandomSeed) ;
        -- x := 2.0 * x01 - 1.0 ; -- scale to -1 to 1
        -- y := 2.0 * y01 - 1.0 ;
        -- s := x*x + y*y ;
        -- exit when s < 1.0 and s > 0.0 ;
      -- end loop ;

      -- -- Calculate Standard Normal Distribution
      -- StdNormalDist := x * sqrt((-2.0 * log(s)) / s) ;

      -- Convert to have Mean and StdDeviation
      return StdDeviation * StdNormalDist + Mean ;
    end function Normal ;

    ------------------------------------------------------------
    -- Normal + RandomVal >= Min and RandomVal <= Max
    impure function Normal (Mean, StdDeviation, Min, Max : real) return real is
    ------------------------------------------------------------
      variable rRandomVal : real ;
    begin
      if Max < Min then
         Alert(OSVVM_RANDOM_ALERTLOG_ID, 
           "RandomPkg.Normal: Min: " & to_string(Min, 2) &
               " >  Max: " & to_string(Max, 2),  
           FAILURE) ;
         return Mean ; 
      else
        loop
          rRandomVal := Normal (Mean, StdDeviation) ;
          exit when rRandomVal >= Min and rRandomVal <= Max ;
        end loop ;
      end if ;
      return rRandomVal ;
    end function Normal ;

    ------------------------------------------------------------
    -- Normal + RandomVal >= Min and RandomVal <= Max
    impure function Normal (
    ------------------------------------------------------------
      Mean          : real ;
      StdDeviation  : real ;
      Min           : integer ;
      Max           : integer ;
      Exclude       : integer_vector := NULL_INTV
    ) return integer is
      variable iRandomVal : integer ;
    begin
      if Max < Min then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, 
          "RandomPkg.Normal: Min: " & to_string(Min) &
             " >  Max: " & to_string(Max),  
          FAILURE) ;
        return integer(round(Mean)) ;
      else
        loop
          iRandomVal := integer(round(  Normal(Mean, StdDeviation)  )) ;
          exit when iRandomVal >= Min and iRandomVal <= Max and
                     not inside(iRandomVal, Exclude) ;
        end loop ;
      end if ;
      return iRandomVal ;
    end function Normal ;


    -----------------------------------------------------------------
    -- Poisson
    --   Generate a random number with a poisson distribution
    --   Discrete distribution = only generates integral values
    --
    -- Use knuth method, per Wikipedia :
    --   http ://en.wikipedia.org/wiki/Poisson_distribution
    --
    ------------------------------------------------------------
    impure function Poisson (Mean : real) return real is
    ------------------------------------------------------------
      variable Product      : Real := 1.0 ;
      variable Bound        : Real := 0.0 ;
      variable UniformRand  : Real := 0.0 ;
      variable PoissonRand  : Real := 0.0 ;
    begin
      Bound := exp(-1.0 * Mean) ;
      Product := 1.0 ;

      -- add this check to set parameters?
      if Mean <= 0.0 or Bound <= 0.0 then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.Poisson: Mean < 0 or too large.  Mean = " & real'image(Mean), FAILURE) ;
        return Mean ;
      end if ;

      while (Product >= Bound) loop
        PoissonRand := PoissonRand + 1.0 ;
        UniformRand := Uniform ;
        Product := Product * UniformRand ;
      end loop ;
      return PoissonRand ;
    end function  Poisson ; -- no range

    ------------------------------------------------------------
    -- Poisson + RandomVal >= Min and RandomVal < Max
    impure function Poisson (Mean, Min, Max : real) return real is
    ------------------------------------------------------------
      variable rRandomVal : real ;
    begin
      if Max < Min then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, 
           "RandomPkg.Poisson: Min: " & to_string(Min, 2) &
               " >  Max: " & to_string(Max, 2),  
           FAILURE) ;        
        return Mean ; 
      else
        loop
          rRandomVal := Poisson (Mean) ;
          exit when rRandomVal >= Min and rRandomVal <= Max ;
        end loop ;
      end if ;
      return rRandomVal ;
    end function  Poisson ;

    ------------------------------------------------------------
    impure function Poisson (
    ------------------------------------------------------------
      Mean          : real ;
      Min           : integer ;
      Max           : integer ;
      Exclude       : integer_vector := NULL_INTV
    ) return integer is
      variable iRandomVal : integer ;
    begin
      if Max < Min then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, 
           "RandomPkg.Poisson: Min: " & to_string(Min) &
               " >  Max: " & to_string(Max),  
           FAILURE) ;        
        return integer(round(Mean)) ; 
      else
        loop
          iRandomVal := integer(round(  Poisson (Mean)  )) ;
          exit when iRandomVal >= Min and iRandomVal <= Max and
                     not inside(iRandomVal, Exclude) ;
        end loop ;
      end if ;
      return iRandomVal ;
    end function  Poisson ;
    

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomization with range.
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function LocalRandInt (Min, Max : integer) return integer is
    ------------------------------------------------------------
    begin
      case RandomParm.Distribution is
        when UNIFORM      =>    return LocalUniform(Min, Max) ;
        when FAVOR_SMALL  =>    return FavorSmall(Min, Max) ;
        when FAVOR_BIG    =>    return FavorBig (Min, Max) ;
        when NORMAL       =>    return Normal(RandomParm.Mean, RandomParm.StdDeviation, Min, Max) ;
        when POISSON      =>    return Poisson(RandomParm.Mean, Min, Max) ;
        when others  =>
          Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandInt: RandomParm.Distribution not implemented", FAILURE) ;
          return integer'low ;
      end case ;
    end function LocalRandInt ;
    
    ------------------------------------------------------------
    impure function RandInt (Min, Max : integer) return integer is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandInt", Min, Max) ;
    begin
      return LocalRandInt(Min, CkMax) ;
    end function RandInt ;

    ------------------------------------------------------------
    impure function RandSlv (Min, Max, Size : natural) return std_logic_vector is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandSlv", Min, Max) ;
    begin
      return std_logic_vector(to_unsigned(LocalRandInt(Min, CkMax), Size)) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandUnsigned (Min, Max, Size : natural) return Unsigned is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandUnsigned", Min, Max) ;
    begin
      return to_unsigned(LocalRandInt(Min, CkMax), Size) ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSigned (Min, Max : integer ; Size : natural ) return Signed is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandSigned", Min, Max) ;
    begin
      return to_signed(LocalRandInt(Min, CkMax), Size) ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandIntV (Min, Max : integer ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
      constant CkMax  : integer := CheckMinMax("RandIntV", Min, Max) ;
    begin
      for i in result'range loop
        result(i) := LocalRandInt(Min, CkMax) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandIntV (Min, Max : integer ; Unique : natural ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
      variable iUnique : natural ; 
    begin
      -- if Unique = 0, it is more efficient to call RandIntV(Min, Max, Size)
      iUnique := Unique ; 
      if Max-Min+1 < Unique then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.(RandIntV | RandRealV | RandTimeV): Unique > number of values available", FAILURE) ;
        iUnique := Max-Min+1 ; 
      end if ; 
      for i in result'range loop
        result(i) := RandInt(Min, Max, result(maximum(1, 1 + i - iUnique) to Size)) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function LocalRandReal(Min, Max : Real) return real is
    ------------------------------------------------------------
    begin
      case RandomParm.Distribution is
        when UNIFORM      =>    return  LocalUniform(Min, Max) ;
        when FAVOR_SMALL  =>    return  FavorSmall(Min, Max) ;
        when FAVOR_BIG    =>    return  FavorBig (Min, Max) ;
        when NORMAL       =>    return  Normal(RandomParm.Mean, RandomParm.StdDeviation, Min, Max) ;
        when POISSON      =>    return  Poisson(RandomParm.Mean, Min, Max) ;
        when others  =>
          Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandReal: Specified RandomParm.Distribution not implemented", FAILURE) ;
          return real(integer'low) ;
      end case ;
    end function LocalRandReal ;

    ------------------------------------------------------------
    impure function RandReal(Min, Max : Real) return real is
    ------------------------------------------------------------
      constant CkMax : real := CheckMinMax("RandReal", Min, Max) ;
    begin
      return LocalRandReal(Min, CkMax) ; 
    end function RandReal ;

    ------------------------------------------------------------
    impure function RandRealV (Min, Max : real ; Size : natural) return real_vector is
    ------------------------------------------------------------
      variable result : real_vector(1 to Size) ;
      constant CkMax  : real := CheckMinMax("RandRealV", Min, Max) ;
    begin
      for i in result'range loop
        result(i) := LocalRandReal(Min, CkMax) ;
      end loop ;
      return result ;
    end function RandRealV ;

    ------------------------------------------------------------
    impure function LocalRandTime (Min, Max : time ; Unit :time := ns) return time is
    ------------------------------------------------------------
      variable IntVal : integer ;
    begin
      --  if Max - Min > 2**31 result will be out of range
      IntVal := LocalRandInt(0, (Max - Min)/Unit) ;
      return Min + Unit*IntVal ;
    end function LocalRandTime ;

    ------------------------------------------------------------
    impure function RandTime (Min, Max : time ; Unit :time := ns) return time is
    ------------------------------------------------------------
      constant CkMax  : time := CheckMinMax("RandTime", Min, Max) ;
    begin
      return LocalRandTime (Min, CkMax, Unit) ;
    end function RandTime ;

    ------------------------------------------------------------
    impure function RandTimeV (Min, Max : time ; Size : natural ; Unit : time := ns) return time_vector is
    ------------------------------------------------------------
      variable result : time_vector(1 to Size) ;
      constant CkMax  : time := CheckMinMax("RandTimeV", Min, Max) ;
    begin
      for i in result'range loop
        result(i) := LocalRandTime(Min, CkMax, Unit) ;
      end loop ;
      return result ;
    end function RandTimeV ;
    
    ------------------------------------------------------------
    impure function RandTimeV (Min, Max : time ; Unique : natural ; Size : natural ; Unit : time := ns) return time_vector is
    ------------------------------------------------------------
      constant CkMax  : time := CheckMinMax("RandTimeV", Min, Max) ;
    begin
      -- if Unique = 0, it is more efficient to call RandTimeV(Min, Max, Size)
      return to_time_vector(RandIntV(Min/Unit, CkMax/Unit, Unique, Size), Unit) ; 
    end function RandTimeV ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomization with range and exclude vector.
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function LocalRandInt (Min, Max : integer ; Exclude : integer_vector ) return integer is
    ------------------------------------------------------------
    begin
      case RandomParm.Distribution is
        when UNIFORM      =>    return  LocalUniform(Min, Max, Exclude) ;
        when FAVOR_SMALL  =>    return  FavorSmall(Min, Max, Exclude) ;
        when FAVOR_BIG    =>    return  FavorBig (Min, Max, Exclude) ;
        when NORMAL       =>    return  Normal(RandomParm.Mean, RandomParm.StdDeviation, Min, Max, Exclude) ;
        when POISSON      =>    return  Poisson(RandomParm.Mean, Min, Max, Exclude) ;
        when others =>
          Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandInt: Specified RandomParm.Distribution not implemented", FAILURE) ;
          return integer'low ;
      end case ;
    end function LocalRandInt ;

    ------------------------------------------------------------
    impure function RandInt (Min, Max : integer ; Exclude : integer_vector ) return integer is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandInt", Min, Max) ;
    begin
      return  LocalRandInt(Min, CkMax, Exclude) ;
    end function RandInt ;

    ------------------------------------------------------------
    impure function RandSlv (Min, Max : natural ; Exclude : integer_vector ; Size  : natural ) return std_logic_vector is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandSlv", Min, Max) ;
    begin
      return std_logic_vector(to_unsigned(RandInt(Min, CkMax, Exclude), Size)) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandUnsigned (Min, Max : natural ; Exclude : integer_vector ; Size  : natural ) return Unsigned is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandUnsigned", Min, Max) ;
    begin
      return to_unsigned(RandInt(Min, CkMax, Exclude), Size) ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSigned (Min, Max : integer ; Exclude : integer_vector ; Size  : natural ) return Signed is
    ------------------------------------------------------------
      constant CkMax : integer := CheckMinMax("RandSigned", Min, Max) ;
    begin
      return to_signed(RandInt(Min, CkMax, Exclude), Size) ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandIntV (Min, Max : integer ; Exclude : integer_vector ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
      constant CkMax  : integer := CheckMinMax("RandIntV", Min, Max) ;
    begin
      for i in result'range loop
        result(i) := RandInt(Min, CkMax, Exclude) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandIntV (Min, Max : integer ; Exclude : integer_vector ; Unique : natural ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable ResultPlus : integer_vector(1 to Size + Exclude'length) ;
      constant CkMax  : integer := CheckMinMax("RandIntV", Min, Max) ;
    begin
      -- if Unique = 0, it is more efficient to call RandIntV(Min, Max, Size)
      ResultPlus(Size+1 to ResultPlus'right) := Exclude ;
      for i in 1 to Size loop
        ResultPlus(i) := RandInt(Min, CkMax, ResultPlus(maximum(1, 1 + i - Unique) to ResultPlus'right)) ;
      end loop ;
      return ResultPlus(1 to Size) ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandTime (Min, Max : time ; Exclude : time_vector ; Unit : time := ns) return time is
    ------------------------------------------------------------
      constant CkMax  : time := CheckMinMax("RandTime", Min, Max) ;
    begin
      --  if Min or Max > 2**31 value will be out of range
      return RandInt(Min/Unit, CkMax/Unit, to_integer_vector(Exclude, Unit)) * Unit ;
    end function RandTime ;

    ------------------------------------------------------------
    impure function RandTimeV (Min, Max : time ; Exclude : time_vector ; Size : natural ; Unit : in time := ns) return time_vector is
    ------------------------------------------------------------
      constant CkMax  : time := CheckMinMax("RandTimeV", Min, Max) ;
    begin
      return to_time_vector( RandIntV(Min/Unit, CkMax/Unit, to_integer_vector(Exclude, Unit), Size), Unit ) ; 
    end function RandTimeV ;

    ------------------------------------------------------------
    impure function RandTimeV (Min, Max : time ; Exclude : time_vector ; Unique : natural ; Size : natural ; Unit : in time := ns) return time_vector is
    ------------------------------------------------------------
      constant CkMax  : time := CheckMinMax("RandTimeV", Min, Max) ;
    begin
      -- if Unique = 0, it is more efficient to call RandIntV(Min, Max, Size)
      return to_time_vector( RandIntV(Min/Unit, CkMax/Unit, to_integer_vector(Exclude, Unit), Unique, Size), Unit ) ; 
    end function RandTimeV ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomly select a value within a set of values
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt ( A : integer_vector ) return integer is
     ------------------------------------------------------------
     alias A_norm : integer_vector(1 to A'length) is A ;
    begin
      return A_norm( RandInt(1, A'length) ) ;
    end function RandInt ;

    ------------------------------------------------------------
    impure function RandReal ( A : real_vector ) return real is
    ------------------------------------------------------------
      alias A_norm : real_vector(1 to A'length) is A ;
    begin
      return A_norm( RandInt(1, A'length) ) ;
    end function RandReal ;

    ------------------------------------------------------------
    impure function RandTime ( A : time_vector ) return time is
    ------------------------------------------------------------
      alias A_norm : time_vector(1 to A'length) is A ;
    begin
      return A_norm( RandInt(1, A'length) ) ;
    end function RandTime ;

    ------------------------------------------------------------
    impure function RandSlv (A : integer_vector ; Size : natural) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(RandInt(A), Size)) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandUnsigned (A : integer_vector ; Size : natural) return Unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(RandInt(A), Size) ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSigned (A : integer_vector ; Size : natural ) return Signed is
    ------------------------------------------------------------
    begin
      return to_signed(RandInt(A), Size) ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandIntV (A : integer_vector ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
    begin
      for i in result'range loop
        result(i) := RandInt(A) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandIntV (A : integer_vector ; Unique : natural ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
      variable iUnique : natural ; 
    begin
      -- if Unique = 0, it is more efficient to call RandIntV(A, Size)
      -- require A'length >= Unique
      iUnique := Unique ; 
      if A'length < Unique then
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandIntV: Unique > length of set of values", FAILURE) ;
        iUnique := A'length ; 
      end if ; 
      for i in result'range loop
        result(i) := RandInt(A, result(maximum(1, 1 + i - iUnique) to Size)) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandRealV (A : real_vector ; Size : natural) return real_vector is
    ------------------------------------------------------------
      variable result : real_vector(1 to Size) ;
    begin
      for i in result'range loop
        result(i) := RandReal(A) ;
      end loop ;
      return result ;
    end function RandRealV ;

    ------------------------------------------------------------
    impure function RandRealV (A : real_vector ; Unique : natural ; Size : natural) return real_vector is
    ------------------------------------------------------------
      alias A_norm : real_vector(1 to A'length) is A ;
      variable result : real_vector(1 to Size) ;
      variable IntResult : integer_vector(result'range) ;
    begin
      -- randomly generate indices
      IntResult := RandIntV(1, A'length, Unique, Size) ;
      -- translate indicies into result values
      for i in result'range loop
        result(i) := A_norm(IntResult(i)) ;
      end loop ;
      return result ;
    end function RandRealV ;

    ------------------------------------------------------------
    impure function RandTimeV (A : time_vector ; Size : natural) return time_vector is
    ------------------------------------------------------------
      variable result : time_vector(1 to Size) ;
    begin
      for i in result'range loop
        result(i) := RandTime(A) ;
      end loop ;
      return result ;
    end function RandTimeV ;

    ------------------------------------------------------------
    impure function RandTimeV (A : time_vector ; Unique : natural ; Size : natural) return time_vector is
    ------------------------------------------------------------
      alias A_norm : time_vector(1 to A'length) is A ;
      variable result : time_vector(1 to Size) ;
      variable IntResult : integer_vector(result'range) ;
    begin
      -- randomly generate indices
      IntResult := RandIntV(1, A'length, Unique, Size) ;
      -- translate indicies into result values
      for i in result'range loop
        result(i) := A_norm(IntResult(i)) ;
      end loop ;
      return result ;
    end function RandTimeV ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomly select a value within a set of values with exclude values (so can skip last or last n)
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt ( A, Exclude : integer_vector ) return integer is
    ------------------------------------------------------------
      variable NewA : integer_vector(1 to A'length) ;
      variable NewALength : natural ;
    begin
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Randomize Index
      return NewA(RandInt(1, NewALength)) ;
    end function RandInt ;

    ------------------------------------------------------------
    impure function RandReal ( A, Exclude : real_vector ) return real is
    ------------------------------------------------------------
      variable NewA : real_vector(1 to A'length) ;
      variable NewALength : natural ;
    begin
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Randomize Index
      return NewA(RandInt(1, NewALength)) ;
    end function RandReal ;

    ------------------------------------------------------------
    impure function RandTime ( A, Exclude : time_vector ) return time is
    ------------------------------------------------------------
      variable NewA : time_vector(1 to A'length) ;
      variable NewALength : natural ;
    begin
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Randomize Index
      return NewA(RandInt(1, NewALength)) ;
    end function RandTime ;

    ------------------------------------------------------------
    impure function RandSlv (A, Exclude : integer_vector ; Size : natural) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(RandInt(A, Exclude), Size)) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandUnsigned (A, Exclude : integer_vector ; Size : natural) return Unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(RandInt(A, Exclude), Size) ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSigned (A, Exclude : integer_vector ; Size : natural ) return Signed is
    ------------------------------------------------------------
    begin
      return to_signed(RandInt(A, Exclude), Size) ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandIntV (A, Exclude : integer_vector ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
      variable NewA  : integer_vector(1 to A'length) ;
      variable NewALength : natural ;
    begin
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Randomize Index
      for i in result'range loop
        result(i) := NewA(RandInt(1, NewALength)) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandIntV (A, Exclude : integer_vector ; Unique : natural ; Size : natural) return integer_vector is
    ------------------------------------------------------------
      variable result : integer_vector(1 to Size) ;
      variable NewA  : integer_vector(1 to A'length) ;
      variable NewALength, iUnique : natural ;
    begin
      -- if Unique = 0, it is more efficient to call RandIntV(Min, Max, Size)
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Require NewALength >= Unique
      iUnique := Unique ; 
      if NewALength < Unique then 
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandIntV: Unique > Length of Set A - Exclude", FAILURE) ;
        iUnique := NewALength ; 
      end if ; 
      -- Randomize using exclude list of Unique # of newly generated values
      for i in result'range loop
        result(i) := RandInt(NewA(1 to NewALength), result(maximum(1, 1 + i - iUnique) to Size)) ;
      end loop ;
      return result ;
    end function RandIntV ;

    ------------------------------------------------------------
    impure function RandRealV (A, Exclude : real_vector ; Size : natural) return real_vector is
    ------------------------------------------------------------
      variable result : real_vector(1 to Size) ;
      variable NewA  : real_vector(1 to A'length) ;
      variable NewALength : natural ;
    begin
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Randomize Index
      for i in result'range loop
        result(i) := NewA(RandInt(1, NewALength)) ;
      end loop ;
      return result ;
    end function RandRealV ;

    ------------------------------------------------------------
    impure function RandRealV (A, Exclude : real_vector ; Unique : natural ; Size : natural) return real_vector is
    ------------------------------------------------------------
      variable result : real_vector(1 to Size) ;
      variable NewA  : real_vector(1 to A'length) ;
      variable NewALength, iUnique : natural ;
    begin
      -- if Unique = 0, it is more efficient to call RandRealV(Min, Max, Size)
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Require NewALength >= Unique
      iUnique := Unique ; 
      if NewALength < Unique then 
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandRealV: Unique > Length of Set A - Exclude", FAILURE) ;
        iUnique := NewALength ; 
      end if ; 
      -- Randomize using exclude list of Unique # of newly generated values
      for i in result'range loop
        result(i) := RandReal(NewA(1 to NewALength), result(maximum(1, 1 + i - iUnique) to Size)) ;
      end loop ;
      return result ;
    end function RandRealV ;

    ------------------------------------------------------------
    impure function RandTimeV (A, Exclude : time_vector ; Size : natural) return time_vector is
    ------------------------------------------------------------
      variable result : time_vector(1 to Size) ;
      variable NewA  : time_vector(1 to A'length) ;
      variable NewALength : natural ;
    begin
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Randomize Index
      for i in result'range loop
        result(i) := NewA(RandInt(1, NewALength)) ;
      end loop ;
      return result ;
    end function RandTimeV ;

    ------------------------------------------------------------
    impure function RandTimeV (A, Exclude : time_vector ; Unique : natural ; Size : natural) return time_vector is
    ------------------------------------------------------------
      variable result : time_vector(1 to Size) ;
      variable NewA  : time_vector(1 to A'length) ;
      variable NewALength, iUnique : natural ;
    begin
      -- if Unique = 0, it is more efficient to call RandRealV(Min, Max, Size)
      -- Remove Exclude from A
      RemoveExclude(A, Exclude, NewA, NewALength) ;
      -- Require NewALength >= Unique
      iUnique := Unique ; 
      if NewALength < Unique then 
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandTimeV: Unique > Length of Set A - Exclude", FAILURE) ;
        iUnique := NewALength ; 
      end if ; 
      -- Randomize using exclude list of Unique # of newly generated values
      for i in result'range loop
        result(i) := RandTime(NewA(1 to NewALength), result(maximum(1, 1 + i - iUnique) to Size)) ;
      end loop ;
      return result ;
    end function RandTimeV ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Basic Discrete Distributions
    --    Always uses Uniform
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistInt ( Weight : integer_vector ) return integer is
    ------------------------------------------------------------
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
          return DistArray'low ; -- allows debugging vs integer'low, out of range
        end if ;
        sum := DistArray(i) ;
      end loop ;
      if sum >= 1 then
        iRandomVal := Uniform(1, sum) ;
        for i in DistArray'range loop
          if iRandomVal <= DistArray(i) then
            return i ;
          end if ;
        end loop ;
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.DistInt: randomization failed", FAILURE) ;
      else
        Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.DistInt: No randomization weights", FAILURE) ;
      end if ;
      return DistArray'low ; -- allows debugging vs integer'low, out of range
    end function DistInt ;

    ------------------------------------------------------------
    impure function DistSlv ( Weight : integer_vector ; Size  : natural ) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(DistInt(Weight), Size)) ;
    end function DistSlv ;

    ------------------------------------------------------------
    impure function DistUnsigned ( Weight : integer_vector ; Size  : natural ) return unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(DistInt(Weight), Size) ;
    end function DistUnsigned ;

    ------------------------------------------------------------
    impure function DistSigned ( Weight : integer_vector ; Size  : natural ) return signed is
    ------------------------------------------------------------
    begin
      return to_signed(DistInt(Weight), Size) ;
    end function DistSigned ;

    ------------------------------------------------------------
    impure function DistBool ( Weight : NaturalVBoolType ) return boolean is
    ------------------------------------------------------------
      variable FullWeight : integer_vector(0 to 1) := (others => 0);
    begin
      for i in Weight'range loop
        FullWeight(boolean'pos(i)) := Weight(i) ;
      end loop ; 
      return boolean'val(DistInt(FullWeight)) ;
    end function DistBool ;

    ------------------------------------------------------------
    impure function DistSl ( Weight : NaturalVSlType ) return std_logic is
    ------------------------------------------------------------
      variable FullWeight : integer_vector(0 to 8) := (others => 0);
    begin
      for i in Weight'range loop
        FullWeight(std_logic'pos(i)) := Weight(i) ;
      end loop ; 
      return std_logic'val(DistInt(FullWeight)) ;
    end function DistSl ;

    ------------------------------------------------------------
    impure function DistBit ( Weight : NaturalVBitType ) return bit is
    ------------------------------------------------------------
      variable FullWeight : integer_vector(0 to 1) := (others => 0);
    begin
      for i in Weight'range loop
        FullWeight(bit'pos(i)) := Weight(i) ;
      end loop ; 
      return bit'val(DistInt(FullWeight)) ;
    end function DistBit ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Basic Distributions with exclude values (so can skip last or last n)
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistInt ( Weight : integer_vector ; Exclude : integer_vector ) return integer is
    ------------------------------------------------------------
      variable DistArray : integer_vector(weight'range) ;
      variable ExcludeTemp : integer ;
    begin
      DistArray := Weight ;
      for i in Exclude'range loop
        ExcludeTemp := Exclude(i) ;
        if ExcludeTemp >= DistArray'low and ExcludeTemp <= DistArray'high then
          DistArray(ExcludeTemp) := 0 ;
        end if ;
      end loop ;
      return DistInt(DistArray) ;
    end function DistInt ;

    ------------------------------------------------------------
    impure function DistSlv ( Weight : integer_vector ; Exclude : integer_vector ; Size  : natural ) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(DistInt(Weight, Exclude), Size)) ;
    end function DistSlv ;

    ------------------------------------------------------------
    impure function DistUnsigned ( Weight : integer_vector ; Exclude : integer_vector ; Size  : natural ) return unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(DistInt(Weight, Exclude), Size) ;
    end function DistUnsigned ;

    ------------------------------------------------------------
    impure function DistSigned ( Weight : integer_vector ; Exclude : integer_vector ; Size  : natural ) return signed is
    ------------------------------------------------------------
    begin
      return to_signed(DistInt(Weight, Exclude), Size) ;
    end function DistSigned ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Distribution for sparse values
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistValInt ( A : DistType ) return integer is
    ------------------------------------------------------------
      variable DistArray : integer_vector(0 to A'length -1) ;
      alias DistRecArray : DistType(DistArray'range) is A ;
    begin
      for i in DistArray'range loop
        DistArray(i) := DistRecArray(i).Weight ;
      end loop ;
      return DistRecArray(DistInt(DistArray)).Value ;
    end function DistValInt ;

    ------------------------------------------------------------
    impure function DistValSlv ( A : DistType ; Size  : natural ) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(DistValInt(A), Size)) ;
    end function DistValSlv ;

    ------------------------------------------------------------
    impure function DistValUnsigned ( A : DistType ; Size  : natural ) return unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(DistValInt(A), Size) ;
    end function DistValUnsigned ;

    ------------------------------------------------------------
    impure function DistValSigned ( A : DistType ; Size  : natural ) return signed is
    ------------------------------------------------------------
    begin
      return to_signed(DistValInt(A), Size) ;
    end function DistValSigned ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Distribution for sparse values with exclude values (so can skip last or last n)
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistValInt ( A : DistType ; Exclude : integer_vector ) return integer is
    ------------------------------------------------------------
      variable DistArray : integer_vector(0 to A'length -1) ;
      alias DistRecArray : DistType(DistArray'range) is A ;
    begin
      for i in DistRecArray'range loop
        if inside(DistRecArray(i).Value, exclude) then
          DistArray(i) := 0 ; -- exclude
        else
          DistArray(i) := DistRecArray(i).Weight ;
        end if ;
      end loop ;
      return DistRecArray(DistInt(DistArray)).Value ;
    end function DistValInt ;

    ------------------------------------------------------------
    impure function DistValSlv ( A : DistType ; Exclude : integer_vector ; Size  : natural ) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(DistValInt(A, Exclude), Size)) ;
    end function DistValSlv ;

    ------------------------------------------------------------
    impure function DistValUnsigned ( A : DistType ; Exclude : integer_vector ; Size  : natural ) return unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(DistValInt(A, Exclude), Size) ;
    end function DistValUnsigned ;

    ------------------------------------------------------------
    impure function DistValSigned ( A : DistType ; Exclude : integer_vector ; Size  : natural ) return signed is
    ------------------------------------------------------------
    begin
      return to_signed(DistValInt(A, Exclude), Size) ;
    end function DistValSigned ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    -- Large vector handling.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandUnsigned (Size : natural) return unsigned is
    ------------------------------------------------------------
      constant NumLoops : integer := integer(ceil(real(Size)/30.0)) ;
      constant Remain : integer := (Size - 1) mod 30 + 1 ; -- range 1 to 30
      variable RandVal : unsigned(1 to Size) ;
    begin
      if size = 0 then
        return NULL_UV ; -- Null array
      end if ;
      for i in 0 to NumLoops-2 loop
        RandVal(1 + 30*i to 30 + 30*i) := to_unsigned(RandInt(0, 2**30-1), 30) ;
      end loop ;
      RandVal(1+30*(NumLoops-1) to Remain + 30*(NumLoops-1)) := to_unsigned(RandInt(0, 2**Remain-1), Remain) ;
      return RandVal ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSlv (Size : natural) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(RandUnsigned(Size)) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandSigned (Size : natural) return signed is
    ------------------------------------------------------------
    begin
      return signed(RandUnsigned(Size)) ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function SizeByLeftMostBit (A : unsigned) return integer is
    ------------------------------------------------------------
      alias normA : unsigned (A'length downto 1) is A ;
    begin
      for i in normA'range loop 
        if normA(i) = '1' then 
          return i ; 
        end if ; 
      end loop ;
      return -1 ; 
    end function SizeByLeftMostBit ; 

    ------------------------------------------------------------
    impure function RandUnsigned (Max : unsigned) return unsigned is
    ------------------------------------------------------------
      alias normMax : unsigned (Max'length downto 1) is Max ;
      variable Result : unsigned(Max'range) := (others => '0') ;
      alias normResult : unsigned(normMax'range) is Result ;
      variable Size : integer ;
    begin
      -- Size = -1 if not found or Max'length = 0
      Size := SizeByLeftMostBit(Max) ;

      if Size > 0 then
        loop
          normResult(Size downto 1) := RandUnsigned(Size) ;
          exit when normResult <= Max ;
        end loop ;
        return Result ; -- = normResult with range same as Max
      else
        return resize("0", Max'length) ;
      end if ;
    end function RandUnsigned ;

    -- Working version that scales the value
    -- impure function RandUnsigned (Max : unsigned) return unsigned is
    --   constant MaxVal  : unsigned(Max'length+3 downto 1) := (others => '1') ;
    -- begin
    --   if max'length > 0 then
    --     -- "Max'length+3" creates 3 guard bits
    --     return resize( RandUnsigned(Max'length+3) * ('0'&Max+1) / ('0'&MaxVal+1), Max'length) ;
    --   else
    --     return NULL_UV ; -- Null Array
    --   end if ;
    -- end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSlv (Max : std_logic_vector) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(RandUnsigned( unsigned(Max))) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandSigned (Max : signed) return signed is
    ------------------------------------------------------------
    begin
      if max'length > 0 then
        AlertIf (OSVVM_RANDOM_ALERTLOG_ID, Max < 0, "RandomPkg.RandSigned: Max < 0", FAILURE) ;
        return signed(RandUnsigned( unsigned(Max))) ;
      else
        return NULL_SV ; -- Null Array
      end if ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandUnsigned (Min, Max : unsigned) return unsigned is
    ------------------------------------------------------------
      constant LEN : integer := maximum(Max'length, Min'length) ;
    begin
      if LEN > 0 and Min <= Max then
        return RandUnsigned(Max-Min) + Min ;
      else
        if Len > 0 then
          Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandUnsigned: Max < Min", FAILURE) ;
        end if ;
        return NULL_UV ;
      end if ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSlv (Min, Max : std_logic_vector) return std_logic_vector is
    ------------------------------------------------------------
      constant LEN : integer := maximum(Max'length, Min'length) ;
    begin
      if LEN > 0 and Min <= Max then
        return RandSlv(Max-Min) + Min ;
      else
        if Len > 0 then
          Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandSlv: Max < Min", FAILURE) ;
        end if ;
          return NULL_SlV ;
      end if ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandSigned (Min, Max : signed) return signed is
    ------------------------------------------------------------
      constant LEN : integer := maximum(Max'length, Min'length) ;
    begin
      if LEN > 0 and Min <= Max then
        return resize(RandSigned(resize(Max,LEN+1) - resize(Min,LEN+1)) + Min, LEN) ;
      else
        if Len > 0 then
          Alert(OSVVM_RANDOM_ALERTLOG_ID, "RandomPkg.RandSigned: Max < Min", FAILURE) ;
        end if ;
        return NULL_SV ;
      end if ;
    end function RandSigned ;

    --- ///////////////////////////////////////////////////////////////////////////
    --
    -- Large vector handling with Exclude values
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandUnsigned (Size : natural ; Exclude : uv_vector) return unsigned is
    ------------------------------------------------------------
      variable Result : unsigned (Size - 1 downto 0) ; 
    begin
      RandValLoop : loop 
        Result := RandUnsigned( Size) ; 
        for i in Exclude'range loop 
          next RandValLoop when Result = Exclude(i) ; 
        end loop ;
        exit RandValLoop ;
      end loop RandValLoop ; 
      return Result ; 
    end function RandUnsigned ;

--!!    ------------------------------------------------------------
--!!    impure function RandUnsigned (Size : natural ; Exclude : unsigned) return unsigned is
--!!    ------------------------------------------------------------
--!!      constant EXCLUDE_VECTOR : uv_vector(1 to 1)(Exclude'range) := (1 => Exclude) ;
--!!    begin
--!!      return RandUnsigned( Size, EXCLUDE_VECTOR) ; 
--!!    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSlv (Size : natural ; Exclude : slv_vector) return std_logic_vector is
    ------------------------------------------------------------
      variable Result : std_logic_vector (Size - 1 downto 0) ; 
    begin
      RandValLoop : loop 
        Result := RandSlv( Size) ; 
        for i in Exclude'range loop 
          next RandValLoop when Result = Exclude(i) ; 
        end loop ;
        exit RandValLoop ;
      end loop RandValLoop ; 
      return Result ; 
    end function RandSlv ;

--!!    ------------------------------------------------------------
--!!    impure function RandSlv (Size : natural ; Exclude : std_logic_vector) return std_logic_vector is
--!!    ------------------------------------------------------------
--!!      constant EXCLUDE_VECTOR : slv_vector(1 to 1)(Exclude'range) := (1 => Exclude) ;
--!!    begin
--!!      return RandSlv( Size, EXCLUDE_VECTOR) ; 
--!!    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandSigned (Size : natural ; Exclude : sv_vector) return signed is
    ------------------------------------------------------------
      variable Result : signed (Size - 1 downto 0) ; 
    begin
      RandValLoop : loop 
        Result := RandSigned( Size) ; 
        for i in Exclude'range loop 
          next RandValLoop when Result = Exclude(i) ; 
        end loop ;
        exit RandValLoop ;
      end loop RandValLoop ; 
      return Result ; 
    end function RandSigned ;

--!!    ------------------------------------------------------------
--!!    impure function RandSigned (Size : natural ; Exclude : signed) return signed is
--!!    ------------------------------------------------------------
--!!      constant EXCLUDE_VECTOR : sv_vector(1 to 1)(Exclude'range) := (1 => Exclude) ;
--!!    begin
--!!      return RandSigned( Size, EXCLUDE_VECTOR) ; 
--!!    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandUnsigned ( Min, Max : unsigned ; Exclude : uv_vector)  return unsigned is
    ------------------------------------------------------------
      constant LEN : integer := maximum(Max'length, Min'length) ;
      variable Result : unsigned (LEN - 1 downto 0) ; 
    begin
      RandValLoop : loop 
        Result := RandUnsigned( Min, Max) ; 
        for i in Exclude'range loop 
          next RandValLoop when Result = Exclude(i) ; 
        end loop ;
        exit RandValLoop ;
      end loop RandValLoop ; 
      return Result ; 
    end function RandUnsigned ;

--!!    ------------------------------------------------------------
--!!    impure function RandUnsigned ( Min, Max : unsigned ; Exclude : unsigned)  return unsigned is
--!!    ------------------------------------------------------------
--!!      constant EXCLUDE_VECTOR : uv_vector(1 to 1)(Exclude'range) := (1 => Exclude) ;
--!!    begin
--!!      return RandUnsigned( Min, Max, EXCLUDE_VECTOR) ; 
--!!    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSlv ( Min, Max : std_logic_vector ; Exclude : slv_vector) return std_logic_vector is
    ------------------------------------------------------------
      constant LEN : integer := maximum(Max'length, Min'length) ;
      variable Result : std_logic_vector (LEN - 1 downto 0) ; 
    begin
      RandValLoop : loop 
        Result := RandSlv( Min, Max) ; 
        for i in Exclude'range loop 
          next RandValLoop when Result = Exclude(i) ; 
        end loop ;
        exit RandValLoop ;
      end loop RandValLoop ; 
      return Result ;   
    end function RandSlv ;

--!!    ------------------------------------------------------------
--!!    impure function RandSlv ( Min, Max : std_logic_vector ; Exclude : std_logic_vector) return std_logic_vector is
--!!    ------------------------------------------------------------
--!!      constant EXCLUDE_VECTOR : slv_vector(1 to 1)(Exclude'range) := (1 => Exclude) ;
--!!    begin
--!!      return RandSlv( Min, Max, EXCLUDE_VECTOR) ; 
--!!    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandSigned ( Min, Max : signed ; Exclude : sv_vector) return signed is
    ------------------------------------------------------------
      constant LEN : integer := maximum(Max'length, Min'length) ;
      variable Result : signed (LEN - 1 downto 0) ; 
    begin
      RandValLoop : loop 
        Result := RandSigned( Min, Max) ; 
        for i in Exclude'range loop 
          next RandValLoop when Result = Exclude(i) ; 
        end loop ;
        exit RandValLoop ;
      end loop RandValLoop ; 
      return Result ; 
    end function RandSigned ;

--!!    ------------------------------------------------------------
--!!    impure function RandSigned ( Min, Max : signed ; Exclude : signed) return signed is
--!!    ------------------------------------------------------------
--!!      constant EXCLUDE_VECTOR : sv_vector(1 to 1)(Exclude'range) := (1 => Exclude) ;
--!!    begin
--!!      return RandSigned( Min, Max, EXCLUDE_VECTOR) ; 
--!!    end function RandSigned ;


    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Convenience Functions.  Resolve into calls into the other functions
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandReal return real is
    ------------------------------------------------------------
    begin
      return RandReal(0.0, 1.0) ;
    end function RandReal ;

    ------------------------------------------------------------
    impure function RandReal(Max : Real) return real is  -- 0.0 to Max
    ------------------------------------------------------------
    begin
      return RandReal(0.0, Max) ;
    end function RandReal ;

    ------------------------------------------------------------
    impure function RandInt return integer is
    ------------------------------------------------------------
    begin
      return RandInt(integer'low, integer'high) ;
    end function RandInt ;

    ------------------------------------------------------------
    impure function RandInt (Max : integer) return integer is
    ------------------------------------------------------------
    begin
      return RandInt(0, Max) ;
    end function RandInt ;

    ------------------------------------------------------------
    impure function RandSlv (Max, Size : natural) return std_logic_vector is
    ------------------------------------------------------------
    begin
      return std_logic_vector(to_unsigned(RandInt(0, Max), Size)) ;
    end function RandSlv ;

    ------------------------------------------------------------
    impure function RandUnsigned (Max, Size : natural) return Unsigned is
    ------------------------------------------------------------
    begin
      return to_unsigned(RandInt(0, Max), Size) ;
    end function RandUnsigned ;

    ------------------------------------------------------------
    impure function RandSigned (Max : integer ; Size : natural ) return Signed is
    ------------------------------------------------------------
    begin
      -- chose 0 to Max rather than -Max to +Max to be same as RandUnsigned, either seems logical
      return to_signed(RandInt(0, Max), Size) ;
    end function RandSigned ;

    ------------------------------------------------------------
    impure function RandBool return boolean is
    ------------------------------------------------------------
    begin
      return RandInt(1) = 1;
    end function RandBool ;

    ------------------------------------------------------------
    impure function RandSl return std_logic is
    ------------------------------------------------------------
    begin
      return std_logic'val(RandInt(8));
    end function RandSl ;
  
    ------------------------------------------------------------
    impure function RandBit return bit is
    ------------------------------------------------------------
    begin
      return bit'val(RandInt(1));
    end function RandBit ;
    
    
    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Convenience Functions with Exclude as an scalar rather than a _vector
    --    Calls the version with _vector
    --
    --- ///////////////////////////////////////////////////////////////////////////
      --- ///////////////////////////////////////////////////////////////////////////
    ---
    --- Base Randomization Distributions
    ---
    --- ///////////////////////////////////////////////////////////////////////////
    impure function Uniform    (Min, Max : integer ; Exclude : integer) return integer is
    begin
      return Uniform(Min, Max, (0 => Exclude)) ; 
    end function Uniform ; 
    impure function FavorSmall (Min, Max : integer ; Exclude : integer) return integer is
    begin
      return FavorSmall(Min, Max, (0 => Exclude)) ; 
    end function FavorSmall ; 
    impure function FavorBig   (Min, Max : integer ; Exclude : integer) return integer is
    begin
      return FavorBig(Min, Max, (0 => Exclude)) ; 
    end function FavorBig ; 
    impure function Normal (Mean, StdDeviation : real; Min, Max, Exclude : integer) return integer is
    begin
      return Normal(Mean, StdDeviation, Min, Max, (0 => Exclude)) ; 
    end function Normal ; 
    impure function Poisson (Mean : real; Min, Max, Exclude : integer) return integer is
    begin
      return Poisson(Mean, Min, Max, (0 => Exclude)) ; 
    end function Poisson ; 
  
    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomization with range and exclude
    --
    --- ///////////////////////////////////////////////////////////////////////////
    impure function RandInt      (Min, Max : integer ; Exclude : integer ) return integer is
    begin
      return RandInt (Min, Max, (0 => Exclude)) ; 
    end function RandInt ; 
-- ambiguous if Unit has a default
--    impure function RandTime     (Min, Max : time ;    Exclude : time ;    Unit   : time := ns) return time is
    impure function RandTime     (Min, Max : time ;    Exclude : time ;    Unit   : time ) return time is
    begin
      return RandTime (Min, Max, (0 => Exclude), Unit) ; 
    end function RandTime ; 
    impure function RandSlv      (Min, Max : natural ; Exclude : integer ; Size   : natural) return std_logic_vector is
    begin
      return RandSlv (Min, Max, (0 => Exclude), Size) ; 
    end function RandSlv ; 
    impure function RandUnsigned (Min, Max : natural ; Exclude : integer ; Size   : natural) return Unsigned is
    begin
      return RandUnsigned (Min, Max, (0 => Exclude), Size) ; 
    end function RandUnsigned ; 
    impure function RandSigned   (Min, Max : integer ; Exclude : integer ; Size   : natural) return Signed is
    begin
      return RandSigned (Min, Max, (0 => Exclude), Size) ; 
    end function RandSigned ; 
-- ambiguous with RandIntV(Min, Max, Unique, Size) return integer_vector ;
--    impure function RandIntV     (Min, Max : integer ; Exclude : integer ; Size   : natural) return integer_vector is
--    begin
--      return RandIntV (Min, Max, (0 => Exclude), Size) ; 
--    end function RandIntV ; 
    impure function RandIntV     (Min, Max : integer ; Exclude : integer ; Unique : natural ; Size : natural) return integer_vector is
    begin
      return RandIntV (Min, Max, (0 => Exclude), Unique, Size) ; 
    end function RandIntV ; 
    impure function RandTimeV    (Min, Max : time ;    Exclude : time ;    Size   : natural ; Unit : in time := ns) return time_vector is
    begin
      return RandTimeV (Min, Max, (0 => Exclude), Size, Unit) ; 
    end function RandTimeV ; 
    impure function RandTimeV    (Min, Max : time ;    Exclude : time ;    Unique : natural ; Size : natural ; Unit : in time := ns) return time_vector is
    begin
      return RandTimeV (Min, Max, (0 => Exclude), Unique, Size, Unit) ; 
    end function RandTimeV ; 

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Randomly select a value within a set of values with exclude values (so can skip last or last n)
    --    Uses internal settings of RandomParm to deterimine distribution.
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function RandInt      (A : integer_vector ; Exclude : integer  ) return integer is
    begin
      return RandInt (A, (0 => Exclude)) ; 
    end function RandInt ; 
    impure function RandReal     (A : real_vector    ; Exclude : real     ) return real is
    begin
      return RandReal (A, (0 => Exclude)) ; 
    end function RandReal ; 
    impure function RandTime     (A : time_vector    ; Exclude : time     ) return time is
    begin
      return RandTime (A, (0 => Exclude)) ; 
    end function RandTime ; 
    impure function RandSlv      (A : integer_vector ; Exclude : integer ; Size : natural) return std_logic_vector is
    begin
      return RandSlv (A, (0 => Exclude), Size) ; 
    end function RandSlv ; 
    impure function RandUnsigned (A : integer_vector ; Exclude : integer ; Size : natural) return Unsigned is
    begin
      return RandUnsigned (A, (0 => Exclude), Size) ; 
    end function RandUnsigned ; 
    impure function RandSigned   (A : integer_vector ; Exclude : integer ; Size : natural ) return Signed is
    begin
      return RandSigned (A, (0 => Exclude), Size) ; 
    end function RandSigned ; 
-- ambiguous with RandIntV(A, Unique, Size) return integer_vector ;
--    impure function RandIntV     (A : integer_vector ; Exclude : integer ; Size : natural) return integer_vector is
--    begin
--      return RandIntV (A, (0 => Exclude), Size) ; 
--    end function RandIntV ; 
    impure function RandIntV     (A : integer_vector ; Exclude : integer ; Unique : natural ; Size : natural) return integer_vector is
    begin
      return RandIntV (A, (0 => Exclude), Unique, Size) ; 
    end function RandIntV ; 
    impure function RandRealV    (A : real_vector    ; Exclude : real    ; Size : natural) return real_vector is
    begin
      return RandRealV (A, (0 => Exclude), Size) ; 
    end function RandRealV ; 
    impure function RandRealV    (A : real_vector    ; Exclude : real    ; Unique : natural ; Size : natural) return real_vector is
    begin
      return RandRealV (A, (0 => Exclude), Unique, Size) ; 
    end function RandRealV ; 
    impure function RandTimeV    (A : time_vector    ; Exclude : time    ; Size : natural) return time_vector is
    begin
      return RandTimeV (A, (0 => Exclude), Size) ; 
    end function RandTimeV ; 
    impure function RandTimeV    (A : time_vector    ; Exclude : time    ; Unique : natural ; Size : natural) return time_vector is
    begin
      return RandTimeV (A, (0 => Exclude), Unique, Size) ; 
    end function RandTimeV ; 

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Basic Distributions with exclude values (so can skip last or last n)
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    impure function DistInt      (Weight : integer_vector ; Exclude : integer ) return integer is
    begin
      return DistInt (Weight, (0 => Exclude)) ; 
    end function DistInt ; 
    impure function DistSlv      (Weight : integer_vector ; Exclude : integer ; Size  : natural ) return std_logic_vector is
    begin
      return DistSlv (Weight, (0 => Exclude), Size) ; 
    end function DistSlv ; 
    impure function DistUnsigned (Weight : integer_vector ; Exclude : integer ; Size  : natural ) return unsigned is
    begin
      return DistUnsigned (Weight, (0 => Exclude), Size) ; 
    end function DistUnsigned ; 
    impure function DistSigned   (Weight : integer_vector ; Exclude : integer ; Size  : natural ) return signed is
    begin
      return DistSigned (Weight, (0 => Exclude), Size) ; 
    end function DistSigned ; 

    --- ///////////////////////////////////////////////////////////////////////////
    --
    --  Distribution for sparse values with exclude values (so can skip last or last n)
    --    Specify weight and value
    --    Always uses Uniform via DistInt
    --
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    impure function DistValInt      (A : DistType ; Exclude : integer ) return integer is
    begin
      return DistValInt (A, (0 => Exclude)) ; 
    end function DistValInt ; 
    impure function DistValSlv      (A : DistType ; Exclude : integer ; Size  : natural) return std_logic_vector is
    begin
      return DistValSlv (A, (0 => Exclude), Size) ; 
    end function DistValSlv ; 
    impure function DistValUnsigned (A : DistType ; Exclude : integer ; Size  : natural) return unsigned is
    begin
      return DistValUnsigned (A, (0 => Exclude), Size) ; 
    end function DistValUnsigned ; 
    impure function DistValSigned   (A : DistType ; Exclude : integer ; Size  : natural) return signed is
    begin
      return DistValSigned (A, (0 => Exclude), Size) ; 
    end function DistValSigned ; 
    
  end protected body RandomPType ;

end RandomPkg ;
