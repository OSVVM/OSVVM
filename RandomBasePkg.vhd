--
--  File Name:         RandomBasePkg.vhd
--  Design Unit Name:  RandomBasePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Defines Base randomization, seed definition, seed generation,
--        and seed IO functionality for RandomPkg.vhd
--        Defines:
--          Procedure Uniform - baseline randomization 
--          Type RandomSeedType - the seed as a single object
--          function GenRandSeed from integer_vector, integer, or string
--          IO function to_string, & procedures write, read
--
--        In revision 2.0 these types and functions are included by package reference.
--        Long term these will be passed as generics to RandomGenericPkg
--
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    01/2023    2023.01    Added functions for SetRandomSalt to support setting in declaration regions
--    10/2022    2022.10    Added SetRandomSalt(string or integer), GetRandomSalt (integer), 
--                          RandomSalt is added to all versions of GenRandSeed
--    06/2021    2021.06    Updated GenRandSeed hash to DJBX33A 
--    01/2020    2020.01    Updated Licenses to Apache
--    6/2015     2015.06    Changed GenRandSeed to impure
--    1/2015     2015.01    Changed Assert/Report to Alert
--    5/2013     2013.05    No Changes
--    4/2013     2013.04    No Changes
--    03/01/2011 2.0        STANDARD VERSION
--                          Fixed abstraction by moving RandomParamType to RandomPkg.vhd 
--    02/25/2009 1.1        Replaced reference to std_2008 with a reference 
--                          to ieee_proposed.standard_additions.all ;
--    02/2009:   1.0        First Public Released Version
--    01/2008:   0.1        Initial revision
--                          Numerous revisions for VHDL Testbenches and Verification
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2008 - 2023 by SynthWorks Design Inc.  
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
use ieee.math_real.all ;
use std.textio.all ;

use work.OsvvmGlobalPkg.all ; 
use work.AlertLogPkg.all ; 
use work.TbUtilPkg.all ; 
use work.SortListPkg_int.all ;

-- comment out following 2 lines with VHDL-2008.  Leave in for VHDL-2002 
-- library ieee_proposed ;						          -- remove with VHDL-2008
-- use ieee_proposed.standard_additions.all ;   -- remove with VHDL-2008


package RandomBasePkg is

  constant OSVVM_RANDOM_ALERTLOG_ID : AlertLogIDType := OSVVM_ALERTLOG_ID ;

  -----------------------------------------------------------------
  constant NULL_STRING : string := "";
  -- note NULL_RANGE_TYPE should probably be in std.standard
  subtype NULL_RANGE_TYPE is integer range NULL_STRING'range ;
  constant NULL_INTV : integer_vector (NULL_RANGE_TYPE) := (others => 0) ;

  -----------------------------------------------------------------
  -- RandomSeedType - Abstract the type for randomization
  type RandomSeedType is array (1 to 2) of integer ;
  
  -----------------------------------------------------------------
  -- Uniform
  --   Generate a random number with a Uniform distribution
  --   Required by RandomPkg.  All randomization is derived from here.
  --   Value produced must be either: 
  --     0 <= Value < 1  or  0 < Value < 1
  --
  --   Current version uses ieee.math_real.Uniform
  --   This abstraction allows higher precision version 
  --   of a uniform distribution to be used provided
  --
  procedure Uniform (Result : out real ;  Seed : inout RandomSeedType) ;

  -----------------------------------------------------------------
  --  GenRandSeed
  --    Generate / hash a seed from a value that is integer_vector, String, Time, or Integer to RandomSeedType
  --    Used by RandomPkg.InitSeed
  --    GenRandSeed makes sure all values are in a valid range
  impure function  GenRandSeed   (IV : integer_vector) return RandomSeedType ;
  impure function  OldGenRandSeed(IV : integer_vector) return RandomSeedType ;
  impure function  GenRandSeed   (I  : integer) return RandomSeedType ;
  impure function  OldGenRandSeed(I  : integer) return RandomSeedType ;
  impure function  GenRandSeed   (T  : Time) return RandomSeedType ;
  impure function  GenRandSeed   (S  : string)  return RandomSeedType ;
  impure function  OldGenRandSeed(S  : string)  return RandomSeedType ;
  procedure SetRandomSalt (I : integer) ; 
  impure function SetRandomSalt (I : integer) return boolean ; 
  impure function SetRandomSalt (I : integer) return integer ; 
  procedure SetRandomSalt (S : string) ; 
  impure function SetRandomSalt (S : string) return boolean ;
  impure function SetRandomSalt (S : string) return string ;
  impure function GetRandomSalt return integer ; 
  
  -----------------------------------------------------------------
  --- RandomSeedType IO
  function  to_string(A : RandomSeedType; Separator : string := " ") return string ;
  procedure write(variable L: inout line ; A : RandomSeedType ) ;
  procedure read (variable L: inout line ; A : out RandomSeedType ; good : out boolean ) ;
  procedure read (variable L: inout line ; A : out RandomSeedType ) ;

  -----------------------------------------------------------------
  --- Distribution Types and read/write procedures
  type RandomDistType is (UNIFORM, FAVOR_SMALL, FAVOR_BIG, NORMAL, POISSON) ;

  type RandomParamType is record
    Distribution : RandomDistType ;
    Mean         : Real ; -- also used as probability of success
    StdDeviation : Real ; -- also used as number of trials for binomial
  end record ;
  
  subtype RandomParmType is RandomParamType ;  -- backward compatibility

  -----------------------------------------------------------------
  -- RandomParm IO
  function to_string(A : RandomDistType) return string ;
  procedure write(variable L : inout line ; A : RandomDistType ) ;
  procedure read (variable L : inout line ; A : out RandomDistType ; good : out boolean ) ;
  procedure read (variable L : inout line ; A : out RandomDistType ) ;
  function to_string(A : RandomParamType) return string ;
  procedure write(variable L : inout line ; A : RandomParamType ) ;
  procedure read (variable L : inout line ; A : out RandomParamType ; good : out boolean ) ;
  procedure read (variable L : inout line ; A : out RandomParamType ) ;

  -----------------------------------------------------------------
  ---  Randomization Support
  ---    Scale                - Scale a value to be within a given range
  ---    FavorSmall, FavorBig - Distribution Support
  ---    RemoveExclude 
  function Scale (A, Min, Max : real) return real ;
  function Scale (A : real ; Min, Max : integer) return integer ;

  function FavorSmall (A : real) return real ;
  function FavorBig   (A : real) return real ;
  
  function to_time_vector    (A : integer_vector ; Unit : time) return time_vector ;
  function to_integer_vector (A : time_vector ; Unit : time) return integer_vector ;
  procedure RemoveExclude    (A, Exclude : integer_vector ; variable NewA : out integer_vector ; variable NewALength : inout natural ) ;
  function inside            (A : real ; Exclude : real_vector) return boolean ;
  procedure RemoveExclude    (A, Exclude : real_vector ; variable NewA : out real_vector ; variable NewALength : inout natural ) ;
  function inside            (A : time ; Exclude : time_vector) return boolean ;
  procedure RemoveExclude    (A, Exclude : time_vector ; variable NewA : out time_vector ; variable NewALength : inout natural ) ;
end RandomBasePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body RandomBasePkg is
  -----------------------------------------------------------------
  -- Uniform
  --   Generate a random number with a Uniform distribution
  --   Required by RandomPkg.  All randomization is derived from here.
  --   Value produced must be either: 
  --     0 <= Value < 1  or  0 < Value < 1
  --
  --   Current version uses ieee.math_real.Uniform
  --   This abstraction allows higher precision version 
  --   of a uniform distribution to be used provided
  --
  -----------------------------------------------------------------
  procedure Uniform (
  -----------------------------------------------------------------
    Result : out   real ;
    Seed   : inout RandomSeedType 
  ) is
  begin
    ieee.math_real.Uniform (Seed(Seed'left), Seed(Seed'right), Result) ;
  end procedure Uniform ;


  -----------------------------------------------------------------
  --  GenRandSeed
  --    Convert integer_vector to RandomSeedType
  --    Uniform requires two seed values of the form:
  --        1 <= SEED1 <= 2147483562; 1 <= SEED2 <= 2147483398
  --
  --    if 2 seed values are passed to GenRandSeed and they are 
  --    in the above range, then they must remain unmodified.
  ------------------------------------------------------------
  impure function GenRandSeed(IV : integer_vector) return RandomSeedType is
  ------------------------------------------------------------
    alias iIV : integer_vector(1 to IV'length) is IV ;
    variable Seed      : RandomSeedType ; 
    variable ChurnSeed : real ;
    constant SEED1_MAX : integer := 2147483562 ;
    constant SEED2_MAX : integer := 2147483398 ;
  begin
    if iIV'Length <= 0 then  -- no seed
      Alert(OSVVM_ALERTLOG_ID, "RandomBasePkg.GenRandSeed received NULL integer_vector", FAILURE) ; 
      return GenRandSeed(integer_vector'(3, 17)) ;  -- if continue seed = (3, 17)

    elsif iIV'Length = 1 then  -- one seed value
      -- inefficient handling, but condition is unlikely
      return GenRandSeed(iIV(1)) ;  -- generate a seed

    else  -- only use the left two values
      -- mod returns 0 to MAX-1, the -1 adjusts legal values, +1 adjusts them back
      -- 1 <= SEED1 <= 2147483562
      Seed(1) := ((iIV(1)-1 + GetRandomSalt) mod SEED1_MAX) + 1 ;
     -- 1 <= SEED2 <= 2147483398
      Seed(2) := ((iIV(2)-1) mod SEED2_MAX) + 1 ;
      
      Uniform(ChurnSeed, Seed) ;
      return Seed ;
    end if ;
  end function GenRandSeed ;

  ------------------------------------------------------------
  impure function OldGenRandSeed(IV : integer_vector) return RandomSeedType is
  ------------------------------------------------------------
    alias iIV : integer_vector(1 to IV'length) is IV ;
    variable Seed1 : integer ;
    variable Seed2 : integer ;
    constant SEED1_MAX : integer := 2147483562 ;
    constant SEED2_MAX : integer := 2147483398 ;
  begin
    if iIV'Length <= 0 then  -- no seed
      Alert(OSVVM_ALERTLOG_ID, "RandomBasePkg.GenRandSeed received NULL integer_vector", FAILURE) ; 
      return OldGenRandSeed(integer_vector'(3, 17)) ;  -- if continue seed = (3, 17)

    elsif iIV'Length = 1 then  -- one seed value
      -- inefficient handling, but condition is unlikely
      return OldGenRandSeed(iIV(1)) ;  -- generate a seed

    else  -- only use the left two values
      -- mod returns 0 to MAX-1, the -1 adjusts legal values, +1 adjusts them back
      -- 1 <= SEED1 <= 2147483562
      Seed1 := ((iIV(1)-1 + GetRandomSalt) mod SEED1_MAX) + 1 ;
      -- 1 <= SEED2 <= 2147483398
      Seed2 := ((iIV(2)-1) mod SEED2_MAX) + 1 ;
      return (Seed1, Seed2) ;
    end if ;
  end function OldGenRandSeed ;


  -----------------------------------------------------------------
  --  GenRandSeed - Integer
  impure function GenRandSeed(I : integer) return RandomSeedType is
  -----------------------------------------------------------------
    variable Seed      : RandomSeedType ; 
    variable ChurnSeed : real ;
  begin
    Seed(1) := integer((real(I + GetRandomSalt) * 5381.0 + 313.0 - 1.0) mod 2.0 ** 30) + 1 ;
    Seed(2) := integer((real(I) * 313.0 + 5381.0 - 1.0) mod 2.0 ** 30) + 1 ; 
    Uniform(ChurnSeed, Seed) ;
    return Seed ; 
  end function GenRandSeed ;

  -----------------------------------------------------------------
  impure function OldGenRandSeed(I : integer) return RandomSeedType is
  -----------------------------------------------------------------
    variable result : integer_vector(1 to 2) ;
  begin
    result(1) := I ;
    result(2) := I/3 + 1 ;
    return OldGenRandSeed(result) ; -- make value ranges legal
  end function OldGenRandSeed ;

  -----------------------------------------------------------------
  --  GenRandSeed - Time
  impure function GenRandSeed(T : Time) return RandomSeedType is
  -----------------------------------------------------------------
  begin
    -- NVC fatals on the integer conversion time values >= 2**31, hence, the following was removed
    --      RandomSeed := GenRandSeed(T /std.env.resolution_limit) ;
    -- Also consider:
    --      RandomSeed := GenRandSeed( (T - (T/2**30)*2**30) /std.env.resolution_limit) ;
--     return GenRandSeed( (T mod (2**30*std.env.resolution_limit)) /std.env.resolution_limit ) ; 
    return GenRandSeed( (T mod (2**30*OSVVM_SIM_RESOLUTION)) /OSVVM_SIM_RESOLUTION ) ; 
  end function GenRandSeed ;

  -----------------------------------------------------------------
  --  GenRandSeed - String
  --    usage:  RV.GenRandSeed(RV'instance_path));
  --    hash based on DJBX33A
  impure function  GenRandSeed(S : string) return RandomSeedType is
  -----------------------------------------------------------------
    constant LEN : integer := S'length ;
    constant HALF_LEN : integer := LEN/2 ;
    alias revS : string(LEN downto 1) is S ;
    variable Seed      : RandomSeedType ; 
    variable ChurnSeed : real ;
    variable temp : real := 5381.0 ;
  begin
    for i in 1 to HALF_LEN loop
      temp := (temp*33.0 + real(character'pos(revS(i)))) mod (2.0**30) ;
    end loop ;
    Seed(1) := (integer(temp) + GetRandomSalt - 1) mod (2**30) + 1 ;
    for i in HALF_LEN + 1 to LEN loop
      temp := (temp*33.0 + real(character'pos(revS(i))) -1.0) mod (2.0**30) + 1.0 ;
    end loop ;
    Seed(2) := integer(temp) ;
    Uniform(ChurnSeed, Seed) ;
    return Seed ; 
  end function GenRandSeed ;
  
  -----------------------------------------------------------------
  impure function OldGenRandSeed(S : string) return RandomSeedType is
  -----------------------------------------------------------------
    constant LEN : integer := S'length ;
    constant HALF_LEN : integer := LEN/2 ;
    alias revS : string(LEN downto 1) is S ;
    variable result : integer_vector(1 to 2) ;
    variable temp : integer := 0 ;
    constant MOD_AMOUNT : integer := 2**30 - 2**8 - 1 + 2**30 ;
  begin
    for i in 1 to HALF_LEN loop
      temp := (temp + character'pos(revS(i))) mod MOD_AMOUNT ;
    end loop ;
    result(1) := (temp + GetRandomSalt - 1) mod MOD_AMOUNT + 1 ;
    for i in HALF_LEN + 1 to LEN loop
      temp := (temp + character'pos(revS(i)) - 1) mod MOD_AMOUNT + 1;
    end loop ;
    result(2) := temp ;
    return OldGenRandSeed(result) ;  -- make value ranges legal
  end function OldGenRandSeed ;

  -----------------------------------------------------------------
  type LocalIntegerPType is protected 
  -----------------------------------------------------------------
    procedure Set (A : Integer) ; 
    impure function get return Integer ; 
  end protected LocalIntegerPType ; 
  type LocalIntegerPType is protected body
    variable SettingsVar : Integer := 0 ; 
    procedure Set (A : Integer) is
    begin
       SettingsVar := A ; 
    end procedure Set ; 
    impure function get return Integer is
    begin
      return SettingsVar ; 
    end function get ; 
  end protected body LocalIntegerPType ; 
  
  shared variable RandomSalt : LocalIntegerPType ; 

  -----------------------------------------------------------------
  procedure SetRandomSalt (I : integer) is
  -----------------------------------------------------------------
  begin 
    RandomSalt.Set(I mod 2**30) ; 
  end procedure SetRandomSalt ; 
  
  -----------------------------------------------------------------
  impure function  SetRandomSalt (I : integer) return boolean is
  -----------------------------------------------------------------
  begin 
    SetRandomSalt(I) ; 
    return TRUE ; 
  end function SetRandomSalt ; 
  
  -----------------------------------------------------------------
  impure function  SetRandomSalt (I : integer) return integer is
  -----------------------------------------------------------------
  begin 
    SetRandomSalt(I) ; 
    return I ; 
  end function SetRandomSalt ; 
  
  -----------------------------------------------------------------
  procedure SetRandomSalt (S : string) is
  -----------------------------------------------------------------
    variable temp : real := 5381.0 ;
  begin
    for i in S'reverse_range loop
--    keep value between 0 and 2**30-1 for later additions.
--      temp := (temp*33.0 + real(character'pos(S(i)))) mod (2.0**31 - 2.0**8 - 1.0) ;
      temp := (temp*33.0 + real(character'pos(S(i)))) mod (2.0**30) ;
    end loop ;
    RandomSalt.Set(integer(temp)) ; 
  end procedure SetRandomSalt ; 

  -----------------------------------------------------------------
  impure function  SetRandomSalt (S : string) return boolean is
  -----------------------------------------------------------------
  begin 
    SetRandomSalt(S) ; 
    return TRUE ; 
  end function SetRandomSalt ; 
  
  -----------------------------------------------------------------
  impure function  SetRandomSalt (S : string) return string is
  -----------------------------------------------------------------
  begin 
    SetRandomSalt(S) ; 
    return S ; 
  end function SetRandomSalt ; 
  
  -----------------------------------------------------------------
  impure function GetRandomSalt return integer is 
  -----------------------------------------------------------------
  begin 
    return RandomSalt.Get ; 
  end function GetRandomSalt ; 

  -----------------------------------------------------------------
  --  RandomSeedType IO
  -- 
  -----------------------------------------------------------------
  function to_string(A : RandomSeedType; Separator : string := " ") return string is
  -----------------------------------------------------------------
  begin
    return to_string(A(A'left)) & Separator & to_string(A(A'right)) ;
  end function to_string ;

  -----------------------------------------------------------------
  procedure write(variable L: inout line ; A : RandomSeedType ) is
  -----------------------------------------------------------------
  begin
    write(L, to_string(A)) ;
  end procedure ;

  -----------------------------------------------------------------
  procedure read(variable L: inout line ; A : out RandomSeedType ; good : out boolean ) is
  -----------------------------------------------------------------
    variable iReadValid : boolean ;
  begin
    for i in A'range loop
      read(L, A(i), iReadValid) ;
      exit when not iReadValid ;
    end loop ;
    good := iReadValid ;
  end procedure read ;

  -----------------------------------------------------------------
  procedure read(variable L: inout line ; A : out RandomSeedType ) is
  -----------------------------------------------------------------
    variable ReadValid : boolean ;
  begin
      read(L, A, ReadValid) ;
      AlertIfNot(ReadValid, OSVVM_ALERTLOG_ID, "RandomBasePkg.read[line, RandomSeedType] failed", FAILURE) ;  
  end procedure read ;
  
  -----------------------------------------------------------------
  --  RandomParamType IO
  -- 
  -----------------------------------------------------------------
  function to_string(A : RandomDistType) return string is
  -----------------------------------------------------------------
  begin
    return RandomDistType'image(A) ;
  end function to_string ;

  -----------------------------------------------------------------
  procedure write(variable L : inout line ; A : RandomDistType ) is
  -----------------------------------------------------------------
  begin
    write(L, to_string(A)) ;
  end procedure write ;

  -----------------------------------------------------------------
  procedure read(variable L : inout line ; A : out RandomDistType ; good : out boolean ) is
  -----------------------------------------------------------------
    variable strval : string(1 to 40) ;
    variable len    : natural ;
  begin
    -- procedure SREAD (L : inout LINE ; VALUE : out STRING ; STRLEN : out NATURAL) ;
    sread(L, strval, len) ;
    A := RandomDistType'value(strval(1 to len)) ;
    good := len > 0 ;
  end procedure read ;

  -----------------------------------------------------------------
  procedure read(variable L : inout line ; A : out RandomDistType ) is
  -----------------------------------------------------------------
    variable ReadValid : boolean ;
  begin
      read(L, A, ReadValid) ;
      AlertIfNot( OSVVM_ALERTLOG_ID, ReadValid, "RandomPkg.read[line, RandomDistType] failed", FAILURE) ;
  end procedure read ;

  -----------------------------------------------------------------
  function to_string(A : RandomParamType) return string is
  -----------------------------------------------------------------
  begin
    return RandomDistType'image(A.Distribution) & " " &
           to_string(A.Mean, 2) & " " & to_string(A.StdDeviation, 2) ;
  end function to_string ;

  -----------------------------------------------------------------
  procedure write(variable L : inout line ; A : RandomParamType ) is
  -----------------------------------------------------------------
  begin
    write(L, to_string(A)) ;
  end procedure write ;

  -----------------------------------------------------------------
  procedure read(variable L : inout line ; A : out RandomParamType ; good : out boolean ) is
  -----------------------------------------------------------------
    variable strval : string(1 to 40) ;
    variable len    : natural ;
    variable igood  : boolean ;
  begin
    loop
      -- procedure SREAD (L : inout LINE ; VALUE : out STRING ; STRLEN : out NATURAL) ;
      sread(L, strval, len) ;
      A.Distribution := RandomDistType'value(strval(1 to len)) ;
      igood := len > 0 ;
      exit when not igood ;

      read(L, A.Mean, igood) ;
      exit when not igood ;

      read(L, A.StdDeviation, igood) ;
      exit ;
    end loop ;
    good := igood ;
  end procedure read ;

  -----------------------------------------------------------------
  procedure read(variable L : inout line ; A : out RandomParamType ) is
  -----------------------------------------------------------------
    variable ReadValid : boolean ;
  begin
      read(L, A, ReadValid) ;
      AlertIfNot( OSVVM_ALERTLOG_ID, ReadValid, "RandomPkg.read[line, RandomParamType] failed", FAILURE) ; 
  end procedure read ;


  -----------------------------------------------------------------
  --  Randomization Support
  --    Scale                - Scale a value to be within a given range
  --    FavorSmall, FavorBig - Distribution Support
  --    RemoveExclude 
  --   
  -----------------------------------------------------------------
  --  Scale - Scale a value to be within a given range
  function Scale (A, Min, Max : real) return real is
  -----------------------------------------------------------------
    variable ValRange : Real ;
  begin
    ValRange := Max - Min ;
    return A * ValRange + Min ;
--!!    -- Already done checked and failed if error.
--!!    -- If continuing this calculation is no worse than returning real'left
--!!    if Max >= Min then
--!!      ValRange := Max - Min ;
--!!      return A * ValRange + Min ;
--!!    else
--!!      return real'left ;
--!!    end if ;
  end function Scale ;

  -----------------------------------------------------------------
  function Scale (A : real ; Min, Max : integer) return integer is
  -----------------------------------------------------------------
    variable ValRange : real ;
    variable rMin, rMax : real ;
  begin
    rMin := real(Min) - 0.5 ;
    rMax := real(Max) + 0.5 ;
    ValRange := rMax - rMin ;
    return integer(round(A * ValRange + rMin)) ;
--!!    -- Already done checked and failed if error.
--!!    -- If continuing this calculation is no worse than returning real'left
--!!    if Max >= Min then
--!!      rMin := real(Min) - 0.5 ;
--!!      rMax := real(Max) + 0.5 ;
--!!      ValRange := rMax - rMin ;
--!!      return integer(round(A * ValRange + rMin)) ;
--!!    else
--!!      return integer'low ;
--!!    end if ;
  end function Scale ;

  -----------------------------------------------------------------
  -- FavorSmall - create more smaller values
  function FavorSmall (A : real) return real is
  -----------------------------------------------------------------
  begin
    return 1.0 - sqrt(A) ;
  end FavorSmall ;

  -----------------------------------------------------------------
  -- FavorBig - create more larger values
  -- alias FavorBig is sqrt[real return real] ;
  function FavorBig   (A : real) return real is
  -----------------------------------------------------------------
  begin
    return sqrt(A) ;
  end FavorBig ;

  -----------------------------------------------------------------
  -- local.
  function to_time_vector (A : integer_vector ; Unit : time) return time_vector is
  -----------------------------------------------------------------
    variable result : time_vector(A'range) ;
  begin
    for i in A'range loop
      result(i) := A(i) * Unit ;
    end loop ;
    return result ;
  end function to_time_vector ;

  -----------------------------------------------------------------
  -- local
  function to_integer_vector (A : time_vector ; Unit : time) return integer_vector is
  -----------------------------------------------------------------
    variable result : integer_vector(A'range) ;
  begin
    for i in A'range loop
      result(i) := A(i) / Unit ;
    end loop ;
    return result ;
  end function to_integer_vector ;

  -----------------------------------------------------------------
  -- Remove the exclude list from the list - integer_vector
  procedure RemoveExclude(A, Exclude : integer_vector ; variable NewA : out integer_vector ; variable NewALength : inout natural ) is
  -----------------------------------------------------------------
    alias norm_NewA : integer_vector(1 to NewA'length) is NewA ;
  begin
    NewALength := 0 ;
    for i in A'range loop
      if not inside(A(i), Exclude) then
        NewALength := NewALength + 1 ;
        norm_NewA(NewALength) := A(i) ;
      end if ;
    end loop ;
  end procedure RemoveExclude ;

  -----------------------------------------------------------------
  -- Inside - real_vector
  function inside(A : real ; Exclude : real_vector) return boolean is
  -----------------------------------------------------------------
  begin
    for i in Exclude'range loop
      if A = Exclude(i) then
        return TRUE ;
      end if ;
    end loop ;
    return FALSE ;
  end function inside ;

  -----------------------------------------------------------------
  -- Remove the exclude list from the list - real_vector
  procedure RemoveExclude(A, Exclude : real_vector ; variable NewA : out real_vector ; variable NewALength : inout natural ) is
  -----------------------------------------------------------------
    alias norm_NewA : real_vector(1 to NewA'length) is NewA ;
  begin
    NewALength := 0 ;
    for i in A'range loop
      if not inside(A(i), Exclude) then
        NewALength := NewALength + 1 ;
        norm_NewA(NewALength) := A(i) ;
      end if ;
    end loop ;
  end procedure RemoveExclude ;

  -----------------------------------------------------------------
  -- Inside - time_vector
  function inside(A : time ; Exclude : time_vector) return boolean is
  -----------------------------------------------------------------
  begin
    for i in Exclude'range loop
      if A = Exclude(i) then
        return TRUE ;
      end if ;
    end loop ;
    return FALSE ;
  end function inside ;

  -----------------------------------------------------------------
  -- Remove the exclude list from the list - time_vector
  procedure RemoveExclude(A, Exclude : time_vector ; variable NewA : out time_vector ; variable NewALength : inout natural ) is
  -----------------------------------------------------------------
    alias norm_NewA : time_vector(1 to NewA'length) is NewA ;
  begin
    NewALength := 0 ;
    for i in A'range loop
      if not inside(A(i), Exclude) then
        NewALength := NewALength + 1 ;
        norm_NewA(NewALength) := A(i) ;
      end if ;
    end loop ;
  end procedure RemoveExclude ;

end RandomBasePkg ;