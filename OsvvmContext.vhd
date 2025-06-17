--
--  File Name:         OsvvmContext.vhd
--  Design Unit Name:  OsvvmContext
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com--
--
--  Description
--      Context Declaration for OSVVM packages
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:      
--    Date      Version    Description
--    02/2025   2025.02    Added FileLinePathPkg.
--    09/2024   2024.09    Added RandomPkg2019 
--    07/2024   2024.07    Added ClockResetPkg, LanguageSupport2019Pkg
--    01/2023   2023.01    Added OsvvmScriptSettingsPkg
--    01/2022   2022.01    Added OsvvmTypesPkg
--    10/2021   2021.10    Added ReportPkg
--    06/2021   2021.06    Updated for release
--    01/2020   2020.01    Updated Licenses to Apache
--    11/2016   2016.11    Added TbUtilPkg and ResolutionPkg
--    06/2015   2015.06    Added MemoryPkg
--    01/2015   2015.01    Initial Revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2015 - 2023 by SynthWorks Design Inc.  
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

context OsvvmContext is
  library OSVVM ;  

  use OSVVM.IfElsePkg.all ;
  use OSVVM.OsvvmTypesPkg.all ; 
  use OSVVM.OsvvmScriptSettingsPkg.all ;
  use OSVVM.NamePkg.all ;
  use OSVVM.NameStorePkg.all ;
  use OSVVM.TranscriptPkg.all ; 
  use OSVVM.TextUtilPkg.all ; 
  use OSVVM.FileUtilPkg.all ; 
  use OSVVM.OsvvmGlobalPkg.all ;
  use OSVVM.AlertLogPkg.all ; 
  use OSVVM.SortListPkg_int.all ;
  use OSVVM.RandomBasePkg.all ;
  use OSVVM.RandomPkg.all ;
  use OSVVM.RandomPkg2019.all ;     -- for non-2019 tools this is empty
  use OSVVM.CoveragePkg.all ;
  use OSVVM.DelayCoveragePkg.all ;
  use OSVVM.MemoryPkg.all ;
  use OSVVM.ResolutionPkg.all ;
  use OSVVM.ResizePkg.all ;
  use OSVVM.TbUtilPkg.all ;
  use OSVVM.ClockResetPkg.all ;
  use OSVVM.ReportPkg.all ;
  use OSVVM.LanguageSupport2019Pkg.all ;  -- for non-2019 tools this has stub subprograms that allow a graceful degradation of 2019 features
  use OSVVM.FilelinePathPkg.all ;
end context OsvvmContext ; 

