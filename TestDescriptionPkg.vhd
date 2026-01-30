--
--  File Name:         TestDescriptionPkg.vhd
--  Design Unit Name:  TestDescriptionPkg
--
--  Description:
--    Test title/brief/description and tag storage + YAML formatting helpers.
--

use std.textio.all ;

library IEEE ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

use work.TextUtilPkg.all ;
use work.YamlUtilPkg.all ;
use work.TagPkg.all ;

package TestDescriptionPkg is

  -- Test Title (short human-friendly label).  Kept separate from test Name.
  procedure SetTestTitle(Title : string ) ;

  -- Test Description and Tags for complex test scenarios
  procedure SetTestBrief(Brief : string ) ;
  procedure SetTestDescription(Description : string ) ;
  -- Append one line to the test description. Automatically inserts LF between lines.
  -- This allows writing readable multi-line descriptions without "& LF &" concatenation.
  procedure AppendTestDescriptionLine(Line : string ) ;
  -- Short alias for AppendTestDescriptionLine.
  alias DescLn is AppendTestDescriptionLine [string] ;

  procedure AddTestTag(TagName : string ; TagValue : string    ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTag(TagName : string ; TagValue : boolean   ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTag(TagName : string ; TagValue : integer   ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTag(TagName : string ; TagValue : time      ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTag(TagName : string ; TagValue : real      ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTag(TagName : string ; TagValue : std_logic ; ShowInSummary : boolean := TRUE ) ;

  -- Array-type tag helpers: avoid overloading AddTestTag on array types (string literals can match arrays)
  procedure AddTestTagUnsigned(TagName : string ; TagValue : unsigned         ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTagSigned  (TagName : string ; TagValue : signed           ; ShowInSummary : boolean := TRUE ) ;
  procedure AddTestTagSlv     (TagName : string ; TagValue : std_logic_vector ; ShowInSummary : boolean := TRUE ) ;

  procedure ClearTestTitle ;
  procedure ClearTestBrief ;
  procedure ClearTestDescription ;
  procedure ClearTestTags ;

  impure function GetTestTitle return string ;
  impure function GetTestBrief return string ;
  impure function GetTestDescription return string ;

  -- Default time units used when formatting time tags (matches OSVVM default time units behavior).
  procedure SetTestTagDefaultTimeUnits(A : time) ;
  impure function GetTestTagDefaultTimeUnits return time ;

  procedure WriteTestDescriptionYaml(
    file TestFile  : text ;
    Prefix         : string
  ) ;

end package TestDescriptionPkg ;

package body TestDescriptionPkg is

  type TestDescriptionStructPType is protected
    procedure SetTitle(Title : string) ;
    procedure ClearTitle ;
    impure function GetTitle return string ;

    procedure SetBrief(Brief : string) ;
    procedure ClearBrief ;
    impure function GetBrief return string ;

    procedure SetDescription(Description : string) ;
    procedure AppendDescriptionLine(LineText : string) ;
    procedure ClearDescription ;
    impure function GetDescription return string ;

    procedure SetDefaultTimeUnits(A : time) ;
    impure function GetDefaultTimeUnits return time ;
  end protected TestDescriptionStructPType ;

  type TestDescriptionStructPType is protected body
    variable TitlePtr            : line ;
    variable BriefPtr            : line ;
    variable DescriptionPtr      : line ;
    variable DefaultTimeUnitsVar : time := 1 ns ;

    procedure SetTitle(Title : string) is
    begin
      Deallocate(TitlePtr) ;
      TitlePtr := new string'(Title) ;
    end procedure SetTitle ;

    procedure ClearTitle is
    begin
      Deallocate(TitlePtr) ;
      TitlePtr := null ;
    end procedure ClearTitle ;

    impure function GetTitle return string is
    begin
      if TitlePtr /= null then
        return TitlePtr.all ;
      else
        return "" ;
      end if ;
    end function GetTitle ;

    procedure SetBrief(Brief : string) is
    begin
      Deallocate(BriefPtr) ;
      BriefPtr := new string'(Brief) ;
    end procedure SetBrief ;

    procedure ClearBrief is
    begin
      Deallocate(BriefPtr) ;
      BriefPtr := null ;
    end procedure ClearBrief ;

    impure function GetBrief return string is
    begin
      if BriefPtr /= null then
        return BriefPtr.all ;
      else
        return "" ;
      end if ;
    end function GetBrief ;

    procedure SetDescription(Description : string) is
    begin
      Deallocate(DescriptionPtr) ;
      DescriptionPtr := new string'(Description) ;
    end procedure SetDescription ;

    procedure AppendDescriptionLine(LineText : string) is
      variable OldDescriptionVar : std.textio.line ;
    begin
      if DescriptionPtr = null then
        DescriptionPtr := new string'(LineText) ;
      elsif DescriptionPtr.all'length = 0 then
        Deallocate(DescriptionPtr) ;
        DescriptionPtr := new string'(LineText) ;
      else
        OldDescriptionVar := DescriptionPtr ;
        DescriptionPtr := new string'(OldDescriptionVar.all & LF & LineText) ;
        Deallocate(OldDescriptionVar) ;
      end if ;
    end procedure AppendDescriptionLine ;

    procedure ClearDescription is
    begin
      Deallocate(DescriptionPtr) ;
      DescriptionPtr := null ;
    end procedure ClearDescription ;

    impure function GetDescription return string is
    begin
      if DescriptionPtr /= null then
        return DescriptionPtr.all ;
      else
        return "" ;
      end if ;
    end function GetDescription ;

    procedure SetDefaultTimeUnits(A : time) is
    begin
      DefaultTimeUnitsVar := A ;
    end procedure SetDefaultTimeUnits ;

    impure function GetDefaultTimeUnits return time is
    begin
      return DefaultTimeUnitsVar ;
    end function GetDefaultTimeUnits ;

  end protected body TestDescriptionStructPType ;

  shared variable TestDescriptionStruct : TestDescriptionStructPType ;

  procedure SetTestTitle(Title : string ) is
  begin
    TestDescriptionStruct.SetTitle(Title) ;
  end procedure SetTestTitle ;

  procedure ClearTestTitle is
  begin
    TestDescriptionStruct.ClearTitle ;
  end procedure ClearTestTitle ;

  procedure SetTestBrief(Brief : string ) is
  begin
    TestDescriptionStruct.SetBrief(Brief) ;
  end procedure SetTestBrief ;

  procedure ClearTestBrief is
  begin
    TestDescriptionStruct.ClearBrief ;
  end procedure ClearTestBrief ;

  procedure SetTestDescription(Description : string ) is
  begin
    TestDescriptionStruct.SetDescription(Description) ;
  end procedure SetTestDescription ;

  procedure AppendTestDescriptionLine(Line : string ) is
  begin
    TestDescriptionStruct.AppendDescriptionLine(Line) ;
  end procedure AppendTestDescriptionLine ;

  procedure ClearTestDescription is
  begin
    TestDescriptionStruct.ClearDescription ;
  end procedure ClearTestDescription ;

  impure function GetTestTitle return string is
  begin
    return TestDescriptionStruct.GetTitle ;
  end function GetTestTitle ;

  impure function GetTestBrief return string is
  begin
    return TestDescriptionStruct.GetBrief ;
  end function GetTestBrief ;

  impure function GetTestDescription return string is
  begin
    return TestDescriptionStruct.GetDescription ;
  end function GetTestDescription ;

  procedure SetTestTagDefaultTimeUnits(A : time) is
  begin
    TestDescriptionStruct.SetDefaultTimeUnits(A) ;
    SetTagDefaultTimeUnits(A) ;
  end procedure SetTestTagDefaultTimeUnits ;

  impure function GetTestTagDefaultTimeUnits return time is
  begin
    return TestDescriptionStruct.GetDefaultTimeUnits ;
  end function GetTestTagDefaultTimeUnits ;

  procedure AddTestTag(TagName : string ; TagValue : string ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTag(TagName, TagValue, ShowInSummary) ;
  end procedure AddTestTag ;

  procedure AddTestTag(TagName : string ; TagValue : boolean ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTag(TagName, TagValue, ShowInSummary) ;
  end procedure AddTestTag ;

  procedure AddTestTag(TagName : string ; TagValue : integer ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTag(TagName, TagValue, ShowInSummary) ;
  end procedure AddTestTag ;

  procedure AddTestTag(TagName : string ; TagValue : time ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTag(TagName, TagValue, ShowInSummary) ;
  end procedure AddTestTag ;

  procedure AddTestTag(TagName : string ; TagValue : real ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTag(TagName, TagValue, ShowInSummary) ;
  end procedure AddTestTag ;

  procedure AddTestTag(TagName : string ; TagValue : std_logic ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTag(TagName, TagValue, ShowInSummary) ;
  end procedure AddTestTag ;

  procedure AddTestTagUnsigned(TagName : string ; TagValue : unsigned ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTestTag(TagName, to_hxstring(TagValue), ShowInSummary) ;
  end procedure AddTestTagUnsigned ;

  procedure AddTestTagSigned(TagName : string ; TagValue : signed ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTestTag(TagName, to_hxstring(TagValue), ShowInSummary) ;
  end procedure AddTestTagSigned ;

  procedure AddTestTagSlv(TagName : string ; TagValue : std_logic_vector ; ShowInSummary : boolean := TRUE ) is
  begin
    AddTestTag(TagName, to_hxstring(TagValue), ShowInSummary) ;
  end procedure AddTestTagSlv ;

  procedure ClearTestTags is
  begin
    ClearTags ;
  end procedure ClearTestTags ;

  procedure WriteTestDescriptionYaml(
    file TestFile  : text ;
    Prefix         : string
  ) is
    variable buf : line ;
    constant TitleStr : string := TestDescriptionStruct.GetTitle ;
    constant BriefStr : string := TestDescriptionStruct.GetBrief ;
    constant DescStr  : string := TestDescriptionStruct.GetDescription ;
  begin
    if TitleStr'length > 0 then
      WriteYamlDoubleQuotedScalar(TestFile, Prefix, "Title", TitleStr) ;
    end if ;

    if BriefStr'length > 0 then
      WriteYamlDoubleQuotedScalar(TestFile, Prefix, "Brief", BriefStr) ;
    end if ;

    if DescStr'length > 0 then
      WriteYamlLiteralBlockScalar(TestFile, Prefix, "Description", DescStr) ;
    end if ;

    if GetNumTags > 0 then
      write(buf, Prefix & "Tags:") ;
      writeline(TestFile, buf) ;
      WriteTagsYaml(TestFile, Prefix) ;
    end if ;
  end procedure WriteTestDescriptionYaml ;

end package body TestDescriptionPkg ;
