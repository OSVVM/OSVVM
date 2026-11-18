--
--  File Name:         SetGetBoundedGenericPkg.vhd
--  Design Unit Name:  NameStorePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--  Description:
--      Emulates package generics using subtypes, constants,
--      and unfortunately a copy of the generic package (no changes though)
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.08    Initial revision.  Derived from NamePkg.vhd
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2026 by SynthWorks Design Inc.
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

------------------------------------------------------------
------------------------------------------------------------
package SetGetBoundedPkg_boolean is
  subtype SetGetType is boolean ;
  constant InitValue : SetGetType := FALSE ;
  type PType is protected
    procedure Set (A : SetGetType) ;
    impure function get return SetGetType ;
  end protected PType ;
end package SetGetBoundedGenericPkg ;
------------------------------------------------------------
package body SetGetBoundedGenericPkg is
  type PType is protected body
    variable SetGetVar : SetGetType := InitValue ;
    procedure Set (A : SetGetType) is
    begin
       SetGetVar := A ;
    end procedure Set ;
    impure function get return SetGetType is
    begin
      return SetGetVar ;
    end function get ;
  end protected body PType ;
end package body SetGetBoundedGenericPkg ;

------------------------------------------------------------
------------------------------------------------------------
package SetGetBoundedPkg_integer is
  subtype  SetGetType is integer ;
  constant InitValue : SetGetType := 0 ;
  type PType is protected
    procedure Set (A : SetGetType) ;
    impure function get return SetGetType ;
  end protected PType ;
end package SetGetBoundedPkg_integer ;
------------------------------------------------------------
package body SetGetBoundedPkg_integer is
  type PType is protected body
    variable SetGetVar : SetGetType := InitValue ;
    procedure Set (A : SetGetType) is
    begin
       SetGetVar := A ;
    end procedure Set ;
    impure function get return SetGetType is
    begin
      return SetGetVar ;
    end function get ;
  end protected body PType ;
end package body SetGetBoundedPkg_integer ;

