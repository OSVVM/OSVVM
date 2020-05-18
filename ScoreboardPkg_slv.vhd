--
--  File Name:         ScoreBoardPkg_slv.vhd
--  Design Unit Name:  ScoreBoardPkg_slv
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          email:  jim@synthworks.com
--
--
--  Description:
--    Instance of Generic Package ScoreboardGenericPkg for std_logic_vector
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    08/2012   2012.08    Generic Instance of ScoreboardGenericPkg
--    08/2014   2013.08    Updated interface for Match and to_string
--    11/2016   2016.11    Released as part of OSVVM library
--    01/2020   2020.01    Updated Licenses to Apache
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2006 - 2020 by SynthWorks Design Inc.  
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


use std.textio.all ;

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;


package ScoreBoardPkg_slv is new work.ScoreboardGenericPkg
  generic map (
    ExpectedType        => std_logic_vector,  
    ActualType          => std_logic_vector,  
    Match               => std_match,  -- "=", [std_logic_vector, std_logic_vector return boolean]
    expected_to_string  => to_hstring, --      [std_logic_vector return string] 
    actual_to_string    => to_hstring  --      [std_logic_vector return string]  
  ) ;  
