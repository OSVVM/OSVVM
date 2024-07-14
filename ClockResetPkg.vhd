--
--  File Name:         ClockResetPkg.vhd
--  Design Unit Name:  ClockResetPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@SynthWorks.com
--  Contributor(s):
--     Jim Lewis      email:  jim@SynthWorks.com
--
--  Package Defines
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Factored Clock and Reset support out of TbUtilPkg
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 1999 - 2024 by SynthWorks Design Inc.
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

  use work.AlertLogPkg.all ;
  use work.CoveragePkg.all ;
  use work.TranscriptPkg.all ;
  use work.ResolutionPkg.all ;
  use work.OsvvmGlobalPkg.all ;
  use work.TbUtilPkg.all ;
  use work.IfElsePkg.all ;

package ClockResetPkg is

  ------------------------------------------------------------
  -- CreateClock,  CreateReset
  --   Note these do not exit
  ------------------------------------------------------------
  procedure CreateClock (
    signal   Clk             : inout std_logic ;
    constant Period          : time ;
    constant DutyCycle       : real := 0.5 ;
    constant Offset          : time := 0 sec ;
    constant ActiveValue     : std_logic := '1' 
  ) ;

  procedure CreateClock (
    signal   Clk             : inout std_logic ;
    signal   Enable          : in boolean ; 
    constant Period          : time ;
    constant DutyCycle       : real := 0.5 ;
    constant Offset          : time := 0 sec ;
    constant ActiveValue     : std_logic := '1' 
  ) ;

  procedure CreateJitterClock (
    signal   Clk             : inout std_logic ;
    variable CoverID         : inout CoverageIdType ; 
    constant Period          : time ;
    constant DutyCycle       : real := 0.5 ;
    constant Offset          : time := 0 sec ;
    constant ActiveValue     : std_logic := '1' 
  ) ;

  procedure OldCreateClock (
    signal   Clk        : inout std_logic ;
    constant Period     : time ;
    constant DutyCycle  : real := 0.5
  ) ;

  procedure CheckClockPeriod (
    constant AlertLogID : AlertLogIDType ;
    signal   Clk        : in  std_logic ;
    constant Period     : time ;
    constant ClkName    : string := "Clock" ;
    constant HowMany    : integer := 5
  ) ;

  procedure CheckClockPeriod (
    signal   Clk        : in  std_logic ;
    constant Period     : time ;
    constant ClkName    : string := "Clock" ;
    constant HowMany    : integer := 5
  ) ;

  procedure CreateReset (
    signal   Reset       : out std_logic ;
    constant ResetActive : in  std_logic ;
    signal   Clk         : in  std_logic ;
    constant Period      :     time ;
    constant tpd         :     time := 0 ns
  ) ;

  procedure LogReset (
    constant AlertLogID  : AlertLogIDType ;
    signal   Reset       : in  std_logic ;
    constant ResetActive : in  std_logic ;
    constant ResetName   : in  string := "Reset" ;
    constant LogLevel    : in  LogType := ALWAYS
  ) ;

  procedure LogReset (
    signal   Reset       : in  std_logic ;
    constant ResetActive : in  std_logic ;
    constant ResetName   : in  string := "Reset" ;
    constant LogLevel    : in  LogType := ALWAYS
  ) ;

end ClockResetPkg ;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
package body ClockResetPkg is

  ------------------------------------------------------------
  -- CreateClock,  CreateReset
  --   Note these do not exit
  ------------------------------------------------------------
  procedure CreateClock (
    signal   Clk             : inout std_logic ;
    constant Period          : time ;
    constant DutyCycle       : real := 0.5 ;
    constant Offset          : time := 0 sec ;
    constant ActiveValue     : std_logic := '1' 
  ) is
    constant ACTIVE_TIME     : time := Period * DutyCycle ;
    constant INACTIVE_TIME   : time := Period - ACTIVE_TIME ;
    constant INACTIVE_VALUE  : std_logic := not ActiveValue ; 
  begin
    if Clk = 'U' then 
      Clk <= INACTIVE_VALUE ; 
    end if ; 
    wait for Offset ;
    Clk <= ActiveValue, INACTIVE_VALUE after ACTIVE_TIME, ActiveValue after Period ;
    wait for Period ;     
    loop 
      Clk <= INACTIVE_VALUE after ACTIVE_TIME, ActiveValue after Period ; 
      wait for Period ;     
    end loop ; 
  end procedure CreateClock ;

  procedure CreateClock (
    signal   Clk             : inout std_logic ;
    signal   Enable          : in boolean ; 
    constant Period          : time ;
    constant DutyCycle       : real := 0.5 ;
    constant Offset          : time := 0 sec ;
    constant ActiveValue     : std_logic := '1' 
  ) is
    constant ACTIVE_TIME     : time := Period * DutyCycle ;
    constant INACTIVE_TIME   : time := Period - ACTIVE_TIME ;
    constant INACTIVE_VALUE  : std_logic := not ActiveValue ; 
  begin
    if Clk = 'U' then 
      Clk <= INACTIVE_VALUE ; 
    end if ; 
    wait for Offset ;
    if not Enable then 
      wait until Enable ; 
    end if ; 
    Clk <= ActiveValue, INACTIVE_VALUE after ACTIVE_TIME, ActiveValue after Period ;
    wait for Period ;     
    loop 
      if not Enable then 
        wait until Enable ; 
      end if ; 
      Clk <= INACTIVE_VALUE after ACTIVE_TIME, ActiveValue after Period ; 
      wait for Period ;     
    end loop ; 
  end procedure CreateClock ;
  
  procedure CreateJitterClock (
    signal   Clk             : inout std_logic ;
    variable CoverID         : inout CoverageIdType ; 
    constant Period          : time ;
    constant DutyCycle       : real := 0.5 ;
    constant Offset          : time := 0 sec ;
    constant ActiveValue     : std_logic := '1' 
  ) is
    variable RandClkPeriod   : time ; 
    variable BurstLength, ClockVariance : integer ; 
    constant ACTIVE_TIME     : time := Period * DutyCycle ;
    constant INACTIVE_TIME   : time := Period - ACTIVE_TIME ;
    constant INACTIVE_VALUE  : std_logic := not ActiveValue ; 
  begin
    CoverID := NewID("JitterClk") ; 
    AddCross(CoverID, GenBin(1,20,1), GenBin(900,1100)) ; 

    if Clk = 'U' then 
      Clk <= INACTIVE_VALUE ; 
    end if ; 
    wait for Offset ;
    Clk <= ActiveValue, INACTIVE_VALUE after ACTIVE_TIME, ActiveValue after Period ;
    wait for Period ;     
    loop 
      (BurstLength, ClockVariance) := RandCovPoint(CoverID) ; 
      RandClkPeriod := (ClockVariance * Period) / 1000 ; 
      for i in 1 to BurstLength loop 
        Clk <= INACTIVE_VALUE after ACTIVE_TIME, ActiveValue after Period ; 
        wait for RandClkPeriod ;
      end loop ; 
    end loop ;
  end procedure CreateJitterClock ;

  ------------------------------------------------------------
  -- CreateClock,  CreateReset
  --   Note these do not exit
  ------------------------------------------------------------
  procedure OldCreateClock (
    signal   Clk        : inout std_logic ;
    constant Period     : time ;
    constant DutyCycle  : real := 0.5
  ) is
    constant HIGH_TIME : time := Period * DutyCycle ;
    constant LOW_TIME  : time := Period - HIGH_TIME ;
  begin
    if HIGH_TIME = LOW_TIME then
      loop
        Clk <= toggle_sl_table(Clk) after HIGH_TIME ;
        wait on Clk ;
      end loop ;
    else
      -- Schedule s.t. all assignments after the first occur on delta cycle 0
      Clk <= '0', '1' after LOW_TIME ;
      wait for period - t_sim_resolution ; -- allows after on future Clk <= '0'
      loop
        Clk <= '0' after t_sim_resolution, '1' after LOW_TIME + t_sim_resolution ;
        wait for period ;
      end loop ;
    end if ;
  end procedure OldCreateClock ;

  procedure CheckClockPeriod (
    constant AlertLogID : AlertLogIDType ;
    signal   Clk        : in  std_logic ;
    constant Period     : time ;
    constant ClkName    : string := "Clock" ;
    constant HowMany    : integer := 5
  ) is
    variable LastLogTime, ObservedPeriod : time ;
  begin
    wait until EdgeActive(Clk, CLK_ACTIVE) ;
    LastLogTime := now ;
    -- Check First HowMany clocks
    for i in 1 to HowMany loop
      wait until Clk = CLK_ACTIVE ;
      ObservedPeriod := now - LastLogTime ;
      AffirmIf(AlertLogID, ObservedPeriod = Period,
         "CheckClockPeriod: " & ClkName & " Period: " & to_string(ObservedPeriod, GetOsvvmDefaultTimeUnits) &
         " = Expected " & to_string(Period, GetOsvvmDefaultTimeUnits)) ;
      LastLogTime := now ;
     end loop ;
     wait ;
  end procedure CheckClockPeriod ;

  procedure CheckClockPeriod (
    signal   Clk        : in  std_logic ;
    constant Period     : time ;
    constant ClkName    : string := "Clock" ;
    constant HowMany    : integer := 5
  ) is
  begin
    CheckClockPeriod (
      AlertLogID => ALERTLOG_DEFAULT_ID,
      Clk        => Clk,
      Period     => Period,
      ClkName    => ClkName,
      HowMany    => HowMany
    ) ;
  end procedure CheckClockPeriod ;

  procedure CreateReset (
    signal   Reset       : out std_logic ;
    constant ResetActive : in  std_logic ;
    signal   Clk         : in  std_logic ;
    constant Period      :     time ;
    constant tpd         :     time := 0 ns
  ) is
  begin
    wait until EdgeActive(Clk, CLK_ACTIVE) ;
    Reset <= ResetActive after tpd ;
    wait for Period - t_sim_resolution ;
    wait until Clk = CLK_ACTIVE ;
    Reset <= not ResetActive after tpd ;
    wait ;
  end procedure CreateReset ;

  procedure LogReset (
    constant AlertLogID  : AlertLogIDType ;
    signal   Reset       : in  std_logic ;
    constant ResetActive : in  std_logic ;
    constant ResetName   : in  string := "Reset" ;
    constant LogLevel    : in  LogType := ALWAYS
  ) is
  begin
    -- Does not log the value of Reset at time 0.
    for_ever : loop
      wait on Reset ;
      if Reset = ResetActive then
        LOG(AlertLogID, ResetName & " now active", INFO) ;
        print("") ;
      elsif Reset = not ResetActive then
        LOG(AlertLogID, ResetName & " now inactive", INFO) ;
        print("") ;
      else
        LOG(AlertLogID, ResetName & " = " & to_string(Reset), INFO) ;
        print("") ;
      end if ;
    end loop for_ever ;
  end procedure LogReset ;

  procedure LogReset (
    signal   Reset       : in  std_logic ;
    constant ResetActive : in  std_logic ;
    constant ResetName   : in  string := "Reset" ;
    constant LogLevel    : in  LogType := ALWAYS
  ) is
  begin
    LogReset (
      AlertLogID  => ALERTLOG_DEFAULT_ID,
      Reset       => Reset,
      ResetActive => ResetActive,
      ResetName   => ResetName,
      LogLevel    => LogLevel
    ) ;
  end procedure LogReset ;

end ClockResetPkg ;
