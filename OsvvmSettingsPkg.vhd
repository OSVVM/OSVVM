--
--  File Name:         OsvvmSettingsPkg_default.vhd
--  Design Unit Name:  OsvvmSettingsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description:
--     OSVVM Settings package
--     The package, OsvvmSettingsPkg_default.vhd contains the current
--     defaults supplied by OSVVM.
--     To change these, create a package with the revised settings
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

package OsvvmSettingsPkg is

  -- ------------------------------------------
  -- Settings for RandomPkg
  -- ------------------------------------------
  -- RandomPkg.InitSeed:
  --   For new designs, make this TRUE.
  --   For old designs, changing it will change your randomization.  If you need that exact pattern, then do not change.
  constant RANDOM_USE_NEW_SEED_METHODS : boolean ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings for ScoreboardGenericPkg
  -- ------------------------------------------
  -- WriteScoreboardYaml
  constant SCOREBOARD_YAML_IS_BASE_FILE_NAME : boolean ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings shared by AlertLogPkg and CoveragePkg
  -- ------------------------------------------
  -- Output Formatting
  constant  OSVVM_PASS_NAME               : string  ;
  constant  OSVVM_FAIL_NAME               : string  ;
  constant  OSVVM_PRINT_PREFIX            : string  ;
  constant  OSVVM_SECONDARY_PREFIX        : string  ;
  constant  OSVVM_BLANK_LINE_PREFIX       : string  ;
  constant  OSVVM_HEADER_PREFIX           : string  ;
  constant  OSVVM_HEADER_SUFFIX           : string  ;
  constant  OSVVM_LINE_LENGTH             : integer ; -- For lines of "===" in headers such as LogHeader
  constant  OSVVM_LINE_WRAP               : integer ; -- For PrintLine - set to integer'high to disable
  constant  OSVVM_LONG_SECONDARY_PREFIX   : string  ;

  constant  OSVVM_DEFAULT_TIME_UNITS               : time ;
  constant  OSVVM_DIGITS_FOR_TIME_FRACTION         : natural ;
  constant  OSVVM_MAX_DIGITS_FOR_FIXED_POINT_REAL  : natural ;
  constant  OSVVM_DIGITS_FOR_REAL_FRACTION         : natural ;
  constant  OSVVM_MAX_TIME_DECIMAL_DIGITS          : natural ; -- Max number of 10**Digits in 2**62 - 1. Should be around 19 + 1 for decimal point

  -- ------------------------------------------
  -- Settings for CoveragePkg
  -- ------------------------------------------
  -- COVERAGE_REQUIREMENT_BY_BIN
  --   if TRUE, each bin of a coverage model is one requirement.
  --   if FALSE, an entire coverage model is one requirement,
  constant  COVERAGE_REQUIREMENT_BY_BIN   : boolean ;
  constant  COVERAGE_DEFAULT_WEIGHT_MODE  : string ;
  -- InitSeed:  When TRUE uses updated seed methods.  TRUE for coverage singleton.
  constant  COVERAGE_USE_NEW_SEED_METHODS : boolean ;

  -- OUTPUT formatting
  constant  COVERAGE_PRINT_PREFIX         : string ;
  constant  COVERAGE_PASS_NAME            : string ;
  constant  COVERAGE_FAIL_NAME            : string ;

  -- WriteBin Settings - not relevant if you use the HTML reports
  constant COVERAGE_WRITE_PASS_FAIL   : boolean ;
  constant COVERAGE_WRITE_BIN_INFO    : boolean ;
  constant COVERAGE_WRITE_COUNT       : boolean ;
  constant COVERAGE_WRITE_ANY_ILLEGAL : boolean ;

  -- ------------------------------------------
  -- Settings for AlertLogPkg
  -- ------------------------------------------
  -- Control printing of Alert/Log
  constant  ALERT_LOG_WRAP                       : boolean ; -- Do not WRAP.  Off by default.  Using LF at start or end of line turns it on
--  constant  ALERT_LOG_WRAP                       : boolean ; -- Historic FALSE = Do not WRAP
  constant  ALERT_LOG_INDENTED_LENGTH            : integer ;
  constant  ALERT_LOG_JUSTIFY_ENABLE             : boolean ; -- Historic FALSE = Do not Justify printing
  constant  ALERT_LOG_WRITE_TIME_FIRST           : boolean ; -- Historic FALSE - If ALERT_LOG_WRAP - then must be TRUE
  constant  ALERT_LOG_TIME_JUSTIFY_AMOUNT        : integer ;  -- Justify time. Historic 0. Particularly when at beginning
  constant  ALERT_LOG_DIGITS_FOR_TIME_FRACTION   : integer ;
  constant  ALERT_LOG_DIGITS_FOR_REAL_FRACTION   : natural ;

  -- File Match/Diff controls - defaults for AffirmIfTranscriptsMatch, AffirmIfFilesMatch, AlertIfDiff
  constant  ALERT_LOG_IGNORE_SPACES              : boolean ; -- Historic FALSE
  constant  ALERT_LOG_IGNORE_EMPTY_LINES         : boolean ; -- Historic FALSE

  -- OUTPUT Formatting
  -- Boolean controls to print or not print fields in Alert/Log
  constant  ALERT_LOG_WRITE_ERRORCOUNT           : boolean ;  -- prefix message with # of errors - requested by Marco for Mike P.
  constant  ALERT_LOG_WRITE_NAME                 : boolean ;   -- Print Alert/Log
  constant  ALERT_LOG_WRITE_LEVEL                : boolean ;   -- Print Level - FAILURE, ERROR, WARNING, INFO, ...
  constant  ALERT_LOG_WRITE_TIME                 : boolean ;   -- Print time

  constant  ALERT_LOG_DONE_NAME                  : string  ; -- Adjusted spacing to match Alert
  constant  ALERT_LOG_PASS_NAME                  : string  ;
  constant  ALERT_LOG_FAIL_NAME                  : string  ;
  constant  ALERT_LOG_PRINT_PREFIX               : string  ;
  constant  ALERT_LOG_ALERT_NAME                 : string  ;
  constant  ALERT_LOG_LOG_NAME                   : string  ;  -- Adjusted spacing to match Alert
  constant  ALERT_LOG_NAME_LENGTH                : integer ;
  constant  ALERT_LOG_ID_SEPARATOR               : string  ;
  constant  ALERT_LOG_SPACES_BEFORE_ALERT        : string  ; -- Adds to the 1 space already there
  constant  ALERT_LOG_SPACES_BEFORE_LEVEL        : string  ;  -- Keeping 1 to equalize the length of DONE and Alert
  constant  ALERT_LOG_SPACES_BEFORE_ID_NAME      : string  ;   -- Adds to the 1 space already there
  constant  ALERT_LOG_WRAP_INDENT_CHAR           : character  ;
  constant  ALERT_LOG_WRAP_END_CHAR              : character  ;

--  Handled by scripts.   Generate NOCHECKS, scripts handles whether it is an error or PASSED.
--  constant ALERT_LOG_NOCHECKS_NAME               : string ;
  constant ALERT_LOG_NOCHECKS_NAME               : string ;
  constant ALERT_LOG_MANUALCHECKS_NAME           : string ;
  constant ALERT_LOG_TIMEOUT_NAME                : string ;
  constant ALERT_LOG_STOPLIMIT_NAME              : string ;

  -- Defaults for Stop Counts
  constant  ALERT_LOG_STOP_COUNT_FAILURE         : integer ; -- OSVVM 1
  constant  ALERT_LOG_STOP_COUNT_ERROR           : integer ; -- OSVVM 2**31-1, VUnit 1
  constant  ALERT_LOG_STOP_COUNT_WARNING         : integer ; -- OSVVM 2**31-1

  -- Allows disabling alerts at startup - and then turn them on at or near system reset
  constant  ALERT_LOG_GLOBAL_ALERT_ENABLE        : boolean ;

  -- requirements
  constant  ALERT_LOG_DEFAULT_PASSED_GOAL        : integer ;

  -- Control what makes a test failure
  constant  ALERT_LOG_FAIL_ON_WARNING            : boolean ;
  constant  ALERT_LOG_FAIL_ON_DISABLED_ERRORS    : boolean ;
  constant  ALERT_LOG_FAIL_ON_REQUIREMENT_ERRORS : boolean ;
--   constant  ALERT_LOG_FAIL_ON_VHDL_ASSERT_ERRORS : boolean ;
  constant  ALERT_LOG_FAIL_ON_VHDL_ASSERT_ERRORS : boolean ;
  constant  ALERT_LOG_PRINT_VHDL_ASSERT_ERRORS   : boolean ;

  -- ReportAlerts Settings -- HTML report prints all of these.  These only impact the text report.
  constant ALERT_LOG_REPORT_HIERARCHY            : boolean ;   -- ReportAerts
  constant ALERT_LOG_PRINT_PASSED                : boolean ;   -- ReportAlerts: Print PassedCount
  constant ALERT_LOG_PRINT_AFFIRMATIONS          : boolean ;  -- ReportAlerts: Print Affirmations Checked
  constant ALERT_LOG_PRINT_DISABLED_ALERTS       : boolean ;  -- ReportAlerts: Print Disabled Alerts
  constant ALERT_LOG_PRINT_REQUIREMENTS          : boolean ;  -- ReportAlerts: Print requirements
  constant ALERT_LOG_PRINT_IF_HAVE_REQUIREMENTS  : boolean ;   -- ReportAlerts: Print requirements if have any

  -- DEPRECATED:
  -- DEPRECATED:   Use OSVVM_DONE_NAME
  -- DEPRECATED:
  constant  OSVVM_DONE_NAME               : string  ;

--!!  -- Defaults for Log Enables
--!!  onstant LOG_ENABLE_INFO             : boolean ;
--!!  onstant LOG_ENABLE_DEBUG            : boolean ;
--!!  onstant LOG_ENABLE_PASSED           : boolean ;
--!!  onstant LOG_ENABLE_FINAL            : boolean ;
--!!
--!!  -- Controls for default Alert enables
--!!  onstant ALERT_ENABLE_FAILURE       : boolean ; -- TRUE and not setable
--!!  onstant ALERT_ENABLE_ERROR         : boolean ; -- TRUE and not setable
--!!  onstant ALERT_ENABLE_WARNING       : boolean ; -- TRUE and not setable
--!!
--!!  There does not seem to be any compelling reason for these
--!!  Instead, I suspect code will be optimized better if these are merged into a single ALERT_LOG value
--!!  -- Controls that split the Alert/Log controls separately
--!!  onstant  ALERT_WRITE_ERRORCOUNT      : boolean ;  -- Prefix message with # of errors
--!!  onstant  ALERT_WRITE_LEVEL           : boolean ;   -- Print FAILURE, ERROR, WARNING
--!!  onstant  ALERT_WRITE_NAME            : boolean ;   -- Print Alert Message
--!!  onstant  LOG_WRITE_ERRORCOUNT        : boolean ;  -- Prefix message with # of errors
--!!  onstant  LOG_WRITE_LEVEL             : boolean ;   -- Print ALWAYS, INFO, DEBUG, FINAL, PASSED
--!!  onstant  LOG_WRITE_NAME              : boolean ;   -- Print Log Message


end package OsvvmSettingsPkg ;
