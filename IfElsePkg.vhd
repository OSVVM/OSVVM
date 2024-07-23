--
--  File Name:         IfElsePkg.vhd
--  Design Unit Name:  IfElsePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Consolidated IfElse Utilities in one place for early analyze
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
--    07/2024   2024.07    Added IfElse for std_logic
--    01/2024   2024.01    Initial revision
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

package IfElsePkg is
  ------------------------------------------------------------
  -- IfElse
  --   Crutch until VHDL-2019 conditional initialization
  --   If condition is true return first parameter otherwise return second
  ------------------------------------------------------------
  function IfElse(Expr : boolean ; A, B : string) return string ; 
  function IfElse(Expr : boolean ; A, B : std_logic) return std_logic ;
  function IfElse(Expr : boolean ; A, B : std_logic_vector) return std_logic_vector ;
  function IfElse(Expr : boolean ; A, B : integer) return integer ;
  function IfElse(Expr : boolean ; A, B : boolean) return boolean ;

end IfElsePkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body IfElsePkg is

  ------------------------------------------------------------
  function IfElse(Expr : boolean ; A, B : string) return string is 
  ------------------------------------------------------------
  begin
    if Expr then 
      return A ; 
    else
      return B ; 
    end if ; 
  end function IfElse ; 
  
  ------------------------------------------------------------
  function IfElse(Expr : boolean ; A, B : std_logic) return std_logic is
  ------------------------------------------------------------
  begin
    if Expr then
      return A ;
    else
      return B ;
    end if ;
  end function IfElse ;

  ------------------------------------------------------------
  function IfElse(Expr : boolean ; A, B : std_logic_vector) return std_logic_vector is
  ------------------------------------------------------------
  begin
    if Expr then
      return A ;
    else
      return B ;
    end if ;
  end function IfElse ;

  ------------------------------------------------------------
  function IfElse(Expr : boolean ; A, B : integer) return integer is
  ------------------------------------------------------------
  begin
    if Expr then
      return A ;
    else
      return B ;
    end if ;
  end function IfElse ;

  ------------------------------------------------------------
  function IfElse(Expr : boolean ; A, B : boolean) return boolean is
  ------------------------------------------------------------
  begin
    if Expr then
      return A ;
    else
      return B ;
    end if ;
  end function IfElse ;


end package body IfElsePkg ;