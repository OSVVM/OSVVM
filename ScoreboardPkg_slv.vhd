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
--  Latest standard version available at:
--        http://www.SynthWorks.com/downloads
--
--  Revision History:
--    Date      Version    Description
--    08/2012   2012.08    Generic Instance of ScoreboardGenericPkg
--    08/2014   2013.08    Updated interface for Match and to_string
--    11/2016   2016.11    Released as part of OSVVM library
--
--
--  Copyright (c) 2006 - 2016 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  This source file is free software; you can redistribute it
--  and/or modify it under the terms of the ARTISTIC License
--  as published by The Perl Foundation; either version 2.0 of
--  the License, or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--
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
