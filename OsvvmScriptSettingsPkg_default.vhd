--
--  File Name:         OsvvmScriptSettingsPkg_default.vhd
--  Design Unit Name:  OsvvmScriptSettingsPkg body
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

package body OsvvmScriptSettingsPkg is
  constant OSVVM_HOME_DIRECTORY        : string := "../OsvvmLibraries" ;
  constant OSVVM_OUTPUT_DIRECTORY      : string := "" ;
  constant OSVVM_BUILD_YAML_FILE       : string := "OsvvmRun.yml" ;
  constant OSVVM_TRANSCRIPT_YAML_FILE  : string := "OSVVM_transcript.yml" ;
end package body OsvvmScriptSettingsPkg ;
