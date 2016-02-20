*"Cadence Development Branch" (OSVVM) Repository*
------
This branch is intended to contain changes to allow OSVVM to work with Cadence simulators.  It is my intent to take the easiest path possible.  IE: where OSVVM uses "?=", this branch will just use "=".  So on Cadence there will be some reduced functionality, but overall, I don't think that most will notice.  

Changes that are OSVVM issues or do not reduce capability will be incorporated into the main branch.  Changes that are Cadence issues will remain on this development branch until they are fixed.


Command line switches
-v200x -extv200x

Current Changes from Main Release:
----------------------------------
AlertLogPkg:
  In AffirmIf, replaced "?=" and "?/=" with "=" and "/=".  
  Impact:  Looses proper handling of '-'
  
In CoveragePkg:
  Moved WriteBinFile from inside protected type to inside package.
  Impact:  only one coverage model WritBin method may use the local file
  Recommendation:  TranscriptPkg.TranscriptFile is intended to replace this anyway
  
In OsvvmGlobalPkg:
  Removed values TRUE and FALSE from OsvvmOptionsType
  Updated return value of to_OsvvmOptionsType
  Impact:  Use values ENABLED and DISABLED instead.
  
In TranscriptPkg:
  Replaced call to TEE with copying the buffer and two calls to WriteLine
  Impact:  May run slightly slower

