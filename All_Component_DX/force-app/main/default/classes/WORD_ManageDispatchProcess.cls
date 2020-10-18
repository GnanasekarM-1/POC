public with sharing class WORD_ManageDispatchProcess
{
    /*Wrapper for the Radio button implemetation*/
    public class JobRecWrapper
    {
        Boolean isJobSelected;
        SVMXC__SVMX_Jobs__c jobRec;
        public SVMXC__SVMX_Jobs__c getjobRec(){return jobRec;}
        public void setobjjobRec(SVMXC__SVMX_Jobs__c rec){jobRec = rec;}
        public JobRecWrapper(Boolean isCurrSel, SVMXC__SVMX_Jobs__c currJobRec)
        {
            isJobSelected = isCurrSel;
            jobRec = currJobRec;
        }
    }
    public List<JobRecWrapper> JobRecLst = new List<JobRecWrapper>();
    public List<JobRecWrapper> getJobRecLst() {return JobRecLst;  }
    public string selectedId='';
    public string getselectedId() {return selectedId;  }
    public void setselectedId(string ids){this.selectedId=ids;}
    /*End of wrapper*/
    //Global Variables Declaration...
    public SVMXC__ServiceMax_Processes__c processobj;
    public List<SVMXC__ServiceMax_Processes__c> DispatchProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> DelDispatchProcess = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> ExceptionProcess = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> RuleLst = new List<SVMXC__ServiceMax_Processes__c>(); 
    public List<SVMXC__ServiceMax_Processes__c> TerritoryRecLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> PriortizationLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> DPExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> IncrementRunExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> RuleExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c>  PriorityExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ltpScheduleConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__SVMX_Jobs__c> jobsList = new List<SVMXC__SVMX_Jobs__c>();
    public List<RecordType> RecType = new  List<RecordType>();
    public List<RecordType> ConfigRecordTypes = new  List<RecordType>();
    public List<SVMXC__ServiceMax_Config_Data__c> DelConfingData = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String,string> MapofAruleID = new Map<String,string>();
    public Map<String,string> MapofPruleID = new Map<String,string>();
    public String DispatchProcessID = ''; 
    public String DelARuleId;
    public String DelPRuleId;
    public string DispatchRTypeId;
    public String RuleRecordTypeId;
    public string ExpressionRTypeId;
    public string Schedule_Rtype_Id; // added for LTP
    public String DPEId;
    public String DPEDispatchMethod;
    public String DPCId;
    public String RuleId;
    public String PriorityId;
    public Boolean HdrMsg = true;
    public Integer MaxSequence = 0;
    public transient List<AggregateResult> Aggresult = new List<AggregateResult>(); 
    //Instance of Utilitis, Setting & DisplayTags
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD014');

    // SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD014'); 
    
     //invoke the webservice
    public OMAX_ServicemaxCom.status WSDLStatus = new  OMAX_ServicemaxCom.status();
    public OMAX_ServicemaxCom.OptimaxServicePort WSDLCall = new OMAX_ServicemaxCom.OptimaxServicePort();
    
     public List<SVMXC__ServiceMax_Processes__c> proCredList = new List<SVMXC__ServiceMax_Processes__c>();
     
        public List<SVMXC__ServiceMax_Processes__c> getProCredList(){return proCredList;}
    public void setProCredList(List<SVMXC__ServiceMax_Processes__c> pro){proCredList = pro;}
     
    
    
    public boolean isActiveJob;
    
     public boolean getIsActiveJob() {
        return this.isActiveJob;
    }
    
     public void setIsActiveJob(boolean activeJob) {
         this.isActiveJob=activeJob;
    }
    
    public boolean isRealTimeOptProcess = false;
    
     public boolean getIsRealTimeOptProcess() {
        return this.isRealTimeOptProcess;
    }
    
     public void setIsRealTimeOptProcess(boolean isRealTimeOptProcess) {
         this.isRealTimeOptProcess=isRealTimeOptProcess;
    }
    
    public boolean enableAbortJobButton = false;
    
    
      public boolean getEnableAbortJobButton() {
        return this.enableAbortJobButton;
    }
    
     public void setEnableAbortJobButton(boolean enableAbortJobButton) {
         this.enableAbortJobButton=enableAbortJobButton;
    }

    public WORD_ManageDispatchProcess ()
    {
        RecType = Database.Query('Select r.Name, r.Id From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        system.debug('RecType'+RecType);
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
            if(Rt.Name == 'SVMX Rule')
            {
                RuleRecordTypeId = Rt.id;
            }
        }
        ConfigRecordTypes = Database.query('Select r.Name, r.Id From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            
            /** added for LTP **/
            if(r.Name == 'Schedule')
                Schedule_Rtype_Id = r.Id;
        }
        DispatchProcessLst = Database.query('Select  s.SVMXC__Dispatch_Process_Status__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Name__c, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId = \'' + DispatchRTypeId + '\'order by SVMXC__Sequence__c');
        
    }
    
    
    //Getter & Setter Methods....
    public List<SVMXC__ServiceMax_Processes__c> getDispatchProcessLst(){return DispatchProcessLst;}
    public void setDispatchProcessLst(List<SVMXC__ServiceMax_Processes__c> pro){DispatchProcessLst = pro;}
    public Boolean getHdrMsg(){return HdrMsg;}
    public boolean getDisProSize()
    {
        if(DispatchProcessLst.size() == 0)
            return true;
        else
            return false;
    }
    public Boolean getDisProLst()
    {
        if(DispatchProcessLst.size() > 0)
            return true;
        else
            return false;
    }
    
    public Boolean ValidProcess = true;
    public List<Integer> SelectedLines = new List<Integer>();
    public Boolean ValidProcess()
    {
        ValidProcess = true;
        SelectedLines.clear();
        for(Integer i = 0; i<DispatchProcessLst.size(); i++)
        {
            if(DispatchProcessLst[i].SVMXC__Select__c == true)
            {
                SelectedLines.add(i);
            }
        }
        if(SelectedLines.size() == 0)
        {
            ValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG014()));
        }
        if(SelectedLines.size() > 1)
        {
            ValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG015()));
        }
        return ValidProcess;
    }
    public pagereference SVMX_NewProcess()
    {
        return page.WORD_SetupDispatchProcess;
    }
    public pagereference SVMX_Clone()
    {
        DPExpression.clear();
        IncrementRunExpression.clear();
        RuleLst.clear();
        MapofAruleID.clear();
        RuleExpression.clear();
        TerritoryRecLst.clear();
        PriortizationLst.clear();
        MapofPruleID.clear();
        PriorityExpression.clear();
        RuleId = '';
        PriorityId = '';
        if(ValidProcess() == true)
        {
            for(Integer i = 0; i<DispatchProcessLst.size(); i++)
            {
                System.debug('SVMX_Clone::Dispatch Process: ' + DispatchProcessLst[i]);
                if(DispatchProcessLst[i].SVMXC__Select__c == true)
                {
                    DPCId = DispatchProcessLst[i].id;
                }
            }
            //Get the Dispatch Process Data & clone it 
            SVMXC__ServiceMax_Processes__c processobj2 = Database.Query('Select SVMXC__Dispatch_Process_Status__c, SVMXC__Optimization_Goal__c, SVMXC__Tolerance__c,SVMXC__Retain_Appointment__c, SVMXC__Retain_Assignment__c, SVMXC__Dispatch_Timezone__c, SVMXC__Full_Run_Unit__c, SVMXC__Final_Exception_Process__c, s.SystemModstamp, s.SVMXC__Weight_Total_Distance__c, SVMXC__Process__c,s.SVMXC__Weight_Time_Window__c, s.SVMXC__Territory__c, s.SVMXC__Start_Time__c, s.SVMXC__Start_Date__c, s.SVMXC__Sequence__c, s.SVMXC__Schedule_Event__c, s.SVMXC__Runs_Every_Wednesday__c, s.SVMXC__Runs_Every_Tuesday__c, s.SVMXC__Runs_Every_Thursday__c, s.SVMXC__Runs_Every_Sunday__c, s.SVMXC__Runs_Every_Saturday__c, s.SVMXC__Runs_Every_Monday__c, s.SVMXC__Runs_Every_Friday__c, s.SVMXC__Weight_Route_Time__c, s.SVMXC__Route_Type__c, s.SVMXC__Weight_Route_Distance__c, s.SVMXC__Calendar_Start_Days__c, s.SVMXC__Calendar_End_Days__c, s.SVMXC__Product_Match_Enabled__c, s.SVMXC__Expertise_Match_Enabled__c, s.SVMXC__Frequency__c, s.SVMXC__End_Date__c, s.SVMXC__Email_On_Success__c, s.SVMXC__Email_On_Error__c, s.SVMXC__Distance_And_Time__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Weight_Node_Type__c, SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c, s.SVMXC__Preferred_Tech_Enabled__c, s.SVMXC__Calendar_Start_Type__c, s.SVMXC__Calendar_End_Type__c, s.SVMXC__Assign_Work_Order_To__c, s.SVMXC__Assign_To_Technician__c, s.SVMXC__Assign_To_Queue__c, s.SVMXC__Assign_To_Dispatcher__c, s.SVMXC__Values__c, s.SVMXC__Target_Record_Type__c, s.SVMXC__Target_Object_Name__c, s.SVMXC__Submodule__c, s.SVMXC__SubmoduleID__c, s.SVMXC__Source_Object_Name__c, s.SVMXC__Settings_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_Type__c, s.SVMXC__SettingID__c, s.SVMXC__Select__c, s.SVMXC__Search_Order__c, s.SVMXC__Rule_Type__c, s.SVMXC__Record_Type_Name__c, s.SVMXC__ProcessID__c, s.SVMXC__Parent_Object_Criteria__c, s.SVMXC__Name__c, s.SVMXC__Module__c, s.SVMXC__ModuleID__c, s.SVMXC__MapID__c, s.SVMXC__IsStandard__c, s.SVMXC__IsPrivate__c, s.SVMXC__Installation_Key__c, s.SVMXC__Description__c, s.SVMXC__Default_Value__c, s.SVMXC__Data_Type__c, s.SVMXC__Child_Object_Criteria__c, s.SVMXC__Advance_Expression__c, s.SVMXC__Active__c, s.RecordTypeId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.Id, s.SVMXC__Dispatch_Threshold__c, s.SVMXC__Optimizer_Sync_Interval__c From SVMXC__ServiceMax_Processes__c s where id = \''+DPCId+'\' and RecordTypeId = \''+DispatchRTypeId+'\'');
            processobj2.SVMXC__Start_Date__c = null;
            processobj2.SVMXC__Sequence__c = null;
            processobj = new SVMXC__ServiceMax_Processes__c();
            processobj = processobj2.clone(false,true);
            processobj.SVMXC__Name__c = processobj2.SVMXC__Name__c + ' ' +system.now();
            processobj.SVMXC__Values__c = null;
            if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch' || processobj.SVMXC__Dispatch_Method__c == 'Real Time Optimization' ||
                                                    processobj.SVMXC__Dispatch_Method__c == 'Long-Term Planner')
                processobj.SVMXC__Dispatch_Process_Status__c = 'Incomplete';
            Aggresult = [select MAX(SVMXC__Sequence__c) FROM SVMXC__ServiceMax_Processes__c   where recordtypeid =: DispatchRTypeId];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for (AggregateResult ar : Aggresult) 
            {
                object Obj = ar.get('expr0');
                String s = string.valueOf(Obj);
                s = s.replace('.','_');
                List<String> s1 = new List<String>(); 
                s1  = s.split('_',2);
                s = s1[0];
                MaxSequence = integer.valueOf(s);
            }
            if(processobj.id == null)
            {
                processobj.SVMXC__Sequence__c = MaxSequence + 1;
            }   
            upsert processobj;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Config_Data__c> DPExpression2 = Database.Query('Select s.SVMXC__User__c, s.SVMXC__Target_Field_Name__c, s.SVMXC__Stock_Status__c, s.SVMXC__Stock_History_Line_Lookup_Field__c, s.SVMXC__Stock_History_Header_Lookup_Field__c, s.SVMXC__Source_Field_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_ID__c, s.SVMXC__Setting_Configuration_Profile__c, s.SVMXC__SettingID__c, s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__RecordType_Name__c, s.SVMXC__Profile__c, s.SVMXC__Profile_Name__c, s.SVMXC__Operator__c, s.SVMXC__Operand__c, s.SVMXC__Object_Name__c, s.SVMXC__MapID__c, s.SVMXC__Lookup_Field_API_Name__c, s.SVMXC__Location_Type__c, s.SVMXC__Location_Field_Name__c, s.SVMXC__Location_Field_From__c, s.SVMXC__IsDefault__c, s.SVMXC__Inventory_Process__c, s.SVMXC__Internal_Value__c, s.SVMXC__Installation_Key__c, s.SVMXC__Field_Name__c, s.SVMXC__FKey_Name_Field__c, s.SVMXC__Expression_Type__c, s.SVMXC__Expression_Rule__c, s.SVMXC__Enter_Date__c, s.SVMXC__Display_Value__c, s.SVMXC__Display_Type__c, s.SVMXC__Display_Map_ID__c, s.SVMXC__Description__c, s.SVMXC__Configuration_Type__c, s.SVMXC__Config_Profile_Name__c, s.SVMXC__Active__c, s.SVMXC__Action__c, s.SVMXC__Access_Configuration_Profile__c, s.RecordTypeId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+DPCId+'\' and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Process_Entry\'');
            if(DPExpression2.size() > 0)
            {
                for(Integer i=0; i < DPExpression2.size(); i++)
                {
                    DPExpression.add(DPExpression2[i].clone(false,true));
                }
                for(Integer i = 0; i < DPExpression.size(); i++)
                {
                    DPExpression[i].SVMXC__Expression_Rule__c = processobj.id;
                }
            }   
            upsert DPExpression;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Config_Data__c> IncreExpression = Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c = \''+DPCId+'\' and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Schedule_Exp\'');
            if(IncreExpression.size() > 0)
            {
                for(Integer i=0; i < IncreExpression.size(); i++)
                {
                    IncrementRunExpression.add(IncreExpression[i].clone(false,true));
                }
                for(Integer i = 0; i < IncrementRunExpression.size(); i++)
                {
                    IncrementRunExpression[i].SVMXC__Expression_Rule__c = processobj.id;
                }
            }   
            upsert IncrementRunExpression;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(processobj.SVMXC__Dispatch_Method__c == 'Immediate')
            {
                //Get the Assignment rule associated with that Dispatch Process & clone it..
                List<SVMXC__ServiceMax_Processes__c> RuleLst2 = Database.Query('Select s.SVMXC__Weight_Total_Distance__c,SVMXC__Process__c, s.SVMXC__Weight_Time_Window__c, s.SVMXC__Territory__c, s.SVMXC__Start_Time__c, s.SVMXC__Start_Date__c, s.SVMXC__Sequence__c, s.SVMXC__Schedule_Event__c, s.SVMXC__Runs_Every_Wednesday__c, s.SVMXC__Runs_Every_Tuesday__c, s.SVMXC__Runs_Every_Thursday__c, s.SVMXC__Runs_Every_Sunday__c, s.SVMXC__Runs_Every_Saturday__c, s.SVMXC__Runs_Every_Monday__c, s.SVMXC__Runs_Every_Friday__c, s.SVMXC__Weight_Route_Time__c, s.SVMXC__Route_Type__c, s.SVMXC__Weight_Route_Distance__c, s.SVMXC__Calendar_Start_Days__c, s.SVMXC__Calendar_End_Days__c, s.SVMXC__Product_Match_Enabled__c, s.SVMXC__Expertise_Match_Enabled__c, s.SVMXC__Frequency__c, s.SVMXC__End_Date__c, s.SVMXC__Email_On_Success__c, s.SVMXC__Email_On_Error__c, s.SVMXC__Distance_And_Time__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Weight_Node_Type__c,SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c, s.SVMXC__Preferred_Tech_Enabled__c, s.SVMXC__Calendar_Start_Type__c, s.SVMXC__Calendar_End_Type__c, s.SVMXC__Assign_Work_Order_To__c, s.SVMXC__Assign_To_Technician__c, s.SVMXC__Assign_To_Queue__c, s.SVMXC__Assign_To_Dispatcher__c, s.SVMXC__Values__c, s.SVMXC__Target_Record_Type__c, s.SVMXC__Target_Object_Name__c, s.SVMXC__Submodule__c, s.SVMXC__SubmoduleID__c, s.SVMXC__Source_Object_Name__c, s.SVMXC__Settings_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_Type__c, s.SVMXC__SettingID__c, s.SVMXC__Select__c, s.SVMXC__Search_Order__c, s.SVMXC__Rule_Type__c, s.SVMXC__Record_Type_Name__c, s.SVMXC__ProcessID__c, s.SVMXC__Parent_Object_Criteria__c, s.SVMXC__Name__c, s.SVMXC__Module__c, s.SVMXC__ModuleID__c, s.SVMXC__MapID__c, s.SVMXC__IsStandard__c, s.SVMXC__IsPrivate__c, s.SVMXC__Installation_Key__c, s.SVMXC__Description__c, s.SVMXC__Default_Value__c, s.SVMXC__Data_Type__c, s.SVMXC__Child_Object_Criteria__c, s.SVMXC__Advance_Expression__c, s.SVMXC__Active__c, s.RecordTypeId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c = \''+DPCId+'\' and RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Simple Assignment\'order by SVMXC__Sequence__c');
                if(RuleLst2.size() > 0)
                {
                    for(Integer i=0; i < RuleLst2.size(); i++)
                    {
                        RuleLst.add(RuleLst2[i].clone(false,true));
                    }
                    for(Integer i=0; i < RuleLst.size(); i++)
                    {
                        RuleLst[i].SVMXC__Process__c = processobj.id;
                        RuleLst[i].SVMXC__Name__c = RuleLst[i].SVMXC__Name__c+ ' ' + i + ' ' + system.now();
                    }
                }
                upsert RuleLst;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(Integer j = 0;j<RuleLst2.size();j++)
                {
                    if(RuleId.length() > 0)
                        RuleId += ',';
                    RuleId += '\'' + String.valueOf(RuleLst2[j].id)+ '\'';
                }
                for(Integer i = 0; i<RuleLst2.size(); i++)
                {
                    MapofAruleID.put(RuleLst2[i].id,RuleLst[i].id);
                }
                List<SVMXC__ServiceMax_Config_Data__c> RuleExpression2 = new List<SVMXC__ServiceMax_Config_Data__c>();
                if(RuleId.length() > 0)
                {   
                    RuleExpression2 = Database.Query('Select s.SVMXC__User__c, s.SVMXC__Target_Field_Name__c, s.SVMXC__Stock_Status__c, s.SVMXC__Stock_History_Line_Lookup_Field__c, s.SVMXC__Stock_History_Header_Lookup_Field__c, s.SVMXC__Source_Field_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_ID__c, s.SVMXC__Setting_Configuration_Profile__c, s.SVMXC__SettingID__c, s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__RecordType_Name__c, s.SVMXC__Profile__c, s.SVMXC__Profile_Name__c, s.SVMXC__Operator__c, s.SVMXC__Operand__c, s.SVMXC__Object_Name__c, s.SVMXC__MapID__c, s.SVMXC__Lookup_Field_API_Name__c, s.SVMXC__Location_Type__c, s.SVMXC__Location_Field_Name__c, s.SVMXC__Location_Field_From__c, s.SVMXC__IsDefault__c, s.SVMXC__Inventory_Process__c, s.SVMXC__Internal_Value__c, s.SVMXC__Installation_Key__c, s.SVMXC__Field_Name__c, s.SVMXC__FKey_Name_Field__c, s.SVMXC__Expression_Type__c, s.SVMXC__Expression_Rule__c, s.SVMXC__Enter_Date__c, s.SVMXC__Display_Value__c, s.SVMXC__Display_Type__c, s.SVMXC__Display_Map_ID__c, s.SVMXC__Description__c, s.SVMXC__Configuration_Type__c, s.SVMXC__Config_Profile_Name__c, s.SVMXC__Active__c, s.SVMXC__Action__c, s.SVMXC__Access_Configuration_Profile__c, s.RecordTypeId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c in( '+RuleId+ ') and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Simple_Assignment\'');
                }   
                for(integer i = 0;i<RuleExpression2.size(); i++)
                {
                    RuleExpression.add(RuleExpression2[i].clone(false,true));
                }
                for(integer i = 0; i<RuleExpression.size(); i++)
                {
                    for(String s :MapofAruleID.keyset())
                    {
                        if( s == RuleExpression[i].SVMXC__Expression_Rule__c)
                            RuleExpression[i].SVMXC__Expression_Rule__c = MapofAruleID.get(s);
                    }   
                }
                upsert RuleExpression;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }   
            if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch')
            {
               /* List<SVMXC__ServiceMax_Processes__c> TerritoryRecLst2 = Database.Query('Select s.SystemModstamp, SVMXC__Territory__r.name,s.SVMXC__Weight_Total_Distance__c,SVMXC__Process__c, s.SVMXC__Weight_Time_Window__c, s.SVMXC__Territory__c, s.SVMXC__Start_Time__c, s.SVMXC__Start_Date__c, s.SVMXC__Sequence__c, s.SVMXC__Schedule_Event__c, s.SVMXC__Runs_Every_Wednesday__c, s.SVMXC__Runs_Every_Tuesday__c, s.SVMXC__Runs_Every_Thursday__c, s.SVMXC__Runs_Every_Sunday__c, s.SVMXC__Runs_Every_Saturday__c, s.SVMXC__Runs_Every_Monday__c, s.SVMXC__Runs_Every_Friday__c, s.SVMXC__Weight_Route_Time__c, s.SVMXC__Route_Type__c, s.SVMXC__Weight_Route_Distance__c, s.SVMXC__Calendar_Start_Days__c, s.SVMXC__Calendar_End_Days__c, s.SVMXC__Product_Match_Enabled__c, s.SVMXC__Expertise_Match_Enabled__c, s.SVMXC__Frequency__c, s.SVMXC__End_Date__c, s.SVMXC__Email_On_Success__c, s.SVMXC__Email_On_Error__c, s.SVMXC__Distance_And_Time__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Weight_Node_Type__c, s.SVMXC__Preferred_Tech_Enabled__c, s.SVMXC__Calendar_Start_Type__c, s.SVMXC__Calendar_End_Type__c, s.SVMXC__Assign_Work_Order_To__c, s.SVMXC__Assign_To_Technician__c, s.SVMXC__Assign_To_Queue__c, s.SVMXC__Assign_To_Dispatcher__c, s.SVMXC__Values__c, s.SVMXC__Target_Record_Type__c, s.SVMXC__Target_Object_Name__c, s.SVMXC__Submodule__c, s.SVMXC__SubmoduleID__c, s.SVMXC__Source_Object_Name__c, s.SVMXC__Settings_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_Type__c, s.SVMXC__SettingID__c, s.SVMXC__Select__c, s.SVMXC__Search_Order__c, s.SVMXC__Rule_Type__c, s.SVMXC__Record_Type_Name__c, s.SVMXC__ProcessID__c, s.SVMXC__Parent_Object_Criteria__c, s.SVMXC__Name__c, s.SVMXC__Module__c, s.SVMXC__ModuleID__c, s.SVMXC__MapID__c, s.SVMXC__IsStandard__c, s.SVMXC__IsPrivate__c, s.SVMXC__Installation_Key__c, s.SVMXC__Description__c, s.SVMXC__Default_Value__c, s.SVMXC__Data_Type__c, s.SVMXC__Child_Object_Criteria__c, s.SVMXC__Advance_Expression__c, s.SVMXC__Active__c, s.RecordTypeId, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById,  s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c = \''+DPCId+'\' and RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Territory Access\'');
                if(TerritoryRecLst2.size() > 0)
                {
                    for(integer i = 0;i<TerritoryRecLst2.size(); i++)
                    {
                        TerritoryRecLst.add(TerritoryRecLst2[i].clone(false,true));
                    }
                    for(integer i = 0;i<TerritoryRecLst.size();i++)
                    {
                        TerritoryRecLst[i].SVMXC__Process__c = processobj.id;
                    }
                }   
                upsert TerritoryRecLst;*/
                /* Clone for the scheduling tab run information */
                List<SVMXC__ServiceMax_Config_Data__c> ActualRunInfoLst = Database.Query('Select s.SVMXC__Display_Type__c,s.SVMXC__Expression_Type__c,s.SVMXC__Run_At__c,s.SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c =\'' + DPCId + '\'  and SVMXC__Expression_Type__c =\'DISP_Schedule\'');
                List<SVMXC__ServiceMax_Config_Data__c> CloneRunInfoLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                if(ActualRunInfoLst != null && ActualRunInfoLst.size() > 0)
                {
                    SVMXC__ServiceMax_Config_Data__c tempObj = null;
                    for(SVMXC__ServiceMax_Config_Data__c currentSO : ActualRunInfoLst)
                    {
                        tempObj = currentSO.clone(false,true);
                        tempObj.SVMXC__Expression_Rule__c = processobj.id;
                        CloneRunInfoLst.add(tempObj);
                    }
                    insert CloneRunInfoLst;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                /* End for the scheduling tab */
            }
            if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch' || processobj.SVMXC__Dispatch_Method__c == 'Real Time Optimization')
            {
                List<SVMXC__ServiceMax_Processes__c> PriortizationLst2 = Database.Query('Select s.SVMXC__Weight_Total_Distance__c,SVMXC__Process__c, s.SVMXC__Weight_Time_Window__c, s.SVMXC__Territory__c, s.SVMXC__Start_Time__c, s.SVMXC__Start_Date__c, s.SVMXC__Sequence__c, s.SVMXC__Schedule_Event__c, s.SVMXC__Runs_Every_Wednesday__c, s.SVMXC__Runs_Every_Tuesday__c, s.SVMXC__Runs_Every_Thursday__c, s.SVMXC__Runs_Every_Sunday__c, s.SVMXC__Runs_Every_Saturday__c, s.SVMXC__Runs_Every_Monday__c, s.SVMXC__Runs_Every_Friday__c, s.SVMXC__Weight_Route_Time__c, s.SVMXC__Route_Type__c, s.SVMXC__Weight_Route_Distance__c, s.SVMXC__Calendar_Start_Days__c, s.SVMXC__Calendar_End_Days__c, s.SVMXC__Product_Match_Enabled__c, s.SVMXC__Expertise_Match_Enabled__c, s.SVMXC__Frequency__c, s.SVMXC__End_Date__c, s.SVMXC__Email_On_Success__c, s.SVMXC__Email_On_Error__c, s.SVMXC__Distance_And_Time__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Weight_Node_Type__c,SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c, s.SVMXC__Preferred_Tech_Enabled__c, s.SVMXC__Calendar_Start_Type__c, s.SVMXC__Calendar_End_Type__c, s.SVMXC__Assign_Work_Order_To__c, s.SVMXC__Assign_To_Technician__c, s.SVMXC__Assign_To_Queue__c, s.SVMXC__Assign_To_Dispatcher__c, s.SVMXC__Values__c, s.SVMXC__Target_Record_Type__c, s.SVMXC__Target_Object_Name__c, s.SVMXC__Submodule__c, s.SVMXC__SubmoduleID__c, s.SVMXC__Source_Object_Name__c, s.SVMXC__Settings_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_Type__c, s.SVMXC__SettingID__c, s.SVMXC__Select__c, s.SVMXC__Search_Order__c, s.SVMXC__Rule_Type__c, s.SVMXC__Record_Type_Name__c, s.SVMXC__ProcessID__c, s.SVMXC__Parent_Object_Criteria__c, s.SVMXC__Name__c, s.SVMXC__Module__c, s.SVMXC__ModuleID__c, s.SVMXC__MapID__c, s.SVMXC__IsStandard__c, s.SVMXC__IsPrivate__c, s.SVMXC__Installation_Key__c, s.SVMXC__Description__c, s.SVMXC__Default_Value__c, s.SVMXC__Data_Type__c, s.SVMXC__Child_Object_Criteria__c, s.SVMXC__Advance_Expression__c, s.SVMXC__Active__c, s.RecordTypeId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c = \''+DPCId+'\' and RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Priortization\'');
                if(PriortizationLst2.size() > 0)
                {
                    for(Integer i = 0; i <PriortizationLst2.size(); i++)
                    {
                        if(PriorityId.length() > 0)
                            PriorityId += ',';
                        PriorityId += '\'' + String.valueOf(PriortizationLst2[i].id)+ '\'';
                    }
                    for(Integer i = 0; i <PriortizationLst2.size(); i++)
                    {
                        PriortizationLst.add(PriortizationLst2[i].clone(false,true));
                    }
                    for(Integer i = 0; i <PriortizationLst.size(); i++)
                    {
                        PriortizationLst[i].SVMXC__Process__c = processobj.id;
                        //PriortizationLst[i].SVMXC__Name__c = PriortizationLst[i].SVMXC__Name__c+ ' ' + i + ' ' + system.now();
                    }
                }   
                
                upsert PriortizationLst;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(Integer i = 0;i<PriortizationLst2.size();i++)
                {
                    MapofPruleID.put(PriortizationLst2[i].id,PriortizationLst[i].id);
                }
                List<SVMXC__ServiceMax_Config_Data__c>  PriorityExpression2 = new List<SVMXC__ServiceMax_Config_Data__c>();
                if(PriorityId.length() > 0)
                {
                    PriorityExpression2 = Database.Query('Select s.SVMXC__User__c, s.SVMXC__Target_Field_Name__c, s.SVMXC__Stock_Status__c, s.SVMXC__Stock_History_Line_Lookup_Field__c, s.SVMXC__Stock_History_Header_Lookup_Field__c, s.SVMXC__Source_Field_Name__c, s.SVMXC__Setting_Unique_ID__c, s.SVMXC__Setting_ID__c, s.SVMXC__Setting_Configuration_Profile__c, s.SVMXC__SettingID__c, s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__RecordType_Name__c, s.SVMXC__Profile__c, s.SVMXC__Profile_Name__c, s.SVMXC__Operator__c, s.SVMXC__Operand__c, s.SVMXC__Object_Name__c, s.SVMXC__MapID__c, s.SVMXC__Lookup_Field_API_Name__c, s.SVMXC__Location_Type__c, s.SVMXC__Location_Field_Name__c, s.SVMXC__Location_Field_From__c, s.SVMXC__IsDefault__c, s.SVMXC__Inventory_Process__c, s.SVMXC__Internal_Value__c, s.SVMXC__Installation_Key__c, s.SVMXC__Field_Name__c, s.SVMXC__FKey_Name_Field__c, s.SVMXC__Expression_Type__c, s.SVMXC__Expression_Rule__c, s.SVMXC__Enter_Date__c, s.SVMXC__Display_Value__c, s.SVMXC__Display_Type__c, s.SVMXC__Display_Map_ID__c, s.SVMXC__Description__c, s.SVMXC__Configuration_Type__c, s.SVMXC__Config_Profile_Name__c, s.SVMXC__Active__c, s.SVMXC__Action__c, s.SVMXC__Access_Configuration_Profile__c, s.RecordTypeId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c in(' +PriorityId+ ') and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Priortization\'');
                }   
                if(PriorityExpression2.size() > 0)
                {
                    for(integer i = 0;i<PriorityExpression2.size(); i++)
                    {
                        PriorityExpression.add(PriorityExpression2[i].clone(false,true));
                    }
                    
                    for(integer i = 0; i<PriorityExpression.size(); i++)
                    {
                        for(String s : MapofPruleID.keyset())
                        {
                            if( s == PriorityExpression[i].SVMXC__Expression_Rule__c)
                                PriorityExpression[i].SVMXC__Expression_Rule__c = MapofPruleID.get(s);
                        }   
                    }
                }   
                upsert PriorityExpression;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }   
            PageReference newpage = new PageReference('/apex/WORD_SetupDispatchProcess');
            newpage.getparameters().put('dpeid',processobj.id);
            newpage.getparameters().put('sMode','clone');
            newpage.setRedirect(true);
            return newpage;
        }
        else
        {
            HdrMsg = true;
        }
        return null;
    }
    public pagereference SVMX_Edit()
    {
        if(ValidProcess() == true)
        {
            for(Integer i = 0; i<DispatchProcessLst.size(); i++)
            {
                if(DispatchProcessLst[i].SVMXC__Select__c == true)
                {
                    DPEId = DispatchProcessLst[i].id;
                    DPEDispatchMethod = DispatchProcessLst[i].SVMXC__Dispatch_Method__c;
                }
            }
            // if(DPEId != null && DPEId !='')
            if(DPEId != null && DPEId != '' && !'Real Time Optimization'.equals(DPEDispatchMethod))
            {
                list<SVMXC__SVMX_Jobs__c> lstSvmxJobs = [Select Id, SVMXC__Start_Time__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :DPEID and (SVMXC__OptiMax_Message__c = 'In Progress' OR SVMXC__OptiMax_Message__c = 'Initiated')];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSvmxJobs != null && lstSvmxJobs.size() > 0)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.WORD014_TAG039));
                    return null;
                }
            }
            
            PageReference editPage = new PageReference('/apex/WORD_SetupDispatchProcess');
            editPage.getparameters().put('dpeid',DPEId);
            editPage.setRedirect(true);
            return editPage;
        }
        else
        {
            HdrMsg = true;
        }
        for(Integer i = 0; i<DispatchProcessLst.size(); i++)
        {
            if(DispatchProcessLst[i].SVMXC__Select__c == true)
            {
                DispatchProcessLst[i].SVMXC__Select__c = false;
            }
        }
        return null;
    }
    List<SVMXC__ServiceMax_Processes__c> DelARule = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Processes__c> DelTerritoryRule = new List<SVMXC__ServiceMax_Processes__c>(); 
    List<SVMXC__ServiceMax_Processes__c> DelPritoryRule = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Processes__c> DelAllRules = new List<SVMXC__ServiceMax_Processes__c>();
    List<SVMXC__ServiceMax_Config_Data__c> DelARuleExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> DelPritoryExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> DelAllRuleExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    public pagereference SVMX_Delete()
    {
        DelAllRules.clear();
        DelAllRuleExp.clear();
        DelARuleId ='';
        DelPRuleId = '';
        DelARule.clear();
        DelARuleExp.clear();
        DelTerritoryRule.clear();
        DelPritoryRule.clear();
        DelPritoryExp.clear();
        DelDispatchProcess.clear();
        ExceptionProcess.clear();
        DelConfingData.clear();
        ltpScheduleConfigData.clear();
        List <SVMXC__SVMX_Jobs__c> DelSvmxJob = new List<SVMXC__SVMX_Jobs__c>();
        List<Integer> SelectedLines = new List<Integer>();
        WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_Delete() start');
        for(Integer i=0;i<DispatchProcessLst.size();i++)
        {
            if(DispatchProcessLst[i].SVMXC__Select__c == true)
            {
                DelDispatchProcess.add(DispatchProcessLst[i]);
                SelectedLines.add(i);
                if(DispatchProcessID.length() > 0)
                    DispatchProcessID += ',';
                DispatchProcessID  += '\'' + String.valueOf(DispatchProcessLst[i].id)+ '\'';
                DispatchProcessLst[i].SVMXC__Select__c = false;
            }   
       }
       if(SelectedLines.size() == 0)
       {
            ValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG014()));
            return null;
       }
       ExceptionProcess = Database.query('Select s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId = \'' + DispatchRTypeId + '\'and SVMXC__Final_Exception_Process__c  in (' + DispatchProcessID + ')');
       if(ExceptionProcess.size() > 0)
       {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG016()));
            return null;
       }
       else
       {
            // Validate job is running and delete eco job
            List <SVMXC__SVMX_Jobs__c> jobList = Database.Query('Select id,SVMXC__OptiMax_Message__c,SVMXC__Type__c From SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c in (' + DispatchProcessID + ')' );
            if(jobList.size() > 0){
            
                for(integer i = 0; i < jobList.size(); i++)
                {
                        if(jobList[i].SVMXC__OptiMax_Message__c == 'RUNNING' || jobList[i].SVMXC__OptiMax_Message__c == 'In Progress'){
                            HdrMsg = true;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG049()));
                            return null;
                        }
                        DelSvmxJob.add(jobList[i]);
                }
            }
            
            //get the expression for the dispatch process and delete it leter
            DelConfingData = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c in (' + DispatchProcessID + ') and RecordTypeId = \''+ExpressionRTypeId+'\'and (SVMXC__Expression_Type__c =\'DISP_Process_Entry\' OR SVMXC__Expression_Type__c =\'DISP_Schedule_Exp\' OR SVMXC__Expression_Type__c =\'DISP_Schedule\')');
            
            //get the LTP scheduling table data
            ltpScheduleConfigData = Database.Query('select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId = \'' + Schedule_Rtype_Id + '\' and SVMXC__Dispatch_Process__c in (' + DispatchProcessID + ')');
            
            //get the Assignment rule and delete it.
            DelARule = Database.Query('Select s.Id From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c in('+DispatchProcessID+') and RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Simple Assignment\'order by SVMXC__Sequence__c');
            DelAllRules.addall(DelARule);
            if(DelARule.size() > 0)
            {
                for(integer i = 0; i < DelARule.size(); i++)
                {
                    if(DelARuleId.length() > 0)
                        DelARuleId += ',';
                    DelARuleId += '\'' + String.valueOf(DelARule[i].id)+ '\'';
                }
            }
            //get the expression for the Assignment rule and delete it leter
            if(DelARuleId.length() > 0)
            {
                DelARuleExp = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c in( '+DelARuleId+ ') and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Simple_Assignment\'');
            }
            DelAllRuleExp.addall(DelARuleExp);
            DelTerritoryRule = Database.Query('Select s.Id,SVMXC__Process__c,SVMXC__Territory__c From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c in(' +DispatchProcessID+ ') and RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Territory Access\'');
            DelAllRules.addall(DelTerritoryRule);
            DelPritoryRule = Database.Query('Select s.Id From SVMXC__ServiceMax_Processes__c s where SVMXC__Process__c in(' +DispatchProcessID+ ') and RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Priortization\'');
            DelAllRules.addall(DelPritoryRule);
            if(DelPritoryRule.size() > 0)
            {
                for(integer i = 0; i < DelPritoryRule.size(); i++)
                {
                    if(DelPRuleId.length() > 0)
                        DelPRuleId += ',';
                    DelPRuleId += '\'' + String.valueOf(DelPritoryRule[i].id)+ '\'';
                }
            }
            if(DelPRuleId.length() > 0)
            {
                DelPritoryExp = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c in(' +DelPRuleId+ ') and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Priortization\'');
            }
            DelAllRuleExp.addall(DelPritoryExp);
        }
       if(ExceptionProcess.size() == 0)
       {
             //add api call for delete schedule
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_Delete() deleteScheduleJob callout');
            String orgGuid = Userinfo.getOrganizationId().substring(0,15);
            for(integer i = 0; i < DelTerritoryRule.size(); i++){
                 WSCH_Provider_ECO_Stubs.DeleteScheduleRequest_WP deleteScheduleRequest = new WSCH_Provider_ECO_Stubs.DeleteScheduleRequest_WP();
                 deleteScheduleRequest.dispatchProcessGuid = DelTerritoryRule[i].SVMXC__Process__c;
                 deleteScheduleRequest.territoryGuid = DelTerritoryRule[i].SVMXC__Territory__c;
                 deleteScheduleRequest.orgGuid = orgGuid; 
                 String requestJson=JSON.serialize(deleteScheduleRequest); 
                 String calloutEndpoint = WSCH_Provider_ECO_Callout_Helper.OPTIMAXSERVICE_ENDPOINT_URL + WSCH_Provider_ECO_Callout_Helper.DELETE_SCHEDULEJOB_PATH;
                 WSCH_Provider_ECO_Stubs.Response_WP response =  WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,calloutEndpoint);
            }
           
            if(DelDispatchProcess.size() > 0)
                delete DelDispatchProcess;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(DelConfingData.size() > 0)   
                delete DelConfingData;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(DelAllRules.size() > 0)
                delete DelAllRules;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(DelAllRuleExp.size() > 0)
                delete DelAllRuleExp;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(ltpScheduleConfigData.size() > 0)
                delete ltpScheduleConfigData;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(DelSvmxJob.size() > 0)
                delete DelSvmxJob;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG018()));
            for(Integer i=selectedLines.size()-1;i>=0;i--)
            {
                DispatchProcessLst.remove(selectedLines.get(i));
            }
       }
       WSCH_AuditLogger.finish();
       return null;
    }
    
    public pagereference SVMX_BackToSetupHome()
    {
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            PageReference HomePage = new PageReference('/lightning/n/SVMXC__ServiceMax_Setup');
            HomePage.setRedirect(true);
            return HomePage;
        }else{
            return page.SVMXC__CONF_SetupHome;
        }
        
    }
    /******************************************* DispatchProcessSequence ********************************************************/
    public List<SVMXC__ServiceMax_Processes__c> TempDPLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    public Map<string,Integer> MyMap = new Map<string,Integer>();
    public string[] items = new String[]{};
    public boolean displaySeqPopup = false;
    public integer selIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    public boolean getdisplaySeqPopup(){return displaySeqPopup;}
    public void SVMX_DPSequence()
    {
        TempDPLst.clear();
        TempDPLst = Database.Query('Select s.SVMXC__Dispatch_Process_Status__c, s.SVMXC__Dispatch_Method__c, s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Name__c, s.LastModifiedDate, s.LastModifiedById, s.Id From SVMXC__ServiceMax_Processes__c s where  RecordTypeId = \''+DispatchRTypeId+'\'order by SVMXC__Sequence__c');
        displaySeqPopup = true;
    }
    public List<SelectOption> getSeqoptions()
    { 
        Seqoptions = new List<SelectOption>();   
        if (TempDPLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempDPLst)
            {                
                if (s.SVMXC__Name__c != null)
                    Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }  
        return Seqoptions; 
    }
    public string[] getitems(){return items;}
    public void setitems(string[] o){this.items=o;}
    public void shuffle(integer selIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
            temp = TempDPLst[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                TempDPLst[j] = TempDPLst[j-1];
            }
            TempDPLst[0] = temp;
        }
        else 
        {
            temp = TempDPLst[selIndex];
            for(integer j=selIndex;j<TempDPLst.size()-1;j++)
            {
                TempDPLst[j] = TempDPLst[j+1];
            }
            TempDPLst[TempDPLst.size()-1] = temp;
        }
    }  
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempDPLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempDPLst[0].Id)
                {
                    TempDPLst[j] = TempDPLst[j];
                    break;
                }
                else if(items[i]==TempDPLst[j].Id)
                {
                    temp = TempDPLst[j]; 
                    TempDPLst[j] = TempDPLst[j-1];
                    TempDPLst[j-1]=temp;     
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempDPLst[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempDPLst[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
    }
    public void Down()
    {  
        SVMXC__ServiceMax_Processes__c temp;
        for(integer i=0;i<items.size();i++)
        {
            MyMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<TempDPLst.size()-1;k++)
            {
                if(items[i]==TempDPLst[k].Id)
                {
                    temp = TempDPLst[k];
                    TempDPLst[k] = TempDPLst[k+1];
                    TempDPLst[k+1]=temp;
                    selIndex = k;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempDPLst[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempDPLst[selIndex].SVMXC__Sequence__c = selIndex;
                    break;       
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempDPLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == TempDPLst[j].Id)
                {
                    selIndex = j;
                    isUpAction = false;
                    isDownAction=false;
                    isTopAction=true;
                    isBottomAction=false;
                    shuffle(selIndex, true);     
                }
            }
        }  
    }
    public void Bottom()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempDPLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == TempDPLst[j].Id)
                {
                    selIndex = j;
                    isUpAction = false;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=true;     
                    shuffle(selIndex, false); 
                }
            }
        }  
    }
    public pagereference SVMX_SaveSequence()
    {
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if(isUpAction)
        {
            for(integer i=0;i<TempDPLst.size();i++)
            {
                TempDPLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempDPLst;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(isDownAction)
        {
            for(integer i=0;i<TempDPLst.size();i++)
            {
                TempDPLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempDPLst;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(isTopAction)
        {
            for(integer i=0;i<TempDPLst.size();i++)
            {
                TempDPLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempDPLst;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(isBottomAction)
        {
            for(integer i=0;i<TempDPLst.size();i++)
            {
                TempDPLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempDPLst;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        DispatchProcessLst.clear();
        DispatchProcessLst.addAll(TempDPLst);
        displaySeqPopup = false;
        return null;    
    }
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup = false;
        return null;
    }
    public void SVMXC_ShowJob()
    {
        JobRecLst.clear();
        if(ValidProcess() == true)
        {
            for(Integer i = 0; i<DispatchProcessLst.size(); i++)
            {
                if(DispatchProcessLst[i].SVMXC__Select__c == true)
                {
                    DPEId = DispatchProcessLst[i].id;
                }
            }
            DetailId = '';
            Lablename = getTAG027();
            showPannel=true;
            TabName='one';
            jobsList=[Select s.SVMXC__Territory__c, s.SVMXC__Start_Time__c, s.SVMXC__OptiMax_Message__c, s.SVMXC__End_Time__c, s.SVMXC__Type__c, s.Name, s.Id From SVMXC__SVMX_Jobs__c s where s.SVMXC__SVMX_Process__c=:DPEId Order by Name DESC];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            /*Code for Radio Button Implementation*/
            for(SVMXC__SVMX_Jobs__c currRec : jobsList)
            {
                JobRecLst.add(new JobRecWrapper(false,currRec));
            }
            
            SVMXC__ServiceMax_Processes__c dispatchProcess = [SELECT Id, SVMXC__Dispatch_Method__c,SVMXC__Territory__c FROM SVMXC__ServiceMax_Processes__c   where  SVMXC__Record_Type_Name__c='Dispatch Process' and id=: DPEId];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(null != dispatchProcess && dispatchProcess.SVMXC__Dispatch_Method__c == 'Real Time Optimization'){
                 isRealTimeOptProcess = true;
            }else{
                 isRealTimeOptProcess = false;
            }
          
            
            /*End for the Radio Button Implementation*/
        }
        else
        {
            HdrMsg = true;
            showPannel=false;
        }
        /*
        for(Integer i = 0; i<DispatchProcessLst.size(); i++)
        {
            if(DispatchProcessLst[i].SVMXC__Select__c == true)
            {
                DispatchProcessLst[i].SVMXC__Select__c = false;
            }
        }
        */
    }
    public Boolean showPannel{get;set;}
    public String hiddenValue{get;set;}
    public String TabName{get;set;}
    public String DetailId='';
    public String Lablename{get;set;}
    public List<SVMXC__SVMX_Jobs__c> getJobObjects()
    {
        return jobsList;
    }
    /*Naveen : Implemented for the revised approch for the initiate the job now*/
    public void SVMX_RunJob()
    {
        WSCH_AuditLogger.debug('Begin SVMX_RunJob');
        try{
            SVMXC__SVMX_Jobs__c selectedJob;
            List<SVMXC__SVMX_Jobs__c> lstSVMXJobs = [select id,SVMXC__SVMX_Process__c,SVMXC__Territory__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where Id =: selectedId];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstSVMXJobs != null && lstSVMXJobs.size() > 0)
            {
                selectedJob = lstSVMXJobs[0];
                WSCH_AuditLogger.debug('selectedJob.SVMXC__Type__c :- '+selectedJob.SVMXC__Type__c);
                if(selectedJob.SVMXC__Type__c == 'ECO'){
                    SVMX_ResumeECOJob(selectedJob);
                }else if(selectedJob.SVMXC__Type__c == 'LTP'){
                    SVMX_RunBatchJob(selectedJob);
                } else {
                    SVMX_RunBatchJob(selectedJob);
                }
            }
        }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
    }
    
    //Run a batch job
    public void SVMX_RunBatchJob(SVMXC__SVMX_Jobs__c batchJob)
    {
      try{
        WSCH_AuditLogger.debug('It is a Batch Job ; Calling SVMX_RunBatchJob');
         //Check if the type is incremetal or full;
        String strDPTerId='';
        String strTerrID = batchJob.SVMXC__Territory__c;
        strTerrID = strTerrID.substring(0,15);
        if(batchJob.SVMXC__Type__c != null && batchJob.SVMXC__Type__c == 'Incremental')
        {
            strDPTerId = batchJob.SVMXC__SVMX_Process__c + '~' + strTerrID + '_INCR'; 
        }else if(batchJob.SVMXC__Type__c != null && batchJob.SVMXC__Type__c == 'LTP')
        {
            strDPTerId = batchJob.SVMXC__SVMX_Process__c + '~' + strTerrID + '_LTP';         
        } else if(batchJob.SVMXC__Type__c != null && batchJob.SVMXC__Type__c == 'Full')
        {
            strDPTerId = batchJob.SVMXC__SVMX_Process__c + '~' + strTerrID + '_FULL';
        }
        
        List<SVMXC__ServiceMax_Processes__c> procCredLst = new List<SVMXC__ServiceMax_Processes__c>();
        String strOrgId = Userinfo.getOrganizationId().substring(0,15);
        procCredLst = [select id,SVMXC__Default_Value__c,SVMXC__SettingID__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03')];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        map<String,String> credentialMap = new map<String,String>();
        if(procCredLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : procCredLst)
            {
                if(pro.SVMXC__SettingID__c != null && pro.SVMXC__Default_Value__c != null)
                    credentialMap.put(pro.SVMXC__SettingID__c,pro.SVMXC__Default_Value__c);
            }
        }
        
        //get the Cardential first....
        OMAX_ServicemaxCom.credential objOMAXCred = new OMAX_ServicemaxCom.credential();
        COMM_SVMXC_Utils4 objUtil = new COMM_SVMXC_Utils4();
        if(procCredLst.size() >= 3)
        {
            if(credentialMap.containskey('PS01'))
                objOMAXCred.loginName = objUtil.Base64Decryption(credentialMap.get('PS01'));
            if(credentialMap.containskey('PS02'))
                objOMAXCred.password = objUtil.Base64Decryption(credentialMap.get('PS02'));
            if(credentialMap.containskey('PS03'))
                objOMAXCred.securityToken = objUtil.Base64Decryption(credentialMap.get('PS03'));
        }
        objOMAXCred.orgGUID = strOrgId;
        objOMAXCred.userGUID = Userinfo.getUserId();
        OMAX_ServicemaxCom.status WSDLStatus = new  OMAX_ServicemaxCom.status();
        OMAX_ServicemaxCom.OptimaxServicePort WSDLCall = new OMAX_ServicemaxCom.OptimaxServicePort();
        if(svmxSettingList.containsKey('GBL010') == true && svmxSettingList.get('GBL010') != null)
        {
            String EndpointURL_x = svmxSettingList.get('GBL010');
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(EndpointURL_x);
            req.setTimeout(60000);//Added by amar on 30th Aug 2010
            HttpResponse res = new Http().send(req);
            string loc = res.getHeader('Location');
            if((loc != NULL)&&(loc != '')) 
            { 
                EndpointURL_x = loc; 
            }
            WSDLCall.endpoint_x = EndpointURL_x;
        }
        system.debug('WORD_ManageDispatchProcess DispatchProcess Id: ' + strDPTerId);   
        system.debug('WORD_ManageDispatchProcess svmxSettingList.get(GBL007): ' + svmxSettingList.get('GBL007') + ' , svmxSettingList.containsKey(GBL007) : '+svmxSettingList.containsKey('GBL007'));  
        if((svmxSettingList.get('GBL007') != null && svmxSettingList.get('GBL007').equals('False'))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG050())); 
        }else{
            WSDLStatus = WSDLCall.OMAX_Execute_Job_WS(objOMAXCred,strDPTerId);
            if(WSDLStatus.status == 'SUCCESS'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, getTAG037()));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG038() + WSDLStatus.message));
            }
        }
        system.debug(WSDLStatus.message); //Check if the type is incremetal or full;
       }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
    }
    
    //Resume a Job 
    public void SVMX_ResumeECOJob(SVMXC__SVMX_Jobs__c ecoJob){
        try{
            //Make a rest call to the rest webservice 
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_ResumeECOJob() Teritory'+ecoJob.SVMXC__Territory__c);
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_ResumeECOJob() Process'+ecoJob.SVMXC__SVMX_Process__c);
            
            WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP resumeRequest = new WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP();
            resumeRequest.dispatchProcessGuid = ecoJob.SVMXC__SVMX_Process__c;
            resumeRequest.territoryGuid = ecoJob.SVMXC__Territory__c;
            resumeRequest.orgGuid =  Userinfo.getOrganizationId().substring(0,15);
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_ResumeECOJob() Request'+resumeRequest);
            
             String requestJson=JSON.serialize(resumeRequest); 
             WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_ResumeECOJob() Request string'+requestJson);
             
             
             if(svmxSettingList.get('GBL007') != null && svmxSettingList.get('GBL007').equals('False')){
                 ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG050()));
             }else{
                 WSCH_Provider_ECO_Stubs.Response_WP response =  WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,WSCH_Provider_ECO_Callout_Helper.ECO_JOB_SERVICE_PATH,WSCH_Provider_ECO_Callout_Helper.ECO_RESUME_JOB_METHOD);
                 system.debug('WORD_ManageDIspatchProcess getSVMXJobResults() svmxSettingList.get(GBL007): '+svmxSettingList.get('GBL007') + ' , response.status: '+response.status);
                 if(response.status == '202'){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO, getTAG037()));
                 }else{
                   ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG038()));
                 }
             }
             WSCH_AuditLogger.finish();  
         }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
    }
    
    
    /*End of implementation*/
    public void switchtab()
    {
       Lablename=ApexPages.currentPage().getParameters().get('tabname');
       DetailId=ApexPages.currentPage().getParameters().get('jid');
       TabName='two';
    }
    public String getDetailPageId()
    {
        return DetailId;
    }
    public String getPageNameToRedirect()
    {
       return  '/apex/SVMXC__COMM_Detail?pid=';
    }
    
      //Enable / Disable Abort Job Functionality
    public void SVMX_Enable_Abort(){
        isActiveJob =  enableAbort();
    }
    
    //On click on Job Radio Button
    public Boolean enableAbort(){
         SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
         objSVMXJob = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c, Id,SVMXC__Type__c From SVMXC__SVMX_Jobs__c  where Id =: selectedId];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         String jobInstanceStatus = objSVMXJob.SVMXC__OptiMax_Message__c;
         return returnAbortJobFlag(jobInstanceStatus);
    }
    
    public Boolean returnAbortJobFlag(String jobInstanceStatus){
       system.debug('WORD_ManageDispatchProcess returnAbortJobFlag jobInstanceStatus '+jobInstanceStatus);
        
       if(jobInstanceStatus != 'In Progress' && jobInstanceStatus !='RUNNING'){
                isActiveJob =  false;
                enableAbortJobButton = false;
            }else{
                isActiveJob =  true;     
                enableAbortJobButton = true;       
            }
        system.debug('WORD_ManageDispatchProcess returnAbortJobFlag enableAbortJobButton '+enableAbortJobButton);
        return isActiveJob;
    }
    
    
   //Method to Abort a Job on Click of the button
       //Method to Abort a Job on Click of the button
    public void SVMX_AbortJob(){ 
        
         String strOrgId = Userinfo.getOrganizationId().substring(0,15);
         proCredList = [select id,SVMXC__Default_Value__c,SVMXC__SettingID__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03')];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         
         system.debug('DispatchProcessLst:- '+DispatchProcessLst);
         
         map<String,String> credentialMap = new map<String,String>();
         if(proCredList.size() > 0)
          {
            for(SVMXC__ServiceMax_Processes__c pro : proCredList)
            {
                if(pro.SVMXC__SettingID__c != null && pro.SVMXC__Default_Value__c != null)
                   credentialMap.put(pro.SVMXC__SettingID__c,pro.SVMXC__Default_Value__c);
             }
          }
            
                      
         //Get the Credential
        OMAX_ServicemaxCom.credential objOMAXCred = new OMAX_ServicemaxCom.credential();
        COMM_SVMXC_Utils4 objUtil = new COMM_SVMXC_Utils4();
        if(DispatchProcessLst.size() >= 3)
        {
            if(credentialMap.containskey('PS01'))
                objOMAXCred.loginName = objUtil.Base64Decryption(credentialMap.get('PS01'));
            if(credentialMap.containskey('PS02'))
                objOMAXCred.password = objUtil.Base64Decryption(credentialMap.get('PS02'));
            if(credentialMap.containskey('PS03'))
                objOMAXCred.securityToken = objUtil.Base64Decryption(credentialMap.get('PS03'));
        }
        objOMAXCred.orgGUID = strOrgId;
        objOMAXCred.userGUID = Userinfo.getUserId();
        
        
        if(svmxSettingList.containsKey('GBL010') == true && svmxSettingList.get('GBL010') != null)
        {
            String EndpointURL_x = svmxSettingList.get('GBL010');
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(EndpointURL_x);
            req.setTimeout(60000);
            HttpResponse res = new Http().send(req);
            string loc = res.getHeader('Location');
            if((loc != NULL)&&(loc != '')) 
            { 
                EndpointURL_x = loc; 
            }
            WSDLCall.endpoint_x = EndpointURL_x;
        }
        
       SVMXC__SVMX_Jobs__c objSVMXJob = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c,SVMXC__End_Time__c,SVMXC__Type__c,SVMXC__Territory__c,SVMXC__SVMX_Process__c,Id From SVMXC__SVMX_Jobs__c  where Id =: selectedId];      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
       
        if(objSVMXJob != null){
             if(null != objSVMXJob.SVMXC__End_Time__c){
                 ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG043()));
             }
             else{
                  if(objSVMXJob.SVMXC__Type__c == 'ECO'){
                    /*String ecoSuspendJobId = objSVMXJob.SVMXC__SVMX_Process__c +'_'+objSVMXJob.SVMXC__Territory__c+'_'+strOrgId;
                    WSDLStatus = WSDLCall.OMAX_Suspend_Job_WS(objOMAXCred,ecoSuspendJobId);
                    if(WSDLStatus.status == 'SUSPENDED'){
                      ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO, getTAG048()));
                    }else{
                     ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG042()));
                    }*/
                    //rest call
                    SVMX_SuspendECOJob(objSVMXJob);
                 }else{
                     WSDLStatus = WSDLCall.OMAX_Suspend_Job_WS(objOMAXCred,selectedId);
                     if(WSDLStatus.status == 'ABORTED')
                     {
                        //Update the status of the job as suspended
                        system.debug('objSVMXJob :-' +objSVMXJob);
                        if(objSVMXJob != null)
                        {
                            objSVMXJob.SVMXC__Status__c = '000';
                            objSVMXJob.SVMXC__OptiMax_Message__c = 'Aborted';
                            objSVMXJob.SVMXC__End_Time__c = system.now();
                            update objSVMXJob;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }   
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO, getTAG041()));
                    }else if(WSDLStatus.status == 'SUCCESS'){
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG043()));
                    }else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG042()));
                    }
                 }
                 system.debug(WSDLStatus.message);
            }
        }
        
    }
    
    //Suspend ECO Job 
    public void SVMX_SuspendECOJob(SVMXC__SVMX_Jobs__c ecoJob){
        try{
            //Make a rest call to the rest webservice 
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_SuspendECOJob() Teritory'+ecoJob.SVMXC__Territory__c);
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_SuspendECOJob() Process'+ecoJob.SVMXC__SVMX_Process__c);
            
            WSCH_Provider_ECO_Stubs.SuspendJobRequest_WP suspendRequest = new WSCH_Provider_ECO_Stubs.SuspendJobRequest_WP();
            suspendRequest.dispatchProcessGuid = ecoJob.SVMXC__SVMX_Process__c;
            suspendRequest.territoryGuid = ecoJob.SVMXC__Territory__c;
            suspendRequest.orgGuid =  Userinfo.getOrganizationId().substring(0,15);
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_SuspendECOJob() Request'+suspendRequest);
            
            String requestJson=JSON.serialize(suspendRequest); 
            WSCH_AuditLogger.debug('WORD_ManageDispatchProcess::SVMX_SuspendECOJob() Request string'+requestJson);
             
            WSCH_Provider_ECO_Stubs.Response_WP response =  WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,WSCH_Provider_ECO_Callout_Helper.ECO_JOB_SERVICE_PATH,WSCH_Provider_ECO_Callout_Helper.ECO_SUSPEND_JOB_METHOD);
        
            if(response.status == '202'){
              ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO, getTAG048()));
            }else{
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG042()));
            }        
             WSCH_AuditLogger.finish();  
         }catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
    }
        
    
  public void getSVMXJobResults() {
        try {
            Boolean isCallSuccess = false;
            String strDPIdTerrIdOrgId;
            String strOrgId = Userinfo.getOrganizationId().substring(0,15);
            List<SVMXC__SVMX_Jobs__c> lstSVMXJobs = null;
            lstSVMXJobs = [select id,SVMXC__SVMX_Process__c,SVMXC__Territory__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where Id =: selectedId];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WORD_ManageDIspatchProcess: getSVMXJobResults():lstSVMXJobs - '+ lstSVMXJobs);
            if(lstSVMXJobs != null && lstSVMXJobs.size() > 0)
            {
                //strTerrID = strTerrID.substring(0,15);
                String strTerrID = lstSVMXJobs[0].SVMXC__Territory__c;
                String strDPId = lstSVMXJobs[0].SVMXC__SVMX_Process__c;
                strDPIdTerrIdOrgId = strDPId.trim() + '_' + strTerrID.trim() + '_' + strOrgId.trim();
                if(svmxSettingList.get('GBL007') != null && svmxSettingList.get('GBL007').equals('False')){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG050())); 
                }else{  
                    isCallSuccess = WSCH_OptimizedSchedulingService.manageSchedulingResults(strDPIdTerrIdOrgId);
                    system.debug('WORD_ManageDIspatchProcess getSVMXJobResults() svmxSettingList.get(GBL007): '+svmxSettingList.get('GBL007') + ' , isCallSuccess: '+isCallSuccess);
                    if(isCallSuccess){
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG045()));
                    }else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG046()));
                    }
                }
            }
        } catch(Exception ex) {
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
    }
    
    
    //Tags
    public string getHLPURL(){ return System.Label.WORD014_HLPURL;}
    public String getTAG001(){ return System.Label.WORD014_TAG001;} // New Process
    public String getTAG002(){ return System.Label.WORD014_TAG002;} // Clone
    public String getTAG003(){ return System.Label.WORD014_TAG003;} // Edit
    public String getTAG004(){ return System.Label.WORD014_TAG004;} // Delete
    public String getTAG005(){ return System.Label.WORD014_TAG005;} // Back To Setup Home
    public String getTAG006(){ return System.Label.WORD014_TAG006;} // Processing...
    public String getTAG007(){ return System.Label.WORD014_TAG007;} // Help
    public String getTAG008(){ return System.Label.WORD014_TAG008;} // Select
    public String getTAG009(){ return System.Label.WORD014_TAG009;} // Dispatch Process Name
    public String getTAG010(){ return System.Label.WORD014_TAG010;} // Dispatch Method
    public String getTAG011(){ return System.Label.WORD014_TAG011;} // Last Modified By
    public String getTAG012(){ return System.Label.WORD014_TAG012;} // Last Modified Date
    public String getTAG013(){ return System.Label.WORD014_TAG013;} // No Records To Display
    public String getTAG014(){ return System.Label.WORD014_TAG014;} // Please select atleast one record to perform action
    public String getTAG015(){ return System.Label.WORD014_TAG015;} // you can not perform this action on multiple records,please select only one record.
    public String getTAG016(){ return System.Label.WORD014_TAG016;} // cannot delete processes referenced in other dispatch processes.
    public String getTAG017(){ return System.Label.WORD014_TAG017;} // Are you sure to delete the selected dispatch processes?
    public String getTAG018(){ return System.Label.WORD014_TAG018;} // Record(s) Deleted
    public String getTAG019(){ return System.Label.WORD014_TAG019;} // Status
    public String getTAG020(){ return System.Label.WORD014_TAG020;} // Sequence
    public String getTAG021(){ return System.Label.WORD014_TAG021;} // Job Number
    public String getTAG022(){ return System.Label.WORD014_TAG022;} // Territory
    public String getTAG023(){ return System.Label.WORD014_TAG023;} // Type
    public String getTAG024(){ return System.Label.WORD014_TAG024;} // Start Time
    public String getTAG025(){ return System.Label.WORD014_TAG025;} // End Time
    public String getTAG026(){ return System.Label.WORD014_TAG026;} // ServiceMax Jobs
    public String getTAG027(){ return System.Label.WORD014_TAG027;} // Job Details 
    public String getTAG028(){ return System.Label.WORD014_TAG028;} // Dispatch Process
    public String getTAG029(){ return System.Label.WORD014_TAG029;} // Save
    public String getTAG030(){ return System.Label.WORD014_TAG030;} //
    public String getTAG031(){ return System.Label.WORD014_TAG031;} // Show Jobs
    public String getTAG032(){ return System.Label.WORD014_TAG032;} //
    public String getTAG033(){ return System.Label.WORD014_TAG033;} // RunJob Now
    public String getTAG034(){ return System.Label.WORD014_TAG034;} // Job Status
    public String getTAG035(){ return System.Label.WORD014_TAG035;} // Full
    public String getTAG036(){ return System.Label.WORD014_TAG036;} // Incremental
    public String getTAG037(){ return System.Label.WORD014_TAG037;} // Started the job successfully.
    public String getTAG038(){ return System.Label.WORD014_TAG038;} // Failed to run the job.
    public String getTAG040(){ return System.Label.WORD014_TAG040;} // Abort a Job
    public String getTAG041(){ return System.Label.WORD014_TAG041;} // Job Abort Succesfully
    public String getTAG042(){ return System.Label.WORD014_TAG042;} // Job Abort Succesfully
    public String getTAG043(){ return System.Label.WORD014_TAG043;} // Job Already Executed
    public String getTAG044(){ return System.Label.WORD014_TAG044;} // Get Results
    public String getTAG045(){ return System.Label.WORD014_TAG045;} // Results retrieval was successful
    public String getTAG046(){ return System.Label.WORD014_TAG046;} // Results retrieval was Not successful
    public String getTAG047(){ return System.Label.WORD014_TAG047;} // Suspend a Job
    public String getTAG048(){ return System.Label.WORD014_TAG048;} // Suspend a ECO Job   
    public String getTAG049(){ return 'Optimization job is currently running.';}
    public String getTAG050(){ return System.Label.WORD014_TAG050;} // Please enable Optimax (GBL007)  
}