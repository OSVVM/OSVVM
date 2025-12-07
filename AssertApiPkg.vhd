--
--  File Name:         AssertApiPkg.vhd
--  Design Unit Name:  AssertApiPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Get File and Line Info from Call Stack - requires VHDL-2019 features
--          
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    11/2025   2025.11    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2025 by SynthWorks Design Inc.  
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

use std.textio.all ;
-- use std.env.all ;
library osvvm ; 
use osvvm.TranscriptPkg.all ; 

package AssertApiPkg is

  constant SUPPORTS_2019_ASSERT_API : BOOLEAN := TRUE ; 
 
  -- Alias's to std.env are not ambiguous just like for ieee.std_logic_textio

  -- VHDL assert failed
  alias IsVhdlAssertFailed is std.env.IsVhdlAssertFailed [return BOOLEAN] ; 
  alias IsVhdlAssertFailed is std.env.IsVhdlAssertFailed [SEVERITY_LEVEL return BOOLEAN] ; 

  -- VHDL assert count
  alias GetVhdlAssertCount is std.env.GetVhdlAssertCount [return NATURAL] ; 
  alias GetVhdlAssertCount is std.env.GetVhdlAssertCount [SEVERITY_LEVEL return NATURAL] ; 

  -- Clear VHDL assert errors
  alias ClearVhdlAssert is std.env.ClearVhdlAssert [] ; 

  -- Assert enable, disable/ignore asserts
  alias SetVhdlAssertEnable is std.env.SetVhdlAssertEnable [BOOLEAN] ; 
  alias SetVhdlAssertEnable is std.env.SetVhdlAssertEnable [SEVERITY_LEVEL, BOOLEAN] ; 
  alias GetVhdlAssertEnable is std.env.GetVhdlAssertEnable [SEVERITY_LEVEL return BOOLEAN] ; 

  -- Assert statement formatting
  alias SetVhdlAssertFormat is std.env.SetVhdlAssertFormat [SEVERITY_LEVEL, STRING] ; 
  alias SetVhdlAssertFormat is std.env.SetVhdlAssertFormat [SEVERITY_LEVEL, STRING, BOOLEAN] ; 
  alias GetVhdlAssertFormat is std.env.GetVhdlAssertFormat [SEVERITY_LEVEL return STRING] ; 

  -- VHDL read severity
  alias SetVhdlReadSeverity is std.env.SetVhdlReadSeverity [SEVERITY_LEVEL] ; 
  alias GetVhdlReadSeverity is std.env.GetVhdlReadSeverity [return SEVERITY_LEVEL] ; 

  -- OSVVM extensions - and requested language features
  impure function SetVhdlAssertEnable(Enable : BOOLEAN := TRUE) return boolean ;
  impure function SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : BOOLEAN := TRUE) return boolean ;


end AssertApiPkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body AssertApiPkg is

  -- OSVVM extensions - and requested language features
  impure function SetVhdlAssertEnable(Enable : BOOLEAN := TRUE) return boolean is
  begin
    std.env.SetVhdlAssertEnable(Enable) ; 
    return Enable ;
  end function SetVhdlAssertEnable ;
  impure function SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : BOOLEAN := TRUE) return boolean is
  begin
    std.env.SetVhdlAssertEnable(Level, Enable) ; 
    return Enable ;
  end function SetVhdlAssertEnable ;

end package body AssertApiPkg ;