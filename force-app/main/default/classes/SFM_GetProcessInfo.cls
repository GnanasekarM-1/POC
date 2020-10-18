/* Security Scanned */
global with sharing class SFM_GetProcessInfo {
    
    private Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    
    //Get Details/Info of a ProcessNode
    public SFM_WrapperDef.SFM_Response_ProcessNodeInfo getProcessInfo(SFM_WrapperDef.SFM_Request request){
        Boolean response_success;
        String response_message;
        String response_tagId;
        List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> response_objectDefMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_Utils utils = new SFM_Utils();
        SVMX_Debug log = new SVMX_Debug();
        Map<String,String> req = new Map<String,String>();
        set<String> setProcessNodeObjectId = new set<String>();
        req = utils.getStringMap(request.stringMap);
        log.login('SFM_getProcessInfo', 'getProcessInfo');
        
        allObjs = Schema.getGlobalDescribe();
        
        List<Sobject> processBizRules = new List<Sobject>();
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Processes__c> processNodeObject = new List<SVMXC__ServiceMax_Processes__c>();
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeSourceObject = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeTargetObject = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> target_SourceUpdate_Map = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>(); 
        list<SVMXC__SFM_Event__c> lstSFMEvent = new list<SVMXC__SFM_Event__c>();

        //---------Added for Checklist used in Output doc---------//
        Boolean isOpDocProcess = false;
        Boolean isChecklistUsedInOpDoc = false;
        List<SFM_WrapperDef.SFM_SelectedChecklistProcess> lstSelectedChecklistProcess = new List<SFM_WrapperDef.SFM_SelectedChecklistProcess>();
        //---------Added for Checklist used in Output doc---------//
        try{
            if(req.get('RECORDID')!=NULL){
                String processId = req.get('RECORDID');
                //Added field SVMXC__SM_Run_Targeted_Sync__c in the query for the story BAC-3889
                //Added field SVMXC__SM_Enable_Version_Control__c in SOQL for the story BAC-3573
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodes = [Select Id, SVMXC__SM_Run_Targeted_Sync__c, SVMXC__SM_Enable_Version_Control__c, Name, SVMXC__SM_Include_Skipped_Sections__c, SVMXC__Enable_Sub_Process__c, SVMXC__Sub_Process_Source_Field__c, SVMXC__Process2__c, SVMXC__Enable_Attachment__c, SVMXC__IsGlobal__c, SVMXC__Doc_Template__c,SVMXC__Doc_Template_Details__c, SVMXC__Purpose__c, SVMXC__Page_Layout__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, 
                                SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Node_Source_Object_API__c, 
                                SVMXC__IsStandard__c,SVMXC__IsStandalone__c,CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                                LastModifiedBy.Name, CreatedBy.Name  
                                From SVMXC__ServiceMax_Processes__c 
                                where Recordtype.Name='Target Manager' And Id=:processId];

                //---------Added for Checklist used in Output doc---------//
                if(processNodes.SVMXC__Purpose__c.toUpperCase() == 'OUTPUT DOCUMENT'){
                    isOpDocProcess = true;
                }
                
                //Send the CreatedBy & ModifiedBy User name as additional parameter in response
                SFM_WrapperDef.SFM_StringMap createdBy = new SFM_WrapperDef.SFM_StringMap();
                SFM_WrapperDef.SFM_StringMap modifiedBy = new SFM_WrapperDef.SFM_StringMap();
                SFM_WrapperDef.SFM_StringMap createdOn = new SFM_WrapperDef.SFM_StringMap();
                SFM_WrapperDef.SFM_StringMap modifiedOn = new SFM_WrapperDef.SFM_StringMap();
                createdBy.key ='CREATEDBY';
                createdBy.value = processNodes.CreatedBy.Name;
                modifiedBy.key ='LASTMODIFIEDBY';
                modifiedBy.value = processNodes.LastModifiedBy.Name;
                createdOn.key ='CREATEDON';
                createdOn.value =String.valueof(processNodes.CreatedDate);
                modifiedOn.key ='LASTMODIFIEDON';
                modifiedOn.value = String.valueof(processNodes.LastModifiedDate);
                
                response_stringMap.add(createdBy);            
                response_stringMap.add(modifiedBy);
                response_stringMap.add(createdOn);            
                response_stringMap.add(modifiedOn);
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodeObject = [Select Id, SVMXC__Source_Key__c, SVMXC__Enable_Attachment__c, Name,SVMXC__Purpose__c, SVMXC__IsGlobal__c, SVMXC__Doc_Template__c,SVMXC__Doc_Template_Details__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent_API__c, SVMXC__ProcessID__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Page_Layout__c,
                                    SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,
                                    SVMXC__Target_Object_label__c,SVMXC__Values__c, SVMXC__IsStandard__c,SVMXC__IsStandalone__c,SVMXC__Final_Exception_Process__c,LastModifiedBy.Name, CreatedBy.Name 
                                    From SVMXC__ServiceMax_Processes__c 
                                    where Recordtype.Name='Process Node Objects' And SVMXC__Process__c = :processId order by SVMXC__Sequence__c];////GM2012-Jan-06 Order by clause added
                if(processNodeObject.size() > 0){
                    for(SVMXC__ServiceMax_Processes__c pro : processNodeObject){
                        setProcessNodeObjectId.add(pro.id);

                        //---------Added for Checklist used in Output doc---------//
                        if(!isChecklistUsedInOpDoc && pro.SVMXC__Type__c.toUpperCase() == 'TARGETCHILD' && pro.SVMXC__Source_Object_Name__c == 'SVMXC__Checklist__c'){
                            isChecklistUsedInOpDoc = true;
                        }
                    }
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processSourceUpdates = [Select Name, SVMXC__SM_Question__c, SVMXC__Dispatch_Process__c,SVMXC__Setting_ID__c,SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Display_Value__c,SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Field Mapping' And SVMXC__Dispatch_Process__c = :processId];
                
                List<SVMXC__ServiceMax_Config_Data__c> sourceUpdate_L;
                //Query Linked Processes 
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstLinkedProcesses = new list<SVMXC__ServiceMax_Processes__c>();
                lstLinkedProcesses = [select id, Name, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Sequence__c, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process1__c =: processId and SVMXC__Process2__c IN : setProcessNodeObjectId and RecordType.Name = 'Linked Process' order by SVMXC__Sequence__c];
                map<String,list<SVMXC__ServiceMax_Processes__c>> mapProcessNodeObjIdLinkedProcesses = new map<String,list<SVMXC__ServiceMax_Processes__c>>();
                if(lstLinkedProcesses.size() > 0){
                    for(SVMXC__ServiceMax_Processes__c pro : lstLinkedProcesses){
                        if(mapProcessNodeObjIdLinkedProcesses.containskey(pro.SVMXC__Process2__c)){
                            mapProcessNodeObjIdLinkedProcesses.get(pro.SVMXC__Process2__c).add(pro);
                        }
                        else{
                            mapProcessNodeObjIdLinkedProcesses.put(pro.SVMXC__Process2__c,new list<SVMXC__ServiceMax_Processes__c>());
                            mapProcessNodeObjIdLinkedProcesses.get(pro.SVMXC__Process2__c).add(pro);
                        }
                    }
                }
                system.debug('mapProcessNodeObjIdLinkedProcesses'+mapProcessNodeObjIdLinkedProcesses);
                for(SVMXC__ServiceMax_Config_Data__c sourceUpdate: processSourceUpdates)
                {
                    sourceUpdate_L = new List<SVMXC__ServiceMax_Config_Data__c>();
                    //Get existing maps
                    if(target_SourceUpdate_Map.containsKey(sourceUpdate.SVMXC__Setting_ID__c))
                    sourceUpdate_L.addAll(target_SourceUpdate_Map.get(sourceUpdate.SVMXC__Setting_ID__c));
                    if(sourceUpdate.SVMXC__Setting_ID__c!=NULL)
                    sourceUpdate_L.add(sourceUpdate);
                    target_SourceUpdate_Map.put(sourceUpdate.SVMXC__Setting_ID__c, sourceUpdate_L);
                }
                System.debug('TEST LOH:1:'+target_SourceUpdate_Map);
                
                system.debug('Process node object size ssss :'+processNodeObject.size()+'Object'+processNodeObject);
                
                for(SVMXC__ServiceMax_Processes__c processNodeObj: processNodeObject){
                    // Build the object definitionsand resplond to flex to display all object names on edit mode
                    String APIName = utils.getOriginalAPIName(processNodeObj.SVMXC__Source_Object_Name__c, allObjs);
                    if(APIName != NULL && allObjs.get(APIName)!= NULL){
                        
                        if(processNodeObj.SVMXC__Type__c=='SOURCE' || processNodeObj.SVMXC__Type__c=='TARGET') {
                            Schema.DescribeSObjectResult selectedObject = allObjs.get(APIName).getDescribe();
                            response_objectDefMap.add(new SFM_WrapperDef.SFM_StringMap(processNodeObj.SVMXC__Source_Object_Name__c, selectedObject.getLabel()));
                        } else if(processNodeObj.SVMXC__Type__c=='SOURCECHILD' || processNodeObj.SVMXC__Type__c=='TARGETCHILD'){
                            APIName = utils.getOriginalAPIName(processNodeObj.SVMXC__Node_Parent_API__c, allObjs);
                            list<schema.Childrelationship> ChildObj = new list<schema.Childrelationship>();                                 
                            String chilRelName = null;
                            ChildObj  = allObjs.get(APIName).getDescribe().getChildRelationships();
                            if(ChildObj.size() > 0){
                                for(Schema.ChildRelationship CR :ChildObj){
                                    if(CR.getField().getDescribe().getName() != null) {
                                        chilRelName = CR.getField().getDescribe().getName();
                                        if(chilRelName == processNodeObj.SVMXC__Parent_Column_Name__c && CR.getChildSObject().getDescribe().getName() == processNodeObj.SVMXC__Source_Object_Name__c) {
                                            String strObjLabelRelatedObjLabel = CR.getChildSObject().getDescribe().getLabel() +' ('+ CR.getField().getDescribe().getLabel() +')';
                                            response_objectDefMap.add(new SFM_WrapperDef.SFM_StringMap(CR.getChildSObject().getDescribe().getName(),strObjLabelRelatedObjLabel,chilRelName));
                                        }
                                    }    
                                } 
                            }//End of if block(ChildObj.size) 
                        }//End of else block                    
                    }
                                    
                    if(processNodeObj.SVMXC__Type__c=='SOURCE' || processNodeObj.SVMXC__Type__c=='SOURCECHILD'){
                        if(target_SourceUpdate_Map.containsKey(processNodeObj.Id)){
                            processNodeSourceObject.add(new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObj, target_SourceUpdate_Map.get(processNodeObj.Id)));
                        }
                        else{
                            processNodeSourceObject.add(new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObj, null));
                        }
                    }
                    if(processNodeObj.SVMXC__Type__c=='TARGET' || processNodeObj.SVMXC__Type__c=='TARGETCHILD'){
                        system.debug('TEST LOG100:'+processNodeObj.Id);
                        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeDetail;
                        if(target_SourceUpdate_Map.containsKey(processNodeObj.Id)){
                            processNodeDetail = new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObj, target_SourceUpdate_Map.get(processNodeObj.Id));
                        }
                        else{
                            processNodeDetail = new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObj, null);
                        }
                        if(mapProcessNodeObjIdLinkedProcesses.containskey(processNodeObj.id)){
                            processNodeDetail.linkedProcesses = mapProcessNodeObjIdLinkedProcesses.get(processNodeObj.id);
                        }
                        processNodeTargetObject.add(processNodeDetail);
                    }
                }
                System.debug('TEST LOH:2:'+processNodeSourceObject);
                System.debug('TEST LOH:3:'+processNodeTargetObject);
                
                //Get Business Rules list associated with SFM Process.
                if(processId != NULL && processId.length() > 0)
                    processBizRules = new SFM_BizRuleUtils().SFM_GetBizRulesForProcess(processId);
                //Get SFM Events for SFM processes
                lstSFMEvent = [select SVMXC__Sequence__c, SVMXC__Namespace__c, SVMXC__Class__c, SVMXC__ServiceMax_Process__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__Event_Call_Type__c, SVMXC__Event_Type__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: processId];

                //---------Added for Checklist used in Output doc---------//
                if(isOpDocProcess && isChecklistUsedInOpDoc){
                    List<String> lstChecklistId = new List<String>();
                    List<String> lstBusinessRuleId = new List<String>();
                    Map<String, String> mapChecklistIdToBRuelId = new Map<String, String>();
                    Map<String, SVMXC__ServiceMax_Processes__c> mapBRuleIdToBRProcess = new Map<String, SVMXC__ServiceMax_Processes__c>();
                    Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapBRuleIdToListExpr = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
                    Map<String, String> mapChecklistIdToVersion = new Map<String, String>();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Processes__c obj : [SELECT Id, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__SM_Checklist_Version__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process1__c =: processId AND Recordtype.Name='Checklist Smart Doc']){
                        lstChecklistId.add(obj.SVMXC__Process2__c);
                        mapChecklistIdToVersion.put(obj.SVMXC__Process2__c, obj.SVMXC__SM_Checklist_Version__c);
                    }
                    System.debug('lstChecklistId: '+lstChecklistId);
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<SVMXC__ServiceMax_Processes__c> lstChecklistProcess = [SELECT Id, Name, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN : lstChecklistId AND Recordtype.Name='Target Manager' AND SVMXC__Purpose__c = 'CHECKLIST'];
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Processes__c obj: [SELECT Id, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name='Process Business Rule' AND SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc' AND SVMXC__Process1__c =: processId AND SVMXC__Process2__c IN: lstChecklistId]){
                        lstBusinessRuleId.add(obj.SVMXC__Process3__c);
                        mapChecklistIdToBRuelId.put(obj.SVMXC__Process2__c, obj.SVMXC__Process3__c);
                    }
                    System.debug('lstBusinessRuleId: '+lstBusinessRuleId);
                    System.debug('mapChecklistIdToBRuelId: '+mapChecklistIdToBRuelId);
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Processes__c obj: [SELECT Id, SVMXC__Source_Object_Name__c, SVMXC__Question_Bank__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: lstBusinessRuleId AND Recordtype.Name='Business Rule' AND SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc']){
                        mapBRuleIdToBRProcess.put(obj.Id, obj);
                    }
                    System.debug('mapBRuleIdToBRProcess: '+mapBRuleIdToBRProcess);
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Config_Data__c objConfig: [SELECT Id, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Parameter_Type__c, SVMXC__Operand__c, SVMXC__Operator__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN: lstBusinessRuleId]){
                        if(!mapBRuleIdToListExpr.containsKey(objConfig.SVMXC__Expression_Rule__c)){
                            mapBRuleIdToListExpr.put(objConfig.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        }
                        mapBRuleIdToListExpr.get(objConfig.SVMXC__Expression_Rule__c).add(objConfig);
                    }
                    System.debug('mapBRuleIdToListExpr: '+mapBRuleIdToListExpr);

                    for(SVMXC__ServiceMax_Processes__c obj: lstChecklistProcess){
                        SFM_WrapperDef.SFM_SelectedChecklistProcess objSelectedCheckPro = new SFM_WrapperDef.SFM_SelectedChecklistProcess();
                        objSelectedCheckPro.checklistProcessRecord = obj;
                        objSelectedCheckPro.selectedChecklistId = obj.Id;
                        objSelectedCheckPro.selectedChecklistVersion = mapChecklistIdToVersion.get(obj.Id);
                        objSelectedCheckPro.checklistCriteriaProcess =  mapBRuleIdToBRProcess.get(mapChecklistIdToBRuelId.get(obj.Id));
                        objSelectedCheckPro.lstExpressionRecord = mapBRuleIdToListExpr.get(mapChecklistIdToBRuelId.get(obj.Id));
                        lstSelectedChecklistProcess.add(objSelectedCheckPro);
                    }
                    System.debug('lstSelectedChecklistProcess: '+lstSelectedChecklistProcess);
                }
                //---------Added for Checklist used in Output doc---------//
                
                response_success = true;
            }
            else{
                response_success = true;
                //response_message = 'Please pass valid RECORDID';
                response_message = system.Label.SFM001_TAG171;
            }
        }
        catch(exception ex){
            log.setlog('ERROR', ex.getmessage());
            response_success = false;
            response_message = ex.getmessage();
        }
        
        SFM_WrapperDef.SFM_Response_ProcessNodeInfo response = new SFM_WrapperDef.SFM_Response_ProcessNodeInfo(processNodes, processNodeSourceObject, processNodeTargetObject);
        response.setSFMEvents(lstSFMEvent);
        response.lstSelectedChecklistProcess = lstSelectedChecklistProcess;
        log.logout();
        log.print();
        response.response.logMsg = log.getlog();
        response.response.success = response_success;
        response.response.message = response_message;
        response.response.stringMap = response_stringMap;
        response.response.MapStringMap.add(new SFM_WrapperDef.SFM_MapStringMap('OBJECTDEFINITIONS', response_objectDefMap));
        response.response.records = processBizRules; //Business Rules list associated with SFM Process.
        system.debug('response_stringMap'+response_stringMap);
        System.debug(LoggingLevel.WARN, 'Response: ' + response);
        return response;
    }
}