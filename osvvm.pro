#  File Name:         osvvm.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to compile the OSVVM library for ModelSim, QuestaSim, and RivieraPro 
#        make sure to change OSVVM_DIR
#        If using Aldec, use VendorCovApiPkg_Aldec.vhd and not VendorCovApiPkg.vhd
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#    11/2016   2016.11    Compile Script for OSVVM
#     1/2020   2020.01    Updated Licenses to Apache
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2016 - 2020 by SynthWorks Design Inc.  
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
library osvvm
analyze NamePkg.vhd
analyze OsvvmGlobalPkg.vhd

# Compile VendorCovApiPkg_Aldec.vhd for RivieraPro and ActiveHDL, otherwise compile VendorCovApiPkg.vhd
if {[info exists aldec]} {
  analyze VendorCovApiPkg_Aldec.vhd
} else {
  analyze VendorCovApiPkg.vhd
}

analyze TranscriptPkg.vhd
analyze TextUtilPkg.vhd
analyze AlertLogPkg.vhd

analyze MessagePkg.vhd
analyze SortListPkg_int.vhd
analyze RandomBasePkg.vhd
analyze RandomPkg.vhd
analyze CoveragePkg.vhd
analyze MemoryPkg.vhd

analyze ScoreboardGenericPkg.vhd
analyze ScoreboardPkg_slv.vhd
analyze ScoreboardPkg_int.vhd

analyze ResolutionPkg.vhd
analyze TbUtilPkg.vhd

analyze OsvvmContext.vhd 