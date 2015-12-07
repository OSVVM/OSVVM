  ------------------------------------------------------------
  -- package local, Used by GenBin, IllegalBin, and IgnoreBin
  function MakeBin(
  ------------------------------------------------------------
    Min, Max      : integer ;
    NumBin        : integer ;
    AtLeast       : integer ;
    Weight        : integer ;
    Action        : integer
  ) return CovBinType is
    variable iCovBin : CovBinType(1 to NumBin) ;
    variable TotalBins : integer ; -- either real or integer
    variable rMax, rCurMin, rNextMin, rNumItemsInBin, rRemainingBins : real ; -- must be real
    variable CurMin, Offset : integer ; 
  begin
    if Min > Max then
      Alert(OSVVM_ALERTLOG_ID, "CoveragePkg.MakeBin (GenBin, IllegalBin, IgnoreBin): Min must be <= Max", FAILURE) ;
      return NULL_BIN ;

    elsif NumBin <= 0 then
      Alert(OSVVM_ALERTLOG_ID, "CoveragePkg.MakeBin (GenBin, IllegalBin, IgnoreBin): NumBin must be <= 0", FAILURE) ;
      return NULL_BIN ;

    elsif NumBin = 1 then
      iCovBin(1) := (
        BinVal => (1 => (Min, Max)),
        Action => Action,
        Count => 0,
        Weight => Weight,
        AtLeast => AtLeast
      ) ;
      return iCovBin ;

    else
      CurMin := Min ; 
      TotalBins := integer( (minimum( real(NumBin), real(Max) - real(Min) + 1.0))) ; 
      RemainingBins := TotalBins ; 
      
      for i in iCovBin'range loop
        exit when RemainingBins = 0 ; 
        
        Offset := CalcOffset(Min, Max, )
        RemainingBins := CALC_NUM_BINS - i ;
        NumItemsInBin := (Max - CurMin + 1) / RemainingBins ;
        NextMin := CurMin + NumItemsInBin ;
        iCovBin(i) := (
          BinVal => (1 => (CurMin, NextMin - 1)),
          Action => Action,
          Count => 0,
          Weight => Weight,
          AtLeast => AtLeast
        ) ;
        CurMin := NextMin ;
      end loop ;
      return iCovBin ;
      
      
      rCurMin := real(Min) ;
      rMax    := real(Max) ;
      rRemainingBins :=  (minimum( real(NumBin), rMax - rCurMin + 1.0 )) ;
      TotalBins := integer(rRemainingBins)  ;
      for i in iCovBin'range loop
        exit when rRemainingBins = 0.0 ;
        rNumItemsInBin := trunc((rMax - rCurMin + 1.0) / rRemainingBins) ; -- can be too large
        rNextMin := rCurMin + rNumItemsInBin ;  -- can be 2**31
        iCovBin(i) := (
          BinVal => (1 => (integer(rCurMin), integer(rNextMin - 1.0))),
          Action => Action,
          Count => 0,
          Weight => Weight,
          AtLeast => AtLeast
        ) ;
        rCurMin := rNextMin ;
        rRemainingBins := rRemainingBins - 1.0 ;
      end loop ;
      return iCovBin(1 to TotalBins) ;
    end if ;
  end function MakeBin ;  


  ------------------------------------------------------------
  -- Local, Used by GenBin, IllegalBin, and IgnoreBin
  function MakeBin(
  ------------------------------------------------------------
    Min, Max      : integer ;
    NumBin        : integer ;
    AtLeast       : integer ;
    Weight        : integer ;
    Action        : integer
  ) return CovBinType is
    constant CALC_NUM_BINS : integer := minimum(NumBin, Max-Min+1) ;
    variable iCovBin : CovBinType(0 to CALC_NUM_BINS -1) ;
    variable CurMin, NextMin, RemainingBins, NumItemsInBin : integer ;
  begin
    CurMin := Min ;
    for i in iCovBin'range loop
      RemainingBins := CALC_NUM_BINS - i ;
      NumItemsInBin := (Max - CurMin + 1) / RemainingBins ;
      NextMin := CurMin + NumItemsInBin ;
      iCovBin(i) := (
        BinVal => (1 => (CurMin, NextMin - 1)),
        Action => Action,
        Count => 0,
        Weight => Weight,
        AtLeast => AtLeast
      ) ;
      CurMin := NextMin ;
    end loop ;
    return iCovBin ;
  end function MakeBin ;
  
