--
--  File Name:         OsvvmDefaultSettingsPkg.vhd
--  Design Unit Name:  OsvvmDefaultSettingsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description:
--     OSVVM Default Settings
--     OSVVM tries to maintain strict backward compatibility
--     This package controls items that break backward compatibility.
--     The constants in this package are deferred constants and are set in the package body
--     
--     The intent is to provide:
--         - a package body that activates new features.
--         - a package body that maintains backward compatibility.
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

package OsvvmDefaultSettingsPkg is
  -- ------------------------------------------
  -- Settings for CoveragePkg
  -- ------------------------------------------
  -- InitSeed:  When TRUE uses updated seed methods.  TRUE for coverage singleton.  
  constant COVERAGE_USE_NEW_SEED_METHODS : boolean ; 
--  constant COVERAGE_DEFAULT_WEIGHT_MODE  : WeightModeType := AT_LEAST ;

--!!  -- WriteBin Settings - not relevant important if you use the HTML reports
--!!  constant OSVVM_DEFAULT_WRITE_PASS_FAIL   : OsvvmOptionsType := FALSE ;
--!!  constant OSVVM_DEFAULT_WRITE_BIN_INFO    : OsvvmOptionsType := TRUE ;
--!!  constant OSVVM_DEFAULT_WRITE_COUNT       : OsvvmOptionsType := TRUE ;
--!!  constant OSVVM_DEFAULT_WRITE_ANY_ILLEGAL : OsvvmOptionsType := FALSE ;

  
  -- ------------------------------------------
  -- Settings for RandomPkg
  -- ------------------------------------------
  -- RandomPkg.InitSeed:  For new designs make this TRUE
  constant RANDOM_USE_NEW_SEED_METHODS : boolean ; 
  
  
  -- ------------------------------------------
  -- Settings for ScoreboardGenericPkg
  -- ------------------------------------------
  -- WriteScoreboardYaml
  constant SCOREBOARD_YAML_IS_BASE_FILE_NAME : boolean ;  

  -- ------------------------------------------
  -- Settings for AlertLogPkg
  -- ------------------------------------------
  -- Control printing of Alert/Log
  constant  ALERT_LOG_JUSTIFY_ENABLE       : boolean ; -- Historic FALSE
  constant  ALERT_LOG_WRITE_TIME_FIRST     : boolean ; -- Historic FALSE
  constant  ALERT_LOG_TIME_JUSTIFY_AMOUNT  : integer ; -- Historic 0
  
--!!  -- Boolean controls to print or not print fields in Alert/Log
--!!  constant  WRITE_ERRORCOUNT           : boolean := FALSE ;  -- prefix message with # of errors - requested by Marco for Mike P.
--!!  constant  WRITE_LEVEL                : boolean := TRUE ;   -- Print FAILURE, ERROR, WARNING
--!!  constant  WRITE_NAME                 : boolean := TRUE ;   -- Print Alert
--!!  constant  WRITE_TIME                 : boolean := TRUE ;   -- Print time 
--!!  
--!!  -- Defaults for names printed in ReportAlerts, Alert, Log
--!!  constant  OSVVM_PRINT_PREFIX         : string := "%% " ;
--!!  constant  ALERT_PRINT_PREFIX         : string := "Alert" ;
--!!  constant  LOG_PRINT_PREFIX           : string := "Log  " ;
--!!  constant  DONE_NAME                  : string := "DONE" ;
--!!  constant  PASS_NAME                  : string := "PASSED" ;
--!!  constant  FAIL_NAME                  : string := "FAILED" ;
--!!  constant  ALERT_LOG_ID_SEPARATOR     : string := ": " ; 
--!!
--!!  -- Defaults for Stop Counts
--!!  constant  STOP_COUNT_FAILURE         : integer ;  -- OSVVM 0
--!!  constant  STOP_COUNT_ERROR           : integer ;  -- OSVVM 2**31-1, VUnit 1
--!!  constant  STOP_COUNT_WARNING         : integer ;  -- OSVVM 2**31-1
--!!
--!!  -- requirements
--!!  constant  DEFAULT_PASSED_GOAL        : integer ; -- 1
--!!  
--!!  -- Defaults for Log Enables
--!!  constant LOG_ENABLE_INFO             : boolean ; -- FALSE 
--!!  constant LOG_ENABLE_DEBUG            : boolean ; -- FALSE 
--!!  constant LOG_ENABLE_PASSED           : boolean ; -- FALSE 
--!!  constant LOG_ENABLE_FINAL            : boolean ; -- FALSE 
--!!
--!!  -- Allows disabling alerts at startup - and then turn them on at or near system reset
--!!  constant  GLOBAL_ALERT_ENABLE        : boolean ; -- default TRUE
--!!  
--!!  -- Control what makes a test failure
--!!  constant  FAIL_ON_WARNING            : boolean ; -- default TRUE
--!!  constant  FAIL_ON_DISABLED_ERRORS    : boolean ; -- default TRUE
--!!  constant  FAIL_ON_REQUIREMENT_ERRORS : boolean ; -- default TRUE
--!!  
--!!  -- ReportAlerts Settings 
--!!  constant REPORT_HIERARCHY            : boolean := TRUE ;   -- ReportAerts 
--!!  constant PRINT_PASSED                : boolean := TRUE ;   -- ReportAlerts: Print PassedCount 
--!!  constant PRINT_AFFIRMATIONS          : boolean := FALSE ;  -- ReportAlerts: Print Affirmations Checked
--!!  constant PRINT_DISABLED_ALERTS       : boolean := FALSE ;  -- ReportAlerts: Print Disabled Alerts
--!!  constant PRINT_REQUIREMENTS          : boolean := FALSE ;  -- ReportAlerts: Print requirements
--!!  constant PRINT_IF_HAVE_REQUIREMENTS  : boolean := TRUE ;   -- ReportAlerts: Print requirements if have any
--!!  
--!!  -- Controls for default Alert enables
--!!  constant ALERT_ENABLE_FAILURE       : boolean ; -- TRUE and not setable 
--!!  constant ALERT_ENABLE_ERROR         : boolean ; -- TRUE and not setable 
--!!  constant ALERT_ENABLE_WARNING       : boolean ; -- TRUE and not setable 
--!!  
--!!  -- Controls that split the Alert/Log controls separately
--!!  constant  WRITEALERT_ERRORCOUNT      : boolean := WRITE_ERRORCOUNT ;  -- Prefix message with # of errors
--!!  constant  WRITEALERT_LEVEL           : boolean := WRITE_LEVEL     ;   -- Print FAILURE, ERROR, WARNING
--!!  constant  WRITEALERT_NAME            : boolean := WRITE_NAME      ;   -- Print Alert Message
--!!  constant  WRITEALERT_TIME            : boolean := WRITE_TIME      ;   -- Print time 
--!!  constant  WRITELOG_ERRORCOUNT        : boolean := WRITE_ERRORCOUNT ;  -- Prefix message with # of errors
--!!  constant  WRITELOG_LEVEL             : boolean := WRITE_LEVEL     ;   -- Print ALWAYS, INFO, DEBUG, FINAL, PASSED
--!!  constant  WRITELOG_NAME              : boolean := WRITE_NAME      ;   -- Print Log Message
--!!  constant  WRITELOG_TIME              : boolean := WRITE_TIME      ;   -- Print Time


end package OsvvmDefaultSettingsPkg ;

-- For the package body with the deferred constant values, see
-- OsvvmDefaultSettingsPkg_local.vhd and OsvvmDefaultSettingsPkg_default.vhd 

package body OsvvmDefaultSettingsPkg is
  -- ------------------------------------------
  -- Settings for CoveragePkg
  -- ------------------------------------------
  -- InitSeed:  When TRUE uses updated seed methods.  TRUE for coverage singleton.  
  constant COVERAGE_USE_NEW_SEED_METHODS : boolean := TRUE ; 
--  constant COVERAGE_DEFAULT_WEIGHT_MODE  : WeightModeType := AT_LEAST ;

--!!  -- WriteBin Settings - not relevant important if you use the HTML reports
--!!  constant OSVVM_DEFAULT_WRITE_PASS_FAIL   : OsvvmOptionsType := FALSE ;
--!!  constant OSVVM_DEFAULT_WRITE_BIN_INFO    : OsvvmOptionsType := TRUE ;
--!!  constant OSVVM_DEFAULT_WRITE_COUNT       : OsvvmOptionsType := TRUE ;
--!!  constant OSVVM_DEFAULT_WRITE_ANY_ILLEGAL : OsvvmOptionsType := FALSE ;

  
  -- ------------------------------------------
  -- Settings for RandomPkg
  -- ------------------------------------------
  -- RandomPkg.InitSeed:  For new designs make this TRUE
  constant RANDOM_USE_NEW_SEED_METHODS : boolean := FALSE ; 
  
  
  -- ------------------------------------------
  -- Settings for ScoreboardGenericPkg
  -- ------------------------------------------
  -- WriteScoreboardYaml
  constant SCOREBOARD_YAML_IS_BASE_FILE_NAME : boolean := FALSE ;  

  -- ------------------------------------------
  -- Settings for AlertLogPkg
  -- ------------------------------------------
  -- Control printing of Alert/Log
  constant  ALERT_LOG_JUSTIFY_ENABLE       : boolean := FALSE ; -- Historic FALSE
  constant  ALERT_LOG_WRITE_TIME_FIRST     : boolean := FALSE ; -- Historic FALSE
  constant  ALERT_LOG_TIME_JUSTIFY_AMOUNT  : integer := 0 ;     -- Historic 0
  
--!!  -- Boolean controls to print or not print fields in Alert/Log
--!!  constant  WRITE_ERRORCOUNT           : boolean := FALSE ;  -- prefix message with # of errors - requested by Marco for Mike P.
--!!  constant  WRITE_LEVEL                : boolean := TRUE ;   -- Print FAILURE, ERROR, WARNING
--!!  constant  WRITE_NAME                 : boolean := TRUE ;   -- Print Alert
--!!  constant  WRITE_TIME                 : boolean := TRUE ;   -- Print time 
--!!  
--!!  -- Defaults for names printed in ReportAlerts, Alert, Log
--!!  constant  OSVVM_PRINT_PREFIX         : string := "%% " ;
--!!  constant  ALERT_PRINT_PREFIX         : string := "Alert" ;
--!!  constant  LOG_PRINT_PREFIX           : string := "Log  " ;
--!!  constant  DONE_NAME                  : string := "DONE" ;
--!!  constant  PASS_NAME                  : string := "PASSED" ;
--!!  constant  FAIL_NAME                  : string := "FAILED" ;
--!!  constant  ALERT_LOG_ID_SEPARATOR     : string := ": " ; 
--!!
--!!  -- Defaults for Stop Counts
--!!  constant  STOP_COUNT_FAILURE         : integer ;  -- OSVVM 0
--!!  constant  STOP_COUNT_ERROR           : integer ;  -- OSVVM 2**31-1, VUnit 1
--!!  constant  STOP_COUNT_WARNING         : integer ;  -- OSVVM 2**31-1
--!!
--!!  -- requirements
--!!  constant  DEFAULT_PASSED_GOAL        : integer ; -- 1
--!!  
--!!  -- Defaults for Log Enables
--!!  constant LOG_ENABLE_INFO             : boolean ; -- FALSE 
--!!  constant LOG_ENABLE_DEBUG            : boolean ; -- FALSE 
--!!  constant LOG_ENABLE_PASSED           : boolean ; -- FALSE 
--!!  constant LOG_ENABLE_FINAL            : boolean ; -- FALSE 
--!!
--!!  -- Allows disabling alerts at startup - and then turn them on at or near system reset
--!!  constant  GLOBAL_ALERT_ENABLE        : boolean ; -- default TRUE
--!!  
--!!  -- Control what makes a test failure
--!!  constant  FAIL_ON_WARNING            : boolean ; -- default TRUE
--!!  constant  FAIL_ON_DISABLED_ERRORS    : boolean ; -- default TRUE
--!!  constant  FAIL_ON_REQUIREMENT_ERRORS : boolean ; -- default TRUE
--!!  
--!!  -- ReportAlerts Settings 
--!!  constant REPORT_HIERARCHY            : boolean := TRUE ;   -- ReportAerts 
--!!  constant PRINT_PASSED                : boolean := TRUE ;   -- ReportAlerts: Print PassedCount 
--!!  constant PRINT_AFFIRMATIONS          : boolean := FALSE ;  -- ReportAlerts: Print Affirmations Checked
--!!  constant PRINT_DISABLED_ALERTS       : boolean := FALSE ;  -- ReportAlerts: Print Disabled Alerts
--!!  constant PRINT_REQUIREMENTS          : boolean := FALSE ;  -- ReportAlerts: Print requirements
--!!  constant PRINT_IF_HAVE_REQUIREMENTS  : boolean := TRUE ;   -- ReportAlerts: Print requirements if have any
--!!  
--!!  -- Controls for default Alert enables
--!!  constant ALERT_ENABLE_FAILURE       : boolean ; -- TRUE and not setable 
--!!  constant ALERT_ENABLE_ERROR         : boolean ; -- TRUE and not setable 
--!!  constant ALERT_ENABLE_WARNING       : boolean ; -- TRUE and not setable 
--!!  
--!!  -- Controls that split the Alert/Log controls separately
--!!  constant  WRITEALERT_ERRORCOUNT      : boolean := WRITE_ERRORCOUNT ;  -- Prefix message with # of errors
--!!  constant  WRITEALERT_LEVEL           : boolean := WRITE_LEVEL     ;   -- Print FAILURE, ERROR, WARNING
--!!  constant  WRITEALERT_NAME            : boolean := WRITE_NAME      ;   -- Print Alert Message
--!!  constant  WRITEALERT_TIME            : boolean := WRITE_TIME      ;   -- Print time 
--!!  constant  WRITELOG_ERRORCOUNT        : boolean := WRITE_ERRORCOUNT ;  -- Prefix message with # of errors
--!!  constant  WRITELOG_LEVEL             : boolean := WRITE_LEVEL     ;   -- Print ALWAYS, INFO, DEBUG, FINAL, PASSED
--!!  constant  WRITELOG_NAME              : boolean := WRITE_NAME      ;   -- Print Log Message
--!!  constant  WRITELOG_TIME              : boolean := WRITE_TIME      ;   -- Print Time


end package body OsvvmDefaultSettingsPkg ;