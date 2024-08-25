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

end LanguageSupport2019Pkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body LanguageSupport2019Pkg is
  ------------------------------------------------------------
  -- to_string
  impure function to_string ( A : integer_vector) return string is
  ------------------------------------------------------------
    alias normA : integer_vector(1 to A'length) is A ;

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
    for i in 1 to A'length-1 loop
      write(buf, A(i)) ;
      swrite(buf, ",") ;
    end loop ;
    write(buf, A(A'length)) ;
    swrite(buf, ")") ;

    return local_to_string ;
  end function to_string ;

end package body LanguageSupport2019Pkg ;