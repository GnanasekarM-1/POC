public with Sharing class WORD_OptimaxCall
{
    public SVMXC__ServiceMax_Processes__c Disprocess = new SVMXC__ServiceMax_Processes__c();
    public List<SVMXC__ServiceMax_Processes__c> TerritoryLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ScheduleRunLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ltpScheduleRunLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String, SVMXC__SVMX_Jobs__c> mapOfTerrIdRTOjob = new Map<String, SVMXC__SVMX_Jobs__c>();
    public Map<String, SVMXC__SVMX_Jobs__c> mapOfTerrIdLTPJob = new Map<String, SVMXC__SVMX_Jobs__c>();
    public List<RecordType> RecordTypes = new List<RecordType>();
    public list<SVMXC__Service_Zone__c> lstZone = new list<SVMXC__Service_Zone__c>();
    public list<id> lstTerritoryId = new list<id>();    
    public map<id,String> mapTerritoryZoneDef = new map<id,String>();
    map<id,map<String,String>> mapTerrZone = new map<id,map<String,String>>();
    public string RuleRecordTypeId;
    public string DispatchProRecordTypeId;
    public string Schedule_Rtype_Id;
    public String Status = '';
    
    /** Below list stores the Territory Ids of ECO_LTP cron. This is used later to create the Job records for LTP **/
    List<String> lstStrECO_LTPTerritoryIds = new List<String>();
    
    /** Initializing with empty string as they are used inside LTP method without to build CRON **/
    public String CORNExpressionFull0Min = '';
    public String CORNExpressionIncr0Min = '';
    public String CORNExpressionFull5Min = '';
    public String CORNExpressionIncr5Min = '';
    public String CORNExpressionFull10Min = '';
    public String CORNExpressionIncr10Min = '';
    public String CORNExpressionFull15Min = '';
    public String CORNExpressionIncr15Min = '';
    public String CORNExpressionFull20Min = '';
    public String CORNExpressionIncr20Min = '';
    public String CORNExpressionFull25Min = '';
    public String CORNExpressionIncr25Min = '';
    public String CORNExpressionFull30Min = '';
    public String CORNExpressionIncr30Min = '';
    public String CORNExpressionFull35Min = '';
    public String CORNExpressionIncr35Min = '';
    public String CORNExpressionFull40Min = '';
    public String CORNExpressionIncr40Min = '';
    public String CORNExpressionFull45Min = '';
    public String CORNExpressionIncr45Min = '';
    public String CORNExpressionFull50Min = '';
    public String CORNExpressionIncr50Min = '';
    public String CORNExpressionFull55Min = '';
    public String CORNExpressionIncr55Min = '';
    public List<String> Split1 = new List<String>(); 
    public List<String> L1 = new List<String>();
    public List<String> L2 = new List<String>(); 
    public Map<String,String> MapOfStatus = new Map<String,String>();
    public Map<String,String> MapOfDeletedTerritory = new Map<String,String>(); 
    //public String DPID = System.currentPageReference().getParameters().get('dpid');
    public String DPID = ApexPages.currentPage().getParameters().get('dpid');
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD015');
    // SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD015'); 
    WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
    public Boolean unfailed=false;
    public WORD_SetupDispatchProcess.ErrorMessage errorMessage;
    
    /** Added the below variables to store LTP cron expressions **/
    public string ltpCORNExpressionFull0Min = '';
    public string ltpCORNExpressionFull5Min = '';
    public string ltpCORNExpressionFull10Min = '';
    public string ltpCORNExpressionFull15Min = '';
    public string ltpCORNExpressionFull20Min = '';
    public string ltpCORNExpressionFull25Min = '';
    public string ltpCORNExpressionFull30Min = '';
    public string ltpCORNExpressionFull35Min = '';
    public string ltpCORNExpressionFull40Min = '';
    public string ltpCORNExpressionFull45Min = '';
    public string ltpCORNExpressionFull50Min = '';
    public string ltpCORNExpressionFull55Min = '';

    public WORD_OptimaxCall()
    {
        Boolean runConstructorLogic = Boolean.valueOf(ApexPages.currentPage().getParameters().get('runConstructorLogic'));
        
        if(!runConstructorLogic) {
            String messagesString =  ApexPages.currentPage().getParameters().get('messagesString');
            system.debug('******ErrorMessaagesSize******'+messagesString);
            List<String> messagesList = new List<String>();
            if(messagesString != null && messagesString.contains('ENDOFMESSAGE')) {
                messagesList = messagesString.split('ENDOFMESSAGE');
            } else if(messagesString != null) {
                messagesList.add(messagesString);
            }
            for(String msg : messagesList) {
                Integer splitIndex = msg.indexOf(':');
                if (msg.split(':')[0] =='ERROR') {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, msg.substring(splitIndex+1)));
                } else if(msg.split(':')[0] == 'CONFIRM') {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, msg.substring(splitIndex+1)));
                }
            }
            
        } else {
            try
            {
                //Query The Record Type
                RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate,r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType= \'SVMXC__ServiceMax_Config_Data__c\')');
                for(RecordType r : RecordTypes)
                {
                    if(r.Name == 'SVMX Rule')
                    {
                        RuleRecordTypeId = r.id;
                    }
                    if(r.Name == 'Dispatch Process')
                    {
                        DispatchProRecordTypeId = r.id;
                    }
                    
                    /** added for LTP **/
                    if(r.Name == 'Schedule' && r.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                        Schedule_Rtype_Id = r.Id;
                }
                //Query Dispatch Process 
                /** Added the following fields for LTP - SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Default_On__c, SVMXC__Confirmation_Message__c **/
                Disprocess = Database.Query('Select s.SystemModstamp,s.SVMXC__Dispatch_Timezone__c, SVMXC__Dispatch_Process_Status__c,s.SVMXC__MTTS_Minutes__c, s.SVMXC__Weight_Total_Distance__c, s.SVMXC__Weight_Time_Window__c,s.SVMXC__Weight_Route_Time__c, s.SVMXC__Weight_Route_Distance__c, s.SVMXC__Weight_Node_Type__c,s.SVMXC__Territory__c, s.SVMXC__Technician_User__c, s.SVMXC__Technician_Service_Group__c,s.SVMXC__Start_Time__c, s.SVMXC__Start_Date__c, s.SVMXC__Schedule_Event__c,     s.SVMXC__Runs_Every_Wednesday__c, s.SVMXC__Runs_Every_Tuesday__c, s.SVMXC__Runs_Every_Thursday__c,s.SVMXC__Runs_Every_Sunday__c, s.SVMXC__Runs_Every_Saturday__c, s.SVMXC__Runs_Every_Monday__c, s.SVMXC__Runs_Every_Friday__c, s.SVMXC__Route_Type__c, s.SVMXC__Product_Match_Enabled__c, s.SVMXC__Preferred_Tech_Enabled__c, s.SVMXC__Frequency__c, s.SVMXC__Final_Exception_Process__c,                                          s.SVMXC__Expertise_Match_Enabled__c, s.SVMXC__End_Date__c, SVMXC__Dispatch_Threshold__c, SVMXC__Optimizer_Sync_Interval__c, s.SVMXC__Email_On_Success__c, s.SVMXC__Email_On_Error__c, s.SVMXC__Distance_And_Time__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Calendar_Start_Type__c, s.SVMXC__Calendar_Start_Days__c, s.SVMXC__Calendar_End_Type__c, s.SVMXC__Calendar_End_Days__c, s.SVMXC__Assign_Work_Order_To__c, s.SVMXC__Assign_To_Technician__c, s.SVMXC__Assign_To_Queue__c, s.SVMXC__Assign_To_Dispatcher__c, s.SVMXC__Values__c, s.SVMXC__Target_Record_Type__c, s.SVMXC__Target_Object_Name__c, s.SVMXC__Submodule__c, s.SVMXC__SubmoduleID__c, s.SVMXC__Source_Object_Name__c, s.SVMXC__Settings_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_Type__c, s.SVMXC__SettingID__c, s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Search_Order__c, s.SVMXC__Rule_Type__c, s.SVMXC__Record_Type_Name__c, s.SVMXC__Process__c, s.SVMXC__ProcessID__c, s.SVMXC__Pick_First_Match__c, s.SVMXC__Parent_Object_Criteria__c, s.SVMXC__Name__c, s.SVMXC__Module__c, s.SVMXC__ModuleID__c, s.SVMXC__Match_Contact__c, s.SVMXC__Match_Account__c, s.SVMXC__MapID__c, s.SVMXC__IsStandard__c, s.SVMXC__IsPrivate__c, s.SVMXC__Installation_Key__c, s.SVMXC__Include_Top_Level__c, s.SVMXC__Include_Product__c, s.SVMXC__Include_Parent__c, s.SVMXC__Entitlement_Scope__c, s.SVMXC__Entitlement_By__c, s.SVMXC__Description__c, s.SVMXC__Default_Value__c, s.SVMXC__Data_Type__c, s.SVMXC__Counter_Vs_Dates_Rule__c, s.SVMXC__Child_Object_Criteria__c, s.SVMXC__Advance_Expression__c, s.SVMXC__Active__c, s.RecordTypeId, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById,  s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.SVMXC__Window_Height__c, s.SVMXC__Window_Width__c, s.SVMXC__Default_On__c, s.SVMXC__Confirmation_Message__c, s.SVMXC__Optimization_Goal__c From SVMXC__ServiceMax_Processes__c s where id =:DPID and RecordTypeId =:DispatchProRecordTypeId');
                //Query Territories Related to  Disptch Process 
                TerritoryLst = Database.Query('Select s.SystemModstamp,SVMXC__Dispatch_Process_Status__c, SVMXC__Territory__r.name, s.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c, s.SVMXC__Territory__r.SVMXC__Mode_Of_Travel__c, s.SVMXC__Weight_Total_Distance__c,SVMXC__Process__c, s.SVMXC__Weight_Time_Window__c, s.SVMXC__Territory__c, s.SVMXC__Start_Time__c, s.SVMXC__Start_Date__c, s.SVMXC__Sequence__c, s.SVMXC__Schedule_Event__c, s.SVMXC__Runs_Every_Wednesday__c, s.SVMXC__Runs_Every_Tuesday__c, s.SVMXC__Runs_Every_Thursday__c, s.SVMXC__Runs_Every_Sunday__c, s.SVMXC__Runs_Every_Saturday__c, s.SVMXC__Runs_Every_Monday__c, s.SVMXC__Runs_Every_Friday__c, s.SVMXC__Weight_Route_Time__c, s.SVMXC__Route_Type__c, s.SVMXC__Weight_Route_Distance__c, s.SVMXC__Calendar_Start_Days__c, s.SVMXC__Calendar_End_Days__c, s.SVMXC__Product_Match_Enabled__c, s.SVMXC__Expertise_Match_Enabled__c, s.SVMXC__Frequency__c, s.SVMXC__End_Date__c, s.SVMXC__Email_On_Success__c, s.SVMXC__Email_On_Error__c, s.SVMXC__Distance_And_Time__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Weight_Node_Type__c, s.SVMXC__Preferred_Tech_Enabled__c, s.SVMXC__Calendar_Start_Type__c, s.SVMXC__Calendar_End_Type__c, s.SVMXC__Assign_Work_Order_To__c, s.SVMXC__Assign_To_Technician__c, s.SVMXC__Assign_To_Queue__c, s.SVMXC__Assign_To_Dispatcher__c, s.SVMXC__Values__c, s.SVMXC__Target_Record_Type__c, s.SVMXC__Target_Object_Name__c, s.SVMXC__Submodule__c, s.SVMXC__SubmoduleID__c, s.SVMXC__Source_Object_Name__c, s.SVMXC__Settings_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_Type__c, s.SVMXC__SettingID__c, s.SVMXC__Select__c, s.SVMXC__Search_Order__c, s.SVMXC__Rule_Type__c, s.SVMXC__Record_Type_Name__c, s.SVMXC__ProcessID__c, s.SVMXC__Parent_Object_Criteria__c, s.SVMXC__Name__c, s.SVMXC__Module__c, s.SVMXC__ModuleID__c, s.SVMXC__MapID__c, s.SVMXC__IsStandard__c, s.SVMXC__IsPrivate__c, s.SVMXC__Installation_Key__c, s.SVMXC__Description__c, s.SVMXC__Default_Value__c, s.SVMXC__Data_Type__c, s.SVMXC__Child_Object_Criteria__c, s.SVMXC__Advance_Expression__c, s.SVMXC__Active__c, s.RecordTypeId, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c =:DPID and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Territory Access\'');
                //Get the schedule run information
                ScheduleRunLst = Database.Query('Select s.SVMXC__Display_Type__c,s.SVMXC__Expression_Type__c,s.SVMXC__Run_At__c,s.SVMXC__Active__c From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c =:DPID and SVMXC__Expression_Type__c =\'DISP_Schedule\'');

                /** Get the LTP schedule information **/
                ltpScheduleRunLst = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: Schedule_Rtype_Id and SVMXC__Dispatch_Process__c =: DPID];
                
                for(SVMXC__ServiceMax_Processes__c objTerr: TerritoryLst)
                {
                    if(objTerr.SVMXC__Territory__c != null )
                        lstTerritoryId.add(objTerr.SVMXC__Territory__c);
                }

                //retrieve all the LTP job records if already existing for this DP
                List<SVMXC__SVMX_Jobs__c> lstOfLTPJobs = [SELECT Id, SVMXC__SVMX_Process__c, SVMXC__Territory__c, SVMXC__Type__c FROM SVMXC__SVMX_Jobs__c WHERE SVMXC__Territory__c =: lstTerritoryId AND (SVMXC__Type__c = 'LTP' OR SVMXC__Type__c = 'ECO')];

                for(SVMXC__SVMX_Jobs__c eachJob:lstOfLTPJobs) {
                    if(eachJob.SVMXC__Type__c.equalsIgnoreCase('ECO')) {
                        mapOfTerrIdRTOJob.put(eachJob.SVMXC__Territory__c, eachJob);
                    } else if(eachJob.SVMXC__Type__c.equalsIgnoreCase('LTP')) {
                        mapOfTerrIdLTPJob.put(eachJob.SVMXC__Territory__c, eachJob);
                    }
                }

                if(DPID != null)
                    lstZone = [Select id, SVMXC__Zone_Definition__c, SVMXC__Zone_Type__c, SVMXC__Territory__c from SVMXC__Service_Zone__c where SVMXC__Territory__c in : lstTerritoryId];
                    
                for(SVMXC__Service_Zone__c objZone: lstZone)
                {
                    
                    if(objZone.SVMXC__Territory__c != null)
                    {
                        
                        if(objZone.SVMXC__Zone_Type__c == 'Polygon' && objZone.SVMXC__Zone_Definition__c != null  && objZone.SVMXC__Zone_Definition__c != '')
                        {
                            map<string,String> maptypeZoneval= new map<string,String>();
                            if(mapTerrZone.containskey(objZone.SVMXC__Territory__c) )
                            {
                                maptypeZoneval = mapTerrZone.get(objZone.SVMXC__Territory__c);
                                if(maptypeZoneval.containskey('Polygon'))
                                    maptypeZoneval.put('Polygon',maptypeZoneval.get('Polygon') + ',' + objZone.SVMXC__Zone_Definition__c);
                                else
                                    maptypeZoneval.put('Polygon', objZone.SVMXC__Zone_Definition__c);
                                mapTerrZone.put(objZone.SVMXC__Territory__c,maptypeZoneval );
                            }
                            else
                            {
                                if(objZone.SVMXC__Zone_Definition__c != null && objZone.SVMXC__Zone_Definition__c != '')
                                {
                                    maptypeZoneval.put('Polygon',objZone.SVMXC__Zone_Definition__c);
                                    mapTerrZone.put(objZone.SVMXC__Territory__c,maptypeZoneval );
                                }
                                
                            }   
                        }
                        if(objZone.SVMXC__Zone_Type__c == 'Circle' && objZone.SVMXC__Zone_Definition__c != null && objZone.SVMXC__Zone_Definition__c != '')
                        {
                            map<string,String> maptypeZoneval= new map<string,String>();
                            if(mapTerrZone.containskey(objZone.SVMXC__Territory__c))
                            {
                                maptypeZoneval = mapTerrZone.get(objZone.SVMXC__Territory__c);
                                if(maptypeZoneval.containskey('Circle'))
                                    maptypeZoneval.put('Circle',maptypeZoneval.get('Circle') + ',' + objZone.SVMXC__Zone_Definition__c);
                                else
                                    maptypeZoneval.put('Circle',objZone.SVMXC__Zone_Definition__c);
                                mapTerrZone.put(objZone.SVMXC__Territory__c,maptypeZoneval );
                            }
                            else
                            {
                                if(objZone.SVMXC__Zone_Definition__c != null && objZone.SVMXC__Zone_Definition__c != '')
                                {
                                    maptypeZoneval.put('Circle',objZone.SVMXC__Zone_Definition__c);
                                    mapTerrZone.put(objZone.SVMXC__Territory__c,maptypeZoneval );
                                }
                            }   
                        }
                        if(objZone.SVMXC__Zone_Type__c == 'Rectangle' && objZone.SVMXC__Zone_Definition__c != null && objZone.SVMXC__Zone_Definition__c != '')
                        {
                            map<string,String> maptypeZoneval= new map<string,String>();
                            if(mapTerrZone.containskey(objZone.SVMXC__Territory__c))
                            {
                                maptypeZoneval = mapTerrZone.get(objZone.SVMXC__Territory__c);
                                if(maptypeZoneval.containskey('Rectangle'))
                                    maptypeZoneval.put('Rectangle',maptypeZoneval.get('Rectangle') + ',' + objZone.SVMXC__Zone_Definition__c);
                                else
                                    maptypeZoneval.put('Rectangle', objZone.SVMXC__Zone_Definition__c);
                                mapTerrZone.put(objZone.SVMXC__Territory__c,maptypeZoneval );
                            }
                            else
                            {
                                if(objZone.SVMXC__Zone_Definition__c != null && objZone.SVMXC__Zone_Definition__c != '')
                                {
                                    maptypeZoneval.put('Rectangle',objZone.SVMXC__Zone_Definition__c);
                                    mapTerrZone.put(objZone.SVMXC__Territory__c,maptypeZoneval );
                                }
                            }   
                        }
                        
                        
                    }
                    
                }
                System.debug('mapTerritoryZoneDef val   '+mapTerritoryZoneDef);
            }
            catch (Exception ex) 
            {
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'ERROR';
                errorMessage.message = ex.getMessage();
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }

        
        
    }
    public WORD_SetupDispatch_Methods getDispMethods() {return DispMethods;}
    public void setDispMethods(WORD_SetupDispatch_Methods s) {DispMethods = s;} 
    public String decryption1(String Encstr)
    {
        String Decodeddata;
        try
        {
            if(unfailed==true)
                Decodeddata=Encstr;
            else
            {
                blob Decodeblob = EncodingUtil.base64Decode(Encstr);
                Decodeddata = Decodeblob.toString();
            }
        }
        catch(Exception ex)
        {
            unfailed=true;
            Decodeddata = Encstr;
        }
        return Decodeddata;
    }
    public Pagereference SVMX_WSDLCall()
    {
        system.debug('WORD_OptimaxCall::SVMX_WSDLCall():start');
        try
        {
            if(Disprocess.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP()) {
                system.debug('WORD_OptimaxCall::SVMX_WSDLCall():processing for RTO DP');
                if(Disprocess.SVMXC__Default_On__c) {
                    CORNLTPExpression(Disprocess);
                }
                OMAX_ServicemaxCom.territorySchedule[] TList = ECO_CRONExpression(Disprocess);
                /** Below method sends the cron expression for LTP also along with RTO Cron if LTP is defined for this Batch Dispatch process **/
                ECO_OptiMaxWebServiceCall(Disprocess, TList);
            } else if(Disprocess.SVMXC__Dispatch_Method__c == 'Optimized Batch'){
                system.debug('WORD_OptimaxCall::SVMX_WSDLCall():processing for Batch DP');
                CORNExpression(Disprocess);
                /** Build the cron expression for LTP if ltpCheckBox is enabled in the Batch Dispatch Process **/
                if(Disprocess.SVMXC__Default_On__c) {
                    CORNLTPExpression(Disprocess);
                }
                /** Below method sends the cron expression for LTP also along with Batch Cron if LTP is defined for this Batch Dispatch process **/
                OptiMaxWebServiceCall(Disprocess,TerritoryLst);
            } else if(Disprocess.SVMXC__Dispatch_Method__c == 'Long-Term Planner') {
                system.debug('WORD_OptimaxCall::SVMX_WSDLCall():processing for LTP DP');
                CORNLTPExpression(Disprocess);
                OptiMaxWebServiceCall(Disprocess,TerritoryLst);
            }
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
        
    }
    public String CORNExpression(SVMXC__ServiceMax_Processes__c processobj)
    {
        try
        {
            CORNExpressionFull0Min = '';
            CORNExpressionIncr0Min = '';
            CORNExpressionFull5Min = '';
            CORNExpressionIncr5Min = '';
            CORNExpressionFull10Min = '';
            CORNExpressionIncr10Min = '';
            CORNExpressionFull15Min = '';
            CORNExpressionIncr15Min = '';
            CORNExpressionFull20Min = '';
            CORNExpressionIncr20Min = '';
            CORNExpressionFull25Min = '';
            CORNExpressionIncr25Min = '';
            CORNExpressionFull30Min = '';
            CORNExpressionIncr30Min = '';
            CORNExpressionFull35Min = '';
            CORNExpressionIncr35Min = '';
            CORNExpressionFull40Min = '';
            CORNExpressionIncr40Min = '';
            CORNExpressionFull45Min = '';
            CORNExpressionIncr45Min = '';
            CORNExpressionFull50Min = '';
            CORNExpressionIncr50Min = '';
            CORNExpressionFull55Min = '';
            CORNExpressionIncr55Min = '';
            String StartTime;
            List<String> TimeInterval = new List<String>();
            integer intHour;
            String strMin;
            String strSec; 
            String WeekDays = '';
            integer StartYear;
            integer EndYear;
            String strRunExpFull0Min = '';
            String strRunExpIncr0Min = '';
            String strRunExpFull5Min = '';
            String strRunExpIncr5Min = '';
            String strRunExpFull10Min = '';
            String strRunExpIncr10Min = '';
            String strRunExpFull15Min = '';
            String strRunExpIncr15Min = '';
            String strRunExpFull20Min = '';
            String strRunExpIncr20Min = '';
            String strRunExpFull25Min = '';
            String strRunExpIncr25Min = '';
            String strRunExpFull30Min = '';
            String strRunExpIncr30Min = '';
            String strRunExpFull35Min = '';
            String strRunExpIncr35Min = '';
            String strRunExpFull40Min = '';
            String strRunExpIncr40Min = '';
            String strRunExpFull45Min = '';
            String strRunExpIncr45Min = '';
            String strRunExpFull50Min = '';
            String strRunExpIncr50Min = '';
            String strRunExpFull55Min = '';
            String strRunExpIncr55Min = '';
            
            /** Code added for the schedule run **/
            for(SVMXC__ServiceMax_Config_Data__c currentSchedule : ScheduleRunLst)
            {
                System.debug('Current Run Information : ' + currentSchedule);
                //if(currentSchedule.SVMXC__Run_At__c !=null)      
                if(currentSchedule.SVMXC__Run_At__c !=null && currentSchedule.SVMXC__Active__c == true)
                {
                    StartTime = currentSchedule.SVMXC__Run_At__c;
                    if(StartTime.contains('PM'))
                    {
                        StartTime = StartTime.replace(' PM',':00');
                        system.debug('StartTime'+StartTime);
                        TimeInterval = StartTime.split(':', 3);
                        system.debug('TimeInterval'+TimeInterval);
                        intHour = Integer.valueof(TimeInterval[0]);
                        if(integer.valueof(TimeInterval[1]) >= 10)
                        {
                            strMin = TimeInterval[1];
                        }
                        if(integer.valueof(TimeInterval[1]) < 10)
                        {
                            strMin = TimeInterval[1].substring(1);
                        }
                        strSec = '0';  
                        if(intHour != 12)
                        {
                            intHour = intHour+12;
                        }   
                    }else if(StartTime.contains('AM'))
                    {
                        StartTime = StartTime.replace(' AM',':00');
                        //system.debug('StartTime'+StartTime);
                        TimeInterval = StartTime.split(':', 3);
                        //system.debug('TimeInterval'+TimeInterval);
                        intHour = Integer.valueof(TimeInterval[0]);
                        if(integer.valueof(TimeInterval[1]) >= 10)
                        {
                            strMin = TimeInterval[1];
                        }
                        if(integer.valueof(TimeInterval[1]) < 10)
                        {
                            strMin = TimeInterval[1].substring(1);
                        }
                        strSec = '0';  
                        if(intHour == 12)
                        {
                            intHour = 0;
                        }
                    }
                    if(strMin == '0')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull0Min = buildExpression(strRunExpFull0Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr0Min = buildExpression(strRunExpIncr0Min, intHour);
                    }
                    else if(strMin == '5')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull5Min = buildExpression(strRunExpFull5Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr5Min = buildExpression(strRunExpIncr5Min, intHour);
                    }
                    else if(strMin == '10')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull10Min = buildExpression(strRunExpFull10Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr10Min = buildExpression(strRunExpIncr10Min, intHour);
                    }
                    else if(strMin == '15')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull15Min = buildExpression(strRunExpFull15Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr15Min = buildExpression(strRunExpIncr15Min, intHour);
                    }
                    else if(strMin == '20')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull20Min = buildExpression(strRunExpFull20Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr20Min = buildExpression(strRunExpIncr20Min, intHour);
                    }
                    else if(strMin == '25')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull25Min = buildExpression(strRunExpFull25Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr25Min = buildExpression(strRunExpIncr25Min, intHour);
                    }
                    else if(strMin == '30')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull30Min = buildExpression(strRunExpFull30Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr30Min = buildExpression(strRunExpIncr30Min, intHour);
                    }
                    else if(strMin == '35')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull35Min = buildExpression(strRunExpFull35Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr35Min = buildExpression(strRunExpIncr35Min, intHour);
                    }
                    else if(strMin == '40')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull40Min = buildExpression(strRunExpFull40Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr40Min = buildExpression(strRunExpIncr40Min, intHour);
                    }
                    else if(strMin == '45')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull45Min = buildExpression(strRunExpFull45Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr45Min = buildExpression(strRunExpIncr45Min, intHour);
                    }
                    else if(strMin == '50')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull50Min = buildExpression(strRunExpFull50Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr50Min = buildExpression(strRunExpIncr50Min, intHour);
                    }
                    else if(strMin == '55')
                    {
                        if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG169())
                            strRunExpFull55Min = buildExpression(strRunExpFull55Min, intHour);
                        else if(currentSchedule.SVMXC__Display_Type__c == DispMethods.getTAG170())
                            strRunExpIncr55Min = buildExpression(strRunExpIncr55Min, intHour);
                    }
                }
            }
            System.debug('FullRun : ' + strRunExpFull0Min +' Incr Run: '+ strRunExpIncr0Min +'FullRun1 : ' + strRunExpFull30Min +' Incr Run1: '+ strRunExpIncr30Min );
            
            if(processobj.SVMXC__Runs_Every_Sunday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '1';
            }
            if(processobj.SVMXC__Runs_Every_Monday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '2';
            }
            if(processobj.SVMXC__Runs_Every_Tuesday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '3';
            }
            if(processobj.SVMXC__Runs_Every_Wednesday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '4';
            }
            if(processobj.SVMXC__Runs_Every_Thursday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '5';
            }
            if(processobj.SVMXC__Runs_Every_Friday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '6';
            }
            if(processobj.SVMXC__Runs_Every_Saturday__c == true)
            {
                if(WeekDays.length() > 0)
                    WeekDays += ',';
                WeekDays += '7';
            }
            WeekDays += ' ';
            
            CORNExpressionFull0Min = buildCRONExpression(strRunExpFull0Min, '0MIN', WeekDays, processobj);
            CORNExpressionIncr0Min = buildCRONExpression(strRunExpIncr0Min, '0MIN', WeekDays, processobj);
            CORNExpressionFull5Min = buildCRONExpression(strRunExpFull5Min, '5MIN', WeekDays, processobj);
            CORNExpressionIncr5Min = buildCRONExpression(strRunExpIncr5Min, '5MIN', WeekDays, processobj);
            CORNExpressionFull10Min = buildCRONExpression(strRunExpFull10Min, '10MIN', WeekDays, processobj);
            CORNExpressionIncr10Min = buildCRONExpression(strRunExpIncr10Min, '10MIN', WeekDays, processobj);
            CORNExpressionFull15Min = buildCRONExpression(strRunExpFull15Min, '15MIN', WeekDays, processobj);
            CORNExpressionIncr15Min = buildCRONExpression(strRunExpIncr15Min, '15MIN', WeekDays, processobj);
            CORNExpressionFull20Min = buildCRONExpression(strRunExpFull20Min, '20MIN', WeekDays, processobj);
            CORNExpressionIncr20Min = buildCRONExpression(strRunExpIncr20Min, '20MIN', WeekDays, processobj);
            CORNExpressionFull25Min = buildCRONExpression(strRunExpFull25Min, '25MIN', WeekDays, processobj);
            CORNExpressionIncr25Min = buildCRONExpression(strRunExpIncr25Min, '25MIN', WeekDays, processobj);
            CORNExpressionFull30Min = buildCRONExpression(strRunExpFull30Min, '30MIN', WeekDays, processobj);
            CORNExpressionIncr30Min = buildCRONExpression(strRunExpIncr30Min, '30MIN', WeekDays, processobj);
            CORNExpressionFull35Min = buildCRONExpression(strRunExpFull35Min, '35MIN', WeekDays, processobj);
            CORNExpressionIncr35Min = buildCRONExpression(strRunExpIncr35Min, '35MIN', WeekDays, processobj);
            CORNExpressionFull40Min = buildCRONExpression(strRunExpFull40Min, '40MIN', WeekDays, processobj);
            CORNExpressionIncr40Min = buildCRONExpression(strRunExpIncr40Min, '40MIN', WeekDays, processobj);
            CORNExpressionFull45Min = buildCRONExpression(strRunExpFull45Min, '45MIN', WeekDays, processobj);
            CORNExpressionIncr45Min = buildCRONExpression(strRunExpIncr45Min, '45MIN', WeekDays, processobj);
            CORNExpressionFull50Min = buildCRONExpression(strRunExpFull50Min, '50MIN', WeekDays, processobj);
            CORNExpressionIncr50Min = buildCRONExpression(strRunExpIncr50Min, '50MIN', WeekDays, processobj);
            CORNExpressionFull55Min = buildCRONExpression(strRunExpFull55Min, '55MIN', WeekDays, processobj);
            CORNExpressionIncr55Min = buildCRONExpression(strRunExpIncr55Min, '55MIN', WeekDays, processobj);
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        system.debug('CORNExpression Full : '+CORNExpressionFull0Min);
        System.debug('CornExpression Incre : ' + CORNExpressionIncr0Min);
        return CORNExpressionFull0Min;  //ignore this return as it is not used in the calling method.
    }
    
    /** Below method added for LTP  **/
    public String CORNLTPExpression(SVMXC__ServiceMax_Processes__c processobj)
    {
        try
        {
            ltpCORNExpressionFull0Min = '';
            ltpCORNExpressionFull5Min = '';
            ltpCORNExpressionFull10Min = '';
            ltpCORNExpressionFull15Min = '';
            ltpCORNExpressionFull20Min = '';
            ltpCORNExpressionFull25Min = '';
            ltpCORNExpressionFull30Min = '';
            ltpCORNExpressionFull35Min = '';
            ltpCORNExpressionFull40Min = '';
            ltpCORNExpressionFull45Min = '';
            ltpCORNExpressionFull50Min = '';
            ltpCORNExpressionFull55Min = '';
            String StartTime;
            List<String> TimeInterval = new List<String>();
            integer intHour;
            String strMin;
            String strSec; 
            String WeekDays = '';
            integer StartYear;
            integer EndYear;
            String strRunExpFull0Min = '';
            String strRunExpFull5Min = '';
            String strRunExpFull10Min = '';
            String strRunExpFull15Min = '';
            String strRunExpFull20Min = '';
            String strRunExpFull25Min = '';
            String strRunExpFull30Min = '';
            String strRunExpFull35Min = '';
            String strRunExpFull40Min = '';
            String strRunExpFull45Min = '';
            String strRunExpFull50Min = '';
            String strRunExpFull55Min = '';
            
            /** Code added for the schedule run **/
            for(SVMXC__ServiceMax_Config_Data__c currentSchedule : ltpScheduleRunLst)
            {
                System.debug('Current Run Information : ' + currentSchedule);
                //if(currentSchedule.SVMXC__Run_At__c !=null)      
                if(currentSchedule.SVMXC__Run_Type__c !=null && currentSchedule.SVMXC__Run_At__c !=null)
                {
                    StartTime = currentSchedule.SVMXC__Run_At__c;
                    if(StartTime.contains('PM'))
                    {
                        StartTime = StartTime.replace(' PM',':00');
                        system.debug('StartTime'+StartTime);
                        TimeInterval = StartTime.split(':', 3);
                        system.debug('TimeInterval'+TimeInterval);
                        intHour = Integer.valueof(TimeInterval[0]);
                        if(integer.valueof(TimeInterval[1]) >= 10)
                        {
                            strMin = TimeInterval[1];
                        }
                        if(integer.valueof(TimeInterval[1]) < 10)
                        {
                            strMin = TimeInterval[1].substring(1);
                        }
                        strSec = '0';  
                        if(intHour != 12)
                        {
                            intHour = intHour+12;
                        }   
                    }else if(StartTime.contains('AM'))
                    {
                        StartTime = StartTime.replace(' AM',':00');
                        system.debug('StartTime'+StartTime);
                        TimeInterval = StartTime.split(':', 3);
                        system.debug('TimeInterval'+TimeInterval);
                        intHour = Integer.valueof(TimeInterval[0]);
                        if(integer.valueof(TimeInterval[1]) >= 10)
                        {
                            strMin = TimeInterval[1];
                        }
                        if(integer.valueof(TimeInterval[1]) < 10)
                        {
                            strMin = TimeInterval[1].substring(1);
                        }
                        strSec = '0';  
                        if(intHour == 12)
                        {
                            intHour = 0;
                        }
                    }
                    if(strMin == '0')
                    {
                        strRunExpFull0Min = buildExpression(strRunExpFull0Min, intHour);
                        ltpCORNExpressionFull0Min = buildLTPCRONExpression(strRunExpFull0Min, '0MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '5')
                    {
                        strRunExpFull5Min = buildExpression(strRunExpFull5Min, intHour);
                        ltpCORNExpressionFull5Min = buildLTPCRONExpression(strRunExpFull5Min, '5MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '10')
                    {
                        strRunExpFull10Min = buildExpression(strRunExpFull10Min, intHour);
                        ltpCORNExpressionFull10Min = buildLTPCRONExpression(strRunExpFull10Min, '10MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '15')
                    {
                        strRunExpFull15Min = buildExpression(strRunExpFull15Min, intHour);
                        ltpCORNExpressionFull15Min = buildLTPCRONExpression(strRunExpFull15Min, '15MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '20')
                    {
                        strRunExpFull20Min = buildExpression(strRunExpFull20Min, intHour);
                        ltpCORNExpressionFull20Min = buildLTPCRONExpression(strRunExpFull20Min, '20MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '25')
                    {
                        strRunExpFull25Min = buildExpression(strRunExpFull25Min, intHour);
                        ltpCORNExpressionFull25Min = buildLTPCRONExpression(strRunExpFull25Min, '25MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '30')
                    {
                        strRunExpFull30Min = buildExpression(strRunExpFull30Min, intHour);
                        ltpCORNExpressionFull30Min = buildLTPCRONExpression(strRunExpFull30Min, '30MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '35')
                    {
                        strRunExpFull35Min = buildExpression(strRunExpFull35Min, intHour);
                        ltpCORNExpressionFull35Min = buildLTPCRONExpression(strRunExpFull35Min, '35MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '40')
                    {
                        strRunExpFull40Min = buildExpression(strRunExpFull40Min, intHour);
                        ltpCORNExpressionFull40Min = buildLTPCRONExpression(strRunExpFull40Min, '40MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '45')
                    {
                        strRunExpFull45Min = buildExpression(strRunExpFull45Min, intHour);
                        ltpCORNExpressionFull45Min = buildLTPCRONExpression(strRunExpFull45Min, '45MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '50')
                    {
                        strRunExpFull50Min = buildExpression(strRunExpFull50Min, intHour);
                        ltpCORNExpressionFull50Min = buildLTPCRONExpression(strRunExpFull50Min, '50MIN', processobj, currentSchedule);
                    }
                    else if(strMin == '55')
                    {
                        strRunExpFull55Min = buildExpression(strRunExpFull55Min, intHour);
                        ltpCORNExpressionFull55Min = buildLTPCRONExpression(strRunExpFull55Min, '55MIN', processobj, currentSchedule);
                    }
                }
            }
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
    }
    
    public String buildExpression(String request, Integer intHour)
    {
        if(request.length() > 0)
        {
            request += ',';
        }
        request += string.valueof(intHour);
        return request;
    }

    public String buildCRONExpression(String expression, String strType, String WeekDays, SVMXC__ServiceMax_Processes__c objProcess)
    {
        String response = '';
        integer StartYear;
        integer EndYear;
        if(expression.length() > 0)
        {
            if(strType == '0MIN')
                response = '0 0 ' + expression;
            if(strType == '5MIN')
                response = '0 5 ' + expression;
            if(strType == '10MIN')
                response = '0 10 ' + expression;
            if(strType == '15MIN')
                response = '0 15 ' + expression;
            if(strType == '20MIN')
                response = '0 20 ' + expression;
            if(strType == '25MIN')
                response = '0 25 ' + expression;
            if(strType == '30MIN')
                response = '0 30 ' + expression;
            if(strType == '35MIN')
                response = '0 35 ' + expression;
            if(strType == '40MIN')
                response = '0 40 ' + expression;
            if(strType == '45MIN')
                response = '0 45 ' + expression;
            if(strType == '50MIN')
                response = '0 50 ' + expression;
            if(strType == '55MIN')
                response = '0 55 ' + expression;
            response += ' ?'+' '+'*'+' ';
            response += WeekDays;
            if(objProcess.SVMXC__Start_Date__c != null)
            {
                StartYear = objProcess.SVMXC__Start_Date__c.year();
                response += String.valueof(StartYear);                  
            }
            if(objProcess.SVMXC__End_Date__c != null)
            {
                EndYear = objProcess.SVMXC__End_Date__c.year();
                if(StartYear != EndYear)
                {
                    response += '-';
                    response += String.valueof(EndYear);
                }
            }
            response += '~' + objProcess.SVMXC__Dispatch_Timezone__c; 
        }
        system.debug('WORD_OptimaxCall::buildCRONExpression(): ' + response);
        return response;
    }
    
    /** Below method builds the LTPCRONExpression **/
    public String buildLTPCRONExpression(String expression, String strType, SVMXC__ServiceMax_Processes__c objProcess, SVMXC__ServiceMax_Config_Data__c configSchedulingData)
    {
        String response = '';
        integer StartYear;
        integer EndYear;
        
        Map<String, String> mapOfWeekDayAndNumber = new Map<String, String>();
        mapOfWeekDayAndNumber.put('Sunday','1');
        mapOfWeekDayAndNumber.put('Monday','2');
        mapOfWeekDayAndNumber.put('Tuesday','3');
        mapOfWeekDayAndNumber.put('Wednesday','4');
        mapOfWeekDayAndNumber.put('Thursday','5');
        mapOfWeekDayAndNumber.put('Friday','6');
        mapOfWeekDayAndNumber.put('Saturday','7');
        
        if(expression.length() > 0)
        {
            if(strType == '0MIN')
                response = '0 0 ' + expression;
            if(strType == '5MIN')
                response = '0 5 ' + expression;
            if(strType == '10MIN')
                response = '0 10 ' + expression;
            if(strType == '15MIN')
                response = '0 15 ' + expression;
            if(strType == '20MIN')
                response = '0 20 ' + expression;
            if(strType == '25MIN')
                response = '0 25 ' + expression;
            if(strType == '30MIN')
                response = '0 30 ' + expression;
            if(strType == '35MIN')
                response = '0 35 ' + expression;
            if(strType == '40MIN')
                response = '0 40 ' + expression;
            if(strType == '45MIN')
                response = '0 45 ' + expression;
            if(strType == '50MIN')
                response = '0 50 ' + expression;
            if(strType == '55MIN')
                response = '0 55 ' + expression;
            //response += ' ?'+' '+'*'+' ';
            //response += WeekDays;
            
            /** Below logic parses the weekdays from the format like monday;tuesday and gets the corresponding integer**/
            if(configSchedulingData.SVMXC__Run_Type__c != null && configSchedulingData.SVMXC__Schedule_Days__c != null) {
                String weekDaysForCron = '';
                if(configSchedulingData.SVMXC__Schedule_Days__c.contains(';')) {
                    String[] lstWeekDays = configSchedulingData.SVMXC__Schedule_Days__c.split(';', -1);
                    for(Integer i=0; i<lstWeekDays.size();i++) {
                        if(i==0) {
                            weekDaysForCron = mapOfWeekDayAndNumber.get(lstWeekDays[i].trim());
                            continue;
                        }
                        weekDaysForCron = weekDaysForCron + ',' + mapOfWeekDayAndNumber.get(lstWeekDays[i].trim());
                    }
                } else {
                    weekDaysForCron = mapOfWeekDayAndNumber.get(configSchedulingData.SVMXC__Schedule_Days__c.trim());
                }
                system.debug('WORD_OptimaxCall::buildLTPCRONExpression:weekDaysForCron - ' + weekDaysForCron);
                response += ' ?'+ ' ' + '*' + ' ' + weekDaysForCron + ' ';  
            }
            
            if(configSchedulingData.SVMXC__Run_Type__c != null && configSchedulingData.SVMXC__Day_to_Run__c != null) {
                response += ' ' + configSchedulingData.SVMXC__Day_to_Run__c + ' ' + '*' + ' ' + '? ';
            }
            
            if(objProcess.SVMXC__Window_Height__c != null) {
                Date todayDateGMT = DateTime.now().addDays(Integer.valueOf(objProcess.SVMXC__Window_Height__c)).DateGMT();
                StartYear = todayDateGMT.year();
                response += String.valueof(StartYear);
            }
            response += '~' + objProcess.SVMXC__Confirmation_Message__c; //this field stores the TimeZone information
            system.debug('WORD_OptimaxCall::buildLTPCRONExpression: LTP Cron Expression - '+ response);
        }
        return response;
    }

    String [] Perameter = new String[]{};
    List<SVMXC__ServiceMax_Processes__c> Cardential = new List<SVMXC__ServiceMax_Processes__c>();
    map<String,String> mapCardential = new map<String,String>();
    
    /**  Introduced the below method to handle both LTP and Batch. And using this method for standalone LTP **/
    public pagereference OptiMaxWebServiceCall(SVMXC__ServiceMax_Processes__c processobj,List<SVMXC__ServiceMax_Processes__c> TerritoryLst)
    {
        try
        {
            Cardential.clear();
            String OrgId = Userinfo.getOrganizationId().substring(0,15);
            //system.debug('OrgId'+OrgId); 
            String DisProID = processobj.id;
            Cardential = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Submodule__r.Id,RecordTypeId,SVMXC__Default_Value__c,SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03')];
            //get the Cardential first....
            OMAX_ServicemaxCom.credential c1 = new OMAX_ServicemaxCom.credential();
            if(Cardential.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c pro : Cardential)
                {
                    if(pro.SVMXC__SettingID__c != null && pro.SVMXC__Default_Value__c != null)
                        mapCardential.put(pro.SVMXC__SettingID__c,pro.SVMXC__Default_Value__c);
                }
            }
            if(mapCardential.size() > 0)
            {
                if(mapCardential.containskey('PS01'))
                    c1.loginName = decryption1(mapCardential.get('PS01'));
                if(mapCardential.containskey('PS02'))
                    c1.password = decryption1(mapCardential.get('PS02'));
                if(mapCardential.containskey('PS03'))   
                    c1.securityToken = decryption1(mapCardential.get('PS03'));
            }    

            c1.orgGUID = OrgId;
            c1.userGUID = Userinfo.getUserId();
            //system.debug('Cardential'+c1);
            /*OMAX_ServicemaxCom.parameter p1 = new  OMAX_ServicemaxCom.parameter();
            p1.name = 'JOptWeight.TimeWindow';
            p1.value = string.valueof(processobj.SVMXC__Weight_Time_Window__c);
            OMAX_ServicemaxCom.parameter p2 = new  OMAX_ServicemaxCom.parameter();
            p2.name = 'JOptWeight.TotalDistance';
            p2.value = string.valueof(processobj.SVMXC__Weight_Total_Distance__c);
            OMAX_ServicemaxCom.parameter p3 = new  OMAX_ServicemaxCom.parameter();
            p3.name = 'JOptWeight.RouteDistance';
            p3.value = string.valueof(processobj.SVMXC__Weight_Route_Distance__c);
            OMAX_ServicemaxCom.parameter p4 = new  OMAX_ServicemaxCom.parameter();
            p4.name = 'JOptWeight.RouteTime';
            p4.value = string.valueof(processobj.SVMXC__Weight_Route_Time__c);
            OMAX_ServicemaxCom.parameter p5 = new  OMAX_ServicemaxCom.parameter();
            p5.name = 'JOptWeight.PreferableResource';
            p5.value = string.valueof(processobj.SVMXC__Weight_Node_Type__c);
            OMAX_ServicemaxCom.parameter p6 = new  OMAX_ServicemaxCom.parameter();
            p6.name = 'JOpt.RouteType';
            p6.value = processobj.SVMXC__Route_Type__c;*/
            //commented the above code to introduce the below new parameter names.
            OMAX_ServicemaxCom.parameter p1 = new  OMAX_ServicemaxCom.parameter();
            p1.name = 'Objectives.CostBucket.TimeWindow';
            p1.value = string.valueof(processobj.SVMXC__Weight_Time_Window__c);
            OMAX_ServicemaxCom.parameter p2 = new  OMAX_ServicemaxCom.parameter();
            p2.name = 'Objectives.CostBucket.WorkDistribution';
            p2.value = string.valueof(processobj.SVMXC__Weight_Total_Distance__c);
            OMAX_ServicemaxCom.parameter p3 = new  OMAX_ServicemaxCom.parameter();
            p3.name = 'Objectives.CostBucket.Distance';
            p3.value = string.valueof(processobj.SVMXC__Weight_Route_Distance__c);
            OMAX_ServicemaxCom.parameter p4 = new  OMAX_ServicemaxCom.parameter();
            p4.name = 'Objectives.CostBucket.Time';
            p4.value = string.valueof(processobj.SVMXC__Weight_Route_Time__c);
            OMAX_ServicemaxCom.parameter p5 = new  OMAX_ServicemaxCom.parameter();
            p5.name = 'Objectives.CostBucket.Relations';
            p5.value = string.valueof(processobj.SVMXC__Weight_Node_Type__c);
            OMAX_ServicemaxCom.parameter p6 = new  OMAX_ServicemaxCom.parameter();
            p6.name = 'JOpt.RouteType';
            p6.value = processobj.SVMXC__Route_Type__c;
            OMAX_ServicemaxCom.parameter p10 = new  OMAX_ServicemaxCom.parameter();
            p10.name = 'Objectives.Name';
            p10.value = processobj.SVMXC__Optimization_Goal__c;
            List<OMAX_ServicemaxCom.parameter> plist = new List<OMAX_ServicemaxCom.parameter>();
            plist.add(p1);
            plist.add(p2);
            plist.add(p3);
            plist.add(p4);
            plist.add(p5);
            plist.add(p6);
            plist.add(p10);

            //// Added By GM : To Send :: Optimax.TriggerDateFormat,Optimax.TriggerStart,Optimax.TriggerEnd in the same order
            OMAX_ServicemaxCom.parameter p7 = new  OMAX_ServicemaxCom.parameter();
            p7.name = 'Optimax.TriggerDateFormat';
            p7.value = 'yyyy/MM/dd';
            plist.add(p7);
            OMAX_ServicemaxCom.parameter p8 = new  OMAX_ServicemaxCom.parameter();
            p8.name = 'Optimax.TriggerStart';
            Date dtSt =  processobj.SVMXC__Start_Date__c;
            if(dtSt != null)
            {
                p8.value = String.valueOf(dtst.year()) + '/' + String.valueOf(dtst.month())+ '/' + String.valueOf(dtst.day());
                plist.add(p8);
            }

            OMAX_ServicemaxCom.parameter p9 = new OMAX_ServicemaxCom.parameter();
            p9.name = 'Optimax.TriggerEnd';
            Date dtEn =  processobj.SVMXC__End_Date__c;
            if(dtEn != null)
            {
                p9.value = String.valueOf(dtEn.year()) + '/' + String.valueOf(dtEn.month())+ '/' + String.valueOf(dtEn.day());
                plist.add(p9);
            }
            for(id Terrid: mapTerrZone.keyset())    
            {
                map<string,String> maptypeZoneval= new map<string,String>();
                string strpolygon = '';
                string strCircle = '';
                string strRectangle = '';
                maptypeZoneval = mapTerrZone.get(Terrid);
                if(maptypeZoneval.Containskey('Polygon'))
                    strpolygon = '{type:"Polygons",values:[' + maptypeZoneval.get('Polygon') + ']}';
                else
                    strpolygon = '{type:"Polygons",values:[]}';
                    
                if(maptypeZoneval.Containskey('Circle'))
                    strCircle = '{type:"Circles",values:[' + maptypeZoneval.get('Circle') + ']}';
                else
                    strCircle = '{type:"Circles",values:[]}';
                    
                if(maptypeZoneval.Containskey('Rectangle'))
                    strRectangle = '{type:"Rectangles",values:[' + maptypeZoneval.get('Rectangle') + ']}';
                else
                    strRectangle = '{type:"Rectangles",values:[]}';
                    
                OMAX_ServicemaxCom.parameter param = new  OMAX_ServicemaxCom.parameter();
                param.name = 'Zone';
                param.category = String.valueof(Terrid);
                //param.value = mapTerritoryZoneDef.get(Terrid);
                param.value = '[' + strpolygon + ',' + strCircle + ',' + strRectangle + ']';
                plist.add(param);
                System.debug(logginglevel.warn,'Parameter List param  '+param);
            }
            System.debug(logginglevel.warn,'Parameter List  '+plist);
            OMAX_ServicemaxCom.territorySchedule[] TList = new OMAX_ServicemaxCom.territorySchedule[]{};
            
            /** Below list stores the Territory Ids. This is used later to create the Job records for LTP **/
            List<String> lstStrTerritoryIds = new List<String>();
            ////This is for Territory which are newly Created or updated in salesforce but needs to Create/Update in optimax..
            if(TerritoryLst.size() > 0)
            {
                for(integer i = 0; i < TerritoryLst.size(); i++)
                {
                    String s = String.valueOf(TerritoryLst[i].SVMXC__Territory__c);
                    s = s.substring(0,15);
                    OMAX_ServicemaxCom.territorySchedule t1 = new OMAX_ServicemaxCom.territorySchedule();
                    String s1 = string.valueOf(TerritoryLst[i].SVMXC__Territory__c);
                    s1 = s1.substring(0,15);
                        
                    if(CORNExpressionFull0Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull0Min, s1, OrgId, '_FULL00', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull0Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull0Min, s1, OrgId, '_LTP00', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull5Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull5Min, s1, OrgId, '_FULL05', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull5Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull5Min, s1, OrgId, '_LTP05', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull10Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull10Min, s1, OrgId, '_FULL10', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull10Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull10Min, s1, OrgId, '_LTP10', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull15Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull15Min, s1, OrgId, '_FULL15', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull15Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull15Min, s1, OrgId, '_LTP15', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull20Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull20Min, s1, OrgId, '_FULL20', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull20Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull20Min, s1, OrgId, '_LTP20', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull25Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull25Min, s1, OrgId, '_FULL25', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull25Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull25Min, s1, OrgId, '_LTP25', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull30Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull30Min, s1, OrgId, '_FULL30', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull30Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull30Min, s1, OrgId, '_LTP30', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull35Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull35Min, s1, OrgId, '_FULL35', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull35Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull35Min, s1, OrgId, '_LTP35', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull40Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull40Min, s1, OrgId, '_FULL40', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull40Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull40Min, s1, OrgId, '_LTP40', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull45Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull45Min, s1, OrgId, '_FULL45', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull45Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull45Min, s1, OrgId, '_LTP45', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull50Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull50Min, s1, OrgId, '_FULL50', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull50Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull50Min, s1, OrgId, '_LTP50', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                    if(CORNExpressionFull55Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull55Min, s1, OrgId, '_FULL55', plist, processobj, 'Optimized Batch');
                        TList.add(t1);
                    }
                    if(ltpCORNExpressionFull55Min.length() > 0)
                    {
                        t1 = buildSchedule(ltpCORNExpressionFull55Min, s1, OrgId, '_LTP55', plist, processobj, 'Long-Term Planner');
                        TList.add(t1);
                        lstStrTerritoryIds.add(TerritoryLst[i].SVMXC__Territory__c);
                    }
                }   
            }   
            OMAX_ServicemaxCom.status WSDLStatus = new  OMAX_ServicemaxCom.status();
            OMAX_ServicemaxCom.OptimaxServicePort WSDLCall = new OMAX_ServicemaxCom.OptimaxServicePort();
            if(svmxSettingList.containsKey('GBL010') == true && svmxSettingList.get('GBL010') != null)
            {
                String EndpointURL_x = svmxSettingList.get('GBL010');
                system.debug('EndpointURL'+EndpointURL_x);
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(EndpointURL_x);
                //req.setTimeout(60000);//Added by amar on 30th Aug 2010
                //TODO:Timeout issue occurd due to Quartz library taking too much time. So increased from 1 min. to 2 min.
                req.setTimeout(120000);//Added by Anantha on 8th July 2019
                HttpResponse res = new Http().send(req);
                string loc = res.getHeader('Location');
                system.debug('Location'+loc);
                if((loc != NULL)&&(loc != '')) 
                { 
                    EndpointURL_x = loc; 
                }
                WSDLCall.endpoint_x = EndpointURL_x;
            }   
            WSDLStatus = WSDLCall.OMAX_Dispatch_Process_Definition_WS(c1,OrgId,DisProID,TList);
            system.debug('WSDLStatus'+WSDLStatus);
            system.debug('WSDLStatus'+WSDLStatus.message); 
            system.debug('WSDLStatus'+WSDLStatus.status); 
            if(WSDLStatus.status == 'SUCCESS')
            {
                system.debug('*************874-success*************');
                Disprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(Disprocess, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert Disprocess;  
                    
                    /** This method creates a Job record for LTP if there is a CRON created**/
                    if(lstStrTerritoryIds.size() > 0) {
                        createLTPJobs(lstStrTerritoryIds, processobj.Id);
                    }
                } else {
                    errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                    errorMessage.messageType = 'ERROR';
                    errorMessage.message = System.label.COMM001_TAG142;

                    WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'CONFIRM';
                errorMessage.message = DispMethods.getTAG141();
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG141()));//WSDLStatus.message
                pagereference newpage = new pagereference('/apex/WORD_ManageDispatchProcess');
                newpage.setRedirect(true);
                return newpage;
            }
            if(WSDLStatus.status == 'FAILURE')
            {
                system.debug('*************897-failure************');
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'ERROR';
                errorMessage.message = DispMethods.getTAG139()+ WSDLStatus.message;
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG139()+ WSDLStatus.message));//
                return null;
            }
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
  }
    //commented the below method and introduced the above one by modifying the below method to handle both LTP and Batch
    /*public pagereference OptiMaxWebServiceCall(SVMXC__ServiceMax_Processes__c processobj,List<SVMXC__ServiceMax_Processes__c> TerritoryLst)
    {
        try
        {
            Cardential.clear();
            String OrgId = Userinfo.getOrganizationId().substring(0,15);
            //system.debug('OrgId'+OrgId); 
            String DisProID = processobj.id;
            Cardential = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Submodule__r.Id,RecordTypeId,SVMXC__Default_Value__c,SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03')];
            //get the Cardential first....
            OMAX_ServicemaxCom.credential c1 = new OMAX_ServicemaxCom.credential();
            if(Cardential.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c pro : Cardential)
                {
                    if(pro.SVMXC__SettingID__c != null && pro.SVMXC__Default_Value__c != null)
                        mapCardential.put(pro.SVMXC__SettingID__c,pro.SVMXC__Default_Value__c);
                }
            }
            if(mapCardential.size() > 0)
            {
                if(mapCardential.containskey('PS01'))
                    c1.loginName = decryption1(mapCardential.get('PS01'));
                if(mapCardential.containskey('PS02'))
                    c1.password = decryption1(mapCardential.get('PS02'));
                if(mapCardential.containskey('PS03'))   
                    c1.securityToken = decryption1(mapCardential.get('PS03'));
            }    

            c1.orgGUID = OrgId;
            c1.userGUID = Userinfo.getUserId();
            //system.debug('Cardential'+c1);
            OMAX_ServicemaxCom.parameter p1 = new  OMAX_ServicemaxCom.parameter();
            p1.name = 'JOptWeight.TimeWindow';
            p1.value = string.valueof(processobj.SVMXC__Weight_Time_Window__c);
            OMAX_ServicemaxCom.parameter p2 = new  OMAX_ServicemaxCom.parameter();
            p2.name = 'JOptWeight.TotalDistance';
            p2.value = string.valueof(processobj.SVMXC__Weight_Total_Distance__c);
            OMAX_ServicemaxCom.parameter p3 = new  OMAX_ServicemaxCom.parameter();
            p3.name = 'JOptWeight.RouteDistance';
            p3.value = string.valueof(processobj.SVMXC__Weight_Route_Distance__c);
            OMAX_ServicemaxCom.parameter p4 = new  OMAX_ServicemaxCom.parameter();
            p4.name = 'JOptWeight.RouteTime';
            p4.value = string.valueof(processobj.SVMXC__Weight_Route_Time__c);
            OMAX_ServicemaxCom.parameter p5 = new  OMAX_ServicemaxCom.parameter();
            p5.name = 'JOptWeight.PreferableResource';
            p5.value = string.valueof(processobj.SVMXC__Weight_Node_Type__c);
            OMAX_ServicemaxCom.parameter p6 = new  OMAX_ServicemaxCom.parameter();
            p6.name = 'JOpt.RouteType';
            p6.value = processobj.SVMXC__Route_Type__c;
            List<OMAX_ServicemaxCom.parameter> plist = new List<OMAX_ServicemaxCom.parameter>();
            plist.add(p1);
            plist.add(p2);
            plist.add(p3);
            plist.add(p4);
            plist.add(p5);
            plist.add(p6);

            //// Added By GM : To Send :: Optimax.TriggerDateFormat,Optimax.TriggerStart,Optimax.TriggerEnd in the same order
            OMAX_ServicemaxCom.parameter p7 = new  OMAX_ServicemaxCom.parameter();
            p7.name = 'Optimax.TriggerDateFormat';
            p7.value = 'yyyy/MM/dd';
            plist.add(p7);
            OMAX_ServicemaxCom.parameter p8 = new  OMAX_ServicemaxCom.parameter();
            p8.name = 'Optimax.TriggerStart';
            Date dtSt =  processobj.SVMXC__Start_Date__c;
            if(dtSt != null)
            {
                p8.value = String.valueOf(dtst.year()) + '/' + String.valueOf(dtst.month())+ '/' + String.valueOf(dtst.day());
                plist.add(p8);
            }

            OMAX_ServicemaxCom.parameter p9 = new OMAX_ServicemaxCom.parameter();
            p9.name = 'Optimax.TriggerEnd';
            Date dtEn =  processobj.SVMXC__End_Date__c;
            if(dtEn != null)
            {
                p9.value = String.valueOf(dtEn.year()) + '/' + String.valueOf(dtEn.month())+ '/' + String.valueOf(dtEn.day());
                plist.add(p9);
            }
            for(id Terrid: mapTerrZone.keyset())    
            {
                map<string,String> maptypeZoneval= new map<string,String>();
                string strpolygon = '';
                string strCircle = '';
                string strRectangle = '';
                maptypeZoneval = mapTerrZone.get(Terrid);
                if(maptypeZoneval.Containskey('Polygon'))
                    strpolygon = '{type:"Polygons",values:[' + maptypeZoneval.get('Polygon') + ']}';
                else
                    strpolygon = '{type:"Polygons",values:[]}';
                    
                if(maptypeZoneval.Containskey('Circle'))
                    strCircle = '{type:"Circles",values:[' + maptypeZoneval.get('Circle') + ']}';
                else
                    strCircle = '{type:"Circles",values:[]}';
                    
                if(maptypeZoneval.Containskey('Rectangle'))
                    strRectangle = '{type:"Rectangles",values:[' + maptypeZoneval.get('Rectangle') + ']}';
                else
                    strRectangle = '{type:"Rectangles",values:[]}';
                    
                OMAX_ServicemaxCom.parameter param = new  OMAX_ServicemaxCom.parameter();
                param.name = 'Zone';
                param.category = String.valueof(Terrid);
                //param.value = mapTerritoryZoneDef.get(Terrid);
                param.value = '[' + strpolygon + ',' + strCircle + ',' + strRectangle + ']';
                plist.add(param);
                System.debug(logginglevel.warn,'Parameter List param  '+param);
            }
            System.debug(logginglevel.warn,'Parameter List  '+plist);
            OMAX_ServicemaxCom.territorySchedule[] TList = new OMAX_ServicemaxCom.territorySchedule[]{};
            //This is for Territory which are deleted in salesforce but needs to delete in optimax..
            //if(MapOfDeletedTerritory.size() > 0)
            //{
            //    for(String s : MapOfDeletedTerritory.keySet())
            //    {
            //        SVMXC.OMAX_ServicemaxCom.territorySchedule t1 = new SVMXC.OMAX_ServicemaxCom.territorySchedule();
            //        t1.cronExpression = CORNExpression;
            //        t1.orgGUID = OrgId;
            //        t1.dispatchProcessGUID = processobj.id;
            //        t1.territoryGUID = s;
            //        t1.errorEmailID = processobj.SVMXC__Email_On_Error__c;
            //        t1.successEmailID = processobj.SVMXC__Email_On_Success__c;
            //        t1.operation = 'Delete'; //MapOfDeletedTerritory.get(s)
            //        t1.status = 'Enable';
            //        t1.optimizationParameters = plist;
            //        TList.add(t1);
            //    }   
            //}
            ////This is for Territory which are newly Created or updated in salesforce but needs to Create/Update in optimax..
            if(TerritoryLst.size() > 0)
            {
                for(integer i = 0; i < TerritoryLst.size(); i++)
                {
                    String s = String.valueOf(TerritoryLst[i].SVMXC__Territory__c);
                    s = s.substring(0,15);
                    OMAX_ServicemaxCom.territorySchedule t1 = new OMAX_ServicemaxCom.territorySchedule();
                    String s1 = string.valueOf(TerritoryLst[i].SVMXC__Territory__c);
                    s1 = s1.substring(0,15);
                        
                    if(CORNExpressionFull0Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull0Min, s1, OrgId, '_FULL00', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr0Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr0Min, s1, OrgId, '_INCR00', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull5Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull5Min, s1, OrgId, '_FULL05', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr5Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr5Min, s1, OrgId, '_INCR05', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull10Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull10Min, s1, OrgId, '_FULL10', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr10Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr10Min, s1, OrgId, '_INCR10', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull15Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull15Min, s1, OrgId, '_FULL15', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr15Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr15Min, s1, OrgId, '_INCR15', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull20Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull20Min, s1, OrgId, '_FULL20', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr20Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr20Min, s1, OrgId, '_INCR20', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull25Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull25Min, s1, OrgId, '_FULL25', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr25Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr25Min, s1, OrgId, '_INCR25', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull30Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull30Min, s1, OrgId, '_FULL30', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr30Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr30Min, s1, OrgId, '_INCR30', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull35Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull35Min, s1, OrgId, '_FULL35', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr35Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr35Min, s1, OrgId, '_INCR35', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull40Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull40Min, s1, OrgId, '_FULL40', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr40Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr40Min, s1, OrgId, '_INCR40', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull45Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull45Min, s1, OrgId, '_FULL45', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr45Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr45Min, s1, OrgId, '_INCR45', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull50Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull50Min, s1, OrgId, '_FULL50', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr50Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr50Min, s1, OrgId, '_INCR50', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionFull55Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionFull55Min, s1, OrgId, '_FULL55', plist, processobj);
                        TList.add(t1);
                    }
                    if(CORNExpressionIncr55Min.length() > 0)
                    {
                        t1 = buildSchedule(CORNExpressionIncr55Min, s1, OrgId, '_INCR55', plist, processobj);
                        TList.add(t1);
                    }
                }   
            }   
            OMAX_ServicemaxCom.status WSDLStatus = new  OMAX_ServicemaxCom.status();
            OMAX_ServicemaxCom.OptimaxServicePort WSDLCall = new OMAX_ServicemaxCom.OptimaxServicePort();
            if(svmxSettingList.containsKey('GBL010') == true && svmxSettingList.get('GBL010') != null)
            {
                String EndpointURL_x = svmxSettingList.get('GBL010');
                system.debug('EndpointURL'+EndpointURL_x);
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(EndpointURL_x);
                //req.setTimeout(60000);//Added by amar on 30th Aug 2010
                //TODO:Timeout issue occurd due to Quartz library taking too much time. So increased from 1 min. to 2 min.
                req.setTimeout(120000);//Added by Anantha on 8th July 2019
                HttpResponse res = new Http().send(req);
                string loc = res.getHeader('Location');
                system.debug('Location'+loc);
                if((loc != NULL)&&(loc != '')) 
                { 
                    EndpointURL_x = loc; 
                }
                WSDLCall.endpoint_x = EndpointURL_x;
            }   
            WSDLStatus = WSDLCall.OMAX_Dispatch_Process_Definition_WS(c1,OrgId,DisProID,TList);
            system.debug('WSDLStatus'+WSDLStatus);
            system.debug('WSDLStatus'+WSDLStatus.message); 
            system.debug('WSDLStatus'+WSDLStatus.status); 
            if(WSDLStatus.status == 'SUCCESS')
            {
                system.debug('*************874-success*************');
                Disprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(Disprocess, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert Disprocess;  
                } else {
                    errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                    errorMessage.messageType = 'ERROR';
                    errorMessage.message = System.label.COMM001_TAG142;

                    WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'CONFIRM';
                errorMessage.message = DispMethods.getTAG141();
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG141()));//WSDLStatus.message
                pagereference newpage = new pagereference('/apex/WORD_ManageDispatchProcess');
                newpage.setRedirect(true);
                return newpage;
            }
            if(WSDLStatus.status == 'FAILURE')
            {
                system.debug('*************897-failure************');
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'ERROR';
                errorMessage.message = DispMethods.getTAG139()+ WSDLStatus.message;
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG139()+ WSDLStatus.message));//
                return null;
            }
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
  }*/
  
    /** This method creates a Job record for LTP **/
    public void createLTPJobs(List<String> lstStrTerritoryIds, String strDispatchProcessId) {
        
        for(String eachTerrId : lstStrTerritoryIds) {
            //check in the map if the job record is already existing for this Terr Id
            //If not, only then create a Job record
            if(!mapOfTerrIdLTPJob.containsKey(eachTerrId)) {
                SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
                objSVMXJob.SVMXC__SVMX_Process__c = strDispatchProcessId;
                objSVMXJob.SVMXC__Territory__c = eachTerrId;
                objSVMXJob.SVMXC__Start_Time__c = system.now();
                objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
                objSVMXJob.SVMXC__Type__c = 'LTP'; // Long-Term Planner
                objSVMXJob.SVMXC__OptiMax_Message__c = 'Initiate Error';
                insert objSVMXJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        }
    }

    /** This method creates a Job record for LTP **/
    public void createRTOJobs(List<String> lstStrTerritoryIds, String strDispatchProcessId) {
        
        for(String eachTerrId : lstStrTerritoryIds) {
            //check in the map if the job record is already existing for this Terr Id
            //If not, only then create a Job record
            if(!mapOfTerrIdRTOJob.containsKey(eachTerrId)) {
                SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
                objSVMXJob.SVMXC__SVMX_Process__c = strDispatchProcessId;
                objSVMXJob.SVMXC__Territory__c = eachTerrId;
                objSVMXJob.SVMXC__Start_Time__c = system.now();
                objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
                objSVMXJob.SVMXC__Type__c = 'ECO'; // RTO
                objSVMXJob.SVMXC__OptiMax_Message__c = 'IDLE';
                insert objSVMXJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        }
    }
  
    public OMAX_ServicemaxCom.territorySchedule buildSchedule(String CORNExpression, String idTerritory, String OrgId, string strType, List<OMAX_ServicemaxCom.parameter> plist, SVMXC__ServiceMax_Processes__c objProcess, String strDispatchMethod)
    {
        system.debug('WORD_OptimaxCall:buildSchedule:Inside');
        OMAX_ServicemaxCom.territorySchedule response = new OMAX_ServicemaxCom.territorySchedule();
        response.orgGUID = OrgId;
        response.territoryGUID = idTerritory + strType;
        response.dispatchProcessGUID = objProcess.id;
        response.cronExpression = CORNExpression; //'0 0/2 * * * ?'; 
        response.errorEmailID = objProcess.SVMXC__Email_On_Error__c;
        response.successEmailID = objProcess.SVMXC__Email_On_Success__c;
        response.operation = 'New'; 
        response.status = 'Enable';
        response.optimizationParameters = plist;
        //response.dispatchMethod = objProcess.SVMXC__Dispatch_Method__c;
        response.dispatchMethod = strDispatchMethod;
        system.debug('buildSchedule - ' + response);
        return response;
    }

  public Pagereference BackToDP()
  {
    pagereference newpage = new pagereference('/apex/WORD_ManageDispatchProcess');
    newpage.setRedirect(true);
    return newpage;
  }
  
    public OMAX_ServicemaxCom.territorySchedule[] ECO_CRONExpression(SVMXC__ServiceMax_Processes__c processobj)
    {
        OMAX_ServicemaxCom.territorySchedule[] TList = new OMAX_ServicemaxCom.territorySchedule[]{};
        try
        {
            List<String> TimeInterval = new List<String>();
            integer intHour;
            String strMin;
            String strSec;
            String strECOStartExp = '';
            
            System.debug(Logginglevel.INFO, 'ECO_CRONExpression: TerritoryLst = ' + TerritoryLst);
            
            String OrgId = Userinfo.getOrganizationId().substring(0,15);

            List<OMAX_ServicemaxCom.parameter> plist = new List<OMAX_ServicemaxCom.parameter>();
            buildParameterList(plist, processobj);

            OMAX_ServicemaxCom.parameter p1 = new OMAX_ServicemaxCom.parameter();
            p1.name = 'Optimax.TriggerDateFormat';
            p1.value = 'yyyy/MM/dd';
            plist.add(p1);
            OMAX_ServicemaxCom.parameter p2 = new OMAX_ServicemaxCom.parameter();
            p2.name = 'Optimax.TriggerStart';
            DateTime dtmNow = system.now();
            Date dtSt = Date.valueOf(dtmNow.format('yyyy-MM-dd'));
            if(dtSt != null)
            {
                p2.value = String.valueOf(dtst.year()) + '/' + String.valueOf(dtst.month())+ '/' + String.valueOf(dtst.day());
                plist.add(p2);
            }

            for(id Terrid: mapTerrZone.keyset())    
            {
                map<string,String> maptypeZoneval= new map<string,String>();
                string strpolygon = '';
                string strCircle = '';
                string strRectangle = '';
                maptypeZoneval = mapTerrZone.get(Terrid);
                if(maptypeZoneval.Containskey('Polygon'))
                    strpolygon = '{type:"Polygons",values:[' + maptypeZoneval.get('Polygon') + ']}';
                else
                    strpolygon = '{type:"Polygons",values:[]}';
                    
                if(maptypeZoneval.Containskey('Circle'))
                    strCircle = '{type:"Circles",values:[' + maptypeZoneval.get('Circle') + ']}';
                else
                    strCircle = '{type:"Circles",values:[]}';
                    
                if(maptypeZoneval.Containskey('Rectangle'))
                    strRectangle = '{type:"Rectangles",values:[' + maptypeZoneval.get('Rectangle') + ']}';
                else
                    strRectangle = '{type:"Rectangles",values:[]}';
                    
                OMAX_ServicemaxCom.parameter param = new  OMAX_ServicemaxCom.parameter();
                param.name = 'Zone';
                param.category = String.valueof(Terrid);
                param.value = '[' + strpolygon + ',' + strCircle + ',' + strRectangle + ']';
                plist.add(param);
                System.debug(Logginglevel.INFO,'ECO_CRONExpression: Parameter List param = ' + param);
            }
            System.debug(Logginglevel.INFO, 'ECO_CRONExpression: Parameter List = ' + plist);
            
            SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
            List<Holiday> holidayList = [Select Name, ActivityDate From Holiday where IsAllDay = TRUE];
            for(integer i = 0; i < TerritoryLst.size(); i++) {
                String modeOfTravel = 'Driving';
                if(TerritoryLst.get(i).SVMXC__Territory__r.SVMXC__Mode_Of_Travel__c != NULL) {
                    modeOfTravel = String.valueOf(TerritoryLst.get(i).SVMXC__Territory__r.SVMXC__Mode_Of_Travel__c);
                }
                plist.add(setParameter('modeOfTravel', modeOfTravel));
                
                String businessHourId = TerritoryLst.get(i).SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c;
                BusinessHours bhForCRON = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE and Id = :businessHourId];

                Map<String, String> startTimeMap = new Map<String, String>();
                Map<String, String> endTimeMap = new Map<String, String>();
                String weekDayStartTime = String.valueOf(bhForCRON.SundayStartTime);
                String weekDayEndTime = String.valueOf(bhForCRON.SundayEndTime);
                if(weekDayStartTime != null && weekDayEndTime!= null) {
                    buildDayTimeMap(weekDayStartTime, startTimeMap, '1');
                    buildDayTimeMap(weekDayEndTime, endTimeMap, '1');
                }
                weekDayStartTime = String.valueOf(bhForCRON.MondayStartTime);
                weekDayEndTime = String.valueOf(bhForCRON.MondayEndTime);
                if(weekDayStartTime!= null && weekDayEndTime!= null) {
                    buildDayTimeMap(String.valueOf(bhForCRON.MondayStartTime), startTimeMap, '2');
                    buildDayTimeMap(String.valueOf(bhForCRON.MondayEndTime), endTimeMap, '2');
                }
                weekDayStartTime = String.valueOf(bhForCRON.TuesdayStartTime);
                weekDayEndTime = String.valueOf(bhForCRON.TuesdayEndTime);
                if(weekDayStartTime != null && weekDayEndTime!= null) {
                    buildDayTimeMap(String.valueOf(bhForCRON.TuesdayStartTime), startTimeMap, '3');
                    buildDayTimeMap(String.valueOf(bhForCRON.TuesdayEndTime), endTimeMap, '3');
                }
                weekDayStartTime = String.valueOf(bhForCRON.WednesdayStartTime);
                weekDayEndTime = String.valueOf(bhForCRON.WednesdayEndTime);
                if(weekDayStartTime != null && weekDayEndTime!= null) {
                    buildDayTimeMap(String.valueOf(bhForCRON.WednesdayStartTime), startTimeMap, '4');
                    buildDayTimeMap(String.valueOf(bhForCRON.WednesdayEndTime), endTimeMap, '4');
                }
                weekDayStartTime = String.valueOf(bhForCRON.ThursdayStartTime);
                weekDayEndTime = String.valueOf(bhForCRON.ThursdayEndTime);
                if(weekDayStartTime != null && weekDayEndTime!= null) {
                    buildDayTimeMap(String.valueOf(bhForCRON.ThursdayStartTime), startTimeMap, '5');
                    buildDayTimeMap(String.valueOf(bhForCRON.ThursdayEndTime), endTimeMap, '5');
                }
                weekDayStartTime = String.valueOf(bhForCRON.FridayStartTime);
                weekDayEndTime = String.valueOf(bhForCRON.FridayEndTime);
                if(weekDayStartTime != null && weekDayEndTime!= null) {
                    buildDayTimeMap(String.valueOf(bhForCRON.FridayStartTime), startTimeMap, '6');
                    buildDayTimeMap(String.valueOf(bhForCRON.FridayEndTime), endTimeMap, '6');
                }
                weekDayStartTime = String.valueOf(bhForCRON.SaturdayStartTime);
                weekDayEndTime = String.valueOf(bhForCRON.SaturdayEndTime);
                if(weekDayStartTime != null && weekDayEndTime!= null) {
                    buildDayTimeMap(String.valueOf(bhForCRON.SaturdayStartTime), startTimeMap, '7');
                    buildDayTimeMap(String.valueOf(bhForCRON.SaturdayEndTime), endTimeMap, '7');
                }
                
                String s1 = String.valueOf(TerritoryLst[i].SVMXC__Territory__c);
                
                String startCron = '';
                for(String startTime : startTimeMap.keySet()) {
                    TimeInterval = startTime.split(':', 3);
                    if(startCron.length() > 0) {
                        startCron += ';';
                    }
                    startCron += buildCRONExpression(TimeInterval[0], TimeInterval[1], startTimeMap.get(startTime));
                    System.debug(Logginglevel.DEBUG, 'ECO_CRONExpression: startCron = ' + startCron);
                }
                String stopCron = '';
                if(processobj.SVMXC__Settings_Name__c == system.label.WORD015_TAG207){
                    for(String endTime : endTimeMap.keySet()) {
                        TimeInterval = endTime.split(':', 3);
                        if(stopCron.length() > 0) {
                            stopCron += ';';
                        }
                        stopCron += buildCRONExpression(TimeInterval[0], TimeInterval[1], endTimeMap.get(endTime));
                        System.debug(Logginglevel.DEBUG, 'ECO_CRONExpression: stopCron = ' + stopCron);
                    }
                }
                
                // building holiday list for this territory using it's business hours
                String holidayDates = '';
                for(Holiday holiday : holidayList) {
                    String holActDate = '';
                    if(!clsOMaxExtension.isWorkingDay(bhForCRON, holiday.ActivityDate)) {
                        holActDate = String.valueOf(holiday.ActivityDate);
                        holActDate = holActDate.split(' ')[0];
                        holidayDates += holidayDates.length() == 0 ? holActDate : ',' + holActDate; 
                    }
                }
                if(holidayDates.length() > 0) {
                    OMAX_ServicemaxCom.parameter param = new  OMAX_ServicemaxCom.parameter();
                    param.name = 'HolidayDates';
                    param.category = s1;
                    param.value = holidayDates;
                    plist.add(param);
                    System.debug(Logginglevel.INFO, 'ECO_CRONExpression: holidayDates for territory + ' + s1 + ' = [' + param.name + ' | ' + param.category + ' | ' + param.value + ']');               
                }
                
                OMAX_ServicemaxCom.territorySchedule t1 = new OMAX_ServicemaxCom.territorySchedule();
                String cronExpression = startCron ;
                if(stopCron != ''){
                    cronExpression += '|' + stopCron ;
                }
                cronExpression += '~' + bhForCRON.TimeZoneSidKey ;
                t1 = buildSchedule(cronExpression, s1, OrgId, '', plist, processobj, 'Real Time Optimization');
                TList.add(t1);
                
                System.debug(Logginglevel.INFO, 'ECO_CRONExpression: CRON expression for territory + ' + s1 + ' = [' + startCron + '|' + stopCron + ']');
                
                /** below method creates a response object for ECO_LTP cron **/
                build_ECO_LTPCron(s1, OrgId, plist, TList, processobj);
                system.debug('WORD_OptimaxCall::ECO_CRONExpression:TList - ' + TList);
            }
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return TList;
    }
    
    public void build_ECO_LTPCron(String s1, String OrgId, List<OMAX_ServicemaxCom.parameter> plist, OMAX_ServicemaxCom.territorySchedule[] TList, SVMXC__ServiceMax_Processes__c processobj) {
        
        system.debug('WORD_OptimaxCall::build_ECO_LTPCron(): before: s1 -' + s1);
        String strTerrId = s1.substring(0,15);
        system.debug('WORD_OptimaxCall::build_ECO_LTPCron(): after: s1 -' + s1);
        system.debug('WORD_OptimaxCall::build_ECO_LTPCron(): strTerrId -' + strTerrId);

        OMAX_ServicemaxCom.territorySchedule t1 = new OMAX_ServicemaxCom.territorySchedule();
        if(ltpCORNExpressionFull0Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull0Min, strTerrId, OrgId, '_LTP00', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                  
        else if(ltpCORNExpressionFull5Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull5Min, strTerrId, OrgId, '_LTP05', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull10Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull10Min, strTerrId, OrgId, '_LTP10', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull15Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull15Min, strTerrId, OrgId, '_LTP15', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull20Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull20Min, strTerrId, OrgId, '_LTP20', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull25Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull25Min, strTerrId, OrgId, '_LTP25', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull30Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull30Min, strTerrId, OrgId, '_LTP30', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull35Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull35Min, strTerrId, OrgId, '_LTP35', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull40Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull40Min, strTerrId, OrgId, '_LTP40', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull45Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull45Min, strTerrId, OrgId, '_LTP45', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull50Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull50Min, strTerrId, OrgId, '_LTP50', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }                    
        else if(ltpCORNExpressionFull55Min.length() > 0) {
            t1 = buildSchedule(ltpCORNExpressionFull55Min, strTerrId, OrgId, '_LTP55', plist, processobj, 'Long-Term Planner');
            TList.add(t1);
            lstStrECO_LTPTerritoryIds.add(s1);
        }
    }
    
    public pagereference ECO_OptiMaxWebServiceCall(SVMXC__ServiceMax_Processes__c processobj, OMAX_ServicemaxCom.territorySchedule[] TList)
    {
        try
        {
            Cardential.clear();
            String OrgId = Userinfo.getOrganizationId().substring(0,15);
            String DisProID = processobj.id;
            Cardential = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Submodule__r.Id,RecordTypeId,SVMXC__Default_Value__c,SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03')];
            // get the Credential first....
            OMAX_ServicemaxCom.credential c1 = new OMAX_ServicemaxCom.credential();
            if(Cardential.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c pro : Cardential)
                {
                    if(pro.SVMXC__SettingID__c != null && pro.SVMXC__Default_Value__c != null)
                        mapCardential.put(pro.SVMXC__SettingID__c,pro.SVMXC__Default_Value__c);
                }
            }
            if(mapCardential.size() > 0)
            {
                if(mapCardential.containskey('PS01'))
                    c1.loginName = decryption1(mapCardential.get('PS01'));
                if(mapCardential.containskey('PS02'))
                    c1.password = decryption1(mapCardential.get('PS02'));
                if(mapCardential.containskey('PS03'))   
                    c1.securityToken = decryption1(mapCardential.get('PS03'));
            }    

            c1.orgGUID = OrgId;
            c1.userGUID = Userinfo.getUserId();
            System.debug(Logginglevel.INFO, 'ECO_OptiMaxWebServiceCall: Cardential = ' + c1);
               
            OMAX_ServicemaxCom.status WSDLStatus = new  OMAX_ServicemaxCom.status();
            OMAX_ServicemaxCom.OptimaxServicePort WSDLCall = new OMAX_ServicemaxCom.OptimaxServicePort();
            if(svmxSettingList.containsKey('GBL010') == true && svmxSettingList.get('GBL010') != null)
            {
                String EndpointURL_x = svmxSettingList.get('GBL010');
                System.debug(Logginglevel.INFO, 'ECO_OptiMaxWebServiceCall: EndpointURL = ' + EndpointURL_x);
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(EndpointURL_x);
                req.setTimeout(60000);//Added by amar on 30th Aug 2010
                HttpResponse res = new Http().send(req);
                string loc = res.getHeader('Location');
                System.debug(Logginglevel.INFO, 'ECO_OptiMaxWebServiceCall: Location' + loc);
                if((loc != NULL)&&(loc != '')) 
                { 
                    EndpointURL_x = loc; 
                }
                WSDLCall.endpoint_x = EndpointURL_x;
            }   
            WSDLStatus = WSDLCall.OMAX_Dispatch_Process_Definition_WS(c1, OrgId, DisProID, TList);
            System.debug(Logginglevel.INFO, 'ECO_OptiMaxWebServiceCall: WSDLStatus' + WSDLStatus);
            System.debug(Logginglevel.INFO, 'ECO_OptiMaxWebServiceCall: WSDLStatus' + WSDLStatus.message); 
            System.debug(Logginglevel.INFO, 'ECO_OptiMaxWebServiceCall: WSDLStatus' + WSDLStatus.status); 
            if(WSDLStatus.status == 'SUCCESS')
            {
                system.debug('************1174-success**********');
                Disprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(Disprocess, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert Disprocess;
                    /** This method creates a Job record for LTP if there is a CRON created**/
                    if(lstStrECO_LTPTerritoryIds.size() > 0) {
                        createLTPJobs(lstStrECO_LTPTerritoryIds, processobj.Id);
                    }
                    if(lstTerritoryId != null && !lstTerritoryId.isEmpty()) {
                        createRTOJobs(lstTerritoryId, processobj.Id);
                    }
                } else {
                    errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                    errorMessage.messageType = 'ERROR';
                    errorMessage.message = System.label.COMM001_TAG142;
                    WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'CONFIRM';
                errorMessage.message = DispMethods.getTAG141();
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG141()));//WSDLStatus.message
                pagereference newpage = new pagereference('/apex/WORD_ManageDispatchProcess');
                newpage.setRedirect(true);
                return newpage;
            }
            if(WSDLStatus.status == 'FAILURE')
            {
                system.debug('***************1196-failure***********');
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'ERROR';
                errorMessage.message = DispMethods.getTAG139()+ WSDLStatus.message;
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG139()+ WSDLStatus.message));//
                return null;
            }
            else
            {
                system.debug('************1206-success**********');
                Disprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(Disprocess, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert Disprocess;
                    /** This method creates a Job record for LTP if there is a CRON created**/
                    if(lstStrECO_LTPTerritoryIds.size() > 0) {
                        createLTPJobs(lstStrECO_LTPTerritoryIds, processobj.Id);
                    }
                    if(lstTerritoryId != null && !lstTerritoryId.isEmpty()) {
                        createRTOJobs(lstTerritoryId, processobj.Id);
                    }
                } else {
                    
                    errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                    errorMessage.messageType = 'ERROR';
                    errorMessage.message = System.label.COMM001_TAG142;
                    WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142)));
                }
                errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
                errorMessage.messageType = 'ERROR';
                errorMessage.message = DispMethods.getTAG141();
                WORD_SetupDispatchProcess.messagesList.add(errorMessage);
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG141()));
            }
        }
        catch (Exception ex) 
        {
            errorMessage = new WORD_SetupDispatchProcess.ErrorMessage();
            errorMessage.messageType = 'ERROR';
            errorMessage.message = ex.getMessage();
            WORD_SetupDispatchProcess.messagesList.add(errorMessage);
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
        return null;    
    }
    
    public void buildDayTimeMap(String timeString, Map<String, String> dayTimeMap, String dayString)
    {
        String days = '';
        if(dayTimeMap.keySet().contains(timeString)) {
            days = dayTimeMap.get(timeString);
            days += ',';
        }
        days += dayString;
        dayTimeMap.put(timeString, days);
    }
    
    public String buildCRONExpression(String hour, String min, String WeekDays)
    {
        String response = '';
        integer StartYear;
        
        if(Integer.valueOf(hour) < 10) {
            hour = hour.substring(1);
        }
        if(Integer.valueOf(min) < 10) {
            min = min.substring(1);
        }

        response = '0 ' + min + ' ' + hour;
        response += ' ?' + ' ' + '*' + ' ';
        response += WeekDays + ' ';
        response += '*' ;
        
        return response;
    }
    
    public void buildParameterList(List<OMAX_ServicemaxCom.parameter> plist, SVMXC__ServiceMax_Processes__c objSVMXProcess) {
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>{'OMAX001_SET001','OMAX001_SET002','OMAX001_SET003','OMAX001_SET004','OMAX001_SET005',
            'OMAX001_SET006','OMAX001_SET007','OMAX001_SET008','OMAX001_SET009','OMAX001_SET011','OMAX001_SET012','OMAX001_SET013','OMAX001_SET017',
            'OMAX003_SET037','OMAX003_SET038','OMAX003_SET039','OMAX003_SET040','OMAX003_SET041'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
        
        String geocodingValue = WSCH_CommonUtils.getSettingValue('DCON001','SET071');
        plist.add(setParameter('Optimax.Geocoding', geocodingValue));
        if(mapSettingValues.containsKey('OMAX001_SET011') == TRUE && mapSettingValues.containsKey('OMAX001_SET012') == TRUE)
        {
            plist.add(setParameter('Optimax.debug', String.valueof(mapSettingValues.get('OMAX001_SET011'))));
            plist.add(setParameter('Optimax.debugMail', String.valueof(mapSettingValues.get('OMAX001_SET012'))));
        }
        if(mapSettingValues.containsKey('OMAX001_SET001') == TRUE)
        {
            plist.add(setParameter('JOpt.Assisted', String.valueof(mapSettingValues.get('OMAX001_SET001'))));
        }
        if(mapSettingValues.containsKey('OMAX001_SET002') == TRUE)
        {
            plist.add(setParameter('JOpt.AssistedMode', String.valueof(mapSettingValues.get('OMAX001_SET002'))));
        }
        if(mapSettingValues.containsKey('OMAX001_SET003') == TRUE)
        {
            plist.add(setParameter('JOpt.OptimizationRule', String.valueof(mapSettingValues.get('OMAX001_SET003'))));
        }
        /*if(mapSettingValues.containsKey('OMAX001_SET004') == TRUE)
        {
            String value = String.valueof(mapSettingValues.get('OMAX001_SET004'));
            value = value.replace('OptiMax', 'JOpt');
            plist.add(setParameter('JOptExitCondition.Type', value));
        }
        if(mapSettingValues.containsKey('OMAX001_SET005') == TRUE)
        {
            plist.add(setParameter('JOptExitCondition.Count', String.valueof(mapSettingValues.get('OMAX001_SET005'))));
        }
        if(mapSettingValues.containsKey('OMAX001_SET006') == TRUE)
        {
            plist.add(setParameter('JOptExitCondition.JOptConvergencyCount', String.valueof(mapSettingValues.get('OMAX001_SET006'))));
        }*/
        if(mapSettingValues.containsKey('OMAX001_SET007') == TRUE)
        {
            plist.add(setParameter('JOptExitCondition.JOptGenerationCount', String.valueof(mapSettingValues.get('OMAX001_SET007'))));
        }
        /*if(mapSettingValues.containsKey('OMAX001_SET008') == TRUE)
        {
            plist.add(setParameter('JOptWeight.Capacity', String.valueof(mapSettingValues.get('OMAX001_SET008'))));
        }
        if(mapSettingValues.containsKey('OMAX001_SET009') == TRUE)
        {
            plist.add(setParameter('JOptWeight.ResourceLoadBalance', String.valueof(mapSettingValues.get('OMAX001_SET009'))));
        }
        if(mapSettingValues.containsKey('OMAX001_SET013') == TRUE)
        {
            plist.add(setParameter('JOptWeight.CompactingFactor', String.valueof(mapSettingValues.get('OMAX001_SET013'))));
        }*/
        if(objSVMXProcess.SVMXC__Route_Type__c != NULL)
        {
            plist.add(setParameter('JOpt.RouteType', objSVMXProcess.SVMXC__Route_Type__c));
        }
        /*if(objSVMXProcess.SVMXC__Weight_Time_Window__c != NULL)
        {
             //plist.add(setParameter('JOptWeight.TimeWindow', String.valueof(objSVMXProcess.SVMXC__Weight_Time_Window__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET040')))));
             plist.add(setParameter('Objectives.CostBucket.TimeWindow', String.valueof(objSVMXProcess.SVMXC__Weight_Time_Window__c)));
        }
        if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
        {
            //plist.add(setParameter('JOptWeight.TotalDistance', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET041')))));
            plist.add(setParameter('Objectives.CostBucket.WorkDistribution', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c)));
            
        }
        if(objSVMXProcess.SVMXC__Weight_Route_Distance__c != NULL)
        {
            //plist.add(setParameter('JOptWeight.RouteDistance', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Distance__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET038')))));
            plist.add(setParameter('Objectives.CostBucket.Distance', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Distance__c)));
        }
        if(objSVMXProcess.SVMXC__Weight_Route_Time__c != NULL)
        {
            //plist.add(setParameter('JOptWeight.RouteTime', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Time__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET039')))));
            plist.add(setParameter('Objectives.CostBucket.Time', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Time__c)));
        }
        if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
        {
             //plist.add(setParameter('JOptWeight.PreferableResource', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET037')))));
             plist.add(setParameter('Objectives.CostBucket.Relations', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c)));
        }*/
        if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
        {
            plist.add(setParameter('distanceWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c)));
        }
        if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
        {
             plist.add(setParameter('MCTMWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c)));
        }
        if(mapSettingValues.containsKey('OMAX001_SET017') == TRUE)
        {
            plist.add(setParameter('distanceProvider', String.valueof(mapSettingValues.get('OMAX001_SET017'))));
        }
        if(objSVMXProcess.SVMXC__Dispatch_Threshold__c != NULL)
        {
             plist.add(setParameter('Optimax.eco.DispatchThreshold', String.valueof(objSVMXProcess.SVMXC__Dispatch_Threshold__c)));
        }
        if(objSVMXProcess.SVMXC__Optimizer_Sync_Interval__c != NULL)
        {
             plist.add(setParameter('Optimax.eco.OptimizerSyncInterval', String.valueof(objSVMXProcess.SVMXC__Optimizer_Sync_Interval__c)));
        }
        /*if(objSVMXProcess.SVMXC__Optimization_Goal__c != NULL) {
            plist.add(setParameter('Objectives.Name', String.valueof(objSVMXProcess.SVMXC__Optimization_Goal__c)));
        }*/

        //Capacity Limitation in RTO
        Map<Id, SVMXC__ServiceMax_Processes__c> mapCapacityRules = new Map<Id, SVMXC__ServiceMax_Processes__c>();   
        mapCapacityRules.putAll([SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__SM_Capacity_Threshold__c, RecordType.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:objSVMXProcess.Id And RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Capacity Reservation' order by SVMXC__Sequence__c]);

        List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> lstExcSetting_WP_CapacityReservtn = new List<WSCH_Provider_ECO_Stubs.ExcSetting_WP>();      

        if(mapCapacityRules != null && mapCapacityRules.size() > 0){
            for(SVMXC__ServiceMax_Processes__c capacityRule : mapCapacityRules.values()){
                plist.add(setParameter('CapacityReservation.Category.'+capacityRule.SVMXC__Name__c+'', String.valueof(capacityRule.SVMXC__SM_Capacity_Threshold__c)));
            }                      
        }

        //adding the batch sizes for event, WO and Technician data sync to server from client
        String strWorkOrderBatchSize = '0'; //these values to come from the custom/standard setting
        String strResourceBatchSize = '0';
        String strEventBatchSize = '0';
        String strIsRTOBatched = 'False';

        strIsRTOBatched = WSCH_CommonUtils.getSettingValue('OMAX004','SET008');
        if(String.isNotEmpty(strIsRTOBatched)){
            strWorkOrderBatchSize = WSCH_CommonUtils.getSettingValue('OMAX004','SET009');
            strResourceBatchSize = WSCH_CommonUtils.getSettingValue('OMAX004','SET010');
            strEventBatchSize = WSCH_CommonUtils.getSettingValue('OMAX004','SET011');
        }else{
            strIsRTOBatched = 'False';
        }
        plist.add(setParameter('IsRTOBatched', strIsRTOBatched));
        plist.add(setParameter('WoBatchSize', strWorkOrderBatchSize));
        plist.add(setParameter('RsrcBatchSize', strResourceBatchSize));
        plist.add(setParameter('EventBatchSize', strEventBatchSize));
    }
    
    public OMAX_ServicemaxCom.parameter setParameter(String key, String value)
    {
        OMAX_ServicemaxCom.parameter param = new OMAX_ServicemaxCom.parameter();
        param.name = key;
        param.value = value;
        return param;
    }   

}