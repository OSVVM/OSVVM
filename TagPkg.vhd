--
--  File Name:         TagPkg.vhd
--  Design Unit Name:  TagPkg
--
--  Description:
--    Tag storage + YAML formatting helpers.
--    Extracted from AlertLogPkg to keep AlertLogPkg focused on alert/logging.
--

use std.textio.all ;

library IEEE ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

use work.TextUtilPkg.all ;
use work.YamlUtilPkg.all ;

package TagPkg is

  -- Tag value type (stored as string + explicit type)
  type TagValueType is (
    TAG_STRING,
    TAG_BOOL,
    TAG_INT,
    TAG_REAL,
    TAG_TIME,
    TAG_STD_LOGIC
  ) ;

  function TagValueTypeToString(A : TagValueType) return string ;

  -- Default time units used when formatting time tags
  procedure SetTagDefaultTimeUnits(A : time) ;
  impure function GetTagDefaultTimeUnits return time ;

  procedure AddTag(TagName : string ; TagValue : string    ; ShowInSummary : boolean := TRUE) ;
  procedure AddTag(TagName : string ; TagValue : boolean   ; ShowInSummary : boolean := TRUE) ;
  procedure AddTag(TagName : string ; TagValue : integer   ; ShowInSummary : boolean := TRUE) ;
  procedure AddTag(TagName : string ; TagValue : real      ; ShowInSummary : boolean := TRUE) ;
  procedure AddTag(TagName : string ; TagValue : std_logic ; ShowInSummary : boolean := TRUE) ;
  procedure AddTag(TagName : string ; TagValue : time      ; ShowInSummary : boolean := TRUE) ;

  procedure ClearTags ;
  impure function GetNumTags return natural ;

  -- Writes only the tag records (no "Tags:" header)
  procedure WriteTagsYaml(
    file TestFile : text ;
    Prefix        : string
  ) ;

end package TagPkg ;

package body TagPkg is

  function TagValueTypeToString(A : TagValueType) return string is
  begin
    case A is
      when TAG_STRING    => return "TAG_STRING" ;
      when TAG_BOOL      => return "TAG_BOOL" ;
      when TAG_INT       => return "TAG_INT" ;
      when TAG_REAL      => return "TAG_REAL" ;
      when TAG_TIME      => return "TAG_TIME" ;
      when TAG_STD_LOGIC => return "TAG_STD_LOGIC" ;
    end case ;
  end function TagValueTypeToString ;


  type TagRecType ;
  type TagRecPtrType is access TagRecType ;
  type TagRecType is record
    Name          : line ;
    TagType       : TagValueType ;
    ValueStr      : line ;
    ShowInSummary : boolean ;
    NextTag       : TagRecPtrType ;
  end record TagRecType ;

  type TagStructPType is protected
    procedure SetDefaultTimeUnits(A : time) ;
    impure function GetDefaultTimeUnits return time ;

    procedure AddTag(TagName : string ; TagValue : string ; TagType : TagValueType ; ShowInSummary : boolean := TRUE) ;
    procedure ClearTags ;
    impure function GetNumTags return natural ;
    impure function GetTagName(Index : natural) return string ;
    impure function GetTagValueStr(Index : natural) return string ;
    impure function GetTagType(Index : natural) return TagValueType ;
    impure function GetTagShowInSummary(Index : natural) return boolean ;
  end protected TagStructPType ;

  type TagStructPType is protected body
    variable DefaultTimeUnitsVar : time := 1 ns ;
    variable TagHeadPtr : TagRecPtrType ;
    variable NumTagsVar : natural := 0 ;

    procedure FindOrCreateTag(
      TagName         : string ;
      TagType         : TagValueType ;
      ShowInSummary   : boolean ;
      variable TagPtr : out TagRecPtrType
    ) is
      variable CurTag  : TagRecPtrType ;
      variable PrevTag : TagRecPtrType ;
      variable NewTag  : TagRecPtrType ;
    begin
      CurTag  := TagHeadPtr ;
      PrevTag := null ;
      while CurTag /= null loop
        if CurTag.Name /= null and CurTag.Name.all = TagName then
          CurTag.TagType       := TagType ;
          CurTag.ShowInSummary := ShowInSummary ;
          TagPtr := CurTag ;
          return ;
        end if ;
        PrevTag := CurTag ;
        CurTag  := CurTag.NextTag ;
      end loop ;

      NewTag               := new TagRecType ;
      NewTag.Name          := new string'(TagName) ;
      NewTag.TagType       := TagType ;
      NewTag.ValueStr      := null ;
      NewTag.ShowInSummary := ShowInSummary ;
      NewTag.NextTag       := null ;

      if TagHeadPtr = null then
        TagHeadPtr := NewTag ;
      else
        PrevTag.NextTag := NewTag ;
      end if ;

      NumTagsVar := NumTagsVar + 1 ;
      TagPtr := NewTag ;
    end procedure FindOrCreateTag ;

    procedure SetDefaultTimeUnits(A : time) is
    begin
      DefaultTimeUnitsVar := A ;
    end procedure SetDefaultTimeUnits ;

    impure function GetDefaultTimeUnits return time is
    begin
      return DefaultTimeUnitsVar ;
    end function GetDefaultTimeUnits ;

    procedure AddTag(TagName : string ; TagValue : string ; TagType : TagValueType ; ShowInSummary : boolean := TRUE) is
      variable CurTag : TagRecPtrType ;
    begin
      FindOrCreateTag(TagName, TagType, ShowInSummary, CurTag) ;
      Deallocate(CurTag.ValueStr) ;
      CurTag.ValueStr := new string'(TagValue) ;
    end procedure AddTag ;

    procedure ClearTags is
      variable CurTag  : TagRecPtrType ;
      variable NextTag : TagRecPtrType ;
    begin
      CurTag := TagHeadPtr ;
      while CurTag /= null loop
        NextTag := CurTag.NextTag ;
        Deallocate(CurTag.Name) ;
        Deallocate(CurTag.ValueStr) ;
        Deallocate(CurTag) ;
        CurTag := NextTag ;
      end loop ;
      TagHeadPtr := null ;
      NumTagsVar := 0 ;
    end procedure ClearTags ;

    impure function GetNumTags return natural is
    begin
      return NumTagsVar ;
    end function GetNumTags ;

    impure function GetTagName(Index : natural) return string is
      variable CurTag : TagRecPtrType ;
      variable Pos    : natural := 0 ;
    begin
      CurTag := TagHeadPtr ;
      while CurTag /= null loop
        Pos := Pos + 1 ;
        if Pos = Index then
          if CurTag.Name /= null then
            return CurTag.Name.all ;
          else
            return "" ;
          end if ;
        end if ;
        CurTag := CurTag.NextTag ;
      end loop ;
      return "" ;
    end function GetTagName ;

    impure function GetTagValueStr(Index : natural) return string is
      variable CurTag : TagRecPtrType ;
      variable Pos    : natural := 0 ;
    begin
      CurTag := TagHeadPtr ;
      while CurTag /= null loop
        Pos := Pos + 1 ;
        if Pos = Index then
          if CurTag.ValueStr /= null then
            return CurTag.ValueStr.all ;
          else
            return "" ;
          end if ;
        end if ;
        CurTag := CurTag.NextTag ;
      end loop ;
      return "" ;
    end function GetTagValueStr ;

    impure function GetTagType(Index : natural) return TagValueType is
      variable CurTag : TagRecPtrType ;
      variable Pos    : natural := 0 ;
    begin
      CurTag := TagHeadPtr ;
      while CurTag /= null loop
        Pos := Pos + 1 ;
        if Pos = Index then
          return CurTag.TagType ;
        end if ;
        CurTag := CurTag.NextTag ;
      end loop ;
      return TAG_STRING ;
    end function GetTagType ;

    impure function GetTagShowInSummary(Index : natural) return boolean is
      variable CurTag : TagRecPtrType ;
      variable Pos    : natural := 0 ;
    begin
      CurTag := TagHeadPtr ;
      while CurTag /= null loop
        Pos := Pos + 1 ;
        if Pos = Index then
          return CurTag.ShowInSummary ;
        end if ;
        CurTag := CurTag.NextTag ;
      end loop ;
      return TRUE ;
    end function GetTagShowInSummary ;
  end protected body TagStructPType ;

  shared variable TagStruct : TagStructPType ;

  procedure SetTagDefaultTimeUnits(A : time) is
  begin
    TagStruct.SetDefaultTimeUnits(A) ;
  end procedure SetTagDefaultTimeUnits ;

  impure function GetTagDefaultTimeUnits return time is
  begin
    return TagStruct.GetDefaultTimeUnits ;
  end function GetTagDefaultTimeUnits ;

  procedure AddTag(TagName : string ; TagValue : string ; ShowInSummary : boolean := TRUE) is
  begin
    TagStruct.AddTag(TagName, TagValue, TAG_STRING, ShowInSummary) ;
  end procedure AddTag ;

  procedure AddTag(TagName : string ; TagValue : boolean ; ShowInSummary : boolean := TRUE) is
  begin
    if TagValue then
      TagStruct.AddTag(TagName, "true", TAG_BOOL, ShowInSummary) ;
    else
      TagStruct.AddTag(TagName, "false", TAG_BOOL, ShowInSummary) ;
    end if ;
  end procedure AddTag ;

  procedure AddTag(TagName : string ; TagValue : integer ; ShowInSummary : boolean := TRUE) is
  begin
    TagStruct.AddTag(TagName, to_string(TagValue), TAG_INT, ShowInSummary) ;
  end procedure AddTag ;

  procedure AddTag(TagName : string ; TagValue : real ; ShowInSummary : boolean := TRUE) is
  begin
    TagStruct.AddTag(TagName, RealToCompactString(TagValue), TAG_REAL, ShowInSummary) ;
  end procedure AddTag ;

  procedure AddTag(TagName : string ; TagValue : std_logic ; ShowInSummary : boolean := TRUE) is
  begin
    TagStruct.AddTag(TagName, std_logic'image(TagValue), TAG_STD_LOGIC, ShowInSummary) ;
  end procedure AddTag ;

  procedure AddTag(TagName : string ; TagValue : time ; ShowInSummary : boolean := TRUE) is
  begin
    TagStruct.AddTag(TagName, to_string(TagValue, TagStruct.GetDefaultTimeUnits), TAG_TIME, ShowInSummary) ;
  end procedure AddTag ;

  procedure ClearTags is
  begin
    TagStruct.ClearTags ;
  end procedure ClearTags ;

  impure function GetNumTags return natural is
  begin
    return TagStruct.GetNumTags ;
  end function GetNumTags ;

  procedure WriteTagsYaml(
    file TestFile : text ;
    Prefix        : string
  ) is
    variable TagTypeVar : TagValueType ;
    constant NumTagsVar : natural := TagStruct.GetNumTags ;
    variable TagNameStr  : line ;
    variable TagValueStr : line ;
  begin
    for i in 1 to NumTagsVar loop
      TagTypeVar := TagStruct.GetTagType(i) ;
      Deallocate(TagNameStr) ;
      Deallocate(TagValueStr) ;
      TagNameStr  := new string'(TagStruct.GetTagName(i)) ;
      TagValueStr := new string'(TagStruct.GetTagValueStr(i)) ;

      case TagTypeVar is
        when TAG_STRING =>
          if TagValueStr /= null and TagValueStr.all'length > 0 then
            WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, TagValueStr.all, TRUE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
          else
            WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, "", TRUE, TRUE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
          end if ;

        when TAG_BOOL | TAG_INT | TAG_REAL =>
          if TagValueStr /= null and TagValueStr.all'length > 0 then
            WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, TagValueStr.all, FALSE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
          else
            -- Default to zero-equivalent
            if TagTypeVar = TAG_BOOL then
              WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, "false", FALSE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
            else
              WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, "0", FALSE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
            end if ;
          end if ;

        when TAG_TIME | TAG_STD_LOGIC =>
          if TagValueStr /= null and TagValueStr.all'length > 0 then
            WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, TagValueStr.all, TRUE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
          else
            if TagTypeVar = TAG_TIME then
              WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, "0 ns", TRUE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
            else
              WriteYamlInlineTagRecord(TestFile, Prefix, TagNameStr.all, std_logic'image('U'), TRUE, FALSE, TagValueTypeToString(TagTypeVar), TagStruct.GetTagShowInSummary(i)) ;
            end if ;
          end if ;
      end case ;
    end loop ;

    Deallocate(TagNameStr) ;
    Deallocate(TagValueStr) ;
  end procedure WriteTagsYaml ;

end package body TagPkg ;
