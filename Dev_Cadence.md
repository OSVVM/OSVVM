*"Cadence Development Branch" (OSVVM) Repository*
------
This branch is intended to contain changes to allow OSVVM to work with Cadence simulators.  It is my intent to take the easiest path possible.  IE: where OSVVM uses "?=", this branch will just use "=".  So on Cadence there will be some reduced functionality, but overall, I don't think that most will notice.  

Changes that are OSVVM issues or do not reduce capability will be incorporated into the main branch.  Changes that are Cadence issues will remain on this development branch until they are fixed.


Command line switches
-v200x -extv200x

Current Changes from Main Release:
----------------------------------
Notes 
  I specifically avoided *_c versions of packages from the 
  VHDL-2008 pre-release.  In some cases, using these packages
  will give you better capability, however, doing that would 
  have required a customized test environment for the DEV_Cadence
  branch.  This is something I at least initially wanted to avoid.
  We may need to reconsider depending on Cadence's committment to 
  supporting the minimal VHDL-2008 features used by OSVVM.
  
Try3 Updates:
  Compilation is finally working.  We are working to address 
  run time issues with calls to SetLogEnable. The errors could be 
  due to the data structure not being initialized.  I have added 
  code to AlertLogPkg to try to find it and added code to 
  the demo programs to allow a little more time for the structure 
  to be initialized if the initialization is going to happen.
  
  AlertLogPkg:
    Added debugging code to SetLogEnable to report unallocated structures more gracefully.   The structures should have been allocated during initialization of the package body.
    
  demo/AlertLog_Demo_Global.vhd and demo/AlertLog_Demo_Hierarchy.vhd
    Changed std.env.stop to std.env.stop(0)
    Changed the wait for 0 ns before SetLogEnable to wait for 1 ns 
  
  
TextUtilPkg:
  Try2:  Added Reference to ieee.std_logic_textio for hwrite
  
AlertLogPkg:
  Try1: 
    In AffirmIf, replaced "?=" and "?/=" with "=" and "/=".  
    Impact:  Looses proper handling of '-'
  Try2: 
    Changed call std.env.stop to std.env.stop(0).  Otherwise will need to be replaced with report
    Replaced LocalInitialize with allocation directly on AlertLogPtr
    Borrowed sread from std_textio_additions
    Borrowed to_string from std_logic_1164_additions
    
AlertLogPkg_alt1:
  AlertLogPkg.Try2 except
    Initialize now is a copy of LocalInitialize.  
    Hence, the only thing that calls LocalInitialize is the constant.
    Wanted to only do this, however, not convinced it would work in Cadence, hence, 
    created a separate AlertLogPkg.
  
CoveragePkg:
  Try1:  
    Moved WriteBinFile from inside protected type to inside package.
    Impact:  only one coverage model WritBin method may use the local file
    Recommendation:  TranscriptPkg.TranscriptFile is intended to replace this anyway
  Try2: 
    Replaced swrite with specific calls
    Issues with RandomPType not being elaborate should be fixed by fixes to RandomPkg
  
OsvvmGlobalPkg:
  Try1: 
    Removed values TRUE and FALSE from OsvvmOptionsType
    Updated return value of to_OsvvmOptionsType
    Impact:  Use values ENABLED and DISABLED instead.
  
TranscriptPkg:
  Try1:  
    Replaced call to TEE with copying the buffer and two calls to WriteLine
    Impact:  May run slightly slower

MemoryPkg:
  Try2:  
    Added reference to std_logic_textio for hwrite
    Borrowed to_string from std_logic_1164_additions.  
    Replaced calls to to_hstring with to_string in Alerts and Logs
    