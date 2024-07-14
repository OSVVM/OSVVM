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

  -- implemented directly by 1076-2019
  -- function to_string ( A : integer_vector) return string ;

end LanguageSupport2019Pkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body LanguageSupport2019Pkg is


end package body LanguageSupport2019Pkg ;