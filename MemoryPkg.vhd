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
--    08/2022   2022.08    INitial
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

use work.MemorySupportPkg.all ; 

package MemoryPkg is new work.MemoryGenericPkg
  generic map (
    MemoryBaseType      => MemoryBaseType_X,
    ToMemoryBaseType    => ToMemoryBaseType,
    FromMemoryBaseType  => FromMemoryBaseType,
    InitMemoryBaseType  => InitMemoryBaseType
  ) ;  
  
use work.MemorySupportPkg.all ; 

package MemoryPkg_X is new work.MemoryGenericPkg
  generic map (
    MemoryBaseType      => MemoryBaseType_X,
    ToMemoryBaseType    => ToMemoryBaseType,
    FromMemoryBaseType  => FromMemoryBaseType,
    InitMemoryBaseType  => InitMemoryBaseType
  ) ;  
  
use work.MemorySupportPkg.all ; 

package MemoryPkg_NoX is new work.MemoryGenericPkg
  generic map (
    MemoryBaseType      => MemoryBaseType_NoX,
    ToMemoryBaseType    => ToMemoryBaseType,
    FromMemoryBaseType  => FromMemoryBaseType,
    InitMemoryBaseType  => InitMemoryBaseType
  ) ;  
  
use work.MemorySupportPkg.all ; 

package MemoryPkg_orig is new work.MemoryGenericPkg
  generic map (
    MemoryBaseType      => MemoryBaseType_Original,
    ToMemoryBaseType    => ToMemoryBaseType,
    FromMemoryBaseType  => FromMemoryBaseType,
    InitMemoryBaseType  => InitMemoryBaseType
  ) ;  

