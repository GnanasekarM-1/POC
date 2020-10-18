/*****************************************************************************
*                       Copyright (C) 2019 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* This class implements all the methods related to Service Flow Automation
* UT -: SFA_PlatformEventPublish_UT
* @author Soumyaranjan Pati
* @version V.04
* @since 2019
*/
/*****************************************************************************************************
*    ID        Name                    Date            Comment
*****************************************************************************************************
*              Soumyaranjan Pati    25th March 2019  Created.
*   BAC-5312   Soumyaranjan Pati    9th Oct 2019      Defect fixed
*****************************************************************************************************/
public class SFA_PlatformTriggerHandler{
    Boolean isJWTTokenEnabled = false;
    String issDetails = '';
    String tokenEndpoint = '';
    String certificateName = '';
    String sobjectOwnerDetail = '';
    String syncGateWayEndPoint = '';
    String smsEndPoint = '';
    String smsClientToken = '';
    String sRelatedobjectRecordId = '';
    String sRelatedobjectRecordName = '';
    String sobjectRecordId = '';
    String sobjectRecordName = '';
    Map<String, String> mapTriggerType = new Map<String, String>();
    Map<String,Map<String, String>> mapEventTriggerFieldMap = new Map<String,Map<String, String>>();
    Map<String, String> mapSFAIProIdSFMProId = new Map<String, String>();
    Map<String,String> objectResultSet = new Map<String,String>(); //BAC-5040
    //Map<String,Schema.SObjectType> globalDescribeVar = Schema.getGlobalDescribe();

    private static String FIELD_TEXT_TO_VALUE = 'FIELD-TEXT-TO-VALUE';
    private static String FIELD_TEXT_TO_TYPE = 'FIELD-TEXT-TO-TYPE';

    private String getSMSClientToken() {
        List<SVMXC__ServiceMax_Properties__c> smsProperty = [Select SVMXC__Value__c from SVMXC__ServiceMax_Properties__c WHERE Name = 'SMS_CLIENT_TOKEN' OR SVMXC__Key__c = 'SMS_CLIENT_TOKEN'];
        if (smsProperty != null && smsProperty.size() > 0) {
            system.debug('SMS Client Token found!!');
            return smsProperty[0].SVMXC__Value__c;
        }
        system.debug('SMS Client Token not found!!');
        return null;
    }

    public void afterInsertPlatformEvent(List<SVMXC__SFA_Platform_Event__e> listPlatformEvents){
        try{
        objectResultSet.put('CASE','CaseNumber');
        objectResultSet.put('SOLUTION','SolutionName');
        objectResultSet.put('TASK','Subject');
        objectResultSet.put('EVENT','Subject');
        objectResultSet.put('CONTRACT','ContractNumber');
        objectResultSet.put('ORDERITEM','OrderItemNumber');
        objectResultSet.put('ORDER','OrderNumber');

        System.debug('listPlatformEvents '+listPlatformEvents);
        // Get all the SVMX setting value
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        List<String> lstSettingIds = new List<String>();
        lstSettingIds.add('SFA001_SET001'); //Enable JWT Token for SFA
        lstSettingIds.add('SFA001_SET002'); //JWT Token End Point for SFA
        lstSettingIds.add('SFA001_SET003'); //JWT Token Certificate Name for SFA
        lstSettingIds.add('SFA001_SET004'); //Issuer Details for SFA
        lstSettingIds.add('SFA001_SET005'); //Sync Gateway URL for SFA
        lstSettingIds.add('SFA001_SET006'); //Sync Gateway URL for SFA - SMS

        Map<String,String> mapAllSettings =  new Map<String,String>();
        String lunDesignerURI;
        //Get all the setting values
        mapAllSettings = commManageSetting.SVMX_getGlobalSettingList(lstSettingIds);
        if(mapAllSettings.size() > 0){
            if(mapAllSettings.containskey('SFA001_SET001'))
                isJWTTokenEnabled = Boolean.valueOf(mapAllSettings.get('SFA001_SET001'));
            if(mapAllSettings.containskey('SFA001_SET002'))
                tokenEndpoint = mapAllSettings.get('SFA001_SET002');
            if(mapAllSettings.containskey('SFA001_SET003'))
                certificateName = mapAllSettings.get('SFA001_SET003');
            if(mapAllSettings.containskey('SFA001_SET004'))
                issDetails = mapAllSettings.get('SFA001_SET004');
            if(mapAllSettings.containskey('SFA001_SET005'))
                syncGateWayEndPoint = mapAllSettings.get('SFA001_SET005');
            if(mapAllSettings.containskey('SFA001_SET006'))
                smsEndPoint = mapAllSettings.get('SFA001_SET006');
        }
        smsClientToken = getSMSClientToken();
        //
        Map<String, SFA_WrapperDef.SFA_SFDCActionJsonWrapper> mapSFAProcessActions = new Map<String, SFA_WrapperDef.SFA_SFDCActionJsonWrapper>();
        Map<String, SFA_WrapperDef.SFA_SMSActionJsonWrapper> mapSFASMSProcessActions = new Map<String, SFA_WrapperDef.SFA_SMSActionJsonWrapper>();

        Map<String,Map<String, String>> mapSFAIdWithPreview = new Map<String,Map<String, String>>();
        Map<Id,String> mapSFAExpressionIds = new Map<Id,String>();
        Map<Id, Boolean> parseResultMap = new Map<Id, Boolean>();
        //Added for BAC-5312
        if(!isJWTTokenEnabled && !Test.isRunningTest()){
            System.debug('JWT token is disabled! Please enable this');
            return;
        }
        Map<String, List<Sobject>> mapSFAProcessWithSobjects = new Map<String, List<Sobject>>();
        List<String> listObjectNames = new List<String>();
        for(SVMXC__SFA_Platform_Event__e platformEventVar: listPlatformEvents){
            listObjectNames.add(platformEventVar.SVMXC__Object_Name__c);
        }
        mapSFAProcessWithSobjects = getListOfConfigDetails(listObjectNames);
        //End for BAC-5312

        for(SVMXC__SFA_Platform_Event__e platformEventVar: listPlatformEvents){// Considering no bulk insert/update
          system.debug('platformEventVar.SVMXC__Object_Name__c: ' + platformEventVar.SVMXC__Object_Name__c);
            //Added for BAC-5312
            mapSFAExpressionIds.clear();
            mapSFAProcessActions.clear();
            mapSFASMSProcessActions.clear();
            mapSFAIdWithPreview.clear();
            parseResultMap.clear();
            if(!mapSFAProcessWithSobjects.containsKey(platformEventVar.SVMXC__Object_Name__c)){
                continue;
            }
            //End for BAC-5312
            List<Sobject> listOfConfigSFA = mapSFAProcessWithSobjects.get(platformEventVar.SVMXC__Object_Name__c); //TODO
            sobjectRecordId = platformEventVar.SVMXC__Record_Id__c;
            sobjectRecordName = platformEventVar.SVMXC__Object_Name__c;

            Boolean isConfigRecordFieldUpdated = false;
            if(listOfConfigSFA.size() > 0){
                //TODO
                for(Sobject sobjConfigRec: listOfConfigSFA){
                    SVMXC__SM_SFA_Process__c sfaConfigvar = (SVMXC__SM_SFA_Process__c)sobjConfigRec;
                    if(sfaConfigvar.SVMXC__SM_Object_API_Name__c.equalsIgnoreCase(platformEventVar.SVMXC__Object_Name__c)){

                        //Get Advance expression details
                        if(sfaConfigvar.SVMXC__SM_Expression__c != null)
                            mapSFAExpressionIds.put(sfaConfigvar.SVMXC__SM_Expression__c, sfaConfigvar.SVMXC__SM_Expression__r.SVMXC__Advance_Expression__c);
                        //
                    }

                    mapSFAIProIdSFMProId.put(sfaConfigvar.SVMXC__SM_SFA_Process_Id__c, sfaConfigvar.SVMXC__SM_SFM_Process_Name__r.SVMXC__ProcessID__c);
                }

                if(mapSFAExpressionIds.size() > 0){
                    Set<String> setWOFieldNames = new Set<String>();
                    List<Id> lstProcessIds = new List<Id>();
                    List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRows = new list<SVMXC__ServiceMax_Config_Data__c>();
                    lstProcessIds.addAll(mapSFAExpressionIds.keySet());
                    Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEntRuleExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
                    // Get the expression rows for all the above named expressions
                    String strExpRowQuery ='Select SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__RecordType_Name__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Inventory_Process__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, Name, Id, SVMXC__Field_Relationship_Name__c, SVMXC__FKey_Name_Field__c ';
                    strExpRowQuery += ' from SVMXC__ServiceMax_Config_Data__c ';
                    strExpRowQuery += ' where Recordtype.Name = \'Expressions\' and SVMXC__Expression_Type__c = \'EXP_Named\' and SVMXC__Expression_Rule__c IN : lstProcessIds';
                    System.debug('strExpRowQuery '+strExpRowQuery);
                    lstExpressionRows = database.query(strExpRowQuery);
                    for(SVMXC__ServiceMax_Config_Data__c svmxConfigData: lstExpressionRows){
                        if(svmxConfigData.SVMXC__Display_Type__c.equalsIgnoreCase('REFERENCE')){
                            setWOFieldNames.add(svmxConfigData.SVMXC__Field_Relationship_Name__c+'.'+svmxConfigData.SVMXC__FKey_Name_Field__c);
                        }else{
                            setWOFieldNames.add(svmxConfigData.SVMXC__Field_Name__c);
                        }
                        if(!mapEntRuleExpression.containsKey(svmxConfigData.SVMXC__Expression_Rule__c))
                            mapEntRuleExpression.put(svmxConfigData.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapEntRuleExpression.get(svmxConfigData.SVMXC__Expression_Rule__c).add(svmxConfigData);
                    }

                    String fieldString = ' ';
                    List<String> queryFieldsDT = new List<String>();
                    for (String field : setWOFieldNames)
                    {
                        if(!String.isBlank(fieldString))
                            fieldString += ', ' + field;
                        else
                            fieldString += field;
                        if (!field.startsWith('(')) {
                            queryFieldsDT.add(field);
                        }
                    }

                    System.debug( LoggingLevel.DEBUG, 'Field List String - ' + fieldString );
                    SObject sRecord;
                     //Check Field Security Check
                    System.debug('checking access for object: '+platformEventVar.SVMXC__Object_Name__c);
                    System.debug('checking access for fields: '+JSON.serialize(queryFieldsDT));
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( platformEventVar.SVMXC__Object_Name__c, queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                        System.debug('Access not found either for object: '+ platformEventVar.SVMXC__Object_Name__c + ' :or for fields: ' + JSON.serialize(queryFieldsDT));
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    //End of Check Field Security Check
                    if(!String.isBlank(fieldString)){
                        Id recordId = platformEventVar.SVMXC__Record_Id__c;
                        sRecord = database.query('Select ' + fieldString + ' from ' + platformEventVar.SVMXC__Object_Name__c + ' Where Id =: recordId');
                    }
                    System.debug('sRecord '+sRecord);

                    //System.debug('sRecord name '+sRecord.get('OwnerId').Name);
                    if(sRecord != null){

                        for(Id namedExprRec: mapSFAExpressionIds.keySet()){
                            boolean namedExpressionQualified = false;
                            //system.debug(namedExprRec);
                            namedExpressionQualified = new COMM_Utils_V2.COMM_ExpressionParsing().SVMX_ExpressionParsing(sRecord, mapEntRuleExpression.get(namedExprRec), mapSFAExpressionIds.get(namedExprRec));
                            parseResultMap.put(namedExprRec, namedExpressionQualified);
                        }
                    }
                }

                for(Sobject sobjConfigRec: listOfConfigSFA){

                    SVMXC__SM_SFA_Process__c sfaConfigvar = (SVMXC__SM_SFA_Process__c)sobjConfigRec;
                    System.debug('sfaConfigvar '+sfaConfigvar);
                    if(sfaConfigvar.SVMXC__SM_Object_API_Name__c.equalsIgnoreCase(platformEventVar.SVMXC__Object_Name__c) && sfaConfigvar.SVMXC__SM_SFA_Event_JSON__c != null && sfaConfigvar.SVMXC__SM_SFA_Action_JSON__c != null){
                        Map<String, String>  fieldValueMap = new Map<String, String>();
                        //Get wrapper Event details
                        SFA_WrapperDef.SFA_SFDCEventJsonWrapper sfaEventWrapperVar = (SFA_WrapperDef.SFA_SFDCEventJsonWrapper) JSON.deserialize(sfaConfigvar.SVMXC__SM_SFA_Event_JSON__c, SFA_WrapperDef.SFA_SFDCEventJsonWrapper.class);
                        System.debug('sfaEventWrapperVar '+sfaEventWrapperVar);
                        if(sfaEventWrapperVar.SFDC_Data_Event_Type == null)
                            continue;
                        if(sfaEventWrapperVar.Preview_Field_List != null){
                            for(String key: sfaEventWrapperVar.Preview_Field_List){
                                fieldValueMap.put(key.trim(),key.trim().toLowerCase());
                            }
                        }
                        if(platformEventVar.SVMXC__Event_Type__c.equalsIgnoreCase('Inserted')){
                            if(sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Updated') || sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Field_Updated'))
                            continue;
                        }
                        if(platformEventVar.SVMXC__Event_Type__c.equalsIgnoreCase('Updated')){
                            if(sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Created'))
                            continue;
                        }
                        mapTriggerType.put(sfaConfigvar.SVMXC__SM_SFA_Process_Id__c, sfaEventWrapperVar.SFDC_Data_Event_Type);
                        if(sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Field_Updated') && platformEventVar.SVMXC__Old_Record_JSON__c != null){
                            //TODO

                            Set<String> eventConfigFields = sfaEventWrapperVar.Event_Trigger_Fields;
                            //System.debug('eventConfigFields '+eventConfigFields);

                            SFA_WrapperDef.SFA_RecordWrapper oldSobjectFieldSetVal = (SFA_WrapperDef.SFA_RecordWrapper) JSON.deserialize(platformEventVar.SVMXC__Old_Record_JSON__c, SFA_WrapperDef.SFA_RecordWrapper.class);
                            //System.debug('oldSobjectFieldSetVal '+oldSobjectFieldSetVal);

                            SFA_WrapperDef.SFA_RecordWrapper newSobjectFieldSetVal = (SFA_WrapperDef.SFA_RecordWrapper) JSON.deserialize(platformEventVar.SVMXC__New_Record_JSON__c, SFA_WrapperDef.SFA_RecordWrapper.class);
                            //System.debug('newSobjectFieldSetVal '+newSobjectFieldSetVal);
                            Map<String,String> mapEventTriggerField = new Map<String,String>();
                            for(String fieldVal: eventConfigFields){
                                if(newSobjectFieldSetVal.mapfieldNameValues.get(fieldVal) != null)
                                    mapEventTriggerField.put(fieldVal, newSobjectFieldSetVal.mapfieldNameValues.get(fieldVal));

                            }
                            if(mapEventTriggerField.size() > 0)
                                mapEventTriggerFieldMap.put(sfaConfigvar.SVMXC__SM_SFA_Process_Id__c, mapEventTriggerField);
                            isConfigRecordFieldUpdated = isFieldValueUpdated(eventConfigFields, oldSobjectFieldSetVal, newSobjectFieldSetVal);
                        }
                        Boolean isExpressionQualified = false;
                        if(parseResultMap.size()> 0 && sobjConfigRec.get('SVMXC__SM_Expression__c')!=null){
                            isExpressionQualified = parseResultMap.get(sfaConfigvar.SVMXC__SM_Expression__c); //For process qualification
                        }else{
                            isExpressionQualified = true;
                        }

                        if((sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Field_Updated') && isConfigRecordFieldUpdated && isExpressionQualified) || (sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Updated') && isExpressionQualified) || (sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Created') && isExpressionQualified) || (sfaEventWrapperVar.SFDC_Data_Event_Type.equalsIgnoreCase('Record_Created_Or_Updated') && isExpressionQualified)){
                            mapSFAIdWithPreview.put(sfaConfigvar.SVMXC__SM_SFA_Process_Id__c, fieldValueMap);
                            if (sfaConfigvar.SVMXC__SM_Action_Type__c.equalsIgnoreCase('Push Notification')) {
                                //Get Advance expression details
                                //
                                SFA_WrapperDef.SFA_SFDCActionJsonWrapper sfaActionWrapperVar = (SFA_WrapperDef.SFA_SFDCActionJsonWrapper) JSON.deserialize(sfaConfigvar.SVMXC__SM_SFA_Action_JSON__c, SFA_WrapperDef.SFA_SFDCActionJsonWrapper.class);
                                System.debug('sfaActionWrapperVar '+sfaActionWrapperVar);
                                //System.debug('sfaEventWrapperVar '+sfaEventWrapperVar);
                                if(sfaActionWrapperVar.Recipient_Field_API_Names == null)
                                    continue;

                                mapSFAProcessActions.put(sfaConfigvar.SVMXC__SM_SFA_Process_Id__c, sfaActionWrapperVar);
                            } else if (sfaConfigvar.SVMXC__SM_Action_Type__c.equalsIgnoreCase('SMS')) {
                                SFA_WrapperDef.SFA_SMSActionJsonWrapper sfaSMSActionWrapperVar = (SFA_WrapperDef.SFA_SMSActionJsonWrapper) JSON.deserialize(sfaConfigvar.SVMXC__SM_SFA_Action_JSON__c, SFA_WrapperDef.SFA_SMSActionJsonWrapper.class);
                                if (sfaSMSActionWrapperVar.Recipients == null || sfaSMSActionWrapperVar.Recipients.size() == 0)
                                    continue;
                                mapSFASMSProcessActions.put(sfaConfigvar.SVMXC__SM_SFA_Process_Id__c, sfaSMSActionWrapperVar);
                            }
                        }
                    }
                }

                if(mapSFAProcessActions.size()> 0)
                    sendDataToSyncGatway(mapSFAProcessActions, platformEventVar.SVMXC__Record_Id__c, platformEventVar.SVMXC__Object_Name__c, mapSFAIdWithPreview);
                if (mapSFASMSProcessActions.size()> 0) {
                    sendSMS(mapSFASMSProcessActions, platformEventVar.SVMXC__Record_Id__c, platformEventVar.SVMXC__Object_Name__c, mapSFAIdWithPreview);
                } else {
                    system.debug('No SFA Process qualified to send the SMS!!');
                }

            }
        }
        }catch(Exception e){
            System.debug('Exception '+e);
        }
    }

    /** Name - getListOfConfigDetails
    * This method is used to get all the records for a given object name from SFA Process object.
    *
    * @param objectApiName - Object API names.
    * @return map of records.
    *
    * @exception no.
    */
    private Map<String,List<Sobject>> getListOfConfigDetails(List<String> objectApiName){ //Added for BAC-5312
        Map<String,List<Sobject>> mapOfRecords = new Map<String,List<Sobject>>();
        String queryString = '';
        queryString = 'Select id, SVMXC__SM_Expression__c, SVMXC__SM_Action_Type__c, SVMXC__SM_Object_API_Name__c, SVMXC__SM_Expression__r.SVMXC__Advance_Expression__c, SVMXC__SM_SFA_Action_JSON__c, SVMXC__SM_SFA_Event_JSON__c, SVMXC__SM_SFA_Process_Id__c, SVMXC__SM_SFM_Process_Name__c, SVMXC__SM_SVMX_Group_Profile__c, SVMXC__SM_SFM_Process_Name__r.SVMXC__ProcessID__c from SVMXC__SM_SFA_Process__c where SVMXC__SM_Object_API_Name__c IN :objectApiName and (SVMXC__SM_Action_Type__c = \'Push Notification\' OR SVMXC__SM_Action_Type__c =\'SMS\') and SVMXC__SM_Enabled__c =true and SVMXC__SM_SFA_Process_Id__c != null'; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        for(Sobject sobjVar:Database.query(queryString)){
            SVMXC__SM_SFA_Process__c sfaConfigvar = (SVMXC__SM_SFA_Process__c)sobjVar;
            if(!mapOfRecords.containsKey(sfaConfigvar.SVMXC__SM_Object_API_Name__c)){
                mapOfRecords.put(sfaConfigvar.SVMXC__SM_Object_API_Name__c, new List<Sobject>());
            }
            mapOfRecords.get(sfaConfigvar.SVMXC__SM_Object_API_Name__c).add(sobjVar);
        }
        System.debug('mapOfRecords '+mapOfRecords);
        return mapOfRecords;
    }

    /** Name - sendSMS
    * This method is used to send SMS for Push Notification using the Notification Service.
    *
    * @param
    *   mapSFASMSProcessActions - Map SFA SMS Action details
    *   recordId - Record Id
    *   sobjectName - Object Name
    *   mapSFAIdWithPreview - Map SFA Id with SFA
    * @return Void
    *
    * @exception no.
    */
    private void sendSMS(Map<String, SFA_WrapperDef.SFA_SMSActionJsonWrapper> mapSFASMSProcessActions, Id recordId, String sobjectName, Map<String,Map<String, String>> mapSFAIdWithPreview) {
        system.debug('Sending SMS for record Id: ' + recordId + ' :of Object: ' + sobjectName);
        if (smsClientToken == null || smsClientToken.length() == 0) {
            system.debug('SMS Client Token is not available hence SMS will not be sent.');
            return;
        }
        List<String> lstMessageBodyDetails = new List<String>();
        Set<String> fields = new Set<String>();
        for(String keyVal: mapSFASMSProcessActions.keySet()){
            SFA_WrapperDef.SFA_SMSActionJsonWrapper sfaSMSActionVar = mapSFASMSProcessActions.get(keyVal);
            lstMessageBodyDetails.add(sfaSMSActionVar.Message_Body);
            for (SFA_WrapperDef.Recipients recipient: sfaSMSActionVar.Recipients) {
                if (recipient.field.equalsIgnoreCase('addition_number')) {
                    continue;
                }
                fields.add(recipient.field);
                if (recipient.relatedRefNameField != null && recipient.relatedRefNameField.length() > 0) {
                    if (recipient.relatedCountryField != null && recipient.relatedCountryField.length() > 0) {
                        fields.add(recipient.relatedRefNameField + '.' + recipient.relatedCountryField);
                    }
                    if (recipient.relatedField != null && recipient.relatedField.size() > 0) {
                        for (String relatedField: recipient.relatedField) {
                            fields.add(recipient.relatedRefNameField + '.' + relatedField);
                        }
                    }
                }
            }
        }

        Map<String, Map<String, String>> mapFieldTextNameAndType = getTheConfigFieldNamefromMessage(sobjectName,lstMessageBodyDetails);
        Map<String,String> mapFieldAPIDetails = mapFieldTextNameAndType.get(FIELD_TEXT_TO_VALUE);
        fields.addAll(mapFieldAPIDetails.values());
        if (fields == null || fields.size() == 0) {
            fields = new Set<String>();
        }
        fields.add('LastModifiedBy.UserName');
        String query = 'Select ' + String.join(new List<String>(fields), ',') + ' from ' + sobjectName + ' Where Id =: recordId';
        Sobject sRecordDetails = database.query(query); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        if(sRecordDetails != null){
            sobjectOwnerDetail = getUserName(sRecordDetails);
        }

        List<SFA_WrapperDef.SMSMessageRequest> messages = new List<SFA_WrapperDef.SMSMessageRequest>();

        for(String keyVal: mapSFASMSProcessActions.keySet()){
            SFA_WrapperDef.SFA_SMSActionJsonWrapper sfaSMSActionVar = mapSFASMSProcessActions.get(keyVal);
            String message = sfaSMSActionVar.Message_Body;
            if (message == null || message.length() == 0) {
                continue;
            }
            if (mapFieldAPIDetails != null && mapFieldAPIDetails.size() > 0) {
                for (String fieldKey: mapFieldAPIDetails.keyset()) {
                    if (message.contains(fieldKey)) {
                        if (mapFieldAPIDetails.get(fieldKey).contains('.')) {
                            List<String> referenceFields = mapFieldAPIDetails.get(fieldKey).split('\\.');
                            if (sRecordDetails.getSobject(referenceFields[0]) != null && sRecordDetails.getSobject(referenceFields[0]).get(referenceFields[1]) != null) {
                              message = message.replace(fieldKey, String.valueOf(sRecordDetails.getSobject(referenceFields[0]).get(referenceFields[1])).replace(' 00:00:00', ''));
                            }
                        } else {
                            if (sRecordDetails.get(mapFieldAPIDetails.get(fieldKey)) != null) {
                                message = message.replace(fieldKey, String.valueOf(sRecordDetails.get(mapFieldAPIDetails.get(fieldKey))).replace(' 00:00:00', ''));
                            }
                        }
                        message = message.replace(fieldKey, '');
                    }
                }
            }

            SFA_WrapperDef.SMSMessageRequest smsMessageRequest = new SFA_WrapperDef.SMSMessageRequest();
            smsMessageRequest.message = message;
            smsMessageRequest.to = new List<SFA_WrapperDef.SMSRecipient>();
            Set<String> uniqueNumberSet = new Set<String>();

            for (SFA_WrapperDef.Recipients recipient: sfaSMSActionVar.Recipients) {
                if (recipient.field.equalsIgnoreCase('addition_number') && recipient.contactnumber != null && recipient.contactnumber.length() > 0) {
                    if(!uniqueNumberSet.contains(recipient.country+recipient.contactnumber)) {
                      SFA_WrapperDef.SMSRecipient smsrecipient = new SFA_WrapperDef.SMSRecipient();
                      smsrecipient.country = recipient.country;
                      smsrecipient.contactnumber = recipient.contactnumber;
                      smsMessageRequest.to.add(smsrecipient);
                      uniqueNumberSet.add(recipient.country+recipient.contactnumber);
                    }
                } else if (recipient.relatedField != null && recipient.relatedField.size() > 0) {
                    for (String relatedField: recipient.relatedField) {
                        Sobject relatedObjectRecord = sRecordDetails.getsobject(recipient.relatedRefNameField);
                        if (relatedObjectRecord != null && relatedObjectRecord.get(relatedField) != null) {
                            String country = '';
                            String contactnumber = '';
                            if (recipient.relatedCountryField != null && recipient.relatedCountryField.length() > 0) {
                                country = String.valueOf(relatedObjectRecord.get(recipient.relatedCountryField));
                            }
                            contactnumber = String.valueOf(relatedObjectRecord.get(relatedField));
                            if (contactnumber != null && contactnumber.length() > 0 && !uniqueNumberSet.contains(country+contactnumber)) {
                                SFA_WrapperDef.SMSRecipient smsrecipient = new SFA_WrapperDef.SMSRecipient();
                                smsrecipient.country = country;
                                smsrecipient.contactnumber = contactnumber;
                                smsMessageRequest.to.add(smsrecipient);
                                uniqueNumberSet.add(country+contactnumber);
                            }
                        }
                    }
                }
            }
            messages.add(smsMessageRequest);
        }

        if(messages == null || messages.size() == 0) {
            system.debug('No Messages to send the SMS!!');
            return;
        }

        SFA_WrapperDef.SMSRequest smsrequest = new SFA_WrapperDef.SMSRequest();
        smsrequest.messages = messages;
        String body = JSON.serialize(smsrequest);
        body = body.replaceAll('contactnumber', 'number');
        if(isJWTTokenEnabled || Test.isRunningTest()){
            callSyncGateWay(smsEndPoint, body, recordId, sobjectOwnerDetail, tokenEndpoint, issDetails, certificateName, smsClientToken);
        }else{
            System.debug('Access token in SVMX setting is not enabled.');
        }
    }

    /** Name - sendDataToSyncGatway
    * This method is used to send data to Sync Gatway for Push Notification.
    *
    * @param
    * @return
    *
    * @exception no.
    */
    private void sendDataToSyncGatway(Map<String, SFA_WrapperDef.SFA_SFDCActionJsonWrapper> tempMapSFAProcessActions, Id recordId, String sobjectName, Map<String,Map<String, String>> mapSFAIdWithPreview){
        System.debug('tempMapSFAProcessActions '+tempMapSFAProcessActions);
        System.debug('mapSFAIdWithPreview '+mapSFAIdWithPreview);
        List<String> lstMessageBodyDetails = new List<String>();
        Map<String,Map<String, String>>  mapRecipientIds = new Map<String, Map<String, String>>();
        Map<String, String> mapDifferentUserDetails = new Map<String, String>();
        Map<String, List<String>> mapGroupUser = new Map<String, List<String>>();
        Map<String, String> mapActualSFAIdWithPreview = new Map<String, String>();
        Map<String, Set<String>> relatedListMapForSecurityCheck = new Map<String, Set<String>>();

        for(String keyVal: tempMapSFAProcessActions.keySet()){
            SFA_WrapperDef.SFA_SFDCActionJsonWrapper sfaActionVar = tempMapSFAProcessActions.get(keyVal);
            lstMessageBodyDetails.add(sfaActionVar.Message_Body);
            Map<String, String> tempFieldMaps = new Map<String, String>();
            for(String recipientId: sfaActionVar.Recipient_Field_API_Names){
                if(recipientId.equalsIgnoreCase('Owner'))
                    recipientId = 'OwnerId';
                if(recipientId.equalsIgnoreCase('CreatedBy'))
                    recipientId = 'CreatedById';
                if(recipientId.equalsIgnoreCase('LastModifiedBy'))
                    recipientId = 'LastModifiedById';
                tempFieldMaps.put(recipientId.trim().toLowerCase(), recipientId.trim().toLowerCase());
            }
            if (sfaActionVar.RelatedList_Recipients != null && sfaActionVar.RelatedList_Recipients.size() > 0) {
              for(SFA_WrapperDef.RelatedListRecipient relatedListRecipient: sfaActionVar.RelatedList_Recipients){
                  String relationshipName = relatedListRecipient.Relationship_Name.trim().toLowerCase();
                  String fieldValue = '(Select ' + relatedListRecipient.RelatedList_Recipient_Field[0].trim().toLowerCase();
                  if (relatedListRecipient.RelatedList_Recipient_Field.size() > 1) {
                    for (integer i=1; i<relatedListRecipient.RelatedList_Recipient_Field.size(); i++) {
                      fieldValue = fieldValue + ',' + relatedListRecipient.RelatedList_Recipient_Field[i].trim().toLowerCase();
                    }
                  }
                  fieldValue = fieldValue + ' FROM ' + relatedListRecipient.Relationship_Name.trim().toLowerCase() + ')';
                  system.debug('Related List Field Added: ' + fieldValue);
                  tempFieldMaps.put(fieldValue, fieldValue);
                  if(!relatedListMapForSecurityCheck.containsKey(relatedListRecipient.RelatedList_Object_API_Name)) {
                    relatedListMapForSecurityCheck.put(relatedListRecipient.RelatedList_Object_API_Name, new Set<String>());
                  }
                  relatedListMapForSecurityCheck.get(relatedListRecipient.RelatedList_Object_API_Name).addAll(relatedListRecipient.RelatedList_Recipient_Field);
              }
            }

            mapRecipientIds.put(keyVal, tempFieldMaps);
        }

        if (relatedListMapForSecurityCheck != null && relatedListMapForSecurityCheck.size() > 0) {
          for(String relatedObject : relatedListMapForSecurityCheck.keyset()) {
            List<String> flds = new List<String>();
            flds.addAll(relatedListMapForSecurityCheck.get(relatedObject));
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( relatedObject, flds, COMM_SecurityUtils.Access.Accessible ) ) {
                System.debug('Access not found either for object: '+ relatedObject + ' :or for fields: ' + JSON.serialize(flds));
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
          }
        }

        Map<String, Map<String, String>> mapFieldTextNameAndType = getTheConfigFieldNamefromMessage(sobjectName,lstMessageBodyDetails);
        Map<String,String> mapFieldAPIDetails = mapFieldTextNameAndType.get(FIELD_TEXT_TO_VALUE);
        Map<String,String> mapFieldToType = mapFieldTextNameAndType.get(FIELD_TEXT_TO_TYPE);
        system.debug('Map field to type: ' + JSON.serialize(mapFieldToType));
        System.debug('mapFieldAPIDetails '+mapFieldAPIDetails);
        //

        String fieldString = '';

        Map<String, String> mapConsolidatedFields = new Map<String,String>();
        Set<String> setAllFieldValues = new Set<String>();
        mapConsolidatedFields.putAll(mapFieldAPIDetails);
        for(String mapTempVal: mapRecipientIds.keySet()){
            mapConsolidatedFields.putAll(mapRecipientIds.get(mapTempVal));
        }
        Map<String, Set<String>> mapSFAProcessToRecipientIds = new Map<String, Set<String>>();
        //Special handlling for Salesforce events
        if(sobjectName.equalsIgnoreCase('Event')){
            Map<String, String> mapActualSFAIdWithPreviewforWO = new Map<String, String>();
            mapActualSFAIdWithPreviewforWO.put('Name','Name');
            mapActualSFAIdWithPreviewforWO.put('Id','Id');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Order_Status__c','SVMXC__Order_Status__c');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Company__r.Name','SVMXC__Company__r.Name');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Contact__r.Name','SVMXC__Contact__r.Name');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Street__c','SVMXC__Street__c');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__City__c','SVMXC__City__c');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__State__c','SVMXC__State__c');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Zip__c','SVMXC__Zip__c');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Country__c','SVMXC__Country__c');
            mapActualSFAIdWithPreviewforWO.put('SVMXC__Priority__c','SVMXC__Priority__c');
            mapActualSFAIdWithPreview.put('StartDateTime','StartDateTime');
            mapActualSFAIdWithPreview.put('EndDateTime','EndDateTime');
            mapActualSFAIdWithPreview.put('WhatId','WhatId');
            mapConsolidatedFields.putAll(mapActualSFAIdWithPreview);
            for(String val: mapConsolidatedFields.values()){ //BAC-4972
                setAllFieldValues.add(val.toLowerCase());
            }
            //setAllFieldValues.addAll(mapConsolidatedFields.values());//Get the unique values
            List<String> queryFieldsDT = new List<String>();
            system.debug('Map field to type: ' + JSON.serialize(mapFieldToType));
            for (String field : setAllFieldValues)
            {
                String fieldForQuery = field;
                for (String mapkey: mapFieldToType.keyset()) {
                  if(mapkey == '[$' + field + ']' && mapFieldToType.get(mapkey)  == 'picklist') {
                    system.debug('Field for Query: ' + '[$' + field + ']' + ' :and type is: ' + mapFieldToType.get(mapkey));
                    fieldForQuery = 'toLabel(' + field + ')';
                  }
                }
                if(!String.isBlank(fieldString))
                    fieldString += ', ' + fieldForQuery;
                else
                    fieldString += fieldForQuery;

                if (!field.startsWith('(')) {
                  queryFieldsDT.add(field);
                }
                system.debug( 'Field from setAllFieldValues: ' + field);
            }

            if(!fieldString.containsIgnoreCase('LastModifiedBy.UserName'))//Added for JWT token
                fieldString += ', ' + 'LastModifiedBy.UserName';
            //Check Field Security Check
            System.debug('checking access for object: '+sobjectName);
            System.debug('checking access for fields: '+JSON.serialize(queryFieldsDT));
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectName, queryFieldsDT, COMM_SecurityUtils.Access.Accessible ) ) {
                System.debug('Access not found either for object: '+ sobjectName + ' :or for fields: ' + JSON.serialize(queryFieldsDT));
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            system.debug('Fields to be queried: ' + fieldString + ' :for object name: ' + sobjectName + ' :with record id: ' + recordId);
            //End of Check Field Security Check
            Sobject sRecordDetails = database.query('Select ' + fieldString + ' from ' + sobjectName + ' Where Id =: recordId'); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            system.debug('Record queried: ' + sRecordDetails);
            if(sRecordDetails != null){
                sobjectOwnerDetail = getUserName(sRecordDetails);
                Id woWhatId;
                String sObjName;
                if(sRecordDetails.get('WhatId') != null){
                    woWhatId = Id.valueOf(String.valueOf(sRecordDetails.get('WhatId')));
                    sObjName = getTheObjectNameFromId(woWhatId);
                    sRelatedobjectRecordName = sObjName;
                    sRelatedobjectRecordId = String.valueOf(sRecordDetails.get('WhatId'));
                }
                Map<String,Object> mapFieldAndValueOfRecord1 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sRecordDetails));
                for(String s:mapFieldAndValueOfRecord1.keySet()){
                    System.debug('s '+s+' value '+mapFieldAndValueOfRecord1.get(s));
                    if(mapConsolidatedFields.containsKey(s)){
                        mapConsolidatedFields.put(s,String.valueOf(mapFieldAndValueOfRecord1.get(s)));
                    }else if(mapConsolidatedFields.containsKey(s.trim().toLowerCase())){
                        mapConsolidatedFields.put(s.trim().toLowerCase(),String.valueOf(mapFieldAndValueOfRecord1.get(s)));
                    }
                    String keyMainVal ='[$' + s + ']';
                    if(s.equalsIgnoreCase('Owner') || s.equalsIgnoreCase('CreatedBy') || s.equalsIgnoreCase('LastModifiedBy')){
                        keyMainVal = '[$' + s + 'Id'+']';
                        type stype= type.forName('User');
                        Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1.get(s)), stype);
                        //System.debug('resultSobject '+resultSobject);
                        if(mapFieldAPIDetails.containsKey(keyMainVal)){
                            mapFieldAPIDetails.put(keyMainVal,String.valueOf(resultSobject.get('Name')));
                        }
                    }else if(s.endsWithIgnoreCase('__r')){ //BAC-5040
                        keyMainVal ='[$' + s.substringBeforeLast('__')+'__c' + ']';
                        System.debug('keyMainVal '+keyMainVal);
                        Object objDetails = mapFieldAndValueOfRecord1.get(s);
                        System.debug('objDetails '+objDetails);
                        Map<String, Object> str = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objDetails)); //BAC-5040
                        System.debug('keyMainVal str '+str);
                        if (!str.containsKey('attributes')) {
                          continue;
                        }
                        Map<String, Object> strAttribute = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(str.get('attributes'))); //BAC-5040
                        System.debug('objDetails str '+strAttribute);
                        String typeObjName = '';
                        for(String internalVar: strAttribute.keySet()){ //BAC-5040
                            System.debug('internalVar attributes '+internalVar);
                            typeObjName = String.valueOf(strAttribute.get('type'));
                        }

                        type stype= type.forName(typeObjName);
                        Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1.get(s)), stype);
                        System.debug('resultSobject '+resultSobject);
                        if(mapFieldAPIDetails.containsKey(keyMainVal)){
                            if(objectResultSet.containsKey(typeObjName.toUpperCase())){ //BAC-5040
                                mapFieldAPIDetails.put(keyMainVal,String.valueOf(resultSobject.get(objectResultSet.get(typeObjName.toUpperCase()))));
                            }else{
                                mapFieldAPIDetails.put(keyMainVal,String.valueOf(resultSobject.get('Name')));
                            }
                        }
                    }else if(mapFieldAPIDetails.containsKey(keyMainVal)){
                        mapFieldAPIDetails.put(keyMainVal,String.valueOf(mapFieldAndValueOfRecord1.get(s)));
                    }
                }
                for(String mapTempVal: mapRecipientIds.keySet()){
                    Set<String> recipientIds = new Set<String>();
                    SFA_WrapperDef.SFA_SFDCActionJsonWrapper sfaProcessAction = tempMapSFAProcessActions.get(mapTempVal);

                    for(String tempFieldsInternal : mapRecipientIds.get(mapTempVal).keySet()) {
                        if (tempFieldsInternal.startsWith('(')) {
                          String relatedListObjectRelationShipName = fetchRelatedListObject(tempFieldsInternal);
                          List<String> relatedListObjectFields = fetchRelatedListObjectFields(tempFieldsInternal);
                          SObject[] relatedListRecords = sRecordDetails.getsobjects(relatedListObjectRelationShipName);
                          if (relatedListRecords != null && relatedListRecords.size() > 0) {
                            for (sObject relatedListRecord: relatedListRecords) {
                              for (String relatedListRecordField: relatedListObjectFields) {
                                if (relatedListRecord.get(relatedListRecordField) != null) {
                                    String fieldValue = String.valueOf(relatedListRecord.get(relatedListRecordField));
                                    recipientIds.add(fieldValue);
                                    mapDifferentUserDetails.put(fieldValue, fieldValue);
                                }
                              }
                            }
                          }
                        } else {
                          if(mapConsolidatedFields.get(tempFieldsInternal) != null){
                              String fieldValue = String.valueOf(mapConsolidatedFields.get(tempFieldsInternal));//get the value of the perticular field
                              recipientIds.add(fieldValue);
                              mapDifferentUserDetails.put(fieldValue, fieldValue);
                          }
                        }
                    }
                    system.debug('For SFA: ' + mapTempVal + ' :Recipient Ids: ' + recipientIds);
                    mapSFAProcessToRecipientIds.put(mapTempVal, recipientIds);
                }
                if(sObjName != null && sObjName.equalsIgnoreCase('SVMXC__Service_Order__c')){
                    List<String> queryFieldsDT1 = new List<String>();
                    String fieldStringWO = '';
                    for (String field : mapActualSFAIdWithPreviewforWO.keySet())
                    {
                        if(!String.isBlank(fieldStringWO))
                            fieldStringWO += ', ' + field;
                        else
                            fieldStringWO += field;
                        if (!field.startsWith('(')) {
                            queryFieldsDT1.add(field);
                        }
                        system.debug( 'Field from setAllFieldValues for WO: ' + field);
                    }

                    //Check Field Security Check
                    System.debug('checking access for object: '+'SVMXC__Service_Order__c');
                    System.debug('checking access for fields: '+JSON.serialize(queryFieldsDT1));
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order__c', queryFieldsDT1, COMM_SecurityUtils.Access.Accessible ) ) {
                        System.debug('Access not found either for object: '+ 'SVMXC__Service_Order__c' + ' :or for fields: ' + JSON.serialize(queryFieldsDT1));
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    //End of Check Field Security Check
                    Sobject sWORecordDetails = database.query('Select ' + fieldStringWO + ' from SVMXC__Service_Order__c Where Id =: woWhatId'); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    Map<String,Object> mapFieldAndValueOfRecordforWO = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sWORecordDetails));
                    for(String s:mapFieldAndValueOfRecordforWO.keySet()){
                        System.debug('s '+s+' value '+mapFieldAndValueOfRecordforWO.get(s));
                        if(mapActualSFAIdWithPreviewforWO.containsKey(s)){
                            mapActualSFAIdWithPreviewforWO.put(s,String.valueOf(mapFieldAndValueOfRecordforWO.get(s)));
                        }else if(s.endsWithIgnoreCase('__r')){
                            type stype= type.forName('SVMXC__Service_Order__c');
                            Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecordforWO.get(s)), stype);
                            //System.debug('resultSobject '+resultSobject);
                            Map<String, Object> fieldsToValue = resultSobject.getPopulatedFieldsAsMap();
                            //System.debug('resultSobject getPopulatedFieldsAsMap '+resultSobject.getPopulatedFieldsAsMap());
                            for(String internalVar:fieldsToValue.keySet()){
                                //System.debug('sssssss '+s+'.'+internalVar);
                                if(mapActualSFAIdWithPreviewforWO.containsKey(s+'.'+internalVar))
                                    mapActualSFAIdWithPreviewforWO.put(s+'.'+internalVar,String.valueOf(fieldsToValue.get(internalVar)));
                            }
                        }
                    }
                    String woAddress = 'SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c';
                    for(String tempFieldsInternal: mapActualSFAIdWithPreviewforWO.keySet()){
                        if(tempFieldsInternal.equalsIgnoreCase('SVMXC__Street__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__City__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__State__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Zip__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Country__c')){
                            if(mapActualSFAIdWithPreviewforWO.get(tempFieldsInternal) !=null)
                                woAddress = woAddress.replace(tempFieldsInternal, mapActualSFAIdWithPreviewforWO.get(tempFieldsInternal));
                            mapActualSFAIdWithPreviewforWO.remove(tempFieldsInternal);
                            mapActualSFAIdWithPreviewforWO.put('wo_address', woAddress);
                        }
                    }
                    if(mapActualSFAIdWithPreviewforWO.containsKey('wo_address')){
                        String woAddressVar = mapActualSFAIdWithPreviewforWO.get('wo_address');
                        //System.debug('woAddressVar '+woAddressVar);
                        if(woAddressVar.containsIgnoreCase('SVMXC__Street__c'))
                        woAddressVar = woAddressVar.replace('SVMXC__Street__c,', '');
                        if(woAddressVar.containsIgnoreCase('SVMXC__City__c'))
                        woAddressVar = woAddressVar.replace('SVMXC__City__c,', '');
                        if(woAddressVar.containsIgnoreCase('SVMXC__State__c'))
                        woAddressVar = woAddressVar.replace('SVMXC__State__c,', '');
                        if(woAddressVar.containsIgnoreCase('SVMXC__Zip__c'))
                        woAddressVar = woAddressVar.replace('SVMXC__Zip__c,', '');
                        if(woAddressVar.containsIgnoreCase('SVMXC__Country__c'))
                        woAddressVar = woAddressVar.replace('SVMXC__Country__c', '');

                        mapActualSFAIdWithPreviewforWO.put('wo_address',woAddressVar);
                    }

                }

                for(String mapTempVal: mapSFAIdWithPreview.keySet()){// For preview fields
                    Map<String,String> fieldValueMapTemp = new Map<String,String>();
                    for(String mapTempValInter: mapSFAIdWithPreview.get(mapTempVal).keySet()){// For preview fields
                        if(mapConsolidatedFields.containsKey(mapTempValInter)){
                            fieldValueMapTemp.put(mapTempValInter, mapConsolidatedFields.get(mapTempValInter));
                        }
                    }
                    if(woWhatId!=null && mapActualSFAIdWithPreviewforWO.size()>0)
                        fieldValueMapTemp.putAll(mapActualSFAIdWithPreviewforWO);
                    for(String mapTempValInter:fieldValueMapTemp.keySet()){
                        if(mapTempValInter.equalsIgnoreCase(fieldValueMapTemp.get(mapTempValInter)))
                            fieldValueMapTemp.put(mapTempValInter, '');
                    }
                    mapSFAIdWithPreview.put(mapTempVal,fieldValueMapTemp);
                }
            }
        } else {
            if(sobjectName.equalsIgnoreCase('SVMXC__Service_Order__c')){
                sRelatedobjectRecordName = sobjectName;
                sRelatedobjectRecordId = recordId;
            }
            for(String mapTempVal: mapSFAIdWithPreview.keySet()){// For preview fields
                mapConsolidatedFields.putAll(mapSFAIdWithPreview.get(mapTempVal));
                mapActualSFAIdWithPreview.putAll(mapSFAIdWithPreview.get(mapTempVal));
            }
            System.debug('mapConsolidatedFields '+mapConsolidatedFields);

            setAllFieldValues.addAll(mapConsolidatedFields.values());//Get the unique values

            List<String> queryFieldsDTSO = new List<String>();
            system.debug('Map field to type: ' + JSON.serialize(mapFieldToType));
            for (String field : setAllFieldValues)
            {
                String fieldForQuery = field;
                for (String mapkey: mapFieldToType.keyset()) {
                  if(mapkey == '[$' + field + ']' && mapFieldToType.get(mapkey)  == 'picklist') {
                    system.debug('Field for Query: ' + '[$' + field + ']' + ' :and type is: ' + mapFieldToType.get(mapkey));
                    fieldForQuery = 'toLabel(' + field + ')';
                  }
                }
                if(!String.isBlank(fieldString))
                    fieldString += ', ' + fieldForQuery;
                else
                    fieldString += fieldForQuery;

                if (!field.startsWith('(')) {
                    queryFieldsDTSO.add(field);
                }
            }
            if(!fieldString.containsIgnoreCase('LastModifiedBy.UserName'))//Added for JWT token
                fieldString += ', ' + 'LastModifiedBy.UserName';
            //Check Field Security Check
            System.debug('checking access for object: '+sobjectName);
            System.debug('checking access for fields: '+JSON.serialize(queryFieldsDTSO));
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( sobjectName, queryFieldsDTSO, COMM_SecurityUtils.Access.Accessible ) ) {
                System.debug('Access not found either for object: '+ sobjectName + ' :or for fields: ' + JSON.serialize(queryFieldsDTSO));
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //End of Check Field Security Check
            System.debug('SOQl '+'Select ' + fieldString + ' from ' + sobjectName + ' Where Id =: '+recordId);
            Sobject sRecordDetails = database.query('Select ' + fieldString + ' from ' + sobjectName + ' Where Id =: recordId'); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            System.debug('sRecordDetails '+sRecordDetails);
            //System.debug('sRecordDetails getPopulatedFieldsAsMap '+sRecordDetails.getPopulatedFieldsAsMap());
            if(sRecordDetails != null){
                Map<String,Object> mapFieldAndValueOfRecord1 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sRecordDetails));

                for(String s:mapFieldAndValueOfRecord1.keySet()){
                    System.debug('s '+s+' value '+mapFieldAndValueOfRecord1.get(s));
                    if(sobjectName.equalsIgnoreCase('SVMXC__SVMX_Event__c') && s.equalsIgnoreCase('SVMXC__Service_Order__c')){
                        sRelatedobjectRecordName = 'SVMXC__Service_Order__c';
                        sRelatedobjectRecordId = String.valueOf(mapFieldAndValueOfRecord1.get(s));
                    }
                    if(mapActualSFAIdWithPreview.containsKey(s)){
                        mapActualSFAIdWithPreview.put(s,String.valueOf(mapFieldAndValueOfRecord1.get(s)));
                    }else if(s.endsWithIgnoreCase('__r')){
                        String keyMainVal ='[$' + s.substringBeforeLast('__')+'__c' + ']';
                        System.debug('keyMainVal '+keyMainVal);
                        Object objDetails = mapFieldAndValueOfRecord1.get(s);
                        Map<String, Object> str = (Map<String, Object>) objDetails;
                        //Map<String, Object> str = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objDetails)); //BAC-5040
                        System.debug('keyMainVal str '+str);
                        if (!str.containsKey('attributes')) {
                          continue;
                        }
                        Map<String, Object> strAttribute = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(str.get('attributes'))); //BAC-5040
                        System.debug('objDetails str '+strAttribute);
                        String typeObjName = '';
                        for(String internalVar: strAttribute.keySet()){ //BAC-5040
                            typeObjName = String.valueOf(strAttribute.get('type'));
                        }

                        type stype= type.forName(typeObjName);
                        Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1.get(s)), stype);
                        System.debug('resultSobject '+resultSobject);
                        Map<String, Object> fieldsToValue = resultSobject.getPopulatedFieldsAsMap();
                        for(String internalVar:fieldsToValue.keySet()){
                            System.debug('sssssss '+s+'.'+internalVar);
                            String relatedObjDetails = s+'.'+internalVar;
                            if(mapActualSFAIdWithPreview.containsKey(s+'.'+internalVar)){
                                mapActualSFAIdWithPreview.put(s+'.'+internalVar,String.valueOf(fieldsToValue.get(internalVar)));
                            }else if(relatedObjDetails.endsWithIgnoreCase('__r')){
                                Sobject resultRelatedSobject = (Sobject)JSON.deserialize(JSON.serialize(fieldsToValue.get(internalVar)), stype);
                                if(mapActualSFAIdWithPreview.containsKey(relatedObjDetails+'.Name'))
                                    mapActualSFAIdWithPreview.put(relatedObjDetails+'.Name',String.valueOf(resultRelatedSobject.get('Name')));
                            }

                        }
                        if(mapFieldAPIDetails.containsKey(keyMainVal)){
                            if(objectResultSet.containsKey(typeObjName.toUpperCase())){ //BAC-5040
                                mapFieldAPIDetails.put(keyMainVal,String.valueOf(resultSobject.get(objectResultSet.get(typeObjName.toUpperCase()))).replace(' 00:00:00', ''));
                            }else{
                                mapFieldAPIDetails.put(keyMainVal,String.valueOf(resultSobject.get('Name')));
                            }
                        }

                    }
                    String keyMainVal ='[$' + s + ']';
                    if(s.equalsIgnoreCase('Owner') || s.equalsIgnoreCase('CreatedBy') || s.equalsIgnoreCase('LastModifiedBy')){
                        keyMainVal = '[$' + s + 'Id'+']';
                        type stype= type.forName(sobjectName);
                        Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1.get(s)), stype);
                        //System.debug('resultSobject '+resultSobject.get('Name'));
                        if(mapFieldAPIDetails.containsKey(keyMainVal)){
                            mapFieldAPIDetails.put(keyMainVal,String.valueOf(resultSobject.get('Name')));
                        }
                    }else if(mapFieldAPIDetails.containsKey(keyMainVal)){
                        mapFieldAPIDetails.put(keyMainVal,String.valueOf(mapFieldAndValueOfRecord1.get(s)).replace(' 00:00:00', ''));
                    }

                }
                System.debug('mapActualSFAIdWithPreview '+mapActualSFAIdWithPreview);
                if(sobjectName.equalsIgnoreCase('SVMXC__Service_Order__c')){
                    String woAddress = 'SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c';
                for(String tempFieldsInternal: mapActualSFAIdWithPreview.keySet()){
                        if(tempFieldsInternal.equalsIgnoreCase('SVMXC__Street__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__City__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__State__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Zip__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Country__c')){
                            if(mapActualSFAIdWithPreview.get(tempFieldsInternal) !=null)
                                woAddress = woAddress.replace(tempFieldsInternal, mapActualSFAIdWithPreview.get(tempFieldsInternal));
                            mapActualSFAIdWithPreview.remove(tempFieldsInternal);
                            mapActualSFAIdWithPreview.put('wo_address', woAddress);
                        }
                    }
                    if(mapActualSFAIdWithPreview.containsKey('wo_address')){
                    String woAddressVar = mapActualSFAIdWithPreview.get('wo_address');
                    //System.debug('woAddressVar '+woAddressVar);
                    if(woAddressVar.containsIgnoreCase('SVMXC__street__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__street__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__city__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__city__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__state__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__state__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__zip__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__zip__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__country__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__country__c', '');

                    mapActualSFAIdWithPreview.put('wo_address',woAddressVar);
                    }
                }else if(String.isNotEmpty(sRelatedobjectRecordId) && sobjectName.equalsIgnoreCase('SVMXC__SVMX_Event__c')){
                    String woAddress = 'SVMXC__Service_Order__r.SVMXC__Street__c, SVMXC__Service_Order__r.SVMXC__City__c, SVMXC__Service_Order__r.SVMXC__State__c, SVMXC__Service_Order__r.SVMXC__Zip__c, SVMXC__Service_Order__r.SVMXC__Country__c';
                for(String tempFieldsInternal: mapActualSFAIdWithPreview.keySet()){
                        if(tempFieldsInternal.equalsIgnoreCase('SVMXC__Service_Order__r.SVMXC__Street__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Service_Order__r.SVMXC__City__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Service_Order__r.SVMXC__State__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Service_Order__r.SVMXC__Zip__c') || tempFieldsInternal.equalsIgnoreCase('SVMXC__Service_Order__r.SVMXC__Country__c')){
                            if(mapActualSFAIdWithPreview.get(tempFieldsInternal) !=null)
                                woAddress = woAddress.replace(tempFieldsInternal, mapActualSFAIdWithPreview.get(tempFieldsInternal));
                            mapActualSFAIdWithPreview.remove(tempFieldsInternal);
                            mapActualSFAIdWithPreview.put('wo_address', woAddress);
                        }
                    }
                    if(mapActualSFAIdWithPreview.containsKey('wo_address')){
                    String woAddressVar = mapActualSFAIdWithPreview.get('wo_address');
                    //System.debug('woAddressVar '+woAddressVar);
                    if(woAddressVar.containsIgnoreCase('SVMXC__service_order__r.SVMXC__street__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__service_order__r.SVMXC__street__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__service_order__r.SVMXC__city__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__service_order__r.SVMXC__city__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__service_order__r.SVMXC__state__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__service_order__r.SVMXC__state__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__service_order__r.SVMXC__zip__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__service_order__r.SVMXC__zip__c,', '');
                    if(woAddressVar.containsIgnoreCase('SVMXC__service_order__r.SVMXC__country__c'))
                    woAddressVar = woAddressVar.replace('SVMXC__service_order__r.SVMXC__country__c', '');

                    mapActualSFAIdWithPreview.put('wo_address',woAddressVar);
                    }
                }
                for(String mapTempVal: mapSFAIdWithPreview.keySet()){// For preview fields
                    Map<String,String> fieldValueMapTemp = new Map<String,String>();
                    for(String mapTempValInter: mapSFAIdWithPreview.get(mapTempVal).keySet()){// For preview fields
                        if(mapActualSFAIdWithPreview.containsKey(mapTempValInter)){
                            fieldValueMapTemp.put(mapTempValInter, mapActualSFAIdWithPreview.get(mapTempValInter));
                        }
                    }
                    for(String mapTempValInter:fieldValueMapTemp.keySet()){
                        if(mapTempValInter.equalsIgnoreCase(fieldValueMapTemp.get(mapTempValInter)))
                            fieldValueMapTemp.put(mapTempValInter, '');
                    }
                    if(mapActualSFAIdWithPreview.containsKey('wo_address'))
                        fieldValueMapTemp.put('wo_address',mapActualSFAIdWithPreview.get('wo_address'));
                    mapSFAIdWithPreview.put(mapTempVal,fieldValueMapTemp);
                }
                System.debug('mapSFAIdWithPreview '+mapSFAIdWithPreview);

                sobjectOwnerDetail = getUserName(sRecordDetails);

                System.debug('sobjectOwnerDetail '+sobjectOwnerDetail);

                for(String tempFields : mapRecipientIds.keySet()){
                    Set<String> recipientIds = new Set<String>();
                    SFA_WrapperDef.SFA_SFDCActionJsonWrapper sfaProcessAction = tempMapSFAProcessActions.get(tempFields);
                    for(String tempFieldsInternal : mapRecipientIds.get(tempFields).keySet()){
                        if (tempFieldsInternal.startsWith('(')) {
                          String relatedListObjectRelationShipName = fetchRelatedListObject(tempFieldsInternal);
                          List<String> relatedListObjectFields = fetchRelatedListObjectFields(tempFieldsInternal);
                          SObject[] relatedListRecords = sRecordDetails.getsobjects(relatedListObjectRelationShipName);
                          if (relatedListRecords != null && relatedListRecords.size() > 0) {
                            for (sObject relatedListRecord: relatedListRecords) {
                              for (String relatedListRecordField: relatedListObjectFields) {
                                if (relatedListRecord.get(relatedListRecordField) != null) {
                                    String fieldValue = String.valueOf(relatedListRecord.get(relatedListRecordField));
                                    recipientIds.add(fieldValue);
                                    mapDifferentUserDetails.put(fieldValue, fieldValue);
                                }
                              }
                            }
                          }
                        } else {
                          if(sRecordDetails.get(tempFieldsInternal) != null){
                              String fieldValue = String.valueOf(sRecordDetails.get(tempFieldsInternal));//get the value of the perticular field
                              recipientIds.add(fieldValue);
                              mapDifferentUserDetails.put(fieldValue, fieldValue);
                          }
                        }
                    }
                    system.debug('For SFA: ' + tempFields + ' :Recipient Ids: ' + recipientIds);
                    mapSFAProcessToRecipientIds.put(tempFields, recipientIds);
                }

                if(mapDifferentUserDetails.size() > 0){
                    for(String objNameTemp: mapDifferentUserDetails.keySet()){ // This will execute number of times that depends how many non user recipientId in the config
                        String sObjName = getTheObjectNameFromId(Id.valueOf(objNameTemp));
                        //System.debug('sObjName '+sObjName);
                        if(sObjName.equalsIgnoreCase('Group')){ //for queue
                            for(GroupMember gm:[SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =:+mapDifferentUserDetails.get(objNameTemp)]){
                                if(mapGroupUser.containsKey(gm.GroupId)){
                                    mapGroupUser.get(String.valueOf(gm.GroupId)).add(String.valueOf(gm.UserOrGroupId));
                                }else{
                                    List<String> listUserTemp = new List<String>();
                                    listUserTemp.add(String.valueOf(gm.UserOrGroupId));
                                    mapGroupUser.put(String.valueOf(gm.GroupId), listUserTemp);
                                }

                            }
                        }else if(sObjName.equalsIgnoreCase('SVMXC__Service_Group_Members__c')){ //for technician
                            for(SVMXC__Service_Group_Members__c gm:[SELECT id, SVMXC__Salesforce_User__c FROM SVMXC__Service_Group_Members__c WHERE id =:+mapDifferentUserDetails.get(objNameTemp) and SVMXC__Active__c = true]){
                                if(mapGroupUser.containsKey(gm.Id)){
                                    mapGroupUser.get(String.valueOf(gm.Id)).add(String.valueOf(gm.SVMXC__Salesforce_User__c));
                                }else{
                                    List<String> listUserTemp = new List<String>();
                                    listUserTemp.add(String.valueOf(gm.SVMXC__Salesforce_User__c));
                                    mapGroupUser.put(String.valueOf(gm.Id), listUserTemp);
                                }

                            }
                        }
                    }
                    //System.debug('mapGroupUser '+mapGroupUser);
                }
            }
        }

        String loginURL = '';
        List<String> loginUrlvar = tokenEndpoint.split('services');

        loginURL = loginUrlvar[0];
        System.debug('mapRecipientIds '+mapRecipientIds);
        for(String fieldVar: mapSFAIdWithPreview.keySet()){
            Map<String,String> mapTempValue = new Map<String,String>();
            mapTempValue.putAll(mapSFAIdWithPreview.get(fieldVar));
            for(String fieldVal: mapTempValue.keySet()){
                //System.debug('fieldVal '+fieldVal);
                //System.debug('fieldVal mapTempValue '+mapTempValue.get(fieldVal));
                if(String.isEmpty(mapTempValue.get(fieldVal)))
                    mapTempValue.remove(fieldVal);
            }
            mapSFAIdWithPreview.put(fieldVar, mapTempValue);
        }
        System.debug('mapSFAIdWithPreview '+mapSFAIdWithPreview);
        for(String internalVar: mapFieldAPIDetails.keySet()){ //BAC-4974
            if(mapFieldAPIDetails.get(internalVar) != null && mapFieldAPIDetails.get(internalVar).endsWithIgnoreCase('__r.Name')){
                mapFieldAPIDetails.put(internalVar,'');
            }
        }
        System.debug('mapFieldAPIDetails a '+mapFieldAPIDetails);
        Map<String, String> mapFieldTextToType = mapFieldTextNameAndType.get(FIELD_TEXT_TO_TYPE);
        filterRecipientIdsForSFAGroupProfile(mapSFAProcessToRecipientIds, tempMapSFAProcessActions, mapGroupUser);
        if (mapSFAProcessToRecipientIds == null || mapSFAProcessToRecipientIds.size() == 0) {
          return;
        }
        String body = getWrapperClassData(tempMapSFAProcessActions, mapFieldAPIDetails, mapSFAIdWithPreview, loginURL, mapSFAProcessToRecipientIds, mapFieldTextToType);
        if(isJWTTokenEnabled || Test.isRunningTest()){
            callSyncGateWay(syncGateWayEndPoint, body, recordId, sobjectOwnerDetail, tokenEndpoint, issDetails, certificateName, null);
        }else{
            System.debug('Access token in SVMX setting is not enabled.');
        }
    }

    private void filterRecipientIdsForSFAGroupProfile(Map<String, Set<String>> mapSFAProcessToRecipientIds, Map<String, SFA_WrapperDef.SFA_SFDCActionJsonWrapper> tempMapSFAProcessActions, Map<String, List<String>> mapGroupUser) {
      system.debug('Started Filtering recipient Ids: ' + mapSFAProcessToRecipientIds);
      Map<String, Set<String>> sfaProcessToRecipientsUserIds = new Map<String, Set<String>>();

      for (String SFAID: mapSFAProcessToRecipientIds.keyset()) {
        Set<String> recipientsUserIds = new Set<String>();
        for (String techId: mapSFAProcessToRecipientIds.get(SFAID)) {
          if(mapGroupUser.size() > 0 && mapGroupUser.containsKey(techId) && mapGroupUser.get(techId) != null && mapGroupUser.get(techId).size() > 0) {
            recipientsUserIds.addAll(mapGroupUser.get(techId));
          } else {
            recipientsUserIds.add(techId);
          }
        }
        sfaProcessToRecipientsUserIds.put(SFAID, recipientsUserIds);
      }
      mapSFAProcessToRecipientIds.clear();
      mapSFAProcessToRecipientIds.putAll(sfaProcessToRecipientsUserIds);

      system.debug('Before filtering recipient Ids based on Group Profile Ids: ' + mapSFAProcessToRecipientIds);
      Map<String, String> mapSFAProcessToGroupProfileId = new Map<String, String>();
      for(SVMXC__SM_SFA_Process__c sfaProcess: [SELECT SVMXC__SM_SFA_Process_Id__c, SVMXC__SM_SVMX_Group_Profile__c FROM SVMXC__SM_SFA_Process__c WHERE SVMXC__SM_SFA_Process_Id__c IN: mapSFAProcessToRecipientIds.keyset()]) {
        mapSFAProcessToGroupProfileId.put(sfaProcess.SVMXC__SM_SFA_Process_Id__c, sfaProcess.SVMXC__SM_SVMX_Group_Profile__c);
      }

      Map<String, String> mapSfProfileIdToSvmxGroupProfileId = new Map<String, String>();
      for (SVMXC__ServiceMax_Config_Data__c profileAccess: [SELECT SVMXC__Access_Configuration_Profile__c, SVMXC__Profile__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'Configuration Access' AND SVMXC__Access_Configuration_Profile__c IN: mapSFAProcessToGroupProfileId.values()]) {
        if (profileAccess.SVMXC__Profile__c != null) {
          mapSfProfileIdToSvmxGroupProfileId.put(profileAccess.SVMXC__Profile__c, profileAccess.SVMXC__Access_Configuration_Profile__c);
        }
      }

      Map<String, Set<String>> mapGroupProfileIdToUserIds = new Map<String, Set<String>>();
      for (User user: [SELECT Id, ProfileId FROM User WHERE ProfileId IN: mapSfProfileIdToSvmxGroupProfileId.keyset()]) {
        system.debug('User Id: ' + user.Id + ' :and Profile Id: ' + user.ProfileId);

        String svmxGroupProfileId = mapSfProfileIdToSvmxGroupProfileId.get(user.ProfileId);
        system.debug('GroupProfile Id: ' + svmxGroupProfileId);
        if (svmxGroupProfileId == null || svmxGroupProfileId.length() == 0) {
          continue;
        }
        if (!mapGroupProfileIdToUserIds.containsKey(svmxGroupProfileId)) {
          mapGroupProfileIdToUserIds.put(svmxGroupProfileId, new Set<String>());
        }
        mapGroupProfileIdToUserIds.get(svmxGroupProfileId).add(user.Id);
      }

      Set<String> sfaProcessIds = mapSFAProcessToRecipientIds.keyset();
      for (String sfaProcessId: sfaProcessIds) {
        String groupProfileId = mapSFAProcessToGroupProfileId.get(sfaProcessId);
        Set<String> userIdsForSvmxGroupProfile = mapGroupProfileIdToUserIds.get(groupProfileId);
        if (userIdsForSvmxGroupProfile == null || userIdsForSvmxGroupProfile.size() == 0) {
          mapSFAProcessToRecipientIds.remove(sfaProcessId);
          tempMapSFAProcessActions.remove(sfaProcessId);
          continue;
        }
        mapSFAProcessToRecipientIds.get(sfaProcessId).retainAll(userIdsForSvmxGroupProfile);
        if (mapSFAProcessToRecipientIds.get(sfaProcessId) == null || mapSFAProcessToRecipientIds.get(sfaProcessId).size() == 0) {
          mapSFAProcessToRecipientIds.remove(sfaProcessId);
          tempMapSFAProcessActions.remove(sfaProcessId);
        }
      }

      system.debug('After filtering recipient Ids based on Group Profile Ids: ' + mapSFAProcessToRecipientIds);
    }

    private String fetchRelatedListObject(String tempFieldsInternal) {
      List<String> fieldsObjectNames = getFieldsObjectNames(tempFieldsInternal);
      return fieldsObjectNames[1];
    }

    private List<String> fetchRelatedListObjectFields(String tempFieldsInternal){
      List<String> fieldsObjectNames = getFieldsObjectNames(tempFieldsInternal);
      return fieldsObjectNames[0].split(',');
    }

    private List<String> getFieldsObjectNames(String tempFieldsInternal) {
      tempFieldsInternal = tempFieldsInternal.replaceAll('\\(Select ', '').replaceAll('\\)', '');
      return tempFieldsInternal.split(' FROM ');
    }

    private String getUserName(Sobject sRecordDetails) {
        User userDetails = (User)sRecordDetails.getSObject('LastModifiedBy');
        return userDetails.Username;
    }

    /** Name - callSyncGateWay
    * This method is hit SyncGateway via future as callout is not supported by trigger.
    *
    *
    * @exception no.
    */
    @future(callout=true)
    public static void callSyncGateWay(String restAPIURL, String body,Id recordId, String sobjectOwnerDetail, String tokenEndpoint, String issDetails, String certificateName, String smsClientToken){
        String accessToken = getSFDCAccessToken(sobjectOwnerDetail, tokenEndpoint, issDetails, certificateName);
        HttpRequest req = getHttpRequestForNotification(restAPIURL, accessToken, body);
        if (smsClientToken != null && smsClientToken.length() > 0) {
            req.setHeader('SMS-CLIENT-TOKEN', smsClientToken);
        }

        String response = '';
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(req);
            if (httpResponse.getStatusCode() == 200 ) {
                response = httpResponse.getStatusCode()+' Successfully publish to SyncGateway';
            } else {
                response = httpResponse.getStatusCode()+' Unable to publish the request';
                throw new CalloutException( httpResponse.getBody() );
            }
        } catch(Exception e) {
            System.debug('ERROR: '+ e);
        }
        System.debug(' ** response ** : ' + response );
    }

    private static String getSFDCAccessToken(String sobjectOwnerDetail, String tokenEndpoint, String issDetails, String certificateName) {
        String accessToken = '';
        String loginURL = '';
        List<String> loginUrlvar = tokenEndpoint.split('services');
        loginURL = loginUrlvar[0];
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(sobjectOwnerDetail);
        //jwt.setSub('soumyaranjan.SVMXC@ge.com');
        jwt.setAud(loginURL);
        jwt.setIss(issDetails);

        //Create the object that signs the JWT bearer token
        Auth.JWS jws = new Auth.JWS(jwt, certificateName);

        if (!Test.isRunningTest()) {
            //Get the resulting JWS in case debugging is required
            //POST the JWT bearer token
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
            accessToken = bearer.getAccessToken();
        }else{
            accessToken ='Success';
        }
        return accessToken;
    }

    private static HttpRequest getHttpRequestForNotification(String restAPIURL, String accessToken, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restAPIURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('From', 'ServiceMaxNow');
        req.setbody(body);
        System.debug('body: '+body);
        return req;
    }

    /** Name - getTheObjectNameFromId
    * This method is used get the Object Name from a given id.
    *
    * @param myId
    * @return return the object name
    *
    * myId -: Id of the given Sobject
    *
    * @exception no.
    */
    private String getTheObjectNameFromId(Id myId){
        String returnValue = '';
        returnValue = myId.getSObjectType().getDescribe().getName();
        return returnValue;
    }
    /** Name - getWrapperClassData
    * This method is used to get the wrapper class data as a JSON format.
    *
    *
    * @exception no.
    */
    private String getWrapperClassData(Map<String, SFA_WrapperDef.SFA_SFDCActionJsonWrapper> tempMapSFAProcessActions, Map<String,String> mapFieldAPIDetails, Map<String,Map<String,String>> previewfieldValueMap, String logginURL, Map<String, Set<String>> mapSFAProcessToRecipientIds, Map<String,String> mapFieldTextToType) {
        String returnValue = '';
        //Get all the users from queue

        //
        //System.debug('mapFieldAPIDetails '+mapFieldAPIDetails);
        List<SFA_WrapperDef.SyncGatewayMessages> lstsyncGatewayMessageVar = new List<SFA_WrapperDef.SyncGatewayMessages>();
        for(String keyVal : tempMapSFAProcessActions.keySet()){
            Map<String,Object> keyValueMap = new Map<String,Object>();
            Map<String,String> keyValueMapforpreviewFields = new Map<String,String>();
            SFA_WrapperDef.SFA_SFDCActionJsonWrapper sfaActionVar = tempMapSFAProcessActions.get(keyVal);
            List<String> applications = new List<String>(); //get it from SFA action
            applications.add(sfaActionVar.Client_App_Name); // Added for DEMO
            List<String> users = new List<String>(); //get it from SFA action
            for(String userTemp: mapSFAProcessToRecipientIds.get(keyVal)){
                users.add(userTemp);
            }
            if(mapEventTriggerFieldMap.size() > 0 && mapEventTriggerFieldMap.containsKey(keyVal)){
                Map<String,String> previewVarMap = new Map<String,String>();
                previewVarMap.putAll(mapEventTriggerFieldMap.get(keyVal));
                for(String previewVar: previewVarMap.keySet()){
                    keyValueMap.put(previewVar, previewVarMap.get(previewVar));
                }
            }

            system.debug('SFA Process User Ids from recipients Fields - users: ' + users);
            if(mapTriggerType.containsKey(keyVal))
                keyValueMap.put('trigger_type', mapTriggerType.get(keyVal));
            String operation = '';
            if(sfaActionVar.Screen_To_Load.equalsIgnoreCase('NOTIFICATION_DETAIL_DIALOG')){
                operation = 'NOTIFICATION_DETAILS';
            }else if(sfaActionVar.Screen_To_Load.equalsIgnoreCase('SFM_VIEW')){
                operation = 'INVOKE_PROCESS';
            } else if(sfaActionVar.Screen_To_Load.equalsIgnoreCase('SF_ACTION')){
                operation = 'INVOKE_ACTION';
            }
            String title = sfaActionVar.Message_Title;//Get it from SFA action
            String bodyTitle = replaceMessageWithActualValue(sfaActionVar.Message_Body, mapFieldAPIDetails); //Get it from SFA action

            if(previewfieldValueMap.size() > 0 && previewfieldValueMap.get(keyVal) != null){
                keyValueMapforpreviewFields.putAll(previewfieldValueMap.get(keyVal));
            }
            keyValueMap.putAll(keyValueMapforpreviewFields); // For preview list

            keyValueMap.put('sfaId', keyVal);
            keyValueMap.put('message', replaceMessageWithActualValue(sfaActionVar.Message_Body, mapFieldAPIDetails, mapFieldTextToType));

            if(mapSFAIProIdSFMProId.size() > 0 && mapSFAIProIdSFMProId.containsKey(keyVal)){
                keyValueMap.put('sfmId', mapSFAIProIdSFMProId.get(keyVal));
            }

            if(!String.isEmpty(sRelatedobjectRecordId) && !sobjectRecordName.equalsIgnoreCase('SVMXC__Service_Order__c')){
                keyValueMap.put('RelatedObjectId', sRelatedobjectRecordId);
                keyValueMap.put('RelatedObjectName', sRelatedobjectRecordName);
            }
            if(sobjectRecordId !=null){
                keyValueMap.put('RecordId', sobjectRecordId);
                keyValueMap.put('ObjectName', sobjectRecordName);
            }

            Boolean isRichContent = false;
            system.debug('is Interactive Action: ' + sfaActionVar.IsInteractiveAction);
            system.debug('Interactive Actions: ' + sfaActionVar.InteractiveActions);
            Set<String> actionsSet = new Set<String>();
            if (sfaActionVar.IsInteractiveAction!= null && sfaActionVar.IsInteractiveAction == true) {
                isRichContent = true;
                if (sfaActionVar.InteractiveActions != null && sfaActionVar.InteractiveActions.size() > 0) {
                    keyValueMap.put('notification_actions', sfaActionVar.InteractiveActions);
                }
            }

            //sobjectData.put('message','Your Work Order Problem Description has been updated');
            SFA_WrapperDef.SyncGatewayMetaData messageData = new SFA_WrapperDef.SyncGatewayMetaData(operation, title, bodyTitle, keyValueMap, isRichContent);
            if(users.size() > 0){
                SFA_WrapperDef.SyncGatewayMessages syncGatewayMessageVar = new SFA_WrapperDef.SyncGatewayMessages(applications, users, messageData);
                lstsyncGatewayMessageVar.add(syncGatewayMessageVar);
            }
        }
        returnValue = JSON.serialize( new SFA_WrapperDef.SyncGatewayMessageWrapper(logginURL, lstsyncGatewayMessageVar));
        system.debug('Generated Notification Body String: ' + returnValue);
        return returnValue;
    }
    /** Name - replaceMessageWithActualValue
    * This method is used replace the actual value for a given message with field API.
    *
    *
    *
    * @exception no.
    */
    private String replaceMessageWithActualValue(String tempMessage, Map<String,String> mapFieldAPIDetails){

        for(String fieldVal: mapFieldAPIDetails.keySet()){
            if(tempMessage.contains(fieldVal)){
                String tempVar = '[$'+mapFieldAPIDetails.get(fieldVal).toLowerCase()+']';
                if(fieldVal.equalsIgnoreCase(tempVar)){
                    tempMessage = tempMessage.replace(fieldVal,'');
                }else{
                    tempMessage = tempMessage.replace(fieldVal,mapFieldAPIDetails.get(fieldVal));

                }
            }

            //System.debug('tempMessage '+tempMessage);
        }
        return tempMessage;
    }

    private String replaceMessageWithActualValue(String tempMessage, Map<String,String> mapFieldAPIDetails, Map<String,String> mapFieldTextToType){
        for(String fieldVal: mapFieldAPIDetails.keySet()){
            if(tempMessage.contains(fieldVal)){
                String tempVar = '[$'+mapFieldAPIDetails.get(fieldVal).toLowerCase()+']';
                if(fieldVal.equalsIgnoreCase(tempVar)){
                    tempMessage = tempMessage.replace(fieldVal,'');
                }else{
                    String resolvedFieldValue = mapFieldAPIDetails.get(fieldVal);
                    if(mapFieldTextToType.containsKey(fieldVal)) {
                        if(mapFieldTextToType.get(fieldVal).equalsIgnoreCase('DATE')) {
                            resolvedFieldValue = '$DATEVALUE(' + mapFieldAPIDetails.get(fieldVal) + ')';
                        } else if(mapFieldTextToType.get(fieldVal).equalsIgnoreCase('DATETIME')) {
                            resolvedFieldValue = '$DATETIMEVALUE(' + mapFieldAPIDetails.get(fieldVal) + ')';
                        } else if(mapFieldTextToType.get(fieldVal).equalsIgnoreCase('TIME')) {
                            resolvedFieldValue = '$TIMEVALUE(' + mapFieldAPIDetails.get(fieldVal) + ')';
                        }
                    }
                    tempMessage = tempMessage.replace(fieldVal,resolvedFieldValue);
                }
            }

            //System.debug('tempMessage '+tempMessage);
        }
        return tempMessage;
    }
    /** Name - isFieldValueUpdated
    * This method is used to check the fieldset value has been updated or not.
    *
    * @param eventConfigFieldsTemp, oldSobjectFieldSetValTemp, newSobjectFieldSetValTemp
    * @return return true if found changes, else false
    *
    * eventConfigFieldsTemp -: Set of fieldset value
    * oldSobjectFieldSetValTemp -: Old fieldset value
    * newSobjectFieldSetValTemp -: New fieldset value
    *
    * @exception no.
    */
    private Boolean isFieldValueUpdated(Set<String> eventConfigFieldsTemp, SFA_WrapperDef.SFA_RecordWrapper oldSobjectFieldSetValTemp, SFA_WrapperDef.SFA_RecordWrapper newSobjectFieldSetValTemp){
        Boolean returnFlag = false;

        for(String fieldVal: eventConfigFieldsTemp){
            //System.debug('oldSobjectFieldSetValTemp '+oldSobjectFieldSetValTemp.mapfieldNameValues.get(fieldVal));

            if(oldSobjectFieldSetValTemp.mapfieldNameValues.get(fieldVal) != newSobjectFieldSetValTemp.mapfieldNameValues.get(fieldVal)){
                returnFlag = true;
                break;
            }
        }
        return returnFlag;
    }
    /** Name - getTheConfigFieldNameforMessage
    * This method is used to check which field is config for a given sobject.
    *
    * @param eventConfigFieldsTemp, oldSobjectFieldSetValTemp, newSobjectFieldSetValTemp
    * @return return true if found changes, else false
    *
    * eventConfigFieldsTemp -: Set of fieldset value
    * oldSobjectFieldSetValTemp -: Old fieldset value
    * newSobjectFieldSetValTemp -: New fieldset value
    *
    * @exception no.
    */
    private Map<String, Map<String, String>> getTheConfigFieldNamefromMessage(String objectName, List<String> listMessageDetails) {
        Map<String, Map<String, String>> mapFieldTextNameAndType = new Map<String, Map<String, String>>();
        Map<String, String> mapFieldToFieldType = new Map<String, String>();
        //SObjectType sobjectName = Schema.getGlobalDescribe().get(objectName);
        //SObjectType sobjectName = globalDescribeVar.get(objectName);
        SObjectType sobjectName = ((SObject)(Type.forName('Schema.'+ objectName ).newInstance())).getSObjectType();
        Map<String,String> mapSobjectFields = new Map<String,String>();
        Map<String,Schema.SObjectField> mfields = sobjectName.getDescribe().fields.getMap();
        for(String tempMessage : listMessageDetails){
            for(String sfield : mfields.keySet()){
                Schema.DescribeFieldResult fldDescribe = mfields.get(sfield).getDescribe();
                String strFieldInText = '[$' + mfields.get(sfield).getDescribe().getName() + ']';
                String resolvedFieldName = sfield;
                if(tempMessage.containsIgnoreCase(strFieldInText)){
                    System.debug('sfield '+sfield);
                    if((fldDescribe.getType() == Schema.DisplayType.Reference) && sfield.endsWithIgnoreCase('__c')) {
                        String referenceFieldName = fldDescribe.getReferenceTo()[0].getDescribe().getName();
                        System.debug('Lookup reference object name: ' + referenceFieldName);
                        if(objectResultSet.containsKey(referenceFieldName.toUpperCase())){ //BAC-5040
                            resolvedFieldName = sfield.substringBeforeLast('__')+'__r.'+objectResultSet.get(referenceFieldName.toUpperCase());
                        } else {
                            resolvedFieldName = sfield.substringBeforeLast('__')+'__r.name';
                        }
                     } else if (sfield.equalsIgnoreCase('OwnerId') || sfield.equalsIgnoreCase('CreatedById') || sfield.equalsIgnoreCase('LastModifiedById')) {
                        resolvedFieldName = sfield.substringBeforeLast('id')+'.name';
                    }
                    mapSobjectFields.put(strFieldInText, resolvedFieldName);
                    mapFieldToFieldType.put(strFieldInText, String.valueOf(fldDescribe.getType()));
                }
            }
        }
        mapFieldTextNameAndType.put(FIELD_TEXT_TO_VALUE, mapSobjectFields);
        mapFieldTextNameAndType.put(FIELD_TEXT_TO_TYPE, mapFieldToFieldType);
        System.debug('mapSobjectFields '+mapSobjectFields);
        System.debug('mapFieldTextNameAndType '+mapFieldTextNameAndType);
        return mapFieldTextNameAndType;
    }
}