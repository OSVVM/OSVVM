--
--  File Name:         TbUtilPkg.vhd
--  Design Unit Name:  TbUtilPkg
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
--    11/1999:  0.1        Initial revision
--                         Numerous revisions for VHDL Testbenches and Verification
--    10/2013   2013.10    Split out Text Utilities
--    11/2016   2016.11    First Public Release Version
--                         Updated naming for consistency.
--    04/2018   2018.04    Added RequestTransaction, WaitForTransaction, Toggle, WaitForToggle for bit.
--                         Added Increment and WaitForToggle for integer.
--    08/2018   2018.08    Updated WaitForTransaction to allow 0 time transactions
--    01/2020   2020.01    Updated Licenses to Apache
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 1999 - 2020 by SynthWorks Design Inc.  
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
  
library osvvm ; 
  use osvvm.AlertLogPkg.all ;
  use osvvm.TranscriptPkg.all ; 

package TbUtilPkg is

  constant CLK_ACTIVE : std_logic := '1' ; 

  constant t_sim_resolution : time := std.env.resolution_limit ;  -- VHDL-2008
  -- constant t_sim_resolution : time := 1 ns ;  -- for non VHDL-2008 simulators

  ------------------------------------------------------------
  -- ZeroOneHot, OneHot
  --   OneHot:      return true if exactly one value is 1
  --   ZeroOneHot:  return false when more than one value is a 1
  ------------------------------------------------------------
  function OneHot ( constant A : in std_logic_vector ) return boolean ;  
  function ZeroOneHot ( constant A : in std_logic_vector ) return boolean ;  


  ------------------------------------------------------------
  -- RequestTransaction
  --   Transaction initiation side of handshaking
  --   Pairs with WaitForTransaction or one of its variations
  ------------------------------------------------------------
  procedure RequestTransaction (
    signal Rdy  : Out std_logic ;
    signal Ack  : In  std_logic 
  ) ;

  procedure RequestTransaction (
    signal Rdy  : Out bit ;
    signal Ack  : In  bit 
  ) ;
  
  ------------------------------------------------------------
  -- WaitForTransaction
  --   Model side of handshaking
  --   Pairs with RequestTransaction 
  ------------------------------------------------------------
  procedure WaitForTransaction (
    signal Clk  : In  std_logic ;
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) ;
  
  procedure WaitForTransaction (
    signal Clk  : In  std_logic ;
    signal Rdy  : In  bit ;
    signal Ack  : Out bit 
  ) ;

  procedure WaitForTransaction (
    signal   Clk       : In  std_logic ;
    signal   Rdy       : In  std_logic ;
    signal   Ack       : Out std_logic ;
    signal   TimeOut   : In  std_logic ;
    constant Polarity  : In  std_logic := '1' 
  ) ;
  
  -- Variation for model that stops waiting when IntReq is asserted
  -- Intended for models that need to switch between instruction streams
  -- such as a CPU when interrupt is pending
  procedure WaitForTransactionOrIrq (
    signal Clk     : In  std_logic ;
    signal Rdy     : In  std_logic ;
    signal IntReq  : In  std_logic 
  ) ;

  -- Set Ack to Model starting value
  procedure StartTransaction  ( signal Ack : Out std_logic ) ; 
  -- Set Ack to Model finishing value
  procedure FinishTransaction ( signal Ack : Out std_logic ) ; 
  -- If a transaction is pending, return true
  function TransactionPending ( signal Rdy : In  std_logic ) return boolean ;

  -- Variation for clockless models
  procedure WaitForTransaction ( 
    signal Rdy : In  std_logic ; 
    signal Ack : Out std_logic 
  ) ;


  ------------------------------------------------------------
  -- Toggle, WaitForToggle
  --   Used for communicating between processes
  ------------------------------------------------------------
  procedure Toggle (
    signal Sig        : InOut std_logic ;
    constant DelayVal : time  
  ) ;
  procedure Toggle ( signal Sig : InOut std_logic ) ;
  procedure ToggleHS ( signal Sig : InOut std_logic ) ;
  function  IsToggle ( signal Sig : In std_logic ) return boolean ; 
  procedure WaitForToggle ( signal Sig : In std_logic ) ;
  
  -- Bit type versions
  procedure Toggle ( signal Sig : InOut bit ; constant DelayVal : time ) ;
  procedure Toggle ( signal Sig : InOut bit ) ;
  procedure ToggleHS ( signal Sig : InOut bit ) ;
  function  IsToggle ( signal Sig : In bit ) return boolean ; 
  procedure WaitForToggle ( signal Sig : In bit ) ;
  
  -- Integer type versions
  procedure Increment ( signal Sig : InOut integer ; constant RollOverValue : in integer := 0) ;
  procedure WaitForToggle ( signal Sig : In integer ) ;


  ------------------------------------------------------------
  -- WaitForBarrier
  --   Barrier Synchronization
  --   Multiple processes call it, it finishes when all have called it
  ------------------------------------------------------------
  procedure WaitForBarrier ( signal Sig : InOut std_logic ) ;
  procedure WaitForBarrier ( signal Sig : InOut std_logic ; signal TimeOut : std_logic ; constant Polarity : in std_logic := '1') ;
  procedure WaitForBarrier ( signal Sig : InOut std_logic ; constant TimeOut : time ) ;
  -- resolved_barrier : summing resolution used in conjunction with integer based barriers
  function resolved_barrier ( s : integer_vector ) return integer ; 
  subtype  integer_barrier is resolved_barrier integer ; 
  -- Usage of integer barriers requires resolved_barrier. Initialization to 1 recommended, but not required
  --   signal barrier1 : resolved_barrier integer := 1 ;     -- using the resolution function
  --   signal barrier2 : integer_barrier := 1 ;              -- using the subtype that already applies the resolution function
  procedure WaitForBarrier ( signal Sig : InOut integer ) ;  
  procedure WaitForBarrier ( signal Sig : InOut integer ; signal TimeOut : std_logic ; constant Polarity : in std_logic := '1') ;
  procedure WaitForBarrier ( signal Sig : InOut integer ; constant TimeOut : time ) ;
  -- Using separate signals
  procedure WaitForBarrier2 ( signal SyncOut : out std_logic ; signal SyncIn : in  std_logic ) ;
  procedure WaitForBarrier2 ( signal SyncOut : out std_logic ; signal SyncInV : in  std_logic_vector ) ;

  
  ------------------------------------------------------------
  -- WaitForClock
  --   Sync to Clock - after a delay, after a number of clocks
  ------------------------------------------------------------
  procedure WaitForClock ( signal Clk : in std_logic ;  constant Delay : in time ) ; 
  procedure WaitForClock ( signal Clk : in std_logic ;  constant NumberOfClocks : in integer := 1) ; 
  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in boolean ) ; 
  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in std_logic ; constant Polarity : std_logic := '1' ) ;


  ------------------------------------------------------------
  -- WaitForLevel
  --   Find a signal at a level
  ------------------------------------------------------------
  procedure WaitForLevel ( signal A : in boolean ) ;
  procedure WaitForLevel ( signal A : in std_logic ; Polarity : std_logic := '1' ) ; 

  ------------------------------------------------------------
  -- CreateClock,  CreateReset
  --   Note these do not exit
  ------------------------------------------------------------
  procedure CreateClock ( 
    signal   Clk        : inout std_logic ; 
    constant Period     : time ; 
    constant DutyCycle  : real := 0.5 
  )  ; 
  
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
    constant tpd         :     time 
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
  
  ------------------------------------------------------------
  --  Deprecated subprogram names
  --    Maintaining backward compatibility using aliases
  ------------------------------------------------------------
  -- History of RequestTransaction / WaitForTransaction
  alias RequestAction is RequestTransaction [std_logic, std_logic] ;
  alias WaitForRequest is WaitForTransaction [std_logic, std_logic, std_logic] ;
  -- History of WaitForToggle
  alias WaitOnToggle is WaitForToggle [std_logic] ;
  -- History of WaitForBarrier 
  alias WayPointBlock is WaitForBarrier [std_logic] ;
  alias SyncTo is WaitForBarrier2[std_logic, std_logic] ;
  alias SyncTo is WaitForBarrier2[std_logic, std_logic_vector] ;
  -- Backward compatible name  
  alias SyncToClk is WaitForClock [std_logic, time] ;


  ------------------------------------------------------------
  -- Deprecated
  -- WaitForAck, StrobeAck
  --   Replaced by WaitForToggle and Toggle
  ------------------------------------------------------------
  procedure WaitForAck ( signal Ack : In  std_logic ) ;
  procedure StrobeAck  ( signal Ack : Out std_logic ) ;
  
end TbUtilPkg ;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
package body TbUtilPkg is 

  ------------------------------------------------------------
  -- ZeroOneHot, OneHot
  --   OneHot:      return true if exactly one value is 1
  --   ZeroOneHot:  return false when more than one value is a 1
  ------------------------------------------------------------
  function OneHot ( constant A : in std_logic_vector ) return boolean is
    variable found_one : boolean := FALSE ;
  begin
    for i in A'range loop 
      if A(i) = '1' or A(i) = 'H' then 
        if found_one then 
          return FALSE ; 
        end if ; 
        found_one := TRUE ;
      end if ; 
    end loop ;
    return found_one ; -- found a one
  end function OneHot ; 
  
  function ZeroOneHot ( constant A : in std_logic_vector ) return boolean is  
    variable found_one : boolean := FALSE ;
  begin
    for i in A'range loop 
      if A(i) = '1' or A(i) = 'H' then 
        if found_one then 
          return FALSE ; 
        end if ; 
        found_one := TRUE ;
      end if ; 
    end loop ;
    return TRUE ;  -- all zero or found a one
  end function ZeroOneHot ; 


  ------------------------------------------------------------
  -- RequestTransaction
  --   Transaction initiation side of handshaking
  --   Pairs with WaitForTransaction or one of its variations
  ------------------------------------------------------------
  procedure RequestTransaction (
    signal Rdy  : Out std_logic ;
    signal Ack  : In  std_logic 
  ) is
  begin
    -- Record contains new transaction
    Rdy        <= '1' ;
    -- Find Ack low = '0' 
    wait until Ack = '0' ;
    -- Prepare for Next Transaction
    Rdy        <= '0' ;
    -- Transaction Done
    wait until Ack = '1' ;        
  end procedure RequestTransaction ;

  procedure RequestTransaction (
    signal Rdy  : Out bit ;
    signal Ack  : In  bit 
  ) is
  begin
    -- Record contains new transaction
    Rdy        <= '1' ;
    -- Find Ack low = '0' 
    wait until Ack = '0' ;
    -- Prepare for Next Transaction
    Rdy        <= '0' ;
    -- Transaction Done
    wait until Ack = '1' ;        
  end procedure RequestTransaction ;


  ------------------------------------------------------------
  -- WaitForTransaction
  --   Model side of handshaking
  --   Pairs with RequestTransaction 
  ------------------------------------------------------------
  procedure WaitForTransaction (
    signal Clk  : In  std_logic ;
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) is
    variable AckTime : time ; 
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6
    AckTime    := NOW ; 
    -- Find Start of Transaction
    wait for 0 ns ; -- Allow Rdy from previous cycle to clear
    if Rdy /= '1' then                --   #2
      wait until Rdy = '1' ; 
    end if ; 
    -- align to clock if needed (not back-to-back transactions)
    if NOW /= AckTime then 
      wait until Clk = CLK_ACTIVE ;
    end if ; 
    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
    wait for 0 ns ; -- Allow transactions without time passing
  end procedure WaitForTransaction ;

  procedure WaitForTransaction (
    signal Clk  : In  std_logic ;
    signal Rdy  : In  bit ;
    signal Ack  : Out bit 
  ) is
    variable AckTime : time ; 
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6
    AckTime    := NOW ; 
    -- Find Start of Transaction
    wait for 0 ns ; -- Allow Rdy from previous cycle to clear
    if Rdy /= '1' then                --   #2
      wait until Rdy = '1' ; 
    else
      wait for 0 ns ; -- allow Ack to update
    end if ; 
    -- align to clock if needed (not back-to-back transactions)
    if NOW /= AckTime then 
      wait until Clk = CLK_ACTIVE ;
    end if ; 
    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
    wait for 0 ns ; -- Allow transactions without time passing
  end procedure WaitForTransaction ;
  
  procedure WaitForTransaction (
    signal   Clk       : In  std_logic ;
    signal   Rdy       : In  std_logic ;
    signal   Ack       : Out std_logic ;
    signal   TimeOut   : In  std_logic ;
    constant Polarity  : In std_logic := '1' 
  ) is
    variable AckTime : time ; 
    variable FoundRdy : boolean ; 
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6
    AckTime    := NOW ; 
    -- Find Ready or Time out
    wait for 0 ns ; -- Allow Rdy from previous cycle to clear
    if (Rdy /= '1' and TimeOut /= Polarity) then 
      wait until Rdy = '1' or TimeOut = Polarity ; 
    end if ; 
    FoundRdy := Rdy = '1' ; 
    -- align to clock if Rdy or TimeOut does not happen within delta cycles from Ack
    if NOW /= AckTime then 
      wait until Clk = CLK_ACTIVE ;
    end if ; 
    if FoundRdy then 
      -- Model active and owns the record
      Ack        <= '0' ;             --  #3
      wait for 0 ns ; -- Allow transactions without time passing
    end if ;
  end procedure WaitForTransaction ;
  
  -- Variation for model that stops waiting when IntReq is asserted
  -- Intended for models that need to switch between instruction streams
  -- such as a CPU when interrupt is pending
  procedure WaitForTransactionOrIrq (
    signal Clk     : In  std_logic ;
    signal Rdy     : In  std_logic ;
    signal IntReq  : In  std_logic 
  ) is
    variable AckTime : time ; 
    constant POLARITY : std_logic := '1' ;
  begin
    AckTime    := NOW ; 
    -- Find Ready or Time out
    wait for 0 ns ; -- allow Rdy from previous cycle to clear
    if (Rdy /= '1' and IntReq /= POLARITY) then 
      wait until Rdy = '1' or IntReq = POLARITY ; 
    else
      wait for 0 ns ; -- allow Ack to update
   end if ; 
    -- align to clock if Rdy or IntReq does not happen within delta cycles from Ack
    if NOW /= AckTime then 
      wait until Clk = CLK_ACTIVE ;
    end if ; 
  end procedure ;
  
  -- Set Ack to Model starting value
  -- Pairs with WaitForTransactionOrIrq above
  procedure StartTransaction  ( signal Ack : Out std_logic ) is
  begin
    Ack        <= '0' ;
    wait for 0 ns ; -- Allow transactions without time passing
  end procedure StartTransaction ; 

  -- Set Ack to Model finishing value
  -- Pairs with WaitForTransactionOrIrq above
  procedure FinishTransaction ( signal Ack : Out std_logic ) is
  begin
    -- End of Cycle
    Ack        <= '1' ;
    wait for 0 ns ; -- Allow Ack to update
  end procedure FinishTransaction ; 

  -- If a transaction is pending, return true
  --   Used to detect presence of transaction stream, 
  --   such as an interrupt handler
  function TransactionPending (
    signal Rdy     : In  std_logic 
  ) return boolean is
  begin
    return Rdy = '1' ; 
  end function TransactionPending ;

  -- Variation for clockless models
  procedure WaitForTransaction (
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) is
    variable AckTime : time ; 
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6
    -- Find Start of Transaction
    wait for 0 ns ; -- Allow Rdy from previous cycle to clear
    if Rdy /= '1' then                --   #2
      wait until Rdy = '1' ; 
    end if ; 
    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
    wait for 0 ns ; -- allow 0 time transactions
  end procedure WaitForTransaction ;


  ------------------------------------------------------------
  -- Toggle, WaitForToggle
  --   Used for communicating between processes
  ------------------------------------------------------------
  type stdulogic_indexby_stdulogic is array (std_ulogic) of std_ulogic;
  constant toggle_sl_table : stdulogic_indexby_stdulogic := (
      '0'     => '1', 
      'L'     => '1', 
      others  => '0' 
  ); 

  procedure Toggle (
    signal Sig        : InOut std_logic ;
    constant DelayVal : time  
  ) is
    variable iDelayVal : time ;
  begin
    if DelayVal > t_sim_resolution then 
      iDelayVal := DelayVal - t_sim_resolution ; 
    else
      iDelayVal := 0 sec ; 
      AlertIf(OSVVM_ALERTLOG_ID, DelayVal < 0 sec, "osvvm.TbUtilPkg.Toggle: Delay value < 0 ns") ;
    end if ;
    Sig <= toggle_sl_table(Sig) after iDelayVal ;
  end procedure Toggle ;

  procedure Toggle ( signal Sig : InOut std_logic ) is
  begin
    Sig <= toggle_sl_table(Sig) ;
  end procedure Toggle ;
  
  procedure ToggleHS ( signal Sig : InOut std_logic ) is
  begin
    Sig    <= toggle_sl_table(Sig) ;
    wait for 0 ns ;  -- Sig toggles
    wait for 0 ns ;  -- new values updated into record
  end procedure ToggleHS ;

  function IsToggle ( signal Sig : In std_logic ) return boolean is 
  begin
    return Sig'event ; 
  end function IsToggle ;

  procedure WaitForToggle ( signal Sig : In std_logic ) is
  begin
    wait on Sig ;
  end procedure WaitForToggle ;

  -- Bit type versions
  procedure Toggle ( signal Sig : InOut bit ; constant DelayVal : time ) is
    variable iDelayVal : time ;
  begin
    if DelayVal > t_sim_resolution then 
      iDelayVal := DelayVal - t_sim_resolution ; 
    else
      iDelayVal := 0 sec ; 
      AlertIf(OSVVM_ALERTLOG_ID, DelayVal < 0 sec, 
         "osvvm.TbUtilPkg.Toggle: Delay value < 0 ns", WARNING) ;
    end if ;
    Sig <= not Sig after iDelayVal ;
  end procedure Toggle ;

  procedure Toggle ( signal Sig : InOut bit ) is
  begin
    Sig <= not Sig ;
  end procedure Toggle ;
  
  procedure ToggleHS ( signal Sig : InOut bit ) is
  begin
    Sig    <= not Sig ;
    wait for 0 ns ;  -- Sig toggles
    wait for 0 ns ;  -- new values updated into record
  end procedure ToggleHS ;

  function IsToggle ( signal Sig : In bit ) return boolean is 
  begin
    return Sig'event ; 
  end function IsToggle ;

  procedure WaitForToggle ( signal Sig : In bit ) is
  begin
    wait on Sig ;
  end procedure WaitForToggle ;
  
  -- Integer type versions
  procedure Increment ( signal Sig : InOut integer ; constant RollOverValue : in integer := 0) is
  begin
    if Sig = integer'high then 
      Sig <= RollOverValue ; 
    else
      Sig <= Sig + 1 ;
    end if ; 
  end procedure Increment ;
  
  procedure WaitForToggle ( signal Sig : In integer ) is
  begin
    wait on Sig ;
  end procedure WaitForToggle ;
  
  
  
  ------------------------------------------------------------
  -- WaitForBarrier
  --   Barrier Synchronization
  --   Multiple processes call it, it finishes when all have called it
  ------------------------------------------------------------
  procedure WaitForBarrier ( signal Sig : InOut std_logic ) is
  begin
    Sig <= 'H' ; 
    -- Wait until all processes set Sig to H  
    -- Level check not necessary since last value /= H yet
    wait until Sig = 'H' ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= '0' ;
    wait for 0 ns ; 
  end procedure WaitForBarrier ; 

  procedure WaitForBarrier ( signal Sig : InOut std_logic ; signal TimeOut : std_logic ; constant Polarity : in std_logic := '1') is
  begin
    Sig <= 'H' ; 
    -- Wait until all processes set Sig to H  
    -- Level check not necessary since last value /= H yet
    wait until Sig = 'H' or TimeOut = Polarity ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= '0' ;
    wait for 0 ns ; 
  end procedure WaitForBarrier ; 

  procedure WaitForBarrier ( signal Sig : InOut std_logic ; constant TimeOut : time ) is
  begin
    Sig <= 'H' ; 
    -- Wait until all processes set Sig to H  
    -- Level check not necessary since last value /= H yet
    wait until Sig = 'H' for TimeOut ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= '0' ;
    wait for 0 ns ; 
  end procedure WaitForBarrier ; 

  ------------------------------------------------------------
  -- resolved_barrier 
  -- summing resolution used in conjunction with integer based barriers
  function resolved_barrier ( s : integer_vector ) return integer is 
    variable result : integer := 0 ; 
  begin
    for i in s'RANGE loop
      if s(i) /= integer'left then 
        result := s(i) + result;
      else 
        result := s(i) + 1;  -- removes the initialization requirement
      end if ;
    end loop ;
    return result ; 
  end function resolved_barrier ; 

  -- Usage of integer barriers requires resolved_barrier. Initialization to 1 recommended, but not required
  --   signal barrier1 : resolved_barrier integer := 1 ;     -- using the resolution function
  --   signal barrier2 : integer_barrier := 1 ;              -- using the subtype that already applies the resolution function
  procedure WaitForBarrier ( signal Sig : InOut integer ) is
  begin
    Sig <= 0 ; 
    -- Wait until all processes set Sig to 0  
    -- Level check not necessary since last value /= 0 yet
    wait until Sig = 0  ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= 1 ;
    wait for 0 ns ; 
  end procedure WaitForBarrier ; 

  procedure WaitForBarrier ( signal Sig : InOut integer ; signal TimeOut : std_logic ; constant Polarity : in std_logic := '1') is
  begin
    Sig <= 0 ; 
    -- Wait until all processes set Sig to 0  
    -- Level check not necessary since last value /= 0 yet
    wait until Sig = 0 or TimeOut = Polarity ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= 1 ;
    wait for 0 ns ; 
  end procedure WaitForBarrier ; 

  procedure WaitForBarrier ( signal Sig : InOut integer ; constant TimeOut : time ) is
  begin
    Sig <= 0 ; 
    -- Wait until all processes set Sig to 0  
    -- Level check not necessary since last value /= 0 yet
    wait until Sig = 0 for TimeOut ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= 1 ;
    wait for 0 ns ; 
  end procedure WaitForBarrier ; 
  
  -- Using separate signals
  procedure WaitForBarrier2 ( signal SyncOut : out std_logic ; signal SyncIn : in  std_logic ) is
  begin
    -- Activate Rdy 
    SyncOut <= '1' ; 
    -- Make sure our Rdy is seen
    wait for 0 ns ; 
    -- Wait until other process' Rdy is at level 1
    if SyncIn /= '1' then 
       wait until SyncIn = '1' ;
    end if ;
    -- Deactivate Rdy
    SyncOut <= '0' ;
  end procedure WaitForBarrier2 ;

  procedure WaitForBarrier2 ( signal SyncOut : out std_logic ; signal SyncInV : in  std_logic_vector ) is
    constant ALL_ONE : std_logic_vector(SyncInV'Range) := (others => '1');
  begin
    -- Activate Rdy 
    SyncOut <= '1' ; 
    -- Make sure our Rdy is seen
    wait for 0 ns ; 
    -- Wait until all other process' Rdy is at level 1
    if SyncInV /= ALL_ONE then 
       wait until SyncInV = ALL_ONE ;
    end if ;
    -- Deactivate Rdy
    SyncOut <= '0' ;
  end procedure WaitForBarrier2 ;

  
  ------------------------------------------------------------
  -- WaitForClock
  --   Sync to Clock - after a delay, after a number of clocks
  ------------------------------------------------------------
  procedure WaitForClock ( signal Clk : in std_logic ;  constant Delay : in time ) is
  begin
    if delay > t_sim_resolution then
      wait for delay - t_sim_resolution ; 
    end if ; 
    wait until Clk = CLK_ACTIVE ;
  end procedure WaitForClock ;  

  procedure WaitForClock ( signal Clk : in std_logic ;  constant NumberOfClocks : in integer := 1) is
  begin
    for i in 1 to NumberOfClocks loop 
      wait until Clk = CLK_ACTIVE ;
    end loop ;
  end procedure WaitForClock ;  
  
  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in boolean ) is 
  begin
    wait on Clk until Clk = CLK_ACTIVE and Enable ;
  end procedure WaitForClock ;   

  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in std_logic ; constant Polarity : std_logic := '1' ) is
  begin
    wait on Clk until Clk = CLK_ACTIVE and Enable = Polarity ;
  end procedure WaitForClock ;   

  
  ------------------------------------------------------------
  -- WaitForLevel
  --   Find a signal at a level
  ------------------------------------------------------------
  procedure WaitForLevel ( signal A : in boolean ) is 
  begin
    if not A then 
      wait until A ;
    end if ; 
  end procedure WaitForLevel ; 
  
  procedure WaitForLevel ( signal A : in std_logic ; Polarity : std_logic := '1' ) is 
  begin
    if A /= Polarity then 
      -- wait on A until A = Polarity ;
      if Polarity = '1' then 
        wait until A = '1' ; 
      else
        wait until A = '0' ;
      end if ; 
    end if ; 
  end procedure WaitForLevel ; 

  
  ------------------------------------------------------------
  -- CreateClock,  CreateReset
  --   Note these do not exit
  ------------------------------------------------------------
  procedure CreateClock ( 
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
      wait for period - 1 ns ; -- allows after on future Clk <= '0'
      loop 
        Clk <= '0' after 1 ns, '1' after LOW_TIME + 1 ns ; 
        wait for period ; 
      end loop ; 
    end if ; 
  end procedure CreateClock ; 
  
  procedure CheckClockPeriod ( 
    constant AlertLogID : AlertLogIDType ; 
    signal   Clk        : in  std_logic ; 
    constant Period     : time ;
    constant ClkName    : string := "Clock" ;
    constant HowMany    : integer := 5
  ) is 
    variable LastLogTime, ObservedPeriod : time ; 
  begin
    wait until Clk = CLK_ACTIVE ; 
    LastLogTime := now ;
    -- Check First HowMany clocks
    for i in 1 to HowMany loop 
      wait until Clk = CLK_ACTIVE ; 
      ObservedPeriod := now - LastLogTime ; 
      AffirmIf(AlertLogID, ObservedPeriod = Period, 
         "CheckClockPeriod: " & ClkName & " Period: " & to_string(ObservedPeriod) & 
         " = Expected " & to_string(Period)) ;
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
    constant tpd         :     time 
  ) is 
  begin
    wait until Clk = CLK_ACTIVE ; 
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
  
  ------------------------------------------------------------
  -- Deprecated
  -- WaitForAck, StrobeAck
  --   Replaced by WaitForToggle and Toggle
  ------------------------------------------------------------
  procedure WaitForAck ( signal Ack : In  std_logic ) is
  begin
    -- Wait for Model to be done
    wait until Ack = '1' ;  
    wait for 0 ns ;
  end procedure ;

  procedure StrobeAck  ( signal Ack  : Out std_logic ) is
  begin
    -- Model done, drive rising edge on Ack
    Ack        <= '0' ;
    wait for 0 ns ;
    Ack        <= '1' ;
    wait for 0 ns ;
  end procedure ;


end TbUtilPkg ;

