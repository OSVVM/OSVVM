--
--  File Name:         ReportPkg.vhd
--  Design Unit Name:  ReportPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--  Description:
--        Generate Final Reports
--        Elements of these reports come from AlertLogPkg, CoveragePkg, and 
--        the ScoreboardGenericPkg instances of ScoreboardPkg_int and ScoreboardPkg_slv
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Added timeout flag to EndOfTestReports. 
--                         Added scoreboard reporting for: unsigned, signed, and IntV
--    12/2023   2024.01    Updated WriteCovSummaryYaml to print FunctionalCoverage:  "" when no functional coverage (to work with TCL 8.5).
--    09/2023   2023.09    Added WriteSimTimeYaml.
--    07/2023   2023.07    Added call to WriteRequirementsYaml.
--    04/2023   2023.04    Added TranscriptOpen without parameters 
--    01/2023   2023.01    OSVVM_RAW_OUTPUT_DIRECTORY replaced REPORTS_DIRECTORY 
--                         Added simple TranscriptOpen that uses GetTestName
--    06/2022   2022.06    Minor reordering of EndOfTestReports
--    02/2022   2022.02    EndOfTestReports now calls WriteScoreboardYaml
--    10/2021   2021.10    Initial revision
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2021-2024 by SynthWorks Design Inc.
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
use work.TranscriptPkg.all ; 
use work.AlertLogPkg.all ;
use work.CoveragePkg.all ;
use work.ScoreboardPkg_slv.all ;
use work.ScoreboardPkg_signed.all ;
use work.ScoreboardPkg_unsigned.all ;
use work.ScoreboardPkg_int.all ;
use work.ScoreboardPkg_IntV.all ;


package ReportPkg is

  impure function EndOfTestReports (
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) ;
    TimeOut        : boolean        := FALSE 
  ) return integer ;

  procedure EndOfTestReports (
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) ;
    Stop           : boolean        := FALSE ;
    TimeOut        : boolean        := FALSE 
  ) ;
  
  procedure TranscriptOpen (OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) ;
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) ;

  alias EndOfTestSummary is EndOfTestReports[boolean, AlertCountType, boolean return integer] ;
  alias EndOfTestSummary is EndOfTestReports[boolean, AlertCountType, boolean, boolean] ;

end ReportPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body ReportPkg is

  ------------------------------------------------------------
  procedure WriteCovSummaryYaml (FileName : string ) is
  ------------------------------------------------------------
--x    file OsvvmYamlFile : text open APPEND_MODE is FileName ;
    file OsvvmYamlFile : text ;
    variable buf : line ;
  begin
    file_open(OsvvmYamlFile, FileName, APPEND_MODE) ;
    if GotCoverage then 
      swrite(buf, "        FunctionalCoverage: " & to_string(GetCov, 2)) ; 
    else
      swrite(buf, "        FunctionalCoverage:  " & """""") ; 
    end if ; 
    writeline(OsvvmYamlFile, buf) ; 
    file_close(OsvvmYamlFile) ;
  end procedure WriteCovSummaryYaml ;

  ------------------------------------------------------------
  procedure WriteSimTimeYaml (FileName : string ) is
  ------------------------------------------------------------
--x    file OsvvmYamlFile : text open APPEND_MODE is FileName ;
    file OsvvmYamlFile : text ;
    variable buf : line ;
  begin
    file_open(OsvvmYamlFile, FileName, APPEND_MODE) ;
    swrite(buf, "        SimulationTime: """ & to_string(NOW) & '"') ; 
    writeline(OsvvmYamlFile, buf) ; 
    file_close(OsvvmYamlFile) ;
  end procedure WriteSimTimeYaml ;

  ------------------------------------------------------------
  impure function EndOfTestReports (
  ------------------------------------------------------------
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) ;
    TimeOut        : boolean        := FALSE 
  ) return integer is
  begin
    if GotCoverage then 
      WriteCovYaml (
        FileName      => OSVVM_RAW_OUTPUT_DIRECTORY &  GetTestName & "_cov.yml"
      ) ;
      RecordCovRequirements ;
    end if ; 
    
    if work.ScoreboardPkg_slv.GotScoreboards then 
      work.ScoreboardPkg_slv.WriteScoreboardYaml (
        FileName => "slv", FileNameIsBaseName => TRUE
      ) ;
    end if ; 
    
    if work.ScoreboardPkg_unsigned.GotScoreboards then 
      work.ScoreboardPkg_unsigned.WriteScoreboardYaml (
        FileName => "unsigned", FileNameIsBaseName => TRUE
      ) ;
    end if ; 

    if work.ScoreboardPkg_signed.GotScoreboards then 
      work.ScoreboardPkg_signed.WriteScoreboardYaml (
        FileName => "signed", FileNameIsBaseName => TRUE
      ) ;
    end if ; 

    if work.ScoreboardPkg_int.GotScoreboards then 
      work.ScoreboardPkg_int.WriteScoreboardYaml (
        FileName => "int", FileNameIsBaseName => TRUE
      ) ;
    end if ; 

    if work.ScoreboardPkg_IntV.GotScoreboards then 
      work.ScoreboardPkg_IntV.WriteScoreboardYaml (
        FileName => "IntV", FileNameIsBaseName => TRUE
      ) ;
    end if ; 

    if GotRequirements then 
      WriteRequirementsYaml (
        FileName      => OSVVM_RAW_OUTPUT_DIRECTORY &  GetTestName & "_req.yml"
      ) ;
    end if ; 
    
    -- Summarize Results Last to allow previous steps to update Alerts
    WriteCovSummaryYaml (
      FileName        => OSVVM_BUILD_YAML_FILE
    ) ;
    WriteSimTimeYaml (
      FileName        => OSVVM_BUILD_YAML_FILE
    ) ;
    
    ReportAlerts(ExternalErrors => ExternalErrors, ReportAll => ReportAll, TimeOut => TimeOut) ; 
    
    WriteAlertSummaryYaml(
      FileName        => OSVVM_BUILD_YAML_FILE, 
      ExternalErrors  => ExternalErrors,
      TimeOut         => TimeOut
    ) ; 
	
    WriteAlertYaml (
      FileName        => OSVVM_RAW_OUTPUT_DIRECTORY &  GetTestName & "_alerts.yml", 
      ExternalErrors  => ExternalErrors,
      TimeOut         => TimeOut
    ) ; 
    
    TranscriptClose ; -- Close Transcript if open

    return SumAlertCount(GetAlertCount + ExternalErrors) ;
  end function EndOfTestReports ;

  ------------------------------------------------------------
  procedure EndOfTestReports (
  ------------------------------------------------------------
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) ;
    Stop           : boolean        := FALSE ;
    TimeOut        : boolean        := FALSE 
  ) is
    variable ErrorCount : integer ; 
  begin
    ErrorCount := EndOfTestReports(ReportAll, ExternalErrors, TimeOut) ;
    if Stop then 
      std.env.stop ; 
    end if ;
  end procedure EndOfTestReports ;

  ------------------------------------------------------------
  procedure TranscriptOpen (OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) is
  ------------------------------------------------------------
    variable Status : FILE_OPEN_STATUS ; 
  begin
    TranscriptOpen(Status, OSVVM_RAW_OUTPUT_DIRECTORY & GetTranscriptName, OpenKind) ;
  end procedure TranscriptOpen ; 

  ------------------------------------------------------------
  procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; OpenKind: WRITE_APPEND_OPEN_KIND := WRITE_MODE) is
  ------------------------------------------------------------
  begin
    TranscriptOpen(Status, OSVVM_RAW_OUTPUT_DIRECTORY & GetTranscriptName, OpenKind) ;
  end procedure TranscriptOpen ; 
  


end package body ReportPkg ;