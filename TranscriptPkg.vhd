--
--  File Name:         TranscriptPkg.vhd
--  Design Unit Name:  TranscriptPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      User interface into OSVVM Transcript capability
--      Defines or aliases to all Transcript functionality
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.08    Added AlertLog controls to PrintLine and BlankLine
--               Moved ReportPkg.TranscriptOpen to here
--               Moved low level essentials into TranscriptBasePkg
--    2023.01    Uses OSVVM_TRANSCRIPT_YAML_FILE from OsvvmScriptSettingsPkg
--    2022.03    Create YAML with files opened during test
--    2020.12    Updated TranscriptOpen parameter Status to InOut to work around simulator bug.
--    2020.01    Updated Licenses to Apache
--    2016.l1    Added procedure BlankLine
--    2016.01    TranscriptOpen function now calls procedure of same name
--    2015.01    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2015 - 2026 by SynthWorks Design Inc.
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

-- Base level transcript capability
use work.TranscriptBasePkg.all ;

use std.textio.all ;
use work.OsvvmScriptSettingsPkg.all ;
use work.OsvvmSettingsPkg.all ;
use work.NamePkg.all ;
use work.NameStorePkg.all ;
use work.AlertLogPkg.all ;
use work.TextUtilPkg.all ;

package TranscriptPkg is
  -- Note:  Aliases are used to make procedures from TranscriptBasePkg
  -- visible using references to TranscriptPkg

--  -- File Identifier to facilitate usage of one transcript file
--  file             TranscriptFile : text ;  -- in TranscriptBasePkg
--

  ------------------------------------------------------------
  alias TranscriptOpen is work.TranscriptBasePkg.TranscriptOpen[FILE_OPEN_STATUS, STRING, WRITE_APPEND_OPEN_KIND] ;
  alias TranscriptOpen is work.TranscriptBasePkg.TranscriptOpen[STRING, WRITE_APPEND_OPEN_KIND] ;
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING) ;
  procedure TranscriptOpen (ExternalName: STRING) ;
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; OpenKind: WRITE_APPEND_OPEN_KIND) ;
  procedure TranscriptOpen (OpenKind: WRITE_APPEND_OPEN_KIND) ;
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS) ;
  procedure TranscriptOpen ;

  impure function  TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND) return FILE_OPEN_STATUS ;
  impure function  TranscriptOpen (ExternalName: STRING) return FILE_OPEN_STATUS ;

  ------------------------------------------------------------
  alias TranscriptClose is work.TranscriptBasePkg.TranscriptClose[] ;

  ------------------------------------------------------------
  impure function  IsTranscriptOpen return boolean ;
  alias            IsTranscriptEnabled is IsTranscriptOpen [return boolean] ;

  ------------------------------------------------------------
  -- Mirroring.  When using TranscriptPkw WriteLine and Print, uses both TranscriptFile and OUTPUT
  procedure        SetTranscriptMirror (A : boolean := TRUE) ;
  impure function  IsTranscriptMirrored return boolean ;
  alias            GetTranscriptMirror is IsTranscriptMirrored [return boolean] ;

  ------------------------------------------------------------
  -- Write to TranscriptFile when open.  Write to OUTPUT when not open or IsTranscriptMirrored
  alias WriteLine is work.TranscriptBasePkg.WriteLine[line]  ;

  ------------------------------------------------------------
  procedure PrintLine (s : string) ;
  procedure PrintLine (s : string ; Level : LogType ) ;
  procedure PrintLine (AlertLogID : AlertLogIDType ; s : string ; Level : LogType ) ;

  procedure        Print(s : string) ;

  ------------------------------------------------------------
  -- Create "count" number of blank lines
  procedure BlankLine (count : natural := 1) ;
  procedure BlankLine (count : natural; Level : LogType; Enable : boolean := FALSE ) ;
  procedure BlankLine (AlertLogID : AlertLogIDType ; count : natural; Level : LogType := ALWAYS; Enable : boolean := FALSE) ;
  procedure Blank (count : natural := 1) ;

  ------------------------------------------------------------
  procedure HeaderLine (S : string) ;
  procedure HeaderLine (S : string; Level : LogType; Enable : boolean := FALSE ) ;
  procedure HeaderLine (AlertLogID : AlertLogIDType; S : string; Level : LogType := ALWAYS; Enable : boolean := FALSE) ;

end TranscriptPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body TranscriptPkg is
--  alias TranscriptOpen is work.TranscriptBasePkg.TranscriptOpen[FILE_OPEN_STATUS, STRING, WRITE_APPEND_OPEN_KIND] ;
--  alias TranscriptOpen is work.TranscriptBasePkg.TranscriptOpen[STRING, WRITE_APPEND_OPEN_KIND] ;
  ------------------------------------------------------------
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING) is
  ------------------------------------------------------------
    variable FileOpenKind : WRITE_APPEND_OPEN_KIND ;
  begin
    if TranscriptNames.Find(ExternalName) then
      FileOpenKind := APPEND_MODE ; -- If has been open, append to it
    else
      FileOpenKind := WRITE_MODE ;  -- If first open, create it
    end if ;

    TranscriptOpen(Status, ExternalName, FileOpenKind) ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen (ExternalName: STRING) is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ;
  begin
    TranscriptOpen(Status, ExternalName) ;
    if Status /= OPEN_OK then
      report "TranscriptPkg.TranscriptOpen file: " &
             ExternalName & " status is: " & to_string(status) & " and is not OPEN_OK" severity FAILURE ;
    end if ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; OpenKind: WRITE_APPEND_OPEN_KIND) is
  ------------------------------------------------------------
  begin
    TranscriptOpen(Status, OSVVM_TEMP_OUTPUT_DIRECTORY & GetTranscriptName, OpenKind) ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen (OpenKind: WRITE_APPEND_OPEN_KIND) is
  ------------------------------------------------------------
  begin
    TranscriptOpen(OSVVM_TEMP_OUTPUT_DIRECTORY & GetTranscriptName, OpenKind) ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS) is
  ------------------------------------------------------------
  begin
    TranscriptOpen(Status, OSVVM_TEMP_OUTPUT_DIRECTORY & GetTranscriptName) ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen  is
  ------------------------------------------------------------
  begin
    TranscriptOpen(OSVVM_TEMP_OUTPUT_DIRECTORY & GetTranscriptName) ;
  end procedure TranscriptOpen ;


  ------------------------------------------------------------
  impure function  TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND) return FILE_OPEN_STATUS is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ;
  begin
    TranscriptOpen(Status, ExternalName, OpenKind) ;
    return Status ;
  end function TranscriptOpen ;

  ------------------------------------------------------------
  impure function  TranscriptOpen (ExternalName: STRING) return FILE_OPEN_STATUS is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ;
  begin
    TranscriptOpen(Status, ExternalName) ;
    return Status ;
  end function TranscriptOpen ;


  ------------------------------------------------------------
  impure function IsTranscriptOpen return boolean is
  ------------------------------------------------------------
  begin
    return TranscriptCurrentlyOpen.Get ;
  end function IsTranscriptOpen ;

  ------------------------------------------------------------
  procedure SetTranscriptMirror (A : boolean := TRUE) is
  ------------------------------------------------------------
  begin
      TranscriptMirror.Set(A) ;
  end procedure SetTranscriptMirror ;

  ------------------------------------------------------------
  impure function IsTranscriptMirrored return boolean is
  ------------------------------------------------------------
  begin
    return TranscriptMirror.Get ;
  end function IsTranscriptMirrored ;


  ------------------------------------------------------------
  procedure PrintLine (s : string) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    WrapToBuf(buf, s, OSVVM_PRINT_PREFIX, OSVVM_PRINT_PREFIX, OSVVM_LINE_WRAP) ;
    work.TranscriptBasePkg.WriteLine(buf) ;
  end procedure PrintLine ;

  ------------------------------------------------------------
  procedure PrintLine (s : string ; Level : LogType ) is
  ------------------------------------------------------------
  begin
    if IsLogEnabled(Level) then
      PrintLine(s) ;
    end if ;
  end procedure PrintLine ;

  ------------------------------------------------------------
  procedure PrintLine (AlertLogID : AlertLogIDType ; s : string ; Level : LogType ) is
  ------------------------------------------------------------
  begin
    if IsLogEnabled(AlertLogID, Level) then
      PrintLine(s) ;
    end if ;
  end procedure PrintLine ;

  ------------------------------------------------------------
  procedure Print(s : string) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    write(buf, s) ;
    work.TranscriptBasePkg.WriteLine(buf) ;
  end procedure Print ;


  ------------------------------------------------------------
  procedure BlankLine (count : natural := 1) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    if count < 1 then
      return ;
    end if ;
    -- Line 2+, LF (separate from previous line) + Prefix (for new line)
    for i in 2 to count loop
      write(buf, OSVVM_BLANK_LINE_PREFIX & LF) ;
    end loop ;
    -- Line 1, Just Prefix
    -- Note The extra space is added since RP throws away LF if line ends in LF.  It is a reported RP issue.
    write(buf, OSVVM_BLANK_LINE_PREFIX & " ") ;
    -- Output the whole set of lines
    work.TranscriptBasePkg.WriteLine(buf) ;
  end procedure BlankLine ;

  ------------------------------------------------------------
  procedure BlankLine (count : natural; Level : LogType; Enable : boolean := FALSE ) is
  ------------------------------------------------------------
  begin
    if Enable or IsLogEnabled(Level) then
      BlankLine(count) ;
    end if ;
  end procedure BlankLine ;

  ------------------------------------------------------------
  procedure BlankLine (AlertLogID : AlertLogIDType ; count : natural; Level : LogType := ALWAYS; Enable : boolean := FALSE) is
  ------------------------------------------------------------
  begin
    if Enable or IsLogEnabled(AlertLogID, Level) then
      BlankLine(count) ;
    end if ;
  end procedure BlankLine ;

  ------------------------------------------------------------
  procedure Blank (count : natural := 1) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    if count < 1 then
      return ;
    end if ;
    -- Line 2+, LF added to get newline
    for i in 2 to count loop
      write(buf, LF) ;
    end loop ;
    -- Line 1, moved to end so it adds a space after LF
    -- Note The extra space is added since RP throws away LF if line ends in LF.  It is a reported RP issue.
    swrite(buf, " ") ;
    -- Output the whole set of lines
    work.TranscriptBasePkg.WriteLine(buf) ;
  end procedure Blank ;


  ------------------------------------------------------------
  procedure HeaderLine(S : string) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    if S'length > 0 then
      HeaderToBuf(buf, S) ;
      work.TranscriptBasePkg.WriteLine(buf) ;
    end if  ;
  end procedure HeaderLine ;

  ------------------------------------------------------------
  procedure HeaderLine (S : string; Level : LogType; Enable : boolean := FALSE ) is
  ------------------------------------------------------------
  begin
    if Enable or IsLogEnabled(Level) then
      HeaderLine(S) ;
    end if ;
  end procedure HeaderLine ;

  ------------------------------------------------------------
  procedure HeaderLine (AlertLogID : AlertLogIDType; S : string; Level : LogType := ALWAYS; Enable : boolean := FALSE) is
  ------------------------------------------------------------
  begin
    if Enable or IsLogEnabled(AlertLogID, Level) then
      HeaderLine(S) ;
    end if ;
  end procedure HeaderLine ;

end package body TranscriptPkg ;