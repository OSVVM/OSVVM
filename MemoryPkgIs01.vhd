--
--  File Name:         MemoryPkgIs01.vhd
--  Design Unit Name:  MemoryPkgIs01
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
--    08/2026   2026.08    Instance for MemoryPkg using policy 01
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
-- MemoryPkg, extablishes storage policy X as the default
--   Keeps the fidelity of U and X in the memory
--   Bit size unlimited
--   Each 16 bits of data stored in a 32 bit integer
--
use work.MemorySupportPkg.all ;
package MemoryPkg is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_01,
    SizeMemoryBaseType  => SizeMemoryBaseType_01,
    ToMemoryBaseType    => ToMemoryBaseType_01,
    FromMemoryBaseType  => FromMemoryBaseType_01,
    InitMemoryBaseType  => InitMemoryBaseType_01
  ) ;

