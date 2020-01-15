*"Open Source VHDL Verification Methodology" (OSVVM) Repository*

[![https://gitter.im/OSVVM/Lobby](https://badges.gitter.im/OSVVM/Lobby.svg)](https://gitter.im/OSVVM/Lobby)
![Latest tag](https://img.shields.io/github/tag/JimLewis/OSVVM.svg?style=flat)
[![Artistic License 2.0](https://img.shields.io/github/license/JimLewis/OSVVM.svg?style=flat)](LICENSE.md)

------
# Open Source VHDL Verification Methodology (OSVVM)
Open Source VHDL Verification Methodology (OSVVM) reduces the complexity of your verification task by providing utility and model libraries.

## OSVVM is the #1 VHDL Verification Methodology 
According to the [2018 Wilson Verification Survey](https://blogs.mentor.com/verificationhorizons/blog/2019/01/15/part-6-the-2018-wilson-research-group-functional-verification-study/), OSVVM is the:
 - #1 VHDL Verification Methodology
 - #1 FPGA Verification Methodology in Europe (ahead of SystemVerilog + UVM)

## The OSVVM Utility Library 
The [OSVVM utility library](https://github.com/OSVVM/OSVVM) offers the same capabilities as those provided by other verification languages (such as SystemVerilog and UVM):

 - Transaction-Level Modeling
 - Constrained Random test generation
 - Functional Coverage with hooks for UCIS coverage database integration
 - Intelligent Coverage Random test generation
 - Utilities for testbench process synchronization generation
 - Utilities for clock and reset generation
 - Transcript files
 - Error logging and reporting - Alerts and Affirmations
 - Message filtering - Logs
 - Scoreboards and FIFOs (data structures for verification)
 - Memory models
 
## The OSVVM Model Library
The OSVVM model library provides off the shelf models for:

 - [AXI4 Lite](https://github.com/OSVVM/AXI4)
   - Master
   - Slave transactor model
 - [AXI Stream](https://github.com/OSVVM/AXI4)
   - Master
   - Slave
 - [UART](https://github.com/OSVVM/AXI4)
   - Transmitter (aka master) - with error injection
   - Receiver (aka slave) - with error injection
 - [OSVVM Common - Required](https://github.com/OSVVM/OSVVM-Common)
   - Shared transcript interfaces
 - [OSVVM Scripts](https://github.com/OSVVM/OSVVM-Scripts)
   - Recommended.  Script layer on top of tcl
   - Common simulator compilation and execution methodology
 - Verification IP
   - Intended to include the above as submodules, but currently something is broken in the linking in GitHub.


**OSVVM Forums - currently broken:**     [http://www.osvvm.org/][osvvm]  
**OSVVM Blog:** [http://www.synthworks.com/blog/osvvm/][osvvm-blog]  
**License:**	[Artistic License 2.0][PAL2.0]  
**Copyright:**	Copyright © 2006-2020 by [SynthWorks Design Inc.](http://www.synthworks.com/)

## Release History
   For current release information see [osvvm_release_notes.pdf](doc/osvvm_release_notes.pdf)
   
   The following has a bad habit of falling behind the current release:
 - Apr-2018 - **2018.04**  Minor updates to AlertLogPkg, CoveragePkg, ScoreboardGenericPkg, TbUtilPkg, MessagePkg
 - May-2017 - **2017.05**  Minor additions to AlertLogPkg, CoveragePkg, and ScoreboardGenericPkg
 - Nov-2016 - **2016.11**  Added VendorCovApiPkg, ScoreboardGenericPkg, TbUtilPkg, ResolutionPkg
 - Jan-2016 - **2016.01**  Fix limit of 32 AlertLogIDs, Updates for GHDL (Purity and L.all(L'left)), 
 - Jul-2015 - **2015.06**  Addition of MemoryPkg
 - Mar-2015 - **2015.03**  Bug fixes to AlertLogPkg (primarily ClearAlerts, but also matching names)
 - Jan-2015 - **2015.01**  Not here. Addition of AlertLogPkg, TranscriptPkg,OsvvmContext, and OsvvmGlobalPkg.  
 - Dec-2014 - **2014.07a** Fixed memory leak in CoveragePkg.Deallocate.  Replaced initialized pointers with initialization functions
 - Jul-2014 - **2014.07**  Not here. Added names to coverage bins.  Added option during WriteBin so that a bin prints PASSED if its count is greater than the coverage goal, otherwise FAILED.  
 - Jan-2014 - **2014.01**  RandomPkg: RandTime, RandIntV, RandRealV, RandTimeV.  CoveragePkg:  Support merging of coverage bins.  
 - May-2013 - **2013.05**  RandomPkg:  Big Vector Randomization.  
 

------

*Starting with 2016.01, this repository was handed off to Jim Lewis (OSVVM Developer) and became the GIT site for OSVVM*  
*Releases prior to 2016.01 were uploaded by Patrick Lehmann*

 [osvvm]:      http://www.osvvm.org/
 [osvvm-blog]: http://www.synthworks.com/blog/osvvm/
 [aldec]:      http://www.aldec.com/
 [PAL2.0]:	   http://www.perlfoundation.org/artistic_license_2_0





