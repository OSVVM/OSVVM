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
--    01/2015   2015.01    Initial Revision
--    06/2015   2015.06    Added MemoryPkg
--    11/2016   2016.11    Added TbUtilPkg and ResolutionPkg
--    01/2020   2020.01    Updated Licenses to Apache
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2015 - 2020 by SynthWorks Design Inc.  
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

    use OSVVM.NamePkg.all ;
    use OSVVM.TranscriptPkg.all ; 
    use OSVVM.TextUtilPkg.all ; 
    use OSVVM.OsvvmGlobalPkg.all ;
    use OSVVM.AlertLogPkg.all ; 
    use OSVVM.RandomPkg.all ;
    use OSVVM.CoveragePkg.all ;
    use OSVVM.MemoryPkg.all ;
    use OSVVM.ResolutionPkg.all ;
    use OSVVM.TbUtilPkg.all ;

end context OsvvmContext ; 

