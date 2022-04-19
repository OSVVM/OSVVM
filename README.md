# The OSVVM VHDL Verification Utility Library 
The [OSVVM VHDL verification utility library](https://github.com/osvvm/osvvm) implements advanced verification capabilities that are simple to use and feel like built-in language features.  These include:   

  - Transaction-Level Modeling (TbUtilPkg, ResolutionPkg)
  - Constrained Random test generation (RandomPkg)
  - Functional Coverage with hooks for UCIS coverage database integration (CoveragePkg)
  - Intelligent Coverage Random test generation  (CoveragePkg)
  - Utilities for testbench process synchronization generation (TbUtilPkg)
  - Utilities for clock and reset generation (TbUtilPkg)
  - Transcript files (TranscriptPkg)
  - Error logging and reporting - Alerts and Affirmations (AlertLogPkg)
  - Message filtering - Logs (AlertLogPkg)
  - Scoreboards and FIFOs (data structures for verification) (ScoreboardGenericPkg)
  - Memory models (MemoryPkg)
  - Test Reporting - Test Suite and Test Case in HTML 
  - Continuous Integration (CI/CD) Support - with JUnit XML reports
 
## Release History
   For current release information see [CHANGELOG.md](CHANGELOG.md)
   
## Learning OSVVM
You can find an overview of OSVVM at [osvvm.github.io](https://osvvm.github.io).
Alternately you can find our pdf documentation at 
[OSVVM Documentation Repository](https://github.com/OSVVM/Documentation#readme).

You can also learn OSVVM by taking the class, [Advanced VHDL Verification and Testbenches - OSVVM&trade; BootCamp](https://synthworks.com/vhdl_testbench_verification.htm)
 
## Download OSVVM Libraries
OSVVM is available as either a git repository 
[OsvvmLibraries](https://github.com/osvvm/OsvvmLibraries) 
or a zip file from [osvvm.org Downloads Page](https://osvvm.org/downloads).

On GitHub, all OSVVM libraries are a submodule of the repository OsvvmLibraries. Download all OSVVM libraries using git clone with the “–recursive” flag:
```    
  $ git clone --recursive https://github.com/osvvm/OsvvmLibraries
```
        
Alternately to get just the OSVVM verification utility library use:  
        `$ git clone https://github.com/OSVVM/OSVVM`

## Run The Demos
A great way to get oriented with OSVVM is to run the demos.
For directions on running the demos, see [OSVVM Scripts](https://github.com/osvvm/OSVVM-Scripts#readme).

## Participating and Project Organization 
The OSVVM project welcomes your participation with either 
issue reports or pull requests.

You can find the project [Authors here](AUTHORS.md) and
[Contributors here](CONTRIBUTORS.md).

## The OSVVM Family of libraries
The OSVVM family of libraries includes the VHDL Verification Utility library (this one)
as well as verification components and scripting.  These are all kept
as submodules of [OsvvmLibraries](https://github.com/osvvm/OsvvmLibraries).

## More Information on OSVVM

**OSVVM Forums and Blog:**     [http://www.osvvm.org/](http://www.osvvm.org/)   
**Gitter:** [https://gitter.im/OSVVM/Lobby](https://gitter.im/OSVVM/Lobby)  
**Documentation:** [osvvm.github.io](https://osvvm.github.io)    
**Documentation:** [PDF Documentation](https://github.com/OSVVM/Documentation)  

## Copyright and License
Copyright (C) 2006-2022 by [SynthWorks Design Inc.](http://www.synthworks.com/)  
Copyright (C) 2022 by [OSVVM Authors](AUTHORS.md)   

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


