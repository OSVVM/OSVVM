--
--  File Name:         FilelinePathPkg.vhd
--  Design Unit Name:  FilelinePathPkg
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

package FilelinePathPkg is

  impure function FILE_NAME return string;
  impure function FILE_PATH return string;
  impure function FILE_LINE return string;
  
  impure function FILE_NAME return line;
  impure function FILE_PATH return line;
  impure function FILE_LINE return POSITIVE;


 type CALL_PATH_ELEMENT is record
   name      : line;      -- subprogram name
   file_name : line;      -- file name containing name
   file_path : line;      -- directory path to file name 
   FILE_LINE : POSITIVE;  -- line number in file name
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
    Separator : string := "" & LF 
  ) return string ;

  impure function GetFilelineInfo(index : integer := 2) return string ; 

end FilelinePathPkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body FilelinePathPkg is

  -------------------------------------------------------
  -- Dummy return values
  -------------------------------------------------------
  impure function FILE_NAME return string is
  begin
    return "" ;
  end function FILE_NAME ; 
  
  impure function FILE_PATH return string is
  begin
    return "" ;
  end function FILE_PATH ; 
  
  impure function FILE_LINE return string is
  begin
    return "" ;
  end function FILE_LINE ; 
  
  impure function FILE_NAME return line is
    variable result : line ; 
    constant FN : string := FILE_NAME ; 
  begin
    result := new string'(FN) ;
    return result ; 
  end function FILE_NAME ; 
  
  impure function FILE_PATH return line is
    variable result : line ; 
    constant FP : string := FILE_NAME ; 
  begin
    result := new string'(FP) ;
    return result ;
  end function FILE_PATH ; 
  
  impure function FILE_LINE return POSITIVE is
  begin
    return 1 ;
  end function FILE_LINE ; 

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
    Separator : string := "" & LF 
  ) return string is 
  begin
    return "" ;
  end function Get_Call_Path;

  ------------------------------------------------------------
  impure function GetFilelineInfo(index : integer := 2) return string is 
  ------------------------------------------------------------
  begin
   return "" ;
  end function GetFilelineInfo ; 


end package body FilelinePathPkg ;