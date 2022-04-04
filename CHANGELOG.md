# OSVVM Utility Library (aka OSVVM) Change Log 

| Revision name | Revision  Date |  Summary |
----------------|----------------|----------- 
| 2022.03  | March 2022      |  Added EdgeRose, ..., FindRisingEdge, ..., ScoreboardPkg Updates 
| 2022.02  | February 2022   |  Added Transition Coverage. 
| 2022.01  | January 2022    |  Added Transition Coverage. 
| 2021.12  | December 2021   |  Added ReadCovYaml. 
| 2021.11  | November 2021   |  Minor updates.  Print CovWeight first in WriteCovYaml. 
|          |                 |     Update to usage of PercentCov in GetCov. 
| 2021.10  | October 2021    |  Updates to generate HTML and JUnit XML for test suite information
|          |                 |     Generate YAML and HTML for reporting Alert and Coverag information
|          |                 |     Added ReportPkg. Uupdated CoveragePkg and AlertLogPkg 
| 2021.09  | September 2021  |  Minor updates to support Synopsys and Cadence
| 2021.08  | August 2021     |  Minor deprecations in CoveragePkg and ScoreboardGenericPkg
| 2021.07  | July 2021       |  Updated Data Structure of CoveragePkg
| 2021.06  | June 2021       |  Updated Data Structures
| 2020.12  | December 2020   |  Minor Updates
| 2020.10  | October 2020    |  Minor Updates
| 2020.08  | August 2020     |  Specification Tracking
| 2020.05  | May 2020        |  PASSED Counting
| 2020.01  | January 2020    |  Apache Licensing
| 2018.04  | April 2018      | 
| 2017.05  | May 2017        | 
| 2016.11  | November 2016   | 
| 2016.01  | January 2016    | 
| 2015.06  | June 2015       | 
| 2015.03  | March 2015      | 
| 2015.01  | January 2015    | 
| 2014.07a | December 2014   | 
| 2014.07  | July 2014       | 
| 2014.01  | January 2014    | 
| 2013.05  | May 2013        | 
| 2013.04  | April 2013      | 
| 2.4      | January 2012    | 
| 2.3      | January 2012    | 
| 2.2      | July 2011       | 
| 2.1      | June 2011       | 
| 2.0      | April 2011      | 
| 1.X      | June 2010       | 


## Copyright and License
Copyright (C) 1999-2021 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2021 by [OSVVM contributors](CONTRIBUTOR.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


## Revision 2022.03 March 2022

### Current Revision and Compile Order

The following table lists the files and revision, starting with the
files that need to be compiled first. Be sure to turn on the VHDL-2008
compile switch. You may also use the OSVVM script - osvvm.pro -- details 
how to run it are in the scripts directory as well as Scripts_user_guide.pdf.

  | File Name                                          | Revision Date  |  
  -----------------------------------------------------|----------
  | TextUtilPkg.vhd                                    | 2022.02  | 
  | ResolutionPkg.vhd                                  | 2021.06  |
  | NamePkg.vhd                                        | 2022.02  |  
  | OsvvmGlobalPkg.vhd                                 | 2022.02  |  
  | VendorCovApiPkg_Aldec.vhd (Aldec only)             | 2020.01  |
  | VendorCovApiPkg.vhd (All others)                   | 2020.01  |
  | TranscriptPkg.vhd                                  | 2020.12  |  
  | AlertLogPkg.vhd                                    | 2022.02  | 
  | NameStorePkg.vhd                                   | 2022.02  |  
  | MessageListPkg.vhd                                 | 2021.07  | 
  | SortListPkg_int.vhd                                | 2020.01  |
  | RandomBasePkg.vhd                                  | 2021.06  |
  | RandomPkg.vhd                                      | 2021.06  |
  | RandomProcedurePkg.vhd                             | 2021.06  |
  | CoveragePkg.vhd                                    | 2022.02  |
  | MemoryPkg.vhd                                      | 2022.02  |
  | ScoreboardGenericPkg.vhd                           | **2022.03**  |
  | ScoreboardPkg_slv.vhd                              | 2020.10  |
  | ScoreboardPkg_int.vhd                              | 2020.01  |
  | ScoreboardPkg_slv_c.vhd                            | 2022.01  | 
  | ScoreboardPkg_int_c.vhd                            | 2022.01  | 
  | ResizePkg.vhd                                      | 2021.06  |
  | TbUtilPkg.vhd                                      | **2022.03**  |
  | ReportPkg.vhd                                      | 2022.02  | 
  | OsvvmTypesPkg.vhd                                  | 2022.01  |
  | OsvvmContext.vhd                                   | 2022.01  |

### TbUtilPkg.vhd  2022.03 
Added EdgeRose, EdgeFell, EdgeActive, FindRisingEdge, FindFallingEdge, FindActiveEdge
Updated WaitForTransaction for RdyType/AckType to use EdgeActive

### ScoreboardGenericPkg.vhd  2022.03 
Maintence update to SetAlertLogID / NewID

## Revision 2022.02 February 2022

### AlertLogPkg.vhd  2022.02 
Added SetAlertPrintCount.   Sets a maximum number of times to print an Alert level for an AlertLogID. 
Added NewID to bring consistent naming with other Singleton data structures and new capability (PrintParent and ReportMode).

### CoveragePkg.vhd  2022.02 
Updated NewID with ParentID, ReportMode, Search, PrintParent.   Supports searching for coverage models.

### MemoryPkg.vhd  2022.02 
Updated NewID with ReportMode, Search, PrintParent.   Supports searching for Memory models.

### ScoreboardGenericPkg.vhd  2022.02 
Updated NewID with ParentID, ReportMode, Search, PrintParent.   Supports searching for Scoreboard models.
Added support to do Scoreboard Reports (GotScoreboards, WriteScoreboardYaml)

### ReportPkg.vhd  2022.02 
In EndOfTestReports, added calls to WriteScoreboardYaml for Scoreboard reporting.

### NameStorePkg.vhd  2022.02 
Updated NewID and Find with ParentID and Search.   Supports searching in CoveragePkg, ScoreboardGenericPkg, and MemoryPkg.

### TextUtilPkg.vhd  2022.02 
Updated to_hxstring for better meta value handling (U, X, Z, W, ).  Four consecutive meta values result in that character.  Mixed meta results in '?'.
Added Justify that aligns LEFT, RIGHT, and CENTER with parameters in a sensible order.  

### OsvvmGlobalPkg.vhd  2022.02 
Added support for IdSeparator.  Supports PrintParent mode PRINT_NAME_AND_PARENT.  <Parent Name> <IdSeparator> <AlertLogID Name>

### NamePkg.vhd  2022.02 
Added NameLength method to NamePType

## Revision 2022.01 January 2022

### TextUtilPkg.vhd  2022.01 
Added to_hxstring - based on hxwrite (in TbUtilPkg prior to release)

### AlertLogPkg.vhd  2022.01 
For AlertIfEqual and AffirmIfEqual, all arrays of std_ulogic use to_hxstring
Updated return value for PathTail

### CoveragePkg.vhd  2022.01 
Added DeallocateBins and TCover
Updates to allow AddBins and AddCross with 0 for AtLeast and Weight
    Updated GenBin s.t. defaults AtLeast and Weight to 0
    Updated AddBins and AddCross s.t. defaults AtLeast and Weight to 1

### ScoreboardGenericPkg.vhd, ScoreboardPkg_slv_c, ScoreboardPkg_int_c  2022.01 
Added CheckExpected
Added SetCheckCountZero to ScoreboardPType

### TbUtilPkg.vhd  2022.01 
Added MetaTo01
Added WaitForTransaction without clock for RdyType/AckType and bit

### OsvvmTypesPkg.vhd  2022.01 
Defined slv_vector

### OsvvmContext.vhd  2022.01 
Added OsvvmTypesPkg

## Revision 2021.12 December 2021

### CoveragePkg.vhd  2021.12 
Added ReadCovYaml.


## Revision 2021.11 November 2021

### CoveragePkg.vhd  2021.11 
Minor updates.  Print CovWeight first in WriteCovYaml. 
Update to usage of PercentCov in GetCov. 

## Revision 2021.10 October 2021

### ReportPkg.vhd 2021.10 
Implements EndOfTestReports (was called EndOfTestSummary in 2021.09).
EndOfTestReports calls 
   - ReportAlerts from AlertPkg,
   - WriteAlertSummaryYaml from AlertPkg to generate Build Report <build>.yml,
   - WriteAlertYaml from AlertPkg to generate ./reports/<test>_alerts.yml
   - WriteCovYaml from CoveragePkg to generate ./reports/<test>_cov.yml
See the OSVVM scripts as the above YAML files are all automatically converted to HTML.
Make sure to name your tests with AlertLogPkg.SetAlertLogName as that is where the 
above "<test>" comes from.   

### AlertLogPkg.vhd 2021.10 
Added WriteAlertYaml to create AlertLog reports in Yaml (which the scripts convert to HTML)
WriteAlertSummaryYaml replaced the experimental CreateYamlReport.
Both of the above are called by ReportPkg.EndOfTestReports.  See above.
Deprecated Items:
  - CreateYamlReport is deprecated.  Please use WriteAlertSummaryYaml.
  - EndOfTestSummary was moved to ReportPkg and deprecated.   It is replaced by EndOfTestReports.
    The move was necessary as it calls procedures from AlertLogPkg and CoveragePkg. 

### CoveragePkg.vhd  2021.10 
Added WriteCovYaml which is called by EndOfTestReports


## Revision 2021.09 September 2021
### AlertLogPkg.vhd 2021.09 
Experimental Release of EndOfTestSummary and CreateYamlReport

### CoveragePkg.vhd  2021.09 
Minor update to WriteBin in CoveragePkg for setting parameters

### ScoreboardPkg_slv_c.vhd and ScoreboardPkg_int_c.vhd  2021.09 
Reintroduced into the repository.  Cadence Xcelium does not yet 
support generics on a package.

### Minor updates for compile/simulate in Synopsys VCS and Cadence Xcelium 
CoveragePkg.vhd, MemoryPkg.vhd, NameStorePkg.vhd, RandomPkg.vhd, 
RandomBasePkg.vhd, and ScoreboardGenericPkg.vhd


## Revision 2021.08 August 2021

### CoveragePkg.vhd  2021.08 
Deprecated and removed SetAlertLogID.  Use NewID instead.
Deprecated SetName, SetMessage.   
Deprecated AddBins, AddCross, GenBin, and GenCross with weight parameter. 

### ScoreboardGenericPkg.vhd  2021.08 
Deprecated and removed SetAlertLogID.  Use NewID instead.



## Revision 2021.07 July 2021

### MessageListPkg.vhd and deprecated MessagePkg.vhd  2021.07 
Created linked list version for multi-line message handling.
Deprecated protected type version (MessagePkg) as it cannot be
used directly in the new data structures.

### CoveragePkg.vhd  2021.07 
Added new data structure to CoveragePkg to facilitate creating
functional coverage using ordinary procedure and function calls.

### Deprecated osvvm.tcl  2021.07
The compile script, osvvm.tcl, is no longer supported.   
Correct order is specified above as well as by osvvm.pro.  



## Revision 2021.06 June 2021

### ResolutionPkg.vhd and ResizePkg.vhd  2021.06 
Refactored conversions of transaction records from ResolutionPkg.vhd into ResizePkg.vhd. 
Part of plan to transaction to VHDL-2019 interfaces.   

### NameStorePkg.vhd   2021.06 
NamePkg with updated data structure to better support new data structures

### AlertLogPkg.vhd 2021.06 
Minor updates to FindAlertLogID

### RandomPkg.vhd and RandomBasePkg.vhd  2021.06 
Updated InitSeed for better seeds.  Defaults to old method.
Moved some items from RandomPkg to RandomBasePkg to support future revisions

### RandomProcedurePkg.vhd   2021.06 
Added to support new data structures in CoveragePkg.
Capability limited to what is needed by CoveragePkg.
When you can use a protected type, use RandomPkg.vhd.
When we have VHDL-2019 support will no longer need this.

### MemoryPkg.vhd    2021.06    
New data structure.  Supports old code.  Adds new use models.

### MemoryPkg_2019.vhd is deleted  2021.06   
New MemoryPkg.vhd replaces MemoryPkg_2019 with data structure + NewID

### ScoreboardGenericPkg.vhd    2021.06    
New data structure.  Supports old code.  Adds new use models.


## Revision 2020.12 December 2020

### Resolution.vhd 2020.12    
Updated ToTransaction and FromTransaction with length parameter.
Downsizing now permitted when it does not change the value.

### MemoryPkg_2019.vhd 2020.12    
Beta version of MemoryPType with VHDL-2019 generics.
Used in place of MemoryPkg.  Tested in RivieraPro. 
Requires compile switch -2019. 

### AlertLogPkg.vhd 2020.12    
Added MetaMatch to AffirmIfEqual and AffirmIfNotEqual 
for std_logic family to use MetaMatch.
Added AffirmIfEqual for boolean.
Oversight as MetaMatch was added to AlertIfEqual and AlertIfNotEqual in 2020.10.  

### Transcript.vhd 2020.12    
Updated TranscriptOpen parameter Status to InOut to work around simulator bug.


## Revision 2020.10 October 2020

### AlertLogPkg.vhd 2020.10
Added function MetaMatch.   It is similar to STD_MATCH and ?=,
except that U=U, X=X, Z=Z, and W=W.  All else is the same as STD_MATCH.
AlertIfEqual and AlertIfNotEqual for std_logic family use MetaMatch rather than ?=.

### ScoreboardPkg_slv.vhd 2020.10
Uses MetaMatch for the Match function instead of STD_MATCH.

## Revision 2020.08 August 2020
### AlertLogPkg.vhd 2020.08

2020.08 is a major update to AlertLogPkg.

This revision is the Alpha release of integrated Specification Tracking
capability. Specification tracking capability is a work in progress and
may change in future releases until stabilized.

Added requirements in the form of \"PASSED\" Goals that are reported
with ReportAlerts. A PASSED goal is a number of \"PASSED\" affirmations
an AlertLogID must have. There are two mechanisms to set passed goals:
GetReqID and ReadSpecification.

When a test has requirements, a test will fail if requirements are not
met and FailOnrequirementErrors is true (default is TRUE). Disable using
SetAlertLogOptions(FailOnRequirementErrors =\> TRUE).

For a test that has requirements, summary of ReportAlerts will print a
requirements summary (\# met of \# total) if PrintIfHaveRequirements is
TRUE (default is TRUE) or PrintRequirements is TRUE (default is FALSE).
Either of these can be changed using SetAlertLogOptions.

For a test that fails, detailed printing of requirements will be printed
in ReportAlerts if PrintRequirements is TRUE (default is FALSE).

Requirements can be specified using either ReadSpecification or
GetReqID. Requirements are recorded with AffirmIF. A new form of
AffirmIF was added, AffirmIF(\"RequirementName\", condition, ... ).
Currently overloading for the new AffirmIf is limited to AffirmIf. Other
variations such as AffirmIFEqual may be used by calling
AffirmIfEqual(GetReqID(\"RequirementName\"), ...).

Requirements are reported in ReportAlerts -- but only in detail if the
test fails. Requirements are reported always in ReportRequirements.

WriteAlerts prints the information from ReportAlerts as a CSV file.
WriteRequirements prints the information in ReportRequirements as a CSV
file.

ReadRequirements reads and merges requirement information from multiple
separate tests.

WriteTestSummary prints the summary information from the first line of
WriteAlerts as a CSV file. It is intended that the results of multiple
tests are written out into the same file -- collecting all test results
together. ReadTestSummaries reads this information in as
\"requirements\". This can be used in conjunction with ReadSpecification
to specify which tests should run -- so we can detect whether all tests
have run and have passed. ReportTestSummaries prints out the test
summaries. WriteTestSummaries writes out the test summaries as a CSV
file.

### RandomPkg.vhd 2020.08

Added the functions RandBool, RandSl, RandBit, DistBool, DistSl, and
DistBit.

### TextUtilPkg.vhd 2020.08


Added the procedures ReadUntilDelimiterOrEOL and FindDelimiter.

## Revision 2020.05 May 2020

### AlertLogPkg.vhd 2020.05

Major update to AlertLogPkg. Output formatting of ReportAlerts has
changed.

Added count of Log PASSED for each level. Prints by default. Disable by
using SetAlertLogOptions (PrintPassed =\> DISABLED).

Added total count of log PASSED for all levels. Prints in \"%% DONE\"
line by default. Disable as per each level. However, always prints if
passed count or affirmation count is \> 0.

Added affirmation counts for each level. Prints by default. Disable by
using SetAlertLogOptions (PrintAffirmations =\> DISABLED).

Total count of affirmations is disabled using SetAlertLogOptions above.
However, it always prints if affirmation count \> 0.

Disabled alerts are now tracked with a separate DisabledAlertCount for
each level. These do not print by default. Enable printing for these by
using SetAlertLogOptions (PrintDisabledAlerts =\> ENABLED).

A total of the DisabledAlertCounts is tracked. Prints in \"%% DONE\"
anytime PrintDisabledAlerts is enabled or FailOnDisabledErrors is
enabled. FailOnDisabledErrors is enabled by default. Disable with
SetAlertLogOptions (FailOnDisabledErrors =\> DISABLED).

Internal to the protected type of AlertLogPkg is AffirmCount which
tracks the total of FAILURE, ERROR, and WARNING and ErrorCount which
tracks a single integer value for all errors. Many simulators give you
the ability to trace these in your waveform windows.

Added printing of current ErrorCount in the alert and log messages. When
enabled, the number immediately follows the \"%% Alert\" or \"%% Log\".
Enable using SetAlertLogOptions (WriteAlertErrorCount=\> ENABLED) and
SetAlertLogOptions (WriteLogErrorCount=\> ENABLED).

Added enable parameter to SetAlertLogJustify(Enable := TRUE) to allow
turning off justification.

Added pragmas \"synthesis translate_off\" and \"synthesis translate_on\"
in a first attempt to make the package ok for synthesis tools. It has
not been tested, so you will need to try it out and report back.

Added a prefix and suffix for Alerts and Logs. They support set, unset,
and get operations using SetAlertLogPrefix(ID, \"String\"),
UnSetAlertLogPrefix(ID), GetAlertLogPrefix(ID), SetAlertLogSuffix(ID,
\"String\"), UnSetAlertLogSuffix (ID), and GetAlertLogSuffix (ID).

Added ClearAlertStopCounts and ClearAlertCounts. ClearAlerts clears
AlertCount, DisabledAlertCount, AffirmCount, PassedCount for each level
as well as ErrorCount, AlertCount, PassedCount, and AffirmCount for the
top level. ClearAlertStopCounts resets the stop counts back to their
default values. ClearAlertCounts calls both ClearAlerts and
ClearAlertStopCounts.

### CoveragePkg.vhd 2020.05

Minor enhancements.

Added GetIncIndex, GetIncBinVal, GetIncPoint which get the index,
BinVal, or point of the next bin in the coverage model (following an
incrementing with wrap around pattern).

Added GetNextIndex, GetNextBinValue, GetNextPoint which in turn use
Random, Incrementing, or Minimum pattern to select the next index,
BinVal, or point. The intent is to allow a test to algorithmically or
via a generic select its mode of next item selection. The selection can
be made through an explicit parameter of type NextPointModeType (whose
values are RANDOM, INCREMENT, or MIN). If no parameter is specified, the
internal NextPointModeVar is used. It is set by calling
SetNextPointMode(Mode =\> RANDOM).

GetLastIndex now will return the index that was last used for either
used for stimulus generation (in the case of GetRandIndex, GetIncIndex,
GetMinIndex, GetMaxIndex, or GetNextIndex) or coverage collection (in
the case of ICover).

For consistency in naming, GetRandIndex (new capability), GetRandBinVal,
and GetRandPoint are introduced to deprecate RandCovBinVal and
RandCovPoint.

Added conversions from integer to_boolean and to_std_logic and from
integer_vector to_boolean_vector and to_std_logic_vector (and alias:
to_slv).

### ScoreboardGenericPkg.vhd 2020.05

Minor enhancements.

Added Check function that returns true when the check passes.

Added additional counts to track the number of items that have been
popped from the FIFO (GetPopCount). Added capability to report the
number of items in the FIFO with GetFifoCount. Number of items Pushed
into the FIFO is now available as GetPushCount (as well as
GetItemCount).

### ResolutionPkg.vhd 2020.05

Added Extend and Reduce functions for type std_logic_vector. Extend is
resize that only allows the array size to grow and is used when putting
a value into the transaction record. Reduce is resize that only allows
the array size to stay the same or shrink and is used when removing a
value from the transaction record.

Added ToTransaction to convert from std_logic_vector to the transaction
type std_logic_vector_c. Alternately use type conversion
std_logic_vector_c. Added FromTransaction to convert from the
transaction type std_logic_vector_c to std_logic_vector. Alternately
could use type conversion std_logic_vector.

## Revision 2020.01 January 2020

Updated license to Apache.

## Revision 2018.04 April 2018

This is a minor release. No other documentation has been updated for
this release.

### Current Revision and Compile Order

See the 2018.04 release notes for details.

### AlertLogPkg.vhd 2018.04

Added minor fix to PathTail. Did some changes to prepare to change
AlertLogIDType to a type.

### CoveragePkg.vhd 2018.04

Added minor fix to the calculation of PercentCov so when AtLeast is less
than or equal to 0 the value is correct. Added \"string\'\" fix for
GHDL. Removed deprecated procedure Increment - however see TbUtilPkg as
it moved there.

### TbUtilPkg.vhd 2018.04

Added RequestTransaction, WaitForTransaction, Toggle, WaitForToggle for
bit. Added Increment and WaitForToggle for integer.

### ScoreboardGenericPkg.vhd 2018.04

Made Pop Functions Visible. Did preparations for AlertLogIDType to
change to a type.

### MessagePkg.vhd 2018.04

Minor updates to Alert message.

## Revision 2017.05 May 2017

### AlertLogPkg.vhd 2017.05

AffirmIf and AffirmIfNot has additional overloading. Added
AffirmIfEqual, AffirmIfDiff, GetAffirmCount, IncAffirmCount,
IsAlertEnabled, and IsLogEnabled.

Deprecated GetAffirmCheckCount (see GetAffirmCount), IncAffirmCheckCount
(see IncAffirmCount), and IsLoggingEnabled (see IsLogEnabled and
GetLogEnable). Deprecated the overloading of AffirmIf that has an
AlertLevel and/or LogLevel as a parameter - for AffirmIf AlertLevel
should be ERROR and LogLevel should be PASSED.

### CoveragePkg.vhd 2017.05

Updated the printing of WriteBin so that the bin name is printed (if it
is specified by either SetAlertLogID or SetName). Added ClearCov (which
deprecates SetCovZero) - makes naming similar to AlertLogPkg
ClearAlerts.

### ScoreboardGenericPkg.vhd 2017.05

Updated printing to correlate with AffirmIf. First the received (actual)
value is printed and then the expected value is printed. In addition,
the expected value is only printed when it does not match the actual
value (an ERROR).

## Revision 2016.11 November 2016

Note that while ScoreboardGenericPkg, TbUtilPkg, and ResolutionPkg are
new to OSVVM, they have been distributed with SynthWorks\' VHDL training
classes for some time now.

### VendorCovApiPkg, VendorCovApiPkg_Aldec 2016.11

Provides API to link CoveragePkg to vendor tools. Compile either
VendorCovApiPkg.vhd or VendorCovApiPkg_Aldec.vhd.

### TranscriptPkg 2016.11

Added BlankLine procedure to print blank lines.

### TextUtilPkg 2016.11

Added to_lower and to_upper. These are necessary when using
\'instance_name with a call to InitSeed in either RandomPkg or
CoveragePkg.

### AlertLogPkg 2016.02

Fixed IsLogEnableType (for PASSED) and AffirmIf (to pass AlertLevel).

### SortListPkg_int 2016.11

Revised Add. When a matching value is found, add the value after the
previous value. Supports situations where the key is shorter than the
entire word.

### RandomPkg 2016.11

No changes to RandomPkg. Advanced release for both the package and the
documentation so they are consistent.

### CoveragePkg 2016.11

Added calls to VendorCovApiPkg to record coverage in the simulator
database. Added GetBinName(Index) to return a coverage bin name.

### MemoryPkg 2016.11

Refined MemRead to return value if written, X if previous contained an
X, or U if the location has never been written.

### ScoreboardGenericPkg (first release to OSVVM) 2016.11

Generic package for creation of Scoreboards and FIFOs inside of a
protected type.

### ScoreboardPkg_slv, ScoreboardPkg_int (first release to OSVVM) 2016.11

Instance of ScoreboardGenericPkg for types std_logic_vector and integer.

### ResolutionPkg (first release to OSVVM) 2016.11

Resolution functions to simplify using records as a transaction
interface.

### TbUtilPkg (first release to OSVVM) 2016.11

Handshaking utilities for transaction based testbenches. Targeted for
use in testbenches that use multiple process (multi-threaded)
transaction dispatch.

### OsvvmContext 2016.11

Updated to include ResolutionPkg and TbUtilPkg. Note that
ScoreboardPkg_int and ScoreboardPkg_slv are intentionally left out as if
they are not used the reference will be a nuisance.

### osvvm.do 2016.11

Compile script for OSVVM in ModelSim, QuestaSim, and RivieraPro. Be sure
to update the path to your files and choose the correct version of
VendorCovApiPkg.

## Revision 2016.01 January 2016

### AlertLogPkg 2016.01

Fixed bug that kept more than 32 bins from being used.

### CoveragePkg 2016.01

Revised ConcatenateBins so it does not call Alert to allow it to be a
pure function. Added bounds checking to ICover so that if ICover is
called with the wrong length of integer_vector, it will cause an Alert
FAILURE.

### MemoryPkg and TextUtilPkg 2016.01

Changed L.all(1) to L.all(L'left). GHDL does not default objects of type
line to have an index of 1.

### TranscriptPkg 2016.01

Minor reorganization of code so that all calls to TranscriptOpen
eventually call the same code.

## Revision 2015.06 June 2015

### MemoryPkg (New) 2015.06

New to OSVVM. Package with protected type for implementing memories.
Methods MemInit, MemRead, MemWrite, MemErase, FileReadH, FileReadB,
FileWriteH, FileWriteB, SetAlertLogID, Deallocate.

### AlertLogPkg 2015.06

Added AffirmIf. Added PASSED log level. Added IncAlertCount as a silent
alert (Used by CoveragePkg). Revised ReportAlerts to print number of
affirmations checked. Added GetAffirmCheckCount, IncAffirmCheckCOunt.
ClearAlerts also clears affirmations. Added CreateHierarchy final
parameter to GetAlertLogID. Added a Get for every Set. Moved
EmptyOrCommentLine to TextUtilPkg and revised.

### CoveragePkg 2015.06

Implemented Mirroring for WriteBin and WriteCovHoles. When in
ILLEGAL_OFF mode, added IncAlertCount (as a silent alert). Added
SetAlertLogID(Name, ParentID, CreateHierarchy). Updated Alert output
format. Added AddCross(CovMatrix?Type). Deprecated
AddBins(CovMatrix?Type). Moved EmptyOrCommentLine to TextUtilPkg and
revised.

### TextUtilPkg (New) 2015.06

Shared utilities for file reading. SkipWhiteSpace, EmptyOrCommentLine,
ReadHexToken, ReadBinaryToken.

### RandomPkg 2015.06

Revised calls to Alert to 2015.03 preferred format with AlertLogID
first.

### NamePkg 2015.06

Added input parameter to Get to specify a return value when NamePtr is
not initialized.

### RandomBasePkg 2015.06

Changed GenRandSeed to impure since it calls Alert (and Alert is a
parent of a call to a protected type method).

### OsvvmContext.pkg 2015.06

Added MemoryPkg

## Revision 2015.03 March 2015

### AlertLogPkg 2015.03

Added AlertIfEqual, AlertIfNotEqual, and AlertIfDiff (file). Added
ReadLogEnables to initialize LogEnables from a file. Added
ReportNonZeroAlerts. Added PathTail to extract an instance name from
MyEntity\'PathName. Added ReportLogEnables and GetAlertLogName. See
AlertLogPkg_User_Guide.pdf for details.

For hierarchy mode, AlertIfEqual, AlertIfNotEqual, and AlertIfDiff have
the AlertLogID parameter first. Overloading was added for AlertIf and
AlertIfNot to make these consistent. Now with multiple parameters, it is
easier to remember that the AlertLogID parameter is first. The older
AlertIf and AlertIfNot with the AlertLogID as the second parameter were
kept for backward compatibility, but are considered bad practice to use
in new code.

Added ParentID parameter to FindAlertLogID. This is necessary to
correctly find an ID within an entity that is used more than once.

Bug fix: Updated GetAlertLogID to use the two parameter FindAlertLogID.
Without this fix, Alerts with the same name incorrectly use the same
AlertLogID.

Bug fix: Updated NewAlertLogRec (called by GetAlertLogID) so a new
record gets Alert and Log enables based on its ParentID rather than the
ALERTLOG_BASE_ID. Issue, if created an Comp1_AlertLogID, and disabled a
level (such as WARNING), and then created a childID of Comp1_AlertLogID,
WARNING would not be disabled in childID.

Bug fix: Updated ClearAlerts to correctly set stop counts (broke since
it previously did not use named association). Without this fix, after
calling ClearAlerts, a single FAILURE would not stop a simulation,
however, a single WARNING would stop a simulation.

## Revision 2015.01 January 2015

### OsvvmContext (New) 2015.01

OsvvmContext is a context declaration. Rather than referencing osvvm
packages with individual use clauses, instead use a single context
reference:

library osvvm ;

context osvvm.OsvvmContext ;

### OsvvmGlobalPkg (New) 2015.01

Manages global report settings for CoveragePkg and AlertLogPkg. Provides
constants and base types for AlertLogPkg.

### TranscriptPkg (New) 2015.01

TranscriptPkg simplifies different parts of a testbench using a common
transcript file (named TranscriptFile). Also provides overloading for
Print and WriteLine that use TranscriptFile when it is opened (via
TranscriptOpen), and otherwise, use std.env.OUTPUT.

### AlertLogPkg (New) 2015.01

New package added to allow catching and counting of assert FAILURE,
ERROR, WARNING as well as do verbosity filtering for log files.

The package offers either a native OSVVM mode or an interface mode. In
the interface mode, the package body is used to redirect OSVVM internal
calls to a separate alert/log package. For example, for BitVis Utility
Library (BVUL), there is a package body of AlertLogPkg that allows OSVVM
to record asserts and logs via BVUL. By only changing the package body,
the interface mode can be recompiled without requiring other elements of
the OSVVM library to be recompiled. This same methodology allows
connection to other packages.

### RandomPkg and RandomBasePkg 2015.01

Replaced all asserts with calls to AlertPkg.

### CoveragePkg 2015.01

#### Changes

Replaced all asserts and reports with calls to AlertPkg. Added a
verbosity flag to WriteBin to allow it to handle debug calls.

WriteBin prints a multiple line report. As a result, instead of calling
Log in the AlertPkg, package, when called with a verbosity flag,
WriteBin first checks to see if its ScopeID and Verbosity Level are
allowed to print. If enabled, it then uses write and writeline to print
the report.

The undocumented method, DumpBin, now has a LogLevel parameter. Its
interface is:

    procedure DumpBin (LogLevel : LogType := DEBUG) ;

#### Additions

The following methods were added:

    procedure SetAlertLogID (A : AlertLogIDType) ;
    impure function GetAlertLogID return AlertLogIDType ;
    impure function SetName (Name : String) return string ;
    impure function GetName return String ;
    impure function InitSeed (S : string ) return string ;
    procedure WriteBin (LogLevel : LogType ; . . .) ;
    procedure WriteCovHoles ( LogLevel : LogType ; . . . ) ;

## Revision 2014.07a December 2014

### CoveragePkg, MessagePkg, NamePkg 2014.12

Removed memory leak in CoveragePkg.Deallocate. Removed initialized
pointers from CoveragePkg, MessagePkg, and NamePkg -- when a protected
type with initialized pointers is abandoned, such as when declared in a
subprogram exits, a memory leak will occur as there is no destructor to
deallocate the initialized pointers.

## Revision 2014.07 July 2014

### RandomPkg

No changes were made to RandomPkg. It is still labeled 2014.01.

### CoveragePkg

CoveragePkg now references both MessagePkg and NamePkg.

Added names to bins. When using WriteBin or WriteCovHoles, if a bin name
is set, it will print. For details, see Setting Bin Names in the
Reporting Coverage section of the CoveragePkg Users Guide.

Enhanced WriteBin to print \"PASSED\" if the count is greater than or
equal to the goal (AtLeast value), otherwise, it prints \"FAILED\".
Added a number of parameters to WriteBin to control what fields of a
WriteBin report get printed. See Enabling and Disabling WriteBin fields
in the Reporting Coverage section of the CoveragePkg Users Guide.

## Revision 2014.01 January 2014

### RandomPkg

Added randomization for time (RandTime), additional overloading for type
real (RandReal), and sets of values for types (integer_vector,
real_vector, and time_vector. Made Sort and RevSort from SortListPkg_int
visible using aliases.

### CoveragePkg

Revised ReadCovDb to support merging of coverage models (from different
test runs).

Revised RandCovPoint and RandCovBinVal to log the bin index in the
LastIndex variable. Revised ICover to look in bin referenced by
LastIndex first. Added method GetLastIndex to get the variable value.
Added GetLastBinVal to get the BinVal of LastIndex.

Revised AddBins and AddCross bin merging to allow arbitrary CountBin
overlap. With the addition of LastIndex, the overlap is not an issue.

Split SetName into SetMessage (headers) and SetName (printing illegal
bins)

Added method GetItemCount to return the count of the number of
randomizations and method GetTotalCovGoal to return the sum of the
individual coverage goals in the coverage model.

## Revision 2013.05 May 2013

### RandomPkg

Added big vector randomization.

### CoveragePkg

No substantial changes. Removed extra variable declaration in functions
GetHoleBinval, RandCovBinVal, RandCovHole, GetHoleBinVal. Now
referencing NULL_RANGE type from RandomPkg to remove NULL range
warnings.

## Revision 2013.04 April 2013

### RandomPkg

Changed DistInt return value. The return value is now determined by the
range of the input array. For literal values, this produces the same
value as it did previously. Also added better error checking for weight
values.

Added better min, max error handling in Uniform, FavorBig, FavorSmall,
Normal, Poisson.

### CoveragePkg

Revised AddBins and AddCross such that bin merging is off by default.
Added SetMerging to enable/disable merging. Note: Merging is an
experimental feature and still evolving.

Revised AddBins and AddCross to check for changes in BinVal size
(different size bin).

Added RandCovPoint for integer.

Added SetThresholding and SetCovThreshold (Percent) to
enable/disable(default) thresholding. Revised RandCovPoint and
RandCovBinVal to use the new mechanism.

Added SetCovTarget to increase/decrease coverage goals for
longer/shorter simulation runs. Made CovTarget the default percentage
goal (via overloading) for methods RandCovPoint, RandCovBinVal,
IsCovered, CountCovHoles, GetHoleBinVal, and WriteCovHoles.

Revised SetIllegalMode and ICover to support ILLEGAL_FAILURE (severity
FAILURE on illegal bin).

Added manual bin iteration support. Added the following methods that
return a bin index value: GetNumBins, GetMinIndex, and GetMaxIndex.
Added the following methods that return bin values: GetBinVal(BinIndex),
GetMinBinVal, and GetMaxBinVal. Added the following methods that return
point values: GetPoint(BinIndex), GetMinPoint, and GetMaxPoint.

Added GetCov to return the current percent done of the entire coverage
model.

Added FileOpenWriteBin and FileCloseWriteBin to specify default file for
WriteBin, WriteCovHoles, and DumpBin.

Added CompareBins to facilitate comparing two coverage models. Added
CompareBins to facilitate comparing two coverage models.

Revised WriteBin, WriteCovHoles, and WriteCovDb to check for
uninitialized model.

Revised WriteBins and WriteCovHoles to only print weight if the selected
WeightMode uses the weight.

Added IsInitialized to check if a coverage model is initialized.

Added GetBinInfo and GetBinValLength to get bin information

Changed WriteCovDb default for File_Open_Kind to WRITE_MODE. Generally
only one WriteCovDb is needed per coverage model.

Revised WriteCovDb and ReadCovDb for new internal control/state
variables, in the order of ThresholdingEnable, CovTarget, and
MergingEnable. To manually edit old file, add FALSE, 100.0, FALSE to end
of first line.

Removed IgnoreBin with AtLeast and Weight parameters. These are zero for
ignore bins.

Revised method naming for consistency. The following have changed:

  | New Name     | Old Name                | Why                    |   
  ---------------|-------------------------|-------------------------   
  | GetErrorCount | CovBinErrCnt           |  Consistency between packages
  | GetMinCount   | GetMinCov\[return integer\]     |  Naming clarity
  | GetMaxCount   | GetMaxCov\[return integer\]     |  Naming clarity
  | SetName       | SetItemName            |  SetName now does multi-line messages
  | RandCovBinVal | RandCovHole            |  Naming consistency (2.4)
  | GetHoleBinVal | GetCovHole             |  Naming consistency (2.4)

Deprecated usage of the AtLeast parameter (integer) with the following
methods: RandCovPoint, RandCovBinVal, IsCovered, CountCovHoles,
GetHoleBinVal, and WriteCovHoles.

## Revision 2.4 January 2012

### RandomPkg

No changes

### CoveragePkg

Added bin merging and deletion for overlapping bins.

Working on consistency of naming. Renamed RandCovHole to RandCovBinVal.
Renamed GetCovHole to GetCovBinVal. Old names maintained for backward
compatibility.

  | New Name     | Old Name  | Why   |
  ---------------|-------------|--------------------   
  | RandCovBinVal  | RandCovHole  | Naming consistency |
  | GetCovBinVal   | GetCovHole   | Naming consistency |

## Revision 2.3 January 2012

### RandomPkg

No changes

### CoveragePkg

Revision 2.3 adds the function GetBin. GetBin is an accessor function
that returns a bin in the form of a record. It is only intended for
debugging. In particular, the return value of this function may change
as the internal data types evolve.

## Revision 2.2 July 2011

### RandomPkg

Removed \'\_\' in the name of subprograms FavorBig and FavorSmall to
make more consistent with other subprogram names.

### CoveragePkg

Revision 2.2 adds AtLeast and Weights to the coverage database. The
AtLeast value allows individual bins to have a specific coverage goal. A
conjunction of the AtLeast and Weight (depending on the WeightMode) are
used to weight the random selection of coverage holes. These features
are at the heart of intelligent coverage.

## Revision 2.1 June 2011

### RandomPkg

Bug fix to convenience functions for slv, unsigned, and signed.

### CoveragePkg

Removed signal based coverage support.

## Revision 2.0 April 2011

### CoveragePkg

Coverage modeled in a protected type.

## Revision 1.X June 2010

### CoveragePkg

Coverage modeled in signals of type integer_vector. The signal based
coverage methodology is available in the package, CoverageSigPkg,
however, it is recommended that you use CoveragePkg instead.
