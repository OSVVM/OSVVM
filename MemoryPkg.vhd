--
--  File Name:         MemoryPkg_orig.vhd
--  Design Unit Name:  MemoryPkg_orig
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          email:  jim@synthworks.com
--
--
--  Description:
--    Instance of Generic Package ScoreboardGenericPkg for integer
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2022   2022.10    Minor edit to commented out code
--    08/2022   2022.08    Initial.  
--    -- ----              See MemoryGenericPkg for older MemoryPkg lineage
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2022 by SynthWorks Design Inc.  
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
--    MemoryBaseType      => MemoryBaseType_X,
    SizeMemoryBaseType  => SizeMemoryBaseType_X,
    ToMemoryBaseType    => ToMemoryBaseType_X,
    FromMemoryBaseType  => FromMemoryBaseType_X,
    InitMemoryBaseType  => InitMemoryBaseType_X
  ) ;  


-- -----------------------------------------------
-- MemoryPkg_X implements storage policy X
--   Keeps the fidelity of U and X in the memory
--   Bit size unlimited
--   Each 16 bits of data stored in a 32 bit integer
-- 
use work.MemorySupportPkg.all ; 
package MemoryPkg_X is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_X,
    SizeMemoryBaseType  => SizeMemoryBaseType_X,
    ToMemoryBaseType    => ToMemoryBaseType_X,
    FromMemoryBaseType  => FromMemoryBaseType_X,
    InitMemoryBaseType  => InitMemoryBaseType_X
  ) ;  


-- -----------------------------------------------
-- MemoryPkg_NoX implements storage policy NoX
--   any Bit with an X becomes 0
--   Bit size unlimited
--   Each 32 bits of data stored in a 32 bit integer
--   For larger word widths, uses half storage as X
-- 
use work.MemorySupportPkg.all ; 
package MemoryPkg_NoX is new work.MemoryGenericPkg
  generic map (
--    MemoryBaseType      => MemoryBaseType_NoX,
    SizeMemoryBaseType  => SizeMemoryBaseType_NoX,
    ToMemoryBaseType    => ToMemoryBaseType_NoX,
    FromMemoryBaseType  => FromMemoryBaseType_NoX,
    InitMemoryBaseType  => InitMemoryBaseType_NoX
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

