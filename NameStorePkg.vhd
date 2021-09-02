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
--    06/2021   2021.06    Initial revision.  Derrived from NamePkg.vhd
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2021 by SynthWorks Design Inc.  
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

package NameStorePkg is
 
  type NameIDType is record
    ID : integer_max ;
  end record NameIDType ; 
  alias NameStoreIDType is NameIDType ; 
  type NameIDArrayType is array (integer range <>) of NameIDType ;  

  constant ID_NOT_FOUND : NameIDType := (ID => -1) ; 
  
  impure function NewID     (NameIn : String) return NameIDType ;
--  impure function NewID     (NameIn : String ; Size : positive ) return NameStoreIDArrayType ;
  procedure       Set       (ID : NameIDType ; NameIn : String) ;
  impure function Get       (ID : NameIDType ;  DefaultName : string := "") return string ;
  impure function Find (NameIn : String) return NameIDType ;
  impure function GetOpt    (ID : NameIDType) return string ;
  impure function IsSet     (ID : NameIDType) return boolean ; 
  procedure       Clear     (ID : NameIDType) ; -- clear name
  procedure       Deallocate(ID : NameIDType) ; -- effectively alias to clear name

  type NameStorePType is protected
    impure function NewID     (NameIn : String) return integer ;
--    impure function NewID     (NameIn : String ; Size : positive ) return integer_vector ;
    procedure       Set       (ID : integer ; NameIn : String) ;
    impure function Get       (ID : integer ;  DefaultName : string := "") return string ;
    impure function Find (NameIn : String) return integer ;
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

    type  LineArrayType    is array (integer range <>) of Line ; 
    type  LineArrayPtrType is access LineArrayType ;

    variable NameArrayPtr   : LineArrayPtrType ;   
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
      variable ItemArrayPtr     : InOut LineArrayPtrType ;
      constant NewNumItems      : in integer ;
      constant CurNumItems      : in integer ;
      constant MinNumItems      : in integer 
    ) is
      variable oldItemArrayPtr  : LineArrayPtrType ;
      constant NormNumItems : integer := NormalizeArraySize(NewNumItems, MinNumItems) ;
    begin
      if ItemArrayPtr = NULL then
        ItemArrayPtr := new LineArrayType(1 to NormNumItems) ;
      elsif NewNumItems > ItemArrayPtr'length then
        oldItemArrayPtr := ItemArrayPtr ;
        ItemArrayPtr := new LineArrayType(1 to NormNumItems) ;
        ItemArrayPtr(1 to CurNumItems) := oldItemArrayPtr(1 to CurNumItems) ;
        deallocate(oldItemArrayPtr) ;
      end if ;
    end procedure GrowNumberItems ;

    ------------------------------------------------------------
    impure function NewID (NameIn : String) return integer is
    ------------------------------------------------------------
      variable NewNumItems : integer ;
    begin
      NewNumItems := NumItems + 1 ; 
      GrowNumberItems(NameArrayPtr, NewNumItems, NumItems, MIN_NUM_ITEMS) ;
      NumItems  := NewNumItems ;
      Set(NumItems, NameIn) ; 
      return NumItems ; 
    end function NewID ;

    ------------------------------------------------------------
    procedure Set (ID : integer ; NameIn : String) is
    ------------------------------------------------------------
    begin
      deallocate(NameArrayPtr(ID)) ;
      NameArrayPtr(ID) := new string'(NameIn) ;
    end procedure Set ;

    ------------------------------------------------------------
    impure function Get (ID : integer ; DefaultName : string := "") return string is
    ------------------------------------------------------------
    begin
      if NameArrayPtr(ID) = NULL then 
        return DefaultName ; 
      else
        return NameArrayPtr(ID).all ; 
      end if ; 
    end function Get ;

    ------------------------------------------------------------
    impure function Find (NameIn : String) return integer is
    ------------------------------------------------------------
    begin
      for ID in 1 to NumItems loop 
        if NameIn = NameArrayPtr(ID).all then 
          return ID ;
        end if ;
      end loop ;
      return ID_NOT_FOUND.ID ;
    end function Find ;

    ------------------------------------------------------------
    impure function GetOpt (ID : integer) return string is
    ------------------------------------------------------------
    begin
      if NameArrayPtr(ID) = NULL then 
        return NUL & "" ; 
      else
        return NameArrayPtr(ID).all ; 
      end if ; 
    end function GetOpt ;

    ------------------------------------------------------------
    impure function IsSet (ID : integer) return boolean is 
    ------------------------------------------------------------
    begin
      return NameArrayPtr(ID) /= NULL ; 
    end function IsSet ;      
    
    ------------------------------------------------------------
    procedure Clear (ID : integer) is
    ------------------------------------------------------------
    begin
      deallocate(NameArrayPtr(ID)) ;
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
  impure function NewID (NameIn : String) return NameIDType is
  ------------------------------------------------------------
    variable Result : NameIDType ; 
  begin
    Result.ID := NameStore.NewID(NameIn) ;
    return Result ; 
  end function NewID ;

  ------------------------------------------------------------
  procedure Set (ID : NameIDType ; NameIn : String) is
  ------------------------------------------------------------
  begin
    NameStore.set(ID.ID, NameIn) ;
  end procedure Set ;

  ------------------------------------------------------------
  impure function Get (ID : NameIDType ; DefaultName : string := "") return string is
  ------------------------------------------------------------
  begin
    return NameStore.Get(ID.ID, DefaultName) ;
  end function Get ;

  ------------------------------------------------------------
  impure function Find (NameIn : String) return NameIDType is
  ------------------------------------------------------------
  begin
    return NameIDType'(ID => NameStore.Find(NameIn)) ;
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
  
end package body NameStorePkg ;