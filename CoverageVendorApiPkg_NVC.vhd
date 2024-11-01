--
--  File Name:         CoverageVendorApiPkg_NVC.vhd
--  Design Unit Name:  CoverageVendorApiPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Based on work done in package CoverageVendorApiPkg_Aldec.vhd by:
--     ...
--
--
--  Package Defines
--     A set of foreign procedures that link OSVVM's CoveragePkg
--     coverage model creation and coverage capture with the
--     built-in capability of a simulator.
--
--
--  Revision History:      For more details, see CoveragePkg_release_notes.pdf
--    Date      Version    Description
--    11/2024   2024.11    Initial revision - derived from CoverageVendorApiPkg_default
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2016 - 2024 by SynthWorks Design Inc.
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

library nvc;
use nvc.cover_pkg.all;

package CoverageVendorApiPkg is

  subtype VendorCovHandleType is t_scope_handle;
  impure function INIT_VENDOR_COV_HANDLE return VendorCovHandleType ;

    -- Types for how coverage bins are represented.  Matches OSVVM types.
  type VendorCovRangeType is record
      min: integer;
      max: integer;
  end record;

  type VendorCovRangeArrayType is array ( integer range <> ) of VendorCovRangeType;

  --  Create Initial Data Structure for Point/Item Functional Coverage Model
  --  Sets initial name of the coverage model if available
  impure function VendorCovPointCreate( name: string ) return VendorCovHandleType;

  --  Create Initial Data Structure for Cross Functional Coverage Model
  --  Sets initial name of the coverage model if available
  impure function VendorCovCrossCreate( name: string ) return VendorCovHandleType;

  --  Sets/Updates the name of the Coverage Model.
  --  Should not be called until the data structure is created by VendorCovPointCreate or VendorCovCrossCreate.
  --  Replaces name that was set by VendorCovPointCreate or VendorCovCrossCreate.
  procedure VendorCovSetName(obj: inout VendorCovHandleType; name: string );

  --  Add a bin or set of bins to either a Point/Item or Cross Functional Coverage Model
  --  Checking for sizing that is different from original sizing already done in OSVVM CoveragePkg
  --  It is important to maintain an index that corresponds to the order the bins were entered as
  --  that is used when coverage is recorded.
  procedure VendorCovBinAdd(obj: inout VendorCovHandleType; bins: VendorCovRangeArrayType; Action: integer; atleast: integer; name: string );

  --  Increment the coverage of bin identified by index number.
  --  Index ranges from 1 to Number of Bins.
  --  Index corresponds to the order the bins were entered (starting from 1)
  procedure VendorCovBinInc(obj: inout VendorCovHandleType; index: integer );

  constant COV_COUNT   : integer := 1;
  constant COV_IGNORE  : integer := 0;
  constant COV_ILLEGAL : integer := -1;

end package;

package body CoverageVendorApiPkg is

  impure function INIT_VENDOR_COV_HANDLE return VendorCovHandleType IS
  begin
    return null ;
  end function INIT_VENDOR_COV_HANDLE ;

  --  Create Initial Data Structure for Point/Item Functional Coverage Model
  --  Sets initial name of the coverage model if available
  impure function VendorCovPointCreate( name: string ) return VendorCovHandleType is
    variable handle : VendorCovHandleType;
  begin
    if name = "" then
      create_cover_scope (handle, "__OSVVM_COVER_POINT");
    else
      create_cover_scope (handle, name);
    end if;

    return handle;
  end function VendorCovPointCreate ;

  --  Create Initial Data Structure for Cross Functional Coverage Model
  --  Sets initial name of the coverage model if available
  impure function VendorCovCrossCreate( name: string ) return VendorCovHandleType is
    variable handle : VendorCovHandleType;
  begin
    if name = "" then
      create_cover_scope (handle, "__OSVVM_COVER_POINT");
    else
      create_cover_scope (handle, name);
    end if;

    return handle;
  end function VendorCovCrossCreate ;

  --  Sets/Updates the name of the Coverage Model.
  --  Should not be called until the data structure is created by VendorCovPointCreate or VendorCovCrossCreate.
  --  Replaces name that was set by VendorCovPointCreate or VendorCovCrossCreate.
  procedure VendorCovSetName(obj: inout VendorCovHandleType; name: string ) is
  begin
    if name = "" then
      set_cover_scope_name(obj, "__OSVVM_COVER_POINT");
    else
      set_cover_scope_name(obj, name);
    end if;
  end procedure VendorCovSetName ;

  --  Add a bin or set of bins to either a Point/Item or Cross Functional Coverage Model
  --  Checking for sizing that is different from original sizing already done in OSVVM CoveragePkg
  --  It is important to maintain an index that corresponds to the order the bins were entered as
  --  that is used when coverage is recorded.
  procedure VendorCovBinAdd(obj: inout VendorCovHandleType; bins: VendorCovRangeArrayType; Action: integer; atleast: integer; name: string )is
    variable item           : t_item_handle;
    variable ranges         : t_item_range_array(1 to bins'length);
    variable atleast_valid  : natural;
   begin
    for i in 1 to bins'length loop
      ranges(i).min := t_item_range_value(bins(i).min);
      ranges(i).max := t_item_range_value(bins(i).max);
    end loop;

    if (action = COV_IGNORE or action = COV_ILLEGAL or atleast < 0) then
      atleast_valid := 0;
    else
      atleast_valid := atleast;
    end if;

    if name = "" then
      add_cover_item(obj, item, "__OSVVM_COVER_BIN", atleast_valid, ranges);
    else
      add_cover_item(obj, item, name, atleast_valid, ranges);
    end if;
  end procedure VendorCovBinAdd ;

  --  Increment the coverage of bin identified by index number.
  --  Index ranges from 1 to Number of Bins.
  --  Index corresponds to the order the bins were entered (starting from 1)
  procedure VendorCovBinInc(obj: inout VendorCovHandleType; index: integer )is
  begin
   increment_cover_item(obj, t_item_handle(index - 1));
  end procedure VendorCovBinInc ;

end package body CoverageVendorApiPkg ;
