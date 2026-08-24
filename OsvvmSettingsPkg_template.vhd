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
  constant RANDOM_USE_NEW_SEED_METHODS : boolean := ${RANDOM_USE_NEW_SEED_METHODS} ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings for ScoreboardGenericPkg
  -- ------------------------------------------
  -- WriteScoreboardYaml
  constant SCOREBOARD_YAML_IS_BASE_FILE_NAME : boolean := ${SCOREBOARD_YAML_IS_BASE_FILE_NAME} ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings shared by AlertLogPkg and CoveragePkg
  -- ------------------------------------------
  -- Output Formatting
  constant  OSVVM_PASS_NAME               : string  := ${OSVVM_PASS_NAME} ;
  constant  OSVVM_FAIL_NAME               : string  := ${OSVVM_FAIL_NAME} ;
  constant  OSVVM_PRINT_PREFIX            : string  := ${OSVVM_PRINT_PREFIX} ;
  constant  OSVVM_SECONDARY_PREFIX        : string  := ${OSVVM_SECONDARY_PREFIX} ;
  -- constant  OSVVM_PRINT_USES_PREFIX       : boolean := ${OSVVM_PRINT_USES_PREFIX} ;
  constant  OSVVM_BLANK_LINE_PREFIX       : string  := ${OSVVM_BLANK_LINE_PREFIX} ;
  constant  OSVVM_HEADER_PREFIX           : string  := ${OSVVM_HEADER_PREFIX} ;
  constant  OSVVM_HEADER_SUFFIX           : string  := ${OSVVM_HEADER_SUFFIX} ;
  constant  OSVVM_LINE_LENGTH             : integer := ${OSVVM_LINE_LENGTH} ; -- For lines of "===" in headers such as LogHeader
  constant  OSVVM_LINE_WRAP               : integer := ${OSVVM_LINE_WRAP} ; -- For PrintLine - set to integer'high to disable
  constant  OSVVM_LONG_SECONDARY_PREFIX   : string  := ${OSVVM_LONG_SECONDARY_PREFIX} ;

  constant  OSVVM_DEFAULT_TIME_UNITS               : time := ${OSVVM_DEFAULT_TIME_UNITS} ;
  constant  OSVVM_DIGITS_FOR_TIME_FRACTION         : natural := ${OSVVM_DIGITS_FOR_TIME_FRACTION} ;
  constant  OSVVM_MAX_DIGITS_FOR_FIXED_POINT_REAL  : natural := ${OSVVM_MAX_DIGITS_FOR_FIXED_POINT_REAL} ;
  constant  OSVVM_DIGITS_FOR_REAL_FRACTION         : natural := ${OSVVM_DIGITS_FOR_REAL_FRACTION} ;
  constant  OSVVM_MAX_TIME_DECIMAL_DIGITS          : natural := ${OSVVM_MAX_TIME_DECIMAL_DIGITS} ; -- Max number of 10**Digits in 2**62 - 1. Should be around 19 + 1 for decimal point

  -- ------------------------------------------
  -- Settings for CoveragePkg
  -- ------------------------------------------
  -- COVERAGE_REQUIREMENT_BY_BIN
  --   if TRUE, each bin of a coverage model is one requirement.
  --   if FALSE, an entire coverage model is one requirement,
  constant  COVERAGE_REQUIREMENT_BY_BIN   : boolean := ${COVERAGE_REQUIREMENT_BY_BIN} ;
  constant  COVERAGE_DEFAULT_WEIGHT_MODE  : string := ${COVERAGE_DEFAULT_WEIGHT_MODE} ;
  -- InitSeed:  When TRUE uses updated seed methods.  TRUE for coverage singleton.
  constant  COVERAGE_USE_NEW_SEED_METHODS : boolean := ${COVERAGE_USE_NEW_SEED_METHODS} ;

  -- OUTPUT formatting
  constant  COVERAGE_PRINT_PREFIX         : string := ${COVERAGE_PRINT_PREFIX} ;
  constant  COVERAGE_PASS_NAME            : string := ${COVERAGE_PASS_NAME} ;
  constant  COVERAGE_FAIL_NAME            : string := ${COVERAGE_FAIL_NAME} ;

  -- WriteBin Settings - not relevant if you use the HTML reports
  constant COVERAGE_WRITE_PASS_FAIL   : boolean := ${COVERAGE_WRITE_PASS_FAIL} ;
  constant COVERAGE_WRITE_BIN_INFO    : boolean := ${COVERAGE_WRITE_BIN_INFO} ;
  constant COVERAGE_WRITE_COUNT       : boolean := ${COVERAGE_WRITE_COUNT} ;
  constant COVERAGE_WRITE_ANY_ILLEGAL : boolean := ${COVERAGE_WRITE_ANY_ILLEGAL} ;

  -- ------------------------------------------
  -- Settings for AlertLogPkg
  -- ------------------------------------------
  -- Control printing of Alert/Log
  constant  ALERT_LOG_WRAP                       : boolean := ${ALERT_LOG_WRAP} ; -- Do not WRAP.  Off by default.  Using LF at start or end of line turns it on
--  constant  ALERT_LOG_WRAP                       : boolean := ${ALERT_LOG_WRAP} ; -- Historic FALSE = Do not WRAP
  constant  ALERT_LOG_INDENTED_LENGTH            : integer := ${ALERT_LOG_INDENTED_LENGTH} ;
  constant  ALERT_LOG_JUSTIFY_ENABLE             : boolean := ${ALERT_LOG_JUSTIFY_ENABLE} ; -- Historic FALSE = Do not Justify printing
  constant  ALERT_LOG_WRITE_TIME_FIRST           : boolean := ${ALERT_LOG_WRITE_TIME_FIRST} ; -- Historic FALSE - If ALERT_LOG_WRAP - then must be TRUE
  constant  ALERT_LOG_TIME_JUSTIFY_AMOUNT        : integer := ${ALERT_LOG_TIME_JUSTIFY_AMOUNT} ;  -- Justify time. Historic 0. Particularly when at beginning
  constant  ALERT_LOG_DIGITS_FOR_TIME_FRACTION   : integer := ${ALERT_LOG_DIGITS_FOR_TIME_FRACTION} ;
  constant  ALERT_LOG_DIGITS_FOR_REAL_FRACTION   : natural := ${ALERT_LOG_DIGITS_FOR_REAL_FRACTION} ;

  -- File Match/Diff controls - defaults for AffirmIfTranscriptsMatch, AffirmIfFilesMatch, AlertIfDiff
  constant  ALERT_LOG_IGNORE_SPACES              : boolean := ${ALERT_LOG_IGNORE_SPACES} ; -- Historic FALSE
  constant  ALERT_LOG_IGNORE_EMPTY_LINES         : boolean := ${ALERT_LOG_IGNORE_EMPTY_LINES} ; -- Historic FALSE

  -- OUTPUT Formatting
  -- Boolean controls to print or not print fields in Alert/Log
  constant  ALERT_LOG_WRITE_ERRORCOUNT           : boolean := ${ALERT_LOG_WRITE_ERRORCOUNT} ;  -- prefix message with # of errors - requested by Marco for Mike P.
  constant  ALERT_LOG_WRITE_NAME                 : boolean := ${ALERT_LOG_WRITE_NAME} ;   -- Print Alert/Log
  constant  ALERT_LOG_WRITE_LEVEL                : boolean := ${ALERT_LOG_WRITE_LEVEL} ;   -- Print Level - FAILURE, ERROR, WARNING, INFO, ...
  constant  ALERT_LOG_WRITE_TIME                 : boolean := ${ALERT_LOG_WRITE_TIME} ;   -- Print time

  constant  ALERT_LOG_DONE_NAME                  : string  := ${ALERT_LOG_DONE_NAME} ;
  constant  ALERT_LOG_PASS_NAME                  : string  := ${ALERT_LOG_PASS_NAME} ;
  constant  ALERT_LOG_FAIL_NAME                  : string  := ${ALERT_LOG_FAIL_NAME} ;
  constant  ALERT_LOG_PRINT_PREFIX               : string  := ${ALERT_LOG_PRINT_PREFIX} ;
  constant  ALERT_LOG_ALERT_NAME                 : string  := ${ALERT_LOG_ALERT_NAME} ;
  constant  ALERT_LOG_LOG_NAME                   : string  := ${ALERT_LOG_LOG_NAME} ;
  constant  ALERT_LOG_NAME_LENGTH                : integer := ${ALERT_LOG_NAME_LENGTH} ;
  constant  ALERT_LOG_ID_SEPARATOR               : string  := ${ALERT_LOG_ID_SEPARATOR} ;
  constant  ALERT_LOG_SPACES_BEFORE_ALERT        : string  := ${ALERT_LOG_SPACES_BEFORE_ALERT} ; -- Keeping 2 space between time and Alert/Log
  constant  ALERT_LOG_SPACES_BEFORE_LEVEL        : string  := ${ALERT_LOG_SPACES_BEFORE_LEVEL} ;  -- Keeping 1 to equalize the length of DONE and Alert
  constant  ALERT_LOG_SPACES_BEFORE_ID_NAME      : string  := ${ALERT_LOG_SPACES_BEFORE_ID_NAME} ; -- has 1 in addition to this

--  Handled by scripts.   Generate NOCHECKS, scripts handles whether it is an error or PASSED.
--  constant ALERT_LOG_NOCHECKS_NAME               : string := ${ALERT_LOG_NOCHECKS_NAME} ;
  constant ALERT_LOG_NOCHECKS_NAME               : string := ${ALERT_LOG_NOCHECKS_NAME} ;
  constant ALERT_LOG_MANUALCHECKS_NAME           : string := ${ALERT_LOG_MANUALCHECKS_NAME} ;
  constant ALERT_LOG_TIMEOUT_NAME                : string := ${ALERT_LOG_TIMEOUT_NAME} ;

  -- Defaults for Stop Counts
  constant  ALERT_LOG_STOP_COUNT_FAILURE         : integer := ${ALERT_LOG_STOP_COUNT_FAILURE} ; -- OSVVM 1
  constant  ALERT_LOG_STOP_COUNT_ERROR           : integer := ${ALERT_LOG_STOP_COUNT_ERROR} ; -- OSVVM 2**31-1, VUnit 1
  constant  ALERT_LOG_STOP_COUNT_WARNING         : integer := ${ALERT_LOG_STOP_COUNT_WARNING} ; -- OSVVM 2**31-1

  -- Allows disabling alerts at startup - and then turn them on at or near system reset
  constant  ALERT_LOG_GLOBAL_ALERT_ENABLE        : boolean := ${ALERT_LOG_GLOBAL_ALERT_ENABLE} ;

  -- requirements
  constant  ALERT_LOG_DEFAULT_PASSED_GOAL        : integer := ${ALERT_LOG_DEFAULT_PASSED_GOAL} ;

  -- Control what makes a test failure
  constant  ALERT_LOG_FAIL_ON_WARNING            : boolean := ${ALERT_LOG_FAIL_ON_WARNING} ;
  constant  ALERT_LOG_FAIL_ON_DISABLED_ERRORS    : boolean := ${ALERT_LOG_FAIL_ON_DISABLED_ERRORS} ;
  constant  ALERT_LOG_FAIL_ON_REQUIREMENT_ERRORS : boolean := ${ALERT_LOG_FAIL_ON_REQUIREMENT_ERRORS} ;
--   constant  ALERT_LOG_FAIL_ON_VHDL_ASSERT_ERRORS : boolean := ${ALERT_LOG_FAIL_ON_VHDL_ASSERT_ERRORS} ;
  constant  ALERT_LOG_FAIL_ON_VHDL_ASSERT_ERRORS : boolean := ${ALERT_LOG_FAIL_ON_VHDL_ASSERT_ERRORS} ;
  constant  ALERT_LOG_PRINT_VHDL_ASSERT_ERRORS   : boolean := ${ALERT_LOG_PRINT_VHDL_ASSERT_ERRORS} ;

  -- ReportAlerts Settings -- HTML report prints all of these.  These only impact the text report.
  constant ALERT_LOG_REPORT_HIERARCHY            : boolean := ${ALERT_LOG_REPORT_HIERARCHY} ;   -- ReportAerts
  constant ALERT_LOG_PRINT_PASSED                : boolean := ${ALERT_LOG_PRINT_PASSED} ;   -- ReportAlerts: Print PassedCount
  constant ALERT_LOG_PRINT_AFFIRMATIONS          : boolean := ${ALERT_LOG_PRINT_AFFIRMATIONS} ;  -- ReportAlerts: Print Affirmations Checked
  constant ALERT_LOG_PRINT_DISABLED_ALERTS       : boolean := ${ALERT_LOG_PRINT_DISABLED_ALERTS} ;  -- ReportAlerts: Print Disabled Alerts
  constant ALERT_LOG_PRINT_REQUIREMENTS          : boolean := ${ALERT_LOG_PRINT_REQUIREMENTS} ;  -- ReportAlerts: Print requirements
  constant ALERT_LOG_PRINT_IF_HAVE_REQUIREMENTS  : boolean := ${ALERT_LOG_PRINT_IF_HAVE_REQUIREMENTS} ;   -- ReportAlerts: Print requirements if have any

  -- DEPRECATED:
  -- DEPRECATED:   Use ALERT_LOG_DONE_NAME
  -- DEPRECATED:
  constant  OSVVM_DONE_NAME               : string  := ${OSVVM_DONE_NAME} ;

--!!  -- Defaults for Log Enables
--!!  constant LOG_ENABLE_INFO             : boolean := ${LOG_ENABLE_INFO} ;
--!!  constant LOG_ENABLE_DEBUG            : boolean := ${LOG_ENABLE_DEBUG} ;
--!!  constant LOG_ENABLE_PASSED           : boolean := ${LOG_ENABLE_PASSED} ;
--!!  constant LOG_ENABLE_FINAL            : boolean := ${LOG_ENABLE_FINAL} ;
--!!
--!!  -- Controls for default Alert enables
--!!  constant ALERT_ENABLE_FAILURE       : boolean := ${ALERT_ENABLE_FAILURE} ; -- TRUE and not setable
--!!  constant ALERT_ENABLE_ERROR         : boolean := ${ALERT_ENABLE_ERROR} ; -- TRUE and not setable
--!!  constant ALERT_ENABLE_WARNING       : boolean := ${ALERT_ENABLE_WARNING} ; -- TRUE and not setable
--!!
--!!  There does not seem to be any compelling reason for these
--!!  Instead, I suspect code will be optimized better if these are merged into a single ALERT_LOG value
--!!  -- Controls that split the Alert/Log controls separately
--!!  constant  ALERT_WRITE_ERRORCOUNT      : boolean := ${ALERT_WRITE_ERRORCOUNT} ;  -- Prefix message with # of errors
--!!  constant  ALERT_WRITE_LEVEL           : boolean := ${ALERT_WRITE_LEVEL} ;   -- Print FAILURE, ERROR, WARNING
--!!  constant  ALERT_WRITE_NAME            : boolean := ${ALERT_WRITE_NAME} ;   -- Print Alert Message
--!!  constant  LOG_WRITE_ERRORCOUNT        : boolean := ${LOG_WRITE_ERRORCOUNT} ;  -- Prefix message with # of errors
--!!  constant  LOG_WRITE_LEVEL             : boolean := ${LOG_WRITE_LEVEL} ;   -- Print ALWAYS, INFO, DEBUG, FINAL, PASSED
--!!  constant  LOG_WRITE_NAME              : boolean := ${LOG_WRITE_NAME} ;   -- Print Log Message


end package body OsvvmSettingsPkg ;
