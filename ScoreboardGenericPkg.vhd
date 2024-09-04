--
--  File Name:         ScoreBoardGenericPkg.vhd
--  Design Unit Name:  ScoreBoardGenericPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          email:  jim@synthworks.com
--
--
--  Description:
--    Defines types and methods to implement a FIFO based Scoreboard
--    Defines type ScoreBoardPType
--    Defines methods for putting values the scoreboard
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2024   2024.09    Updated Data Structure.  Added FindAndDelete and FindAndFlush.  
--    07/2024   2024.07    Made function generics impure. Added IsInitialized.  Updated Yaml.  
--    05/2023   2023.05    Updated Pop fail on empty error to print tag if a tag is used
--    02/2023   2023.04    Bug fix for Peek with a tag.
--    01/2023   2023.01    OSVVM_RAW_OUTPUT_DIRECTORY replaced REPORTS_DIRECTORY 
--    11/2022   2022.11    Updated default search to PRIVATE_NAME
--    10/2022   2022.10    Added Parent Name to YAML output.
--    09/2022   2022.09    Added FifoCount to YAML output.
--    03/2022   2022.03    Removed deprecated SetAlertLogID in Singleton API
--    02/2022   2022.02    Added WriteScoreboardYaml and GotScoreboards.  Updated NewID with ParentID,
--                         ReportMode, Search, PrintParent.   Supports searching for Scoreboard models..
--    01/2022   2022.01    Added CheckExpected.  Added SetCheckCountZero to ScoreboardPType
--    08/2021   2021.08    Removed SetAlertLogID from singleton public interface - set instead by NewID
--    06/2021   2021.06    Updated Data Structure, IDs for new use model, and Wrapper Subprograms
--    10/2020   2020.10    Added Peek
--    05/2020   2020.05    Updated calls to IncAffirmCount
--                         Overloaded Check with functions that return pass/fail (T/F)
--                         Added GetFifoCount.   Added GetPushCount which is same as GetItemCount
--    01/2020   2020.01    Updated Licenses to Apache
--    04/2018   2018.04    Made Pop Functions Visible.   Prep for AlertLogIDType being a type.
--    05/2017   2017.05    First print Actual then only print Expected if mis-match
--    11/2016   2016.11    Released as part of OSVVM
--    06/2015   2015.06    Added Alerts, SetAlertLogID, Revised LocalPush, GetDropCount,
--                         Deprecated SetFinish and ReportMode - REPORT_NONE, FileOpen
--                         Deallocate, Initialized, Function SetName
--    09/2013   2013.09    Added file handling, Check Count, Finish Status
--                         Find, Flush
--    08/2013   2013.08    Generics:  to_string replaced write, Match replaced check
--                         Added Tags - Experimental
--                         Added Array of Scoreboards
--    08/2012   2012.08    Added Type and Subprogram Generics
--    05/2012   2012.05    Changed FIFO to store pointers to ExpectedType
--                         Allows usage of unconstrained arrays
--    08/2010   2010.08    Added Tail Pointer
--    12/2006   2006.12    Initial revision
--
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2006 - 2024 by SynthWorks Design Inc.
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

  use work.IfElsePkg.all ;
  use work.OsvvmScriptSettingsPkg.all ;
  use work.OsvvmSettingsPkg.all ;
  use work.TranscriptPkg.all ;
  use work.TextUtilPkg.all ;
  use work.AlertLogPkg.all ;
  use work.NamePkg.all ;
  use work.NameStorePkg.all ;
  use work.ResolutionPkg.all ;

package ScoreboardGenericPkg is
  generic (
    type ExpectedType ;
    type ActualType ;
    impure function Match(Actual : ActualType ;                           -- defaults
                   Expected : ExpectedType) return boolean ;       -- is "=" ;
    impure function expected_to_string(A : ExpectedType) return string ;  -- is to_string ;
    impure function actual_to_string  (A : ActualType) return string      -- is to_string ;
  ) ;

--   --  For a VHDL-2002 package, comment out the generics and
--   --  uncomment the following, it replaces a generic instance of the package.
--   --  As a result, you will have multiple copies of the entire package.
--   --  Inconvenient, but ok as it still works the same.
--   subtype ExpectedType is std_logic_vector ;
--   subtype ActualType   is std_logic_vector ;
--   alias Match is std_match [ActualType, ExpectedType return boolean] ;  -- for std_logic_vector
--   alias expected_to_string is to_hstring [ExpectedType return string];  -- VHDL-2008
--   alias actual_to_string is to_hstring [ActualType return string];  -- VHDL-2008

  -- Replaced by Affirmations.  ERROR is the default.  ALL turns on PASSED flag
  type ScoreboardReportType is (REPORT_ERROR, REPORT_ALL, REPORT_NONE) ;   -- replaced by affirmations

  type ScoreboardIdType is record
    Id : integer_max ;
  end record ScoreboardIdType ;
  type ScoreboardIdArrayType  is array (integer range <>) of ScoreboardIdType ;
  type ScoreboardIdMatrixType is array (integer range <>, integer range <>) of ScoreboardIdType ;

  constant SCOREBOARD_ID_UNINITIALZED : ScoreboardIdType := (ID => integer'left) ; 

  -- Preparation for refactoring - if that ever happens.
  subtype FifoIdType       is ScoreboardIdType ;
  subtype FifoIdArrayType  is ScoreboardIdArrayType ;
  subtype FifoIdMatrixType is ScoreboardIdMatrixType ;

  ------------------------------------------------------------
  -- Used by Scoreboard Store
  impure function NewID (
    Name          : String ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDType ;

  ------------------------------------------------------------
  -- Vector: 1 to Size
  impure function NewID (
    Name          : String ;
    Size          : positive ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDArrayType ;

  ------------------------------------------------------------
  -- Vector: X(X'Left) to X(X'Right)
  impure function NewID (
    Name          : String ;
    X             : integer_vector ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDArrayType ;

  ------------------------------------------------------------
  -- Matrix: 1 to X, 1 to Y
  impure function NewID (
    Name          : String ;
    X, Y          : positive ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType ;

  ------------------------------------------------------------
  -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
  impure function NewID (
    Name          : String ;
    X, Y          : integer_vector ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType ;

  ------------------------------------------------------------
  impure function IsInitialized (ID : ScoreboardIDType) return boolean ;

  ------------------------------------------------------------
  -- Push items into the scoreboard/FIFO
  -- Simple Scoreboard, no tag
  procedure Push (
    constant ID     : in  ScoreboardIDType ;
    constant Item   : in  ExpectedType
  ) ;

  -- Simple Tagged Scoreboard
  procedure Push (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    constant Item   : in  ExpectedType
  ) ;

  ------------------------------------------------------------
  -- Push as a function
  -- Simple Scoreboard, no tag
  impure function Push (
    constant ID     : in  ScoreboardIDType ;
    constant Item   : in  ExpectedType
  ) return ExpectedType ;

  -- Simple Tagged Scoreboard
  impure function Push (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    constant Item   : in  ExpectedType
  ) return ExpectedType ;

  ------------------------------------------------------------
  -- Check received item with item in the scoreboard/FIFO

  -- Simple Scoreboard, no tag
  procedure Check (
    constant ID           : in  ScoreboardIDType ;
    constant ActualData   : in ActualType
  ) ;

  -- Simple Tagged Scoreboard
  procedure Check (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ActualData   : in  ActualType
  ) ;

  -- Simple Scoreboard, no tag
  impure function Check (
    constant ID           : in  ScoreboardIDType ;
    constant ActualData   : in ActualType
  ) return boolean ;

  -- Simple Tagged Scoreboard
  impure function Check (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ActualData   : in  ActualType
  ) return boolean ;

  ----------------------------------------------
  -- Simple Scoreboard, no tag
  procedure CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant ExpectedData : in  ActualType
  ) ;

  -- Simple Tagged Scoreboard
  procedure CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ExpectedData : in  ActualType
  ) ;

  -- Simple Scoreboard, no tag
  impure function CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant ExpectedData : in  ActualType
  ) return boolean ;

  -- Simple Tagged Scoreboard
  impure function CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ExpectedData : in  ActualType
  ) return boolean ;

  ------------------------------------------------------------
  -- Pop the top item (FIFO) from the scoreboard/FIFO

  -- Simple Scoreboard, no tag
  procedure Pop (
    constant ID     : in  ScoreboardIDType ;
    variable Item   : out  ExpectedType
  ) ;

  -- Simple Tagged Scoreboard
  procedure Pop (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    variable Item   : out  ExpectedType
  ) ;

  ------------------------------------------------------------
  -- Pop the top item (FIFO) from the scoreboard/FIFO
  -- Caution:  this did not work in older simulators (@2013)

  -- Simple Scoreboard, no tag
  impure function Pop (
    constant ID     : in  ScoreboardIDType
  ) return ExpectedType ;

  -- Simple Tagged Scoreboard
  impure function Pop (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string
  ) return ExpectedType ;


  ------------------------------------------------------------
  -- Peek at the top item (FIFO) from the scoreboard/FIFO

  -- Simple Tagged Scoreboard
  procedure Peek (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    variable Item   : out ExpectedType
  ) ;

  -- Simple Scoreboard, no tag
  procedure Peek (
    constant ID     : in  ScoreboardIDType ;
    variable Item   : out  ExpectedType
  ) ;

  ------------------------------------------------------------
  -- Peek at the top item (FIFO) from the scoreboard/FIFO
  -- Caution:  this did not work in older simulators (@2013)

  -- Tagged Scoreboards
  impure function Peek (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string
  ) return ExpectedType ;

  -- Simple Scoreboard
  impure function Peek (
    constant ID     : in  ScoreboardIDType
  ) return ExpectedType ;

  ------------------------------------------------------------
  -- Empty - check to see if scoreboard is empty
  impure function IsEmpty (
    constant ID     : in  ScoreboardIDType
  ) return boolean ;
  -- Tagged
  impure function IsEmpty (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string
  ) return boolean ;                    -- Simple, Tagged

  alias Empty           is IsEmpty [ScoreboardIDType return boolean] ;
  alias Empty           is IsEmpty [ScoreboardIDType, string return boolean] ;
  alias ScoreboardEmpty is IsEmpty [ScoreboardIDType return boolean] ;
  alias ScoreboardEmpty is IsEmpty [ScoreboardIDType, string return boolean] ;
  
  impure function AllScoreboardsEmpty return boolean ;                     -- All scoreboards in the singleton


  ------------------------------------------------------------
  -- GetAlertLogID - Get the AlertLogID of a scoreboard set by NewID
  --    SetAlertLogID not for singletons since it is already set.
  impure function GetAlertLogID (
    constant ID     : in  ScoreboardIDType
  ) return AlertLogIDType ;


  ------------------------------------------------------------
  -- Find - Returns the ItemNumber for a value and tag (if applicable) in a scoreboard.
  -- Find returns integer'left if no match found
  -- Also See Flush.  Flush will drop items up through the ItemNumber

  -- Simple Scoreboard
  impure function Find (
    constant ID          : in  ScoreboardIDType ;
    constant ActualData  :  in  ActualType
  ) return integer ;

  -- Tagged Scoreboard
  impure function Find (
    constant ID          : in  ScoreboardIDType ;
    constant Tag         :  in  string;
    constant ActualData  :  in  ActualType
  ) return integer ;

  ------------------------------------------------------------
  -- Flush - Remove elements in the scoreboard upto and including the one with ItemNumber
  -- See Find to identify an ItemNumber of a particular value and tag (if applicable)

  -- Simple Scoreboards
  procedure Flush (
    constant ID          :  in  ScoreboardIDType ;
    constant ItemNumber  :  in  integer
  ) ;

  -- Tagged Scoreboards - only removes items that also match the tag
  procedure Flush (
    constant ID          :  in  ScoreboardIDType ;
    constant Tag         :  in  string ;
    constant ItemNumber  :  in  integer
  ) ;

  ------------------------------------------------------------
  -- FindAndDelete - Targeted at out of order scoreboards
  -- Tagged Scoreboards - must find ActualData and matching Tag
  procedure FindAndDelete (
    constant ID          :  in  ScoreboardIDType ;
    constant Tag         :  in  string ;
    constant ActualData  :  in  ActualType
  ) ;
  
  -- Ignores tag to determine match
  procedure FindAndDelete (
    constant ID          :  in  ScoreboardIDType ;
    constant ActualData  :  in  ActualType
  ) ;

  ------------------------------------------------------------
  -- FindAndFlush - Targeted at in order scoreboards that drop values
  -- Removes values if the tag matches up to the value found
  procedure FindAndFlush (
    constant ID          :  in  ScoreboardIDType ;
    constant Tag         :  in  string ;
    constant ActualData  :  in  ActualType
  ) ;
  
  -- Removes all values up to the value found
  procedure FindAndFlush (
    constant ID          :  in  ScoreboardIDType ;
    constant ActualData  :  in  ActualType
  ) ;

  ------------------------------------------------------------
  -- Writing YAML Reports
  impure function GotScoreboards return boolean ;
  procedure WriteScoreboardYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE; FileNameIsBaseName : boolean := SCOREBOARD_YAML_IS_BASE_FILE_NAME) ;

  ------------------------------------------------------------
  -- Scoreboard Introspection

  -- Number of items put into scoreboard
  impure function GetItemCount (
    constant ID     : in  ScoreboardIDType
  ) return integer ;   -- Simple, with or without tags

  impure function GetPushCount (
    constant ID     : in  ScoreboardIDType
  ) return integer ;   -- Simple, with or without tags

  -- Number of items removed from scoreboard by pop or check
  impure function GetPopCount (
    constant ID     : in  ScoreboardIDType
  ) return integer ;

  -- Number of items currently in the scoreboard (= PushCount - PopCount - DropCount)
  impure function GetFifoCount (
    constant ID     : in  ScoreboardIDType
  ) return integer ;

  -- Number of items checked by scoreboard
  impure function GetCheckCount (
    constant ID     : in  ScoreboardIDType
  ) return integer ;  -- Simple, with or without tags

  -- Number of items dropped by scoreboard.  See Find/Flush
  impure function GetDropCount (
    constant ID     : in  ScoreboardIDType
  ) return integer ;   -- Simple, with or without tags


  ------------------------------------------------------------
  -- Generally these are not required.  When a simulation ends and
  -- another simulation is started, a simulator will release all allocated items.
  -- Deallocate - Deletes all allocated items
  procedure Deallocate (constant ID : in  ScoreboardIDType) ;  
  -- Initialize - reCreates initial data structure if it was destroyed with Deallocate
  procedure Initialize (constant ID : in  ScoreboardIDType) ;  


  -------------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ScoreBoardPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ScoreBoardPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ScoreBoardPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  -------------------------------------------------------------------------------------------------
  type ScoreBoardPType is protected

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Used for constructing a Scoreboard in the Singleton Data Structure
    -- /////////////////////////////////////////
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Used by Scoreboard Store
    impure function NewID (
      Name          : String ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDType ;

    ------------------------------------------------------------
    -- Vector: 1 to Size
    impure function NewID (
      Name          : String ;
      Size          : positive ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType ;

    ------------------------------------------------------------
    -- Vector: X(X'Left) to X(X'Right)
    impure function NewID (
      Name          : String ;
      X             : integer_vector ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType ;

    ------------------------------------------------------------
    -- Matrix: 1 to X, 1 to Y
    impure function NewID (
      Name          : String ;
      X, Y          : positive ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType ;

    ------------------------------------------------------------
    -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
    impure function NewID (
      Name          : String ;
      X, Y          : integer_vector ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType ;

    ------------------------------------------------------------
    impure function IsInitialized (ID : ScoreboardIDType) return boolean ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Methods for Singleton and Arrays of Scoreboards - unless noted as Singleton only
    -- /////////////////////////////////////////
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Push item into the scoreboard/FIFO
    -- Scoreboard no tag
    procedure Push (
      constant Index  : in  integer ;
      constant Item   : in  ExpectedType
    ) ;

    -- Tagged Scoreboard
    procedure Push (
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) ;

    ------------------------------------------------------------
    -- Check received item against scoreboard/FIFO
    -- Scoreboard no tag
    procedure Check (
      constant Index        : in  integer ;
      constant ActualData   : in ActualType
    ) ;

    -- Tagged Scoreboard
    procedure Check (
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) ;

    -- Scoreboard no tag
    impure function Check (
      constant Index        : in  integer ;
      constant ActualData   : in ActualType
    ) return boolean ;

    -- Tagged Scoreboard
    impure function Check (
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean ;

    -------------------------------
    -- Tagged Scoreboards - Singleton Only
    impure function CheckExpected (
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ExpectedData : in  ActualType
    ) return boolean ;


    ------------------------------------------------------------
    -- Pop the top item (FIFO) from the scoreboard/FIFO
    -- Scoreboard no tag
    procedure Pop (
      constant Index : in   integer ;
      variable Item : out  ExpectedType
    ) ;

    -- Tagged Scoreboard
    procedure Pop (
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) ;

    ------------------------------------------------------------
    -- Pop as a function
    -- Caution:  Not supported by older simulators (@2013)
    -- Scoreboard no tag
      impure function Pop (Index : integer) return ExpectedType ;

    -- Tagged Scoreboard
      impure function Pop (
        constant Index  : in  integer ;
        constant Tag    : in  string
      ) return ExpectedType ;

    ------------------------------------------------------------
    -- Peek at the top item (FIFO) from the scoreboard/FIFO
    -- Scoreboard no tag
    procedure Peek (
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out ExpectedType
    ) ;

    -- Tagged Scoreboard
    procedure Peek (
      constant Index  : in  integer ;
      variable Item   : out  ExpectedType
    ) ;

    ------------------------------------------------------------
    -- Peek as a function
    -- Scoreboard no tag
    impure function Peek (Index : integer) return ExpectedType ;

    -- Tagged Scoreboard
    impure function Peek (
      constant Index  : in  integer ;
      constant Tag    : in  string
    ) return ExpectedType ;

    ------------------------------------------------------------
    -- Empty - check to see if scoreboard is empty
    impure function Empty (Index  : integer) return boolean ;                -- Array
    impure function Empty (Index  : integer; Tag : String) return boolean ;  -- Array, Tagged
    
    -- Empty for all scoreboards in the singleton
    impure function AllScoreboardsEmpty return boolean ; 
    
    ------------------------------------------------------------
    -- Find - Returns the ItemNumber for a value and tag (if applicable) in a scoreboard.
    -- Find returns integer'left if no match found
    -- Also See Flush.  Flush will drop items up through the ItemNumber
    -- Scoreboard no tag
    impure function Find (
      constant Index       :  in  integer ;
      constant ActualData  :  in  ActualType
    ) return integer ;

    -- Tagged Scoreboard
    impure function Find (
      constant Index       :  in  integer ;
      constant Tag         :  in  string;
      constant ActualData  :  in  ActualType
    ) return integer ;
    
    ------------------------------------------------------------
    -- Flush - Remove elements in the scoreboard upto and including the one with ItemNumber
    -- See Find to identify an ItemNumber of a particular value and tag (if applicable)
    -- Scoreboard no tag
    procedure Flush (
      constant Index       :  in  integer ;
      constant ItemNumber  :  in  integer
    ) ;

    -- Tagged Scoreboard - only removes items that also match the tag
    procedure Flush (
      constant Index       :  in  integer ;
      constant Tag         :  in  string ;
      constant ItemNumber  :  in  integer
    ) ;

    ------------------------------------------------------------
    -- FindAndDelete - Targeted at out of order scoreboards
    -- Tagged Scoreboards - must find ActualData and matching Tag
    procedure FindAndDelete (
      constant Index       :  in  integer ;
      constant Tag         :  in  string ;
      constant ActualData  :  in  ActualType
    ) ;
    
    -- Ignores tag to determine match
    procedure FindAndDelete (
      constant Index       :  in  integer ;
      constant ActualData  :  in  ActualType
    ) ;

    ------------------------------------------------------------
    -- FindAndFlush - Targeted at in order scoreboards that drop values
    -- Removes values if the tag matches up to the value found
    procedure FindAndFlush (
      constant Index       :  in  integer ;
      constant Tag         :  in  string ;
      constant ActualData  :  in  ActualType
    ) ;
    
    -- Removes all values up to the value found
    procedure FindAndFlush (
      constant Index       :  in  integer ;
      constant ActualData  :  in  ActualType
    ) ;

    ------------------------------------------------------------
    -- Writing YAML Reports
    impure function GotScoreboards return boolean ;
    procedure WriteScoreboardYaml (FileName : string; OpenKind : File_Open_Kind; FileNameIsBaseName : boolean) ;

    ------------------------------------------------------------
    -- GetAlertLogID - get the AlertLogID set by NewID
    --   Note SetAlertID not for singletons since it is already set
    impure function GetAlertLogID(Index : Integer) return AlertLogIDType ;

    ------------------------------------------------------------
    -- Scoreboard Introspection
    -- Note Scoreboard Reports automatically done by OSVVM contain all of this information
    -- Number of items put into scoreboard
    impure function GetItemCount (Index  : integer) return integer ; 
    impure function GetPushCount (Index  : integer) return integer ; 
    -- Number of items removed from scoreboard by pop or check
    impure function GetPopCount (Index  : integer) return integer ;
    -- Number of items currently in the scoreboard (= PushCount - PopCount - DropCount)
    impure function GetFifoCount (Index  : integer) return integer ;
    -- Number of items checked by scoreboard
    impure function GetCheckCount (Index  : integer) return integer ; 
    -- Number of items dropped by scoreboard.  See Find/Flush
    impure function GetDropCount (Index  : integer) return integer ;  

    ------------------------------------------------------------
    -- Generally these are not required.  When a simulation ends and
    -- another simulation is started, a simulator will release all allocated items.
    procedure Deallocate ;  -- Deletes all allocated items
    procedure Initialize ;  -- Creates initial data structure if it was destroyed with Deallocate


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  -- Compatibility Methods - Allows ScoreboardGenericPkg to Work as a PT still
  --    Please use the singleton for new stuff - it is easier ...
  --    The PT is soft deprecated.   It will not get future enhancements that the Singleton does.
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  ------------------------------------------------------------

    ------------------------------------------------------------
    -- Emulate arrays of scoreboards
    procedure SetArrayIndex(L, R : integer) ;  -- supports integer indices
    procedure SetArrayIndex(R : natural) ;     -- indicies 1 to R
    impure function GetArrayIndex return integer_vector ;
    impure function GetArrayLength return natural ;

    ------------------------------------------------------------
    -- Push item into the scoreboard/FIFO
    -- Simple Scoreboard, no tag
    procedure Push (Item   : in  ExpectedType) ;

    -- Simple Tagged Scoreboard
    procedure Push (
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) ;

    ------------------------------------------------------------
    -- Check received item with item in the scoreboard/FIFO
    -- Simple Scoreboard, no tag
    procedure Check (ActualData : ActualType) ;

    -- Simple Tagged Scoreboard
    procedure Check (
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) ;

    -- Simple Scoreboard, no tag
    impure function Check (ActualData : ActualType) return boolean ;

    -- Simple Tagged Scoreboard
    impure function Check (
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean ;

    ------------------------------------------------------------
    -- Pop the top item (FIFO) from the scoreboard/FIFO
    -- Simple Scoreboard, no tag
    procedure Pop (variable Item : out  ExpectedType) ;

    -- Simple Tagged Scoreboard
    procedure Pop (
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) ;

    ------------------------------------------------------------
    -- Pop as a function
    -- Caution:  Not supported by older simulators (@2013)
    -- Simple Scoreboard, no tag
    impure function Pop return ExpectedType ;

    -- Simple Tagged Scoreboard
    impure function Pop (
      constant Tag : in  string
    ) return ExpectedType ;

    ------------------------------------------------------------
    -- Peek at the top item (FIFO) from the scoreboard/FIFO
    -- Simple Tagged Scoreboard
    procedure Peek (
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) ;

    -- Simple Scoreboard, no tag
    procedure Peek (variable Item : out  ExpectedType) ;

    ------------------------------------------------------------
    -- Peek as a function
    -- Simple Scoreboard, no tag
    impure function Peek return ExpectedType ;

    -- Simple Tagged Scoreboard
    impure function Peek (
      constant Tag : in  string
    ) return ExpectedType ;

    ------------------------------------------------------------
    -- Empty - check to see if scoreboard is empty
    impure function Empty return boolean ;                                   -- Simple
    impure function Empty (Tag : String) return boolean ;                    -- Simple, Tagged

    ------------------------------------------------------------
    -- Find - Returns the ItemNumber for a value and tag (if applicable) in a scoreboard.
    -- Find returns integer'left if no match found
    -- Also See Flush.  Flush will drop items up through the ItemNumber
    -- Simple Scoreboard
    impure function Find (
      constant ActualData  :  in  ActualType
    ) return integer ;

    -- Tagged Scoreboard
    impure function Find (
      constant Tag         :  in  string;
      constant ActualData  :  in  ActualType
    ) return integer ;

    ------------------------------------------------------------
    -- Flush - Remove elements in the scoreboard upto and including the one with ItemNumber
    -- See Find to identify an ItemNumber of a particular value and tag (if applicable)
    -- Simple Scoreboard
    procedure Flush (
      constant ItemNumber  :  in  integer
    ) ;

    -- Tagged Scoreboard - only removes items that also match the tag
    procedure Flush (
      constant Tag         :  in  string ;
      constant ItemNumber  :  in  integer
    ) ;

    ------------------------------------------------------------
    -- SetAlertLogID - associate an AlertLogID with a scoreboard to allow integrated error reporting
    -- ReportMode := ENABLED when not DoNotReport else DISABLED ;
    procedure SetAlertLogID(Index : Integer; Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) ;
    procedure SetAlertLogID(Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) ;
    -- Use when an AlertLogID is used by multiple items (Model or other Scoreboards).  See also AlertLogPkg.GetAlertLogID
    procedure SetAlertLogID (Index : Integer ; A : AlertLogIDType) ;
    procedure SetAlertLogID (A : AlertLogIDType) ;
    impure function GetAlertLogID return AlertLogIDType ;

    ------------------------------------------------------------
    -- Scoreboard Introspection
    -- Number of items put into scoreboard
    impure function GetItemCount return integer ;
    impure function GetPushCount return integer ;
    -- Number of items removed from scoreboard by pop or check
    impure function GetPopCount return integer ;
    -- Number of items currently in the scoreboard (= PushCount - PopCount - DropCount)
    impure function GetFifoCount return integer ;
    -- Number of items checked by scoreboard
    impure function GetCheckCount return integer ; 
    -- Number of items dropped by scoreboard.  See Find/Flush
    impure function GetDropCount return integer ; 


    ------------------------------------------------------------
    -- Set a scoreboard name.
    -- Used when scoreboard AlertLogID is shared between different sources.
    procedure SetName (Name : String) ;
    impure function SetName (Name : String) return string ;
    impure function GetName (DefaultName : string := "Scoreboard") return string ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- /////////////////////////////////////////
    -- Deprecated.  Supported only for backward compatibility.   
    -- /////////////////////////////////////////
    -- /////////////////////////////////////////
    ------------------------------------------------------------

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Deprecated.  Use alerts directly instead.
    -- AlertIF(SB.GetCheckCount < 10, ....) ;
    -- AlertIf(Not SB.Empty, ...) ;
    ------------------------------------------------------------
    -- Set alerts if scoreboard not empty or if CheckCount <
    -- Use if need to check empty or CheckCount for a specific scoreboard.

    -- Simple Scoreboards, with or without tag
    procedure CheckFinish (
      FinishCheckCount   : integer ;
      FinishEmpty        : boolean
    ) ;

    -- Array of Scoreboards, with or without tag
    procedure CheckFinish (
      Index              : integer ;
      FinishCheckCount   : integer ;
      FinishEmpty        : boolean
    ) ;

    ------------------------------------------------------------
    -- Get error count
    -- Deprecated, replaced by usage of Alerts
    -- AlertFLow:      Instead use AlertLogPkg.ReportAlerts or AlertLogPkg.GetAlertCount
    -- Not AlertFlow:  use GetErrorCount to get total error count

    -- Simple Scoreboards, with or without tag
    impure function GetErrorCount return integer ;

    -- Array of Scoreboards, with or without tag
    impure function GetErrorCount(Index : integer) return integer ;

    ------------------------------------------------------------
    -- Error count manipulation

    -- IncErrorCount - not recommended, use alerts instead - may be deprecated in the future
    procedure IncErrorCount ;                          -- Simple, with or without tags
    procedure IncErrorCount (Index  : integer) ;       -- Arrays, with or without tags

    -- Clear error counter.  Caution does not change AlertCounts, must also use AlertLogPkg.ClearAlerts
    procedure SetErrorCountZero ;                      -- Simple, with or without tags
    procedure SetErrorCountZero (Index  : integer) ;   -- Arrays, with or without tags
    -- Clear check counter. Caution does not change AffirmationCounters
    procedure SetCheckCountZero ;                      -- Simple, with or without tags
    procedure SetCheckCountZero (Index  : integer) ;   -- Arrays, with or without tags

    ------------------------------------------------------------
    -- SetReportMode - deprecated
    --   Instead use:
    --      AlertLogPkg.SetLogEnable(ID, PASSED, TRUE)  for REPORT_ALL
    --      AlertLogPkg.SetLogEnable(ID, PASSED, FALSE) for REPORT_ERROR and REPORT_NONE
    --   and 
    --      AlertLogPkg.SetAlertPrintCount(ID, integer'high)  for REPORT_ALL and REPORT_ERROR
    --      AlertLogPkg.SetAlertPrintCount(ID, 0) for REPORT_NONE
    -- 
    procedure SetReportMode (ReportModeIn : ScoreboardReportType) ;
    impure function GetReportMode return ScoreboardReportType ;

    ------------------------------------------------------------
    -- Deprecated.  Names changed.  Maintained for backward compatibility  - would prefer an alias
    ------------------------------------------------------------
    procedure FileOpen (FileName : string; OpenKind : File_Open_Kind ) ; -- Replaced by TranscriptPkg.TranscriptOpen
    procedure PutExpectedData (ExpectedData : ExpectedType) ;            -- Replaced by push
    procedure CheckActualData (ActualData : ActualType) ;                -- Replaced by Check
    impure function GetItemNumber return integer ;                       -- Replaced by GetItemCount
    procedure SetMessage (MessageIn : String) ;                          -- Replaced by SetName
    impure function GetMessage return string ;                           -- Replaced by GetName

    -- Deprecated and may be deleted in a future revision
    procedure SetFinish (    -- Replaced by CheckFinish
      Index       : integer ;
      FCheckCount : integer ;
      FEmpty      : boolean := TRUE;
      FStatus     : boolean := TRUE
    ) ;

    procedure SetFinish (     -- Replaced by CheckFinish
      FCheckCount : integer ;
      FEmpty      : boolean := TRUE;
      FStatus     : boolean := TRUE
    ) ;

    ------------------------------------------------------------
    ------------------------------------------------------------


  end protected ScoreBoardPType ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  -- Deprecated.  Supported only for backward compatibility. 
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  
  ------------------------------------------------------------
  -- GetErrorCount - Deprecated, replaced by usage of Alerts
  --   Use AlertLogPkg.GetAlertCount(AlertLogID)
  impure function GetErrorCount(
    constant ID     : in  ScoreboardIDType
  ) return integer ;

  ------------------------------------------------------------
  procedure CheckFinish (
  ------------------------------------------------------------
    ID                 : ScoreboardIDType ;
    FinishCheckCount   : integer ;
    FinishEmpty        : boolean
  ) ;

  ------------------------------------------------------------
  -- SetReportMode - deprecated
  --   Instead use:
  --      AlertLogPkg.SetLogEnable(ID, PASSED, TRUE)  for REPORT_ALL
  --      AlertLogPkg.SetLogEnable(ID, PASSED, FALSE) for REPORT_ERROR and REPORT_NONE
  --   and 
  --      AlertLogPkg.SetAlertPrintCount(ID, integer'high)  for REPORT_ALL and REPORT_ERROR
  --      AlertLogPkg.SetAlertPrintCount(ID, 0) for REPORT_NONE
  -- 
  procedure SetReportMode (
    constant ID           : in  ScoreboardIDType ;
    constant ReportModeIn : in  ScoreboardReportType
  ) ;
  impure function GetReportMode (
    constant ID           : in  ScoreboardIDType
    ) return ScoreboardReportType ;


  -- Deprecated Interface to NewID - these remap to the current NewID 
  impure function NewID (Name : String; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDType ;
  -- Vector: 1 to Size
  impure function NewID (Name : String; Size : positive; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType ;
  -- Vector: X(X'Left) to X(X'Right)
  impure function NewID (Name : String; X : integer_vector; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType ;
  -- Matrix: 1 to X, 1 to Y
  impure function NewID (Name : String; X, Y : positive; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType ;
  -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
  impure function NewID (Name : String; X, Y : integer_vector; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType ;


end ScoreboardGenericPkg ;


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
package body ScoreboardGenericPkg is

  type ScoreBoardPType is protected body
    type ExpectedPtrType is access ExpectedType ;

    type ListType ;
    type ListPtrType is access ListType ;
    type ListType is record
      ItemNumber     : integer ;
      TagPtr         : line ;
      ExpectedPtr    : ExpectedPtrType ;
      NextPtr        : ListPtrType ;
    end record ;

    type ScoreboardRecType is record
      HeadPtr        : ListPtrType ;
      TailPtr        : ListPtrType ;
      PopListPtr     : ListPtrType ;

      ItemNumber     : integer ;
      ErrorCount     : integer ;
      DropCount      : integer ;
      PopCount       : integer ;
      CheckCount     : integer ;
      AlertLogID     : AlertLogIDType ;
    end record ScoreboardRecType ;

    type     ItemArrayType    is array (integer range <>) of ScoreboardRecType ; 
    type     ItemArrayPtrType is access ItemArrayType ;
    
    -- Template and new ItemArray'(Template) initialization support usage as PT.  Not needed for singleton.
    constant DEFAULT_INDEX    : integer := 1 ;
    variable Template  : ItemArrayType(DEFAULT_INDEX to DEFAULT_INDEX) := (DEFAULT_INDEX => (NULL, NULL, NULL, 0, 0, 0, 0, 0, OSVVM_SCOREBOARD_ALERTLOG_ID)) ;  -- Work around for QS 2020.04 and 2021.02
    variable SbPtr : ItemArrayPtrType := new ItemArrayType'(Template) ;

    -- Used by ScoreboardStore
    variable NumItems         : integer := 0 ; 
--    constant NUM_ITEMS_TO_ALLOCATE    : integer := 4 ; -- Temporarily small for testing
    constant NUM_ITEMS_TO_ALLOCATE    : integer := 32 ; -- Min amount to resize array
    variable LocalNameStore   : NameStorePType ; 
    variable CalledNewID      : boolean := FALSE ;  -- singleton initialized

    -- MinIndex, MaxIndex - mainly for PT, but usable for both as bounds checking of ID 
    variable MinIndex         : integer := DEFAULT_INDEX ; 
    variable MaxIndex         : integer := DEFAULT_INDEX ; 
    
    -- PT only 
    variable ArrayLengthVar   : integer := 1 ; -- only for PT.  Default 1 item in Sb array.
    variable NameVar          : NamePType ;
    variable PrintIndexVar    : boolean := TRUE ;
    

    ------------------------------------------------------------
    -- PT Only.   Not for Singleton
    procedure SetPrintIndex (Enable : boolean := TRUE) is
    ------------------------------------------------------------
    begin
      PrintIndexVar := Enable ;
    end procedure SetPrintIndex ;

    ------------------------------------------------------------
    -- Package Local
    function NormalizeArraySize( NewNumItems, MinNumItems : integer ) return integer is
    ------------------------------------------------------------
      variable NormNumItems : integer := NewNumItems ;
      variable ModNumItems  : integer := 0;
    begin
      ModNumItems := NewNumItems mod MinNumItems ;
      if ModNumItems > 0 then
        NormNumItems := NormNumItems + (MinNumItems - ModNumItems) ;
      end if ;
      return NormNumItems ;
    end function NormalizeArraySize ;

    ------------------------------------------------------------
    -- Package Local
    procedure GrowNumberItems (
    ------------------------------------------------------------
      variable ItemArrayPtr     : InOut ItemArrayPtrType ;
      variable NumItems         : InOut integer ;
      constant GrowAmount       : in integer ;
      constant MinNumItems      : in integer
    ) is
      variable oldItemArrayPtr  : ItemArrayPtrType ;
      variable NewNumItems : integer ;
    begin
      NewNumItems := NumItems + GrowAmount ;
      if ItemArrayPtr = NULL then
        ItemArrayPtr := new ItemArrayType(1 to NormalizeArraySize(NewNumItems, MinNumItems)) ;
      elsif NewNumItems > ItemArrayPtr'length then
        oldItemArrayPtr := ItemArrayPtr ;
        ItemArrayPtr := new ItemArrayType(1 to NormalizeArraySize(NewNumItems, MinNumItems)) ;
        ItemArrayPtr(1 to NumItems) := ItemArrayType'(oldItemArrayPtr(1 to NumItems)) ;
        deallocate(oldItemArrayPtr) ;
      end if ;
      NumItems := NewNumItems ;
      MaxIndex := NumItems ; 
    end procedure GrowNumberItems ;

    ------------------------------------------------------------
    -- Local/Private to package
    impure function LocalNewID (
      Name          : String ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDType is
    ------------------------------------------------------------
      variable NameID              : integer ;
    begin
      CalledNewID := TRUE ;
      NameID := LocalNameStore.find(Name, ParentID, Search) ;

      -- Share the scoreboards if they match
      if NameID /= ID_NOT_FOUND.ID then
        return ScoreboardIDType'(ID => NameID) ;
      else
        -- Resize Data Structure as necessary
        GrowNumberItems(SbPtr, NumItems, GrowAmount => 1, MinNumItems => NUM_ITEMS_TO_ALLOCATE) ;
        -- Create AlertLogID
        SbPtr(NumItems) := Template(DEFAULT_INDEX) ; 
        SbPtr(NumItems).AlertLogID := NewID(Name, ParentID, ReportMode, PrintParent, CreateHierarchy => FALSE) ;
        -- Add item to NameStore
        NameID := LocalNameStore.NewID(Name, ParentID, Search) ;
        AlertIfNotEqual(SbPtr(NumItems).AlertLogID, NameID, NumItems, "ScoreboardPkg: Index of LocalNameStore /= ScoreboardID") ;
        return ScoreboardIDType'(ID => NumItems) ;
      end if ;
    end function LocalNewID ;

    ------------------------------------------------------------
    -- Used by Scoreboard Store
    impure function NewID (
      Name          : String ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDType is
    ------------------------------------------------------------
      variable ResolvedSearch      : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
    begin
      SetPrintIndex(FALSE) ;  -- historic, but needed

      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_SCOREBOARD_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_SCOREBOARD_ALERTLOG_ID, PrintParent) ;

      return LocalNewID(Name, ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent) ;

    end function NewID ;

    ------------------------------------------------------------
    -- Vector. Assumes valid range (done by NewID)
    impure function LocalNewID (
      Name          : String ;
      X             : integer_vector ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType is
    ------------------------------------------------------------
      variable Result          : ScoreboardIDArrayType(X(X'left) to X(X'right)) ;
      variable ResolvedSearch  : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
--      variable ArrayParentID       : AlertLogIDType ;
    begin
      SetPrintIndex(FALSE) ;  -- historic, but needed

      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_SCOREBOARD_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_SCOREBOARD_ALERTLOG_ID, PrintParent) ;
--      ArrayParentID       := NewID(Name, ParentID, ReportMode, ResolvedPrintParent, CreateHierarchy => FALSE) ;

      for i in Result'range loop
        Result(i) := LocalNewID(Name & "(" & to_string(i) & ")", ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent) ;
      end loop ;
      return Result ;
    end function LocalNewID ;

    ------------------------------------------------------------
    -- Vector: 1 to Size
    impure function NewID (
      Name          : String ;
      Size          : positive ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType is
    ------------------------------------------------------------
    begin
      return LocalNewID(Name, (1, Size) , ParentID, ReportMode, Search, PrintParent) ;
    end function NewID ;

    ------------------------------------------------------------
    -- Vector: X(X'Left) to X(X'Right)
    impure function NewID (
      Name          : String ;
      X             : integer_vector ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType is
    ------------------------------------------------------------
    begin
      AlertIf(ParentID, X'length /= 2, "ScoreboardPkg.NewID Array parameter X has " & to_string(X'length) & "dimensions.  Required to be 2", FAILURE) ;
      AlertIf(ParentID, X(X'Left) > X(X'right), "ScoreboardPkg.NewID Array parameter X(X'left): " & to_string(X'Left) & " must be <= X(X'right): " & to_string(X(X'right)), FAILURE) ;
      return LocalNewID(Name, X, ParentID, ReportMode, Search, PrintParent) ;
    end function NewID ;

    ------------------------------------------------------------
    -- Matrix. Assumes valid indices (done by NewID)
    impure function LocalNewID (
      Name          : String ;
      X, Y          : integer_vector ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType is
    ------------------------------------------------------------
      variable Result          : ScoreboardIdMatrixType(X(X'left) to X(X'right), Y(Y'left) to Y(Y'right)) ;
      variable ResolvedSearch  : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
--      variable ArrayParentID       : AlertLogIDType ;
    begin
      SetPrintIndex(FALSE) ;

      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_SCOREBOARD_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_SCOREBOARD_ALERTLOG_ID, PrintParent) ;
--      ArrayParentID       := NewID(Name, ParentID, ReportMode, ResolvedPrintParent, CreateHierarchy => FALSE) ;

      for i in X(X'left) to X(X'right) loop
        for j in Y(Y'left) to Y(Y'right) loop
          Result(i, j) := LocalNewID(Name & "(" & to_string(i) & ", " & to_string(j) & ")", ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent) ;
        end loop ;
      end loop ;
      return Result ;
    end function LocalNewID ;

    ------------------------------------------------------------
    -- Matrix: 1 to X, 1 to Y
    impure function NewID (
      Name          : String ;
      X, Y          : positive ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType is
    ------------------------------------------------------------
    begin
      return LocalNewID(Name, (1,X), (1,Y), ParentID, ReportMode, Search, PrintParent) ;
    end function NewID ;

    ------------------------------------------------------------
    -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
    impure function NewID (
      Name          : String ;
      X, Y          : integer_vector ;
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ;
      Search        : NameSearchType          := PRIVATE_NAME ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType is
    ------------------------------------------------------------
    begin
      AlertIf(ParentID, X'length /= 2, "ScoreboardPkg.NewID Matrix parameter X has " & to_string(X'length) & "dimensions.  Required to be 2", FAILURE) ;
      AlertIf(ParentID, Y'length /= 2, "ScoreboardPkg.NewID Matrix parameter Y has " & to_string(Y'length) & "dimensions.  Required to be 2", FAILURE) ;
      AlertIf(ParentID, X(X'Left) > X(X'right), "ScoreboardPkg.NewID Matrix parameter X(X'left): " & to_string(X'Left) & " must be <= X(X'right): " & to_string(X(X'right)), FAILURE) ;
      AlertIf(ParentID, Y(Y'Left) > Y(Y'right), "ScoreboardPkg.NewID Matrix parameter Y(Y'left): " & to_string(Y'Left) & " must be <= Y(Y'right): " & to_string(Y(Y'right)), FAILURE) ;
      return LocalNewID(Name, X, Y, ParentID, ReportMode, Search, PrintParent) ;
    end function NewID ;

    ------------------------------------------------------------
    impure function IsInitialized (ID : ScoreboardIDType) return boolean is
    ------------------------------------------------------------
    begin
      return ID /= SCOREBOARD_ID_UNINITIALZED ;
    end function IsInitialized ;

    ------------------------------------------------------------
    impure function LocalOutOfRange(
    ------------------------------------------------------------
      constant Index : in integer ;
      constant Name  : in string
    ) return boolean is
    begin
      if Index >= MinIndex and Index <= MaxIndex then
        return FALSE ; 
      else 
        Alert(OSVVM_SCOREBOARD_ALERTLOG_ID, 
         GetName & " " & Name & " Index: " & to_string(Index) &
               " is not in the range (" & to_string(MinIndex) &
               " to " & to_string(MaxIndex) & ")",
         FAILURE ) ;
        return TRUE ; 
      end if ; 
    end function LocalOutOfRange ;

    ------------------------------------------------------------
    procedure LocalPush (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) is
      variable TailPtr : ListPtrType ; 
      variable ExpectedPtr : ExpectedPtrType ;
      variable TagPtr : line ;
    begin
      if LocalOutOfRange(Index, "Push") then
        return ; -- error reporting in LocalOutOfRange
      end if ;

      SbPtr(Index).ItemNumber  := SbPtr(Index).ItemNumber + 1 ;
      ExpectedPtr := new ExpectedType'(Item) ;
      TagPtr := new string'(Tag) ;

      if SbPtr(Index).HeadPtr = NULL then
        -- 2015.05: allocation using ListTtype'(...) in a protected type does not work in some simulators
        -- SbPtr(Index).HeadPtr := new ListType'(SbPtr(Index).ItemNumber, TagPtr, ExpectedPtr, NULL) ;
        TailPtr := new ListType ; 
        SbPtr(Index).HeadPtr := TailPtr ;
        
      else
        -- 2015.05: allocation using ListTtype'(...) in a protected type does not work in some simulators
        -- SbPtr(Index).TailPtr.NextPtr := new ListType'(SbPtr(Index).ItemNumber, TagPtr, ExpectedPtr, NULL) ;
        TailPtr := new ListType ; 
        SbPtr(Index).TailPtr.NextPtr := TailPtr ;
      end if ; 
      
      TailPtr.ItemNumber  := SbPtr(Index).ItemNumber ;
      TailPtr.TagPtr      := TagPtr ;
      TailPtr.ExpectedPtr := ExpectedPtr ;
      TailPtr.NextPtr     := NULL ;
      
      SbPtr(Index).TailPtr := TailPtr ;
    end procedure LocalPush ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    procedure Push (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) is
      variable ExpectedPtr : ExpectedPtrType ;
      variable TagPtr : line ;
    begin
      LocalPush(Index, Tag, Item) ;
    end procedure Push ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    procedure Push (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Item   : in  ExpectedType
    ) is
    begin
      LocalPush(Index, "", Item) ;
    end procedure Push ;

    ------------------------------------------------------------
    -- Local Only
    -- Pops highest element matching Tag into SbPtr(Index).PopListPtr
    procedure LocalPop (Index : integer ; Tag : string; Name : string; Found : out boolean)  is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      Found := FALSE ;
      if LocalOutOfRange(Index, Name) then
        return ; -- error reporting in LocalOutOfRange
      end if ;
      if SbPtr(Index).HeadPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        if tag'length > 0 then 
          Alert(SbPtr(Index).AlertLogID, GetName & " Empty during " & Name & ",  tag: " & Tag , FAILURE) ;
        else
          Alert(SbPtr(Index).AlertLogID, GetName & " Empty during " & Name, FAILURE) ;
        end if ; 
        return ;
      end if ;
      SbPtr(Index).PopCount := SbPtr(Index).PopCount + 1 ;
      -- deallocate previous pointer
      if SbPtr(Index).PopListPtr /= NULL then
        deallocate(SbPtr(Index).PopListPtr.TagPtr) ;
        deallocate(SbPtr(Index).PopListPtr.ExpectedPtr) ;
        deallocate(SbPtr(Index).PopListPtr) ;
      end if ;
      -- Descend to find Tag field and extract
      CurPtr := SbPtr(Index).HeadPtr ;
      if CurPtr.TagPtr.all = Tag then
        -- Non-tagged scoreboards find this one.
        SbPtr(Index).PopListPtr  := SbPtr(Index).HeadPtr ;
        SbPtr(Index).HeadPtr     := SbPtr(Index).HeadPtr.NextPtr ;
        Found := TRUE ;
      else
        loop
          if CurPtr.NextPtr = NULL then
            SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
            AffirmIf(SbPtr(Index).AlertLogID, FALSE, Name & "   Tag: " & Tag & " not found", ERROR) ;
            exit ;
          elsif CurPtr.NextPtr.TagPtr.all = Tag then
            Found := TRUE ;
            SbPtr(Index).PopListPtr := CurPtr.NextPtr ;
            CurPtr.NextPtr := CurPtr.NextPtr.NextPtr ;
            if CurPtr.NextPtr = NULL then
              SbPtr(Index).TailPtr := CurPtr ;
            end if ;
            exit ;
          else
            CurPtr := CurPtr.NextPtr ;
          end if ;
        end loop ;
      end if ;
    end procedure LocalPop ;

    ------------------------------------------------------------
    -- Local Only
    -- Pops highest element matching Tag into SbPtr(Index).PopListPtr
    procedure LocalPop (Index : integer ; Name : string; Found : out boolean)  is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      Found := FALSE ;
      if LocalOutOfRange(Index, Name) then
        return ; -- error reporting in LocalOutOfRange
      end if ;
      if SbPtr(Index).HeadPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        Alert(SbPtr(Index).AlertLogID, GetName & " Empty during " & Name, FAILURE) ;
        return ;
      end if ;
      SbPtr(Index).PopCount := SbPtr(Index).PopCount + 1 ;
      -- deallocate previous pointer
      if SbPtr(Index).PopListPtr /= NULL then
        deallocate(SbPtr(Index).PopListPtr.TagPtr) ;
        deallocate(SbPtr(Index).PopListPtr.ExpectedPtr) ;
        deallocate(SbPtr(Index).PopListPtr) ;
      end if ;
      SbPtr(Index).PopListPtr  := SbPtr(Index).HeadPtr ;
      SbPtr(Index).HeadPtr     := SbPtr(Index).HeadPtr.NextPtr ;
      Found := TRUE ;
    end procedure LocalPop ;
    
    
    ------------------------------------------------------------
    -- Local Only
    procedure LocalCheck (
    ------------------------------------------------------------
      constant Index          : in    integer ;
      constant ActualData     : in    ActualType ;
      variable Found          : inout boolean ;
      constant ExpectedInFIFO : in    boolean := TRUE
    ) is
      variable ExpectedPtr    : ExpectedPtrType ;
      variable CurrentItem  : integer ;
      variable WriteBuf : line ;
      variable PassedFlagEnabled : boolean ;
      variable FoundError : boolean ; 
    begin
      SbPtr(Index).CheckCount := SbPtr(Index).CheckCount + 1 ;
      ExpectedPtr := SbPtr(Index).PopListPtr.ExpectedPtr ;
      CurrentItem := SbPtr(Index).PopListPtr.ItemNumber ;

      PassedFlagEnabled := GetLogEnable(SbPtr(Index).AlertLogID, PASSED) ;

      if not Match(ActualData, ExpectedPtr.all) then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        FoundError := TRUE ;
        -- IncAffirmCount(SbPtr(Index).AlertLogID) ;
      else
        FoundError := FALSE ;
        -- If PassFlagEnabled, will count it in the log later.
        if not PassedFlagEnabled then
          IncAffirmPassedCount(SbPtr(Index).AlertLogID) ;
        end if ;
      end if ;
      Found := not FoundError ; 

--      IncAffirmCount(SbPtr(Index).AlertLogID) ;

--      if FoundError or ReportModeVar = REPORT_ALL then
      if FoundError or PassedFlagEnabled then
        -- Only used for PT based SB - Singleton uses AlertLogID name instead
        if not CalledNewID then 
          if SbPtr(Index).AlertLogID = OSVVM_SCOREBOARD_ALERTLOG_ID  then
  --x          write(WriteBuf, GetName(DefaultName => "Scoreboard")) ;
            write(WriteBuf, NameVar.Get("Scoreboard")) ;
            if not (ArrayLengthVar > 1 and PrintIndexVar) then
              swrite(WriteBuf, "   ") ;
            end if ;
          elsif NameVar.IsSet then 
  --x          write(WriteBuf, GetName(DefaultName => "")) ;
            write(WriteBuf, NameVar.Get("")) ;
            if not (ArrayLengthVar > 1 and PrintIndexVar) then
              swrite(WriteBuf, "   ") ;
            end if ;
          end if ;
          -- Only used for PT based SB - Index SB not used in the same way.
          if ArrayLengthVar > 1 and PrintIndexVar then
            write(WriteBuf, " (" & to_string(Index) & ")    ") ;
          end if ;
        end if ; 
        if ExpectedInFIFO then
          write(WriteBuf, "Received: " & actual_to_string(ActualData)) ;
          if FoundError then
            write(WriteBuf, "   Expected: " & expected_to_string(ExpectedPtr.all)) ;
          end if ;
        else
          write(WriteBuf, "Received: " & expected_to_string(ExpectedPtr.all)) ;
          if FoundError then
            write(WriteBuf, "   Expected: " & actual_to_string(ActualData)) ;
          end if ;
        end if ;
--x        if SbPtr(Index).PopListPtr.TagPtr.all /= "" then
        if SbPtr(Index).PopListPtr.TagPtr.all'length > 0 then
          write(WriteBuf, "   Tag: " & SbPtr(Index).PopListPtr.TagPtr.all) ;
        end if;
        write(WriteBuf, "   Item Number: " & to_string(CurrentItem)) ;
        
        AffirmIf(SbPtr(Index).AlertLogID, not FoundError, WriteBuf.all) ; 

        deallocate(WriteBuf) ;
      end if ;
    end procedure LocalCheck ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    procedure Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) is
      variable found : boolean ; 
    begin
      LocalPop(Index, Tag, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then 
        LocalCheck(Index, ActualData, found) ;
      end if ;
    end procedure Check ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    procedure Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant ActualData   : in  ActualType
    ) is
      variable found : boolean ; 
    begin
      LocalPop(Index, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then 
        LocalCheck(Index, ActualData, found) ;
      end if ;
    end procedure Check ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    impure function Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean is
      variable found : boolean ; 
    begin
      LocalPop(Index, Tag, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then 
        LocalCheck(Index, ActualData, found) ;
      end if ;
      return found ;
    end function Check ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    impure function Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant ActualData   : in  ActualType
    ) return boolean is
      variable found : boolean ; 
    begin
      LocalPop(Index, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then 
        LocalCheck(Index, ActualData, found) ;
      end if ;
      return found ;
    end function Check ;

    ------------------------------------------------------------
    -- Singleton only.  Index. Tag.
    impure function CheckExpected (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ExpectedData : in  ActualType
    ) return boolean is
      variable found : boolean ; 
    begin
      LocalPop(Index, Tag, "Check   Received: " & actual_to_string(ExpectedData), found) ;
      if found then 
        LocalCheck(Index, ExpectedData, found, ExpectedInFIFO => FALSE) ;
      end if ; 
      return found ;
    end function CheckExpected ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    procedure Pop (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) is
      variable found : boolean ; 
    begin
      LocalPop(Index, Tag, "Pop", found) ;
      if found then
        Item := SbPtr(Index).PopListPtr.ExpectedPtr.all ;
      end if ; 
    end procedure Pop ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    procedure Pop (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      variable Item   : out  ExpectedType
    ) is
      variable found : boolean ; 
    begin
      LocalPop(Index, "Pop", found) ;
      if found then
        Item := SbPtr(Index).PopListPtr.ExpectedPtr.all ;
      end if ; 
    end procedure Pop ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    impure function Pop (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string
    ) return ExpectedType is
      variable found : boolean ; 
    begin
      LocalPop(Index, Tag, "Pop", found) ;
      return SbPtr(Index).PopListPtr.ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    impure function Pop (Index : integer) return ExpectedType is
    ------------------------------------------------------------
      variable found : boolean ; 
    begin
      LocalPop(Index, "Pop", found) ;
      return SbPtr(Index).PopListPtr.ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Local Only similar to LocalPop
    -- Returns a pointer to the highest element matching Tag
    impure function LocalPeek (Index : integer ; Tag : string) return ListPtrType is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
--!! LocalPeek does this, but so do each of the indexed calls
--!!      if LocalOutOfRange(Index, "Peek") then
--!!        return NULL ; -- error reporting in LocalOutOfRange
--!!      end if ;
      if SbPtr(Index).HeadPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        Alert(SbPtr(Index).AlertLogID, GetName & " Empty during Peek", FAILURE) ;
        return NULL ;
      end if ;
      -- Descend to find Tag field and extract
      CurPtr := SbPtr(Index).HeadPtr ;
      if CurPtr.TagPtr.all = Tag then
        -- Non-tagged scoreboards find this one.
        return CurPtr ;
      else
        loop
          if CurPtr.NextPtr = NULL then
            SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
            Alert(SbPtr(Index).AlertLogID, GetName & " Peek, tag: " & Tag & " not found", FAILURE) ;
            -- return NULL ;
            exit ; 
          elsif CurPtr.NextPtr.TagPtr.all = Tag then
            -- return CurPtr.NextPtr ;
            exit ; 
          else
            CurPtr := CurPtr.NextPtr ;
          end if ;
        end loop ;
      end if ;
      return CurPtr.NextPtr ;
    end function LocalPeek ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    procedure Peek (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out ExpectedType
    ) is
      variable CurPtr : ListPtrType ;
    begin
      if LocalOutOfRange(Index, "Peek") then
        return ; -- error reporting in LocalOutOfRange
      end if ;
      CurPtr := LocalPeek(Index, Tag) ;
      if CurPtr /= NULL then
        Item := CurPtr.ExpectedPtr.all ;
      end if ;
    end procedure Peek ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    procedure Peek (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      variable Item   : out  ExpectedType
    ) is
      variable CurPtr : ListPtrType ;
    begin
      if LocalOutOfRange(Index, "Peek") then
        return ; -- error reporting in LocalOutOfRange
      end if ;
      CurPtr := LocalPeek(Index, "") ;
      if CurPtr /= NULL then
        Item := CurPtr.ExpectedPtr.all ;
      end if ;
    end procedure Peek ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    impure function Peek (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string
    ) return ExpectedType is
      variable CurPtr : ListPtrType ;
    begin
      if LocalOutOfRange(Index, "Peek") then
        -- error reporting in LocalOutOfRange
        return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ;
      CurPtr := LocalPeek(Index, Tag) ;
      if CurPtr /= NULL then
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ;
    end function Peek ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    impure function Peek (Index : integer) return ExpectedType is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      if LocalOutOfRange(Index, "Peek") then
        -- error reporting in LocalOutOfRange
        return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ;
      CurPtr := LocalPeek(Index, "") ;
      if CurPtr /= NULL then
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ;
    end function Peek ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    impure function Empty (Index  : integer; Tag : String) return boolean is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      CurPtr := SbPtr(Index).HeadPtr ;
      while CurPtr /= NULL loop
        if CurPtr.TagPtr.all = Tag then
          return FALSE ;   -- Found Tag
        end if ;
        CurPtr := CurPtr.NextPtr ;
      end loop ;
      return TRUE ;  -- Tag not found
    end function Empty ;

    ------------------------------------------------------------
    -- Scoreboards, no tag
    impure function Empty (Index  : integer) return boolean is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).HeadPtr = NULL ;
    end function Empty ;

    ------------------------------------------------------------
    impure function AllScoreboardsEmpty return boolean is
    -- All scoreboards in the singleton.  Not for PT
    ------------------------------------------------------------
      variable AllEmpty : boolean := FALSE ; 
    begin
      if CalledNewID then
        -- Is a singleton 
        for i in 1 to NumItems loop
          AllEmpty := Empty(i) ; 
          exit when not AllEmpty ; 
        end loop ;
        return AllEmpty ; 
      else
        -- singleton not initialized.  Return TRUE as all are indeed empty.
        alert(OSVVM_SCOREBOARD_ALERTLOG_ID, "AllScoreboardsEmpty: Scoreboard is either a PT or not initialized") ;
        return TRUE ; 
      end if ;
    end function AllScoreboardsEmpty ;

    ------------------------------------------------------------
    -- Find using Tag.
    procedure LocalFind (
    ------------------------------------------------------------
      variable FindPtr       : inout ListPtrType ;
      variable FindParentPtr : inout ListPtrType ;
      constant Index         : in    integer ;
      constant Tag           : in    string;
      constant ActualData    : in    ActualType ;
      constant Name          : in    String
    ) is
    begin
      if LocalOutOfRange(Index, Name) then
        FindPtr       := NULL ;
        FindParentPtr := NULL ; 
        return ; 
      end if ;
      FindParentPtr := NULL ; 
      FindPtr := SbPtr(Index).HeadPtr ;
      loop
        if FindPtr = NULL then
          -- Failed to find it
          exit ;

        elsif FindPtr.TagPtr.all = Tag and
          Match(ActualData, FindPtr.ExpectedPtr.all) then
          exit ; 

        else  -- Descend
          FindParentPtr := FindPtr ; 
          FindPtr := FindPtr.NextPtr ;
        end if ;
      end loop ;
    end procedure LocalFind ;
    
    ------------------------------------------------------------
    -- No Tag - search without using tag.
    procedure LocalFind (
    ------------------------------------------------------------
      variable FindPtr       : inout ListPtrType ;
      variable FindParentPtr : inout ListPtrType ;
      constant Index         : in    integer ;
      constant ActualData    : in    ActualType ;
      constant Name          : in    String
    ) is
    begin
      if LocalOutOfRange(Index, Name) then
        FindPtr       := NULL ;
        FindParentPtr := NULL ; 
        return ; 
      end if ;
      FindParentPtr := NULL ; 
      FindPtr := SbPtr(Index).HeadPtr ;
      loop
        if FindPtr = NULL then
          -- Failed to find it
--          SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
--          Alert(SbPtr(Index).AlertLogID,
--                GetName & " Did not find Actual Data: " & actual_to_string(ActualData),
--                ERROR ) ;
          exit ;

        elsif Match(ActualData, FindPtr.ExpectedPtr.all) then
          exit ; 

        else  -- Descend
          FindParentPtr := FindPtr ; 
          FindPtr := FindPtr.NextPtr ;
        end if ;
      end loop ;
    end procedure LocalFind ;
    
    ------------------------------------------------------------
    -- Tagged Scoreboards
    -- Find Element with Matching Tag and ActualData
    -- Returns integer'left if no match found
    impure function Find (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant Tag         :  in  string;
      constant ActualData  :  in  ActualType
    ) return integer is
      variable FindPtr       : ListPtrType ;
      variable FindParentPtr : ListPtrType ;
    begin
--!!        if LocalOutOfRange(Index, "Find") then
--!!          return integer'left ; -- error reporting in LocalOutOfRange
--!!        end if ;
--!!        CurPtr := SbPtr(Index).HeadPtr ;
--!!        loop
--!!          if CurPtr = NULL then
--!!            -- Failed to find it
--!!            SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
--!!            if Tag /= "" then
--!!              Alert(SbPtr(Index).AlertLogID,
--!!                    GetName & " Did not find Tag: " & Tag & " and Actual Data: " & actual_to_string(ActualData),
--!!                    ERROR ) ;
--!!            else
--!!              Alert(SbPtr(Index).AlertLogID,
--!!                    GetName & " Did not find Actual Data: " & actual_to_string(ActualData),
--!!                    ERROR ) ;
--!!            end if ;
--!!  --          return integer'left ;
--!!            LocalItemNumber := integer'left ;
--!!            exit ;
--!!  
--!!          elsif CurPtr.TagPtr.all = Tag and
--!!            Match(ActualData, CurPtr.ExpectedPtr.all) then
--!!            -- Found it.  Return Index.
--!!  --          return CurPtr.ItemNumber ;
--!!            LocalItemNumber := CurPtr.ItemNumber ;
--!!            exit ; 
--!!  
--!!          else  -- Descend
--!!            CurPtr := CurPtr.NextPtr ;
--!!          end if ;
--!!        end loop ;
--!!        return LocalItemNumber ; 
      LocalFind (FindPtr, FindParentPtr, Index, Tag, ActualData, "Find") ; 

      if FindPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        Alert(SbPtr(Index).AlertLogID, 
                  "Did not find Tag: " & Tag & " and Actual Data: " & actual_to_string(ActualData)) ; 
        return integer'low ; 
      else
        -- Found it somewhere else in the List
        return FindPtr.ItemNumber ; 
      end if ; 
    end function Find ;

    ------------------------------------------------------------
    -- Simple Scoreboards
    -- Find Element with Matching ActualData
    impure function Find (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant ActualData  :  in  ActualType
    ) return integer is
      variable FindPtr       : ListPtrType ;
      variable FindParentPtr : ListPtrType ;
    begin
--      return Find(Index, "", ActualData) ;
      LocalFind (FindPtr, FindParentPtr, Index, ActualData, "Find") ; 

      if FindPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        Alert(SbPtr(Index).AlertLogID, 
                  "Did not find Actual Data: " & actual_to_string(ActualData)) ; 
        return integer'low ; 
      else
        -- Found it somewhere else in the List
        return FindPtr.ItemNumber ; 
      end if ; 
    end function Find ;

    ------------------------------------------------------------
    -- Tagged Scoreboards
    -- Flush Remove elements with tag whose itemNumber is <= ItemNumber parameter
    procedure Flush (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant Tag         :  in  string ;
      constant ItemNumber  :  in  integer
    ) is
      variable CurPtr, RemovePtr, LastPtr : ListPtrType ;
    begin
      if LocalOutOfRange(Index, "Flush") then
        return ; -- error reporting in LocalOutOfRange
      end if ;
      CurPtr  := SbPtr(Index).HeadPtr ;
      LastPtr := NULL ;
      loop
        if CurPtr = NULL then
          -- Done
          return ;
        elsif CurPtr.TagPtr.all = Tag then
          if ItemNumber >= CurPtr.ItemNumber then
            -- remove it
            RemovePtr := CurPtr ;
            if CurPtr = SbPtr(Index).TailPtr then
              SbPtr(Index).TailPtr := LastPtr ;
            end if ;
            if CurPtr = SbPtr(Index).HeadPtr then
              SbPtr(Index).HeadPtr := CurPtr.NextPtr ;
            else -- if LastPtr /= NULL then
              LastPtr.NextPtr := LastPtr.NextPtr.NextPtr ;
            end if ;
            CurPtr := CurPtr.NextPtr ;
            -- LastPtr := LastPtr ; -- no change
            SbPtr(Index).DropCount := SbPtr(Index).DropCount + 1 ;
            deallocate(RemovePtr.TagPtr) ;
            deallocate(RemovePtr.ExpectedPtr) ;
            deallocate(RemovePtr) ;
          else
            -- Done
            return ;
          end if ;
        else
          -- Descend
          LastPtr := CurPtr ;
          CurPtr  := CurPtr.NextPtr ;
        end if ;
      end loop ;
    end procedure Flush ;

    ------------------------------------------------------------
    -- Simple Scoreboards
    -- Flush - Remove Elements upto and including the one with ItemNumber
    procedure Flush (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant ItemNumber  :  in  integer
    ) is
      variable CurPtr : ListPtrType ;
    begin
      if LocalOutOfRange(Index, "Find") then
        return ; -- error reporting in LocalOutOfRange
      end if ;
      CurPtr  := SbPtr(Index).HeadPtr ;
      loop
        if CurPtr = NULL then
          -- Done
          return ;
        elsif ItemNumber >= CurPtr.ItemNumber then
          -- Descend, Check Tail, Deallocate
          SbPtr(Index).HeadPtr := SbPtr(Index).HeadPtr.NextPtr ;
          if CurPtr = SbPtr(Index).TailPtr then
            SbPtr(Index).TailPtr := NULL ;
          end if ;
          SbPtr(Index).DropCount := SbPtr(Index).DropCount + 1 ;
          deallocate(CurPtr.TagPtr) ;
          deallocate(CurPtr.ExpectedPtr) ;
          deallocate(CurPtr) ;
          CurPtr := SbPtr(Index).HeadPtr ;
        else
          -- Done
          return ;
        end if ;
      end loop ;
    end procedure Flush ;
    
    ------------------------------------------------------------
    -- Tagged Scoreboards 
    -- Find Element with Matching Tag and ActualData and Delete it
    procedure FindAndDelete (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant Tag         :  in  string ;
      constant ActualData  :  in  ActualType
    ) is
      variable FindPtr       : ListPtrType ;
      variable FindParentPtr : ListPtrType ;
    begin
      LocalFind (FindPtr, FindParentPtr, Index, Tag, ActualData, "FindAndDelete") ; 

      if FindPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        AffirmIf( SbPtr(Index).AlertLogID, FALSE,
              "Received: " & actual_to_string(ActualData) & "   Tag: " & Tag & "  was not found." ) ;
      else
        AffirmIf( SbPtr(Index).AlertLogID, TRUE,
              "Received: " & actual_to_string(ActualData) & "   Tag: " & Tag & "   Item Number: " & to_string(FindPtr.ItemNumber) ) ;
        -- Update counts
        SbPtr(Index).PopCount   := SbPtr(Index).PopCount + 1 ;
        SbPtr(Index).CheckCount := SbPtr(Index).CheckCount + 1 ;
        -- Found it somewhere else in the List
        if FindParentPtr = NULL then
          -- Found at HeadPtr.  Adjust HeadPtr and TailPtr
          SbPtr(Index).HeadPtr := FindPtr.NextPtr ; 
          if FindPtr.NextPtr = NULL or SbPtr(Index).HeadPtr.NextPtr = NULL then
            -- Adjust tail pointer - for 0 or 1 item in FIFO
            SbPtr(Index).TailPtr := SbPtr(Index).HeadPtr ; 
          end if ; 
        else 
          -- Not found at HeadPtr.  Remove it from the list.
          FindParentPtr.NextPtr := FindPtr.NextPtr ; 
          if FindPtr.NextPtr = NULL then
            -- Adjust tail pointer
            SbPtr(Index).TailPtr := FindParentPtr ; 
          end if ; 
        end if ; 
        -- DeleteCell(FindPtr)
        deallocate(FindPtr.TagPtr) ;
        deallocate(FindPtr.ExpectedPtr) ;
        deallocate(FindPtr) ;
      end if ; 
    end procedure FindAndDelete ;
    
    ------------------------------------------------------------
    -- Scoreboard no tag
    -- Find Element with Matching Tag and ActualData
    -- Returns integer'left if no match found
    procedure FindAndDelete (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant ActualData  :  in  ActualType
    ) is
      variable FindPtr       : ListPtrType ;
      variable FindParentPtr : ListPtrType ;
    begin 
      LocalFind (FindPtr, FindParentPtr, Index, ActualData, "FindAndDelete") ; 

      if FindPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        AffirmIf( SbPtr(Index).AlertLogID, FALSE,
              "Received: " & actual_to_string(ActualData) & "  was not found." ) ;
      else
        AffirmIf( SbPtr(Index).AlertLogID, TRUE,
              "Received: " & actual_to_string(ActualData) & "   Item Number: " & to_string(FindPtr.ItemNumber)) ;
        -- Update counts
        SbPtr(Index).PopCount   := SbPtr(Index).PopCount + 1 ;
        SbPtr(Index).CheckCount := SbPtr(Index).CheckCount + 1 ;
        -- Remove it from the list
        if FindParentPtr = NULL then
          -- Found at HeadPtr.  Adjust HeadPtr and TailPtr
          SbPtr(Index).HeadPtr := FindPtr.NextPtr ; 
          if FindPtr.NextPtr = NULL or SbPtr(Index).HeadPtr.NextPtr = NULL then
            -- Adjust tail pointer - for 0 or 1 item in FIFO
            SbPtr(Index).TailPtr := SbPtr(Index).HeadPtr ; 
          end if ; 
        else 
          -- Not found at HeadPtr.  Remove it from the list.
          FindParentPtr.NextPtr := FindPtr.NextPtr ; 
          if FindPtr.NextPtr = NULL then
            -- Adjust tail pointer
            SbPtr(Index).TailPtr := FindParentPtr ; 
          end if ; 
        end if ; 
        -- DeleteCell(FindPtr)
        deallocate(FindPtr.TagPtr) ;
        deallocate(FindPtr.ExpectedPtr) ;
        deallocate(FindPtr) ;
      end if ; 
    end procedure FindAndDelete ;

    ------------------------------------------------------------
    -- Tagged Scoreboards 
    -- Find Element with Matching Tag and ActualData and Delete it
    procedure FindAndFlush (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant Tag         :  in  string ;
      constant ActualData  :  in  ActualType
    ) is
      variable FindPtr       : ListPtrType ;
      variable FindParentPtr : ListPtrType ;
    begin
      LocalFind (FindPtr, FindParentPtr, Index, Tag, ActualData, "FindAndFlush") ; 

      if FindPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        AffirmIf( SbPtr(Index).AlertLogID, FALSE,
              "Received: " & actual_to_string(ActualData) & "  with Tag: " & Tag & "  was not found." ) ;
      else
        AffirmIf( SbPtr(Index).AlertLogID, TRUE,
              "Flush up to Received: " & actual_to_string(ActualData) & "  with Tag: " & Tag ) ;
        Flush(Index, Tag, FindPtr.ItemNumber) ;
      end if ; 
    end procedure FindAndFlush ;
    
    ------------------------------------------------------------
    -- Scoreboard no tag
    -- Find Element with Matching Tag and ActualData
    -- Returns integer'left if no match found
    procedure FindAndFlush (
    ------------------------------------------------------------
      constant Index       :  in  integer ;
      constant ActualData  :  in  ActualType
    ) is
      variable FindPtr       : ListPtrType ;
      variable FindParentPtr : ListPtrType ;
    begin 
      LocalFind (FindPtr, FindParentPtr, Index, ActualData, "FindAndFlush") ; 

      if FindPtr = NULL then
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        AffirmIf( SbPtr(Index).AlertLogID, FALSE,
              "Received: " & actual_to_string(ActualData) & "  was not found." ) ;
      else
        AffirmIf( SbPtr(Index).AlertLogID, TRUE,
              "Flush up to Received: " & actual_to_string(ActualData)) ;
        Flush(Index, FindPtr.ItemNumber) ;
      end if ; 
    end procedure FindAndFlush ;

    ------------------------------------------------------------
    impure function GotScoreboards return boolean is
    ------------------------------------------------------------
    begin
      return CalledNewID ;
    end function GotScoreboards ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteScoreboardYaml (Index : integer; file CovYamlFile : text) is
    ------------------------------------------------------------
      variable buf       : line ;
      constant NAME_PREFIX : string := "  " ;
    begin
      write(buf, NAME_PREFIX & "- Name:         " & '"' & string'(GetAlertLogName(SbPtr(Index).AlertLogID)) & '"' & LF) ;
      write(buf, NAME_PREFIX & "  ParentName:   " & '"' & string'(GetAlertLogName(GetAlertLogParentID(SbPtr(Index).AlertLogID))) & '"' & LF) ;
      write(buf, NAME_PREFIX & "  ItemCount:    " & to_string(SbPtr(Index).ItemNumber)  & LF) ;
      write(buf, NAME_PREFIX & "  ErrorCount:   " & to_string(SbPtr(Index).ErrorCount)      & LF) ;
      write(buf, NAME_PREFIX & "  ItemsChecked: " & to_string(SbPtr(Index).CheckCount)  & LF) ;
      write(buf, NAME_PREFIX & "  ItemsPopped:  " & to_string(SbPtr(Index).PopCount)    & LF) ;
      write(buf, NAME_PREFIX & "  ItemsDropped: " & to_string(SbPtr(Index).DropCount)   & LF) ;
      write(buf, NAME_PREFIX & "  FifoCount: "    & to_string(GetFifoCount(Index))   ) ;
--      write(buf, NAME_PREFIX & "  ItemCount:    " & '"' & to_string(SbPtr(Index).ItemNumber)       & '"' & LF) ;
--      write(buf, NAME_PREFIX & "  ErrorCount:   " & '"' & to_string(SbPtr(Index).ErrorCount)           & '"' & LF) ;
--      write(buf, NAME_PREFIX & "  ItemsChecked: " & '"' & to_string(SbPtr(Index).CheckCount)       & '"' & LF) ;
--      write(buf, NAME_PREFIX & "  ItemsPopped:  " & '"' & to_string(SbPtr(Index).PopCount)         & '"' & LF) ;
--      write(buf, NAME_PREFIX & "  ItemsDropped: " & '"' & to_string(SbPtr(Index).DropCount)        & '"' & LF) ;
--      write(buf, NAME_PREFIX & "  FifoCount: "    & '"' & to_string(GetFifoCount(Index))        & '"' ) ;
      writeline(CovYamlFile, buf) ;
    end procedure WriteScoreboardYaml ;
    
    ------------------------------------------------------------
    procedure WriteScoreboardYaml (FileName : string; OpenKind : File_Open_Kind; FileNameIsBaseName : boolean) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := IfElse(FileName = "", OSVVM_RAW_OUTPUT_DIRECTORY & GetTestName & "_sb.yml", 
                                              IfElse(FileNameIsBaseName, OSVVM_RAW_OUTPUT_DIRECTORY & GetTestName & "_sb_" & FileName &".yml",FileName) ) ;
--x      file SbYamlFile : text open OpenKind is RESOLVED_FILE_NAME ;
      file SbYamlFile : text ;
      variable buf : line ;
    begin
      file_open(SbYamlFile, RESOLVED_FILE_NAME, OpenKind) ;
      if SbPtr = NULL or SbPtr'length <= 0 then
        Alert("Scoreboard.WriteScoreboardYaml: no scoreboards defined ", ERROR) ;
        return ;
      end if ;

      swrite(buf, "Version: ""1.1""" & LF) ;
      swrite(buf, "TestCase: " & '"' & GetTestName & '"' & LF) ;
      swrite(buf, "Scoreboards: ") ;
      writeline(SbYamlFile, buf) ;
      if CalledNewID then
        -- Used by singleton
        for i in 1 to NumItems loop
          WriteScoreboardYaml(i, SbYamlFile) ;
        end loop ;
      else
        -- Used by PT method, but not singleton
        for i in SbPtr'range loop
          WriteScoreboardYaml(i, SbYamlFile) ;
        end loop ;
      end if ;
      file_close(SbYamlFile) ;
    end procedure WriteScoreboardYaml ;
    
    ------------------------------------------------------------
    impure function GetAlertLogID(Index : Integer) return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).AlertLogID ;
    end function GetAlertLogID ;

    ------------------------------------------------------------
    impure function GetItemCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).ItemNumber ;
    end function GetItemCount ;

    ------------------------------------------------------------
    impure function GetPushCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).ItemNumber ;
    end function GetPushCount ;

    ------------------------------------------------------------
    impure function GetPopCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).PopCount ;
    end function GetPopCount ;

    ------------------------------------------------------------
    impure function GetFifoCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).ItemNumber - SbPtr(Index).PopCount - SbPtr(Index).DropCount ;
    end function GetFifoCount ;

    ------------------------------------------------------------
    impure function GetCheckCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).CheckCount ;
    end function GetCheckCount ;

    ------------------------------------------------------------
    impure function GetDropCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).DropCount ;
    end function GetDropCount ;
    
    ------------------------------------------------------------
    procedure Deallocate is
    ------------------------------------------------------------
      variable CurListPtr, LastListPtr : ListPtrType ;
    begin
      for Index in SbPtr'range loop
      -- Deallocate contents in the scoreboards
        CurListPtr  := SbPtr(Index).HeadPtr ;
        while CurListPtr /= Null loop
          deallocate(CurListPtr.TagPtr) ;
          deallocate(CurListPtr.ExpectedPtr) ;
          LastListPtr := CurListPtr ;
          CurListPtr := CurListPtr.NextPtr ;
          Deallocate(LastListPtr) ;
        end loop ;
      end loop ;

      for Index in SbPtr'range loop
      -- Deallocate PopListPtr - only has single element
        CurListPtr  := SbPtr(Index).PopListPtr ;
        if CurListPtr /= NULL then
          deallocate(CurListPtr.TagPtr) ;
          deallocate(CurListPtr.ExpectedPtr) ;
          deallocate(CurListPtr) ;
        end if ;
      end loop ;

      -- Deallocate Array Structure
      Deallocate(SbPtr) ;

      -- Deallocate NameVar - NamePType
      NameVar.Deallocate ;
      
      -- Set the state s.t. there is nothing in the SB
      MinIndex       := 0 ;
      MaxIndex       := 0 ;
      ArrayLengthVar := 0 ; 
      NumItems       := 0 ;
      CalledNewID    := FALSE ;
    end procedure Deallocate ;

    ------------------------------------------------------------
    -- Construct initial data structure
    procedure Initialize is
    ------------------------------------------------------------
    begin
      SetArrayIndex(1, 1) ;
    end procedure Initialize ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  -- Compatibility Methods - Allows ScoreboardGenericPkg to Work as a PT still
  --    Please use the singleton for new stuff - it is easier ...
  --    The PT is soft deprecated.   It will not get future enhancements that the Singleton does.
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  ------------------------------------------------------------

    ------------------------------------------------------------
    procedure SetArrayIndex(L, R : integer) is
    ------------------------------------------------------------
      variable OldSbPtr : ItemArrayPtrType ;
      variable Len, OldLen, AllOfOldSb : integer ;
    begin
      OldLen := ArrayLengthVar ;
      MinIndex := minimum(L, R) ;
      MaxIndex := maximum(L, R) ;
      AllOfOldSb := MinIndex + OldLen - 1 ;
      Len := MaxIndex - MinIndex + 1 ;
      ArrayLengthVar := Len ; 
      if Len >= OldLen then
        OldSbPtr := SbPtr ;
        SbPtr := new ItemArrayType'(MinIndex to MaxIndex => Template(DEFAULT_INDEX)) ;
        if OldSbPtr /= NULL then
          -- Copy OldHeadPtr number of items
          SbPtr(MinIndex to AllOfOldSb) := OldSbPtr.all ; 
          Deallocate(OldSbPtr) ;
        end if ;
      elsif Len < OldLen then
        report "ScoreboardGenericPkg: SetArrayIndex, new array Length <= current array length"
        severity failure ;
      end if ;
    end procedure SetArrayIndex ;

    ------------------------------------------------------------
    procedure SetArrayIndex(R : natural) is
    ------------------------------------------------------------
    begin
      SetArrayIndex(1, R) ;
    end procedure SetArrayIndex ;

    ------------------------------------------------------------
    impure function GetArrayIndex return integer_vector is
    ------------------------------------------------------------
    begin
      return (1 => SbPtr'left, 2 => SbPtr'right) ;
    end function GetArrayIndex ;

    ------------------------------------------------------------
    impure function GetArrayLength return natural is
    ------------------------------------------------------------
    begin
      return MaxIndex - MinIndex + 1 ;
    end function GetArrayLength ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Push (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) is
    begin
      LocalPush(MinIndex, Tag, Item) ;
    end procedure Push ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Push (Item   : in  ExpectedType) is
    ------------------------------------------------------------
    begin
      LocalPush(MinIndex, "", Item) ;
    end procedure Push ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Check (
    ------------------------------------------------------------
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) is
      variable found   : boolean ;
    begin
      LocalPop(MinIndex, Tag, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then
        LocalCheck(MinIndex, ActualData, found) ;
      end if ; 
    end procedure Check ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Check (ActualData : ActualType) is
    ------------------------------------------------------------
      variable found   : boolean ;
    begin
      LocalPop(MinIndex, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then
        LocalCheck(MinIndex, ActualData, found) ;
      end if ; 
    end procedure Check ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Check (
    ------------------------------------------------------------
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean is
      variable found   : boolean ;
    begin
      LocalPop(MinIndex, Tag, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then
        LocalCheck(MinIndex, ActualData, found) ;
      end if ; 
      return found ;
    end function Check ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Check (ActualData : ActualType) return boolean is
    ------------------------------------------------------------
      variable found   : boolean ;
    begin
      LocalPop(MinIndex, "Check   Received: " & actual_to_string(ActualData), found) ;
      if found then
        LocalCheck(MinIndex, ActualData, found) ;
      end if ; 
      return found ;
    end function Check ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Pop (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) is
      variable found : boolean ; 
    begin
      LocalPop(MinIndex, Tag, "Pop", found) ;
      if found then
        Item := SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ; 
    end procedure Pop ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Pop (variable Item : out  ExpectedType) is
    ------------------------------------------------------------
      variable found : boolean ; 
    begin
      LocalPop(MinIndex, "Pop", found) ;
      if found then
        Item := SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ; 
    end procedure Pop ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Pop (
    ------------------------------------------------------------
      constant Tag : in  string
    ) return ExpectedType is
      variable found : boolean ; 
    begin
      LocalPop(MinIndex, Tag, "Pop", found) ;
      return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Pop return ExpectedType is
    ------------------------------------------------------------
      variable found : boolean ; 
    begin
      LocalPop(MinIndex, "Pop", found) ;
      return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Peek (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) is
      variable CurPtr : ListPtrType ;
    begin
      CurPtr := LocalPeek(MinIndex, Tag) ;
      if CurPtr /= NULL then
        Item := CurPtr.ExpectedPtr.all ;
      end if ;
    end procedure Peek ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Peek (variable Item : out  ExpectedType) is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      CurPtr := LocalPeek(MinIndex, "") ;
      if CurPtr /= NULL then
        Item := CurPtr.ExpectedPtr.all ;
      end if ;
    end procedure Peek ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Peek (
    ------------------------------------------------------------
      constant Tag : in  string
    ) return ExpectedType is
      variable CurPtr : ListPtrType ;
    begin
      CurPtr := LocalPeek(MinIndex, Tag) ;
      if CurPtr /= NULL then
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ;
    end function Peek ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Peek return ExpectedType is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      CurPtr := LocalPeek(MinIndex, "") ;
      if CurPtr /= NULL then
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return SbPtr(MinIndex).PopListPtr.ExpectedPtr.all ;
      end if ;
    end function Peek ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Empty (Tag : String) return boolean is
    ------------------------------------------------------------
      variable CurPtr : ListPtrType ;
    begin
      return Empty(MinIndex, Tag) ;
    end function Empty ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Empty return boolean is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).HeadPtr = NULL ;
    end function Empty ;

    ------------------------------------------------------------
    -- Tagged Scoreboard
    -- Find Element with Matching ActualData
    impure function Find (
    ------------------------------------------------------------
      constant Tag         :  in  string;
      constant ActualData  :  in  ActualType
    ) return integer is
    begin
      return Find(MinIndex, Tag, ActualData) ;
    end function Find ;

    ------------------------------------------------------------
    -- Simple Scoreboard
    -- Find Element with Matching ActualData
    impure function Find (
    ------------------------------------------------------------
      constant ActualData  :  in  ActualType
    ) return integer is
    begin
      return Find(MinIndex, "", ActualData) ;
    end function Find ;

    ------------------------------------------------------------
    -- Tagged Scoreboard
    -- Flush Remove elements with tag whose itemNumber is <= ItemNumber parameter
    procedure Flush (
    ------------------------------------------------------------
      constant Tag         :  in  string ;
      constant ItemNumber  :  in  integer
    ) is
    begin
      Flush(MinIndex, Tag, ItemNumber) ;
    end procedure Flush ;

    ------------------------------------------------------------
    -- Simple Scoreboard
    -- Flush - Remove Elements upto and including the one with ItemNumber
    procedure Flush (
    ------------------------------------------------------------
      constant ItemNumber  :  in  integer
    ) is
    begin
      Flush(MinIndex, ItemNumber) ;
    end procedure Flush ;
    
    ------------------------------------------------------------
    procedure SetAlertLogID (Index : Integer ; A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      SbPtr(Index).AlertLogID := A ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID (A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      SbPtr(MinIndex).AlertLogID := A ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(Index : Integer; Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) is
    ------------------------------------------------------------
      variable ReportMode : AlertLogReportModeType ;
    begin
      ReportMode := ENABLED when not DoNotReport else DISABLED ;
      SbPtr(Index).AlertLogID := NewID(Name, ParentID, ReportMode => ReportMode, PrintParent => PRINT_NAME, CreateHierarchy => CreateHierarchy) ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) is
    ------------------------------------------------------------
      variable ReportMode : AlertLogReportModeType ;
    begin
      ReportMode := ENABLED when not DoNotReport else DISABLED ;
      SbPtr(MinIndex).AlertLogID := NewID(Name, ParentID, ReportMode => ReportMode, PrintParent => PRINT_NAME, CreateHierarchy => CreateHierarchy) ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    impure function GetAlertLogID return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).AlertLogID ;
    end function GetAlertLogID ;

    ------------------------------------------------------------
    impure function GetItemCount return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).ItemNumber ;
    end function GetItemCount ;

    ------------------------------------------------------------
    impure function GetPushCount return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).ItemNumber ;
    end function GetPushCount ;

    ------------------------------------------------------------
    impure function GetPopCount return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).PopCount ;
    end function GetPopCount ;

    ------------------------------------------------------------
    impure function GetFifoCount return integer is
    ------------------------------------------------------------
    begin
      return GetFifoCount(MinIndex) ;
    end function GetFifoCount ;

    ------------------------------------------------------------
    impure function GetCheckCount return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).CheckCount ;
    end function GetCheckCount ;

    ------------------------------------------------------------
    impure function GetDropCount return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(MinIndex).DropCount ;
    end function GetDropCount ;

    ------------------------------------------------------------
    procedure SetName (Name : String) is
    ------------------------------------------------------------
    begin
      NameVar.Set(Name) ;
    end procedure SetName ;

    ------------------------------------------------------------
    impure function SetName (Name : String) return string is
    ------------------------------------------------------------
    begin
      NameVar.Set(Name) ;
      return Name ;
    end function SetName ;

    ------------------------------------------------------------
    impure function GetName (DefaultName : string := "Scoreboard") return string is
    ------------------------------------------------------------
    begin
      return NameVar.Get(DefaultName) ;
    end function GetName ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  -- Deprecated.  Supported only for backward compatibility. 
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  ------------------------------------------------------------
    ------------------------------------------------------------
    procedure CheckFinish (
    ------------------------------------------------------------
      Index              : integer ;
      FinishCheckCount   : integer ;
      FinishEmpty        : boolean
    ) is
      variable EmptyError : Boolean ;
      variable WriteBuf : line ;
    begin
      if SbPtr(Index).AlertLogID = OSVVM_SCOREBOARD_ALERTLOG_ID  then
--x        write(WriteBuf, GetName(DefaultName => "Scoreboard")) ;
        write(WriteBuf, NameVar.Get("Scoreboard")) ;
      else
--x        write(WriteBuf, GetName(DefaultName => "")) ;
        write(WriteBuf, NameVar.Get("")) ; 
      end if ;
      if ArrayLengthVar > 1 then
--x        if WriteBuf.all /= "" then
        if WriteBuf.all'length > 0 then
          swrite(WriteBuf, " ") ;
        end if ;
        write(WriteBuf, "Index(" & to_string(Index) & "),  ") ;
      else
--x        if WriteBuf.all /= "" then
        if WriteBuf.all'length > 0 then
          swrite(WriteBuf, ",  ") ;
        end if ;
      end if ;
      if FinishEmpty then
        AffirmIf(SbPtr(Index).AlertLogID, Empty(Index), WriteBuf.all & "Checking Empty: " & to_string(Empty(Index)) &
                 "  FinishEmpty: " & to_string(FinishEmpty)) ;
        if not Empty(Index) then
          -- Increment internal count on FinishEmpty Error
          SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
        end if ;
      end if ;
      AffirmIf(SbPtr(Index).AlertLogID, SbPtr(Index).CheckCount >= FinishCheckCount, WriteBuf.all &
                 "Checking CheckCount: " & to_string(SbPtr(Index).CheckCount) &
                 " >= Expected: " & to_string(FinishCheckCount))  ;
      if not (SbPtr(Index).CheckCount >= FinishCheckCount) then
        -- Increment internal count on FinishCheckCount Error
        SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
      end if ;
      deallocate(WriteBuf) ;
    end procedure CheckFinish ;

    ------------------------------------------------------------
    procedure CheckFinish (
    ------------------------------------------------------------
      FinishCheckCount   : integer ;
      FinishEmpty        : boolean
    ) is
    begin
      for Index in SbPtr'range loop
        CheckFinish(Index, FinishCheckCount, FinishEmpty) ;
      end loop ;
    end procedure CheckFinish ;

    ------------------------------------------------------------
    impure function GetErrorCount (Index : integer)  return integer is
    ------------------------------------------------------------
    begin
      return SbPtr(Index).ErrorCount ;
    end function GetErrorCount ;

    ------------------------------------------------------------
    impure function GetErrorCount return integer is
    ------------------------------------------------------------
      variable TotalErrorCount : integer := 0 ;
    begin
      for Index in SbPtr'range loop
        TotalErrorCount := TotalErrorCount + GetErrorCount(Index) ;
      end loop ;
      return TotalErrorCount ;
    end function GetErrorCount ;

    ------------------------------------------------------------
    procedure IncErrorCount (Index  : integer) is
    ------------------------------------------------------------
    begin
      SbPtr(Index).ErrorCount := SbPtr(Index).ErrorCount + 1 ;
      IncAlertCount(SbPtr(Index).AlertLogID, ERROR) ;
    end IncErrorCount ;

    ------------------------------------------------------------
    procedure IncErrorCount is
    ------------------------------------------------------------
    begin
      SbPtr(MinIndex).ErrorCount := SbPtr(MinIndex).ErrorCount + 1 ;
      IncAlertCount(SbPtr(MinIndex).AlertLogID, ERROR) ;
    end IncErrorCount ;

    ------------------------------------------------------------
    procedure SetErrorCountZero (Index  : integer) is
    ------------------------------------------------------------
    begin
      SbPtr(Index).ErrorCount := 0;
    end procedure SetErrorCountZero ;

    ------------------------------------------------------------
    procedure SetErrorCountZero is
    ------------------------------------------------------------
    begin
      SbPtr(MinIndex).ErrorCount := 0 ;
    end procedure SetErrorCountZero ;

    ------------------------------------------------------------
    procedure SetCheckCountZero (Index  : integer) is
    ------------------------------------------------------------
    begin
      SbPtr(Index).CheckCount := 0;
    end procedure SetCheckCountZero ;

    ------------------------------------------------------------
    procedure SetCheckCountZero is
    ------------------------------------------------------------
    begin
      SbPtr(MinIndex).CheckCount := 0;
    end procedure SetCheckCountZero ;


    ------------------------------------------------------------
    procedure SetReportMode (ReportModeIn : ScoreboardReportType) is
    ------------------------------------------------------------
      variable SignaledAlert : boolean := FALSE ;
      variable AlertLogID : AlertLogIDType ;

    begin
      -- ReportModeVar := ReportModeIn ;
      for i in SbPtr'range loop
        AlertLogID := GetAlertLogID(i) ;
        if not SignaledAlert then 
          SignaledAlert := TRUE ; 
          if AlertLogID = OSVVM_ALERTLOG_ID then 
            Alert(AlertLogID, "ScoreboardPkg.SetReportMode.  ID = OSVVM_ALERTLOG_ID impacts AlertLog settings beyond just scoreboards.  Use ScoreboardPkg.SetAlertLogID to set a unique id", WARNING) ;
          end if ; 
        end if ; 
        case ReportModeIn is 
          when REPORT_ALL => 
            SetLogEnable(AlertLogID, PASSED, TRUE) ;
            SetAlertPrintCount(AlertLogID, ERROR,  integer'high) ; 

          when REPORT_ERROR =>
            SetLogEnable(AlertLogID, PASSED, FALSE) ;
            SetAlertPrintCount(AlertLogID, ERROR,  integer'high) ; 
            
          when REPORT_NONE =>
            SetLogEnable(AlertLogID, PASSED, FALSE) ;
            SetAlertPrintCount(AlertLogID, ERROR,  0) ; 

        end case ; 
      end loop ; 
    end procedure SetReportMode ;

    ------------------------------------------------------------
    impure function GetReportMode return ScoreboardReportType is
    ------------------------------------------------------------
    variable LogEnable  : boolean ; 
    variable PrintCount : integer ; 
    variable AlertLogID : AlertLogIDType ;
    variable ReportMode : ScoreboardReportType ;
    begin
      AlertLogID := SbPtr(MinIndex).AlertLogID ;
      LogEnable  := GetLogEnable(AlertLogID, PASSED) ; 
      PrintCount := GetAlertPrintCount(AlertLogID, ERROR) ; 
      if LogEnable and PrintCount = integer'high then 
        return REPORT_ALL ;
      elsif not LogEnable and PrintCount = integer'high then 
        return REPORT_ERROR ; 
      elsif not LogEnable and PrintCount = 0 then
        return REPORT_NONE ; 
      else
        Alert(AlertLogID, "ScoreboardPkg.GetReportMode, Values inconsistent with ScoreboardReportType" & 
              ".  LogEnable = "  & to_string(LogEnable) & 
              ".  PrintCount = " & to_string(PrintCount), FAILURE) ;
        return REPORT_NONE ;  -- value is not correct.  Note FAILURE above
      end if ; 
    end function GetReportMode ; 
    
    ------------------------------------------------------------
    -- Deprecated.  Maintained for backward compatibility.
    -- Use TranscriptPkg.TranscriptOpen
    procedure FileOpen (FileName : string; OpenKind : File_Open_Kind ) is
    ------------------------------------------------------------
    begin
      -- WriteFileInit := TRUE ;
      -- file_open( WriteFile , FileName , OpenKind );
      TranscriptOpen(FileName, OpenKind) ;
    end procedure FileOpen ;


    ------------------------------------------------------------
    -- Deprecated.  Maintained for backward compatibility.
    procedure PutExpectedData (ExpectedData : ExpectedType) is
    ------------------------------------------------------------
    begin
      Push(ExpectedData) ;
    end procedure PutExpectedData ;

    ------------------------------------------------------------
    -- Deprecated.  Maintained for backward compatibility.
    procedure CheckActualData (ActualData : ActualType) is
    ------------------------------------------------------------
    begin
      Check(ActualData) ;
    end procedure CheckActualData ;

    ------------------------------------------------------------
    -- Deprecated.  Maintained for backward compatibility.
    impure function GetItemNumber return integer is
    ------------------------------------------------------------
    begin
      return GetItemCount(MinIndex) ;
    end GetItemNumber ;

    ------------------------------------------------------------
    -- Deprecated.  Maintained for backward compatibility.
    procedure SetMessage (MessageIn : String) is
    ------------------------------------------------------------
    begin
      -- deallocate(Message) ;
      -- Message := new string'(MessageIn) ;
      SetName(MessageIn) ;
    end procedure SetMessage ;

    ------------------------------------------------------------
    -- Deprecated.  Maintained for backward compatibility.
    impure function GetMessage return string is
    ------------------------------------------------------------
    begin
      -- return Message.all ;
      return GetName("Scoreboard") ;
    end function GetMessage ;

    ------------------------------------------------------------
    procedure SetFinish ( -- Replaced by CheckFinish
    ------------------------------------------------------------
      Index       : integer ;
      FCheckCount : integer ;
      FEmpty      : boolean := TRUE;
      FStatus     : boolean := TRUE
    ) is
    begin
      Alert(SbPtr(Index).AlertLogID, "OSVVM.ScoreboardGenericPkg.SetFinish: Deprecated and removed.  See CheckFinish", ERROR) ;
    end procedure SetFinish ;

    ------------------------------------------------------------
    procedure SetFinish ( -- Replaced by CheckFinish
    ------------------------------------------------------------
      FCheckCount : integer ;
      FEmpty      : boolean := TRUE;
      FStatus     : boolean := TRUE
    ) is
    begin
      SetFinish(MinIndex, FCheckCount, FEmpty, FStatus) ;
    end procedure SetFinish ;
  end protected body ScoreBoardPType ;
  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ScoreBoardPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ScoreBoardPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- Singleton Data Structure
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  shared variable ScoreboardStore : ScoreBoardPType ;


  ------------------------------------------------------------
  -- Used by Scoreboard Store
  impure function NewID (
    Name          : String ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDType is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.NewID(Name, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Vector: 1 to Size
  impure function NewID (
    Name          : String ;
    Size          : positive ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDArrayType is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.NewID(Name, Size, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Vector: X(X'Left) to X(X'Right)
  impure function NewID (
    Name          : String ;
    X             : integer_vector ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDArrayType is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.NewID(Name, X, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Matrix: 1 to X, 1 to Y
  impure function NewID (
    Name          : String ;
    X, Y          : positive ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.NewID(Name, X, Y, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
  impure function NewID (
    Name          : String ;
    X, Y          : integer_vector ;
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ;
    Search        : NameSearchType          := PRIVATE_NAME ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.NewID(Name, X, Y, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  impure function IsInitialized (ID : ScoreboardIDType) return boolean is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.IsInitialized(ID) ; 
  end function IsInitialized ; 

  ------------------------------------------------------------
  -- Push items into the scoreboard/FIFO

  ------------------------------------------------------------
  -- Simple Scoreboard, no tag
  procedure Push (
  ------------------------------------------------------------
    constant ID     : in  ScoreboardIDType ;
    constant Item   : in  ExpectedType
  ) is
  begin
    ScoreboardStore.Push(ID.ID, Item) ;
  end procedure Push ;

  -- Simple Tagged Scoreboard
  procedure Push (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    constant Item   : in  ExpectedType
  ) is
  begin
    ScoreboardStore.Push(ID.ID, Tag, Item) ;
  end procedure Push ;
  
  ------------------------------------------------------------
  -- Push as a function
  -- Simple Scoreboard, no tag
  impure function Push (
  ------------------------------------------------------------
    constant ID     : in  ScoreboardIDType ;
    constant Item   : in  ExpectedType
  ) return ExpectedType is
  begin
    ScoreboardStore.Push(ID.ID, Item) ;
    return Item ;
  end function Push ;

  -- Simple Tagged Scoreboard
  impure function Push (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    constant Item   : in  ExpectedType
  ) return ExpectedType is
  begin
    ScoreboardStore.Push(ID.ID, Tag, Item) ;
    return Item ;
  end function Push ;

  ------------------------------------------------------------
  -- Check received item with item in the scoreboard/FIFO
  -- Simple Scoreboard, no tag
  procedure Check (
    constant ID           : in  ScoreboardIDType ;
    constant ActualData   : in ActualType
  ) is
  begin
    ScoreboardStore.Check(ID.ID, ActualData) ;
  end procedure Check ;

  -- Simple Tagged Scoreboard
  procedure Check (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ActualData   : in  ActualType
  ) is
  begin
    ScoreboardStore.Check(ID.ID, Tag, ActualData) ;
  end procedure Check ;

  -- Simple Scoreboard, no tag
  impure function Check (
    constant ID           : in  ScoreboardIDType ;
    constant ActualData   : in ActualType
  ) return boolean is
  begin
    return ScoreboardStore.Check(ID.ID, ActualData) ;
  end function Check ;

  -- Simple Tagged Scoreboard
  impure function Check (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ActualData   : in  ActualType
  ) return boolean is
  begin
    return ScoreboardStore.Check(ID.ID, Tag, ActualData) ;
  end function Check ;

  -------------
  ----------------------------------------------
  -- Simple Scoreboard, no tag
  procedure CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant ExpectedData : in  ActualType
  ) is
    variable Passed : boolean ;
  begin
    Passed := ScoreboardStore.CheckExpected(ID.ID, "", ExpectedData) ;
  end procedure CheckExpected ;

  -- Simple Tagged Scoreboard
  procedure CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ExpectedData : in  ActualType
  ) is
    variable Passed : boolean ;
  begin
    Passed := ScoreboardStore.CheckExpected(ID.ID, Tag, ExpectedData) ;
  end procedure CheckExpected ;

  -- Simple Scoreboard, no tag
  impure function CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant ExpectedData : in  ActualType
  ) return boolean is
  begin
    return ScoreboardStore.CheckExpected(ID.ID, "", ExpectedData) ;
  end function CheckExpected ;

  -- Simple Tagged Scoreboard
  impure function CheckExpected (
    constant ID           : in  ScoreboardIDType ;
    constant Tag          : in  string ;
    constant ExpectedData : in  ActualType
  ) return boolean is
  begin
    return ScoreboardStore.CheckExpected(ID.ID, Tag, ExpectedData) ;
  end function CheckExpected ;

  ------------------------------------------------------------
  -- Pop the top item (FIFO) from the scoreboard/FIFO
  -- Simple Scoreboard, no tag
  procedure Pop (
    constant ID     : in  ScoreboardIDType ;
    variable Item   : out  ExpectedType
  ) is
  begin
    ScoreboardStore.Pop(ID.ID, Item) ;
  end procedure Pop ;

  -- Simple Tagged Scoreboard
  procedure Pop (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    variable Item   : out  ExpectedType
  ) is
  begin
    ScoreboardStore.Pop(ID.ID, Tag, Item) ;
  end procedure Pop ;

  ------------------------------------------------------------
  -- Pop as a function
  -- Simple Scoreboard, no tag
  impure function Pop (
    constant ID     : in  ScoreboardIDType
  ) return ExpectedType is
  begin
    return ScoreboardStore.Pop(ID.ID) ;
  end function Pop ;

  -- Simple Tagged Scoreboard
  impure function Pop (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string
  ) return ExpectedType is
  begin
    return ScoreboardStore.Pop(ID.ID, Tag) ;
  end function Pop ;

  ------------------------------------------------------------
  -- Peek at the top item (FIFO) from the scoreboard/FIFO
  -- Simple Tagged Scoreboard
  procedure Peek (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string ;
    variable Item   : out ExpectedType
  ) is
  begin
    ScoreboardStore.Peek(ID.ID, Tag, Item) ;
  end procedure Peek ;

  -- Simple Scoreboard, no tag
  procedure Peek (
    constant ID     : in  ScoreboardIDType ;
    variable Item   : out  ExpectedType
  ) is
  begin
    ScoreboardStore.Peek(ID.ID, Item) ;
  end procedure Peek ;

  ------------------------------------------------------------
  -- Peek as a function
  -- Tagged Scoreboards
  impure function Peek (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string
  ) return ExpectedType is
  begin
    return ScoreboardStore.Peek(Index => ID.ID, Tag => Tag) ;
  end function Peek ;

  -- Simple Scoreboard
  impure function Peek (
    constant ID     : in  ScoreboardIDType
  ) return ExpectedType is
  begin
    return ScoreboardStore.Peek(Index => ID.ID) ;
  end function Peek ;

  ------------------------------------------------------------
  -- ScoreboardEmpty - check to see if scoreboard is empty
  -- Simple
  impure function IsEmpty (
    constant ID     : in  ScoreboardIDType
  ) return boolean is
  begin
    return ScoreboardStore.Empty(ID.ID) ;
  end function IsEmpty ;

  -- Tagged
  impure function IsEmpty (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string
  ) return boolean is
  begin
    return ScoreboardStore.Empty(ID.ID, Tag) ;
  end function IsEmpty ;
  
  -- All scoreboards in the singleton
  impure function AllScoreboardsEmpty return boolean is
  begin
    return ScoreboardStore.AllScoreboardsEmpty ;
  end function AllScoreboardsEmpty ; 

  impure function GetAlertLogID (
    constant ID     : in  ScoreboardIDType
  ) return AlertLogIDType is
  begin
    return ScoreboardStore.GetAlertLogID(ID.ID) ;
  end function GetAlertLogID ;


  ------------------------------------------------------------
  -- Scoreboard Introspection

  -- Number of items put into scoreboard
  impure function GetItemCount (
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return ScoreboardStore.GetItemCount(ID.ID) ;
  end function GetItemCount ;

  impure function GetPushCount (
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return ScoreboardStore.GetPushCount(ID.ID) ;
  end function GetPushCount ;

  -- Number of items removed from scoreboard by pop or check
  impure function GetPopCount (
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return ScoreboardStore.GetPopCount(ID.ID) ;
  end function GetPopCount ;

  -- Number of items currently in the scoreboard (= PushCount - PopCount - DropCount)
  impure function GetFifoCount (
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return ScoreboardStore.GetFifoCount(ID.ID) ;
  end function GetFifoCount ;

  -- Number of items checked by scoreboard
  impure function GetCheckCount (
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return ScoreboardStore.GetCheckCount(ID.ID) ;
  end function GetCheckCount ;

  -- Number of items dropped by scoreboard.  See Find/Flush
  impure function GetDropCount (
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return ScoreboardStore.GetDropCount(ID.ID) ;
  end function GetDropCount ;

  ------------------------------------------------------------
  -- Find - Returns the ItemNumber for a value and tag (if applicable) in a scoreboard.
  -- Find returns integer'left if no match found
  -- Also See Flush.  Flush will drop items up through the ItemNumber

  -- Simple Scoreboard
  impure function Find (
    constant ID          : in  ScoreboardIDType ;
    constant ActualData  : in  ActualType
  ) return integer is
  begin
    return ScoreboardStore.Find(ID.ID, ActualData) ;
  end function Find ;

  -- Tagged Scoreboard
  impure function Find (
    constant ID          : in  ScoreboardIDType ;
    constant Tag         : in  string;
    constant ActualData  : in  ActualType
  ) return integer is
  begin
    return ScoreboardStore.Find(ID.ID, Tag, ActualData) ;
  end function Find ;

  ------------------------------------------------------------
  -- Flush - Remove elements in the scoreboard upto and including the one with ItemNumber
  -- See Find to identify an ItemNumber of a particular value and tag (if applicable)

  -- Simple Scoreboards
  procedure Flush (
    constant ID          :  in  ScoreboardIDType ;
    constant ItemNumber  :  in  integer
  ) is
  begin
    ScoreboardStore.Flush(ID.ID, ItemNumber) ;
  end procedure Flush ;


  -- Tagged Scoreboards - only removes items that also match the tag
  procedure Flush (
    constant ID          :  in  ScoreboardIDType ;
    constant Tag         :  in  string ;
    constant ItemNumber  :  in  integer
  ) is
  begin
    ScoreboardStore.Flush(ID.ID, Tag, ItemNumber) ;
  end procedure Flush ;

    ------------------------------------------------------------
    -- Tagged Scoreboards 
    procedure FindAndDelete (
    ------------------------------------------------------------
      constant ID          :  in  ScoreboardIDType ;
      constant Tag         :  in  string ;
      constant ActualData  :  in  ActualType
    ) is
  begin
    ScoreboardStore.FindAndDelete(ID.ID, Tag, ActualData) ;
  end procedure FindAndDelete ;
    
    ------------------------------------------------------------
    -- Scoreboard no tag
    procedure FindAndDelete (
    ------------------------------------------------------------
      constant ID          :  in  ScoreboardIDType ;
      constant ActualData  :  in  ActualType
    ) is
  begin
    ScoreboardStore.FindAndDelete(ID.ID, ActualData) ;
  end procedure FindAndDelete ;

    ------------------------------------------------------------
    -- Tagged Scoreboards 
    procedure FindAndFlush (
    ------------------------------------------------------------
      constant ID          :  in  ScoreboardIDType ;
      constant Tag         :  in  string ;
      constant ActualData  :  in  ActualType
    ) is
  begin
    ScoreboardStore.FindAndFlush(ID.ID, Tag, ActualData) ;
  end procedure FindAndFlush ;
    
    ------------------------------------------------------------
    -- Scoreboard no tag
    procedure FindAndFlush (
    ------------------------------------------------------------
      constant ID          :  in  ScoreboardIDType ;
      constant ActualData  :  in  ActualType
    ) is
  begin
    ScoreboardStore.FindAndFlush(ID.ID, ActualData) ;
  end procedure FindAndFlush ;

  ------------------------------------------------------------
  -- Scoreboard YAML Reports
  impure function GotScoreboards return boolean is
  begin
    return ScoreboardStore.GotScoreboards ;
  end function GotScoreboards ;

  ------------------------------------------------------------
  procedure WriteScoreboardYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE; FileNameIsBaseName : boolean := SCOREBOARD_YAML_IS_BASE_FILE_NAME) is
  begin
    ScoreboardStore.WriteScoreboardYaml(FileName, OpenKind, FileNameIsBaseName) ;
  end procedure WriteScoreboardYaml ;

  ------------------------------------------------------------
  -- Generally these are not required.  When a simulation ends and
  -- another simulation is started, a simulator will release all allocated items.
  procedure Deallocate (
    constant ID     : in  ScoreboardIDType
  ) is
  begin
    ScoreboardStore.Deallocate ;
  end procedure Deallocate ;

  procedure Initialize (
    constant ID     : in  ScoreboardIDType
  ) is
  begin
    ScoreboardStore.Initialize ;
  end procedure Initialize ;

  ------------------------------------------------------------
  -- Get error count
  -- Deprecated, replaced by usage of Alerts
  -- AlertFLow:      Instead use AlertLogPkg.ReportAlerts or AlertLogPkg.GetAlertCount
  -- Not AlertFlow:  use GetErrorCount to get total error count

  -- Scoreboards, with or without tag
  impure function GetErrorCount(
    constant ID     : in  ScoreboardIDType
  ) return integer is
  begin
    return GetAlertCount(ScoreboardStore.GetAlertLogID(ID.ID)) ;
  end function GetErrorCount ;


  ------------------------------------------------------------
  procedure CheckFinish (
  ------------------------------------------------------------
    ID                 : ScoreboardIDType ;
    FinishCheckCount   : integer ;
    FinishEmpty        : boolean
  ) is
  begin
    ScoreboardStore.CheckFinish(ID.ID, FinishCheckCount, FinishEmpty) ;
  end procedure CheckFinish ;


  ------------------------------------------------------------
  -- SetReportMode
  --   Translates ScoreboardReportType into calls to SetLogEnable and SetAlertPrintCount
  --   Recommendation, you may use those settings directly instead, but 
  --   if you do, do not use GetReportMode.
  --   
  procedure SetReportMode (
    constant ID           : in  ScoreboardIDType ;
    constant ReportModeIn : in  ScoreboardReportType
  ) is
    variable AlertLogID : AlertLogIDType ;
  begin
    AlertLogID := ScoreboardStore.GetAlertLogID(ID.ID) ;
    case ReportModeIn is 
      when REPORT_ALL => 
        SetLogEnable(AlertLogID, PASSED, TRUE) ;
        SetAlertPrintCount(AlertLogID, ERROR,  integer'high) ; 
        
      when REPORT_ERROR =>
        SetLogEnable(AlertLogID, PASSED, FALSE) ;
        SetAlertPrintCount(AlertLogID, ERROR,  integer'high) ; 
        
      when REPORT_NONE =>
        SetLogEnable(AlertLogID, PASSED, FALSE) ;
        SetAlertPrintCount(AlertLogID, ERROR,  0) ; 

    end case ; 
  end procedure SetReportMode ;

  ------------------------------------------------------------
  -- GetReportMode
  --   A FAILURE is generated if PrintCount is other than 0 or integer'high
  --   Take care if SetAlertPrintCount is called for this ID or all IDs
  --   after the call to SetReportMode.
  --
  impure function GetReportMode (
    constant ID           : in  ScoreboardIDType
  ) return ScoreboardReportType is
    variable LogEnable  : boolean ; 
    variable PrintCount : integer ; 
    variable AlertLogID : AlertLogIDType ;
    variable ReportMode : ScoreboardReportType ;
  begin
    AlertLogID := ScoreboardStore.GetAlertLogID(ID.ID) ;
    LogEnable  := GetLogEnable(AlertLogID, PASSED) ; 
    PrintCount := GetAlertPrintCount(AlertLogID, ERROR) ; 
    if LogEnable and PrintCount = integer'high then 
      return REPORT_ALL ;
    elsif not LogEnable and PrintCount = integer'high then 
      return REPORT_ERROR ; 
    elsif not LogEnable and PrintCount = 0 then
      return REPORT_NONE ; 
    else
      Alert(AlertLogID, "ScoreboardPkg.GetReportMode, Values inconsistent with ScoreboardReportType" & 
            ".  LogEnable = "  & to_string(LogEnable) & 
            ".  PrintCount = " & to_string(PrintCount), FAILURE) ;
      return REPORT_NONE ;  -- value is not correct.  Note FAILURE above
    end if ; 
  end function GetReportMode ; 


  --==========================================================
  --!! Deprecated Subprograms
  --==========================================================

  ------------------------------------------------------------
  -- Deprecated interface to NewID
  impure function NewID (Name : String ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDType is
  ------------------------------------------------------------
    variable ReportMode : AlertLogReportModeType ;
  begin
    ReportMode := ENABLED when not DoNotReport else DISABLED ;
    return ScoreboardStore.NewID(Name, ParentAlertLogID, ReportMode => ReportMode) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Vector: 1 to Size
  impure function NewID (Name : String ; Size : positive ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType is
  ------------------------------------------------------------
    variable ReportMode : AlertLogReportModeType ;
  begin
    ReportMode := ENABLED when not DoNotReport else DISABLED ;
    return ScoreboardStore.NewID(Name, Size, ParentAlertLogID, ReportMode => ReportMode) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Vector: X(X'Left) to X(X'Right)
  impure function NewID (Name : String ; X : integer_vector ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType is
  ------------------------------------------------------------
    variable ReportMode : AlertLogReportModeType ;
  begin
    ReportMode := ENABLED when not DoNotReport else DISABLED ;
    return ScoreboardStore.NewID(Name, X, ParentAlertLogID, ReportMode => ReportMode) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Matrix: 1 to X, 1 to Y
  impure function NewID (Name : String ; X, Y : positive ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType is
  ------------------------------------------------------------
    variable ReportMode : AlertLogReportModeType ;
  begin
    ReportMode := ENABLED when not DoNotReport else DISABLED ;
    return ScoreboardStore.NewID(Name, X, Y, ParentAlertLogID, ReportMode => ReportMode) ;
  end function NewID ;

  ------------------------------------------------------------
  -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
  impure function NewID (Name : String ; X, Y : integer_vector ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType is
  ------------------------------------------------------------
    variable ReportMode : AlertLogReportModeType ;
  begin
    ReportMode := ENABLED when not DoNotReport else DISABLED ;
    return ScoreboardStore.NewID(Name, X, Y, ParentAlertLogID, ReportMode => ReportMode) ;
  end function NewID ;


end ScoreboardGenericPkg ;