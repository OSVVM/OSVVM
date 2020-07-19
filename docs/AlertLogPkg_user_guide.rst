AlertLogPkg User Guide
######################


Whats New 2020.05:  A Quick Highlight
=====================================

The big enhancement in this revision is the addition of PASSED counts
for both the top level error summary as well as a per hierarchy level
(verification model and sublevels). For more details see the release
notes at the end.

AlertLogPkg Overview  
==================== 

Error reporting and messaging is an important part of any testbench.

Printing too many messages can significantly slow a test down. So for
messaging, we need the ability to turn messages on (such as for debug or
the final test report) and turn them off.

For error reporting, we need to be able to report messages as they
happen as well as produce a summary report when a test finishes. Hence,
we need a mechanism to record the number of errors that have happened.

VHDL assert and TextIO capability can certainly do some of this,
however, these take work and lack in capability (until VHDL-2019 where
we gave them a simple OSVVM like interface).

Simple Mode: Errors and Messaging in a Basic Testbench
======================================================

First include OSVVM library in your testbench. You can do this by
referencing the context declaration that includes all of OSVVM's
packages:

.. code-block:: VHDL

   Library osvvm ;
   use osvvm.OsvvmContext ;

Name the test by calling SetAlertLogName. This name prints as part of
the summary report that is done either at the end of the test or if the
test reaches a stop condition (such as a FAILURE – more on this later).

.. code-block:: VHDL

   SetAlertLogName("AxiLite_Uart1") ;

Messages in OSVVM are called logs. The following indicates the start of
a UART transmit transaction:

.. code-block:: VHDL

   Log("Uart Sending Data: X" & to_hstring(TxData), ALWAYS) ;

This will print as:

.. code-block:: bash

   %% Log ALWAYS Uart Sending Data: X4A at 15110 ns

Logs have levels ALWAYS, DEBUG, FINAL, INFO, and PASSED. Log level
ALWAYS always prints. The remaining logs print when they are enabled and
are disabled by default. ALWAYS is the default if a level is not
specified.

Enable a log with SetLogEnable.

.. code-block:: VHDL

   SetLogEnable(INFO, TRUE) ;

Now that we have INFO messages enabled, let's rewrite our original log
to use INFO as we may wish to turn it off when we are running
regressions.

.. code-block:: VHDL

   Log("Uart Sending Data: X" & to_hstring(TxData), INFO) ;

This will print as:

.. code-block:: bash

   %% Log INFO Uart Sending Data: X4A at 15110 ns

The same method is used to turn DEBUG or any other message on or off.
Generally it is recommended to call SetLogEnable from the top level
testbench, however, it can be called from anywhere in the testbench
infrastructure.

Alerts are for signaling error conditions. The following is a protocol
checker that flags an error if the X86Lite model receives an acknowledge
when the interface is idle.

.. code-block:: VHDL

   X86_Rdy_Check: process
   begin
     wait until Rising_Edge(Clk) and nRdy = '1' ;
     AlertIf(BusIdle, "X86 Lite received ready when it was idle", ERROR) ;
   end process ;

This will print as:

.. code-block:: bash

  %% Alert ERROR X86 Lite received ready when it was idle at 15110 ns

Alerts have levels FAILURE, ERROR, and WARNING. Error is the default if
a level is not specified. Alerts are enabled by default. Alerts are
disabled using SetAlertEnable.

.. code-block:: VHDL

   SetAlertEnable(WARNING, FALSE) ; -- Test still fails, see Disabling Alerts

Affirmations are for adding checking to tests. When an affirmation
passes, it calls log with PASSED and when it fails it calls Alert with
ERROR.

.. code-block:: VHDL

   AffirmIf(RxData = Expected, "RxData, Actual: " & to_hstring(RxDat),
       "Expected: " & to_hstring(Expected)) ;

Note there are two strings associated with AffirmIf. The first is for
the received value from the DUT (actual) and the second is for the
expected value. When AffirmIf passes and log level "PASSED" is enabled,
the following message will print.

.. code-block:: bash

   %% Log PASSED RxData, Actual: X4A at 15110 ns

When AffirmIf is FALSE, the following message will print.

.. code-block:: bash

   %% Alert ERROR RxData, Actual: 52 Expected: 4A at 15110 ns

As Alerts (FAILURE, ERROR, WARNING), PASSED, and affirmations occur, a
data structure inside the AlertLogPkg tabulates them. When the test is
done, a summary message can be created by calling ReportAlerts.

.. code-block:: VHDL

   ReportAlerts ;

If the test passed, a message such as the following prints.

.. code-block:: bash

   %% DONE PASSED AxiLite_Uart1 Passed: 14 Affirmations Checked: 14 at 380810 ns

If the test failed, a message such as the following prints. The line
starts with "%%" and prints on a single line (here shown with line wrap
to fit in the text).

.. code-block:: bash

   %% DONE FAILED AxiLite_Uart1 Total Error(s) = 6 Failures: 0 Errors: 6 Warnings: 0 Passed: 8 Affirmations Checked: 14 at 380810 ns

This is enough to get you started with basic testbenches. Read on when
you are ready for more capability. Even for basic testbenches, you will
want to learn about the overloading of Alerts and Affirmations as well
as alert stop counts.

Hierarchy Mode: Model Based Error and Message Handling
======================================================

As testbench complexity increases, it helps to know which model a
particular error came from. This is what hierarchy mode is all about. We
also get a better summary report from ReportAlerts.

First include OSVVM library in your testbench. You can do this by
referencing the context declaration that includes all of OSVVM's
packages:

.. code-block:: VHDL

   Library osvvm ;
   use osvvm.OsvvmContext ;

Name the test by calling SetAlertLogName. This name prints as part of
the summary report that is done either at the end of the test or if the
test reaches a stop condition (such as a FAILURE – more on this later).

.. code-block:: VHDL

   SetAlertLogName("AxiLite_Uart1") ;

In hierarchy mode, each source (generally each verification model) has
its own AlertLogID. Create one by declaring it.

.. code-block:: VHDL

   signal ModelID : AlertLogIDType ;

Next get the AlertLogID by calling GetAlertLogID

.. code-block:: VHDL

   Initialize : process
   begin
     ModelID <= GetAlertLogID("AxiMaster") ;
     wait ;
   end process Initialize ;

It would be nice to be able to do this in one step in a declaration such
as the following, and indeed all simulators it has been tested on it
works, but formally the VHDL LRM says one is not allowed to access a
protected type in a declarative region.

.. code-block:: VHDL

   signal ModelID : AlertLogIDType := GetAlertLogID("AxiMaster") ;

Sometimes a model may wish to further classify its Alerts and Logs into
subclasses. This is done as follows.

.. code-block:: VHDL

   signal ModelID, ProtocolID, CheckerID : AlertLogIDType ;
   . . .
   Initialize : process
     Variable ID : AlertLogID ;
   begin
     ID := GetAlertLogID("AxiMaster") ;
     ModelID <= ID ;
     ProtocolID := GetAlertLogID("AxiMaster: Protocol", ID) ;
     CheckerID := GetAlertLogID("AxiMaster: Checker", ID) ;
     wait ;
   end process Initialize ;

Ok. The hard part is done. On all calls to Log, SetLogEnable, AlertIf,
AffirmIf, SetAlertEnable, … the AlertLogID is specified as the first
parameter to the call.

Alerts and Logs can be enabled (or disabled) either for the entire
testbench or for a single model. However to do this in the testbench, we
need to get the AlertLogID for the model. No problem. We can use
GetAlertLogID to look up the AlertLogID by using the same string used in
its definition in the component.

.. code-block:: VHDL

   signal TBID, AxiMasterID, UartTxID, UartRxID : AlertLogIDType ;
   . . .
   Control : process
   begin
     TBID <= GetAlertLogID("TB") ;
     AxiMasterID <= GetAlertLogID("AxiMaster") ; -- These names must match
     UartTxID <= GetAlertLogID("UartTx") ; -- the names used in the component
     UartRxID <= GetAlertLogID("UartRx") ;
     . . .
     SetLogEnable(PASSED, TRUE) ; -- Turn on for ALL Levels
     SetLogEnable(UartTxID, INFO, TRUE) ; -- Turn on just UartTxID
     wait ;
   end process Control ;

Above first we turned on PASSED for all AlertLogIDs, but only turned on
INFO for the UartTx model. If you have worked with UARTs you will
understand that this is an important capability in tracking what is
happening in the UART. If we cannot do this, we have to hunt for the
infrequent message from the UART mixed in with the multitude of messages
from the AxiMaster.

Adding log in the UartTx model.

.. code-block:: VHDL

   Log(ModelID, "Uart Sending Data: X" & to_hstring(TxData), INFO) ;

This will print as the following. Note the context information, "In
UartTx,".

.. code-block:: bash

   %% Log INFO In UartTx, Uart Sending Data: X4A at 15110 ns

Updating the protocol checker in the X86Lite model.

.. code-block:: VHDL

   X86_Rdy_Check: process
   begin
     wait until Rising_Edge(Clk) and nRdy = '1' ;
     AlertIf(ProtocolID, BusIdle, "X86 Lite received ready when it was idle");
   end process ;

This will print as:

.. code-block:: bash

   %% Alert ERROR In X86Lite, X86 Lite received ready when it was idle at 15110 ns

Updating the affirmation using the equivalent form of AffirmIfEqual and
doing it from the testbench.

.. code-block:: VHDL

   AffirmIfEqual(TBID, RxData, Expected, "RxData, ") ;

When AffirmIfEqual passes and log level "PASSED" is enabled, the
following message will print.

.. code-block:: bash

   %% Log PASSED In TB, RxData, Actual: X4A at 15110 ns

When AffirmIfEqual fails, the following message will print.

.. code-block:: bash

   %% Alert ERROR In TB, RxData, Actual: 52 Expected: 4A at 15110 ns

When the test is done, a summary message is created by calling
ReportAlerts.

.. code-block:: VHDL

   ReportAlerts ;

If the test passed, we get the same simple message as for Simple Mode.

.. code-block:: bash

   %% DONE PASSED AxiLite_Uart1 Passed: 14 Affirmations Checked: 14 at 380810 ns

If the test failed, we get a summary as well as details for each source.
The line starts with "%%" and prints on a single line (here shown with
line wrap to fit in the text).

.. code-block:: bash

   %% DONE FAILED AxiLite_Uart1 Total Error(s) = 7 Failures: 0 Errors: 7 Warnings: 0 Passed: 8 Affirmations Checked: 14 at 380810 ns
   %% Default Failures: 0 Errors: 0 Warnings: 0 Passed: 0
   %% OSVVM Failures: 0 Errors: 0 Warnings: 0 Passed: 0
   %% TB Failures: 0 Errors: 2 Warnings: 0 Passed: 2
   %% AxiMaster Failures: 0 Errors: 3 Warnings: 0 Passed: 0
   %% AxiMaster: Protocol Failures: 0 Errors: 1 Warnings: 0 Passed: 0
   %% AxiMaster: Checker Failures: 0 Errors: 2 Warnings: 0 Passed: 2
   %% UartTx Failures: 0 Errors: 0 Warnings: 0 Passed: 2
   %% UartRx Failures: 0 Errors: 2 Warnings: 0 Passed: 2

Note errors in the Default bin would be the result of calling an alert
or affirmation without an AlertLogID.

Package References
==================

To keep it simple use the OSVVM context clause:

.. code-block:: VHDL

   library osvvm ;
   context osvvm.OsvvmContext ;

Alternately to just use AlertLogPkg use the following package
references:

.. code-block:: VHDL

   library osvvm ;
   use osvvm.OsvvmGlobalPkg.all ; -- required to call SetAlertLogOptions
   use osvvm.AlertLogPkg.all ;

Setting the Test Name and AlertLogIDs
=====================================

Tests always start in simple model. Hierarchical mode is automatically
entered when GetAlertLogID is called.

All overloading supported for simple mode is also supported in
hierarchical mode. The only difference is that in hierarchical mode, the
first parameter is the AlertLogID.

Also note that when in hierarchical mode, any alert, log, or affirmation
that is called without an AlertLogID will use the "Default" bin.

SetAlertLogName: Setting the Test Name
--------------------------------------

SetAlertLogName sets the name of the current test that is printed by
ReportAlerts. This is particularly recommended if a test can end due to
a stop count, such as FAILURE as ReportAlerts is automatically called.

.. code-block:: VHDL

   procedure SetAlertLogName(Name : string ) ;
   . . .
   SetAlertLogName("AxiLite_Uart1") ;

GetAlertLogName
---------------

GetAlertLogName returns the string value of name associated with an
AlertLogID. If no AlertLogID is specified, it will return the name set
by SetAlertLogName.

.. code-block:: VHDL

   impure function GetAlertLogName(AlertLogID : AlertLogIDType:= ALERTLOG_BASE_ID) return string ;

GetAlertLogID: Creating Hierarchy 
---------------------------------

Each level in a hierarchy is referenced with an AlertLogID. The
function, GetAlertLogID, creates a new AlertLogID. If an AlertLogID
already exists for the specified name, GetAlertLogID will return its
AlertLogID. It is recommended to use the instance label as the Name. The
interface for GetAlertLogID is as follows.

.. code-block:: VHDL

   impure function GetAlertLogID(
     Name : string ;
     ParentID : AlertLogIDType := ALERTLOG_BASE_ID ;
     CreateHierarchy : Boolean := TRUE
   ) return AlertLogIDType ;

The CreateHierarchy parameter is intended to allow packages to use a
unique AlertLogID for reporting Alerts without creating hierarchy in
ReportAlerts. As a function, GetAlertLogID can be called while
elaborating the design by using it to initialize a constant or signal:

.. code-block:: VHDL

   Constant UartID : AlertLogIDType := GetAlertLogID("UART_1", ALERTLOG_BASE_ID);
                                                   -- Name, Parent AlertLogID

FindAlertLogID: Find an AlertLogID
----------------------------------

The function, FindAlertLogID, finds an existing AlertLogID. Only use it
after time 0 ns when an AlertLogID may or may not exist. If the
AlertLogID is not found, ALERTLOG_ID_NOT_FOUND is returned. Caution, at
time 0 ns, FindAlertLogID may return ALERTLOG_ID_NOT_FOUND for an ID
that has not been initialized by the model yet. Use GetAlertID for this
situation. It is ok if the testbench creates the ID and then the model
uses it.

The interface for FindAlertLogID is as follows.

.. code-block:: VHDL

   impure function FindAlertLogID(Name : string ; ParentID : AlertLogIDType) return AlertLogIDType ;
   impure function FindAlertLogID(Name : string ) return AlertLogIDType ;

Note the single parameter FindAlertLogID is only useful when there is
only one AlertLogID with a particular name (such as for top-level
instance names). As a function, FindAlertLogID can be called while
elaborating the design by using it to initialize a constant or signal.

.. code-block:: VHDL

   constant UartID : AlertLogIDType := FindAlertLogID(Name => "UART_1") ;

PathTail - Used to Discover Instance Name of a Component
--------------------------------------------------------

When used in conjunction with attribute PATH_NAME applied to an entity
name, PathTail returns the instance name of component.

.. code-block:: VHDL

   constant CPU_ALERT_ID : AlertLogIDType := GetAlertLogID(PathTail(CpuModel'PATH_NAME), ALERTLOG_BASE_ID) ;
                                                         -- Name (string value),         Parent AlertLogID

GetAlertLogParentID
-------------------

Get the AlertLogID of the parent of a specified AlertLogID.

.. code-block:: VHDL

   impure function GetAlertLogParentID(AlertLogID : AlertLogIDType) return AlertLogIDType ;

Alert Method Reference 
======================

Alert is intended for parameter error checking. For self-checking see
affirmations.

AlertType 
---------

Alert levels can be FAILURE, ERROR, or WARNING.

.. code-block:: VHDL

   type AlertType is (FAILURE, ERROR, WARNING) ;

Alert
-----

Alert generates an alert. The following overloading is supported.

.. code-block:: VHDL

   procedure alert(
     AlertLogID : AlertLogIDType ;
     Message : string ;
     Level : AlertType := ERROR
   ) ;
   
   procedure Alert( Message : string ; Level : AlertType := ERROR ) ;

Usage of alert:

.. code-block:: VHDL

   . . .
   Alert(UartID, "Uart Parity", ERROR) ;
   Alert("Uart Parity") ; -- ERROR by default

AlertIf and AlertIfNot
----------------------

Alert has two conditional forms, AlertIf and AlertIfNot. The following
is their overloading.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AlertIf( AlertLogID : AlertLogIDType ; condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) ;
   impure function AlertIf( AlertLogID : AlertLogIDType ; condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) return boolean ;

   procedure AlertIfNot( AlertLogID : AlertLogIDType ; condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) ;
   impure function AlertIfNot( AlertLogID : AlertLogIDType ; condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) return boolean ;

   -- without an AlertLogID
   procedure AlertIf( condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) ;
   impure function AlertIf( condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) return boolean ;

   procedure AlertIfNot( condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) ;
   impure function AlertIfNot( condition : boolean ;
                      Message : string ; Level : AlertType := ERROR ) return boolean ;

Usage of conditional alerts:

.. code-block:: VHDL

   -- with an AlertLogID
   AlertIf(UartID, Break='1', "Uart Break", ERROR) ;
   AlertIfNot(UartID, ReadValid, "Read", FAILURE);
   
   -- without an AlertLogID
   AlertIf(Break='1', "Uart Break", ERROR) ;
   AlertIfNot(ReadValid, "Read Failed", FAILURE) ;
   
The function form is convenient for use for conditional exit of a loop.
   
.. code-block:: VHDL

   exit AlertIfNot(UartID, ReadValid, "in ReadCovDb while reading …",
   FAILURE) ;

AlertIfEqual and AlertIfNotEqual
--------------------------------

Alert form AlertIfEqual and AlertIfNotEqual to check two values. In the
following, AType can be std_logic, std_logic_vector, unsigned, signed,
integer, real, character, string, or time.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AlertIfEqual( AlertLogID : AlertLogIDType ; L, R : AType ;
                Message : string ; Level : AlertType := ERROR ) ;
   procedure AlertIfNotEqual( AlertLogID : AlertLogIDType ; L, R : AType ;
                Message : string ; Level : AlertType := ERROR ) ;
   
   -- without an AlertLogID
   procedure AlertIfEqual( L, R : AType ; Message : string ;
                Level : AlertType := ERROR ) ; Message : string ;
   procedure AlertIfNotEqual( L, R : AType ;
                Level : AlertType := ERROR ) ;
             
AlertIfDiff
-----------

Alert form AlertIfDiff is for comparing two files.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AlertIfDiff (AlertLogID : AlertLogIDType ; Name1, Name2 : string;
                   Message : string := "" ; Level : AlertType := ERROR ) ;
   procedure AlertIfDiff (AlertLogID : AlertLogIDType ; file File1, File2 : text;
                   Message : string := "" ; Level : AlertType := ERROR ) ;
   
   -- without an AlertLogID
   procedure AlertIfDiff (Name1, Name2 : string; Message : string := "" ;
                   Level : AlertType := ERROR ) ;
   procedure AlertIfDiff (file File1, File2 : text; Message : string := "" ;
                   Level : AlertType := ERROR ) ;

IncrementAlertCount
-------------------

Intended as a silent alert. Used by CoveragePkg.

.. code-block:: VHDL

   -- Hierarchy
   procedure IncAlertCount( -- A silent form of alert
     AlertLogID : AlertLogIDType ;
     Level : AlertType := ERROR
   ) ;
   
   -- Global Alert Counters
   procedure IncAlertCount( Level : AlertType := ERROR ) ;

SetAlertEnable: Alert Enable / Disable
--------------------------------------

Alerts are enabled by default. SetAlertEnable allows alert levels to be
individually enabled or disabled. When used without AlertLogID,
SetAlertEnable sets a value for all AlertLogIDs.

.. code-block:: VHDL

   procedure SetAlertEnable(Level : AlertType ; Enable : boolean) ;
   . . .
   -- Level, Enable
   SetAlertEnable(WARNING, FALSE) ;

When an AlertLogID is used, SetAlertEnable sets a value for that
AlertLogID, and if DescendHierarchy is TRUE, it’s the AlertLogID's of
its children.

.. code-block:: VHDL

   procedure SetAlertEnable(AlertLogID : AlertLogIDType ; Level : AlertType ; Enable : boolean ; DescendHierarchy : boolean := TRUE) ;

GetAlertEnable
--------------

Get the value of the current alert enable for either a specific
AlertLogId or for the global alert counter.

.. code-block:: VHDL

   -- Hierarchy
   impure function GetAlertEnable(AlertLogID : AlertLogIDType ; Level : AlertType) return boolean ;
   
   -- Global Alert Counter
   impure function GetAlertEnable(Level : AlertType) return boolean ;

SetAlertStopCount: Alert Stop Counts
------------------------------------

For tests that complete with numerous errors, perhaps it is better to
stop after some small number of errors have occurred and start
debugging. That is the job of alert stop counts.

When an alert stop count is reached, the simulation stops. When used
without AlertLogID, SetAlertStopCount sets the alert stop count for the
top level to the specified value if the current count is integer'right,
otherwise, it sets it to the specified value plus the current count.

.. code-block:: VHDL

   procedure SetAlertStopCount(Level : AlertType ; Count : integer) ;
   . . .
   -- Level, Count
   SetAlertStopCount(ERROR, 20) ; -- Stop if 20 errors occur

When used with an AlertLogID, SetAlertStopCount sets the value for the
specified AlertLogID and all of its parents. At each level, the current
alert stop count is set to the specified value when the current count is
integer'right, otherwise, the value is set to the specified value plus
the current count.

.. code-block:: VHDL

   procedure SetAlertStopCount(AlertLogID : AlertLogIDType ; Level : AlertType ; Count : integer) ;
   . . .
   -- AlertLogID, Level, Count
   SetAlertStopCount(UartID, ERROR, 20) ;

By default, the AlertStopCount for WARNING and ERROR are integer'right,
and FAILURE is 0.

GetAlertStopCount
-----------------

Get the value of the current alert stop count for either a specific
AlertLogId or for the global alert counter.

.. code-block:: VHDL

   -- Hierarchy
   impure function GetAlertStopCount(
     AlertLogID : AlertLogIDType ;
     Level : AlertType
   ) return integer ;
   
   -- Global Alert Stop Count
   impure function GetAlertStopCount(Level : AlertType) return integer ;

ClearAlertStopCounts: Reset Alert Stop Counts
---------------------------------------------

ClearAlerts resets alert stop counts back to their default.

.. code-block:: VHDL

   procedure ClearAlertStopCounts ;

ClearAlerts: Reset Alert Counts
-------------------------------

ClearAlerts resets alert counts to 0. Recommended as an alternative to
SetGlobalAlertEnable – just after the design enters reset, call
ClearAlerts.

.. code-block:: VHDL

   procedure ClearAlerts ;

ClearAlertCounts: Reset Alert and Alert Stop Counts
---------------------------------------------------

ClearAlerts resets alert counts to 0 and alert stop counts back to their
default.

.. code-block:: VHDL

   procedure ClearAlertCounts ;

SetGlobalAlertEnable: Alert Global Enable / Disable
---------------------------------------------------

SetGlobalAlertEnable allows Alerts to be globally enabled and disabled.
The Global Alert Enable is enabled by default.

.. code-block:: VHDL

   procedure SetGlobalAlertEnable (A : EnableType := TRUE) ;

impure function SetGlobalAlertEnable (A : EnableType := TRUE) return
EnableType ;

Originally intended to be used to disable alerts during startup, as
shown below. Instead, for most applications we recommend using
ClearAlerts just after reset.

.. code-block:: VHDL

   InitAlerts : Process
     constant DisableAlerts : boolean := SetGlobalAlertEnable(FALSE);
   begin
     wait until nReset = '1' ; -- Deassertion of reset
     SetGlobalAlertEnable(TRUE) ; -- enable alerts

GetGlobalAlertEnable
--------------------

Get the current value of the global alert enable

.. code-block:: VHDL

   impure function GetGlobalAlertEnable return boolean ;

Reporting and Getting Alert Counts
==================================

AlertCountType
--------------

Alerts are stored as a value of AlertCountType.

.. code-block:: VHDL

   subtype AlertIndexType is AlertType range FAILURE to WARNING ;
   type AlertCountType is array (AlertIndexType) of integer ;

CAUTION: When working with values of AlertCountType, be sure to use
named association as the type ordering may change in the future.

.. code-block:: VHDL

   variable ExternalErrors : AlertCountType ;
   . . .
   ExternalErrors := (FAILURE => 0, ERROR => 6, WARNING => 0) ;

Reporting Alerts: ReportAlerts, ReportNonZeroAlerts
---------------------------------------------------

Report Summary
~~~~~~~~~~~~~~

The report summary is the first line printed by
ReportAlerts/ReportNonZeroAlerts

.. code-block:: bash

   %% DONE FAILED t17_print_ctrl Total Error(s) = 2 Failures: 0 Errors: 0 Warnings: 0 Total Disabled Error(s) = 2 Failures: 0 Errors: 2 Warnings: 0 Passed: 0 Affirmations Checked: 2 at 20160 ns

Note in the above message, two affirmations were done and they both
resulted in an error, however, the error was disabled (see
SetAlertEnable) so it reported as a Disabled Error.

Options can be enabled or disabled using SetAlertLogOptions. Let's look
at the report piece by piece.

If Total Errors /= 0, then the following part of the message prints. In
this case, Total Errors is nonzero since FailedOnDisabledErrors is
enabled (default) and the disabled errors count as test errors. Hence,
Failures, Errors, and Warnings are all 0.

.. code-block:: bash

   Total Error(s) = 2 Failures: 0 Errors: 0 Warnings: 0

If FailedOnDisabledErrors is disabled, then the same test will PASS as
shown below.

.. code-block:: bash

   %% DONE PASSED t17_print_ctrl Total Disabled Error(s) = 2 Passed: 0 Affirmations Checked: 2 at 20160 ns

Next is the Total Disabled Errors summary. It will print if the
DisabledAlerts /= 0 or if PrintDisabledAlerts is enabled (default is
disabled).

.. code-block:: bash

   Total Disabled Error(s) = 2

Next is the details of the Disabled Errors. These will print if
FailedOnDisabledErrors is enabled and DisabledAlerts /= 0 or if
PrintDisabledAlerts is enabled.

.. code-block:: bash

   Total Disabled Error(s) = 2 Failures: 0 Errors: 2 Warnings: 0

Next is the printing of the pass and affirmation counts. If PrintPassed
is enabled (default), the passed count will be printed. If
PrintAffirmations is enabled (default is disabled) or Affirmation Count
/= 0 then the passed and affirmation counts will be printed.

.. code-block:: bash

   Passed: 0 Affirmations Checked: 2

Report Details
~~~~~~~~~~~~~~

When in hierarchy mode, a summary for each AlertLogID will be printed.
This can include the following details. Each line summary starts with
"%%".

.. code-block:: bash

   %% Default Failures: 0 Errors: 2 Warnings: 0 Disabled Failures: 0 Errors: 0 Warnings: 0 Passed: 2 Affirmations: 4
   %% OSVVM Failures: 0 Errors: 0 Warnings: 0 Disabled Failures: 0 Errors: 0 Warnings: 0 Passed: 0 Affirmations: 0
   %% Cpu1 Failures: 0 Errors: 2 Warnings: 0 Disabled Failures: 0 Errors: 0 Warnings: 0 Passed: 2 Affirmations: 4
   %% UartTx Failures: 0 Errors: 0 Warnings: 0 Disabled Failures: 0 Errors: 2 Warnings: 0 Passed: 2 Affirmations: 4
   %% UartRx Failures: 0 Errors: 2 Warnings: 0 Disabled Failures: 0 Errors: 0 Warnings: 0 Passed: 2 Affirmations: 4

The Failures, Errors, and Warnings always prints.

Disabled Failures, Errors, and Warnings only print if
PrintDisabledAlerts is enabled (default is disabled).

Passed only prints if PrintPassed is enabled (default).

Affirmations only prints if PrintAffirmations is enabled (default is
disabled).

With PrintDisabledAlerts disabled (default), PrintPassed enabled
(default), and PrintAffirmations disabled (default), and DisabledAlerts
= 0, the report will be simplified to the following.

.. code-block:: bash

   %% Default Failures: 0 Errors: 2 Warnings: 0 Passed: 2
   %% OSVVM Failures: 0 Errors: 0 Warnings: 0 Passed: 0
   %% Cpu1 Failures: 0 Errors: 2 Warnings: 0 Passed: 2
   %% UartTx Failures: 0 Errors: 0 Warnings: 0 Passed: 2
   %% UartRx Failures: 0 Errors: 2 Warnings: 0 Passed: 2

ReportAlerts: Reporting Alerts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

At test completion alerts are reported with ReportAlerts.

.. code-block:: VHDL

   procedure ReportAlerts (
     Name : string := "" ;
     AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID ;
     ExternalErrors : AlertCountType := (others => 0)
   ) ;
   . . .
   ReportAlerts ;

ReportAlerts has 3 optional parameters: Name, AlertLogID, and
ExternalErrors. Name overrides the name specified by SetAlertLogName.
AlertLogID allows reporting alerts for a specific AlertLogID and its
children (if any). ExternalErrors allows separately detected errors to
be reported. ExternalErrors is type AlertCountType and the value
(FAILURE => 0, ERROR => 5, WARNING => 1) indicates detection logic
separate from AlertLogPkg saw 0 Failures, 5 Errors, and 1 Warning. See
notes under AlertCountType.

.. code-block:: VHDL

   --            Name, AlertLogID, ExternalErrors
   ReportAlerts("Uart1", UartID, (FAILURE => 0, ERROR => 5, WARNING => 1) );

ReportNonZeroAlerts
~~~~~~~~~~~~~~~~~~~

When in hierarchy mode, a summary for each AlertLogID will be printed.
This can include the following details. Each summary starts with "%%".

Within the hierarchy, if a level has no alerts set, then that level will
not be printed.

.. code-block:: VHDL

   procedure ReportNonZeroAlerts (
     Name : string := OSVVM_STRING_INIT_PARM_DETECT ;
     AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID ;
     ExternalErrors : AlertCountType := (others => 0)
   ) ;

Overloaded ReportAlerts for Reporting AlertCounts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ReportAlerts can also be used to print a passed/failed message for an
AlertCount that is passed into the procedure call. This will not use any
of the internal settings or information.

procedure ReportAlerts ( Name : String ; AlertCount : AlertCountType) ;

This is useful to accumulate values returned by different phases of a
test that need to be reported separately.

ReportAlerts("Test1: Final", Phase1AlertCount + Phase2AlertCount) ;

GetAlertCount
-------------

GetAlertCount returns the AlertCount value at AlertLogID. GetAlertCount
is overloaded to return either AlertCountType or integer.

.. code-block:: VHDL

   impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType ;
   impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return integer ;
   . . .
   TopTotalErrors := GetAlertCount ; -- AlertCount for Top of hierarchy
   UartTotalErrors := GetAlertCount(UartID) ; -- AlertCount for UartID

GetEnabledAlertCount
--------------------

GetEnabledAlertCount is similar to GetAlertCount except it returns 0 for
disabled alert levels. GetEnabledAlertCount is overloaded to return
either AlertCountType or integer.

.. code-block:: VHDL

   impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType ;
   impure function GetEnabledAlertCount (AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return integer ;
   . . .
   TopTotalErrors := GetEnabledAlertCount ; -- Top of hierarchy
   UartTotalErrors := GetEnabledAlertCount(UartID) ; -- UartID

GetDisabledAlertCount
---------------------

GetDisabledAlertCount returns the count of disabled errors for either
the entire design hierarchy or a particular AlertLogID.
GetDisabledAlertCount is relevant since a "clean" passing design will
not have any disabled alert counts.

.. code-block:: VHDL

   impure function GetDisabledAlertCount return AlertCountType ;
   impure function GetDisabledAlertCount return integer ;
   impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return AlertCountType ;
   impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return integer ;

Note that disabled errors are not added to higher levels in the
hierarchy. Hence, often GetAlertCount /= GetEnabledAlertCount +
GetDisabledAlertCount.

Math on AlertCountType
----------------------

.. code-block:: VHDL

   function "+" (L, R : AlertCountType) return AlertCountType ;
   function "-" (L, R : AlertCountType) return AlertCountType ;
   function "-" (R : AlertCountType) return AlertCountType ;
   . . .
   TotalAlertCount := Phase1Count + Phase2Count ;
   TotalErrors := GetAlertCount - ExpectedErrors ;
   NegateErrors := -ExpectedErrors ;

SumAlertCount: AlertCountType to Integer Error Count
----------------------------------------------------

SumAlertCount sums up the FAILURE, ERROR, and WARNING values into a
single integer value.

.. code-block:: VHDL

   impure function SumAlertCount(AlertCount: AlertCountType) return integer;
   . . .
   ErrorCountInt := SumAlertCount(AlertCount) ;

Log Method Reference 
====================

LogType
-------

Log levels can be ALWAYS, DEBUG, PASSED, or INFO.

.. code-block:: VHDL

   type LogType is (ALWAYS, DEBUG, FINAL, INFO, PASSED) ;

Log
---

If the log level is enabled, then the log message will print. The Enable
parameter indicates to print the message even if the log level is not
enabled. This is useful to enable printing for a single transaction.

.. code-block:: VHDL

  -- with an AlertLogID
  procedure log(
    AlertLogID : AlertLogIDType ;
    Message : string ;
    Level : LogType := ALWAYS ; -- Log if LogType is enabled
    Enable : boolean := FALSE -- also log if Enable is TRUE
  ) ;
  
  -- without an AlertLogID
  procedure log(
    Message : string ;
    Level : LogType := ALWAYS ; -- Log if LogType is enabled
    Enable : boolean := FALSE -- also log if Enable is TRUE
  ) ;

Usage:

.. code-block:: VHDL

   Log(UartID, "Uart Parity Received", DEBUG) ;
   . . .
   Log("Received UART word", DEBUG) ;

SetLogEnable: Enable / Disable Logging
--------------------------------------

Excepting ALWAYS, log enables are disabled by default. SetLogEnable
allows alert levels to be individually enabled. When used without
AlertLogID, SetLogEnable sets a value for all AlertLogIDs.

.. code-block:: VHDL

   procedure SetLogEnable(Level : LogType ; Enable : boolean) ;
   . . .
   SetLogEnable(PASSED, TRUE) ;

When an AlertLogID is used, SetLogEnable sets a value for that
AlertLogID, and if Hierarchy is true, the AlertLogIDs of its children.

.. code-block:: VHDL

   procedure SetLogEnable(
     AlertLogID : AlertLogIDType ;
     Level : LogType ; 
     Enable : boolean ; 
     DescendHierarchy : boolean := TRUE
   );
   . . .
   -- AlertLogID, Level, Enable, DescendHierarchy
   SetLogEnable(UartID, INFO, TRUE, TRUE) ;

Reading Log Enables from a FILE
-------------------------------

ReadLogEnables read enables from a file.

.. code-block:: VHDL

   procedure ReadLogEnables (FileName : string) ;
   procedure ReadLogEnables (file AlertLogInitFile : text) ;

The preferred file format is:

.. code-block:: bash

   U_CpuModel DEBUG
   U_UART_TX DEBUG INFO
   U_UART_RX PASSED INFO DEBUG

ReadLogEnables will also read a file of the format:

.. code-block:: bash

   U_CpuModel
   DEBUG
   U_UART_TX
   DEBUG
   U_UART_TX
   INFO

IsLogEnabled /GetLogEnable
--------------------------

IsLoggingEnabled returns true when logging is enabled for a particular
AlertLogID.

.. code-block:: VHDL

   impure function IsLogEnabled(Level : LogType) return boolean ;
   impure function IsLogEnabled(AlertLogID : AlertLogIDType ; Level : LogType) return boolean ;
   . . .
   If IsLogEnabled(UartID, DEBUG) then
   . . .
   
GetLogEnable is a synonym for IsLogEnabled.

.. code-block:: VHDL

   impure function GetLogEnable(AlertLogID : AlertLogIDType ; Level : LogType) return boolean ;
   impure function GetLogEnable(Level : LogType) return boolean ;

Alert and Log Prefix and Suffix to Message
==========================================

A prefix and suffix can be added message that is printed with Alert or
Log. These are set on an AlertLogID basis using the following
operations.

.. code-block:: VHDL

   procedure SetAlertLogPrefix(AlertLogID : AlertLogIDType; Name : string ) ;
   procedure UnSetAlertLogPrefix(AlertLogID : AlertLogIDType) ;
   impure function GetAlertLogPrefix(AlertLogID : AlertLogIDType) return string ;
   procedure SetAlertLogSuffix(AlertLogID : AlertLogIDType; Name : string ) ;
   procedure UnSetAlertLogSuffix(AlertLogID : AlertLogIDType) ;
   impure function GetAlertLogSuffix(AlertLogID : AlertLogIDType) return string ;

Affirmation Reference 
=====================

Affirmations are a combination of Alerts and Logs. If the Affirmation is
true, then a log is generated. If an Affirmation is false, then an alert
is generated.

Affirmations are intended to be used for self-checking of a test. Each
call to AffirmIf is counted and reported during ReportAlerts. This
provides feedback on the amount of self-checking added by a test and is
used as a quality metric.

AffirmIf / AffirmIfNot
----------------------

AffirmIF has two forms of overloading. The first has a separate
ReceivedMessage and ExpectedMessage. When the affirmation passes, log is
called with just the Received Message. When an affirmation fails, alert
is called with the ExpectedMessage concatenated to the end of the
ReceivedMessage.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIf(
     AlertLogID : AlertLogIDType ;
     condition : boolean ;
     ReceivedMessage : string ;
     ExpectedMessage : string ;
     Enable : boolean := FALSE
   ) ;
   
   -- without an AlertLogID
   procedure AffirmIf(
     condition : boolean ;
     ReceivedMessage : string ;
     ExpectedMessage : string ;
     Enable : boolean := FALSE
   ) ;

The second overloading of AffirmIF has a single Message parameter.
Hence, both alert and log print the same message.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIf(
     AlertLogID : AlertLogIDType ;
     condition : boolean ;
     Message : string ;
     Enable : boolean := FALSE
   ) ;
   
   -- without an AlertLogID
   procedure AffirmIf(
     condition : boolean ;
     Message : string ;
     Enable : boolean := FALSE
   ) ;

There is also an AffirmIfNot for both of the forms above.

AffirmIfEqual
-------------

Affirmation form AffirmIfEqual checks if two values are equal. It
greatly simplifies the message printing since it differentiates between
the Received and Expected values. In the following, AType can be
std_logic, std_logic_vector, unsigned, signed, integer, real, character,
string or time.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIfEqual(
     AlertLogID : AlertLogIDType ;
     Received, Expected : AType ;
     Message : string := "";
     Enable : boolean := FALSE
   ) ;
   
   -- without an AlertLogID
   procedure AffirmIfEqual(
     Received, Expected : AType ;
     Message : string := "";
     Enable : boolean := FALSE
   ) ;

AffirmIfDiff
------------

Affirmation form AffirmIfDiff is for comparing two files.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIfDiff (
     AlertLogID : AlertLogIDType ;
     Name1, Name2 : string;
     Message : string := "" ;
     Level : AlertType := ERROR
   ) ;
   
   procedure AffirmIfDiff (
     AlertLogID : AlertLogIDType ;
     file File1, File2 : text;
     Message : string := "" ;
     Level : AlertType := ERROR
   ) ;
   
   -- without an AlertLogID
   procedure AffirmIfDiff (
     Name1, Name2 : string;
     Message : string := "" ;
     Level : AlertType := ERROR
   ) ;
   
   procedure AffirmIfDiff (
     file File1, File2 : text;
     Message : string := "" ;
     Level : AlertType := ERROR
   ) ;

GetAffirmCount 
--------------

Returns the current affirmation check count.

.. code-block:: VHDL

   impure function GetAffirmCount return natural ;

IncAffirmCount
--------------

Increments the affirmation check count. Intended to be used only in
special situations, such as packages that have additional considerations
when using affirmations.

.. code-block:: VHDL

   procedure IncAffirmCount ;

Alert and Log Output Control Options 
====================================

SetAlertLogJustify
------------------

SetAlertLogJustify justifies name fields of Alerts and Logs. Call after
setting up the entire hierarchy if you want Alerts and Logs justified
(hence optional).

.. code-block:: VHDL

   SetAlertLogJustify(Enable : boolean := TRUE) ;

OsvvmOptionsType
----------------

OsvvmOptionsType defines the values for options. User values are:
OPT_DEFAULT, DISABLED, FALSE, ENABLED, TRUE. The values DISABLED and
FALSE are handled the same. The values ENABLED and TRUE are treated the
same. The value OPT_USE_DEFAULT causes the variable to use its default
value. OsvvmOptionsType is defined in OsvvmGlobalPkg.

.. code-block:: VHDL

   type OsvvmOptionsType is (OPT_INIT_PARM_DETECT, OPT_USE_DEFAULT, DISABLED, FALSE, ENABLED, TRUE) ;

SetAlertLogOptions: Configuring Report Options
----------------------------------------------

The output from Alert, Log, and ReportAlerts is configurable using
SetAlertLogOptions.

.. code-block:: VHDL

   procedure SetAlertLogOptions (
     FailOnWarning : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     FailOnDisabledErrors : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     ReportHierarchy : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertErrorCount : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; -- 2020.05
     WriteAlertLevel : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertName : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertTime : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteLogErrorCount : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; -- 2020.05
     WriteLogLevel : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteLogName : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     PrintPassed : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; -- 2020.05
     PrintAffirmations : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; -- 2020.05
     PrintDisabledAlerts : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; -- 2020.05
     WriteLogTime : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     AlertPrefix : string := OSVVM_STRING_INIT_PARM_DETECT;
     LogPrefix : string := OSVVM_STRING_INIT_PARM_DETECT;
     ReportPrefix : string := OSVVM_STRING_INIT_PARM_DETECT;
     DoneName : string := OSVVM_STRING_INIT_PARM_DETECT;
     PassName : string := OSVVM_STRING_INIT_PARM_DETECT;
     FailName : string := OSVVM_STRING_INIT_PARM_DETECT
   ) ;

The following options are for ReportAlerts.

+----------------------+---------------------------+-----------+
| PrintPassed          | If PrintPassed is         | Enabled   |
|                      | enabled, print number of  |           |
|                      | passed logs in the report |           |
|                      | summary and for each      |           |
|                      | AlertLogID                |           |
+======================+===========================+===========+
| PrintAffirmations    | If PrintAffirmations is   | Disabled  |
|                      | enabled, print the number |           |
|                      | of affirmations in the    |           |
|                      | report summary and for    |           |
|                      | each AlertLogID           |           |
+----------------------+---------------------------+-----------+
| FailOnWarning        | Count warnings as test    | Enabled   |
|                      | errors.                   |           |
+----------------------+---------------------------+-----------+
| FailOnDisabledErrors | If FailOnDisabledErrors   | Enabled   |
|                      | is enabled and            |           |
|                      | DisabledAlerts /= 0:      |           |
|                      |                           |           |
|                      |    Test Fails             |           |
|                      |                           |           |
|                      |    DisabledAlerts are     |           |
|                      |    printed in the report  |           |
|                      |    summary.               |           |
|                      |                           |           |
|                      |    DisabledAlerts print   |           |
|                      |    for each AlertLogID    |           |
+----------------------+---------------------------+-----------+
| PrintDisabledAlerts  | If PrintDisabledAlerts is | Disabled  |
|                      | Enabled, print            |           |
|                      | DisabledAlerts in the     |           |
|                      | report summary and for    |           |
|                      | each AlertLogID           |           |
+----------------------+---------------------------+-----------+
| ReportHierarchy      | When multiple AlertLogIDs | Enabled   |
|                      | exist, print an error     |           |
|                      | summary for each level.   |           |
+----------------------+---------------------------+-----------+
| ReportPrefix         | Prefix for each line of   | "%% "     |
|                      | ReportAlerts.             |           |
+----------------------+---------------------------+-----------+
| DoneName             | Name printed after        | "DONE"    |
|                      | ReportPrefix on first     |           |
|                      | line of ReportAlerts.     |           |
+----------------------+---------------------------+-----------+
| PassName             | Name printed when a test  | "PASSED". |
|                      | passes.                   |           |
+----------------------+---------------------------+-----------+
| FailName             | Name printed when a test  | "FAILED"  |
|                      | fails.                    |           |
+----------------------+---------------------------+-----------+

The following options are for alert:

+----------------------+---------------------------+------------+
| WriteAlertErrorCount | Print Error Count         | Disabled   |
|                      | immediately after %%      |            |
|                      | Alert                     |            |
+======================+===========================+============+
| WriteAlertLevel      | Print level.              | Enabled    |
+----------------------+---------------------------+------------+
| WriteAlertName       | Print AlertLogID name.    | Enabled    |
+----------------------+---------------------------+------------+
| WriteAlertTime       | Alerts print time.        | Enabled    |
+----------------------+---------------------------+------------+
| AlertPrefix          | Name printed at beginning | "%% Alert" |
|                      | of alert.                 |            |
+----------------------+---------------------------+------------+

The following options are for Log:

================== ========================================== ========
WriteLogErrorCount Print Error Count immediately after %% Log Disabled
================== ========================================== ========
WriteLogLevel      Print level.                               Enabled
WriteLogName       Print AlertLogID name.                     Enabled
WriteLogTime       Logs print time.                           Enabled
LogPrefix          Name printed at beginning of log.          "%% Log"
================== ========================================== ========

SetAlertOptions will change as AlertLogPkg evolves. Use of named
association is required to ensure future compatibility.

.. code-block:: VHDL

   SetAlertLogOptions (
     FailOnWarning => FALSE,
     FailOnDisabledErrors => FALSE
   ) ;

After setting a value, a string value can be reset using
OSVVM_STRING_USE_DEFAULT and an OsvvmOptionsType value can be reset
using OPT_USE_DEFAULT.

ReportAlertLogOptions: Print Report Options
-------------------------------------------

Prints out AlertLogPkg Report Options.

Getting AlertLog Report Options
-------------------------------

Report options can be retrieved with one of the Get functions below.

.. code-block:: VHDL

   function GetAlertLogFailOnWarning return AlertLogOptionsType ;
   function GetAlertLogFailOnDisabledErrors return AlertLogOptionsType ;
   function GetAlertLogReportHierarchy return AlertLogOptionsType ;
   function GetAlertLogHierarchyInUse return AlertLogOptionsType ;
   function GetAlertLogWriteAlertLevel return AlertLogOptionsType ;
   function GetAlertLogWriteAlertName return AlertLogOptionsType ;
   function GetAlertLogWriteAlertTime return AlertLogOptionsType ;
   function GetAlertLogWriteLogLevel return AlertLogOptionsType ;
   function GetAlertLogWriteLogName return AlertLogOptionsType ;
   function GetAlertLogWriteLogTime return AlertLogOptionsType ;
   function GetAlertLogAlertPrefix return string ;
   function GetAlertLogLogPrefix return string ;
   function GetAlertLogReportPrefix return string ;
   function GetAlertLogDoneName return string ;
   function GetAlertLogPassName return string ;
   function GetAlertLogFailName return string ;

Deallocating and Re-initializing the Data structure 
===================================================

DeallocateAlertLogStruct 
------------------------

DeallocateAlertLogStruct deallocates all temporary storage allocated by
AlertLogPkg. Also see ClearAlerts.

InitializeAlertLogStruct 
------------------------

InitializeAlertLogStruct is used after DeallocateAlertLogStruct to
create and initialize internal storage.

Compiling AlertLogPkg and Friends
=================================

See OSVVM_release_notes.pdf for the current compilation directions.

Release Notes for 2020.05
=========================

Major update to AlertLogPkg. Output formatting of ReportAlerts has
changed.

Added count of Log PASSED for each level. Prints by default. Disable by
using SetAlertLogOptions (PrintPassed => DISABLED).

Added total count of log PASSED for all levels. Prints in "%% DONE" line
by default. Disable as per each level. However, always prints if passed
count or affirmation count is > 0.

Added affirmation counts for each level. Prints by default. Disable by
using SetAlertLogOptions (PrintAffirmations => DISABLED).

Total count of affirmations is disabled using SetAlertLogOptions above.
However, it always prints if affirmation count > 0.

Disabled alerts are now tracked with a separate DisabledAlertCount for
each level. These do not print by default. Enable printing for these by
using SetAlertLogOptions (PrintDisabledAlerts => ENABLED).

A total of the DisabledAlertCounts is tracked. Prints in "%% DONE"
anytime PrintDisabledAlerts is enabled or FailOnDisabledErrors is
enabled. FailOnDisabledErrors is enabled by default. Disable with
SetAlertLogOptions (FailOnDisabledErrors => DISABLED).

Internal to the protected type of AlertLogPkg is AffirmCount which
tracks the total of FAILURE, ERROR, and WARNING and ErrorCount which
tracks a single integer value for all errors. Many simulators give you
the ability to trace these in your waveform windows.

Added printing of current ErrorCount in the alert and log messages. When
enabled, the number immediately follows the "%% Alert" or "%% Log".
Enable using SetAlertLogOptions (WriteAlertErrorCount=> ENABLED) and
SetAlertLogOptions (WriteLogErrorCount=> ENABLED).

Added direct access to SetAlertLogJustify(Enable := TRUE) which makes
all alert and log printing justified.

Added pragmas "synthesis translate_off" and "synthesis translate_on" in
a first attempt to make the package ok for synthesis tools. It has not
been tested, so you will need to try it out and report back.

Added a prefix and suffix for Alerts and Logs. They support set, unset,
and get operations using SetAlertLogPrefix(ID, "String"),
UnSetAlertLogPrefix(ID), GetAlertLogPrefix(ID), SetAlertLogSuffix(ID,
"String"), UnSetAlertLogSuffix (ID), and GetAlertLogSuffix (ID).

Added ClearAlertStopCounts and ClearAlertCounts. ClearAlerts clears
AlertCount, DisabledAlertCount, AffirmCount, PassedCount for each level
as well as ErrorCount, AlertCount, PassedCount, and AffirmCount for the
top level. ClearAlertStopCounts resets the stop counts back to their
default values. ClearAlertCounts calls both ClearAlerts and
CLearAlertStopCounts.

About AlertLogPkg
=================

AlertLogPkg was developed and is maintained by Jim Lewis of SynthWorks
VHDL Training.

Please support our effort in supporting AlertLogPkg and OSVVM by
purchasing your VHDL training from SynthWorks.

AlertLogPkg is released under the Apache open source license. It is free
(both to download and use - there are no license fees). You can download
it from https://github.com/OSVVM/OSVVM. It will be updated from time to
time. Currently there are numerous planned revisions.

If you add features to the package, please donate them back under the
same license as candidates to be added to the standard version of the
package. If you need features, be sure to contact us. I blog about the
packages at http://www.synthworks.com/blog. We also support the OSVVM
user community and blogs through http://www.osvvm.org.

Find any innovative usage for the package? Let us know, you can blog
about it at osvvm.org.

Future Work
===========

AlertLogPkg.vhd is a work in progress and will be updated from time to
time.

Caution, undocumented items are experimental and may be removed in a
future version.

About the Author - Jim Lewis
============================

Jim Lewis, the founder of SynthWorks, has thirty plus years of design,
teaching, and problem solving experience. In addition to working as a
Principal Trainer for SynthWorks, Mr Lewis has done ASIC and FPGA
design, custom model development, and consulting.

Mr. Lewis is chair of the IEEE 1076 VHDL Working Group (VASG) and is the
primary developer of the Open Source VHDL Verification Methodology
(OSVVM.org) packages. Neither of these activities generate revenue.
Please support our volunteer efforts by buying your VHDL training from
SynthWorks.

If you find bugs these packages or would like to request enhancements,
you can reach me at jim@synthworks.com.

