--
--  File Name:         OsvvmSettingsPkg_default.vhd
--  Design Unit Name:  OsvvmSettingsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description:
--     OSVVM Settings package body
--     The package body, OsvvmSettingsPkg_default.vhd contains the current
--     defaults supplied by OSVVM.
--     To change these, create a package body with the revised settings
--     in the file OsvvmSettingsPkg_local.vhd
--
--     If the file OsvvmSettingsPkg_local.vhd exits it will be analyzed by
--     the scripts if it exists, otherwise, OsvvmSettingsPkg_default.vhd
--     will be analyzed.
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    02/2025   2025.02    Added COVERAGE_REQUIREMENT_BY_BIN
--    09/2024   2024.09    Added ALERT_LOG_IGNORE_SPACES and ALERT_LOG_IGNORE_EMPTY_LINES
--    07/2024   2024.07    Added ALERT_LOG_NOCHECKS_NAME and ALERT_LOG_TIMEOUT_NAME
--    03/2024   2024.03    Major updates
--    09/2023   2023.09    Initial
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2023 - 2024 by SynthWorks Design Inc.
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

use work.IfElsePkg.all ;
use work.OsvvmScriptSettingsPkg.all ;

package body OsvvmSettingsPkg is

  -- ------------------------------------------
  -- Settings for RandomPkg
  -- ------------------------------------------
  -- RandomPkg.InitSeed:
  --   For new designs, make this TRUE.
  --   For old designs, changing it will change your randomization.  If you need that exact pattern, then do not change.
  constant RANDOM_USE_NEW_SEED_METHODS : boolean := IfElse(OSVVM_SETTINGS_REVISION >= "2024", TRUE, FALSE) ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings for ScoreboardGenericPkg
  -- ------------------------------------------
  -- WriteScoreboardYaml
  constant SCOREBOARD_YAML_IS_BASE_FILE_NAME : boolean := IfElse(OSVVM_SETTINGS_REVISION >= "2024", TRUE, FALSE) ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings shared by AlertLogPkg and CoveragePkg
  -- ------------------------------------------
  -- Output Formatting
  constant  OSVVM_PRINT_PREFIX         : string := "%% " ;
  constant  OSVVM_DONE_NAME            : string := "DONE" ;
  constant  OSVVM_PASS_NAME            : string := "PASSED" ;
  constant  OSVVM_FAIL_NAME            : string := "FAILED" ;

  constant  OSVVM_DEFAULT_TIME_UNITS   : time := 1 ns ;

  -- ------------------------------------------
  -- Settings for CoveragePkg
  -- ------------------------------------------
  -- COVERAGE_REQUIREMENT_BY_BIN
  --   if TRUE, each bin of a coverage model is one requirement. 
  --   if FALSE, an entire coverage model is one requirement, 
  constant  COVERAGE_REQUIREMENT_BY_BIN   : boolean := TRUE ;  
  constant  COVERAGE_DEFAULT_WEIGHT_MODE  : string := IfElse(OSVVM_SETTINGS_REVISION >= "2024", string'("REMAIN"), "AT_LEAST") ;
  -- InitSeed:  When TRUE uses updated seed methods.  TRUE for coverage singleton.
  constant  COVERAGE_USE_NEW_SEED_METHODS : boolean := TRUE ;
  
  -- OUTPUT formatting
  constant  COVERAGE_PRINT_PREFIX         : string := OSVVM_PRINT_PREFIX ;
  constant  COVERAGE_PASS_NAME            : string := OSVVM_PASS_NAME ;
  constant  COVERAGE_FAIL_NAME            : string := OSVVM_FAIL_NAME ;

  -- WriteBin Settings - not relevant if you use the HTML reports
  constant COVERAGE_WRITE_PASS_FAIL   : boolean := FALSE ;
  constant COVERAGE_WRITE_BIN_INFO    : boolean := TRUE ;
  constant COVERAGE_WRITE_COUNT       : boolean := TRUE ;
  constant COVERAGE_WRITE_ANY_ILLEGAL : boolean := FALSE ;


  -- ------------------------------------------
  -- Settings for AlertLogPkg
  -- ------------------------------------------
  -- Control printing of Alert/Log
  constant  ALERT_LOG_JUSTIFY_ENABLE             : boolean := IfElse(OSVVM_SETTINGS_REVISION >= "2024", TRUE, FALSE) ; -- Historic FALSE - Do not Justify printing
  constant  ALERT_LOG_WRITE_TIME_FIRST           : boolean := IfElse(OSVVM_SETTINGS_REVISION >= "2024", TRUE, FALSE) ; -- Historic FALSE
  constant  ALERT_LOG_WRITE_TIME_LAST            : boolean := not ALERT_LOG_WRITE_TIME_FIRST ;
  constant  ALERT_LOG_TIME_JUSTIFY_AMOUNT        : integer := IfElse(OSVVM_SETTINGS_REVISION >= "2024", 9, 0) ;  -- Justify time - particularly when at beginning

  -- File Match/Diff controls - defaults for AffirmIfTranscriptsMatch, AffirmIfFilesMatch, AlertIfDiff
  constant  ALERT_LOG_IGNORE_SPACES                : boolean := FALSE ; -- Historic FALSE
  constant  ALERT_LOG_IGNORE_EMPTY_LINES           : boolean := FALSE ; -- Historic FALSE

  -- OUTPUT Formatting
  -- Boolean controls to print or not print fields in Alert/Log
  constant  ALERT_LOG_WRITE_ERRORCOUNT           : boolean := FALSE ;  -- prefix message with # of errors - requested by Marco for Mike P.
  constant  ALERT_LOG_WRITE_NAME                 : boolean := TRUE ;   -- Print Alert/Log
  constant  ALERT_LOG_WRITE_LEVEL                : boolean := TRUE ;   -- Print Level Name
  constant  ALERT_LOG_WRITE_TIME                 : boolean := TRUE ;   -- Print Level Name

  constant  ALERT_LOG_ALERT_NAME                 : string := "Alert" ;
  constant  ALERT_LOG_LOG_NAME                   : string := "Log  " ;
  constant  ALERT_LOG_ID_SEPARATOR               : string := ": " ;
  constant  ALERT_LOG_PRINT_PREFIX               : string := OSVVM_PRINT_PREFIX ;
  constant  ALERT_LOG_DONE_NAME                  : string := OSVVM_DONE_NAME ;
  constant  ALERT_LOG_PASS_NAME                  : string := OSVVM_PASS_NAME ;
  constant  ALERT_LOG_FAIL_NAME                  : string := OSVVM_FAIL_NAME ;

--  Handled by scripts.   Generate NOCHECKS, scripts handles whether it is an error or PASSED.
--  constant ALERT_LOG_NOCHECKS_NAME               : string := IfElse(OSVVM_SETTINGS_REVISION >= "2024.07", "NOCHECKS", "PASSED") ;
  constant ALERT_LOG_NOCHECKS_NAME               : string := "NOCHECKS" ;
  constant ALERT_LOG_TIMEOUT_NAME                : string := "TIMEOUT" ;

  -- Defaults for Stop Counts
  constant  ALERT_LOG_STOP_COUNT_FAILURE         : integer := 0 ;
  constant  ALERT_LOG_STOP_COUNT_ERROR           : integer := integer'high ; --  VUnit 1
  constant  ALERT_LOG_STOP_COUNT_WARNING         : integer := integer'high ;

  -- Allows disabling alerts at startup - and then turn them on at or near system reset
  constant  ALERT_LOG_GLOBAL_ALERT_ENABLE        : boolean := TRUE ;

  -- requirements
  constant  ALERT_LOG_DEFAULT_PASSED_GOAL        : integer := 1 ;

  -- Control what makes a test failure
  constant  ALERT_LOG_FAIL_ON_WARNING            : boolean := TRUE ;
  constant  ALERT_LOG_FAIL_ON_DISABLED_ERRORS    : boolean := TRUE ;
  constant  ALERT_LOG_FAIL_ON_REQUIREMENT_ERRORS : boolean := TRUE ;

  -- ReportAlerts Settings
  constant ALERT_LOG_REPORT_HIERARCHY            : boolean := TRUE ;   -- ReportAerts
  constant ALERT_LOG_PRINT_PASSED                : boolean := TRUE ;   -- ReportAlerts: Print PassedCount
  constant ALERT_LOG_PRINT_AFFIRMATIONS          : boolean := FALSE ;  -- ReportAlerts: Print Affirmations Checked
  constant ALERT_LOG_PRINT_DISABLED_ALERTS       : boolean := FALSE ;  -- ReportAlerts: Print Disabled Alerts
  constant ALERT_LOG_PRINT_REQUIREMENTS          : boolean := FALSE ;  -- ReportAlerts: Print requirements
  constant ALERT_LOG_PRINT_IF_HAVE_REQUIREMENTS  : boolean := TRUE ;   -- ReportAlerts: Print requirements if have any


--!!  -- Defaults for Log Enables
--!!  constant LOG_ENABLE_INFO             : boolean := FALSE ;
--!!  constant LOG_ENABLE_DEBUG            : boolean := FALSE ;
--!!  constant LOG_ENABLE_PASSED           : boolean := FALSE ;
--!!  constant LOG_ENABLE_FINAL            : boolean := FALSE ;
--!!
--!!  -- Controls for default Alert enables
--!!  constant ALERT_ENABLE_FAILURE       : boolean := TRUE ; -- TRUE and not setable
--!!  constant ALERT_ENABLE_ERROR         : boolean := TRUE ; -- TRUE and not setable
--!!  constant ALERT_ENABLE_WARNING       : boolean := TRUE ; -- TRUE and not setable
--!!
--!!  There does not seem to be any compelling reason for these
--!!  Instead, I suspect code will be optimized better if these are merged into a single ALERT_LOG value
--!!  -- Controls that split the Alert/Log controls separately
--!!  constant  ALERT_WRITE_ERRORCOUNT      : boolean := ALERT_LOG_WRITE_ERRORCOUNT ;  -- Prefix message with # of errors
--!!  constant  ALERT_WRITE_LEVEL           : boolean := ALERT_LOG_WRITE_LEVEL     ;   -- Print FAILURE, ERROR, WARNING
--!!  constant  ALERT_WRITE_NAME            : boolean := ALERT_LOG_WRITE_NAME      ;   -- Print Alert Message
--!!  constant  LOG_WRITE_ERRORCOUNT        : boolean := ALERT_LOG_WRITE_ERRORCOUNT ;  -- Prefix message with # of errors
--!!  constant  LOG_WRITE_LEVEL             : boolean := ALERT_LOG_WRITE_LEVEL     ;   -- Print ALWAYS, INFO, DEBUG, FINAL, PASSED
--!!  constant  LOG_WRITE_NAME              : boolean := ALERT_LOG_WRITE_NAME      ;   -- Print Log Message


end package body OsvvmSettingsPkg ;