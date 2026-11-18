--
--  File Name:         IdFifoPtPkg.vhd
--  Design Unit Name:  IdFifoPtPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Package Defines
--      Fifo for OSVVM singleton IDs (so they can be released) 
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.05    Initial revision.  
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2026 by SynthWorks Design Inc.  
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

use work.AlertLogPkg.all ;

package IdFifoPtPkg is 
  subtype ElementType is integer ; 

  type IdFifoPType is protected
    procedure Push(Item : in ElementType) ;
    impure function Pop return ElementType ; 
    impure function IsEmpty return boolean ; 
  end protected IdFifoPType ;

end package IdFifoPtPkg ;

package body IdFifoPtPkg is
  ------------------------------------------------------------
  type IdFifoPType is protected body
    type FifoRecType ;

    type FifoRecPtrType is access FifoRecType ;

    type FifoRecType is record
      Item    : ElementType ; 
      NextPtr : FifoRecPtrType ;
    end record ; 

    -- Head and Tail of FIFO
    variable HeadPtr, TailPtr : FifoRecPtrType := NULL ; 

    -- PopList holds FifoRecType objects rather than deallocating 
    -- this list will ebb and flow in size - but will not 
    -- exceed the number of Ids allocated.
    -- It is a LIFO (push front, pop front)
    variable PopListPtr : FifoRecPtrType := NULL ; 

    ------------------------------------------------------------
    procedure Push(Item : in ElementType) is
    begin
      If HeadPtr = NULL then 
        if PopListPtr = NULL then 
          -- Get new object
          HeadPtr    := new FifoRecType ; 
        else
          -- Recycle an old one
          HeadPtr    := PopListPtr ; 
          PopListPtr := PopListPtr.NextPtr ; 
        end if ; 
        TailPtr      := HeadPtr ; 
      else
        if PopListPtr = NULL then 
          -- Get new object
          TailPtr.NextPtr := new FifoRecType ; 
        else 
          -- Recycle an old one
          TailPtr.NextPtr := PopListPtr ; 
          PopListPtr := PopListPtr.NextPtr ; 
        end if ; 
        TailPtr := TailPtr.NextPtr ; 
      end if ; 
      TailPtr.Item := Item ; 
    end procedure push ; 

    ------------------------------------------------------------
    impure function Pop return ElementType is
      variable Result      : integer ; 
      variable MoveItemPtr : FifoRecPtrType ; 
    begin 
      if HeadPtr = NULL then 
        -- Failure is not tolerated.  Check IsEmpty first.
        Alert("FifoPtPkg_int: Pop with no elements", FAILURE) ;
        return -1 ; 
      end if ; 
      Result := HeadPtr.Item ; 
      -- Remove Head Object from HeadPtr
      MoveItemPtr := HeadPtr ; 
      HeadPtr     := HeadPtr.NextPtr ; 
      -- Add Head Object to PopListPtr
      MoveItemPtr.NextPtr := PopListPtr ; 
      PopListPtr := MoveItemPtr ; 
      return Result ;
    end function Pop ; 

    ------------------------------------------------------------
    impure function IsEmpty return boolean is
    begin
      return HeadPtr = NULL ; 
    end function IsEmpty ;
  end protected body IdFifoPType ;

end package body IdFifoPtPkg ;