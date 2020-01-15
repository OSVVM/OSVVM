--
--  File Name:         Demo_Rand.vhd
--  Design Unit Name:  Demo_Rand
--  Revision:          STANDARD VERSION,  revision 2015.03  
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
--  Contributor(s):            
--     Jim Lewis      email:  jim@synthworks.com   
--
--  Description:
--    Demonstration program for RandomPkg.vhd
--    
--  Developed for: 
--        SynthWorks Design Inc. 
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    02/2009:  1.0        Initial revision and First Public Released Version
--    03/2009   1.1        Minor tweek to printing
--    03/2015   2015.03    Updated FAVOR_BIG to FavorBig and FAVOR_SMALL to FavorSmall
--    11/2016   2016.11    Updated library to OSVVM
--    01/2020   2020.01    Updated Licenses to Apache
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2009 - 2020 by SynthWorks Design Inc.  
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
  use ieee.std_logic_1164.all ;
  use std.textio.all ;
  use ieee.std_logic_textio.all ;
  
Package TestSupportPkg is 
  type integer_array is array (integer range <>) of integer ;
  
  procedure TestInit (TestName : string ; variable Results : inout integer_array ) ;  
  procedure TestInit (TestName : string ; variable Results : inout integer_array ; variable Count : inout natural ) ;  
  procedure AccumulateResults (IntVal : integer ; Num : integer ; variable Results : inout integer_array) ;
  procedure PrintResults (Results : integer_array) ;

end TestSupportPkg ;
Package body TestSupportPkg is 
  procedure TestInit (TestName : string ; variable Results : inout integer_array ) is
  begin
    write(OUTPUT, LF&LF & TestName & LF ) ;
    Results := (Results'range => 0) ; 
    write(OUTPUT, "1st 20 values = ") ; 
  end ;
  
  procedure TestInit (TestName : string ; variable Results : inout integer_array ; variable Count : inout natural ) is
  begin
    Count := Count + 1 ; 
    write(OUTPUT, LF&LF & "Test " & integer'image(Count) & ": " & TestName & LF ) ;
    Results := (Results'range => 0) ; 
    write(OUTPUT, "1st 20 values = ") ; 
  end ;

  procedure AccumulateResults (IntVal : integer ; Num : integer ; variable Results : inout integer_array) is
  begin
    Results(IntVal) :=Results(IntVal) + 1 ;
    if Num < 20 then 
      write(OUTPUT, integer'image(IntVal) & " ") ; 
    end if ; 
  end ;
  
  procedure PrintResults (Results : integer_array) is
  begin
    write(OUTPUT, LF & "Accumulated Results.  Expecting approximately 1000 of each per weight." & LF) ; 
    for i in Results'range loop 
      if Results(i) > 0 then 
        write(OUTPUT, "**  ") ; 
        write(OUTPUT, integer'image(i) & " : " & integer'image(Results(i)) & LF) ;
      end if ; 
    end loop ;
  end ;
end TestSupportPkg ;

library IEEE ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

  use std.textio.all ;
  use ieee.std_logic_textio.all ;

library OSVVM ; 
  use OSVVM.RandomBasePkg.all ; 
  use OSVVM.RandomPkg.all ; 

use work.TestSupportPkg.all ; 

entity Demo_Rand is 
end Demo_Rand ;
architecture test of Demo_Rand is 
begin


  RandomGenProc : process
    variable RV : RandomPType ; 
    
    variable DataInt      : integer ; 
    variable DataSlv      : std_logic_vector(3 downto 0) ; 
    variable DataUnsigned : unsigned(3 downto 0) ; 
    variable DataSigned   : signed(4 downto 0) ; 

    -- Statistics
    variable TestNum : integer := 0 ; 
    variable Results : integer_array (-100 to 100) := (others => 0) ; 
    variable writebuf : line ;   
    
  begin

    RV.InitSeed(RV'instance_name)  ;  -- Initialize Seed.  Typically done one time
  
  
write(OUTPUT, LF&LF& "Random Range Tests") ; 
    TestInit("RandInt(0, 7)  Range 0-7", Results, TestNum) ;  -- 1
    for i in 1 to 8000  loop   -- Loop 1000x per value
      DataInt := RV.RandInt(0, 7);
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;
    
    TestInit("RandInt(1, 13, (3, 7, 11)  Range 1-13, Exclude 3,7,11", Results, TestNum) ;  -- 2
    for i in 1 to 10000 loop   -- Loop 1000x per value
      DataInt := RV.RandInt(1, 13, (3, 7, 11));
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RandSlv(0, 4, 4)  Range 0-4", Results, TestNum) ;  -- 3
    for i in 1 to 5000  loop   -- Loop 1000x per value
      DataSlv := RV.RandSlv(0, 4, 4);
      AccumulateResults(to_integer(unsigned(DataSlv)), i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RandUnsigned(4, 9, (0 => 7), 4)  Range 4-9, Exclude 7", Results, TestNum) ;  -- 4
    for i in 1 to 5000 loop   -- Loop 1000x per value
      DataUnsigned := RV.RandUnsigned(4, 9, (0 => 7), 4);  -- only 1 exclude element
      AccumulateResults(to_integer(DataUnsigned), i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RandSigned(-4, 3, 5)", Results, TestNum) ;  -- 5
    for i in 1 to 8000  loop   -- Loop 1000x per value
      DataSigned := RV.RandSigned(-4, 3, 5);
      AccumulateResults(to_integer(DataSigned), i, Results) ;
    end loop ;
    PrintResults (Results) ;

    
write(OUTPUT, LF&LF& "Random Set Tests") ; 
    TestNum := 0 ; 
    TestInit("RandInt( (-50, -22, -14, -7, -2, 0, 3, 7, 9, 27, 49, 89, 99)).  Set: (-50, -22, -14, -7, -2, 0, 3, 7, 9, 27, 49, 89, 99)", Results, TestNum) ;  -- 1
    for i in 1 to 13000  loop   -- Loop 1000x per value
      DataInt := RV.RandInt( (-50, -22, -14, -7, -2, 0, 3, 7, 9, 27, 49, 89, 99)); 
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;    
    
    TestInit("RandInt( (-5, -1, 3, 7, 11), (-1, 7) )  Set (-5, -1, 3, 7, 11), Exclude (-1, 7)", Results, TestNum) ;  -- 2
    for i in 1 to 3000 loop   -- Loop 1000x per value
      DataInt := RV.RandInt( (-5, -1, 3, 7, 11), (-1, 7) );
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RandSlv( (1, 2, 3, 7, 11), 4)", Results, TestNum) ;  -- 3
    for i in 1 to 5000 loop   -- Loop 1000x per value
      DataSlv := RV.RandSlv( (1, 2, 3, 7, 11), 4);
      AccumulateResults(to_integer(unsigned(DataSlv)), i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RandUnsigned( (1, 2, 3, 11), (1 => 3), 4)", Results, TestNum) ;  -- 4
    for i in 1 to 3000 loop   -- Loop 1000x per value
      DataUnsigned := RV.RandUnsigned( (1, 2, 3, 11), (1 => 3), 4);   -- 1 element middle
      AccumulateResults(to_integer(DataUnsigned), i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RandSigned( (-5, -1, 3, 7, 11), 5)", Results, TestNum) ;  -- 5
    for i in 1 to 5000 loop   -- Loop 1000x per value
      DataSigned := RV.RandSigned( (-5, -1, 3, 7, 11), 5);
      AccumulateResults(to_integer(DataSigned), i, Results) ;
    end loop ;
    PrintResults (Results) ;

    
write(OUTPUT, LF&LF& "Weighted Distribution Tests") ; 
    TestNum := 0 ; 
    -- There is also DistSlv, DistUnsigned, DistSigned
    TestInit("RV.DistInt( (7, 2, 1) ) ", Results, TestNum) ;
    for i in 1 to 10000  loop   -- Loop 1000x per distribute weight
      DataInt := RV.DistInt( (7, 2, 1) ) ;
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("RV.DistInt( (0, 2, 0, 4, 0, 6, 0, 8, 0, 10), (3,9) );", Results, TestNum) ;
    for i in 1 to 16000  loop   -- Loop 1000x per distribute weight
      DataInt := RV.DistInt( (0, 2, 0, 4, 0, 6, 0, 8, 0, 10), (3,9) ) ;
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;
    

write(OUTPUT, LF&LF& "Weighted Distribution with Value") ; 
    TestNum := 0 ; 
    -- There is also DistValSlv, DistValUnsigned, DistValSigned
    TestInit("RV.DistValInt( ((1, 7), (3, 2), (5, 1)) ) ", Results, TestNum) ;
    for i in 1 to 10000  loop   -- Loop 1000x per distribute weight
      DataInt := RV.DistValInt( ((1, 7), (3, 2), (5, 1)) ) ;
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;
    
    TestInit("RV.DistValInt( ((1, 7), (3, 2), (5, 1)), (1=>3) ) Exclude 3", Results, TestNum) ;
    for i in 1 to 8000  loop   -- Loop 1000x per distribute weight
      DataInt := RV.DistValInt( ((1, 7), (3, 2), (5, 1)), (1=>3) ) ;
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;
    
write(OUTPUT, LF&LF& "Mode Direct Tests") ;
    -- There are also real return values
    TestNum := 0 ; 
    TestInit("Integer Uniform:  Integer Range (0 to 9)", Results, TestNum) ;
    for i in 1 to 10000  loop   -- Loop 1000x per value
      DataInt := RV.uniform(0,9);
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("Integer FavorSmall:  Integer Range (0 to 9)", Results, TestNum) ;
    for i in 1 to 10000  loop   -- Loop 1000x per value
      DataInt := RV.FavorSmall(0,9);
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("Integer FavorBig:  Integer Range (0 to 9)", Results, TestNum) ;
    for i in 1 to 10000  loop   -- Loop 1000x per value
      DataInt := RV.FavorBig(0,9);
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("Integer NORMAL, 50.0, 5.0 range -100 to 100", Results, TestNum) ;
    for i in 1 to 100000  loop   -- Loop 1000x per value
      DataInt := RV.Normal(50.0, 5.0, -100, 100);
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;

    TestInit("Integer Poisson, 10.0, -100, 100", Results, TestNum) ;
    for i in 1 to 10000  loop   -- Loop 1000x per value
      DataInt := RV.Poisson(10.0, -100, 100) ; 
      AccumulateResults(DataInt, i, Results) ;
    end loop ;
    PrintResults (Results) ;
    
    wait ;
  end process RandomGenProc ;

end test ; 