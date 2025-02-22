--
--  File Name:         MemoryGenericPkg.vhd
--  Design Unit Name:  MemoryGenericPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
--  Contributor(s):            
--     Jim Lewis      email:  jim@synthworks.com   
--
--  Description
--      Package defines a protected type, MemoryPType, and methods  
--      for efficiently implementing memory data structures
--    
--  Developed for: 
--        SynthWorks Design Inc. 
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2024   2024.09    Updated reporting for integer'high and integer'low
--    07/2024   2024.07    Throw Errors on Address > 41 and warnings if Address > 38
--                         Added IsInitialized
--    01/2023   2023.01    Updated address checks in MemRead and MemWrite
--    11/2022   2022.11    Updated default search to PRIVATE_NAME
--    08/2022   2022.08    Refactored and added generics for base type
--    02/2022   2022.02    Updated NewID with ReportMode, Search, PrintParent.   Supports searching for Memory models.
--    06/2021   2021.06    Updated Data Structure, IDs for new use model, and Wrapper Subprograms
--    01/2020   2020.01    Updated Licenses to Apache
--    11/2016   2016.11    Refinement to MemRead to return value, X (if X), U (if not initialized)
--    01/2016   2016.01    Update for buf.all(buf'left)
--    06/2015   2015.06    Updated for Alerts, ...
--    ...       ...        Numerous revisions for VHDL Testbenches and Verification
--    05/2005   0.1        Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2005 - 2022 by SynthWorks Design Inc.  
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
library IEEE ; 
  use IEEE.std_logic_1164.all ; 
  use IEEE.numeric_std.all ; 
  use IEEE.numeric_std_unsigned.all ; 
  use IEEE.math_real.all ;
  
  use work.TextUtilPkg.all ;
  use work.TranscriptPkg.all ;  
  use work.AlertLogPkg.all ;
  use work.NameStorePkg.all ;
  use work.ResolutionPkg.all ; 
  
-- Temporary workaround for MemoryBaseType 
  use work.MemorySupportPkg.MemoryBaseType ;

package MemoryGenericPkg is
  generic (
--    type MemoryBaseType ;
    function SizeMemoryBaseType(Size : integer) return integer ; -- is <> ;
    function ToMemoryBaseType  (A : std_logic_vector ; Size : integer) return MemoryBaseType ; -- is <> ;
    function FromMemoryBaseType(A : MemoryBaseType   ; Size : integer) return std_logic_vector ; -- is <> ;
    function InitMemoryBaseType(Size : integer) return MemoryBaseType -- is <> 
  ) ;
  
  type MemoryIDType is record
    ID : integer_max ;
  end record MemoryIDType ; 
  
  constant MEMORY_ID_UNINITIALZED : MemoryIdType := (ID => integer'low) ; 

  type MemoryIDArrayType is array (integer range <>) of MemoryIDType ;

  constant OSVVM_MEMORY_ALERTLOG_ID : AlertLogIDType := OSVVM_ALERTLOG_ID ;
  ------------------------------------------------------------
  impure function NewID (
    Name                : String ; 
    AddrWidth           : integer ; 
    DataWidth           : integer ; 
    ParentID            : AlertLogIDType          := OSVVM_MEMORY_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ; 
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return MemoryIDType ;

  impure function IsInitialized (ID : MemoryIDType) return boolean ;

  ------------------------------------------------------------
  procedure MemWrite ( 
    ID    : MemoryIDType ; 
    Addr  : std_logic_vector ;
    Data  : std_logic_vector 
  ) ; 
  alias Write is MemWrite [MemoryIDType, std_logic_vector, std_logic_vector ] ; 
  
  procedure MemRead (  
    ID    : in MemoryIDType ;
    Addr  : in  std_logic_vector ;
    Data  : out std_logic_vector 
  ) ; 
  alias Read is MemRead [MemoryIDType, std_logic_vector, std_logic_vector ] ; 
  
  impure function MemRead ( 
    ID    : MemoryIDType ; 
    Addr  : std_logic_vector 
  ) return std_logic_vector ; 
  alias Read is MemRead [MemoryIDType, std_logic_vector return std_logic_vector ] ; 

  ------------------------------------------------------------
  procedure MemErase (ID : in MemoryIDType); 
  procedure deallocate (ID : in MemoryIDType) ;
  procedure MemoryPkgDeallocate ;
  
  ------------------------------------------------------------
  impure function GetAlertLogID (ID : in MemoryIDType) return AlertLogIDType ;
  
  ------------------------------------------------------------
  procedure FileReadH (    -- Hexadecimal File Read 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) ;
  procedure FileReadH (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) ;
  procedure FileReadH (
    ID           : MemoryIDType ;
    FileName     : string 
  ) ;

  ------------------------------------------------------------
  procedure FileReadB (    -- Binary File Read 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) ;
  procedure FileReadB (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) ;
  procedure FileReadB (
    ID           : MemoryIDType ;
    FileName     : string 
  ) ;

  ------------------------------------------------------------
  procedure FileWriteH (    -- Hexadecimal File Write 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) ;
  procedure FileWriteH (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) ;
  procedure FileWriteH (
    ID           : MemoryIDType ;
    FileName     : string 
  ) ;

  ------------------------------------------------------------
  procedure FileWriteB (    -- Binary File Write 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) ;
  procedure FileWriteB (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) ;
  procedure FileWriteB (
    ID           : MemoryIDType ;
    FileName     : string 
  ) ;

  type MemoryPType is protected 
  
    ------------------------------------------------------------
    impure function NewID (
      Name                : String ; 
      AddrWidth           : integer ; 
      DataWidth           : integer ; 
      ParentID            : AlertLogIDType          := OSVVM_MEMORY_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := ENABLED ; 
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return integer ;

    impure function IsInitialized (ID : MemoryIDType) return boolean ;

    ------------------------------------------------------------
    procedure MemWrite ( 
      ID    : integer ; 
      Addr  : std_logic_vector ;
      Data  : std_logic_vector 
    ) ; 
    procedure MemRead (  
      ID    : in integer ;
      Addr  : in  std_logic_vector ;
      Data  : out std_logic_vector 
    ) ; 
    impure function MemRead ( 
      ID    : integer ; 
      Addr  : std_logic_vector 
    ) return std_logic_vector ; 

    ------------------------------------------------------------
    procedure MemErase (ID : integer) ; 
    
    impure function GetAlertLogID (ID : integer) return AlertLogIDType ;
    
    ------------------------------------------------------------
    procedure FileReadH (    -- Hexadecimal File Read 
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileReadH (
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) ;
    procedure FileReadH (
      ID           : integer ;
      FileName     : string 
    ) ;

    ------------------------------------------------------------
    procedure FileReadB (    -- Binary File Read 
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileReadB (
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) ;
    procedure FileReadB (
      ID           : integer ;
      FileName     : string 
    ) ;

    ------------------------------------------------------------
    procedure FileWriteH (    -- Hexadecimal File Write 
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileWriteH (
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) ;
    procedure FileWriteH (
      ID           : integer ;
      FileName     : string 
    ) ;

    ------------------------------------------------------------
    procedure FileWriteB (    -- Binary File Write 
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileWriteB (
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) ;
    procedure FileWriteB (
      ID           : integer ;
      FileName     : string 
    ) ;

    ------------------------------------------------------------
    -- Destroys the entire data structure
    -- Usage:  At the end of the simulation to remove all 
    -- memory used by data structure.  
    -- Note, a normal simulator does this for you.  
    -- You only need this if the simulator is broken.
    procedure deallocate (ID : integer) ; 
    procedure deallocate ; 

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- Historical Interface
    --   In the new implementation, these use index 1. 
    --   These are for backward compatibility support
    -- 
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure MemInit ( AddrWidth, DataWidth  : in  integer ) ;
    
    ------------------------------------------------------------
    procedure MemWrite ( Addr, Data  : in  std_logic_vector ) ; 

    ------------------------------------------------------------
    procedure MemRead (  
      Addr  : in  std_logic_vector ;
      Data  : out std_logic_vector 
    ) ; 
    impure function MemRead ( Addr  : std_logic_vector ) return std_logic_vector ; 

    ------------------------------------------------------------
    procedure MemErase ; 
    
    ------------------------------------------------------------
    procedure SetAlertLogID (A : AlertLogIDType) ;
    procedure SetAlertLogID (Name : string ; ParentID : AlertLogIDType := OSVVM_MEMORY_ALERTLOG_ID ; CreateHierarchy : Boolean := TRUE) ;    
    impure function GetAlertLogID return AlertLogIDType ;
    
    ------------------------------------------------------------
    procedure FileReadH (    -- Hexadecimal File Read 
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileReadH (FileName : string ;  StartAddr : std_logic_vector) ;
    procedure FileReadH (FileName : string) ; 

    ------------------------------------------------------------
    procedure FileReadB (    -- Binary File Read 
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileReadB (FileName : string ;  StartAddr : std_logic_vector) ;
    procedure FileReadB (FileName : string) ; 

    ------------------------------------------------------------
    procedure FileWriteH (    -- Hexadecimal File Write 
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileWriteH (FileName : string ;  StartAddr : std_logic_vector) ;
    procedure FileWriteH (FileName : string) ; 

    ------------------------------------------------------------
    procedure FileWriteB (    -- Binary File Write 
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) ;
    procedure FileWriteB (FileName : string ;  StartAddr : std_logic_vector) ;
    procedure FileWriteB (FileName : string) ;    

  end protected MemoryPType ;

end MemoryGenericPkg ;

package body MemoryGenericPkg is 
  constant BLOCK_WIDTH : integer := 10 ; 
  constant WARNING_AT_ADDRESS_WIDTH : integer := BLOCK_WIDTH + 24 ; -- 16 M Byte array of pointers
  constant MAXIMUM_ADDRESS_WIDTH    : integer := BLOCK_WIDTH + 30 ; -- 1 G Byte Array of pointers - Maximum size supported by type integer

  type MemoryPType is protected body

    type MemBlockType      is array (integer range <>) of MemoryBaseType ;
    type MemBlockPtrType   is access MemBlockType ;
    type MemArrayType      is array (integer range <>) of MemBlockPtrType ;
    type MemArrayPtrType   is access MemArrayType ; 
    
    type FileFormatType is (BINARY, HEX) ; 
        
    type MemStructType is record
      MemArrayPtr         : MemArrayPtrType ; 
      AddrWidth           : integer ;
      DataWidth           : natural ;
      BlockWidth          : natural ; 
      MemoryBaseTypeWidth : natural ; 
      AlertLogID          : AlertLogIDType ; 
    end record MemStructType ; 
    
    -- New Structure
    type     ItemArrayType    is array (integer range <>) of MemStructType ; 
    type     ItemArrayPtrType is access ItemArrayType ;
    
    variable Template         : ItemArrayType(1 to 1) := (1 => (NULL, -1, 1, 0, 0, OSVVM_MEMORY_ALERTLOG_ID)) ;  -- Work around for QS 2020.04 and 2021.02
    variable MemStructPtr     : ItemArrayPtrType := new ItemArrayType'(Template) ;   
    constant MIN_INDEX        : integer := 1 ;
    constant PT_ID            : integer := MIN_INDEX ; 
    variable NumItems         : integer := 0 ; 
--    constant NUM_ITEMS_TO_ALLOCATE    : integer := 4 ; -- Temporarily small for testing
    constant NUM_ITEMS_TO_ALLOCATE    : integer := 32 ; -- Min amount to resize array
    variable LocalNameStore   : NameStorePType ; 
    
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
--      constant NewNumItems      : in integer ;
--      constant CurNumItems      : in integer ;
      constant MinNumItems      : in integer 
    ) is
      variable oldItemArrayPtr  : ItemArrayPtrType ;
      variable NewNumItems : integer ;
    begin
      NewNumItems := NumItems + GrowAmount ;
      -- Array Allocated in declaration to have a single item, but no items (historical mode)
      -- if ItemArrayPtr = NULL then
      --  ItemArrayPtr := new ItemArrayType(1 to NormalizeArraySize(NewNumItems, MinNumItems)) ;
      -- elsif NewNumItems > ItemArrayPtr'length then
      if NewNumItems > ItemArrayPtr'length then
        oldItemArrayPtr := ItemArrayPtr ;
        ItemArrayPtr := new ItemArrayType(1 to NormalizeArraySize(NewNumItems, MinNumItems)) ;
        ItemArrayPtr.all(1 to NumItems) := ItemArrayType'(oldItemArrayPtr.all(1 to NumItems)) ;
        deallocate(oldItemArrayPtr) ;
      end if ;
      NumItems := NewNumItems ; 
    end procedure GrowNumberItems ;  
    
   ------------------------------------------------------------
    -- PT Local 
    function MaximumAddressWidth (AddrWidth : integer) return integer is
    ------------------------------------------------------------
    begin
      return minimum(AddrWidth, MAXIMUM_ADDRESS_WIDTH) ;
    end function MaximumAddressWidth ; 

   ------------------------------------------------------------
    -- PT Local 
    procedure MemInit (ID : integer ;  AddrWidth, DataWidth  : integer ) is
    ------------------------------------------------------------
      constant ADJ_BLOCK_WIDTH             : integer := minimum(BLOCK_WIDTH, AddrWidth) ;
      constant ADJ_ADDR_WDITH              : integer := MaximumAddressWidth(AddrWidth) ; 
      constant ADJ_ARRAY_OF_POINTERS_WIDTH : integer := ADJ_ADDR_WDITH - ADJ_BLOCK_WIDTH ; 
    begin
      if AddrWidth <= 0 then 
        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemInit/NewID.  AddrWidth = " & to_string(AddrWidth) & " must be > 0.", FAILURE) ; 
        return ; 
      end if ; 
      if AddrWidth >= WARNING_AT_ADDRESS_WIDTH then  
        -- Array of pointers > 64 M words
        log(MemStructPtr(ID).AlertLogID, "MemoryPkg.NewID(MemInit):  Requested AddrWidth = " & to_string(AddrWidth) & ".") ; 
        log(MemStructPtr(ID).AlertLogID, "MemoryPkg.NewID(MemInit):  Internally this creates an array sized 2**" & to_string(ADJ_ARRAY_OF_POINTERS_WIDTH) & ".") ; 
        log(MemStructPtr(ID).AlertLogID, "MemoryPkg.NewID(MemInit):  Memories this large may result in poor simulation performance.") ; 
        log(MemStructPtr(ID).AlertLogID, "MemoryPkg.NewID(MemInit):  If you need a memory this large, be sure to file an issue on GitHub/OSVVM/OsvvmLibraries or osvvm.org.") ; 

        if AddrWidth > ADJ_ADDR_WDITH then
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.NewID(MemInit):  Requested AddrWidth = " & to_string(AddrWidth) & 
                                             " was truncated to " & to_string(ADJ_ADDR_WDITH) & ".", ERROR) ; 
        else 
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.NewID(MemInit):  Requested AddrWidth = " & to_string(AddrWidth) & " is large and may slow simulation.", WARNING) ; 
        end if ; 
      end if ; 
--      if DataWidth <= 0 or DataWidth > 31 then 
--        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemInit/NewID.  DataWidth = " & to_string(DataWidth) & " must be > 0 and <= 31.", FAILURE) ; 
      if DataWidth <= 0 then 
        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemInit/NewID.  DataWidth = " & to_string(DataWidth) & " must be > 0 ", FAILURE) ; 
        return ; 
      end if ; 

      MemStructPtr(ID).AddrWidth           := ADJ_ADDR_WDITH ; 
      MemStructPtr(ID).DataWidth           := DataWidth ; 
      MemStructPtr(ID).MemoryBaseTypeWidth := SizeMemoryBaseType(DataWidth) ; 
      MemStructPtr(ID).BlockWidth          := ADJ_BLOCK_WIDTH ;
      if ADJ_ARRAY_OF_POINTERS_WIDTH < 31 then 
        MemStructPtr(ID).MemArrayPtr         := new MemArrayType(0 to 2**(ADJ_ARRAY_OF_POINTERS_WIDTH)-1) ;  
      else
        -- with 32 bit signed numbers, formulating 2**31-1 can be interesting.
        MemStructPtr(ID).MemArrayPtr         := new MemArrayType(0 to (2**30-1) + 2**30) ; 
      end if ; 
    end procedure MemInit ;
    
    ------------------------------------------------------------
    impure function NewID (
    ------------------------------------------------------------
      Name                : String ; 
      AddrWidth           : integer ; 
      DataWidth           : integer ; 
      ParentID            : AlertLogIDType          := OSVVM_MEMORY_ALERTLOG_ID ;
      ReportMode          : AlertLogReportModeType  := ENABLED ; 
      Search              : NameSearchType          := PRIVATE_NAME ;
      PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
    ) return integer is 
      variable NameID              : integer ; 
      variable ResolvedSearch      : NameSearchType ; 
      variable ResolvedPrintParent : AlertLogPrintParentType ; 
    begin
      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_MEMORY_ALERTLOG_ID, Search) ; 
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_MEMORY_ALERTLOG_ID, PrintParent) ; 
      
      NameID := LocalNameStore.find(Name, ParentID, ResolvedSearch) ; 

      -- Share the memory if they match
      if NameID /= ID_NOT_FOUND.ID then
        if MemStructPtr(NameID).MemArrayPtr /= NULL then 
          -- Found ID and structure exists, does structure match?
          AlertIf(MemStructPtr(NameID).AlertLogID, MaximumAddressWidth(AddrWidth) /= MemStructPtr(NameID).AddrWidth,  
            "NewID: AddrWidth: " & to_string(MaximumAddressWidth(AddrWidth)) & " /= Existing AddrWidth: "  & to_string(MemStructPtr(NameID).AddrWidth), FAILURE);
          AlertIf(MemStructPtr(NameID).AlertLogID, DataWidth /= MemStructPtr(NameID).DataWidth,  
            "NewID: DataWidth: " & to_string(DataWidth) & " /= Existing DataWidth: "  & to_string(MemStructPtr(NameID).DataWidth), FAILURE);
          -- NameStore IDs are issued sequentially and match MemoryID
        else 
          -- Found ID and structure does not exist, Reconstruct Memory
          MemInit(NameID, AddrWidth, DataWidth) ;
        end if ; 
        return NameID ; 
        
      else
        -- Add New Memory to Structure 
        GrowNumberItems(MemStructPtr, NumItems, GrowAmount => 1, MinNumItems => NUM_ITEMS_TO_ALLOCATE) ;
        -- Create AlertLogID
        MemStructPtr(NumItems).AlertLogID := NewID(Name, ParentID, ReportMode, ResolvedPrintParent, CreateHierarchy => FALSE) ;
        -- Construct Memory, Reports agains AlertLogID
        MemInit(NumItems, AddrWidth, DataWidth) ;
        -- Add item to NameStore
        NameID := LocalNameStore.NewID(Name, ParentID, ResolvedSearch) ;
        -- Check NameStore Index vs MemoryIndex
        AlertIfNotEqual(MemStructPtr(NumItems).AlertLogID, NameID, NumItems, "MemoryStore, Check Index of LocalNameStore matches MemoryID") ;  
        return NumItems ; 
      end if ;
    end function NewID ;
    
    ------------------------------------------------------------
    impure function IsInitialized (ID : MemoryIDType) return boolean is
    ------------------------------------------------------------
    begin
      return ID /= MEMORY_ID_UNINITIALZED ;
    end function IsInitialized ;

    ------------------------------------------------------------
    -- PT Local 
    impure function IdOutOfRange(
    ------------------------------------------------------------
      constant ID    : in integer ; 
      constant Name  : in string
    ) return boolean is 
    begin
      if ID < MIN_INDEX or ID > MemStructPtr'High then 
        if ID = integer'low then 
          Alert(OSVVM_MEMORY_ALERTLOG_ID, "MemoryPkg." & Name & " ID not initialized yet.  " &
            "Either a call to NewID or wait for 0 ns (to allow for signal update) is needed. ",
             FAILURE ) ;
        else 
          Alert(OSVVM_MEMORY_ALERTLOG_ID,  
             "MemoryPkg." & Name & " ID: " & to_string_max(ID) & 
                   " is not in the range (" & to_string(MIN_INDEX) &
                   " to " & to_string(MemStructPtr'High) & ")",
             FAILURE ) ;
        end if ; 
        return TRUE ;
      else
        -- valid ID
        return FALSE ; 
      end if; 
    end function IdOutOfRange ; 

    ------------------------------------------------------------
    -- Local
    -- This is a temporary solution that works around GHDL issues
    function InitMemoryBlockType(BlockWidth, BaseWidth : integer) return MemBlockType is  
    ------------------------------------------------------------
-- This keeps MemoryBaseType from being a generic type
      constant BaseU : MemoryBaseType(BaseWidth-1 downto 0) := InitMemoryBaseType(BaseWidth) ;
--!! GHDL Bug     constant BaseU : MemoryBaseType := InitMemoryBaseType(BaseWidth) ;
    begin
      return MemBlockType'(0 to 2**BlockWidth-1 => BaseU) ;
    end function InitMemoryBlockType ; 

    ------------------------------------------------------------
    procedure MemWrite ( 
    ------------------------------------------------------------
      ID    : integer ; 
      Addr  : std_logic_vector ;
      Data  : std_logic_vector 
    ) is 
      variable BlockWidth, AddrWidth : integer ;
      variable MemoryBaseWidth : integer ;
--      constant BlockWidth : integer := MemStructPtr(ID).BlockWidth;
      variable BlockAddr, WordAddr  : integer ;
      alias aAddr : std_logic_vector (Addr'length-1 downto 0) is Addr ; 
--      subtype MemBlockSubType is MemBlockType(0 to 2**BlockWidth-1) ;
      variable MemArrayPtr : MemArrayPtrType ; 
    begin
      if IdOutOfRange(ID, "MemWrite") then 
        return ;
      end if ; 
      
      AddrWidth   := MemStructPtr(ID).AddrWidth  ;
      MemArrayPtr := MemStructPtr(ID).MemArrayPtr ;
      
      -- Check Bounds of Address and if memory is initialized
      if Addr'length > AddrWidth then
        if (MemArrayPtr = NULL) then -- ONLY PT since if ID in range, then MemInit called
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemWrite:  Memory not initialized, Write Ignored.", FAILURE) ; 
          return ; 
        elsif aAddr(aAddr'left downto AddrWidth) /= 0 then
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemWrite:  Address value " & to_hxstring(Addr) & " goes beyond memory address width: " & to_string(MemStructPtr(ID).AddrWidth), FAILURE) ; 
          return ; 
        end if ; 
      end if ; 

      -- Check Bounds on Data
      if Data'length /= MemStructPtr(ID).DataWidth then
        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemWrite:  Data'length: " & to_string(Data'length) & " /= Memory Data Width: " & to_string(MemStructPtr(ID).DataWidth), FAILURE) ; 
        return ; 
      end if ; 

      if is_X( Addr ) then
        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemWrite:  Address X, Write Ignored.") ; 
        return ;
      end if ; 

      BlockWidth := MemStructPtr(ID).BlockWidth ; 

      -- Slice out upper address to form block address
      if aAddr'high >= BlockWidth then
        BlockAddr := to_integer(aAddr(aAddr'high downto BlockWidth)) ;
      else
        BlockAddr  := 0 ; 
      end if ; 

      MemoryBaseWidth := MemStructPtr(ID).MemoryBaseTypeWidth ; 

      -- If empty, allocate a memory block
      if (MemArrayPtr(BlockAddr) = NULL) then 
        MemArrayPtr(BlockAddr) := new 
            MemBlockType'(InitMemoryBlockType(BlockWidth, MemoryBaseWidth)) ;

-- Long term, we need the first one to allow transition of MemoryBaseType to a generic.
--!! GHDL Bug        MemStructPtr(ID).MemArrayPtr(BlockAddr) := new 
--!! GHDL Bug            MemBlockType'(0 to 2**BlockWidth-1 =>  InitMemoryBaseType(MemoryBaseWidth) ) ;
--        MemStructPtr(ID).MemArrayPtr(BlockAddr) := new 
--          MemBlockType(0 to 2**BlockWidth-1)(MemoryBaseWidth-1 downto 0) ;
--!! GHDL Bug        MemStructPtr(ID).MemArrayPtr(BlockAddr).all := (0 to 2**BlockWidth-1 => InitMemoryBaseType(MemoryBaseWidth));
      end if ; 

      -- Address of a word within a block
      WordAddr  := to_integer(aAddr(BlockWidth -1 downto 0)) ;

      -- Write to BlockAddr, WordAddr
      MemArrayPtr(BlockAddr)(WordAddr) := ToMemoryBaseType(Data, MemoryBaseWidth) ;
    end procedure MemWrite ; 

    ------------------------------------------------------------
    procedure MemRead (  
    ------------------------------------------------------------
      ID    : in integer ;
      Addr  : in  std_logic_vector ;
      Data  : out std_logic_vector 
    ) is
      variable BlockWidth, AddrWidth : integer ;
      variable BlockAddr, WordAddr  : integer ;
      alias aAddr : std_logic_vector (Addr'length-1 downto 0) is Addr ; 
    begin
    
      Data := (Data'range => 'U') ;  -- Error return value

      if IdOutOfRange(ID, "MemRead") then 
        return ;
      end if ; 
      
      AddrWidth := MemStructPtr(ID).AddrWidth ;

      -- Check Bounds of Address and if memory is initialized
      if Addr'length > AddrWidth then
        if (MemStructPtr(ID).MemArrayPtr = NULL) then  -- ONLY PT since if ID in range, then MemInit called
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemRead:  Memory not initialized. Returning U", FAILURE) ; 
          return ; 
        elsif aAddr(aAddr'left downto AddrWidth) /= 0 then
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemRead:  Address value " & to_hxstring(Addr) & " goes beyond memory address width: " & to_string(MemStructPtr(ID).AddrWidth), FAILURE) ; 
          return ; 
        end if ; 
      end if ; 
      
      -- Check Bounds on Data
      if Data'length /= MemStructPtr(ID).DataWidth then
        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.MemRead:  Data'length: " & to_string(Data'length) & " /= Memory Data Width: " & to_string(MemStructPtr(ID).DataWidth), FAILURE) ; 
        return ; 
      end if ; 

      -- If Addr X, data = X
      if is_X( aAddr ) then
        Data := (Data'range => 'X') ; 
        return ; 
      end if ; 

      BlockWidth := MemStructPtr(ID).BlockWidth ;

      -- Slice out upper address to form block address
      if aAddr'high >= BlockWidth then
        BlockAddr := to_integer(aAddr(aAddr'high downto BlockWidth)) ;
      else
        BlockAddr  := 0 ; 
      end if ; 
      
      -- Empty Block, return all U
      if (MemStructPtr(ID).MemArrayPtr(BlockAddr) = NULL) then 
        Data := (Data'range => 'U') ; 
        return ; 
      end if ; 

      -- Address of a word within a block
      WordAddr := to_integer(aAddr(BlockWidth -1 downto 0)) ;
      
      Data := FromMemoryBaseType(MemStructPtr(ID).MemArrayPtr(BlockAddr)(WordAddr), Data'length) ; 

    end procedure MemRead ; 

    ------------------------------------------------------------
    impure function MemRead ( 
      ID    : integer ; 
      Addr  : std_logic_vector 
    ) return std_logic_vector is
    ------------------------------------------------------------
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "MemRead function") ;
      constant DATA_WIDTH : integer := MemStructPtr(ID).DataWidth ; 
      variable Data  : std_logic_vector(DATA_WIDTH-1 downto 0) ; 
    begin
      MemRead(ID, Addr, Data) ; 
      return Data ; 
    end function MemRead ; 

    ------------------------------------------------------------
    procedure MemErase(ID : integer) is 
    -- Erase the memory, but not the array of pointers
    ------------------------------------------------------------
    begin
      if IdOutOfRange(ID, "MemErase") then 
        return ;
      end if ; 

      for BlockAddr in MemStructPtr(ID).MemArrayPtr'range loop 
        if (MemStructPtr(ID).MemArrayPtr(BlockAddr) /= NULL) then 
          deallocate (MemStructPtr(ID).MemArrayPtr(BlockAddr)) ; 
        end if ; 
      end loop ; 
    end procedure ; 
    
    ------------------------------------------------------------
    impure function GetAlertLogID (ID : integer) return AlertLogIDType is
    ------------------------------------------------------------
    begin
      if IdOutOfRange(ID, "MemErase") then 
        return ALERTLOG_ID_NOT_FOUND ;
      else
        return MemStructPtr(ID).AlertLogID ; 
      end if ; 
    end function GetAlertLogID ;

    ------------------------------------------------------------
    -- PT Local
    procedure FileReadX (
    -- Hexadecimal or Binary File Read 
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ;
      DataFormat   : FileFormatType ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
      constant ADDR_WIDTH : integer := MemStructPtr(ID).AddrWidth ;
      constant DATA_WIDTH : integer := MemStructPtr(ID).DataWidth ; 
--      constant TemplateRange : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '0') ;
      -- Format:  
      --  @hh..h     -- Address in hex
      --  hhh_XX_ZZ  -- data values in hex - space delimited 
      --  "--" or "//" -- comments
      file MemFile : text open READ_MODE is FileName ;
     
      variable Addr             : std_logic_vector(ADDR_WIDTH - 1 downto 0) ;
      variable SmallAddr        : std_logic_vector(ADDR_WIDTH - 1 downto 0) ;
      variable BigAddr          : std_logic_vector(ADDR_WIDTH - 1 downto 0) ;
      variable Data             : std_logic_vector(DATA_WIDTH - 1 downto 0) ;
      variable LineNum          : natural ; 
      variable ItemNum          : natural ; 
      variable AddrInc          : std_logic_vector(ADDR_WIDTH - 1 downto 0) ; 
      variable buf              : line ;
      variable ReadValid        : boolean ;
      variable Empty            : boolean ; 
      variable MultiLineComment : boolean ; 
      variable NextChar         : character ; 
      variable StrLen           : integer ;       
    begin
      MultiLineComment := FALSE ; 
      if StartAddr'length /= ADDR_WIDTH and EndAddr'length /= ADDR_WIDTH then
        if (MemStructPtr(ID).MemArrayPtr = NULL) then 
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.FileReadX:  Memory not initialized, FileRead Ignored.", FAILURE) ; 
        else
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.FileReadX:  Addr'length: " & to_string(Addr'length) & " /= Memory Address Width: " & to_string(ADDR_WIDTH), FAILURE) ; 
        end if ; 
        return ; 
      end if ; 

      Addr    := StartAddr ; 
      LineNum := 0 ; 
      
      if StartAddr <= EndAddr then 
        SmallAddr := StartAddr ; 
        BigAddr   := EndAddr ; 
        AddrInc   := (ADDR_WIDTH -1 downto 0 => '0') + 1 ;  
      else
        SmallAddr := EndAddr ; 
        BigAddr   := StartAddr ; 
        AddrInc   := (others => '1') ;  -- -1
      end if; 
      
      ReadLineLoop : while not EndFile(MemFile) loop
        ReadLine(MemFile, buf) ;
        LineNum := LineNum + 1 ; 
        ItemNum := 0 ; 
        
        ItemLoop : loop 
          EmptyOrCommentLine(buf, Empty, MultiLineComment) ; 
          exit ItemLoop when Empty ; 
          ItemNum := ItemNum + 1 ; 
          NextChar := buf.all(buf'left) ;
          
          if (NextChar = '@') then 
          -- Get Address
            read(buf, NextChar) ; 
            ReadHexToken(buf, Addr, StrLen) ; 
            exit ReadLineLoop when AlertIf(MemStructPtr(ID).AlertLogID, StrLen = 0, "MemoryPkg.FileReadX: Address length 0 on line: " & to_string(LineNum), FAILURE) ;
            exit ItemLoop when AlertIf(MemStructPtr(ID).AlertLogID, Addr < SmallAddr, 
                                           "MemoryPkg.FileReadX: Address in file: " & to_hxstring(Addr) & 
                                           " < StartAddr: " & to_hxstring(StartAddr) & " on line: " & to_string(LineNum)) ; 
            exit ItemLoop when AlertIf(MemStructPtr(ID).AlertLogID, Addr > BigAddr, 
                                           "MemoryPkg.FileReadX: Address in file: " & to_hxstring(Addr) & 
                                           " > EndAddr: " & to_hxstring(BigAddr) & " on line: " & to_string(LineNum)) ; 
          
          elsif DataFormat = HEX and IsHexOrStdLogic(NextChar) then 
          -- Get Hex Data
            ReadHexToken(buf, data, StrLen) ;
            exit ReadLineLoop when AlertIfNot(MemStructPtr(ID).AlertLogID, StrLen > 0, 
              "MemoryPkg.FileReadH: Error while reading data on line: " & to_string(LineNum) &
              "  Item number: " & to_string(ItemNum), FAILURE) ;
            log(MemStructPtr(ID).AlertLogID, "MemoryPkg.FileReadX:  MemWrite(Addr => " & to_hxstring(Addr) & ", Data => " & to_hxstring(Data) & ")", DEBUG) ; 
            MemWrite(ID, Addr, data) ; 
            Addr := Addr + AddrInc ; 
            
          elsif DataFormat = BINARY and isstd_logic(NextChar) then 
          -- Get Binary Data
            -- read(buf, data, ReadValid) ;
            ReadBinaryToken(buf, data, StrLen) ;
            -- exit ReadLineLoop when AlertIfNot(MemStructPtr(ID).AlertLogID, ReadValid, 
            exit ReadLineLoop when AlertIfNot(MemStructPtr(ID).AlertLogID, StrLen > 0, 
              "MemoryPkg.FileReadB: Error while reading data on line: " & to_string(LineNum) &
              "  Item number: " & to_string(ItemNum), FAILURE) ;
            log(MemStructPtr(ID).AlertLogID, "MemoryPkg.FileReadX:  MemWrite(Addr => " & to_hxstring(Addr) & ", Data => " & to_string(Data) & ")", DEBUG) ; 
            MemWrite(ID, Addr, data) ; 
            Addr := Addr + AddrInc ; 
          
          else
            if NextChar = LF or NextChar = CR then 
              -- If LF or CR, silently skip the character (DOS file in Unix)
              read(buf, NextChar) ; 
            else
              -- invalid Text, issue warning and skip rest of line
              Alert(MemStructPtr(ID).AlertLogID,  
                "MemoryPkg.FileReadX: Invalid text on line: " & to_string(LineNum) &
                "  Item: " & to_string(ItemNum) & ".  Skipping text: " & StripCrLf(buf.all)) ;
              exit ItemLoop ; 
            end if ; 
          end if ; 
          
        end loop ItemLoop ; 
      end loop ReadLineLoop ; 
      
--      -- must read EndAddr-StartAddr number of words if both start and end specified
--      if (StartAddr /= 0 or (not EndAddr) /= 0) and (Addr /= EndAddr) then 
--        Alert("MemoryPkg.FileReadH: insufficient data values", WARNING) ; 
--      end if ;       
      file_close(MemFile) ; 
    end FileReadX ;
    
    ------------------------------------------------------------
    procedure FileReadH (
    -- Hexadecimal File Read 
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileReadH") ;
    begin
      FileReadX(ID, FileName, HEX, StartAddr, EndAddr) ; 
    end FileReadH ;
    
    ------------------------------------------------------------
    -- Hexadecimal File Read 
    procedure FileReadH (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileReadH") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH - 1 downto 0 => '1') ;
    begin
      FileReadX(ID, FileName, HEX, StartAddr, EndAddr) ; 
    end FileReadH ;

    ------------------------------------------------------------
    -- Hexadecimal File Read 
    procedure FileReadH (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string 
    ) is 
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileReadH") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant StartAddr   : std_logic_vector := (ADDR_WIDTH - 1 downto 0 => '0') ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH - 1 downto 0 => '1') ;
    begin
      FileReadX(ID, FileName, HEX, StartAddr, EndAddr) ; 
    end FileReadH ;    
    
    ------------------------------------------------------------
    -- Binary File Read 
    procedure FileReadB (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileReadB") ;
    begin
      FileReadX(ID, FileName, BINARY, StartAddr, EndAddr) ; 
    end FileReadB ;
    
    ------------------------------------------------------------
    -- Binary File Read 
    procedure FileReadB (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileReadB") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH - 1 downto 0 => '1') ;
    begin 
      FileReadX(ID, FileName, BINARY, StartAddr, EndAddr) ; 
    end FileReadB ;

    ------------------------------------------------------------
    -- Binary File Read 
    procedure FileReadB (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string 
    ) is 
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileReadB") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant StartAddr   : std_logic_vector := (ADDR_WIDTH - 1 downto 0 => '0') ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH - 1 downto 0 => '1') ;
    begin
      FileReadX(ID, FileName, BINARY, StartAddr, EndAddr) ; 
    end FileReadB ;    

    ------------------------------------------------------------
    -- PT Local
    -- Hexadecimal or Binary File Write 
    procedure FileWriteX (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ; 
      DataFormat   : FileFormatType ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant DATA_WIDTH  : integer := MemStructPtr(ID).DataWidth ; 
      constant BLOCK_WIDTH : integer := MemStructPtr(ID).BlockWidth ;
      -- Format:  
      --  @hh..h     -- Address in hex
      --  hhhhh      -- data one per line in either hex or binary as specified 
      file MemFile : text open WRITE_MODE is FileName ;
      alias normStartAddr     : std_logic_vector(StartAddr'length-1 downto 0) is StartAddr ; 
      alias normEndAddr       : std_logic_vector(EndAddr'length-1 downto 0) is EndAddr ; 
      variable StartBlockAddr : natural ;
      variable EndBlockAddr   : natural ;
      variable StartWordAddr  : natural ; 
      variable EndWordAddr    : natural ; 
      variable FoundData      : boolean ; 
      variable buf            : line ;
      variable Data           : std_logic_vector(DATA_WIDTH-1 downto 0) ;
      constant AllU           : std_logic_vector := (DATA_WIDTH-1 downto 0 => 'U');
      
    begin
      if StartAddr'length /= ADDR_WIDTH and EndAddr'length /= ADDR_WIDTH then
      -- Check StartAddr and EndAddr Widths and Memory not initialized
        if (MemStructPtr(ID).MemArrayPtr = NULL) then 
          Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.FileWriteX:  Memory not initialized, FileWrite Ignored.", FAILURE) ; 
        else
          AlertIf(MemStructPtr(ID).AlertLogID, StartAddr'length /= ADDR_WIDTH, "MemoryPkg.FileWriteX:  StartAddr'length: " 
                               & to_string(StartAddr'length) & 
                               " /= Memory Address Width: " & to_string(ADDR_WIDTH), FAILURE) ; 
          AlertIf(MemStructPtr(ID).AlertLogID, EndAddr'length /= ADDR_WIDTH, "MemoryPkg.FileWriteX:  EndAddr'length: " 
                               & to_string(EndAddr'length) & 
                               " /= Memory Address Width: " & to_string(ADDR_WIDTH), FAILURE) ; 
        end if ; 
        return ; 
      end if ; 

      if StartAddr > EndAddr then 
      -- Only support ascending addresses
        Alert(MemStructPtr(ID).AlertLogID, "MemoryPkg.FileWriteX:  StartAddr: " & to_hxstring(StartAddr) & 
                             " > EndAddr: " & to_hxstring(EndAddr), FAILURE) ;
        return ; 
      end if ; 
            
      -- Slice out upper address to form block address
      if ADDR_WIDTH >= BLOCK_WIDTH then
        StartBlockAddr := to_integer(normStartAddr(ADDR_WIDTH-1 downto BLOCK_WIDTH)) ;
        EndBlockAddr   := to_integer(  normEndAddr(ADDR_WIDTH-1 downto BLOCK_WIDTH)) ;
      else
        StartBlockAddr  := 0 ; 
        EndBlockAddr  := 0 ; 
      end if ; 
            
      BlockAddrLoop : for BlockAddr in StartBlockAddr to EndBlockAddr loop 
        next BlockAddrLoop when MemStructPtr(ID).MemArrayPtr(BlockAddr) = NULL ;  
        if BlockAddr = StartBlockAddr then 
          StartWordAddr := to_integer(normStartAddr(BLOCK_WIDTH-1 downto 0)) ; 
        else
          StartWordAddr := 0 ;
        end if ; 
        if BlockAddr = EndBlockAddr then 
          EndWordAddr := to_integer(normEndAddr(BLOCK_WIDTH-1 downto 0)) ; 
        else 
          EndWordAddr := 2**BLOCK_WIDTH-1 ;
        end if ; 
        FoundData := FALSE ; 
        WordAddrLoop : for WordAddr in StartWordAddr to EndWordAddr loop 
          Data := FromMemoryBaseType(MemStructPtr(ID).MemArrayPtr(BlockAddr)(WordAddr), Data'length) ;
          if MetaMatch(Data, AllU) then 
            FoundData := FALSE ;
          else 
            if not FoundData then
              -- Write Address
              write(buf, '@') ; 
              hwrite(buf, to_slv(BlockAddr, ADDR_WIDTH-BLOCK_WIDTH) & to_slv(WordAddr, BLOCK_WIDTH)) ; 
              writeline(MemFile, buf) ; 
            end if ; 
            FoundData := TRUE ; 
          end if ;
          if FoundData then  -- Write Data
            if DataFormat = HEX then
              hwrite(buf, Data) ; 
              writeline(MemFile, buf) ; 
            else
              write(buf, Data) ; 
              writeline(MemFile, buf) ; 
            end if; 
          end if ;                
        end loop WordAddrLoop ; 
      end loop BlockAddrLoop ;       
      file_close(MemFile) ; 
    end FileWriteX ;
    
    ------------------------------------------------------------
    -- Hexadecimal File Write 
    procedure FileWriteH (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileWriteH") ;
    begin
      FileWriteX(ID, FileName, HEX, StartAddr, EndAddr) ; 
    end FileWriteH ;

    ------------------------------------------------------------
    -- Hexadecimal File Write 
    procedure FileWriteH (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileWriteH") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '1') ;
    begin
      FileWriteX(ID, FileName, HEX, StartAddr, EndAddr) ; 
    end FileWriteH ;

    ------------------------------------------------------------
    -- Hexadecimal File Write 
    procedure FileWriteH (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string 
    ) is 
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileWriteH") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant StartAddr   : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '0') ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '1') ;
    begin
      FileWriteX(ID, FileName, HEX, StartAddr, EndAddr) ; 
    end FileWriteH ;    
    
    ------------------------------------------------------------
    -- Binary File Write 
    procedure FileWriteB (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileWriteB") ;
    begin
      FileWriteX(ID, FileName, BINARY, StartAddr, EndAddr) ; 
    end FileWriteB ;
    
    ------------------------------------------------------------
    -- Binary File Write 
    procedure FileWriteB (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string ;  
      StartAddr    : std_logic_vector
    ) is
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileWriteB") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '1') ;
    begin
      FileWriteX(ID, FileName, BINARY, StartAddr, EndAddr) ; 
    end FileWriteB ;

    ------------------------------------------------------------
    -- Binary File Write 
    procedure FileWriteB (
    ------------------------------------------------------------
      ID           : integer ;
      FileName     : string 
    ) is 
      constant ID_CHECK_OK : boolean := IdOutOfRange(ID, "FileWriteB") ;
      constant ADDR_WIDTH  : integer := MemStructPtr(ID).AddrWidth ;
      constant StartAddr   : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '0') ;
      constant EndAddr     : std_logic_vector := (ADDR_WIDTH-1 downto 0 => '1') ;
    begin
      FileWriteX(ID, FileName, BINARY, StartAddr, EndAddr) ; 
    end FileWriteB ;  

-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Structure Wide Methods
-- /////////////////////////////////////////
-- /////////////////////////////////////////
    ------------------------------------------------------------
    -- Erase the memory
    -- Used between independent pieces of a test
    -- to erase the all memory model contents, but
    -- keeps the memory size and infrastructure
    procedure MemErase is 
    ------------------------------------------------------------
    begin
      for ID in MemStructPtr'range loop 
        MemErase(ID) ;
      end loop ;
    end procedure ; 

    ------------------------------------------------------------
    -- Destroys the entire data structure
    -- Usage:  At the end of the simulation to remove all 
    -- memory used by data structure.  
    -- Note, a normal simulator does this for you.  
    -- You only need this if the simulator is broken.
    ------------------------------------------------------------
    procedure deallocate (ID : integer) is 
    ------------------------------------------------------------
    begin
      MemErase(ID) ; 
      deallocate(MemStructPtr(ID).MemArrayPtr) ; 
      MemStructPtr(ID).AddrWidth   := -1 ;
      MemStructPtr(ID).DataWidth   := 1 ;
      MemStructPtr(ID).BlockWidth  := 0 ;
    end procedure ; 

    procedure deallocate is
    begin
      for ID in MemStructPtr'range loop 
        deallocate(ID) ;
      end loop ;
-- If this is done, nothing will work after
--      deallocate(MemStructPtr) ;   
      NumItems := 0 ; 
--      MemStructPtr := new ItemArrayType'(Template) ;   -- I--
    end procedure deallocate ; 

-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Compatibility Methods
-- /////////////////////////////////////////
-- /////////////////////////////////////////
   ------------------------------------------------------------
    procedure MemInit ( AddrWidth, DataWidth  : in  integer ) is
    ------------------------------------------------------------
    begin
      MemInit(PT_ID, AddrWidth, DataWidth) ;
    end procedure MemInit ;

    ------------------------------------------------------------
    procedure MemWrite (  Addr, Data  : in  std_logic_vector ) is 
    ------------------------------------------------------------
    begin
      MemWrite(PT_ID, Addr, Data) ; 
    end procedure MemWrite ; 

    ------------------------------------------------------------
    procedure MemRead (  
    ------------------------------------------------------------
      Addr  : In   std_logic_vector ;
      Data  : Out  std_logic_vector 
    ) is
    begin
      MemRead(PT_ID, Addr, Data) ; 
    end procedure MemRead ; 

    ------------------------------------------------------------
    impure function MemRead ( Addr  : std_logic_vector ) return std_logic_vector is
    ------------------------------------------------------------
      constant DATA_WIDTH : integer := MemStructPtr(PT_ID).DataWidth ; 
      variable Data  : std_logic_vector(DATA_WIDTH-1 downto 0) ; 
    begin
      MemRead(PT_ID, Addr, Data) ; 
      return Data ; 
    end function MemRead ; 

    ------------------------------------------------------------
    procedure SetAlertLogID (A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      MemStructPtr(PT_ID).AlertLogID  := A ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(Name : string ; ParentID : AlertLogIDType := OSVVM_MEMORY_ALERTLOG_ID ; CreateHierarchy : Boolean := TRUE) is
    ------------------------------------------------------------
    begin
      MemStructPtr(PT_ID).AlertLogID := GetAlertLogID(Name, ParentID, CreateHierarchy) ;
    end procedure SetAlertLogID ;
    
    ------------------------------------------------------------
    impure function GetAlertLogID return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return MemStructPtr(PT_ID).AlertLogID ; 
    end function GetAlertLogID ;
      
    ------------------------------------------------------------
    procedure FileReadH (
    -- Hexadecimal File Read 
    ------------------------------------------------------------
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
    begin
      FileReadH(PT_ID, FileName, StartAddr, EndAddr) ; 
    end FileReadH ;
    
    ------------------------------------------------------------
    procedure FileReadH (FileName : string ;  StartAddr : std_logic_vector) is
    -- Hexadecimal File Read 
    ------------------------------------------------------------
    begin
      FileReadH(PT_ID, FileName, StartAddr) ; 
    end FileReadH ;

    ------------------------------------------------------------
    procedure FileReadH (FileName : string) is 
    -- Hexadecimal File Read 
    ------------------------------------------------------------
    begin
      FileReadH(PT_ID, FileName) ; 
    end FileReadH ;    
    
     ------------------------------------------------------------
    procedure FileReadB (
    -- Binary File Read 
    ------------------------------------------------------------
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
    begin
      FileReadB(PT_ID, FileName, StartAddr, EndAddr) ; 
    end FileReadB ;
    
    ------------------------------------------------------------
    procedure FileReadB (FileName : string ;  StartAddr : std_logic_vector) is
    -- Binary File Read 
    ------------------------------------------------------------
    begin
      FileReadB(PT_ID, FileName, StartAddr) ; 
    end FileReadB ;

    ------------------------------------------------------------
    procedure FileReadB (FileName : string) is 
    -- Binary File Read 
    ------------------------------------------------------------
    begin
      FileReadB(PT_ID, FileName) ; 
    end FileReadB ;    

    ------------------------------------------------------------
    procedure FileWriteH (
    -- Hexadecimal File Write 
    ------------------------------------------------------------
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
    begin
      FileWriteH(PT_ID, FileName, StartAddr, EndAddr) ; 
    end FileWriteH ;
    
    ------------------------------------------------------------
    procedure FileWriteH (FileName : string ;  StartAddr : std_logic_vector) is
    -- Hexadecimal File Write 
    ------------------------------------------------------------
    begin
      FileWriteH(PT_ID, FileName, StartAddr) ; 
    end FileWriteH ;

    ------------------------------------------------------------
    procedure FileWriteH (FileName : string) is 
    -- Hexadecimal File Write 
    ------------------------------------------------------------
    begin
      FileWriteH(PT_ID, FileName) ; 
    end FileWriteH ;    
    
     ------------------------------------------------------------
    procedure FileWriteB (
    -- Binary File Write 
    ------------------------------------------------------------
      FileName     : string ; 
      StartAddr    : std_logic_vector ; 
      EndAddr      : std_logic_vector
    ) is
    begin
      FileWriteB(PT_ID, FileName, StartAddr, EndAddr) ; 
    end FileWriteB ;
    
    ------------------------------------------------------------
    procedure FileWriteB (FileName : string ;  StartAddr : std_logic_vector) is
    -- Binary File Write 
    ------------------------------------------------------------
    begin
      FileWriteB(PT_ID, FileName, StartAddr) ; 
    end FileWriteB ;

    ------------------------------------------------------------
    procedure FileWriteB (FileName : string) is 
    -- Binary File Write 
    ------------------------------------------------------------
    begin
      FileWriteB(PT_ID, FileName) ; 
    end FileWriteB ;        
  end protected body MemoryPType ;
 
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Singleton Data Structure
-- /////////////////////////////////////////
-- /////////////////////////////////////////
  shared variable MemoryStore : MemoryPType ;
 
   ------------------------------------------------------------
  impure function NewID (
    Name                : String ; 
    AddrWidth           : integer ; 
    DataWidth           : integer ; 
    ParentID            : AlertLogIDType          := OSVVM_MEMORY_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ; 
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return MemoryIDType is
    variable Result : MemoryIDType ; 
  begin
    Result.ID := MemoryStore.NewID(Name, AddrWidth, DataWidth, ParentID, ReportMode, Search, PrintParent) ; 
    return Result ; 
  end function NewID ; 

  ------------------------------------------------------------
  impure function IsInitialized (ID : MemoryIDType) return boolean is
  ------------------------------------------------------------
  begin
    return MemoryStore.IsInitialized(ID) ;
  end function IsInitialized ;

  ------------------------------------------------------------
  procedure MemWrite ( 
    ID    : MemoryIDType ; 
    Addr  : std_logic_vector ;
    Data  : std_logic_vector 
  ) is
  begin
    MemoryStore.MemWrite(ID.ID, Addr, Data) ; 
  end procedure MemWrite ; 
  
  procedure MemRead (  
    ID    : in MemoryIDType ;
    Addr  : in  std_logic_vector ;
    Data  : out std_logic_vector 
  ) is
  begin
    MemoryStore.MemRead(ID.ID, Addr, Data) ; 
  end procedure MemRead ; 
  
  impure function MemRead ( 
    ID    : MemoryIDType ; 
    Addr  : std_logic_vector 
  ) return std_logic_vector is
  begin
    return MemoryStore.MemRead(ID.ID, Addr) ; 
  end function MemRead ; 

  ------------------------------------------------------------
  procedure MemErase (ID : in MemoryIDType) is
  begin
    MemoryStore.MemErase(ID.ID) ; 
  end procedure MemErase ;  
  
  ------------------------------------------------------------
  procedure deallocate (ID : in MemoryIDType) is 
  begin
    MemoryStore.deallocate(ID.ID) ; 
  end procedure ; 

  ------------------------------------------------------------
  procedure MemoryPkgDeallocate is
  begin
    MemoryStore.deallocate ; 
  end procedure MemoryPkgDeallocate ; 

  ------------------------------------------------------------
  impure function GetAlertLogID (
    ID : in MemoryIDType
  ) return AlertLogIDType is
  begin
    return MemoryStore.GetAlertLogID(ID.ID) ; 
  end function GetAlertLogID ; 
  
  ------------------------------------------------------------
  procedure FileReadH (    -- Hexadecimal File Read 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) is
  begin
    MemoryStore.FileReadH(ID.ID, FileName, StartAddr, EndAddr) ; 
  end procedure FileReadH ; 
  
  procedure FileReadH (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) is
  begin
    MemoryStore.FileReadH(ID.ID, FileName, StartAddr) ; 
  end procedure FileReadH ; 

  procedure FileReadH (
    ID           : MemoryIDType ;
    FileName     : string 
  ) is
  begin
    MemoryStore.FileReadH(ID.ID, FileName) ; 
  end procedure FileReadH ; 

  ------------------------------------------------------------
  procedure FileReadB (    -- Binary File Read 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) is
  begin
    MemoryStore.FileReadB(ID.ID, FileName, StartAddr, EndAddr) ; 
  end procedure FileReadB ; 

  procedure FileReadB (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) is
  begin
    MemoryStore.FileReadB(ID.ID, FileName, StartAddr) ; 
  end procedure FileReadB ; 

  procedure FileReadB (
    ID           : MemoryIDType ;
    FileName     : string 
  ) is
  begin
    MemoryStore.FileReadB(ID.ID, FileName) ; 
  end procedure FileReadB ; 

  ------------------------------------------------------------
  procedure FileWriteH (    -- Hexadecimal File Write 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) is
  begin
    MemoryStore.FileWriteH(ID.ID, FileName, StartAddr, EndAddr) ; 
  end procedure FileWriteH ; 

  procedure FileWriteH (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) is
  begin
    MemoryStore.FileWriteH(ID.ID, FileName, StartAddr) ; 
  end procedure FileWriteH ; 
  
  procedure FileWriteH (
    ID           : MemoryIDType ;
    FileName     : string 
  ) is
  begin
    MemoryStore.FileWriteH(ID.ID, FileName) ; 
  end procedure FileWriteH ; 
  
  ------------------------------------------------------------
  procedure FileWriteB (    -- Binary File Write 
    ID           : MemoryIDType ;
    FileName     : string ; 
    StartAddr    : std_logic_vector ; 
    EndAddr      : std_logic_vector
  ) is
  begin
    MemoryStore.FileWriteB(ID.ID, FileName, StartAddr, EndAddr) ; 
  end procedure FileWriteB ; 
  
  procedure FileWriteB (
    ID           : MemoryIDType ;
    FileName     : string ;  
    StartAddr    : std_logic_vector
  ) is
  begin
    MemoryStore.FileWriteB(ID.ID, FileName, StartAddr) ; 
  end procedure FileWriteB ; 

  procedure FileWriteB (
    ID           : MemoryIDType ;
    FileName     : string 
  ) is
  begin
    MemoryStore.FileWriteB(ID.ID, FileName) ; 
  end procedure FileWriteB ; 
end MemoryGenericPkg ;