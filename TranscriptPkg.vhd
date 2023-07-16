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
--        Define file identifier TranscriptFile
--        provide subprograms to open, close, and print to it.
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

use std.textio.all ;
use work.OsvvmScriptSettingsPkg.all ;
package TranscriptPkg is

  -- File Identifier to facilitate usage of one transcript file
  file             TranscriptFile : text ;

  -- Cause compile errors if READ_MODE is passed to TranscriptOpen
  subtype WRITE_APPEND_OPEN_KIND is FILE_OPEN_KIND range WRITE_MODE to APPEND_MODE ;

  -- Open and close TranscriptFile.  Function allows declarative opens
  procedure        TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) ;
  procedure        TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) ;
  impure function  TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) return FILE_OPEN_STATUS ;
  -- The following two are in ReportPkg to resolve circular depedencies
  --   procedure TranscriptOpen (OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) ;
  --   procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) ;

  procedure        TranscriptClose ;
  impure function  IsTranscriptOpen return boolean ;
  alias            IsTranscriptEnabled is IsTranscriptOpen [return boolean] ;

  -- Mirroring.  When using TranscriptPkw WriteLine and Print, uses both TranscriptFile and OUTPUT
  procedure        SetTranscriptMirror (A : boolean := TRUE) ;
  impure function  IsTranscriptMirrored return boolean ;
  alias            GetTranscriptMirror is IsTranscriptMirrored [return boolean] ;

  -- Write to TranscriptFile when open.  Write to OUTPUT when not open or IsTranscriptMirrored
  procedure        WriteLine(buf : inout line)  ;
  procedure        Print(s : string) ;

  -- Create "count" number of blank lines
  procedure BlankLine (count : integer := 1) ;

  impure function GetTranscriptFilePath return string ;

end TranscriptPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body TranscriptPkg is
  ------------------------------------------------------------
  type LocalBooleanPType is protected
    procedure Set (A : boolean) ;
    impure function get return boolean ;
  end protected LocalBooleanPType ;
  type LocalBooleanPType is protected body
    variable GlobalVar : boolean := FALSE ;
    procedure Set (A : boolean) is
    begin
       GlobalVar := A ;
    end procedure Set ;
    impure function get return boolean is
    begin
      return GlobalVar ;
    end function get ;
  end protected body LocalBooleanPType ;

  type LocalStringPType is protected
    procedure Set (A : string) ;
    impure function Get return string ;
    procedure Clear;
  end protected LocalStringPType ;
  type LocalStringPType is protected body
    variable GlobalVar : line := null ;
    procedure Set (A : string) is
    begin
      deallocate(GlobalVar);
      GlobalVar := new string'(A);
    end procedure Set ;
    impure function Get return string is
    begin
      if GlobalVar = null then
        return "";
      end if;
      return GlobalVar.all ;
    end function Get ;
    procedure Clear is
    begin
      deallocate(GlobalVar);
    end procedure Clear;
  end protected body LocalStringPType ;

  file TranscriptYamlFile : text ;

  ------------------------------------------------------------
  shared variable TranscriptEnable : LocalBooleanPType ;
  shared variable TranscriptMirror : LocalBooleanPType ;
  shared variable TranscriptOpened : LocalBooleanPType ;
  shared variable TranscriptFilePath : LocalStringPType ;

  ------------------------------------------------------------
  procedure CreateTranscriptYamlLog (Name : STRING) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    -- Create Yaml file with list of files.
    if not TranscriptOpened.Get then
      file_open(TranscriptYamlFile, OSVVM_TRANSCRIPT_YAML_FILE, WRITE_MODE) ;
--      swrite(buf, "Transcripts: ") ;
--      WriteLine(TranscriptYamlFile, buf) ;
      TranscriptOpened.Set(TRUE) ;
    else
      file_open(TranscriptYamlFile, OSVVM_TRANSCRIPT_YAML_FILE, APPEND_MODE) ;
    end if ;
    swrite(buf, "  - " & Name) ;
    WriteLine(TranscriptYamlFile, buf) ;
    file_close(TranscriptYamlFile) ;
  end procedure CreateTranscriptYamlLog ;

  ------------------------------------------------------------
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) is
  ------------------------------------------------------------
  begin
    file_open(Status, TranscriptFile, ExternalName, OpenKind) ;

    if Status = OPEN_OK then
      CreateTranscriptYamlLog(ExternalName) ;
      TranscriptEnable.Set(TRUE) ;
      TranscriptFilePath.Set(ExternalName) ;
    end if ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ;
  begin
    TranscriptOpen(Status, ExternalName, OpenKind) ;
    if Status /= OPEN_OK then
      report "TranscriptPkg.TranscriptOpen file: " &
             ExternalName & " status is: " & to_string(status) & " and is not OPEN_OK" severity FAILURE ;
    end if ;
  end procedure TranscriptOpen ;

  ------------------------------------------------------------
  impure function  TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) return FILE_OPEN_STATUS is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ;
  begin
    TranscriptOpen(Status, ExternalName, OpenKind) ;
    return Status ;
  end function TranscriptOpen ;

  ------------------------------------------------------------
  procedure TranscriptClose is
  ------------------------------------------------------------
  begin
    if TranscriptEnable.Get then
      file_close(TranscriptFile) ;
    end if ;
    TranscriptEnable.Set(FALSE) ;
      TranscriptFilePath.Clear ;
  end procedure TranscriptClose ;

  ------------------------------------------------------------
  impure function IsTranscriptOpen return boolean is
  ------------------------------------------------------------
  begin
    return TranscriptEnable.Get ;
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
  procedure WriteLine(buf : inout line) is
  ------------------------------------------------------------
  begin
    if not TranscriptEnable.Get then
      WriteLine(OUTPUT, buf) ;
    elsif TranscriptMirror.Get then
      TEE(TranscriptFile, buf) ;
    else
      WriteLine(TranscriptFile, buf) ;
    end if ;
  end procedure WriteLine ;

  ------------------------------------------------------------
  procedure Print(s : string) is
  ------------------------------------------------------------
    variable buf : line ;
  begin
    write(buf, s) ;
    WriteLine(buf) ;
  end procedure Print ;

  ------------------------------------------------------------
  procedure BlankLine (count : integer := 1) is
  ------------------------------------------------------------
  begin
    for i in 1 to count loop
      print("") ;
    end loop ;
  end procedure Blankline ;

  ------------------------------------------------------------
  impure function GetTranscriptFilePath return string is
  ------------------------------------------------------------
  begin
    return TranscriptFilePath.Get;
  end function GetTranscriptFilePath ;

end package body TranscriptPkg ;