--
--  File Name:         TranscriptBasePkg.vhd
--  Design Unit Name:  TranscriptBasePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--     Low level Transcript handling required by other OSVVM capabilities
--     Intended to be private to OSVVM - and not referenced outside OSVVM
--     TranscriptPkg is the public interface and has aliases to all subprograms defined here
--     Defines File Identifier
--     Defines protected shared variables for control
--     Defines subprograms
--       FileOpen - used by ScoreboardGenericPkg (deprecated)
--       FileClose - used by AlertLogPkg as it is stopping a simulation due to errors
--       WriteLine - used by most OSVVM packages
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
--    08/2026   2026.08    Refactored into TranscriptBasePkg (with low level essentials) and TranscriptPkg (user interface)
--    01/2023   2023.01    Uses OSVVM_TRANSCRIPT_YAML_FILE from OsvvmScriptSettingsPkg
--    02/2022   2022.03    Create YAML with files opened during test
--    12/2020   2020.12    Updated TranscriptOpen parameter Status to InOut to work around simulator bug.
--    01/2020   2020.01    Updated Licenses to Apache
--    11/2016   2016.l1    Added procedure BlankLine
--    01/2016   2016.01    TranscriptOpen function now calls procedure of same name
--    01/2015   2015.01    Initial revision
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

use std.textio.all ;
use work.OsvvmScriptSettingsPkg.all ;
use work.OsvvmSettingsPkg.all ;
use work.NamePkg.all ;
use work.NameStorePkg.all ;
use work.SetGetBoundedPkg_boolean.all ;

package TranscriptBasePkg is

  -- File Identifier to facilitate usage of one transcript file
  file             TranscriptFile : text ;

  -- Cause compile errors if READ_MODE is passed to TranscriptOpen
  subtype WRITE_APPEND_OPEN_KIND is FILE_OPEN_KIND range WRITE_MODE to APPEND_MODE ;

  -- Open and close TranscriptFile.  Function allows declarative opens
  procedure        TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND) ;
  procedure        TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND) ;
  procedure        TranscriptClose ;
  procedure        WriteLine(buf : inout line)  ;

  ------------------------------------------------------------
  shared variable TranscriptCurrentlyOpen : work.SetGetBoundedPkg_boolean.PType ;
  shared variable TranscriptMirror        : work.SetGetBoundedPkg_boolean.PType ;
  shared variable HasTranscriptBeenOpened : work.SetGetBoundedPkg_boolean.PType ;
  shared variable TranscriptNames         : NameStorePType ;
  shared variable CurrentTranscriptName   : NamePType ;

end TranscriptBasePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body TranscriptBasePkg is
  file TranscriptYamlFile : text ;

  ------------------------------------------------------------
  procedure CreateTranscriptYamlLog (Name : STRING) is
  ------------------------------------------------------------
    variable buf : line ;
    variable FileOpenKind : WRITE_APPEND_OPEN_KIND := APPEND_MODE ;
  begin
    -- Create Yaml file with list of files.
    if not HasTranscriptBeenOpened.Get then
      -- first time to open this session - use WRITE_MODE
      FileOpenKind := WRITE_MODE;
      HasTranscriptBeenOpened.Set(TRUE) ;
    end if ;
    file_open(TranscriptYamlFile, OSVVM_TRANSCRIPT_YAML_FILE, FileOpenKind) ;
    swrite(buf, "  - " & Name) ;
    WriteLine(TranscriptYamlFile, buf) ;
    file_close(TranscriptYamlFile) ;
  end procedure CreateTranscriptYamlLog ;

  ------------------------------------------------------------
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND) is
  ------------------------------------------------------------
    variable FileOpenKind : WRITE_APPEND_OPEN_KIND := OpenKind ;
  begin
    if TranscriptCurrentlyOpen.Get then
      if ExternalName = CurrentTranscriptName.Get then
        -- Do nothing and return
        return ;
      else
        TranscriptClose ;
      end if ;
    end if ;

    file_open(Status, TranscriptFile, ExternalName, FileOpenKind) ;

    if Status = OPEN_OK then
      CreateTranscriptYamlLog(ExternalName) ;
      CurrentTranscriptName.Set(ExternalName) ;
      TranscriptNames.Insert(ExternalName) ;
      TranscriptCurrentlyOpen.Set(TRUE) ;
    else
      report "osvvm.TranscriptBasePkg.TranscriptOpen: bad file open status for file:  " & ExternalName & "  file_open status: " & to_string(Status) & "   Ignoring TranscriptOpen." severity note;
    end if ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND) is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ;
  begin
    TranscriptOpen(Status, ExternalName, OpenKind) ;
    if Status /= OPEN_OK then
      report "TranscriptBasePkg.TranscriptOpen file: " &
             ExternalName & " status is: " & to_string(status) & " and is not OPEN_OK" severity FAILURE ;
    end if ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptClose is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    if TranscriptCurrentlyOpen.Get then
      file_close(TranscriptFile) ;
      if not TranscriptMirror.Get then
        swrite(buf, OSVVM_PREFIX_X_MARKS_THE_SPOT) ; -- Spot to insert a link to html transcript file
        WriteLine(OUTPUT, buf) ;
      end if ;
    end if ;
    TranscriptCurrentlyOpen.Set(FALSE) ;
  end procedure TranscriptClose ;

  ------------------------------------------------------------
  procedure WriteLine(buf : inout line) is
  ------------------------------------------------------------
  begin
    if not TranscriptCurrentlyOpen.Get then
      WriteLine(OUTPUT, buf) ;
    elsif TranscriptMirror.Get then
      TEE(TranscriptFile, buf) ;
    else
      WriteLine(TranscriptFile, buf) ;
    end if ;
  end procedure WriteLine ;

end package body TranscriptBasePkg ;