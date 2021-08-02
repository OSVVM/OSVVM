--
--  File Name:         MessageListPkg.vhd
--  Design Unit Name:  MessageListPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Package Defines
--      Data structure for multi-line message
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2021   2021.07    Initial revision.  
--                         Written as a replacement for protected types (MessagePkg)
--                         to simplify usage in new data structure. 
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2021 by SynthWorks Design Inc.  
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
use std.textio.all ;

package MessageListPkg is
  type MessageStructType ; 
  type MessageStructPtrType is access MessageStructType ; 
  type MessageStructType is record
    Name    : line ; 
    NextPtr : MessageStructPtrType ; 
  end record MessageStructType ; 
  
  procedure SetMessage        (variable Message : inout MessageStructPtrType; Name : String) ;
  procedure WriteMessage      (variable buf : inout line; variable Message : inout MessageStructPtrType; prefix : string := "") ; 
  procedure WriteMessage      (file f : text; variable Message : inout MessageStructPtrType; prefix : string := "") ; 
  procedure GetMessageCount   (variable Message : inout MessageStructPtrType; variable Count : out integer) ;
  procedure DeallocateMessage (variable Message : inout MessageStructPtrType) ; 

end package MessageListPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body MessageListPkg is

  ------------------------------------------------------------
  procedure SetMessage (variable Message : inout MessageStructPtrType; Name : String) is
  ------------------------------------------------------------
    variable M : MessageStructPtrType ; 
  begin
    if Message = NULL then
      Message         := new MessageStructType ; 
      Message.Name    := new string'(Name) ; 
      Message.NextPtr := NULL ;
    else
      M := Message ; 
      while M.NextPtr /= NULL loop
        M := M.NextPtr ; 
      end loop ; 
      M.NextPtr := new MessageStructType ; 
      M         := M.NextPtr ; 
      M.Name    := new string'(Name) ; 
      M.NextPtr := NULL ;
    end if ; 
  end procedure SetMessage ; 

  ------------------------------------------------------------
  procedure WriteMessage (variable buf : inout line;  variable Message : inout MessageStructPtrType; prefix : string := "") is 
  ------------------------------------------------------------
    variable M : MessageStructPtrType ; 
  begin
    M := Message ; 
    while M /= NULL loop
      write(buf, prefix & M.Name.all & LF) ;      
      M := M.NextPtr ; 
    end loop ;
  end procedure WriteMessage ;

  ------------------------------------------------------------
  procedure WriteMessage (file f : text; variable Message : inout MessageStructPtrType; prefix : string := "") is 
  ------------------------------------------------------------
    variable M : MessageStructPtrType ; 
    variable buf : line ; 
  begin
    M := Message ; 
    while M /= NULL loop
      write(buf, prefix & M.Name.all) ;
      writeline(f, buf) ;
      M := M.NextPtr ; 
    end loop ;
  end procedure WriteMessage ;

  ------------------------------------------------------------
  procedure GetMessageCount (variable Message : inout MessageStructPtrType; variable Count : out integer) is
  ------------------------------------------------------------
    variable M : MessageStructPtrType ; 
  begin
    Count := 0 ; 
    M := Message ; 
    while M /= NULL loop
      Count := Count + 1 ; 
      M := M.NextPtr ; 
    end loop ;
  end procedure GetMessageCount ;

  ------------------------------------------------------------
  procedure DeallocateMessage (variable Message : inout MessageStructPtrType) is 
  ------------------------------------------------------------
    variable OldM : MessageStructPtrType ; 
  begin
    while Message /= NULL loop
      OldM := Message ; 
      Message := Message.NextPtr ; 
      deallocate(OldM) ;
    end loop ;
  end procedure DeallocateMessage ;

end package body MessageListPkg ;