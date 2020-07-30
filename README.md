*"Open Source VHDL Verification Methodology" (OSVVM) Repository*

[![https://gitter.im/OSVVM/Lobby](https://badges.gitter.im/OSVVM/Lobby.svg)](https://gitter.im/OSVVM/Lobby)
![Latest tag](https://img.shields.io/github/tag/JimLewis/OSVVM.svg?style=flat)
[![Apache License 2.0](https://img.shields.io/github/license/JimLewis/OSVVM.svg?style=flat)](LICENSE.md)

------


# About Open Source VHDL Verification Methodology (OSVVM) 
Open Source VHDL Verification Methodology (OSVVM) provides 
utility and model libraries that simplify 
your FPGA and ASIC verification tasks.
Using these libraries you can create a simple, readable, and 
powerful testbench that is suitable for either a simple FPGA block
or a complex ASIC.

This repository contains the OSVVM Utility Library. 
Download it using git:    
   `git clone https://github.com/OSVVM/OSVVM.git`



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
 
Download the OSVVM Utility library using git:    
   `git clone https://github.com/OSVVM/OSVVM.git`

 
## The OSVVM Model Library
The OSVVM model library is a growing set of models 
commonly used for FPGA and ASIC verification.  
The library currently contains the following repositories:

 - [OSVVM-Libraries](https://github.com/osvvm/OsvvmLibraries)  
   - Repository that contains all of the OSVVM libraries as submodules.
   - Download all OSVVM libraries using git clone with the "--recursive" flag:  
        `$ git clone --recursive https://github.com/OSVVM/OsvvmLibraries.git`
   - Note submodules are not included in the GitHub zip files
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

We use the word models as short hand for 
Transaction Based Models (TBM). 
They are simply an entity and architecture coded in 
an effective manner for verification.
Some use other terminology such as 
VHDL verification components (VVC) - 
these are the same thing.
Historically we used Bus Functional Models (BFM). 
However, recently we abandoned BFM due to others using BFM to 
refer to their own lesser capable subprogram based approach.

OSVVM models use records for the transaction interfaces, 
so connecting them to your testbench is simple - 
connect only a single signal.

Testbenches are in the Git repository, so you can 
run a simulation and see a live example 
of how to use the models.

**OSVVM Forums - currently broken:**     [http://www.osvvm.org/][osvvm]  
**OSVVM Blog:** [http://www.synthworks.com/blog/osvvm/][osvvm-blog]  
**License:**	[Apache License 2.0][AL2]
**Copyright:**	Copyright © 2006-2020 by [SynthWorks Design Inc.](http://www.synthworks.com/)

## Release History
   For current release information see [osvvm_release_notes.pdf](doc/osvvm_release_notes.pdf)
   

------

*Starting with 2016.01, this repository was handed off to Jim Lewis (OSVVM Developer) and became the GIT site for OSVVM*  
*Releases prior to 2016.01 were uploaded by Patrick Lehmann*

 [osvvm]:      http://www.osvvm.org/
 [osvvm-blog]: http://www.synthworks.com/blog/osvvm/
 [aldec]:      http://www.aldec.com/
 [AL2]:	   http://www.apache.org/licenses/LICENSE-2.0





