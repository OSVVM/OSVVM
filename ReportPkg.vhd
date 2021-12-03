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
--    10/2021   2021.10    Initial revision
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2021 by SynthWorks Design Inc.
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
use work.AlertLogPkg.all ;
use work.CoveragePkg.all ;
use work.ScoreboardPkg_slv.all ;
use work.ScoreboardPkg_int.all ;


package ReportPkg is


  impure function EndOfTestReports (
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) 
  ) return integer ;

  procedure EndOfTestReports (
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) ;
    Stop           : boolean        := FALSE
  ) ;
  
  alias EndOfTestSummary is EndOfTestReports[boolean, AlertCountType return integer] ;
  alias EndOfTestSummary is EndOfTestReports[boolean, AlertCountType, boolean] ;

end ReportPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body ReportPkg is

  ------------------------------------------------------------
  impure function EndOfTestReports (
  ------------------------------------------------------------
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) 
  ) return integer is
  begin
    ReportAlerts(ExternalErrors => ExternalErrors, ReportAll => ReportAll) ; 
    
    WriteAlertSummaryYaml(
      FileName        => "./reports/OsvvmRun.yml", 
      ExternalErrors  => ExternalErrors
    ) ; 
    WriteAlertYaml (
      FileName        => "./reports/" & GetAlertLogName & "_alerts.yml", 
      ExternalErrors  => ExternalErrors
    ) ; 
        
    if GotCoverage then 
      WriteCovYaml (
        FileName     => "./reports/" & GetAlertLogName & "_cov.yml"
      ) ;
    end if ; 
    
--    if work.ScoreboardPkg_slv.GotScoreboard then 
--       work.ScoreboardPkg_slv.WriteScoreboardYaml ;
--    end if ; 
--
--    if work.ScoreboardPkg_int.GotScoreboard then 
--       work.ScoreboardPkg_int.WriteScoreboardYaml ;
--    end if ; 

    return SumAlertCount(GetAlertCount + ExternalErrors) ;
  end function EndOfTestReports ;

  ------------------------------------------------------------
  procedure EndOfTestReports (
  ------------------------------------------------------------
    ReportAll      : boolean        := FALSE ;
    ExternalErrors : AlertCountType := (0,0,0) ;
    Stop           : boolean        := FALSE
  ) is
    variable ErrorCount : integer ; 
  begin
    ErrorCount := EndOfTestReports(ReportAll, ExternalErrors) ;
    if Stop then 
      std.env.stop(ErrorCount) ; 
    end if ;
  end procedure EndOfTestReports ;


end package body ReportPkg ;