use std.textio.all;

package CommonLogPkg is
  constant IsOriginalPkg : boolean;
  constant NoTime : time := -1 ns;
  constant NoString : string := "";

  -- Converts a log message and associated metadata to a string written to the specified log destination.
  procedure WriteToLog(
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
    LogSourceName : string := NoString
  );
end package;
