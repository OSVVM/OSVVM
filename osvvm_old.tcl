#  File Name:         osvvm.do
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        A simple "do" file to compile OSVVM
#        Updated for 2021.06, but not tested.
#        Please switch to the osvvm.pro scripts to build the design
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#    06/2021   2021.06    Updated for current release - but not tested
#    01/2020   2020.01    Updated Licenses to Apache
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
#
# Update OSVVM_DIR to match your environment:
set OSVVM_LIB_NAME osvvm
set OSVVM_DIR [pwd]
if {$argc > 0} {
  set OSVVM_DIR $1
}

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ResolutionPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/NamePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/NameStorePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/OsvvmGlobalPkg.vhd

# Compile VendorCovApiPkg_Aldec.vhd for RivieraPro and ActiveHDL, otherwise compile VendorCovApiPkg.vhd
if {[info exists aldec]} {
  vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/VendorCovApiPkg_Aldec.vhd
} else {
  vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/VendorCovApiPkg.vhd
}

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/TranscriptPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/TextUtilPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/AlertLogPkg.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/MessagePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/SortListPkg_int.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/RandomBasePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/RandomPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/RandomProcedurePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/CoveragePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/MemoryPkg.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ScoreboardGenericPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ScoreboardPkg_slv.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ScoreboardPkg_int.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ResizePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/TbUtilPkg.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/OsvvmContext.vhd 

