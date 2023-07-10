use std.textio.all;

package CommonLogPkg is
  constant IsOriginalPkg : boolean;
  constant NoTime : time := -1 ns;
  constant NoVal : integer := integer'low;

  -- Converts a log message and associated metadata to a string written to the specified log destination.
  procedure WriteToLog(
    ----------------------------------------------------
    -- Log entry items common to many logging frameworks
    ----------------------------------------------------

    -- Destination of the log message is either std.textio.output (std output) or a text file object previously opened
    -- for writing
    file LogDestination : text;
    -- Path to LogDestination if it's a file, empty string otherwise
    LogDestinationPath : string := "";
    -- Log message
    Msg : string := "";
    -- Simulation time associated with the log message
    LogTime : time := NoTime;
    -- Level associated with the log message. For example "DEBUG" or "WARNING".
    LogLevel : string := "";
    -- Name of the producer of the log message. Hierarchical names use colon as the delimiter.
    -- For example "parent_component:child_component".
    LogSourceName : string := "";

    ----------------------------------------------------------------------------------------------------------------------------
    -- Log entry items less commonly used are passed to the procedure with no-name string and integer parameters which
    -- meaning is specific to an implementation of the procedure. The documentation below is valid for OSVVM only
    ----------------------------------------------------------------------------------------------------------------------------

    Str1, -- WritePrefix
    Str2, -- Write error counter
    Str3, -- Log or alert
    Str4, -- Prefix
    Str5, -- Suffix
    Str6, Str7, Str8, Str9, Str10 : string := "";

    Val1, -- AlertLogJustifyAmount
    Val2, -- Write level
    Val3, -- Write time first
    Val4, -- Write time last
    Val5, -- TimeJustifyAmount
    Val6, Val7, Val8, Val9, Val10 : integer := NoVal);
end package;
