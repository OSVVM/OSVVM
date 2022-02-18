#  File Name:         osvvm.pro
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
#    10/2021   2021.10    Added ReportPkg
#     6/2021   2021.06    Updated for release
#     1/2020   2020.01    Updated Licenses to Apache
#    11/2016   2016.11    Compile Script for OSVVM
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2016 - 2021 by SynthWorks Design Inc.  
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
analyze TextUtilPkg.vhd
analyze ResolutionPkg.vhd
analyze NamePkg.vhd
analyze OsvvmGlobalPkg.vhd

# Compile VendorCovApiPkg_Aldec.vhd for RivieraPro and ActiveHDL, otherwise compile VendorCovApiPkg.vhd
if {$::osvvm::ToolVendor eq "Aldec"}  {
  analyze VendorCovApiPkg_Aldec.vhd
} else {
  analyze VendorCovApiPkg.vhd
}

analyze TranscriptPkg.vhd
analyze AlertLogPkg.vhd

analyze NameStorePkg.vhd

analyze MessageListPkg.vhd
# PT based MessagePkg replaced by List based MessageListPkg
# analyze MessagePkg.vhd      
analyze SortListPkg_int.vhd
analyze RandomBasePkg.vhd
analyze RandomPkg.vhd
# RandomProcedurePkg is a temporary and is used by CoveragePkg
# Likely will be replaced when VHDL-2019 support is good.
analyze RandomProcedurePkg.vhd
analyze CoveragePkg.vhd
# analyze CoveragePkg_new.vhd


if {$::osvvm::ToolVendor ne "Cadence"}  {
  analyze ScoreboardGenericPkg.vhd
  analyze ScoreboardPkg_slv.vhd
  analyze ScoreboardPkg_int.vhd
} else {
  analyze ScoreboardPkg_slv_c.vhd
  analyze ScoreboardPkg_int_c.vhd
}
analyze ResizePkg.vhd
analyze MemoryPkg.vhd

analyze TbUtilPkg.vhd

analyze ReportPkg.vhd
analyze OsvvmTypesPkg.vhd

analyze OsvvmContext.vhd 