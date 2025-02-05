--
--  File Name:         NameStorePkg.vhd
--  Design Unit Name:  NameStorePkg
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
--    07/2024   2024.07    Added IsInitialized
--    05/2024   2024.05    Calls to singleton forgot to pass ParentID and Search parameter to internal Protected type calls
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.   
--    02/2022   2022.02    Updated NewID for Updated NewID and Find with ParentID and Search.   
--                         Supports searching in CoveragePkg, ScoreboardGenericPkg, and MemoryPkg.
--    06/2021   2021.06    Initial revision.  Derrived from NamePkg.vhd
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2021-2022 by SynthWorks Design Inc.  
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
use work.ResolutionPkg.all ; 
use work.AlertLogPkg.all ; 

package NameStorePkg is
 
  type NameIDType is record
    ID : integer_max ;
  end record NameIDType ; 
  alias NameStoreIDType is NameIDType ; 
  type NameIDArrayType is array (integer range <>) of NameIDType ;  
  type NameSearchType is (PRIVATE_NAME, NAME, NAME_AND_PARENT, NAME_AND_PARENT_ELSE_PRIVATE) ; 
  constant ID_NOT_FOUND : NameIDType := (ID => -1) ; 
  constant NAME_ID_UNINITIALZED : NameIdType := (ID => integer'low) ; 
  
  ------------------------------------------------------------
  impure function NewID (
    iName    : String ;
    ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
    Search   : NameSearchType := NAME 
  ) return NameIDType ;
  
  ------------------------------------------------------------
  impure function IsInitialized (ID : NameIDType) return boolean ;

  ------------------------------------------------------------
  procedure Set (
    ID       : NameIDType ; 
    iName    : String ;
    ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
    Search   : NameSearchType := NAME 
  ) ;
  
  impure function Get       (ID : NameIDType ;  DefaultName : string := "") return string ;
  
  ------------------------------------------------------------
  impure function Find (
    iName    : String ;
    ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
    Search   : NameSearchType := NAME 
  ) return NameIDType ;
  
  impure function GetOpt    (ID : NameIDType) return string ;
  impure function IsSet     (ID : NameIDType) return boolean ; 
  procedure       Clear     (ID : NameIDType) ; -- clear name
  procedure       Deallocate(ID : NameIDType) ; -- effectively alias to clear name
  
  ------------------------------------------------------------
  -- Helper function for NewID in data structures
  function ResolveSearch (
    UniqueParent : boolean ;
    Search       : NameSearchType  
  ) return NameSearchType ;

  type NameStorePType is protected

    ------------------------------------------------------------
    impure function NewID (
      iName    : String ;
      ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
      Search   : NameSearchType := NAME 
    ) return integer ;

    ------------------------------------------------------------
    impure function IsInitialized (ID : NameIDType) return boolean ;

    ------------------------------------------------------------
    procedure Set (
      ID       : integer ; 
      iName    : String ;
      ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
      Search   : NameSearchType := NAME 
    ) ;
    
    impure function Get       (ID : integer ;  DefaultName : string := "") return string ;
    
    ------------------------------------------------------------
    impure function Find (
      iName    : String ;
      ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
      Search   : NameSearchType := NAME 
    ) return integer ;
    
    impure function GetOpt    (ID : integer) return string ;
    impure function IsSet     (ID : integer) return boolean ; 
    procedure       Clear     (ID : integer) ; -- clear name
    procedure       Deallocate(ID : integer) ; -- effectively alias to clear name
  end protected NameStorePType ;

end package NameStorePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body NameStorePkg is

  type NameStorePType is protected body

    type NameItemRecType is record
      Name     : Line ; 
      ParentID : AlertLogIDType ; 
      Search   : NameSearchType ;  
    end record NameItemRecType ; 
    
    type  NameArrayType    is array (integer range <>) of NameItemRecType ; 
    type  NameArrayPtrType is access NameArrayType ;

--    type  LineArrayType    is array (integer range <>) of Line ; 
--    type  LineArrayPtrType is access LineArrayType ;
--    variable NameArrayPtr   : LineArrayPtrType ;   

    variable NameArrayPtr   : NameArrayPtrType ;   
    variable NumItems       : integer := 0 ; 
--    constant MIN_NUM_ITEMS  : integer := 4 ; -- Temporarily small for testing
    constant MIN_NUM_ITEMS  : integer := 32 ; -- Min amount to resize array

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
      variable ItemArrayPtr     : InOut NameArrayPtrType ;
      variable NumItems         : InOut integer ;
      constant GrowAmount       : in integer ;
      constant MinNumItems      : in integer 
    ) is
      variable oldItemArrayPtr  : NameArrayPtrType ;
--!!Xc      constant NewNumItems      : integer := NumItems + GrowAmount ; 
--!!Xc      constant NewSize : integer := NormalizeArraySize(NewNumItems, MinNumItems) ;
      variable NewNumItems  : integer ;
      variable NewSize      : integer ;
    begin
      NewNumItems := NumItems + GrowAmount ; 
      NewSize     := NormalizeArraySize(NewNumItems, MinNumItems) ;
      if ItemArrayPtr = NULL then
        ItemArrayPtr := new NameArrayType(1 to NewSize) ;
      elsif NewNumItems > ItemArrayPtr'length then
        oldItemArrayPtr := ItemArrayPtr ;
        ItemArrayPtr := new NameArrayType(1 to NewSize) ;
        ItemArrayPtr.all(1 to NumItems) := oldItemArrayPtr.all(1 to NumItems) ;
        deallocate(oldItemArrayPtr) ;
      end if ;
      NumItems := NewNumItems ; 
    end procedure GrowNumberItems ;

    ------------------------------------------------------------
    impure function NewID (
    ------------------------------------------------------------
      iName    : String ;
      ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
      Search   : NameSearchType := NAME 
    ) return integer is
    begin
      GrowNumberItems(NameArrayPtr, NumItems, 1, MIN_NUM_ITEMS) ;
      Set(NumItems, iName, ParentID, Search) ; 
      return NumItems ; 
    end function NewID ;

    ------------------------------------------------------------
    impure function IsInitialized (ID : NameIDType) return boolean is
    ------------------------------------------------------------
    begin
      return ID /= NAME_ID_UNINITIALZED ;
    end function IsInitialized ;

    ------------------------------------------------------------
    procedure Set (
    ------------------------------------------------------------
      ID       : integer ; 
      iName    : String ;
      ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
      Search   : NameSearchType := NAME 
    ) is
    begin
      deallocate(NameArrayPtr(ID).Name) ;
      NameArrayPtr(ID).Name     := new string'(iName) ;
      NameArrayPtr(ID).Search   := Search ;
      NameArrayPtr(ID).ParentID := ParentID ;
    end procedure Set ;

    ------------------------------------------------------------
    impure function Get (ID : integer ; DefaultName : string := "") return string is
    ------------------------------------------------------------
    begin
      if NameArrayPtr(ID).Name = NULL then 
        return DefaultName ; 
      else
        return NameArrayPtr(ID).Name.all ; 
      end if ; 
    end function Get ;

    ------------------------------------------------------------
    -- Local
    impure function FindName (iName : String) return integer is
    ------------------------------------------------------------
    begin
      for ID in 1 to NumItems loop 
        -- skip if private
        next when NameArrayPtr(ID).Search = PRIVATE_NAME ; 
        -- find Name
        if iName = NameArrayPtr(ID).Name.all then 
          return ID ;
        end if ;
      end loop ;
      return ID_NOT_FOUND.ID ;
    end function FindName ;

    ------------------------------------------------------------
    -- Local
    impure function FindNameAndParent (iName : String; ParentID : AlertLogIdType) return integer is
    ------------------------------------------------------------
    begin
      for ID in 1 to NumItems loop 
        -- skip if private
        next when NameArrayPtr(ID).Search = PRIVATE_NAME ; 
        -- find Name and Parent
        if iName = NameArrayPtr(ID).Name.all and (ParentID = NameArrayPtr(ID).ParentID or NameArrayPtr(ID).Search = NAME) then 
          return ID ;
        end if ;
      end loop ;
      return ID_NOT_FOUND.ID ;
    end function FindNameAndParent ;

    ------------------------------------------------------------
    impure function Find (
    ------------------------------------------------------------
      iName    : String ;
      ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
      Search   : NameSearchType := NAME 
    ) return integer is
    begin
      case Search is
        when PRIVATE_NAME =>       return ID_NOT_FOUND.ID ;
        when NAME    =>       return FindName(iName) ;
        when others  =>       return FindNameAndParent(iName, ParentID) ; 
      end case ; 
    end function Find ;

    ------------------------------------------------------------
    impure function GetOpt (ID : integer) return string is
    ------------------------------------------------------------
    begin
      if NameArrayPtr(ID).Name = NULL then 
        return NUL & "" ; 
      else
        return NameArrayPtr(ID).Name.all ; 
      end if ; 
    end function GetOpt ;

    ------------------------------------------------------------
    impure function IsSet (ID : integer) return boolean is 
    ------------------------------------------------------------
    begin
      return NameArrayPtr(ID).Name /= NULL ; 
    end function IsSet ;      
    
    ------------------------------------------------------------
    procedure Clear (ID : integer) is
    ------------------------------------------------------------
    begin
      deallocate(NameArrayPtr(ID).Name) ;
    end procedure Clear ;
    
    ------------------------------------------------------------
    procedure Deallocate(ID : integer) is
    ------------------------------------------------------------
    begin
      Clear(ID) ;
    end procedure Deallocate ;
  end protected body NameStorePType ;
  

-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Singleton Data Structure
-- /////////////////////////////////////////
-- /////////////////////////////////////////
  shared variable NameStore : NameStorePType ; 
  
  ------------------------------------------------------------
  impure function NewID (
  ------------------------------------------------------------
    iName    : String ;
    ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
    Search   : NameSearchType := NAME 
  ) return NameIDType is
    variable Result : NameIDType ; 
  begin
    Result.ID := NameStore.NewID(iName, ParentID, Search) ;
    return Result ; 
  end function NewID ;

  ------------------------------------------------------------
  impure function IsInitialized (ID : NameIDType) return boolean is
  ------------------------------------------------------------
  begin
    return NameStore.IsInitialized(ID) ;
  end function IsInitialized ;

  ------------------------------------------------------------
  procedure Set (
  ------------------------------------------------------------
    ID       : NameIDType ; 
    iName    : String ;
    ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
    Search   : NameSearchType := NAME 
  ) is
  begin
    NameStore.set(ID.ID, iName, ParentID, Search) ;
  end procedure Set ;

  ------------------------------------------------------------
  impure function Get (ID : NameIDType ; DefaultName : string := "") return string is
  ------------------------------------------------------------
  begin
    return NameStore.Get(ID.ID, DefaultName) ;
  end function Get ;

  ------------------------------------------------------------
  impure function Find (
  ------------------------------------------------------------
    iName    : String ;
    ParentID : AlertLogIdType := ALERTLOG_BASE_ID ;
    Search   : NameSearchType := NAME 
  ) return NameIDType is
  begin
    return NameIDType'(ID => NameStore.Find(iName, ParentID, Search)) ;
  end function Find ;

  ------------------------------------------------------------
  impure function GetOpt (ID : NameIDType) return string is
  ------------------------------------------------------------
  begin
    return NameStore.Get(ID.ID) ;
  end function GetOpt ;

  ------------------------------------------------------------
  impure function IsSet (ID : NameIDType) return boolean is 
  ------------------------------------------------------------
  begin
    return NameStore.IsSet(ID.ID) ;
  end function IsSet ;      
  
  ------------------------------------------------------------
  procedure Clear (ID : NameIDType) is
  ------------------------------------------------------------
  begin
    NameStore.Clear(ID.ID) ;
  end procedure Clear ;
  
  ------------------------------------------------------------
  procedure Deallocate(ID : NameIDType) is
  ------------------------------------------------------------
  begin
    NameStore.Clear(ID.ID) ;
  end procedure Deallocate ;
  
  ------------------------------------------------------------
  -- Helper function for NewID in data structures
  function ResolveSearch (
  ------------------------------------------------------------
    UniqueParent : boolean ;
    Search       : NameSearchType  
  ) return NameSearchType is
    variable result : NameSearchType ; 
  begin
    if search = NAME_AND_PARENT_ELSE_PRIVATE then 
      result := NAME_AND_PARENT when UniqueParent else PRIVATE_NAME ;
    else 
      result := Search ; 
    end if ; 
    return result ; 
  end function ResolveSearch ; 
  
end package body NameStorePkg ;