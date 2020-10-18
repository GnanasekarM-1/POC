public with Sharing class SLA_Clock_WO_Controller { 
        
    @AuraEnabled
    public static SLADetil getSLADetails(Id recordId){
        Map<String,String> BHMap = new Map<String,String>();
        Datetime InitialResponseBy, OnsiteResponseBy, RestorationBy, ResolutionBy;
        SLADetil wrapperInstance = new SLADetil();
        SVMXC.COMM_Utils_DateCalculation  DatCal = new SVMXC.COMM_Utils_DateCalculation();
        List<SVMXC__SLA_Detail__c> SLADetails = new List<SVMXC__SLA_Detail__c>();
        SVMXC__Service_Level__c  SLATerm = new SVMXC__Service_Level__c ();
        Account AccountBH = new Account();
        SVMXC__Installed_Product__c IBBH = new SVMXC__Installed_Product__c();
        Set<String> listClockStartsFrom = new Set<String>(); //list of SVMXC__Clock_Starts_From__c fields for all commitment types for an SLA
        map<string, SVMXC__SLA_Detail__c> mpSLADtlTypeToSLADtl = new map<string, SVMXC__SLA_Detail__c>();
        Case caseobj = new Case();
        String RemainingTimeIR = '';
        String RemainingTimeOR = '';
        String RemainingTimeResto = '';
        String RemainingTimeResol = '';
        
        String WOID = recordId;
        BusinessHours bh = [Select id from BusinessHours where IsDefault = true];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        List<String> queryFields = new List<String> {'SVMXC__Order_Type__c','SVMXC__Priority__c','SVMXC__SLA_Terms__c','SVMXC__SLA_Clock_Paused__c','SVMXC__SLA_Clock_Pause_Time__c','SVMXC__SLA_Clock_Pause_Restart_Time__c','SVMXC__SLA_Clock_Pause_Reason__c','SVMXC__SLA_Clock_Pause_Minutes__c','SVMXC__SLA_Clock_Pause_Hours__c','SVMXC__SLA_Clock_Pause_Days__c','SVMXC__SLA_Clock_Extension_Minutes__c','SVMXC__Restoration_Internal_By__c','SVMXC__Restoration_Customer_By__c','SVMXC__Resolution_Internal_By__c','SVMXC__Resolution_Customer_By__c','SVMXC__Onsite_Response_Internal_By__c','SVMXC__Onsite_Response_Customer_By__c','SVMXC__Initial_Response_Internal_By__c','SVMXC__Initial_Response_Customer_By__c','SVMXC__Component__c','SVMXC__Company__c','SVMXC__Clock_Paused_Forever__c','SVMXC__Case__c','SVMXC__Actual_Restoration__c','SVMXC__Actual_Resolution__c','SVMXC__Actual_Onsite_Response__c','SVMXC__Actual_Initial_Response__c','Name','Id','SVMXC__SM_SLA_Initial_Response__c','SVMXC__SM_SLA_Onsite_Response__c','SVMXC__SM_SLA_Resolution__c','SVMXC__SM_SLA_Restoration__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        SVMXC__Service_Order__c WOObj = database.query('Select  SVMXC__Order_Type__c,  SVMXC__Priority__c,  SVMXC__SLA_Terms__c,  SVMXC__SLA_Clock_Paused__c,  SVMXC__SLA_Clock_Pause_Time__c,  SVMXC__SLA_Clock_Pause_Restart_Time__c,  SVMXC__SLA_Clock_Pause_Reason__c,  SVMXC__SLA_Clock_Pause_Minutes__c,  SVMXC__SLA_Clock_Pause_Hours__c,  SVMXC__SLA_Clock_Pause_Days__c,  SVMXC__SLA_Clock_Extension_Minutes__c,  SVMXC__Restoration_Internal_By__c,  SVMXC__Restoration_Customer_By__c,  SVMXC__Resolution_Internal_By__c,  SVMXC__Resolution_Customer_By__c,  SVMXC__Onsite_Response_Internal_By__c,  SVMXC__Onsite_Response_Customer_By__c,  SVMXC__Initial_Response_Internal_By__c,  SVMXC__Initial_Response_Customer_By__c,  SVMXC__Component__c,  SVMXC__Company__c,  SVMXC__Clock_Paused_Forever__c,  SVMXC__Case__c,  SVMXC__Actual_Restoration__c,  SVMXC__Actual_Resolution__c,  SVMXC__Actual_Onsite_Response__c,  SVMXC__Actual_Initial_Response__c,  Name,  Id,SVMXC__SM_SLA_Initial_Response__c,SVMXC__SM_SLA_Onsite_Response__c,SVMXC__SM_SLA_Resolution__c,SVMXC__SM_SLA_Restoration__c From SVMXC__Service_Order__c where id = \''+WOID+'\'');
        
        // Get the SLA Terms and applicable SLA Details for the Work Order
        
        if(WOObj.SVMXC__SLA_Terms__c != null)
        {
            SLATerm = [Select SVMXC__Business_Hours__r.IsActive,SVMXC__Restoration_Tracked_On__c, SVMXC__Resolution_Tracked_On__c, SVMXC__Onsite_Response_Tracked_On__c, SVMXC__Initial_Response_Tracked_On__c, SVMXC__Business_Hours__c, Id From SVMXC__Service_Level__c Where Id =: WOObj.SVMXC__SLA_Terms__c];
            
            List<SVMXC__SLA_Detail__c> SLADetail1 = new List<SVMXC__SLA_Detail__c>();
            
            string strQuery = 'Select SVMXC__Business_Hours__r.IsActive, s.SVMXC__Type__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Priority__c, s.SVMXC__Internal_Goal__c, s.SVMXC__Customer_Commitment__c, s.SVMXC__Commitment_Type__c, s.SVMXC__Business_Hours__c, s.SVMXC__Business_Hours_Source__c, s.Id,s.SVMXC__Clock_Starts_From__c From SVMXC__SLA_Detail__c s Where SVMXC__SLA_Terms__c = \''+WOObj.SVMXC__SLA_Terms__c+'\' AND SVMXC__Priority__c = \'' + WOObj.SVMXC__Priority__c + '\' AND (SVMXC__Type__c = \'' + WOObj.SVMXC__Order_Type__c + '\' OR SVMXC__Type__c = \'All\')';
            SLADetail1 = database.Query(strQuery);
            
            for(SVMXC__SLA_Detail__c sq: SLADetail1)
            {
                if(!mpSLADtlTypeToSLADtl.containsKey(sq.SVMXC__Commitment_Type__c))
                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                else if(sq.SVMXC__Type__c == WOObj.SVMXC__Order_Type__c)
                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                
                listClockStartsFrom.add(sq.SVMXC__Clock_Starts_From__c);
            }
            
            SLADetails.addAll(mpSLADtlTypeToSLADtl.values());
        }
        
        //Calculate the SLA Clock Display based on internal Commitment or Customer Commitment...
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('SLAT003');
        
        if(svmxSettingList.containsKey('SET001') && svmxSettingList.get('SET001').toUpperCase() == 'INTERNAL COMMITMENT')
        {
            if(WOObj.SVMXC__Initial_Response_Internal_By__c != null)
            {
                InitialResponseBy = WOObj.SVMXC__Initial_Response_Internal_By__c;
            }
            if(WOObj.SVMXC__Onsite_Response_Internal_By__c != null)
            {
                OnsiteResponseBy = WOObj.SVMXC__Onsite_Response_Internal_By__c;
            }
            if(WOObj.SVMXC__Restoration_Internal_By__c != null)
            {
                RestorationBy = WOObj.SVMXC__Restoration_Internal_By__c;
            }
            if(WOObj.SVMXC__Resolution_Internal_By__c != null)
            {
                ResolutionBy = WOObj.SVMXC__Resolution_Internal_By__c;
            }            
        }
        else
        {
            if(WOObj.SVMXC__Initial_Response_Customer_By__c != null)
            {
                InitialResponseBy = WOObj.SVMXC__Initial_Response_Customer_By__c;
            }
            if(WOObj.SVMXC__Onsite_Response_Customer_By__c != null)
            {
                OnsiteResponseBy = WOObj.SVMXC__Onsite_Response_Customer_By__c;
            }
            if(WOObj.SVMXC__Restoration_Customer_By__c != null)
            {
                RestorationBy = WOObj.SVMXC__Restoration_Customer_By__c;
            }
            if(WOObj.SVMXC__Resolution_Customer_By__c != null)
            {
                ResolutionBy = WOObj.SVMXC__Resolution_Customer_By__c;
            }            
        }
        
        wrapperInstance.SLAIRMin = WOObj.SVMXC__SM_SLA_Initial_Response__c;
        wrapperInstance.SLAORMin = WOObj.SVMXC__SM_SLA_Onsite_Response__c;
        wrapperInstance.SLAResolutionMin = WOObj.SVMXC__SM_SLA_Resolution__c;
        wrapperInstance.SLARestorationMin = WOObj.SVMXC__SM_SLA_Restoration__c;
        
        List<String> queryFields1 = new List<String> {'SVMXC__Access_Hours__c','SVMXC__Access_Hours__r.IsActive'};
        //Get the BusinessHours ID from Account, IB, and Contract
        if(WOObj.SVMXC__Company__c != null)
        {
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'account', queryFields1, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }           
            AccountBH = [select id,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from account where id =: WOObj.SVMXC__Company__c ];
        }
        if(WOObj.SVMXC__Component__c != null)
        {
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields1, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            IBBH = [select id,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from SVMXC__Installed_Product__c where id =: WOObj.SVMXC__Component__c ];
        }
        if(WOObj.SVMXC__Case__c != null)
        {
            List<String> queryFields2 = new List<String> {'SVMXC__SContract_Business_Hour__c'};
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Case', queryFields2, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            caseobj = [select c.SVMXC__SContract_Business_Hour__c, c.Id From Case c where id =: WOObj.SVMXC__Case__c];
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
        
        //Query SVMXC__Clock_Starts_From__c from Work Order to calculate initial commitment time for each clock.
        String fieldList = 'Id';
        List<String> queryFields3 = new List<String>();
        for(String s : listClockStartsFrom){
            fieldList += ','+s;
            queryFields3.add(s);
        }
        
        if(queryFields3.size()>0 && !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order__c', queryFields3, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        String WOQuery = 'Select '+fieldList+' From SVMXC__Service_Order__c where Id = :WOID';
        SVMXC__Service_Order__c WOObj1 = database.query(WOQuery);
        
        
        //Calculate the time to send to java Script timer..
        if(WOObj.SVMXC__Actual_Initial_Response__c == null)
        {
            if(InitialResponseBy != null)
                RemainingTimeIR = formatDate(WOObj,InitialResponseBy,null);
        }
        else
        {
            if(InitialResponseBy != null)
                RemainingTimeIR = formatDate(WOObj,InitialResponseBy,WOObj.SVMXC__Actual_Initial_Response__c);
        }   
        if(WOObj.SVMXC__Actual_Onsite_Response__c == null)
        {
            if(OnsiteResponseBy != null)
                RemainingTimeOR = formatDate(WOObj,OnsiteResponseBy,null);
        }
        else
        {
            if(OnsiteResponseBy != null)
                RemainingTimeOR = formatDate(WOObj,OnsiteResponseBy,WOObj.SVMXC__Actual_Onsite_Response__c);
        }   
        if(WOObj.SVMXC__Actual_Restoration__c == null)
        {
            if(RestorationBy != null)
                RemainingTimeResto = formatDate(WOObj,RestorationBy,null);
        }
        else
        {
            if(RestorationBy != null)
                RemainingTimeResto = formatDate(WOObj,RestorationBy,WOObj.SVMXC__Actual_Restoration__c);
        }   
        if(WOObj.SVMXC__Actual_Resolution__c == null)
        {
            if(ResolutionBy != null)
                RemainingTimeResol = formatDate(WOObj,ResolutionBy,null);
        }
        else
        {
            if(ResolutionBy != null)
                RemainingTimeResol = formatDate(WOObj,ResolutionBy,WOObj.SVMXC__Actual_Resolution__c);
        }
        if(RemainingTimeIR != null && RemainingTimeIR.length() > 0 )
        {
            if(RemainingTimeIR.startsWith('00:00:00') || RemainingTimeIR.startsWith('0:0:0')){
                wrapperInstance.isOverTimeIR = true;    
                //Calculate Overdue Time
                Long milliseconds = datetime.now().getTime() - InitialResponseBy.getTime();
                String diffIR = DatCal.getCountDown(milliseconds);
                system.debug('diffIR =='+diffIR);              
                if(diffIR.split(':')[0] == '0' || diffIR.split(':')[0] == '00'){
                    if(diffIR.split(':')[1] == '00' && diffIR.split(':')[2] == '00'){
                        wrapperInstance.overdueTimeIR = '+0:0';                     
                    }else{
                        wrapperInstance.overdueTimeIR = '+'+diffIR.split(':')[1] +':' +diffIR.split(':')[2]; 
                    }
                    
                }else if(Integer.valueOf(diffIR.split(':')[0]) > 99){
                    wrapperInstance.overdueTimeIR = '';
                }else{
                    wrapperInstance.overdueTimeIR = '+'+diffIR.split(':')[0]+' '+System.Label.SLAT003_TAG009;
                }
                system.debug('overdueTimeIR=='+wrapperInstance.overdueTimeIR);
            }
            system.debug(LoggingLevel.Warn, 'Remaining time for Initial Response: ' + RemainingTimeIR);
            List<String> TimeLstIR = new List<String>();
            TimeLstIR = RemainingTimeIR.split(':');
            wrapperInstance.iIRdays = integer.valueof(TimeLstIR[0]);
            wrapperInstance.iIRhrs = integer.valueof(TimeLstIR[1]);
            wrapperInstance.iIRmins = integer.valueof(TimeLstIR[2]);
            wrapperInstance.iIRsecs = integer.valueof(TimeLstIR[3]);
            
            if(mpSLADtlTypeToSLADtl.get('InitialResponse') != null){
                DateTime ClockStartsFrom = (DateTime)WOObj1.get(mpSLADtlTypeToSLADtl.get('InitialResponse').SVMXC__Clock_Starts_From__c); 
                if(ClockStartsFrom != null){
                    wrapperInstance.CommitmentTimeIR = DatCal.getCountDown(InitialResponseBy.getTime() - ClockStartsFrom.getTime());
                }
                
            }
            
        }
        
        if(RemainingTimeOR != null && RemainingTimeOR.length() > 0 )
        {
            if(RemainingTimeOR.startsWith('00:00:00') || RemainingTimeOR.startsWith('0:0:0')){
                wrapperInstance.isOverTimeOR = true;
                //Calculate Overdue Time
                Long milliseconds = datetime.now().getTime() - OnsiteResponseBy.getTime();
                String diffIR = DatCal.getCountDown(milliseconds);              
                if(diffIR.split(':')[0] == '0' || diffIR.split(':')[0] == '00'){
                    if(diffIR.split(':')[1] == '00' && diffIR.split(':')[2] == '00'){
                        wrapperInstance.overdueTimeOR = '+0:0';                     
                    }else{
                        wrapperInstance.overdueTimeOR = '+'+diffIR.split(':')[1] +':' +diffIR.split(':')[2]; 
                    }
                    
                }else if(Integer.valueOf(diffIR.split(':')[0]) > 99){
                    wrapperInstance.overdueTimeOR = '';
                }else{
                    wrapperInstance.overdueTimeOR = '+'+diffIR.split(':')[0]+' '+System.Label.SLAT003_TAG009;
                }
                system.debug('overdueTimeOR=='+wrapperInstance.overdueTimeOR);
            }
            system.debug(LoggingLevel.Warn, 'Remaining time for Onsite Response: ' + RemainingTimeOR);
            List<String> TimeLstOR = new List<String>();
            TimeLstOR = RemainingTimeOR.split(':');
            wrapperInstance.iORdays = integer.valueof(TimeLstOR[0]);
            wrapperInstance.iORhrs = integer.valueof(TimeLstOR[1]);
            wrapperInstance.iORmins = integer.valueof(TimeLstOR[2]);
            wrapperInstance.iORsecs = integer.valueof(TimeLstOR[3]);
            
            if(mpSLADtlTypeToSLADtl.get('OnsiteResponse') != null){
                DateTime ClockStartsFrom = (DateTime)WOObj1.get(mpSLADtlTypeToSLADtl.get('OnsiteResponse').SVMXC__Clock_Starts_From__c); 
                if(ClockStartsFrom != null){
                    wrapperInstance.CommitmentTimeOR = DatCal.getCountDown(OnsiteResponseBy.getTime() - ClockStartsFrom.getTime()); 
                }
            }
            
        }
        
        if(RemainingTimeResto != null && RemainingTimeResto.length() > 0 )
        {
            if(RemainingTimeResto.startsWith('00:00:00') || RemainingTimeResto.startsWith('0:0:0')){
                wrapperInstance.isOverTimeREST = true;
                //Calculate Overdue Time
                Long milliseconds = datetime.now().getTime() - RestorationBy.getTime();
                String diffIR = DatCal.getCountDown(milliseconds);              
                if(diffIR.split(':')[0] == '0' || diffIR.split(':')[0] == '00'){
                    if(diffIR.split(':')[1] == '00' && diffIR.split(':')[2] == '00'){
                        wrapperInstance.overdueTimeREST = '+0:0';                       
                    }else{
                        wrapperInstance.overdueTimeREST = '+'+diffIR.split(':')[1] +':' +diffIR.split(':')[2]; 
                    }
                    
                }else if(Integer.valueOf(diffIR.split(':')[0]) > 99){
                    wrapperInstance.overdueTimeREST = '';
                }else{
                    wrapperInstance.overdueTimeREST = '+'+diffIR.split(':')[0]+' '+System.Label.SLAT003_TAG009;
                }
                system.debug('overdueTimeREST=='+wrapperInstance.overdueTimeREST);
            }
            system.debug(LoggingLevel.Warn, 'Remaining time for Restoration: ' + RemainingTimeResto);
            List<String> TimeLstResto = new List<String>();
            TimeLstResto = RemainingTimeResto.split(':');
            wrapperInstance.iAREdays = integer.valueof(TimeLstResto[0]);
            wrapperInstance.iAREhrs = integer.valueof(TimeLstResto[1]);
            wrapperInstance.iAREmins = integer.valueof(TimeLstResto[2]);
            wrapperInstance.iAREsecs = integer.valueof(TimeLstResto[3]);
            
            if(mpSLADtlTypeToSLADtl.get('Restoration') != null){
                DateTime ClockStartsFrom = (DateTime)WOObj1.get(mpSLADtlTypeToSLADtl.get('Restoration').SVMXC__Clock_Starts_From__c);
                if(ClockStartsFrom != null){
                    wrapperInstance.CommitmentTimeResto = DatCal.getCountDown(RestorationBy.getTime() - ClockStartsFrom.getTime());
                }
            }
            
        }
        
        if(RemainingTimeResol != null && RemainingTimeResol.length() > 0 )
        {
            if(RemainingTimeResol.startsWith('0:0:0') || RemainingTimeResol.startsWith('00:00:00')){
                wrapperInstance.isOverTimeRES = true;
                //Calculate Overdue Time
                Long milliseconds = datetime.now().getTime() - ResolutionBy.getTime();
                String diffIR = DatCal.getCountDown(milliseconds);              
                if(diffIR.split(':')[0] == '0' || diffIR.split(':')[0] == '00'){
                    if(diffIR.split(':')[1] == '00' && diffIR.split(':')[2] == '00'){
                        wrapperInstance.overdueTimeRES = '+0:0';                        
                    }else{
                        wrapperInstance.overdueTimeRES = '+'+diffIR.split(':')[1] +':' +diffIR.split(':')[2]; 
                    }
                    
                }else if(Integer.valueOf(diffIR.split(':')[0]) > 99){
                    wrapperInstance.overdueTimeRES = '';
                }else{
                    wrapperInstance.overdueTimeRES = '+'+diffIR.split(':')[0]+' '+System.Label.SLAT003_TAG009;
                }
                system.debug('overdueTimeRES=='+wrapperInstance.overdueTimeRES);
            }
            system.debug(LoggingLevel.Warn, 'Remaining time for Resolution: ' + RemainingTimeResol);
            List<String> TimeLstResol = new List<String>();
            TimeLstResol = RemainingTimeResol.split(':');
            wrapperInstance.iAROdays = integer.valueof(TimeLstResol[0]);
            wrapperInstance.iAROhrs = integer.valueof(TimeLstResol[1]);
            wrapperInstance.iAROmins = integer.valueof(TimeLstResol[2]);
            wrapperInstance.iAROsecs = integer.valueof(TimeLstResol[3]);
            
            if(mpSLADtlTypeToSLADtl.get('Resolution') != null){
                DateTime ClockStartsFrom = (DateTime)WOObj1.get(mpSLADtlTypeToSLADtl.get('Resolution').SVMXC__Clock_Starts_From__c);
                if(ClockStartsFrom != null){
                    wrapperInstance.CommitmentTimeResol = DatCal.getCountDown(ResolutionBy.getTime() - ClockStartsFrom.getTime());
                }
            }
            
        }
        
        wrapperInstance.WOObj = WOObj;
        wrapperInstance.SLATerm = SLATerm;
        wrapperInstance.SLADetails = SLADetails;
        if(InitialResponseBy!=null){
            wrapperInstance.InitialResponseBy = InitialResponseBy.format();
        }
        if(OnsiteResponseBy!=null){
            wrapperInstance.OnsiteResponseBy = OnsiteResponseBy.format();
        }
        if(RestorationBy!=null){
            wrapperInstance.RestorationBy = RestorationBy.format();
        }
        if(ResolutionBy!=null){
            wrapperInstance.ResolutionBy = ResolutionBy.format();
        }   
        if(svmxSettingList.containsKey('SET002')){
            wrapperInstance.SLAClockPausedSetting = Boolean.valueOf(svmxSettingList.get('SET002'));
        }
        
        wrapperInstance.BHMap = BHMap;
        return wrapperInstance;
    } 
    
    public static String formatDate(SVMXC__Service_Order__c WOObj,Datetime CommitmentTime, Datetime ActualResponse)
    {
        SVMXC.COMM_Utils_DateCalculation  DatCal = new SVMXC.COMM_Utils_DateCalculation();
        String calculatedTime = '';
        Long lngClkPauseTime = 0;
        Long SLAClkExtMin = 0;
        Long LCommitmentTime = 0;
        Long LActualResponse = 0;
        Long Lnow = 0;
        Long Ldiff = 0;
        if(ActualResponse == null)
        {
            if(WOObj.SVMXC__SLA_Clock_Paused__c == true)
            {
                LCommitmentTime = CommitmentTime.getTime();
                if(WOObj.SVMXC__SLA_Clock_Pause_Time__c != null)
                    lngClkPauseTime = WOObj.SVMXC__SLA_Clock_Pause_Time__c.gettime();
                if(WOObj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
                {   
                    Ldiff = LCommitmentTime - (lngClkPauseTime + WOObj.SVMXC__SLA_Clock_Extension_Minutes__c.longValue());
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
                if(WOObj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
                {   
                    Ldiff = LCommitmentTime - Lnow + WOObj.SVMXC__SLA_Clock_Extension_Minutes__c.longValue();
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
            if(WOObj.SVMXC__SLA_Clock_Extension_Minutes__c != null)
            {   
                Ldiff =  LCommitmentTime - LActualResponse + WOObj.SVMXC__SLA_Clock_Extension_Minutes__c.longValue();
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
    
    @AuraEnabled
    public static SVMXC__Service_Order__c SVMX_PauseNow(SVMXC__Service_Order__c WOObj,String ForHowLong)
    {
        String WOReason = '';
        if(SVMX_ValidPause(WOObj,ForHowLong) == true)
        {
            WOObj.SVMXC__SLA_Clock_Pause_Time__c = system.now();
            WOObj.SVMXC__SLA_Clock_Pause_Restart_Time__c = null;
            if(ForHowLong == 'b')
            {
                WOObj.SVMXC__SLA_Clock_Paused__c = true;
                WOObj.SVMXC__Clock_Paused_Forever__c = false;
            }
            else if(ForHowLong == 'a')
            {
                WOObj.SVMXC__SLA_Clock_Paused__c = true;
                WOObj.SVMXC__Clock_Paused_Forever__c = true;
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( WOObj, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert WOObj;
            } else {
                throw new AuraHandledException(System.Label.COMM001_TAG142);
            }
            WOReason = getWorkOrderData(ForHowLong,WOObj);
            Task taskobj = new Task();
            taskobj.WhatId = WOObj.id;
            taskobj.Subject = 'SLA Clock Stop';
            taskobj.Type = 'Other';
            taskobj.Status = 'Completed';
            taskobj.Priority = 'Normal';
            taskobj.OwnerId = Userinfo.getUserId();
            taskobj.IsReminderSet = false;
            taskobj.Description = getTAG014() + ' ' + system.now() + ' ' + getTAG015() + ' ' + Userinfo.getFirstName() + Userinfo.getLastName() + ' ' + getTAG016() + ' ' + WOObj.SVMXC__SLA_Clock_Pause_Reason__c + ' '+WOReason; 
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( taskobj, COMM_SecurityUtils.Access.Createable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                insert taskobj;
            } else {
                throw new AuraHandledException(System.Label.COMM001_TAG142);
            }
        }
        return WOObj;
    }
    
    public static Boolean SVMX_ValidPause(SVMXC__Service_Order__c WOObj,String ForHowLong)
    {
        Boolean SVMX_ValidPause = true;
        if(WOObj.SVMXC__SLA_Clock_Pause_Reason__c == null)
        {
            SVMX_ValidPause = false;
            throw new AuraHandledException(getTAG012());
        }
        if(ForHowLong == 'b')
        {
            if(WOObj.SVMXC__SLA_Clock_Pause_Days__c == null  && WOObj.SVMXC__SLA_Clock_Pause_Hours__c == null && WOObj.SVMXC__SLA_Clock_Pause_Minutes__c == null)
            {
                SVMX_ValidPause = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG013()));
            }
        }
        system.debug(LoggingLevel.Warn, 'Reason: ' + WOObj.SVMXC__SLA_Clock_Pause_Reason__c + '; ForHowLong: ' + ForHowLong + '; SVMX_ValidPause: ' + SVMX_ValidPause);
        return SVMX_ValidPause;
    }
    
    public static String getWorkOrderData(String ForHowLong,SVMXC__Service_Order__c WOObj)
    {
        String WOReason = '';
        WOReason += getTAG002() + ':';
        if(ForHowLong == 'a')
        {
            WOReason += ' ' + getTAG007();
        }
        else if(ForHowLong == 'b')
        {
            
            if(WOObj.SVMXC__SLA_Clock_Pause_Days__c != null)
                WOReason +=  ' '+WOObj.SVMXC__SLA_Clock_Pause_Days__c + ' ' + getTAG009();
            if(WOObj.SVMXC__SLA_Clock_Pause_Hours__c != null)
                WOReason += ' '+WOObj.SVMXC__SLA_Clock_Pause_Hours__c + ' ' + getTAG010();
            if(WOObj.SVMXC__SLA_Clock_Pause_Minutes__c != null)
                WOReason += ' '+WOObj.SVMXC__SLA_Clock_Pause_Minutes__c + ' ' + getTAG011();        
        }
        if(WOObj.SVMXC__Initial_Response_Customer_By__c != null)
        {
            WOReason += ' ' + getTAG018() + ' ' + WOObj.SVMXC__Initial_Response_Customer_By__c;
        }
        if(WOObj.SVMXC__Onsite_Response_Customer_By__c != null)
        {
            WOReason += ' ' + getTAG019() + ' ' + WOObj.SVMXC__Onsite_Response_Customer_By__c;
        }
        if(WOObj.SVMXC__Restoration_Customer_By__c != null)
        {
            WOReason += ' ' + getTAG020() + ' ' + WOObj.SVMXC__Restoration_Customer_By__c;
        }
        if(WOObj.SVMXC__Resolution_Customer_By__c != null)
        {
            WOReason += ' ' + getTAG021() + ' ' + WOObj.SVMXC__Resolution_Customer_By__c;
        }   
        return WOReason;
    }
    
    @AuraEnabled
    public static Long getElapsedMinutes(SVMXC__Service_Order__c WOObj)
    {
        Long ElapsedMinutes = 0;
        Long Ldiff = 0;
        Long L1 = 0;
        Long L2 = 0;
        if(WOObj.SVMXC__SLA_Clock_Pause_Time__c != null)
        {
            L1 = WOObj.SVMXC__SLA_Clock_Pause_Time__c.gettime(); 
            L2 = system.now().getTime();
            if(L1 > 0 && L2 > 0 && L2 > L1)
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
    
    @AuraEnabled
    public static SVMXC__Service_Order__c SVMX_Yes(SVMXC__Service_Order__c WOObj,List<SVMXC__SLA_Detail__c> SLADetails,Map<String,String> BHMap,Integer ElapsedMins)
    {
        Long ElapsedMinutes = 0;
        BusinessHours bh = new BusinessHours();
        String BuildDescForTask = '';
        bh = [Select id from BusinessHours where IsDefault = true];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        WOObj.SVMXC__Clock_Paused_Forever__c = false;
        WOObj.SVMXC__SLA_Clock_Paused__c = false;
        WOObj.SVMXC__SLA_Clock_Pause_Reason__c = null;
        WOObj.SVMXC__SLA_Clock_Pause_Restart_Time__c = system.now();
        WOObj.SVMXC__SLA_Clock_Pause_Days__c = null;
        WOObj.SVMXC__SLA_Clock_Pause_Hours__c = null;
        WOObj.SVMXC__SLA_Clock_Pause_Minutes__c = null;
        
        String businessHoursId;
        String strCommitType;
        String strInternalFldName;
        String strCustomerFldName;
        Long lngRemainingTime;
        
        // Calculate all the the commitment fields based on applicable BH for the clocks which have not yet been stopped
        if(ElapsedMins > 0 && SLADetails.size() > 0)
        {
            for(Integer i = 0; i < SLADetails.size(); i++)
            {
                // Set the datetime fields applicable for this SLA Detail record
                if(SLADetails[i].SVMXC__Commitment_Type__c == 'InitialResponse')
                {
                    if(WOObj.SVMXC__Actual_Initial_Response__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Initial_Response_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Initial_Response_Customer_By__c';
                    strCommitType = 'IR';
                }
                else if(SLADetails[i].SVMXC__Commitment_Type__c == 'OnsiteResponse')
                {
                    if(WOObj.SVMXC__Actual_Onsite_Response__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Onsite_Response_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Onsite_Response_Customer_By__c';
                    strCommitType = 'OR';
                }
                else if(SLADetails[i].SVMXC__Commitment_Type__c == 'Restoration')
                {
                    if(WOObj.SVMXC__Actual_Restoration__c != null) // Stopped clock, no further calculations
                        continue;
                    strInternalFldName = 'SVMXC__Restoration_Internal_By__c';
                    strCustomerFldName = 'SVMXC__Restoration_Customer_By__c';
                    strCommitType = 'Resto';
                }
                else if(SLADetails[i].SVMXC__Commitment_Type__c == 'Resolution')
                {
                    if(WOObj.SVMXC__Actual_Resolution__c != null) // Stopped clock, no further calculations
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
                if((datetime)WOObj.get(strCustomerFldName) != null)
                {
                    lngRemainingTime = BusinessHours.diff(businessHoursId, WOObj.SVMXC__SLA_Clock_Pause_Time__c, (datetime)WOObj.get(strCustomerFldName));
                    if(lngRemainingTime > 0)
                    {
                        WOObj.put(strCustomerFldName, BusinessHours.addGmt(businessHoursId, WOObj.SVMXC__SLA_Clock_Pause_Restart_Time__c, lngRemainingTime));
                    }
                }
                if((datetime)WOObj.get(strInternalFldName) != null)
                {
                    lngRemainingTime = BusinessHours.diff(businessHoursId, WOObj.SVMXC__SLA_Clock_Pause_Time__c, (datetime)WOObj.get(strInternalFldName));
                    if(lngRemainingTime > 0)
                    {
                        WOObj.put(strInternalFldName, BusinessHours.addGmt(businessHoursId, WOObj.SVMXC__SLA_Clock_Pause_Restart_Time__c, lngRemainingTime));
                    }
                }
            }
            //Added for the SPM Average Response Time ART Metric support. 
            //Populating extension minutes in the fields and incrementing it with the subsequent pause and resume(If user says YES)
            ElapsedMinutes = getElapsedMinutes(WOObj);
            if(WOObj.SVMXC__SLA_Clock_Extension_Minutes__c != null && WOObj.SVMXC__SLA_Clock_Extension_Minutes__c > 0){
                WOObj.SVMXC__SLA_Clock_Extension_Minutes__c += ElapsedMinutes;
            }
            else{
                WOObj.SVMXC__SLA_Clock_Extension_Minutes__c = ElapsedMinutes;
            }
        }           
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( WOObj, COMM_SecurityUtils.Access.Upsertable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            upsert WOObj;
        } else {
            throw new AuraHandledException(System.Label.COMM001_TAG142);
            
        }
        BuildDescForTask = BuildDescForTask(ElapsedMinutes,WOObj);
        Task Taskobj = new Task();
        Taskobj.WhatId = WOObj.id;
        Taskobj.Type = 'Other';
        Taskobj.Subject = 'SLA Clock Start';
        Taskobj.Status = 'Completed';
        Taskobj.Priority = 'Normal';
        Taskobj.OwnerId = Userinfo.getUserId();
        Taskobj.IsReminderSet = false;
        Taskobj.Description = BuildDescForTask;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Taskobj, COMM_SecurityUtils.Access.Createable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert Taskobj;
        } else {
            throw new AuraHandledException(System.Label.COMM001_TAG142);
        }
                
        return WOObj;
    }
    
    public static String BuildDescForTask(Long ElapsedMinutes,SVMXC__Service_Order__c WOObj)
    {
        String BuildDescForTask = '';
        BuildDescForTask += getTAG027() + ' ' + system.now() + ' ' + getTAG028() + ' ' + Userinfo.getFirstName() + Userinfo.getLastName() + ' ' + getTAG029() + ' ' + ElapsedMinutes;
        if(WOObj.SVMXC__Initial_Response_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG018() + ' ' + WOObj.SVMXC__Initial_Response_Customer_By__c;
        }
        if(WOObj.SVMXC__Onsite_Response_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG019() + ' ' + WOObj.SVMXC__Onsite_Response_Customer_By__c;
        }
        if(WOObj.SVMXC__Restoration_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG020() + ' ' + WOObj.SVMXC__Restoration_Customer_By__c;
        }
        if(WOObj.SVMXC__Resolution_Customer_By__c != null)
        {
            BuildDescForTask += ' ' + getTAG021() + ' ' + WOObj.SVMXC__Resolution_Customer_By__c;
        } 
        return BuildDescForTask;
    }
    
    public static String getTAG002(){ return System.Label.SLAT003_TAG002;}//For How Long
    public static String getTAG007(){ return System.Label.SLAT003_TAG007;}//Indefinitely
    public static String getTAG009(){ return System.Label.SLAT003_TAG009;}//Days
    public static String getTAG010(){ return System.Label.SLAT003_TAG010;}//Hours
    public static String getTAG011(){ return System.Label.SLAT003_TAG011;}//Mins
    public static String getTAG012(){ return System.Label.SLAT003_TAG012;}// Please select a reason
    public static String getTAG013(){ return System.Label.SLAT003_TAG013;}// You must enter at least one of Days, Hours or Minutes
    public static String getTAG014(){ return System.Label.SLAT003_TAG014;}//SLA Clock Paused at
    public static String getTAG015(){ return System.Label.SLAT003_TAG015;}//SLA Clock Paused by
    public static String getTAG016(){ return System.Label.SLAT003_TAG016;}//Pause Reason:
    public static String getTAG018(){ return System.Label.SLAT003_TAG018;}//Initial Response Required by: 
    public static String getTAG019(){ return System.Label.SLAT003_TAG019;}//Onsite Response Required by:
    public static String getTAG020(){ return System.Label.SLAT003_TAG020;}//Restoration Required by:
    public static String getTAG021(){ return System.Label.SLAT003_TAG021;}//Resolution Required by:
    public static String getTAG027(){ return System.Label.SLAT003_TAG027;}//SLA Clock Restarted at
    public static String getTAG028(){ return System.Label.SLAT003_TAG028;}//SLA Clock Restarted by
    public static String getTAG029(){ return System.Label.SLAT003_TAG029;}//Time elapsed since last stop
    public static String getTAG045(){ return System.Label.SLAT003_TAG045;}//SLAT003_TAG045
    public static String getTAG046(){ return System.Label.SLAT003_TAG046;}//SLAT003_TAG046
    
    public class SLADetil{
        @AuraEnabled public SVMXC__Service_Order__c WOObj = new SVMXC__Service_Order__c();
        @AuraEnabled public SVMXC__Service_Level__c  SLATerm = new SVMXC__Service_Level__c ();
        @AuraEnabled public List<SVMXC__SLA_Detail__c> SLADetails = new List<SVMXC__SLA_Detail__c>();
        @AuraEnabled public Map<String,String> BHMap = new Map<String,String>();
        @AuraEnabled public String InitialResponseBy, OnsiteResponseBy, RestorationBy, ResolutionBy;
        @AuraEnabled public integer iIRdays = 0;
        @AuraEnabled public integer iIRhrs = 0;
        @AuraEnabled public integer iIRmins = 0;
        @AuraEnabled public integer iIRsecs = 0;
        @AuraEnabled public integer iORdays = 0;
        @AuraEnabled public integer iORhrs = 0;
        @AuraEnabled public integer iORmins = 0;
        @AuraEnabled public integer iORsecs = 0;
        @AuraEnabled public integer iAREdays = 0;
        @AuraEnabled public integer iAREhrs = 0;
        @AuraEnabled public integer iAREmins = 0;
        @AuraEnabled public integer iAREsecs = 0;
        @AuraEnabled public integer iAROdays = 0;
        @AuraEnabled public integer iAROhrs = 0;
        @AuraEnabled public integer iAROmins = 0;
        @AuraEnabled public integer iAROsecs = 0;
        @AuraEnabled public String CommitmentTimeIR = '';
        @AuraEnabled public String CommitmentTimeOR = '';
        @AuraEnabled public String CommitmentTimeResto = '';
        @AuraEnabled public String CommitmentTimeResol = '';
        @AuraEnabled public double SLAIRMin = 0;
        @AuraEnabled public double SLAORMin = 0;
        @AuraEnabled public double SLARestorationMin = 0;
        @AuraEnabled public double SLAResolutionMin = 0;
        @AuraEnabled public integer ThresholdTime = 0;
        @AuraEnabled public Boolean SLAClockPausedSetting;
        @AuraEnabled public Boolean isOverTimeIR;
        @AuraEnabled public Boolean isOverTimeOR;
        @AuraEnabled public Boolean isOverTimeRES;
        @AuraEnabled public Boolean isOverTimeREST;
        @AuraEnabled public String overdueTimeIR;
        @AuraEnabled public String overdueTimeOR;
        @AuraEnabled public String overdueTimeRES;
        @AuraEnabled public String overdueTimeREST;
    }
}