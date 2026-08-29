--
--  File Name:         SetGetBoundedGenericPkg.vhd
--  Design Unit Name:  NameStorePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--  Description:
--      In a protected type, defines a generic set-get capability
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.08    Initial revision.  Derived from NamePkg.vhd
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2026 by SynthWorks Design Inc.
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

package SetGetBoundedPkg_boolean is new work.SetGetBoundedGenericPkg
  generic map (
    SetGetType        => boolean,
    InitValue         => FALSE
  ) ;

  package SetGetBoundedPkg_integer is new work.SetGetBoundedGenericPkg
  generic map (
    SetGetType        => integer,
    InitValue         => 0
  ) ;

