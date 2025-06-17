--
--  File Name:         FileUtilPkg.vhd
--  Design Unit Name:  FileUtilPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Shared Utilities for handling file paths and such
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
--    06/2025   2025.06    FileExists from TextUtilPkg + adding on need basis
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
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

package FileUtilPkg is

  ------------------------------------------------------------
  -- FileExists - open for read and close - if successful, it exists
  impure function FileExists(FileName : string) return boolean ;

  ------------------------------------------------------------
  -- Tail - get last element path
  function Tail (A : string ; PathDelimiter : character := '/') return string ;

  ------------------------------------------------------------
  -- ChangeSeparator - from \ to /.   To address cases where it is both.  Prefer / as it works in Unix and windows
  function ChangeSeparator (A : string ; FromSeparator : character := '\' ; ToSeparator : character := '/') return string ;

  ------------------------------------------------------------
  -- RemoveEndingSeparator - if path ends with a separator, remove it
  function RemoveEndingSeparator (A : string ; Separator : character := '/') return string ;

  -- Potential Extensions
  -- dirname   - path without tail
  -- Root      - file name without file extension
  -- Extension - file extension
  -- isfile    - 
  -- isdirectory -



end FileUtilPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body FileUtilPkg is

  ------------------------------------------------------------
  -- FileExists
  --    Return TRUE if file exists
  ------------------------------------------------------------
  impure function FileExists(FileName : string) return boolean is
    file     FileID : text ;
    variable status : file_open_status ;
  begin
    file_open(status, FileID, FileName, READ_MODE) ;
    file_close(FileID) ;
    return status = OPEN_OK ;
  end function FileExists ;
  
  ------------------------------------------------------------
  function Tail (A : string ; PathDelimiter : character := '/') return string is
  ------------------------------------------------------------
    alias aA : string(1 to A'length) is A ;
    variable LenA : integer := A'length ;
    variable FoundAtIndex : integer ; 
  begin
    -- Remove ending PathDelimiter
    if aA(LenA) = PathDelimiter then
      LenA := LenA - 1 ;
    end if ;
    -- Find ending characters from right until find PathDelimiter
    FoundAtIndex := 1 ;
    for i in LenA downto 1 loop
      if aA(i) = PathDelimiter then
        FoundAtIndex := i + 1;
        exit ;
      end if ;
    end loop ;
    return aA(FoundAtIndex to LenA) ;
  end function Tail ;

  ------------------------------------------------------------
  function ChangeSeparator (A : string ; FromSeparator : character := '\' ; ToSeparator : character := '/') return string is
  ------------------------------------------------------------
    constant LEN_A : integer := A'length ;
    alias aA : string(1 to LEN_A) is A ;
    variable Result : string(1 to LEN_A) ;
  begin
    -- Find ending characters from right until find PathDelimiter
    for i in aA'range loop
      if aA(i) = FromSeparator then
        Result(i) := ToSeparator ;
      else
        Result(i) := aA(i) ;
      end if ;
    end loop ;
    return Result ;
  end function ChangeSeparator ;

  ------------------------------------------------------------
  function RemoveEndingSeparator (A : string ; Separator : character := '/') return string is
  ------------------------------------------------------------
    constant LEN_A : integer := A'length ;
    alias aA : string(1 to LEN_A) is A ;
  begin
    if aA(LEN_A) = Separator then
      return aA(1 to LEN_A-1) ;
    else
      return aA(1 to LEN_A) ;
    end if ;
  end function RemoveEndingSeparator ;


end package body FileUtilPkg ;