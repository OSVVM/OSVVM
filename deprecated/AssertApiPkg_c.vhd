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
--        Get File and line Info from Call Stack - requires VHDL-2019 features
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
--    11/2024   2024.11    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2024 by SynthWorks Design Inc.  
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
library ieee ; 

package AssertApiPkg is

  constant SUPPORTS_2019_ASSERT_API : BOOLEAN := FALSE ; 

  -- VHDL assert failed
  impure function IsVhdlAssertFailed return BOOLEAN ;
  impure function IsVhdlAssertFailed (Level : SEVERITY_LEVEL ) return BOOLEAN ;

  -- VHDL assert count
  impure function GetVhdlAssertCount return NATURAL ;
  impure function GetVhdlAssertCount (Level : SEVERITY_LEVEL ) return NATURAL ;

  -- Clear VHDL assert errors
  procedure ClearVhdlAssert ;

  -- Assert enable, disable/ignore asserts
  procedure SetVhdlAssertEnable(Enable : BOOLEAN := TRUE) ;
  procedure SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : BOOLEAN := TRUE) ;
  impure function GetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE) return BOOLEAN ;

  -- Assert statement formatting
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; format: STRING) ;
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; format: STRING; Valid : out BOOLEAN) ;
  impure function GetVhdlAssertFormat(Level : SEVERITY_LEVEL) return STRING ;

  -- VHDL read severity
  procedure SetVhdlReadSeverity(Level: SEVERITY_LEVEL := FAILURE) ;
  impure function GetVhdlReadSeverity return SEVERITY_LEVEL ;

  -- OSVVM extensions - and requested language features
  impure function SetVhdlAssertEnable(Enable : BOOLEAN := TRUE) return boolean ;
  impure function SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : BOOLEAN := TRUE) return boolean ;


end AssertApiPkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body AssertApiPkg is

  -------------------------------------------------------
  -- Dummy return values
  -------------------------------------------------------
  -- VHDL assert failed
  impure function IsVhdlAssertFailed return BOOLEAN is
  begin
    return FALSE ;
  end function IsVhdlAssertFailed ; 

  impure function IsVhdlAssertFailed (Level : SEVERITY_LEVEL ) return BOOLEAN is
  begin
    return FALSE ;
  end function IsVhdlAssertFailed ; 

  -- VHDL assert count
  impure function GetVhdlAssertCount return NATURAL is
  begin
    return 0 ;
  end function GetVhdlAssertCount ; 
  impure function GetVhdlAssertCount (Level : SEVERITY_LEVEL ) return NATURAL is
  begin
    return 0 ;
  end function GetVhdlAssertCount ; 

  -- Clear VHDL assert errors
  procedure ClearVhdlAssert is
  begin
    null ;
  end procedure ClearVhdlAssert ; 

  -- Assert enable, disable/ignore asserts
  procedure SetVhdlAssertEnable(Enable : BOOLEAN := TRUE) is
  begin
    null ;
  end procedure SetVhdlAssertEnable ;
  procedure SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : BOOLEAN := TRUE) is
  begin
    null ;
  end procedure SetVhdlAssertEnable ;
  impure function GetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE) return BOOLEAN is
  begin
    return TRUE ;
  end function GetVhdlAssertEnable ;

  -- Assert statement formatting
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; format: STRING) is
  begin
    null ;
  end procedure SetVhdlAssertFormat ;
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; format: STRING; Valid : out BOOLEAN) is
  begin
    null ;
  end procedure SetVhdlAssertFormat ;
  impure function GetVhdlAssertFormat(Level : SEVERITY_LEVEL) return STRING is
  begin
    return "" ;
  end function GetVhdlAssertFormat ;

  -- VHDL read severity
  procedure SetVhdlReadSeverity(Level: SEVERITY_LEVEL := FAILURE) is
  begin
    null ;
  end procedure SetVhdlReadSeverity ;
  impure function GetVhdlReadSeverity return SEVERITY_LEVEL is
  begin
    return ERROR ;
  end function GetVhdlReadSeverity ;

  -- OSVVM extensions - and requested language features
  impure function SetVhdlAssertEnable(Enable : BOOLEAN := TRUE) return boolean is
  begin
    SetVhdlAssertEnable(Enable) ; 
    return Enable ;
  end function SetVhdlAssertEnable ;
  impure function SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : BOOLEAN := TRUE) return boolean is
  begin
    SetVhdlAssertEnable(Level, Enable) ; 
    return Enable ;
  end function SetVhdlAssertEnable ;

end package body AssertApiPkg ;