--
--  File Name:         FileLinePathPkg.vhd
--  Design Unit Name:  FileLinePathPkg
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

package FileLinePathPkg is

 type CALL_PATH_ELEMENT is record
   name      : LINE;      -- subprogram name
   file_name : LINE;      -- file name containing name
   file_path : LINE;      -- directory path to file name 
   file_line : POSITIVE;  -- line number in file name
 end record;
  
  type CALL_PATH_VECTOR is array (natural range <>) of CALL_PATH_ELEMENT ;
  type CALL_PATH_VECTOR_PTR is access CALL_PATH_VECTOR ;
    
  ------------------------------------------------------------
  procedure deallocate(      variable Cpe    : inout CALL_PATH_ELEMENT) ;
  procedure deallocateCpvPtr(variable CpvPtr : inout CALL_PATH_VECTOR_PTR) ;
  
  ------------------------------------------------------------
  -- Get Call Path as a string
  impure function Get_Call_Path(
    index: integer := 2 ;
    Separator : STRING := "" & LF 
  ) return string ;

  impure function GetFileLineInfo(index : integer := 2) return string ; 

end FileLinePathPkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body FileLinePathPkg is

  ------------------------------------------------------------
  procedure deallocate(variable Cpe : inout CALL_PATH_ELEMENT) is 
  ------------------------------------------------------------
  begin
  end procedure deallocate ; 

  ------------------------------------------------------------
  procedure deallocateCpvPtr(variable CpvPtr : inout CALL_PATH_VECTOR_PTR) is 
  ------------------------------------------------------------
  begin
  end procedure deallocateCpvPtr ; 

--  ------------------------------------------------------------
--  impure function to_string(variable CpvPtr : inout CALL_PATH_VECTOR_PTR ; index : integer) return string is
--  ------------------------------------------------------------
--  begin 
--    return to_string(CpvPtr(index to PathValue'right) ) ;
--  end function to_string

  ------------------------------------------------------------
  -- Get Call Path as a string
  impure function Get_Call_Path(
  ------------------------------------------------------------
    index: integer := 2 ;
    Separator : STRING := "" & LF 
  ) return string is 
  begin
  end function Get_Call_Path;

  ------------------------------------------------------------
  impure function GetFileLineInfo(index : integer := 2) return string is 
  ------------------------------------------------------------
  begin
  end function GetFileLineInfo ; 


end package body FileLinePathPkg ;