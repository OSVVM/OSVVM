    constant COV_READ_YAML_ALERT_LEVEL : AlertType := ERROR ;
    
    ------------------------------------------------------------
    --  pt local.  Find a specific token potentially split across lines
    procedure ReadFindToken (
    ------------------------------------------------------------
      file     ReadFile :       text ; 
      constant Token    : in    string ;
      variable buf      : inout line ;
      variable Found    : out   boolean
    ) is
      variable Empty, MultiLineComment      : boolean ;
      variable vToken     : string(1 to Token'length) ;
    begin
      Found := FALSE ; 
      
      ReadLoop : loop   
        if L = NULL or L.all'length = 0  then 
          -- return Good FALSE when file empty
          exit ReadLoop when EndFile(ReadFile) ;
          -- Get Next Line
          ReadLine(ReadFile, buf) ;
        end if ; 
        -- Skip blank and multi-line comment lines
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ; 
        next ReadLoop when Empty;

        read(buf, vToken, ReadValid) ;
        exit ReadLoop when not ReadValid ; 
        exit ReadLoop when vToken /= Token ;
        Found := TRUE ; 
        exit ReadLoop ;
      end loop ReadLoop ;
    end procedure ReadFindToken ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadQuotedString (
    ------------------------------------------------------------
      variable buf      : inout line ;
      variable Name     : inout line 
    ) is
      variable char    : character ; 
      variable vString : string(1 to buf'length) ; 
      variable Index   : integer := 1 ; 
      variable Found, Empty, ReadValid : boolean ; 
    begin
      Found := FALSE ; 
      if Name /= NULL then 
        deallocate(Name) ; 
      end if ; 
      
      ReadLoop : loop   
        SkipWhiteSpace(buf, Empty) ;  -- Skips white space at beginning of line
        exit ReadLoop when Empty ;
        
        exit ReadLoop when buf.all(buf'left) /= '"' ;
        Read(buf, Char, ReadValid) ;
        exit ReadLoop when not ReadValid ;
        
        for i in vString'range loop
          Read(buf, Char, ReadValid) ;
          exit ReadLoop when not ReadValid ;
          if Char = '"' then 
            Index := i - 1 ; 
            Found := TRUE ; 
            exit ; 
          end if ; 
          exit ReadLoop when buf.all'length = 0 ;
        end loop ; 
      end loop ReadLoop ;
        
      if Found then 
        Name := new string'(vSting(1 to Index)) ; 
      end if ; 
    end procedure ReadQuotedString ;
    
    ------------------------------------------------------------
    --  pt local
    procedure ReadCovModelNameYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ; 
      variable ID          : out CoverageIDType ;
      variable Found       : out boolean
    ) is
      variable buf  : line ;
      variable Name : line ; 
    begin
      Found := FALSE ; 
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "- Name:", buf, Found) ; 
        exit ReadLoop when not Found ; 
        -- Get the Name
        ReadQuotedString(buf, Name) ;
        exit when AlertIf(OSVVM_COV_ALERTLOG_ID, Name = NULL, 
            "CoveragePkg.ReadCovYaml: Unnamed Coverage Model.", COV_READ_YAML_ALERT_LEVEL);
        ID := NewID(Name.all) ; 
        deallocate(Name) ; 
        Found := TRUE ; 
        exit ; 
      end loop ReadLoop ; 
    end procedure ReadCovModelNameYaml ; 

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovSettingsYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ; 
      constant CovID       : in  CoverageIDType ;
      variable Found       : out boolean
    ) is
      variable buf          : line ;
      variable Name         : line ; 
      constant ID           : integer := CovID.ID ; 
      constant AlertLogID   : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
      variable vInteger     : integer ; 
      variable vReal        : integer ; 
      variable Seed1, Seed2 : integer ; 
    begin
      Found := FALSE ; 
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "Settings:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Settings:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- CovWeight
        ReadFindToken (CovYamlFile, "CovWeight:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Settings:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, Valid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading CovWeight value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovWeight := vInteger ; 

        -- Goal
        ReadFindToken (CovYamlFile, "Goal:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Goal:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vReal, Valid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading CovTarget value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovTarget := vReal ; 

       -- WeightMode
        ReadFindToken (CovYamlFile, "WeightMode:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""WeightMode:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ; 
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL, 
            "CoveragePkg.ReadCovYaml Error while reading WeightMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "REMAIN" then
          CovStructPtr(ID).CovBinPtr(BinIndex).WeightMode := REMAIN ; 
        else -- at_least
          CovStructPtr(ID).CovBinPtr(BinIndex).WeightMode := AT_LEAST ; 
        end if ; 
        
       -- Seeds
        ReadFindToken (CovYamlFile, "Seeds:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Seeds:""", COV_READ_YAML_ALERT_LEVEL) ;
            
        -- [
        ReadFindToken (CovYamlFile, "[", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find Seeds ""[""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Seed1, ReadValid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading Seed1 value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- ,
        ReadFindToken (CovYamlFile, ",", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find Seed #2 "",""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Seed2, ReadValid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading Seed2 value.", COV_READ_YAML_ALERT_LEVEL) ;

        CovStructPtr(ID).CovBinPtr(BinIndex).RV := (Seed1, Seed2) ; 
            
       -- CountMode
        ReadFindToken (CovYamlFile, "CountMode:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""CountMode:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ; 
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL, 
            "CoveragePkg.ReadCovYaml Error while reading CountMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "COUNT_ALL" then
          CovStructPtr(ID).CovBinPtr(BinIndex).CountMode := COUNT_ALL ; 
        else
          CovStructPtr(ID).CovBinPtr(BinIndex).CountMode := COUNT_FIRST ; 
        end if ; 

       -- IllegalMode
        ReadFindToken (CovYamlFile, "IllegalMode:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""IllegalMode:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ; 
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL, 
            "CoveragePkg.ReadCovYaml Error while reading IllegalMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "ILLEGAL_OFF" then
          CovStructPtr(ID).CovBinPtr(BinIndex).IllegalMode := ILLEGAL_OFF ; 
        elsif Name.all = "ILLEGAL_FAILURE" then
          CovStructPtr(ID).CovBinPtr(BinIndex).IllegalMode := ILLEGAL_FAILURE ; 
        else
          CovStructPtr(ID).CovBinPtr(BinIndex).IllegalMode := ILLEGAL_ON ; 
        end if ; 

       -- Threashold
        ReadFindToken (CovYamlFile, "Threashold:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Threashold:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vReal, Valid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading Threashold value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovThreshold := vReal ; 

       -- ThreasholdEnable
        ReadFindToken (CovYamlFile, "ThreasholdEnable:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""ThreasholdEnable:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ; 
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL, 
            "CoveragePkg.ReadCovYaml Error while reading IllegalMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "TRUE" then
          CovStructPtr(ID).CovBinPtr(BinIndex).ThresholdingEnable := TRUE ; 
        else
          CovStructPtr(ID).CovBinPtr(BinIndex).ThresholdingEnable := FALSE ; 
        end if ; 

       -- TotalCovCount - read and toss
        ReadFindToken (CovYamlFile, "TotalCovCount:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""TotalCovCount:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, Valid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading TotalCovCount value.", COV_READ_YAML_ALERT_LEVEL) ;
        -- Value not used

       -- TotalCovGoal - read and toss
        ReadFindToken (CovYamlFile, "TotalCovGoal:", buf, Found) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""TotalCovGoal:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, Valid) ; 
        exit ReadLoop when AlertIf(AlertLogID, not Valid, 
            "CoveragePkg.ReadCovYaml Error while reading TotalCovGoal value.", COV_READ_YAML_ALERT_LEVEL) ;
        -- Value not used
        Found := TRUE ; 
        exit ; 
      end loop ReadLoop ; 
      deallocate(Name) ; 
    end procedure ReadCovModelNameYaml ; 
    
    ------------------------------------------------------------
    --  pt local
    procedure ReadCovBinInfoYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ; 
      constant CovID       : in  CoverageIDType ;
      variable Dimensions  : out integer ; 
      variable NumBins     : out integer ; 
      variable Found       : out boolean
    ) is
      variable buf            : line ;
      variable FieldNameArray : FieldNameArrayType(1 to 20) ;
      constant ID             : integer := CovID.ID ; 
      constant AlertLogID     : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
    begin
      Found := FALSE ; 
      Dimensions := 0 ; 
      NumBins := 0 ; 
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "BinInfo:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""BinInfo:""", COV_READ_YAML_ALERT_LEVEL) ;
        
        -- Dimensions
        ReadFindToken (CovYamlFile, "Dimensions:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Dimensions:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Dimensions, Valid) ; 
        exit when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading Dimensions value.", COV_READ_YAML_ALERT_LEVEL) ;
        
        -- FieldNames
        ReadFindToken (CovYamlFile, "FieldNames:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""FieldNames:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- FieldNames Values
        FoundFieldName := FALSE ; 
        for i in 1 to Dimensions loop 
          ReadFindToken (CovYamlFile, "-", buf, Found) ; 
          exit when AlertIf(AlertLogID, not Found, 
              "CoveragePkg.ReadCovYaml did not find Field Name deliminter '-'.", COV_READ_YAML_ALERT_LEVEL) ;
          ReadQuotedString(buf, FieldNameArray(i)) ; 
          exit ReadLoop when AlertIf(AlertLogID, FieldNameArray(i) = NULL, 
              "CoveragePkg.ReadCovYaml Error while reading Field Name value # " & to_string(i), COV_READ_YAML_ALERT_LEVEL) ;
          if FieldNameArray(i) /= ("Bin" & to_string(i)) then 
            FoundFieldName := TRUE ; 
          end if ;
        end loop ; 
        if FoundFieldName then
          CovStructPtr(ID).FieldName := new FieldNameArrayType'(FieldNameArray(1 to Dimensions)) ;
        end if ;
        
        -- NumBins
        ReadFindToken (CovYamlFile, "NumBins:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""NumBins:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, NumBins, Valid) ; 
        exit when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading NumBins value.", COV_READ_YAML_ALERT_LEVEL) ;
        
        -- End 
        Found := TRUE ; 
        exit ; 
      end loop ReadLoop ;
      if not Found or not FoundFieldName then 
        -- clean up pointers
        for i in 1 to Dimensions loop
          deallocate(FieldNameArray(i)) ; 
        end loop ;
      end if ; 
    end procedure ReadCovBinInfoYaml ; 

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovOneBinYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ; 
      constant CovID       : in  CoverageIDType ;
      constant BinIndex    : in  integer ; 
      constant Dimensions  : in  integer ; 
      variable Found       : out boolean
    ) is
      variable buf            : line ;
      variable Name           : line ; 
      constant ID             : integer := CovID.ID ; 
      constant AlertLogID     : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
      variable Min, Max       : integer ; 
      variable vInteger       : integer ;
      variable vReal          : real ;
    begin
      Found := FALSE ; 
      ReadLoop: loop
        -- - Name:
        ReadFindToken (CovYamlFile, "- Name:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find Bins ""Name:""", COV_READ_YAML_ALERT_LEVEL) ;

        ReadFindToken(buf, NamePtr) ; 
        CovStructPtr(ID).CovBinPtr(BinIndex).Name := NamePtr ;  

        -- Type:
        ReadFindToken (CovYamlFile, "Type:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Type:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ; 
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL, 
            "CoveragePkg.ReadCovYaml Error while reading Type value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "COUNT" then
          CovStructPtr(ID).CovBinPtr(BinIndex).Action := 1 ; 
        elsif Name.all = "IGNORE" then
          CovStructPtr(ID).CovBinPtr(BinIndex).Action := 0 ; 
        else -- Illegal
          CovStructPtr(ID).CovBinPtr(BinIndex).Action := -1 ; 
        end if ; 
        deallocate(Name) ; 

        -- Range:
        ReadFindToken (CovYamlFile, "Range:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Range:""", COV_READ_YAML_ALERT_LEVEL) ;
            
        -- RangeArrayType
        CovStructPtr(ID).CovBinPtr(BinIndex).BinVal := new RangeArrayType(1 to Dimensions) ;
        for i in 1 to Dimensions loop
          -- - {Min:
          ReadFindToken (CovYamlFile, "- {Min:", buf, Found) ; 
          exit ReadLoop when AlertIf(AlertLogID, not Found, 
              "CoveragePkg.ReadCovYaml did not find Bins ""Min:""", COV_READ_YAML_ALERT_LEVEL) ;
          Read(buf, Min, ReadValid) ; 
          exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
              "CoveragePkg.ReadCovYaml Error while reading Min value.", COV_READ_YAML_ALERT_LEVEL) ;

          -- , Max:
          ReadFindToken (CovYamlFile, ", Max:", buf, Found) ; 
          exitReadLoop  when AlertIf(AlertLogID, not Found, 
              "CoveragePkg.ReadCovYaml did not find Bins ""Max:""", COV_READ_YAML_ALERT_LEVEL) ;
          Read(buf, Max, ReadValid) ; 
          exit ReadLoop when AlertIf(AlertLogID, not ReadValid, 
              "CoveragePkg.ReadCovYaml Error while reading Max value.", COV_READ_YAML_ALERT_LEVEL) ;

          CovStructPtr(ID).CovBinPtr(BinIndex).BinVal(i) := (Min => Min, Max => Max) ; 
        end loop ; 
        
        -- Count: 
        ReadFindToken (CovYamlFile, "Count:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Count:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, ReadValid) ; 
        exit when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading Count value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovBinPtr(BinIndex).Count := vInteger ; 
        
        -- AtLeast: 
        ReadFindToken (CovYamlFile, "AtLeast:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""AtLeast:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, ReadValid) ; 
        exit when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading AtLeast value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovBinPtr(BinIndex).AtLeast := vInteger ; 

        -- PercentCov: 
        ReadFindToken (CovYamlFile, "PercentCov:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""PercentCov:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vReal, ReadValid) ; 
        exit when AlertIf(AlertLogID, not ReadValid, 
            "CoveragePkg.ReadCovYaml Error while reading PercentCov value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovBinPtr(BinIndex).PercentCov := vReal ; 

        -- End 
        Found := TRUE ; 
        exit ; 
      end loop ReadLoop ;
    end procedure ReadCovOneBinYaml ;     
    
--    ------------------------------------------------------------
--    --  pt local
--    procedure WriteCovBinsYaml (ID : CoverageIDType; variable buf : inout LINE; Prefix : string ) is
--    ------------------------------------------------------------
--      variable Action : integer ; 
--      variable CovBin : CovBinInternalBaseType ;
--    begin
--      -- write bins to YAML file
--      write(buf, Prefix & "Bins: " & LF) ; 
--      
--      writeloop : for EachLine in 1 to CovStructPtr(ID).NumBins loop
--        CovBin := CovStructPtr(ID).CovBinPtr(EachLine) ;
--        write(buf, Prefix & "  - Name: " & IfElse(CovBin.Name'length > 0, CovBin.Name.all, "~") & LF) ;
--        write(buf, Prefix & "    Type: " & ActionToName(CovBin.Action) & LF ) ;
--        write(buf, Prefix & "    Range: " & LF) ;
--        WriteBinValYaml(buf, CovBin.BinVal.all, Prefix & "      ") ; 
--        write(buf, Prefix & "    Count: "      & to_string(CovBin.Count) & LF) ;
--        write(buf, Prefix & "    AtLeast: "    & to_string(CovBin.AtLeast) & LF) ;
--        write(buf, Prefix & "    PercentCov: " & to_string(CovBin.PercentCov, 4) & LF) ;
--      end loop writeloop ; 
--    end procedure WriteCovBinsYaml ;
    
    ------------------------------------------------------------
    --  pt local
    procedure ReadCovBinsYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ; 
      constant CovID       : in  CoverageIDType ;
      constant Dimensions  : in  integer ; 
      constant NumBins     : in  integer ; 
      variable Found       : out boolean
    ) is
      variable buf            : line ;
      variable FieldNameArray : FieldNameArrayType(1 to 20) ;
      constant ID             : integer := CovID.ID ; 
      constant AlertLogID     : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
    begin
      Found := FALSE ; 
      Dimensions := 0 ; 
      NumBins := 0 ; 
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "Bins:", buf, Found) ; 
        exit when AlertIf(AlertLogID, not Found, 
            "CoveragePkg.ReadCovYaml did not find ""Bins:""", COV_READ_YAML_ALERT_LEVEL) ;
        
        CovStructPtr(ID).CovBinPtr := new CovBinInternalType(1 to NumBins) ;
        
        for i in 1 to NumBins loop
          ReadCovOneBinYaml(CovYamlFile, ID, i, Dimensions, Found) ; 
          exit ReadLoop when not Found ;
        end loop ;

        -- End 
        Found := TRUE ; 
        exit ; 
      end loop ReadLoop ;
    end procedure ReadCovBinsYaml ; 
    
    ------------------------------------------------------------
    --  pt local
    procedure ReadCovYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ; 
      variable FoundModel  : out boolean
    ) is
      variable Found : boolean ; 
      variable CovID : CoverageIDType ; 
      
      variable Dimensions : integer ; 
      variable NumBins : integer ; 
    begin
      FoundModel := FALSE ;
      FoundModelName := FALSE ;
      
      ReadLoop: loop
        ReadCovModelNameYaml(CovYamlFile, CovID, Found) ;
        exit when not Found ;
        FoundModelName := TRUE ;

-- Nothing to do with this for now        
--        ReadCovTestCasesYaml(CovID, CovYamlFile, Found) ;
--        exit when not Found ;
      
        ReadCovSettingsYaml(CovID, CovYamlFile, Found) ;
        exit when not Found ;
        
        ReadCovBinInfoYaml(CovID, CovYamlFile, Dimensions, NumBins, Found) ;
        exit when not Found ;

        ReadCovBinsYaml(CovID, CovYamlFile, Dimensions, NumBins, Found) ;
        exit when not Found ;

      end loop ReadLoop ; 
      
      if FoundModelName and not Found then
        -- remove partially constructed model
      end if ; 
      FoundModel := Found ;
    end procedure ReadCovYaml ; 

--     ------------------------------------------------------------
--     procedure ReadCovYaml (ModelName : string; FileName : string) is
--     ------------------------------------------------------------
--       file CovYamlFile : text open READ_MODE is FileName ;
--     begin
--       ID := NewID("ModelName"
--       ReadCovYaml(ID, CovYamlFile) ; 
--       file_close(CovYamlFile) ;
--     end procedure ReadCovYaml ;

    ------------------------------------------------------------
    procedure ReadCovYaml (FileName : string := ""; Coverage : real) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := IfElse(FileName = "", "./reports/" & GetAlertLogName & "_cov.yml", FileName) ; 
      file CovYamlFile : text open READ_MODE is RESOLVED_FILE_NAME ;
      variable buf : line ;
    begin
      ReadUntilToken (CovYamlFile, "Models:", buf, Match) ; 
      if not Match then 
        Alert(OSVVM_COV_ALERTLOG_ID, 
            "No Coverage Models found in " & RESOLVED_FILE_NAME, COV_READ_YAML_ALERT_LEVEL) ; 
        return ; 
      end if;
      
      loop
        ReadCovYaml(CovYamlFile, Found) ; 
        exit when not Found ; 
      end loop ;
      file_close(CovYamlFile) ;
    end procedure ReadCovYaml ;
