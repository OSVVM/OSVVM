use std.textio.all;

package CommonLogPkg is
  constant IsOriginalPkg : boolean;
  constant NoTime : time := -1 ns;
  constant NoString : string := "";

  -- Converts a log message and associated metadata to a string written to the specified log destination.
  procedure WriteToLog(
    ----------------------------------------------------
    -- Log entry items common to many logging frameworks
    ----------------------------------------------------

    -- Destination of the log message is either std.textio.output (std output) or a text file object previously opened
    -- for writing
    file LogDestination : text;
    -- Path to LogDestination if it's a file, empty string otherwise
    LogDestinationPath : string := NoString;
    -- Log message
    Msg : string := NoString;
    -- Simulation time associated with the log message
    LogTime : time := NoTime;
    -- Level associated with the log message. For example "DEBUG" or "WARNING".
    LogLevel : string := NoString;
    -- Name of the producer of the log message. Hierarchical names use colon as the delimiter.
    -- For example "parent_component:child_component".
    LogSourceName : string := NoString;

    ----------------------------------------------------------------------------------------------------------------------------
    -- Log entry items less commonly used are passed to the procedure with no-name string, integer and boolean parameters which
    -- meaning is specific to an implementation of the procedure. The documentation below is valid for OSVVM only
    ----------------------------------------------------------------------------------------------------------------------------

    Str1, -- WritePrefix
    Str2, -- Write error counter
    Str3, -- Log or alert
    Str4, -- Prefix
    Str5, -- Suffix
    Str6, Str7, Str8, Str9, Str10 : string := "";

    Int1, -- AlertLogJustifyAmount
    Int2, -- TimeJustifyAmount
    Int3, Int4, Int5, Int6, Int7, Int8, Int9, Int10 : integer := 0;

    Bool1, -- Write level
    Bool2, -- Write time first
    Bool3, -- Write time last
    Bool4, Bool5, Bool6, Bool7, Bool8, Bool9, Bool10 : boolean := false);
end package;
