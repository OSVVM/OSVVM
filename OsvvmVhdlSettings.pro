#  File Name:         OsvvmVhdlSettings.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to compile the OSVVM library  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#     4/2025   2025.04    Initial, factored from osvvm.pro
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2016 - 2025 by SynthWorks Design Inc.  
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  


set SettingsDirectory [FindOsvvmSettingsDirectory]

if {[FileExists $SettingsDirectory/OsvvmScriptSettingsPkg_local.vhd]} {
  analyze $SettingsDirectory/OsvvmScriptSettingsPkg_local.vhd

# If SettingsDirectory is in a subdirectory for a tool and/or vendor it may be appropriate to look above to find a local "default one"
# elsif {[FileExists $SettingsDirectory/../OsvvmScriptSettingsPkg_local.vhd]} { analyze $SettingsDirectory/../OsvvmScriptSettingsPkg_local.vhd }  

} else {
  # Generate the file if possible
  set GeneratedPkg [CreateOsvvmScriptSettingsPkg $SettingsDirectory]
  puts "GeneratedPkg = $GeneratedPkg"
  if {[FileExists $GeneratedPkg]} {
    analyze   $GeneratedPkg
  } else {
    analyze OsvvmScriptSettingsPkg_default.vhd
  }
}

if {[FileExists $SettingsDirectory/OsvvmSettingsPkg_local.vhd]} {
  analyze $SettingsDirectory/OsvvmSettingsPkg_local.vhd

# If SettingsDirectory is in a subdirectory for a tool and/or vendor it may be appropriate to look above to find a local "default one"
# elsif {[FileExists $SettingsDirectory/../OsvvmSettingsPkg_local.vhd]} { analyze $SettingsDirectory/../OsvvmSettingsPkg_local.vhd }  

} else {
  analyze OsvvmSettingsPkg_default.vhd
}

