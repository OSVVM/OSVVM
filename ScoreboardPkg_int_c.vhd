--
--  File Name:         ScoreBoardPkg_int.vhd
--  Design Unit Name:  ScoreBoardPkg_int
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
--    Date      Version     Description 
--    03/2022   2022.03     Removed deprecated SetAlertLogID in Singleton API  
--    02/2022   2022.02     Added WriteScoreboardYaml and GotScoreboards.  Updated NewID with ParentID, 
--                          ReportMode, Search, PrintParent.   Supports searching for Scoreboard models..
--    01/2022   2022.01     Added CheckExpected.  Added SetCheckCountZero to ScoreboardPType   
--    08/2021   2021.08     Removed SetAlertLogID from singleton public interface - set instead by NewID
--    06/2021   2021.06     Updated Data Structure, IDs for new use model, and Wrapper Subprograms
--    10/2020   2020.10     Added Peek
--    05/2020   2020.05     Updated calls to IncAffirmCount
--                          Overloaded Check with functions that return pass/fail (T/F)
--                          Added GetFifoCount.   Added GetPushCount which is same as GetItemCount
--    01/2020   2020.01     Updated Licenses to Apache
--    04/2018   2018.04     Made Pop Functions Visible.   Prep for AlertLogIDType being a type.
--    05/2017   2017.05     First print Actual then only print Expected if mis-match  
--    11/2016   2016.11     Released as part of OSVVM 
--    06/2015   2015.06     Added Alerts, SetAlertLogID, Revised LocalPush, GetDropCount, 
--                          Deprecated SetFinish and ReportMode - REPORT_NONE, FileOpen
--                          Deallocate, Initialized, Function SetName
--    09/2013   2013.09     Added file handling, Check Count, Finish Status
--                          Find, Flush
--    08/2013   2013.08     Generics:  to_string replaced write, Match replaced check
--                          Added Tags - Experimental
--                          Added Array of Scoreboards
--    08/2012   2012.08     Added Type and Subprogram Generics
--    05/2012   2012.05     Changed FIFO to store pointers to ExpectedType
--                          Allows usage of unconstrained arrays
--    08/2010   2010.08     Added Tailpointer
--    12/2006   2006.12     Initial revision
--
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2006 - 2022 by SynthWorks Design Inc.  
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
  
  use work.TranscriptPkg.all ; 
  use work.TextUtilPkg.all ; 
  use work.AlertLogPkg.all ; 
  use work.NamePkg.all ; 
  use work.NameStorePkg.all ;
  use work.ResolutionPkg.all ; 


package ScoreBoardPkg_int is
--  generic (
--    type ExpectedType ; 
--    type ActualType ; 
--    function Match(Actual : ActualType ;                           -- defaults
--                   Expected : ExpectedType) return boolean ;       -- is "=" ;
--    function expected_to_string(A : ExpectedType) return string ;  -- is to_string ;
--    function actual_to_string  (A : ActualType) return string      -- is to_string ; 
--  ) ; 
--
   --  For a VHDL-2002 package, comment out the generics and 
   --  uncomment the following, it replaces a generic instance of the package.
   --  As a result, you will have multiple copies of the entire package. 
   --  Inconvenient, but ok as it still works the same.
   subtype ExpectedType is integer ;
   subtype ActualType   is integer ;
   alias Match is "=" [ActualType, ExpectedType return boolean] ;  -- for std_logic_vector
   alias expected_to_string is to_string [ExpectedType return string];  -- VHDL-2008
   alias actual_to_string is to_string [ActualType return string];  -- VHDL-2008

  -- ScoreboardReportType is deprecated
  -- Replaced by Affirmations.  ERROR is the default.  ALL turns on PASSED flag
  type ScoreboardReportType is (REPORT_ERROR, REPORT_ALL, REPORT_NONE) ;   -- replaced by affirmations

  type ScoreboardIdType is record
    Id : integer_max ;
  end record ScoreboardIdType ; 
  type ScoreboardIdArrayType  is array (integer range <>) of ScoreboardIdType ;  
  type ScoreboardIdMatrixType is array (integer range <>, integer range <>) of ScoreboardIdType ;
  
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
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDType ;
   
  ------------------------------------------------------------
  -- Vector: 1 to Size
  impure function NewID (
    Name          : String ; 
    Size          : positive ; 
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
    ReportMode    : AlertLogReportModeType  := ENABLED ; 
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDArrayType ;

  ------------------------------------------------------------
  -- Vector: X(X'Left) to X(X'Right)
  impure function NewID (
    Name          : String ; 
    X             : integer_vector ; 
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
    ReportMode    : AlertLogReportModeType  := ENABLED ; 
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIDArrayType ;

  ------------------------------------------------------------
  -- Matrix: 1 to X, 1 to Y
  impure function NewID (
    Name          : String ; 
    X, Y          : positive ; 
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
    ReportMode    : AlertLogReportModeType  := ENABLED ; 
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType ;        
   
  ------------------------------------------------------------
  -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
  impure function NewID (
    Name          : String ; 
    X, Y          : integer_vector ; 
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
    ReportMode    : AlertLogReportModeType  := ENABLED ; 
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType ; 
  
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
  -- Simple 
  impure function ScoreboardEmpty (
    constant ID     : in  ScoreboardIDType 
  ) return boolean ; 
  -- Tagged 
  impure function ScoreboardEmpty (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string       
  ) return boolean ;                    -- Simple, Tagged

  impure function Empty (
    constant ID     : in  ScoreboardIDType 
  ) return boolean ; 
  -- Tagged 
  impure function Empty (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string       
  ) return boolean ;                    -- Simple, Tagged

--!!  ------------------------------------------------------------
--!!  -- SetAlertLogID - associate an AlertLogID with a scoreboard to allow integrated error reporting
--!!  procedure SetAlertLogID(
--!!    constant ID              : in  ScoreboardIDType ;
--!!    constant Name            : in  string ; 
--!!    constant ParentID        : in  AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
--!!    constant CreateHierarchy : in  Boolean := TRUE ;
--!!    constant DoNotReport     : in  Boolean := FALSE
--!!  ) ;
--!!
--!!  -- Use when an AlertLogID is used by multiple items (Model or other Scoreboards).  See also AlertLogPkg.GetAlertLogID
--!!  procedure SetAlertLogID (
--!!    constant ID     : in  ScoreboardIDType ;
--!!    constant A      : AlertLogIDType
--!!  ) ; 
    
  impure function GetAlertLogID (
    constant ID     : in  ScoreboardIDType 
  ) return AlertLogIDType ;
  

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
    constant ID          : in  ScoreboardIDType ;
    constant ItemNumber  :  in  integer 
  ) ; 

  -- Tagged Scoreboards - only removes items that also match the tag
  procedure Flush (
    constant ID          : in  ScoreboardIDType ;
    constant Tag         :  in  string ; 
    constant ItemNumber  :  in  integer 
  ) ; 
  
  ------------------------------------------------------------
  -- Writing YAML Reports 
  impure function GotScoreboards return boolean ;
  procedure WriteScoreboardYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE) ;

  ------------------------------------------------------------
  -- Generally these are not required.  When a simulation ends and 
  -- another simulation is started, a simulator will release all allocated items.  
  procedure Deallocate (
    constant ID     : in  ScoreboardIDType 
  ) ;  -- Deletes all allocated items
  procedure Initialize (
    constant ID     : in  ScoreboardIDType 
  ) ;  -- Creates initial data structure if it was destroyed with Deallocate 
      
  ------------------------------------------------------------
  -- Get error count
  -- Deprecated, replaced by usage of Alerts
  -- AlertFLow:      Instead use AlertLogPkg.ReportAlerts or AlertLogPkg.GetAlertCount
  -- Not AlertFlow:  use GetErrorCount to get total error count 
  
  -- Scoreboards, with or without tag
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
  -- SetReportMode  
  -- Not AlertFlow
  --     REPORT_ALL:     Replaced by AlertLogPkg.SetLogEnable(PASSED, TRUE)
  --     REPORT_ERROR:   Replaced by AlertLogPkg.SetLogEnable(PASSED, FALSE)
  --     REPORT_NONE:    Deprecated, do not use.
  -- AlertFlow:      
  --     REPORT_ALL:     Replaced by AlertLogPkg.SetLogEnable(AlertLogID, PASSED, TRUE)
  --     REPORT_ERROR:   Replaced by AlertLogPkg.SetLogEnable(AlertLogID, PASSED, FALSE)
  --     REPORT_NONE:    Replaced by AlertLogPkg.SetAlertEnable(AlertLogID, ERROR, FALSE)
  procedure SetReportMode (
    constant ID           : in  ScoreboardIDType ;
    constant ReportModeIn : in  ScoreboardReportType
  ) ;
  impure function GetReportMode (
    constant ID           : in  ScoreboardIDType
    ) return ScoreboardReportType ;

  type ScoreBoardPType is protected

    ------------------------------------------------------------
    -- Used by Scoreboard Store
    impure function NewID (
      Name          : String ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDType ;
     
    ------------------------------------------------------------
    -- Vector: 1 to Size
    impure function NewID (
      Name          : String ; 
      Size          : positive ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType ;

    ------------------------------------------------------------
    -- Vector: X(X'Left) to X(X'Right)
    impure function NewID (
      Name          : String ; 
      X             : integer_vector ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType ;

    ------------------------------------------------------------
    -- Matrix: 1 to X, 1 to Y
    impure function NewID (
      Name          : String ; 
      X, Y          : positive ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType ;        
     
    ------------------------------------------------------------
    -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
    impure function NewID (
      Name          : String ; 
      X, Y          : integer_vector ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType ; 
    
    ------------------------------------------------------------
    -- Emulate arrays of scoreboards 
    procedure SetArrayIndex(L, R : integer) ;  -- supports integer indices 
    procedure SetArrayIndex(R : natural) ;     -- indicies 1 to R
    impure function GetArrayIndex return integer_vector ;
    impure function GetArrayLength return natural ;

    ------------------------------------------------------------
    -- Push items into the scoreboard/FIFO

    -- Simple Scoreboard, no tag
    procedure Push (Item   : in  ExpectedType) ;
    
    -- Simple Tagged Scoreboard
    procedure Push (
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) ;

    -- Array of Scoreboards, no tag
    procedure Push (
      constant Index  : in  integer ;
      constant Item   : in  ExpectedType
    ) ;
    
    -- Array of Tagged Scoreboards
    procedure Push (
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) ;

--    ------------------------------------------------------------
--    -- Push items into the scoreboard/FIFO
--    -- Function form supports chaining of operations
--    -- In 2013, this caused overloading issues in some simulators, will retest later
--
--      -- Simple Scoreboard, no tag
--      impure function Push (Item : ExpectedType) return ExpectedType ;
--  
--      -- Simple Tagged Scoreboard
--      impure function Push (
--        constant Tag    : in  string ;
--        constant Item   : in  ExpectedType
--      ) return ExpectedType ;
--  
--      -- Array of Scoreboards, no tag
--      impure function Push (
--        constant Index  : in  integer ;
--        constant Item   : in  ExpectedType
--      ) return ExpectedType ;
--  
--      -- Array of Tagged Scoreboards 
--      impure function Push (
--        constant Index  : in  integer ;
--        constant Tag    : in  string ;
--        constant Item   : in  ExpectedType
--      ) return ExpectedType ; -- for chaining of operations
    
    ------------------------------------------------------------
    -- Check received item with item in the scoreboard/FIFO
    
    -- Simple Scoreboard, no tag
    procedure Check (ActualData : ActualType) ;
    
    -- Simple Tagged Scoreboard
    procedure Check (
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) ;

    -- Array of Scoreboards, no tag
    procedure Check (
      constant Index        : in  integer ;
      constant ActualData   : in ActualType
    ) ;

    -- Array of Tagged Scoreboards
    procedure Check (
      constant Index        : in  integer ;
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

    -- Array of Scoreboards, no tag
    impure function Check (
      constant Index        : in  integer ;
      constant ActualData   : in ActualType
    ) return boolean ;

    -- Array of Tagged Scoreboards
    impure function Check (
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean ;

    -------------------------------
    -- Array of Tagged Scoreboards
    impure function CheckExpected (
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ExpectedData : in  ActualType
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

    -- Array of Scoreboards, no tag
    procedure Pop (
      constant Index : in   integer ;
      variable Item : out  ExpectedType
    ) ;

    -- Array of Tagged Scoreboards
    procedure Pop (
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) ;

    ------------------------------------------------------------
    -- Pop the top item (FIFO) from the scoreboard/FIFO
    -- Caution:  this did not work in older simulators (@2013)

      -- Simple Scoreboard, no tag
      impure function Pop return ExpectedType ;
      
      -- Simple Tagged Scoreboard
      impure function Pop (
        constant Tag : in  string       
      ) return ExpectedType ;
  
      -- Array of Scoreboards, no tag
      impure function Pop (Index : integer) return ExpectedType ;
  
      -- Array of Tagged Scoreboards
      impure function Pop (
        constant Index  : in  integer ;
        constant Tag    : in  string       
      ) return ExpectedType ;


    ------------------------------------------------------------
    -- Peek at the top item (FIFO) from the scoreboard/FIFO
    
    -- Array of Tagged Scoreboards
    procedure Peek (
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out ExpectedType
    ) ;

    -- Array of Scoreboards, no tag
    procedure Peek (
      constant Index  : in  integer ;
      variable Item   : out  ExpectedType
    ) ;

    -- Simple Tagged Scoreboard
    procedure Peek (
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) ;

    -- Simple Scoreboard, no tag
    procedure Peek (variable Item : out  ExpectedType) ;
    
    ------------------------------------------------------------
    -- Peek at the top item (FIFO) from the scoreboard/FIFO
    -- Caution:  this did not work in older simulators (@2013)
    
    -- Array of Tagged Scoreboards
    impure function Peek (
      constant Index  : in  integer ;
      constant Tag    : in  string       
    ) return ExpectedType ;

    -- Array of Scoreboards, no tag
    impure function Peek (Index : integer) return ExpectedType ;

    -- Simple Tagged Scoreboard
    impure function Peek (
      constant Tag : in  string       
    ) return ExpectedType ;

    -- Simple Scoreboard, no tag
    impure function Peek return ExpectedType ;
    
    ------------------------------------------------------------
    -- Empty - check to see if scoreboard is empty
    impure function Empty return boolean ;                                   -- Simple 
    impure function Empty (Tag : String) return boolean ;                    -- Simple, Tagged
    impure function Empty (Index  : integer) return boolean ;                -- Array
    impure function Empty (Index  : integer; Tag : String) return boolean ;  -- Array, Tagged

    ------------------------------------------------------------
    -- SetAlertLogID - associate an AlertLogID with a scoreboard to allow integrated error reporting
    -- ReportMode := ENABLED when not DoNotReport else DISABLED ;
    procedure SetAlertLogID(Index : Integer; Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) ;
    procedure SetAlertLogID(Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) ;
    -- Use when an AlertLogID is used by multiple items (Model or other Scoreboards).  See also AlertLogPkg.GetAlertLogID
    procedure SetAlertLogID (Index : Integer ; A : AlertLogIDType) ;  
    procedure SetAlertLogID (A : AlertLogIDType) ;
    impure function GetAlertLogID(Index : Integer) return AlertLogIDType ;
    impure function GetAlertLogID return AlertLogIDType ;
    
    ------------------------------------------------------------
    -- Set a scoreboard name.  
    -- Used when scoreboard AlertLogID is shared between different sources.
    procedure SetName (Name : String) ;
    impure function SetName (Name : String) return string ;
    impure function GetName (DefaultName : string := "Scoreboard") return string ;


    ------------------------------------------------------------
    -- Scoreboard Introspection  
    
    -- Number of items put into scoreboard
    impure function GetItemCount return integer ;                      -- Simple, with or without tags
    impure function GetItemCount (Index  : integer) return integer ;   -- Arrays, with or without tags
    impure function GetPushCount return integer ;                      -- Simple, with or without tags
    impure function GetPushCount (Index  : integer) return integer ;   -- Arrays, with or without tags
    
    -- Number of items removed from scoreboard by pop or check
    impure function GetPopCount (Index  : integer) return integer ;
    impure function GetPopCount return integer ; 

    -- Number of items currently in the scoreboard (= PushCount - PopCount - DropCount)
    impure function GetFifoCount (Index  : integer) return integer ;
    impure function GetFifoCount return integer ; 

    -- Number of items checked by scoreboard
    impure function GetCheckCount return integer ;                     -- Simple, with or without tags
    impure function GetCheckCount (Index  : integer) return integer ;  -- Arrays, with or without tags
    
    -- Number of items dropped by scoreboard.  See Find/Flush
    impure function GetDropCount return integer ;                      -- Simple, with or without tags
    impure function GetDropCount (Index  : integer) return integer ;   -- Arrays, with or without tags

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

    -- Array of Simple Scoreboards
    impure function Find (
      constant Index       :  in  integer ; 
      constant ActualData  :  in  ActualType 
    ) return integer ; 

    -- Array of Tagged Scoreboards
    impure function Find (
      constant Index       :  in  integer ; 
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
    
    -- Array of Simple Scoreboards
    procedure Flush (
      constant Index       :  in  integer ; 
      constant ItemNumber  :  in  integer 
    ) ; 

    -- Array of Tagged Scoreboards - only removes items that also match the tag
    procedure Flush (
      constant Index       :  in  integer ; 
      constant Tag         :  in  string ; 
      constant ItemNumber  :  in  integer 
    ) ; 
    
    ------------------------------------------------------------
    -- Writing YAML Reports 
    impure function GotScoreboards return boolean ;
    procedure WriteScoreboardYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE) ;
    
    ------------------------------------------------------------
    -- Generally these are not required.  When a simulation ends and 
    -- another simulation is started, a simulator will release all allocated items.  
    procedure Deallocate ;  -- Deletes all allocated items
    procedure Initialize ;  -- Creates initial data structure if it was destroyed with Deallocate 
    
    
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
    -- SetReportMode  
    -- Not AlertFlow
    --     REPORT_ALL:     Replaced by AlertLogPkg.SetLogEnable(PASSED, TRUE)
    --     REPORT_ERROR:   Replaced by AlertLogPkg.SetLogEnable(PASSED, FALSE)
    --     REPORT_NONE:    Deprecated, do not use.
    -- AlertFlow:      
    --     REPORT_ALL:     Replaced by AlertLogPkg.SetLogEnable(AlertLogID, PASSED, TRUE)
    --     REPORT_ERROR:   Replaced by AlertLogPkg.SetLogEnable(AlertLogID, PASSED, FALSE)
    --     REPORT_NONE:    Replaced by AlertLogPkg.SetAlertEnable(AlertLogID, ERROR, FALSE)
    procedure SetReportMode (ReportModeIn : ScoreboardReportType) ;
    impure function GetReportMode return ScoreboardReportType ;

    ------------------------------------------------------------
    ------------------------------------------------------------
--    -- Deprecated Interface to NewID
--    impure function NewID (Name : String; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDType ;
--    -- Vector: 1 to Size
--    impure function NewID (Name : String; Size : positive; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType ;
--    -- Vector: X(X'Left) to X(X'Right)
--    impure function NewID (Name : String; X : integer_vector; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType ;
--    -- Matrix: 1 to X, 1 to Y
--    impure function NewID (Name : String; X, Y : positive; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType ;
--    -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
--    impure function NewID (Name : String; X, Y : integer_vector; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType ;


  end protected ScoreBoardPType ;
  
  ------------------------------------------------------------
  -- Deprecated Interface to NewID
  impure function NewID (Name : String; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDType ;
  -- Vector: 1 to Size
  impure function NewID (Name : String; Size : positive; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType ;
  -- Vector: X(X'Left) to X(X'Right)
  impure function NewID (Name : String; X : integer_vector; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType ;
  -- Matrix: 1 to X, 1 to Y
  impure function NewID (Name : String; X, Y : positive; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType ;
  -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
  impure function NewID (Name : String; X, Y : integer_vector; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType ;


end ScoreBoardPkg_int ;


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
package body ScoreBoardPkg_int is

  type ScoreBoardPType is protected body
    type ExpectedPointerType is access ExpectedType ;

    type ListType ;
    type ListPointerType is access ListType ;
    type ListType is record
      ItemNumber     : integer ;
      TagPtr         : line ; 
      ExpectedPtr    : ExpectedPointerType ;
      NextPtr        : ListPointerType ;
    end record ;
    
--!! Replace the following with
--    type ScoreboardRecType is record
--      HeadPointer    : ListPointerType ;
--      TailPointer    : ListPointerType ; 
--      PopListPointer : ListPointerType ;
--
--      ErrCnt         : integer ; 
--      DropCount      : integer ;
--      ItemNumber     : integer ;
--      PopCount       : integer ;
--      CheckCount     : integer ;
--      AlertLogID     : AlertLogIDType ;
--      Name           : NameStoreIDType ; 
--      ReportMode     : ScoreboardReportType ; 
--    end record ScoreboardRecType ; 
--
--    type ScoreboardRecArrayType is array (integer range <>) of ScoreboardRecType ;  
--    type ScoreboardRecArrayPointerType is access ScoreboardRecArrayType ;
--    variable ScoreboardPointer : ScoreboardRecArrayPointerType ;
--
--    -- Alas unfortunately aliases don't word as follows:
--    -- alias HeadPointer(I) is ScoreboardPointer(I).HeadPointer ;

    type ListArrayType is array (integer range <>) of ListPointerType ;  
    type ListArrayPointerType is access ListArrayType ; 
    
    variable ArrayLengthVar  : integer := 1 ; 
    
-- Original Code
--    variable HeadPointer     : ListArrayPointerType := new ListArrayType(1 to 1) ;
--    variable TailPointer     : ListArrayPointerType := new ListArrayType(1 to 1)  ;
--    -- PopListPointer needed for Pop to be a function - alternately need 2019 features
--    variable PopListPointer  : ListArrayPointerType := new ListArrayType(1 to 1) ; 
--
-- Legal, but crashes simulator more thoroughly 
--    variable HeadPointer     : ListArrayPointerType := new ListArrayType'(1 => NULL) ;
--    variable TailPointer     : ListArrayPointerType := new ListArrayType'(1 => NULL) ;
--    -- PopListPointer needed for Pop to be a function - alternately need 2019 features
--    variable PopListPointer  : ListArrayPointerType := new ListArrayType'(1 => NULL) ; 
-- Working work around for QS 2020.04 and 2021.02
    variable Template : ListArrayType(1 to 1) ;  -- Work around for QS 2020.04 and 2021.02

    variable HeadPointer     : ListArrayPointerType := new ListArrayType'(Template) ;
    variable TailPointer     : ListArrayPointerType := new ListArrayType'(Template) ;
    -- PopListPointer needed for Pop to be a function - alternately need 2019 features
    variable PopListPointer  : ListArrayPointerType := new ListArrayType'(Template) ; 

    type IntegerArrayType is array (integer range <>) of Integer ;  
    type IntegerArrayPointerType is access IntegerArrayType ; 
    type AlertLogIDArrayType is array (integer range <>) of AlertLogIDType ;  
    type AlertLogIDArrayPointerType is access AlertLogIDArrayType ; 
    
    variable ErrCntVar       : IntegerArrayPointerType := new IntegerArrayType'(1 => 0) ;
    variable DropCountVar    : IntegerArrayPointerType := new IntegerArrayType'(1 => 0) ;
    variable ItemNumberVar   : IntegerArrayPointerType := new IntegerArrayType'(1 => 0) ;
    variable PopCountVar     : IntegerArrayPointerType := new IntegerArrayType'(1 => 0) ;
    variable CheckCountVar   : IntegerArrayPointerType := new IntegerArrayType'(1 => 0) ;
    variable AlertLogIDVar   : AlertLogIDArrayPointerType := new AlertLogIDArrayType'(1 => OSVVM_SCOREBOARD_ALERTLOG_ID) ;

    variable NameVar         : NamePType ;
    variable ReportModeVar   : ScoreboardReportType ; 
    variable FirstIndexVar   : integer := 1 ;
    
    variable PrintIndexVar   : boolean := TRUE ; 
    
    variable CalledNewID     : boolean := FALSE ; 
    variable LocalNameStore  : NameStorePType ; 

    ------------------------------------------------------------
    -- Used by ScoreboardStore
    variable NumItems       : integer := 0 ; 
    constant MIN_NUM_ITEMS  : integer := 4 ; -- Temporarily small for testing
--    constant MIN_NUM_ITEMS      : integer := 32 ; -- Min amount to resize array
    
    ------------------------------------------------------------
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
      variable NumItems         : InOut integer ;
      constant GrowAmount       : in integer ;
      constant MinNumItems      : in integer 
    ) is
      variable NewNumItems : integer ;
    begin
      NewNumItems := NumItems + GrowAmount ;
      if NewNumItems > HeadPointer'length then
        SetArrayIndex(1, NormalizeArraySize(NewNumItems, MinNumItems)) ;
      end if ;
      NumItems := NewNumItems ; 
    end procedure GrowNumberItems ;  
    
    ------------------------------------------------------------
    -- Local/Private to package
    impure function LocalNewID (
      Name          : String ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDType is
    ------------------------------------------------------------
      variable NameID              : integer ; 
    begin
      NameID := LocalNameStore.find(Name, ParentID, Search) ; 

      -- Share the scoreboards if they match
      if NameID /= ID_NOT_FOUND.ID then
        return ScoreboardIDType'(ID => NameID) ; 
      else
        -- Resize Data Structure as necessary
        GrowNumberItems(NumItems, GrowAmount => 1, MinNumItems => MIN_NUM_ITEMS) ; 
        -- Create AlertLogID
        AlertLogIDVar(NumItems) := NewID(Name, ParentID, ReportMode, PrintParent, CreateHierarchy => FALSE) ;
        -- Add item to NameStore
        NameID := LocalNameStore.NewID(Name, ParentID, Search) ;
        AlertIfNotEqual(AlertLogIDVar(NumItems), NameID, NumItems, "ScoreboardPkg: Index of LocalNameStore /= ScoreboardID") ;  
        return ScoreboardIDType'(ID => NumItems) ; 
      end if ; 
    end function LocalNewID ;

    ------------------------------------------------------------
    -- Used by Scoreboard Store
    impure function NewID (
      Name          : String ; 
      ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
      ReportMode    : AlertLogReportModeType  := ENABLED ; 
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDType is
    ------------------------------------------------------------
      variable ResolvedSearch      : NameSearchType ; 
      variable ResolvedPrintParent : AlertLogPrintParentType ; 
    begin
      CalledNewID := TRUE ;
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
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIDArrayType is
    ------------------------------------------------------------
      variable Result          : ScoreboardIDArrayType(X(X'left) to X(X'right)) ; 
      variable ResolvedSearch  : NameSearchType ; 
      variable ResolvedPrintParent : AlertLogPrintParentType ; 
--      variable ArrayParentID       : AlertLogIDType ; 
    begin
      CalledNewID := TRUE ;
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
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
      PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return ScoreboardIdMatrixType is
    ------------------------------------------------------------
      variable Result          : ScoreboardIdMatrixType(X(X'left) to X(X'right), Y(Y'left) to Y(Y'right)) ; 
      variable ResolvedSearch  : NameSearchType ; 
      variable ResolvedPrintParent : AlertLogPrintParentType ; 
--      variable ArrayParentID       : AlertLogIDType ; 
    begin
      CalledNewID := TRUE ;
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
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
      Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
    procedure SetReportMode (ReportModeIn : ScoreboardReportType) is
    ------------------------------------------------------------
    begin
      ReportModeVar := ReportModeIn ; 
      if ReportModeVar = REPORT_ALL then 
        Alert(OSVVM_SCOREBOARD_ALERTLOG_ID, "ScoreboardGenericPkg.SetReportMode: To turn off REPORT_ALL, use osvvm.AlertLogPkg.SetLogEnable(PASSED, FALSE)", WARNING) ; 
        for i in AlertLogIDVar'range loop
          SetLogEnable(AlertLogIDVar(i), PASSED, TRUE) ; 
        end loop ;
      end if ; 
      if ReportModeVar = REPORT_NONE then 
        Alert(OSVVM_SCOREBOARD_ALERTLOG_ID, "ScoreboardGenericPkg.SetReportMode: ReportMode REPORT_NONE has been deprecated and will be removed in next revision.  Please contact OSVVM architect Jim Lewis if you need this capability.", WARNING) ; 
      end if ; 
    end procedure SetReportMode ;

    ------------------------------------------------------------
    impure function GetReportMode return ScoreboardReportType is
    ------------------------------------------------------------
    begin
      return ReportModeVar ;
    end function GetReportMode ;
    
    ------------------------------------------------------------
    procedure SetArrayIndex(L, R : integer) is
    ------------------------------------------------------------
      variable OldHeadPointer, OldTailPointer, OldPopListPointer : ListArrayPointerType ;
      variable OldErrCnt, OldDropCount, OldItemNumber, OldPopCount, OldCheckCount : IntegerArrayPointerType ;
      variable OldAlertLogIDVar : AlertLogIDArrayPointerType ;
      variable Min, Max, Len, OldLen, OldMax : integer ; 
    begin
      Min := minimum(L, R) ; 
      Max := maximum(L, R) ; 
      OldLen := ArrayLengthVar ; 
      OldMax := Min + ArrayLengthVar - 1 ; 
      Len := Max - Min + 1 ; 
      ArrayLengthVar := Len ; 
      if Len >= OldLen then 
        FirstIndexVar := Min ; 
      
        OldHeadPointer := HeadPointer ; 
        HeadPointer := new ListArrayType(Min to Max) ;
        if OldHeadPointer /= NULL then 
          HeadPointer(Min to OldMax) := OldHeadPointer.all ; -- (OldHeadPointer'range) ; 
          Deallocate(OldHeadPointer) ; 
        end if ; 
        
        OldTailPointer := TailPointer ; 
        TailPointer := new ListArrayType(Min to Max) ;
        if OldTailPointer /= NULL then 
          TailPointer(Min to OldMax) := OldTailPointer.all ; 
          Deallocate(OldTailPointer) ; 
        end if ; 

        OldPopListPointer := PopListPointer ; 
        PopListPointer := new ListArrayType(Min to Max) ;
        if OldPopListPointer /= NULL then 
          PopListPointer(Min to OldMax) := OldPopListPointer.all ;
          Deallocate(OldPopListPointer) ; 
        end if ; 

        OldErrCnt := ErrCntVar ; 
        ErrCntVar := new IntegerArrayType'(Min to Max => 0) ;
        if OldErrCnt /= NULL then 
          ErrCntVar(Min to OldMax) := OldErrCnt.all ; 
          Deallocate(OldErrCnt) ; 
        end if ; 

        OldDropCount := DropCountVar ; 
        DropCountVar := new IntegerArrayType'(Min to Max => 0) ;
        if OldDropCount /= NULL then 
          DropCountVar(Min to OldMax) := OldDropCount.all ; 
          Deallocate(OldDropCount) ; 
        end if ; 

        OldItemNumber := ItemNumberVar ; 
        ItemNumberVar := new IntegerArrayType'(Min to Max => 0) ;
        if OldItemNumber /= NULL then 
          ItemNumberVar(Min to OldMax) := OldItemNumber.all ; 
          Deallocate(OldItemNumber) ; 
        end if ; 

        OldPopCount := PopCountVar ; 
        PopCountVar := new IntegerArrayType'(Min to Max => 0) ;
        if OldPopCount /= NULL then 
          PopCountVar(Min to OldMax) := OldPopCount.all ; 
          Deallocate(OldPopCount) ; 
        end if ; 

        OldCheckCount := CheckCountVar ; 
        CheckCountVar := new IntegerArrayType'(Min to Max => 0) ;
        if OldCheckCount /= NULL then 
          CheckCountVar(Min to OldMax) := OldCheckCount.all ; 
          Deallocate(OldCheckCount) ; 
        end if ; 

        OldAlertLogIDVar := AlertLogIDVar ; 
        AlertLogIDVar := new AlertLogIDArrayType'(Min to Max => OSVVM_SCOREBOARD_ALERTLOG_ID) ;
        if OldAlertLogIDVar /= NULL then 
          AlertLogIDVar(Min to OldMax) := OldAlertLogIDVar.all ; 
          Deallocate(OldAlertLogIDVar) ; 
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
    procedure Deallocate is
    ------------------------------------------------------------
      variable CurListPtr, LastListPtr : ListPointerType ;
    begin
      for Index in HeadPointer'range loop
      -- Deallocate contents in the scoreboards
        CurListPtr  := HeadPointer(Index) ; 
        while CurListPtr /= Null loop 
          deallocate(CurListPtr.TagPtr) ; 
          deallocate(CurListPtr.ExpectedPtr) ; 
          LastListPtr := CurListPtr ;
          CurListPtr := CurListPtr.NextPtr ; 
          Deallocate(LastListPtr) ; 
        end loop ;
      end loop ;
      
      for Index in PopListPointer'range loop
      -- Deallocate PopListPointer - only has single element
        CurListPtr  := PopListPointer(Index) ; 
        if CurListPtr /= NULL then
          deallocate(CurListPtr.TagPtr) ; 
          deallocate(CurListPtr.ExpectedPtr) ; 
          deallocate(CurListPtr) ; 
        end if ;
      end loop ; 
        
      -- Deallocate arrays of pointers
      Deallocate(HeadPointer) ; 
      Deallocate(TailPointer) ; 
      Deallocate(PopListPointer) ; 

      -- Deallocate supporting arrays
      Deallocate(ErrCntVar) ; 
      Deallocate(DropCountVar) ; 
      Deallocate(ItemNumberVar) ; 
      Deallocate(PopCountVar) ; 
      Deallocate(CheckCountVar) ; 
      Deallocate(AlertLogIDVar) ; 

      -- Deallocate NameVar - NamePType
      NameVar.Deallocate ; 
      
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
    impure function GetArrayIndex return integer_vector is
    ------------------------------------------------------------
    begin
      return (1 => HeadPointer'left, 2 => HeadPointer'right) ;
    end function GetArrayIndex ;

    ------------------------------------------------------------
    impure function GetArrayLength return natural is
    ------------------------------------------------------------
    begin
      return ArrayLengthVar ;  -- HeadPointer'length ;
    end function GetArrayLength ;
    
    ------------------------------------------------------------
    procedure SetAlertLogID (Index : Integer ; A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      AlertLogIDVar(Index) := A ;
    end procedure SetAlertLogID ;
    
    ------------------------------------------------------------
    procedure SetAlertLogID (A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      AlertLogIDVar(FirstIndexVar) := A ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(Index : Integer; Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) is
    ------------------------------------------------------------
      variable ReportMode : AlertLogReportModeType ;
    begin
      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
      AlertLogIDVar(Index) := NewID(Name, ParentID, ReportMode => ReportMode, PrintParent => PRINT_NAME, CreateHierarchy => CreateHierarchy) ;
    end procedure SetAlertLogID ;
    
    ------------------------------------------------------------
    procedure SetAlertLogID(Name : string; ParentID : AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID; CreateHierarchy : Boolean := TRUE; DoNotReport : Boolean := FALSE) is
    ------------------------------------------------------------
      variable ReportMode : AlertLogReportModeType ;
    begin
      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
      AlertLogIDVar(FirstIndexVar) := NewID(Name, ParentID, ReportMode => ReportMode, PrintParent => PRINT_NAME, CreateHierarchy => CreateHierarchy) ;
    end procedure SetAlertLogID ;
    
    ------------------------------------------------------------
    impure function GetAlertLogID(Index : Integer) return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return AlertLogIDVar(Index) ; 
    end function GetAlertLogID ;
        
    ------------------------------------------------------------
    impure function GetAlertLogID return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return AlertLogIDVar(FirstIndexVar) ; 
    end function GetAlertLogID ;
        
    ------------------------------------------------------------
    impure function LocalOutOfRange(
    ------------------------------------------------------------
      constant Index : in integer ; 
      constant Name  : in string
    ) return boolean is 
    begin
      return AlertIf(OSVVM_SCOREBOARD_ALERTLOG_ID, Index < HeadPointer'Low or Index > HeadPointer'High, 
         GetName & " " & Name & " Index: " & to_string(Index) & 
               "is not in the range (" & to_string(HeadPointer'Low) &
               "to " & to_string(HeadPointer'High) & ")",
         FAILURE ) ;
    end function LocalOutOfRange ; 

    ------------------------------------------------------------
    procedure LocalPush (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) is
      variable ExpectedPtr : ExpectedPointerType ;
      variable TagPtr : line ; 
    begin
      if LocalOutOfRange(Index, "Push") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
        
      ItemNumberVar(Index)  := ItemNumberVar(Index) + 1 ;
      ExpectedPtr := new ExpectedType'(Item) ;
      TagPtr := new string'(Tag) ; 

      if HeadPointer(Index) = NULL then
        -- 2015.05: allocation using ListTtype'(...) in a protected type does not work in some simulators 
        -- HeadPointer(Index) := new ListType'(ItemNumberVar(Index), TagPtr, ExpectedPtr, NULL) ;
        HeadPointer(Index) := new ListType ;
        HeadPointer(Index).ItemNumber  := ItemNumberVar(Index) ;
        HeadPointer(Index).TagPtr      := TagPtr ;
        HeadPointer(Index).ExpectedPtr := ExpectedPtr ;
        HeadPointer(Index).NextPtr     := NULL ;
        TailPointer(Index) := HeadPointer(Index) ;
      else
        -- 2015.05: allocation using ListTtype'(...) in a protected type does not work in some simulators 
        -- TailPointer(Index).NextPtr := new ListType'(ItemNumberVar(Index), TagPtr, ExpectedPtr, NULL) ;
        TailPointer(Index).NextPtr := new ListType ;
        TailPointer(Index).NextPtr.ItemNumber  := ItemNumberVar(Index) ;
        TailPointer(Index).NextPtr.TagPtr      := TagPtr ;
        TailPointer(Index).NextPtr.ExpectedPtr := ExpectedPtr ;
        TailPointer(Index).NextPtr.NextPtr     := NULL ;
        TailPointer(Index) := TailPointer(Index).NextPtr ;
      end if ;
    end procedure LocalPush ;
    
    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    procedure Push (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) is
      variable ExpectedPtr : ExpectedPointerType ;
      variable TagPtr : line ; 
    begin
      if LocalOutOfRange(Index, "Push") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPush(Index, Tag, Item) ; 
    end procedure Push ;
    
    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    procedure Push (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Item   : in  ExpectedType
    ) is
    begin
      if LocalOutOfRange(Index, "Push") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPush(Index, "", Item) ; 
    end procedure Push ; 
    
    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Push (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) is
    begin
      LocalPush(FirstIndexVar, Tag, Item) ; 
    end procedure Push ; 

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Push (Item   : in  ExpectedType) is
    ------------------------------------------------------------
    begin
      LocalPush(FirstIndexVar, "", Item) ; 
    end procedure Push ; 

    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    impure function Push (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) return ExpectedType is
    begin
      if LocalOutOfRange(Index, "Push") then 
        return Item ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPush(Index, Tag, Item) ;
      return Item ; 
    end function Push ; 

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    impure function Push (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Item   : in  ExpectedType
    ) return ExpectedType is
    begin
      if LocalOutOfRange(Index, "Push") then 
        return Item ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPush(Index, "", Item) ;
      return Item ; 
    end function Push ; 

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Push (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      constant Item   : in  ExpectedType
    ) return ExpectedType is
    begin
      LocalPush(FirstIndexVar, Tag, Item) ;
      return Item ; 
    end function Push ; 

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Push (Item : ExpectedType) return ExpectedType is
    ------------------------------------------------------------
    begin
      LocalPush(FirstIndexVar, "", Item) ;
      return Item ; 
    end function Push ; 
    
    ------------------------------------------------------------
    -- Local Only
    -- Pops highest element matching Tag into PopListPointer(Index) 
    procedure LocalPop (Index : integer ; Tag : string; Name : string)  is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
      if LocalOutOfRange(Index, "Pop/Check") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      if HeadPointer(Index) = NULL then
        ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
        Alert(AlertLogIDVar(Index), GetName & " Empty during " & Name, FAILURE) ; 
        return ;
      end if ;
      PopCountVar(Index) := PopCountVar(Index) + 1 ;
      -- deallocate previous pointer
      if PopListPointer(Index) /= NULL then
        deallocate(PopListPointer(Index).TagPtr) ; 
        deallocate(PopListPointer(Index).ExpectedPtr) ; 
        deallocate(PopListPointer(Index)) ; 
      end if ; 
      -- Descend to find Tag field and extract
      CurPtr := HeadPointer(Index) ;
      if CurPtr.TagPtr.all = Tag then 
        -- Non-tagged scoreboards find this one.
        PopListPointer(Index)  := HeadPointer(Index) ; 
        HeadPointer(Index)     := HeadPointer(Index).NextPtr ;
      else 
        loop 
          if CurPtr.NextPtr = NULL then
            ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
            Alert(AlertLogIDVar(Index), GetName & " Pop/Check (" & Name & "), tag: " & Tag & " not found", FAILURE) ; 
            exit ; 
          elsif CurPtr.NextPtr.TagPtr.all = Tag then 
            PopListPointer(Index) := CurPtr.NextPtr ; 
            CurPtr.NextPtr := CurPtr.NextPtr.NextPtr ;
            if CurPtr.NextPtr = NULL then 
              TailPointer(Index) := CurPtr ; 
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
    procedure LocalCheck (
    ------------------------------------------------------------
      constant Index          : in    integer ;
      constant ActualData     : in    ActualType ;
      variable FoundError     : inout boolean ;
      constant ExpectedInFIFO : in    boolean := TRUE
    ) is
      variable ExpectedPtr    : ExpectedPointerType ;
      variable CurrentItem  : integer ;
      variable WriteBuf : line ;
      variable PassedFlagEnabled : boolean ; 
    begin
      CheckCountVar(Index) := CheckCountVar(Index) + 1 ;
      ExpectedPtr := PopListPointer(Index).ExpectedPtr ;
      CurrentItem := PopListPointer(Index).ItemNumber ; 

      PassedFlagEnabled := GetLogEnable(AlertLogIDVar(Index), PASSED) ;
      
      if not Match(ActualData, ExpectedPtr.all) then
        ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
        FoundError := TRUE ; 
        IncAffirmCount(AlertLogIDVar(Index)) ;
      else
        FoundError := FALSE ; 
        if not PassedFlagEnabled then 
          IncAffirmPassedCount(AlertLogIDVar(Index)) ;
        end if ; 
      end if ; 
      
--      IncAffirmCount(AlertLogIDVar(Index)) ;  
      
--      if FoundError or ReportModeVar = REPORT_ALL then
      if FoundError or PassedFlagEnabled then
        if AlertLogIDVar(Index) = OSVVM_SCOREBOARD_ALERTLOG_ID  then 
          write(WriteBuf, GetName(DefaultName => "Scoreboard")) ; 
        else
          write(WriteBuf, GetName(DefaultName => "")) ; 
        end if ; 
        if ArrayLengthVar > 1 and PrintIndexVar then 
          write(WriteBuf, " (" & to_string(Index) & ") ") ; 
        end if ; 
        if ExpectedInFIFO then 
          write(WriteBuf, "   Received: " & actual_to_string(ActualData)) ;
          if FoundError then 
            write(WriteBuf, "   Expected: " & expected_to_string(ExpectedPtr.all)) ;
          end if ; 
        else
          write(WriteBuf, "   Received: " & expected_to_string(ExpectedPtr.all)) ;
          if FoundError then 
            write(WriteBuf, "   Expected: " & actual_to_string(ActualData)) ;
          end if ; 
        end if ; 
        if PopListPointer(Index).TagPtr.all /= "" then
          write(WriteBuf, "   Tag: " & PopListPointer(Index).TagPtr.all) ;
        end if; 
        write(WriteBuf, "   Item Number: " & to_string(CurrentItem)) ; 
        if FoundError then 
          if ReportModeVar /= REPORT_NONE then 
            -- Affirmation Failed
            Alert(AlertLogIDVar(Index), WriteBuf.all, ERROR) ; 
          else
            -- Affirmation Failed, but silent, unless in DEBUG mode
            Log(AlertLogIDVar(Index), "ERROR " & WriteBuf.all, DEBUG) ;
            IncAlertCount(AlertLogIDVar(Index)) ;  -- Silent Counted Alert
          end if ; 
        else
          -- Affirmation passed, PASSED flag increments AffirmCount
          Log(AlertLogIDVar(Index), WriteBuf.all, PASSED) ;
        end if ; 
        deallocate(WriteBuf) ; 
      end if ;
    end procedure LocalCheck ;

    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    procedure Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) is
      variable FoundError   : boolean ;
    begin
      if LocalOutOfRange(Index, "Check") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, Tag, "Check") ; 
      LocalCheck(Index, ActualData, FoundError) ; 
    end procedure Check ;

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    procedure Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant ActualData   : in  ActualType
    ) is
      variable FoundError   : boolean ;
    begin
      if LocalOutOfRange(Index, "Check") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, "", "Check") ; 
      LocalCheck(Index, ActualData, FoundError) ; 
    end procedure Check ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Check (
    ------------------------------------------------------------
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) is
      variable FoundError   : boolean ;
    begin
      LocalPop(FirstIndexVar, Tag, "Check") ; 
      LocalCheck(FirstIndexVar, ActualData, FoundError) ; 
    end procedure Check ;
    
    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Check (ActualData : ActualType) is
    ------------------------------------------------------------
      variable FoundError   : boolean ;
    begin
      LocalPop(FirstIndexVar, "", "Check") ; 
      LocalCheck(FirstIndexVar, ActualData, FoundError) ; 
    end procedure Check ;
    
    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    impure function Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean is
      variable FoundError   : boolean ;
    begin
      if LocalOutOfRange(Index, "Function Check") then 
        return FALSE ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, Tag, "Check") ; 
      LocalCheck(Index, ActualData, FoundError) ; 
      return not FoundError ; 
    end function Check ;

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    impure function Check (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant ActualData   : in  ActualType
    ) return boolean is
      variable FoundError   : boolean ;
    begin
      if LocalOutOfRange(Index, "Function Check") then 
        return FALSE ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, "", "Check") ; 
      LocalCheck(Index, ActualData, FoundError) ; 
      return not FoundError ; 
    end function Check ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Check (
    ------------------------------------------------------------
      constant Tag          : in  string ;
      constant ActualData   : in  ActualType
    ) return boolean is
      variable FoundError   : boolean ;
    begin
      LocalPop(FirstIndexVar, Tag, "Check") ; 
      LocalCheck(FirstIndexVar, ActualData, FoundError) ; 
      return not FoundError ; 
    end function Check ;
    
    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Check (ActualData : ActualType) return boolean is
    ------------------------------------------------------------
      variable FoundError   : boolean ;
    begin
      LocalPop(FirstIndexVar, "", "Check") ; 
      LocalCheck(FirstIndexVar, ActualData, FoundError) ; 
      return not FoundError ; 
    end function Check ;
    
    ------------------------------------------------------------
    -- Scoreboard Store.  Index. Tag.
    impure function CheckExpected (
    ------------------------------------------------------------
      constant Index        : in  integer ;
      constant Tag          : in  string ;
      constant ExpectedData : in  ActualType
    ) return boolean is
      variable FoundError   : boolean ;
    begin
      if LocalOutOfRange(Index, "Function Check") then 
        return FALSE ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, Tag, "Check") ; 
      LocalCheck(Index, ExpectedData, FoundError, ExpectedInFIFO => FALSE) ; 
      return not FoundError ; 
    end function CheckExpected ;

    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    procedure Pop (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) is
    begin
      if LocalOutOfRange(Index, "Pop") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, Tag, "Pop") ; 
      Item := PopListPointer(Index).ExpectedPtr.all ;
    end procedure Pop ;

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    procedure Pop (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      variable Item   : out  ExpectedType
    ) is
    begin
      if LocalOutOfRange(Index, "Pop") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      LocalPop(Index, "", "Pop") ; 
      Item := PopListPointer(Index).ExpectedPtr.all ;
    end procedure Pop ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    procedure Pop (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) is
    begin
      LocalPop(FirstIndexVar, Tag, "Pop") ; 
      Item := PopListPointer(FirstIndexVar).ExpectedPtr.all ;
    end procedure Pop ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Pop (variable Item : out  ExpectedType) is
    ------------------------------------------------------------
    begin
      LocalPop(FirstIndexVar, "", "Pop") ; 
      Item := PopListPointer(FirstIndexVar).ExpectedPtr.all ;
    end procedure Pop ;
    
    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    impure function Pop (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string       
    ) return ExpectedType is
    begin
      if LocalOutOfRange(Index, "Pop") then 
        -- error reporting in LocalOutOfRange
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ; 
      end if ; 
      LocalPop(Index, Tag, "Pop") ;
      return PopListPointer(Index).ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    impure function Pop (Index : integer) return ExpectedType is
    ------------------------------------------------------------
    begin
      if LocalOutOfRange(Index, "Pop") then 
        -- error reporting in LocalOutOfRange
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ; 
      end if ; 
      LocalPop(Index, "", "Pop") ;
      return PopListPointer(Index).ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Pop (
    ------------------------------------------------------------
      constant Tag : in  string       
    ) return ExpectedType is
    begin
      LocalPop(FirstIndexVar, Tag, "Pop") ;
      return PopListPointer(FirstIndexVar).ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Pop return ExpectedType is
    ------------------------------------------------------------
    begin
      LocalPop(FirstIndexVar, "", "Pop") ;
      return PopListPointer(FirstIndexVar).ExpectedPtr.all ;
    end function Pop ;

    ------------------------------------------------------------
    -- Local Only similar to LocalPop
    -- Returns a pointer to the highest element matching Tag  
    impure function LocalPeek (Index : integer ; Tag : string) return ListPointerType is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
--!! LocalPeek does this, but so do each of the indexed calls
--!!      if LocalOutOfRange(Index, "Peek") then 
--!!        return NULL ; -- error reporting in LocalOutOfRange
--!!      end if ; 
      if HeadPointer(Index) = NULL then
        ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
        Alert(AlertLogIDVar(Index), GetName & " Empty during Peek", FAILURE) ; 
        return NULL ;
      end if ;
      -- Descend to find Tag field and extract
      CurPtr := HeadPointer(Index) ;
      if CurPtr.TagPtr.all = Tag then 
        -- Non-tagged scoreboards find this one.
        return CurPtr ; 
      else 
        loop 
          if CurPtr.NextPtr = NULL then
            ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
            Alert(AlertLogIDVar(Index), GetName & " Peek, tag: " & Tag & " not found", FAILURE) ; 
            return NULL ; 
          elsif CurPtr.NextPtr.TagPtr.all = Tag then 
            return CurPtr ; 
          else
            CurPtr := CurPtr.NextPtr ;
          end if ; 
        end loop ;
      end if ;
    end function LocalPeek ; 

    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    procedure Peek (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string ;
      variable Item   : out ExpectedType
    ) is
      variable CurPtr : ListPointerType ;
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
    -- Array of Scoreboards, no tag
    procedure Peek (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      variable Item   : out  ExpectedType
    ) is
      variable CurPtr : ListPointerType ;
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
    -- Simple Tagged Scoreboard
    procedure Peek (
    ------------------------------------------------------------
      constant Tag    : in  string ;
      variable Item   : out  ExpectedType
    ) is
      variable CurPtr : ListPointerType ;
    begin
      CurPtr := LocalPeek(FirstIndexVar, Tag) ; 
      if CurPtr /= NULL then 
        Item := CurPtr.ExpectedPtr.all ;
      end if ; 
    end procedure Peek ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    procedure Peek (variable Item : out  ExpectedType) is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
      CurPtr := LocalPeek(FirstIndexVar, "") ; 
      if CurPtr /= NULL then 
        Item := CurPtr.ExpectedPtr.all ;
      end if ; 
    end procedure Peek ;
    
    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    impure function Peek (
    ------------------------------------------------------------
      constant Index  : in  integer ;
      constant Tag    : in  string       
    ) return ExpectedType is
      variable CurPtr : ListPointerType ;
    begin
      if LocalOutOfRange(Index, "Peek") then 
        -- error reporting in LocalOutOfRange
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ; 
      end if ; 
      CurPtr := LocalPeek(Index, Tag) ; 
      if CurPtr /= NULL then 
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ;
      end if ; 
    end function Peek ;

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    impure function Peek (Index : integer) return ExpectedType is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
      if LocalOutOfRange(Index, "Peek") then 
        -- error reporting in LocalOutOfRange
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ; 
      end if ; 
      CurPtr := LocalPeek(Index, "") ; 
      if CurPtr /= NULL then 
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ;
      end if ; 
    end function Peek ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Peek (
    ------------------------------------------------------------
      constant Tag : in  string       
    ) return ExpectedType is
      variable CurPtr : ListPointerType ;
    begin
      CurPtr := LocalPeek(FirstIndexVar, Tag) ; 
      if CurPtr /= NULL then 
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ;
      end if ; 
    end function Peek ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Peek return ExpectedType is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
      CurPtr := LocalPeek(FirstIndexVar, "") ; 
      if CurPtr /= NULL then 
        return CurPtr.ExpectedPtr.all ;
      else
        -- Already issued failure, continuing for debug only
        return PopListPointer(FirstIndexVar).ExpectedPtr.all ;
      end if ; 
    end function Peek ;

    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    impure function Empty (Index  : integer; Tag : String) return boolean is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
      CurPtr := HeadPointer(Index) ;      
      while CurPtr /= NULL loop
        if CurPtr.TagPtr.all = Tag then 
          return FALSE ;   -- Found Tag
        end if ; 
        CurPtr := CurPtr.NextPtr ; 
      end loop ;
      return TRUE ;  -- Tag not found
    end function Empty ;

    ------------------------------------------------------------
    -- Array of Scoreboards, no tag
    impure function Empty (Index  : integer) return boolean is
    ------------------------------------------------------------
    begin
      return HeadPointer(Index) = NULL ;
    end function Empty ;

    ------------------------------------------------------------
    -- Simple Tagged Scoreboard
    impure function Empty (Tag : String) return boolean is
    ------------------------------------------------------------
      variable CurPtr : ListPointerType ;
    begin
      return Empty(FirstIndexVar, Tag) ;
    end function Empty ;

    ------------------------------------------------------------
    -- Simple Scoreboard, no tag
    impure function Empty return boolean is
    ------------------------------------------------------------
    begin
      return HeadPointer(FirstIndexVar) = NULL ;
    end function Empty ;

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
      if AlertLogIDVar(Index) = OSVVM_SCOREBOARD_ALERTLOG_ID  then 
        write(WriteBuf, GetName(DefaultName => "Scoreboard")) ; 
      else
        write(WriteBuf, GetName(DefaultName => "")) ; 
      end if ; 
      if ArrayLengthVar > 1 then 
        if WriteBuf.all /= "" then 
          swrite(WriteBuf, " ") ; 
        end if ; 
        write(WriteBuf, "Index(" & to_string(Index) & "),  ") ; 
      else
        if WriteBuf.all /= "" then 
          swrite(WriteBuf, ",  ") ; 
        end if ; 
      end if ; 
      if FinishEmpty then 
        AffirmIf(AlertLogIDVar(Index), Empty(Index), WriteBuf.all & "Checking Empty: " & to_string(Empty(Index)) & 
                 "  FinishEmpty: " & to_string(FinishEmpty)) ; 
        if not Empty(Index) then 
          -- Increment internal count on FinishEmpty Error
          ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
        end if ; 
      end if ; 
      AffirmIf(AlertLogIDVar(Index), CheckCountVar(Index) >= FinishCheckCount, WriteBuf.all & 
                 "Checking CheckCount: " & to_string(CheckCountVar(Index)) & 
                 " >= Expected: " & to_string(FinishCheckCount))  ;
      if not (CheckCountVar(Index) >= FinishCheckCount) then 
        -- Increment internal count on FinishCheckCount Error
        ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
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
      for AlertLogID in AlertLogIDVar'range loop 
        CheckFinish(AlertLogID, FinishCheckCount, FinishEmpty) ; 
      end loop ;
    end procedure CheckFinish ; 
    
    ------------------------------------------------------------
    impure function GetErrorCount (Index : integer)  return integer is
    ------------------------------------------------------------
    begin
      return ErrCntVar(Index) ;
    end function GetErrorCount ;

    ------------------------------------------------------------
    impure function GetErrorCount return integer is
    ------------------------------------------------------------
      variable TotalErrorCount : integer := 0 ; 
    begin
      for Index in AlertLogIDVar'range loop 
        TotalErrorCount := TotalErrorCount + GetErrorCount(Index) ; 
      end loop ;
      return TotalErrorCount ; 
    end function GetErrorCount ;
    
    ------------------------------------------------------------
    procedure IncErrorCount (Index  : integer) is
    ------------------------------------------------------------
    begin
      ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
      IncAlertCount(AlertLogIDVar(Index), ERROR) ; 
    end IncErrorCount ;

    ------------------------------------------------------------
    procedure IncErrorCount is
    ------------------------------------------------------------
    begin
      ErrCntVar(FirstIndexVar) := ErrCntVar(FirstIndexVar) + 1 ;
      IncAlertCount(AlertLogIDVar(FirstIndexVar), ERROR) ; 
    end IncErrorCount ;
    
    ------------------------------------------------------------
    procedure SetErrorCountZero (Index  : integer) is
    ------------------------------------------------------------
    begin
      ErrCntVar(Index) := 0;
    end procedure SetErrorCountZero ;

    ------------------------------------------------------------
    procedure SetErrorCountZero is
    ------------------------------------------------------------
    begin
      ErrCntVar(FirstIndexVar) := 0 ;
    end procedure SetErrorCountZero ;

    ------------------------------------------------------------
    procedure SetCheckCountZero (Index  : integer) is
    ------------------------------------------------------------
    begin
      CheckCountVar(Index) := 0;
    end procedure SetCheckCountZero ;

    ------------------------------------------------------------
    procedure SetCheckCountZero is
    ------------------------------------------------------------
    begin
      CheckCountVar(FirstIndexVar) := 0;
    end procedure SetCheckCountZero ;

    ------------------------------------------------------------
    impure function GetItemCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return ItemNumberVar(Index) ; 
    end function GetItemCount ; 

    ------------------------------------------------------------
    impure function GetItemCount return integer is
    ------------------------------------------------------------
    begin
      return ItemNumberVar(FirstIndexVar) ; 
    end function GetItemCount ; 

    ------------------------------------------------------------
    impure function GetPushCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return ItemNumberVar(Index) ; 
    end function GetPushCount ; 

    ------------------------------------------------------------
    impure function GetPushCount return integer is
    ------------------------------------------------------------
    begin
      return ItemNumberVar(FirstIndexVar) ; 
    end function GetPushCount ; 

    ------------------------------------------------------------
    impure function GetPopCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return PopCountVar(Index) ; 
    end function GetPopCount ; 

    ------------------------------------------------------------
    impure function GetPopCount return integer is
    ------------------------------------------------------------
    begin
      return PopCountVar(FirstIndexVar) ; 
    end function GetPopCount ; 
    
    ------------------------------------------------------------
    impure function GetFifoCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return ItemNumberVar(Index) - PopCountVar(Index) - DropCountVar(Index) ; 
    end function GetFifoCount ; 

    ------------------------------------------------------------
    impure function GetFifoCount return integer is
    ------------------------------------------------------------
    begin
      return GetFifoCount(FirstIndexVar) ; 
    end function GetFifoCount ; 
    
    ------------------------------------------------------------
    impure function GetCheckCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return CheckCountVar(Index) ; 
    end function GetCheckCount ; 

    ------------------------------------------------------------
    impure function GetCheckCount return integer is
    ------------------------------------------------------------
    begin
      return CheckCountVar(FirstIndexVar) ; 
    end function GetCheckCount ; 
    
    ------------------------------------------------------------
    impure function GetDropCount (Index  : integer) return integer is
    ------------------------------------------------------------
    begin
      return DropCountVar(Index) ; 
    end function GetDropCount ; 

    ------------------------------------------------------------
    impure function GetDropCount return integer is
    ------------------------------------------------------------
    begin
      return DropCountVar(FirstIndexVar) ; 
    end function GetDropCount ; 

    ------------------------------------------------------------
    procedure SetFinish (
    ------------------------------------------------------------
      Index       : integer ; 
      FCheckCount : integer ; 
      FEmpty      : boolean := TRUE; 
      FStatus     : boolean := TRUE
    ) is 
    begin
      Alert(AlertLogIDVar(Index), "OSVVM.ScoreboardGenericPkg.SetFinish: Deprecated and removed.  See CheckFinish", ERROR) ; 
    end procedure SetFinish ; 
    
    ------------------------------------------------------------
    procedure SetFinish (
    ------------------------------------------------------------
      FCheckCount : integer ; 
      FEmpty      : boolean := TRUE; 
      FStatus     : boolean := TRUE
    ) is 
    begin
      SetFinish(FirstIndexVar, FCheckCount, FEmpty, FStatus) ; 
    end procedure SetFinish ; 
    
    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    -- Find Element with Matching Tag and ActualData 
    -- Returns integer'left if no match found
    impure function Find (
    ------------------------------------------------------------
      constant Index       :  in  integer ; 
      constant Tag         :  in  string; 
      constant ActualData  :  in  ActualType 
    ) return integer is
      variable CurPtr : ListPointerType ;
    begin
      if LocalOutOfRange(Index, "Find") then 
        return integer'left ; -- error reporting in LocalOutOfRange
      end if ; 
      CurPtr := HeadPointer(Index) ; 
      loop 
        if CurPtr = NULL then 
          -- Failed to find it
          ErrCntVar(Index) := ErrCntVar(Index) + 1 ;
          if Tag /= "" then 
            Alert(AlertLogIDVar(Index), 
                  GetName & " Did not find Tag: " & Tag & " and Actual Data: " & actual_to_string(ActualData),
                  FAILURE ) ; 
          else 
            Alert(AlertLogIDVar(Index), 
                  GetName & " Did not find Actual Data: " & actual_to_string(ActualData),
                  FAILURE ) ; 
          end if ;
          return integer'left ;
          
        elsif CurPtr.TagPtr.all = Tag and 
          Match(ActualData, CurPtr.ExpectedPtr.all) then 
          -- Found it.  Return Index.
          return CurPtr.ItemNumber ; 
          
        else  -- Descend
          CurPtr := CurPtr.NextPtr ; 
        end if ; 
      end loop ;
    end function Find ; 
    
    ------------------------------------------------------------
    -- Array of Simple Scoreboards
    -- Find Element with Matching ActualData 
    impure function Find (
    ------------------------------------------------------------
      constant Index       :  in  integer ; 
      constant ActualData  :  in  ActualType 
    ) return integer is
    begin
      return Find(Index, "", ActualData) ; 
    end function Find ; 

    ------------------------------------------------------------
    -- Tagged Scoreboard
    -- Find Element with Matching ActualData 
    impure function Find (
    ------------------------------------------------------------
      constant Tag         :  in  string; 
      constant ActualData  :  in  ActualType 
    ) return integer is
    begin
      return Find(FirstIndexVar, Tag, ActualData) ; 
    end function Find ; 

    ------------------------------------------------------------
    -- Simple Scoreboard
    -- Find Element with Matching ActualData 
    impure function Find (
    ------------------------------------------------------------
      constant ActualData  :  in  ActualType 
    ) return integer is
    begin
      return Find(FirstIndexVar, "", ActualData) ; 
    end function Find ; 

    ------------------------------------------------------------
    -- Array of Tagged Scoreboards
    -- Flush Remove elements with tag whose itemNumber is <= ItemNumber parameter
    procedure Flush (
    ------------------------------------------------------------
      constant Index       :  in  integer ; 
      constant Tag         :  in  string ; 
      constant ItemNumber  :  in  integer 
    ) is
      variable CurPtr, RemovePtr, LastPtr : ListPointerType ;
    begin
      if LocalOutOfRange(Index, "Find") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      CurPtr  := HeadPointer(Index) ; 
      LastPtr := NULL ; 
      loop 
        if CurPtr = NULL then 
          -- Done
          return ; 
        elsif CurPtr.TagPtr.all = Tag then
          if ItemNumber >= CurPtr.ItemNumber then
            -- remove it 
            RemovePtr := CurPtr ; 
            if CurPtr = TailPointer(Index) then 
              TailPointer(Index) := LastPtr ; 
            end if ; 
            if CurPtr = HeadPointer(Index) then 
              HeadPointer(Index) := CurPtr.NextPtr ;
            else -- if LastPtr /= NULL then 
              LastPtr.NextPtr := LastPtr.NextPtr.NextPtr ; 
            end if ; 
            CurPtr := CurPtr.NextPtr ; 
            -- LastPtr := LastPtr ; -- no change
            DropCountVar(Index) := DropCountVar(Index) + 1 ; 
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
    -- Tagged Scoreboard
    -- Flush Remove elements with tag whose itemNumber is <= ItemNumber parameter
    procedure Flush (
    ------------------------------------------------------------
      constant Tag         :  in  string ; 
      constant ItemNumber  :  in  integer 
    ) is
    begin
      Flush(FirstIndexVar, Tag, ItemNumber) ;
    end procedure Flush ; 
    
    ------------------------------------------------------------
    -- Array of Simple Scoreboards
    -- Flush - Remove Elements upto and including the one with ItemNumber 
    procedure Flush (
    ------------------------------------------------------------
      constant Index       :  in  integer ; 
      constant ItemNumber  :  in  integer 
    ) is
      variable CurPtr : ListPointerType ;
    begin
      if LocalOutOfRange(Index, "Find") then 
        return ; -- error reporting in LocalOutOfRange
      end if ; 
      CurPtr  := HeadPointer(Index) ; 
      loop 
        if CurPtr = NULL then 
          -- Done
          return ; 
        elsif ItemNumber >= CurPtr.ItemNumber then
          -- Descend, Check Tail, Deallocate 
          HeadPointer(Index) := HeadPointer(Index).NextPtr ; 
          if CurPtr = TailPointer(Index) then 
            TailPointer(Index) := NULL ; 
          end if ; 
          DropCountVar(Index) := DropCountVar(Index) + 1 ; 
          deallocate(CurPtr.TagPtr) ; 
          deallocate(CurPtr.ExpectedPtr) ; 
          deallocate(CurPtr) ; 
          CurPtr := HeadPointer(Index) ; 
        else
          -- Done
          return ; 
        end if ; 
      end loop ;
    end procedure Flush ; 

    ------------------------------------------------------------
    -- Simple Scoreboard
    -- Flush - Remove Elements upto and including the one with ItemNumber 
    procedure Flush (
    ------------------------------------------------------------
      constant ItemNumber  :  in  integer 
    ) is
    begin
      Flush(FirstIndexVar, ItemNumber) ;
    end procedure Flush ; 
    
    
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
      write(buf, NAME_PREFIX & "- Name:         " & '"' & string'(GetAlertLogName(AlertLogIDVar(Index))) & '"' & LF) ; 
      write(buf, NAME_PREFIX & "  ItemCount:    " & '"' & to_string(ItemNumberVar(Index))       & '"' & LF) ; 
      write(buf, NAME_PREFIX & "  ErrorCount:   " & '"' & to_string(ErrCntVar(Index))           & '"' & LF) ; 
      write(buf, NAME_PREFIX & "  ItemsChecked: " & '"' & to_string(CheckCountVar(Index))       & '"' & LF) ; 
      write(buf, NAME_PREFIX & "  ItemsPopped:  " & '"' & to_string(PopCountVar(Index))         & '"' & LF) ; 
      write(buf, NAME_PREFIX & "  ItemsDropped: " & '"' & to_string(DropCountVar(Index))        & '"' & LF) ; 

      writeline(CovYamlFile, buf) ;
    end procedure WriteScoreboardYaml ;

    ------------------------------------------------------------
    procedure WriteScoreboardYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := IfElse(FileName = "", REPORTS_DIRECTORY & GetAlertLogName & "_sb.yml", FileName) ; 
      file SbYamlFile : text open OpenKind is RESOLVED_FILE_NAME ;
      variable buf : line ;
    begin
      if AlertLogIDVar = NULL or AlertLogIDVar'length <= 0 then
        Alert("Scoreboard.WriteScoreboardYaml: no scoreboards defined ", ERROR) ;
        return ; 
      end if ; 
      
      swrite(buf, "Version: 1.0" & LF) ; 
      swrite(buf, "TestCase: " & '"' & GetAlertLogName & '"' & LF) ; 
      swrite(buf, "Scoreboards: ") ; 
      writeline(SbYamlFile, buf) ; 
      if CalledNewID then 
        -- Used by singleton
        for i in 1 to NumItems loop
          WriteScoreboardYaml(i, SbYamlFile) ; 
        end loop ; 
      else
        -- Used by PT method, but not singleton
        for i in AlertLogIDVar'range loop
          WriteScoreboardYaml(i, SbYamlFile) ; 
        end loop ; 
      end if ; 
      file_close(SbYamlFile) ;
    end procedure WriteScoreboardYaml ;
    
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Remaining Deprecated.     
    ------------------------------------------------------------
    ------------------------------------------------------------

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
      return GetItemCount(FirstIndexVar) ;
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
    
--!!    ------------------------------------------------------------
--!!    -- Deprecated Call to NewID, refactored to call new version of NewID
--!!    impure function NewID (Name : String ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDType is
--!!    ------------------------------------------------------------
--!!      variable ReportMode : AlertLogReportModeType ;
--!!    begin
--!!      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
--!!      return NewID(Name, ParentAlertLogID, ReportMode => ReportMode) ; 
--!!    end function NewID ;
--!!
--!!    ------------------------------------------------------------
--!!    -- Deprecated Call to NewID, refactored to call new version of NewID
--!!    -- Vector: 1 to Size
--!!    impure function NewID (Name : String ; Size : positive ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType is
--!!    ------------------------------------------------------------
--!!      variable ReportMode : AlertLogReportModeType ;
--!!    begin
--!!      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
--!!      return NewID(Name, (1, Size) , ParentAlertLogID, ReportMode => ReportMode) ; 
--!!    end function NewID ;
--!!
--!!    ------------------------------------------------------------
--!!    -- Deprecated Call to NewID, refactored to call new version of NewID
--!!    -- Vector: X(X'Left) to X(X'Right)
--!!    impure function NewID (Name : String ; X : integer_vector ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIDArrayType is
--!!    ------------------------------------------------------------
--!!      variable ReportMode     : AlertLogReportModeType ;
--!!    begin
--!!      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
--!!      return NewID(Name, X, ParentAlertLogID, ReportMode => ReportMode) ; 
--!!    end function NewID ;
--!!
--!!    ------------------------------------------------------------
--!!    -- Deprecated Call to NewID, refactored to call new version of NewID
--!!    -- Matrix: 1 to X, 1 to Y
--!!    impure function NewID (Name : String ; X, Y : positive ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType is
--!!    ------------------------------------------------------------
--!!      variable ReportMode     : AlertLogReportModeType ;
--!!    begin
--!!      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
--!!      return NewID(Name, X, Y, ParentAlertLogID, ReportMode => ReportMode) ; 
--!!    end function NewID ;        
--!!     
--!!    ------------------------------------------------------------
--!!    -- Deprecated Call to NewID, refactored to call new version of NewID
--!!    -- Matrix: X(X'Left) to X(X'Right), Y(Y'Left) to Y(Y'Right)
--!!    impure function NewID (Name : String ; X, Y : integer_vector ; ParentAlertLogID : AlertLogIDType; DoNotReport : Boolean) return ScoreboardIdMatrixType is
--!!    ------------------------------------------------------------
--!!      variable ReportMode     : AlertLogReportModeType ;
--!!    begin
--!!      ReportMode := ENABLED when not DoNotReport else DISABLED ;  
--!!      return NewID(Name, X, Y, ParentAlertLogID, ReportMode => ReportMode) ; 
--!!    end function NewID ; 
        
  end protected body ScoreBoardPType ;
  
  shared variable ScoreboardStore : ScoreBoardPType ;
  
  ------------------------------------------------------------
  -- Used by Scoreboard Store
  impure function NewID (
    Name          : String ; 
    ParentID      : AlertLogIDType          := OSVVM_SCOREBOARD_ALERTLOG_ID ;
    ReportMode    : AlertLogReportModeType  := ENABLED ; 
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
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
    Search        : NameSearchType          := NAME_AND_PARENT_ELSE_PRIVATE ;
    PrintParent   : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return ScoreboardIdMatrixType is
  ------------------------------------------------------------
  begin
    return ScoreboardStore.NewID(Name, X, Y, ParentID, ReportMode, Search, PrintParent) ; 
  end function NewID ; 
  

  
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
  -- Pop the top item (FIFO) from the scoreboard/FIFO
  -- Caution:  this did not work in older simulators (@2013)

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
  -- Peek at the top item (FIFO) from the scoreboard/FIFO
  -- Caution:  this did not work in older simulators (@2013)
  
  -- Tagged Scoreboards
  impure function Peek (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string       
  ) return ExpectedType is
  begin
--      return ScoreboardStore.Peek(Tag) ;
    log("Issues compiling return later");
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
  impure function ScoreboardEmpty (
    constant ID     : in  ScoreboardIDType 
  ) return boolean is
  begin
    return ScoreboardStore.Empty(ID.ID) ; 
  end function ScoreboardEmpty ;
  
  -- Tagged 
  impure function ScoreboardEmpty (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string       
  ) return boolean is
  begin
    return ScoreboardStore.Empty(ID.ID, Tag) ; 
  end function ScoreboardEmpty ;
  
  impure function Empty (
    constant ID     : in  ScoreboardIDType 
  ) return boolean is
  begin
    return ScoreboardStore.Empty(ID.ID) ; 
  end function Empty ;
  
  -- Tagged 
  impure function Empty (
    constant ID     : in  ScoreboardIDType ;
    constant Tag    : in  string       
  ) return boolean is
  begin
    return ScoreboardStore.Empty(ID.ID, Tag) ; 
  end function Empty ;
  
--!!  ------------------------------------------------------------
--!!  -- SetAlertLogID - associate an AlertLogID with a scoreboard to allow integrated error reporting
--!!  procedure SetAlertLogID(
--!!    constant ID              : in  ScoreboardIDType ;
--!!    constant Name            : in  string ; 
--!!    constant ParentID        : in  AlertLogIDType := OSVVM_SCOREBOARD_ALERTLOG_ID ; 
--!!    constant CreateHierarchy : in  Boolean := TRUE ;
--!!    constant DoNotReport     : in  Boolean := FALSE
--!!  ) is
--!!  begin
--!!    ScoreboardStore.SetAlertLogID(ID.ID, Name, ParentID, CreateHierarchy, DoNotReport) ; 
--!!  end procedure SetAlertLogID ;
--!!
--!!  -- Use when an AlertLogID is used by multiple items (Model or other Scoreboards).  See also AlertLogPkg.GetAlertLogID
--!!  procedure SetAlertLogID (
--!!    constant ID     : in  ScoreboardIDType ;
--!!    constant A      : AlertLogIDType
--!!  ) is
--!!  begin
--!!    ScoreboardStore.SetAlertLogID(ID.ID, A) ; 
--!!  end procedure SetAlertLogID ; 
    
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
  -- Scoreboard YAML Reports
  impure function GotScoreboards return boolean is
  begin
    return ScoreboardStore.GotScoreboards ; 
  end function GotScoreboards ; 
  
  ------------------------------------------------------------
  procedure WriteScoreboardYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE) is
  begin
    ScoreboardStore.WriteScoreboardYaml(FileName, OpenKind) ; 
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
  -- Not AlertFlow
  --     REPORT_ALL:     Replaced by AlertLogPkg.SetLogEnable(PASSED, TRUE)
  --     REPORT_ERROR:   Replaced by AlertLogPkg.SetLogEnable(PASSED, FALSE)
  --     REPORT_NONE:    Deprecated, do not use.
  -- AlertFlow:      
  --     REPORT_ALL:     Replaced by AlertLogPkg.SetLogEnable(AlertLogID, PASSED, TRUE)
  --     REPORT_ERROR:   Replaced by AlertLogPkg.SetLogEnable(AlertLogID, PASSED, FALSE)
  --     REPORT_NONE:    Replaced by AlertLogPkg.SetAlertEnable(AlertLogID, ERROR, FALSE)
  procedure SetReportMode (
    constant ID           : in  ScoreboardIDType ;
    constant ReportModeIn : in  ScoreboardReportType
  ) is
  begin
--    ScoreboardStore.SetReportMode(ID.ID, ReportModeIn) ; 
	ScoreboardStore.SetReportMode(ReportModeIn) ; 
  end procedure SetReportMode ; 
  
  impure function GetReportMode (
    constant ID           : in  ScoreboardIDType
  ) return ScoreboardReportType is
  begin
--    return ScoreboardStore.GetReportMode(ID.ID) ; 
	return ScoreboardStore.GetReportMode ; 
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

  
end ScoreBoardPkg_int ;