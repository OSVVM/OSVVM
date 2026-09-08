--
--  File Name:         MemoryPkg.vhd
--  Design Unit Name:  MemoryPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          email:  jim@synthworks.com
--
--
--  Description:
--    Instances of MemoryGenericPkg
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    08/2026   2026.08    Adding MemoryPkg_UX01 and MemoryPkg_01.
--                         Moved MemoryPkg to a separate file
--                         Marked MemoryPkg_X (replaced by MemoryPkg_UX01), MemoryPkg_NoX (replaced by MemoryPkg_01) as deprecated.
--    10/2022   2022.10    Minor edit to commented out code
--    08/2022   2022.08    Initial.
--    -- ----              See MemoryGenericPkg for older MemoryPkg lineage
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2022 to 2026 by SynthWorks Design Inc.
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


-- -----------------------------------------------
-- MemoryPkg_UX01 uses Memory Storage Policy UX01
--   Memory supports values UX01 and maintains fidelity of X and U
--   Each integer value stores HALF_WORD_WIDTH bits of data and HALF_WORD_WIDTH bits of X and U
--   Bit size unlimited
--
use work.MemorySupportPkg.all ;
package MemoryPkg_UX01 is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_UX01,
    SizeMemoryBaseType  => SizeMemoryBaseType_UX01,
    ToMemoryBaseType    => ToMemoryBaseType_UX01,
    FromMemoryBaseType  => FromMemoryBaseType_UX01,
    InitMemoryBaseType  => InitMemoryBaseType_UX01
  ) ;


-- -----------------------------------------------
-- MemoryPkg_01 uses Memory Storage Policy 01
--   Memory only stores 0 and 1.  X and U are stored as a 0
--   Each integer value stores WORD_WIDTH bits of data
--   Bit size unlimited
--   For larger word widths, uses half storage as UX01
--
use work.MemorySupportPkg.all ;
package MemoryPkg_01 is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_01,
    SizeMemoryBaseType  => SizeMemoryBaseType_01,
    ToMemoryBaseType    => ToMemoryBaseType_01,
    FromMemoryBaseType  => FromMemoryBaseType_01,
    InitMemoryBaseType  => InitMemoryBaseType_01
  ) ;


-- -----------------------------------------------
-- MemoryPkg, default instance
--   MemoryPkg default instance uses UX01 storage policy
--   To use 01 as the default, set Tcl variable
--   $::osvvm::UseMemoryPkg01 to true
--
use work.MemorySupportPkg.all ;
package MemoryPkg is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_UX01,
    SizeMemoryBaseType  => SizeMemoryBaseType_UX01,
    ToMemoryBaseType    => ToMemoryBaseType_UX01,
    FromMemoryBaseType  => FromMemoryBaseType_UX01,
    InitMemoryBaseType  => InitMemoryBaseType_UX01
  ) ;


-- -----------------------------------------------
-- MemoryPkg_orig implements storage policy orig
--   upto 31 bits of data
--   X in any bit and the word becomes X
--
use work.MemorySupportPkg.all ;
package MemoryPkg_orig is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_orig,
    SizeMemoryBaseType  => SizeMemoryBaseType_orig,
    ToMemoryBaseType    => ToMemoryBaseType_orig,
    FromMemoryBaseType  => FromMemoryBaseType_orig,
    InitMemoryBaseType  => InitMemoryBaseType_orig
  ) ;

-- -----------------------------------------------
-- MemoryPkg_X is deprecated.  Use MemoryPkg_UX01 (same policy)
--
use work.MemorySupportPkg.all ;
package MemoryPkg_X is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_UX01,
    SizeMemoryBaseType  => SizeMemoryBaseType_UX01,
    ToMemoryBaseType    => ToMemoryBaseType_UX01,
    FromMemoryBaseType  => FromMemoryBaseType_UX01,
    InitMemoryBaseType  => InitMemoryBaseType_UX01
  ) ;


-- -----------------------------------------------
-- MemoryPkg_NoX is deprecated.  Use MemoryPkg_01 (same policy)
--
use work.MemorySupportPkg.all ;
package MemoryPkg_NoX is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_01,
    SizeMemoryBaseType  => SizeMemoryBaseType_01,
    ToMemoryBaseType    => ToMemoryBaseType_01,
    FromMemoryBaseType  => FromMemoryBaseType_01,
    InitMemoryBaseType  => InitMemoryBaseType_01
  ) ;


