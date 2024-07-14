--
--  File Name:         ScoreBoardPkg_unsigned.vhd
--  Design Unit Name:  ScoreBoardPkg_unsigned
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
--    07/2023   2024.07    Generic Instance of ScoreboardGenericPkg based on ScoreboardPkg_slv
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2024 by SynthWorks Design Inc.  
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

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;


package ScoreBoardPkg_unsigned is new work.ScoreboardGenericPkg
  generic map (
    ExpectedType        => unsigned,
    ActualType          => unsigned,
    Match               => work.AlertLogPkg.MetaMatch,  -- "=", [unsigned, unsigned return boolean]
    expected_to_string  => work.TextUtilPkg.to_hxstring,  --    [unsigned return string] 
    actual_to_string    => work.TextUtilPkg.to_hxstring   --    [unsigned return string]  
  ) ;  
