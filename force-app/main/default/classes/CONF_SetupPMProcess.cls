public with sharing class CONF_SetupPMProcess
{
    //-------------------------------------- Variables and Getter-Setter Methods ------------------------------------------------------
    public SVMXC__ServiceMax_Processes__c objPMPlanProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getobjPMPlanProcess(){return this.objPMPlanProcess;}
    public void setobjPMPlanProcess(SVMXC__ServiceMax_Processes__c proces){this.objPMPlanProcess = proces;}    
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules() { return this.lstSchedules;}
    public void setlstSchedules(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSchedules = lst;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules_toDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> LstExp = new List<SVMXC__ServiceMax_Config_Data__c>();    
    public Integer lstSchedules_HighSeqNum 
    {
        get{return lstSchedules.size();}
    }

    public String strProcessType {get; set;}
    public Boolean isProcessTypeDisabled{get; set;}
    public Boolean isTabDisabled {get; set;}
    public Boolean isAllowAddSchedule {get; set;}
    public Boolean isFieldMapSDToWOHide {get; set;}
    public List<SelectOption> lstProcessType = new List<SelectOption>();
    public List<SelectOption> getlstProcessType(){return this.lstProcessType;} 
    
    public string strRecordId;
    public string strMode;
    public string strProcessName{get;set;}
    public string strProcessID{get;set;}
    public string strProcessDesc{get;set;}
    public String strSelectedRow {get; set;}
    public String strCreateWorkOrder {get; set;}
    public String strSelectedWOmap {get; set;}
    public String strSelectedLocMap {get; set;}
    // 19 Oct; Anchal-  Added New variables for selecting Schedule Definition to Case/ Work Order Map
    public String strSelectedSDWOMap {get; set;}
    public String strAssignWOto {get; set;}
    public String strSelectedCasemap {get; set;}
    public String strSelectedQueueforWO {get; set;}
    public String strSelectedQueueforCase {get; set;}
    public String strSelectedTaskObject {get; set;}
    public String strSelectedTaskmap {get; set;}
    public String strSelectedReqPartsmap {get; set;}
    public String strSelectedWORefField {get; set;} 
    public string strSelectedTimeZone{get;set;}
    public string strAssignCaseTo{get;set;}
    public boolean isDisableEditLink{get;set;}
    public boolean isdisabled{get;set;}
    public boolean isValid{get;set;}
    public boolean isCreateNewExp{get;set;}
    public boolean isRenderExpBlock{get;set;}
    public boolean isCreateCase{get;set;}
    public boolean isRenderUser{get;set;}
    public boolean isRenderQueue{get;set;}
    public boolean isRenderTechnician{get;set;}
    public boolean isRenderWORefFields{get;set;}    
    public boolean isRenderTeam{get;set;}
    public boolean isRenderUser1{get;set;}
    public boolean isRenderQueue1{get;set;}
    public boolean isRendercasemap{get;set;}
    public boolean isRenderAssignto{get;set;}
    public boolean isRendertaskmap{get;set;}
    public boolean isEnableLogging{get;set;}
    public boolean isActive{get;set;}
    public boolean isLocationCovered = false;
    public boolean getisLocationCovered(){return this.isLocationCovered;}
    
    public string strcreateWOndaysBeforeConditional {get;set;}
    
    public Integer intDetailSize = 0;
    public integer intExpDetailSize = 0;
    public integer intcreateWOndaysBefore;
    public string strcreateWOndaysBefore {get;set;}
    public integer getintExpDetailSize(){return this.intExpDetailSize;}
    public void setintExpDetailSize(integer inte){this.intExpDetailSize = inte;}
    public string strSelectedTab{get;set;}
    public string delIndex{get;set;}
    public string strSelectedExp{get;set;}
    public List<SelectOption> lstCriteria = new List<SelectOption>();
    public List<SelectOption> getlstCriteria(){return this.lstCriteria;}
    public List<SelectOption> lstUpdateOperator = new List<SelectOption>();
    public List<SelectOption> getlstUpdateOperator(){return this.lstUpdateOperator;} 
    public void setlstUpdateOperator(List<SelectOption> lstField){this.lstUpdateOperator = lstField;}
    public List<selectoption> lstPMplanfield=new List<selectoption>();
    public List<selectoption> getlstPMplanfield() {return this.lstPMplanfield;}
    public List<SVMXC__ServiceMax_Processes__c> lstWOmaptouse = new List<SVMXC__ServiceMax_Processes__c>();    
    public List<SVMXC__ServiceMax_Processes__c> lstTaskTemptoSelTaskObjectmap = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> lstReqPartstoWorkDetailmap = new List<SVMXC__ServiceMax_Processes__c>(); 
    public List<SVMXC__ServiceMax_Processes__c> lstMappingLocToWorkOrder = new List<SVMXC__ServiceMax_Processes__c>(); 
    // List PM schedule Definition & WO Map
    public List<SVMXC__ServiceMax_Processes__c> LstSDTMaps = new List<SVMXC__ServiceMax_Processes__c>(); 
    
    public List<SVMXC__ServiceMax_Processes__c> lstCasemaptouse = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SelectOption> lstCreateWOonpicklst = new List<SelectOption>();
    public List<SelectOption> getlstCreateWOonpicklst(){return this.lstCreateWOonpicklst;} 
    public List<SelectOption> lstWOmaptousepicklist = new List<SelectOption>();
    public List<SelectOption> getlstWOmaptousepicklist(){return this.lstWOmaptousepicklist;} 
    public List<SelectOption> lstWORefFieldsPicklist = new  List<SelectOption>();
    public List<SelectOption> getlstWORefFieldsPicklist(){return this.lstWORefFieldsPicklist;} 
    public List<SelectOption> lstTaskObjectpicklst = new List<SelectOption>();
    public List<SelectOption> getlstTaskObjectpicklst(){return this.lstTaskObjectpicklst;}   
    public List<SelectOption> lstTaskmaptousepicklst = new List<SelectOption>();
    public List<SelectOption> getlstTaskmaptousepicklst(){return this.lstTaskmaptousepicklst;}    
    public List<SelectOption> lstReqPartstousepicklst = new List<SelectOption>();
    public List<SelectOption> getlstReqPartstousepicklst(){return this.lstReqPartstousepicklst;}  
    public List<QueueSobject> lstQueueWO = new List<QueueSobject>();
    public List<QueueSobject> lstQueueCase = new List<QueueSobject>();
    public List<SelectOption> lstAssignWOpicklst = new List<SelectOption>();
    public List<SelectOption> getlstAssignWOpicklst(){return this.lstAssignWOpicklst;} 
    public List<SelectOption> lstCasemaptousepicklst = new List<SelectOption>();
    public List<SelectOption> getlstCasemaptousepicklst(){return this.lstCasemaptousepicklst;} 
    public List<SelectOption> lstQueuepicklstWO = new List<SelectOption>();
    public List<SelectOption> getlstQueuepicklstWO(){return this.lstQueuepicklstWO;} 
    public List<SelectOption> lstQueuepicklstCase = new List<SelectOption>();
    public List<SelectOption> getlstQueuepicklstCase(){return this.lstQueuepicklstCase;} 
    public List<SelectOption> lstOperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getlstOperatorSelectLst(){return lstOperatorSelectLst;}
    public List<SelectOption> lstTimeZones = new List<SelectOption>();
    public List<SelectOption> getlstTimeZones(){return lstTimeZones;}
    public SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Expression Exp = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression ExpPM = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpPM(){return this.ExpPM;}
    public void setExpPM(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpPM = sfmExp;}
    public COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
    public integer intSeqVal;
    public integer getintSeqVal(){return this.intSeqVal;}
    public void setintSeqVal(integer index){this.intSeqVal = index;}
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRecExp = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SeqNumsrcUpdate = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    public string ExpHdr_Rtype_Id;
    public string ExpDtl_Rtype_Id;  
    public string Schedule_Rtype_Id;
    public string ObjMap_Rtype_Id;
    public string strPMplan_RtypeID = '';
    public Boolean isLocationBasedPMActive = false;
    public List<SelectOption> optnMappingLocToWO = new List<SelectOption>();
    public List<SelectOption> getOptnMappingLocToWO(){return this.optnMappingLocToWO;}
    
    public List<SelectOption> optnMappingSDToWO = new List<SelectOption>();
    public List<SelectOption> getOptnMappingSDToWO(){return this.optnMappingSDToWO;}
    
    public Boolean isCaseObjAvailable = false;
    public Boolean getisCaseObjAvailable(){return this.isCaseObjAvailable;}
    
    //Drop-downs displayed will be managed through these constant values.
    public string ONE_PER_PLAN = 'One Per Plan';
    public string ONE_PER_PRODUCT = 'One Per Product';
    
    //transient List<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
    
    public CONF_SetupPMProcess()
    {
        try
        {
            COMM_Utils objComm_Utils = new COMM_Utils();
            isCaseObjAvailable = objComm_Utils.SVMX_isObjectLicensed('Case');
            
            //Get the setting value to enable / disable Location Based Preventive Maintenance
            List<String> lstSubModules = new List<String>{'PREV001'};
            Map<String, Map<String, String>> AllsvmxSettingList = new Map<String, Map<String, String>>();
            AllsvmxSettingList = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList(lstSubModules);
            Map<String, String> svmxSettingListPREV001 = AllsvmxSettingList.get('PREV001');


            if(svmxSettingListPREV001.get('SET003') != NULL && svmxSettingListPREV001.get('SET003').toUpperCase() == 'TRUE')
                isLocationBasedPMActive = Boolean.valueOf(svmxSettingListPREV001.get('SET003'));



            system.debug(LoggingLevel.WARN, 'Settine SET003: ' + isLocationBasedPMActive);
            
            isLocationCovered = isLocationBasedPMActive;
            strMode = System.currentPageReference().getParameters().get('SVMX_Mode');
            strRecordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
            
            lstWOmaptouse =[select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c in ('SVMXC__Installed_Product__C','SVMXC__Service_Contract__C','Account' ) and SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            lstReqPartstoWorkDetailmap =[select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c ='SVMXC__Required_Part__c' and SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(isLocationBasedPMActive){
                lstMappingLocToWorkOrder =[select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c ='SVMXC__Site__c' and SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            
            LstSDTMaps = [select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c ='SVMXC__PM_Schedule_Definition__c' and (SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            
            setDefaultValues();
            retrieveRecordTypes();
            preparingPicklists();
            isRendertaskmap= false;
           
            if(strMode != 'New' && strRecordId != null && strRecordId != '')
            {
                objPMPlanProcess = [select id, SVMXC__Name__c, SVMXC__SM_Process_Type__c, SVMXC__Submodule__c, SVMXC__Parent_Object__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Module__c, SVMXC__Create_Work_Order__c, SVMXC__Node_Parent__c, SVMXC__Process3__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Assign_To_Queue__c, SVMXC__Assign_To_Service_Team__c, SVMXC__Assign_To_Technician__c, SVMXC__Include_Parent__c, SVMXC__Assign_Case_To__c, SVMXC__Case_Assign_To_User__c,SVMXC__Case_Assign_To_Queue__c,SVMXC__Process__c,SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c,SVMXC__Capture_Log__c,SVMXC__Product_Match_Enabled__c,SVMXC__Preferred_Tech_Enabled__c, SVMXC__Frequency__c, SVMXC__Target_Object_Name__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__APL_Field_Name__c,SVMXC__Active__c, SVMXC__Dispatch_Timezone__c, SVMXC__Assign_To_Technician__r.Name, SVMXC__Assign_To_Dispatcher__r.Name,SVMXC__Assign_To_Service_Team__r.Name,SVMXC__Case_Assign_To_User__r.Name, SVMXC__SM_Do_Not_Create_New_WO__c,SVMXC__SM_Do_Not_Create_WO_Within__c from SVMXC__ServiceMax_Processes__c where id =: strRecordId and RecordTypeId =: strPMplan_RtypeID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
                if(objPMPlanProcess != null)
                {
                    strProcessName = objPMPlanProcess.SVMXC__Name__c;
                    strProcessID = objPMPlanProcess.SVMXC__ProcessID__c;
                    strProcessDesc = objPMPlanProcess.SVMXC__Description__c;
                    strSelectedExp = objPMPlanProcess.SVMXC__Module__c;
                    strcreateWOndaysBefore = String.valueof(integer.valueof(objPMPlanProcess.Frequency__c));
                    strCreateWorkOrder = objPMPlanProcess.SVMXC__Create_Work_Order__c;
                    strProcessType = objPMPlanProcess.SVMXC__SM_Process_Type__c;
                    isProcessTypeDisabled = true;
                    isTabDisabled = false;
                    if(strProcessType == null || strProcessType == ''){
                        strProcessType = 'TIME_BASED_PM';
                    }
                    if(strProcessType == 'CONDITION_BASED_PM'){
                        isAllowAddSchedule = false;
                        isFieldMapSDToWOHide = false;
                    }
                    else{
                        isAllowAddSchedule = true;
                        isFieldMapSDToWOHide = true;
                    }

                    strSelectedWOmap=objPMPlanProcess.SVMXC__Node_Parent__c;
                    strSelectedLocMap=objPMPlanProcess.SVMXC__Process3__c;
                    // 19 Oct; Anchal
                    // Submodule Field will be used to store Schedule Definition & WO mapping process.
                    strSelectedSDWOMap = objPMPlanProcess.SVMXC__Submodule__c ;
                    
                    strAssignWOto=objPMPlanProcess.SVMXC__Assign_Work_Order_To__c;
                    isActive = objPMPlanProcess.SVMXC__Active__c;
                    
                    isCreateCase=objPMPlanProcess.SVMXC__Include_Parent__c;
                    strSelectedCasemap=objPMPlanProcess.SVMXC__Process__c;
                    strSelectedQueueforWO=objPMPlanProcess.SVMXC__Assign_To_Queue__c;
                    strSelectedQueueforCase=objPMPlanProcess.SVMXC__Case_Assign_To_Queue__c;
                    strSelectedTaskObject =objPMPlanProcess.SVMXC__Target_Object_Name__c;
                    strSelectedTaskmap = objPMPlanProcess.SVMXC__Process1__c;
                    strSelectedReqPartsmap = objPMPlanProcess.SVMXC__Process2__c ;
                    strSelectedWORefField = objPMPlanProcess.SVMXC__APL_Field_Name__c;
                    strSelectedTimeZone = objPMPlanProcess.SVMXC__Dispatch_Timezone__c; 
                    if(objPMPlanProcess.SVMXC__IsStandard__c == true)
                    {
                        isdisabled = true;
                        strAssignCaseTo = objPMPlanProcess.SVMXC__Assign_Case_To__c;
                    }
                    preparingPicklists();
                    visibilitycontrol();
                    onChngSelectedTaskObject();
                    onChangeProcessType();
                    strSelectedWOmap=objPMPlanProcess.SVMXC__Node_Parent__c;
                    if(strSelectedExp != getTAG009() && strSelectedExp != null)
                    {
                        onChngExp();
                    }
                    
                    lstSchedules = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: Schedule_Rtype_Id and SVMXC__Dispatch_Process__c =: objPMPlanProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstSchedules == null || lstSchedules.size() == 0)
                        lstSchedules_AddRow();
                }
            }
            else
            {
                objPMPlanProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__SM_Do_Not_Create_New_WO__c = true, SVMXC__SM_Do_Not_Create_WO_Within__c=0);
                if(strMode=='New')
                {
                    //strCreateWorkOrder=getTAG039();
                    strCreateWorkOrder = ONE_PER_PLAN;
                    strProcessType = 'SVMX.NONE';
                    isProcessTypeDisabled = false;
                    isTabDisabled = true;
                    isAllowAddSchedule = true;
                    isFieldMapSDToWOHide = true;
                    preparingPicklists();
                    onChngCreateWO();
                    strcreateWOndaysBefore = String.valueof(0);
                }
                lstSchedules_AddRow();
                isActive = true;
            }
            
            if(strMode == 'Clone')
            {
                isdisabled = false;
                isProcessTypeDisabled = true;
                isTabDisabled = false;
                SVMXC__ServiceMax_Processes__c tempProcess = new SVMXC__ServiceMax_Processes__c();
                tempProcess = objPMPlanProcess ;
                
                objPMPlanProcess = new SVMXC__ServiceMax_Processes__c();
                objPMPlanProcess=tempProcess.clone(false, true);
                objPMPlanProcess.SVMXC__IsStandard__c = false;
                strProcessID = objPMPlanProcess.SVMXC__ProcessID__c + system.now().format('MM/dd/yyyy');
                
                List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
              
                tempLst.addAll(lstSchedules);
                lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
                
                 
                for(SVMXC__ServiceMax_Config_Data__c CD : tempLst)
                {
                    SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
                    confData.SVMXC__Sequence__c = CD.SVMXC__Sequence__c;
                    confData.SVMXC__Run_At__c = CD.SVMXC__Run_At__c;
                    confData.SVMXC__Schedule_Days__c = CD.SVMXC__Schedule_Days__c;
                    confData.SVMXC__Run_Type__c = CD.SVMXC__Run_Type__c;
                    confData.SVMXC__Day_to_Run__c = CD.SVMXC__Day_to_Run__c;
                    confData.RecordTypeId = Schedule_Rtype_Id;
                    lstSchedules.add(confData);
                }
            }
        }
        catch(exception ex)
        {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052()));
        }
    
    }
 
    //-------------------------------- Method to set Default Values for different Variables ------------------------------------
    public void setDefaultValues()
    {
        isDisableEditLink = true;
        isRenderExpBlock = false;
        isValid = true;
        isCreateNewExp = false;
        isdisabled = false;
        strSelectedExp = getTAG009();
        isCreateCase = false;
        isRenderUser = false;
        isRenderTechnician = false;
        isRenderQueue = false;
        isRenderTeam = false;
        isRenderUser1 = false;
        isRenderQueue1 = false;
        isRenderAssignto = false;
        isRendercasemap = false;
        isRenderWORefFields = true;
        isRendertaskmap = false;
        strAssignWOto = 'Primary Technician';
        strCreateWorkOrder = ONE_PER_PLAN;
        //strCreateWorkOrder =getTAG039();
        onChngCreateWO();
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        strSelectedTimeZone = userTimeZone.TimeZoneSidKey;
        
    }
    
    //-------------------------------- Method to to set some variable for location based pm plam process ------------------------------------
    public PageReference onChngLocBased()
    {
        strSelectedLocMap = getTAG009();
        return null;
    }
    
  
    //---------------------------------------- Method to retrieve All the Record Types -----------------------------------------
   public void retrieveRecordTypes()
    {
        List<string> lstRCNames = new List<string>();
        lstRCNames.add('SVMX Rule');
        lstRCNames.add('Expressions');
        lstRCNames.add('Schedule');
        lstRCNames.add('PM Process');
        lstRCNames.add('Object Mapping');
        
        List<string> lstObjs = new List<string>();
        lstObjs.add('SVMXC__ServiceMax_Processes__c');
        lstObjs.add('SVMXC__ServiceMax_Config_Data__c');
        
        for(RecordType RC: [select id, Name, SobjectType from RecordType where Name IN: lstRCNames and SobjectType IN: lstObjs])
        {
            if(RC.Name == 'SVMX Rule' && RC.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                ExpHdr_Rtype_Id = RC.Id;
            if(RC.Name == 'Expressions' && RC.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                ExpDtl_Rtype_Id = RC.Id;
            if(RC.Name == 'Schedule' && RC.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                Schedule_Rtype_Id = RC.Id;
            if(RC.Name == 'PM Process' && RC.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                strPMplan_RtypeID = RC.Id;
            if(RC.Name == 'Object Mapping' && RC.SobjectType == 'SVMXC__ServiceMax_Processes__c')

                ObjMap_Rtype_Id = RC.Id;
        }        
    }
    
    public void preparingPicklists()
    {
        SFM_WrapperDef.SFM_Request SFMReq = new SFM_WrapperDef.SFM_Request();
        
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap strinmap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'EXPRESSION');
        lstStringMap.add(strinmap1);
        SFM_WrapperDef.SFM_StringMap strinmap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', 'SVMXC__PM_Plan__c');
        lstStringMap.add(strinmap2);
        
        SFMReq.stringMap = lstStringMap;
        
        SFM_GetObjectFieldList newObjToGetFields = new SFM_GetObjectFieldList();
        SFM_WrapperDef.SFM_Response_ObjectFields responseObjFields = newObjToGetFields.getObjectFieldList(SFMReq);
        List<SFM_WrapperDef.fieldProperties> fieldProp = new List<SFM_WrapperDef.fieldProperties>();
        if(responseObjFields.response.success)        
            fieldProp = responseObjFields.fields;       
      
        lstPMplanfield.clear();
        lstPMplanfield.add(new SelectOption('SVMX.NONE',getTAG009()));
        
        for(SFM_WrapperDef.fieldProperties fp : fieldProp)
            lstPMplanfield.add(new SelectOption(fp.key, fp.value));
        
        lstPMplanfield = sortingSelectOption(lstPMplanfield);
        
        
        lstOperatorSelectLst.clear();
        lstOperatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG009()));
        lstOperatorSelectLst.add(new SelectOption('eq', getTAG060()));
        lstOperatorSelectLst.add(new SelectOption('ne', getTAG061()));
        lstOperatorSelectLst.add(new SelectOption('gt', getTAG062()));
        lstOperatorSelectLst.add(new SelectOption('ge', getTAG063()));
        lstOperatorSelectLst.add(new SelectOption('lt', getTAG064()));
        lstOperatorSelectLst.add(new SelectOption('le', getTAG065()));
        lstOperatorSelectLst.add(new SelectOption('starts', getTAG066()));
        lstOperatorSelectLst.add(new SelectOption('contains', getTAG067()));
        lstOperatorSelectLst.add(new SelectOption('notcontain', getTAG068()));
        lstOperatorSelectLst.add(new SelectOption('in', getTAG069()));
        lstOperatorSelectLst.add(new SelectOption('notin', getTAG070()));
        lstOperatorSelectLst.add(new SelectOption('isnull', getTAG071()));
        lstOperatorSelectLst.add(new SelectOption('isnotnull', getTAG072()));
        
        
        lstCriteria.clear();
        lstCriteria.add(new SelectOption(getTAG009(), getTAG009()));
                    
        lstStringMap.clear();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__PM_Plan__c');
        lstStringMap.add(stringMap1);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();        
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteria.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriteria = sortingSelectOption(lstCriteria);
       
        lstCreateWOonpicklst.clear();       
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Processes__c.SVMXC__Create_Work_Order__c.getDescribe();
        List<Schema.PicklistEntry> pick = F.getPicklistValues();
        /*
        for(Schema.PicklistEntry pv : pick)
           lstCreateWOonpicklst.add(new SelectOption(pv.getValue(),pv.getLabel())); 
           */
        
        lstCreateWOonpicklst.add(new SelectOption(ONE_PER_PLAN, getTAG039())); 
        lstCreateWOonpicklst.add(new SelectOption(ONE_PER_PRODUCT,getTAG040()));

        lstProcessType.clear();
        lstProcessType.add(new SelectOption('SVMX.NONE',getTAG009()));
        lstProcessType.add(new SelectOption('CONDITION_BASED_PM', getTAG095())); 
        lstProcessType.add(new SelectOption('TIME_BASED_PM',getTAG096()));      
            
        lstWOmaptousepicklist = new List<SelectOption>();
        lstWOmaptousepicklist.add(new SelectOption(getTAG009(),getTAG009()));
        
        if(lstWOmaptouse != null && lstWOmaptouse.size() > 0){
            for(integer i = 0;i<lstWOmaptouse.size();i++)
            {    
                if(strCreateWorkOrder == getTAG040() || strCreateWorkOrder == ONE_PER_PRODUCT){
                    if(lstWOmaptouse[i].SVMXC__Source_Object_Name__c =='SVMXC__Installed_Product__c')     
                        lstWOmaptousepicklist.add(new selectOption(lstWOmaptouse[i].id,lstWOmaptouse[i].SVMXC__Name__c));
                }
                else if(strCreateWorkOrder == getTAG039() || strCreateWorkOrder == ONE_PER_PLAN){             
                    if(lstWOmaptouse[i].SVMXC__Source_Object_Name__c !='SVMXC__Installed_Product__c' )    
                        lstWOmaptousepicklist.add(new selectOption(lstWOmaptouse[i].id,lstWOmaptouse[i].SVMXC__Name__c));
                }
            }
        }
        
        optnMappingLocToWO = new List<SelectOption>();
        optnMappingLocToWO.add(new SelectOption(getTAG009(),getTAG009()));
        if(lstMappingLocToWorkOrder != null && lstMappingLocToWorkOrder.size() > 0){
            for(integer i = 0; i<lstMappingLocToWorkOrder.size(); i++)
                optnMappingLocToWO.add(new selectOption(lstMappingLocToWorkOrder[i].id, lstMappingLocToWorkOrder[i].SVMXC__Name__c));
        }
        
        
        optnMappingSDToWO = new List<SelectOption>();
        optnMappingSDToWO.add(new SelectOption(getTAG009(), getTAG009()));
        
        if(LstSDTMaps != null && LstSDTMaps.size() > 0){
            for(integer i = 0; i<LstSDTMaps.size(); i++){
                if(LstSDTMaps[i].SVMXC__Target_Object_Name__c.equalsIgnoreCase('SVMXC__Service_Order__c'))
                    optnMappingSDToWO.add(new selectOption(LstSDTMaps[i].id, LstSDTMaps[i].SVMXC__Name__c));
            }
        }
        
        
        lstAssignWOpicklst.clear();
        lstAssignWOpicklst.add(new SelectOption(getTAG009(),getTAG009()));
        Schema.DescribeFieldResult des = SVMXC__ServiceMax_Processes__c.SVMXC__Assign_Work_Order_To__c.getDescribe();
        List<Schema.PicklistEntry> pickval = des.getPicklistValues();
        for(Schema.PicklistEntry pv : pickval)
          lstAssignWOpicklst.add(new SelectOption(pv.getValue(),pv.getLabel()));
            
        lstTaskObjectpicklst = new List<SelectOption>();
        lstTaskObjectpicklst.add(new SelectOption(getTAG009(), getTAG009()));
        
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        List<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
        ChildObj = (allObjs.get('service_Order__c')).getDescribe().getChildRelationships();

        boolean isEnterprise = new SVMXC.COMM_Utils().SVMX_isEnterpriseLicense();
        Map<String,Boolean> permitdStdObjMap = new Map<String,Boolean>();
        if(!isEnterprise) 
            permitdStdObjMap = new SVMXC.COMM_Utils().SVMX_getPermittedStandardObjectList();
        for(Schema.ChildRelationship CR :ChildObj)
        {
            Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe();
            if(new SVMXC.COMM_Utils().SVMX_isObjectCustom(String.valueof(D.getname())) || (permitdStdObjMap.containsKey(String.valueof(D.getname())) || isEnterprise))
                lstTaskObjectpicklst.add(new SelectOption(D.getname(), D.getLabel()));
            
        }
        lstTaskObjectpicklst = sortingSelectOption(lstTaskObjectpicklst);
        
              
       
        lstReqPartstousepicklst = new List<SelectOption>();
        lstReqPartstousepicklst.add(new SelectOption(getTAG009(), getTAG009()));
        if(lstReqPartstoWorkDetailmap!=null && lstReqPartstoWorkDetailmap.size()>0)
            for(integer i = 0;i<lstReqPartstoWorkDetailmap.size();i++)
                lstReqPartstousepicklst.add(new selectOption(lstReqPartstoWorkDetailmap[i].id,lstReqPartstoWorkDetailmap[i].SVMXC__Name__c));
                
        Schema.DescribeFieldResult timeZoneinfo =user.TimeZoneSidKey.getDescribe();        
        lstTimeZones = new List<SelectOption>();
        List<Schema.PicklistEntry> lstallTimezones = timeZoneinfo.getPicklistValues();
        for(Schema.PicklistEntry timeZoneinst: lstallTimezones)
        {
            lstTimeZones.add(new selectOption(timeZoneinst.getValue(),timeZoneinst.getLabel()));
        }    
    }
    
    //------------------------------------- Method to sort the Options of the PickList --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList)
        {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys)
           resultList.addAll(tempLst.get(key)); 
        
        return resultList;
    }
    //---------------------------------On change of Create WO --------------------------------------------------
    public void onChngCreateWO()
    {
            lstWOmaptousepicklist.clear();
            strSelectedWOmap = getTAG009();
            //strSelectedLocMap = getTAG009();
            lstWOmaptousepicklist.add(new SelectOption(getTAG009(),getTAG009()));
            if(lstWOmaptouse!=null && lstWOmaptouse.size()>0)
            for(integer i = 0;i<lstWOmaptouse.size();i++)
            {    
                if(strCreateWorkOrder==getTAG040() || strCreateWorkOrder == ONE_PER_PRODUCT)
                {
                    if(lstWOmaptouse[i].SVMXC__Source_Object_Name__c =='SVMXC__Installed_Product__C')     
                        lstWOmaptousepicklist.add(new selectOption(lstWOmaptouse[i].id,lstWOmaptouse[i].SVMXC__Name__c));
                    
                }
                else if(strCreateWorkOrder == getTAG039() || strCreateWorkOrder == ONE_PER_PLAN)
                {
                    if(lstWOmaptouse[i].SVMXC__Source_Object_Name__c !='SVMXC__Installed_Product__C')    
                        lstWOmaptousepicklist.add(new selectOption(lstWOmaptouse[i].id,lstWOmaptouse[i].SVMXC__Name__c));
                    
                }
            }
    }
    //---------------------------------On change of Process Type ----------------------------------------------------------
    public void onChangeProcessType(){
        if(strProcessType != 'SVMX.NONE'){
            isProcessTypeDisabled = true;
            isTabDisabled = false;
        }

        if(strProcessType == 'CONDITION_BASED_PM'){
            lstCreateWOonpicklst.clear();
            lstCreateWOonpicklst.add(new SelectOption(ONE_PER_PRODUCT,getTAG040()));
            strCreateWorkOrder = ONE_PER_PRODUCT;
            isAllowAddSchedule = false;
            isFieldMapSDToWOHide = false;
        }
        onChngCreateWO();
    }
    //---------------------------------On change of Selected Task Object --------------------------------------------------
    public void onChngSelectedTaskObject()
    {
        
        lstWORefFieldsPicklist = new List<SelectOption>();
        lstWORefFieldsPicklist.add(new SelectOption(getTAG009(), getTAG009())); 
        
        if(strSelectedTaskObject != getTAG009())
            isRendertaskmap = true;
        
        if(strSelectedTaskObject == getTAG009() || strSelectedTaskObject == null)
        {
            isRendertaskmap = false;
            strSelectedTaskmap = getTAG009();
            strSelectedWORefField = getTAG009();
        }
        
        if(strSelectedTaskObject  == 'Task')        
            isRenderWORefFields = false;
        else   
            isRenderWORefFields = true;
            
        lstTaskTemptoSelTaskObjectmap =[select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c ='SVMXC__Task_Template__c' and SVMXC__Target_Object_Name__c =: strSelectedTaskObject]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstTaskmaptousepicklst = new List<SelectOption>();
        lstTaskmaptousepicklst.add(new SelectOption(getTAG009(), getTAG009())); 
       
        if(lstTaskTemptoSelTaskObjectmap!=null && lstTaskTemptoSelTaskObjectmap.size()>0)
            for(integer i = 0;i<lstTaskTemptoSelTaskObjectmap.size();i++)                           
                lstTaskmaptousepicklst.add(new selectOption(lstTaskTemptoSelTaskObjectmap[i].id,lstTaskTemptoSelTaskObjectmap[i].SVMXC__Name__c));
        if(strSelectedTaskObject  != 'Task')
        {   MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            List<schema.Childrelationship> ChildObj = new List<schema.Childrelationship>();
            ChildObj = (allObjs.get('service_Order__c')).getDescribe().getChildRelationships();
            boolean isEnterprise = new SVMXC.COMM_Utils().SVMX_isEnterpriseLicense();
            Map<String,Boolean> permitdStdObjMap = new Map<String,Boolean>();
                                    
            if(!isEnterprise) 
                permitdStdObjMap = new SVMXC.COMM_Utils().SVMX_getPermittedStandardObjectList();
            for(Schema.ChildRelationship CR :ChildObj)
            {
                Schema.DescribeSObjectResult D = CR.getChildSObject().getDescribe();
                if(new SVMXC.COMM_Utils().SVMX_isObjectCustom(String.valueof(D.getname())) || (permitdStdObjMap.containsKey(String.valueof(D.getname())) || isEnterprise))
                {
                    if(D.getname() == strSelectedTaskObject)
                    {
                        lstWORefFieldsPicklist.add(new SelectOption(CR.getField().getDescribe().getName(),CR.getField().getDescribe().getlabel()));
                    }
                }
            }

                lstWORefFieldsPicklist = sortingSelectOption(lstWORefFieldsPicklist);
              
           
        
        }
    }
   //---------------------------------On change of Run Type -------------------------------------------------- 
    public void Chngruntype()
    {
        
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
   //---------------------------------------------------Visibility control on VF page------------------------------------------------------
    public void visibilitycontrol()
    {
        if(strAssignWOto == getTAG009())
        {
            isRenderUser=false;
            isRenderTechnician=false;
            isRenderQueue=false;
            isRenderTeam=false;
            strSelectedQueueforWO=null;
            objPMPlanProcess.Assign_To_Dispatcher__c=null;
            objPMPlanProcess.Assign_To_Queue__c=null;
            objPMPlanProcess.Assign_To_Service_Team__c=null;
            objPMPlanProcess.Assign_To_Technician__c=null;
        }
        if(strAssignWOto == 'Dispatcher')
        {
            isRenderUser=true;
            isRenderTechnician=false;
            isRenderQueue=false;
            isRenderTeam=false;
            strSelectedQueueforWO=null;
            objPMPlanProcess.Assign_To_Queue__c=null;
            objPMPlanProcess.Assign_To_Service_Team__c=null;
            objPMPlanProcess.Assign_To_Technician__c=null;
        }
        if(strAssignWOto == 'Technician')
        {
            
            isRenderTechnician=true;
            isRenderUser=false;
            isRenderQueue=false;
            isRenderTeam=false;
            strSelectedQueueforWO=null;
            objPMPlanProcess.Assign_To_Dispatcher__c=null;
            objPMPlanProcess.Assign_To_Queue__c=null;
            objPMPlanProcess.Assign_To_Service_Team__c=null;
        }
        if(strAssignWOto == 'Primary Technician')
        {
            isRenderUser=false;
            isRenderTechnician=false;
            isRenderQueue=false;
            isRenderTeam=false;
            strSelectedQueueforWO=null;
            objPMPlanProcess.Assign_To_Dispatcher__c=null;
            objPMPlanProcess.Assign_To_Queue__c=null;
            objPMPlanProcess.Assign_To_Service_Team__c=null;
            objPMPlanProcess.Assign_To_Technician__c=null;
        }
        if(strAssignWOto == 'Queue')
        {
            lstQueueWO=[Select SobjectType, Queue.Name, QueueId, Id From QueueSobject where SobjectType = 'SVMXC__Service_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstQueuepicklstWO = new List<SelectOption>();
            lstQueuepicklstWO.add(new SelectOption(getTAG009(),getTAG009()));        
            if(lstQueueWO!=null && lstQueueWO.size()>0)
                for(integer i = 0;i<lstQueueWO.size();i++)
                    lstQueuepicklstWO.add(new selectOption(lstQueueWO[i].Queueid,lstQueueWO[i].Queue.Name));
                isRenderQueue=true;
                isRenderUser=false;
                isRenderTechnician=false;
                isRenderTeam=false;
                objPMPlanProcess.Assign_To_Dispatcher__c=null;
                objPMPlanProcess.Assign_To_Service_Team__c=null;
                objPMPlanProcess.Assign_To_Technician__c=null;
        }
        if(strAssignWOto == 'Team')
        {
            isRenderTeam=true;
            isRenderUser=false;
            isRenderTechnician=false;
            isRenderQueue=false;
            strSelectedQueueforWO=null;
            objPMPlanProcess.Assign_To_Dispatcher__c=null;
            objPMPlanProcess.Assign_To_Queue__c=null;
            objPMPlanProcess.Assign_To_Technician__c=null;
        }
        if(objPMPlanProcess.Include_Parent__c==true)
        {
            isRenderAssignto=true;
            isRendercasemap=true;
            lstCasemaptouse=[select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c' and SVMXC__Target_Object_Name__c = 'Case']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstCasemaptousepicklst = new List<SelectOption>();
            lstCasemaptousepicklst.add(new SelectOption(getTAG009(),getTAG009()));
        
            if(lstCasemaptouse!=null && lstCasemaptouse.size()>0)
                for(integer i = 0;i<lstCasemaptouse.size();i++)
                    lstCasemaptousepicklst.add(new selectOption(lstCasemaptouse[i].id,lstCasemaptouse[i].SVMXC__Name__c));
                    
            lstQueueCase=[Select SobjectType, Queue.Name, QueueId, Id From QueueSobject where SobjectType = 'Case']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstQueuepicklstCase = new List<SelectOption>();
            lstQueuepicklstCase.add(new SelectOption(getTAG009(),getTAG009()));        
            if(lstQueueCase!=null && lstQueueCase.size()>0)
                for(integer i = 0;i<lstQueueCase.size();i++)
                    lstQueuepicklstCase.add(new selectOption(lstQueueCase[i].Queueid,lstQueueCase[i].Queue.Name));
                
        }
        else 
        {
            isRenderAssignto=false;
            isRendercasemap=false;
            isRenderUser1=false;
            isRenderQueue1=false;
            strSelectedCasemap=getTAG009();
            objPMPlanProcess.Assign_Case_To__c=null;
        }
        if(objPMPlanProcess.Assign_Case_To__c == getTAG009() || objPMPlanProcess.Assign_Case_To__c =='' || objPMPlanProcess.Assign_Case_To__c == null)
        {
            isRenderUser1=false;
            isRenderQueue1=false;
            strSelectedQueueforCase=null;
            objPMPlanProcess.Case_Assign_To_User__c=null;
            objPMPlanProcess.Case_Assign_To_Queue__c=null;
        }
        if(objPMPlanProcess.Assign_Case_To__c == 'User')
        {
            isRenderUser1=true;
            isRenderQueue1=false;
            strSelectedQueueforCase=null;
            objPMPlanProcess.Case_Assign_To_Queue__c=null;
        }
        if(objPMPlanProcess.Assign_Case_To__c == 'Queue')
        {
         isRenderUser1=false;
         isRenderQueue1=true;
        objPMPlanProcess.Case_Assign_To_User__c=null;
        }
        
    }
   
    
    public void quickSave()
    {
        isValid = true;
        validation();
        if(isValid == true)
            saveExps();
        if(isValid == true)
        {
            save();
        }
    }
    
    public pagereference saveClose()
    {
        isValid = true;
        validation();
        if(isValid == true)
            saveExps();
            
        if(isValid == true)
        {
            save();
            String loc = '/apex/SVMXC__CONF_ManagePMProcesses';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else
            return null;
    }
    
    public pagereference cancel()
    {
        String loc = '/apex/SVMXC__CONF_ManagePMProcesses';
        PageReference pr = new PageReference(loc);
        return pr;
    }
    
    public void save()
    {
        try
        {
            objPMPlanProcess.RecordTypeId=strPMplan_RtypeID;
            objPMPlanProcess.SVMXC__SM_Process_Type__c = strProcessType;
            objPMPlanProcess.SVMXC__Name__c=strProcessName;
            objPMPlanProcess.SVMXC__ProcessID__c=strProcessID;
            objPMPlanProcess.SVMXC__Description__c=strProcessDesc;
            //system.debug(LoggingLevel.WARN,'strPMplan_RtypeID: '+strPMplan_RtypeID+'  strProcessName: '+strProcessName+'      strProcessID:  '+strProcessID+'  strProcessDesc:  '+strProcessDesc);
            if(strAssignWOto!= getTAG009())
                objPMPlanProcess.SVMXC__Assign_Work_Order_To__c = strAssignWOto;
            else
            {
                objPMPlanProcess.SVMXC__Assign_Work_Order_To__c =null;
                objPMPlanProcess.Assign_To_Dispatcher__c=null;
                objPMPlanProcess.Assign_To_Queue__c=null;
                objPMPlanProcess.Assign_To_Service_Team__c=null;
                objPMPlanProcess.Assign_To_Technician__c=null;
            }
            if(strAssignWOto == 'Dispatcher')
            {
                objPMPlanProcess.Assign_To_Queue__c=null;
                objPMPlanProcess.Assign_To_Service_Team__c=null;
                objPMPlanProcess.Assign_To_Technician__c=null;
            }
            if(strAssignWOto == 'Queue')
            {
                objPMPlanProcess.Assign_To_Dispatcher__c=null;
                objPMPlanProcess.Assign_To_Service_Team__c=null;
                objPMPlanProcess.Assign_To_Technician__c=null;
            }
            if(strAssignWOto == 'Team')
            {
                objPMPlanProcess.Assign_To_Dispatcher__c=null;
                objPMPlanProcess.Assign_To_Queue__c=null;
                objPMPlanProcess.Assign_To_Technician__c=null;
            }
            if(strAssignWOto == 'Technician')
            {
                objPMPlanProcess.Assign_To_Dispatcher__c=null;
                objPMPlanProcess.Assign_To_Queue__c=null;
                objPMPlanProcess.Assign_To_Service_Team__c=null;
            }
            if(strAssignWOto == 'Primary Technician')
            {                
                objPMPlanProcess.Assign_To_Dispatcher__c=null;
                objPMPlanProcess.Assign_To_Queue__c=null;
                objPMPlanProcess.Assign_To_Service_Team__c=null;
                objPMPlanProcess.Assign_To_Technician__c=null;
            }
            if(objPMPlanProcess.Include_Parent__c==false)
            {
                 objPMPlanProcess.SVMXC__Process__c =null;
                 objPMPlanProcess.Assign_Case_To__c=null;
                 objPMPlanProcess.Case_Assign_To_User__c=null;
                 objPMPlanProcess.Case_Assign_To_Queue__c=null;
            }
            if(objPMPlanProcess.Assign_Case_To__c == 'User')
              objPMPlanProcess.Case_Assign_To_Queue__c=null;
              
            if(objPMPlanProcess.Assign_Case_To__c == 'Queue')
             objPMPlanProcess.Case_Assign_To_User__c=null;
            
            if(objPMPlanProcess.SVMXC__SM_Do_Not_Create_New_WO__c){
                objPMPlanProcess.SVMXC__SM_Do_Not_Create_WO_Within__c = 0;
            }
        
            if(strSelectedExp != getTAG009())
                objPMPlanProcess.SVMXC__Module__c = strSelectedExp;
            else
                objPMPlanProcess.SVMXC__Module__c = null;
                
            if(strCreateWorkOrder != getTAG009())
                objPMPlanProcess.SVMXC__Create_Work_Order__c = strCreateWorkOrder;
            else
                objPMPlanProcess.SVMXC__Create_Work_Order__c = null;
            
            if(strSelectedWOmap != getTAG009())
                objPMPlanProcess.SVMXC__Node_Parent__c = strSelectedWOmap;
            else
                objPMPlanProcess.SVMXC__Node_Parent__c =null;
            
            if(isLocationCovered && strSelectedLocMap != getTAG009())
                objPMPlanProcess.SVMXC__Process3__c = strSelectedLocMap;
            else
                objPMPlanProcess.SVMXC__Process3__c =null;
            // 19 Oct; Anchal
            // Save the selected Object mappings for Schedule Definition to Case/Work Order
                
            if(strSelectedSDWOMap != getTAG009())
                objPMPlanProcess.SVMXC__Submodule__c = strSelectedSDWOMap;
            else
                objPMPlanProcess.SVMXC__Submodule__c =null;
            
            
            if(strSelectedCasemap != getTAG009())
                objPMPlanProcess.SVMXC__Process__c = strSelectedCasemap;
            else
                objPMPlanProcess.SVMXC__Process__c =null;
                
            if(objPMPlanProcess.Assign_Case_To__c ==getTAG009() || objPMPlanProcess.Assign_Case_To__c =='')
            {
                objPMPlanProcess.Assign_Case_To__c = null;
                objPMPlanProcess.Case_Assign_To_User__c=null;
                objPMPlanProcess.Case_Assign_To_Queue__c=null;
            }
            if(strSelectedQueueforWO!=null && strSelectedQueueforWO!='')
                objPMPlanProcess.Assign_To_Queue__c=strSelectedQueueforWO;
                
            if(strSelectedQueueforCase!=null && strSelectedQueueforCase!='')
                objPMPlanProcess.Case_Assign_To_Queue__c=strSelectedQueueforCase;            
            
            if(strSelectedTaskObject  == 'Task' &&  strSelectedTaskObject == getTAG009())      
                strSelectedWORefField = getTAG009();
            if(strSelectedWORefField == getTAG009())
                objPMPlanProcess.SVMXC__APL_Field_Name__c =null;
                
            else
                objPMPlanProcess.SVMXC__APL_Field_Name__c = strSelectedWORefField; 
                          
             // SK this is for lagacy defect BAC -3855 
              if (strcreateWOndaysBefore == NULL || strcreateWOndaysBefore==''){
               strcreateWOndaysBefore = '0';
               }
               
            objPMPlanProcess.Frequency__c = integer.valueof(strcreateWOndaysBefore);
            if(strSelectedTaskObject ==getTAG009() )
                objPMPlanProcess.SVMXC__Target_Object_Name__c = null;
            else
                objPMPlanProcess.SVMXC__Target_Object_Name__c = strSelectedTaskObject;
            if(strSelectedTaskmap == getTAG009() )
               objPMPlanProcess.SVMXC__Process1__c = null;  
            else
                objPMPlanProcess.SVMXC__Process1__c = strSelectedTaskmap;  
            if(strSelectedReqPartsmap ==getTAG009() )     
                objPMPlanProcess.SVMXC__Process2__c = null ;   
            else
                objPMPlanProcess.SVMXC__Process2__c = strSelectedReqPartsmap ; 
                
            objPMPlanProcess.SVMXC__Active__c = isActive;
            /* Not required as suggested by PM
            objPMPlanProcess.SVMXC__Match_Location__c = isLocationCovered; */
            objPMPlanProcess.SVMXC__Dispatch_Timezone__c = strSelectedTimeZone ;
            //upsert objPMPlanProcess;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(objPMPlanProcess, COMM_SecurityUtils.Access.Upsertable)){
                upsert objPMPlanProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return;
            }
            
            if(lstSchedules_toDelete != null && lstSchedules_toDelete.size() > 0)
                delete lstSchedules_toDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstSchedules_toDelete.clear();
            
            
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            if(lstSchedules != null && lstSchedules.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules)
                {
                    if(configdata.SVMXC__Run_At__c== getTAG009() ||configdata.SVMXC__Run_At__c== '')
                        {
                            configdata.SVMXC__Run_Type__c=null;
                            configdata.SVMXC__Schedule_Days__c=null;
                            configdata.SVMXC__Day_to_Run__c=null;
                        }
                    if(configdata.SVMXC__Run_Type__c=='Day of Week')
                        if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009() && configdata.SVMXC__Schedule_Days__c != null && configdata.SVMXC__Schedule_Days__c != '' && configdata.SVMXC__Schedule_Days__c !=getTAG009() && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                        {
                             //system.debug(LoggingLevel.WARN,'Day to run  '+configdata.SVMXC__Day_to_Run__c+'  Dispatch Process id: '+objPMPlanProcess.Id+'  Schedule Days:'+ configdata.SVMXC__Schedule_Days__c);
                            configdata.SVMXC__Day_to_Run__c=null;
                            configdata.RecordTypeId = Schedule_Rtype_Id;
                            configdata.SVMXC__Dispatch_Process__c = objPMPlanProcess.Id;
                            lstConfigdataToSave.add(configdata);
                        }
                    if(configdata.SVMXC__Run_Type__c=='Date of Month')
                        if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009() && configdata.SVMXC__Day_to_Run__c != null && configdata.SVMXC__Day_to_Run__c != '' && configdata.SVMXC__Day_to_Run__c !=getTAG009()  && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                        {
                            //system.debug(LoggingLevel.WARN,'Day to run  '+configdata.SVMXC__Day_to_Run__c+'  Dispatch Process id: '+objPMPlanProcess.Id+'  Schedule Days:'+ configdata.SVMXC__Schedule_Days__c);
                            configdata.SVMXC__Schedule_Days__c=null;
                            configdata.RecordTypeId = Schedule_Rtype_Id;
                            configdata.SVMXC__Dispatch_Process__c = objPMPlanProcess.Id;
                            lstConfigdataToSave.add(configdata);
                        }
                }
            }
            //system.debug(LoggingLevel.WARN,'Config data to save '+lstConfigdataToSave);
            if(lstConfigdataToSave != null && lstConfigdataToSave.size() > 0){
                 /*
                    SECSCAN-822 : Security Fix
                */
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigdataToSave, COMM_SecurityUtils.Access.Upsertable)){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return;
                }
                upsert lstConfigdataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            
            }
             
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,getTAG041(),''));
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG056(),''));
        }
    }
    //----------------------------------------------Validation----------------------------------------------------------------
    public void validation()
    {

        //Jira Defect :BAC-2640
        if(objPMPlanProcess.SVMXC__SM_Process_Type__c == 'CONDITION_BASED_PM' && !objPMPlanProcess.SVMXC__SM_Do_Not_Create_New_WO__c && objPMPlanProcess.SVMXC__SM_Do_Not_Create_WO_Within__c == null){
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.CONF036_TAG049 + ':' + System.Label.SFM002_TAG039) );
        }

        if(strProcessType == 'SVMX.NONE'){
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG053(),''));
        }
        if(strProcessName == null || strProcessName == '')
        {
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG053(),''));
        }
        //system.debug(LoggingLevel.WARN,'Process ID:  '+strProcessID);
        if(strProcessID == null || strProcessID == '' ||strProcessID.length() < 8)
        {
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG055(),''));
        }
        
        
        
        if(objPMPlanProcess.SVMXC__Email_On_Error__c == null || objPMPlanProcess.SVMXC__Email_On_Error__c.length() == 0)
        {
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG073(),''));
        }
        
        
        List<SVMXC__ServiceMax_Processes__c> LstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId = strProcessID;
        string SCONID;
        if(objPMPlanProcess.get('Id') == null)
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId and RecordTypeId =: strPMplan_RtypeID');
        else
        {
            SCONID = objPMPlanProcess.Id;
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId and RecordTypeId =: strPMplan_RtypeID AND Id !=: SCONID');
        }
        //system.debug(LoggingLevel.WARN,' List of Id to check:  '+LstToCheckId);
        if(LstToCheckId != null && LstToCheckId.size() > 0)
        {
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG055(),''));
        }
        
        if(strSelectedWOmap==getTAG009())
        {
            isValid= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG074(),''));
        }
        
        if(strSelectedLocMap==getTAG009())
        {
            isValid= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG074(),''));
        }
        
        
        if(strSelectedTaskObject != getTAG009() && strSelectedTaskmap == getTAG009())
        {
            isValid= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG084(),''));
        }
        if(strSelectedTaskObject != getTAG009() && strSelectedTaskObject  != 'Task' && strSelectedWORefField == getTAG009())
        {
            isValid= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG085(),''));
        }
      
        if(objPMPlanProcess.Include_Parent__c==true)
            if(strSelectedCasemap==getTAG009())
            {
                isValid= false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG054(),''));
            }
        if(strAssignWOto == 'Dispatcher')
        {
            if(objPMPlanProcess.Assign_To_Dispatcher__c==null)
            {
                isvalid=false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
        }
        if(strAssignWOto == 'Technician')
        {
            if(objPMPlanProcess.Assign_To_Technician__c==null)
            {
                isvalid=false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
            //system.debug(LoggingLevel.WARN,'Assign To Technician'+objPMPlanProcess.Assign_To_Technician__c);
            if(objPMPlanProcess.Assign_To_Technician__c != null)
            {
                SVMXC__Service_Group_Members__c lsttechrec = new SVMXC__Service_Group_Members__c();
                lsttechrec = [Select id, SVMXC__Active__c,SVMXC__Salesforce_User__c,SVMXC__Salesforce_User__r.isactive from SVMXC__Service_Group_Members__c where id =: objPMPlanProcess.Assign_To_Technician__c limit 1];
                
                if(lsttechrec != null && (!lsttechrec.SVMXC__Active__c))
                {
                    isvalid=false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG077()));
                }
                
                 if(lsttechrec != null && lsttechrec.SVMXC__Salesforce_User__c != null && (!lsttechrec.SVMXC__Salesforce_User__r.isactive))
                {
                    isvalid=false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG077()));
                }
            }
            
        }
        if(strAssignWOto == 'Queue')
        {
            if(strSelectedQueueforWO==null || strSelectedQueueforWO==getTAG009() || strSelectedQueueforWO=='')
            {
                isvalid=false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
        }
        if(strAssignWOto == 'Team')
        {
            if(objPMPlanProcess.Assign_To_Service_Team__c==null)
            {
                isvalid=false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG076()));
            }
        }
        
        if(objPMPlanProcess.Assign_Case_To__c == 'User')
        {
             if(objPMPlanProcess.Case_Assign_To_User__c==null)
            {
                isvalid=false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG027()));
            }
        }
        if(objPMPlanProcess.Assign_Case_To__c == 'Queue')
        {
          if(strSelectedQueueforCase==null || strSelectedQueueforCase==getTAG009() || strSelectedQueueforCase=='')
            {
                isvalid=false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG027()));
            }
        }
        
        //---------------------------------------------- Validation for the Schedules -----------------------------------------------------------
        if(lstSchedules != null && lstSchedules.size()>0)
        {
            for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules)
            {
                if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009()) 
                {
                    if(configdata.SVMXC__Run_Type__c ==getTAG009() || configdata.SVMXC__Run_Type__c == null || configdata.SVMXC__Run_Type__c == '' )
                    {
                        isValid=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG075()));
                    }
                    if(configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                    {
                         if(configdata.SVMXC__Run_Type__c=='Day of Week')
                            if(configdata.SVMXC__Schedule_Days__c == null || configdata.SVMXC__Schedule_Days__c == '' || configdata.SVMXC__Schedule_Days__c ==getTAG009()) 
                            {
                                isValid=false;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG075()));
                            }
                          if(configdata.SVMXC__Run_Type__c=='Date of Month')
                            if(configdata.SVMXC__Day_to_Run__c == null || configdata.SVMXC__Day_to_Run__c == '' || configdata.SVMXC__Day_to_Run__c ==getTAG009())
                            {
                                isValid=false;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG075()));
                            }
                    }
                }
                
                
            }
        }
   
         
        Set<String> setAllRunAtRec = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c ScheduleRec :lstSchedules)
        {
            if(ScheduleRec.SVMXC__Run_Type__c == 'Day of Week')
            {   
                list<string> LstScheduleDays = new list<string>();
                if(ScheduleRec.SVMXC__Schedule_Days__c != null)
                LstScheduleDays = ScheduleRec.SVMXC__Schedule_Days__c.split(';',7);
                for(string str: LstScheduleDays)
                {
                    if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + str))
                    {
                        isValid=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG090()+ ' ' + ScheduleRec.SVMXC__Run_At__c));
                        break;
                    }
                    else
                        setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + str);
                }
            }
            else
            {
                if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + ScheduleRec.SVMXC__Day_to_Run__c))
                {
                    isValid=false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG090()+ ' ' + ScheduleRec.SVMXC__Run_At__c));
                    break;
                }
                else
                    setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + ScheduleRec.SVMXC__Day_to_Run__c);
            }
        }
   
  
    }
    
    public void saveExps()
    {
        APL_Utils APLUtilObj = new APL_Utils();
        if(ExpPM != null && ExpPM.namedExpression.SVMXC__IsStandard__c != true && ((strSelectedExp != getTAG009() && strSelectedExp != null) || isCreateNewExp == true))
        {
            for(integer i=0; i < ExpPM.expressionDetails.size(); i++)
                ExpPM.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__c';
            ExpPM.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpPM.expressionDetails);
            Exp = ExpPM;
            intDetailSize = intExpDetailSize;
            submitExp();
            if(isValid == true)
            {
                preparingPicklists();
                strSelectedExp = ExpPM.namedExpression.Id;
            }
        }
    }
    
    public String savedExpressionResultId;
    public String getsavedExpressionResultId() { return savedExpressionResultId;}
    public void setsavedExpressionResultId(String val){this.savedExpressionResultId = val;}
    
    //------------------------------------------------Method to save One Expression----------------------------------------------------------------------
    public void submitExp()
    {
        if(Exp.namedExpression != null && Exp.namedExpression.SVMXC__Name__c != null && (Exp.namedExpression.SVMXC__Name__c).length() > 0 &&  Exp.namedExpression.SVMXC__ProcessID__c != null && (Exp.namedExpression.SVMXC__ProcessID__c).length() > 0 )
        {
            SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
            try
            {
                Exp.namedExpression.SVMXC__SettingId__c = Exp.namedExpression.SVMXC__ProcessID__c;
                List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :Exp.expressionDetails)
                {
                    if(expressiondtlRec.SVMXC__Operator__c != null && expressiondtlRec.SVMXC__Operator__c != 'SVMX.NONE' && expressiondtlRec.SVMXC__Field_Name__c != 'None' && expressiondtlRec.SVMXC__Field_Name__c != 'SVMX.NONE')
                        ExpressionDetails2Save.add(expressiondtlRec);
                }
                Exp.expressionDetails.clear();
                if(ExpressionDetails2Save.size()>0)
                    Exp.expressionDetails.addAll(ExpressionDetails2Save);
                intDetailSize = Math.Round(Exp.expressionDetails.size());
                
                if(intDetailSize >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(Exp.namedExpression,Exp.expressionDetails);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
                    Save_Response = saveExp.SFM_saveExpression(oRequest);
                    
                    if( Save_Response != null && Save_Response.success != null)
                    {
                        if(Boolean.valueOf(Save_Response.success))
                        {
                            if( Save_Response.resultIds != null && Save_Response.resultIds.size() > 0 )
                            {
                                savedExpressionResultId = Save_Response.resultIds[0];
                                setsavedExpressionResultId(Save_Response.resultIds[0]);
                            }
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
                            isValid = false;
                            HdrADDRow(); //Method called to add row
                            HdrADDRow(); //Method called to add row
                        }
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG056()));
                        isValid = false;
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG057()));
                    isValid = false;
                    HdrADDRow(); //Method called to add row
                    HdrADDRow(); //Method called to add row
                }   
            }
            catch(Exception ex)
            {
                if( Save_Response != null && Save_Response.message != null && Save_Response.success == false )
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+Save_Response.message + ': ' + ex.getmessage()));
                    isValid = false;
                }
            }
        }
        else
        {
            if( Exp.namedExpression == null || Exp.namedExpression.SVMXC__Name__c == null || Exp.namedExpression.SVMXC__Name__c == '' || (Exp.namedExpression.SVMXC__Name__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG058()));
                isValid = false;
            }
            if( Exp.namedExpression == null || Exp.namedExpression.SVMXC__ProcessID__c == null || Exp.namedExpression.SVMXC__ProcessID__c == '' || (Exp.namedExpression.SVMXC__ProcessID__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG059()));
                isValid = false;
            }
        }
    }
    
    //----------------------------------------- Method to retrieve Expression Details ---------------------------------------------
    public SFM_WrapperDef.SFM_Response_Expression retrieveExpDetails(string expId)
    {
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('EXPRESSIONID',expId);
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        responseExp = namedExpLst.SFM_getNamedExpressionList(request2);
        
        return responseExp;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria  --------------------------------
    public void onChngExp()
    {
        isCreateNewExp = false;
        isRenderExpBlock = false;
        if(strSelectedExp != getTAG009())
        {
            isDisableEditLink = false;
            responseExp = retrieveExpDetails(strSelectedExp);
            if(responseExp.expressions.size() > 0)
            {
                ExpPM = responseExp.expressions[0];
                intExpDetailSize = ExpPM.expressionDetails.size();
                Map_SeqNumRecExp.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpPM.expressionDetails)
                {
                    Map_SeqNumRecExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            isDisableEditLink = true;
    }
    
    //----------------------------------------- View/Edit  Expression---------------------------------------------
    public void EditExp()
    {
        isRenderExpBlock = true;
    }
    
    //----------------------------------------- New Criteria Expression ---------------------------------------------
    public void NewExp()
    {
        isCreateNewExp = true;
        strSelectedExp = getTAG009();
        isDisableEditLink = true;
        isRenderExpBlock = true;
        ExpPM = new SFM_WrapperDef.SFM_Expression();
        ExpPM.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpHdr_Rtype_Id, SVMXC__Source_Object_Name__c = 'SVMXC__PM_Plan__c');ExpPM.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpHdr_Rtype_Id, SVMXC__Source_Object_Name__c = 'SVMXC__PM_Plan__c');
        ExpPM.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpPM.expressionDetails != null)
            intExpDetailSize = ExpPM.expressionDetails.size();
        else
            intExpDetailSize = 0;
        Exp = ExpPM;
        intDetailSize = intExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecExp.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecExp);
        HdrADDRow();        
        ExpPM = Exp;
        intExpDetailSize = intDetailSize;
        Map_SeqNumRecExp.clear();
        Map_SeqNumRecExp.putAll(Map_SeqNumRec);
    }
    
    
    //----------------------------------------- Delete Row to Expression  ---------------------------------------------
    public PageReference HdrDeleteRowExp()
    {
        Exp = ExpPM;
        intDetailSize = intExpDetailSize;
        Map_SeqNumRec.clear();
        Map_SeqNumRec.putAll(Map_SeqNumRecExp);
        HdrDeleteRow();
        Map_SeqNumRecExp.clear();
        Map_SeqNumRecExp.putAll(Map_SeqNumRec);
        intExpDetailSize = intDetailSize;
        ExpPM = Exp;
        return null;
    }
    
    //----------------------------------------- Add Row to Expression ---------------------------------------------
    public PageReference HdrADDRowExp()
    {
        Exp = ExpPM;
        intDetailSize = intExpDetailSize;
        Map_SeqNumRec.clear();
        if(Map_SeqNumRecExp.size() > 0)
            Map_SeqNumRec.putAll(Map_SeqNumRecExp);
        HdrADDRow();
        intExpDetailSize = intDetailSize;
        Map_SeqNumRecExp.clear();
        Map_SeqNumRecExp.putAll(Map_SeqNumRec);
        ExpPM = Exp;
        return null;
    }
    
    
    //-------------------------------------- Methods to add row of Expression details -------------------------------------------------------
    public void HdrADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpDtl_Rtype_Id, SVMXC__Sequence__c = Integer.valueOf( Exp.expressionDetails.size() + 1 ) );
            
            Map_SeqNumRec.put( Math.Round(Integer.valueOf( Exp.expressionDetails.size() + 1 )), NewExpDetailRec );
            Exp.expressionDetails.add( NewExpDetailRec );
            if(strMode=='New')
            {
                NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpDtl_Rtype_Id, SVMXC__Sequence__c = Integer.valueOf( Exp.expressionDetails.size() + 1 ) );
                Map_SeqNumRec.put( Math.Round(Integer.valueOf( Exp.expressionDetails.size() + 1 )), NewExpDetailRec );
                Exp.expressionDetails.add( NewExpDetailRec );
                
            }
            
            if(Exp.expressionDetails != null)
                intDetailSize = Exp.expressionDetails.size();
            else
                intDetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //---------------------------- Methods to delete row of Expression details ------------------------------------------
    public void HdrDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < Exp.expressionDetails.size(); i++ )
            {
                if( Map_SeqNumRec != null && Map_SeqNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SeqNumRec.put( i + 1 - SeqNumToSubtract, Exp.expressionDetails[i] );
                else if ( Map_SeqNumRec != null && Map_SeqNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SeqNumRec.clear();
            if( TempMap_SeqNumRec != null )
                Map_SeqNumRec.putAll(TempMap_SeqNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SeqNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SeqNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SeqNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            Exp.expressionDetails.clear();
            Exp.expressionDetails.addAll(Temp_ExpDetailsLst);
            if(Exp.expressionDetails != null)
                intDetailSize = Exp.expressionDetails.size();
            else
                intDetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public pagereference lstSchedules_AddRow()
    {
        lstSchedules.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Schedule_Rtype_Id,SVMXC__Run_Type__c='Day of Week', SVMXC__Sequence__c = lstSchedules.size() + 1 ));     
        
        return null;
    }
    
    public pagereference lstSchedules_DelRow()
    {
        if(lstSchedules == null || (lstSchedules != null && !(lstSchedules.size() > 0)))
            return null;
        Integer tempDeletedIndex = Integer.valueOf(strSelectedRow) - 1;
        if(lstSchedules[tempDeletedIndex] != null && lstSchedules[tempDeletedIndex].get('Id') != null)
            lstSchedules_toDelete.add(lstSchedules[tempDeletedIndex]);
        lstSchedules.remove(tempDeletedIndex);
        for(integer i=0; i< lstSchedules.size(); i++)
            lstSchedules[i].SVMXC__Sequence__c = i + 1;
        return null;
    }
    
    //-----------------------------------------------Method to validate string --------------------------------------------------------
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    //--------------------------------------------- Method to display exceptions ------------------------------------------------------
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, ''));
    }
    
    //------------------------------------- Methods To Switch Between Tabs -----------------------------------------   
    public void GeneralInfo()
    {
        strSelectedTab = 'SVMX_TAB1';
    }
   
    public void SrcUpd()
    {
        strSelectedTab = 'SVMX_TAB2';
    }
    public void Schedules()
    {
        strSelectedTab = 'SVMX_TAB3';
    }
    
      //------------------------------------- Getter methods for the custom labels ----------------------------------
        
        public string getHLPURL() {return system.label.CONF036_HLPURL;} //http://userdocs.servicemax.com:8080/ServiceMaxHelp/Summer12/en_us/svmx_redirector.htm?uid=
        public string getHLPTITLE() {return system.label.COMM001_TAG064;} // 'Help'
        public string getTAG001(){return system.label.CONF036_TAG003;}// 'Setup Preventive Maintenance Process'
        public string getTAG002(){return system.label.COMM001_TAG053;} // 'Quick Save'
        public string getTAG003(){return system.label.COMM001_TAG054;}  // 'Save & Close'
        public string getTAG004(){return system.label.COMM001_TAG040;}  // 'Cancel'
        public string getTAG005(){return system.label.COMM001_TAG072;}// 'General Info'
        public String getTAG006() {return system.label.CONF036_TAG010;}//   'Field map to use'
        public string getTAG007(){return system.label.CONF036_TAG005;}//'Work Order Rules'   
        public string getTAG008(){return system.label.COMM001_TAG075;}// 'Schedule & Notifications'
        public string getTAG009(){return system.label.COMM002_TAG005;} //'--None--'
        public string getTAG010(){return system.label.COMM001_TAG055;} // 'Process Name'
        public string getTAG011(){return system.label.COMM001_TAG056;}  // 'Process Id'
        public string getTAG012(){return system.label.COMM001_TAG017;} // 'Description'
        public string getTAG013(){return system.label.CONF036_TAG004;}//'Using the expression-builder below, indicate how Preventive Maintenance Plan records qualify for Work Order creation'   
        public string getTAG014(){return system.label.COMM002_TAG031;} // 'Use an existing criteria from the list'
        public string getTAG015(){return system.label.COMM002_TAG037;}// 'View/Edit'
        public string getTAG016(){return system.label.COMM002_TAG036;} // Create New
        public string getTAG017(){return system.label.COMM001_TAG041;}  // 'Processing...'
        public string getTAG018(){return system.label.COMM002_TAG025;} // 'Expression Name'
        public string getTAG019(){return system.label.COMM002_TAG026;}  // 'Expression ID'
        public string getTAG020(){return system.label.COMM002_TAG027;} // 'Field Name'
        public string getTAG021(){return system.label.COMM002_TAG028;}  // 'Operator'
        public string getTAG022(){return system.label.COMM002_TAG029;} // 'Value'
        public string getTAG023(){return system.label.COMM002_TAG032;} // 'Add Row'
        public string getTAG024(){return system.label.COMM002_TAG033;}  // 'Delete Row'
        public string getTAG025(){return system.label.COMM002_TAG024;} // 'Advanced Expression'
        public string getTAG026(){return system.label.CONF036_TAG007;}//'Number of Work Orders'   
        public string getTAG027(){return system.label.CONF036_TAG029;}//'Insufficient information to assign Case'  
        public string getTAG028(){return system.label.CONF036_TAG011;}//'Assign To'  
        public String getTAG029() {return system.label.CONF036_TAG017;}//'Create Case'  
        public string getTAG030(){return system.label.CONF036_TAG006;}// 'Mapping & Rules to Create Work Order'         
        public string getTAG031(){return system.label.CONF036_TAG016;}//'Case Creation On Work Order'  
        public String getTAG032() {return system.label.CONF036_TAG021;}//'Create Work Order 'n' days before scheduled date'  
        public string getTAG033(){return system.label.CONF036_TAG024;}//'Create an activity in PM Plan if errors occur in execution'  
        public string getTAG034(){return system.label.CONF036_TAG023;}//'Create an activity in PM Plan upon successful execution'
        public String getTAG035() {return system.label.CONF036_TAG018;}//'User'
        public String getTAG036() {return system.label.CONF036_TAG013;}//'Queue' 
        public String getTAG037() {return system.label.CONF036_TAG015;}//'Technician' 
        public String getTAG038() {return system.label.CONF036_TAG014;}//'Team' 
        public String getTAG039() {return system.label.CONF036_TAG008;}//'One Per Plan' 
        public String getTAG040() {return system.label.CONF036_TAG009;}//'One Per Product' 
        public String getTAG041() {return system.label.COMM001_TAG058;}//'Record(s) saved successfully'
        public String getTAG042() {return system.label.CONF036_TAG012;}//'Dispatcher'  
        public string getTAG043(){return system.label.CONF036_TAG019;}//'Choose the times and days to run Preventive Maintenance Work Order Generation Engine for this process'
        public string getTAG044(){return system.label.COMM001_TAG078;}//Run At (GMT)
        public string getTAG045(){return system.label.COMM001_TAG079;}//'On These Days'
        public string getTAG046(){return system.label.COMM001_TAG080;}//'Available'
        public string getTAG047(){return system.label.COMM001_TAG081;}//'Chosen'
        public string getTAG048(){return system.label.COMM001_TAG086;}//'Specify recipents of notifications and alerts'
        public string getTAG049(){return system.label.COMM001_TAG082;}//'Send success notifications to this email address'
        public string getTAG050(){return system.label.COMM001_TAG083;}//'Send error notifications to this email address'
        public string getTAG051(){return system.label.COMM001_TAG087;}//'Enable Logging'
        public string getTAG052(){return system.label.COMM001_TAG084;}//'Insufficient parameters provided. Please contact your ServiceMax Administrator.'
        public string getTAG053(){return system.label.COMM001_TAG059;}//'Please enter values for all the mandatory fields'
        public String getTAG054() {return system.label.CONF036_TAG026;}//'Please enter Case Map to use'
        public string getTAG055(){return system.label.COMM001_TAG085;}//'Process ID must be unique and at least 8 characters long'
        public String getTAG056() {return system.label.COMM001_TAG077;}//'An unexpected error occurred. Please contact your ServiceMax Administrator.'
        public String getTAG057() {return system.label.COMM002_TAG004;} //'Invalid expression'
        public String getTAG058() {return system.label.COMM002_TAG034;}//'Please enter Expression Name'
        public String getTAG059() {return system.label.COMM002_TAG035;}//'Please enter unique Expression Id which is at least 8 characters long'
        public String getTAG060() {return system.label.COMM002_TAG006;}//Equals
        public String getTAG061() {return system.label.COMM002_TAG007;}//Not Equal
        public String getTAG062() {return system.label.COMM002_TAG008;}//Greater Than
        public String getTAG063() {return system.label.COMM002_TAG009;}//Greater or Equal To
        public String getTAG064() {return system.label.COMM002_TAG010;}//Less Than
        public String getTAG065() {return system.label.COMM002_TAG011;}//Less or Equal To
        public String getTAG066() {return system.label.COMM002_TAG012;}//Starts With
        public String getTAG067() {return system.label.COMM002_TAG013;}//Contains
        public String getTAG068() {return system.label.COMM002_TAG014;}//Does Not Contain
        public String getTAG069() {return system.label.COMM002_TAG015;}//Includes
        public String getTAG070() {return system.label.COMM002_TAG016;}//Excludes
        public String getTAG071() {return system.label.COMM002_TAG022;}//Is Null
        public String getTAG072() {return system.label.COMM002_TAG023;}//Is Not Null
        public String getTAG073() {return system.label.CONF036_TAG039;}// Please enter a valid email address for error notifications
        public String getTAG074() {return system.label.CONF036_TAG025;}//Please enter Work Order Map to use        
        public String getTAG075() {return system.label.CONF036_TAG027;}//Insufficient time and day information to run PM Engine'
        public String getTAG076() {return system.label.CONF036_TAG028;}//Insufficient information to assign Work Order
        public String getTAG077() {return system.label.CONF036_TAG022;}//'Technician is inactive. Please choose an active Technician'
        public String getTAG078() {return system.label.CONF036_TAG020;}//Schedule Threshold Definition
        public String getTAG079() {return system.label.CONF036_TAG030;} //Select task object
        public String getTAG080() {return system.label.CONF036_TAG031;} //Task map to use
        public String getTAG081() {return system.label.CONF036_TAG032;} //Work Order reference field
        public String getTAG082() {return system.label.CONF036_TAG033;} //Required Parts map to use
        public String getTAG083() {return system.label.CONF036_TAG034;} //Please select task object
        public String getTAG084() {return system.label.CONF036_TAG035;} //Please select task map
        public String getTAG085() {return system.label.CONF036_TAG036;}//Please select Work Order reference field
        public String getTAG086() {return  system.label.CONF036_TAG037;}//Please select Required Parts map
        public String getTAG087(){return system.label.COMM001_TAG016;}
        public String getTAG088() {return system.label.COMM001_TAG103;}//Time zone
        public String getTAG089() {return system.label.CONF036_TAG038;}// Mapping & Rules to create Task and Required Parts
        public String getTAG090() {return system.label.COMM001_TAG088;}  // ' has been entered twice in schedule frequency list'
        public String getTAG091() {return system.label.CONF036_TAG040;} //'Field Map (Coverage Type: Location )';}
        public String getTAG092() {return system.label.CONF036_TAG041;}  //'Note: When the setting "Enabled Location based PM Plan" is True and there is a PM plan with Coverage Type set as "Location (Must have Location), then one Work Order will be created per covered location.';}  //CONF036_TAG040
        public String getTAG093() {return system.label.CONF036_TAG042;}

        public String getTAG094() {return System.label.CONF036_TAG044;}
        public String getTAG095() {return System.label.CONF036_TAG045;}
        public String getTAG096() {return System.label.CONF036_TAG046;}
        public String getTAG097() {return System.Label.CONF036_TAG050;} 
        public String getTAG098() {return System.Label.CONF036_TAG048;}
        public String getTAG099() {return System.Label.CONF036_TAG049;}

}