--
--  File Name:         BurstCoveragePkg.vhd
--  Design Unit Name:  BurstCoveragePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Package Defines
--      Data structure for name. 
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2023   2023.05    Initial revision. 
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2023 by SynthWorks Design Inc.  
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
use work.TextUtilPkg.all ; 
use work.TbUtilPkg.all ; 
use work.ResolutionPkg.all ; 
use work.AlertLogPkg.all ; 
use work.CoveragePkg.all ; 
use work.NameStorePkg.all ;
use work.OsvvmScriptSettingsPkg.all ;

package BurstCoveragePkg is
 
  type BurstCoverageIDType is record
      ID             : integer_max ;
      BurstLengthCov : CoverageIDType ; 
      BurstDelayCov  : CoverageIDType ; 
      BeatDelayCov   : CoverageIDType ; 
  end record BurstCoverageIDType ; 
  
  type BurstCoverageIDArrayType is array (integer range <>) of BurstCoverageIDType ;  
  
  ------------------------------------------------------------
  --- ///////////////////////////////////////////////////////////////////////////
  ------------------------------------------------------------
  -- BurstCoverageIDType Overloading 
  ------------------------------------------------------------
  impure function NewID (
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return BurstCoverageIDType ;
  
  ------------------------------------------------------------
  impure function NewBurstCoverage ( 
    ID                  : Integer ;
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return BurstCoverageIDType ;

  impure function GetBurstCoverage(ID : integer) return BurstCoverageIDType ;
  procedure SetBurstCoverage ( ID : BurstCoverageIDType ) ;
  
  ------------------------------------------------------------
  impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer ;
  impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer_vector ;

  ------------------------------------------------------------
  procedure DeallocateBins ( ID : BurstCoverageIDType ) ;
  
  ------------------------------------------------------------
  --- ///////////////////////////////////////////////////////////////////////////
  ------------------------------------------------------------
  -- BurstCoverageIDArrayType Overloading 
  ------------------------------------------------------------
  impure function NewID (
    Name                : string ;
    Size                : positive ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    Name1               : string                  := "" ;
    Name2               : string                  := "" ;
    Name3               : string                  := "" ;
    Name4               : string                  := "" ;
    Name5               : string                  := "" ;
    Name6               : string                  := "" ;
    Name7               : string                  := "" ;
    Name8               : string                  := "" ;
    Name9               : string                  := "" ;
    Name10              : string                  := "" ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
  ) return BurstCoverageIDArrayType ;
  
  ------------------------------------------------------------
  impure function NewBurstCoverage ( 
    ID                  : Integer ;               -- Starting ID, and the ID's are consecutive
    Name                : String ;
    Size                : positive ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    Name1               : string                  := "" ;
    Name2               : string                  := "" ;
    Name3               : string                  := "" ;
    Name4               : string                  := "" ;
    Name5               : string                  := "" ;
    Name6               : string                  := "" ;
    Name7               : string                  := "" ;
    Name8               : string                  := "" ;
    Name9               : string                  := "" ;
    Name10              : string                  := "" ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
  ) return BurstCoverageIDArrayType ;

  impure function GetBurstCoverage(ID : integer;  Size : positive ) return BurstCoverageIDArrayType ;
  procedure SetBurstCoverage ( ID : BurstCoverageIDArrayType ) ;
  
  ------------------------------------------------------------
  procedure DeallocateBins ( ID : BurstCoverageIDArrayType ) ;
    
end package BurstCoveragePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body BurstCoveragePkg is

  type BurstCoveragePType is protected

    ------------------------------------------------------------
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    -- BurstCoverageIDType Overloading 
    ------------------------------------------------------------
    impure function NewID (
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return BurstCoverageIDType ;

    ------------------------------------------------------------
    impure function NewBurstCoverage ( 
      ID                  : Integer ;
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return BurstCoverageIDType ;

    impure function GetBurstCoverage(ID : integer) return BurstCoverageIDType ;
    procedure SetBurstCoverage ( ID : BurstCoverageIDType ) ;
    
    ------------------------------------------------------------
    impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer ;
    impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer_vector ;
    
    ------------------------------------------------------------
    procedure DeallocateBins ( ID : BurstCoverageIDType ) ;
    
    ------------------------------------------------------------
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    -- BurstCoverageIDArrayType Overloading 
    ------------------------------------------------------------
    impure function NewID (
      Name                : string ;
      Size                : positive ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      Name1               : string                  := "" ;
      Name2               : string                  := "" ;
      Name3               : string                  := "" ;
      Name4               : string                  := "" ;
      Name5               : string                  := "" ;
      Name6               : string                  := "" ;
      Name7               : string                  := "" ;
      Name8               : string                  := "" ;
      Name9               : string                  := "" ;
      Name10              : string                  := "" ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return BurstCoverageIDArrayType ;
    
    ------------------------------------------------------------
    impure function NewBurstCoverage ( 
      ID                  : Integer ;               -- Starting ID, and the ID's are consecutive
      Name                : String ;
      Size                : positive ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      Name1               : string                  := "" ;
      Name2               : string                  := "" ;
      Name3               : string                  := "" ;
      Name4               : string                  := "" ;
      Name5               : string                  := "" ;
      Name6               : string                  := "" ;
      Name7               : string                  := "" ;
      Name8               : string                  := "" ;
      Name9               : string                  := "" ;
      Name10              : string                  := "" ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return BurstCoverageIDArrayType ;

    impure function GetBurstCoverage(ID : integer;  Size : positive ) return BurstCoverageIDArrayType ;
    procedure SetBurstCoverage ( ID : BurstCoverageIDArrayType ) ;
    
    ------------------------------------------------------------
    procedure DeallocateBins ( ID : BurstCoverageIDArrayType ) ;
    
  end protected BurstCoveragePType ;


  type BurstCoveragePType is protected body
  
    type SingletonStructType is record
      BurstLengthCov    : CoverageIDType ; 
      BurstDelayCov     : CoverageIDType ; 
      BeatDelayCov      : CoverageIDType ; 
      BurstLength       : integer ; 
    end record SingletonStructType ;

    type  SingletonArrayType    is array (integer range <>) of SingletonStructType ; 
    type  SingletonArrayPtrType is access SingletonArrayType ;
    
    variable SingletonArrayPtr : SingletonArrayPtrType ;   
    variable NumItems          : integer := 0 ; 
    constant MIN_NUM_ITEMS     : integer := 32 ; -- Min amount to resize array
    variable LocalNameStore    : NameStorePType ;

    ------------------------------------------------------------
    -- Package Local
    function NormalizeArraySize( NewNumItems, MinNumItems : integer ) return integer is
    ------------------------------------------------------------
      variable NormNumItems : integer ;
      variable ModNumItems  : integer ;
    begin
      NormNumItems := NewNumItems ; 
      ModNumItems  := NewNumItems mod MinNumItems ; 
      if ModNumItems > 0 then 
        NormNumItems := NormNumItems + (MinNumItems - ModNumItems) ; 
      end if ; 
      return NormNumItems ; 
    end function NormalizeArraySize ;

    ------------------------------------------------------------
    -- Package Local
    procedure GrowNumberItems (
    ------------------------------------------------------------
      variable SingletonArrayPtr : InOut SingletonArrayPtrType ;
      variable NumItems          : InOut integer ;
      constant GrowAmount        : in    integer ;
      constant MinNumItems       : in    integer 
    ) is
      variable oldSingletonArrayPtr : SingletonArrayPtrType ;
      variable NewNumItems     : integer ;
      variable NewSize         : integer ;
    begin
      NewNumItems := NumItems + GrowAmount ; 
      NewSize     := NormalizeArraySize(NewNumItems, MinNumItems) ;
      if SingletonArrayPtr = NULL then
        SingletonArrayPtr := new SingletonArrayType(1 to NewSize) ;
      elsif NewNumItems > SingletonArrayPtr'length then
        oldSingletonArrayPtr := SingletonArrayPtr ;
        SingletonArrayPtr    := new SingletonArrayType(1 to NewSize) ;
        SingletonArrayPtr.all(1 to NumItems) := oldSingletonArrayPtr.all(1 to NumItems) ;
        deallocate(oldSingletonArrayPtr) ;
      end if ;
      NumItems := NewNumItems ; 
    end procedure GrowNumberItems ;

--    ------------------------------------------------------------
--    -- PT Local
--    impure function NewBurstCoverage ( 
--    ------------------------------------------------------------
--      ID                  : Integer ;
--      Name                : String ;
--      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
--      ReportMode          : AlertLogReportModeType  := ENABLED ;
--      Search              : NameSearchType          := PRIVATE_NAME ;
--      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
--    ) return BurstCoverageIDType is
--      variable NewCoverageID : BurstCoverageIDType ;
--    begin
--      SingletonArrayPtr(ID).BurstLengthCov := NewID(Name & ifelse(Name'length > 0, " ", "") & "BurstLength", ParentID, ReportMode, Search, PrintParent) ; 
--      SingletonArrayPtr(ID).BurstDelayCov  := NewID(Name & ifelse(Name'length > 0, " ", "") & "BurstDelay",  ParentID, ReportMode, Search, PrintParent) ; 
--      SingletonArrayPtr(ID).BeatDelayCov   := NewID(Name & ifelse(Name'length > 0, " ", "") & "BeatDelay",   ParentID, ReportMode, Search, PrintParent) ; 
--      SingletonArrayPtr(ID).BurstLength    := 0 ; 
--      return GetBurstCoverage( ID ) ; 
--    end function NewBurstCoverage ; 

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- BurstCoverageIDType Overloading 
    ------------------------------------------------------------
    impure function NewID (
    ------------------------------------------------------------
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return BurstCoverageIDType is
      variable NameID              : integer ;
      variable ResolvedSearch      : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
      variable NewCoverageID : BurstCoverageIDType ;
    begin
      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, PrintParent) ;

      NameID := LocalNameStore.find(Name, ParentID, ResolvedSearch) ;

      if NameID /= ID_NOT_FOUND.ID then
        -- Get the current existing information
        return GetBurstCoverage( NameID ) ;
      else
        -- Add New Coverage Model to Structure
        GrowNumberItems(SingletonArrayPtr, NumItems, 1, MIN_NUM_ITEMS) ;

        -- Add item to NameStore
        NameID := LocalNameStore.NewID(Name, ParentID, ResolvedSearch) ;
        AlertIfNotEqual(ParentID, NameID, NumItems, "BurstCoveragePkg: in " & Name & ", Index of LocalNameStore /= CoverageID") ;

        NewCoverageID := NewBurstCoverage( NumItems, Name, ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent ) ;
        SetBurstCoverage(NewCoverageID) ; 
        return NewCoverageID ; 
--        return NewBurstCoverage( NumItems, Name, ParentID, ReportMode, ResolveSearch, ResolvedPrintParent ) ;
      end if ;
    end function NewID ;

    ------------------------------------------------------------
    impure function NewBurstCoverage ( 
    ------------------------------------------------------------
      ID                  : Integer ;
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return BurstCoverageIDType is
      variable ResolvedSearch      : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
      variable NewCoverageID : BurstCoverageIDType ;
    begin
      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, PrintParent) ;

      NewCoverageID.ID := ID ;
      NewCoverageID.BurstLengthCov := NewID(Name & ifelse(Name'length > 0, " ", "") & "BurstLength", ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent) ; 
      SetCovWeight(NewCoverageID.BurstLengthCov, 0) ; 
      NewCoverageID.BurstDelayCov  := NewID(Name & ifelse(Name'length > 0, " ", "") & "BurstDelay",  ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent) ; 
      SetCovWeight(NewCoverageID.BurstDelayCov, 0) ; 
      NewCoverageID.BeatDelayCov   := NewID(Name & ifelse(Name'length > 0, " ", "") & "BeatDelay",   ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent) ; 
      SetCovWeight(NewCoverageID.BeatDelayCov, 0) ; 
      return NewCoverageID ; 
    end function NewBurstCoverage ; 

    ------------------------------------------------------------
    impure function GetBurstCoverage ( ID : integer ) return BurstCoverageIDType is
    ------------------------------------------------------------
      variable NewCoverageID : BurstCoverageIDType ;
    begin
      NewCoverageID.ID             := ID ; 
      NewCoverageID.BurstLengthCov := SingletonArrayPtr(ID).BurstLengthCov ; 
      NewCoverageID.BurstDelayCov  := SingletonArrayPtr(ID).BurstDelayCov  ; 
      NewCoverageID.BeatDelayCov   := SingletonArrayPtr(ID).BeatDelayCov   ; 
      return NewCoverageID ; 
    end function GetBurstCoverage ;
    
    ------------------------------------------------------------
    procedure SetBurstCoverage ( ID : BurstCoverageIDType ) is
    ------------------------------------------------------------
    begin
      SingletonArrayPtr(ID.ID).BurstLengthCov := ID.BurstLengthCov ; 
      SingletonArrayPtr(ID.ID).BurstDelayCov  := ID.BurstDelayCov  ; 
      SingletonArrayPtr(ID.ID).BeatDelayCov   := ID.BeatDelayCov   ; 
      SingletonArrayPtr(ID.ID).BurstLength    := 0 ; 
    end procedure SetBurstCoverage ;


--    ------------------------------------------------------------
--    impure function GetBurstCoverage ( ID : BurstCoverageIDType ) return BurstCoverageIDType is
--    ------------------------------------------------------------
--    begin
--      return GetBurstCoverage(ID.ID) ; 
--    end function GetBurstCoverage ;

    ------------------------------------------------------------
    -- PT Local
    impure function GetRandBurstDelayCov ( ID : BurstCoverageIDType ) return CoverageIDType is
    ------------------------------------------------------------
      variable DelayCov : CoverageIDType ; 
    begin 
      if SingletonArrayPtr(ID.ID).BurstLength < 1 then 
        DelayCov := SingletonArrayPtr(ID.ID).BurstDelayCov ; 
        SingletonArrayPtr(ID.ID).BurstLength := GetRandPoint(SingletonArrayPtr(ID.ID).BurstLengthCov) ; 
        ICoverLast(SingletonArrayPtr(ID.ID).BurstLengthCov) ; 
      else
        DelayCov := SingletonArrayPtr(ID.ID).BeatDelayCov ; 
      end if ; 
      SingletonArrayPtr(ID.ID).BurstLength := SingletonArrayPtr(ID.ID).BurstLength - 1; 
      return DelayCov ; 
    end function GetRandBurstDelayCov ; 

    ------------------------------------------------------------
    impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer is
    ------------------------------------------------------------
      variable DelayCov  : CoverageIDType ;
      variable RandIndex : integer ; 
    begin 
      DelayCov  := GetRandBurstDelayCov( ID ) ;
      RandIndex := GetRandIndex( DelayCov, CovTargetPercent => 0.0 ) ;   -- CovTargetPercent = 0.0 selects constrained random 
      ICoverLast( DelayCov ) ;
      return GetPoint( DelayCov, RandIndex ) ; 
--      return GetRandPoint( GetRandBurstDelayCov(ID), CoverLast => TRUE ) ; 
    end function GetRandBurstDelay ; 
    
    ------------------------------------------------------------
    impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer_vector is
    ------------------------------------------------------------
      variable DelayCov  : CoverageIDType ;
      variable RandIndex : integer ; 
    begin 
      DelayCov  := GetRandBurstDelayCov( ID ) ;
      RandIndex := GetRandIndex( DelayCov ) ; 
      ICoverLast( DelayCov ) ;
      return GetPoint( DelayCov, RandIndex ) ; 
--      return GetRandPoint( GetRandBurstDelayCov(ID), CoverLast => TRUE ) ; 
    end function GetRandBurstDelay ; 

    ------------------------------------------------------------
    procedure DeallocateBins ( ID : BurstCoverageIDType ) is
    ------------------------------------------------------------
    begin
      SingletonArrayPtr(ID.ID).BurstLength := 0 ; 
      DeallocateBins(SingletonArrayPtr(ID.ID).BurstLengthCov) ; 
      DeallocateBins(SingletonArrayPtr(ID.ID).BurstDelayCov) ; 
      DeallocateBins(SingletonArrayPtr(ID.ID).BeatDelayCov) ; 
    end procedure DeallocateBins ;
    
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- BurstCoverageIDArrayType Overloading 
    ------------------------------------------------------------
    impure function NewID (
    ------------------------------------------------------------
      Name                : string ;
      Size                : positive ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      Name1               : string                  := "" ;
      Name2               : string                  := "" ;
      Name3               : string                  := "" ;
      Name4               : string                  := "" ;
      Name5               : string                  := "" ;
      Name6               : string                  := "" ;
      Name7               : string                  := "" ;
      Name8               : string                  := "" ;
      Name9               : string                  := "" ;
      Name10              : string                  := "" ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return BurstCoverageIDArrayType is
      variable NewCoverageID : BurstCoverageIDArrayType(1 to Size) ;
    begin
      for i in NewCoverageID'range loop 
        case i is 
          when  1 => NewCoverageID(1)  := NewID(Name & ifelse(Name'length > 0 and Name1'length  > 0, " ", "") & Name1,  ParentID, ReportMode, Search, PrintParent) ; 
          when  2 => NewCoverageID(2)  := NewID(Name & ifelse(Name'length > 0 and Name2'length  > 0, " ", "") & Name2,  ParentID, ReportMode, Search, PrintParent) ; 
          when  3 => NewCoverageID(3)  := NewID(Name & ifelse(Name'length > 0 and Name3'length  > 0, " ", "") & Name3,  ParentID, ReportMode, Search, PrintParent) ; 
          when  4 => NewCoverageID(4)  := NewID(Name & ifelse(Name'length > 0 and Name4'length  > 0, " ", "") & Name4,  ParentID, ReportMode, Search, PrintParent) ; 
          when  5 => NewCoverageID(5)  := NewID(Name & ifelse(Name'length > 0 and Name5'length  > 0, " ", "") & Name5,  ParentID, ReportMode, Search, PrintParent) ; 
          when  6 => NewCoverageID(6)  := NewID(Name & ifelse(Name'length > 0 and Name6'length  > 0, " ", "") & Name6,  ParentID, ReportMode, Search, PrintParent) ; 
          when  7 => NewCoverageID(7)  := NewID(Name & ifelse(Name'length > 0 and Name7'length  > 0, " ", "") & Name7,  ParentID, ReportMode, Search, PrintParent) ; 
          when  8 => NewCoverageID(8)  := NewID(Name & ifelse(Name'length > 0 and Name8'length  > 0, " ", "") & Name8,  ParentID, ReportMode, Search, PrintParent) ; 
          when  9 => NewCoverageID(9)  := NewID(Name & ifelse(Name'length > 0 and Name9'length  > 0, " ", "") & Name9,  ParentID, ReportMode, Search, PrintParent) ; 
          when 10 => NewCoverageID(10) := NewID(Name & ifelse(Name'length > 0 and Name10'length > 0, " ", "") & Name10, ParentID, ReportMode, Search, PrintParent) ; 
          when others => NULL ; 
        end case ; 
      end loop ; 
      return NewCoverageID ; 
    end function NewID ;

--!! todo
--  --    -- insert an object into the data structure.   Updates the ID fields
--      impure function NewID( ID : BurstCoverageIDArrayType ) return BurstCoverageIDArrayType is 
--        variable NewCoverageID : BurstCoverageIDArrayType(ID'range) ;
--      begin
--        for i in ID'range loop 
--          NewCoverageID(i) := NewID(ID(i)) ; 
--        end loop ; 
--        return NewCoverageID ; 
--      end function NewID ; 


    ------------------------------------------------------------
    impure function NewBurstCoverage ( 
    ------------------------------------------------------------
      ID                  : Integer ;               -- Starting ID, and the ID's are consecutive
      Name                : String ;
      Size                : positive ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      Name1               : string                  := "" ;
      Name2               : string                  := "" ;
      Name3               : string                  := "" ;
      Name4               : string                  := "" ;
      Name5               : string                  := "" ;
      Name6               : string                  := "" ;
      Name7               : string                  := "" ;
      Name8               : string                  := "" ;
      Name9               : string                  := "" ;
      Name10              : string                  := "" ;
      ReportMode          : AlertLogReportModeType  := ENABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return BurstCoverageIDArrayType is
      variable NewCoverageID : BurstCoverageIDArrayType(1 to Size) ;
    begin
      for i in NewCoverageID'range loop 
        case i is 
          when  1 => NewCoverageID(1)  := NewBurstCoverage(ID,   Name & ifelse(Name'length > 0 and Name1'length  > 0, " ", "") & Name1,  ParentID, ReportMode, Search, PrintParent) ; 
          when  2 => NewCoverageID(2)  := NewBurstCoverage(ID+1, Name & ifelse(Name'length > 0 and Name2'length  > 0, " ", "") & Name2,  ParentID, ReportMode, Search, PrintParent) ; 
          when  3 => NewCoverageID(3)  := NewBurstCoverage(ID+2, Name & ifelse(Name'length > 0 and Name3'length  > 0, " ", "") & Name3,  ParentID, ReportMode, Search, PrintParent) ; 
          when  4 => NewCoverageID(4)  := NewBurstCoverage(ID+2, Name & ifelse(Name'length > 0 and Name4'length  > 0, " ", "") & Name4,  ParentID, ReportMode, Search, PrintParent) ; 
          when  5 => NewCoverageID(5)  := NewBurstCoverage(ID+4, Name & ifelse(Name'length > 0 and Name5'length  > 0, " ", "") & Name5,  ParentID, ReportMode, Search, PrintParent) ; 
          when  6 => NewCoverageID(6)  := NewBurstCoverage(ID+5, Name & ifelse(Name'length > 0 and Name6'length  > 0, " ", "") & Name6,  ParentID, ReportMode, Search, PrintParent) ; 
          when  7 => NewCoverageID(7)  := NewBurstCoverage(ID+6, Name & ifelse(Name'length > 0 and Name7'length  > 0, " ", "") & Name7,  ParentID, ReportMode, Search, PrintParent) ; 
          when  8 => NewCoverageID(8)  := NewBurstCoverage(ID+7, Name & ifelse(Name'length > 0 and Name8'length  > 0, " ", "") & Name8,  ParentID, ReportMode, Search, PrintParent) ; 
          when  9 => NewCoverageID(9)  := NewBurstCoverage(ID+8, Name & ifelse(Name'length > 0 and Name9'length  > 0, " ", "") & Name9,  ParentID, ReportMode, Search, PrintParent) ; 
          when 10 => NewCoverageID(10) := NewBurstCoverage(ID+9, Name & ifelse(Name'length > 0 and Name10'length > 0, " ", "") & Name10, ParentID, ReportMode, Search, PrintParent) ; 
          when others => NULL ; 
        end case ; 
      end loop ; 
      return NewCoverageID ; 
    end function NewBurstCoverage ; 

    ------------------------------------------------------------
    impure function GetBurstCoverage(ID : integer;  Size : positive ) return BurstCoverageIDArrayType is
    ------------------------------------------------------------
      variable NewCoverageID : BurstCoverageIDArrayType(0 to Size-1) ;
    begin
      for i in NewCoverageID'range loop 
        NewCoverageID(i) := GetBurstCoverage(ID+i) ; 
      end loop ; 
      return NewCoverageID ; 
    end function GetBurstCoverage ;
    
    ------------------------------------------------------------
    procedure SetBurstCoverage ( ID : BurstCoverageIDArrayType ) is
    ------------------------------------------------------------
    begin
      for i in ID'range loop 
        SetBurstCoverage(ID(i)) ; 
      end loop ; 
    end procedure SetBurstCoverage ;

    ------------------------------------------------------------
    procedure DeallocateBins ( ID : BurstCoverageIDArrayType ) is
    ------------------------------------------------------------
    begin
      for i in ID'range loop 
        DeallocateBins(ID(i)) ; 
      end loop ; 
    end procedure DeallocateBins ;
  end protected body BurstCoveragePType ;
  

-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Singleton Data Structure
-- /////////////////////////////////////////
-- /////////////////////////////////////////
  shared variable BurstCoverage : BurstCoveragePType ; 
  
  ------------------------------------------------------------
  impure function NewID (
  ------------------------------------------------------------
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return BurstCoverageIDType is
  begin
    return BurstCoverage.NewID (Name, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  impure function NewBurstCoverage ( 
  ------------------------------------------------------------
    ID                  : Integer ;
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return BurstCoverageIDType is
  begin
    return BurstCoverage.NewBurstCoverage (ID, Name, ParentID, ReportMode, Search, PrintParent) ;
  end function NewBurstCoverage ; 

  ------------------------------------------------------------
  impure function GetBurstCoverage ( ID : integer ) return BurstCoverageIDType is
  ------------------------------------------------------------
  begin
    return BurstCoverage.GetBurstCoverage ( ID ) ;
  end function GetBurstCoverage ;

  ------------------------------------------------------------
  procedure SetBurstCoverage ( ID : BurstCoverageIDType ) is
  ------------------------------------------------------------
  begin
    BurstCoverage.SetBurstCoverage ( ID ) ;
  end procedure SetBurstCoverage ;

  ------------------------------------------------------------
  impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer is
  ------------------------------------------------------------
  begin
    return BurstCoverage.GetRandBurstDelay(ID) ;
  end function GetRandBurstDelay ;

  ------------------------------------------------------------
  impure function GetRandBurstDelay ( ID : BurstCoverageIDType ) return integer_vector is
  ------------------------------------------------------------
  begin
    return BurstCoverage.GetRandBurstDelay(ID) ;
  end function GetRandBurstDelay ;

  ------------------------------------------------------------
  procedure DeallocateBins(ID : BurstCoverageIDType) is
  ------------------------------------------------------------
  begin
    BurstCoverage.DeallocateBins(ID) ;
  end procedure DeallocateBins ;
  
  ------------------------------------------------------------
  --- ///////////////////////////////////////////////////////////////////////////
  ------------------------------------------------------------
  -- BurstCoverageIDArrayType Overloading 
  ------------------------------------------------------------
  impure function NewID (
  ------------------------------------------------------------
    Name                : string ;
    Size                : positive ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    Name1               : string                  := "" ;
    Name2               : string                  := "" ;
    Name3               : string                  := "" ;
    Name4               : string                  := "" ;
    Name5               : string                  := "" ;
    Name6               : string                  := "" ;
    Name7               : string                  := "" ;
    Name8               : string                  := "" ;
    Name9               : string                  := "" ;
    Name10              : string                  := "" ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
  ) return BurstCoverageIDArrayType is
  begin
    return BurstCoverage.NewID (
      Name, Size, ParentID, 
      Name1, Name2, Name3, Name4, Name5, Name6, Name7, Name8, Name9, Name10, 
      ReportMode, Search, PrintParent) ;
  end function NewID ;
  
  ------------------------------------------------------------
  impure function NewBurstCoverage ( 
  ------------------------------------------------------------
    ID                  : Integer ;               -- Starting ID, and the ID's are consecutive
    Name                : String ;
    Size                : positive ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    Name1               : string                  := "" ;
    Name2               : string                  := "" ;
    Name3               : string                  := "" ;
    Name4               : string                  := "" ;
    Name5               : string                  := "" ;
    Name6               : string                  := "" ;
    Name7               : string                  := "" ;
    Name8               : string                  := "" ;
    Name9               : string                  := "" ;
    Name10              : string                  := "" ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
  ) return BurstCoverageIDArrayType is
  begin
    return BurstCoverage.NewBurstCoverage (
      ID, Name, Size, ParentID, 
      Name1, Name2, Name3, Name4, Name5, Name6, Name7, Name8, Name9, Name10, 
      ReportMode, Search, PrintParent) ;
  end function NewBurstCoverage ; 

  ------------------------------------------------------------
  impure function GetBurstCoverage(ID : integer;  Size : positive ) return BurstCoverageIDArrayType is
  ------------------------------------------------------------
  begin
    return BurstCoverage.GetBurstCoverage ( ID, Size ) ;
  end function GetBurstCoverage ;

  ------------------------------------------------------------
  procedure SetBurstCoverage ( ID : BurstCoverageIDArrayType ) is
  ------------------------------------------------------------
  begin
    BurstCoverage.SetBurstCoverage ( ID ) ;
  end procedure SetBurstCoverage ;

  ------------------------------------------------------------
  procedure DeallocateBins ( ID : BurstCoverageIDArrayType ) is
  ------------------------------------------------------------
  begin
    BurstCoverage.DeallocateBins(ID) ;
  end procedure DeallocateBins ;


end package body BurstCoveragePkg ;