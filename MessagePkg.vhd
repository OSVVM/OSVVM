--
--  File Name:         MessagePkg.vhd
--  Design Unit Name:  MessagePkg
--  Revision:          STANDARD VERSION,  revision 2014.01
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Package Defines
--      Data structure for name and message handling. 
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Latest standard version available at:
--        http://www.SynthWorks.com/downloads
--
--  Revision History:
--    Date      Version    Description
--    06/2010:  0.1        Initial revision
--
--
--  Copyright (c) 2010 - 2013 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  This source file is free software; you can redistribute it
--  and/or modify it under the terms of the ARTISTIC License
--  as published by The Perl Foundation; either version 2.0 of
--  the License, or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.math_real.all ;
use std.textio.all ;

package MessagePkg is

  type MessagePType is protected

    procedure SetName (NameIn : String) ;
    impure function GetName return string ;
    impure function IsSetName return boolean ; 
    
    procedure SetMessage (MessageIn : String) ;
    impure function GetMessage (ItemNumber : integer) return string ; 
    impure function GetMessageCount return integer ; 

    procedure DeallocateName ; -- clear name
    procedure DeallocateMessage ; -- clear message
    procedure Deallocate ; -- clear all
    
  end protected MessagePType ;

end package MessagePkg ;
package body MessagePkg is

  -- Local Data Structure Types
  type LineArrayType is array (natural range <>) of line ; 
  type LineArrayPtrType is access LineArrayType ;
    
  ------------------------------------------------------------
  -- Local.  Get first word from a string
  function GetWord (Message : string) return string is
  ------------------------------------------------------------
    alias aMessage : string( 1 to Message'length) is Message ; 
  begin
    for i in aMessage'range loop 
      if aMessage(i) = ' ' or aMessage(i) = HT then 
        return aMessage(1 to i-1) ; 
      end if ; 
    end loop ; 
    return aMessage ;
  end function GetWord ; 
      

  type MessagePType is protected body
  
    variable NamePtr   : line := new string'("") ;
    variable MessageCount : integer := 0 ; 
    constant INITIAL_ITEM_COUNT : integer := 25 ; 
    variable MaxMessageCount : integer := INITIAL_ITEM_COUNT ; 
    variable MessagePtr : LineArrayPtrType := new LineArrayType(1 to INITIAL_ITEM_COUNT) ; 

    ------------------------------------------------------------
    procedure SetName (NameIn : String) is
    ------------------------------------------------------------
    begin
      deallocate(NamePtr) ;
      NamePtr := new string'(NameIn) ;
    end procedure SetName ;

    ------------------------------------------------------------
    impure function GetName return string is
    ------------------------------------------------------------
    begin
      if NamePtr.all /= "" or MessagePtr(1) = NULL then 
        return NamePtr.all ;
      else
        return GetWord( MessagePtr(1).all ) ; 
      end if ;
    end function GetName ;

    ------------------------------------------------------------
    impure function IsSetName return boolean is 
    ------------------------------------------------------------
    begin
      return NamePtr.all /= "" ; 
    end function IsSetName ;      

    ------------------------------------------------------------
    procedure SetMessage (MessageIn : String) is
    ------------------------------------------------------------
      variable NamePtr : line ;
      variable OldMaxMessageCount : integer ;
      variable OldMessagePtr : LineArrayPtrType ; 
    begin
      MessageCount := MessageCount + 1 ; 
      if MessageCount > MaxMessageCount then
        OldMaxMessageCount := MaxMessageCount ; 
        MaxMessageCount := OldMaxMessageCount * 2 ; 
        OldMessagePtr := MessagePtr ;
        MessagePtr := new LineArrayType(1 to MaxMessageCount) ; 
        for i in 1 to OldMaxMessageCount loop
          MessagePtr(i) := OldMessagePtr(i) ; 
        end loop ;
        Deallocate( OldMessagePtr ) ;
      end if ; 
      MessagePtr(MessageCount) := new string'(MessageIn) ;
    end procedure SetMessage ; 

    ------------------------------------------------------------
    impure function GetMessage (ItemNumber : integer) return string is
    ------------------------------------------------------------
    begin
      if MessageCount > 0 then 
        if ItemNumber >= 1 and ItemNumber <= MessageCount then 
          return MessagePtr(ItemNumber).all ; 
        else
          report LF & "%% MessagePkg:MessagePType.GetMessage input value out of range" severity failure ; 
          return "" ; -- error if this happens 
        end if ; 
      else 
        return NamePtr.all ; 
      end if ;
    end function GetMessage ; 

    ------------------------------------------------------------
    impure function GetMessageCount return integer is 
    ------------------------------------------------------------
    begin
      return MessageCount ; 
    end function GetMessageCount ; 

    ------------------------------------------------------------
    procedure DeallocateName is  -- clear name
    ------------------------------------------------------------
    begin
      deallocate(NamePtr) ;
      NamePtr := new string'("") ;
    end procedure DeallocateName ;

    ------------------------------------------------------------
    procedure DeallocateMessage is  -- clear message
    ------------------------------------------------------------
      variable CurPtr : LineArrayPtrType ;
    begin
      for i in 1 to MessageCount loop 
        deallocate( MessagePtr(i) ) ; 
      end loop ; 
      MessageCount := 0 ; 
      -- Do NOT Do this: deallocate( MessagePtr ) ; 
    end procedure DeallocateMessage ;

    ------------------------------------------------------------
    procedure Deallocate is  -- clear all
    ------------------------------------------------------------
    begin
      DeallocateName ;
      DeallocateMessage ;
    end procedure Deallocate ;

  end protected body MessagePType ;

end package body MessagePkg ;


