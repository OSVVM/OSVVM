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
--    11/2024   2024.11    Replaced time with delay_length (0 to time'high) and integer with natural (in WaitForClock)
--    09/2024   2024.09    Updated predefined barriers s.t. there is a record of barriers named PredefinedBarrierType.  Names introduced in 2024.07 are now aliases
--    07/2024   2024.07    Added pre-defined barriers:  
--                             OsvvmTestInit, OsvvmResetDone, OsvvmVcInit, 
--                             OsvvmTestDone, TestDone
--                         For all procedures that use Clk, added a ClkActive input parameter and 
--                         defaulted it to CLOCK_ACTIVE.  Allows all to support either edge of clock.
--                         Former input parameters named polarity were renamed - breaking change if using named association
--                         Moved Clock and Reset support from TbUtilPkg to ClockResetPkg
--    01/2024   2024.01    IfElse function moved to IfElsePkg
--    09/2022   2022.09    Added WaitForTransactionOrIrq, FinishTransaction, and TransactionPending for AckType/RdyType
--    03/2022   2022.03    Added EdgeRose, EdgeFell, FindRisingEdge, FindFallingEdge.
--    01/2022   2022.01    Added MetaTo01.  Added WaitForTransaction without clock for RdyType/AckType and bit.
--    02/2021   2021.02    Added AckType, RdyType, RequestTransaction, WaitForTransaction for AckType/RdyType
--    12/2020   2020.12    Added IfElse functions for string and integer.
--                         Added Increment function for integer
--    01/2020   2020.01    Updated Licenses to Apache
--    08/2018   2018.08    Updated WaitForTransaction to allow 0 time transactions
--    04/2018   2018.04    Added RequestTransaction, WaitForTransaction, Toggle, WaitForToggle for bit.
--                         Added Increment and WaitForToggle for integer.
--    11/2016   2016.11    First Public Release Version
--                         Updated naming for consistency.
--    10/2013   2013.10    Split out Text Utilities
--    11/1999:  0.1        Initial revision
--                         Numerous revisions for VHDL Testbenches and Verification
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

  use work.ResolutionPkg.all ;
--  use work.AlertLogPkg.all ;
--  use work.TranscriptPkg.all ;
--  use work.OsvvmGlobalPkg.all ;

package TbUtilPkg is
  type stdulogic_indexed_by_stdulogic is array (std_ulogic) of std_ulogic;

  constant CLK_ACTIVE : std_logic := '1' ;

  constant OSVVM_SIM_RESOLUTION : delay_length := 1 ns ;  -- for simulators that do not support std_env.resolution_limit
--  constant OSVVM_SIM_RESOLUTION : delay_length := std.env.resolution_limit ;  -- VHDL-2008
  constant t_sim_resolution     : delay_length := OSVVM_SIM_RESOLUTION ;  -- VHDL-2008

  constant toggle_sl_table : stdulogic_indexed_by_stdulogic := (
      '0'     => '1',
      'L'     => '1',
      others  => '0'
  );

  ------------------------------------------------------------
  -- ZeroOneHot, OneHot
  --   OneHot:      return true if exactly one value is 1
  --   ZeroOneHot:  return false when more than one value is a 1
  ------------------------------------------------------------
  function OneHot ( constant A : in std_logic_vector ) return boolean ;
  function ZeroOneHot ( constant A : in std_logic_vector ) return boolean ;

  ------------------------------------------------------------
  -- EdgeRose, EdgeFell, FindRisingEdge, FindFallingEdge
  ------------------------------------------------------------
  function  EdgeRose ( signal C : in std_logic ) return boolean ;
  function  EdgeFell ( signal C : in std_logic ) return boolean ;
  function  EdgeActive ( signal C : in std_logic; A : std_logic ) return boolean ;
  function  ChangingEdge ( signal C : in std_logic; A : std_logic ) return boolean ; -- rising/falling edge that can be specified
  alias changing_edge is ChangingEdge [std_logic, std_logic return boolean] ; -- matching naming of rising_edge
  procedure FindRisingEdge ( signal C : in std_logic) ;
  procedure FindFallingEdge ( signal C : in std_logic ) ;
  procedure FindActiveEdge ( signal C : in std_logic; A : std_logic ) ;

  ------------------------------------------------------------
  -- MetaTo01
  --   Convert Meta values to 0
  ------------------------------------------------------------
  function MetaTo01 ( constant A : in std_ulogic ) return std_ulogic ;
  function MetaTo01 ( constant A : in std_ulogic_vector ) return std_ulogic_vector ;

  ------------------------------------------------------------
  -- RequestTransaction - WaitForTransaction
  --   RequestTransaction - Transaction initiation in transaction procedure
  --   WaitForTransaction - Transaction execution control in VC
  ------------------------------------------------------------
  ------------------------------------------------------------
  -- RequestTransaction - WaitForTransaction
  --   std_logic
  ------------------------------------------------------------
  procedure RequestTransaction (
    signal Rdy  : Out std_logic ;
    signal Ack  : In  std_logic
  ) ;

  procedure WaitForTransaction (
    signal Clk         : In  std_logic ;
    signal Rdy         : In  std_logic ;
    signal Ack         : Out std_logic ;
    constant ClkActive : In std_logic := CLK_ACTIVE
  ) ;

  -- Only for clockless models
  procedure WaitForTransaction (
    signal Rdy : In  std_logic ;
    signal Ack : Out std_logic
  ) ;

  ------------------------------------------------------------
  -- RequestTransaction - WaitForTransaction
  --   bit
  ------------------------------------------------------------
  procedure RequestTransaction (
    signal Rdy  : Out bit ;
    signal Ack  : In  bit
  ) ;

  procedure WaitForTransaction (
    signal Clk         : In  std_logic ;
    signal Rdy         : In  bit ;
    signal Ack         : Out bit ;
    constant ClkActive : In std_logic := CLK_ACTIVE
  ) ;
  
  -- Only for clockless models
  procedure WaitForTransaction (
    signal Rdy : in  bit ;
    signal Ack : out bit
  ) ;

  ------------------------------------------------------------
  -- RequestTransaction - WaitForTransaction
  --   integer
  ------------------------------------------------------------
  subtype RdyType is resolved_max integer range  0 to integer'high ;
  subtype AckType is resolved_max integer range -1 to integer'high ;

  procedure RequestTransaction (
    signal Rdy     : InOut RdyType ;
    signal Ack     : In    AckType
  ) ;

  procedure WaitForTransaction (
    signal Clk         : In    std_logic ;
    signal Rdy         : In    RdyType ;
    signal Ack         : InOut AckType ;
    constant ClkActive : In std_logic := CLK_ACTIVE
  ) ;

  -- Only for clockless models
  procedure WaitForTransaction (
    signal Rdy      : In    RdyType ;
    signal Ack      : InOut AckType
  );


  ------------------------------------------------------------
  -- Interrupt handling variations of WaitForTransaction 
  --   std_logic / std_logic 
  ------------------------------------------------------------
  procedure WaitForTransaction (
    signal   Clk            : In  std_logic ;
    signal   Rdy            : In  std_logic ;
    signal   Ack            : Out std_logic ;
    signal   TimeOut        : In  std_logic ;
    constant TimeOutActive  : In  std_logic := '1' ;
    constant ClkActive      : In std_logic := CLK_ACTIVE
  ) ;

  -- Intended for models that need to switch between instruction streams
  -- such as a CPU when interrupt is pending
  procedure WaitForTransactionOrIrq (
    signal Clk         : In  std_logic ;
    signal Rdy         : In  std_logic ;
    signal IntReq      : In  std_logic ;
    constant ClkActive : In  std_logic := CLK_ACTIVE
  ) ;

  -- Set Ack to Model starting value
  procedure StartTransaction  ( signal Ack : Out std_logic ) ;
  -- Set Ack to Model finishing value
  procedure FinishTransaction ( signal Ack : Out std_logic ) ;
  -- If a transaction is pending, return true
  function TransactionPending ( signal Rdy : In  std_logic ) return boolean ;

  ------------------------------------------------------------
  -- Interrupt handling variations of WaitForTransaction 
  --   RdyType/AckType 
  ------------------------------------------------------------
  -- Intended for models that need to switch between instruction streams
  -- such as a CPU when interrupt is pending
  procedure WaitForTransactionOrIrq (
    signal   Clk          : In  std_logic ;
    signal   Rdy          : In  RdyType ;
    signal   Ack          : In  AckType ;
    signal   IntReq       : In  std_logic ;
    constant IntReqActive : In  std_logic := '1' ;
    constant ClkActive    : In std_logic := CLK_ACTIVE
  ) ;

  -- StartTransaction not used, Ack is incremented at transaction completion
--  procedure StartTransaction  ( signal Ack : Out AckType ) ; 

  -- Increment Ack
  procedure FinishTransaction ( signal Ack : InOut AckType ) ;

  -- If a transaction is pending, return true
  --   Used to detect presence of transaction stream,
  --   such as an interrupt handler
  function TransactionPending (
    signal Rdy     : In  RdyType ;
    signal Ack     : In  AckType
  ) return boolean ;


  ------------------------------------------------------------
  -- Toggle, WaitForToggle
  --   Used for communicating between processes
  ------------------------------------------------------------
  procedure Toggle (
    signal Sig        : InOut std_logic ;
    constant DelayVal : delay_length
  ) ;
  procedure Toggle ( signal Sig : InOut std_logic ) ;
  procedure ToggleHS ( signal Sig : InOut std_logic ) ;
  function  IsToggle ( signal Sig : In std_logic ) return boolean ;
  procedure WaitForToggle ( signal Sig : In std_logic ) ;

  -- Bit type versions
  procedure Toggle ( signal Sig : InOut bit ; constant DelayVal : delay_length ) ;
  procedure Toggle ( signal Sig : InOut bit ) ;
  procedure ToggleHS ( signal Sig : InOut bit ) ;
  function  IsToggle ( signal Sig : In bit ) return boolean ;
  procedure WaitForToggle ( signal Sig : In bit ) ;

  -- Integer type versions
  procedure Increment ( signal Sig : InOut integer ; constant RollOverValue : in integer := 0) ;
  function  Increment (constant Sig : in integer ; constant Amount : in integer := 1) return integer ;
  procedure WaitForToggle ( signal Sig : In integer ) ;

  ------------------------------------------------------------
  -- WaitForBarrier
  --   Barrier Synchronization
  --   Multiple processes call it, it finishes when all have called it
  ------------------------------------------------------------
  -- resolved_barrier : summing resolution used in conjunction with integer based barriers
  function resolved_barrier ( s : integer_vector ) return integer ;
  -- integer'low+1 is for Xilinx.   It should be just integer'low
  subtype  BarrierType is resolved_barrier integer range integer'low+1 to integer'high ;
--  alias    integer_barrier is BarrierType ; 
  subtype  integer_barrier is BarrierType ; 
  -- Usage of integer barriers requires resolved_barrier.  Usage of BarrierType is recommended.
  --   signal barrier1 : BarrierType ;                    -- Recommended
  --   signal barrier2 : resolved_barrier integer := 1 ;  -- Supported
  procedure WaitForBarrier ( signal Sig : InOut BarrierType ) ;
  procedure WaitForBarrier ( signal Sig : InOut BarrierType ; signal TimeOut : std_logic ; constant TimeOutActive : in std_logic := '1') ;
  procedure WaitForBarrier ( signal Sig : InOut BarrierType ; constant TimeOut : delay_length ) ;
  -- std_logic support
  procedure WaitForBarrier ( signal Sig : InOut std_logic ) ;
  procedure WaitForBarrier ( signal Sig : InOut std_logic ; signal TimeOut : std_logic ; constant TimeOutActive : in std_logic := '1') ;
  procedure WaitForBarrier ( signal Sig : InOut std_logic ; constant TimeOut : delay_length ) ;
  -- Using separate signals
  procedure WaitForBarrier2 ( signal SyncOut : out std_logic ; signal SyncIn : in  std_logic ) ;
  procedure WaitForBarrier2 ( signal SyncOut : out std_logic ; signal SyncInV : in  std_logic_vector ) ;

  ------------------------------------------------------------
  -- Predefined barrier signals
  ------------------------------------------------------------
  type PredefinedBarrierType is record 
    ResetStarted   : BarrierType ; 
    ResetDone      : BarrierType ; 
    TestInit       : BarrierType ; 
    TestDone       : BarrierType ; 
    VcInit         : BarrierType ; 
  end record PredefinedBarrierType ; 
  signal Barrier : PredefinedBarrierType ;
  
  alias OsvvmResetStarted  : BarrierType is Barrier.ResetStarted ; 
  alias OsvvmResetDone     : BarrierType is Barrier.ResetDone ; 
  alias OsvvmTestInit      : BarrierType is Barrier.TestInit ; 
  alias OsvvmTestDone      : BarrierType is Barrier.TestDone ; 
  alias TestDone           : BarrierType is Barrier.TestDone ; 
  alias OsvvmVcInit        : BarrierType is Barrier.VcInit ; 

  ------------------------------------------------------------
  -- WaitForClock
  --   Sync to Clock - after a delay, after a number of clocks
  ------------------------------------------------------------
  procedure WaitForClock ( signal Clk : in std_logic ;  constant Delay : in delay_length ; constant ClkActive : in std_logic := CLK_ACTIVE) ;
  procedure WaitForClock ( signal Clk : in std_logic ;  constant NumberOfClocks : in natural := 1 ; constant ClkActive : in std_logic := CLK_ACTIVE) ;
  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in boolean ; constant ClkActive : in std_logic := CLK_ACTIVE) ;
  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in std_logic ; constant EnableActive : std_logic := '1' ; constant ClkActive : in std_logic := CLK_ACTIVE) ;

  ------------------------------------------------------------
  -- WaitForLevel
  --   Find a signal at a level
  ------------------------------------------------------------
  procedure WaitForLevel ( signal A : in boolean ) ;
  procedure WaitForLevel ( signal A : in std_logic ; Level : std_logic := '1' ) ;

  procedure WaitForLevel ( signal A : in boolean;   constant TimeOut : delay_length);
  procedure WaitForLevel ( signal A : in std_logic; constant TimeOut : delay_length; constant Level : std_logic := '1');

  procedure WaitForLevel ( signal A : in boolean;   constant TimeOut : delay_length; variable TimeOutReached : out boolean);
  procedure WaitForLevel ( signal A : in std_logic; constant TimeOut : delay_length; variable TimeOutReached : out boolean; constant Level : std_logic := '1');
  alias WaitForLevelTimeOut is WaitForLevel [boolean, delay_length, boolean] ;
  alias WaitForLevelTimeOut is WaitForLevel [std_logic, delay_length, boolean, std_logic] ;

  ------------------------------------------------------------
  --  Deprecated subprogram names
  --    Maintaining backward compatibility using aliases
  ------------------------------------------------------------
  -- History of RequestTransaction / WaitForTransaction
  alias RequestAction is RequestTransaction [std_logic, std_logic] ;
  alias WaitForRequest is WaitForTransaction [std_logic, std_logic, std_logic, std_logic] ;
  -- History of WaitForToggle
  alias WaitOnToggle is WaitForToggle [std_logic] ;
  -- History of WaitForBarrier
  alias WayPointBlock is WaitForBarrier [std_logic] ;
  alias SyncTo is WaitForBarrier2[std_logic, std_logic] ;
  alias SyncTo is WaitForBarrier2[std_logic, std_logic_vector] ;
  -- Backward compatible name
  alias SyncToClk is WaitForClock [std_logic, delay_length, std_logic] ;

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
  -- EdgeRose, EdgeFell, FindRisingEdge, FindFallingEdge
  ------------------------------------------------------------
  function EdgeRose ( signal C : in std_logic ) return boolean is
  begin
    return  to_x01(C)='1' and to_x01(C'last_value)='0' and C'last_event= 0 sec ;
  end function EdgeRose ;

  function EdgeFell ( signal C : in std_logic ) return boolean is
  begin
    return  to_x01(C)='0' and to_x01(C'last_value)='1' and C'last_event= 0 sec ;
  end function EdgeFell ;

  function EdgeActive ( signal C : in std_logic; A : std_logic ) return boolean is
  begin
    return  to_x01(C)=A and to_x01(C'last_value)=not A and C'last_event= 0 sec ;
  end function EdgeActive ;

  function ChangingEdge ( signal C : in std_logic; A : std_logic ) return boolean is
  begin
    return  to_x01(C)=A and to_x01(C'last_value)=not A and C'event ;
  end function ChangingEdge ;

  procedure FindRisingEdge ( signal C : in std_logic) is
  begin
    if not EdgeRose(C) then
      wait until rising_edge(C) ;
    end if ;
  end procedure FindRisingEdge ;

--!!  Rejected as the semantic is confusing
--!!  procedure FindRisingEdge ( signal C : in std_logic; Count : integer) is
--!!    variable Start : integer := 1 ;
--!!  begin
--!!    if EdgeRose(C) then
--!!      Start := 2 ;
--!!    end if
--!!    for i in Start to Count loop
--!!      wait until rising_edge(C) ;
--!!    end loop ;
--!!  end procedure FindRisingEdge ;

  procedure FindFallingEdge ( signal C : in std_logic ) is
  begin
    if not EdgeFell(C) then
      wait until falling_edge(C) ;
    end if ;
  end procedure FindFallingEdge ;

  procedure FindActiveEdge ( signal C : in std_logic; A : std_logic ) is
  begin
    if A = '1' then
      FindRisingEdge(C) ;
    else
      FindFallingEdge(C) ;
    end if ;
  end procedure FindActiveEdge ;


  ------------------------------------------------------------
  -- MetaTo01
  --   Convert Meta values to 0
  ------------------------------------------------------------
  constant MetaTo01Table : stdulogic_indexed_by_stdulogic := (
      '1'     => '1',
      'H'     => '1',
      others  => '0'
  );

  function MetaTo01 ( constant A : in std_ulogic ) return std_ulogic is
  begin
    return MetaTo01Table(A) ;
  end function MetaTo01 ;

  function MetaTo01 ( constant A : in std_ulogic_vector ) return std_ulogic_vector is
    variable result : std_logic_vector(A'range) ;
  begin
    for i in A'range loop
      result(i) := MetaTo01Table(A(i)) ;
    end loop ;
    return result ;
  end function MetaTo01 ;


  ------------------------------------------------------------
  -- RequestTransaction - WaitForTransaction
  --   RequestTransaction - Transaction initiation in transaction procedure
  --   WaitForTransaction - Transaction execution control in VC
  ------------------------------------------------------------
  ------------------------------------------------------------
  -- RequestTransaction - WaitForTransaction
  --   std_logic
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

  procedure WaitForTransaction (
    signal Clk         : In  std_logic ;
    signal Rdy         : In  std_logic ;
    signal Ack         : Out std_logic ;
    constant ClkActive : In std_logic := CLK_ACTIVE
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
      wait until Clk = ClkActive ;
    end if ;
    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
    wait for 0 ns ; -- Allow transactions without time passing
  end procedure WaitForTransaction ;

  -- Only for clockless models 
  procedure WaitForTransaction (
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic
  ) is
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
  -- RequestTransaction - WaitForTransaction
  --   bit
  ------------------------------------------------------------
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

  procedure WaitForTransaction (
    signal Clk         : In  std_logic ;
    signal Rdy         : In  bit ;
    signal Ack         : Out bit ;
    constant ClkActive : In std_logic := CLK_ACTIVE
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
      wait until Clk = ClkActive ;
    end if ;
    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
    wait for 0 ns ; -- Allow transactions without time passing
  end procedure WaitForTransaction ;

  -- Only for clockless models 
  procedure WaitForTransaction (
    signal Rdy  : in  bit ;
    signal Ack  : out bit
  ) is
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
  -- RequestTransaction - WaitForTransaction
  --   integer
  ------------------------------------------------------------
  procedure RequestTransaction (
    signal Rdy     : InOut RdyType ;
    signal Ack     : In    AckType
  ) is
  begin
    -- Initiate Transaction Request
    Rdy <= Increment(Rdy) ;
    wait for 0 ns ;

    -- Wait for Transaction Completion
    wait until Rdy = Ack ;
  end procedure RequestTransaction ;

  procedure WaitForTransaction (
    signal Clk         : In    std_logic ;
    signal Rdy         : In    RdyType ;
    signal Ack         : InOut AckType ;
    constant ClkActive : In std_logic := CLK_ACTIVE
  ) is
  begin
    -- End of Previous Cycle.  Signal Done
    Ack <= Increment(Ack) ;

    -- Find Start of Transaction
    wait until Ack /= Rdy ;

    -- Align to clock if needed (not back-to-back transactions)
    if not EdgeActive(Clk, ClkActive) then
      wait until Clk = ClkActive ;
    end if ;
  end procedure WaitForTransaction ;

  -- Only for clockless models 
  procedure WaitForTransaction (
    signal Rdy      : In    RdyType ;
    signal Ack      : InOut AckType
  ) is
  begin
    -- End of Previous Cycle.  Signal Done
    Ack <= Increment(Ack) ;

    -- Find Start of Transaction
    wait until Ack /= Rdy ;
  end procedure WaitForTransaction ;

  ------------------------------------------------------------
  -- WaitForTransaction 
  --   Specializations for interrupt handling
  ------------------------------------------------------------
  procedure WaitForTransaction (
    signal   Clk            : In  std_logic ;
    signal   Rdy            : In  std_logic ;
    signal   Ack            : Out std_logic ;
    signal   TimeOut        : In  std_logic ;
    constant TimeOutActive  : In  std_logic := '1' ;
    constant ClkActive      : In std_logic := CLK_ACTIVE
  ) is
    variable AckTime : time ;
    variable FoundRdy : boolean ;
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6
    AckTime    := NOW ;
    -- Find Ready or Time out
    wait for 0 ns ; -- Allow Rdy from previous cycle to clear
    if (Rdy /= '1' and TimeOut /= TimeOutActive) then
      wait until Rdy = '1' or TimeOut = TimeOutActive ;
    end if ;
    FoundRdy := Rdy = '1' ;
    -- align to clock if Rdy or TimeOut does not happen within delta cycles from Ack
    if NOW /= AckTime then
      wait until Clk = ClkActive ;
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
    signal Clk         : In  std_logic ;
    signal Rdy         : In  std_logic ;
    signal IntReq      : In  std_logic ;
    constant ClkActive : In std_logic := CLK_ACTIVE
  ) is
    variable AckTime : time ;
    constant IntReqActive : std_logic := '1' ;
  begin
    AckTime    := NOW ;
    -- Find Ready or Time out
    wait for 0 ns ; -- allow Rdy from previous cycle to clear
    if (Rdy /= '1' and IntReq /= IntReqActive) then
      wait until Rdy = '1' or IntReq = IntReqActive ;
    else
      wait for 0 ns ; -- allow Ack to update
   end if ;
    -- align to clock if Rdy or IntReq does not happen within delta cycles from Ack
    if NOW /= AckTime then
      wait until Clk = ClkActive ;
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

  ------------------------------------------------------------
  -- WaitForTransaction - RdyType/AckType 
  --   Specializations for interrupt handling
  ------------------------------------------------------------
  -- Intended for models that need to switch between instruction streams
  -- such as a CPU when interrupt is pending
  procedure WaitForTransactionOrIrq (
    signal   Clk          : In  std_logic ;
    signal   Rdy          : In  RdyType ;
    signal   Ack          : In  AckType ;
    signal   IntReq       : In  std_logic ;
    constant IntReqActive : In  std_logic := '1' ;
    constant ClkActive    : In std_logic := CLK_ACTIVE
  ) is
  begin
    if (Ack = Rdy and IntReq /= IntReqActive) then
      wait until Ack /= Rdy or IntReq = IntReqActive ;
   end if ;
    -- Align to clock if needed (not back-to-back transactions)
    if not EdgeActive(Clk, ClkActive) then
      wait until Clk = ClkActive ;
    end if ;
  end procedure ;

  -- Set Ack to Model starting value
  -- Pairs with WaitForTransactionOrIrq above
--  procedure StartTransaction  ( signal Ack : Out AckType ) is
--  begin
--    Null ; -- Do nothing
--  end procedure StartTransaction ;

  -- Set Ack to Model finishing value
  -- Pairs with WaitForTransactionOrIrq above
  procedure FinishTransaction ( signal Ack : InOut AckType ) is
  begin
    -- End of Cycle
    Ack <= Increment(Ack) ;
    wait for 0 ns ; -- allow Ack to update - required for WaitForTransactionOrIrq
  end procedure FinishTransaction ;

  -- If a transaction is pending, return true
  --   Used to detect presence of transaction stream,
  --   such as an interrupt handler
  function TransactionPending (
    signal Rdy     : In  RdyType ;
    signal Ack     : In  AckType
  ) return boolean is
  begin
    return Rdy /= Ack ;
  end function TransactionPending ;


  ------------------------------------------------------------
  -- Toggle, WaitForToggle
  --   Used for communicating between processes
  ------------------------------------------------------------
  procedure Toggle (
    signal Sig        : InOut std_logic ;
    constant DelayVal : delay_length
  ) is
    variable iDelayVal : delay_length ;
  begin
    if DelayVal > OSVVM_SIM_RESOLUTION then
      iDelayVal := DelayVal - OSVVM_SIM_RESOLUTION ;
    else
      iDelayVal := 0 sec ;
--      AlertIf(OSVVM_ALERTLOG_ID, DelayVal < 0 sec, "osvvm.TbUtilPkg.Toggle: Delay value < 0 ns") ;
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
  procedure Toggle ( signal Sig : InOut bit ; constant DelayVal : delay_length ) is
    variable iDelayVal : delay_length ;
  begin
    if DelayVal > OSVVM_SIM_RESOLUTION then
      iDelayVal := DelayVal - OSVVM_SIM_RESOLUTION ;
    else
      iDelayVal := 0 sec ;
--      AlertIf(OSVVM_ALERTLOG_ID, DelayVal < 0 sec, "osvvm.TbUtilPkg.Toggle: Delay value < 0 ns", WARNING) ;
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
  procedure Increment (signal Sig : InOut integer ; constant RollOverValue : in integer := 0) is
  begin
--!!    if Sig = integer'high then
    if Sig = 2**30-1 then -- for consistency with function increment
      Sig <= RollOverValue ;
    else
      Sig <= Sig + 1 ;
    end if ;
  end procedure Increment ;

  function Increment (constant Sig : in integer ; constant Amount : in integer := 1) return integer is
  begin
--! Sig = integer'high - Amount + 1 ;
    return (Sig + Amount) mod 2**30 ;
  end function Increment ;

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

  procedure WaitForBarrier ( signal Sig : InOut std_logic ; signal TimeOut : std_logic ; constant TimeOutActive : in std_logic := '1') is
  begin
    Sig <= 'H' ;
    -- Wait until all processes set Sig to H
    -- Level check not necessary since last value /= H yet
    wait until Sig = 'H' or TimeOut = TimeOutActive ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= '0' ;
    wait for 0 ns ;
  end procedure WaitForBarrier ;

  procedure WaitForBarrier ( signal Sig : InOut std_logic ; constant TimeOut : delay_length ) is
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
      if s(i) /= 0 then
        result := result + 1;  -- removes the initialization requirement
      end if ;
    end loop ;
    return result ;
  end function resolved_barrier ;

  -- Usage of integer barriers requires resolved_barrier.  Usage of BarrierType is recommended.
  --   signal barrier1 : BarrierType ;                    -- Recommended
  --   signal barrier2 : resolved_barrier integer := 1 ;  -- Supported
  procedure WaitForBarrier ( signal Sig : InOut BarrierType ) is
  begin
    Sig <= 0 ;
    -- Wait until all processes set Sig to 0
    -- Level check not necessary since last value /= 0 yet
    wait until Sig = 0  ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= 1 ;
    wait for 0 ns ;
  end procedure WaitForBarrier ;

  procedure WaitForBarrier ( signal Sig : InOut BarrierType ; signal TimeOut : std_logic ; constant TimeOutActive : in std_logic := '1') is
  begin
    Sig <= 0 ;
    -- Wait until all processes set Sig to 0
    -- Level check not necessary since last value /= 0 yet
    wait until Sig = 0 or TimeOut = TimeOutActive ;
    -- Deactivate and propagate to allow back to back calls
    Sig <= 1 ;
    wait for 0 ns ;
  end procedure WaitForBarrier ;

  procedure WaitForBarrier ( signal Sig : InOut BarrierType ; constant TimeOut : delay_length ) is
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
  procedure WaitForClock ( signal Clk : in std_logic ;  constant Delay : in delay_length ; constant ClkActive : in std_logic := CLK_ACTIVE) is
  begin
    if delay > OSVVM_SIM_RESOLUTION then
      wait for delay - OSVVM_SIM_RESOLUTION ;
    end if ;
    wait until Clk = ClkActive ;
  end procedure WaitForClock ;

  procedure WaitForClock ( signal Clk : in std_logic ;  constant NumberOfClocks : in natural := 1 ; constant ClkActive : in std_logic := CLK_ACTIVE) is
  begin
    for i in 1 to NumberOfClocks loop
      wait until Clk = ClkActive ;
    end loop ;
  end procedure WaitForClock ;

  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in boolean ; constant ClkActive : in std_logic := CLK_ACTIVE) is
  begin
    wait on Clk until Clk = ClkActive and Enable ;
  end procedure WaitForClock ;

  procedure WaitForClock ( signal Clk : in std_logic ;  signal Enable : in std_logic ; constant EnableActive : std_logic := '1' ; constant ClkActive : in std_logic := CLK_ACTIVE) is
  begin
    wait on Clk until Clk = ClkActive and Enable = EnableActive ;
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

  procedure WaitForLevel ( signal A : in std_logic ; Level : std_logic := '1' ) is
  begin
    if A /= Level then
      -- wait on A until A = Level ;
      if Level = '1' then
        wait until A = '1' ;
      else
        wait until A = '0' ;
      end if ;
    end if ;
  end procedure WaitForLevel ;

  ------------------------------------------------------------
  -- WaitForLevel with TimeOut
  --   Find a signal at a level or simply pass after timeout
  ------------------------------------------------------------
  procedure WaitForLevel ( signal A : in boolean; constant TimeOut : delay_length) is 
  begin
    if not A then 
      wait until A for TimeOut;
    end if ; 
  end procedure WaitForLevel ; 
  
  procedure WaitForLevel ( signal A : in std_logic; constant TimeOut : delay_length; constant Level : std_logic := '1') is 
  begin
    if A /= Level then 
	    wait until A = Level for TimeOut; 
    end if ; 
  end procedure WaitForLevel ; 
				
  procedure WaitForLevel ( signal A : in boolean; constant TimeOut : delay_length; variable TimeOutReached : out boolean) is 
  begin
    WaitForLevel(A, TimeOut) ; 
    TimeOutReached := not A ; 
  end procedure WaitForLevel ; 
  
  procedure WaitForLevel ( signal A : in std_logic; constant TimeOut : delay_length; variable TimeOutReached : out boolean; constant Level : std_logic := '1') is 
  begin
    WaitForLevel(A, TimeOut, Level) ; 
    TimeOutReached := A /= Level ; 
  end procedure WaitForLevel ; 

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
