--
--  File Name:         LanguageSupport2019Pkg_c.vhd
--  Design Unit Name:  LanguageSupport2019Pkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--     Utilities to stand in for things added in 1076-2019
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
--    07/2024   2024.07    Initial revision
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
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

package LanguageSupport2019Pkg is

  ------------------------------------------------------------
  -- to_string
  --   for integer_vector
  ------------------------------------------------------------
  impure function to_string ( A : integer_vector) return string ;
  
  impure function VHDL_VERSION return STRING;
  function TOOL_TYPE return STRING;
  function TOOL_VENDOR return STRING;
  function TOOL_NAME return STRING;
  function TOOL_EDITION return STRING;
  function TOOL_VERSION return STRING;
  
  -- VHDL assert failed
  impure function IsVhdlAssertFailed return boolean;
  impure function IsVhdlAssertFailed (Level : severity_level ) return boolean ;
  
  -- VHDL assert count
  impure function GetVhdlAssertCount return natural ;
  impure function GetVhdlAssertCount (Level : severity_level ) return natural ;
  
  -- Clear VHDL assert errors
  procedure ClearVhdlAssert;
  
  -- Assert enable, disable/ignore asserts
  procedure SetVhdlAssertEnable(Enable : boolean := TRUE);
  procedure SetVhdlAssertEnable(Level : severity_level := NOTE; Enable : boolean := TRUE);
  impure function GetVhdlAssertEnable(Level : severity_level := NOTE) return boolean;

end LanguageSupport2019Pkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body LanguageSupport2019Pkg is
  impure function VHDL_VERSION return STRING is
  begin
    return "2008" ;
  end function VHDL_VERSION ; 
  function TOOL_TYPE return STRING is
  begin
    return "SIMULATION" ;
  end function TOOL_TYPE ; 
  function TOOL_VENDOR return STRING is
  begin
    return "" ;
  end function TOOL_VENDOR ; 
  function TOOL_NAME return STRING is
  begin
    return "" ;
  end function TOOL_NAME ; 
  function TOOL_EDITION return STRING is
  begin
    return "" ;
  end function TOOL_EDITION ; 
  function TOOL_VERSION return STRING is
  begin
    return "" ;
  end function TOOL_VERSION ; 
  


  ------------------------------------------------------------
  -- to_string
  impure function to_string ( A : integer_vector) return string is
  ------------------------------------------------------------
    constant A_LEN : integer := A'length ; 
    alias normalizedA : integer_vector(1 to A_LEN) is A ;

    variable buf : line ;
    -- with VHDL-2019 this could be general purpose with buf as a parameter
    impure function local_to_string return string is
      variable result : string(1 to buf'length) ;
    begin
      result := buf.all ;
      deallocate(buf) ;
      return result ;
    end function local_to_string ;

  begin
    swrite(buf, "(") ;
    for i in 1 to A_LEN-1 loop
      write(buf, normalizedA(i)) ;
      swrite(buf, ",") ;
    end loop ;
    write(buf, normalizedA(A_LEN)) ;
    swrite(buf, ")") ;

    return local_to_string ;
  end function to_string ;
  
  -------------------------------------------------------
  -- Dummy return values
  -------------------------------------------------------
  -- VHDL assert failed
  impure function IsVhdlAssertFailed return boolean is
  begin
    return FALSE ;
  end function IsVhdlAssertFailed ; 
  impure function IsVhdlAssertFailed (Level : severity_level ) return boolean is
  begin
    return FALSE ;
  end function IsVhdlAssertFailed ; 
  
  -- VHDL assert count
  impure function GetVhdlAssertCount return natural is
  begin
    return integer'high ;
  end function GetVhdlAssertCount ; 
  impure function GetVhdlAssertCount (Level : severity_level ) return natural is
  begin
    return integer'high ;
  end function GetVhdlAssertCount ; 
  
  -- Clear VHDL assert errors
  procedure ClearVhdlAssert is
  begin
  end procedure ClearVhdlAssert ;
  
  -- Assert enable, disable/ignore asserts
  procedure SetVhdlAssertEnable(Enable : boolean := TRUE) is
  begin
  end ; 
  procedure SetVhdlAssertEnable(Level : severity_level := NOTE; Enable : boolean := TRUE) is
  begin
  end ; 
  impure function GetVhdlAssertEnable(Level : severity_level := NOTE) return boolean is
  begin
    return TRUE ;
  end ; 



end package body LanguageSupport2019Pkg ;