--
--  File Name:         OsvvmScriptSettingsPkg.vhd
--  Design Unit Name:  OsvvmScriptSettingsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description:
--     OSVVM Script Settings defaults
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
--    01/2023   2023.01    Initial
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

package OsvvmScriptSettingsPkg is
  constant OSVVM_HOME_DIRECTORY         : string ;  -- Absolute or relative path to OSVVM install
  constant OSVVM_RAW_OUTPUT_DIRECTORY   : string ;  -- Directory for Raw Output - temporary log and yaml files. often just ""
  constant OSVVM_BASE_OUTPUT_DIRECTORY  : string ;  -- Directory for Output Directories.  Use this to locate the reports and results directory. Often just ""
  constant OSVVM_BUILD_YAML_FILE        : string ;  -- "OsvvmRun.yml" unless you have edited OSVVM scripts
  constant OSVVM_TRANSCRIPT_YAML_FILE   : string ;  -- "OSVVM_transcript.yml" unless you have edited OSVVM scripts
  constant OSVVM_REVISION               : string ;  -- Current Revision / Release
  constant OSVVM_SETTINGS_REVISION      : string ;  -- Purpose: use new release, but keep settings to match an older release - See OsvvmSettingsPkg_default
end package OsvvmScriptSettingsPkg ;

-- For the package body with the deferred constant values, see
-- OsvvmScriptSettingsPkg_generated.vhd and OsvvmScriptSettingsPkg_default.vhd 