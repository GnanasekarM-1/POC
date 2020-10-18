public with Sharing class WORD_SetupDispatchProcess
{
    /*Naveen 09/12/2010: Wrapper to maintain the Type of optimax run for the periodic intervals*/ 
    public class RunInformation
    {
        public Boolean IsSelected;
        private String RunType;
        private String RunAt;
        private Boolean IsActive;
        
        public RunInformation(){}
        public RunInformation(Boolean isSelected,String runType,String runAt,Boolean isActive)
        {
            this.IsSelected = isSelected;
            this.RunType = runType;
            this.RunAt = runAt;
            this.IsActive = isActive;
        }
        public Boolean getIsSelected()
        {
            return this.IsSelected;
        }        
        public String getRunType()
        {           
            return runType;
        }
        public String getRunAt()
        {
            return runAt;
        }
        public void setIsSelected(Boolean isSelected)
        {
            this.IsSelected = isSelected;            
        }
        public void setRunType(String runType)
        {           
            this.RunType = runType;
        }
        public void setRunAt(String runAt)
        {
            this.RunAt = runAt;
        }
        public void setIsActive(Boolean isActive) {
            this.IsActive = IsActive;
        }
        public Boolean getIsActive() {
            return IsActive;
        }
    }
    /*End of the Wrapper class*/
    //Global Variables..
    public Boolean CallFromFinalSave = false;
    public String selectedTab;
    public Boolean HdrMsg = false; 
    public Boolean Tab2Msg=false;
    public Boolean Tab4Msg=false;
    public Boolean DontProcess=true; 
    public string delIndex;
    public String DelRuleId='';
    public String Status='';
    public string RuleRecordTypeId;
    public string ExpHdr_Rtype_Id;
    public string DispatchProRecordTypeId;
    public String ExpressionRTypeId;
    public Boolean ARuleEdit=false;
    public Boolean AssignmentRulesTab=true;
    public Boolean TerritoriesTab=true;
    public Boolean PrioritizationTab=true;
    public Boolean CapacityLimitationsTab=false;
    public Boolean PreferencesTab=true;
    public Boolean CostParametersTab=true;
    public Boolean SchedulingTab=true;
    public Boolean ECOSchedulingTab=true;
    public Boolean ZoneTab=true;
    public Boolean longTermPlannerTab = true;
    public boolean disableValue=false;
    public Boolean DisbaleChkBox=false;
    public Boolean DisbleNewBttn=false; 
    public Boolean DisbleEditBttn=false; 
    public Boolean DisbleSaveBttn=true;
    public Boolean DisbleDelBttn=false; 
    public Boolean DisbleRSeqBttn=false; 
    public Boolean DisbleCancleBttn=true;
    public Boolean RuleBlockSection=false;
    public Boolean DisableTabs=false;
    public Boolean disableCapacityTab = false;
    public List<String> capLimErrorMssg = new List<String>();
    //jyothsna
    public map<String,SObjectType> workorderfieldMap = new map<String,SObjectType>(); 
    
    public List<SelectOption> WOQueue=new List<SelectOption>();
    public SVMXC__ServiceMax_Processes__c processobj=new SVMXC__ServiceMax_Processes__c();//SVMXC__Start_Date__c=system.now().dateGMT()
    public List<SVMXC__ServiceMax_Processes__c> TerritoryRecLst=new List<SVMXC__ServiceMax_Processes__c>();
    public SVMXC__ServiceMax_Processes__c ruleobj=new SVMXC__ServiceMax_Processes__c();
    public List<SVMXC__ServiceMax_Processes__c> SaveTerritoryLst=new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> RuleLst=new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempRuleLst=new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> Priortization=new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> CapacityLimitations = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> DPExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> RuleExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> PriorityExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> CapacityLimitaionsExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> DelRunInformation=new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String,String> MapofPickListDefValue=new Map<String,String>();
    public Integer AvailCount;
    public String DPEID='';
    public String sMode='';
    public SVMXC.COMM_Utils Utils=new SVMXC.COMM_Utils();
    public WORD_SetupDispatch_Methods DispMethods=new WORD_SetupDispatch_Methods(); 
    public COMM_SVMXC_Search_Expressions DPCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
    public COMM_SVMXC_Search_Expressions RuleCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
    public COMM_SVMXC_Search_Expressions PriorityCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
    public COMM_SVMXC_Search_Expressions CapacityLimitationsCriExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
    public Integer WeightTimeWindow=1; 
    public Integer WeightTotalDistance=1; 
    public Integer WeightRouteDistance=1;
    public Integer WeightRouteTime=1;
    public Integer WeightNodeType=1; 
    public Integer MaxSequence=0;
    public Integer RuleMaxSeq=0;
    public Integer WeightEligibility; 
    public Integer WeightExpertise; 
    public Integer WeightProductSpecilaization;
    public Integer WeightPreferredTech;
    public transient List<AggregateResult> Aggresult=new List<AggregateResult>(); 
    public transient List<AggregateResult> RuleAggresult=new List<AggregateResult>(); 
    
    /*Naveen:10/12/2010 : Variables for the scheduling tab*/
    public List<SelectOption>  DefaultRunTypes{get;set;}
    public List<SelectOption>  businessHourWindow{get;set;}
    public String StartAfter{get;set;}
    public Integer Frequency ;
    public String SelectedRunType{get;set;}
    public String SelectedStartTime{get;set;}
    public String SelectedEndTime{get;set;}
    public String SelectedFrequency{get;set;}   
    public String strStartAftrFul{get;set;}
    public String strScheduleDays{get;set;}
    public String strStartAftrInc{get;set;}
    public List<RunInformation> Disp_Schedule{get;set;}
    public List<SelectOption> DefaultStartTime{get;set;}
    public Boolean DisplayQuickAddSchedulePopup{get;set;}
    public List<SVMXC__ServiceMax_Config_Data__c> IncrementRunExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
    public COMM_SVMXC_Search_Expressions IncrementRunExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
    
    /** Start: Long Term Planning variables  **/
    public List<SVMXC__ServiceMax_Config_Data__c> lstLongTermPlanningConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstLongTermPlanningConfigData() { return this.lstLongTermPlanningConfigData;}
    public void setlstLongTermPlanningConfigData(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstLongTermPlanningConfigData = lst;}
    
    public COMM_SVMXC_Search_Expressions longTermPlanningRunExpressions = new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();

    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules() { return this.lstSchedules;}
    public void setlstSchedules(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSchedules = lst;}
    
    public integer intSeqVal;
    public integer getintSeqVal(){return this.intSeqVal;}
    public void setintSeqVal(integer index){this.intSeqVal = index;}
    public string strSelectedTimeZone{get;set;}
    public String strLTPStartAftrFull{get;set;}
    public String strLTPScheduleDays{get;set;}
    
    public boolean enableLTPCheckbox = false;
    public boolean getenableLTPCheckbox() { return enableLTPCheckbox; }
    public void setenableLTPCheckbox(boolean enableLTPCheckbox) { this.enableLTPCheckbox = enableLTPCheckbox; }
    
    public boolean isRenderToolBar1{get; set;}
    public boolean isRenderToolBar2{get; set;}
    public boolean isRenderToolBar3{get; set;}
    public boolean isRenderLTPExpressionSec{get; set;}
    public boolean isRenderLTPScheduleTableSec{get; set;}
    public boolean isRenderLTPHorizonSec{get; set;}
    public boolean isRenderLTPMailSec{get; set;}
    public boolean isRenderLTPCheckBox{get; set;}
    public boolean isDispatchMethodLTP = false;
    
    /** End: Long Term Planning variables  **/
    
    //public RunInformation Schedule{get;set;}
    public List<SelectOption> DefaultTimeZones{get;set;}  
    public Boolean msgFreqGr1 = false;
    public Boolean getmsgFreqGr1(){return msgFreqGr1;}
    public boolean isMCTMenabled{get;set;}
    public String ltpRunAt {get; set;}
    public String ltpStartAfter {get; set;}
    public string Schedule_Rtype_Id;
    /*end of varibles for scheduling tab*/
    
    public List<SelectOption> lstSOAssignWOTo = new List<SelectOption>();
    public List<SelectOption> lstDispatchMethod = new List<SelectOption>();
    public List<SelectOption> getlstSOAssignWOTo(){return this.lstSOAssignWOTo;}
    public List<SelectOption> getlstDispatchMethod(){return this.lstDispatchMethod;}

    //Static Map to hold OptimaxCall messages - Anush Spr 17 security issue
    public static String messagesString;
    public class ErrorMessage{
        public String messageType;
        public String message;
    }
    public static List<ErrorMessage> messagesList = new List<ErrorMessage>();
    public List<String> apexMessagesList = new List<String>(); //Anush Spr 17 security issue
    public boolean makeOptimaxCall = false; //Anush Spr 17 security issue
    public boolean disableAddTerrBtn{get;set;}
       
    public WORD_SetupDispatchProcess()
    {
        disp_Schedule = new List<RunInformation>();
        buildPicklist();
        try
        {
            //jyothsna
            workorderfieldMap.put('SVMXC__Service_Order__c',DispMethods.allObjs.get('SVMXC__Service_Order__c'));
            DispMethods.allObjs.clear();
            DispMethods.allObjs.put('SVMXC__Service_Order__c',workorderfieldMap.get('SVMXC__Service_Order__c'));
            workorderfieldMap.clear();
            
            isMCTMenabled = false;
            system.debug('constructor called');
            /**Naveen 13/12/2010: Scheduling Tab**/
            DefaultStartTime = new List<SelectOption>();
            DefaultTimeZones = new List<SelectOption>();
            DefaultRunTypes = new List<SelectOption>();
            businessHourWindow = new List<SelectOption>();
            DefaultRunTypes.add(new SelectOption(DispMethods.getTAG169(),DispMethods.getTAG169()));
            //DefaultRunTypes.add(new SelectOption(DispMethods.getTAG170(),DispMethods.getTAG170()));
            businessHourWindow.add(new SelectOption(DispMethods.getTAG207(),DispMethods.getTAG207()));
            businessHourWindow.add(new SelectOption(DispMethods.getTAG206(),DispMethods.getTAG206()));
            IncrementRunExpressions.DefaultField=DispMethods.getTAG033();
            IncrementRunExpressions.DefaultOperator=DispMethods.getTAG033();
            IncrementRunExpressions.DefaultListValue=DispMethods.getTAG033();
            IncrementRunExpressions.ExpressionType='CRITERIA';
            IncrementRunExpressions.FieldsList=Hdrfldlist;
            CreateDefaultTimeZones();
            GetDefaultStartTimes();              
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('OMAX003');
            Map<String, String> mapMCTMSetng = commSettings.SVMX_getSettingList('OMAX001');            
            User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];
            processobj.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
            if(svmxSettingList.containsKey('SET019') && svmxSettingList.get('SET019') != null)
                strStartAftrInc = String.ValueOf(Integer.valueOf(svmxSettingList.get('SET019')));
            
            else                
                strStartAftrInc = String.ValueOf(1);  
            processobj.SVMXC__Full_Run_Unit__c = 'Days';     
            /**End for scheduling tab**/
            
            if(mapMCTMSetng.containsKey('SET014') && mapMCTMSetng.get('SET014') != null)
            {
                if(mapMCTMSetng.get('SET014') == 'true')
                    isMCTMenabled = true ;  
                
            }
            //selectedTab=DispMethods.getTAG008();//commented to deal with defect
            selectedTab=DispMethods.getTAG003();
            strStartAftrFul = String.valueof(0);
            strScheduleDays = String.valueof(3);
            if(svmxSettingList.containsKey('SET016') && svmxSettingList.get('SET016') != null)
                strStartAftrFul =  String.valueof(Integer.valueOf(svmxSettingList.get('SET016')));
            if(svmxSettingList.containsKey('SET017') && svmxSettingList.get('SET017') != null)
                strScheduleDays = String.valueof(Integer.valueOf(svmxSettingList.get('SET017')));
            if(System.currentPageReference().getParameters().containsKey('dpeid'))
            {
                DPEID=System.currentPageReference().getParameters().get('dpeid');
            }
            if(System.currentPageReference().getParameters().containsKey('sMode'))
            {
                sMode=System.currentPageReference().getParameters().get('sMode');
            }
            
            if(isMCTMenabled)
            {
                if(svmxSettingList.containsKey('SET042') && svmxSettingList.get('SET042') != null)      
                    WeightEligibility = Integer.valueOf(svmxSettingList.get('SET042'));
                else 
                    WeightEligibility = 10;
                if(svmxSettingList.containsKey('SET043') && svmxSettingList.get('SET043') != null)
                    WeightProductSpecilaization = Integer.valueOf(svmxSettingList.get('SET043'));  
                else
                    WeightProductSpecilaization = 10;
                if(svmxSettingList.containsKey('SET044') && svmxSettingList.get('SET044') != null)
                    WeightPreferredTech = Integer.valueOf(svmxSettingList.get('SET044'));     
                else
                    WeightPreferredTech = 10;
                if(svmxSettingList.containsKey('SET047') && svmxSettingList.get('SET047') != null)
                    WeightExpertise = Integer.valueOf(svmxSettingList.get('SET047'));
                else
                    WeightExpertise = 10;
            }
            else
            {
                WeightEligibility = 0;
                WeightProductSpecilaization = 0;
                WeightPreferredTech = 0;
                WeightExpertise = 0;
            }
            
            List<string> Fieldname = new List<string>();
            Fieldname.add('SVMXC__Start_Time__c');
            MapofPickListDefValue=utils.SVMX_getDefaultPicklistValue('SVMXC__ServiceMax_Processes__c',FieldName);
            processobj.SVMXC__Start_Time__c=MapofPickListDefValue.get('SVMXC__Start_Time__c');
            DPCriExpressions.DefaultField=DispMethods.getTAG033();
            DPCriExpressions.DefaultOperator=DispMethods.getTAG033();
            DPCriExpressions.DefaultListValue=DispMethods.getTAG033();
            DPCriExpressions.ExpressionType='CRITERIA';
            RuleCriExpressions.DefaultField=DispMethods.getTAG033();
            RuleCriExpressions.DefaultOperator=DispMethods.getTAG033();
            RuleCriExpressions.DefaultListValue=DispMethods.getTAG033();
            RuleCriExpressions.ExpressionType='CRITERIA';
            PriorityCriExpressions.DefaultField=DispMethods.getTAG033();
            PriorityCriExpressions.DefaultOperator=DispMethods.getTAG033();
            PriorityCriExpressions.DefaultListValue=DispMethods.getTAG033();
            PriorityCriExpressions.ExpressionType='CRITERIA';
            
            //Start Capacity Limitations
            CapacityLimitationsCriExpressions.DefaultField=DispMethods.getTAG033();
            CapacityLimitationsCriExpressions.DefaultOperator=DispMethods.getTAG033();
            CapacityLimitationsCriExpressions.DefaultListValue=DispMethods.getTAG033();
            CapacityLimitationsCriExpressions.ExpressionType='CRITERIA';
            //End Capacity Limitations 
            
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, DPCriExpressions.mapFieldDispType, DPCriExpressions.FieldApiLable);
            DPCriExpressions.FieldsList=Hdrfldlist;
            DPCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, RuleCriExpressions.mapFieldDispType, RuleCriExpressions.FieldApiLable);
            RuleCriExpressions.FieldsList=Hdrfldlist;
            RuleCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, PriorityCriExpressions.mapFieldDispType, PriorityCriExpressions.FieldApiLable);
            PriorityCriExpressions.FieldsList=Hdrfldlist;
            PriorityCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            
            // Start Capacity Limitaions
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CapacityLimitationsCriExpressions.mapFieldDispType, CapacityLimitationsCriExpressions.FieldApiLable);
            CapacityLimitationsCriExpressions.FieldsList=Hdrfldlist;
            CapacityLimitationsCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            // End Capacity Limitations
            
            //LTP Expressions
            longTermPlanningRunExpressions.DefaultField=DispMethods.getTAG033();
            longTermPlanningRunExpressions.DefaultOperator=DispMethods.getTAG033();
            longTermPlanningRunExpressions.DefaultListValue=DispMethods.getTAG033();
            longTermPlanningRunExpressions.ExpressionType='CRITERIA';
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, longTermPlanningRunExpressions.mapFieldDispType, longTermPlanningRunExpressions.FieldApiLable);
            longTermPlanningRunExpressions.FieldsList=Hdrfldlist;
            longTermPlanningRunExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            
            List<QueueSobject> WOQue = Database.query('Select QueueId, Queue.Name From QueueSobject where SobjectType=\'SVMXC__Service_Order__C\'');
            WOQueue.clear();
            WOQueue.add(new selectOption('', DispMethods.getTAG033()));
            for(Integer i=0; i<WOQue.size(); i++)
                WOQueue.add(new selectOption(WOQue[i].QueueId,WOQue[i].Queue.Name));
            
            /** added the field in where clause Name = 'Schedule' **/
            List<RecordType> RecordTypes = Database.query('Select Id, Name, SobjectType From RecordType where (SobjectType=\'SVMXC__ServiceMax_Processes__c\' OR SobjectType=\'SVMXC__ServiceMax_Config_Data__c\') AND ( Name = \'SVMX Rule\' OR Name = \'Dispatch Process\' OR Name = \'Expressions\' OR Name = \'Schedule\')');
            for(RecordType r : RecordTypes)
            {
                if(r.Name == 'SVMX Rule')
                    RuleRecordTypeId = r.id;
                else if(r.Name == 'Dispatch Process')
                    DispatchProRecordTypeId = r.id;
                else if(r.Name == 'Expressions')
                    ExpressionRTypeId = r.id;
                    
                if(r.Name == 'SVMX Rule' && r.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                    ExpHdr_Rtype_Id = r.id;
                    
                /** added for LTP **/
                if(r.Name == 'Schedule' && r.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                    Schedule_Rtype_Id = r.Id;
            }
            
            Aggresult=[select MAX(SVMXC__Sequence__c) FROM SVMXC__ServiceMax_Processes__c  where recordtypeid =: DispatchProRecordTypeId];      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(Aggresult.size() > 0)
            {
                for(AggregateResult ar : Aggresult) 
                {
                    String s;
                    object Obj = ar.get('expr0');
                    if(Obj != null)
                        s = string.valueOf(Obj);
                    if(s != null && s.length() > 0)
                    {
                        s = s.replace('.','_');
                        List<String> s1 = new List<String>(); 
                        s1  = s.split('_',2);
                        s = s1[0];
                        MaxSequence = integer.valueOf(s);
                    }   
                }
                if(processobj.id == null && MaxSequence != null)
                {
                    processobj.SVMXC__Sequence__c=MaxSequence + 1;
                }
            }
            if(SVMX_IsValidID(DPEID))
            {
                /** Added the following fields for LTP - SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Default_On__c, SVMXC__Confirmation_Message__c **/
                system.debug('valid DP');
                processobj=Database.Query('Select SVMXC__Settings_Name__c,SVMXC__Dispatch_Method__c, SVMXC__Product_Match_Enabled__c, SVMXC__Expertise_Match_Enabled__c, SVMXC__Default_Value__c, SVMXC__Advance_Expression__c,SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c, SVMXC__Weight_Route_Time__c, SVMXC__Weight_Node_Type__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Assign_To_Queue__c, SVMXC__Name__c, RecordTypeId, SVMXC__Dispatch_Process_Status__c, SVMXC__Runs_Every_Monday__c, SVMXC__Runs_Every_Tuesday__c, SVMXC__Runs_Every_Wednesday__c, SVMXC__Runs_Every_Thursday__c, SVMXC__Runs_Every_Friday__c, SVMXC__Runs_Every_Saturday__c, SVMXC__Runs_Every_Sunday__c, SVMXC__Start_Time__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Calendar_Start_Days__c, SVMXC__Full_Run_Unit__c, SVMXC__Frequency__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, SVMXC__Child_Object_Criteria__c, SVMXC__Optimization_Goal__c, SVMXC__Description__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Route_Type__c, SVMXC__Tolerance__c, SVMXC__Retain_Appointment__c, SVMXC__Retain_Assignment__c, SVMXC__Dispatch_Timezone__c, SVMXC__Calendar_End_Days__c, SVMXC__Sequence__c, id, SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c, SVMXC__Target_URL__c,SVMXC__Dispatch_Threshold__c, SVMXC__Optimizer_Sync_Interval__c, SVMXC__SM_Drive_Before_Shift_Start__c, SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Default_On__c, SVMXC__Confirmation_Message__c  from SVMXC__ServiceMax_Processes__c where id =:DPEID and RecordTypeId =:DispatchProRecordTypeId');
                //New Goal Changes
                if(processobj.SVMXC__Optimization_Goal__c != null && processobj.SVMXC__Optimization_Goal__c.equals('Maximize Response Time')){
                    processobj.SVMXC__Optimization_Goal__c ='Maximize SLA Compliance';
                } else if(processobj.SVMXC__Optimization_Goal__c != null && processobj.SVMXC__Optimization_Goal__c.equals('Right Person to Right Job')){
                    processobj.SVMXC__Optimization_Goal__c ='Custom';
                } else if(processobj.SVMXC__Optimization_Goal__c != null && processobj.SVMXC__Optimization_Goal__c.equals('Minimize Overall Cost')){
                    processobj.SVMXC__Optimization_Goal__c ='Maximize Resource Utilization';
                }
                
                system.debug('DPEID: '+DPEID);
                system.debug('DispatchProRecordTypeId: '+DispatchProRecordTypeId);
                system.debug('processobj.SVMXC__Optimization_Goal__c: '+processobj.SVMXC__Optimization_Goal__c);
                if(processobj.SVMXC__Dispatch_Method__c == 'Immediate')
                {
                    AssignmentRulesTab=true; 
                    TerritoriesTab=false;
                    PrioritizationTab=false;
                    //CapacityLimitationsTab=false;
                    PreferencesTab=false;
                    CostParametersTab=false;
                    SchedulingTab=false;
                    ECOSchedulingTab=false;
                    longTermPlannerTab = false;
                    ZoneTab=false;
                }
                if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch')
                {
                    AssignmentRulesTab=false; 
                    TerritoriesTab=true;
                    PrioritizationTab=true;
                    CapacityLimitationsTab=true;
                    PreferencesTab=true;
                    CostParametersTab=true;
                    SchedulingTab=true;
                    ECOSchedulingTab=false;
                    longTermPlannerTab = true;
                    ZoneTab=true;
                }
                if(processobj.SVMXC__Dispatch_Method__c == 'Linx for ServicePower')
                {
                    AssignmentRulesTab=false; 
                    TerritoriesTab=false;
                    PrioritizationTab=false;
                    //CapacityLimitationsTab=false;
                    PreferencesTab=false;
                    CostParametersTab=false;
                    SchedulingTab=false;
                    ECOSchedulingTab=false;
                    longTermPlannerTab = false;
                    ZoneTab=false;
                    SaveCloseDPBtn=false;
                    NextDPBtn=true;
                }   
                // ECO changes
                if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() )
                {
                    AssignmentRulesTab=false; 
                    TerritoriesTab=true;
                    PrioritizationTab=true;
                    CapacityLimitationsTab=true;
                    PreferencesTab=true;
                    CostParametersTab=false;
                    SchedulingTab=false;
                    ECOSchedulingTab=true;
                    longTermPlannerTab = true;
                    ZoneTab=true;
                }
                
                if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getlongTermPlannerDP()) {
                    AssignmentRulesTab=false; 
                    TerritoriesTab=true;
                    PrioritizationTab=true;
                    CapacityLimitationsTab=true;
                    PreferencesTab=true;
                    CostParametersTab=true;
                    SchedulingTab=false;
                    ECOSchedulingTab=false;
                    longTermPlannerTab = true;
                    ZoneTab=true;
                    isDispatchMethodLTP = true;
                }              
                // ECO changes end             
                if(processobj.SVMXC__Product_Match_Enabled__c)
                {
                    ProductExpertise=DispMethods.getTAG043();
                }
                if(processobj.SVMXC__Expertise_Match_Enabled__c)
                {
                    ProductExpertise=DispMethods.getTAG048();  
                } 
                /**Naveen: Loading the incremental expression and the run information into the expression builder**/
                //commented the below code as incremental run is not in use
                //system.debug('came here');
                //IncrementRunExpressions = SVMX_setExpressionProperties('DISP_Schedule_Exp');
                //system.debug('IncrementRunExpressions'+IncrementRunExpressions);
                DelRunInformation = LoadConfigDataForRecordType('DISP_Schedule');  
                //if(processobj.SVMXC__Default_Value__c != null)
                //{   
                //    IncrementRunExpressions.AdvanceOption=processobj.SVMXC__Default_Value__c;
                //}*
                /*end of loading the incremetnal expression*/
                
                DPExpression=Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =:DPEID and RecordTypeId =:ExpressionRTypeId and SVMXC__Expression_Type__c =\'DISP_Process_Entry\'');
                
                if(DPExpression.size() == 0)
                {
                    DPCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
                    ClearSelOptList(Hdrfldlist);
                    DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, DPCriExpressions.mapFieldDispType, DPCriExpressions.FieldApiLable);
                    DPCriExpressions.FieldsList=Hdrfldlist;
                    DPCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
                }
                if(DPExpression != null && DPExpression.size() > 0)
                {
                    DPCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
                    ClearSelOptList(Hdrfldlist);
                    DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, DPCriExpressions.mapFieldDispType, DPCriExpressions.FieldApiLable);
                    DPCriExpressions.FieldsList=Hdrfldlist;
                    DPCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
                    DPCriExpressions.DefaultField=DispMethods.getTAG033();
                    DPCriExpressions.DefaultOperator=DispMethods.getTAG033();
                    DPCriExpressions.DefaultListValue=DispMethods.getTAG033();
                    DPCriExpressions.ExpressionType='CRITERIA';
                    for(SVMXC__ServiceMax_Config_Data__c exp : DPExpression)
                    {
                        DPCriExpressions.setExpressions(exp);
                    }
                }
                system.debug('DPCriExpressions'+DPCriExpressions);
                if(processobj.SVMXC__Advance_Expression__c != null)
                {
                    DPCriExpressions.AdvanceOption=processobj.SVMXC__Advance_Expression__c;
                }
                
                RuleLst=Database.Query('Select SVMXC__Select__c, SVMXC__Name__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Assign_To_Queue__c, SVMXC__Schedule_Event__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Description__c, SVMXC__Sequence__c, id From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: DPEID and RecordTypeId =: RuleRecordTypeId and SVMXC__Rule_Type__c =\'Simple Assignment\'order by SVMXC__Sequence__c');

                TerritoryRecLst=Database.Query('Select id, SVMXC__Select__c, SVMXC__Territory__c, SVMXC__Territory__r.Name, SVMXC__Process__c, RecordTypeId, SVMXC__Rule_Type__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:DPEID and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Territory Access\'');
                
                Priortization=Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:DPEID and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Priortization\'');
                
                CapacityLimitations = Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c, SVMXC__SM_Capacity_Threshold__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:DPEID and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Capacity Reservation\'');
                setDefaultValues();
                
                /**Start: Retrieving LTP information to populate LTP section  **/
                //Retrieve the expression section only for ECO DP and Batch DP
                //if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() || processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch') {
                    
                     lstLongTermPlanningConfigData = Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =:DPEID and RecordTypeId =:ExpressionRTypeId and SVMXC__Expression_Type__c =\'DISP_Schedule_Exp\'');
                
                    if(lstLongTermPlanningConfigData.size() == 0)
                    {
                        longTermPlanningRunExpressions = new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
                        ClearSelOptList(Hdrfldlist);
                        DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, longTermPlanningRunExpressions.mapFieldDispType, longTermPlanningRunExpressions.FieldApiLable);
                        longTermPlanningRunExpressions.FieldsList = Hdrfldlist;
                        longTermPlanningRunExpressions.objfieldMap = DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
                    }
                    if(lstLongTermPlanningConfigData != null && lstLongTermPlanningConfigData.size() > 0)
                    {
                        longTermPlanningRunExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
                        ClearSelOptList(Hdrfldlist);
                        DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, longTermPlanningRunExpressions.mapFieldDispType, longTermPlanningRunExpressions.FieldApiLable);
                        longTermPlanningRunExpressions.FieldsList=Hdrfldlist;
                        longTermPlanningRunExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
                        longTermPlanningRunExpressions.DefaultField=DispMethods.getTAG033();
                        longTermPlanningRunExpressions.DefaultOperator=DispMethods.getTAG033();
                        longTermPlanningRunExpressions.DefaultListValue=DispMethods.getTAG033();
                        longTermPlanningRunExpressions.ExpressionType='CRITERIA';
                        for(SVMXC__ServiceMax_Config_Data__c exp : lstLongTermPlanningConfigData)
                        {
                            longTermPlanningRunExpressions.setExpressions(exp);
                        }
                    }
                    system.debug('longTermPlanningRunExpressions - '+longTermPlanningRunExpressions);
                    if(processobj.SVMXC__Default_Value__c != null)
                    {
                        longTermPlanningRunExpressions.AdvanceOption = processobj.SVMXC__Default_Value__c;
                    }
                    
                    if(processobj.SVMXC__Default_On__c != null) {
                        enableLTPCheckbox = processobj.SVMXC__Default_On__c;
                    }
                //}
                
                if(processobj.SVMXC__Confirmation_Message__c != null) {
                    strSelectedTimeZone = processobj.SVMXC__Confirmation_Message__c;
                }
                
                //copying the horizonDays from ECO/Batch Schedule and storing as startDay in LTP
                /*if((processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() || 
                                    processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch') && strScheduleDays != null) {
                    strLTPStartAftrFull = strScheduleDays;  
                }*/
                
                if(processobj.SVMXC__Window_Height__c != null) {
                    system.debug('WORD_SetupDispatchProcess: processobj.SVMXC__Window_Height__c - ' + processobj.SVMXC__Window_Height__c);
                    strLTPStartAftrFull = String.valueOf(integer.valueOf(processobj.SVMXC__Window_Height__c));
                }
                
                if(processobj.SVMXC__Window_Width__c != null) {
                    system.debug('WORD_SetupDispatchProcess: processobj.SVMXC__Window_Width__c - ' + processobj.SVMXC__Window_Width__c);
                    strLTPScheduleDays = String.valueOf(integer.valueOf(processobj.SVMXC__Window_Width__c));
                }

                if(processobj.Calendar_Start_Days__c != null)
                    strStartAftrFul = String.valueOf(integer.valueOf(processobj.Calendar_Start_Days__c));
                if(processobj.Calendar_End_Days__c != null) 
                    strScheduleDays = String.valueOf(integer.valueOf(processobj.Calendar_End_Days__c));
                if(processobj.Frequency__c != null)     
                    strStartAftrInc = String.valueOf(integer.valueOf(processobj.Frequency__c));
                
                /** Initializing the schedule information table **/
                initializeLTPScheduleTable();
                
                /**  Initialize the LTP sections based on the Dispatch Method **/
                toEnableDisableLTPSections();
                
                /** This method enables or disables the LTP section based on the check box **/
                if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP()) {
                    enableLTPSectionOnCheckBox();
                }
                
                /**End: Retrieving LTP information to populate LTP section  **/
                
                if(processobj.SVMXC__Weight_Time_Window__c != null)
                {
                    WeightTimeWindow=processobj.SVMXC__Weight_Time_Window__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Total_Distance__c != null)
                {
                    WeightTotalDistance=processobj.SVMXC__Weight_Total_Distance__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Route_Distance__c != null)
                {
                    WeightRouteDistance=processobj.SVMXC__Weight_Route_Distance__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Route_Time__c != null)
                {
                    WeightRouteTime=processobj.SVMXC__Weight_Route_Time__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Node_Type__c != null)
                {
                    WeightNodeType=processobj.SVMXC__Weight_Node_Type__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Tech_Eligibility__c != null)
                {
                    WeightEligibility=processobj.SVMXC__Weight_Tech_Eligibility__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Skill_Match__c != null)
                {
                    WeightExpertise=processobj.SVMXC__Weight_Skill_Match__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Product_Specialization__c != null)
                {
                    WeightProductSpecilaization=processobj.SVMXC__Weight_Product_Specialization__c.intvalue();
                }
                if(processobj.SVMXC__Weight_Preferred_Technician__c != null)
                {
                    WeightPreferredTech=processobj.SVMXC__Weight_Preferred_Technician__c.intvalue();
                }

                //moved the below commented code to top as the default value of strScheduleDays was copied to strLTPStartAftrFull - OPT-3905
                /*if(processobj.Calendar_Start_Days__c != null)
                    strStartAftrFul = String.valueOf(integer.valueOf(processobj.Calendar_Start_Days__c));
                if(processobj.Calendar_End_Days__c != null) 
                    strScheduleDays = String.valueOf(integer.valueOf(processobj.Calendar_End_Days__c));
                if(processobj.Frequency__c != null)     
                    strStartAftrInc = String.valueOf(integer.valueOf(processobj.Frequency__c));*/
                
                /***Multiple Instance BEGIN***/
                //re-initialize the Picklist when the user is in Edit Mode.
                buildSPInstPicklist();
                if (processobj.Target_URL__c != null){
                    /*mapSpInstance = new Map<String, String>();
                    spInstName = '';
                    strDefaultConnection = '';
                    mapSpInstance = getSpInstanceMap();*/
                    for(String strConNum: mapSpInstance.keySet()){
                        if(mapSpInstance.get(strConNum).equalsIgnoreCase(processobj.Target_URL__c)){
                            processobj.Target_URL__c = mapSpInstance.get(strConNum);
                        }
                    }
                }else{
                    processobj.Target_URL__c = System.Label.DCON001_TAG280;
                }
                /***Multiple Instance END***/
            }  
        }
        catch (Exception ex) 
        {
            Tab4Msg=false;
            HdrMsg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        } 
    }
    Public Void buildPicklist()
    {
        lstSOAssignWOTo.add(new SelectOption('SVMX.None', DispMethods.getTAG033()));
        lstSOAssignWOTo.add(new SelectOption('Technician', DispMethods.getTAG030()));
        lstSOAssignWOTo.add(new SelectOption('Queue', DispMethods.getTAG032()));
        lstSOAssignWOTo.add(new SelectOption('Dispatcher', DispMethods.getTAG031()));
        
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Processes__c.SVMXC__Dispatch_Method__c.getDescribe();
        List<Schema.PicklistEntry> pick = F.getPicklistValues();
        lstDispatchMethod.add(new SelectOption('SVMX.None', DispMethods.getTAG033()));
        for(Schema.PicklistEntry pv : pick)
        {
            if( pv.getValue() == 'Immediate')
                lstDispatchMethod.add(new SelectOption(pv.getValue(),pv.getLabel()));
            else
            {
                SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
                list<string> lstSubModuleId = new list<string>();
                lstSubModuleId.add('GLOB001');
                map<string, Map<String, String>> mapOptimizationSetting = settings.SVMX_getSettingList(lstSubModuleId); 
                Set<String> providersSet = new Set<String>();
                if(mapOptimizationSetting != null && mapOptimizationSetting.size() >0 && mapOptimizationSetting.containskey('GLOB001') && mapOptimizationSetting.get('GLOB001').containskey('GBL022'))
                {
                    for(String StrProvider : mapOptimizationSetting.get('GLOB001').get('GBL022').split(','))
                        providersSet.add(StrProvider.touppercase());
                }
                if(mapOptimizationSetting.containsKey('GLOB001') && mapOptimizationSetting.get('GLOB001').containsKey('GBL007') && mapOptimizationSetting.get('GLOB001').get('GBL007') == 'True' && providersSet.contains('OPTIMAX') && (pv.getValue() == 'Optimized Batch' || pv.getValue() == DispMethods.getEcoDP() || pv.getValue() == DispMethods.getlongTermPlannerDP() ))
                    lstDispatchMethod.add(new SelectOption(pv.getValue(),pv.getLabel()));
                if(mapOptimizationSetting.containsKey('GLOB001') && mapOptimizationSetting.get('GLOB001').containsKey('GBL007') && mapOptimizationSetting.get('GLOB001').get('GBL007') == 'True' && (providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER')) && pv.getValue() == 'Linx for ServicePower')
                    lstDispatchMethod.add(new SelectOption(pv.getValue(),pv.getLabel()));               
            }   
        }
    }
    public Integer getWeightTimeWindow(){return WeightTimeWindow;} 
    public void setWeightTimeWindow(Integer s) {WeightTimeWindow=s;}
    public Integer getWeightTotalDistance() {return WeightTotalDistance;}
    public void setWeightTotalDistance(Integer s) {WeightTotalDistance=s;}
    public Integer getWeightRouteDistance(){return WeightRouteDistance;}
    public void setWeightRouteDistance(Integer s) {WeightRouteDistance=s;}
    public Integer getWeightRouteTime(){return WeightRouteTime;}
    public void setWeightRouteTime(Integer s){WeightRouteTime=s;}
    public Integer getWeightNodeType() {return WeightNodeType;}
    public void setWeightNodeType(Integer s) {WeightNodeType=s;}
    public Integer getWeightEligibility(){return WeightEligibility;} 
    public void setWeightEligibility(Integer s) {WeightEligibility=s;}    
    public Integer getWeightExpertise(){return WeightExpertise;} 
    public void setWeightExpertise(Integer s) {WeightExpertise=s;}
    public Integer getWeightProductSpecilaization(){return WeightProductSpecilaization;} 
    public void setWeightProductSpecilaization(Integer s) {WeightProductSpecilaization=s;}
    public Integer getWeightPreferredTech(){return WeightPreferredTech;} 
    public void setWeightPreferredTech(Integer s) {WeightPreferredTech=s;}  
    
    public Boolean IsNew=true;
    public Boolean getDisableTabs(){return DisableTabs;}
    public Boolean getdisableCapacityTab(){return disableCapacityTab;}
    
    public Boolean getIsNew()
    {
        if(DPEID != null && DPEID.length() > 0)
            IsNew=false;
        else
            IsNew=true;
        return IsNew;
    }
    public void setIsNew(Boolean b) {IsNew=b; }
    public Boolean getDontProcess(){return DontProcess;}
    public void setDontProcess(Boolean b) {DontProcess=b;}
    public PageReference ValidateDispatchMethod()
    {
        AssignmentRulesTab=false;
        TerritoriesTab=false;
        PrioritizationTab=false;
        CapacityLimitationsTab=false;
        PreferencesTab=false;
        CostParametersTab=false;
        SchedulingTab=false;
        ECOSchedulingTab=false;
        longTermPlannerTab = false;
        ZoneTab=false;
        return null;
    } 
    public boolean SVMX_IsValidID(String id)
    {
        if (id <> null && id <> '' && id.length() > 0)
            return true;
        else
            return false;
    }
    public Boolean getNewMode() 
    {
        Boolean NewMode=false;
        if(DPEID == '')
            NewMode=true;
        return NewMode;     
    }
    public Boolean getEditMode() 
    {  
        Boolean EditMode=false;
        if(DPEID != null && DPEID.length() > 0)
            EditMode=true;
        return EditMode;     
    }
    public Boolean getCloneMode() 
    {  
        Boolean CloneMode = false;
        if(sMode != null && sMode == 'clone')
            CloneMode = true;
        return CloneMode;     
    }
    public Boolean ValidDPAssignTo=true;
    public Boolean ValidDPAssignTo()
    {
        ValidDPAssignTo=true;
        if(processobj.SVMXC__Dispatch_Method__c == null || processobj.SVMXC__Dispatch_Method__c == 'SVMX.None')
        {
            ValidDPAssignTo=false;
            processobj.SVMXC__Dispatch_Method__c.addError(DispMethods.getTAG092());
        }
        if(processobj.SVMXC__Assign_Work_Order_To__c == null || processobj.SVMXC__Assign_Work_Order_To__c == 'SVMX.None')
        {
            ValidDPAssignTo=false;
            processobj.SVMXC__Assign_Work_Order_To__c.addError(DispMethods.getTAG099());
        }
        if(processobj.SVMXC__Assign_Work_Order_To__c == 'Technician' && processobj.SVMXC__Assign_To_Technician__c == null)
        {
            ValidDPAssignTo=false;
            processobj.SVMXC__Assign_To_Technician__c.AddError(DispMethods.getTAG100());
        }
        if(processobj.SVMXC__Assign_Work_Order_To__c == 'Dispatcher' && processobj.SVMXC__Assign_To_Dispatcher__c == null)
        {
            ValidDPAssignTo=false;
            processobj.SVMXC__Assign_To_Dispatcher__c.AddError(DispMethods.getTAG101());
        }
        if(processobj.SVMXC__Assign_Work_Order_To__c == 'Queue' && processobj.SVMXC__Assign_To_Queue__c == null )
        {
            ValidDPAssignTo=false;
            processobj.SVMXC__Assign_To_Queue__c.AddError(DispMethods.getTAG102());
        }
        return ValidDPAssignTo;
    }
    public Boolean SVMX_ValidDP=true;
    public Boolean SVMX_ValidDP()
    {
        SVMX_ValidDP=true;
        if(processobj.SVMXC__Name__c == null)
        {
            SVMX_ValidDP=false;
            processobj.SVMXC__Name__c.addError(DispMethods.getTAG095());
        }
        else if(processobj.SVMXC__Name__c.length()<8)
        {
            SVMX_ValidDP=false;
            //processobj.SVMXC__Name__c.addError(System.Label.CONF014_TAG011); // Dispatch process name should be at least 8 characters long.
            apexMessagesList.add(System.Label.CONF014_TAG011); // Dispatch process name should be at least 8 characters long.
        }
        if(SVMX_IsValidID(DPEID))
        {
            system.debug('is valid id');
            List<SVMXC__ServiceMax_Processes__c> DispatchProcesses=Database.query('Select id,SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId=\''+DispatchProRecordTypeId+'\'and id != \''+DPEID+'\'');
            if(processobj.SVMXC__Name__c != null)
            {
                for(SVMXC__ServiceMax_Processes__c DP : DispatchProcesses)
                {
                    String s=processobj.SVMXC__Name__c;
                    String s1=DP.SVMXC__Name__c;
                    if(s.trim() == s1.trim())
                    {    
                        SVMX_ValidDP=false;
                        processobj.SVMXC__Name__c.addError(DispMethods.getTAG096());
                    }
                }
            } 
        }
        if(!SVMX_IsValidID(DPEID))
        {
            system.debug('is not valid id');
            system.debug('DPEID'+DPEID);
            List<SVMXC__ServiceMax_Processes__c> DispatchProcesses=Database.query('Select id,SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where RecordTypeId=\''+DispatchProRecordTypeId+'\'');
            if(processobj.SVMXC__Name__c != null)
            {
                for(SVMXC__ServiceMax_Processes__c DP : DispatchProcesses)
                {
                    String s=processobj.SVMXC__Name__c;
                    String s1=DP.SVMXC__Name__c;
                    if(s.trim() == s1.trim())
                    {
                        SVMX_ValidDP=false;
                        processobj.SVMXC__Name__c.addError(DispMethods.getTAG096());
                    }
                }
            } 
        }
        return SVMX_ValidDP;
    } 
    public Boolean SVMX_ValidAR=true;
    public Boolean SVMX_ValidAR()
    {   
        SVMX_ValidAR=true;
        for(SVMXC__ServiceMax_Processes__c AR : RuleLst)
        {
            if(AR.SVMXC__Select__c == true)
            {
                if(AR.SVMXC__Name__c == '' || AR.SVMXC__Name__c == null)
                {
                    SVMX_ValidAR=false;
                    AR.SVMXC__Name__c.addError(DispMethods.getTAG097());
                }
            }
        }
        String s;
        String s1;
        for(Integer i=0; i < RuleLst.size(); i++)
        {
            if(RuleLst[i].SVMXC__Name__c != null && RuleLst[i].SVMXC__Select__c == true)
            {
                s=RuleLst[i].SVMXC__Name__c.trim();
            }
        } 
        for(Integer i=0; i < RuleLst.size(); i++) 
        {
            if(RuleLst[i].SVMXC__Select__c == false && RuleLst[i].SVMXC__Name__c != null)
            { 
                s1=RuleLst[i].SVMXC__Name__c.trim();
            }    
            if(s != null && s1 != null && s.toUpperCase() == s1.toUpperCase())
            {
                SVMX_ValidAR=false;
                RuleLst[i].SVMXC__Name__c.addError(DispMethods.getTAG098());
            }
        }
        for(Integer i=0; i < RuleLst.size(); i++) 
        {
            if(RuleLst[i].SVMXC__Select__c == true )
            {    
                if(ruleobj.SVMXC__Assign_Work_Order_To__c == null || ruleobj.SVMXC__Assign_Work_Order_To__c == 'SVMX.None')
                {
                    SVMX_ValidAR=false;
                    ruleobj.SVMXC__Assign_Work_Order_To__c.addError(DispMethods.getTAG103());
                }
                if(ruleobj.SVMXC__Assign_Work_Order_To__c == 'Technician' && ruleobj.SVMXC__Assign_To_Technician__c == null)
                {
                    SVMX_ValidAR=false;
                    ruleobj.SVMXC__Assign_To_Technician__c.AddError(DispMethods.getTAG100());
                }
                if(ruleobj.SVMXC__Assign_Work_Order_To__c == 'Dispatcher' && ruleobj.SVMXC__Assign_To_Dispatcher__c == null)
                {
                    SVMX_ValidAR=false;
                    ruleobj.SVMXC__Assign_To_Dispatcher__c.AddError(DispMethods.getTAG101());
                }
                if(ruleobj.SVMXC__Assign_Work_Order_To__c == 'Queue' && ruleobj.SVMXC__Assign_To_Queue__c == null )
                {
                    SVMX_ValidAR=false;
                    ruleobj.SVMXC__Assign_To_Queue__c.AddError(DispMethods.getTAG102());
                }
            }
        }  
        return SVMX_ValidAR;
    }
    public WORD_SetupDispatch_Methods getDispMethods() {return DispMethods;}
    public void setDispMethods(WORD_SetupDispatch_Methods s) {DispMethods=s;} 
    public string getselectedTab() {return selectedTab;}
    public void setselectedTab(string str) {str=selectedTab;}
    public string getdelIndex (){return this.delIndex;}
    public void setdelIndex (string str){this.delIndex=str;}
    public boolean getdisableValue(){return this.disableValue;}
    public Boolean getHdrMsg() {return HdrMsg;}
    public Boolean getAssignmentRulesTab(){return AssignmentRulesTab;}
    public Boolean getTerritoriesTab(){return TerritoriesTab;} 
    public Boolean getPrioritizationTab(){return PrioritizationTab;}
    public Boolean getCapacityLimitationsTab(){return CapacityLimitationsTab;}
    public Boolean getPreferencesTab() {return PreferencesTab;}
    public Boolean getCostParametersTab() {return CostParametersTab;}
    public Boolean getSchedulingTab() {return SchedulingTab;}
    public Boolean getECOSchedulingTab() {return ECOSchedulingTab;}
    public Boolean getlongTermPlannerTab() {return longTermPlannerTab;}
    public Boolean getisDispatchMethodLTP() {return isDispatchMethodLTP;}
    public Boolean getZoneTab() {return ZoneTab;}
    public void ClearSelOptMap ( map<string,SelectOption> m)
    {
        m.clear();
        m.put('', new SelectOption('',DispMethods.getTAG033()));
    }
    public List<selectoption> Hdrfldlist=new List<selectoption>(); //list of fields values
    public List<selectoption> getHdrFldlist() {return DispMethods.sortingSelectOption(Hdrfldlist, true);}
    public void ClearSelOptList(List<SelectOption> lst)
    {
        lst.clear();
    } 
    /*********************************************************Tab1's Methods**********************************************/
    public SVMXC__ServiceMax_Processes__c getprocessobj(){return processobj;}
    public void setprocessobj(SVMXC__ServiceMax_Processes__c sp){processobj=sp;}
    public COMM_SVMXC_Search_Expressions getDPCriExpressions() {return DPCriExpressions;}
    public void DPCriADDRow(){ DPCriExpressions.addCriteriaExpression(1);}
    public void DPCriDeleteRow()
    {
        if(delIndex.length() > 0)
            DPCriExpressions.removeCriteriaExpression(integer.valueOf(delIndex));
    }
    public pagereference SVMX_BackToDP()
    {
        if(sMode != null && sMode == 'clone')
        {
            List<SVMXC__ServiceMax_Processes__c> delPriortization=new List<SVMXC__ServiceMax_Processes__c>();
            List<SVMXC__ServiceMax_Config_Data__c> RuleExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> PriorityExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
            
            List<SVMXC__ServiceMax_Processes__c> delCapacityLimitation = new List<SVMXC__ServiceMax_Processes__c>();
            List<SVMXC__ServiceMax_Config_Data__c> capacityCriteriaExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            String RuleId='';
            String PriorityId='';
            String capacityId = '';
            if(processobj != null)
                delete processobj;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(DPExpression.size() > 0)
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){   //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete DPExpression;
                }else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
                if(RuleLst.size() > 0)
            {
                for(Integer i=0; i < RuleLst.size();i++)
                {
                    if(RuleId.length() > 0)
                        RuleId += ',';
                    RuleId += '\'' + String.valueOf(RuleLst[i].id)+ '\'';
                }
                if(RuleId.length() > 0)
                {
                    RuleExpression=Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in( '+RuleId+ ') and RecordTypeId=\''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Simple_Assignment\'');
                }  
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {  //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete RuleLst;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
            }
            if(RuleExpression.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete RuleExpression;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
            }  
            if(Priortization.size() > 0)
            {
                for(integer i=0; i <Priortization.size();i++)
                {
                    if(Priortization[i].id != null)
                    {
                        delPriortization.add(Priortization[i]);
                        if(PriorityId.length() > 0)
                            PriorityId += ',';
                        PriorityId += '\'' + String.valueOf(Priortization[i].id)+ '\'';
                    }
                }
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete delPriortization;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                if(PriorityId.length() > 0)
                {
                    PriorityExpression=Database.Query('Select id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in(' +PriorityId+ ') and RecordTypeId=\''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Priortization\'');
                }  
                if(PriorityExpression.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {    //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete PriorityExpression;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                }
            }
            
            if(CapacityLimitations.size() > 0)
            {
                for(integer i=0; i <CapacityLimitations.size();i++)
                {
                    if(CapacityLimitations[i].id != null)
                    {
                        delCapacityLimitation.add(CapacityLimitations[i]);
                        if(capacityId.length() > 0)
                            capacityId += ',';
                        capacityId += '\'' + String.valueOf(CapacityLimitations[i].id)+ '\'';
                    }
                }
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete delCapacityLimitation;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                if(capacityId.length() > 0)
                {
                    capacityCriteriaExpression = Database.Query('Select id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in(' +capacityId+ ') and RecordTypeId=\''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Capacity_Reservation\'');
                }  
                if(capacityCriteriaExpression.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {    //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete capacityCriteriaExpression;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                }
            }  
        }
        PageReference Page=new PageReference('/apex/WORD_ManageDispatchProcess');
        Page.setRedirect(true);
        return Page;
    }
    public pagereference SVMX_AssignmentRules()
    {
        System.debug(LoggingLevel.INFO, 'Dispatch method name : in 2nd tab ' + processobj.SVMXC__Dispatch_Method__c);
        if(processobj.SVMXC__Dispatch_Method__c == null || processobj.SVMXC__Dispatch_Method__c == 'SVMX.None')
        {
            HdrMsg = true;
            processobj.SVMXC__Dispatch_Method__c.addError(DispMethods.getTAG092());
        }
        if(processobj.SVMXC__Dispatch_Method__c == 'Immediate')
        {
            AssignmentRulesTab=true;
            TerritoriesTab=false;
            PrioritizationTab=false;
            //CapacityLimitationsTab=false;
            PreferencesTab=false;
            CostParametersTab=false;
            SchedulingTab=false;
            ECOSchedulingTab=false;
            longTermPlannerTab = false;
            ZoneTab=false;
            selectedTab=DispMethods.getTAG004();//commented to deal with defect number 1787
            //selectedTab='tab2';
        }
        if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch')
        {
            AssignmentRulesTab=false;
            TerritoriesTab=true;
            PrioritizationTab=true;
            CapacityLimitationsTab=true;
            PreferencesTab=true;
            CostParametersTab=true;
            SchedulingTab=true;
            ECOSchedulingTab=false;
            longTermPlannerTab = true;
            ZoneTab=true;
            selectedTab=DispMethods.getTAG005(); //commented to deal with defect number 1787
            disableCapacityTab = false;
            //selectedTab='tab3';
        }
        if(processobj.SVMXC__Dispatch_Method__c == 'Linx for ServicePower')
        {
            AssignmentRulesTab=false;
            TerritoriesTab=false;
            PrioritizationTab=false;
            //CapacityLimitationsTab=true;
            PreferencesTab=false;
            CostParametersTab=false;
            SchedulingTab=false;
            ECOSchedulingTab=false;
            longTermPlannerTab = false;
            ZoneTab=false;
            selectedTab=DispMethods.getTAG005(); //commented to deal with defect number 1787
            //selectedTab='tab3';
            SaveCloseDPBtn=false;
        }
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() )
        {
            AssignmentRulesTab=false;
            TerritoriesTab=true;
            PrioritizationTab=true;
            CapacityLimitationsTab=true;
            PreferencesTab=true;
            CostParametersTab=false;
            //SchedulingTab=true;
            SchedulingTab=false;
            longTermPlannerTab = true;
            ZoneTab=true;
            ECOSchedulingTab=true;
            selectedTab=DispMethods.getTAG005();
            disableCapacityTab = true;
        }
        
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getlongTermPlannerDP()) {
            AssignmentRulesTab=false; 
            TerritoriesTab=true;
            PrioritizationTab=true;
            CapacityLimitationsTab=true;
            PreferencesTab=true;
            CostParametersTab=true;
            SchedulingTab=false;
            ECOSchedulingTab=false;
            longTermPlannerTab = true;
            ZoneTab=true;
            selectedTab=DispMethods.getTAG005();
            disableCapacityTab = true;
            isDispatchMethodLTP = true;
        }
        
        /**  Initialize the LTP sections based on the Dispatch Method **/
        toEnableDisableLTPSections();
        
        /** Initializing the schedule information table **/
        initializeLTPScheduleTable();
        
        /** This method enables or disables the LTP section based on the check box **/
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP()) {
            enableLTPSectionOnCheckBox();
        }
        
        return null;
    }
    
    public pagereference getDispatchMethod(){
        system.debug('entered getDispatchMethod');
        if(processobj.SVMXC__Dispatch_Method__c == 'Linx for ServicePower'){
            SaveCloseDPBtn=false;
            NextDPBtn=true;
            /***Multiple Instance BEGIN***/
            //initialize the picklist when user is in NEW mode. 
            buildSPInstPicklist();
            /***Multiple Instance END***/
        }else{
            SaveCloseDPBtn=true;
            NextDPBtn=false;    
        }
        return null;
        
    }
    public Boolean SaveCloseRulesBtn=false;
    public Boolean getSaveCloseRulesBtn(){return SaveCloseRulesBtn;} 
    public Boolean SaveCloseDPBtn=true;
    public Boolean getSaveCloseDPBtn(){return SaveCloseDPBtn;} 
    public Boolean NextDPBtn=false;
    public Boolean getNextDPBtn(){return NextDPBtn;} 
    public List<SVMXC__ServiceMax_Processes__c> getRuleLst(){return RuleLst;}
    public void setRuleLst(List<SVMXC__ServiceMax_Processes__c> sp){RuleLst=sp;}
    public SVMXC__ServiceMax_Processes__c getruleobj(){return ruleobj;}
    public void setruleobj(SVMXC__ServiceMax_Processes__c sp){ruleobj=sp;}
    public COMM_SVMXC_Search_Expressions getRuleCriExpressions() {return RuleCriExpressions;}
    public void RuleCriADDRow(){ RuleCriExpressions.addCriteriaExpression(1);}
    public void RuleCriDeleteRow()
    {
        if(delIndex.length() > 0)
            RuleCriExpressions.removeCriteriaExpression(integer.valueOf(delIndex));
    }
    public Boolean getTab2Msg(){return Tab2Msg;}
    public List<SelectOption> getWOQueue()
    {
        return WOQueue;
    }
    public Boolean getDisbleNewBttn(){return DisbleNewBttn;} 
    public Boolean getDisbleEditBttn() 
    {  
        if(RuleLst.size() == 0)
        {
            DisbleEditBttn=true;
        }
        return DisbleEditBttn;
    }
    public Boolean getDisbleDelBttn()
    {
        if(RuleLst.size() == 0)
        {
            DisbleDelBttn=true;
        }
        return DisbleDelBttn;
    }
    public Boolean getDisbleRSeqBttn() 
    {
        if(RuleLst.size() <= 1)
        {
            DisbleRSeqBttn=true;
        }
        return DisbleRSeqBttn;
    }
    public Boolean getDisbleCancleBttn(){return DisbleCancleBttn;}
    public Boolean getDisbaleChkBox(){return DisbaleChkBox;}
    public Boolean getRuleBlockSection(){return RuleBlockSection;}
    public Boolean getDisbleSaveBttn(){return DisbleSaveBttn;}
    public pageReference SVMX_NewRule()
    {
        for(SVMXC__ServiceMax_Processes__c rule :RuleLst)
        {
            if(rule.SVMXC__Select__c == true)
                rule.SVMXC__Select__c=false;
        }
        SVMXC__ServiceMax_Processes__c newRule=new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c=true);
        RuleAggresult=Database.query('Select MAX(SVMXC__Sequence__c) From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:DPEID and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Simple Assignment\'');
        if(RuleAggresult.size() > 0)
        {
            for (AggregateResult ar : RuleAggresult) 
            {
                String s;
                object Obj = ar.get('expr0');
                if(Obj != null)
                    s = string.valueOf(Obj);
                if(s != null && s.length() > 0)
                {
                    s = s.replace('.','_');
                    List<String> s1 = new List<String>(); 
                    s1  = s.split('_',2);
                    s = s1[0];
                    RuleMaxSeq =  integer.valueof(s);
                }   
            }
            if(newRule.id == null && RuleMaxSeq != null)
            {
                newRule.SVMXC__Sequence__c=RuleMaxSeq + 1;
            }
        }    
        RuleLst.add(newRule);
        RuleCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
        ClearSelOptList(Hdrfldlist);
        DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, RuleCriExpressions.mapFieldDispType, RuleCriExpressions.FieldApiLable);
        RuleCriExpressions.FieldsList=Hdrfldlist;
        RuleCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
        ruleobj.SVMXC__Assign_Work_Order_To__c=null;
        ruleobj.SVMXC__Assign_To_Technician__c=null;
        ruleobj.SVMXC__Assign_To_Dispatcher__c=null;
        ruleobj.SVMXC__Assign_To_Queue__c=null;
        ruleobj.SVMXC__Schedule_Event__c=null;
        RuleBlockSection=true;
        DisbaleChkBox=true;
        DisbleCancleBttn=false;
        DisbleNewBttn=true;
        DisbleEditBttn=true;
        DisbleDelBttn=true;
        DisbleRSeqBttn=true;
        DisbleSaveBttn=false;
        SaveCloseRulesBtn=true;
        RuleMaxSeq=0;
        return null;
    } 
    public Boolean SVMX_ValidateARule=false;
    public Boolean SVMX_ValidateARule()
    {
        SVMX_ValidateARule=false;
        List<Integer> SelectedLines=new List<Integer>();
        for(integer i=0; i < RuleLst.size();i++)
        {
            if(RuleLst[i].SVMXC__Select__c == true)
            {
                SelectedLines.add(i);
            }
        }
        if(SelectedLines.size() == 0)
        {
            SVMX_ValidateARule=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG089()));
        }
        if(SelectedLines.size() > 1)
        {
            for(Integer j=0; j < RuleLst.size(); j++)
            {
                RuleLst[j].SVMXC__Select__c=False;
            }
            SVMX_ValidateARule=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG107()));
        }
        return SVMX_ValidateARule;
    }
    public pageReference SVMX_EditRule()
    {
        String AdvanceOption='';
        if(SVMX_ValidateARule() == true)
        {
            Tab2Msg=true;
            return null;
        }
        else
        {
            RuleExpression.clear();
            RuleCriExpressions.lstExpressions.clear();
            String RuleId;
            for(SVMXC__ServiceMax_Processes__c rule :RuleLst)
            {
                if(rule.SVMXC__Select__c == true)
                {
                    RuleId=rule.id;
                    if(rule.SVMXC__Assign_Work_Order_To__c == 'SVMX.None')
                        rule.SVMXC__Assign_Work_Order_To__c = null;
                    
                    if(rule.SVMXC__Assign_Work_Order_To__c != null)
                    {
                        ruleobj.SVMXC__Assign_Work_Order_To__c=rule.SVMXC__Assign_Work_Order_To__c;
                    }
                    if(rule.SVMXC__Assign_To_Technician__c != null)
                    {
                        ruleobj.SVMXC__Assign_To_Technician__c=rule.SVMXC__Assign_To_Technician__c;
                    }
                    if(rule.SVMXC__Assign_To_Dispatcher__c != null)
                    {
                        ruleobj.SVMXC__Assign_To_Dispatcher__c=rule.SVMXC__Assign_To_Dispatcher__c;
                    }
                    if(rule.SVMXC__Assign_To_Queue__c != null)
                    {
                        ruleobj.SVMXC__Assign_To_Queue__c=rule.SVMXC__Assign_To_Queue__c;
                    }
                    if(rule.SVMXC__Schedule_Event__c != null)
                    {
                        ruleobj.SVMXC__Schedule_Event__c=rule.SVMXC__Schedule_Event__c;
                    }
                    if(rule.SVMXC__Advance_Expression__c != null)
                    {
                        AdvanceOption=rule.SVMXC__Advance_Expression__c;
                    }
                }
            }
            if(RuleId != null && RuleId.length() > 0)
            {
                RuleExpression=Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c=\''+RuleId+'\' and RecordTypeId=\''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Simple_Assignment\'');
            }
            if(RuleExpression.size() == 0 )
            {
                RuleCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
                ClearSelOptList(Hdrfldlist);
                DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, RuleCriExpressions.mapFieldDispType, RuleCriExpressions.FieldApiLable);
                RuleCriExpressions.FieldsList=Hdrfldlist;
                RuleCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            }
            if(RuleExpression != null && RuleExpression.size() > 0)
            {
                RuleCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
                DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, RuleCriExpressions.mapFieldDispType, RuleCriExpressions.FieldApiLable);
                RuleCriExpressions.FieldsList=Hdrfldlist;
                RuleCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
                RuleCriExpressions.DefaultField=DispMethods.getTAG033();
                RuleCriExpressions.DefaultOperator=DispMethods.getTAG033();
                RuleCriExpressions.DefaultListValue=DispMethods.getTAG033();
                RuleCriExpressions.ExpressionType='CRITERIA';
                for(SVMXC__ServiceMax_Config_Data__c exp : RuleExpression)
                {
                    RuleCriExpressions.setExpressions(exp);
                }
            }
            RuleCriExpressions.AdvanceOption=AdvanceOption;
            RuleBlockSection=true;
            DisbaleChkBox=true;
            DisbleNewBttn=true;
            DisbleEditBttn=true;
            DisbleDelBttn=true;
            DisbleRSeqBttn=true;
            DisbleCancleBttn=false;
            DisbleSaveBttn=false;
            SaveCloseRulesBtn=true;
            return null;
        } 
    }
    public pageReference SVMX_DeleteRule()
    {
        try
        {
            List<SVMXC__ServiceMax_Processes__c> DelRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
            List<SVMXC__ServiceMax_Config_Data__c> DelRuleExpression=new List<SVMXC__ServiceMax_Config_Data__c>();
            List<integer> SelectedLines=new List<integer>();
            for(Integer i=0; i<RuleLst.size(); i++)
            {
                if(RuleLst[i].SVMXC__Select__c == true)
                {
                    SelectedLines.add(i);
                    DelRuleLst.add(RuleLst[i]);
                    if(DelRuleId.length() > 0)
                        DelRuleId += ',';
                    DelRuleId += '\'' + String.valueOf(RuleLst[i].id)+ '\'';
                }
            }
            if(SelectedLines.size() == 0)
            {
                Tab2Msg=true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG089()));
                return null;
            }
            if(DelRuleId.length()> 0)
            {
                DelRuleExpression=Database.Query('Select id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in (' + DelRuleId + ')');
            } 
            if(DelRuleLst.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete DelRuleLst;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
            }
            if(DelRuleExpression.size() > 0)
            {   
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {        //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete DelRuleExpression;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
            }       
            Tab2Msg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, DispMethods.getTAG108()));
            for(Integer i=selectedLines.size()-1;i>=0;i--)
            {
                RuleLst.remove(selectedLines.get(i));
            }
        }
        catch (Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        } 
        return null;
    }
    public pageReference SVMX_cancleASRule()
    {
        for(integer i=0; i < RuleLst.size();i++)
        {
            if(RuleLst[i].SVMXC__Select__c == true)
            {
                RuleLst[i].SVMXC__Select__c=false;
                if(RuleLst[i].id == null)
                {
                    RuleLst.remove(i);
                }
            }
        }
        RuleExpression.clear();
        RuleCriExpressions.lstExpressions.clear();
        ruleobj.SVMXC__Assign_Work_Order_To__c=null;
        ruleobj.SVMXC__Assign_To_Technician__c=null;
        ruleobj.SVMXC__Assign_To_Dispatcher__c=null;
        ruleobj.SVMXC__Assign_To_Queue__c=null;
        ruleobj.SVMXC__Schedule_Event__c=null;
        RuleBlockSection=false;
        DisbaleChkBox=false;
        DisbleCancleBttn=true;
        DisbleNewBttn=false;
        DisbleEditBttn=false;
        DisbleDelBttn=false;
        DisbleRSeqBttn=false;
        DisbleSaveBttn=true;
        SaveCloseRulesBtn=false;
        return null;
    }
    public pageReference SVMX_ProcessDefination()
    {
        selectedTab=DispMethods.getTAG003();
        return null;
    }
    public Boolean SVMX_SaveDP()
    {
        Boolean SVMX_SaveDP=false;
        try
        {
            
            if(SVMX_ValidDP() == true)
            {
                string DPCriExpressionsErr=DPCriExpressions.getCriteria('SVMXC__Service_Order__c');
                system.debug('DPCriExpressionsErr '+DPCriExpressionsErr);
                if(DPCriExpressionsErr != 'ERROR')
                {
                    Processobj.RecordTypeId=DispatchProRecordTypeId;
                    processobj.SVMXC__Advance_Expression__c=DPCriExpressions.AdvanceOption;
                    if(processobj.SVMXC__Dispatch_Method__c == 'Immediate' || processobj.SVMXC__Dispatch_Method__c == 'Linx for ServicePower')
                    {
                        processobj.SVMXC__Dispatch_Process_Status__c='Complete';
                    } 
                    System.debug('Upserting the processobj in the saveDP().');  
                    system.debug('Processobj'+Processobj); 
                    if(CallFromFinalSave == false)
                    {
                        upsert Processobj; 
                        DPEID=Processobj.id;
                    }   
                    map<string, string> mapProperties=new map<string, string>(); 
                    mapProperties.put('RecordTypeID', ExpressionRTypeId);
                    mapProperties.put('SVMXC__Expression_Type__c', 'DISP_Process_Entry');
                    mapProperties.put('SVMXC__Expression_Rule__c', Processobj.Id);
                    DPCriExpressions.getExpressions(mapProperties);
                    
                    //Commenting the below code as incremental run is not in use
                    /*map<string, string> mapPropertiesForIncreRun = new map<string, string>();                
                    //processobj.SVMXC__Child_Object_Criteria__c = IncrementalExpressionErr;        
                    system.debug('Advance Option'+IncrementRunExpressions.AdvanceOption);        
                    processobj.SVMXC__Default_Value__c = IncrementRunExpressions.AdvanceOption;
                    mapPropertiesForIncreRun.put('RecordTypeID', ExpressionRTypeId);
                    mapPropertiesForIncreRun.put('SVMXC__Expression_Type__c', 'DISP_Schedule_Exp');
                    mapPropertiesForIncreRun.put('SVMXC__Expression_Rule__c', Processobj.Id);                              
                    IncrementRunExpressions.getExpressions(mapPropertiesForIncreRun);*/
                    
                    SVMX_SaveDP=true; 
                }
                else 
                    selectedTab=DispMethods.getTAG003();
                
            }
            else
            {
                SVMX_SaveDP=false;
                HdrMsg=true;
                Tab4Msg=false;
                
            }
        }
        catch (Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            apexMessagesList.add(ex.getMessage());
        }  
        return SVMX_SaveDP;
    }
    public pagereference SVMX_SaveRules()
    {
        SVMXC__ServiceMax_Processes__c Rule=new SVMXC__ServiceMax_Processes__c(); 
        if(SVMX_SaveDP() == true)
        {
            if(SVMX_ValidAR() == true && ValidDPAssignTo() == true)
            {
                string RuleCriExpressionsErr=RuleCriExpressions.getCriteria('SVMXC__Service_Order__c');
                if(RuleCriExpressionsErr != 'ERROR')
                {
                    for(SVMXC__ServiceMax_Processes__c AR: RuleLst)
                    {
                        if(AR.SVMXC__Select__c == true)
                        {
                            AR.RecordTypeId=RuleRecordTypeId;
                            AR.SVMXC__Rule_Type__c='Simple Assignment';
                            AR.SVMXC__Process__c=Processobj.id;
                            AR.SVMXC__Assign_Work_Order_To__c=ruleobj.SVMXC__Assign_Work_Order_To__c;
                            AR.SVMXC__Assign_To_Technician__c=ruleobj.SVMXC__Assign_To_Technician__c;
                            AR.SVMXC__Assign_To_Dispatcher__c=ruleobj.SVMXC__Assign_To_Dispatcher__c;
                            AR.SVMXC__Assign_To_Queue__c=ruleobj.SVMXC__Assign_To_Queue__c;
                            AR.SVMXC__Schedule_Event__c=ruleobj.SVMXC__Schedule_Event__c;
                            AR.SVMXC__Advance_Expression__c=RuleCriExpressions.AdvanceOption;
                            Rule=AR;
                        }  
                    }
                    Rule.SVMXC__Select__c=false;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Rule, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert Rule;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    map<string, string> mapPropertiesRule=new map<string, string>(); 
                    mapPropertiesRule.put('RecordTypeID', ExpressionRTypeId);
                    mapPropertiesRule.put('SVMXC__Expression_Type__c', 'DISP_Simple_Assignment');
                    mapPropertiesRule.put('SVMXC__Expression_Rule__c', Rule.Id);
                    RuleCriExpressions.getExpressions(mapPropertiesRule);
                    Tab2Msg=true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG106()));
                    RuleBlockSection=false;
                    DisbaleChkBox=false;
                    DisbleCancleBttn=true;
                    DisbleNewBttn=false;
                    DisbleEditBttn=false;
                    DisbleDelBttn=false;
                    DisbleRSeqBttn=false;
                    DisbleSaveBttn=true;
                    if(Processobj.Id != null)
                    {
                        RuleLst.clear();
                        RuleLst=Database.Query('Select SVMXC__Select__c, SVMXC__Name__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Assign_To_Queue__c, SVMXC__Schedule_Event__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Description__c, SVMXC__Sequence__c, id From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c=\''+Processobj.Id+'\' and RecordTypeId=\''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Simple Assignment\'order by SVMXC__Sequence__c');
                    }  
                    SaveCloseRulesBtn=false;
                }
                if(RuleCriExpressionsErr == 'ERROR')
                {
                    Tab2Msg=true;
                }
            }
            else
            {
                Tab2Msg=true;
            }
        }
        else
        {
            Tab2Msg=true;
        }    
        return null;
    }
    public pageReference SVMX_SaveCloseRules()
    {
        HdrMsg=false;
        DontProcess=false; 
        if(SVMX_SaveDP() == true && ValidDPAssignTo() == true)
        {
            return page.WORD_ManageDispatchProcess;
        }  
        else
        {
            Tab4Msg=false;
            HdrMsg=true;
        }
        return null;
    }
    
    public pageReference SVMX_SaveContinuousDP()
    {
        HdrMsg=false;
        DontProcess=false; 
        if(SVMX_SaveDP() == true)
        {
            return page.WORD_ManageDispatchProcess;
        }  
        else
        {
            Tab4Msg=false;
            HdrMsg=true;
        }
        return null;
    }    
    public pageReference AssignWOto()
    {
        /** March 15,2011:Added the below three lines of code Defect No :001462**/
        ruleobj.SVMXC__Assign_To_Technician__c = null;
        ruleobj.SVMXC__Assign_To_Dispatcher__c = null;
        ruleobj.SVMXC__Assign_To_Queue__c = null;
        return null;
    }
    /** March 15,2011:Added the method code Defect No :001462**/
    public pageReference RulesNotMatchedThenAssignWOto()
    {         
        processobj.SVMXC__Assign_To_Technician__c = null;
        processobj.SVMXC__Assign_To_Dispatcher__c = null;
        processobj.SVMXC__Assign_To_Queue__c = null;
        return null;
    }
    public List<SelectOption> Seqoptions=new List<SelectOption>();
    public Map<string,Integer> MyMap=new Map<string,Integer>();
    public string[] items=new String[]{};
        public integer selIndex=0;
    public boolean isUpAction=false;
    public boolean isDownAction=false;
    public boolean isTopAction=false;
    public boolean isBottomAction=false;
    public boolean displaySeqPopup=false;
    public boolean getdisplaySeqPopup(){return displaySeqPopup;}
    public void SVMX_RuleSequence()
    {
        TempRuleLst.clear();
        
        TempRuleLst=Database.Query('Select id, SVMXC__Name__c, SVMXC__Sequence__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c=\''+DPEID+'\' and RecordTypeId=\''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Simple Assignment\'order by SVMXC__Sequence__c');
        
        displaySeqPopup=true;
        DisbaleChkBox=true;
        DisbleNewBttn=true;
        DisbleEditBttn=true;
        DisbleDelBttn=true;
        DisbleRSeqBttn=true;
    }
    public List<SelectOption> getSeqoptions()
    { 
        Seqoptions=new List<SelectOption>();  
        if (TempRuleLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempRuleLst)
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
            temp=TempRuleLst[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                TempRuleLst[j]=TempRuleLst[j-1];
            }
            TempRuleLst[0]=temp;
        }
        else 
        {
            temp=TempRuleLst[selIndex];
            for(integer j=selIndex;j<TempRuleLst.size()-1;j++)
            {
                TempRuleLst[j]=TempRuleLst[j+1];
            }
            TempRuleLst[TempRuleLst.size()-1]=temp;
        }
    } 
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempRuleLst[0].Id)
                {
                    TempRuleLst[j]=TempRuleLst[j];
                    break;
                }
                else if(items[i]==TempRuleLst[j].Id)
                {
                    temp=TempRuleLst[j]; 
                    TempRuleLst[j]=TempRuleLst[j-1];
                    TempRuleLst[j-1]=temp;   
                    selIndex=j;
                    isUpAction=true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempRuleLst[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempRuleLst[selIndex].SVMXC__Sequence__c=selIndex;
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
            for(integer k=0;k<TempRuleLst.size()-1;k++)
            {
                if(items[i]==TempRuleLst[k].Id)
                {
                    temp=TempRuleLst[k];
                    TempRuleLst[k]=TempRuleLst[k+1];
                    TempRuleLst[k+1]=temp;
                    selIndex=k;
                    isUpAction=false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempRuleLst[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempRuleLst[selIndex].SVMXC__Sequence__c=selIndex;
                    break;    
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempRuleLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == TempRuleLst[j].Id)
                {
                    selIndex=j;
                    isUpAction=false;
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
        for(integer j=0;j<TempRuleLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == TempRuleLst[j].Id)
                {
                    selIndex=j;
                    isUpAction=false;
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
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable) ) {      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update TempRuleLst;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            }
        }
        else if(isDownAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable) ) {      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update TempRuleLst;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            }
        }
        else if(isTopAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable) ) {      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update TempRuleLst;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            }
        }
        else if(isBottomAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRuleLst, COMM_SecurityUtils.Access.Updateable) ) {      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update TempRuleLst;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            }
        }
        RuleLst.clear();
        RuleLst.addAll(TempRuleLst);
        displaySeqPopup=false;
        DisbaleChkBox=false;
        DisbleNewBttn=false;
        DisbleEditBttn=false;
        DisbleDelBttn=false;
        DisbleRSeqBttn=false;
        selectedTab=DispMethods.getTAG004();
        return null;  
    }
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup=false;
        DisbaleChkBox=false;
        DisbleNewBttn=false;
        DisbleEditBttn=false;
        DisbleDelBttn=false;
        DisbleRSeqBttn=false;
        selectedTab=DispMethods.getTAG004();
        return null;
    }
    /*********************************************************(New)Tab3's Methods*********************************************/
    public List<SVMXC__Territory__c> OrignalTerritory=new List<SVMXC__Territory__c>();
    public List<SVMXC__Territory__c> TerritorySearchLst=new List<SVMXC__Territory__c>();
    public Boolean Tab3Msg=false;
    public Boolean Tab3Msg2=false;
    public Boolean PanelMsg=False;
    public Boolean msgDeleteRunInfo = false;
    public Boolean getTab3Msg(){return Tab3Msg;}
    public Boolean getPanelMsg(){return PanelMsg;}
    public Boolean getTab3Msg2(){return Tab3Msg2;}
    public Boolean getmsgDeleteRunInfo(){return msgDeleteRunInfo;}
    public List<SVMXC__ServiceMax_Processes__c> getTerritoryRecLst(){return TerritoryRecLst;}      
    public String SearchKeyword='';
    public String getSearchKeyword(){return SearchKeyword;}
    public void setSearchKeyword(String s) {SearchKeyword=s;} 
    public List<SVMXC__Territory__c> getOrignalTerritory(){return OrignalTerritory;}
    public pagereference SVMX_AddTerritory()
    {
        SVMXC__ServiceMax_Processes__c newTerrotory=new SVMXC__ServiceMax_Processes__c();
        TerritoryRecLst.add(newTerrotory);
        system.debug('TerritoryRecLst'+TerritoryRecLst.size());
        disableAddTerrBtn = true;
        if(getOrignalTerritory() != null)
          getOrignalTerritory().clear();
          
        return null; 
    }
    public List<SVMXC__ServiceMax_Processes__c> deleteTerritoryLst=new List<SVMXC__ServiceMax_Processes__c>();
    public pagereference SVMX_DeleteTerritory()
    {
        List<integer> SelectedLines=new List<integer>();
        Tab3Msg2=false;
        for(Integer i=0; i<TerritoryRecLst.size(); i++)
        {
            if(TerritoryRecLst[i].SVMXC__Select__c == true)
            {
                SelectedLines.add(i);
                if(TerritoryRecLst[i].id != null)
                    deleteTerritoryLst.add(TerritoryRecLst[i]);
            }               
        }
        if(SelectedLines.size() < 1)
        {
            Tab3Msg2=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG104())); 
        }
        for(Integer j=SelectedLines.size()-1; j >=0; j--)
        {
            TerritoryRecLst.remove(SelectedLines.get(j));
        }
        return null;
    }
    public pagereference SVMX_GO()
    {
        TerritorySearchLst.clear();
        OrignalTerritory.clear();
        SearchKeyword.trim();
        PanelMsg=false;
        if(SearchKeyword == null || SearchKeyword.length() < 2)
        {
            PanelMsg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG111()));  
        }
        else
        {
            TerritorySearchLst=database.query('Select id, Name,SVMXC__Select__c From SVMXC__Territory__c s where Name LIKE \'%'+String.escapeSingleQuotes(SearchKeyword)+'%\'order by Name');
        }
        for(Integer i=0; i<TerritorySearchLst.size(); i++)
        {
            boolean IsNotExist= true;
            for(Integer j=0; j< TerritoryRecLst.size(); j++)
            {
                if(TerritoryRecLst[j].SVMXC__Territory__c == TerritorySearchLst[i].id )
                    IsNotExist=false;
            }
            if(IsNotExist)
                OrignalTerritory.add(TerritorySearchLst[i]);
        }
        if(OrignalTerritory.size() == 0 && SearchKeyword.length() > 2)
        {
            panelMsg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG110())); 
        } 
        return null;
    }
    public PageReference SVMX_AddSelected()
    {
        List<integer> SelectedLines=new List<integer>();
        for(Integer i=0;i<OrignalTerritory.size();i++)
        {
            if(OrignalTerritory[i].SVMXC__Select__c == true)
            {
                SelectedLines.add(i);
                SVMXC__ServiceMax_Processes__c newTerritory=new SVMXC__ServiceMax_Processes__c();
                newTerritory.SVMXC__Territory__c=OrignalTerritory[i].id;
                TerritoryRecLst.add(newTerritory);
            }
        }
        if(SelectedLines.size() < 1)
        {
            panelMsg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Please Select Atleast on record to add')); 
        }else if(SelectedLines.size() > 1 && processobj.SVMXC__Dispatch_Method__c == 'Real Time Optimization')
        {
            panelMsg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Please select only one record to add')); 
            TerritoryRecLst.clear();
        }
        
        if(SelectedLines.size() == 1 && processobj.SVMXC__Dispatch_Method__c == 'Real Time Optimization')
            disableAddTerrBtn = true;
        
        if((SelectedLines.size() == 1 && processobj.SVMXC__Dispatch_Method__c == 'Real Time Optimization') || processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch')
            for(Integer j=SelectedLines.size()-1; j >=0; j--)
            {
                //OrignalTerritory.remove(SelectedLines.get(j));
                OrignalTerritory.clear();
            }
        return null;
    }
    
    // Start Capacity Limitations
    
    public void CapacityLimitaionsCriADDRow(){ 
        //system.debug('CapacityLimitaionsCriADDRow CapacityLimitationsCriExpressions.lstExpressions111 : '+CapacityLimitationsCriExpressions.lstExpressions);
        CapacityLimitationsCriExpressions.addCriteriaExpression(1);
        //system.debug('CapacityLimitaionsCriADDRow CapacityLimitationsCriExpressions.lstExpressions222 : '+CapacityLimitationsCriExpressions.lstExpressions);
    }
    public void CapacityLimitaionsCriDeleteRow()
    {
        if(delIndex.length() > 0)
            CapacityLimitationsCriExpressions.removeCriteriaExpression(integer.valueOf(delIndex));
    }
    
    /*public void CapacityLimitaionsADDRule(){ 
            SVMXC__ServiceMax_Processes__c newRule=new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c=4,SVMXC__Name__c='', SVMXC__SM_Capacity_Threshold__c=0);
            CapacityLimitations.add(newRule);
    }*/
    
    public COMM_SVMXC_Search_Expressions getCapacityLimitationsCriExpressions() {return CapacityLimitationsCriExpressions;}
    public pageReference SVMX_CapacityLimitations(){selectedTab=DispMethods.getTAG211();return null;}
    public Boolean CapacityNewRuleBtn=true;
    public Boolean CapacitySaveBtn=true;
    public Boolean CapacityCancelBtn=false;
    public Boolean CapacityEditBtn=true;
    public Boolean CapacityDelBtn=true;
    public Boolean CapacityBlkSec=false;
    public Boolean CapacityEditName=true;
    public Boolean CapacityEditThreshold=true;
    public Boolean CapacityDisbalePriChkBox=false;
    //public Boolean getTab4Msg() {return Tab4Msg;}
    public Boolean getCapacityNewRuleBtn(){return CapacityNewRuleBtn;}
    public Boolean getCapacitySaveBtn(){return CapacitySaveBtn;}
    public Boolean getCapacityCancelBtn(){return CapacityCancelBtn;}
    public Boolean getCapacityEditBtn(){return CapacityEditBtn;}
    public Boolean getCapacityDelBtn(){return CapacityDelBtn;}
    public Boolean getCapacityDisbalePriChkBox(){return CapacityDisbalePriChkBox;}
    public Boolean getCapacityBlkSec(){return CapacityBlkSec;}
    public Boolean getCapacityEditName(){return CapacityEditName;}
    public Boolean getCapacityEditThreshold(){return CapacityEditThreshold;}
    
    public string strProcessName{ get; set; }
    public string strDescription{ get; set; }
    public string strCapacityThreshold{ get; set; }
    
    public boolean enableAdvanceExprSec = false;
    public boolean getenableAdvanceExprSec(){ return enableAdvanceExprSec; }
    public void setenableAdvanceExprSec(boolean b){ this.enableAdvanceExprSec = b; }
    public boolean isNewRule = false;
    public Boolean IsValidProcess = true;
    
    /*public List<SVMXC__ServiceMax_Processes__c> getCapacityLimitations()
    {
        //system.debug('getCapacityLimitations CapacityLimitations ==> '+CapacityLimitations);
        if(CapacityLimitations.size() == 0)
        {
            SVMXC__ServiceMax_Processes__c newRule=new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c=true, SVMXC__Sequence__c=6, SVMXC__Name__c='', SVMXC__SM_Capacity_Threshold__c=0);
            
            CapacityLimitations.add(newRule);
            
            //CapacityNewRuleBtn=false;
            //CapacityEditThreshold=false;
                    
            return CapacityLimitations;
        }
        else
        
        {
            return CapacityLimitations;
        }
        
        return CapacityLimitations;
    }*/
    
    public void setDefaultValues() {
        
        system.debug('WORD_SetupDispatchProcess::setDefaultValues()');
        if(CapacityLimitations != null && CapacityLimitations.size() > 0) {
            system.debug('WORD_SetupDispatchProcess::setDefaultValues()::CapacityLimitations.size() - ' + CapacityLimitations.size());
            CapacityNewRuleBtn = true;
            CapacitySaveBtn = false;
            CapacityCancelBtn = true;
            CapacityEditBtn = true;
            CapacityDelBtn = true;
            CapacityBlkSec = false;
            enableAdvanceExprSec = false;
        }
        
        if(CapacityLimitations!= null && CapacityLimitations.size()== 0) {
            system.debug('WORD_SetupDispatchProcess::setDefaultValues()::CapacityLimitations.size() - ' + CapacityLimitations.size());
            CapacityNewRuleBtn = true;
            CapacitySaveBtn = false;
            CapacityCancelBtn = true;
            CapacityEditBtn = false;
            CapacityDelBtn = false;
            CapacityBlkSec = false;
            enableAdvanceExprSec = false;  
        }
        
        if(CapacityLimitations!= null && CapacityLimitations.size() == 4) {
            CapacityNewRuleBtn = false;
        }
    }
    
    public List<SVMXC__ServiceMax_Processes__c> getCapacityLimitations() {
        return CapacityLimitations;
    }
    
    
    public void setCapacityLimitations(List<SVMXC__ServiceMax_Processes__c> sp){CapacityLimitations=sp;}
    
    public pagereference SVMX_AddRuleCapacityLimitations()
    {
        system.debug('WORD_SetupDispatchProcess::SVMX_AddRuleCapacityLimitations:New rule creation');
        //CapacityLimitationsCriExpressions.AdvanceOption=AdvanceOption;
        CapacityNewRuleBtn = false;
        CapacitySaveBtn = true;
        CapacityCancelBtn = true; 
        CapacityEditBtn = false;
        CapacityDelBtn = false;
        CapacityDisbalePriChkBox = false;
        CapacityBlkSec = true;
        DisableTabs = true;
        CapacityEditThreshold = false;
        enableAdvanceExprSec = true;
        isNewRule = true;
        
        strProcessName = '';
        strDescription = '';
        strCapacityThreshold = '';
        
        //Clearing all the unsaved data from the expressions list and the capacityLimitation list from the previous 
        //transaction in the same session so that this data will not be shown up
        //in the UI in the subsequent rule creation during same session.
        CapacityLimitaionsExpression.clear();
        //CapacityLimitationsCriExpressions.lstExpressions.clear();
        
        
        Integer ruleSeqId;
        if(CapacityLimitations != null) {
            ruleSeqId = 5 + CapacityLimitations.size();     //5 is hardcoded because already 5 rules are considered by default for a DP.
        }
        
        SVMXC__ServiceMax_Processes__c newRule = new SVMXC__ServiceMax_Processes__c();
        newRule.SVMXC__Sequence__c = ruleSeqId + 1;
        newRule.SVMXC__Select__c = true;
        CapacityLimitations.add(newRule);
        
        system.debug('WORD_SetupDispatchProcess::SVMX_AddRuleCapacityLimitations:CapacityLimitations.size() - ' + CapacityLimitations.size());
        
        if(CapacityLimitationsCriExpressions != null && CapacityLimitationsCriExpressions.lstExpressions != null 
                && CapacityLimitationsCriExpressions.lstExpressions.size() == 0) {
            CapacityLimitationsCriExpressions = new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CapacityLimitationsCriExpressions.mapFieldDispType, CapacityLimitationsCriExpressions.FieldApiLable);
            CapacityLimitationsCriExpressions.FieldsList = Hdrfldlist;
            CapacityLimitationsCriExpressions.objfieldMap = DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
        }
        
        //CapacityLimitationsCriExpressions.addCriteriaExpression(1);
        //system.debug('WORD_SetupDispatchProcess::SVMX_AddRuleCapacityLimitations::CapacityLimitationsCriExpressions - ' + CapacityLimitationsCriExpressions);
        
        return null;
    }
    
    public pagereference SVMX_EditCapacityLimitations()
    {
        CapacityNewRuleBtn = false;
        CapacitySaveBtn = true;
        CapacityCancelBtn = true; 
        CapacityEditBtn = false;
        CapacityDelBtn = false;
        CapacityDisbalePriChkBox = true;
        CapacityBlkSec = true;
        DisableTabs = true;
        CapacityEditName = false;
        CapacityEditThreshold = false;
        enableAdvanceExprSec = true;
        isNewRule = false;
        
        String AdvanceOption='';
        String CapacityId;
        Integer intSelectedCount = 0;
        for(integer i=0; i < CapacityLimitations.size();i++) {
            if(CapacityLimitations[i].SVMXC__Select__c == true) {  
                intSelectedCount ++;
            }
        }
        
        if(intSelectedCount == 0) {
            Tab4Msg=true;
            CapacityDisbalePriChkBox = false;
            CapacityBlkSec = false;
            enableAdvanceExprSec = false;
            CapacityEditBtn = true;
            CapacityNewRuleBtn = true;
            CapacityDelBtn = true;
            CapacitySaveBtn = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG089()));
            return null;
        } else if(intSelectedCount > 1) {
            
            for(integer i=0; i < CapacityLimitations.size();i++) {
                if(CapacityLimitations[i].SVMXC__Select__c == true) {  
                    CapacityLimitations[i].SVMXC__Select__c = false;
                }
            }
            
            Tab4Msg=true;
            CapacityDisbalePriChkBox = false;
            CapacityBlkSec = false;
            enableAdvanceExprSec = false;
            CapacityEditBtn = true;
            CapacityNewRuleBtn = true;
            CapacityDelBtn = true;
            CapacitySaveBtn = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG107()));   
            return null;
        }
        
        //Clearing all the unsaved data from the expressions list and the capacityLimitation list from the previous 
        //transaction in the same session so that this data will not be shown up
        //in the UI in the subsequent rule creation during same session.
        CapacityLimitaionsExpression.clear();
        CapacityLimitationsCriExpressions.lstExpressions.clear();
        System.debug('WORD_SetupDispatchProcess::SVMX_EditCapacityLimitations:CapacityLimitations : ' + CapacityLimitations);
        //CapacityLimitations = Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c, SVMXC__SM_Capacity_Threshold__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:DPEID and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Capacity Reservation\'');
        for(SVMXC__ServiceMax_Processes__c cl :CapacityLimitations) {
            if(cl.SVMXC__Select__c == true) {
                CapacityId = cl.id;
                AdvanceOption = cl.SVMXC__Advance_Expression__c;
                strProcessName = cl.SVMXC__Name__c;
                strDescription = cl.SVMXC__Description__c;
                strCapacityThreshold = String.valueOf(cl.SVMXC__SM_Capacity_Threshold__c);
            }
        }
        system.debug('WORD_SetupDispatchProcess::SVMX_EditCapacityLimitations:CapacityId : ' + CapacityId);
        if(CapacityId != null && CapacityId.length() > 0) {
            CapacityLimitaionsExpression=Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c=\''+CapacityId+'\' and RecordTypeId=\''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Capacity_Reservation\'');
        }
        
        //System.debug('SVMX_EditCapacityLimitations 222 --- CapacityLimitaionsExpression.size(): '+CapacityLimitaionsExpression.size()+' , CapacityLimitaionsExpression: '+CapacityLimitaionsExpression);
        //Below is the case when only the rule is created and there is no criteria defined for this rule and hence there is no config data to retrieve here.
        //Hence we only populate the Object CapacityLimitationsCriExpressions with required criteria picklist fields with default as NONE.
        if(CapacityLimitaionsExpression.size() == 0 ) {
            CapacityLimitationsCriExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CapacityLimitationsCriExpressions.mapFieldDispType, CapacityLimitationsCriExpressions.FieldApiLable);
            CapacityLimitationsCriExpressions.FieldsList=Hdrfldlist;
            CapacityLimitationsCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
        }
        //Below is the case where the rule has one or more criteria defined. Hence we populate the 
        //Object CapacityLimitationsCriExpressions with relevant fields along with the criteria picklist with 
        //appropriate values after retriving the data from the config object to display in UI
        if(CapacityLimitaionsExpression != null && CapacityLimitaionsExpression.size() > 0) {
            CapacityLimitationsCriExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CapacityLimitationsCriExpressions.mapFieldDispType, CapacityLimitationsCriExpressions.FieldApiLable);
            CapacityLimitationsCriExpressions.FieldsList=Hdrfldlist;
            CapacityLimitationsCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            CapacityLimitationsCriExpressions.DefaultField=DispMethods.getTAG033();
            CapacityLimitationsCriExpressions.DefaultOperator=DispMethods.getTAG033();
            CapacityLimitationsCriExpressions.DefaultListValue=DispMethods.getTAG033();
            CapacityLimitationsCriExpressions.ExpressionType='CRITERIA';
            //populate the criteria picklist values in UI by using the data from the config object retrieved above.
            for(SVMXC__ServiceMax_Config_Data__c exp : CapacityLimitaionsExpression) {
                CapacityLimitationsCriExpressions.setExpressions(exp);
            }
        }
        CapacityLimitationsCriExpressions.AdvanceOption=AdvanceOption;
        
        return null;
    }
    
    public Boolean SVMX_SaveCapacityLimitations=false;
    
    public pagereference SVMX_SaveCapacityLimitations()
    {
        CapacityNewRuleBtn = false;
        CapacitySaveBtn = false;
        CapacityCancelBtn = true; 
        CapacityEditBtn = false;
        CapacityDelBtn = true;
        CapacityDisbalePriChkBox = false;
        CapacityBlkSec = false;
        enableAdvanceExprSec = false;
        SVMX_SaveCapacityLimitations = true;
        DisableTabs = false;
        
        this.validation();
        
        if(isValidProcess) {
            SVMX_SaveCapacityLimitations=false;
            Tab4Msg=false;
            
            String SelectdId ='';
            String capacityRuleId;
            
            //system.debug('CapacityLimitationsCriExpressionsErr  == : '+CapacityLimitationsCriExpressionsErr+'\n');
            //system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::CapacityLimitationsCriExpressions ' + CapacityLimitationsCriExpressions);
            system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::isNewRule - ' + isNewRule);
            
            //in case of Edit, if select == true fetch the capacityRuleId
            if(!isNewRule) {
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::Edit Rule section');
                for(SVMXC__ServiceMax_Processes__c cl :CapacityLimitations) {
                    system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::CapacityLimitations cl.SVMXC__Name__c : '+cl.SVMXC__Name__c);
                    if(cl.SVMXC__Select__c == true) {  
                        capacityRuleId=cl.id;
                    }
                }
                
                ClearSelOptList(Hdrfldlist);
                DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CapacityLimitationsCriExpressions.mapFieldDispType, CapacityLimitationsCriExpressions.FieldApiLable);
                CapacityLimitationsCriExpressions.FieldsList=Hdrfldlist;
                CapacityLimitationsCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            } else {
                CapacityLimitationsCriExpressions.addCriteriaExpression(1);
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::New Rule section');
                //CapacityLimitationsCriExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
                ClearSelOptList(Hdrfldlist);
                DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CapacityLimitationsCriExpressions.mapFieldDispType, CapacityLimitationsCriExpressions.FieldApiLable);
                CapacityLimitationsCriExpressions.FieldsList=Hdrfldlist;
                CapacityLimitationsCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            }
            
            //system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::CapacityLimitationsCriExpressions: ' + CapacityLimitationsCriExpressions);
            system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::CapacityLimitations.size(): ' + CapacityLimitations.size());
            
            string CapacityLimitationsCriExpressionsErr = CapacityLimitationsCriExpressions.getCriteria('SVMXC__Service_Order__c');
            system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::CapacityLimitationsCriExpressionsErr: '+CapacityLimitationsCriExpressionsErr);
            Integer newRuleIndex;
            
            if(CapacityLimitationsCriExpressionsErr != 'ERROR') {
                for(Integer i=0;i<CapacityLimitations.size();i++) {
                    if(CapacityLimitations[i].SVMXC__Select__c == true) {
                        CapacityLimitations[i].RecordTypeId = RuleRecordTypeId;
                        CapacityLimitations[i].SVMXC__Rule_Type__c = 'Capacity Reservation';
                        CapacityLimitations[i].SVMXC__Name__c = strProcessName;
                        CapacityLimitations[i].SVMXC__Description__c = strDescription;
                        if(!String.isEmpty(strCapacityThreshold)) {
                            CapacityLimitations[i].SVMXC__SM_Capacity_Threshold__c = Decimal.valueOf(strCapacityThreshold);
                        }
                        CapacityLimitations[i].SVMXC__Advance_Expression__c = CapacityLimitationsCriExpressions.AdvanceOption;
                        CapacityLimitations[i].SVMXC__Select__c = false;
                        //if(CapacityLimitations[i].SVMXC__Process__c == null || CapacityLimitations[i].id == null)
                            CapacityLimitations[i].SVMXC__Process__c = Processobj.id;
                        newRuleIndex = i;
                    }
                }
                
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: CapacityLimitaionsExpression - '+CapacityLimitaionsExpression);
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: CapacityLimitationsCriExpressions.AdvanceOption - '+CapacityLimitationsCriExpressions.AdvanceOption);
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: CapacityLimitationsCriExpressions.lstExpressions - '+CapacityLimitationsCriExpressions.lstExpressions);
                
                list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();

                for(integer k=0; k < CapacityLimitationsCriExpressions.lstExpressions.size(); k++)
                {
                   if(CapacityLimitationsCriExpressions.lstExpressions[k].FieldName != null && CapacityLimitationsCriExpressions.lstExpressions[k].FieldName != 'SVMX.NONE' && CapacityLimitationsCriExpressions.lstExpressions[k].Operator != null && CapacityLimitationsCriExpressions.lstExpressions[k].Operator != 'SVMX.NONE' && CapacityLimitationsCriExpressions.lstExpressions[k].FieldName.length() > 0 && CapacityLimitationsCriExpressions.lstExpressions[k].Operator.length() > 0)
                    {
                        SVMXC__ServiceMax_Config_Data__c confObj = new SVMXC__ServiceMax_Config_Data__c();
                        
                        confObj.SVMXC__Sequence__c = CapacityLimitationsCriExpressions.lstExpressions[k].Sequence;
                        confObj.SVMXC__Field_Name__c = CapacityLimitationsCriExpressions.lstExpressions[k].FieldName;
                        confObj.SVMXC__Operator__c = CapacityLimitationsCriExpressions.lstExpressions[k].Operator;
                        confObj.SVMXC__Operand__c = CapacityLimitationsCriExpressions.lstExpressions[k].Operand;
                        
                        lstConfigData.add(confObj);
                    }
                }   
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: lstConfigData - '+lstConfigData);
                boolean isExp1Val = false;
                if(CapacityLimitationsCriExpressions.AdvanceOption != null) {
                    isExp1Val = submitExp(Processobj,lstConfigData,CapacityLimitationsCriExpressions.AdvanceOption);
                }
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: isExp1Val - '+isExp1Val);
                                
                if(isExp1Val){
                    if(CapacityLimitations!= null) {  
                        upsert CapacityLimitations;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::capacityRuleId - ' + capacityRuleId);
                    
                    map<string, string> mapPropertiesCapacityLimitations = new map<string, string>(); 
                    mapPropertiesCapacityLimitations.put('RecordTypeID', ExpressionRTypeId);
                    mapPropertiesCapacityLimitations.put('SVMXC__Expression_Type__c', 'DISP_Capacity_Reservation');
                    if(!isNewRule) {
                        system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::capacityRuleId - ' + capacityRuleId);
                        mapPropertiesCapacityLimitations.put('SVMXC__Expression_Rule__c', capacityRuleId);
                    } else {
                        system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::CapacityLimitations[newRuleIndex].Id - ' + CapacityLimitations[newRuleIndex].Id);
                        mapPropertiesCapacityLimitations.put('SVMXC__Expression_Rule__c', CapacityLimitations[newRuleIndex].Id);
                    }
                    CapacityLimitationsCriExpressions.getExpressions(mapPropertiesCapacityLimitations);
                    
                    Tab4Msg=true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG106()));
                    //Clear all the data from the CapacityLimitations list from the previous 
                    //transaction in the same session so that in the subsequent rule creation, 
                    //this data does not show up in UI. This is very important
                    if(Processobj.id != null)
                    {
                        CapacityLimitations.clear();
                        CapacityLimitations=Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c, SVMXC__SM_Capacity_Threshold__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c=\''+Processobj.id+'\' and RecordTypeId=\''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Capacity Reservation\'');
                    }
                    
                    CapacityNewRuleBtn = true;
                    CapacitySaveBtn = false;
                    CapacityCancelBtn = true; 
                    CapacityEditBtn = true;
                    DisableTabs = false;
                    CapacityDelBtn = true;
                    
                    //Clearing all the data from the expressions list so that this data will not be shown up
                    //in the criteria fields in the subsequent rule creation during same session.
                    CapacityLimitaionsExpression.clear();
                    CapacityLimitationsCriExpressions.lstExpressions.clear();
                    
                    if(CapacityLimitations!= null && CapacityLimitations.size() == 4) {
                        CapacityNewRuleBtn = false;
                    }
                }else {
                    //To make the rule record editable when the advanced expression is not valid
                    if(CapacityLimitations[newRuleIndex].SVMXC__Select__c == false){  
                        CapacityLimitations[newRuleIndex].SVMXC__Select__c = true;
                    }
                    tab4Msg = true;
                    CapacitySaveBtn = true;
                    CapacityBlkSec = true;
                    enableAdvanceExprSec = true;
                    CapacityDelBtn = false;
                    CapacityDisbalePriChkBox = true;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, DispMethods.getTAG224()));
                    //capLimErrorMssg.add('Please provide the correct advanced expression \n');
                }
                
            } else {
                Tab4Msg=true;
            } 
        } else { 
                tab4Msg = true;
                CapacitySaveBtn = true;
                CapacityBlkSec = true;
                enableAdvanceExprSec = true;
                CapacityDelBtn = false;
                CapacityDisbalePriChkBox = true;
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations::Enter a valid rule name');
                
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: Before capLimErrorMssg: ' + capLimErrorMssg);
                if(capLimErrorMssg.size() > 0){
                    for(String msg : capLimErrorMssg){
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,msg ));
                    }
                    capLimErrorMssg.clear();
                }
                system.debug('WORD_SetupDispatchProcess::SVMX_SaveCapacityLimitations:: After capLimErrorMssg: ' + capLimErrorMssg);
                
                return null;
        }
        
        return null;
    }
    
    public PageReference SVMX_CancleCapacityLimitations()
    {
        //Clearing all the unsaved data from the expressions list and the capacityLimitation list so that this data will not be shown up
        //in the UI in the subsequent rule creation during same session.
        CapacityLimitaionsExpression.clear();
        CapacityLimitationsCriExpressions.lstExpressions.clear();
        CapacityLimitations.clear();
        if(Processobj.id != null) {
            CapacityLimitations.clear();
            CapacityLimitations=Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c, SVMXC__SM_Capacity_Threshold__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c=\''+Processobj.id+'\' and RecordTypeId=\''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Capacity Reservation\'');
        }
        
        for(integer i=0; i < CapacityLimitations.size();i++) {
            if(CapacityLimitations[i].SVMXC__Select__c == true) {
                CapacityLimitations[i].SVMXC__Select__c = false;
            }
        }
        
        CapacitySaveBtn = false;
        CapacityCancelBtn = true; 
        CapacityEditBtn = false;
        CapacityDelBtn = false;
        CapacityDisbalePriChkBox = false;
        CapacityBlkSec = false;
        DisableTabs = false;
        CapacityNewRuleBtn = true;
        enableAdvanceExprSec = false;
        
        if(CapacityLimitations != null && CapacityLimitations.size() > 0) {
            CapacityEditBtn = true;
            CapacityDelBtn = true;
        }
        return null;
    }  
    
    public pagereference SVMX_DeleteCapacityLimitations()
    {
        system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::Inside delete rule method');
        SVMXC__ServiceMax_Processes__c delCapacityLimitationsRule = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> lstOfCapacityConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        String AdvanceOption ='';
        String CapacityId;
        Integer intSelectedCount = 0;
        
        CapacityNewRuleBtn = true;
        CapacitySaveBtn = false;
        CapacityCancelBtn = true; 
        CapacityEditBtn = false;
        CapacityDelBtn = false;
        CapacityDisbalePriChkBox = true;
        CapacityBlkSec = false;
        enableAdvanceExprSec = false;
        DisableTabs = true;
        CapacityEditThreshold = false;
        
        Integer indexToRemove = 0;
        
        system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::CapacityLimitations.size() - ' + CapacityLimitations.size());
        system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::intSelectedCount - ' + intSelectedCount);
        
        for(integer i=0; i < CapacityLimitations.size();i++) {
            if(CapacityLimitations[i].SVMXC__Select__c == true) {  
                intSelectedCount ++;
            }
        }
        
        if(intSelectedCount == 0) {
            Tab4Msg=true;
            CapacityEditBtn = true;
            CapacityDelBtn = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG104()));
            return null;
        } else if(intSelectedCount > 1) {
            for(integer i=0; i < CapacityLimitations.size();i++) {
                if(CapacityLimitations[i].SVMXC__Select__c == true) {  
                    CapacityLimitations[i].SVMXC__Select__c = false;
                }
            }
            Tab4Msg=true;
            CapacityEditBtn = true;
            CapacityDelBtn = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG215()));   
            return null;
        } else if(intSelectedCount == 1) {
            system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::Inside selected count 1 ');
            for(integer i=0; i < CapacityLimitations.size();i++) {
                if(CapacityLimitations[i].SVMXC__Select__c == true) {
                    //system.debug('CapacityLimitations inside loop: '+CapacityLimitations[i].SVMXC__Name__c);
                    delCapacityLimitationsRule = CapacityLimitations[i];
                    indexToRemove = i;
                }
            }
            
            system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::delCapacityLimitationsRule - ' + delCapacityLimitationsRule);
            
            lstOfCapacityConfigData = [Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: delCapacityLimitationsRule.Id and RecordTypeId =: ExpressionRTypeId and SVMXC__Expression_Type__c = 'DISP_Capacity_Reservation'];
            
            system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::lstOfCapacityConfigData.size() - ' + lstOfCapacityConfigData.size());
            
            if(lstOfCapacityConfigData.size() > 0 && COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')) {  //SDL-SVMX-DELETE-FLS-ENFORCED
                delete lstOfCapacityConfigData;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
            } 
            
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')) {
                delete delCapacityLimitationsRule;
                CapacityLimitations.remove(indexToRemove);
                system.debug('WORD_SetupDispatchProcess::SVMX_DeleteCapacityLimitations::CapacityLimitations.size() - ' + CapacityLimitations.size());
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
            } 
        }
        
        if(Processobj.id != null) {
            CapacityLimitations.clear();
            CapacityLimitations=Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c, SVMXC__SM_Capacity_Threshold__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c=\''+Processobj.id+'\' and RecordTypeId=\''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Capacity Reservation\'');
        }
        
        CapacityLimitationsCriExpressions.AdvanceOption=AdvanceOption;
        
        if(CapacityLimitations != null && CapacityLimitations.size() > 0) {
            CapacityEditBtn = true;
            CapacityDelBtn = true;
            CapacityDisbalePriChkBox = false;
        }
        
        return null;
    }
    
    public void validation() {
        
        system.debug('Inside validation()');
        integer count = 0;
        IsValidProcess = true;
        if(strProcessName == null || strProcessName == '') {
            IsValidProcess = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,DispMethods.getTAG219()));
            system.debug('Process name is null ' + DispMethods.getTAG219());
            capLimErrorMssg.add(DispMethods.getTAG219());
            //return;
        }  
        /*if( strProcessName.length() < 8 ) {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,DispMethods.getTAG220()));
            system.debug('Process length is < 8 ' + DispMethods.getTAG220());
            return;
        }*/
        
        if(String.isEmpty(strCapacityThreshold) || !strCapacityThreshold.isNumeric()) {
            IsValidProcess = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Enter a valid Capacity Threshold value'));
            //system.debug('Enter a valid Capacity Threshold value');
            capLimErrorMssg.add(DispMethods.getTAG225());
            //return;
        }
        
        if(!String.isEmpty(strCapacityThreshold) && strCapacityThreshold.isNumeric() && Integer.valueOf(strCapacityThreshold) <=0) {
            IsValidProcess = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Capacity Threshold value cannot be lesser than or equal to 0'));
            system.debug('Capacity Threshold value cannot be lesser than or equal to 0 ');
            capLimErrorMssg.add(DispMethods.getTAG227());
        }
        
        if(!String.isEmpty(strCapacityThreshold) && Integer.valueOf(strCapacityThreshold) > 100) {
            IsValidProcess = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Capacity Threshold value cannot be greater than 100'));
            system.debug('Capacity Threshold value cannot be greater than 100 ');
            capLimErrorMssg.add(DispMethods.getTAG226());
        }
        
        /*if(strCapacityThreshold.startsWith('-')) {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Capacity Threshold value should be positive'));
            system.debug('Capacity Threshold value should be positive ' + DispMethods.getTAG220());
            return;
        }*/  
       
        for(SVMXC__ServiceMax_Processes__c capacityLimRule: CapacityLimitations) {
            if(capacityLimRule.SVMXC__Select__c == true) {
                count =  count + 1;
            }
        }
        if(count > 1) {
            IsValidProcess = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, DispMethods.getTAG217()));
            system.debug('process count is > 1 ' + DispMethods.getTAG217());
            capLimErrorMssg.add(DispMethods.getTAG217());
        }
        if(count == 0) {
            IsValidProcess = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, DispMethods.getTAG218()));
            system.debug('process count is = 0 ' + DispMethods.getTAG218());
            capLimErrorMssg.add(DispMethods.getTAG218());
        }
        
        /*system.debug('WORD_SetupDispatchProcess :: validation: CapacityLimitationsCriExpressions.AdvanceOption: '+CapacityLimitationsCriExpressions.AdvanceOption);
        system.debug('WORD_SetupDispatchProcess :: validation: CapacityLimitaionsExpression: '+CapacityLimitaionsExpression);
        system.debug('WORD_SetupDispatchProcess :: validation: Processobj: '+Processobj);
        
        if((CapacityLimitationsCriExpressions.AdvanceOption != null) && (!submitExp(Processobj,CapacityLimitaionsExpression,CapacityLimitationsCriExpressions.AdvanceOption))){
            IsValidProcess = false;
            capLimErrorMssg.add('Please provide the correct advanced expression \n');
        }
        
        system.debug('WORD_SetupDispatchProcess :: validation: capLimErrorMssg: '+capLimErrorMssg);*/
    }
    
    public boolean submitExp(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst, string AdvExp)
    {   
        system.debug('WORD_SetupDispatchProcess Inside submitExp()');
        SVMXC.SFM_WrapperDef.SFM_Response Save_Response = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
        SVMXC.SFM_WrapperDef.SFM_Expression oSFM_Exp = new SVMXC.SFM_WrapperDef.SFM_Expression(ProcessObj,ExpConfigDataLst);
        oSFM_Exp.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpHdr_Rtype_Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Advance_Expression__c=AdvExp);
        List<SVMXC.SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
        LstSFM_Exp.add(oSFM_Exp);
        SVMXC.SFM_WrapperDef.SFM_Request_Expression oRequest = new SVMXC.SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        Save_Response = ValidateExp.SFM_validateExpression(oRequest);      
        system.debug('WORD_SetupDispatchProcess submitExp Save_Response: '+Save_Response);  
        if( Save_Response.success != null && Boolean.valueOf(Save_Response.success)){
            system.debug('WORD_SetupDispatchProcess If condition submitExp()');
            return true;
        }else{       
            system.debug('WORD_SetupDispatchProcess Else condition submitExp()');
            return false;
        }
    }
        
    // End Capacity Limitations
    
    public pageReference SVMX_Prioritization(){selectedTab=DispMethods.getTAG006();return null;}
    public Boolean PrioritySaveBtn=true;
    public Boolean PriorityCancelBtn=true;
    public Boolean PriorityEditBtn=false;
    public Boolean PriorityBlkSec=false;
    public Boolean DisbalePriChkBox=false;
    public Boolean getTab4Msg() {return Tab4Msg;}
    public Boolean getPrioritySaveBtn(){return PrioritySaveBtn;}
    public Boolean getPriorityCancelBtn(){return PriorityCancelBtn;}
    public Boolean getPriorityEditBtn(){return PriorityEditBtn;}
    public Boolean getDisbalePriChkBox(){return DisbalePriChkBox;}
    public Boolean getPriorityBlkSec(){return PriorityBlkSec;}
    public List<SVMXC__ServiceMax_Processes__c> getPriortization()
    {
        if(Priortization.size() == 0)
        {
            SVMXC__ServiceMax_Processes__c newRule4=new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c=5,SVMXC__Name__c=DispMethods.getTAG119());
            SVMXC__ServiceMax_Processes__c newRule3=new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c=4,SVMXC__Name__c=DispMethods.getTAG120());
            SVMXC__ServiceMax_Processes__c newRule2=new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c=3,SVMXC__Name__c=DispMethods.getTAG121());
            SVMXC__ServiceMax_Processes__c newRule1=new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c=2,SVMXC__Name__c=DispMethods.getTAG122());
            Priortization.add(newRule4);
            Priortization.add(newRule3);
            Priortization.add(newRule2);
            Priortization.add(newRule1);
            return Priortization;
        }
        else
        {
            return Priortization;
        }
    }
    public void setPriortization(List<SVMXC__ServiceMax_Processes__c> sp){Priortization=sp;}
    public COMM_SVMXC_Search_Expressions getPriorityCriExpressions() {return PriorityCriExpressions;}
    public void PriorityCriADDRow(){ PriorityCriExpressions.addCriteriaExpression(1);}
    public void PriorityCriDeleteRow()
    {
        if(delIndex!=null && delIndex.length() > 0)
            PriorityCriExpressions.removeCriteriaExpression(integer.valueOf(delIndex));
    }
    public pagereference SVMX_EditPriortization()
    {
        String AdvanceOption='';
        String PriorityId;
        List<Integer> SelectedLines=new List<Integer>();
        for(integer i=0; i < Priortization.size();i++)
        {
            if(Priortization[i].SVMXC__Select__c == true)
            {  
                SelectedLines.add(i);
            }
        }
        if(SelectedLines.size() == 0)
        {
            Tab4Msg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG089()));
            return null;
        }
        if(SelectedLines.size() > 1)
        {
            for(integer i=0; i < Priortization.size();i++)
            {
                if(Priortization[i].SVMXC__Select__c == true)
                {
                    Priortization[i].SVMXC__Select__c=false;
                }
            }
            Tab4Msg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG107()));   
            return null;
        }
        PriorityExpression.clear();
        PriorityCriExpressions.lstExpressions.clear();
        for(SVMXC__ServiceMax_Processes__c pr :Priortization)
        {
            if(pr.SVMXC__Select__c == true)
            {
                PriorityId=pr.id;
                AdvanceOption=pr.SVMXC__Advance_Expression__c;
            }
        }
        if(PriorityId != null && PriorityId.length() > 0)
        {
            PriorityExpression=Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c=\''+PriorityId+'\' and RecordTypeId=\''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Priortization\'');
        }
        if(PriorityExpression.size() == 0 )
        {
            PriorityCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, PriorityCriExpressions.mapFieldDispType, PriorityCriExpressions.FieldApiLable);
            PriorityCriExpressions.FieldsList=Hdrfldlist;
            PriorityCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
        }
        if(PriorityExpression != null && PriorityExpression.size() > 0)
        {
            PriorityCriExpressions=new COMM_SVMXC_Search_Expressions(3,true,true,true,false,true,'','');
            ClearSelOptList(Hdrfldlist);
            DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, PriorityCriExpressions.mapFieldDispType, PriorityCriExpressions.FieldApiLable);
            PriorityCriExpressions.FieldsList=Hdrfldlist;
            PriorityCriExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
            PriorityCriExpressions.DefaultField=DispMethods.getTAG033();
            PriorityCriExpressions.DefaultOperator=DispMethods.getTAG033();
            PriorityCriExpressions.DefaultListValue=DispMethods.getTAG033();
            PriorityCriExpressions.ExpressionType='CRITERIA';
            for(SVMXC__ServiceMax_Config_Data__c exp : PriorityExpression)
            {
                PriorityCriExpressions.setExpressions(exp);
            }
        }
        PriorityCriExpressions.AdvanceOption=AdvanceOption;
        PrioritySaveBtn=false;
        PriorityCancelBtn=false; 
        PriorityEditBtn=true;
        DisbalePriChkBox=true;
        PriorityBlkSec=true;
        DisableTabs=true;
        return null;
    }
    List<SVMXC__ServiceMax_Processes__c> SavePriorityRule=new List<SVMXC__ServiceMax_Processes__c>();
    SVMXC__ServiceMax_Processes__c SelectedRule;
    public Boolean SVMX_SavePriortization=false;
    public pagereference SVMX_SavePriortization()
    {
        if(DPEId != null && DPEId !='')
        {
            list<SVMXC__SVMX_Jobs__c> lstSvmxJobs = [Select Id, SVMXC__Start_Time__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :DPEID and (SVMXC__OptiMax_Message__c = 'In Progress' OR SVMXC__OptiMax_Message__c = 'Initiated')];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstSvmxJobs != null && lstSvmxJobs.size() > 0)
            {
                 HdrMsg=true;
                //msgFreqGr1 = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.WORD014_TAG039));
                
                return null;
            }

        }
        SVMX_SavePriortization=false;
        Tab4Msg=false;
        
        
        String SelectdId ='';
        SavePriorityRule.clear();
        string PriorityCriExpressionsErr=PriorityCriExpressions.getCriteria('SVMXC__Service_Order__c');
        if(PriorityCriExpressionsErr != 'ERROR')
        {
            for(Integer i=0;i<Priortization.size();i++)
            {
                if(Priortization[i].SVMXC__Select__c == true)
                {
                    Priortization[i].RecordTypeId=RuleRecordTypeId;
                    Priortization[i].SVMXC__Rule_Type__c='Priortization';
                    Priortization[i].SVMXC__Advance_Expression__c=PriorityCriExpressions.AdvanceOption;
                    if(Priortization[i].id == null && Priortization[i].SVMXC__Process__c == null)
                        Priortization[i].SVMXC__Process__c=Processobj.id;
                    Priortization[i].SVMXC__Select__c=false;
                    SelectedRule=new SVMXC__ServiceMax_Processes__c();
                    SelectedRule=Priortization[i]; 
                }
                if(Priortization[i].SVMXC__Select__c == false)
                {
                    Priortization[i].RecordTypeId=RuleRecordTypeId;
                    Priortization[i].SVMXC__Rule_Type__c='Priortization';
                    if(Priortization[i].SVMXC__Process__c == null || Priortization[i].id == null)
                        Priortization[i].SVMXC__Process__c=Processobj.id;
                    SavePriorityRule.add(Priortization[i]); 
                }
            }
            if(SelectedRule!= null)
            {  
                upsert SelectedRule;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                SelectdId=SelectedRule.id;
            }
            if(SavePriorityRule.size() > 0)
            {        
                upsert SavePriorityRule;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            map<string, string> mapPropertiesPriority=new map<string, string>(); 
            mapPropertiesPriority.put('RecordTypeID', ExpressionRTypeId);
            mapPropertiesPriority.put('SVMXC__Expression_Type__c', 'DISP_Priortization');
            mapPropertiesPriority.put('SVMXC__Expression_Rule__c', SelectdId);
            PriorityCriExpressions.getExpressions(mapPropertiesPriority);
            Tab4Msg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,DispMethods.getTAG106()));
            if(Processobj.id != null)
            {
                Priortization.clear();
                Priortization=Database.Query('Select id, SVMXC__Select__c, SVMXC__Advance_Expression__c, RecordTypeId, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Sequence__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c=\''+Processobj.id+'\' and RecordTypeId=\''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Priortization\'');
            }
            PrioritySaveBtn=true;
            PriorityCancelBtn=true; 
            PriorityEditBtn=false;
            DisbalePriChkBox=false;
            PriorityBlkSec=false;
            SVMX_SavePriortization=true;
            DisableTabs=false;
        }
        if(PriorityCriExpressionsErr == 'ERROR')
        {
            Tab4Msg=true;
        }  
        
        
        
        
        
        return null;
    }
    public PageReference SVMX_CanclePriortization()
    {
        for(integer i=0; i < Priortization.size();i++)
        {
            if(Priortization[i].SVMXC__Select__c == true)
            {
                Priortization[i].SVMXC__Select__c=false;
            }
        }
        PriorityExpression.clear();
        PriorityCriExpressions.lstExpressions.clear();
        PrioritySaveBtn=true;
        PriorityCancelBtn=true; 
        PriorityEditBtn=false;
        DisbalePriChkBox=false;
        PriorityBlkSec=false;
        DisableTabs=false;
        return null;
    }
    public pagereference SVMX_Territories(){selectedTab=DispMethods.getTAG005();return null;}
    public pagereference SVMX_DispatchPreferences(){selectedTab=DispMethods.getTAG007();return null;}
    public List<SelectOption> getProductExpertiseOpt()
    {
        List<SelectOption> options=new List<SelectOption>();
        options.add(new selectOption(DispMethods.getTAG029(),DispMethods.getTAG029()));
        options.add(new selectOption(DispMethods.getTAG043(),DispMethods.getTAG043()));
        options.add(new selectOption(DispMethods.getTAG048(),DispMethods.getTAG048()));
        return options;
    }
    public String ProductExpertise;
    public String getProductExpertise(){return ProductExpertise;}
    public void setProductExpertise(String s) {ProductExpertise=s;} 
    public List<SelectOption> opt=new List<SelectOption>();
    public List<SelectOption> getOptions()
    {
        opt.clear();
        opt.add(new selectOption('false',DispMethods.getTAG054()));
        opt.add(new selectOption('true',DispMethods.getTAG053()));
        return opt;
    }
    public List<SelectOption> getRouteNatureToConsider()
    {
        List<SelectOption> Options=new List<SelectOption>();
        Options.add(new selectOption('CLOSED','CLOSED'));
        Options.add(new selectOption('OPEN','OPEN'));
        return Options;
    } 
    
    public pageReference SVMX_CostParameters(){selectedTab=DispMethods.getTAG008();return null;}
    public pageReference SVMX_Scheduling() {
        system.debug(LoggingLevel.INFO, processobj.SVMXC__Dispatch_Method__c);
        if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch') {
            selectedTab=DispMethods.getTAG009();
            return null;
        } else {
            selectedTab=DispMethods.getTAG198();
            return null;
        }
    }
    
    public pageReference SVMX_LongTermPlanner() {
        
        selectedTab=DispMethods.getlongTermPlannerDP();
        
        /** copying scheduling days value from Batch or Eco tab to LTP tab when LTP section is enabled**/
        if((processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() || 
                                processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch') && strScheduleDays != null) {
            strLTPStartAftrFull = strScheduleDays;
        }
        return null;
    }
    
    public Boolean SVMX_ValidAdvanceProcess=true; 
    public Boolean SVMX_ValidAdvanceProcess()
    {
        SVMX_ValidAdvanceProcess=true; 
        if(TerritoryRecLst.size() < 1)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG123()));
            apexMessagesList.add(DispMethods.getTAG123());
        }
        if(TerritoryRecLst.size() > 0)
        {
            List<Id> territoryIds = new List<Id>();
            for(Integer i=0; i < TerritoryRecLst.size(); i++)
            {
                if(TerritoryRecLst[i].SVMXC__Territory__c == null)
                {
                    SVMX_ValidAdvanceProcess=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG145()));
                }
                territoryIds.add(TerritoryRecLst[i].SVMXC__Territory__c);
            }
            
            system.debug('territoryIds ==> '+territoryIds);
            
            List<SVMXC__Territory__c> terrObjs = Database.Query('Select id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Active__c, SVMXC__Territory_s_Business_Hours__r.IsActive From SVMXC__Territory__c s where id in :territoryIds');
            
            system.debug('terrObjs ==> '+terrObjs);
            
            if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP())
            {
                //List<SVMXC__Territory__c> terrObjs = Database.Query('Select id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Active__c, SVMXC__Territory_s_Business_Hours__r.IsActive From SVMXC__Territory__c s where id in :territoryIds');
                for(Integer i=0; i < terrObjs.size(); i++)
                {
                    if(terrObjs[i].SVMXC__Active__c == false)
                    {
                        SVMX_ValidAdvanceProcess = false;
                        TerritoryRecLst[i].SVMXC__Territory__c.addError(DispMethods.getTAG204());
                        apexMessagesList.add(DispMethods.getTAG204());
                    }
                    else if(terrObjs[i].SVMXC__Territory_s_Business_Hours__c == null)
                    {
                        SVMX_ValidAdvanceProcess = false;
                        TerritoryRecLst[i].SVMXC__Territory__c.addError(DispMethods.getTAG202());
                        //Anush Opt-1784
                        apexMessagesList.add(DispMethods.getTAG202());
                    }
                    else if(!terrObjs[i].SVMXC__Territory_s_Business_Hours__r.IsActive)
                    {
                        SVMX_ValidAdvanceProcess = false;
                        TerritoryRecLst[i].SVMXC__Territory__c.addError(DispMethods.getTAG203());
                        //Anush Opt-1784
                        apexMessagesList.add(DispMethods.getTAG203());
                    }
                }
            }
            
            if(processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch')
            {
                for(Integer i=0; i < terrObjs.size(); i++)
                {
                    if(terrObjs[i].SVMXC__Active__c == false)
                    {
                        SVMX_ValidAdvanceProcess = false;
                        TerritoryRecLst[i].SVMXC__Territory__c.addError(DispMethods.getTAG204());
                        apexMessagesList.add(DispMethods.getTAG204());
                    }
                }   
           }
        }
        if(SVMX_IsValidID(DPEID))
        {
            List<SVMXC__ServiceMax_Processes__c> TRule = Database.Query('Select id, SVMXC__Territory__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c != :DPEID and SVMXC__Process__c != null and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Territory Access\'');
            system.debug('Enter for Exsisting process'+TRule);
            Map<String,String> TRuleMap=new Map<String,String>();
            if(TRule.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c TR : TRule)
                {
                    if(TR.SVMXC__Territory__c != null)
                        TRuleMap.put(String.valueof(TR.SVMXC__Territory__c).substring(0,15),TR.id);
                }       
            }
            if(TerritoryRecLst.size() >  0)
            {
                for(SVMXC__ServiceMax_Processes__c TR1 : TerritoryRecLst)
                {
                    if(TR1.SVMXC__Territory__c != null && TRuleMap.containsKey(String.valueof(TR1.SVMXC__Territory__c).substring(0,15)))
                    {    
                        SVMX_ValidAdvanceProcess=false;
                        TR1.SVMXC__Territory__c.addError(DispMethods.getTAG146());
                        //Anush Opt-1784
                        apexMessagesList.add(DispMethods.getTAG146());

                    }
                }       
            }
        }
        if(!SVMX_IsValidID(DPEID))
        {
            List<SVMXC__ServiceMax_Processes__c> TRule=Database.query('Select id, SVMXC__Territory__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c != null and RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Territory Access\'');
            
            system.debug('Enter for New process'+TRule);
            Map<String,String> TRuleMap=new Map<String,String>();
            if(TRule.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c TR : TRule)
                {
                    if(TR.SVMXC__Territory__c != null)
                        TRuleMap.put(String.valueof(TR.SVMXC__Territory__c).substring(0,15),TR.id);
                }       
            }
            if(TerritoryRecLst.size() >  0)
            {
                for(SVMXC__ServiceMax_Processes__c TR1 : TerritoryRecLst)
                {
                    if(TR1.SVMXC__Territory__c != null && TRuleMap.containsKey(String.valueof(TR1.SVMXC__Territory__c).substring(0,15)))
                    {    
                        SVMX_ValidAdvanceProcess=false;
                        TR1.SVMXC__Territory__c.addError(DispMethods.getTAG146());
                        //Anush Opt-1784
                        apexMessagesList.add(DispMethods.getTAG146());
                    }
                }       
            }
        }        
        if(WeightTimeWindow == null ||  WeightTimeWindow > 100) 
        {
            SVMX_ValidAdvanceProcess=false;
            processobj.SVMXC__Weight_Time_Window__c.AddError(DispMethods.getTAG134());
        }
        if(WeightTotalDistance == null || WeightTotalDistance > 100)
        {
            SVMX_ValidAdvanceProcess=false;
            processobj.SVMXC__Weight_Total_Distance__c.AddError(DispMethods.getTAG135());
        }
        if(WeightRouteDistance == null || WeightRouteDistance > 100)
        {
            SVMX_ValidAdvanceProcess=false;
            processobj.SVMXC__Weight_Route_Distance__c.AddError(DispMethods.getTAG136());
        }
        if( WeightRouteTime == null ||  WeightRouteTime > 100)
        {
            SVMX_ValidAdvanceProcess=false;
            processobj.SVMXC__Weight_Route_Time__c.AddError(DispMethods.getTAG137());
        }
        if(WeightNodeType == null || WeightNodeType > 100)
        {
            SVMX_ValidAdvanceProcess=false;
            processobj.SVMXC__Weight_Node_Type__c.AddError(DispMethods.getTAG138());
        }
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && processobj.SVMXC__Optimization_Goal__c == null) {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select the dispatch goal in Cost Factors tab'));
            apexMessagesList.add('Please select the Dispatch Goal in Cost Factors tab');
        }
        // Total weight of the cost factors should be either 0 or 100
        if((processobj.SVMXC__Optimization_Goal__c != null && processobj.SVMXC__Optimization_Goal__c.equals('Custom'))&&!((WeightTimeWindow + WeightTotalDistance + WeightRouteDistance + WeightRouteTime + WeightNodeType) == 100 || (WeightTimeWindow + WeightTotalDistance + WeightRouteDistance + WeightRouteTime + WeightNodeType) == 0)){
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, DispMethods.getTAG210()));
            apexMessagesList.add(DispMethods.getTAG210());
        }
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && processobj.SVMXC__Runs_Every_Monday__c == false && processobj.SVMXC__Runs_Every_Tuesday__c == false && processobj.SVMXC__Runs_Every_Wednesday__c == false && processobj.SVMXC__Runs_Every_Thursday__c == false && processobj.SVMXC__Runs_Every_Friday__c == false && processobj.SVMXC__Runs_Every_Saturday__c == false && processobj.SVMXC__Runs_Every_Sunday__c == false)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG112()));
            apexMessagesList.add(DispMethods.getTAG112());
        }
        if(processobj.SVMXC__Start_Time__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG142()));
            apexMessagesList.add(DispMethods.getTAG142());
        }
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && 
                processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && processobj.SVMXC__Start_Date__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG143()));
            apexMessagesList.add(DispMethods.getTAG143());
        }
        if(!SVMX_IsValidID(DPEID))
        {
            if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && 
                processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && processobj.SVMXC__Start_Date__c < system.now().dateGMT())
            {
                SVMX_ValidAdvanceProcess=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG144()));
                apexMessagesList.add(DispMethods.getTAG144());
            }
        }  
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && 
                processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && processobj.SVMXC__End_Date__c != null && processobj.SVMXC__End_Date__c <= processobj.SVMXC__Start_Date__c)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, DispMethods.getTAG114()));
            apexMessagesList.add(DispMethods.getTAG114());
        }
        if(processobj.SVMXC__Email_On_Success__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG115()));
            apexMessagesList.add(DispMethods.getTAG115());
        }
        if(processobj.SVMXC__Email_On_Error__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG116()));
            apexMessagesList.add(DispMethods.getTAG116());
        }
        /** Validation for the Scheduling run intervals **/
        String isValidRuns = ValidateScheduleRuns();
        if(isValidRuns == 'duplicate')
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG173()));
            apexMessagesList.add(DispMethods.getTAG173());
        }
        else if(isValidRuns == 'between')
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG176()));
            apexMessagesList.add(DispMethods.getTAG176());
        }
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && 
                processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && !(integer.valueOf(strStartAftrFul) > 0) && processobj.SVMXC__Full_Run_Unit__c == 'Hours')
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG175()));  
            apexMessagesList.add(DispMethods.getTAG175());
        }
        /*if(!(integer.valueOf(strStartAftrInc) > 0))  
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG175())); 
            apexMessagesList.add(DispMethods.getTAG175());
        }*/
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && 
                processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && !(Disp_Schedule.size() > 0))
        {            
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG177()));
            apexMessagesList.add(DispMethods.getTAG177());
        }
        
        if(Disp_Schedule.size() > 0)
        {
            Integer isNonActiveCount = 0;
            for(RunInformation run : Disp_Schedule)
            {//checking if all the schedules of the current dispatch process are inactive.
                if(!run.getIsActive()) {
                    isNonActiveCount++;
                }
            }
            System.debug('Inside SVMX_ValidAdvanceProcess: Disp_Schedule.size() - ' + Disp_Schedule.size());
            System.debug('Inside SVMX_ValidAdvanceProcess: isNonActiveCount - ' + isNonActiveCount);
            
            if(isNonActiveCount == Disp_Schedule.size()) {
                SVMX_ValidAdvanceProcess=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG194()));
                apexMessagesList.add(DispMethods.getTAG194());
            }
        }
        
        if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && processobj.SVMXC__Full_Run_Unit__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG163())); 
            apexMessagesList.add(DispMethods.getTAG163());
        }
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() && processobj.SVMXC__Dispatch_Threshold__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG199()));
            apexMessagesList.add(DispMethods.getTAG199());
        }
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() && processobj.SVMXC__Dispatch_Threshold__c != null)
        {
            Integer dispatchThreshold = Integer.valueOf(processobj.SVMXC__Dispatch_Threshold__c);
            Integer planningTimeHorizon = Integer.valueOf(strScheduleDays) * 24 * 60;
            if(dispatchThreshold >= planningTimeHorizon) {
                SVMX_ValidAdvanceProcess=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG200()));
                apexMessagesList.add(DispMethods.getTAG200());
            }
        }
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() && processobj.SVMXC__Optimizer_Sync_Interval__c == null)
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG201()));
            apexMessagesList.add(DispMethods.getTAG201());
        }
        /** Start: added for LTP **/
        /*if(processobj.SVMXC__Dispatch_Method__c != DispMethods.getEcoDP() && processobj.SVMXC__Dispatch_Method__c != DispMethods.getlongTermPlannerDP() && String.isNotEmpty(strStartAftrFul) && !(integer.valueOf(strStartAftrFul) > 0))  
        {
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG175())); 
            apexMessagesList.add(DispMethods.getTAG175());
        }*/
        
        if((processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() || processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch') 
                        && enableLTPCheckbox && String.isNotEmpty(strLTPScheduleDays) && !(integer.valueOf(strLTPScheduleDays) > 0)) {
            
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, 'Scheduling Horizon should be greater than zero')); 
            apexMessagesList.add('Scheduling Horizon should be greater than zero');
        }
        
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getlongTermPlannerDP() && String.isNotEmpty(strLTPScheduleDays) && !(integer.valueOf(strLTPScheduleDays) > 0)) {
            
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, 'Scheduling Horizon should be greater than zero')); 
            apexMessagesList.add('Scheduling Horizon should be greater than zero');
        }
        
        if(processobj.SVMXC__Dispatch_Method__c == DispMethods.getlongTermPlannerDP() && String.isNotEmpty(strLTPStartAftrFull) && !(integer.valueOf(strLTPStartAftrFull) > 0)) {
            
            SVMX_ValidAdvanceProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, DispMethods.getTAG175())); 
            apexMessagesList.add(DispMethods.getTAG175());
        }
        /** End: added for LTP **/
        System.debug(Logginglevel.INFO,'End of method SVMX_ValidAdvanceProcess() '+SVMX_ValidAdvanceProcess);
        /**End of validation for the run intervals**/
        return SVMX_ValidAdvanceProcess;
    }
    public pagereference SVMX_FinalSave()
    {
        HdrMsg=false;
        DontProcess=false; 
        CallFromFinalSave = true;
        //apexMessagesList = new List<ApexPages.Message>();
        try
        {
            if(DPEId != null && DPEId !='')
            {
                list<SVMXC__SVMX_Jobs__c> lstSvmxJobs = [Select Id, SVMXC__Start_Time__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :DPEID and (SVMXC__OptiMax_Message__c = 'In Progress' OR SVMXC__OptiMax_Message__c = 'Initiated')];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSvmxJobs != null && lstSvmxJobs.size() > 0)
                {
                    HdrMsg=true;
                    //msgFreqGr1 = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.WORD014_TAG039));
                    apexMessagesList.add(System.Label.WORD014_TAG039);
                    System.debug('msgFreqGr1: '+msgFreqGr1);
                    return null;
                }

            }
            Savepoint sp=Database.setSavepoint();
            system.debug('deleteTerritoryLst'+deleteTerritoryLst);
            if(deleteTerritoryLst.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete deleteTerritoryLst;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    apexMessagesList.add(System.label.COMM001_TAG142);
                }
            }
            if(SVMX_ValidAdvanceProcess() == true && SVMX_SaveDP() == true)
            {
                System.debug('Entered the save process'); 
                string IncrementalExpressionErr = IncrementRunExpressions.getCriteria('SVMXC__Service_Order__c');
                if(IncrementalExpressionErr == 'ERROR')
                {
                    selectedTab=DispMethods.getTAG009();
                    HdrMsg=true;
                    Tab4Msg=false;
                    
                    return null;
                }
                
                /** If LTP schedule information is invalid flag the error **/
                if(enableLTPCheckbox && isvalidLTPSchedule() == false) {
                    system.debug('WORD_SetupDispatchProcess::SVMX_FinalSave(): LTP Scheduling information is invalid.');
                    selectedTab=DispMethods.getlongTermPlannerDP();
                    HdrMsg=true;
                    Tab4Msg=false;
                    
                    return null;
                }
                
                if(ProductExpertise == DispMethods.getTAG043())
                {
                    processobj.SVMXC__Product_Match_Enabled__c=true;
                }  
                else
                {
                    processobj.SVMXC__Product_Match_Enabled__c=false;
                }
                if(ProductExpertise == DispMethods.getTAG048())
                {       
                    processobj.SVMXC__Expertise_Match_Enabled__c=true;
                }  
                else
                {
                    processobj.SVMXC__Expertise_Match_Enabled__c=false;
                }
                               
                if(processobj.SVMXC__Assign_Work_Order_To__c == 'SVMX.None')
                    processobj.SVMXC__Assign_Work_Order_To__c = null;
                
                processobj.SVMXC__Dispatch_Process_Status__c='InComplete';
                processobj.SVMXC__Calendar_Start_Type__c='Next Day';
                processobj.SVMXC__Calendar_End_Type__c='Next Day';
                processobj.SVMXC__Weight_Time_Window__c=WeightTimeWindow; 
                processobj.SVMXC__Weight_Total_Distance__c=WeightTotalDistance;
                processobj.SVMXC__Weight_Route_Distance__c=WeightRouteDistance; 
                processobj.SVMXC__Weight_Route_Time__c=WeightRouteTime; 
                processobj.SVMXC__Weight_Node_Type__c=WeightNodeType; 
                processobj.Calendar_Start_Days__c = integer.valueOf(strStartAftrFul); 
                processobj.Calendar_End_Days__c = integer.valueOf(strScheduleDays); 
                processobj.Frequency__c = integer.valueOf(strStartAftrInc); 
                
                
                /*if(isMCTMenabled)
                    processobj.SVMXC__Weight_Node_Type__c=WeightNodeType; 
                else
                    processobj.SVMXC__Weight_Node_Type__c = 0;*/
                processobj.SVMXC__Weight_Tech_Eligibility__c=WeightEligibility; 
                processobj.SVMXC__Weight_Skill_Match__c=WeightExpertise; 
                processobj.SVMXC__Weight_Product_Specialization__c=WeightProductSpecilaization; 
                processobj.SVMXC__Weight_Preferred_Technician__c=WeightPreferredTech; 
                //first save the Dispatch process b'coz we need dispatch process ID as a reference for other data.
                if(processobj != null)
                {
                    if(processobj.RecordTypeId == null)
                    {
                        processobj.RecordTypeId=DispatchProRecordTypeId;
                    }     
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( processobj, COMM_SecurityUtils.Access.Upsertable) ) {   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert processobj;  
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                //now if its final save is called then we also have to save the dispatch process criteria 
                string DPCriExpressionsErr=DPCriExpressions.getCriteria('SVMXC__Service_Order__c');
                if(DPCriExpressionsErr != 'ERROR')
                {
                    map<string, string> mapProperties=new map<string, string>(); 
                    mapProperties.put('RecordTypeID', ExpressionRTypeId);
                    mapProperties.put('SVMXC__Expression_Type__c', 'DISP_Process_Entry');
                    mapProperties.put('SVMXC__Expression_Rule__c', Processobj.Id);
                    DPCriExpressions.getExpressions(mapProperties);
                }
                else 
                    selectedTab=DispMethods.getTAG003();
                    
                /** Start: Save the LTP criteria expressions **/
                /** Save the LTP section when checkBox is enabled **/
                if(enableLTPCheckbox) {
                    string ltpCriExpressionsErr = longTermPlanningRunExpressions.getCriteria('SVMXC__Service_Order__c');
                    if(ltpCriExpressionsErr != 'ERROR')
                    {
                        map<string, string> mapProperties=new map<string, string>(); 
                        mapProperties.put('RecordTypeID', ExpressionRTypeId);
                        mapProperties.put('SVMXC__Expression_Type__c', 'DISP_Schedule_Exp');
                        mapProperties.put('SVMXC__Expression_Rule__c', Processobj.Id);
                        longTermPlanningRunExpressions.getExpressions(mapProperties);
                        
                        /** Validating the LTP criteria expression **/
                        Boolean isExpValid = validateAdvanceExpression(longTermPlanningRunExpressions);
                        if(!isExpValid) {
                            system.debug('WORD_SetupDispatchProcess::SVMX_FinalSave(): LTP advanced expression is invalid.');
                            selectedTab=DispMethods.getlongTermPlannerDP();
                            HdrMsg=true;
                            Tab4Msg=false;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, 'Advanced Expression is Invalid'));
                            apexMessagesList.add('Advanced Expression is Invalid');
                            return null;
                        }
                        
                        processobj.SVMXC__Default_Value__c = longTermPlanningRunExpressions.AdvanceOption;
                        processobj.SVMXC__Child_Object_Criteria__c = ltpCriExpressionsErr;
                        //save the LTP scheduling information
                        //saveLTPSchedule();
                        processobj.SVMXC__Confirmation_Message__c = strSelectedTimeZone;    //storing timezone information in this field. Using the existing field
                        processobj.SVMXC__Window_Height__c = Integer.valueOf(strScheduleDays);  //copying the horizonDays from Batch Schedule and storing as startDay in LTP
                        processobj.SVMXC__Window_Width__c = Integer.valueOf(strLTPScheduleDays);
                        processobj.SVMXC__Default_On__c = enableLTPCheckbox;        //Using the existing field instead of introducing one
                        
                        /** Save the LTP scheduling information **/
                        saveLTPSchedule();
                    }
                    else {
                        selectedTab=DispMethods.getTAG003();
                    }
                } else {
                    processobj.SVMXC__Default_On__c = enableLTPCheckbox;    //save the status of checkBox in process object.
                }
                
                /** End: Save the LTP criteria expressions **/
                
                /** Naveen:  giving inputs from scheduling tab **/
                //processobj.SVMXC__Frequency__c =  
                /** End of inputs for scheduling tab**/
                System.debug('Upserting the process object.');
                /** Naveen: storing the schedule information in the config data object **/
                //deleted the old data and store the new data
                if(DelRunInformation.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') ) {    //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete DelRunInformation;   
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                List<SVMXC__ServiceMax_Config_Data__c> currentRunLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                
                Integer isNonActiveCount = 0;
                for(RunInformation run : Disp_Schedule)
                {
                    SVMXC__ServiceMax_Config_Data__c currentRun = new SVMXC__ServiceMax_Config_Data__c();
                    //currentRun.SVMXC__Display_Type__c = run.getRunType();
                    currentRun.SVMXC__Display_Type__c = 'Full';
                    currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
                    currentRun.SVMXC__Expression_Rule__c = processobj.id;
                    currentRun.RecordTypeID = ExpressionRTypeId;
                    currentRun.SVMXC__Run_At__c = run.getRunAt();
                    currentRun.SVMXC__Active__c = run.getIsActive();
                    currentRunLst.add(currentRun);                    
                }
                System.debug('Upserting the run list.');
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( currentRunLst, COMM_SecurityUtils.Access.Upsertable) ) {    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert currentRunLst;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    apexMessagesList.add(System.label.COMM001_TAG142);
                }
                /**End of storing schedule information**/
                
                for(Integer i=0;i<TerritoryRecLst.size();i++)
                {
                    TerritoryRecLst[i].SVMXC__Process__c=processobj.id;
                    TerritoryRecLst[i].RecordTypeId=RuleRecordTypeId;
                    TerritoryRecLst[i].SVMXC__Rule_Type__c='Territory Access';
                    SaveTerritoryLst.add(TerritoryRecLst[i]);
                }
                System.debug('Upserting the teritory list.');
                if(SaveTerritoryLst.size() > 0)
                {  
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveTerritoryLst, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SaveTerritoryLst;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }     
                List<SVMXC__ServiceMax_Processes__c> SavePr=new List<SVMXC__ServiceMax_Processes__c>();
                for(Integer i=0;i<Priortization.size();i++)
                {
                    if(Priortization[i].Id == null || Priortization[i].SVMXC__Process__c == null)
                    {
                        Priortization[i].SVMXC__Process__c=processobj.id;
                        Priortization[i].RecordTypeId=RuleRecordTypeId;
                        Priortization[i].SVMXC__Rule_Type__c='Priortization';
                        SavePr.add(Priortization[i]);
                    }
                }
                System.debug('Inserting the prioritization.');
                if(SavePr.size() > 0)
                {
                    // insert SavePr;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SavePr, COMM_SecurityUtils.Access.Upsertable) ) {   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SavePr;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                //string IncrementalExpressionErr = IncrementRunExpressions.getCriteria('SVMXC__Service_Order__c');
                /*Naveen:  scheduling tab : saving incremetal run expression*/
                //if there is no incremental schedule then there is no need of storing the expression
                /* Boolean isIncrExists = false;
                for(RunInformation runInfo : Disp_Schedule)
                {
                if(runInfo.getRunType() == DispMethods.getTAG170())
                {
                isIncrExists = true;
                break;
                }
                } 
                system.debug('amar'+IncrementalExpressionErr+isIncrExists);*/
                //commented the below code as incremental run is not in use
                /*map<string, string> mapPropertiesForIncreRun = new map<string, string>();
                //if(isIncrExists)//IncrementalExpressionErr != 'ERROR'
                if(IncrementalExpressionErr != 'ERROR')
                {
                    if(IncrementalExpressionErr.length() > 0)
                    {
                        IncrementalExpressionErr = IncrementalExpressionErr.toUpperCase().replace('SVMX.CURRENTUSER',  UserInfo.getUserId() );
                        IncrementalExpressionErr = IncrementalExpressionErr.toUpperCase().replace('SVMX.OWNER',  UserInfo.getUserId() );
                        IncrementalExpressionErr = IncrementalExpressionErr.replace('SVMX.Now', 'TODAY');
                        IncrementalExpressionErr = IncrementalExpressionErr.replace('SVMX.now', 'TODAY');
                        IncrementalExpressionErr = IncrementalExpressionErr.replace('SVMX.NOW', 'TODAY');
                    }
                    processobj.SVMXC__Child_Object_Criteria__c = IncrementalExpressionErr;        
                    system.debug('Advance Option'+IncrementRunExpressions.AdvanceOption);        
                    processobj.SVMXC__Default_Value__c = IncrementRunExpressions.AdvanceOption;
                    mapPropertiesForIncreRun.put('RecordTypeID', ExpressionRTypeId);
                    mapPropertiesForIncreRun.put('SVMXC__Expression_Type__c', 'DISP_Schedule_Exp');
                    mapPropertiesForIncreRun.put('SVMXC__Expression_Rule__c', Processobj.Id);              
                }
                IncrementRunExpressions.getExpressions(mapPropertiesForIncreRun);*/
                /*End of saving incremental expression*/
                
                
                // Start Capacity Limitation
                List<SVMXC__ServiceMax_Processes__c> SaveCapLim=new List<SVMXC__ServiceMax_Processes__c>();
                //system.debug('Final Save CapacityLimitationsCriExpressions11111111  == : '+CapacityLimitationsCriExpressions+'\n');
                for(Integer i=0;i<CapacityLimitations.size();i++)
                {
                    //system.debug('Final Save CapacityLimitations[i].Id  == : '+CapacityLimitations[i].Id+'\n');
                    if(CapacityLimitations[i].Id == null || CapacityLimitations[i].SVMXC__Process__c == null)
                    {
                        CapacityLimitations[i].SVMXC__Process__c=processobj.id;
                        CapacityLimitations[i].RecordTypeId=RuleRecordTypeId;
                        CapacityLimitations[i].SVMXC__Rule_Type__c='Capacity Reservation';
                        SaveCapLim.add(CapacityLimitations[i]);
                        
                        /*map<string, string> mapPropertiesCapacityLimitations=new map<string, string>(); 
                        mapPropertiesCapacityLimitations.put('RecordTypeID', ExpressionRTypeId);
                        mapPropertiesCapacityLimitations.put('SVMXC__Expression_Type__c', 'DISP_Capacity_Reservation');
                        mapPropertiesCapacityLimitations.put('SVMXC__Expression_Rule__c', CapacityLimitations[i].Id);
                        CapacityLimitationsCriExpressions.getExpressions(mapPropertiesCapacityLimitations);*/
            
                        //system.debug('Final Save mapPropertiesCapacityLimitations  == : '+mapPropertiesCapacityLimitations+'\n');
                        //system.debug('Final Save CapacityLimitationsCriExpressions222222  == : '+CapacityLimitationsCriExpressions+'\n');
                
                    }
                }
                //system.debug('Final Save CapacityLimitationsCriExpressions33333333  == : '+CapacityLimitationsCriExpressions+'\n');
                System.debug('Inserting the Capacity Limitation.');
                if(SaveCapLim.size() > 0)
                {
                    // insert SaveCapLim;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveCapLim, COMM_SecurityUtils.Access.Upsertable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SaveCapLim;  
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                
                // End Capacity Limitation
                
                // at last also upsert the dispatch process b'coz some reference are assigned after insert/update of the process 
                if(processobj != null)
                    upsert processobj;  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                //PageReference Page=new PageReference('/apex/WORD_OptimaxCall?dpid='+processobj.id);
                makeOptimaxCall = true;
            }
            else
            {
                HdrMsg=true;
                Tab4Msg=false;
                makeOptimaxCall = false;
                Database.rollback(sp);
                
            }  
        }
        catch (Exception ex) 
        {
            Tab4Msg=false;
            HdrMsg=true;
            makeOptimaxCall = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            apexMessagesList.add(ex.getMessage());
        } 
        return null;
    }
    
    public PageReference SVMX_ECOFinalSave()
    {
        HdrMsg=false;
        DontProcess=false; 
        CallFromFinalSave = true;
        //apexMessagesList = new List<ApexPages.Message>();
        try
        {
            System.debug(Logginglevel.INFO,'DPEId '+DPEId); 
            if(DPEId != null && DPEId !='')
            {
                list<SVMXC__SVMX_Jobs__c> lstSvmxJobs = [Select Id, SVMXC__Start_Time__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :DPEID and (SVMXC__OptiMax_Message__c = 'In Progress' OR SVMXC__OptiMax_Message__c = 'Initiated')];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSvmxJobs != null && lstSvmxJobs.size() > 0)
                {
                    HdrMsg=true;
                    //msgFreqGr1 = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.WORD014_TAG039));
                    apexMessagesList.add(System.Label.WORD014_TAG039);
                    System.debug('msgFreqGr1: '+msgFreqGr1);
                    return null;
                }

            }
            Savepoint sp=Database.setSavepoint();
            system.debug('deleteTerritoryLst'+deleteTerritoryLst);
            if(deleteTerritoryLst.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete deleteTerritoryLst;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    apexMessagesList.add(System.label.COMM001_TAG142);
                }
            }
            if(SVMX_ValidAdvanceProcess() == true && SVMX_SaveDP() == true)
            {
                System.debug(Logginglevel.INFO,'Entered the ECO save process'); 
                string IncrementalExpressionErr = IncrementRunExpressions.getCriteria('SVMXC__Service_Order__c');
                if(IncrementalExpressionErr == 'ERROR')
                {
                    selectedTab=DispMethods.getTAG009();
                    HdrMsg=true;
                    Tab4Msg=false;
                    
                    return null;
                }
                
                /** If LTP schedule information is invalid flag the error **/
                if(enableLTPCheckbox && isvalidLTPSchedule() == false) {
                    system.debug('WORD_SetupDispatchProcess::SVMX_ECOFinalSave(): LTP Scheduling information is invalid.');
                    selectedTab=DispMethods.getlongTermPlannerDP();
                    HdrMsg=true;
                    Tab4Msg=false;
                    
                    return null;
                }
                
                if(ProductExpertise == DispMethods.getTAG043())
                {
                    processobj.SVMXC__Product_Match_Enabled__c=true;
                }  
                else
                {
                    processobj.SVMXC__Product_Match_Enabled__c=false;
                }
                if(ProductExpertise == DispMethods.getTAG048())
                {       
                    processobj.SVMXC__Expertise_Match_Enabled__c=true;
                }  
                else
                {
                    processobj.SVMXC__Expertise_Match_Enabled__c=false;
                }
                                
                if(processobj.SVMXC__Assign_Work_Order_To__c == 'SVMX.None')
                    processobj.SVMXC__Assign_Work_Order_To__c = null;
                
                processobj.SVMXC__Dispatch_Process_Status__c='InComplete';
                processobj.SVMXC__Calendar_Start_Type__c='Next Day';
                processobj.SVMXC__Calendar_End_Type__c='Next Day';
                processobj.SVMXC__Weight_Time_Window__c=WeightTimeWindow; 
                processobj.SVMXC__Weight_Total_Distance__c=WeightTotalDistance;
                processobj.SVMXC__Weight_Route_Distance__c=WeightRouteDistance; 
                processobj.SVMXC__Weight_Route_Time__c=WeightRouteTime; 
                processobj.SVMXC__Weight_Node_Type__c=WeightNodeType; 
                processobj.Calendar_Start_Days__c = integer.valueOf(strStartAftrFul); 
                processobj.Calendar_End_Days__c = integer.valueOf(strScheduleDays); 
                processobj.Frequency__c = integer.valueOf(strStartAftrInc); 
                
                
                /*if(isMCTMenabled)
                    processobj.SVMXC__Weight_Node_Type__c=WeightNodeType; 
                else
                    processobj.SVMXC__Weight_Node_Type__c = 0;*/ 
                processobj.SVMXC__Weight_Tech_Eligibility__c=WeightEligibility; 
                processobj.SVMXC__Weight_Skill_Match__c=WeightExpertise; 
                processobj.SVMXC__Weight_Product_Specialization__c=WeightProductSpecilaization; 
                processobj.SVMXC__Weight_Preferred_Technician__c=WeightPreferredTech; 
                //first save the Dispatch process b'coz we need dispatch process ID as a reference for other data.
                if(processobj != null)
                {
                    if(processobj.RecordTypeId == null)
                    {
                        processobj.RecordTypeId=DispatchProRecordTypeId;
                    }     
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveTerritoryLst, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert processobj;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                //now if its final save is called then we also have to save the dispatch process criteria 
                string DPCriExpressionsErr=DPCriExpressions.getCriteria('SVMXC__Service_Order__c');
                if(DPCriExpressionsErr != 'ERROR')
                {
                    map<string, string> mapProperties=new map<string, string>(); 
                    mapProperties.put('RecordTypeID', ExpressionRTypeId);
                    mapProperties.put('SVMXC__Expression_Type__c', 'DISP_Process_Entry');
                    mapProperties.put('SVMXC__Expression_Rule__c', Processobj.Id);
                    DPCriExpressions.getExpressions(mapProperties);
                }
                else 
                    selectedTab=DispMethods.getTAG003();
                    
                /** Start: Save the LTP criteria expressions **/
                /** Save the LTP section when checkBox is enabled **/
                if(enableLTPCheckbox) {
                    string ltpCriExpressionsErr = longTermPlanningRunExpressions.getCriteria('SVMXC__Service_Order__c');
                    if(ltpCriExpressionsErr != 'ERROR')
                    {
                        map<string, string> mapProperties=new map<string, string>(); 
                        mapProperties.put('RecordTypeID', ExpressionRTypeId);
                        mapProperties.put('SVMXC__Expression_Type__c', 'DISP_Schedule_Exp');
                        mapProperties.put('SVMXC__Expression_Rule__c', Processobj.Id);
                        longTermPlanningRunExpressions.getExpressions(mapProperties);
                        
                        /** Validating the LTP criteria expression **/
                        Boolean isExpValid = validateAdvanceExpression(longTermPlanningRunExpressions);
                        if(!isExpValid) {
                            system.debug('WORD_SetupDispatchProcess::SVMX_FinalSave(): LTP advanced expression is invalid.');
                            selectedTab=DispMethods.getlongTermPlannerDP();
                            HdrMsg=true;
                            Tab4Msg=false;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, 'Please provide the correct advanced expression'));
                            return null;
                        }
                        
                        processobj.SVMXC__Default_Value__c = longTermPlanningRunExpressions.AdvanceOption;
                        processobj.SVMXC__Child_Object_Criteria__c = ltpCriExpressionsErr;
                        //save the LTP scheduling information
                        //saveLTPSchedule();
                        processobj.SVMXC__Confirmation_Message__c = strSelectedTimeZone;    //storing timezone information in this field. Using the existing field
                        processobj.SVMXC__Window_Height__c = Integer.valueOf(strScheduleDays);  //copying the horizonDays from ECO Schedule and storing as startDay in LTP
                        processobj.SVMXC__Window_Width__c = Integer.valueOf(strLTPScheduleDays);
                        processobj.SVMXC__Default_On__c = enableLTPCheckbox;        //Using the existing field instead of introducing one
                        
                        /** Save the LTP scheduling information **/
                        saveLTPSchedule();
                    }
                    else {
                        selectedTab=DispMethods.getTAG003();
                    }
                } else {
                    processobj.SVMXC__Default_On__c = enableLTPCheckbox;    //save the status of checkBox in process object.
                }
                
                /** End: Save the LTP criteria expressions **/
                
                /** Naveen:  giving inputs from scheduling tab **/
                //processobj.SVMXC__Frequency__c =  
                /** End of inputs for scheduling tab**/
                // System.debug(LoggingLevel.INFO,'Upserting the process object.');
                /** Naveen: storing the schedule information in the config data object **/
                //deleted the old data and store the new data
                /* if(DelRunInformation.size() > 0)
                {
                    delete DelRunInformation;
                }
                List<SVMXC__ServiceMax_Config_Data__c> currentRunLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                
                Integer isNonActiveCount = 0;
                for(RunInformation run : Disp_Schedule)
                {
                    SVMXC__ServiceMax_Config_Data__c currentRun = new SVMXC__ServiceMax_Config_Data__c();
                    currentRun.SVMXC__Display_Type__c = run.getRunType();
                    currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
                    currentRun.SVMXC__Expression_Rule__c = processobj.id;
                    currentRun.RecordTypeID = ExpressionRTypeId;
                    currentRun.SVMXC__Run_At__c = run.getRunAt();
                    currentRun.SVMXC__Active__c = run.getIsActive();
                    currentRunLst.add(currentRun);
                }
                System.debug('Upserting the run list.');
                upsert currentRunLst; */
                /**End of storing schedule information**/
                
                for(Integer i=0;i<TerritoryRecLst.size();i++)
                {
                    TerritoryRecLst[i].SVMXC__Process__c=processobj.id;
                    TerritoryRecLst[i].RecordTypeId=RuleRecordTypeId;
                    TerritoryRecLst[i].SVMXC__Rule_Type__c='Territory Access';
                    SaveTerritoryLst.add(TerritoryRecLst[i]);
                }
                System.debug('Upserting the teritory list.');
                if(SaveTerritoryLst.size() > 0)
                {  
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveTerritoryLst, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SaveTerritoryLst;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }     
                List<SVMXC__ServiceMax_Processes__c> SavePr=new List<SVMXC__ServiceMax_Processes__c>();
                for(Integer i=0;i<Priortization.size();i++)
                {
                    if(Priortization[i].Id == null || Priortization[i].SVMXC__Process__c == null)
                    {
                        Priortization[i].SVMXC__Process__c=processobj.id;
                        Priortization[i].RecordTypeId=RuleRecordTypeId;
                        Priortization[i].SVMXC__Rule_Type__c='Priortization';
                        SavePr.add(Priortization[i]);
                    }
                }
                System.debug('Inserting the prioritization.');
                if(SavePr.size() > 0)
                {
                    // insert SavePr;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SavePr, COMM_SecurityUtils.Access.Upsertable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SavePr;  
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                //string IncrementalExpressionErr = IncrementRunExpressions.getCriteria('SVMXC__Service_Order__c');
                /*Naveen:  scheduling tab : saving incremetal run expression*/
                //if there is no incremental schedule then there is no need of storing the expression
                /* Boolean isIncrExists = false;
                for(RunInformation runInfo : Disp_Schedule)
                {
                if(runInfo.getRunType() == DispMethods.getTAG170())
                {
                isIncrExists = true;
                break;
                }
                } 
                system.debug('amar'+IncrementalExpressionErr+isIncrExists); */
                // map<string, string> mapPropertiesForIncreRun = new map<string, string>();
                //if(isIncrExists)//IncrementalExpressionErr != 'ERROR'
                /* if(IncrementalExpressionErr != 'ERROR')
                {
                    if(IncrementalExpressionErr.length() > 0)
                    {
                        IncrementalExpressionErr = IncrementalExpressionErr.toUpperCase().replace('SVMX.CURRENTUSER',  UserInfo.getUserId() );
                        IncrementalExpressionErr = IncrementalExpressionErr.toUpperCase().replace('SVMX.OWNER',  UserInfo.getUserId() );
                        IncrementalExpressionErr = IncrementalExpressionErr.replace('SVMX.Now', 'TODAY');
                        IncrementalExpressionErr = IncrementalExpressionErr.replace('SVMX.now', 'TODAY');
                        IncrementalExpressionErr = IncrementalExpressionErr.replace('SVMX.NOW', 'TODAY');
                    }
                    processobj.SVMXC__Child_Object_Criteria__c = IncrementalExpressionErr;        
                    system.debug('Advance Option'+IncrementRunExpressions.AdvanceOption);        
                    processobj.SVMXC__Default_Value__c = IncrementRunExpressions.AdvanceOption;
                    mapPropertiesForIncreRun.put('RecordTypeID', ExpressionRTypeId);
                    mapPropertiesForIncreRun.put('SVMXC__Expression_Type__c', 'DISP_Schedule_Exp');
                    mapPropertiesForIncreRun.put('SVMXC__Expression_Rule__c', Processobj.Id);              
                }
                IncrementRunExpressions.getExpressions(mapPropertiesForIncreRun); */
                /*End of saving incremental expression*/
                // at last also upsert the dispatch process b'coz some reference are assigned after insert/update of the process 
                if(processobj != null)
                    upsert processobj;
                System.debug(Logginglevel.INFO, 'processobj in the end of making call next page  '+processobj);
                //PageReference Page=new PageReference('/apex/WORD_OptimaxCall?dpid='+processobj.id);
                makeOptimaxCall = true;
            }
            else
            {
                HdrMsg=true;
                Tab4Msg=false;
                makeOptimaxCall = false;
                Database.rollback(sp);
                
            }  
        }
        catch (Exception ex) 
        {
            Tab4Msg=false;
            HdrMsg=true;
            makeOptimaxCall = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            apexMessagesList.add(ex.getMessage());
        } 
        return null;
    }
    
    public PageReference SVMX_SaveLTP() {
        system.debug('WORD_SetupDispatchProcess::SVMX_SaveLTP(): Inside SVMX_SaveLTP method');
        
        HdrMsg=false;
        DontProcess=false; 
        CallFromFinalSave = true;
        //apexMessagesList = new List<ApexPages.Message>();
        try
        {
            System.debug(Logginglevel.INFO,'DPEId '+DPEId); 
            if(DPEId != null && DPEId !='')
            {
                list<SVMXC__SVMX_Jobs__c> lstSvmxJobs = [Select Id, SVMXC__Start_Time__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :DPEID and (SVMXC__OptiMax_Message__c = 'In Progress' OR SVMXC__OptiMax_Message__c = 'Initiated')];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSvmxJobs != null && lstSvmxJobs.size() > 0)
                {
                    HdrMsg=true;
                    //msgFreqGr1 = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.WORD014_TAG039));
                    apexMessagesList.add(System.Label.WORD014_TAG039);
                    System.debug('msgFreqGr1: '+msgFreqGr1);
                    return null;
                }

            }
            Savepoint sp=Database.setSavepoint();
            system.debug('deleteTerritoryLst'+deleteTerritoryLst);
            if(deleteTerritoryLst.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c') ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete deleteTerritoryLst;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    apexMessagesList.add(System.label.COMM001_TAG142);
                }
            }
            if(SVMX_ValidAdvanceProcess() == true && SVMX_SaveDP() == true)
            {
                /** If LTP schedule information is invalid flag the error **/
                if(isvalidLTPSchedule() == false) {
                    system.debug('WORD_SetupDispatchProcess::SVMX_SaveLTP(): LTP Scheduling information is invalid.');
                    selectedTab=DispMethods.getlongTermPlannerDP();
                    HdrMsg=true;
                    Tab4Msg=false;
                    
                    return null;
                }
                
                System.debug(Logginglevel.INFO,'Entered the LTP save process');
                
                if(ProductExpertise == DispMethods.getTAG043())
                {
                    processobj.SVMXC__Product_Match_Enabled__c=true;
                }  
                else
                {
                    processobj.SVMXC__Product_Match_Enabled__c=false;
                }
                if(ProductExpertise == DispMethods.getTAG048())
                {       
                    processobj.SVMXC__Expertise_Match_Enabled__c=true;
                }  
                else
                {
                    processobj.SVMXC__Expertise_Match_Enabled__c=false;
                }
                                
                if(processobj.SVMXC__Assign_Work_Order_To__c == 'SVMX.None')
                    processobj.SVMXC__Assign_Work_Order_To__c = null;
                
                processobj.SVMXC__Dispatch_Process_Status__c='InComplete';
                processobj.SVMXC__Calendar_Start_Type__c='Next Day';
                processobj.SVMXC__Calendar_End_Type__c='Next Day';
                processobj.SVMXC__Weight_Time_Window__c=WeightTimeWindow; 
                processobj.SVMXC__Weight_Total_Distance__c=WeightTotalDistance;
                processobj.SVMXC__Weight_Route_Distance__c=WeightRouteDistance; 
                processobj.SVMXC__Weight_Route_Time__c=WeightRouteTime; 
                processobj.SVMXC__Weight_Node_Type__c=WeightNodeType;
                
                
                /** Start: storing the LTP information in the Process Obj **/
                
                processobj.SVMXC__Window_Height__c = Integer.valueOf(strLTPStartAftrFull);
                processobj.SVMXC__Window_Width__c = Integer.valueOf(strLTPScheduleDays);
                processobj.SVMXC__Confirmation_Message__c = strSelectedTimeZone;
                
                /** End: storing the LTP information in the Process Obj **/
                
                /*processobj.Calendar_Start_Days__c = integer.valueOf(strStartAftrFul); 
                processobj.Calendar_End_Days__c = integer.valueOf(strScheduleDays); 
                processobj.Frequency__c = integer.valueOf(strStartAftrInc); */
                
                
                /*if(isMCTMenabled)
                    processobj.SVMXC__Weight_Node_Type__c=WeightNodeType; 
                else
                    processobj.SVMXC__Weight_Node_Type__c = 0;*/ 
                processobj.SVMXC__Weight_Tech_Eligibility__c=WeightEligibility; 
                processobj.SVMXC__Weight_Skill_Match__c=WeightExpertise; 
                processobj.SVMXC__Weight_Product_Specialization__c=WeightProductSpecilaization; 
                processobj.SVMXC__Weight_Preferred_Technician__c=WeightPreferredTech; 
                //first save the Dispatch process b'coz we need dispatch process ID as a reference for other data.
                if(processobj != null)
                {
                    if(processobj.RecordTypeId == null)
                    {
                        processobj.RecordTypeId=DispatchProRecordTypeId;
                    }     
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveTerritoryLst, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert processobj;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                //now if its final save is called then we also have to save the dispatch process criteria 
                string DPCriExpressionsErr=DPCriExpressions.getCriteria('SVMXC__Service_Order__c');
                if(DPCriExpressionsErr != 'ERROR')
                {
                    map<string, string> mapProperties=new map<string, string>(); 
                    mapProperties.put('RecordTypeID', ExpressionRTypeId);
                    mapProperties.put('SVMXC__Expression_Type__c', 'DISP_Process_Entry');
                    mapProperties.put('SVMXC__Expression_Rule__c', Processobj.Id);
                    DPCriExpressions.getExpressions(mapProperties);
                }
                else 
                    selectedTab=DispMethods.getTAG003();
                
                for(Integer i=0;i<TerritoryRecLst.size();i++)
                {
                    TerritoryRecLst[i].SVMXC__Process__c=processobj.id;
                    TerritoryRecLst[i].RecordTypeId=RuleRecordTypeId;
                    TerritoryRecLst[i].SVMXC__Rule_Type__c='Territory Access';
                    SaveTerritoryLst.add(TerritoryRecLst[i]);
                }
                System.debug('Upserting the teritory list.');
                if(SaveTerritoryLst.size() > 0)
                {  
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveTerritoryLst, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SaveTerritoryLst;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }     
                List<SVMXC__ServiceMax_Processes__c> SavePr=new List<SVMXC__ServiceMax_Processes__c>();
                for(Integer i=0;i<Priortization.size();i++)
                {
                    if(Priortization[i].Id == null || Priortization[i].SVMXC__Process__c == null)
                    {
                        Priortization[i].SVMXC__Process__c=processobj.id;
                        Priortization[i].RecordTypeId=RuleRecordTypeId;
                        Priortization[i].SVMXC__Rule_Type__c='Priortization';
                        SavePr.add(Priortization[i]);
                    }
                }
                System.debug('Inserting the prioritization.');
                if(SavePr.size() > 0)
                {
                    // insert SavePr;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SavePr, COMM_SecurityUtils.Access.Upsertable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert SavePr;  
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        apexMessagesList.add(System.label.COMM001_TAG142);
                    }
                }
                
                /** Save the LTP scheduling information as the Dispatch Process is saved above and this DP ID is required to link the LTP schedule**/
                saveLTPSchedule();
                
                // at last also upsert the dispatch process b'coz some reference are assigned after insert/update of the process 
                if(processobj != null)
                    upsert processobj;
                System.debug(Logginglevel.INFO, 'processobj in the end of making call next page  '+processobj);
                //PageReference Page=new PageReference('/apex/WORD_OptimaxCall?dpid='+processobj.id);
                makeOptimaxCall = true;
            }
            else
            {
                HdrMsg=true;
                Tab4Msg=false;
                makeOptimaxCall = false;
                Database.rollback(sp);
                
            }  
        }
        catch (Exception ex) 
        {
            Tab4Msg=false;
            HdrMsg=true;
            makeOptimaxCall = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            apexMessagesList.add(ex.getMessage());
        } 
        
        return null;
    }

    public PageReference optimaxCall() {
        if(makeOptimaxCall){
            ApexPages.currentPage().getParameters().put('dpid', processobj.id);
            ApexPages.currentPage().getParameters().put('runConstructorLogic', 'true');
            
            system.debug('WORD_SetupDispatchProcess:: inside optimaxCall()');
            system.debug('WORD_SetupDispatchProcess::optimaxCall(): ApexPages.currentPage().getParameters().get(\'runConstructorLogic\') - '
                                        + ApexPages.currentPage().getParameters().get('runConstructorLogic'));
            system.debug('WORD_SetupDispatchProcess::optimaxCall(): ApexPages.currentPage().getParameters().get(\'dpid\') - '
                                        + ApexPages.currentPage().getParameters().get('dpid'));
            
            WORD_OptimaxCall optimaxCall = new WORD_OptimaxCall();
            optimaxCall.SVMX_WSDLCall();
            for(integer i=0;i<WORD_SetupDispatchProcess.messagesList.size();i++) {
                system.debug('*******messages********'+WORD_SetupDispatchProcess.messagesList[i].messageType+ ':' +WORD_SetupDispatchProcess.messagesList[i].message);
                if(i==0){
                    messagesString = WORD_SetupDispatchProcess.messagesList[i].messageType+ ':' +WORD_SetupDispatchProcess.messagesList[i].message;
                } else {
                    messagesString = messagesString + 'ENDOFMESSAGE' + WORD_SetupDispatchProcess.messagesList[i].messageType+ ':' +WORD_SetupDispatchProcess.messagesList[i].message;
                }
            }
            PageReference Page=new PageReference('/apex/WORD_OptimaxCall');
            Page.getParameters().put('runConstructorLogic', 'false');
            Page.getParameters().put('messagesString', messagesString);
            Page.setRedirect(true);
            return Page;
        } else {
            if(apexMessagesList.size() > 0){
                for(String msg : apexMessagesList){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,msg ));
                }
                apexMessagesList.clear();
            }
            return null;
        }
        
    }
    
    public pagereference ChangeSliders()
    {
        List<SVMXC__Field_Default_Rules__c> FL = new List<SVMXC__Field_Default_Rules__c>();
        String str = processobj.SVMXC__Optimization_Goal__c;
        if(str != null && str.length() > 0)
            FL = Database.query('Select SVMXC__Target_Key__c, SVMXC__Target_Value__c, SVMXC__Source_Key__c From SVMXC__Field_Default_Rules__c where SVMXC__Source_Key__c =: str');
        if(FL.size() > 0)
        {
            MAP<String,Map<String,integer>> DPGoal = new MAP<String,Map<String,integer>>();
            Map<String,integer> FLmap = new Map<String,integer>();
            for(Integer i = 0 ; i < FL.size(); i++)
            {
                FLmap.put(FL[i].SVMXC__Target_Key__c,integer.valueof(FL[i].SVMXC__Target_Value__c));
            }
            for(Integer i = 0 ; i < FL.size(); i++)
            {
                DPGoal.put(FL[i].SVMXC__Source_Key__c,FLmap);
            }
            for(String s: DPGoal.keySet())
            {
                if(DPGoal.containsKey(s) && DPGoal.get(s) != null && s == processobj.SVMXC__Optimization_Goal__c)
                {
                    if(DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Time_Window__c') != null)
                        WeightTimeWindow = DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Time_Window__c');
                    if(DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Total_Distance__c')!= null )
                        WeightTotalDistance =  DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Total_Distance__c');
                    if(DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Route_Distance__c') != null)   
                        WeightRouteDistance =  DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Route_Distance__c');
                    if(DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Route_Time__c') != null)   
                        WeightRouteTime =  DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Route_Time__c');
                    if(DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Node_Type__c') != null)    
                        WeightNodeType =  DPGoal.get(processobj.SVMXC__Optimization_Goal__c).get('SVMXC__Weight_Node_Type__c');
                }       
            }
        }   
        return null;
    }
    /*Naveen 09/12/2010: Methods for the schedule tab*/
    /** Method to get the data from the config data for the current dispatch process **/
    public List<SVMXC__ServiceMax_Config_Data__c> LoadConfigDataForRecordType(String recType)
    {
        List<SVMXC__ServiceMax_Config_Data__c> configDataList=new List<SVMXC__ServiceMax_Config_Data__c>();
        configDataList = Database.Query('Select s.SVMXC__Display_Type__c,s.SVMXC__Expression_Type__c,s.SVMXC__Run_At__c,s.SVMXC__Active__c From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c =:DPEID and SVMXC__Expression_Type__c =\''+recType+'\'');
        
        Boolean isOldDisProcess = isOldDispatchProcess(configDataList);
        
        if(configDataList.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c currConfig : configDataList)
            {
                //if dispatch process is existing, set the isActive field to true for all scchedules
                if(isOldDisProcess) {
                    Disp_Schedule.add(new RunInformation(false,currConfig.SVMXC__Display_Type__c,currConfig.SVMXC__Run_At__c, true));
                } else {
                    Disp_Schedule.add(new RunInformation(false,currConfig.SVMXC__Display_Type__c,currConfig.SVMXC__Run_At__c, currConfig.SVMXC__Active__c));
                }
            }   
        }
        return configDataList;
    }
    
    public Boolean isOldDispatchProcess(List<SVMXC__ServiceMax_Config_Data__c> configDataList) {
        
        Boolean isOldDP = false;
        Integer configNonActiveCount = 0;
        
        //checking if the Active field is false for all Config data. This means it is the old dispatch process where IsActive was not
        // part of schedules.
        if(configDataList.size() > 0) {
            for(SVMXC__ServiceMax_Config_Data__c currConfig : configDataList)
            {
                if(currConfig.SVMXC__Active__c == false) {
                    configNonActiveCount++;
                }
            }
        }
        System.debug('Inside isOldDispatchProcess, configDataList.size() - ' + configDataList.size());
        System.debug('Inside isOldDispatchProcess, configNonActiveCount - ' + configNonActiveCount);
        if(configNonActiveCount == configDataList.size()) {
            isOldDP = true;
        }
        return isOldDP;
    }
    /** End of fetching the data from the config data **/
    /** Generic method to get and set the Expression Builder Properties**/
    //Commented the below method as it is use for Incremental run which is not in use
    /*public COMM_SVMXC_Search_Expressions SVMX_setExpressionProperties(String recType)
    {
        system.debug('Entered for Incrment Expresion');
        COMM_SVMXC_Search_Expressions expr = null;
        
        List<SVMXC__ServiceMax_Config_Data__c> IncreExpression = Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =:DPEID and RecordTypeId =:ExpressionRTypeId and SVMXC__Expression_Type__c =\''+recType+'\'');
        
        expr=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
        ClearSelOptList(Hdrfldlist);
        DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, IncrementRunExpressions.mapFieldDispType, IncrementRunExpressions.FieldApiLable);
        expr.FieldsList=Hdrfldlist;
        expr.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
        
        if(IncreExpression.size() > 0)
        {               
            expr.DefaultField=DispMethods.getTAG033(); 
            expr.DefaultOperator=DispMethods.getTAG033();
            expr.DefaultListValue=DispMethods.getTAG033();
            expr.ExpressionType='CRITERIA';
            for(SVMXC__ServiceMax_Config_Data__c exp : IncreExpression)
            {
                expr.setExpressions(exp);
            }
        }
        if(processobj.SVMXC__Default_Value__c != null)
        {
            expr.AdvanceOption=processobj.SVMXC__Default_Value__c;
        }
        return expr;
    }*/
    /** End of ExpressionBuilderProperties**/
    
    /* This method is to calculate and add the schedule runs */ 
    public pagereference SVMX_addScheduleRuns()
    {
        try
        {
            System.debug('Started calculating the intervals between the start time: ' + SelectedStartTime + ' and end time: ' + SelectedEndTime + 'with freq:' + SelectedFrequency);
            Integer selFreq ;
            try{
                selFreq = Integer.valueof(SelectedFrequency);
            }catch(Exception ex)
            {
                msgFreqGr1 = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG113()));
                return null;    
            }    
            if(selFreq <= 0)
            {
                msgFreqGr1 = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG113()));
                return null;           
            }
            
            List<String> TotalCalculatedRuns= calculateScheduleIntervals(SelectedStartTime,SelectedEndTime,selFreq);    
            List<RunInformation> TotalSchedules = new List<RunInformation>();                
            if(TotalCalculatedRuns.Size() > 0)
            {
                for(String strRunAt : TotalCalculatedRuns)
                {
                    RunInformation objCurrentInfo = new RunInformation(false,SelectedRunType,strRunAt,null);
                    disp_Schedule.add(objCurrentInfo);
                }
            }  
            System.debug('End of calculating the intervals between the start time and end time'); 
        }
        catch(Exception ex)
        {
            HdrMsg=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }   
        return null;        
    }
    /*End of method addScheduleRuns*/
    /*calculate the interval between the start time and end time*/
    public List<String> calculateScheduleIntervals(String startTime, String endTime,Integer interval)
    {
        Integer ActualStartHour=0,StartHour=0,StartMinute=0,EndHour=0,EndMinute=0,TotalHours=0;
        List<String> StartTimeInterval = new List<String>();
        List<String> EndTimeInterval = new List<String>();
        String Start_AMORPM = 'AM';
        String End_AMORPM = 'AM';
        String Temo_Start_AMORPM;
        List<String> ActualRunAt = new List<String>();
        StartTime = StartTime.replace(' AM',':00'); 
        endTime = endTime.replace(' AM',':00');  
        if(interval <= 0)
        {
            return ActualRunAt;
        }
        if(startTime.contains('PM'))
        {
            StartTime = StartTime.replace(' PM',':00');
            StartHour = StartHour + 12;
            Start_AMORPM = 'PM';                    
        }
        if(endTime.contains('PM'))
        {
            endTime = endTime.replace(' PM',':00');
            EndHour = EndHour + 12;             
            End_AMORPM = 'PM';                    
        }
        System.debug('Verified the starthour and endhour');
        StartTimeInterval = StartTime.split(':', 3);
        EndTimeInterval = EndTime.split(':', 3);
        System.debug('StartTimeInterval:'+ StartTimeInterval +'EndTimeInterval: ' + EndTimeInterval);
        StartHour = Integer.valueof(StartTimeInterval[0]);
        ActualStartHour = Integer.valueof(StartTimeInterval[0]);
        StartMinute = Integer.valueof(StartTimeInterval[1]);
        EndHour = Integer.valueof(EndTimeInterval[0]);
        EndMinute = Integer.valueof(EndTimeInterval[1]);
        Temo_Start_AMORPM = Start_AMORPM;
        System.debug('Calculated the starthour and endhour');
        Integer TempFreq = interval;
        while(StartHour + Temo_Start_AMORPM != EndHour + End_AMORPM)
        {
            if(TempFreq == interval)
            { 
                ActualRunAt.add(StartHour + ':' + StartTimeInterval[1] + ' ' + Temo_Start_AMORPM);
                TempFreq = 0;
            }
            if(StartHour == 11)
            {
                System.debug('Changing AM TO PM OR PM TO AM');
                if(Temo_Start_AMORPM == 'AM')
                {
                    Temo_Start_AMORPM = 'PM';
                }else
                {
                    Temo_Start_AMORPM = 'AM';
                }
            }else if(StartHour == 12)
            {
                StartHour = 0;
            }
            StartHour = StartHour + 1;
            TempFreq = TempFreq + 1;
        }
        if(StartTimeInterval[1] == '00' && EndTimeInterval[1] == '30')
        {
            if(TempFreq == interval)
            { 
                ActualRunAt.add(StartHour + ':' + StartTimeInterval[1] + ' ' + Temo_Start_AMORPM);
            }
        }
        System.debug('Calculated the intervals' + ActualRunAt);
        SVMX_disableQuickAddPopup();
        return ActualRunAt;                             
    }
    /*End of method calculateScheduleIntervals*/
    public List<RunInformation> SVMX_addScheduleRun()
    {
        RunInformation runInfo = new RunInformation(false,'','',true);
        Disp_Schedule.add(runInfo);
        return null;
    }
    public void SVMX_enableQuickAddPopup()
    {
        DisplayQuickAddSchedulePopup = true;
    }
    public void SVMX_disableQuickAddPopup()
    {
        DisplayQuickAddSchedulePopup = false;
    }
    public COMM_SVMXC_Search_Expressions getIncrementRunExpressions() {return IncrementRunExpressions;}
    public void IncreExpresCriADDRow(){ IncrementRunExpressions.addCriteriaExpression(1);}
    public void IncreExpresCriDeleteRow()
    {
        if(delIndex.length() > 0)
            IncrementRunExpressions.removeCriteriaExpression(integer.valueOf(delIndex));
    }
    public pagereference DeleteRunInformation()
    {
        List<RunInformation> TempDisp_Schedule = new List<RunInformation>();
        Boolean isSelected = false;
        //TempDisp_Schedule = Disp_Schedule;
        for(Integer count = 0; count < Disp_Schedule.size() ; count++ )
        {
            system.debug('TEST LOG1: '+Disp_Schedule[count]);
            if(!Disp_Schedule[count].IsSelected)
            {
                TempDisp_Schedule.add(Disp_Schedule[count]);
            }
            else
            {
                isSelected = true;
            }
        }
        Disp_Schedule.clear();
        Disp_Schedule = TempDisp_Schedule;
        if(!isSelected)
        {
            msgDeleteRunInfo = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,DispMethods.getTAG104())); 
        }
        return null;
    }
    public String ValidateScheduleRuns()
    {
        //set is used because we can run the contains method
        Set<Integer> increRunInfo = new Set<Integer>();
        Set<Integer> fullRunInfo = new Set<Integer>();
        //This list is used because we cannot sort set information
        List<Integer> increRunInfoLst = new List<Integer>();
        String RunAt,RunType;
        System.debug('Started validating the schedule runs');
        List<String> RunAtInterval,TimeIntervals;
        for(RunInformation run : Disp_Schedule)
        {
            RunAt = run.RunAt;
            RunType = run.RunType;
            RunAtInterval = new List<String>();
            TimeIntervals = new List<String>();
            RunAtInterval = RunAt.split(' ', 2);
            TimeIntervals = RunAtInterval[0].split(':',2);
            System.debug('Run Interval: '+RunAtInterval +' Time Interval: '+TimeIntervals);
            Integer interval;
            if(TimeIntervals[0] == '12' && RunAtInterval[1] == 'AM')
            {
                interval = Integer.valueof(0 + TimeIntervals[1]);
            }
            else if(TimeIntervals[0] == '12' && RunAtInterval[1] == 'PM')
            {
                interval = Integer.valueof(12 + TimeIntervals[1]);
            }
            else if(RunAtInterval[1] == 'PM')
            {
                interval = Integer.valueof((Integer.valueof(TimeIntervals[0]) + 12) + TimeIntervals[1]);
            }
            else
            {
                interval = Integer.valueof(Integer.valueof(TimeIntervals[0]) + TimeIntervals[1]);
            }
            if(!increRunInfo.contains(interval) && !fullRunInfo.contains(interval))
            {
                if(RunType != 'Full')
                {
                    increRunInfo.add(interval);
                    increRunInfoLst.add(interval);
                }
                else
                    fullRunInfo.add(interval);
            }
            else
            {
                //duplicates are existing so validation failed.
                System.debug('Run information is not valid because of duplicate runs' + interval);
                return 'duplicate';
            }               
        }
        system.debug('Created the Lists for full and incremental run information');
        increRunInfoLst.sort();
        Integer increStartRun,increEndRun;
        if(increRunInfoLst.size() > 1)
        {
            increStartRun = increRunInfoLst[0];
            increEndRun = increRunInfoLst[increRunInfoLst.size()-1];
            if(fullRunInfo.size() > 0)
            {
                for(Integer fullRunTime : fullRunInfo)
                {
                    if(fullRunTime > increStartRun && fullRunTime < increEndRun)
                    {
                        system.debug('Run information is not valid because the full run is existing in between valid runs');
                        system.debug('fullRunTime :' + fullRunTime + ' >increStartRun' + increStartRun + ' <fullRunTime' + increEndRun);
                        return 'between';
                    }                       
                }
            }
        }
        return '';
    }
    private void CreateDefaultTimeZones()
    {
        Schema.DescribeFieldResult CT =user.TimeZoneSidKey.getDescribe();
        system.debug('List of TimeZones ');
        List<Schema.PicklistEntry> allTimezones = CT.getPicklistValues();
        for(Schema.PicklistEntry currTimeZone: allTimezones)
        {
            DefaultTimeZones.add(new selectOption(currTimeZone.getValue(),currTimeZone.getLabel()));
        }           
    }
    private void GetDefaultStartTimes()
    {
        Schema.DescribeFieldResult defaultStartTimes =SVMXC__ServiceMax_Processes__c.SVMXC__Start_Time__c.getDescribe();
        List<Schema.PicklistEntry> StartTimes = defaultStartTimes.getPicklistValues();
        for(Schema.PicklistEntry currentStartTime: startTimes)
        {
            DefaultStartTime.add(new selectOption(currentStartTime.getValue(),currentStartTime.getLabel()));
        }               
    }
    
    /*Naveen 09/12/2010: End of Methods for the schedule tab*/
    
    /*** @Multiple Instance BEGIN ***/
    public List<SelectOption> lstSPInstance{get;set;} 
    public Map<String,String> mapSPInstance;
    public String spInstName{get;set;}
    public String strDefaultConnection;
    public Map<String, SVMXC__ServiceMax_Properties__c> allSpSettings = new Map<String, SVMXC__ServiceMax_Properties__c>();
    //This method creates PickList values for the Connection Names.
    public void buildSPInstPicklist(){
        lstSPInstance = new List<SelectOption>();
        mapSpInstance = new Map<String, String>();
        try
        {
            mapSpInstance = getSpInstanceMap();
            lstSPInstance.add(new SelectOption(System.Label.DCON001_TAG280, System.Label.DCON001_TAG280));
            for(String strConNum: mapSpInstance.keySet())
            {
                lstSPInstance.add(new SelectOption(strConNum, strConNum));
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:WORD_SetupDispatchProcess: buildSPInstPicklist() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
        }
    }
    //This method creates a map of Connection Names. 
    public Map<String, String> getSpInstanceMap(){
        SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
        Map<String, String> mapRetSpInstance = new Map<String, String>();
        try{
            allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            if((allSpSettings != null) && (!allSpSettings.isEmpty())){
                for(String strConNum: allSpSettings.keySet()){
                    instanceName = allSpSettings.get(strConNum);
                    if (('ServicePower Connection Name'.equalsIgnoreCase(instanceName.SVMXC__Key__c)) &&
                        ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_01_' + (instanceName.Name).right(2)).SVMXC__Value__c))){                 
                        mapRetSpInstance.put(instanceName.SVMXC__Value__c, instanceName.SVMXC__Value__c);
                    }
                }
            }else{
                WSCH_AuditLogger.ERROR('WORD_SetupDispatchProcess: getSpInstanceMap: No Valid Connection Name');
                throw new WSCH_EXCEPTION('WORD_SetupDispatchProcess: getSpInstanceMap: No Valid Connection Name');
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:WORD_SetupDispatchProcess: getSpInstanceMap() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
        }
        return mapRetSpInstance;
    }
    /*** @Multiple Instance END ***/
    
    /** Start: Methods for LTP tab**/
    public COMM_SVMXC_Search_Expressions getlongTermPlanningRunExpressions() {return longTermPlanningRunExpressions;}
    public void ltpExpresCriADDRow(){ longTermPlanningRunExpressions.addCriteriaExpression(1);}
    public void ltpExpresCriDeleteRow() {
        if(delIndex.length() > 0)
            longTermPlanningRunExpressions.removeCriteriaExpression(integer.valueOf(delIndex));
    }
    
    public pagereference lstSchedules_AddRow() {
        lstSchedules.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Schedule_Rtype_Id,SVMXC__Run_Type__c='Day of Week', SVMXC__Sequence__c = lstSchedules.size() + 1 ));     
        
        return null;
    }
    
    /** This method validates if the scheduling information for LTP is valid **/
    public Boolean isvalidLTPSchedule() {
        system.debug('WORD_SetupDispatchProcess::isvalidLTPSchedule()');
        Boolean retVal = true;
        system.debug('WORD_SetupDispatchProcess::isvalidLTPSchedule(): lstSchedules - ' + lstSchedules);
        if(lstSchedules != null && lstSchedules.size()>0) {
            for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules) {
                
                if(configdata.SVMXC__Run_At__c == null || configdata.SVMXC__Run_At__c == DispMethods.getTAG033() || configdata.SVMXC__Run_At__c == '' ||
                configdata.SVMXC__Run_Type__c == null || configdata.SVMXC__Run_Type__c == DispMethods.getTAG033() || configdata.SVMXC__Run_Type__c == '' ) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, DispMethods.getTAG109()));
                    apexMessagesList.add(DispMethods.getTAG109());
                    system.debug('WORD_SetupDispatchProcess::isvalidLTPSchedule(): Invalid schedule.');
                    retVal = false;
                }
                
                if(configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c=='Day of Week' && 
                    (configdata.SVMXC__Schedule_Days__c == null || configdata.SVMXC__Schedule_Days__c == '')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, DispMethods.getTAG109()));
                    apexMessagesList.add(DispMethods.getTAG109());
                    system.debug('WORD_SetupDispatchProcess::isvalidLTPSchedule(): Invalid schedule.');
                    retVal = false;
                }
                
                if(configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c=='Date of Month' && 
                    (configdata.SVMXC__Day_to_Run__c == null || configdata.SVMXC__Day_to_Run__c == '')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, DispMethods.getTAG109()));
                    apexMessagesList.add(DispMethods.getTAG109());
                    system.debug('WORD_SetupDispatchProcess::isvalidLTPSchedule(): Invalid schedule.');
                    retVal = false;
                }
            }
        }
        return retVal;
    }
    
    /** Below method saves the LTP scheduling information **/
    public void saveLTPSchedule() {
        
        system.debug('WORD_SetupDispatchProcess::saveLTPSchedule(): Start');
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
            
        if(lstSchedules != null && lstSchedules.size()>0) {
            for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules) {
                /*if(configdata.SVMXC__Run_At__c== DispMethods.getTAG033() || configdata.SVMXC__Run_At__c== '' || configdata.SVMXC__Run_Type__c== DispMethods.getTAG033() 
                    || configdata.SVMXC__Run_Type__c == '' || configdata.SVMXC__Schedule_Days__c == '' || configdata.SVMXC__Day_to_Run__c == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, DispMethods.getTAG109()));
                    apexMessagesList.add(DispMethods.getTAG109());
                    return;
                }*/
                if(configdata.SVMXC__Run_Type__c=='Day of Week') {
                    system.debug('WORD_SetupDispatchProcess::saveLTPSchedule(): run type is Day Of Week');
                    if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' 
                        && configdata.SVMXC__Run_At__c !=DispMethods.getTAG033() && configdata.SVMXC__Schedule_Days__c != null 
                            && configdata.SVMXC__Schedule_Days__c != '' && configdata.SVMXC__Schedule_Days__c !=DispMethods.getTAG033()) {
                         //system.debug(LoggingLevel.WARN,'Day to run  '+configdata.SVMXC__Day_to_Run__c+'  Dispatch Process id: '+objPMPlanProcess.Id+'  Schedule Days:'+ configdata.SVMXC__Schedule_Days__c);
                        configdata.SVMXC__Day_to_Run__c=null;
                        configdata.RecordTypeId = Schedule_Rtype_Id;
                        configdata.SVMXC__Dispatch_Process__c = processobj.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                }
                    
                if(configdata.SVMXC__Run_Type__c=='Date of Month') {
                    system.debug('WORD_SetupDispatchProcess::saveLTPSchedule(): run type is Date of Month');
                    if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' 
                        && configdata.SVMXC__Run_At__c !=DispMethods.getTAG033() && configdata.SVMXC__Day_to_Run__c != null 
                            && configdata.SVMXC__Day_to_Run__c != '' && configdata.SVMXC__Day_to_Run__c !=DispMethods.getTAG033()) {
                        //system.debug(LoggingLevel.WARN,'Day to run  '+configdata.SVMXC__Day_to_Run__c+'  Dispatch Process id: '+objPMPlanProcess.Id+'  Schedule Days:'+ configdata.SVMXC__Schedule_Days__c);
                        configdata.SVMXC__Schedule_Days__c=null;
                        configdata.RecordTypeId = Schedule_Rtype_Id;
                        configdata.SVMXC__Dispatch_Process__c = processobj.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                }
            }
        }
        //system.debug(LoggingLevel.WARN,'Config data to save '+lstConfigdataToSave);
        if(lstConfigdataToSave != null && lstConfigdataToSave.size() > 0){
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigdataToSave, COMM_SecurityUtils.Access.Upsertable)){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return;
            }
            system.debug('WORD_SetupDispatchProcess::saveLTPSchedule(): saving the LTP schedule data.');
            upsert lstConfigdataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        }
    }
    
    public void changeRunType() {
        if(lstSchedules != null && lstSchedules.size()>0)
        {
            for(SVMXC__ServiceMax_Config_Data__c tempconfigdata : lstSchedules)
            {
                if(tempconfigdata.SVMXC__Sequence__c==(intSeqVal))
                {
                    tempconfigdata.SVMXC__Day_to_Run__c = null;
                        tempconfigdata.SVMXC__Schedule_Days__c = null;
                }     
            }
        }
    }
    
    /** This method initializes the Schedule Information Table in UI **/
    public void initializeLTPScheduleTable() {
        system.debug('WORD_SetupDispatchProcess:: Inside initializeLTPScheduleTable()');
        if(processobj.id != null) {
            lstSchedules = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: Schedule_Rtype_Id and SVMXC__Dispatch_Process__c =: processobj.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
            
        if(lstSchedules == null || lstSchedules.size() == 0) {
            lstSchedules_AddRow();
        }
    }
    
    /** Enable/Disable LTP sections based on the dispatch method**/
    public void toEnableDisableLTPSections() {
        system.debug('WORD_SetupDispatchProcess: inside toEnableDisableLTPSections: isDispatchMethodLTP - ' + isDispatchMethodLTP);
        if(isDispatchMethodLTP) {
            system.debug('WORD_SetupDispatchProcess: toEnableDisableLTPSections(): Enabling Standalone LTP section');
            isRenderToolBar1 = false;
            isRenderLTPExpressionSec = false;
            isRenderLTPCheckBox = false;
            
            isRenderToolBar2 = true;
            isRenderToolBar3 = true;
            isRenderLTPScheduleTableSec = true;
            isRenderLTPHorizonSec = true;
            isRenderLTPMailSec = true;
        } else if(!isDispatchMethodLTP) {
            isRenderLTPCheckBox = true;
        }
    }
    
    /** This method enables or disables the LTP section based on the check box**/
    public void enableLTPSectionOnCheckBox() {
        system.debug('WORD_SetupDispatchProcess: inside enableLTPSectionOnCheckBox: enableLTPCheckbox - ' + enableLTPCheckbox);
        if(enableLTPCheckbox) {
            system.debug('WORD_SetupDispatchProcess: enableLTPSectionOnCheckBox():LTP checkBox is enabled.');
            
            /** copying scheduling days value from Batch or Eco tab to LTP tab when LTP section is enabled**/
            if((processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() || 
                                    processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch') && strScheduleDays != null) {
                strLTPStartAftrFull = strScheduleDays;
            }
            
            isRenderToolBar1 = true;
            isRenderToolBar2 = true;
            isRenderToolBar3 = true;
            isRenderLTPExpressionSec = true;
            isRenderLTPScheduleTableSec = true;
            isRenderLTPHorizonSec = true;
            if(!isDispatchMethodLTP) {
                isRenderLTPMailSec = false;
            }
            
        } else if(!enableLTPCheckbox) {
            system.debug('WORD_SetupDispatchProcess: enableLTPSectionOnCheckBox():LTP checkBox is disabled.');
            isRenderToolBar1 = false;
            isRenderToolBar2 = false;
            isRenderToolBar3 = false;
            isRenderLTPExpressionSec = false;
            isRenderLTPScheduleTableSec = false;
            isRenderLTPHorizonSec = false;
            isRenderLTPMailSec = false;
        }
    }
    
    public PageReference populateLTPData() {
        system.debug('WORD_SetupDispatchProcess::inside populateLTPData(): selectedTab - ' + selectedTab);
        system.debug('WORD_SetupDispatchProcess::inside populateLTPData(): DispMethods.getlongTermPlannerDP() - ' + DispMethods.getlongTermPlannerDP());
            system.debug('WORD_SetupDispatchProcess:Calling populateLTPData()');
            // copying scheduling days value from Batch or Eco tab to LTP tab when LTP section is enabled
            if((processobj.SVMXC__Dispatch_Method__c == DispMethods.getEcoDP() || 
                                    processobj.SVMXC__Dispatch_Method__c == 'Optimized Batch')) {
                system.debug('WORD_SetupDispatchProcess:populateLTPData(): strScheduleDays:' + strScheduleDays);
                strLTPStartAftrFull = strScheduleDays;
            }
        return null;
    }
    
    public boolean validateAdvanceExpression(COMM_SVMXC_Search_Expressions longTermPlanningRunExpressions) {
        Boolean isExpressionValid = false;
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        for(integer k=0; k < longTermPlanningRunExpressions.lstExpressions.size(); k++)
        {
           if(longTermPlanningRunExpressions.lstExpressions[k].FieldName != null && longTermPlanningRunExpressions.lstExpressions[k].FieldName != 'SVMX.NONE' && 
                longTermPlanningRunExpressions.lstExpressions[k].Operator != null && longTermPlanningRunExpressions.lstExpressions[k].Operator != 'SVMX.NONE' && 
                    longTermPlanningRunExpressions.lstExpressions[k].FieldName.length() > 0 && longTermPlanningRunExpressions.lstExpressions[k].Operator.length() > 0)
            {
                SVMXC__ServiceMax_Config_Data__c confObj = new SVMXC__ServiceMax_Config_Data__c();
                
                confObj.SVMXC__Sequence__c = longTermPlanningRunExpressions.lstExpressions[k].Sequence;
                confObj.SVMXC__Field_Name__c = longTermPlanningRunExpressions.lstExpressions[k].FieldName;
                confObj.SVMXC__Operator__c = longTermPlanningRunExpressions.lstExpressions[k].Operator;
                confObj.SVMXC__Operand__c = longTermPlanningRunExpressions.lstExpressions[k].Operand;
                
                lstConfigData.add(confObj);
            }
        }   
        system.debug('WORD_SetupDispatchProcess::SVMX_FinalSave:: lstConfigData - '+lstConfigData);
        if(longTermPlanningRunExpressions.AdvanceOption != null) {
            isExpressionValid = submitExp(Processobj,lstConfigData,longTermPlanningRunExpressions.AdvanceOption);
        }
        return isExpressionValid;
    }
    /** End: Methods for LTP tab**/
}