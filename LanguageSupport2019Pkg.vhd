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
--     Abstraction layer around 1076-2019 features to support a 
--     graceful degradation of capability without breaking the 
--     code in 2008.
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
  constant TOOL_USES_32_BIT_INTEGERS : boolean := 
    -- GHDL does not support writing -2**31 so using -2**30 - 2**30
    -- 2's complement               or  1's complement
    (integer'left = -2**30 - 2**30) or (integer'left = 1 -2**30 - 2**30) ; 
    
  ------------------------------------------------------------
  -- Language built in
  ------------------------------------------------------------
  alias to_string is std.standard.to_string [integer_vector return string] ;
  
  ------------------------------------------------------------
  -- ToolVersionApi
  ------------------------------------------------------------
  alias VHDL_VERSION is std.env.VHDL_VERSION [return STRING] ;
  alias TOOL_TYPE    is std.env.TOOL_TYPE    [return STRING] ;
  alias TOOL_VENDOR  is std.env.TOOL_VENDOR  [return STRING] ;
  alias TOOL_NAME    is std.env.TOOL_NAME    [return STRING] ;
  alias TOOL_EDITION is std.env.TOOL_EDITION [return STRING] ;
  alias TOOL_VERSION is std.env.TOOL_VERSION [return STRING] ;


end LanguageSupport2019Pkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body LanguageSupport2019Pkg is

end package body LanguageSupport2019Pkg ;