/* Security Scanned */
public with sharing class SLAT_SLAClockOnCase
{
    public Long ElapsedMinutes = 0;
    public Datetime InitialResponseBy, OnsiteResponseBy, RestorationBy, ResolutionBy;
    public integer iIRdays = 0;
    public integer iIRhrs = 0;
    public integer iIRmins = 0;
    public integer iIRsecs = 0;
    public integer iORdays = 0;
    public integer iORhrs = 0;
    public integer iORmins = 0;
    public integer iORsecs = 0;
    public integer iAREdays = 0;
    public integer iAREhrs = 0;
    public integer iAREmins = 0;
    public integer iAREsecs = 0;
    public integer iAROdays = 0;
    public integer iAROhrs = 0;
    public integer iAROmins = 0;
    public integer iAROsecs = 0;
    public String RemainingTimeIR = '';
    public String RemainingTimeOR = '';
    public String RemainingTimeResto = '';
    public String RemainingTimeResol = '';
    public String CaseReason = '';
    public string VFMessage = '';
    public Case caseobj = new Case();
    public BusinessHours bh = new BusinessHours();
    public SVMXC__Service_Level__c  SLATerm = new SVMXC__Service_Level__c ();
    public List<SVMXC__SLA_Detail__c> SLADetails = new List<SVMXC__SLA_Detail__c>();
    public boolean PopupMsg = false;
    public Boolean displayPopUp = false;
    public Boolean displaystartPopUp = false;
    SVMXC.COMM_Utils_DateCalculation  DatCal = new SVMXC.COMM_Utils_DateCalculation(); 
    public Boolean SLAClockPause; 
    public String Reason;
    public String ForHowLong;
    public double SLAIRMin = 0;
    public double SLAORMin = 0;
    public double SLARestorationMin = 0;
    public double SLAResolutionMin = 0;
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    public integer ThresholdTime = 0;
    public Account AccountBH = new Account();
    public SVMXC__Installed_Product__c IBBH = new SVMXC__Installed_Product__c();
    public SVMXC__Service_Contract__c ServiceContractBH = new SVMXC__Service_Contract__c();
    public Map<String,String> BHMap = new Map<String,String>();
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('SLAT002');

    public Object getair(){ return caseobj.Actual_Initial_Response__c; }
    public void setair(Object value){}
    
    public Object getaor(){ return caseobj.Actual_Onsite_Response__c; }
    public void setaor(Object value){}
    
    public Object getart(){ return caseobj.Actual_Restoration__c; }
    public void setart(Object value){}
    
    public Object getars(){ return caseobj.Actual_Resolution__c; }
    public void setars(Object value){}
    
    public SLAT_SLAClockOnCase(ApexPages.StandardController controller) 
    {
        String CaseID = controller.getId();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        bh = [Select id from BusinessHours where IsDefault = true];

        caseobj = database.query('Select c.Priority, c.Type, c.SVMXC__SLA_Clock_Paused__c, c.SVMXC__SLA_Clock_Pause_Time__c, c.SVMXC__SLA_Clock_Pause_Restart_Time__c, c.SVMXC__SLA_Clock_Pause_Reason__c, c.SVMXC__SLA_Clock_Pause_Minutes__c, c.SVMXC__SLA_Clock_Pause_Hours__c, c.SVMXC__SLA_Clock_Pause_Days__c, c.SVMXC__SLA_Clock_Extension_Minutes__c, c.SVMXC__Restoration_Internal_By__c, c.SVMXC__Restoration_Customer_By__c, c.SVMXC__Resolution_Internal_By__c, c.SVMXC__Resolution_Customer_By__c, c.SVMXC__Onsite_Response_Internal_By__c, c.SVMXC__Onsite_Response_Customer_By__c, c.SVMXC__Initial_Response_Internal_By__c, c.SVMXC__Initial_Response_Customer_By__c, c.SVMXC__Clock_Paused_Forever__c, c.SVMXC__Actual_Restoration__c, c.SVMXC__Actual_Resolution__c, c.SVMXC__Actual_Onsite_Response__c, c.SVMXC__Actual_Initial_Response__c, c.SVMXC__SLA_Terms__c, c.SVMXC__Component__c, c.Id, c.CaseNumber, c.AccountId, c.SVMXC__SContract_Business_Hour__c From Case c where id = \''+CaseID+'\'');   

        // Get the SLA Terms and applicable SLA Details for the Case
        if(caseobj.SVMXC__SLA_Terms__c != null)
        {
            SLATerm = [Select SVMXC__Business_Hours__r.IsActive,SVMXC__Restoration_Tracked_On__c, SVMXC__Resolution_Tracked_On__c, SVMXC__Onsite_Response_Tracked_On__c, SVMXC__Initial_Response_Tracked_On__c, SVMXC__Business_Hours__c, SVMXC__Effective_Date__c, SVMXC__Description__c, SVMXC__Active__c, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__Service_Level__c Where Id =: caseobj.SVMXC__SLA_Terms__c];
            
            List<SVMXC__SLA_Detail__c> SLADetail1 = new List<SVMXC__SLA_Detail__c>();
            
            string strQuery = 'Select s.SystemModstamp, SVMXC__Business_Hours__r.IsActive,s.SVMXC__Type__c, s.SVMXC__Service_Name__c, s.SVMXC__Service_Details__c, s.SVMXC__Select__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Priority__c, s.SVMXC__Number_Of_Units__c, s.SVMXC__Internal_Goal__c, s.SVMXC__Included_Or_Not__c, s.SVMXC__Frequency__c, s.SVMXC__Customer_Commitment__c, s.SVMXC__Commitment_Type__c, s.SVMXC__Clock_Starts_From__c,s.SVMXC__Business_Hours__c, s.SVMXC__Business_Hours_Source__c, s.SVMXC__Available_Services__c, s.RecordTypeId, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById,  s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById From SVMXC__SLA_Detail__c s Where RecordType.Name = \'Commitment\' AND SVMXC__SLA_Terms__c = \''+caseobj.SVMXC__SLA_Terms__c+'\' AND SVMXC__Priority__c = \'' + caseobj.Priority + '\' AND (SVMXC__Type__c = \'' + caseobj.Type + '\' OR SVMXC__Type__c = \'All\')';
            SLADetail1 = database.query(strQuery);
            
            map<string, SVMXC__SLA_Detail__c> mpSLADtlTypeToSLADtl = new map<string, SVMXC__SLA_Detail__c>();
            
            for(SVMXC__SLA_Detail__c sq: SLADetail1)
            {
                if(!mpSLADtlTypeToSLADtl.containsKey(sq.SVMXC__Commitment_Type__c))
                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                else if(sq.SVMXC__Type__c == caseobj.Type)
                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
            }
            
            SLADetails.addAll(mpSLADtlTypeToSLADtl.values());
        }   
        
        //Calculate the SLA Clock Display based on internal Commitment or Customer Commitment...
        if(svmxSettingList.containsKey('SET001') && svmxSettingList.get('SET001').toUpperCase() == 'INTERNAL COMMITMENT')
        {
            if(caseobj.SVMXC__Initial_Response_Internal_By__c != null)
            {
                InitialResponseBy = caseobj.SVMXC__Initial_Response_Internal_By__c;
            }
            if(caseobj.SVMXC__Onsite_Response_Internal_By__c != null)
            {
                OnsiteResponseBy = caseobj.SVMXC__Onsite_Response_Internal_By__c;
            }
            if(caseobj.SVMXC__Restoration_Internal_By__c != null)
            {
                RestorationBy = caseobj.SVMXC__Restoration_Internal_By__c;
            }
            if(caseobj.SVMXC__Resolution_Internal_By__c != null)
            {
                ResolutionBy = caseobj.SVMXC__Resolution_Internal_By__c;
            }
            if(SLADetails.size() > 0)
            {
                for(Integer i = 0; i < SLADetails.size(); i++)
                {
                    if(SLADetails[i].SVMXC__Internal_Goal__c != null)
                    {
                        if(SLADetails[i].SVMXC__Commitment_Type__c  == 'InitialResponse' )
                        {
                            SLAIRMin = SLADetails[i].SVMXC__Internal_Goal__c;
                        }
                        else if(SLADetails[i].SVMXC__Commitment_Type__c  == 'OnsiteResponse')
                        {
                            SLAORMin = SLADetails[i].SVMXC__Internal_Goal__c;
                        }
                        else if(SLADetails[i].SVMXC__Commitment_Type__c  == 'Restoration')
                        {
                            SLARestorationMin = SLADetails[i].SVMXC__Internal_Goal__c;
                        }
                        else if(SLADetails[i].SVMXC__Commitment_Type__c  == 'Resolution')
                        {
                            SLAResolutionMin = SLADetails[i].SVMXC__Internal_Goal__c;
                        }
                    }   
                }
            }
        }
        else
        {
            if(caseobj.SVMXC__Initial_Response_Customer_By__c != null)
            {
                InitialResponseBy = caseobj.SVMXC__Initial_Response_Customer_By__c;
            }
            if(caseobj.SVMXC__Onsite_Response_Customer_By__c != null)
            {
                OnsiteResponseBy = caseobj.SVMXC__Onsite_Response_Customer_By__c;
            }
            if(caseobj.SVMXC__Restoration_Customer_By__c != null)
            {
                RestorationBy = caseobj.SVMXC__Restoration_Customer_By__c;
            }
            if(caseobj.SVMXC__Resolution_Customer_By__c != null)
            {
                ResolutionBy = caseobj.SVMXC__Resolution_Customer_By__c;
            }
            if(SLADetails.size() > 0)
            {
                for(Integer i=0; i<SLADetails.size();i++)
                {
                    if(SLADetails[i].SVMXC__Customer_Commitment__c != null)
                    {
                        if(SLADetails[i].SVMXC__Commitment_Type__c  == 'InitialResponse' )
                        {
                            SLAIRMin = SLADetails[i].SVMXC__Customer_Commitment__c;
                        }
                        else if(SLADetails[i].SVMXC__Commitment_Type__c  == 'OnsiteResponse')
                        {
                            SLAORMin = SLADetails[i].SVMXC__Customer_Commitment__c;
                        }
                        else if(SLADetails[i].SVMXC__Commitment_Type__c  == 'Restoration')
                        {
                            SLARestorationMin = SLADetails[i].SVMXC__Customer_Commitment__c;
                        }
                        else if(SLADetails[i].SVMXC__Commitment_Type__c  == 'Resolution')
                        {
                            SLAResolutionMin = SLADetails[i].SVMXC__Customer_Commitment__c;
                        }
                    }   
                }
            }
        }

        //Get the BusinessHours ID from Account, IB, and Contract
        if(caseobj.AccountId != null)
        {
            AccountBH = [select id,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from account where id =: caseobj.AccountId ];
        }
        if(caseobj.SVMXC__Component__c != null)
        {
            IBBH = [select id,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from SVMXC__Installed_Product__c where id =: caseobj.SVMXC__Component__c ];
        }

        //Get the BusinessHours for all clocks
        map<String, String> mapCommitSuffix = new map<String, String>();
        mapCommitSuffix.put('InitialResponse', 'IR');
        mapCommitSuffix.put('OnsiteResponse', 'OR');
        mapCommitSuffix.put('Restoration', 'Resto');
        mapCommitSuffix.put('Resolution', 'Resol');
        
        if(SLADetails.size() > 0)
        {
            for(Integer i = 0; i < SLADetails.size(); i++)
            {
                if(mapCommitSuffix.containskey(SLADetails[i].SVMXC__Commitment_Type__c))
                {
                    if(SLADetails[i].SVMXC__Business_Hours_Source__c == 'SLA')
                    {
                        if(SLATerm.SVMXC__Business_Hours__c != null && SLATerm.SVMXC__Business_Hours__r.IsActive == true)
                            BHMap.put('SLA' + mapCommitSuffix.get(SLADetails[i].SVMXC__Commitment_Type__c), SLATerm.SVMXC__Business_Hours__c);
                    }
                    else if(SLADetails[i].SVMXC__Business_Hours_Source__c == 'Custom')
                    {
                        if(SLADetails[i].SVMXC__Business_Hours__c != null && SLADetails[i].SVMXC__Business_Hours__r.IsActive == true)
                            BHMap.put('Custom' + mapCommitSuffix.get(SLADetails[i].SVMXC__Commitment_Type__c), SLADetails[i].SVMXC__Business_Hours__c);
                    }
                    else if(SLADetails[i].SVMXC__Business_Hours_Source__c == 'Account')
                    {
                        if(AccountBH.SVMXC__Access_Hours__c != null && AccountBH.SVMXC__Access_Hours__r.IsActive == true)
                            BHMap.put('Account' + mapCommitSuffix.get(SLADetails[i].SVMXC__Commitment_Type__c), AccountBH.SVMXC__Access_Hours__c);
                    }
                    else if(SLADetails[i].SVMXC__Business_Hours_Source__c == 'Product')
                    {
                        if(IBBH.SVMXC__Access_Hours__c != null && IBBH.SVMXC__Access_Hours__r.IsActive == true)
                            BHMap.put('Product' + mapCommitSuffix.get(SLADetails[i].SVMXC__Commitment_Type__c), IBBH.SVMXC__Access_Hours__c);
                    }
                    else if(SLADetails[i].SVMXC__Business_Hours_Source__c == 'Contract' && caseobj.SVMXC__SContract_Business_Hour__c != null)
                    {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        BusinessHours SCBH = [Select Name,IsActive,Id From BusinessHours where id =:caseobj.SVMXC__SContract_Business_Hour__c and IsActive = true];
                        if(SCBH.id != null)
                        {
                            BHMap.put('Contract' + mapCommitSuffix.get(SLADetails[i].SVMXC__Commitment_Type__c), SCBH.id);
                        }   
                    }
                }
            }
        }

        //Calculate the time to send to java Script timer..
        if(caseobj.SVMXC__Actual_Initial_Response__c == null)
        {
            if(InitialResponseBy != null)
                RemainingTimeIR = formatDate(InitialResponseBy,null);
        }
        else
        {
            if(InitialResponseBy != null)
                RemainingTimeIR = formatDate(InitialResponseBy,caseobj.SVMXC__Actual_Initial_Response__c);
        }   
        if(caseobj.SVMXC__Actual_Onsite_Response__c == null)
        {
            if(OnsiteResponseBy != null)
                RemainingTimeOR = formatDate(OnsiteResponseBy,null);
        }
        else
        {
            if(OnsiteResponseBy != null)
                RemainingTimeOR = formatDate(OnsiteResponseBy,caseobj.SVMXC__Actual_Onsite_Response__c);
        }   
        if(caseobj.SVMXC__Actual_Restoration__c == null)
        {
            if(RestorationBy != null)
                RemainingTimeResto = formatDate(RestorationBy,null);
        }
        else
        {
            if(RestorationBy != null)
                RemainingTimeResto = formatDate(RestorationBy,caseobj.SVMXC__Actual_Restoration__c);
        }   
        if(caseobj.SVMXC__Actual_Resolution__c == null)
        {
            if(ResolutionBy != null)
                RemainingTimeResol = formatDate(ResolutionBy,null);
        }
        else
        {
            if(ResolutionBy != null)
                RemainingTimeResol = formatDate(ResolutionBy,caseobj.SVMXC__Actual_Resolution__c);
        }
        if(RemainingTimeIR != null && RemainingTimeIR.length() > 0 )
        {
            system.debug(LoggingLevel.Warn, 'Remaining time for Initial Response: ' + RemainingTimeIR);
            List<String> TimeLstIR = new List<String>();
            TimeLstIR = RemainingTimeIR.split(':');
            iIRdays = integer.valueof(TimeLstIR[0]);
            iIRhrs = integer.valueof(TimeLstIR[1]);
            iIRmins = integer.valueof(TimeLstIR[2]);
            iIRsecs = integer.valueof(TimeLstIR[3]);
        }
        if(RemainingTimeOR != null && RemainingTimeOR.length() > 0 )
        {
            system.debug(LoggingLevel.Warn, 'Remaining time for Onsite Response: ' + RemainingTimeOR);
            List<String> TimeLstOR = new List<String>();
            TimeLstOR = RemainingTimeOR.split(':');
            iORdays = integer.valueof(TimeLstOR[0]);
            iORhrs = integer.valueof(TimeLstOR[1]);
            iORmins = integer.valueof(TimeLstOR[2]);
            iORsecs = integer.valueof(TimeLstOR[3]);
        }
        if(RemainingTimeResto != null && RemainingTimeResto.length() > 0 )
        {
            system.debug(LoggingLevel.Warn, 'Remaining time for Restoration: ' + RemainingTimeResto);
            List<String> TimeLstResto = new List<String>();
            TimeLstResto = RemainingTimeResto.split(':');
            iAREdays = integer.valueof(TimeLstResto[0]);
            iAREhrs = integer.valueof(TimeLstResto[1]);
            iAREmins = integer.valueof(TimeLstResto[2]);
            iAREsecs = integer.valueof(TimeLstResto[3]);
        }
        if(RemainingTimeResol != null && RemainingTimeResol.length() > 0 )
        {
            system.debug(LoggingLevel.Warn, 'Remaining time for Resolution: ' + RemainingTimeResol);
            List<String> TimeLstResol = new List<String>();
            TimeLstResol = RemainingTimeResol.split(':');
            iAROdays = integer.valueof(TimeLstResol[0]);
            iAROhrs = integer.valueof(TimeLstResol[1]);
            iAROmins = integer.valueof(TimeLstResol[2]);
            iAROsecs = integer.valueof(TimeLstResol[3]);
        }
    }

    public String formatDate(Datetime CommitmentTime, Datetime ActualResponse)
    {
        String calculatedTime = '';
        Long lngClkPauseTime = 0;
        Long SLAClkExtMin = 0;
        Long LCommitmentTime = 0;
        Long LActualResponse = 0;
        Long Lnow = 0;
        Long Ldiff = 0;
        if(ActualResponse == null)
        {
            if(caseobj.SVMXC__SLA_Clock_Paused__c == true)
            {
                LCommitmentTime = CommitmentTime.getTime();
                if(caseobj.SVMXC__SLA_Clock_Pause_Time__c != null)
                    lngClkPauseTime = caseobj.SVMXC__SLA_Clock_Pause_Time__c.gettime();
                if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
                {   
                    Ldiff = LCommitmentTime - (lngClkPauseTime + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c.longValue());
                }
                else
                {
                    Ldiff = LCommitmentTime - lngClkPauseTime;
                }   
                if(Ldiff > 0)
                {
                    calculatedTime = DatCal.getCountDown(Ldiff);
                }
                else
                {
                    calculatedTime = '00:00:00:00';
                }   
            }
            else
            {
                LCommitmentTime = CommitmentTime.getTime();
                Lnow = System.now().gettime();
                if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
                {   
                    Ldiff = LCommitmentTime - Lnow + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c.longValue();
                }
                else
                {
                    Ldiff = LCommitmentTime - Lnow;
                }   
                if(Ldiff > 0)
                {
                    calculatedTime = DatCal.getCountDown(Ldiff);
                }
                else
                {
                    calculatedTime = '00:00:00:00';
                }   
            }   
        }
        else
        {
            LCommitmentTime = CommitmentTime.getTime();
            LActualResponse = ActualResponse.getTime();
            if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
            {   
                Ldiff =  LCommitmentTime - LActualResponse + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c.longValue();
            }
            else
            {
                Ldiff =  LCommitmentTime - LActualResponse;
            }
            if(Ldiff > 0)
            {
                calculatedTime = DatCal.getCountDown(Ldiff);
            }
            else
            {
                calculatedTime = '00:00:00:00';
            }   
        }
        return calculatedTime;
    }

    // Not used
    public String SLAClockPausedSetting = '';
    public String getSLAClockPausedSetting()
    { 
        if(svmxSettingList.containsKey('SET002'))
        {
            SLAClockPausedSetting = svmxSettingList.get('SET002').toUpperCase();//'FALSE';//
        }
        return SLAClockPausedSetting;
    } 
    public void setSLAClockPausedSetting(String s) {s = SLAClockPausedSetting; }
    
    // Not used
    public String PauseRestartSLAClock = '';
    public String getPauseRestartSLAClock()
    {
         if(svmxSettingList.containsKey('SET002'))
         {
            PauseRestartSLAClock = svmxSettingList.get('SET002').toUpperCase();
         }
         system.debug('PauseRestartSLAClock'+PauseRestartSLAClock);
         return PauseRestartSLAClock;
    } 
    public void setPauseRestartSLAClock(String s) {s = PauseRestartSLAClock;} 
    
    // Not used
    public integer getThresholdTime()
    {
        if(svmxSettingList.containsKey('SET004'))
        {
            ThresholdTime = integer.valueOf(svmxSettingList.get('SET004'));
        }   
        return ThresholdTime;
    }
    public void setThresholdTime(integer i){ThresholdTime = i;}
    
    public Case getcaseobj(){return caseobj;}
    public void setcaseobj(Case c){caseobj = c;}
    public integer getiIRdays(){return this.iIRdays;}
    public void setiIRdays(Integer i){this.iIRdays = i;}
    public integer getiIRhrs(){return this.iIRhrs;}
    public void setiIRhrs(Integer i){this.iIRhrs = i;}
    public integer getiIRmins(){return this.iIRmins;}
    public void setiIRmins(Integer i){this.iIRmins = i;}
    public integer getiIRsecs(){return this.iIRsecs;}
    public void setiIRsecs(Integer i){this.iIRsecs = i;}
    
    public integer getiORdays(){return this.iORdays;}
    public void setiORdays(Integer i){this.iORdays = i;}
    public integer getiORhrs(){return this.iORhrs;}
    public void setiORhrs(Integer i){this.iORhrs = i;}
    public integer getiORmins(){return this.iORmins;}
    public void setiORmins(Integer i){this.iORmins = i;}
    public integer getiORsecs(){return this.iORsecs;}
    public void setiORsecs(Integer i){this.iORsecs = i;}
    
    public integer getiAREdays(){return this.iAREdays;}
    public void setiAREdays(Integer i){this.iAREdays = i;}
    public integer getiAREhrs(){return this.iAREhrs;}
    public void setiAREhrs(Integer i){this.iAREhrs = i;}
    public integer getiAREmins(){return this.iAREmins;}
    public void setiAREmins(Integer i){this.iAREmins = i;}
    public integer getiAREsecs(){return this.iAREsecs;}
    public void setiAREsecs(Integer i){this.iAREsecs = i;}
    
    public integer getiAROdays(){return this.iAROdays;}
    public void setiAROdays(Integer i){this.iAROdays = i;}
    public integer getiAROhrs(){return this.iAROhrs;}
    public void setiAROhrs(Integer i){this.iAROhrs = i;}
    public integer getiAROmins(){return this.iAROmins;}
    public void setiAROmins(Integer i){this.iAROmins = i;}
    public integer getiAROsecs(){return this.iAROsecs;}
    public void setiAROsecs(Integer i){this.iAROsecs = i;}
    
    public double getSLAIRMin()
    {
        if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
        {
            SLAIRMin = SLAIRMin + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c;
        }
        return SLAIRMin;
    }
    public void setSLAIRMin(double i) {SLAIRMin = i;}
    
    public double getSLAORMin()
    {
        if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
        {
            SLAORMin = SLAORMin + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c;
        }
        return SLAORMin;
    }
    public void setSLAORMin(double i) {SLAORMin = i;}
    
    public double getSLARestorationMin()
    {
        if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
        {
            SLARestorationMin = SLARestorationMin + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c;
        }
        return SLARestorationMin;
    }
    public void setSLARestorationMin(double i) {SLARestorationMin = i;}
    
    public double getSLAResolutionMin()
    {
        if(caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
        {
            SLAResolutionMin = SLAResolutionMin + caseobj.SVMXC__SLA_Clock_Extension_Minutes__c;
        }
        return SLAResolutionMin;
    }
    public void setSLAResolutionMin(double i) {SLAResolutionMin = i;}
    
    public Boolean getSLAClockPause(){return caseobj.SVMXC__SLA_Clock_Paused__c;}
    public boolean getPopupMsg() {return PopupMsg;}
    public void setSLAClockPause(Boolean s){caseobj.SVMXC__SLA_Clock_Paused__c = s;}
    public Boolean getdisplayPopUp(){return displayPopUp;}
    public void setdisplayPopUp(Boolean b){}
    public Boolean getdisplaystartPopUp() {return displaystartPopUp;}
    //public void setdisplaystartPopUp(Boolean b) {}
    public List<SelectOption> getReasonOpt()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('',getTAG006()));
        Map<String,String> MapOfPiclListvalues = new Map<String,String>();
        MapOfPiclListvalues = SVMX_getPickListValues('SVMXC__SLA_Clock_Pause_Reason__c');
        if(MapOfPiclListvalues.size() > 0)
        {
            for(String s : MapOfPiclListvalues.keyset())
            {
                Options.add(new selectOption(s,MapOfPiclListvalues.get(s)));
            }
        }
        return options;
    }
    public String getForHowLong(){return ForHowLong;}
    public void setForHowLong(String s){ForHowLong = s;}
    public List<SelectOption> getForHowLongOpt()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('a',getTAG007()));
        return options;
    }
    //Validation...
    public Boolean SVMX_ValidPause = true;
    public Boolean SVMX_ValidPause()
    {
        SVMX_ValidPause = true;
        if(Caseobj.SVMXC__SLA_Clock_Pause_Reason__c == null)
        {
            SVMX_ValidPause = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG012()));
        }
        if(ForHowLong == 'b')
        {
            if(Caseobj.SVMXC__SLA_Clock_Pause_Days__c == null  && Caseobj.SVMXC__SLA_Clock_Pause_Hours__c == null && Caseobj.SVMXC__SLA_Clock_Pause_Minutes__c == null)
            {
                SVMX_ValidPause = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG013()));
            }
        }
        return SVMX_ValidPause;
    }
    //Button Methods...
    public pagereference SVMX_Start()
    {
        displaystartPopUp = true;
        return null;
    }
    public pagereference SVMX_Pause()
    {
        //system.debug('SVMX_Pause: ' + displayPopUp);
        displayPopUp = true;
        return null;
    }
    public pagereference SVMX_PauseNow()
    {
        PopupMsg = false;
        if(SVMX_ValidPause() == true)
        {
            displayPopUp = false;
            Caseobj.SVMXC__SLA_Clock_Pause_Time__c = system.now();
            Caseobj.SVMXC__SLA_Clock_Pause_Restart_Time__c = null;
            if(ForHowLong == 'b')
            {
                Caseobj.SVMXC__SLA_Clock_Paused__c = true;
                Caseobj.SVMXC__Clock_Paused_Forever__c = false;
            }
            else if(ForHowLong == 'a')
            {
                Caseobj.SVMXC__SLA_Clock_Paused__c = true;
                Caseobj.SVMXC__Clock_Paused_Forever__c = true;
            }
            //upsert Caseobj;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Caseobj, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert Caseobj;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
            getcaseData();
            Task taskobj = new Task();
            taskobj.WhatId = Caseobj.id;
            taskobj.Subject = 'SLA Clock Stop';
            taskobj.Type = 'Other';
            taskobj.Status = 'Completed';
            taskobj.Priority = 'Normal';
            taskobj.OwnerId = Userinfo.getUserId();
            taskobj.IsReminderSet = false;
            taskobj.Description = getTAG014() + ' ' + system.now() + ' ' + getTAG015() + ' ' + Userinfo.getFirstName() + Userinfo.getLastName() + ' ' + getTAG016() + ' ' + Caseobj.SVMXC__SLA_Clock_Pause_Reason__c + ' ' + CaseReason; 
            //insert taskobj;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( taskobj, COMM_SecurityUtils.Access.Createable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                insert taskobj;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
        }
        else
        {
            PopupMsg = true;
        }   
        return null;
    }
    public String getcaseData()
    {
        CaseReason += getTAG002() + ':';
        if(ForHowLong == 'a')
        {
            CaseReason += ' ' + getTAG007();
        }
        else if(ForHowLong == 'b')
        {
            
            if(Caseobj.SVMXC__SLA_Clock_Pause_Days__c != null)
                CaseReason +=  ' '+Caseobj.SVMXC__SLA_Clock_Pause_Days__c + ' ' + getTAG009();
            if(Caseobj.SVMXC__SLA_Clock_Pause_Hours__c != null)
                CaseReason += ' '+Caseobj.SVMXC__SLA_Clock_Pause_Hours__c + ' ' + getTAG010();
            if(Caseobj.SVMXC__SLA_Clock_Pause_Minutes__c != null)
                CaseReason += ' '+Caseobj.SVMXC__SLA_Clock_Pause_Minutes__c + ' ' + getTAG011();        
        }
        if(caseobj.SVMXC__Initial_Response_Customer_By__c != null)
        {
            CaseReason += ' ' + getTAG018() + ' ' + Caseobj.SVMXC__Initial_Response_Customer_By__c;
        }
        if(caseobj.SVMXC__Onsite_Response_Customer_By__c != null)
        {
            CaseReason += ' ' + getTAG019() + ' ' + Caseobj.SVMXC__Onsite_Response_Customer_By__c;
        }
        if(caseobj.SVMXC__Restoration_Customer_By__c != null)
        {
            CaseReason += ' ' + getTAG020() + ' ' + Caseobj.SVMXC__Restoration_Customer_By__c;
        }
        if(caseobj.SVMXC__Resolution_Customer_By__c != null)
        {
            CaseReason += ' ' + getTAG021() + ' ' + Caseobj.SVMXC__Resolution_Customer_By__c;
        }   
        return CaseReason;
    }
    public string getVFMessage()
    {
        getElapsedMinutes();
        VFMessage  = '';
        VFMessage += String.valueof(ElapsedMinutes) + ' ' + getTAG025() + ' ' + Caseobj.CaseNumber + '.';
        VFMessage += ' ' + getTAG026() + ' ' + ElapsedMinutes + ' ' + getTAG039();
        return VFMessage;
    } 
    public Long getElapsedMinutes()
    {
        ElapsedMinutes = 0;
        Long Ldiff = 0;
        Long L1 = 0;
        Long L2 = 0;
        if(Caseobj.SVMXC__SLA_Clock_Pause_Time__c != null)
        {
            L1 = Caseobj.SVMXC__SLA_Clock_Pause_Time__c.gettime(); 
            L2 = system.now().getTime();
            if(L1 > 0 && L2 > 0 && L2 >= L1)
            {
                Ldiff = L2 - L1;
            }   
            if(Ldiff > 0)
            {
                ElapsedMinutes = Ldiff/60000;
            }
        }
        system.debug(LoggingLevel.Warn, 'Elapsed Minutes: ' + ElapsedMinutes);
        return ElapsedMinutes;
    } 
    public pagereference SVMX_Cancel()
    {
        displayPopUp = false;
        return null;
    }
    public pagereference SVMX_CancelStartPopup()
    {
        displaystartPopUp = false;
        return null;
    }
    public pagereference SVMX_Yes()
    {
        Caseobj.SVMXC__Clock_Paused_Forever__c = false;
        Caseobj.SVMXC__SLA_Clock_Paused__c = false;
        Caseobj.SVMXC__SLA_Clock_Pause_Reason__c = null;
        Caseobj.SVMXC__SLA_Clock_Pause_Restart_Time__c = system.now();
        Caseobj.SVMXC__SLA_Clock_Pause_Days__c = null;
        Caseobj.SVMXC__SLA_Clock_Pause_Hours__c = null;
        Caseobj.SVMXC__SLA_Clock_Pause_Minutes__c = null;
        
        //Boolean isCustomerCommit = true;
        //if(svmxSettingList.containsKey('SET001') && svmxSettingList.get('SET001').toUpperCase() == 'INTERNAL COMMITMENT')
            //isCustomerCommit = false;
        
        String businessHoursId;
        String strCommitType;
        String strInternalFldName;
        String strCustomerFldName;
        Long lngRemainingTime;

        // Calculate all the the commitment fields based on applicable BH for the clocks which have not yet been stopped
        if(ElapsedMinutes > 0 && SLADetails.size() > 0)
        {
            for(Integer i = 0; i < SLADetails.size(); i++)
            {
                // Set the datetime fields applicable for this SLA Detail record
                if(SLADetails[i].SVMXC__Commitment_Type__c == 'InitialResponse')
                {
                    if(Caseobj.SVMXC__Actual_Initial_Response__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Initial_Response_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Initial_Response_Customer_By__c';
                    strCommitType = 'IR';
                }
                else if(SLADetails[i].SVMXC__Commitment_Type__c == 'OnsiteResponse')
                {
                    if(Caseobj.SVMXC__Actual_Onsite_Response__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Onsite_Response_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Onsite_Response_Customer_By__c';
                    strCommitType = 'OR';
                }
                else if(SLADetails[i].SVMXC__Commitment_Type__c == 'Restoration')
                {
                    if(Caseobj.SVMXC__Actual_Restoration__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Restoration_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Restoration_Customer_By__c';
                    strCommitType = 'Resto';
                }
                else if(SLADetails[i].SVMXC__Commitment_Type__c == 'Resolution')
                {
                    if(Caseobj.SVMXC__Actual_Resolution__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Resolution_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Resolution_Customer_By__c';
                    strCommitType = 'Resol';
                }

                // Find the Business Hour applicable for this SLA Detail record
                businessHoursId = BHMap.get(SLADetails[i].SVMXC__Business_Hours_Source__c + strCommitType);
                if(businessHoursId == null)
                    businessHoursId = bh.id;

                // If the clock had time remaining at the last pause time, recalculate the new remaining time
                // Do it for both internal and customer commit values so that they are in sync
                // This way, when the setting which determines whether to consider internal or customer is changed,
                // the count down will be correct
                if((datetime)Caseobj.get(strCustomerFldName) != null)
                {
                    lngRemainingTime = BusinessHours.diff(businessHoursId, Caseobj.SVMXC__SLA_Clock_Pause_Time__c, (datetime)Caseobj.get(strCustomerFldName));
                    if(lngRemainingTime > 0)
                    {
                        Caseobj.put(strCustomerFldName, BusinessHours.addGmt(businessHoursId, Caseobj.SVMXC__SLA_Clock_Pause_Restart_Time__c, lngRemainingTime));
                    }
                }
                if((datetime)Caseobj.get(strInternalFldName) != null)
                {
                    lngRemainingTime = BusinessHours.diff(businessHoursId, Caseobj.SVMXC__SLA_Clock_Pause_Time__c, (datetime)Caseobj.get(strInternalFldName));
                    if(lngRemainingTime > 0)
                    {
                        Caseobj.put(strInternalFldName, BusinessHours.addGmt(businessHoursId, Caseobj.SVMXC__SLA_Clock_Pause_Restart_Time__c, lngRemainingTime));
                    }
                }
            }
            //Populating extension minutes in the fields and incrementing it with the subsequent pause and resume(If user says YES)
            Long ElapsedMinutes = getElapsedMinutes();
            if(Caseobj.SVMXC__SLA_Clock_Extension_Minutes__c != null && Caseobj.SVMXC__SLA_Clock_Extension_Minutes__c > 0){
                Caseobj.SVMXC__SLA_Clock_Extension_Minutes__c += ElapsedMinutes;
            }
            else{
                Caseobj.SVMXC__SLA_Clock_Extension_Minutes__c = ElapsedMinutes;
            }
        }
        //upsert Caseobj;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Caseobj, COMM_SecurityUtils.Access.Upsertable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            upsert Caseobj;
        } else {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
            return null;
        }
        BuildDescForTask();
        Task Taskobj = new Task();
        Taskobj.WhatId = Caseobj.id;
        Taskobj.Type = 'Other';
        Taskobj.Subject = 'SLA Clock Start';
        Taskobj.Status = 'Completed';
        Taskobj.Priority = 'Normal';
        Taskobj.OwnerId = Userinfo.getUserId();
        Taskobj.IsReminderSet = false;
        Taskobj.Description = BuildDescForTask;
        //insert Taskobj;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Taskobj, COMM_SecurityUtils.Access.Createable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert Taskobj;
        } else {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
            return null;
        }
        displaystartPopUp = false;
        
        String strURL = '/apex/SLAT_SLAClockOnCase?id='+Caseobj.id;
        COMM_SVMXC_Utils2 objCls = new COMM_SVMXC_Utils2();
        strURL = objCls.GetCommunityPrefix(strURL);
        pagereference newpage = new pagereference(strURL);
        newpage.setredirect(true);
        return newpage;
    }
    public String BuildDescForTask = '';
    public String BuildDescForTask()
    {
        BuildDescForTask += getTAG027() + ' ' + system.now() + ' ' + getTAG028() + ' ' + Userinfo.getFirstName() + Userinfo.getLastName() + ' ' + getTAG029() + ' ' + ElapsedMinutes;
        if(caseobj.SVMXC__Initial_Response_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG018() + ' ' + Caseobj.SVMXC__Initial_Response_Customer_By__c;
        }
        if(caseobj.SVMXC__Onsite_Response_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG019() + ' ' + Caseobj.SVMXC__Onsite_Response_Customer_By__c;
        }
        if(caseobj.SVMXC__Restoration_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG020() + ' ' + Caseobj.SVMXC__Restoration_Customer_By__c;
        }
        if(caseobj.SVMXC__Resolution_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG021() + ' ' + Caseobj.SVMXC__Resolution_Customer_By__c;
        } 
        return BuildDescForTask;
    }
    public pagereference SVMX_No()
    {
        ElapsedMinutes = 0;
        return SVMX_Yes();
    }
    //Tags
    public String getTAG001(){ return system.label.SLAT002_TAG001;}//Reason
    public String getTAG002(){ return system.label.SLAT002_TAG002;}//For How Long
    public String getTAG003(){ return system.label.SLAT002_TAG003;}//Delete
    public String getTAG004(){ return system.label.SLAT002_TAG004;}//Back To Setup Home
    public String getTAG005(){ return system.label.SLAT002_TAG005;}//Processing...
    public String getTAG006(){ return system.label.SLAT002_TAG006;}//--None--
    public String getTAG007(){ return system.label.SLAT002_TAG007;}//Indefinitely
    public String getTAG008(){ return system.label.SLAT002_TAG008;}//I Will Choose my duration
    public String getTAG009(){ return system.label.SLAT002_TAG009;}//Days
    public String getTAG010(){ return system.label.SLAT002_TAG010;}//Hours
    public String getTAG011(){ return system.label.SLAT002_TAG011;}//Mins
    public String getTAG012(){ return system.label.SLAT002_TAG012;}// Please select a reason
    public String getTAG013(){ return system.label.SLAT002_TAG013;}// You must enter at least one of Days, Hours or Minutes
    public String getTAG014(){ return system.label.SLAT002_TAG014;}//SLA Clock Paused at
    public String getTAG015(){ return system.label.SLAT002_TAG015;}//SLA Clock Paused by
    public String getTAG016(){ return system.label.SLAT002_TAG016;}//Pause Reason:
    public String getTAG017(){ return system.label.SLAT002_TAG017;}//For How Long:
    public String getTAG018(){ return system.label.SLAT002_TAG018;}//Initial Response Required by: 
    public String getTAG019(){ return system.label.SLAT002_TAG019;}//Onsite Response Required by:
    public String getTAG020(){ return system.label.SLAT002_TAG020;}//Restoration Required by:
    public String getTAG021(){ return system.label.SLAT002_TAG021;}//Resolution Required by:
    public String getTAG022(){ return system.label.SLAT002_TAG022;}//Yes
    public String getTAG023(){ return system.label.SLAT002_TAG023;}//No
    public String getTAG024(){ return system.label.SLAT002_TAG024;}//Cancel
    public String getTAG025(){ return system.label.SLAT002_TAG025;}//minutes have elapsed since the SLA clock was paused for this
    public String getTAG026(){ return system.label.SLAT002_TAG026;}//Do you want to extend the SLA commitment times by
    public String getTAG027(){ return system.label.SLAT002_TAG027;}//SLA Clock Restarted at
    public String getTAG028(){ return system.label.SLAT002_TAG028;}//SLA Clock Restarted by
    public String getTAG029(){ return system.label.SLAT002_TAG029;}//Time elapsed since last stop
    public String getTAG030(){ return system.label.SLAT002_TAG030;}//Initial Response
    public String getTAG031(){ return system.label.SLAT002_TAG031;}//Onsite Response
    public String getTAG032(){ return system.label.SLAT002_TAG032;}//Restoration
    public String getTAG033(){ return system.label.SLAT002_TAG033;}//Resolution
    public String getTAG034(){ return system.label.SLAT002_TAG034;}//Pause
    public String getTAG035(){ return system.label.SLAT002_TAG035;}//Resume
    public String getTAG036(){ return system.label.SLAT002_TAG036;}//Invalid Time
    public String getTAG037(){ return system.label.SLAT002_TAG037;}//Enter Time
    public String getTAG038(){ return system.label.SLAT002_TAG038;}//Select Reason
    public String getTAG039(){ return system.label.SLAT002_TAG039;}//minutes?
    
    public map<String,String> SVMX_getPickListValues(String FieldName)
    {
        Map<String,String> MapOfPiclListvalues = new Map<String,String>();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = Schema.SObjectType.Case.fields.getMap(); 
        for(Schema.SObjectField fld:objfieldMap.values())
        {
            Schema.DescribeFieldResult FSO = fld.getDescribe();
            if(FSO != null && FSO.getname() == FieldName)
            {
                if(FSO.getType() == Schema.DisplayType.PickList)
                {
                    List<Schema.PicklistEntry> P = FSO.getPicklistValues(); // returing picklist values
                    for(integer v=0;v<p.size();v++)
                    {
                        MapOfPiclListvalues.put(p[v].getLabel(),p[v].getValue()); 
                    }
                }
            }   
        }
        return MapOfPiclListvalues;
    }
}