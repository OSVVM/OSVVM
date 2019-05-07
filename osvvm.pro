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