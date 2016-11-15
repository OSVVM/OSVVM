-- EMACS settings: -*-  tab-width: 2;indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2;replace-tabs off;indent-width 2;
-- =============================================================================
-- Authors:					Patrick Lehmann
--
-- Package:     		Protected type implementations.
--
-- Description:
-- -------------------------------------
-- .. TODO:: No documentation available.
--
-- License:
-- =============================================================================
-- Copyright 2007-2016 Patrick Lehmann - Dresden, Germany
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =============================================================================
--
library ieee ;
use			ieee.std_logic_1164.all ;
use			ieee.numeric_std.all ;

package ScoreboardPkg is
	package ScoreboardPkg_int is new work.ScoreboardGenericPkg
		generic map (
			ExpectedType        => integer,
			ActualType          => integer,
			Match               => "=",
			expected_to_string  => to_string,
			actual_to_string    => to_string
		);
	package ScoreboardPkg_slv is new work.ScoreboardGenericPkg
		generic map (
			ExpectedType        => std_logic_vector,
			ActualType          => std_logic_vector,
			Match               => std_match,  -- "=", [std_logic_vector, std_logic_vector return boolean]
			expected_to_string  => to_hstring, --      [std_logic_vector return string] 
			actual_to_string    => to_hstring  --      [std_logic_vector return string]  
		) ;
	package ScoreboardPkg_s is new work.ScoreboardGenericPkg
		generic map (
			ExpectedType        => signed,
			ActualType          => signed,
			Match               => std_match,  -- "=", [std_logic_vector, std_logic_vector return boolean]
			expected_to_string  => to_hstring, --      [std_logic_vector return string]
			actual_to_string    => to_hstring  --      [std_logic_vector return string]
		) ;
	package ScoreboardPkg_us is new work.ScoreboardGenericPkg
		generic map (
			ExpectedType        => unsigned,
			ActualType          => unsigned,
			Match               => std_match,  -- "=", [std_logic_vector, std_logic_vector return boolean]
			expected_to_string  => to_hstring, --      [std_logic_vector return string]
			actual_to_string    => to_hstring  --      [std_logic_vector return string]
		) ;
	
	alias Integer_ScoreBoard					is ScoreboardPkg_int.ScoreBoardPType;
	alias StdLogicVector_ScoreBoard		is ScoreboardPkg_slv.ScoreBoardPType;
	alias Signed_ScoreBoard						is ScoreboardPkg_s.ScoreBoardPType;
	alias Unsigned_ScoreBoard					is ScoreboardPkg_us.ScoreBoardPType;
end package;
