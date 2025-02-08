--
--  File Name:         OsvvmGlobalPkg.vhd
--  Design Unit Name:  OsvvmGlobalPkg
--  Revision:          STANDARD VERSION,  revision 2015.01
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Global Settings for OSVVM packages
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
--    03/2024   2024.03    Most of package functionality replaced by constants in OsvvmSettingsPkg_default.vhd
--    06/2022   2022.06    Minor reordering of constants
--    02/2022   2022.02    Added support for IdSeparator.  
--                         Supports PrintParent mode PRINT_NAME_AND_PARENT.  <Parent Name> <IdSeparator> <AlertLogID Name>.   
--    01/2020   2020.01    Updated Licenses to Apache
--    01/2014   2015.01    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2015 - 2020 by SynthWorks Design Inc.  
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

library ieee ;
use std.textio.all ;

use work.NamePkg.all ; 

package OsvvmGlobalPkg is
  -- Shared Options Type used in OSVVM
  type OsvvmOptionsType is (OPT_INIT_PARM_DETECT, OPT_USE_DEFAULT, DISABLED, FALSE, ENABLED, TRUE) ;
  function IsEnabled (A : OsvvmOptionsType) return boolean ;  -- Requires that TRUE is last and ENABLED is 2nd to last
  function to_OsvvmOptionsType (A : boolean) return OsvvmOptionsType ;

  -- Defaults for String values
  constant OSVVM_STRING_INIT_PARM_DETECT  : string := NUL & NUL & NUL ; 
  constant OSVVM_STRING_USE_DEFAULT       : string := NUL & "" ; 
  
  function IsOsvvmStringSet (A : string) return boolean ;


end OsvvmGlobalPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body OsvvmGlobalPkg is
  function IsEnabled (A : OsvvmOptionsType) return boolean is
  begin
    return A >= ENABLED ; 
  end function IsEnabled ; 
  
  function to_OsvvmOptionsType (A : boolean) return OsvvmOptionsType is
  begin
    if A then 
      return TRUE ; 
    else 
      return FALSE ;
    end if ; 
  end function to_OsvvmOptionsType ; 
  
  function IsOsvvmStringSet (A : string) return boolean is
  begin
    if A'length = 0 then   -- Null strings permitted
      return TRUE ;     
    else 
      return A(A'left) /= NUL ;
    end if; 
  end function IsOsvvmStringSet ;
  
end package body OsvvmGlobalPkg ;