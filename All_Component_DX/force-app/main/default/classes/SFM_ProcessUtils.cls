/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * SFM Process Utils to validate and Save each tab details
 *
 * @author Servicemax
 * @version
 * @since 2018
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
                Sachin S                Oct 2018
 *****************************************************************************************************/
public class SFM_ProcessUtils{

    public Static String tabInfo = 'ALL';
    public Static Set<String> processNodeIds;
    public Static Set<String> expressionIds;
    public Static Set<String> linkedProcessIds;
    public Static Set<String> dvrProcessIds;
    public Static Set<String> formualaIds;
    public Static Set<String> checklistIds;
    public Static Set<String> apiConfigIds;
    public Static String tagKeys;
    public Static CONF_ManageTranslations manageTranslations;
    public Static String entityType;

    public Static CONF_ManageTranslations getManageTranslationInstance() {
        if(manageTranslations == null){
            manageTranslations = new CONF_ManageTranslations();
        }
        return manageTranslations;
    }

    //Step1 : Properties Tab Validate and Save
    public void savePropertiesTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo, String entityType){

        if(processInfo.targetManager != null){
            String entityStatus = 'Incomplete';
            // Only for SFM Processes
            if (entityType == SFM_DesignerUtils.entity_sfm && processInfo.targetManager.entityStatus != null) {
                entityStatus = processInfo.targetManager.entityStatus;
            }
            SFM_WrapperDef2.SFM2_EntityDetail targetManager = processInfo.targetManager;
            //Validate Transacation name for duplicates
            if(SFM_DesignerUtils.isEntityNameAlreadyUsed(targetManager.entityName, entityType, targetManager.entityId)){
                System.debug( System.LoggingLevel.ERROR, 'Duplicate Name already exists');
                throw new SFM_DesignerUtils.ServicemaxNestedException( System.Label.SFM001_TAG685 );
            }

            SVMXC__ServiceMax_Processes__c targetManagerEntry = mapTargetManagerValuesToRecord(targetManager);

            if(processInfo.pageLayoutId != null){
                entityStatus = entityType == SFM_DesignerUtils.entity_sfm ? processInfo.targetManager.entityStatus : 'Complete';
                if(targetManager.entitySubType != null && targetManager.entitySubType.equalsIgnoreCase( SFM_DesignerUtils.entity_checklist)){
                    entityStatus = processInfo.targetManager.entityStatus != null ? processInfo.targetManager.entityStatus: 'Incomplete';
                }
            }

            if(processInfo.adv_AttachmentEnabled == null){
               processInfo.adv_AttachmentEnabled = false;
            }

            if(processInfo.enableTargetedSync == null){
               processInfo.enableTargetedSync = false;
            }

            targetManagerEntry.SVMXC__SM_Run_Targeted_Sync__c = processInfo.enableTargetedSync;
            targetManagerEntry.SVMXC__SM_Enable_Version_Control__c = processInfo.enableVersionControl != null ? processInfo.enableVersionControl: false;
            targetManagerEntry.SVMXC__SM_Display_File_Name__c = processInfo.displayFileName;
            targetManagerEntry.SVMXC__Export_Configuration__c = processInfo.displayFileMetaData;
            targetManagerEntry.SVMXC__SM_Include_Skipped_Sections__c = processInfo.includeSkippedSections != null ? processInfo.includeSkippedSections: false;
            targetManagerEntry.SVMXC__SM_Exclude_Unanswered_Questions__c = processInfo.excludeSkippedQuestions != null ? processInfo.excludeSkippedQuestions: false;

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(targetManagerEntry, COMM_SecurityUtils.Access.Upsertable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
            }

            try{
                tagKeys = processInfo.tagKeys;
                tagKeys = tagKeys != null ? tagKeys : '';
                getManageTranslationInstance();

                if(targetManagerEntry.SVMXC__Name__c != null && targetManagerEntry.SVMXC__Name__c.length() > 0) {
                    String strUniqueKey = manageTranslations.generate_UniqueKeys(targetManagerEntry.SVMXC__Name__c, null, null, 'SFM_PROCESS_NAME');
                    if(strUniqueKey != null && !createProcessKeySet(tagKeys).contains(strUniqueKey)) {
                        tagKeys += strUniqueKey;
                    }
                }

                if(targetManagerEntry.SVMXC__ProcessID__c != null && String.isNotBlank(targetManagerEntry.SVMXC__Description__c)) {
                    String strUniqueKey = manageTranslations.generate_UniqueKeys(targetManagerEntry.SVMXC__Description__c, targetManagerEntry.SVMXC__ProcessID__c, '_DESC', 'SFM_PROCESS_DESCRIPTION');
                    if(strUniqueKey != null && !createProcessKeySet(tagKeys).contains(strUniqueKey)) {
                        tagKeys += strUniqueKey;
                    }
                }

                targetManagerEntry.SVMXC__Tag_Keys__c = tagKeys;
                targetManagerEntry.SVMXC__Dispatch_Process_Status__c = entityStatus;
                upsert targetManagerEntry;

                SFM_DesignerUtils.manageSVMXTags(targetManager.tagsList, targetManagerEntry.Id);

                targetManager.entityId = targetManagerEntry.Id;
                targetManager.entityStatus = entityStatus;
                processInfo.targetManager = targetManager;
                processInfo.tagKeys = tagKeys;

                if((targetManager.entitySubType.equalsIgnoreCase('OUTPUT DOCUMENT') || targetManager.entitySubType.equalsIgnoreCase('CHECKLIST')) && tabInfo.equalsIgnoreCase('PROPERTIES')){
                    saveObjectMappingTab(processInfo);
                }
            }
            catch(Exception ex){
                System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Properties Tab :' + ex.getMessage() + ' /n ' + ex.getStackTraceString());
                //throw new SFM_DesignerUtils.ServicemaxNestedException('message');
                throw ex;
            }
        }
    }

    public void saveObjectMappingTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo){

        if(processInfo != null && processInfo.processNodeList != null){

            List<SVMXC__ServiceMax_Processes__c> processNodeEntryList = new List<SVMXC__ServiceMax_Processes__c>();
            Map<String, SFM_WrapperDef2.SFM2_ProcessNode> processNodeMap = new Map<String, SFM_WrapperDef2.SFM2_ProcessNode>();
            processNodeIds = new Set<String>();
            String qcId;

            try{

                for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                    SVMXC__ServiceMax_Processes__c processNodeEntry = mapProcessNodeValuesToRecord(processNode);
                    processNodeEntry.SVMXC__Process__c = processInfo.targetManager.entityId;
                    processNodeMap.put(processNode.nodeType + processNode.sequence, processNode);
                    processNodeEntryList.add(processNodeEntry);

                }

                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processNodeEntryList, COMM_SecurityUtils.Access.Upsertable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }

                upsert processNodeEntryList;

                for(SVMXC__ServiceMax_Processes__c processNodeEntryRec : processNodeEntryList){

                    if(processNodeMap.containsKey(processNodeEntryRec.SVMXC__Type__c + processNodeEntryRec.SVMXC__Source_Key__c)){
                        SFM_WrapperDef2.SFM2_ProcessNode processNode = processNodeMap.get(processNodeEntryRec.SVMXC__Type__c + processNodeEntryRec.SVMXC__Source_Key__c);
                        if(processNodeEntryRec.SVMXC__Type__c.equalsIgnoreCase('TARGET') && processNodeEntryRec.SVMXC__Submodule__c != null){
                            qcId = processNodeEntryRec.SVMXC__Submodule__c;
                        }
                        processNode.nodeId = processNodeEntryRec.Id;
                    }

                    processNodeIds.add(processNodeEntryRec.Id);

                }

                for(SVMXC__ServiceMax_Processes__c processNodeEntryRec : processNodeEntryList){

                    if(processNodeMap.containsKey(processNodeEntryRec.SVMXC__Type__c + processNodeEntryRec.SVMXC__Source_Key__c)){
                        SFM_WrapperDef2.SFM2_ProcessNode processNode = processNodeMap.get(processNodeEntryRec.SVMXC__Type__c + processNodeEntryRec.SVMXC__Source_Key__c);


                        if(processNodeEntryRec.SVMXC__Type__c.equalsIgnoreCase('TARGET') && processNodeMap.containsKey('SOURCE' + processNodeEntryRec.SVMXC__Source_Key__c)){

                            processNodeEntryRec.SVMXC__Parent_Object__c = processNodeMap.get('SOURCE' + processNodeEntryRec.SVMXC__Source_Key__c).nodeId;
                            processNode.sourceNodeId = processNodeEntryRec.SVMXC__Parent_Object__c;
                        }

                        if(processNodeEntryRec.SVMXC__Type__c.equalsIgnoreCase('TARGETCHILD') && processNodeMap.containsKey('SOURCECHILD' + processNodeEntryRec.SVMXC__Source_Key__c)){

                            processNodeEntryRec.SVMXC__Parent_Object__c = processNodeMap.get('SOURCECHILD' + processNodeEntryRec.SVMXC__Source_Key__c).nodeId;
                            processNode.sourceNodeId = processNodeEntryRec.SVMXC__Parent_Object__c;

                        }
                    }
                }

                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processNodeEntryList, COMM_SecurityUtils.Access.Updateable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }

                update processNodeEntryList;


                if(qcId != null) {
                    List<SVMXC__ServiceMax_Processes__c> qcExpressionList = [SELECT Id, SVMXC__Parent_Error_Msg__c FROM SVMXC__ServiceMax_Processes__c WHERE Id=: qcId AND SVMXC__Parent_Error_Msg__c != null];
                    if(!qcExpressionList.isEmpty()){
                        tagKeys = processInfo.tagKeys;
                        tagKeys = tagKeys != null ? tagKeys : '';
                        getManageTranslationInstance();
                        String strUniqueKey = manageTranslations.generate_UniqueKeys(qcExpressionList[0].SVMXC__Parent_Error_Msg__c, null, null, 'HEADER_ERROR_MESSAGE');
                        if(strUniqueKey != null && !createProcessKeySet(tagKeys).contains(strUniqueKey)){
                            tagKeys += strUniqueKey;
                            if(processInfo.targetManager.entityId != null){
                                SVMXC__ServiceMax_Processes__c targetManagerEntry = new SVMXC__ServiceMax_Processes__c();
                                targetManagerEntry.Id = processInfo.targetManager.entityId;
                                targetManagerEntry.SVMXC__Tag_Keys__c = tagKeys;
                                update targetManagerEntry;
                            }
                        }
                    }
                }

                processInfo.tagKeys = tagKeys;

            }
            catch(Exception ex){
                System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Objects and Mapping Tab :' + ex.getMessage() );
                throw ex;
            }
        }
    }

    public void savePageLayoutTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo, String entityType){

        try{
            if(processInfo != null && processInfo.targetManager != null && processInfo.targetManager.entityId != null){
                apiConfigIds = new Set<String>();
                List<SVMXC__SFM_Event__c> apiEventsList;
                tagKeys = processInfo.tagKeys;
                tagKeys = tagKeys != null ? tagKeys : '';

                Boolean isEntitySFM = entityType == SFM_DesignerUtils.entity_sfm;
                String entityStatus = isEntitySFM ? processInfo.targetManager.entityStatus : 'Incomplete';
                getManageTranslationInstance();
                SFM_WrapperDef2.SFM2_EntityDetail targetManager = processInfo.targetManager;
                SVMXC__ServiceMax_Processes__c targetManagerRecord = mapTargetManagerValuesToRecord(targetManager);//new SVMXC__ServiceMax_Processes__c(Id = targetManager.entityId);
                apiEventsList = new List<SVMXC__SFM_Event__c>();
                if(processInfo.events != null && !processInfo.events.isEmpty()){
                    for(SFM_WrapperDef2.SFM2_Event eventWrapperRec : processInfo.events){
                        SVMXC__SFM_Event__c eventRecord = new SVMXC__SFM_Event__c();
                        if(eventWrapperRec.eventId != null){
                            eventRecord.Id = eventWrapperRec.eventId;
                        }
                        eventRecord.SVMXC__ServiceMax_Process__c = targetManager.entityId;
                        eventRecord.SVMXC__Event_Call_Type__c = eventWrapperRec.eventCallType;
                        eventRecord.SVMXC__Event_Type__c = eventWrapperRec.eventType;
                        eventRecord.SVMXC__Namespace__c = eventWrapperRec.targetNameSpace;
                        eventRecord.SVMXC__Sequence__c = eventWrapperRec.sequence;
                        eventRecord.SVMXC__ServiceMax_Custom_Action__c = eventWrapperRec.eventActionId;
                        if(eventRecord.SVMXC__Event_Call_Type__c.equals('SFM TRIGGER') && eventRecord.SVMXC__Event_Type__c.equals('Inventory Updates') && eventRecord.SVMXC__Class__c == null){
                            eventRecord.SVMXC__Class__c = 'SFM_InvtUpdOnWorkOrderClosure';
                        }
                        apiEventsList.add(eventRecord);
                    }
                }
                if(processInfo.pageLayoutId != null || processInfo.templateId != null ){
                    targetManagerRecord.SVMXC__Page_Layout__c = processInfo.pageLayoutId;
                    targetManagerRecord.SVMXC__Doc_Template__c = processInfo.templateId;
                    entityStatus = isEntitySFM ? processInfo.targetManager.entityStatus : 'Complete';
                    if( String.isNotBlank( targetManager.entitySubType ) && targetManager.entitySubType.equalsIgnoreCase( SFM_DesignerUtils.entity_checklist ) ) {
                        entityStatus = processInfo.targetManager.entityStatus != null ? processInfo.targetManager.entityStatus: 'Incomplete';
                        targetManagerRecord.SVMXC__Tag_Keys__c = '';
                        targetManagerRecord = manageTranslations.i18N_Checklist_Translation( targetManagerRecord );
                        tagKeys = targetManagerRecord.SVMXC__Tag_Keys__c;
                    } else {
                    tagKeys = updatePageLayoutTagKey(processInfo.pageLayoutId, tagKeys);
                    }
                }else {
                    targetManagerRecord.SVMXC__Page_Layout__c = null;
                    targetManagerRecord.SVMXC__Doc_Template__c = null;
                    entityStatus = isEntitySFM ? processInfo.targetManager.entityStatus : 'Incomplete';
                }

                if(!targetManager.entitySubType.equalsIgnoreCase('OUTPUT DOCUMENT')){
                    linkedProcessIds = new Set<String>();
                    targetManagerRecord.SVMXC__SM_Run_Targeted_Sync__c = processInfo.enableTargetedSync;
                    targetManagerRecord.SVMXC__SM_Disable_Realtime_Validation__c = processInfo.enableRealTimeValidation != null ? !processInfo.enableRealTimeValidation: false;
                    if(processInfo.adv_SubProcessId != null){
                        targetManagerRecord.SVMXC__Enable_Sub_Process__c = true;
                        targetManagerRecord.SVMXC__Process2__c = processInfo.adv_SubProcessId;
                        targetManagerRecord.SVMXC__Sub_Process_Source_Field__c = processInfo.adv_SubProcessSrcField;
                    } else {
                        targetManagerRecord.SVMXC__Enable_Sub_Process__c = false;
                        targetManagerRecord.SVMXC__Process2__c = null;
                        targetManagerRecord.SVMXC__Sub_Process_Source_Field__c = null;
                    }
                }

                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(targetManagerRecord, COMM_SecurityUtils.Access.Updateable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                }


                if(processInfo.processNodeList != null){
                    List<SVMXC__ServiceMax_Processes__c> processNodeList = new List<SVMXC__ServiceMax_Processes__c>();
                    List<SVMXC__ServiceMax_Processes__c> linkedProcessList;

                    for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){
                        SVMXC__ServiceMax_Processes__c processNodeRecord = new SVMXC__ServiceMax_Processes__c(Id = processNode.nodeId, SVMXC__Page_Layout__c = processNode.pageDetailId,
                                                                                                                    SVMXC__Doc_Template_Details__c = processNode.templateDetailId);

                        if(!targetManager.entitySubType.equalsIgnoreCase('OUTPUT DOCUMENT') || tabInfo.equalsIgnoreCase('ALL')){
                            String advancedInfo = serializeAdvancedOptionsInfo(processNode.fieldSets, processNode.adv_SortingInfo);
                            processNodeRecord.SVMXC__Values__c = advancedInfo;
                            processNodeRecord.SVMXC__Final_Exception_Process__c = processNode.valueMappingId;
                            if(processNode.nodeType.equalsIgnoreCase('TARGET')){
                                processNodeRecord.SVMXC__Enable_Attachment__c = processInfo.adv_AttachmentEnabled;
                            }

                            if(processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){
                                // added for allow attachments and images for related section
                                processNodeRecord.SVMXC__Enable_Attachment__c = processNode.allowAttachments != null ? processNode.allowAttachments : false;
                                processNodeRecord.SVMXC__SM_Enable_Image__c = processNode.allowImages != null ? processNode.allowImages : false;
                                if(processNode.linkedProcessList != null && !processNode.linkedProcessList.isEmpty()){

                                    if(linkedProcessList == null){
                                        linkedProcessList = new List<SVMXC__ServiceMax_Processes__c>();
                                    }

                                    for(SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess: processNode.linkedProcessList) {
                                        String strUniqueKey = manageTranslations.generate_UniqueKeys(linkedProcess.linkedProcessName, null, null, 'LINKED_PROCESS_TITLE');
                                        if(strUniqueKey != null && !createProcessKeySet(tagKeys).contains(strUniqueKey)) {
                                            tagKeys += strUniqueKey;
                                        }

                                        SVMXC__ServiceMax_Processes__c linkedProcessEntry = mapLinkedProcessValuesToRecord(linkedProcess, processNode.nodeId, targetManager.entityId);
                                        linkedProcessEntry.RecordtypeId =  SFM_DesignerUtils.recordTypeIdMap.get('Linked Process');

                                        linkedProcessList.add(linkedProcessEntry);
                                    }
                                }
                            }
                        }

                        processNodeList.add(processNodeRecord);
                    }

                    if(!processNodeList.isEmpty()){

                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processNodeList, COMM_SecurityUtils.Access.Updateable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }

                        update processNodeList;
                    }


                    if(linkedProcessList != null && !linkedProcessList.isEmpty()){
                        System.debug(LoggingLevel.INFO, 'linkedProcessList  :' + linkedProcessList.size());

                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(linkedProcessList, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }

                        upsert linkedProcessList;

                        Map<String, Id> junctionRecordIdMap = new Map<String, Id>();  //Key : ProcessNodeId + BusinessProcessID/LinkedProcessId

                        for(SVMXC__ServiceMax_Processes__c linkedProcessRec : linkedProcessList){
                            String junctionKey = linkedProcessRec.SVMXC__Process2__c + '' + linkedProcessRec.SVMXC__Process3__c;
                            junctionRecordIdMap.put(junctionKey, linkedProcessRec.Id);
                            linkedProcessIds.add(linkedProcessRec.Id);
                        }


                        for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                            if(processNode.nodeType.equalsIgnoreCase('TARGETCHILD') && processNode.linkedProcessList != null){
                                mapJunctionRecordIds(processNode.linkedProcessList, junctionRecordIdMap, processNode.nodeId);
                            }
                        }

                    }

                    if(apiEventsList != null && !apiEventsList.isEmpty()){
                        System.debug(LoggingLevel.INFO, 'apiEventsList  :' + apiEventsList.size());
                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(apiEventsList, COMM_SecurityUtils.Access.Upsertable)){
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        upsert apiEventsList;
                        List<SFM_WrapperDef2.SFM2_Event> sfmEventWrapperList = new List<SFM_WrapperDef2.SFM2_Event>();
                        for(SVMXC__SFM_Event__c eventRecord : apiEventsList){
                            apiConfigIds.add(eventRecord.Id);
                            SFM_WrapperDef2.SFM2_Event eventWrapperRec = new SFM_WrapperDef2.SFM2_Event();
                            eventWrapperRec.eventId = eventRecord.Id;
                            eventWrapperRec.eventCallType = eventRecord.SVMXC__Event_Call_Type__c;
                            eventWrapperRec.eventType = eventRecord.SVMXC__Event_Type__c;
                            eventWrapperRec.targetNameSpace = eventRecord.SVMXC__Namespace__c;
                            eventWrapperRec.sequence = Integer.valueOf(eventRecord.SVMXC__Sequence__c);
                            eventWrapperRec.eventActionId = eventRecord.SVMXC__ServiceMax_Custom_Action__c;
                            sfmEventWrapperList.add(eventWrapperRec);
                        }
                        processInfo.events = sfmEventWrapperList;
                    }
                }

                targetManagerRecord.SVMXC__Dispatch_Process_Status__c = entityStatus;
                targetManagerRecord.SVMXC__Tag_Keys__c = tagKeys;
                update targetManagerRecord;
                processInfo.targetManager.entityStatus = entityStatus;
                processInfo.tagKeys = tagKeys;

            }
        }catch(DmlException ex){
            System.debug(LoggingLevel.ERROR, 'Exception occurred while associating page layout to Process Record:' + ex.getMessage());
            throw ex;
        }
    }

    public void saveSourceObjectUpdateTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo){

        if(processInfo != null && processInfo.processNodeList != null){
            try{

                List<SVMXC__ServiceMax_Config_Data__c> expressionEntryList;
                expressionIds = new Set<String>();
                for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                    if(processNode.nodeType.equalsIgnoreCase('TARGET') || processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){

                        if(processNode.sourceUpdateRule != null){
                            SFM_WrapperDef2.SFM2_Rule sourceUpdateRule = processNode.sourceUpdateRule;

                            List<SFM_WrapperDef2.SFM2_RuleExpression> expressionsList = sourceUpdateRule.expressionsList;

                            if(expressionsList != null && !expressionsList.isEmpty()){
                                if(expressionEntryList == null){
                                    expressionEntryList = new List<SVMXC__ServiceMax_Config_Data__c>();
                                }

                                for(SFM_WrapperDef2.SFM2_RuleExpression expressionRec : expressionsList){
                                    SVMXC__ServiceMax_Config_Data__c expressionEntry = mapExpressionValuesToRecord(expressionRec, processNode);
                                    expressionEntry.SVMXC__Dispatch_Process__c = processInfo.targetManager.entityId;
                                    expressionEntryList.add(expressionEntry);
                                }
                            }
                        }
                    }
                }

                /*
                    Map required to map back the expression Ids to related process nodes
                */
                Map<String, List<SVMXC__ServiceMax_Config_Data__c>> nodeExpressionsMap;

                if(expressionEntryList != null && !expressionEntryList.isEmpty()){

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(expressionEntryList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    upsert expressionEntryList;

                    nodeExpressionsMap = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();

                    for(SVMXC__ServiceMax_Config_Data__c configRec : expressionEntryList){
                        expressionIds.add(configRec.Id);
                        String mapKey = configRec.SVMXC__MapID__c + '' + configRec.SVMXC__Setting_ID__c;
                        List<SVMXC__ServiceMax_Config_Data__c> tempList = new List<SVMXC__ServiceMax_Config_Data__c>();

                        if(nodeExpressionsMap.containsKey(mapKey)){
                            tempList = nodeExpressionsMap.get(mapKey);
                        }
                        tempList.add(configRec);
                        nodeExpressionsMap.put(mapKey, tempList);
                    }

                    for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){
                        String mapKey = processNode.sourceNodeId + processNode.nodeId;
                        List<SFM_WrapperDef2.SFM2_RuleExpression> expressionsList = new List<SFM_WrapperDef2.SFM2_RuleExpression>();

                        if(processNode.nodeType.equalsIgnoreCase('TARGET') || processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){

                            if(nodeExpressionsMap != null && nodeExpressionsMap.containsKey(mapKey)){

                                for(SVMXC__ServiceMax_Config_Data__c configRec : nodeExpressionsMap.get(mapKey)){

                                    SFM_WrapperDef2.SFM2_RuleExpression ruleExpression = mapSourceUpdateRulesToWrapper(configRec);
                                    ruleExpression.sourceObject = processNode.nodeSourceAPIName;

                                    expressionsList.add(ruleExpression);
                                }

                                SFM_WrapperDef2.SFM2_Rule sourceUpdateRule = new SFM_WrapperDef2.SFM2_Rule();
                                sourceUpdateRule.expressionsList = expressionsList;
                                processNode.sourceUpdateRule = sourceUpdateRule;
                            }
                        }

                    }
                }

                //deleteRecords(processInfo.targetManager.entityId, null, expressionIds, null, null);

            }catch(DmlException ex){
                System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Source Update Rule:' + ex.getMessage());
                throw ex;
            }
        }
    }

    public void saveDvrTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo){

        try{
            if(processInfo != null && processInfo.processNodeList != null){

                dvrProcessIds = new Set<String>();
                List<SVMXC__ServiceMax_Processes__c> businessRuleList = new List<SVMXC__ServiceMax_Processes__c>();
                SVMXC__ServiceMax_Processes__c targetManagerEntry;
                tagKeys = processInfo.tagKeys;
                tagKeys = tagKeys != null ? tagKeys : '';
                getManageTranslationInstance();
                for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                    if(processNode.nodeType.equalsIgnoreCase('TARGET') || processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){

                        if(processNode.validationRulesList != null){

                            for(SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess : processNode.validationRulesList){
                                if(linkedProcess.message != null && linkedProcess.message.length() > 0) {
                                    String strUniqueKey = manageTranslations.generate_UniqueKeys(linkedProcess.message, null, null, 'DATA_VALIDATION_RULE_MESSAGE');
                                    if(strUniqueKey != null && !createProcessKeySet(tagKeys).contains(strUniqueKey)) {
                                        tagKeys += strUniqueKey;
                                        if(targetManagerEntry == null && processInfo.targetManager.entityId != null){
                                            targetManagerEntry = new SVMXC__ServiceMax_Processes__c();
                                            targetManagerEntry.Id = processInfo.targetManager.entityId;
                                        }
                                    }
                                }
                                SVMXC__ServiceMax_Processes__c linkedProcessEntry = mapLinkedProcessValuesToRecord(linkedProcess, processNode.nodeId, processInfo.targetManager.entityId);
                                linkedProcessEntry.RecordtypeId =  SFM_DesignerUtils.recordTypeIdMap.get('Process Business Rule');
                                businessRuleList.add(linkedProcessEntry);
                            }

                        }
                    }

                }

                if(!businessRuleList.isEmpty()){
                    System.debug(LoggingLevel.INFO, 'businessRuleList  :' + businessRuleList.size());

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(businessRuleList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    upsert businessRuleList;

                    Map<String, Id> junctionRecordIdMap = new Map<String, Id>();  //Key : ProcessNodeId + BusinessProcessID/LinkedProcessId

                    for(SVMXC__ServiceMax_Processes__c linkedProcessRec : businessRuleList){
                        String junctionKey = linkedProcessRec.SVMXC__Process2__c + '' + linkedProcessRec.SVMXC__Process3__c;
                        junctionRecordIdMap.put(junctionKey, linkedProcessRec.Id);
                        dvrProcessIds.add(linkedProcessRec.Id);
                    }

                    for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                        if(processNode.nodeType.equalsIgnoreCase('TARGET') || processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){

                            if(processNode.validationRulesList != null){
                                mapJunctionRecordIds(processNode.validationRulesList, junctionRecordIdMap, processNode.nodeId);
                            }

                        }

                    }

                    if(targetManagerEntry != null){
                        targetManagerEntry.SVMXC__Tag_Keys__c = tagKeys;
                        update targetManagerEntry;
                    }
                }

                processInfo.tagKeys = tagKeys;

            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Data Validation Rules Tab :' + ex.getMessage() );
            throw ex;
        }
    }

    public void saveFormulaTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo){
        try{
            if(processInfo != null && processInfo.processNodeList != null){

                formualaIds = new Set<String>();
                List<SVMXC__ServiceMax_Processes__c> formulasList = new List<SVMXC__ServiceMax_Processes__c>();

                for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                    if(processNode.nodeType.equalsIgnoreCase('TARGET') || processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){

                        if(processNode.formulasList != null){

                            for(SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess : processNode.formulasList){
                                SVMXC__ServiceMax_Processes__c linkedProcessEntry = mapLinkedProcessValuesToRecord(linkedProcess, processNode.nodeId, processInfo.targetManager.entityId);
                                linkedProcessEntry.RecordtypeId =  SFM_DesignerUtils.recordTypeIdMap.get('Process Business Rule');
                                formulasList.add(linkedProcessEntry);
                            }

                        }
                    }

                }

                if(!formulasList.isEmpty()){
                    System.debug(LoggingLevel.INFO, 'formulasList  :' + formulasList.size());

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(formulasList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    upsert formulasList;

                    Map<String, Id> junctionRecordIdMap = new Map<String, Id>();  //Key : ProcessNodeId + BusinessProcessID/LinkedProcessId

                    for(SVMXC__ServiceMax_Processes__c linkedProcessRec : formulasList){
                        String junctionKey = linkedProcessRec.SVMXC__Process2__c + '' + linkedProcessRec.SVMXC__Process3__c;
                        junctionRecordIdMap.put(junctionKey, linkedProcessRec.Id);
                        formualaIds.add(linkedProcessRec.Id);
                    }

                    for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){

                        if(processNode.nodeType.equalsIgnoreCase('TARGET') || processNode.nodeType.equalsIgnoreCase('TARGETCHILD')){

                            if(processNode.formulasList != null){
                                mapJunctionRecordIds(processNode.formulasList, junctionRecordIdMap, processNode.nodeId);
                            }

                        }

                    }
                }

                //deleteRecords(processInfo.targetManager.entityId, null, null, null, dvrProcessIds);

            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Formula Rules Tab :' + ex.getMessage() );
            throw ex;
        }
    }

    public void saveSortingTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo){
        try{
            if(processInfo.processNodeList != null){
                List<SVMXC__ServiceMax_Processes__c> processNodeList = new List<SVMXC__ServiceMax_Processes__c>();

                for(SFM_WrapperDef2.SFM2_ProcessNode processNode : processInfo.processNodeList){
                    SVMXC__ServiceMax_Processes__c processNodeRecord = new SVMXC__ServiceMax_Processes__c(Id = processNode.nodeId);
                    String advancedInfo = serializeAdvancedOptionsInfo(null, processNode.adv_SortingInfo);
                    processNodeRecord.SVMXC__Values__c = advancedInfo;
                    processNodeList.add(processNodeRecord);
                }

                if(!processNodeList.isEmpty()){

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processNodeList, COMM_SecurityUtils.Access.Updateable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    update processNodeList;
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Sorting Tab :' + ex.getMessage() );
            throw ex;
        }

    }

    public void saveChecklistTab(SFM_WrapperDef2.SFM2_ProcessInfo processInfo){
        try{
            List<SVMXC__ServiceMax_Processes__c> checklistProcessJunctionList = new List<SVMXC__ServiceMax_Processes__c>();
            Map<Id, SFM_WrapperDef2.SFM2_LinkedProcess> checklistProcessIdMap = new  Map<Id, SFM_WrapperDef2.SFM2_LinkedProcess>();
            checklistIds = new Set<String>();
            Set<Id> criteriaIds = new Set<Id>();
            Set<Id> criteriaIdsWithRuleInfo = new Set<Id>();
            Map<Id, SVMXC__ServiceMax_Processes__c> checklistRuleHeaderInfoMap = new Map<Id, SVMXC__ServiceMax_Processes__c>();
            Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> checklistRuleExpressionsMap = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();

            if(processInfo != null && processInfo.targetManager != null && processInfo.targetManager.entityId != null && processInfo.checklistProcessList != null){
                String opdocProcessId = processInfo.targetManager.entityId;
                if(tabInfo.equalsIgnoreCase('OPDOCCHECKLIST')){
                    SVMXC__ServiceMax_Processes__c targetManagerEntry = new SVMXC__ServiceMax_Processes__c(Id=opdocProcessId);
                    targetManagerEntry.SVMXC__SM_Include_Skipped_Sections__c = processInfo.includeSkippedSections;
                    targetManagerEntry.SVMXC__SM_Exclude_Unanswered_Questions__c = processInfo.excludeSkippedQuestions;
                    upsert targetManagerEntry;
                }

                for(SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess : processInfo.checklistProcessList){
                    if(linkedProcess.checklistId != null){
                        SVMXC__ServiceMax_Processes__c linkedProcessEntry = mapLinkedProcessValuesToRecord(linkedProcess, linkedProcess.checklistId, opdocProcessId);
                        if(linkedProcess.ruleInfo != null){
                            List<SVMXC__ServiceMax_Config_Data__c> configList = new List<SVMXC__ServiceMax_Config_Data__c>();
                            SFM_WrapperDef2.SFM2_Rule ruleInfo = linkedProcess.ruleInfo;
                            SVMXC__ServiceMax_Processes__c businessRuleRecord = new SVMXC__ServiceMax_Processes__c();
                            if(ruleInfo.ruleDetail.entityId != null ) {
                                businessRuleRecord.Id = ruleInfo.ruleDetail.entityId;
                            }
                            businessRuleRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Business Rule');
                            businessRuleRecord.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
                            businessRuleRecord.SVMXC__Source_Object_Name__c = ruleInfo.sourceObject;
                            businessRuleRecord.SVMXC__Question_Bank__c = ruleInfo.questionId;
                            if(ruleInfo.expressionsList != null){
                                for(SFM_WrapperDef2.SFM2_RuleExpression ruleExpression : ruleInfo.expressionsList){
                                    SVMXC__ServiceMax_Config_Data__c configData = new SFM_SaveExpression().mapDetailFieldValues(ruleExpression, ruleExpression.expressionId, SFM_DesignerUtils.entity_checklistCriteria);
                                    configData.SVMXC__Display_Type__c = ruleExpression.sourceFldDtaType;
                                    configList.add(configData);
                                }
                            }

                            checklistRuleHeaderInfoMap.put(linkedProcess.checklistId, businessRuleRecord);
                            checklistRuleExpressionsMap.put(linkedProcess.checklistId, configList);
                            if(linkedProcess.linkedProcessId != null){
                                criteriaIdsWithRuleInfo.add(linkedProcess.linkedProcessId);
                            }
                        }


                        if(linkedProcess.linkedProcessId != null){
                            criteriaIds.add(linkedProcess.linkedProcessId);
                        }

                        linkedProcessEntry.SVMXC__Process3__c = null;
                        linkedProcessEntry.RecordtypeId =  SFM_DesignerUtils.recordTypeIdMap.get('Checklist Smart Doc');
                        checklistProcessIdMap.put(linkedProcess.checklistId, linkedProcess);
                        checklistProcessJunctionList.add(linkedProcessEntry);
                        checklistIds.add(linkedProcess.checklistId);

                    }
                }


                if(!checklistRuleHeaderInfoMap.values().isEmpty()){
                    System.debug(LoggingLevel.INFO, 'Question Expression Headers List' + checklistRuleHeaderInfoMap.values().size());

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(checklistRuleHeaderInfoMap.values(), COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    upsert checklistRuleHeaderInfoMap.values();
                }

                Map<Id, SVMXC__ServiceMax_Processes__c> checkListCriteriaJunctionMap = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                List<Id> criteriaDeleteIds = new List<Id>();
                for(SVMXC__ServiceMax_Processes__c criteriaJunctionRecord : [SELECT Id, SVMXC__Process2__c, SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc'
                                                                               AND SVMXC__Process1__c =: opdocProcessId AND RecordType.Name = 'Process Business Rule']){

                    if(criteriaJunctionRecord.SVMXC__Process3__c != null){
                        if(criteriaIds.contains(criteriaJunctionRecord.SVMXC__Process3__c)){
                            checkListCriteriaJunctionMap.put(criteriaJunctionRecord.SVMXC__Process2__c, criteriaJunctionRecord);
                        }else{
                            criteriaDeleteIds.add(criteriaJunctionRecord.SVMXC__Process3__c);
                        }
                    }
                }


                List<SVMXC__ServiceMax_Config_Data__c> allConfigList =  new List<SVMXC__ServiceMax_Config_Data__c>();
                for(Id checklistIdVal : checklistRuleHeaderInfoMap.keySet()){
                    Id criteriaExpressionId = checklistRuleHeaderInfoMap.get(checklistIdVal).Id;
                    if(checklistRuleExpressionsMap.containsKey(checklistIdVal)){
                        for(SVMXC__ServiceMax_Config_Data__c configRec : checklistRuleExpressionsMap.get(checklistIdVal)){
                            configRec.SVMXC__Expression_Rule__c = criteriaExpressionId;
                            allConfigList.add(configRec);
                        }
                    }

                    if(!checkListCriteriaJunctionMap.containsKey(checklistIdVal)){
                        SVMXC__ServiceMax_Processes__c criteraJunctionRecord = new SVMXC__ServiceMax_Processes__c();
                        criteraJunctionRecord.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
                        criteraJunctionRecord.recordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Process Business Rule');
                        criteraJunctionRecord.SVMXC__Process1__c = opdocProcessId;
                        criteraJunctionRecord.SVMXC__Process2__c = checklistIdVal;
                        criteraJunctionRecord.SVMXC__Process3__c = criteriaExpressionId;
                        checklistProcessJunctionList.add(criteraJunctionRecord);
                    }

                }

                Set<Id> configRecIds = new Set<Id>();
                if(!allConfigList.isEmpty()){
                    System.debug(LoggingLevel.INFO, 'Question Expressions Config List' + allConfigList.size());
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(allConfigList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    upsert allConfigList;

                    for(SVMXC__ServiceMax_Config_Data__c configRec : allConfigList){
                        configRecIds.add(configRec.Id);
                    }

                }

                if(!checklistProcessJunctionList.isEmpty()){
                    System.debug(LoggingLevel.INFO, 'checklistProcessJunctionList  :' + checklistProcessJunctionList.size());

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(checklistProcessJunctionList, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    upsert checklistProcessJunctionList;
                    for(SVMXC__ServiceMax_Processes__c linkedProcessRec : checklistProcessJunctionList){
                        if(linkedProcessRec.SVMXC__Rule_Type__c != 'Checklist Criteria in Output Doc' && linkedProcessRec.SVMXC__Process2__c != null && checklistProcessIdMap.containsKey(linkedProcessRec.SVMXC__Process2__c)){
                            SFM_WrapperDef2.SFM2_LinkedProcess linkedWrapProcess = checklistProcessIdMap.get(linkedProcessRec.SVMXC__Process2__c);
                            linkedWrapProcess.processId = linkedProcessRec.Id;
                            linkedWrapProcess.ruleInfo = null;
                            if(checklistRuleHeaderInfoMap.containsKey(linkedProcessRec.SVMXC__Process2__c)){
                                linkedWrapProcess.linkedProcessId = checklistRuleHeaderInfoMap.get(linkedProcessRec.SVMXC__Process2__c).Id;
                            }

                        }
                    }

                }


                if(!criteriaIdsWithRuleInfo.isEmpty()){

                    if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    List<SVMXC__ServiceMax_Config_Data__c> expressionRowsDeleteList = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN: criteriaIdsWithRuleInfo AND ID NOT IN: configRecIds];
                    if(!expressionRowsDeleteList.isEmpty()){
                        delete expressionRowsDeleteList;
                    }
                }

                if(!criteriaDeleteIds.isEmpty()){
                    SFM_DeleteProcesses.deleteEntities(criteriaDeleteIds, SFM_DesignerUtils.entity_checklistCriteria, null);
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception occurred while saving Checklist Tab :' + ex.getMessage() );
            throw ex;
        }
    }

    void mapJunctionRecordIds(List<SFM_WrapperDef2.SFM2_LinkedProcess> linkedProcessList, Map<String,Id> junctionRecordIdMap, String nodeId){

        String mapKey3;

        for(SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess : linkedProcessList){
            mapKey3 = nodeId + '' + linkedProcess.linkedProcessId;

            if(junctionRecordIdMap.containsKey(mapKey3)){
                linkedProcess.processId = junctionRecordIdMap.get(mapKey3);
            }
        }
    }

    private SVMXC__ServiceMax_Processes__c mapTargetManagerValuesToRecord(SFM_WrapperDef2.SFM2_EntityDetail targetManager){

        SVMXC__ServiceMax_Processes__c targetManagerEntry = new SVMXC__ServiceMax_Processes__c();
        targetManagerEntry.SVMXC__Name__c = targetManager.entityName;
        targetManagerEntry.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Target Manager');
        targetManagerEntry.SVMXC__IsStandard__c = targetManager.isStandard;
        targetManagerEntry.SVMXC__Description__c = targetManager.entityDescription;
        targetManagerEntry.SVMXC__Purpose__c = targetManager.entitySubType;
        targetManagerEntry.SVMXC__Dispatch_Process_Status__c = 'Incomplete';
        targetManagerEntry.SVMXC__Rule_Type__c = 'Interactive';

        if(targetManager.entityId != null){
            targetManagerEntry.Id = targetManager.entityId;
            if( targetManager.uniqueId != null ) {
                targetManagerEntry.SVMXC__ProcessID__c = targetManager.uniqueId;
            }
        }else{
            targetManagerEntry.SVMXC__ProcessID__c = SFM_DesignerUtils.generateUniqueId('SFM');
            targetManager.uniqueId = targetManagerEntry.SVMXC__ProcessID__c;
        }

        return targetManagerEntry;
    }


    SFM_WrapperDef2.SFM2_RuleExpression mapSourceUpdateRulesToWrapper(SVMXC__ServiceMax_Config_Data__c configRec){
        SFM_WrapperDef2.SFM2_RuleExpression ruleExpression = new SFM_WrapperDef2.SFM2_RuleExpression();
        ruleExpression.expressionId = configRec.Id;
        ruleExpression.sourceField = configRec.SVMXC__Source_Field_Name__c;
        ruleExpression.targetField = configRec.SVMXC__Target_Field_Name__c;
        ruleExpression.value = configRec.SVMXC__Display_Value__c;
        ruleExpression.displayValue = configRec.SVMXC__SM_Display_Value2__c;
        ruleExpression.targetNodeId = configRec.SVMXC__Setting_ID__c;
        ruleExpression.sourceNodeId = configRec.SVMXC__MapID__c;
        ruleExpression.action = configRec.SVMXC__Action__c;
        if(ruleExpression.targetField != null){
           ruleExpression.parameterType = 'Field Value';
        }else if(ruleExpression.value != null){
           ruleExpression.parameterType = 'Value';
            if(ruleExpression.value.startsWith('SVMX.') || SFM_DesignerUtils.supportedLiterals.contains(ruleExpression.value.toUpperCase())){
                ruleExpression.parameterType = 'Constant';
            }
        }else if(configRec.SVMXC__SM_Question__c != null){
            ruleExpression.value = configRec.SVMXC__SM_Question__c;
            ruleExpression.parameterType = 'Question';
        }
        return ruleExpression;
    }

    SVMXC__ServiceMax_Processes__c mapProcessNodeValuesToRecord(SFM_WrapperDef2.SFM2_ProcessNode processNode){
        SVMXC__ServiceMax_Processes__c processNodeEntry = new SVMXC__ServiceMax_Processes__c();

        if(processNode.nodeId != null){
            processNodeEntry.Id = processNode.nodeId;
        }

        processNodeEntry.SVMXC__Type__c = processNode.nodeType;

        processNodeEntry.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Process Node Objects');
        processNodeEntry.SVMXC__Target_Object_label__c = processNode.objectLabel;
        processNodeEntry.SVMXC__Source_Object_Name__c = processNode.objectAPIName;
        processNodeEntry.SVMXC__Node_Parent_API__c = processNode.nodeAPIName;
        processNodeEntry.SVMXC__Node_Source_Object_API__c = processNode.nodeSourceAPIName;
        processNodeEntry.SVMXC__Final_Exception_Process__c = processNode.valueMappingId;
        processNodeEntry.SVMXC__Module__c = processNode.fieldMappingId;
        /*
            To be Updated on QC Tab Save
        */
        processNodeEntry.SVMXC__Submodule__c = processNode.qcRuleId;
        processNodeEntry.SVMXC__Values__c = serializeAdvancedOptionsInfo(processNode.fieldSets, processNode.adv_SortingInfo);// processNode.adv_SortingInfo;
        processNodeEntry.SVMXC__Sequence__c = processNode.sequence;
        processNodeEntry.SVMXC__Source_Key__c = processNode.sequence;
        processNodeEntry.SVMXC__Parent_Column_Name__c = processNode.parentColumnAPIName;

        return processNodeEntry;
    }

    SVMXC__ServiceMax_Config_Data__c mapExpressionValuesToRecord(SFM_WrapperDef2.SFM2_RuleExpression expressionRec, SFM_WrapperDef2.SFM2_ProcessNode processNode){
        SVMXC__ServiceMax_Config_Data__c expressionEntry = new SVMXC__ServiceMax_Config_Data__c();
        if(expressionRec.expressionId != null){
            expressionEntry.Id = expressionRec.expressionId;
        }

        expressionEntry.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Field Mapping');
        expressionEntry.SVMXC__Configuration_Type__c = 'Source Update';
        expressionEntry.SVMXC__Source_Field_Name__c = expressionRec.sourceField;
        expressionEntry.SVMXC__Target_Field_Name__c = expressionRec.targetField;
        expressionEntry.SVMXC__Display_Value__c = expressionRec.value;
        if(expressionRec.parameterType == 'Question'){
            expressionEntry.SVMXC__Display_Value__c = null;
            expressionEntry.SVMXC__SM_Question__c = expressionRec.value;
        }
        expressionEntry.SVMXC__SM_Display_Value2__c = expressionRec.displayValue;
        expressionEntry.SVMXC__Action__c = expressionRec.action;
        expressionEntry.SVMXC__MapID__c = processNode.sourceNodeId;
        expressionEntry.SVMXC__Setting_ID__c = processNode.nodeId;

        return expressionEntry;
    }

    SVMXC__ServiceMax_Processes__c mapLinkedProcessValuesToRecord(SFM_WrapperDef2.SFM2_LinkedProcess linkedProcess, String processNodeId, String targetManagerId){
        SVMXC__ServiceMax_Processes__c linkedProcessEntry = new SVMXC__ServiceMax_Processes__c();

        if(linkedProcess.processId != null){
            linkedProcessEntry.Id = linkedProcess.processId;
        }

        linkedProcessEntry.SVMXC__Name__c = linkedProcess.linkedProcessName;
        linkedProcessEntry.SVMXC__Sequence__c = linkedProcess.sequence;
        linkedProcessEntry.SVMXC__Process1__c = targetManagerId;
        linkedProcessEntry.SVMXC__Process2__c = processNodeId;
        linkedProcessEntry.SVMXC__Process3__c = linkedProcess.linkedProcessId;
        linkedProcessEntry.SVMXC__SM_Checklist_Version__c = linkedProcess.checklistVersion;
        linkedProcessEntry.SVMXC__Parent_Error_Msg__c = linkedProcess.message;
        return linkedProcessEntry;
    }

    /*
        Serializes field Sets and Sorting info to object SFM_WrapperDef.FieldSetWithSorting
    */
    String serializeAdvancedOptionsInfo(List<String> fieldSets, List<SFM_WrapperDef.SortingRec> adv_SortingInfo){

        if(fieldSets != null || adv_SortingInfo != null){
            SFM_WrapperDef.FieldSetWithSorting fieldSetWithSorting = new SFM_WrapperDef.FieldSetWithSorting(fieldSets, adv_SortingInfo, null, null, null, null);
            return JSON.serialize(fieldSetWithSorting, true);
        }

        return null;
    }

    public void deleteRecords(String targetManagerId){


        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }


        String queryStr = 'SELECT Id ';

        if(processNodeIds != null){
            queryStr += ', (SELECT Id FROM ServiceMax_Processes3__r WHERE RecordType.Name = \'Process Node Objects\' AND Id NOT IN : processNodeIds) ';
        }

        if(expressionIds != null){
            queryStr += ', (SELECT Id FROM ServiceMax_Config_Data__r WHERE SVMXC__Configuration_Type__c = \'Source Update\' AND RecordType.Name = \'Field Mapping\' AND ID NOT IN: expressionIds) ';
        }

        if(linkedProcessIds != null || dvrProcessIds != null || formualaIds != null || checklistIds != null){
            String subQueryStr;
            queryStr += ', (SELECT Id FROM  ServiceMax_Processes1__r WHERE ';

            if(linkedProcessIds != null){
                subQueryStr = '(RecordType.Name = \'Linked Process\' AND ID NOT IN: linkedProcessIds) ';
            }

            if(dvrProcessIds != null || formualaIds != null || checklistIds != null){
                Set<String> entityIds = new Set<String>();

                if(dvrProcessIds != null){
                    if(subQueryStr != null){
                        subQueryStr += 'OR (RecordType.Name = \'Process Business Rule\' AND SVMXC__Process3__r.SVMXC__Rule_Type__c = NULL AND ID NOT IN: dvrProcessIds) ';
                    }else{
                        subQueryStr = '(RecordType.Name = \'Process Business Rule\' AND SVMXC__Process3__r.SVMXC__Rule_Type__c = NULL AND ID NOT IN: dvrProcessIds) ';
                    }
                }

                if(formualaIds != null){
                    if(subQueryStr != null){
                        subQueryStr += 'OR (RecordType.Name = \'Process Business Rule\' AND SVMXC__Process3__r.SVMXC__Rule_Type__c = \'Field Update Rule\' AND ID NOT IN: formualaIds) ';
                    }else{
                        subQueryStr = '(RecordType.Name = \'Process Business Rule\' AND SVMXC__Process3__r.SVMXC__Rule_Type__c = \'Field Update Rule\' AND ID NOT IN: formualaIds) ';
                    }
                }

                if(checklistIds != null){
                    if(subQueryStr != null){
                        subQueryStr += 'OR ((RecordType.Name = \'Checklist Smart Doc\' AND SVMXC__Process2__c NOT IN: checklistIds) OR (RecordType.Name = \'Process Business Rule\' AND (SVMXC__Process2__c NOT IN: checklistIds OR SVMXC__Process3__c = NULL))) ';
                    }else{
                        subQueryStr = '((RecordType.Name = \'Checklist Smart Doc\' AND SVMXC__Process2__c NOT IN: checklistIds) OR (RecordType.Name = \'Process Business Rule\' AND (SVMXC__Process2__c NOT IN: checklistIds OR SVMXC__Process3__c = NULL))) ';
                    }
                }

            }

            queryStr = queryStr + subQueryStr + ') ';
        }

        if(apiConfigIds != null){
             queryStr += ', (SELECT Id FROM SFM_Events__r WHERE SVMXC__Event_Type__c = \'Inventory Updates\' AND Id NOT IN : apiConfigIds) ';               
        }
        queryStr += ' FROM SVMXC__ServiceMax_Processes__c WHERE Id =: targetManagerId ';

        try{

            List<SVMXC__ServiceMax_Processes__c> processRecord = (List<SVMXC__ServiceMax_Processes__c>) Database.query(queryStr);

            if(!processRecord.isEmpty()){

                if(!processRecord[0].ServiceMax_Processes3__r.isEmpty()){
                    delete processRecord[0].ServiceMax_Processes3__r;
                }

                if(!processRecord[0].ServiceMax_Config_Data__r.isEmpty()){
                    delete processRecord[0].ServiceMax_Config_Data__r;
                }

                if(!processRecord[0].ServiceMax_Processes1__r.isEmpty()){
                    delete processRecord[0].ServiceMax_Processes1__r;
                }
                if(!processRecord[0].SFM_Events__r.isEmpty()){
                    delete processRecord[0].SFM_Events__r;
                }
            }
        }catch(DmlException ex){
            throw ex;
        }

    }

    private Set<String> createProcessKeySet( String strTagKeys ) {

        Set<String> setExistingKeys = new Set<String>();
        if( strTagKeys != NULL && strTagKeys.length() > 0 ) {
            String[] tagArray = strTagKeys.split(';');
            for( String tag : tagArray ) {
                setExistingKeys.add(tag + ';');
            }
            //setExistingKeys.addAll(strTagKeys.split(';'));
        }

        return setExistingKeys;
    }

    // Tag Keys for page layouts
    private String updatePageLayoutTagKey( String pageLayoutId, String layoutTagKeys ) {

        if( pageLayoutId != null ) {
            Set<Id> pageLayoutIds = new Set<Id>();
            //List<SVMXC__Page_Layout__c> pageLayoutList = new List<SVMXC__Page_Layout__c>();

            for(SVMXC__Page_Layout__c objPageLayout : [Select Id, SVMXC__Page_Help__c, SVMXC__Page_Layout_ID__c, SVMXC__Type__c, SVMXC__Name__c,  SVMXC__Header_Page_Layout__c from SVMXC__Page_Layout__c where (Id =: pageLayoutId OR SVMXC__Header_Page_Layout__c =: pageLayoutId) AND SVMXC__Type__c IN ('Header', 'Detail') AND SVMXC__Type__c != null]) {

                if(objPageLayout.SVMXC__Name__c != null && objPageLayout.SVMXC__Type__c == 'Detail') {
                    String strUniqueKey = manageTranslations.generate_UniqueKeys(objPageLayout.SVMXC__Name__c, null, null, 'SFM_SECTION_TITLE');
                    if(strUniqueKey != null && !createProcessKeySet(layoutTagKeys).contains(strUniqueKey))
                        layoutTagKeys += strUniqueKey;
                }
                if(objPageLayout.SVMXC__Page_Help__c != null && objPageLayout.SVMXC__Page_Layout_ID__c != null)
                {
                    String strUniqueKey = manageTranslations.generate_UniqueKeys(objPageLayout.SVMXC__Page_Help__c, objPageLayout.SVMXC__Page_Layout_ID__c, '_PAGEHELP', 'SFM_PAGE_HELP');
                    if(strUniqueKey != null && !createProcessKeySet(layoutTagKeys).contains(strUniqueKey))
                       layoutTagKeys += strUniqueKey;
                }
                //pageLayoutList.add(objPageLayout);
                pageLayoutIds.add(objPageLayout.Id);
            }

            for(SVMXC__Page_Layout_Detail__c objPageLayoutDetail : [Select SVMXC__Page_Layout__c, SVMXC__Detail_Type__c, SVMXC__Page_Layout__r.SVMXC__Type__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__Type__c, SVMXC__Title__c from SVMXC__Page_Layout_Detail__c where (SVMXC__Page_Layout__c IN: pageLayoutIds OR SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c IN: pageLayoutIds) AND SVMXC__Detail_Type__c IN ('Button', 'Section')]){

                if(objPageLayoutDetail.SVMXC__Title__c != null && objPageLayoutDetail.SVMXC__Title__c.length() > 0) {

                    String strTagContext = '';
                    if(objPageLayoutDetail.SVMXC__Detail_Type__c == 'Section')
                        strTagContext = 'SFM_SECTION_TITLE';
                    else if(objPageLayoutDetail.SVMXC__Detail_Type__c == 'Button')
                        strTagContext = 'SFM_BUTTON_TITLE';
                    String strUniqueKey = manageTranslations.generate_UniqueKeys(objPageLayoutDetail.SVMXC__Title__c, null, null, strTagContext);
                    if(strUniqueKey != null && !createProcessKeySet(layoutTagKeys).contains(strUniqueKey)) {
                        layoutTagKeys += strUniqueKey;
                    }
                }
            }

        }
        return layoutTagKeys;
    }
}