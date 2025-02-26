--
--  File Name:         OsvvmSettingsPkg.vhd
--  Design Unit Name:  OsvvmSettingsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description:
--     OSVVM Default Settings
--     This package establishes a set of constants that can be
--     set in the package body 
--
--     The package body, OsvvmSettingsPkg_default.vhd contains the current
--     defaults supplied by OSVVM.   
--     To change these, create a package body with the revised settings
--     in the file OsvvmSettingsPkg_local.vhd
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
--    02/2025   2025.02    Added COVERAGE_REQUIREMENT_BY_BIN
--    09/2024   2024.09    Added ALERT_LOG_IGNORE_SPACES and ALERT_LOG_IGNORE_EMPTY_LINES
--    07/2024   2024.07    Added ALERT_LOG_NOCHECKS_NAME and ALERT_LOG_TIMEOUT_NAME
--    03/2024   2024.03    Major updates
--    09/2023   2023.09    Initial
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2023 by SynthWorks Design Inc.
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

package OsvvmSettingsPkg is
  -- ------------------------------------------
  -- Settings for RandomPkg
  -- ------------------------------------------
  -- RandomPkg.InitSeed:  For new designs make this TRUE
  constant RANDOM_USE_NEW_SEED_METHODS : boolean ;  -- Historic FALSE

  
  -- ------------------------------------------
  -- Settings for ScoreboardGenericPkg
  -- ------------------------------------------
  -- WriteScoreboardYaml
  constant SCOREBOARD_YAML_IS_BASE_FILE_NAME : boolean ;  -- Historic FALSE


  -- ------------------------------------------
  -- Settings shared by AlertLogPkg and CoveragePkg
  -- ------------------------------------------
--!!  -- Defaults for names printed in ReportAlerts, Alert, Log
  constant  OSVVM_PRINT_PREFIX         : string ;
  constant  OSVVM_DONE_NAME            : string ;
  constant  OSVVM_PASS_NAME            : string ;
  constant  OSVVM_FAIL_NAME            : string ;

  constant  OSVVM_DEFAULT_TIME_UNITS   : time ;

  -- ------------------------------------------
  -- Settings for CoveragePkg
  -- ------------------------------------------
  constant  COVERAGE_REQUIREMENT_BY_BIN  : boolean ;  
  constant  COVERAGE_DEFAULT_WEIGHT_MODE  : string ;
  -- InitSeed:  When TRUE uses updated seed methods.  TRUE for coverage singleton.  
  constant  COVERAGE_USE_NEW_SEED_METHODS : boolean ; 
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
  constant  ALERT_LOG_JUSTIFY_ENABLE       : boolean ; -- Historic FALSE
  constant  ALERT_LOG_WRITE_TIME_FIRST     : boolean ; -- Historic FALSE
  constant  ALERT_LOG_WRITE_TIME_LAST      : boolean ; 
  constant  ALERT_LOG_TIME_JUSTIFY_AMOUNT  : integer ;     -- Historic 0
  
  -- File Match/Diff controls
  constant  ALERT_LOG_IGNORE_SPACES           : boolean ; 
  constant  ALERT_LOG_IGNORE_EMPTY_LINES     : boolean ; 
  
  -- Boolean controls to print or not print fields in Alert/Log
  constant  ALERT_LOG_WRITE_ERRORCOUNT     : boolean ;  -- prefix message with # of errors - requested by Marco for Mike P.
  constant  ALERT_LOG_WRITE_NAME           : boolean ;   -- Print Alert
  constant  ALERT_LOG_WRITE_LEVEL          : boolean ;   -- Print Level - FAILURE, ERROR, WARNING, INFO, ...
  constant  ALERT_LOG_WRITE_TIME           : boolean ;   -- Print time


  constant  ALERT_LOG_ALERT_NAME       : string ;
  constant  ALERT_LOG_LOG_NAME         : string ;
  constant  ALERT_LOG_ID_SEPARATOR     : string ; 
  constant  ALERT_LOG_PRINT_PREFIX     : string ; 
  constant  ALERT_LOG_DONE_NAME        : string ;
  constant  ALERT_LOG_PASS_NAME        : string ;
  constant  ALERT_LOG_FAIL_NAME        : string ;
  
  constant ALERT_LOG_NOCHECKS_NAME     : string ;
  constant ALERT_LOG_TIMEOUT_NAME      : string ;
  
  -- Defaults for Stop Counts
  constant  ALERT_LOG_STOP_COUNT_FAILURE         : integer ;  -- OSVVM 0
  constant  ALERT_LOG_STOP_COUNT_ERROR           : integer ;  -- OSVVM 2**31-1, VUnit 1
  constant  ALERT_LOG_STOP_COUNT_WARNING         : integer ;  -- OSVVM 2**31-1

  -- Allows disabling alerts at startup - and then turn them on at or near system reset
  constant  ALERT_LOG_GLOBAL_ALERT_ENABLE        : boolean ;

  -- requirements
  constant  ALERT_LOG_DEFAULT_PASSED_GOAL        : integer ;

  -- Control what makes a test failure
  constant  ALERT_LOG_FAIL_ON_WARNING            : boolean ;
  constant  ALERT_LOG_FAIL_ON_DISABLED_ERRORS    : boolean ;
  constant  ALERT_LOG_FAIL_ON_REQUIREMENT_ERRORS : boolean ;

  -- ReportAlerts Settings
  constant ALERT_LOG_REPORT_HIERARCHY            : boolean ;  -- ReportAerts 
  constant ALERT_LOG_PRINT_PASSED                : boolean ;  -- ReportAlerts: Print PassedCount 
  constant ALERT_LOG_PRINT_AFFIRMATIONS          : boolean ;  -- ReportAlerts: Print Affirmations Checked
  constant ALERT_LOG_PRINT_DISABLED_ALERTS       : boolean ;  -- ReportAlerts: Print Disabled Alerts
  constant ALERT_LOG_PRINT_REQUIREMENTS          : boolean ;  -- ReportAlerts: Print requirements
  constant ALERT_LOG_PRINT_IF_HAVE_REQUIREMENTS  : boolean ;  -- ReportAlerts: Print requirements if have any
  
  
--!!  -- Defaults for Log Enables
--!!  constant LOG_ENABLE_INFO             : boolean ;  
--!!  constant LOG_ENABLE_DEBUG            : boolean ;  
--!!  constant LOG_ENABLE_PASSED           : boolean ;  
--!!  constant LOG_ENABLE_FINAL            : boolean ;  
--!!
--!!  -- Controls for default Alert enables
--!!  constant ALERT_ENABLE_FAILURE       : boolean ; -- TRUE and not setable 
--!!  constant ALERT_ENABLE_ERROR         : boolean ; -- TRUE and not setable 
--!!  constant ALERT_ENABLE_WARNING       : boolean ; -- TRUE and not setable 
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


end package OsvvmSettingsPkg ;

-- For the package body with the deferred constant values, see
-- OsvvmSettingsPkg_local.vhd and OsvvmSettingsPkg_default.vhd 

