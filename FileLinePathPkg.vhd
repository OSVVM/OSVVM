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
--    02/2025   2025.02    alias to FILE_PATH, FILE_LINE, FILE_NAME from std.env.
--                         coordinates with deprecated/FileLinePathPkg_c.vhd
--    11/2024   2024.11    Initial revision
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
use std.env.all ;
library osvvm ; 
use osvvm.TranscriptPkg.all ; 

package FileLinePathPkg is

  alias FILE_NAME is FILE_NAME [return string] ;
  alias FILE_PATH is FILE_PATH [return string] ;
  alias FILE_LINE is FILE_LINE [return string] ;
  

  ------------------------------------------------------------
  procedure deallocate(      variable Cpe    : inout CALL_PATH_ELEMENT) ;
  procedure deallocateCpvPtr(variable CpvPtr : inout CALL_PATH_VECTOR_PTR) ;
  
  ------------------------------------------------------------
  -- Get Call Path as a string
  impure function Get_Call_Path(
    index: integer := 1 ;
    Separator : STRING := "" & LF 
  ) return string ;

  impure function GetFileLineInfo(index : integer := 1) return string ; 

end FileLinePathPkg ;
  
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body FileLinePathPkg is

-- Add to TextUtilPkg
--  ------------------------------------------------------------
--  -- Put this in other package.
--  impure function to_string(  variable L : inout line ) return string is 
--  ------------------------------------------------------------
--    constant result : string := L.all ; 
--  begin
--    deallocate(L) ; 
--    return result ; 
--  end function to_string ; 

  ------------------------------------------------------------
--  type CALL_PATH_ELEMENT is record
--    name      : LINE;      -- subprogram name
--    file_name : LINE;      -- file name containing name
--    file_path : LINE;      -- directory path to file name 
--    file_line : POSITIVE;  -- line number in file name
--  end record;

  ------------------------------------------------------------
  procedure deallocate(variable Cpe : inout CALL_PATH_ELEMENT) is 
  ------------------------------------------------------------
  begin
    deallocate(Cpe.name) ; 
    deallocate(Cpe.file_name) ; 
    deallocate(Cpe.file_path) ; 
  end procedure deallocate ; 

  ------------------------------------------------------------
  procedure deallocateCpvPtr(variable CpvPtr : inout CALL_PATH_VECTOR_PTR) is 
  ------------------------------------------------------------
  begin
    for i in CpvPtr'range loop 
      deallocate(CpvPtr(i)) ; 
    end loop ; 
    deallocate(CpvPtr) ; 
  end procedure deallocateCpvPtr ; 

  ------------------------------------------------------------
  impure function to_string(variable CpvPtr : inout CALL_PATH_VECTOR_PTR ; index : integer ; Separator : STRING := "" & LF ) return string is
  ------------------------------------------------------------
  begin 
    return to_string(CpvPtr(index - 1 to CpvPtr'right) ) ;
  end function to_string ;

  ------------------------------------------------------------
  -- Get Call Path as a string
  impure function Get_Call_Path(
  ------------------------------------------------------------
    index: integer := 1 ;
    Separator : STRING := "" & LF 
  ) return string is 
    variable CpvPtr  : Call_Path_Vector_Ptr := Get_Call_Path ;  --  0 to N.  Note 0 is this subprogram
    constant Result  : string := to_string(CpvPtr(index to CpvPtr'right), Separator) ;  -- uses 2019 version
--    constant Result  : string := to_string(CpvPtr, index, Separator) ;  
  begin
    deallocateCpvPtr( CpvPtr )  ;
    return Result ; 
  end function Get_Call_Path;

  ------------------------------------------------------------
  impure function GetFileLineInfo ( variable CpvPtr : inout Call_Path_Vector; index : integer) return string is
  ------------------------------------------------------------
  begin
    return "in " & CpvPtr(index).file_name.all & " line: " & to_string(CpvPtr(index).file_line) ;
  end function GetFileLineInfo ; 
  
  ------------------------------------------------------------
  impure function GetFileLineInfo(index : integer := 1) return string is 
  ------------------------------------------------------------
    variable CpvPtr : Call_Path_Vector_Ptr := Get_Call_Path ; --  0 to N.  Note 0 is this subprogram
--    constant Result : string := "in file: " & CpvPtr(index).file_name.all & " line: " & to_string(CpvPtr(index).file_line) ;
    constant Result : string := GetFileLineInfo(CpvPtr.all, index) ; 
  begin
    deallocateCpvPtr( CpvPtr )  ;
    return Result ; 
  end function GetFileLineInfo ; 


end package body FileLinePathPkg ;