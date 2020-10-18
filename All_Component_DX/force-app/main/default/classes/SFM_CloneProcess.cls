/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 *
 *
 *
 * @author
 * @version
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                Mar 2018        Created cloneProcess_V2 Method for Designer 2.0
 *
 *****************************************************************************************************/
public with sharing class SFM_CloneProcess {
    
    public SVMXC.SFM_WrapperDef.SFM_Response_ProcessNodeInfo ProcessNodeInfo = new SVMXC.SFM_WrapperDef.SFM_Response_ProcessNodeInfo();
    //Clone process details
    public SFM_WrapperDef.SFM_Response cloneProcess(SFM_WrapperDef.SFM_Request request)
    {
        String strREGEX = '[-~!@#$%^&*()+=|/{}:\\[\\]"\';<>,.?\\\\ ]';
        try{
            Boolean isSave = true;
            SVMXC.SFM_getProcessInfo getprocess = new SVMXC.SFM_getProcessInfo();
            list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            lstStringMap = request.stringMap;
            system.debug('Request object in clone is :' + request);
            if(lstStringMap.size() > 0)
            {
                for(integer i =0;i<lstStringMap.size();i++)
                {
                    if(lstStringMap[i].key != null && lstStringMap[i].key == 'INMEMORY')
                        isSave = false;
                }
            }
            ProcessNodeInfo = getprocess.getProcessInfo(request);
            Map<String, Id> objectRecType_Map = new Map<String, Id>();
            SFM_Utils utils = new SFM_Utils();
            List<String> recTypeNames = new List<String>();
            recTypeNames.add('SVMXC__ServiceMax_Processes__c~Target Manager');
            recTypeNames.add('SVMXC__ServiceMax_Processes__c~Process Node Objects');
            recTypeNames.add('SVMXC__ServiceMax_Processes__c~Process Business Rule');
            recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
            
            objectRecType_Map = utils.getRecordTypes(recTypeNames);
            SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();//member of SFM_Response_ProcessNodeInfo
            List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeSourceObject = new List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail>();//member of SFM_Response_ProcessNodeInfo
            List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeTargetObject = new List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail>();//member of SFM_Response_ProcessNodeInfo
            list<SVMXC__SFM_Event__c> lstSFMEvents = new list<SVMXC__SFM_Event__c>(); 
            SVMXC__ServiceMax_Processes__c CloneprocessNodes = new SVMXC__ServiceMax_Processes__c();
            List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail> CloneprocessNodeSourceObject = new List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail>();
            List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail> CloneprocessNodeTargetObject = new List<SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail>();
            list<SVMXC__SFM_Event__c> ClonelstSFMEvents = new list<SVMXC__SFM_Event__c>();
            if(processNodeinfo.processNodes != null)
               processNodes = processNodeinfo.processNodes;
            if(processNodeinfo.processNodeSourceObject != null)   
               processNodeSourceObject = processNodeinfo.processNodeSourceObject;
            if(processNodeinfo.processNodeTargetObject != null)   
               processNodeTargetObject = processNodeinfo.processNodeTargetObject;
            if(processNodeinfo.sfmEvents != null)
                lstSFMEvents = processNodeinfo.sfmEvents;
            if(processNodes != null)
            {
                CloneprocessNodes = processNodes.clone(false,true);
                CloneprocessNodes.SVMXC__Name__c = CloneprocessNodes.SVMXC__Name__c + ' ' + system.now();
                String strProcessId = CloneprocessNodes.SVMXC__ProcessID__c + ' '+ system.now();
                if(Pattern.matches('.*' + strREGEX + '.*', strProcessId)) {
                    strProcessId = strProcessId.replaceAll(strREGEX, '_');
                }
                CloneprocessNodes.SVMXC__ProcessID__c = strProcessId;
                CloneprocessNodes.SVMXC__IsStandard__c = false;
                CloneprocessNodes.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Target Manager');
            }   
            System.debug('processNodeSourceObjectTTT :'+processNodeSourceObject);
            if(processNodeSourceObject != null && processNodeSourceObject.size() > 0)
            {
                for(Integer i = 0;i<processNodeSourceObject.size();i++)
                {
                    SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail ProcessNodeDetail = new SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail();
                    ProcessNodeDetail = processNodeSourceObject[i];
                    SVMXC__ServiceMax_Processes__c processNodeObejct = new SVMXC__ServiceMax_Processes__c();
                    List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                    processNodeObejct = ProcessNodeDetail.processNodeObejct.clone(false,true);
                    //processNodeObejct.SVMXC__Name__c = processNodeObejct.SVMXC__Name__c + ' ' + system.now();
                    
                    //Neeraj(April-30th-2012): Splitted the process id of Process Node Objects records from space and added current timestamp to handle defect-004076
                    //processNodeObejct.SVMXC__ProcessID__c = processNodeObejct.SVMXC__ProcessID__c + ' '+ system.now();
                    string strTimeStamp = ' '+system.now();
                    if(processNodeObejct.SVMXC__ProcessID__c != null && processNodeObejct.SVMXC__ProcessID__c.length() > 0)
                        processNodeObejct.SVMXC__ProcessID__c = processNodeObejct.SVMXC__ProcessID__c.split(' ')[0] + strTimeStamp;
                    
                    processNodeObejct.SVMXC__IsStandard__c = false;
                    processNodeObejct.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                    if(ProcessNodeDetail.processSourceUpdates!=null)
                    for(Integer j = 0;j<ProcessNodeDetail.processSourceUpdates.size();j++)
                    {
                        SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        tempconfigdata = ProcessNodeDetail.processSourceUpdates[j].clone(false,true);
                        tempconfigdata.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                        processSourceUpdates.add(tempconfigdata);
                    }
                    CloneprocessNodeSourceObject.add(new SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObejct,processSourceUpdates));
                }
            }
            if(processNodeTargetObject.size() > 0)
            {
                for(Integer i = 0;i<processNodeTargetObject.size();i++)
                {
                    SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail ProcessNodeDetail = new SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail();
                    ProcessNodeDetail = processNodeTargetObject[i];
                    SVMXC__ServiceMax_Processes__c processNodeObejct = new SVMXC__ServiceMax_Processes__c();
                    List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                    List<SVMXC__ServiceMax_Processes__c> processBizRules = new List<SVMXC__ServiceMax_Processes__c>();
                    list<SVMXC__ServiceMax_Processes__c> lstlinkedProcesses = new list<SVMXC__ServiceMax_Processes__c>();
                    processNodeObejct = ProcessNodeDetail.processNodeObejct.clone(false,true);
                    //processNodeObejct.SVMXC__Name__c = processNodeObejct.SVMXC__Name__c + ' ' + system.now();
                    
                    //Neeraj(April-30th-2012): Splitted the process id of Process Node Objects records from space and added current timestamp to handle defect-004076
                     //processNodeObejct.SVMXC__ProcessID__c = processNodeObejct.SVMXC__ProcessID__c + ' '+ system.now();
                    string strTimeStamp = ' '+system.now();
                    if(processNodeObejct.SVMXC__ProcessID__c != null && processNodeObejct.SVMXC__ProcessID__c.length() > 0)
                        processNodeObejct.SVMXC__ProcessID__c = processNodeObejct.SVMXC__ProcessID__c.split(' ')[0] + strTimeStamp;
                    processNodeObejct.SVMXC__IsStandard__c = false;
                    processNodeObejct.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                    if(ProcessNodeDetail.processSourceUpdates!=null)
                    for(Integer j = 0;j<ProcessNodeDetail.processSourceUpdates.size();j++)
                    {
                        SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                        tempconfigdata = ProcessNodeDetail.processSourceUpdates[j].clone(false,true);
                        tempconfigdata.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                        processSourceUpdates.add(tempconfigdata);
                    }
                    //Clone Linked Processe..
                    if(ProcessNodeDetail.linkedProcesses != NULL && ProcessNodeDetail.linkedProcesses.size() > 0){
                        for(SVMXC__ServiceMax_Processes__c linkedPro : ProcessNodeDetail.linkedProcesses){
                            SVMXC__ServiceMax_Processes__c objLinkedProcess = new SVMXC__ServiceMax_Processes__c();
                            objLinkedProcess = linkedPro.clone(false,true);
                            lstlinkedProcesses.add(objLinkedProcess);
                        }
                    }
                    //Clone Process Business Rules
                    if(ProcessNodeDetail.processBizRules != NULL && ProcessNodeDetail.processBizRules.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Processes__c currProcessBizRule : ProcessNodeDetail.processBizRules)
                        {
                            SVMXC__ServiceMax_Processes__c ProcessBizRule = new SVMXC__ServiceMax_Processes__c();
                            ProcessBizRule = currProcessBizRule.clone(false,true);
                            ProcessBizRule.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Business Rule');
                            processBizRules.add(ProcessBizRule);
                        }
                    }
                    
                    SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail objProcessNodeDetail = new SVMXC.SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObejct,processSourceUpdates);
                    objProcessNodeDetail.processBizRules = processBizRules;
                    objProcessNodeDetail.linkedProcesses = lstlinkedProcesses;
                    CloneprocessNodeTargetObject.add(objProcessNodeDetail);
                }
            }
            if(lstSFMEvents != null && lstSFMEvents.size() > 0){
                for(SVMXC__SFM_Event__c objSFMEvent : lstSFMEvents){
                    SVMXC__SFM_Event__c ObjSFMEventCloned = new SVMXC__SFM_Event__c();
                    ObjSFMEventCloned = objSFMEvent.clone(false,true);
                    ObjSFMEventCloned.SVMXC__IsStandard__c = false;
                    ClonelstSFMEvents.add(ObjSFMEventCloned);
                }
            }
            if(isSave)
            {
                SVMXC.SFM_saveProcess saveprocess = new SVMXC.SFM_saveProcess();
                return saveprocess.saveProcess(new SVMXC.SFM_WrapperDef.SFM_Request_ProcessNodeInfo(CloneprocessNodes,CloneprocessNodeSourceObject,CloneprocessNodeTargetObject,ClonelstSFMEvents));
            }
            else
            {
                if(CloneprocessNodes != null)
                    processNodeinfo.processNodes = CloneprocessNodes;
                if(CloneprocessNodeSourceObject != null)   
                    processNodeinfo.processNodeSourceObject = CloneprocessNodeSourceObject;
                if(CloneprocessNodeTargetObject != null)   
                    processNodeinfo.processNodeTargetObject = CloneprocessNodeTargetObject;
                if(ClonelstSFMEvents != null)
                    processNodeinfo.sfmEvents = ClonelstSFMEvents;
                return null;    
            }
        }
        catch(exception ex ){}    
        return null;    
    }

    
    /**
     * This method is used to clone/Edit SFM Process for Designer 2.0
     * 
     * @param processIds : Process Id to be cloned.
     * 
     * @return Returns cloned ProcessInfo for the requested Id.
     */

    public SFM_WrapperDef2.SFM2_ProcessInfo cloneProcess_V2(List<String> processIds){
        
        System.debug(LoggingLevel.INFO, 'cloneProcess_V2 - Enter , processIds '  + processIds);
        
        SFM_WrapperDef2.SFM2_ProcessInfo processInfo;
        
        try{
            /*
                Security Check : To check if fields are accessible before querying
                Objects : SVMXC__ServiceMax_Processes__c, SVMXC__ServiceMax_Config_Data__c
            */


            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Rule_Type__c', 'SVMXC__Process2__c', 'SVMXC__Description__c', 'SVMXC__ProcessID__c', 'SVMXC__Purpose__c', 
                'SVMXC__Dispatch_Process_Status__c', 'LastModifiedDate', 'LastModifiedBy.Name', 'CreatedDate', 'CreatedBy.Name', 'SVMXC__IsStandard__c', 'SVMXC__Page_Layout__c', 'SVMXC__SM_Run_Targeted_Sync__c', 'SVMXC__Doc_Template__c',
                'SVMXC__Enable_Sub_Process__c', 'SVMXC__Sub_Process_Source_Field__c', 'SVMXC__Values__c', 'SVMXC__Sequence__c', 'SVMXC__Parent_Column_Name__c', 'SVMXC__SM_Disable_Realtime_Validation__c',
                'SVMXC__SM_Include_Skipped_Sections__c', 'SVMXC__SM_Exclude_Unanswered_Questions__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__Parent_Object__c', 'SVMXC__Node_Source_Object_API__c', 'SVMXC__Module__c', 'SVMXC__Submodule__c',
                'SVMXC__Target_Object_label__c', 'SVMXC__Type__c', 'SVMXC__Node_Parent_API__c', 'SVMXC__Final_Exception_Process__c', 'SVMXC__Final_Exception_Process__r.SVMXC__Name__c', 'SVMXC__Enable_Attachment__c', 'SVMXC__SM_Enable_Image__c', 'SVMXC__Parent_Error_Msg__c', 'SVMXC__Process1__c', 'SVMXC__Process2__r.SVMXC__Source_Object_Name__c', 'SVMXC__Process3__c',
                'SVMXC__Process3__r.SVMXC__Rule_Type__c'}, COMM_SecurityUtils.Access.Accessible )){

                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );

            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Config_Data__c', new List<String>{'Id','SVMXC__Dispatch_Process__c', 'SVMXC__Setting_ID__c', 'SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c', 'SVMXC__MapID__c',
                'SVMXC__Source_Field_Name__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Action__c', 'SVMXC__Action_Type__c', 'SVMXC__Display_Value__c', 'SVMXC__SM_Display_Value2__c'}, COMM_SecurityUtils.Access.Accessible)){

                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(processIds.size() == 1){
                List<SVMXC__ServiceMax_Processes__c> processList = [SELECT Id,  SVMXC__Name__c, SVMXC__Rule_Type__c, SVMXC__Process2__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Dispatch_Process_Status__c, LastModifiedDate, LastModifiedBy.Name, CreatedDate, CreatedBy.Name, SVMXC__IsStandard__c, SVMXC__Enable_Sub_Process__c, SVMXC__Sub_Process_Source_Field__c, SVMXC__Page_Layout__c, SVMXC__SM_Run_Targeted_Sync__c, SVMXC__Doc_Template__c, SVMXC__SM_Disable_Realtime_Validation__c,
                                    SVMXC__SM_Enable_Version_Control__c, SVMXC__SM_Display_File_Name__c, SVMXC__Export_Configuration__c, SVMXC__Tag_Keys__c, (SELECT Id, SVMXC__Values__c, SVMXC__Page_Layout__c, SVMXC__Sequence__c, SVMXC__Parent_Column_Name__c, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object__c, SVMXC__Parent_Object__r.SVMXC__Sequence__c, SVMXC__Node_Source_Object_API__c, SVMXC__Module__c, SVMXC__Submodule__c, SVMXC__Target_Object_label__c, SVMXC__Type__c,SVMXC__Node_Parent_API__c, SVMXC__Final_Exception_Process__c,
                                    SVMXC__Module__r.SVMXC__Name__c, SVMXC__Submodule__r.SVMXC__Name__c, SVMXC__Doc_Template_Details__c, SVMXC__Final_Exception_Process__r.SVMXC__Name__c, SVMXC__Enable_Attachment__c, SVMXC__SM_Enable_Image__c FROM ServiceMax_Processes3__r WHERE RecordType.Name = 'Process Node Objects'), (SELECT Id, SVMXC__Event_Call_Type__c, SVMXC__Event_Type__c, SVMXC__Namespace__c, SVMXC__Sequence__c, SVMXC__ServiceMax_Custom_Action__c FROM SFM_Events__r),
                                    SVMXC__SM_Include_Skipped_Sections__c, SVMXC__SM_Exclude_Unanswered_Questions__c, (SELECT Id, SVMXC__Dispatch_Process__c,SVMXC__Setting_ID__c,SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c, SVMXC__MapID__c, SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Action_Type__c, SVMXC__Display_Value__c, SVMXC__SM_Display_Value2__c, SVMXC__SM_Question__c FROM ServiceMax_Config_Data__r WHERE SVMXC__Configuration_Type__c = 'Source Update' AND RecordType.Name = 'Field Mapping')
                                    //(SELECT Id, SVMXC__Sequence__c, SVMXC__Namespace__c, SVMXC__Class__c, SVMXC__ServiceMax_Process__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__Event_Call_Type__c, SVMXC__Event_Type__c from SFM_Events__r)
                                    FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name='Target Manager' AND Id IN : processIds];

                if(processList.size() == 1 ){
                    SVMXC__ServiceMax_Processes__c processRecord = processList[0];
                    processInfo = new SFM_WrapperDef2.SFM2_ProcessInfo();
                    processInfo.targetManager = buildEntityDetail(processRecord);
                    processInfo.pageLayoutId = processRecord.SVMXC__Page_Layout__c;
                    processInfo.enableTargetedSync = processRecord.SVMXC__SM_Run_Targeted_Sync__c;
                    processInfo.enableRealTimeValidation = !processRecord.SVMXC__SM_Disable_Realtime_Validation__c;
                    processInfo.enableVersionControl = processRecord.SVMXC__SM_Enable_Version_Control__c;
                    processInfo.displayFileName = processRecord.SVMXC__SM_Display_File_Name__c;
                    processInfo.displayFileMetaData = processRecord.SVMXC__Export_Configuration__c;
                    processInfo.templateId = processRecord.SVMXC__Doc_Template__c;
                    processInfo.includeSkippedSections = processRecord.SVMXC__SM_Include_Skipped_Sections__c;
                    processInfo.excludeSkippedQuestions = processRecord.SVMXC__SM_Exclude_Unanswered_Questions__c;
                    processInfo.tagKeys = processRecord.SVMXC__Tag_Keys__c;

                    if(processRecord.SVMXC__Enable_Sub_Process__c){
                        processInfo.adv_SubProcessId = processRecord.SVMXC__Process2__c;
                        processInfo.adv_SubProcessSrcField = processRecord.SVMXC__Sub_Process_Source_Field__c;
                    }

                    List<SFM_WrapperDef2.SFM2_RuleExpression> expressionsList;
                    Map<Id, List<SFM_WrapperDef2.SFM2_RuleExpression>> sourceUpdateRuleMap = new Map<Id, List<SFM_WrapperDef2.SFM2_RuleExpression>>();

                    if( processRecord.ServiceMax_Config_Data__r.size() > 0 ) {
                    for(SVMXC__ServiceMax_Config_Data__c configRec : processRecord.ServiceMax_Config_Data__r){
                        expressionsList = new List<SFM_WrapperDef2.SFM2_RuleExpression>();

                        if(sourceUpdateRuleMap.containsKey(configRec.SVMXC__Setting_ID__c)){
                            expressionsList = sourceUpdateRuleMap.get(configRec.SVMXC__Setting_ID__c);
                        }

                        SFM_WrapperDef2.SFM2_RuleExpression ruleExpression = buildExpressionDetail(configRec);
                        expressionsList.add(ruleExpression);

                        sourceUpdateRuleMap.put(configRec.SVMXC__Setting_ID__c, expressionsList);
                        }
                    }

                    Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>> linkedProcessMap = new Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>>();
                    Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>> validationRulesNodeMap = new Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>>();
                    Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>> formulaRulesNodeMap = new Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>>();
                    Map<String, String> checklistRuleMap = new Map<String, String>();
                    List<SFM_WrapperDef2.SFM2_LinkedProcess> checklistProcessList = new List<SFM_WrapperDef2.SFM2_LinkedProcess>();

                        
                    for(SVMXC__ServiceMax_Processes__c linkedProcessRec : [SELECT Id, RecordType.Name, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c, SVMXC__Process2__c, 
                                                                                SVMXC__Process2__r.SVMXC__Name__c ,SVMXC__Process2__r.SVMXC__Source_Object_Name__c, SVMXC__Process3__c, SVMXC__Process3__r.SVMXC__Rule_Type__c, SVMXC__Sequence__c, 
                                                                                SVMXC__Name__c, SVMXC__SM_Checklist_Version__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name IN ('Linked Process', 'Process Business Rule', 'Checklist Smart Doc') 
                                                                                AND SVMXC__Process1__c IN : processIds]){

                        if(linkedProcessRec.Recordtype.Name == 'Linked Process'){
                            addToMap(linkedProcessMap, linkedProcessRec);
                        }

                        if(linkedProcessRec.Recordtype.Name == 'Process Business Rule'){

                            if(linkedProcessRec.SVMXC__Process3__c != null){
                                if(linkedProcessRec.SVMXC__Process3__r.SVMXC__Rule_Type__c == null){ //Validation Rules
                                    addToMap(validationRulesNodeMap, linkedProcessRec);
                                    
                                }else if(linkedProcessRec.SVMXC__Process3__r.SVMXC__Rule_Type__c == 'Field Update Rule'){ //Formulas
                                    addToMap(formulaRulesNodeMap, linkedProcessRec);
                                }else if(linkedProcessRec.SVMXC__Process3__r.SVMXC__Rule_Type__c == 'Checklist Criteria in Output Doc'){
                                    checklistRuleMap.put(linkedProcessRec.SVMXC__Process2__c, linkedProcessRec.SVMXC__Process3__c);
                                }
                            }
                        }
                        if(linkedProcessRec.Recordtype.Name == 'Checklist Smart Doc'){
                            if(linkedProcessRec.SVMXC__Process2__c != null){
                            SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess = new SFM_WrapperDef2.SFM2_LinkedProcess();
                            linkedProcess.checklistId = linkedProcessRec.SVMXC__Process2__c;
                            linkedProcess.checklistName = linkedProcessRec.SVMXC__Process2__r.SVMXC__Name__c;
                            linkedProcess.checklistVersion = linkedProcessRec.SVMXC__SM_Checklist_Version__c;
                            linkedProcess.processId = linkedProcessRec.Id;
                            checklistProcessList.add(linkedProcess);
                            }
                        }
                    }

                    List<SFM_WrapperDef2.SFM2_ProcessNode> processNodeList = new List<SFM_WrapperDef2.SFM2_ProcessNode>();

                    if( processRecord.ServiceMax_Processes3__r.size() > 0 ) {
                    //Process Nodes Records Mapping
                    for(SVMXC__ServiceMax_Processes__c processNodeRec : processRecord.ServiceMax_Processes3__r){
                        SFM_WrapperDef2.SFM2_ProcessNode processNode = setProcessNodeValues(processNodeRec);
                        
                        //To Check if attachment is enabled in advanced options
                        if(processNodeRec.SVMXC__Type__c != null && (processNodeRec.SVMXC__Type__c.equalsIgnoreCase('TARGET') || processNodeRec.SVMXC__Type__c.equalsIgnoreCase('TARGETCHILD'))){
                            
                            if(processNodeRec.SVMXC__Type__c.equalsIgnoreCase('TARGET')){
                                processInfo.adv_AttachmentEnabled = processNodeRec.SVMXC__Enable_Attachment__c;
                            }

                            processNode.sourceNodeId = processNodeRec.SVMXC__Parent_Object__c;

                                if(processNodeRec.SVMXC__Parent_Object__c != null && processNodeRec.SVMXC__Parent_Object__r.SVMXC__Sequence__c != null ) {
                                Integer sequence = Integer.valueOf(processNodeRec.SVMXC__Parent_Object__r.SVMXC__Sequence__c);
                                sequence = sequence < 100 ? sequence: (sequence - 100);
                                if(sequence != processNode.sequence){
                                    processNode.sequence = sequence;
                                }
                            }
                        }

                        if(sourceUpdateRuleMap.containsKey(processNodeRec.Id)){
                            SFM_WrapperDef2.SFM2_Rule sourceUpdateRule = new SFM_WrapperDef2.SFM2_Rule();
                            sourceUpdateRule.expressionsList = sourceUpdateRuleMap.get(processNodeRec.Id);
                            processNode.sourceUpdateRule = sourceUpdateRule;
                        }

                        if(linkedProcessMap != null && linkedProcessMap.containsKey(processNodeRec.Id)){
                            processNode.linkedProcessList = linkedProcessMap.get(processNodeRec.Id);
                        }

                        if(validationRulesNodeMap != null && validationRulesNodeMap.containsKey(processNodeRec.Id)){
                            processNode.validationRulesList = validationRulesNodeMap.get(processNodeRec.Id);
                        }

                        if(formulaRulesNodeMap != null && formulaRulesNodeMap.containsKey(processNodeRec.Id)){
                            processNode.formulasList = formulaRulesNodeMap.get(processNodeRec.Id);
                        }

                        processNodeList.add(processNode);
                        }
                    }

                    processInfo.processNodeList = processNodeList;                

                    for(SFM_WrapperDef2.SFM2_LinkedProcess checklistLinkedRecord : checklistProcessList){
                        if(checklistLinkedRecord.checklistId != null && checklistRuleMap.containsKey(checklistLinkedRecord.checklistId)){
                            checklistLinkedRecord.linkedProcessId = checklistRuleMap.get(checklistLinkedRecord.checklistId);
                        }
                    }
                    if( processRecord.SFM_Events__r.size() > 0 ) {
                    processInfo.events = eventListWrapper(processRecord.SFM_Events__r);
                    }
                    processInfo.checklistProcessList = checklistProcessList;
                    
                }  
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ' cloneProcess_V2 - Exception ' + ex.getStackTraceString() );
            throw ex;
        }   

        System.debug(LoggingLevel.ERROR, ' cloneProcess_V2 - Exit, Response: ' + processInfo);
        return processInfo;         
    }
    
    SFM_WrapperDef2.SFM2_ProcessNode setProcessNodeValues(SVMXC__ServiceMax_Processes__c processNodeRec){
        SVMXC.SFM_WrapperDef.FieldSetWithSorting deserializeAdvancedInfo = deserializeAdvancedOptionsInfo(processNodeRec.SVMXC__Values__c);
        SFM_WrapperDef2.SFM2_ProcessNode processNode = new SFM_WrapperDef2.SFM2_ProcessNode();
        processNode.nodeId = processNodeRec.Id;
        processNode.nodeType = processNodeRec.SVMXC__Type__c;
        processNode.objectLabel = processNodeRec.SVMXC__Target_Object_label__c;
        processNode.objectAPIName = processNodeRec.SVMXC__Source_Object_Name__c;
        processNode.nodeAPIName = processNodeRec.SVMXC__Node_Parent_API__c;
        processNode.nodeSourceAPIName = processNodeRec.SVMXC__Node_Source_Object_API__c;
        processNode.valueMappingId = processNodeRec.SVMXC__Final_Exception_Process__c;
        processNode.valueMappingName = processNodeRec.SVMXC__Final_Exception_Process__r.SVMXC__Name__c;
        processNode.pageDetailId = processNodeRec.SVMXC__Page_Layout__c;
        processNode.templateDetailId = processNodeRec.SVMXC__Doc_Template_Details__c;
        processNode.fieldMappingId = processNodeRec.SVMXC__Module__c;
        processNode.fieldMappingName = processNodeRec.SVMXC__Module__r.SVMXC__Name__c;
        processNode.qcRuleId = processNodeRec.SVMXC__Submodule__c;
        processNode.qcRuleName = processNodeRec.SVMXC__Submodule__r.SVMXC__Name__c;
        if( processNodeRec.SVMXC__Sequence__c != null ) {
        Integer sequence = Integer.valueOf(processNodeRec.SVMXC__Sequence__c);
        processNode.sequence = sequence < 100 ? sequence: (sequence - 100);
        }
        processNode.parentColumnAPIName = processNodeRec.SVMXC__Parent_Column_Name__c;
        // allow attachments and allow Images
        processNode.allowAttachments = processNodeRec.SVMXC__Enable_Attachment__c;
        processNode.allowImages = processNodeRec.SVMXC__SM_Enable_Image__c;
        
        if(deserializeAdvancedInfo != null){
            processNode.adv_SortingInfo = deserializeAdvancedInfo.lstSortingRec;
            processNode.fieldSets = deserializeAdvancedInfo.lstFieldSetAPIName;
        }        
        return processNode;             

    }

    SVMXC.SFM_WrapperDef.FieldSetWithSorting deserializeAdvancedOptionsInfo(String advancedInfoJson){
        
        if(advancedInfoJson != null){
            SVMXC.SFM_WrapperDef.FieldSetWithSorting deserializeAdvancedInfo = (SVMXC.SFM_WrapperDef.FieldSetWithSorting)JSON.deserialize(advancedInfoJson, SVMXC.SFM_WrapperDef.FieldSetWithSorting.class);
            return deserializeAdvancedInfo;
        }

        return null;
    }


    void addToMap(Map<Id, List<SFM_WrapperDef2.SFM2_LinkedProcess>> processMap, SVMXC__ServiceMax_Processes__c linkedProcessRec){
        
        System.debug(LoggingLevel.INFO, ' processMap :' + processMap);
        SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess = new SFM_WrapperDef2.SFM2_LinkedProcess();
        linkedProcess.targetNodeId = linkedProcessRec.SVMXC__Process2__c;
        linkedProcess.linkedProcessId = linkedProcessRec.SVMXC__Process3__c;
        linkedProcess.sequence = linkedProcessRec.SVMXC__Sequence__c != null ? Integer.valueOf(linkedProcessRec.SVMXC__Sequence__c): null;
        linkedProcess.linkedProcessName = linkedProcessRec.SVMXC__Name__c;
        linkedProcess.processId = linkedProcessRec.Id;
        linkedProcess.message = linkedProcessRec.SVMXC__Parent_Error_Msg__c;
        List<SFM_WrapperDef2.SFM2_LinkedProcess> linkedProcessList = new List<SFM_WrapperDef2.SFM2_LinkedProcess>();
        
        if(processMap.containsKey(linkedProcessRec.SVMXC__Process2__c)){
            linkedProcessList = processMap.get(linkedProcessRec.SVMXC__Process2__c);
        }

        linkedProcessList.add(linkedProcess);
        processMap.put(linkedProcessRec.SVMXC__Process2__c, linkedProcessList);        
    }

    SFM_WrapperDef2.SFM2_EntityDetail buildEntityDetail(SVMXC__ServiceMax_Processes__c processRecord ) {

        SFM_WrapperDef2.SFM2_EntityDetail headerDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        headerDetail.entityId = processRecord.Id;
        headerDetail.isStandard = processRecord.SVMXC__IsStandard__c;
        headerDetail.entityDescription = processRecord.SVMXC__Description__c;
        headerDetail.entityName = processRecord.SVMXC__Name__c;
        headerDetail.entitySubType = processRecord.SVMXC__Purpose__c;
        headerDetail.entityStatus = processRecord.SVMXC__Dispatch_Process_Status__c;
        headerDetail.lastModifiedDate = String.valueOfGmt(processRecord.LastModifiedDate);
        headerDetail.createdDate = String.valueOfGmt(processRecord.CreatedDate);
        headerDetail.createdBy = processRecord.CreatedBy.Name;
        headerDetail.lastModifiedBy = processRecord.LastModifiedBy.Name;
        List<String> entityIds = new List<String> { processRecord.Id};
        Map<String, List<String>> entityIdTagsMap = SFM_DesignerUtils.getSVMXTags(entityIds);
        if(entityIdTagsMap.containskey(processRecord.Id)){
            headerDetail.tagsList = entityIdTagsMap.get(processRecord.Id);
        }
        headerDetail.uniqueId = processRecord.SVMXC__ProcessID__c;
        
        return headerDetail;
    }

    SFM_WrapperDef2.SFM2_RuleExpression buildExpressionDetail(SVMXC__ServiceMax_Config_Data__c configRec) {
        SFM_WrapperDef2.SFM2_RuleExpression ruleExpression = new SFM_WrapperDef2.SFM2_RuleExpression();
        ruleExpression.expressionId = configRec.Id;
        ruleExpression.sourceObject = configRec.SVMXC__Setting_ID__r.SVMXC__Node_Source_Object_API__c;
        ruleExpression.sourceField = configRec.SVMXC__Source_Field_Name__c;
        ruleExpression.targetField = configRec.SVMXC__Target_Field_Name__c;
        ruleExpression.value = configRec.SVMXC__Display_Value__c;
        ruleExpression.displayValue = configRec.SVMXC__SM_Display_Value2__c;
        ruleExpression.targetNodeId = configRec.SVMXC__Setting_ID__c;
        ruleExpression.sourceNodeId = configRec.SVMXC__MapID__c;
        ruleExpression.action = configRec.SVMXC__Action__c;
        if(configRec.SVMXC__Target_Field_Name__c != null){
           ruleExpression.parameterType = 'Field Value';     
        }else if(configRec.SVMXC__Display_Value__c != null){
           ruleExpression.parameterType = 'Value';
            if(ruleExpression.value.startsWith('SVMX.') || SFM_DesignerUtils.supportedLiterals.contains(ruleExpression.value.toUpperCase())){
                ruleExpression.parameterType = 'Constant';     
            }
        }else if(configRec.SVMXC__SM_Question__c != null){
           ruleExpression.parameterType = 'Question';
           ruleExpression.value = configRec.SVMXC__SM_Question__c;
        }
        return ruleExpression;
    }
    public List<SFM_WrapperDef2.SFM2_Event> eventListWrapper(List<SVMXC__SFM_Event__c> eventsList){
       if(eventsList != null && !eventsList.isEmpty()){
            List<SFM_WrapperDef2.SFM2_Event> sfmEventWrapperList = new List<SFM_WrapperDef2.SFM2_Event>();
            for(SVMXC__SFM_Event__c eventRecord : eventsList){
                SFM_WrapperDef2.SFM2_Event eventWrapperRec = new SFM_WrapperDef2.SFM2_Event();
                eventWrapperRec.eventId = eventRecord.Id;
                eventWrapperRec.eventCallType = eventRecord.SVMXC__Event_Call_Type__c;
                eventWrapperRec.eventType = eventRecord.SVMXC__Event_Type__c;
                eventWrapperRec.targetNameSpace = eventRecord.SVMXC__Namespace__c;
                eventWrapperRec.sequence = eventRecord.SVMXC__Sequence__c != null ? Integer.valueOf(eventRecord.SVMXC__Sequence__c) : null;
                eventWrapperRec.eventActionId = eventRecord.SVMXC__ServiceMax_Custom_Action__c;
                sfmEventWrapperList.add(eventWrapperRec);
            }
            return sfmEventWrapperList;
       }
       return null;
    }
}