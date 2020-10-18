/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * The SFA_ConfigurationUtility provides methods of implementation to retrieve list of Service Flow Automation
 * Processes. Also, it provides method to save, edit and delete SFA processes.
 *
 *
 * @author Manish Kushwah
 * @version 19.2
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         20 March 2019     Created.
 *   Soumyaranjan Pati      6th Sept 2019     Changes objGeofenceEventJson and objGeofenceActionJson for BAC-5214
 *****************************************************************************************************/

public with sharing class SFA_ConfigurationUtility {

    private static List<String> DEFAULT_BLACK_LIST_OBJECTS = new List<String>{
      'AttachedContentDocument', 'Attachment', 'CollaborationGroupRecord', 'CombinedAttachment',
      'ContactRequest', 'ContentDistribution', 'ContentDocumentLink', 'ContentVersion', 'DuplicateRecordItem',
      'EmailMessage', 'EntitySubscription', 'FeedComment', 'FeedItem', 'FlowRecordRelation', 'Note',
      'NoteAndAttachment', 'OpenActivity', 'OutgoingEmail', 'ProcessInstance', 'RecordAction', 'Task', 'TopicAssignment'};

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetListOfProcesses(SFA_WrapperDef.SFA_ConfigurationRequest request){

        List<SFA_WrapperDef.SFA_ProcessDetail> lstSFAProcess = new List<SFA_WrapperDef.SFA_ProcessDetail>();

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        try{
            List<SVMXC__SM_SFA_Process__c> lstSFAProcesses = [SELECT Id, SVMXC__SM_SFA_Process_Id__c, SVMXC__SM_SFA_Process_Name__c, SVMXC__SM_Event_Type__c, SVMXC__SM_Action_Type__c, SVMXC__SM_Enabled__c, LastModifiedDate, SVMXC__SM_SVMX_Group_Profile__r.SVMXC__Profile_Name__c FROM SVMXC__SM_SFA_Process__c Order By LastModifiedDate]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

            if(lstSFAProcesses.size() > 0){
                for(SVMXC__SM_SFA_Process__c objSFAProcess : lstSFAProcesses){

                    SFA_WrapperDef.SFA_ProcessDetail objProcessDetail = new SFA_WrapperDef.SFA_ProcessDetail();
                    objProcessDetail.strSFAId = objSFAProcess.Id;
                    objProcessDetail.strSFAProcessId = objSFAProcess.SVMXC__SM_SFA_Process_Id__c;
                    objProcessDetail.strSFAProcessName = objSFAProcess.SVMXC__SM_SFA_Process_Name__c;
                    objProcessDetail.strEventType = objSFAProcess.SVMXC__SM_Event_Type__c;
                    objProcessDetail.strActionType = objSFAProcess.SVMXC__SM_Action_Type__c;
                    objProcessDetail.isEnabled = objSFAProcess.SVMXC__SM_Enabled__c;
                    objProcessDetail.strLastActivity = String.valueOfGmt(objSFAProcess.LastModifiedDate); //Changed String.valueOf to String.valueOfGmt for fixing defect BAC-5086
                    objProcessDetail.strGroupProfileName = objSFAProcess.SVMXC__SM_SVMX_Group_Profile__r.SVMXC__Profile_Name__c;

                    lstSFAProcess.add(objProcessDetail);
                }
                objResponse.lstSFAProcesses = lstSFAProcess;
            }
            else{
                objResponse.success = true;
                objResponse.lstSFAProcesses = lstSFAProcess;
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetListOfProcesses method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetListOfProcesses method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetListOfProcesses method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetProcessInfo(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);
        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        try{
            if(request != null && !String.isBlank(request.strSFAId)){
                String strProcessId = String.escapeSingleQuotes(request.strSFAId);

                List<SVMXC__SM_SFA_Process__c> lstSFAProcess = [SELECT Id, SVMXC__SM_SFA_Process_Id__c, SVMXC__SM_SFA_Process_Name__c, SVMXC__SM_Event_Type__c, SVMXC__SM_Action_Type__c,
                                                                    SVMXC__SM_Enabled__c, SVMXC__SM_Description__c, SVMXC__SM_Expression__c, SVMXC__SM_Object_API_Name__c,
                                                                    SVMXC__SM_SFA_Action_JSON__c, SVMXC__SM_SFA_Event_JSON__c, SVMXC__SM_SFM_Process_Name__c, SVMXC__SM_SVMX_Group_Profile__c
                                                                    FROM SVMXC__SM_SFA_Process__c WHERE Id =: strProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                if(lstSFAProcess.size() > 0){
                    SVMXC__SM_SFA_Process__c objSFAProcess = lstSFAProcess[0];
                    SFA_WrapperDef.SFA_ProcessInformation objProcessInfo = new SFA_WrapperDef.SFA_ProcessInformation();
                    objProcessInfo.strSFAId = objSFAProcess.Id;
                    objProcessInfo.strSFAProcessId = objSFAProcess.SVMXC__SM_SFA_Process_Id__c;
                    objProcessInfo.strSFAProcessName = objSFAProcess.SVMXC__SM_SFA_Process_Name__c;
                    objProcessInfo.strDescription = objSFAProcess.SVMXC__SM_Description__c;
                    objProcessInfo.isEnabled = objSFAProcess.SVMXC__SM_Enabled__c;
                    objProcessInfo.strEventType = objSFAProcess.SVMXC__SM_Event_Type__c;
                    objProcessInfo.strActionType = objSFAProcess.SVMXC__SM_Action_Type__c;
                    objProcessInfo.strObjectApiName = objSFAProcess.SVMXC__SM_Object_API_Name__c;
                    objProcessInfo.strExpressionId = objSFAProcess.SVMXC__SM_Expression__c;
                    objProcessInfo.strSFMProcessId = objSFAProcess.SVMXC__SM_SFM_Process_Name__c;
                    objProcessInfo.strSVMXGroupProfileId = objSFAProcess.SVMXC__SM_SVMX_Group_Profile__c;

                    if(!String.isBlank(objSFAProcess.SVMXC__SM_SFA_Event_JSON__c) && !String.isBlank(objSFAProcess.SVMXC__SM_Event_Type__c)){
                        if(objSFAProcess.SVMXC__SM_Event_Type__c.equals('Salesforce Event')){
                            objProcessInfo.objSFDCEventJson = (SFA_WrapperDef.SFA_SFDCEventJsonWrapper)JSON.deserialize(objSFAProcess.SVMXC__SM_SFA_Event_JSON__c, SFA_WrapperDef.SFA_SFDCEventJsonWrapper.class);
                        }
                        else if(objSFAProcess.SVMXC__SM_Event_Type__c.equals('Geofence')){
                            objProcessInfo.objGeofenceEventJson = (SFA_WrapperDef.SFA_GeofenceEventJsonWrapper)JSON.deserialize(objSFAProcess.SVMXC__SM_SFA_Event_JSON__c, SFA_WrapperDef.SFA_GeofenceEventJsonWrapper.class);
                        }
                    }
                    if(!String.isBlank(objSFAProcess.SVMXC__SM_SFA_Action_JSON__c) && !String.isBlank(objSFAProcess.SVMXC__SM_Action_Type__c)){
                        if(objSFAProcess.SVMXC__SM_Action_Type__c.equals('Push Notification')){
                            objProcessInfo.objSFDCActionJson = (SFA_WrapperDef.SFA_SFDCActionJsonWrapper)JSON.deserialize(objSFAProcess.SVMXC__SM_SFA_Action_JSON__c, SFA_WrapperDef.SFA_SFDCActionJsonWrapper.class);
                        }else if(objSFAProcess.SVMXC__SM_Action_Type__c.equals('Local Notification')){
                            objProcessInfo.objGeofenceActionJson = (SFA_WrapperDef.SFA_GeofenceActionJsonWrapper)JSON.deserialize(objSFAProcess.SVMXC__SM_SFA_Action_JSON__c, SFA_WrapperDef.SFA_GeofenceActionJsonWrapper.class);
                        }else if(objSFAProcess.SVMXC__SM_Action_Type__c.equals('SMS')){ // Added for BAC-5214
                            objProcessInfo.objSMSActionJson = (SFA_WrapperDef.SFA_SMSActionJsonWrapper)JSON.deserialize(objSFAProcess.SVMXC__SM_SFA_Action_JSON__c, SFA_WrapperDef.SFA_SMSActionJsonWrapper.class);
                        }

                    }
                    objResponse.objSFAProcessInfo = objProcessInfo;
                }
                else{
                    objResponse.success = false;
                    objResponse.message = 'SFA Process Not found';
                }
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetProcessInfo method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetProcessInfo method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetProcessInfo method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_DeleteProcess(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);
        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        try{
            if(request != null && !String.isBlank(request.strSFAId)){
                String strProcessId = String.escapeSingleQuotes(request.strSFAId);

                List<SVMXC__SM_SFA_Process__c> lstSFAProcess = [SELECT Id FROM SVMXC__SM_SFA_Process__c WHERE Id =: strProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                if(lstSFAProcess.size() > 0){
                    delete lstSFAProcess; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    objResponse.message = 'SFA Process successfully deleted';
                }
                else{
                    objResponse.success = false;
                    objResponse.message = 'SFA Process Not found for deletion';
                }
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_DeleteProcess method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_DeleteProcess method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_DeleteProcess method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_SaveProcess(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);
        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        try{
            if(request != null && request.objSFAProcessInfo != null){
                SVMXC__SM_SFA_Process__c objSFAProcess = new SVMXC__SM_SFA_Process__c();
                if(!String.isBlank(request.objSFAProcessInfo.strSFAId)){
                    objSFAProcess.Id = request.objSFAProcessInfo.strSFAId;

                    if(!String.isBlank(request.objSFAProcessInfo.strSFAProcessId)){
                        String SFAProcessId = String.escapeSingleQuotes(request.objSFAProcessInfo.strSFAProcessId);

                        List<SVMXC__SM_SFA_Process__c> lstSFAProcess = [SELECT Id FROM SVMXC__SM_SFA_Process__c WHERE SVMXC__SM_SFA_Process_Id__c =: SFAProcessId AND Id !=: objSFAProcess.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(lstSFAProcess.size() > 0){
                            objResponse.success = false;
                            objResponse.message = 'SFA process with given name already exist. Please provide another name.';
                            System.debug(LoggingLevel.WARN, 'Response of SFA_SaveProcess method: ' + objResponse);
                            return objResponse;
                        }
                    }
                }
                else if(!String.isBlank(request.objSFAProcessInfo.strSFAProcessId)){
                    String SFAProcessId = String.escapeSingleQuotes(request.objSFAProcessInfo.strSFAProcessId);

                    List<SVMXC__SM_SFA_Process__c> lstSFAProcess = [SELECT Id FROM SVMXC__SM_SFA_Process__c WHERE SVMXC__SM_SFA_Process_Id__c =: SFAProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstSFAProcess.size() > 0){
                        objResponse.success = false;
                        objResponse.message = 'SFA process with given name already exist. Please provide another name.';
                        System.debug(LoggingLevel.WARN, 'Response of SFA_SaveProcess method: ' + objResponse);
                        return objResponse;
                    }
                }

                objSFAProcess.SVMXC__SM_SFA_Process_Id__c = request.objSFAProcessInfo.strSFAProcessId;
                objSFAProcess.SVMXC__SM_SFA_Process_Name__c = request.objSFAProcessInfo.strSFAProcessName;
                objSFAProcess.SVMXC__SM_Description__c = request.objSFAProcessInfo.strDescription;
                objSFAProcess.SVMXC__SM_Enabled__c = request.objSFAProcessInfo.isEnabled;
                objSFAProcess.SVMXC__SM_Event_Type__c = request.objSFAProcessInfo.strEventType;
                objSFAProcess.SVMXC__SM_Action_Type__c = request.objSFAProcessInfo.strActionType;
                objSFAProcess.SVMXC__SM_Object_API_Name__c = request.objSFAProcessInfo.strObjectApiName;
                objSFAProcess.SVMXC__SM_Expression__c = request.objSFAProcessInfo.strExpressionId;
                objSFAProcess.SVMXC__SM_SFM_Process_Name__c = request.objSFAProcessInfo.strSFMProcessId;
                objSFAProcess.SVMXC__SM_SVMX_Group_Profile__c = request.objSFAProcessInfo.strSVMXGroupProfileId;

                if(request.objSFAProcessInfo.objSFDCEventJson != null){
                    objSFAProcess.SVMXC__SM_SFA_Event_JSON__c = JSON.serialize(request.objSFAProcessInfo.objSFDCEventJson);
                }
                else if(request.objSFAProcessInfo.objGeofenceEventJson != null){
                    objSFAProcess.SVMXC__SM_SFA_Event_JSON__c = JSON.serialize(request.objSFAProcessInfo.objGeofenceEventJson);
                }


                if(request.objSFAProcessInfo.objSFDCActionJson != null){
                    objSFAProcess.SVMXC__SM_SFA_Action_JSON__c = JSON.serialize(request.objSFAProcessInfo.objSFDCActionJson);
                }
                else if(request.objSFAProcessInfo.objGeofenceActionJson != null){
                    objSFAProcess.SVMXC__SM_SFA_Action_JSON__c = JSON.serialize(request.objSFAProcessInfo.objGeofenceActionJson);
                }
                else if(request.objSFAProcessInfo.objSMSActionJson != null){ // Added for for BAC-5214
                    objSFAProcess.SVMXC__SM_SFA_Action_JSON__c = JSON.serialize(request.objSFAProcessInfo.objSMSActionJson);
                }

                upsert objSFAProcess; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objResponse.message = 'SFA Process successfully saved';
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_SaveProcess method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_SaveProcess method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_SaveProcess method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetExpressionDetails(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        try{
            if(request != null && !String.isBlank(request.strFilterId)){
                List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = [SELECT Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operand__c, SVMXC__Operator__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Rule__r.SVMXC__Name__c, SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c, SVMXC__Expression_Rule__r.SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c =: request.strFilterId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                if(lstConfigData.size() > 0){
                    SFA_WrapperDef.SFA_Expression objExpression = new SFA_WrapperDef.SFA_Expression();

                    Boolean getHeaderInfo = false;
                    List<SFA_WrapperDef.SFA_ExpressionDetail> lstExpressionDetail = new List<SFA_WrapperDef.SFA_ExpressionDetail>();
                    for(SVMXC__ServiceMax_Config_Data__c objConfigData : lstConfigData){

                        if(!getHeaderInfo){
                            objExpression.strExpressionSFId = objConfigData.SVMXC__Expression_Rule__c;
                            objExpression.strExpressionProcessId = objConfigData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c;
                            objExpression.strExpressionProcessName = objConfigData.SVMXC__Expression_Rule__r.SVMXC__Name__c;
                            objExpression.strAdvancedExpr = objConfigData.SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c;
                            objExpression.isStandard = objConfigData.SVMXC__Expression_Rule__r.SVMXC__IsStandard__c;
                            getHeaderInfo = true;
                        }

                        SFA_WrapperDef.SFA_ExpressionDetail objExpressionDetail = new SFA_WrapperDef.SFA_ExpressionDetail();
                        objExpressionDetail.strSequence = String.valueOf(objConfigData.SVMXC__Sequence__c);
                        objExpressionDetail.strFieldName = objConfigData.SVMXC__Field_Name__c;
                        objExpressionDetail.strOperator = objConfigData.SVMXC__Operator__c;
                        objExpressionDetail.strOperand = objConfigData.SVMXC__Operand__c;
                        objExpressionDetail.strFieldDataType = objConfigData.SVMXC__Display_Type__c;

                        lstExpressionDetail.add(objExpressionDetail);
                    }
                    objExpression.lstExprDetails = lstExpressionDetail;
                    objResponse.objExpression = objExpression;
                }
                else{
                    objResponse.success = false;
                    objResponse.message = 'There is no valid rules for given expression id';
                }
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetExpressionDetails method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetExpressionDetails method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetExpressionDetails method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetFieldList(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        List<SFA_WrapperDef.SFA_ItemListInformation> lstSFA_ItemListInformation = new List<SFA_WrapperDef.SFA_ItemListInformation>();

        try{
            if(request != null && request.lstObjectName.size() > 0){
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(request.lstObjectName);

                for(Schema.DescribeSobjectResult ojbSObjectResult: results){
                    SFA_WrapperDef.SFA_ItemListInformation objItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();
                    objItemListInformation.strObjectLabel = ojbSObjectResult.getLabel();
                    objItemListInformation.strObjectValue = ojbSObjectResult.getName();

                    Map<String, Schema.SObjectField> mapFields = ojbSObjectResult.fields.getMap();
                    COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
                    mapFields = objCommUtilV2.removeDuplicateFields(mapFields);

                    List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
                    for(Schema.SObjectField objSObjectField : mapFields.values()){
                        SFA_WrapperDef.SFA_ItemList objItemList = new SFA_WrapperDef.SFA_ItemList();
                        objItemList.strValue = objSObjectField.getDescribe().getName();
                        objItemList.strLabel = objSObjectField.getDescribe().getLabel();
                        lstSFA_ItemList.add(objItemList);
                    }

                    objItemListInformation.lstFieldList = lstSFA_ItemList;
                    lstSFA_ItemListInformation.add(objItemListInformation);
                }
                objResponse.lstItemListInformation = lstSFA_ItemListInformation;
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetFieldList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetFieldList method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetFieldList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetCustomActionList(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            if(request != null && !String.isBlank(request.strObjectName)){
                objSFA_ItemListInformation.strObjectValue = request.strObjectName;
                //Added where clause condition SVMXC__Process__r.SVMXC__IsPrivate__c = false for the defect BAC-5082
                List<SVMXC__ServiceMax_Processes__c> lstCustomActions = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c  WHERE SVMXC__Record_Type_Name__c = 'SF Action' AND SVMXC__Source_Object_Name__c =: request.strObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                Set<Id> setIds = new Set<Id>();
                List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
                for(SVMXC__ServiceMax_Processes__c objCustomAction : lstCustomActions){
                    if(!setIds.contains(objCustomAction.SVMXC__ProcessID__c)){
                        SFA_WrapperDef.SFA_ItemList objSFA_ItemList = new SFA_WrapperDef.SFA_ItemList();
                        objSFA_ItemList.strValue = objCustomAction.Id;
                        objSFA_ItemList.strValueId = objCustomAction.SVMXC__ProcessID__c;
                        objSFA_ItemList.strLabel = objCustomAction.SVMXC__Name__c;
                        lstSFA_ItemList.add(objSFA_ItemList);
                        setIds.add(objCustomAction.SVMXC__ProcessID__c);
                    }
                }
                objSFA_ItemListInformation.lstSFM = lstSFA_ItemList;
                objResponse.objItemListInformation = objSFA_ItemListInformation;
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetCustomActionList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetCustomActionList method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetCustomActionList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetSFMList(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            if(request != null && !String.isBlank(request.strObjectName)){
                objSFA_ItemListInformation.strObjectValue = request.strObjectName;
                //Added where clause condition SVMXC__Process__r.SVMXC__IsPrivate__c = false for the defect BAC-5082
                List<SVMXC__ServiceMax_Processes__c> lstSFMProcess = [SELECT SVMXC__Process__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Process__r.SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c  WHERE SVMXC__Record_Type_Name__c = 'Process Node Objects' AND SVMXC__Type__c = 'TARGET' AND SVMXC__Source_Object_Name__c =: request.strObjectName AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = 'Complete' AND SVMXC__Process__r.SVMXC__IsPrivate__c = false AND (SVMXC__Process__r.SVMXC__Purpose__c = 'VIEW RECORD' OR SVMXC__Process__r.SVMXC__Purpose__c = 'STANDALONE EDIT')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                Set<Id> setIds = new Set<Id>();
                List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
                for(SVMXC__ServiceMax_Processes__c objPNO : lstSFMProcess){

                    if(!setIds.contains(objPNO.SVMXC__Process__c)){

                        SFA_WrapperDef.SFA_ItemList objSFA_ItemList = new SFA_WrapperDef.SFA_ItemList();
                        objSFA_ItemList.strValue = objPNO.SVMXC__Process__c;
                        objSFA_ItemList.strValueId = objPNO.SVMXC__Process__r.SVMXC__ProcessID__c;
                        objSFA_ItemList.strLabel = objPNO.SVMXC__Process__r.SVMXC__Name__c;
                        lstSFA_ItemList.add(objSFA_ItemList);

                        setIds.add(objPNO.SVMXC__Process__c);
                    }
                }
                objSFA_ItemListInformation.lstSFM = lstSFA_ItemList;
                objResponse.objItemListInformation = objSFA_ItemListInformation;
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetSFMList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetSFMList method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetSFMList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetFilterList(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            if(request != null && !String.isBlank(request.strObjectName)){
                objSFA_ItemListInformation.strObjectValue = request.strObjectName;

                List<SVMXC__ServiceMax_Processes__c> lstExpression = [SELECT Id, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Source_Object_Name__c =: request.strObjectName AND SVMXC__Rule_Type__c = 'Named Expression']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
                for(SVMXC__ServiceMax_Processes__c objExpression : lstExpression){

                    SFA_WrapperDef.SFA_ItemList objSFA_ItemList = new SFA_WrapperDef.SFA_ItemList();
                    objSFA_ItemList.strValue = objExpression.Id;
                    objSFA_ItemList.strLabel = objExpression.SVMXC__Name__c;

                    lstSFA_ItemList.add(objSFA_ItemList);
                }
                objSFA_ItemListInformation.lstFilterList = lstSFA_ItemList;
                objResponse.objItemListInformation = objSFA_ItemListInformation;
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetFilterList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetFilterList method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetFilterList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetGroupProfileList(SFA_WrapperDef.SFA_ConfigurationRequest request){

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            List<SVMXC__ServiceMax_Config_Data__c> lstGroupProfile = [SELECT Id, SVMXC__Profile_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__Active__c = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

            List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
            for(SVMXC__ServiceMax_Config_Data__c objProfile : lstGroupProfile){
                SFA_WrapperDef.SFA_ItemList objSFA_ItemList = new SFA_WrapperDef.SFA_ItemList();
                objSFA_ItemList.strValue = objProfile.Id;
                objSFA_ItemList.strLabel = objProfile.SVMXC__Profile_Name__c;

                lstSFA_ItemList.add(objSFA_ItemList);
            }
            objSFA_ItemListInformation.lstGroupProfile = lstSFA_ItemList;
            objResponse.objItemListInformation = objSFA_ItemListInformation;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetGroupProfileList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetGroupProfileList method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetGroupProfileList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetFieldsOfLookupToObject(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            if(request != null && !String.isBlank(request.strObjectName) && request.lstLookupToObject != null && request.lstLookupToObject.size() > 0){
                Set<String> setLookupToObject = new Set<String>(request.lstLookupToObject);
                //Start Added for BAC-5214
                Boolean relatedObjectRequest = true;
                if(request.relatedObjectDetails ==null || request.relatedObjectDetails == false){
                    relatedObjectRequest = false;
                }
                //End Added for BAC-5214
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{request.strObjectName});

                for(Schema.DescribeSobjectResult ojbSObjectResult: results){
                    objSFA_ItemListInformation.strObjectLabel = ojbSObjectResult.getLabel();
                    objSFA_ItemListInformation.strObjectValue = ojbSObjectResult.getName();

                    Map<String, Schema.SObjectField> mapFields = ojbSObjectResult.fields.getMap();
                    COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
                    mapFields = objCommUtilV2.removeDuplicateFields(mapFields);

                    List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
                    for(Schema.SObjectField objSObjectField : mapFields.values()){
                        Schema.DescribeFieldResult objDescribeFieldResult = objSObjectField.getDescribe();
                        System.debug('objDescribeFieldResult '+objDescribeFieldResult);
                        List<Schema.sObjectType> lstsObjectType = objDescribeFieldResult.getReferenceTo();

                        if(lstsObjectType != null && lstsObjectType.size() == 1 && setLookupToObject.contains(lstsObjectType[0].getDescribe().getName())) {
                            System.debug('lstsObjectType '+lstsObjectType);
                            SFA_WrapperDef.SFA_ItemList objItemList = new SFA_WrapperDef.SFA_ItemList();
                            objItemList.strValue = objDescribeFieldResult.getName();
                            objItemList.strLabel = objDescribeFieldResult.getLabel();
                            if(relatedObjectRequest){ //Added for BAC-5214
                                objItemList.strRelatedObjectName = lstsObjectType[0].getDescribe().getName();  //Added for BAC-5214
                                objItemList.strRelatedRefFieldName = objDescribeFieldResult.getRelationshipName(); //Added for BAC-5214
                            }
                            lstSFA_ItemList.add(objItemList);
                        }
                        else if(lstsObjectType != null && lstsObjectType.size() > 1){
                            System.debug('lstsObjectType '+lstsObjectType);
                            for(Schema.sObjectType objsObjectType : lstsObjectType){
                                if(setLookupToObject.contains(objsObjectType.getDescribe().getName())){
                                    SFA_WrapperDef.SFA_ItemList objItemList = new SFA_WrapperDef.SFA_ItemList();
                                    objItemList.strValue = objDescribeFieldResult.getName();
                                    objItemList.strLabel = objDescribeFieldResult.getLabel();
                                    if(relatedObjectRequest){ //Added for BAC-5214
                                        objItemList.strRelatedObjectName = objsObjectType.getDescribe().getName();  //Added for BAC-5214
                                        objItemList.strRelatedRefFieldName = objDescribeFieldResult.getRelationshipName(); //Added for BAC-5214
                                    }
                                    lstSFA_ItemList.add(objItemList);
                                }
                            }
                        }
                    }
                    objSFA_ItemListInformation.lstFieldList = lstSFA_ItemList;
                    objResponse.objItemListInformation = objSFA_ItemListInformation;
                }
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetFieldsOfLookupToObject method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetFieldsOfLookupToObject method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetFieldsOfLookupToObject method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetObjectList(SFA_WrapperDef.SFA_ConfigurationRequest request){

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            Schema.DescribeSobjectResult[] sobjectResults = Schema.describeSObjects(new List<String>{'SVMXC__Service_Order__c','SVMXC__SVMX_Event__c','Event'});

            List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();

            if(sobjectResults != null && sobjectResults.size() > 0){

                for(Schema.DescribeSobjectResult ojbSObjectResult: sobjectResults){
                    SFA_WrapperDef.SFA_ItemList objItemList = new SFA_WrapperDef.SFA_ItemList();
                    objItemList.strValue = ojbSObjectResult.getName();
                    objItemList.strLabel = ojbSObjectResult.getLabel();

                    lstSFA_ItemList.add(objItemList);
                }
                objSFA_ItemListInformation.lstObject = lstSFA_ItemList;
                objResponse.objItemListInformation = objSFA_ItemListInformation;
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetObjectList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetObjectList method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetObjectList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetCustomLabels(SFA_WrapperDef.SFA_ConfigurationRequest request){

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        List<SFA_WrapperDef.SFA_CustomLabel> lstSFA_CustomLabel = new List<SFA_WrapperDef.SFA_CustomLabel>();

        lstSFA_CustomLabel.add(new SFA_WrapperDef.SFA_CustomLabel('TAG001', 'TagValue'));
        lstSFA_CustomLabel.add(new SFA_WrapperDef.SFA_CustomLabel('TAG002', 'TagValue'));
        lstSFA_CustomLabel.add(new SFA_WrapperDef.SFA_CustomLabel('TAG003', 'TagValue'));

        objResponse.lstCustomLabel = lstSFA_CustomLabel;

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetObjectList method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetUserInfo(SFA_WrapperDef.SFA_ConfigurationRequest request){

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        try{
            SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();

            SFA_WrapperDef.UserInfoWrapper userRecord = new SFA_WrapperDef.UserInfoWrapper();
            userRecord.userId = UserInfo.getUserId();
            userRecord.firstName = UserInfo.getFirstName();
            userRecord.lastName = UserInfo.getLastName();
            userRecord.dateFormat = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(userRecord.userId);
            userRecord.timeZoneOffSet = constantUtils.getUserTimezoneOffset();
            userRecord.timeFormat = 'h:mm A';
            Map<String,String> numberFormatMap = constantUtils.getDecimalSeparator();
            userRecord.thousandSepartor = numberFormatMap.get('TS') ;
            userRecord.decimalSeparator = numberFormatMap.get('DS') ;
            userRecord.userCurrency = UserInfo.getDefaultCurrency();
            userRecord.svmxNameSpace = DCON_Service_Org_WS.getnamespace();

            objResponse.objUserInfo = userRecord;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetUserInfo method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetUserInfo method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetUserInfo method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetFieldListByDataType(SFA_WrapperDef.SFA_ConfigurationRequest request){

        System.debug(LoggingLevel.WARN, 'Request: ' + request);

        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;

        List<SFA_WrapperDef.SFA_ItemListInformation> lstSFA_ItemListInformation = new List<SFA_WrapperDef.SFA_ItemListInformation>();

        try{
            if(request != null && !String.isBlank(request.strObjectName) && request.lstDataType != null && request.lstDataType.size() > 0){
                Set<String> setDataType = new Set<String>(request.lstDataType);
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{request.strObjectName});

                for(Schema.DescribeSobjectResult ojbSObjectResult: results){
                    SFA_WrapperDef.SFA_ItemListInformation objItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();
                    objItemListInformation.strObjectLabel = ojbSObjectResult.getLabel();
                    objItemListInformation.strObjectValue = ojbSObjectResult.getName();

                    Map<String, Schema.SObjectField> mapFields = ojbSObjectResult.fields.getMap();
                    COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
                    mapFields = objCommUtilV2.removeDuplicateFields(mapFields);

                    List<SFA_WrapperDef.SFA_ItemList> lstSFA_ItemList = new List<SFA_WrapperDef.SFA_ItemList>();
                    for(Schema.SObjectField objSObjectField : mapFields.values()){
                        Schema.DescribeFieldResult objDescribeFieldResult = objSObjectField.getDescribe();
                        if(setDataType.contains(String.valueOf(objDescribeFieldResult.getType()))){
                            SFA_WrapperDef.SFA_ItemList objItemList = new SFA_WrapperDef.SFA_ItemList();
                            objItemList.strValue = objDescribeFieldResult.getName();
                            objItemList.strLabel = objDescribeFieldResult.getLabel();
                            lstSFA_ItemList.add(objItemList);
                        }
                    }

                    objItemListInformation.lstFieldList = lstSFA_ItemList;
                    lstSFA_ItemListInformation.add(objItemListInformation);
                }
                objResponse.lstItemListInformation = lstSFA_ItemListInformation;
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetFieldListByDataType method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetFieldListByDataType method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetFieldListByDataType method: ' + objResponse);
        return objResponse;
    }

    public SFA_WrapperDef.SFA_ConfigurationResponse SFA_GetRelatedListToObject(SFA_WrapperDef.SFA_ConfigurationRequest request){
        System.debug(LoggingLevel.WARN, 'Request: ' + request);
        SFA_WrapperDef.SFA_ConfigurationResponse objResponse = new SFA_WrapperDef.SFA_ConfigurationResponse();
        objResponse.success = true;
        SFA_WrapperDef.SFA_ItemListInformation objSFA_ItemListInformation = new SFA_WrapperDef.SFA_ItemListInformation();

        try{
            List<String> blackListedObjects = new List<String>();
            blackListedObjects.addAll(DEFAULT_BLACK_LIST_OBJECTS);
            COMM_Utils_ManageSettings commSettings = new COMM_Utils_ManageSettings();

            if(request != null && !String.isBlank(request.strObjectName)) {
              Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{request.strObjectName});
              //List<String> childSObjects = new List<String>();
              Map<String, List<String>> childSObjectsFields = new Map<String, List<String>>();
              Map<String, Map<String, String>> childSObjectsFieldsRelationShipName = new Map<String, Map<String, String>>();
              for(Schema.DescribeSobjectResult res: results) {
                //childSObjects.add(rels.getChildSObject());
                for (Schema.ChildRelationship rels: res.getChildRelationships()) {
                  String objectName = rels.getChildSObject().getDescribe().getName();
                  if (!objectName.endswith('History') && !objectName.endswith('Tag') && !objectName.endswith('ChangeEvent') && !blackListedObjects.contains(objectName)) {
                      String fieldName = rels.getField().getDescribe().getName();
                      String fieldRelationshipName = rels.getRelationshipName();
                      Map<String, String> fieldNameToRelationShipName = new Map<String, String>();
                      if (childSObjectsFields.get(objectName) == null || childSObjectsFields.get(objectName).size() <= 0) {
                        childSObjectsFields.put(objectName, new List<String>());
                        fieldNameToRelationShipName = new Map<String, String>();
                      } else {
                        fieldNameToRelationShipName = childSObjectsFieldsRelationShipName.get(objectName);
                      }
                      fieldNameToRelationShipName.put(fieldName, fieldRelationshipName);
                      childSObjectsFields.get(objectName).add(fieldName);
                      childSObjectsFieldsRelationShipName.put(objectName, fieldNameToRelationShipName);
                  }
                }
              }

              List<SFA_WrapperDef.SFA_ItemListInformation> lstSfaItemListInfo = new List<SFA_WrapperDef.SFA_ItemListInformation>();
              Schema.DescribeSobjectResult[] childSObjectsDescribeResults = Schema.describeSObjects(new List<String>(childSObjectsFields.keyset()));
              for(Schema.DescribeSobjectResult csdr: childSObjectsDescribeResults) {
                SFA_WrapperDef.SFA_ItemListInformation sfmItemListInfo = new SFA_WrapperDef.SFA_ItemListInformation();
                List<String> relatedFields = childSObjectsFields.get(csdr.getName());
                Map<String, String> fieldNameToRelationShipName = childSObjectsFieldsRelationShipName.get(csdr.getName());
                if (relatedFields != null && relatedFields.size() > 0) {
                  sfmItemListInfo.strObjectLabel = csdr.getLabel();
                  sfmItemListInfo.strObjectValue = csdr.getName();
                  List<SFA_WrapperDef.SFA_ItemList> lstFieldList = new List<SFA_WrapperDef.SFA_ItemList>();
                  Map<String, Schema.SObjectField> mapFields = csdr.fields.getMap();
                  for (String fld: mapFields.keyset()) {
                    Schema.DescribeFieldResult dfr = mapFields.get(fld).getDescribe();
                    if (relatedFields.contains(dfr.getName())) {
                      SFA_WrapperDef.SFA_ItemList sfaItelList = new SFA_WrapperDef.SFA_ItemList();
                      sfaItelList.strLabel = dfr.getLabel();
                      sfaItelList.strValue = dfr.getName();
                      sfaItelList.strRelatedRefFieldName = fieldNameToRelationShipName.get(dfr.getName());
                      lstFieldList.add(sfaItelList);
                    }
                  }
                  sfmItemListInfo.lstFieldList = lstFieldList;
                }
                lstSfaItemListInfo.add(sfmItemListInfo);
              }

              objResponse.lstItemListInformation = lstSfaItemListInfo;
            }
            else{
                objResponse.success = false;
                objResponse.message = 'Invalid Request';
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception in SFA_GetRelatedListToObject method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in SFA_GetRelatedListToObject method: ' + ex.getStackTraceString());
        }

        System.debug(LoggingLevel.WARN, 'Response of SFA_GetRelatedListToObject method: ' + objResponse);
        return objResponse;
    }
}