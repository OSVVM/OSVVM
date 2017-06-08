#  File Name:         osvvm.do
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
#    Date       Version    Description
#    11/2016    2016.11    Compile Script for OSVVM
#
#  Copyright (c) 2016 by SynthWorks Design Inc.  All rights reserved.
#
#  Verbatim copies of this source file may be used and
#  distributed without restriction.
#
#  This source file is free software; you can redistribute it
#  and/or modify it under the terms of the ARTISTIC License
#  as published by The Perl Foundation; either version 2.0 of
#  the License, or (at your option) any later version.
#
#  This source is distributed in the hope that it will be
#  useful, but WITHOUT ANY WARRANTY; without even the implied
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#  PURPOSE. See the Artistic License for details.
#
#  You should have received a copy of the license with this source.
#  If not download it from,
#     http://www.perlfoundation.org/artistic_license_2_0
#
#
# Update OSVVM_DIR to match your environment:
set OSVVM_LIB_NAME osvvm
set OSVVM_DIR [pwd]
if {$argc > 0} {
  set OSVVM_DIR $1
}

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/NamePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/OsvvmGlobalPkg.vhd

# Compile VendorCovApiPkg_Aldec.vhd for RivieraPro and soon ActiveHDL, otherwise compile VendorCovApiPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/VendorCovApiPkg.vhd
# vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/VendorCovApiPkg_Aldec.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/TranscriptPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/TextUtilPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/AlertLogPkg.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/MessagePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/SortListPkg_int.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/RandomBasePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/RandomPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/CoveragePkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/MemoryPkg.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ScoreboardGenericPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ScoreboardPkg_slv.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ScoreboardPkg_int.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/ResolutionPkg.vhd
vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/TbUtilPkg.vhd

vcom -2008 -work ${OSVVM_LIB_NAME}  ${OSVVM_DIR}/OsvvmContext.vhd 

