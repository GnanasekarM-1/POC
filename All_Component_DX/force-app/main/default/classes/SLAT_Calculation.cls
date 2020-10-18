/* Security Scanned */
global with sharing class SLAT_Calculation 
{
    public Map<String, String> AllSubModuleSettings = new Map<String, String>();
    List<Account> AccountBH = new List<Account>();
    List<SVMXC__Installed_Product__c> IBBH = new List<SVMXC__Installed_Product__c>();
    List<Case> CaseData = new List<Case>();
    Map<String, String> CaseSLASubModuleSettings = new Map<String, String> ();
    Map<Id,BusinessHours> mapBusinessHours;//Added by Nidhi as part of BAC-4646
    // Constructors
    public SLAT_Calculation(){}
    
    public SLAT_Calculation(Map<String, String> mapCaseSLASettings){
        this.CaseSLASubModuleSettings = mapCaseSLASettings;
    }
    
    public SLAT_Calculation(Map<String, String> mapOMAXSettings, Map<String, String> mapSLATSettings, List<Account> LstAccount,List<Case> LstCase,List<SVMXC__Installed_Product__c> LstComponent)
    {
        mapOMAXSettings.get('SET008');
        AllSubModuleSettings.put('OMAX003_SET008', mapOMAXSettings.get('SET008'));
        mapSLATSettings.get('SET003');
        AllSubModuleSettings.put('SLAT003_SET003', mapSLATSettings.get('SET003'));
        
        //Added for the SPM Average Response Time metric
        if(mapSLATSettings.containsKey('SET001')){
            AllSubModuleSettings.put('SLAT003_SET001', mapSLATSettings.get('SET001'));
            System.debug('Commitment type Setting: '+AllSubModuleSettings.get('SLAT003_SET001'));
        }
        
        //Code Added by Akash on june 21,2010 for code optimization 
        AccountBH = LstAccount;
        CaseData = LstCase;
        IBBH = LstComponent;
    }

    //*********************************Calculation for Work Order************************************
    global void SLAT_CalculationOnWO(List<SVMXC__Service_Order__c> ProcessWO)
    {

        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        List<SVMXC__Service_Level__c> SLATerm = new List<SVMXC__Service_Level__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        set<id> SLATermId = new set<id>();
        set<id> accid = new set<id>();
        set<id> IBid = new set<id>();
        set<id> CaseId = new set<id>();
        set<id> SCid = new set<id>();//Added by Nidhi Defect-48054 Fix 
        set<string> SContractBH = new set<string>();
        List<SVMXC__Service_Contract__c> ServiceContractBH = new List<SVMXC__Service_Contract__c>();//Added by Nidhi Defect-48054 Fix
        BusinessHours DefaultBH = new  BusinessHours();
        List<BusinessHours> SCBH = new List<BusinessHours>(); 
        Map<String,String> BHMap = new Map<String,String>();
        Map<String,String> MapofSCBH = new Map<String,String>();
        String strSLATimeStampForWO ;
        
        Map<id, List<SVMXC__SLA_Detail__c>> MapofSLADetail = new Map<id, List<SVMXC__SLA_Detail__c>>();
        Map<id,SVMXC__Service_Level__c> MapofSLATerm = new Map<id, SVMXC__Service_Level__c>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        DefaultBH = [Select b.Id From BusinessHours b where IsDefault = true and IsActive = true];
        
        if(AllSubModuleSettings.containsKey('SLAT003_SET003') && String.isNotBlank(AllSubModuleSettings.get('SLAT003_SET003')) && AllSubModuleSettings.get('SLAT003_SET003').toUpperCase() == 'TRUE')
        {
            if(AllSubModuleSettings.containsKey('OMAX003_SET008'))
                strSLATimeStampForWO = AllSubModuleSettings.get('OMAX003_SET008');
            for (Integer i = 0; i < ProcessWO.size(); i++) 
            {
                if(ProcessWO[i].SVMXC__SLA_Terms__c != null)
                    SLATermId.add(ProcessWO[i].SVMXC__SLA_Terms__c);

                //Added by Nidhi Defect-48054 Fix 
                if(ProcessWO[i].SVMXC__Service_Contract__c != null){
                    SCid.add(ProcessWO[i].SVMXC__Service_Contract__c);
                } //Added by Nidhi Defect-48054 Fix Ends Here
            }  
            if(SLATermId.size() > 0)
            {
                //New fields added in the query by Nidhi as part of BAC-4646
                SLATerm = [Select s.SVMXC__Restoration_Tracked_On__c, s.SVMXC__Resolution_Tracked_On__c, s.SVMXC__Onsite_Response_Tracked_On__c, s.SVMXC__Initial_Response_Tracked_On__c, s.SVMXC__Business_Hours__c, s.SVMXC__Effective_Date__c, s.Id,SVMXC__SM_Initial_SLA_Cutoff_Time__c,SVMXC__SM_Initial_Unit_of_Measure__c,SVMXC__SM_Onsite_SLA_Cutoff_Time__c,SVMXC__SM_Onsite_Unit_of_Measure__c,SVMXC__SM_Resolution_SLA_Cutoff_Time__c,SVMXC__SM_Resolution_Unit_of_Measure__c,SVMXC__SM_Restoration_SLA_Cutoff_Time__c,SVMXC__SM_Restoration_Unit_of_Measure__c From SVMXC__Service_Level__c s where id in :SLATermId AND (SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder' OR SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder' OR SVMXC__Restoration_Tracked_On__c = 'WorkOrder' OR SVMXC__Resolution_Tracked_On__c = 'WorkOrder')];
                
                for(SVMXC__Service_Level__c slaT: SLATerm)
                    MapofSLATerm.put(slaT.Id, slaT);
                
                SLADetail = [Select s.SVMXC__Type__c, s.SVMXC__Service_Details__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Priority__c, s.SVMXC__Number_of_units__c, s.SVMXC__Internal_Goal__c, s.SVMXC__Included_Or_Not__c, s.SVMXC__Frequency__c, s.SVMXC__Customer_Commitment__c, s.SVMXC__Commitment_Type__c, s.SVMXC__Clock_Starts_From__c, s.SVMXC__Business_Hours__c, s.SVMXC__Business_Hours_Source__c, s.Id From SVMXC__SLA_Detail__c s where SVMXC__SLA_Terms__c in :SLATermId AND SVMXC__Type__c != null AND SVMXC__Priority__c != null AND RecordType.Name = 'Commitment' AND SVMXC__Clock_Starts_From__c != null AND (SVMXC__Internal_Goal__c != null OR SVMXC__Customer_Commitment__c != null)];
            }
            
            if(SLADetail != null && SLADetail.size() > 0)
            {
                for(SVMXC__SLA_Detail__c dtl: SLADetail)
                {
                    if(!MapofSLADetail.containsKey(dtl.SVMXC__SLA_Terms__c))
                        MapofSLADetail.put(dtl.SVMXC__SLA_Terms__c, new List<SVMXC__SLA_Detail__c>());
                    MapofSLADetail.get(dtl.SVMXC__SLA_Terms__c).add(dtl);
                }
            }
            
            if(CaseData.size() > 0)
            {
                for(integer i = 0;i < CaseData.size();i++)
                {
                    SContractBH.add(CaseData[i].SVMXC__SContract_Business_Hour__c);
                    MapofSCBH.put(CaseData[i].SVMXC__SContract_Business_Hour__c,CaseData[i].id);
                }
            }

            //Added by Nidhi Defect-48054 Fix . This gets Business Hours From Service Contract on WO
            if(SCid.size() > 0)
                ServiceContractBH = [select id,SVMXC__Business_Hours__c,SVMXC__Business_Hours__r.IsActive from SVMXC__Service_Contract__c where id in : SCid];
                if(ServiceContractBH.size() != 0){   
                    for(integer i =0; i< ServiceContractBH.size(); i++)
                    {
                        if(ServiceContractBH[i].SVMXC__Business_Hours__r.IsActive == true)
                            BHMap.put(ServiceContractBH[i].id, ServiceContractBH[i].SVMXC__Business_Hours__c);
                    }
                } 
            //Added by Nidhi Defect-48054 Fix Ends Here
            
            if(SContractBH != null)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                SCBH = [select id,IsActive from BusinessHours where id in: SContractBH]; 
            
            if(AccountBH.size() != 0)
            {
                for(integer i =0; i< AccountBH.size(); i++)
                {
                    if(AccountBH[i].SVMXC__Access_Hours__r.IsActive == true)
                    { 
                        BHMap.put(AccountBH[i].id, AccountBH[i].SVMXC__Access_Hours__c);
                    }   
                }
            }
            if(IBBH.size() != 0)
            {   
                for(integer i =0; i< IBBH.size(); i++)
                {
                    if(IBBH[i].SVMXC__Access_Hours__r.IsActive == true)
                    {
                        BHMap.put(IBBH[i].id, IBBH[i].SVMXC__Access_Hours__c);
                    }   
                }
            }
            if(SCBH.size() != 0)
            {   
                for(integer i =0; i< SCBH.size(); i++)
                {
                    if(SCBH[i].IsActive == true )
                    {
                        BHMap.put(MapofSCBH.get(SCBH[i].id),SCBH[i].id);
                    }   
                }
            }
            
            Set<String> setBHIds = new Set<String>();//Added by Nidhi as part of BAC-4646
            setBHIds.addAll(BHMap.values());//Add business hour Ids in BHMap
            setBHIds.add(DefaultBH.id);//Default Business Hour Id,Added by Nidhi Ends here
            
            if(ProcessWO.size() != 0 && SLATerm.size() != 0 && SLADetail.size() != 0)
            {   
                for(Integer i = 0; i < ProcessWO.size(); i++)
                {
                    ProcessWO[i].SVMXC__Preferred_Business_Hours__c = DefaultBH.id;
                    
                    map<string, SVMXC__SLA_Detail__c> mpSLADtlTypeToSLADtl = new map<string, SVMXC__SLA_Detail__c>();
                    List<SVMXC__SLA_Detail__c> lstSLADtls = MapofSLADetail.get(ProcessWO[i].SVMXC__SLA_Terms__c);
                    if(lstSLADtls != null && lstSLADtls.size() > 0)
                    {
                        for(SVMXC__SLA_Detail__c sq: lstSLADtls)
                        {
                            if(sq.SVMXC__Priority__c == ProcessWO[i].SVMXC__Priority__c && (sq.SVMXC__Type__c == ProcessWO[i].SVMXC__Order_Type__c || sq.SVMXC__Type__c == 'All'))
                            {
                                if(!mpSLADtlTypeToSLADtl.containsKey(sq.SVMXC__Commitment_Type__c))
                                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                                else if(sq.SVMXC__Type__c == ProcessWO[i].SVMXC__Order_Type__c)
                                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                            }
                        }
                    
                        List<SVMXC__SLA_Detail__c> SLADetailsToProcess = new List<SVMXC__SLA_Detail__c>();
                        
                        for(string str: mpSLADtlTypeToSLADtl.keyset()){                         
                            SLADetailsToProcess.add(mpSLADtlTypeToSLADtl.get(str));
                            
                            //Added by nidhi as part of BAC-4646, to get list of all the Business Hours
                            SVMXC__SLA_Detail__c detailRecord = mpSLADtlTypeToSLADtl.get(str);                            
                            setBHIds.add(MapofSLATerm.get(detailRecord.SVMXC__SLA_Terms__c).SVMXC__Business_Hours__c);//Business Hour on the SLA term
                            setBHIds.add(detailRecord.SVMXC__Business_Hours__c);//Business Hour on the SLA Detail
                            //Code Added by Nidhi ends here
                        }
                        
                        //Added by Nidhi, to optimize Business Hour Query further used in CalculateSLAForWO method. BAC-4646
                        mapBusinessHours = new Map<Id,BusinessHours>([select Id,timezonesidkey,FridayEndTime,MondayEndTime,SaturdayEndTime,SundayEndTime,ThursdayEndTime,TuesdayEndTime,WednesdayEndTime from BusinessHours where id In :setBHIds]);//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        
                        for(SVMXC__SLA_Detail__c sq: SLADetailsToProcess)
                        {
                            
                            if(sq.SVMXC__Commitment_Type__c == 'InitialResponse' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Initial_Response_Tracked_On__c == 'WorkOrder')
                            {
                                //CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Initial_Response_Internal_By__c','SVMXC__Initial_Response_Customer_By__c','Initial Response Internal','Initial Response Customer');
                                //Added one more argument (API name of the field 'SVMXC__SM_SLA_Initial_Response__c') for the SPM ART metric
                                CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Initial_Response_Internal_By__c','SVMXC__Initial_Response_Customer_By__c','Initial Response Internal','Initial Response Customer', 'SVMXC__SM_SLA_Initial_Response__c');
                            }
                            else if(sq.SVMXC__Commitment_Type__c == 'OnsiteResponse' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Onsite_Response_Tracked_On__c == 'WorkOrder')
                            {
                                //CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Onsite_Response_Internal_By__c','SVMXC__Onsite_Response_Customer_By__c','Onsite Response Internal','Onsite Response Customer');
                                //Added one more argument (API name of the field 'SVMXC__SM_SLA_Onsite_Response__c') for the SPM ART metric
                                CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Onsite_Response_Internal_By__c','SVMXC__Onsite_Response_Customer_By__c','Onsite Response Internal','Onsite Response Customer', 'SVMXC__SM_SLA_Onsite_Response__c');
                            }
                            else if(sq.SVMXC__Commitment_Type__c == 'Restoration' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Restoration_Tracked_On__c == 'WorkOrder')
                            {
                                //CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Restoration_Internal_By__c','SVMXC__Restoration_Customer_By__c','Restoration Internal','Restoration Customer');
                                //Added one more argument (API name of the field 'SVMXC__SM_SLA_Restoration__c') for the SPM ART metric
                                CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Restoration_Internal_By__c','SVMXC__Restoration_Customer_By__c','Restoration Internal','Restoration Customer', 'SVMXC__SM_SLA_Restoration__c');
                            }
                            else if(sq.SVMXC__Commitment_Type__c == 'Resolution' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Resolution_Tracked_On__c == 'WorkOrder')
                            {
                                //CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Resolution_Internal_By__c','SVMXC__Resolution_Customer_By__c','Resolution Internal','Resolution Customer'); 
                                //Added one more argument (API name of the field 'SVMXC__SM_SLA_Resolution__c') for the SPM ART metric
                                CalculateSLAForWO(ProcessWO[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,strSLATimeStampForWO,'SVMXC__Resolution_Internal_By__c','SVMXC__Resolution_Customer_By__c','Resolution Internal','Resolution Customer', 'SVMXC__SM_SLA_Resolution__c'); 
                            }
                        }
                    }
                    if(ProcessWO[i].SVMXC__Is_SLA_Calculated__c == true)
                    {
                        ProcessWO[i].SVMXC__Is_SLA_Calculated__c = false;
                    }
                }
            }     
        }        
    }
    //public SVMXC__Service_Order__c CalculateSLAForWO (SVMXC__Service_Order__c oWO, SVMXC__Service_Level__c oSLATerm ,SVMXC__SLA_Detail__c oSLADetail, map<String, string> BHMap, BusinessHours DefaultBH,String strSLATimeStampForWO,String InternalByField, String CustomerByField ,String InternalSetVal ,String CustomerSetVal)
    
    //Added one more argument (ResponseField) for the SPM ART metric
    public SVMXC__Service_Order__c CalculateSLAForWO (SVMXC__Service_Order__c oWO, SVMXC__Service_Level__c oSLATerm ,SVMXC__SLA_Detail__c oSLADetail, map<String, string> BHMap, BusinessHours DefaultBH,String strSLATimeStampForWO,String InternalByField, String CustomerByField ,String InternalSetVal ,String CustomerSetVal, String ResponseField)
    {
        //calculate the value of clock start from...
        system.debug('oSLADetail'+oSLADetail.SVMXC__Business_Hours_Source__c);
        Datetime newdate;
        if(oSLADetail.SVMXC__Clock_Starts_From__c != 'CreatedDate' || oSLADetail.SVMXC__Clock_Starts_From__c != 'LastModifiedDate')
        {
            newdate = datetime.valueof(oWO.get(oSLADetail.SVMXC__Clock_Starts_From__c));
            system.debug('newdate'+newdate);
        }
        if(oSLADetail.SVMXC__Clock_Starts_From__c == 'CreatedDate')
        {
            if(oWO.CreatedDate == null )
            {
                newdate = system.now();
            }
            if(oWO.CreatedDate != null )
            {
                newdate = oWO.CreatedDate;
            }
        }   
        if(oSLADetail.SVMXC__Clock_Starts_From__c == 'LastModifiedDate')
        {
            newdate = system.now();
        }   
        if(newdate != null)
        {        
            Long InternalGoal;
            Long CustomerCommitment;
            Long ExtensionMinites;
            //Calculate the value of internal goal field...
            try
            {
                if(oSLADetail.SVMXC__Internal_Goal__c != null)
                {
                    String str =String.valueOf(oSLADetail.SVMXC__Internal_Goal__c);
                    InternalGoal = long.valueOf(str);
                }   
            }
            catch(exception ex){}           
            //Calculate Customer Comittment..
            try
            {
                if(oSLADetail.SVMXC__Customer_Commitment__c != null)
                {
                    String str1 = String.valueof(oSLADetail.SVMXC__Customer_Commitment__c);
                    CustomerCommitment = long.valueOf(str1);
                }   
            }   
            catch(exception ex){}   
            //Calculate the ExtensionMinitus
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Custom')
            {   
                if(oSLADetail.SVMXC__Business_Hours__c != null)
                {
                    if(InternalGoal != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,InternalGoal,InternalByField,oSLADetail.SVMXC__Business_Hours__c);
                        //oWO.put(InternalByField,BusinessHours.add(oSLADetail.SVMXC__Business_Hours__c,newdate,InternalGoal * 60 * 1000L));
                    }
                    if(CustomerCommitment != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,CustomerCommitment,CustomerByField,oSLADetail.SVMXC__Business_Hours__c);                       
                        //oWO.put(CustomerByField,BusinessHours.add(oSLADetail.SVMXC__Business_Hours__c,newdate,CustomerCommitment * 60 * 1000L));
                    }
                    if(strSLATimeStampForWO != null && (InternalSetVal == strSLATimeStampForWO ||CustomerSetVal == strSLATimeStampForWO))
                        oWO.SVMXC__Preferred_Business_Hours__c = oSLADetail.SVMXC__Business_Hours__c;
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'SLA')
            {
                if(oSLATerm.SVMXC__Business_Hours__c != null)
                {
                    if(InternalGoal != null){ 
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,InternalGoal,InternalByField,oSLATerm.SVMXC__Business_Hours__c);
                        //oWO.put(InternalByField,BusinessHours.add(oSLATerm.SVMXC__Business_Hours__c,newdate,InternalGoal * 60 * 1000L));                            
                    }
                    if(CustomerCommitment != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,CustomerCommitment,CustomerByField,oSLATerm.SVMXC__Business_Hours__c);                     
                        //oWO.put(CustomerByField,BusinessHours.add(oSLATerm.SVMXC__Business_Hours__c,newdate,CustomerCommitment * 60 * 1000L));                        
                    }
                    if(strSLATimeStampForWO != null && (InternalSetVal == strSLATimeStampForWO ||CustomerSetVal == strSLATimeStampForWO))
                        oWO.SVMXC__Preferred_Business_Hours__c = oSLATerm.SVMXC__Business_Hours__c;
                }  
                
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Account')
            {
                if(BHMap.containsKey(oWO.SVMXC__Company__c) && BHMap.get(oWO.SVMXC__Company__c) != null)
                {
                    if(InternalGoal != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,InternalGoal,InternalByField,BHMap.get(oWO.SVMXC__Company__c));
                        //oWO.put(InternalByField,BusinessHours.add(BHMap.get(oWO.SVMXC__Company__c),newdate,InternalGoal * 60 * 1000L));
                    }
                    if(CustomerCommitment != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,CustomerCommitment,CustomerByField,BHMap.get(oWO.SVMXC__Company__c));                      
                        //oWO.put(CustomerByField,BusinessHours.add(BHMap.get(oWO.SVMXC__Company__c),newdate,CustomerCommitment * 60 * 1000L));
                    }
                    if(strSLATimeStampForWO != null && (InternalSetVal == strSLATimeStampForWO ||CustomerSetVal == strSLATimeStampForWO))
                        oWO.SVMXC__Preferred_Business_Hours__c = BHMap.get(oWO.SVMXC__Company__c);
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Product')
            {
                if(BHMap.containsKey(oWO.SVMXC__Component__c) && BHMap.get(oWO.SVMXC__Component__c) != null)
                {
                    if(InternalGoal != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,InternalGoal,InternalByField,BHMap.get(oWO.SVMXC__Component__c));
                        //oWO.put(InternalByField,BusinessHours.add(BHMap.get(oWO.SVMXC__Component__c),newdate,InternalGoal * 60 * 1000L));
                    }
                    if(CustomerCommitment != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,CustomerCommitment,CustomerByField,BHMap.get(oWO.SVMXC__Component__c));                        
                        //oWO.put(CustomerByField,BusinessHours.add(BHMap.get(oWO.SVMXC__Component__c),newdate,CustomerCommitment * 60 * 1000L));
                    }
                    if(strSLATimeStampForWO != null && (InternalSetVal == strSLATimeStampForWO ||CustomerSetVal == strSLATimeStampForWO))
                        oWO.SVMXC__Preferred_Business_Hours__c = BHMap.get(oWO.SVMXC__Component__c);
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Contract')
            {
                //Added by Nidhi Defect-48054 Fix . This gets Business Hours From Service Contract on WO
                //if(BHMap.containsKey(oWO.SVMXC__Case__c) && BHMap.get(oWO.SVMXC__Case__c) != null)
                if(BHMap.containsKey(oWO.SVMXC__Service_Contract__c) && BHMap.get(oWO.SVMXC__Service_Contract__c) != null)
                {
                    if(InternalGoal != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,InternalGoal,InternalByField,BHMap.get(oWO.SVMXC__Service_Contract__c));
                        //oWO.put(InternalByField,BusinessHours.add(BHMap.get(oWO.SVMXC__Service_Contract__c),newdate,InternalGoal * 60 * 1000L));
                    }
                    if(CustomerCommitment != null){
                        //Changes added by Nidhi as part of BAC-4646
                        string clockType = CustomerSetVal.split(' ')[0];
                        calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,CustomerCommitment,CustomerByField,BHMap.get(oWO.SVMXC__Service_Contract__c));                     
                        //oWO.put(CustomerByField,BusinessHours.add(BHMap.get(oWO.SVMXC__Service_Contract__c),newdate,CustomerCommitment * 60 * 1000L));
                    }
                    if(strSLATimeStampForWO != null && (InternalSetVal == strSLATimeStampForWO ||CustomerSetVal == strSLATimeStampForWO))
                        oWO.SVMXC__Preferred_Business_Hours__c = BHMap.get(oWO.SVMXC__Service_Contract__c);
                }   
            }
            if(oWO.get(InternalByField) == null && oWO.get(CustomerByField) == null )
            {
                if(InternalGoal != null){   
                    //Changes added by Nidhi as part of BAC-4646
                    string clockType = CustomerSetVal.split(' ')[0];
                    calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,InternalGoal,InternalByField,DefaultBH.id);
                    //oWO.put(InternalByField,BusinessHours.add(DefaultBH.id,newdate,InternalGoal * 60 * 1000L));
                }
                if(CustomerCommitment != null){
                    string clockType = CustomerSetVal.split(' ')[0];
                    calculateSLAEndTime(oWO,clockType,oSLATerm,newdate,CustomerCommitment,CustomerByField,DefaultBH.id);
                    //oWO.put(CustomerByField,BusinessHours.add(DefaultBH.id,newdate,CustomerCommitment * 60 * 1000L));
                }
            }
            
            //Added for the SPM Average Response Time metric to populating new fields created to hold commitment minutes which is configured in SLA terms definition
            if(!AllSubModuleSettings.isEmpty() && AllSubModuleSettings.containsKey('SLAT003_SET001')){
                if(AllSubModuleSettings.get('SLAT003_SET001').equalsIgnoreCase('Customer Commitment') && CustomerCommitment != null){
                    oWO.put(ResponseField, (Double)CustomerCommitment);
                }
                else if(AllSubModuleSettings.get('SLAT003_SET001').equalsIgnoreCase('Internal Commitment') && InternalGoal != null){
                    oWO.put(ResponseField, (Double)InternalGoal);
                }
            }
        }
        return oWO;
    }
    
    //Following method added by Nidhi as part of BAC-4646, to calculate end datetime based on unit of measure set on SLA Term
    public void calculateSLAEndTime(SVMXC__Service_Order__c oWO,String clocktype,SVMXC__Service_Level__c oSLATerm,Datetime newdate,long commitmentTime,String endDateFieldOnWO,String BusinessHoursId){ 
        system.debug('mapBusinessHours=='+mapBusinessHours);
        BusinessHours currentBH = mapBusinessHours.get(BusinessHoursId);        
        
        system.debug('clockType=='+clockType);
        if(clockType == 'initial'){
            if(oSLATerm.SVMXC__SM_Initial_Unit_of_Measure__c == 'Day'){
                Time cutOffTime = oSLATerm.SVMXC__SM_Initial_SLA_Cutoff_Time__c;              
                if(String.isBlank(String.valueOf(cutOffTime))){//If cutoff time is null, End of BH becomes the cutoff time.
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                }else{ 
                    Datetime newDateToCheckCutOff = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0); // this new date is to check if cutOff time is within business hours.
                    if(!BusinessHours.isWithin(BusinessHoursId, newDateToCheckCutOff)){//If cutoff time is outside business hours,End of BH becomes the cutoff time.
                        String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                        cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    }
                }
                
                if(newdate.time() < cutOffTime && commitmentTime!=0){
                    //work order created datetime is less than cutoff,SLA end time will be end of BH
                    for (Integer i = 0; i < commitmentTime; i++){   
                        if(i!=0){
                            newdate = newdate.addDays(1);
                        }                                           
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    //Calculate End of Business hours 
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    Time endOfBH = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    if(String.valueOf(endOfBH) == '00:00:00.000Z'){//End of Business Hours being 12 AM should be considered as next day's 12 Am. Add one day
                        newdate = newdate.addDays(1);
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){//Check if new date is within working days                    
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),endOfBH.hour(),endOfBH.minute(),endOfBH.second());
                }else if(newdate.time() > cutOffTime && commitmentTime!=0){
                    //work order created datetime is greater than cutoff,SLA end time will be next day cutoff time
                    for (Integer i = 0; i < commitmentTime; i++){                                                       
                        newdate = newdate.addDays(1);                                          
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate.Date())){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate.Date());
                        }
                    }              
                    system.debug('cutOffTime=='+cutOffTime);
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0);
                    system.debug('newdate=='+newdate);
                }
                oWO.put(endDateFieldOnWO,newdate);
            }else{
            //If unit of measure is minutes, no changes to existing functionality.
                oWO.put(endDateFieldOnWO,BusinessHours.add(BusinessHoursId,newdate,commitmentTime * 60 * 1000L));
            }                                   
        }else if(clockType == 'onsite'){
            if(oSLATerm.SVMXC__SM_Onsite_Unit_of_Measure__c == 'Day'){
                Time cutOffTime = oSLATerm.SVMXC__SM_Onsite_SLA_Cutoff_Time__c;
                if(String.isBlank(String.valueOf(cutOffTime))){//If cutoff time is null, End of BH becomes the cutoff time.
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                }else{ 
                    Datetime newDateToCheckCutOff = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0); // this new date is to check if cutOff time is within business hours.
                    if(!BusinessHours.isWithin(BusinessHoursId, newDateToCheckCutOff)){//If cutoff time is outside business hours,End of BH becomes the cutoff time.
                        String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                        cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    }
                }
                
                if(newdate.time() < cutOffTime && commitmentTime!=0){
                    //work order created datetime is less than cutoff,SLA end time will be end of BH
                    for (Integer i = 0; i < commitmentTime; i++){   
                        if(i!=0){
                            newdate = newdate.addDays(1);
                        }                                           
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    //Calculate End of Business hours 
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    Time endOfBH = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    if(String.valueOf(endOfBH) == '00:00:00.000Z'){//End of Business Hours being 12 AM should be considered as next day's 12 Am. Add one day
                        newdate = newdate.addDays(1);
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){//Check if new date is within working days                    
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),endOfBH.hour(),endOfBH.minute(),endOfBH.second());
                }else if(newdate.time() > cutOffTime && commitmentTime!=0){
                    for (Integer i = 0; i < commitmentTime; i++){                               
                        newdate = newdate.addDays(1);                
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate.Date())){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate.Date());
                        }
                    }                   
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0);
                }
                oWO.put(endDateFieldOnWO,newdate);
            }else{
            //If unit of measure is minutes, no changes to existing functionality.
                oWO.put(endDateFieldOnWO,BusinessHours.add(BusinessHoursId,newdate,commitmentTime * 60 * 1000L));   
            }
        }else if(clockType == 'restoration'){
            if(oSLATerm.SVMXC__SM_Restoration_Unit_of_Measure__c == 'Day'){
                Time cutOffTime = oSLATerm.SVMXC__SM_Restoration_SLA_Cutoff_Time__c;
                if(String.isBlank(String.valueOf(cutOffTime))){//If cutoff time is null, End of BH becomes the cutoff time.
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                }else{ 
                    Datetime newDateToCheckCutOff = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0); // this new date is to check if cutOff time is within business hours.
                    if(!BusinessHours.isWithin(BusinessHoursId, newDateToCheckCutOff)){//If cutoff time is outside business hours,End of BH becomes the cutoff time.
                        String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                        cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    }
                }
                
                if(newdate.time() < cutOffTime && commitmentTime!=0){
                    //work order created datetime is less than cutoff,SLA end time will be end of BH
                    for (Integer i = 0; i < commitmentTime; i++){   
                        if(i!=0){
                            newdate = newdate.addDays(1);
                        }
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    //Calculate End of Business hours 
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    Time endOfBH = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    if(String.valueOf(endOfBH) == '00:00:00.000Z'){//End of Business Hours being 12 AM should be considered as next day's 12 Am. Add one day
                        newdate = newdate.addDays(1);
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){//Check if new date is within working days                    
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),endOfBH.hour(),endOfBH.minute(),endOfBH.second());
                }else if(newdate.time() > cutOffTime && commitmentTime!=0){
                    for (Integer i = 0; i < commitmentTime; i++){                               
                        newdate = newdate.addDays(1);                 
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate.Date())){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate.Date());
                        }
                    } 
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0);
                }
                oWO.put(endDateFieldOnWO,newdate);
            }else{
            //If unit of measure is minutes, no changes to existing functionality.
                oWO.put(endDateFieldOnWO,BusinessHours.add(BusinessHoursId,newdate,commitmentTime * 60 * 1000L));   
            }
        }else if(clockType == 'resolution'){
            if(oSLATerm.SVMXC__SM_Resolution_Unit_of_Measure__c == 'Day'){
                Time cutOffTime = oSLATerm.SVMXC__SM_Resolution_SLA_Cutoff_Time__c;
                if(String.isBlank(String.valueOf(cutOffTime))){//If cutoff time is null, End of BH becomes the cutoff time.
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                }else{ 
                    Datetime newDateToCheckCutOff = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0); // this new date is to check if cutOff time is within business hours.
                    if(!BusinessHours.isWithin(BusinessHoursId, newDateToCheckCutOff)){//If cutoff time is outside business hours,End of BH becomes the cutoff time.
                        String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                        cutOffTime = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    }
                }
                
                if(newdate.time() < cutOffTime && commitmentTime!=0){
                    //work order created datetime is less than cutoff,SLA end time will be end of BH
                    for (Integer i = 0; i < commitmentTime; i++){   
                        if(i!=0){
                            newdate = newdate.addDays(1);
                        }
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    //Calculate End of Business hours 
                    String strDayOfWeek = newdate.format('EEEE', currentBH.timezonesidkey);
                    Time endOfBH = (Time)currentBH.get(strDayOfWeek + 'EndTime');
                    if(String.valueOf(endOfBH) == '00:00:00.000Z'){//End of Business Hours being 12 AM should be considered as next day's 12 Am. Add one day
                        newdate = newdate.addDays(1);
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate)){//Check if new date is within working days                    
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate);
                        }
                    }
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),endOfBH.hour(),endOfBH.minute(),endOfBH.second());
                }else if(newdate.time() > cutOffTime && commitmentTime!=0){
                    for (Integer i = 0; i < commitmentTime; i++){                               
                        newdate = newdate.addDays(1);                 
                        //Check if new date is within working days
                        if (!BusinessHours.isWithin(BusinessHoursId, newdate.Date())){                      
                            newdate = BusinessHours.nextStartDate(BusinessHoursId, newdate.Date());
                        }
                    }                   
                    newdate = datetime.newInstance(newdate.year(),newdate.month(),newdate.day(),cutOffTime.hour(),0,0);
                }
                oWO.put(endDateFieldOnWO,newdate);
            }else{
            //If unit of measure is minutes, no changes to existing functionality.
                oWO.put(endDateFieldOnWO,BusinessHours.add(BusinessHoursId,newdate,commitmentTime * 60 * 1000L));   
            }
        }
    }
    global void SLAT_CalculationOnCase(List<Case> ProcessCase)
    {
        List<SVMXC__Service_Level__c> SLATerm = new List<SVMXC__Service_Level__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        set<id> SLATermId = new set<id>();
        set<id> accid = new set<id>();
        set<id> IBid = new set<id>();
        set<id> SCid = new set<id>();
        BusinessHours DefaultBH = new  BusinessHours();
        List<Account> AccountBH = new List<Account>();
        List<SVMXC__Installed_Product__c> IBBH = new List<SVMXC__Installed_Product__c>();
        List<SVMXC__Service_Contract__c> ServiceContractBH = new List<SVMXC__Service_Contract__c>();
        Map<String,String> BHMap = new Map<String,String>();
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('SLAT002','SET003');
        
        Map<id, List<SVMXC__SLA_Detail__c>> MapofSLADetail = new Map<id, List<SVMXC__SLA_Detail__c>>();
        Map<id,SVMXC__Service_Level__c> MapofSLATerm = new Map<id, SVMXC__Service_Level__c>();
        
        //DefaultBH = [Select b.Id From BusinessHours b where IsDefault = true]; Commented from here. Query this under if condition.
        system.debug(Logginglevel.WARN, 'SLA setting value: ' + CaseSLASubModuleSettings);
        
        /* Neeraj - Changed condition, since we are passing setting in different format from Case trigger. 
        Also, querying default business hour inside method.
        Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('SLAT002','SET003'); 
        //if(CaseSLASubModuleSettings.containsKey('SET003')&& CaseSLASubModuleSettings.get('SET003').toUpperCase() == 'TRUE')
        */
        if(CaseSLASubModuleSettings.containsKey('SLAT002_SET003')&& CaseSLASubModuleSettings.get('SLAT002_SET003').toUpperCase() == 'TRUE')
        {
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            DefaultBH = [Select b.Id From BusinessHours b where IsDefault = true];
            for (Integer i = 0; i < ProcessCase.size(); i++) 
            {
                if(ProcessCase[i].SVMXC__SLA_Terms__c != null)  
                {
                    SLATermId.add(ProcessCase[i].SVMXC__SLA_Terms__c);
                }
                if(ProcessCase[i].AccountId != null)
                {
                    accid.add(ProcessCase[i].AccountId);
                }
                if(ProcessCase[i].SVMXC__Component__c != null)
                {
                    IBid.add(ProcessCase[i].SVMXC__Component__c);
                }
                if(ProcessCase[i].SVMXC__Service_Contract__c != null)
                {
                    SCid.add(ProcessCase[i].SVMXC__Service_Contract__c);
                }
            }
            if(SLATermId.size() > 0)
            {  
                SLATerm = [Select s.SVMXC__Restoration_Tracked_On__c, s.SVMXC__Resolution_Tracked_On__c, s.SVMXC__Onsite_Response_Tracked_On__c, s.SVMXC__Initial_Response_Tracked_On__c, s.SVMXC__Business_Hours__c, s.SVMXC__Effective_Date__c, s.Id From SVMXC__Service_Level__c s where id in :SLATermId AND (SVMXC__Initial_Response_Tracked_On__c = 'case' OR SVMXC__Onsite_Response_Tracked_On__c = 'case' OR SVMXC__Restoration_Tracked_On__c = 'case' OR SVMXC__Resolution_Tracked_On__c = 'case')];
                
                for(SVMXC__Service_Level__c slaT: SLATerm)
                    MapofSLATerm.put(slaT.Id, slaT);
                
                SLADetail = [Select s.SVMXC__Type__c, s.SVMXC__Service_Details__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Priority__c, s.SVMXC__Number_of_units__c, s.SVMXC__Internal_Goal__c, s.SVMXC__Included_Or_Not__c, s.SVMXC__Frequency__c, s.SVMXC__Customer_Commitment__c, s.SVMXC__Commitment_Type__c, s.SVMXC__Clock_Starts_From__c, s.SVMXC__Business_Hours__c, s.SVMXC__Business_Hours_Source__c, s.Id From SVMXC__SLA_Detail__c s where SVMXC__SLA_Terms__c in :SLATermId AND SVMXC__Type__c != null AND SVMXC__Priority__c != null AND RecordType.Name = 'Commitment' AND SVMXC__Clock_Starts_From__c != null AND (SVMXC__Internal_Goal__c != null OR SVMXC__Customer_Commitment__c != null)];
            }
            
            if(SLADetail != null && SLADetail.size() > 0)
            {
                for(SVMXC__SLA_Detail__c dtl: SLADetail)
                {
                    if(!MapofSLADetail.containsKey(dtl.SVMXC__SLA_Terms__c))
                        MapofSLADetail.put(dtl.SVMXC__SLA_Terms__c, new List<SVMXC__SLA_Detail__c>());
                    MapofSLADetail.get(dtl.SVMXC__SLA_Terms__c).add(dtl);
                }
            }
            
            if(accid.size() > 0)       
                AccountBH = [select id,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from account where id in :accid];
            
            if(IBid.size() > 0)
                IBBH = [select id,SVMXC__Access_Hours__c,SVMXC__Access_Hours__r.IsActive from SVMXC__Installed_Product__c where id in : IBid];
                
            if(SCid.size() > 0)
                ServiceContractBH = [select id,SVMXC__Business_Hours__c,SVMXC__Business_Hours__r.IsActive from SVMXC__Service_Contract__c where id in : SCid];
                
            if(AccountBH.size() != 0)
            {
                for(integer i =0; i< AccountBH.size(); i++)
                {
                    if(AccountBH[i].SVMXC__Access_Hours__r.IsActive == true)
                        BHMap.put(AccountBH[i].id, AccountBH[i].SVMXC__Access_Hours__c);
                }
            }
            
            if(IBBH.size() != 0)
            {   
                for(integer i =0; i< IBBH.size(); i++)
                {
                    if(IBBH[i].SVMXC__Access_Hours__r.IsActive == true)
                        BHMap.put(IBBH[i].id, IBBH[i].SVMXC__Access_Hours__c);
                }
            }
            
            if(ServiceContractBH.size() != 0)
            {   
                for(integer i =0; i< ServiceContractBH.size(); i++)
                {
                    if(ServiceContractBH[i].SVMXC__Business_Hours__r.IsActive == true)
                        BHMap.put(ServiceContractBH[i].id, ServiceContractBH[i].SVMXC__Business_Hours__c);
                }
            }   
            if(ProcessCase.size() != 0 && SLATerm.size() != 0 && SLADetail.size() != 0)
            {   
                for(Integer i = 0; i < ProcessCase.size(); i++)
                {
                    map<string, SVMXC__SLA_Detail__c> mpSLADtlTypeToSLADtl = new map<string, SVMXC__SLA_Detail__c>();
                    List<SVMXC__SLA_Detail__c> lstSLADtls = MapofSLADetail.get(ProcessCase[i].SVMXC__SLA_Terms__c);
                    if(lstSLADtls != null && lstSLADtls.size() > 0)
                    {
                        for(SVMXC__SLA_Detail__c sq: lstSLADtls)
                        {
                            if(sq.SVMXC__Priority__c == ProcessCase[i].Priority && (sq.SVMXC__Type__c == ProcessCase[i].Type || sq.SVMXC__Type__c == 'All'))
                            {
                                if(!mpSLADtlTypeToSLADtl.containsKey(sq.SVMXC__Commitment_Type__c))
                                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                                else if(sq.SVMXC__Type__c == ProcessCase[i].Type)
                                    mpSLADtlTypeToSLADtl.put(sq.SVMXC__Commitment_Type__c, sq);
                            }
                        }
                        
                        List<SVMXC__SLA_Detail__c> SLADetailsToProcess = new List<SVMXC__SLA_Detail__c>();
                        
                        for(string str: mpSLADtlTypeToSLADtl.keyset())
                            SLADetailsToProcess.add(mpSLADtlTypeToSLADtl.get(str));
                        
                        for(SVMXC__SLA_Detail__c sq: SLADetailsToProcess)
                        {
                            if(sq.SVMXC__Commitment_Type__c == 'InitialResponse' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Initial_Response_Tracked_On__c == 'case')
                            {
                                CalculateSLAForCase (ProcessCase[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,'SVMXC__Initial_Response_Internal_By__c','SVMXC__Initial_Response_Customer_By__c');
                            }
                            else if(sq.SVMXC__Commitment_Type__c == 'OnsiteResponse' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Onsite_Response_Tracked_On__c == 'case')
                            {
                                CalculateSLAForCase (ProcessCase[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,'SVMXC__Onsite_Response_Internal_By__c','SVMXC__Onsite_Response_Customer_By__c');
                            }
                            else if(sq.SVMXC__Commitment_Type__c == 'Restoration' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Restoration_Tracked_On__c == 'case')
                            {
                                CalculateSLAForCase (ProcessCase[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,'SVMXC__Restoration_Internal_By__c','SVMXC__Restoration_Customer_By__c');
                            }
                            else if(sq.SVMXC__Commitment_Type__c == 'Resolution' && MapofSLATerm.get(sq.SVMXC__SLA_Terms__c).SVMXC__Resolution_Tracked_On__c == 'case')
                            {
                                CalculateSLAForCase (ProcessCase[i],MapofSLATerm.get(sq.SVMXC__SLA_Terms__c),sq,BHMap,DefaultBH,'SVMXC__Resolution_Internal_By__c','SVMXC__Resolution_Customer_By__c');
                            }
                        }
                    }
                    if(ProcessCase[i].SVMXC__Is_SLA_Calculated__c == true)
                    {
                        ProcessCase[i].SVMXC__Is_SLA_Calculated__c = false;
                    }
                }
            }     
        }
    }
    
    public Case CalculateSLAForCase (Case oCase, SVMXC__Service_Level__c oSLATerm ,SVMXC__SLA_Detail__c oSLADetail, map<String, string> BHMap, BusinessHours DefaultBH, String InternalByField, String CustomerByField)
    {
        //calculate the value of clock start from...
        Datetime newdate;
        if(oSLADetail.SVMXC__Clock_Starts_From__c != 'CreatedDate' || oSLADetail.SVMXC__Clock_Starts_From__c != 'LastModifiedDate')
        {
            newdate = datetime.valueof(oCase.get(oSLADetail.SVMXC__Clock_Starts_From__c));
        }
        if(oSLADetail.SVMXC__Clock_Starts_From__c == 'CreatedDate')
        {
            if(oCase.CreatedDate == null )
            {
                newdate = system.now();
            }
            if(oCase.CreatedDate != null )
            {
                newdate = oCase.CreatedDate;
            } 
        }   
        if(oSLADetail.SVMXC__Clock_Starts_From__c == 'LastModifiedDate')
        {
            newdate = system.now();
        }     
             System.debug('newDate: '+String.valueOf(newdate));
        if(newdate != null)
        {       
            Long InternalGoal;
            Long CustomerCommitment;
             //Calculate the value of internal goal field...
            
            try
            {
                String str =String.valueOf(oSLADetail.SVMXC__Internal_Goal__c);
                InternalGoal = long.valueOf(str);
            }
            catch(Exception ex){}
            //Calculate Customer Comittment..
            try
            {
                String str1 = String.valueof(oSLADetail.SVMXC__Customer_Commitment__c);
                CustomerCommitment = long.valueOf(str1);
            }   
            catch(Exception ex){}
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Custom')
            {   
                if(oSLADetail.SVMXC__Business_Hours__c != null)
                {
                    if(InternalGoal != null)
                        oCase.put(InternalByField,BusinessHours.add(oSLADetail.SVMXC__Business_Hours__c,newdate,InternalGoal * 60 * 1000L));
                    if(CustomerCommitment != null)
                        oCase.put(CustomerByField,BusinessHours.add(oSLADetail.SVMXC__Business_Hours__c,newdate,CustomerCommitment * 60 * 1000L));
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'SLA')
            {
                if(oSLATerm.SVMXC__Business_Hours__c != null)
                {   
                    System.debug('oSLATerm.SVMXC__Business_Hours__c'+oSLATerm.SVMXC__Business_Hours__c);
                    System.debug('newdate'+newdate);
                    System.debug('CustomerCommitment'+CustomerCommitment);
                    System.debug('BusinessHours.add(oSLATerm.SVMXC__Business_Hours__c,newdate,CustomerCommitment * 60 * 1000L)'+BusinessHours.add(oSLATerm.SVMXC__Business_Hours__c,newdate,CustomerCommitment * 60 * 1000L));
                    if(InternalGoal != null)
                        oCase.put(InternalByField,BusinessHours.add(oSLATerm.SVMXC__Business_Hours__c,newdate,InternalGoal * 60 * 1000L));
                    if(CustomerCommitment != null)
                        oCase.put(CustomerByField,BusinessHours.add(oSLATerm.SVMXC__Business_Hours__c,newdate,CustomerCommitment * 60 * 1000L));
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Account')
            {
                if(BHMap.containsKey(oCase.AccountId) && BHMap.get(oCase.AccountId) != null)
                {
                    if(InternalGoal != null)
                        oCase.put(InternalByField,BusinessHours.add(BHMap.get(oCase.AccountId),newdate,InternalGoal * 60 * 1000L));
                    if(CustomerCommitment != null)
                        oCase.put(CustomerByField,BusinessHours.add(BHMap.get(oCase.AccountId),newdate,CustomerCommitment * 60 * 1000L));
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Product')
            {
                if(BHMap.containsKey(oCase.SVMXC__Component__c) && BHMap.get(oCase.SVMXC__Component__c) != null)
                {
                    if(InternalGoal != null)
                        oCase.put(InternalByField,BusinessHours.add(BHMap.get(oCase.SVMXC__Component__c),newdate,InternalGoal * 60 * 1000L));
                    if(CustomerCommitment != null)
                        oCase.put(CustomerByField,BusinessHours.add(BHMap.get(oCase.SVMXC__Component__c),newdate,CustomerCommitment * 60 * 1000L));
                }   
            }
            if(oSLADetail.SVMXC__Business_Hours_Source__c == 'Contract')
            {
                if(BHMap.containsKey(oCase.SVMXC__Service_Contract__c) && BHMap.get(oCase.SVMXC__Service_Contract__c) != null)
                {
                    if(InternalGoal != null)
                        oCase.put(InternalByField,BusinessHours.add(BHMap.get(oCase.SVMXC__Service_Contract__c),newdate,InternalGoal * 60 * 1000L));
                    if(CustomerCommitment != null)
                        oCase.put(CustomerByField,BusinessHours.add(BHMap.get(oCase.SVMXC__Service_Contract__c),newdate,CustomerCommitment * 60 * 1000L));
                }   
            }
            if(oCase.get(InternalByField) == null && oCase.get(CustomerByField) == null)
            {            
                if(InternalGoal != null)
                    oCase.put(InternalByField,BusinessHours.add(DefaultBH.id,newdate,InternalGoal * 60 * 1000L));
                if(CustomerCommitment != null)
                    oCase.put(CustomerByField,BusinessHours.add(DefaultBH.id,newdate,CustomerCommitment * 60 * 1000L));
            }
        }
        return oCase;
    }
    //Request Class
    public class SLAT_Request{
        public list<SLAT_StringMap> listOfStringMap = new list<SLAT_StringMap>();
        public list<SLAT_StringListMap> listOfStringListMap = new list<SLAT_StringListMap>();
    }
    // Response Class
    public class SLAT_Response{
        public map<String,SLAT_SLABHInfo> mapWorkOrderIdBusinessHourInfo = new map<String,SLAT_SLABHInfo>();
        public map<String,SLAT_SLABHInfo> mapCaseIdBusinessHourInfo = new map<String,SLAT_SLABHInfo>();
    }
    
    public class SLAT_StringMap{
        public String key;
        public String value;
        
        public SLAT_StringMap(String key, String value){
            this.key = key;
            this.value = value;
        }
        
        public  SLAT_StringMap(){}
    }
     public class SLAT_StringListMap{
        public String key;
        public list<String> valueList = new list<String>();
        
        public SLAT_StringListMap(String key, list<String> valueList){
            this.key = key;
            this.valueList = valueList;
        }
        public SLAT_StringListMap(){}
    }
    // This class cotains Business hours Id for SLA.
    public class SLAT_SLABHInfo{
        
        public String initialResponseBH;
        public String onsiteResponseBH;
        public String reslutionBH;
        public String restorationBH;
        public String defaultBH;
        public String initialClockStartField;
        public String onsiteClockStartField;
        public String resolveClockStartField;
        public String restoreClockStartField;       
        public SLAT_SLABHInfo(String initialResponseBH, String onsiteResponseBH, String reslutionBH, String restorationBH, String defaultBH, String initialClockStartField, String onsiteClockStartField, String resolveClockStartField, String restoreClockStartField){
            this.initialResponseBH = initialResponseBH;
            this.onsiteResponseBH = onsiteResponseBH;
            this.reslutionBH = reslutionBH;
            this.restorationBH = restorationBH;
            this.defaultBH = defaultBH;
            this.initialClockStartField = initialClockStartField;
            this.onsiteClockStartField = onsiteClockStartField;
            this.resolveClockStartField = resolveClockStartField;
            this.restoreClockStartField = restoreClockStartField;
        }
    } 
    
    //This method accepts work order Ids and commitment type of SLA definition returns associated Business Hours Id in given work order for SLA Definition associated to work order
    public SLAT_Response slaBusinessHoursForWO(SLAT_Request request){
        
        SLAT_Response response = new SLAT_Response();
        map<String,SLAT_SLABHInfo> mapWorkOrderIdBusinessHourInfo = new map<String,SLAT_SLABHInfo>();
        map<String,SLAT_SLABHInfo> mapCaseIdBusinessHourInfo = new map<String,SLAT_SLABHInfo>();
        list<String> lstWorkOrderId = new list<String>();
        list<String> lstCaseId = new list<String>();
        set<String> strCommitmentType = new set<String>();
        Boolean isAllType = true;
        
        // Get work order ids from given request.
        for(SLAT_StringListMap lstStringListMap : request.listOfStringListMap){
            if(lstStringListMap.key == 'WORKORDERIDS')
                lstWorkOrderId.addall(lstStringListMap.valueList);
            else if(lstStringListMap.key == 'CASEIDS')
                lstCaseId.addall(lstStringListMap.valueList);
        }
        // Get commitment type from given request.
        for(SLAT_StringMap stringMap : request.listOfStringMap){
            if(stringMap.key == 'COMMITMENTTYPE' &&  stringMap.value == 'INITIALRESPONSE'){
                isAllType = false;
                strCommitmentType.add('INITIALRESPONSE');
            }
            else if(stringMap.key == 'COMMITMENTTYPE' &&  stringMap.value == 'ONSITERESPONSE'){
                isAllType = false;
                strCommitmentType.add('ONSITERESPONSE');
            }
            else if(stringMap.key == 'COMMITMENTTYPE' &&  stringMap.value == 'RESOLUTION'){
                isAllType = false;
                strCommitmentType.add('RESOLUTION');
            }
            else if(stringMap.key == 'COMMITMENTTYPE' &&  stringMap.value == 'RESTORATION'){
                isAllType = false;
                strCommitmentType.add('RESTORATION');
            }
        }
        
        //For Given Work Orders get SLA Ids 
        map<String,SVMXC__Service_Order__c> mapWorkOrders = new map<String,SVMXC__Service_Order__c>(); 
        map<String,SVMXC__Service_Order__c> mapSLAIdWorkOrder = new map<String,SVMXC__Service_Order__c>();
        //For Given Cases get SLA Ids
        map<String,Case> mapCases = new map<String,Case>(); 
        map<String,Case> mapSLAIdCases = new map<String,Case>();
        
        list<SVMXC__SLA_Detail__c> lstSLADetails = new list<SVMXC__SLA_Detail__c>();
        if(lstWorkOrderId.size()>0){
            mapWorkOrders.putall([select Id, SVMXC__SLA_Terms__r.SVMXC__Business_Hours__c, SVMXC__Company__r.SVMXC__Access_Hours__c,SVMXC__Component__r.SVMXC__Access_Hours__c,SVMXC__Case__r.SVMXC__SContract_Business_Hour__c,SVMXC__Priority__c,SVMXC__Order_Type__c from SVMXC__Service_Order__c where id IN : lstWorkOrderId and SVMXC__SLA_Terms__c != null]);
            system.debug('mapWorkOrders'+mapWorkOrders);
            for(String str : mapWorkOrders.keyset()){
                mapSLAIdWorkOrder.put(mapWorkOrders.get(str).SVMXC__SLA_Terms__c, mapWorkOrders.get(str));
            }
            
            if(isAllType){
                lstSLADetails = [Select SVMXC__SLA_Terms__c, SVMXC__Priority__c, SVMXC__Commitment_Type__c,  SVMXC__Business_Hours__c, SVMXC__Business_Hours_Source__c, Id, SVMXC__Type__c, SVMXC__Clock_Starts_From__c  From SVMXC__SLA_Detail__c where SVMXC__Commitment_Type__c != null And SVMXC__SLA_Terms__c IN : mapSLAIdWorkOrder.keyset()];
            }
            else{
                lstSLADetails = [Select SVMXC__SLA_Terms__c, SVMXC__Priority__c, SVMXC__Commitment_Type__c,  SVMXC__Business_Hours__c, SVMXC__Business_Hours_Source__c, Id, SVMXC__Type__c, SVMXC__Clock_Starts_From__c  From SVMXC__SLA_Detail__c where SVMXC__Commitment_Type__c IN : strCommitmentType And SVMXC__SLA_Terms__c IN : mapSLAIdWorkOrder.keyset()];
            }
            system.debug('lstSLADetails'+lstSLADetails);
        }
        else if(lstCaseId.size()>0){
            mapCases.putall([select Id, SVMXC__SLA_Terms__r.SVMXC__Business_Hours__c, Account.SVMXC__Access_Hours__c,SVMXC__Component__r.SVMXC__Access_Hours__c, SVMXC__SContract_Business_Hour__c, Type, Priority from Case where id IN : lstCaseId and SVMXC__SLA_Terms__c != null]); 
            system.debug('mapCases'+mapCases);
            for(String str : mapCases.keyset()){
                mapSLAIdCases.put(mapCases.get(str).SVMXC__SLA_Terms__c, mapCases.get(str));
            }
            
            if(isAllType){
                lstSLADetails = [Select SVMXC__SLA_Terms__c, SVMXC__Priority__c, SVMXC__Commitment_Type__c,  SVMXC__Business_Hours__c, SVMXC__Business_Hours_Source__c, Id, SVMXC__Type__c, SVMXC__Clock_Starts_From__c  From SVMXC__SLA_Detail__c where SVMXC__Commitment_Type__c != null And SVMXC__SLA_Terms__c IN : mapSLAIdCases.keyset()];
            }
            else{
                lstSLADetails = [Select SVMXC__SLA_Terms__c, SVMXC__Priority__c, SVMXC__Commitment_Type__c,  SVMXC__Business_Hours__c, SVMXC__Business_Hours_Source__c, Id, SVMXC__Type__c, SVMXC__Clock_Starts_From__c  From SVMXC__SLA_Detail__c where SVMXC__Commitment_Type__c IN : strCommitmentType And SVMXC__SLA_Terms__c IN : mapSLAIdCases.keyset()];
            }
            system.debug('lstSLADetails'+lstSLADetails);
        }
        
        map<String,list<SVMXC__SLA_Detail__c>> mapSLAIdSLADetail = new map<String,list<SVMXC__SLA_Detail__c>>();
        
        for(SVMXC__SLA_Detail__c slaDetail : lstSLADetails){
            if(!mapSLAIdSLADetail.containskey(slaDetail.SVMXC__SLA_Terms__c))
                mapSLAIdSLADetail.put(slaDetail.SVMXC__SLA_Terms__c, new list<SVMXC__SLA_Detail__c>());
            mapSLAIdSLADetail.get(slaDetail.SVMXC__SLA_Terms__c).add(slaDetail);        
        }
        system.debug('mapSLAIdSLADetail'+mapSLAIdSLADetail);
        
        for(String str : mapSLAIdSLADetail.keyset()){
            if(mapSLAIdSLADetail.get(Str).size() > 0){
                String initialResponseBH;
                String onsiteResponseBH;
                String reslutionBH;
                String restorationBH;
                String initialClockStartField;
                String onsiteClockStartField;
                String resolveClockStartField;
                String restoreClockStartField;
                
                for(SVMXC__SLA_Detail__c slaDetail : mapSLAIdSLADetail.get(Str)){
                    if(slaDetail.SVMXC__Commitment_Type__c == 'InitialResponse'){
                        if(lstWorkOrderId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Priority__c) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Order_Type__c) || slaDetail.SVMXC__Type__c.equals('All'))){
                            initialResponseBH = businessHourIdForCommitmentType(slaDetail, mapSLAIdWorkOrder, null, str, 'Work Order');
                            initialClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                        else if(lstCaseId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdCases.get(str).Priority) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdCases.get(str).Type) || slaDetail.SVMXC__Type__c.equals('All'))){
                            initialResponseBH = businessHourIdForCommitmentType(slaDetail, null, mapSLAIdCases, str, 'Case');
                            initialClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                    }
                    else if(slaDetail.SVMXC__Commitment_Type__c == 'OnsiteResponse'){
                        if(lstWorkOrderId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Priority__c) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Order_Type__c) || slaDetail.SVMXC__Type__c.equals('All'))){
                            onsiteResponseBH = businessHourIdForCommitmentType(slaDetail, mapSLAIdWorkOrder, null, str, 'Work Order');
                            onsiteClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                        else if(lstCaseId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdCases.get(str).Priority) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdCases.get(str).Type) || slaDetail.SVMXC__Type__c.equals('All'))){
                            onsiteResponseBH = businessHourIdForCommitmentType(slaDetail, null, mapSLAIdCases, str, 'Case');
                            onsiteClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                    }
                    else if(slaDetail.SVMXC__Commitment_Type__c == 'Resolution'){
                        if(lstWorkOrderId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Priority__c) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Order_Type__c) || slaDetail.SVMXC__Type__c.equals('All'))){
                            reslutionBH = businessHourIdForCommitmentType(slaDetail, mapSLAIdWorkOrder, null, str, 'Work Order');
                            resolveClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                        else if(lstCaseId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdCases.get(str).Priority) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdCases.get(str).Type) || slaDetail.SVMXC__Type__c.equals('All'))){
                            reslutionBH = businessHourIdForCommitmentType(slaDetail, null, mapSLAIdCases, str, 'Case');
                            resolveClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                    }
                    else if(slaDetail.SVMXC__Commitment_Type__c == 'Restoration'){
                        if(lstWorkOrderId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Priority__c) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdWorkOrder.get(str).SVMXC__Order_Type__c) || slaDetail.SVMXC__Type__c.equals('All'))){
                            restorationBH = businessHourIdForCommitmentType(slaDetail, mapSLAIdWorkOrder, null, str, 'Work Order');
                            restoreClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                        else if(lstCaseId.size()>0 && slaDetail.SVMXC__Priority__c.equals(mapSLAIdCases.get(str).Priority) && (slaDetail.SVMXC__Type__c.equals(mapSLAIdCases.get(str).Type) || slaDetail.SVMXC__Type__c.equals('All'))){
                            restorationBH = businessHourIdForCommitmentType(slaDetail, null, mapSLAIdCases, str, 'Case');
                            restoreClockStartField = slaDetail.SVMXC__Clock_Starts_From__c;
                        }
                    }
                }
                BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
                if(lstWorkOrderId.size()>0)
                    mapWorkOrderIdBusinessHourInfo.put(mapSLAIdWorkOrder.get(str).Id, new SLAT_SLABHInfo(initialResponseBH,onsiteResponseBH,reslutionBH,restorationBH,bh.id,initialClockStartField,onsiteClockStartField,resolveClockStartField,restoreClockStartField));
                else if(lstCaseId.size()>0)
                    mapCaseIdBusinessHourInfo.put(mapSLAIdCases.get(str).Id, new SLAT_SLABHInfo(initialResponseBH,onsiteResponseBH,reslutionBH,restorationBH,bh.id,initialClockStartField,onsiteClockStartField,resolveClockStartField,restoreClockStartField)); 
            }
        }
        system.debug('mapWorkOrderIdBusinessHourInfo'+mapWorkOrderIdBusinessHourInfo);
        system.debug('mapCaseIdBusinessHourInfo'+mapCaseIdBusinessHourInfo);
        if(lstWorkOrderId.size()>0)
            response.mapWorkOrderIdBusinessHourInfo = mapWorkOrderIdBusinessHourInfo;
        else if(lstCaseId.size()>0)
            response.mapCaseIdBusinessHourInfo = mapCaseIdBusinessHourInfo;
        return response;
    }
    
    //method for get Business hour id corresponding to commitment type 
    private String businessHourIdForCommitmentType(SVMXC__SLA_Detail__c slaDetail, map<String,SVMXC__Service_Order__c> mapSLAIdWorkOrder, map<String,Case> mapSLAIdCases, String str, String strOjbectName){
        String strBusinessHourId ;
        
        if(slaDetail.SVMXC__Business_Hours_Source__c == 'Account'){
            if(strOjbectName.equals('Work Order'))
                strBusinessHourId = mapSLAIdWorkOrder.get(str).SVMXC__Company__r.SVMXC__Access_Hours__c;
            else if(strOjbectName.equals('Case'))
                strBusinessHourId = mapSLAIdCases.get(str).Account.SVMXC__Access_Hours__c;
        }
        else if(slaDetail.SVMXC__Business_Hours_Source__c == 'Product'){
            if(strOjbectName.equals('Work Order'))
                strBusinessHourId = mapSLAIdWorkOrder.get(str).SVMXC__Component__r.SVMXC__Access_Hours__c;
            else if(strOjbectName.equals('Case'))
                strBusinessHourId = mapSLAIdCases.get(str).SVMXC__Component__r.SVMXC__Access_Hours__c;
        }
        else if(slaDetail.SVMXC__Business_Hours_Source__c == 'Contract'){
            if(strOjbectName.equals('Work Order'))
                strBusinessHourId = mapSLAIdWorkOrder.get(str).SVMXC__Case__r.SVMXC__SContract_Business_Hour__c;
            else if(strOjbectName.equals('Case'))
                strBusinessHourId = mapSLAIdCases.get(str).SVMXC__SContract_Business_Hour__c;
        }
        else if(slaDetail.SVMXC__Business_Hours_Source__c == 'SLA'){
            if(strOjbectName.equals('Work Order'))
                strBusinessHourId = mapSLAIdWorkOrder.get(str).SVMXC__SLA_Terms__r.SVMXC__Business_Hours__c;
            else if(strOjbectName.equals('Case'))
                strBusinessHourId = mapSLAIdCases.get(str).SVMXC__SLA_Terms__r.SVMXC__Business_Hours__c;
        }
        else if(slaDetail.SVMXC__Business_Hours_Source__c == 'Custom')
            strBusinessHourId = slaDetail.SVMXC__Business_Hours__c;
        
        System.debug('strBusinessHourId in method :'+strBusinessHourId);
        return strBusinessHourId;
    }
    
    //added by Manish for calculating response mins by giving map of new work order and old work order
    public void calculateResponseTimeForWO(map<String,SVMXC__Service_Order__c> mapIdWorkOrder, map<String,SVMXC__Service_Order__c> mapOldIdWorkOrder){
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<Task> lstTask = [SELECT Id, CreatedDate, Subject, WhatId FROM Task WHERE WhatId IN : mapIdWorkOrder.keyset()];
        Map<String, List<Task>> mapWoIdListTask = new Map<String, List<Task>>();
        for(Task objTask : lstTask){
            if(!mapWoIdListTask.containskey(objTask.WhatId))
                mapWoIdListTask.put(objTask.WhatId, new List<Task>());
            mapWoIdListTask.get(objTask.WhatId).add(objTask);
        }
        
        List<SLAT_Calculation.SLAT_StringListMap> listOfStringListMap = new List<SLAT_Calculation.SLAT_StringListMap>();
        List<String> lstWorkOid = new List<String>();
        lstWorkOid.addAll(mapIdWorkOrder.keyset());
        listOfStringListMap.add(new SLAT_Calculation.SLAT_StringListMap('WORKORDERIDS', lstWorkOid));
        
        SLAT_Calculation.SLAT_Request objSLAT_Request = new SLAT_Calculation.SLAT_Request();
        objSLAT_Request.listOfStringMap = new List<SLAT_Calculation.SLAT_StringMap>();
        objSLAT_Request.listOfStringListMap = listOfStringListMap;
        
        SLAT_Calculation objSLAT_Calculation = new SLAT_Calculation();
        SLAT_Calculation.SLAT_Response objSLAT_Response = objSLAT_Calculation.slaBusinessHoursForWO(objSLAT_Request);
        Map<String,SLAT_SLABHInfo> mapWorkOrderIdBusinessHourInfo = objSLAT_Response.mapWorkOrderIdBusinessHourInfo;
        
        for(String WOID : mapWorkOrderIdBusinessHourInfo.keyset()){
            SVMXC__Service_Order__c newWO = mapIdWorkOrder.get(WOID);
            SVMXC__Service_Order__c oldWO = mapOldIdWorkOrder.get(WOID);
            SLAT_Calculation.SLAT_SLABHInfo objSLAT_SLABHInfo = mapWorkOrderIdBusinessHourInfo.get(WOID);
            List<Task> lstSortedTask = new List<Task>();
            if(mapWoIdListTask.containskey(newWO.id) && mapWoIdListTask.get(newWO.id).size()>0)
                lstSortedTask = sortListOfTask(mapWoIdListTask.get(newWO.id));
            
            String strInitialClkStartField = objSLAT_SLABHInfo.initialClockStartField;
            String strOnsiteClkStartField = objSLAT_SLABHInfo.onsiteClockStartField;
            String strRestoreClkStartField = objSLAT_SLABHInfo.restoreClockStartField;
            String strResolveClkStartField = objSLAT_SLABHInfo.resolveClockStartField;
            
            if(strInitialClkStartField != null && newWO.SVMXC__Actual_Initial_Response__c != null && newWO.get(strInitialClkStartField) != null && (newWO.SVMXC__Actual_Initial_Response__c != oldWO.SVMXC__Actual_Initial_Response__c || newWO.get(strInitialClkStartField) != oldWO.get(strInitialClkStartField)))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Initial_Response__c = calculateResponseTimeCommitment(newWO, null, objSLAT_SLABHInfo, lstSortedTask, 'InitialResponse');
            else if(newWO.SVMXC__Actual_Initial_Response__c == null || (strInitialClkStartField != null && newWO.get(strInitialClkStartField) == null))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Initial_Response__c = null;
            
            if(strOnsiteClkStartField != null && newWO.SVMXC__Actual_Onsite_Response__c != null && newWO.get(strOnsiteClkStartField) != null && (newWO.SVMXC__Actual_Onsite_Response__c != oldWO.SVMXC__Actual_Onsite_Response__c || newWO.get(strOnsiteClkStartField) != oldWO.get(strOnsiteClkStartField)))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Onsite_Response__c = calculateResponseTimeCommitment(newWO, null, objSLAT_SLABHInfo, lstSortedTask, 'OnsiteResponse');
            else if(newWO.SVMXC__Actual_Onsite_Response__c == null || (strOnsiteClkStartField != null && newWO.get(strOnsiteClkStartField) == null))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Onsite_Response__c = null;
            
            if(strRestoreClkStartField != null && newWO.SVMXC__Actual_Restoration__c != null && newWO.get(strRestoreClkStartField) != null && (newWO.SVMXC__Actual_Restoration__c != oldWO.SVMXC__Actual_Restoration__c || newWO.get(strRestoreClkStartField) != oldWO.get(strRestoreClkStartField)))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Restore__c = calculateResponseTimeCommitment(newWO, null, objSLAT_SLABHInfo, lstSortedTask, 'Restoration');
            else if(newWO.SVMXC__Actual_Restoration__c == null || (strRestoreClkStartField != null && newWO.get(strRestoreClkStartField) == null))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Restore__c = null;
            
            if(strResolveClkStartField != null && newWO.SVMXC__Actual_Resolution__c != null && newWO.get(strResolveClkStartField) != null && (newWO.SVMXC__Actual_Resolution__c != oldWO.SVMXC__Actual_Resolution__c || newWO.get(strResolveClkStartField) != oldWO.get(strResolveClkStartField)))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Resolve__c = calculateResponseTimeCommitment(newWO, null, objSLAT_SLABHInfo, lstSortedTask, 'Resolution');
                //Jaysukh :Below condition changed as part of defect 040574
            else if(newWO.SVMXC__Actual_Resolution__c == null ||(strResolveClkStartField != null && newWO.get(strResolveClkStartField) == null))
                mapIdWorkOrder.get(WOID).SVMXC__Time_to_Resolve__c = null;
        }
    }
    
    //method to calculate actual response time according to different commitment type for case and work order
    private Double calculateResponseTimeCommitment(SVMXC__Service_Order__c newWO, Case newCase, SLAT_Calculation.SLAT_SLABHInfo objSLAT_SLABHInfo, List<Task> lstSortedTask, String strCommitmentType){
        String strBusinessHourId;
        String strClockStartFieldName;
        DateTime dtClockStart;
        DateTime dtActualDateTime;
        Double dblActualResponseTime = 0.0;
        
        //getting business hour id
        if(strCommitmentType.equals('InitialResponse')){
            strBusinessHourId = objSLAT_SLABHInfo.initialResponseBH;
            strClockStartFieldName = objSLAT_SLABHInfo.initialClockStartField;
            if(newWO != null)
                dtActualDateTime = newWO.SVMXC__Actual_Initial_Response__c;
            else if(newCase != null)
                dtActualDateTime = newCase.SVMXC__Actual_Initial_Response__c;
        }
        else if(strCommitmentType.equals('OnsiteResponse')){
            strBusinessHourId = objSLAT_SLABHInfo.onsiteResponseBH;
            strClockStartFieldName = objSLAT_SLABHInfo.onsiteClockStartField;
            if(newWO != null)
                dtActualDateTime = newWO.SVMXC__Actual_Onsite_Response__c;
            else if(newCase != null)
                dtActualDateTime = newCase.SVMXC__Actual_Onsite_Response__c;
        }
        else if(strCommitmentType.equals('Restoration')){
            strBusinessHourId = objSLAT_SLABHInfo.restorationBH;
            strClockStartFieldName = objSLAT_SLABHInfo.restoreClockStartField;
            if(newWO != null)
                dtActualDateTime = newWO.SVMXC__Actual_Restoration__c;
            else if(newCase != null)
                dtActualDateTime = newCase.SVMXC__Actual_Restoration__c;
        }
        else if(strCommitmentType.equals('Resolution')){
            strBusinessHourId = objSLAT_SLABHInfo.reslutionBH;
            strClockStartFieldName = objSLAT_SLABHInfo.resolveClockStartField;
            if(newWO != null)
                dtActualDateTime = newWO.SVMXC__Actual_Resolution__c;
            else if(newCase != null)
                dtActualDateTime = newCase.SVMXC__Actual_Resolution__c;
        }
        if(strBusinessHourId == null)
            strBusinessHourId = objSLAT_SLABHInfo.defaultBH;
        if(newWO != null)
            dtClockStart = DateTime.valueOf(newWO.get(strClockStartFieldName));
        else if(newCase != null)
            dtClockStart = DateTime.valueOf(newCase.get(strClockStartFieldName));
        
        System.debug(Logginglevel.INFO,'strBusinessHourId in calculation method:'+strBusinessHourId);
        System.debug(Logginglevel.INFO,'dtClockStart  in calculation method:'+dtClockStart);
        System.debug(Logginglevel.INFO,'dtActualDateTime in calculation method:'+dtActualDateTime);
        Long lngResponseTimeInMilliSec = 0;
        Long lngTotalPauseTimeInMilliSec = 0;
        if(dtClockStart != null && dtActualDateTime != null){
            //calculating response time
            lngResponseTimeInMilliSec = BusinessHours.diff(strBusinessHourId, dtClockStart, dtActualDateTime);
            System.debug(Logginglevel.INFO,'Response time in seconds : '+lngResponseTimeInMilliSec);
            
            //calculating pause time
            if(lstSortedTask.size()>0){
                DateTime dtPauseDateTime;
                DateTime dtResumeDateTime;
                Boolean isStartTimeAvailable = false;
                for(Task tsk : lstSortedTask){
                    if(isStartTimeAvailable == false && tsk.Subject.equals('SLA Clock Stop')){
                        dtPauseDateTime = tsk.CreatedDate;
                        isStartTimeAvailable = true;
                    }
                    else if(isStartTimeAvailable == true && tsk.Subject.equals('SLA Clock Start')){
                        dtResumeDateTime = tsk.CreatedDate;
                        Long lngSinglePauseTimeInMilliSec = BusinessHours.diff(strBusinessHourId, dtPauseDateTime, dtResumeDateTime);
                        if(lngSinglePauseTimeInMilliSec > 0)
                            lngTotalPauseTimeInMilliSec += lngSinglePauseTimeInMilliSec;
                        isStartTimeAvailable = false;
                    }
                }
                System.debug(Logginglevel.INFO,'Total Pause MilliSeconds for '+strCommitmentType+' lngTotalPauseTimeInMilliSec: '+lngTotalPauseTimeInMilliSec);
            }
            //deducting pause milliseconds from response time
            Double dblActualResponseTimeInMilliSec = Double.valueOf(lngResponseTimeInMilliSec - lngTotalPauseTimeInMilliSec);
            Double dblsec = dblActualResponseTimeInMilliSec/1000;
            dblActualResponseTime = dblsec/60;
            System.debug(Logginglevel.INFO,'Actual response time for '+strCommitmentType+' dblActualResponseTime: '+dblActualResponseTime);
        }
        return dblActualResponseTime;
    }
    
    //method to sort list of task on the basis of created date in ascending order
    private List<Task> sortListOfTask(List<Task> lstTsk){
        List<DateTime> lstDateTime =  new List<DateTime>();
        Map<DateTime, Task> mapCreatedDateTask = new Map<DateTime, Task>();
        for(Task tsk: lstTsk){
            mapCreatedDateTask.put(tsk.CreatedDate, tsk);
            lstDateTime.add(tsk.CreatedDate);
        }
        List<Task> lstNewTask = new List<Task>();
        lstDateTime.sort();
        for(DateTime dt: lstDateTime)
            lstNewTask.add(mapCreatedDateTask.get(dt));
        System.debug(Logginglevel.INFO,'Sorted list of task :'+lstNewTask);
        return lstNewTask;
    }
    
    //added by Manish for calculating response mins by giving map of new case and old case
    public void calculateResponseTimeForCase(map<String, Case> mapIdCase, map<String, Case> mapOldIdCase){
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<Task> lstTask = [SELECT Id, CreatedDate, Subject, WhatId FROM Task WHERE WhatId IN : mapIdCase.keyset()];
        Map<String, List<Task>> mapCaseIdListTask = new Map<String, List<Task>>();
        for(Task objTask : lstTask){
            if(!mapCaseIdListTask.containskey(objTask.WhatId))
                mapCaseIdListTask.put(objTask.WhatId, new List<Task>());
            mapCaseIdListTask.get(objTask.WhatId).add(objTask);
        }
        
        List<SLAT_Calculation.SLAT_StringListMap> listOfStringListMap = new List<SLAT_Calculation.SLAT_StringListMap>();
        List<String> lstCaseId = new List<String>();
        lstCaseId.addAll(mapIdCase.keyset());
        listOfStringListMap.add(new SLAT_Calculation.SLAT_StringListMap('CASEIDS', lstCaseId));
        
        SLAT_Calculation.SLAT_Request objSLAT_Request = new SLAT_Calculation.SLAT_Request();
        objSLAT_Request.listOfStringMap = new List<SLAT_Calculation.SLAT_StringMap>();
        objSLAT_Request.listOfStringListMap = listOfStringListMap;
        
        SLAT_Calculation objSLAT_Calculation = new SLAT_Calculation();
        SLAT_Calculation.SLAT_Response objSLAT_Response = objSLAT_Calculation.slaBusinessHoursForWO(objSLAT_Request);
        Map<String,SLAT_SLABHInfo> mapCaseIdBusinessHourInfo = objSLAT_Response.mapCaseIdBusinessHourInfo;
        
        for(String CaseID : mapCaseIdBusinessHourInfo.keyset()){
            Case newCase = mapIdCase.get(CaseID);
            Case oldCase = mapOldIdCase.get(CaseID);
            SLAT_Calculation.SLAT_SLABHInfo objSLAT_SLABHInfo = mapCaseIdBusinessHourInfo.get(CaseID);
            List<Task> lstSortedTask = new List<Task>();
            if(mapCaseIdListTask.containskey(newCase.id) && mapCaseIdListTask.get(newCase.id).size()>0)
                lstSortedTask = sortListOfTask(mapCaseIdListTask.get(newCase.id));
                
            String strInitialClkStartField = objSLAT_SLABHInfo.initialClockStartField;
            String strOnsiteClkStartField = objSLAT_SLABHInfo.onsiteClockStartField;
            String strRestoreClkStartField = objSLAT_SLABHInfo.restoreClockStartField;
            String strResolveClkStartField = objSLAT_SLABHInfo.resolveClockStartField;
            system.debug('strInitialClkStartField=='+strInitialClkStartField);
            system.debug('newCase.SVMXC__Actual_Initial_Response__c=='+newCase.SVMXC__Actual_Initial_Response__c);
            system.debug('newCase.get(strInitialClkStartField)=='+newCase.get(strInitialClkStartField));
            system.debug('newCase=='+newCase);
            system.debug('oldCase=='+oldCase);
            if(strInitialClkStartField != null && newCase.SVMXC__Actual_Initial_Response__c != null && newCase.get(strInitialClkStartField) != null && (newCase.SVMXC__Actual_Initial_Response__c != oldCase.SVMXC__Actual_Initial_Response__c || newCase.get(strInitialClkStartField) != oldCase.get(strInitialClkStartField)))
                mapIdCase.get(CaseID).SVMXC__Time_to_Initial_Response__c = calculateResponseTimeCommitment(null, newCase, objSLAT_SLABHInfo, lstSortedTask, 'InitialResponse');
            else if(newCase.SVMXC__Actual_Initial_Response__c == null || (strInitialClkStartField != null && newCase.get(strInitialClkStartField) == null))
                mapIdCase.get(CaseID).SVMXC__Time_to_Initial_Response__c = null;

            if(strOnsiteClkStartField != null && newCase.SVMXC__Actual_Onsite_Response__c != null && newCase.get(strOnsiteClkStartField) != null && (newCase.SVMXC__Actual_Onsite_Response__c != oldCase.SVMXC__Actual_Onsite_Response__c || newCase.get(strOnsiteClkStartField) != oldCase.get(strOnsiteClkStartField)))
                mapIdCase.get(CaseID).SVMXC__Time_to_Onsite_Response__c = calculateResponseTimeCommitment(null, newCase, objSLAT_SLABHInfo, lstSortedTask, 'OnsiteResponse');
            else if(newCase.SVMXC__Actual_Onsite_Response__c == null || (strOnsiteClkStartField != null && newCase.get(strOnsiteClkStartField) == null))
                mapIdCase.get(CaseID).SVMXC__Time_to_Onsite_Response__c = null;
            
            if(strRestoreClkStartField != null && newCase.SVMXC__Actual_Restoration__c != null && newCase.get(strRestoreClkStartField) != null && (newCase.SVMXC__Actual_Restoration__c != oldCase.SVMXC__Actual_Restoration__c || newCase.get(strRestoreClkStartField) != oldCase.get(strRestoreClkStartField)))
                mapIdCase.get(CaseID).SVMXC__Time_to_Restore__c = calculateResponseTimeCommitment(null, newCase, objSLAT_SLABHInfo, lstSortedTask, 'Restoration');
            else if(newCase.SVMXC__Actual_Restoration__c == null || (strRestoreClkStartField != null && newCase.get(strRestoreClkStartField) == null))
                mapIdCase.get(CaseID).SVMXC__Time_to_Restore__c = null;
            
            if(strResolveClkStartField != null && newCase.SVMXC__Actual_Resolution__c != null && newCase.get(strResolveClkStartField) != null && (newCase.SVMXC__Actual_Resolution__c != oldCase.SVMXC__Actual_Resolution__c || newCase.get(strResolveClkStartField) != oldCase.get(strResolveClkStartField)))
                mapIdCase.get(CaseID).SVMXC__Time_to_Resolve__c = calculateResponseTimeCommitment(null, newCase, objSLAT_SLABHInfo, lstSortedTask, 'Resolution');
            else if(newCase.SVMXC__Actual_Resolution__c == null || (strResolveClkStartField != null && newCase.get(strResolveClkStartField) == null))
                mapIdCase.get(CaseID).SVMXC__Time_to_Resolve__c = null;
        }
    }
}