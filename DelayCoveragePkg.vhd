--
--  File Name:         DelayCoveragePkg.vhd
--  Design Unit Name:  DelayCoveragePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Description:
--     Implements a pattern for randomizing cycle based delays such as AXI's Valid and Ready 
--       
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    11/2024   2024.11    Added SetBurstLength.  SetDelayCoverage randomizes BurstLength if RandomSalt is set.
--    07/2024   2024.07    Added IsInitialized
--    05/2023   2023.05    Initial revision. 
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

use std.textio.all ;
use work.IfElsePkg.all ;
use work.TextUtilPkg.all ; 
use work.TbUtilPkg.all ; 
use work.ResolutionPkg.all ; 
use work.AlertLogPkg.all ; 
use work.CoveragePkg.all ; 
use work.NameStorePkg.all ;
use work.OsvvmScriptSettingsPkg.all ;
use work.RandomBasePkg.all ; 

package DelayCoveragePkg is
 
  type DelayCoverageIDType is record
      ID             : integer_max ;
      BurstLengthCov : CoverageIDType ; 
      BurstDelayCov  : CoverageIDType ; 
      BeatDelayCov   : CoverageIDType ; 
  end record DelayCoverageIDType ; 
  type DelayCoverageIDArrayType is array (integer range <>) of DelayCoverageIDType ;  

  constant DELAYCOVERAGE_ID_UNINITIALZED : DelayCoverageIDType := (ID => integer'low, others => COVERAGE_ID_UNINITIALZED) ; 
  
  ------------------------------------------------------------
  --- ///////////////////////////////////////////////////////////////////////////
  ------------------------------------------------------------
  -- DelayCoverageIDType Overloading 
  ------------------------------------------------------------
  impure function NewID (
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := DISABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DelayCoverageIDType ;
  
  ------------------------------------------------------------
  impure function NewDelayCoverage ( 
    ID                  : Integer ;
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := DISABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DelayCoverageIDType ;

  ------------------------------------------------------------
  impure function IsInitialized (ID : DelayCoverageIDType) return boolean ;

  ------------------------------------------------------------
  impure function GetDelayCoverage(ID : integer) return DelayCoverageIDType ;
  procedure SetDelayCoverage ( ID : DelayCoverageIDType ) ;
  procedure SetBurstLength ( ID : DelayCoverageIDType ; BurstLength : integer ) ;
  impure function GetBurstLength ( ID : DelayCoverageIDType ) return integer ;
  
  ------------------------------------------------------------
  impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer ;
  impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer_vector ;

  ------------------------------------------------------------
  procedure DeallocateBins ( ID : DelayCoverageIDType ) ;
  
  ------------------------------------------------------------
  --- ///////////////////////////////////////////////////////////////////////////
  ------------------------------------------------------------
------------------------------------------------------------
-- The following items currently in ALPHA development mode
-- They may be part of a future implementation, but they also may be removed.
-- They were anticipated as needed for Axi4 VC, but an alternate path was used.
-- They were removed for the official release.
------------------------------------------------------------
--!    -- DelayCoverageIDArrayType Overloading 
--!    ------------------------------------------------------------
--!  -- experimental
--!    impure function NewID (
--!      Name                : string ;
--!      Size                : positive ;
--!      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
--!      Name1               : string                  := "" ;
--!      Name2               : string                  := "" ;
--!      Name3               : string                  := "" ;
--!      Name4               : string                  := "" ;
--!      Name5               : string                  := "" ;
--!      Name6               : string                  := "" ;
--!      Name7               : string                  := "" ;
--!      Name8               : string                  := "" ;
--!      Name9               : string                  := "" ;
--!      Name10              : string                  := "" ;
--!      ReportMode          : AlertLogReportModeType  := DISABLED ;
--!      Search              : NameSearchType          := PRIVATE_NAME ;
--!      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
--!    ) return DelayCoverageIDArrayType ;
--!    
--!    ------------------------------------------------------------
--!  -- experimental
--!    impure function NewDelayCoverage ( 
--!      ID                  : Integer ;               -- Starting ID, and the ID's are consecutive
--!      Name                : String ;
--!      Size                : positive ;
--!      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
--!      Name1               : string                  := "" ;
--!      Name2               : string                  := "" ;
--!      Name3               : string                  := "" ;
--!      Name4               : string                  := "" ;
--!      Name5               : string                  := "" ;
--!      Name6               : string                  := "" ;
--!      Name7               : string                  := "" ;
--!      Name8               : string                  := "" ;
--!      Name9               : string                  := "" ;
--!      Name10              : string                  := "" ;
--!      ReportMode          : AlertLogReportModeType  := DISABLED ;
--!      Search              : NameSearchType          := PRIVATE_NAME ;
--!      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
--!    ) return DelayCoverageIDArrayType ;
--!  
--!  -- experimental, Removed during dev as it assumes the IDs are consecutive - which they may or may not be.
--!  --   impure function GetDelayCoverage(ID : integer;  Size : positive ) return DelayCoverageIDArrayType ; 
--!  -- experimental
--!    procedure SetDelayCoverage ( ID : DelayCoverageIDArrayType ) ; 
--!    
--!    ------------------------------------------------------------
--!    procedure DeallocateBins ( ID : DelayCoverageIDArrayType ) ;
    
    
  -- Backward compatible with Beta Dev names
  subtype BurstCoverageIDType is DelayCoverageIDType ; 
  subtype BurstCoverageIDArrayType is DelayCoverageIDArrayType ; 

  alias NewBurstCoverage is NewDelayCoverage [
    Integer, String, AlertLogIDType, AlertLogReportModeType, NameSearchType, AlertLogPrintParentType return DelayCoverageIDType] ;

  alias GetBurstCoverage is GetDelayCoverage[integer return DelayCoverageIDType] ;
  alias SetBurstCoverage is SetDelayCoverage[DelayCoverageIDType] ;
  
  alias GetRandBurstDelay is GetRandDelay [DelayCoverageIDType return integer] ;
  alias GetRandBurstDelay is GetRandDelay [DelayCoverageIDType return integer_vector] ;

end package DelayCoveragePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body DelayCoveragePkg is

  type DelayCoveragePType is protected

    ------------------------------------------------------------
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    -- DelayCoverageIDType Overloading 
    ------------------------------------------------------------
    impure function NewID (
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return DelayCoverageIDType ;

    ------------------------------------------------------------
    impure function NewDelayCoverage ( 
      ID                  : Integer ;
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return DelayCoverageIDType ;

    ------------------------------------------------------------
    impure function IsInitialized (ID : DelayCoverageIDType) return boolean ;

    impure function GetDelayCoverage(ID : integer) return DelayCoverageIDType ;
    procedure SetDelayCoverage ( ID : DelayCoverageIDType ) ;
    procedure SetBurstLength ( ID : DelayCoverageIDType ; BurstLength : integer ) ;
    impure function GetBurstLength ( ID : DelayCoverageIDType ) return integer ;
    
    ------------------------------------------------------------
    impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer ;
    impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer_vector ;
    
    ------------------------------------------------------------
    procedure DeallocateBins ( ID : DelayCoverageIDType ) ;
    
    ------------------------------------------------------------
    --- ///////////////////////////////////////////////////////////////////////////
    ------------------------------------------------------------
    -- DelayCoverageIDArrayType Overloading 
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
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return DelayCoverageIDArrayType ;
    
    ------------------------------------------------------------
    impure function NewDelayCoverage ( 
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
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return DelayCoverageIDArrayType ;

    impure function GetDelayCoverage(ID : integer;  Size : positive ) return DelayCoverageIDArrayType ;
    procedure SetDelayCoverage ( ID : DelayCoverageIDArrayType ) ;
    
    ------------------------------------------------------------
    procedure DeallocateBins ( ID : DelayCoverageIDArrayType ) ;
    
  end protected DelayCoveragePType ;


  type DelayCoveragePType is protected body
  
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
--    impure function NewDelayCoverage ( 
--    ------------------------------------------------------------
--      ID                  : Integer ;
--      Name                : String ;
--      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
--      ReportMode          : AlertLogReportModeType  := DISABLED ;
--      Search              : NameSearchType          := PRIVATE_NAME ;
--      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
--    ) return DelayCoverageIDType is
--      variable NewCoverageID : DelayCoverageIDType ;
--    begin
--      SingletonArrayPtr(ID).BurstLengthCov := NewID(Name & ifelse(Name'length > 0, " ", "") & "BurstLength", ParentID, ReportMode, Search, PrintParent) ; 
--      SingletonArrayPtr(ID).BurstDelayCov  := NewID(Name & ifelse(Name'length > 0, " ", "") & "BurstDelay",  ParentID, ReportMode, Search, PrintParent) ; 
--      SingletonArrayPtr(ID).BeatDelayCov   := NewID(Name & ifelse(Name'length > 0, " ", "") & "BeatDelay",   ParentID, ReportMode, Search, PrintParent) ; 
--      SingletonArrayPtr(ID).BurstLength    := 0 ; 
--      return GetDelayCoverage( ID ) ; 
--    end function NewDelayCoverage ; 

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- DelayCoverageIDType Overloading 
    ------------------------------------------------------------
    impure function NewID (
    ------------------------------------------------------------
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return DelayCoverageIDType is
      variable NameID              : integer ;
      variable ResolvedSearch      : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
      variable NewCoverageID : DelayCoverageIDType ;
    begin
      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, PrintParent) ;

      NameID := LocalNameStore.find(Name, ParentID, ResolvedSearch) ;

      if NameID /= ID_NOT_FOUND.ID then
        -- Get the current existing information
        return GetDelayCoverage( NameID ) ;
      else
        -- Add New Coverage Model to Structure
        GrowNumberItems(SingletonArrayPtr, NumItems, 1, MIN_NUM_ITEMS) ;

        -- Add item to NameStore
        NameID := LocalNameStore.NewID(Name, ParentID, ResolvedSearch) ;
        AlertIfNotEqual(ParentID, NameID, NumItems, "DelayCoveragePkg: in " & Name & ", Index of LocalNameStore /= CoverageID") ;

        NewCoverageID := NewDelayCoverage( NumItems, Name, ParentID, ReportMode, ResolvedSearch, ResolvedPrintParent ) ;
        SetDelayCoverage(NewCoverageID) ; 
        return NewCoverageID ; 
--        return NewDelayCoverage( NumItems, Name, ParentID, ReportMode, ResolveSearch, ResolvedPrintParent ) ;
      end if ;
    end function NewID ;

    ------------------------------------------------------------
    impure function NewDelayCoverage ( 
    ------------------------------------------------------------
      ID                  : Integer ;
      Name                : String ;
      ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return DelayCoverageIDType is
      variable ResolvedSearch      : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
      variable NewCoverageID : DelayCoverageIDType ;
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
    end function NewDelayCoverage ; 
    
    ------------------------------------------------------------
    impure function IsInitialized (ID : DelayCoverageIDType) return boolean is
    ------------------------------------------------------------
    begin
      return ID /= DELAYCOVERAGE_ID_UNINITIALZED ;
    end function IsInitialized ;

    ------------------------------------------------------------
    impure function GetDelayCoverage ( ID : integer ) return DelayCoverageIDType is
    ------------------------------------------------------------
      variable NewCoverageID : DelayCoverageIDType ;
    begin
      NewCoverageID.ID             := ID ; 
      NewCoverageID.BurstLengthCov := SingletonArrayPtr(ID).BurstLengthCov ; 
      NewCoverageID.BurstDelayCov  := SingletonArrayPtr(ID).BurstDelayCov  ; 
      NewCoverageID.BeatDelayCov   := SingletonArrayPtr(ID).BeatDelayCov   ; 
      return NewCoverageID ; 
    end function GetDelayCoverage ;
    
    ------------------------------------------------------------
    procedure SetDelayCoverage ( ID : DelayCoverageIDType ) is
    ------------------------------------------------------------
    begin
      SingletonArrayPtr(ID.ID).BurstLengthCov := ID.BurstLengthCov ; 
      SingletonArrayPtr(ID.ID).BurstDelayCov  := ID.BurstDelayCov  ; 
      SingletonArrayPtr(ID.ID).BeatDelayCov   := ID.BeatDelayCov   ; 
      if GetRandomSalt /= 0 then 
        -- If RandomSalt set, randomize BurstLength
        SingletonArrayPtr(ID.ID).BurstLength    := ToRandPoint(ID.BurstLengthCov, (1 => (Min => 0, Max => 5))) ;  -- start with beat delay (1 to 5) vs burst delay (0)
      else
        -- If RandomSalt is not set, randomizaation would always produce the same value, so why not 0 the original behavior.
        SingletonArrayPtr(ID.ID).BurstLength    := 0 ; 
      end if ; 
    end procedure SetDelayCoverage ;

    ------------------------------------------------------------
    procedure SetBurstLength ( ID : DelayCoverageIDType ; BurstLength : integer ) is
    ------------------------------------------------------------
    begin
      SingletonArrayPtr(ID.ID).BurstLength    := BurstLength ;
    end procedure SetBurstLength ;

    ------------------------------------------------------------
    impure function GetBurstLength ( ID : DelayCoverageIDType ) return integer is
    ------------------------------------------------------------
    begin
      return SingletonArrayPtr(ID.ID).BurstLength ;
    end function GetBurstLength ;

--    ------------------------------------------------------------
--    impure function GetDelayCoverage ( ID : DelayCoverageIDType ) return DelayCoverageIDType is
--    ------------------------------------------------------------
--    begin
--      return GetDelayCoverage(ID.ID) ; 
--    end function GetDelayCoverage ;

    ------------------------------------------------------------
    -- PT Local
    impure function GetRandDelayCov ( ID : DelayCoverageIDType ) return CoverageIDType is
    ------------------------------------------------------------
      variable DelayCov : CoverageIDType ; 
    begin 
      if SingletonArrayPtr(ID.ID).BurstLength < 1 then 
        DelayCov := SingletonArrayPtr(ID.ID).BurstDelayCov ; 
        SingletonArrayPtr(ID.ID).BurstLength := GetRandPoint(SingletonArrayPtr(ID.ID).BurstLengthCov) ; 
        ICoverLast(SingletonArrayPtr(ID.ID).BurstLengthCov) ; 
      else
        DelayCov := SingletonArrayPtr(ID.ID).BeatDelayCov ; 
        SingletonArrayPtr(ID.ID).BurstLength := SingletonArrayPtr(ID.ID).BurstLength - 1; 
      end if ; 
      return DelayCov ; 
    end function GetRandDelayCov ; 

    ------------------------------------------------------------
    impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer is
    ------------------------------------------------------------
      variable DelayCov  : CoverageIDType ;
      variable RandIndex : integer ; 
    begin 
      DelayCov  := GetRandDelayCov( ID ) ;
      RandIndex := GetRandIndex( DelayCov ) ; 
      ICoverLast( DelayCov ) ;
      return GetPoint( DelayCov, RandIndex ) ; 
--      return GetRandPoint( GetRandDelayCov(ID), CoverLast => TRUE ) ; 
    end function GetRandDelay ; 
    
    ------------------------------------------------------------
    impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer_vector is
    ------------------------------------------------------------
      variable DelayCov  : CoverageIDType ;
      variable RandIndex : integer ; 
    begin 
      DelayCov  := GetRandDelayCov( ID ) ;
      RandIndex := GetRandIndex( DelayCov ) ; 
      ICoverLast( DelayCov ) ;
      return GetPoint( DelayCov, RandIndex ) ; 
--      return GetRandPoint( GetRandDelayCov(ID), CoverLast => TRUE ) ; 
    end function GetRandDelay ; 

--    ------------------------------------------------------------
--    procedure DeallocateBins ( ID : DelayCoverageIDType ) is
--    ------------------------------------------------------------
--    begin
--      SingletonArrayPtr(ID.ID).BurstLength := 0 ; 
--      DeallocateBins(SingletonArrayPtr(ID.ID).BurstLengthCov) ; 
--      DeallocateBins(SingletonArrayPtr(ID.ID).BurstDelayCov) ; 
--      DeallocateBins(SingletonArrayPtr(ID.ID).BeatDelayCov) ; 
--    end procedure DeallocateBins ;

    ------------------------------------------------------------
    procedure DeallocateBins ( ID : DelayCoverageIDType ) is
    ------------------------------------------------------------
    begin
      SingletonArrayPtr(ID.ID).BurstLength := 0 ;  -- Changing the coverage models, so initialize the length to 0
      DeallocateBins(ID.BurstLengthCov) ; 
      DeallocateBins(ID.BurstDelayCov) ; 
      DeallocateBins(ID.BeatDelayCov) ; 
    end procedure DeallocateBins ;
    
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- DelayCoverageIDArrayType Overloading 
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
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return DelayCoverageIDArrayType is
      variable NewCoverageID : DelayCoverageIDArrayType(1 to Size) ;
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
--      impure function NewID( ID : DelayCoverageIDArrayType ) return DelayCoverageIDArrayType is 
--        variable NewCoverageID : DelayCoverageIDArrayType(ID'range) ;
--      begin
--        for i in ID'range loop 
--          NewCoverageID(i) := NewID(ID(i)) ; 
--        end loop ; 
--        return NewCoverageID ; 
--      end function NewID ; 


    ------------------------------------------------------------
    impure function NewDelayCoverage ( 
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
      ReportMode          : AlertLogReportModeType  := DISABLED ;
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
    ) return DelayCoverageIDArrayType is
      variable NewCoverageID : DelayCoverageIDArrayType(1 to Size) ;
    begin
      for i in NewCoverageID'range loop 
        case i is 
          when  1 => NewCoverageID(1)  := NewDelayCoverage(ID,   Name & ifelse(Name'length > 0 and Name1'length  > 0, " ", "") & Name1,  ParentID, ReportMode, Search, PrintParent) ; 
          when  2 => NewCoverageID(2)  := NewDelayCoverage(ID+1, Name & ifelse(Name'length > 0 and Name2'length  > 0, " ", "") & Name2,  ParentID, ReportMode, Search, PrintParent) ; 
          when  3 => NewCoverageID(3)  := NewDelayCoverage(ID+2, Name & ifelse(Name'length > 0 and Name3'length  > 0, " ", "") & Name3,  ParentID, ReportMode, Search, PrintParent) ; 
          when  4 => NewCoverageID(4)  := NewDelayCoverage(ID+2, Name & ifelse(Name'length > 0 and Name4'length  > 0, " ", "") & Name4,  ParentID, ReportMode, Search, PrintParent) ; 
          when  5 => NewCoverageID(5)  := NewDelayCoverage(ID+4, Name & ifelse(Name'length > 0 and Name5'length  > 0, " ", "") & Name5,  ParentID, ReportMode, Search, PrintParent) ; 
          when  6 => NewCoverageID(6)  := NewDelayCoverage(ID+5, Name & ifelse(Name'length > 0 and Name6'length  > 0, " ", "") & Name6,  ParentID, ReportMode, Search, PrintParent) ; 
          when  7 => NewCoverageID(7)  := NewDelayCoverage(ID+6, Name & ifelse(Name'length > 0 and Name7'length  > 0, " ", "") & Name7,  ParentID, ReportMode, Search, PrintParent) ; 
          when  8 => NewCoverageID(8)  := NewDelayCoverage(ID+7, Name & ifelse(Name'length > 0 and Name8'length  > 0, " ", "") & Name8,  ParentID, ReportMode, Search, PrintParent) ; 
          when  9 => NewCoverageID(9)  := NewDelayCoverage(ID+8, Name & ifelse(Name'length > 0 and Name9'length  > 0, " ", "") & Name9,  ParentID, ReportMode, Search, PrintParent) ; 
          when 10 => NewCoverageID(10) := NewDelayCoverage(ID+9, Name & ifelse(Name'length > 0 and Name10'length > 0, " ", "") & Name10, ParentID, ReportMode, Search, PrintParent) ; 
          when others => NULL ; 
        end case ; 
      end loop ; 
      return NewCoverageID ; 
    end function NewDelayCoverage ; 

    ------------------------------------------------------------
    impure function GetDelayCoverage(ID : integer;  Size : positive ) return DelayCoverageIDArrayType is
    ------------------------------------------------------------
      variable NewCoverageID : DelayCoverageIDArrayType(0 to Size-1) ;
    begin
      for i in NewCoverageID'range loop 
        NewCoverageID(i) := GetDelayCoverage(ID+i) ; 
      end loop ; 
      return NewCoverageID ; 
    end function GetDelayCoverage ;
    
    ------------------------------------------------------------
    procedure SetDelayCoverage ( ID : DelayCoverageIDArrayType ) is
    ------------------------------------------------------------
    begin
      for i in ID'range loop 
        SetDelayCoverage(ID(i)) ; 
      end loop ; 
    end procedure SetDelayCoverage ;

    ------------------------------------------------------------
    procedure DeallocateBins ( ID : DelayCoverageIDArrayType ) is
    ------------------------------------------------------------
    begin
      for i in ID'range loop 
        DeallocateBins(ID(i)) ; 
      end loop ; 
    end procedure DeallocateBins ;
  end protected body DelayCoveragePType ;
  

-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Singleton Data Structure
-- /////////////////////////////////////////
-- /////////////////////////////////////////
  shared variable DelayCoverage : DelayCoveragePType ; 
  
  ------------------------------------------------------------
  impure function NewID (
  ------------------------------------------------------------
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := DISABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DelayCoverageIDType is
  begin
    return DelayCoverage.NewID (Name, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  impure function NewDelayCoverage ( 
  ------------------------------------------------------------
    ID                  : Integer ;
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := DISABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DelayCoverageIDType is
  begin
    return DelayCoverage.NewDelayCoverage (ID, Name, ParentID, ReportMode, Search, PrintParent) ;
  end function NewDelayCoverage ; 

  ------------------------------------------------------------
  impure function IsInitialized (ID : DelayCoverageIDType) return boolean is
  ------------------------------------------------------------
  begin
    return DelayCoverage.IsInitialized(ID) ;
  end function IsInitialized ;

  ------------------------------------------------------------
  impure function GetDelayCoverage ( ID : integer ) return DelayCoverageIDType is
  ------------------------------------------------------------
  begin
    return DelayCoverage.GetDelayCoverage ( ID ) ;
  end function GetDelayCoverage ;

  ------------------------------------------------------------
  procedure SetDelayCoverage ( ID : DelayCoverageIDType ) is
  ------------------------------------------------------------
  begin
    DelayCoverage.SetDelayCoverage ( ID ) ;
  end procedure SetDelayCoverage ;

  ------------------------------------------------------------
  impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer is
  ------------------------------------------------------------
  begin
    return DelayCoverage.GetRandDelay(ID) ;
  end function GetRandDelay ;

  ------------------------------------------------------------
  impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer_vector is
  ------------------------------------------------------------
  begin
    return DelayCoverage.GetRandDelay(ID) ;
  end function GetRandDelay ;

  ------------------------------------------------------------
  procedure DeallocateBins(ID : DelayCoverageIDType) is
  ------------------------------------------------------------
  begin
    DelayCoverage.DeallocateBins(ID) ;
  end procedure DeallocateBins ;
  
  ------------------------------------------------------------
  --- ///////////////////////////////////////////////////////////////////////////
  ------------------------------------------------------------
  -- DelayCoverageIDArrayType Overloading 
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
    ReportMode          : AlertLogReportModeType  := DISABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
  ) return DelayCoverageIDArrayType is
  begin
    return DelayCoverage.NewID (
      Name, Size, ParentID, 
      Name1, Name2, Name3, Name4, Name5, Name6, Name7, Name8, Name9, Name10, 
      ReportMode, Search, PrintParent) ;
  end function NewID ;
  
  ------------------------------------------------------------
  impure function NewDelayCoverage ( 
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
    ReportMode          : AlertLogReportModeType  := DISABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT 
  ) return DelayCoverageIDArrayType is
  begin
    return DelayCoverage.NewDelayCoverage (
      ID, Name, Size, ParentID, 
      Name1, Name2, Name3, Name4, Name5, Name6, Name7, Name8, Name9, Name10, 
      ReportMode, Search, PrintParent) ;
  end function NewDelayCoverage ; 

  ------------------------------------------------------------
  impure function GetDelayCoverage(ID : integer;  Size : positive ) return DelayCoverageIDArrayType is
  ------------------------------------------------------------
  begin
    return DelayCoverage.GetDelayCoverage ( ID, Size ) ;
  end function GetDelayCoverage ;

  ------------------------------------------------------------
  procedure SetDelayCoverage ( ID : DelayCoverageIDArrayType ) is
  ------------------------------------------------------------
  begin
    DelayCoverage.SetDelayCoverage ( ID ) ;
  end procedure SetDelayCoverage ;
  
  ------------------------------------------------------------
  procedure SetBurstLength ( ID : DelayCoverageIDType ; BurstLength : integer ) is
  ------------------------------------------------------------
  begin
    DelayCoverage.SetBurstLength ( ID, BurstLength ) ;
  end procedure SetBurstLength ;

  ------------------------------------------------------------
  impure function GetBurstLength ( ID : DelayCoverageIDType ) return integer is
  ------------------------------------------------------------
  begin
    return DelayCoverage.GetBurstLength ( ID ) ;
  end function GetBurstLength ;

  ------------------------------------------------------------
  procedure DeallocateBins ( ID : DelayCoverageIDArrayType ) is
  ------------------------------------------------------------
  begin
    DelayCoverage.DeallocateBins(ID) ;
  end procedure DeallocateBins ;


end package body DelayCoveragePkg ;