public class SVMX_PushNotification
{
    public void sendNotification(map<Id, SObject> newMapOfIdToSObjTrigger, String strObjectName, String strAlertType, map<String, String> mapEachSetting, Boolean isSFDCPN)
    {
        Set<String> setOfAllUserIds = new Set<String>();
        Map<String,List<PayLoadMessage>> mapOfRecordAndItsMessage = new Map<String,List<PayloadMessage>>();
        try
        {
            System.debug(LoggingLevel.WARN, 'Start of SVMX_PushNotification::sendNotification():No of Queries used in this handler code so far: ' + Limits.getQueries());
            system.debug(LoggingLevel.WARN, 'newMapOfIdToSObjTrigger = ' + newMapOfIdToSObjTrigger);
            map<Id, SObject> newMapOfIdToSObj = new map<Id, SObject>();
            newMapOfIdToSObj = getObjectDefinition(newMapOfIdToSObjTrigger, strObjectName, mapEachSetting);
            system.debug(LoggingLevel.WARN, 'newMapOfIdToSObj = ' + newMapOfIdToSObj);
            DateTime dt;
            Integer intLimit = 0;
            Set<String> setNtfctnCnfgsName = new Set<String>();
            List<DateTime> lstCreatedDtOfNtfctn = new List<DateTime>();
            Map<String, Object> mapUserData = new Map<String, Object>();
            Map<String, String> mapNotificationToExpr = new Map<String, String>();
            List<SVMXC__SVMX_Job_Logs__c> lstUpsertPushLogs = new List<SVMXC__SVMX_Job_Logs__c>();
            List<SVMXC__SVMX_Job_Logs__c> lstSVMXPushNotfctnLogs = new List<SVMXC__SVMX_Job_Logs__c>();
            List<SVMXC__SVMX_Job_Logs__c> lstSNSPushNotfctnLogs = new List<SVMXC__SVMX_Job_Logs__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstNotificationConfigs = new List<SVMXC__ServiceMax_Config_Data__c>();
            Map<String, SVMXC__SVMX_Job_Logs__c> mapNotificationNameTorecord = new Map<String, SVMXC__SVMX_Job_Logs__c>();
            Map<String, SVMXC__SVMX_Job_Logs__c> mapSNSNotificationNameTorecord = new Map<String, SVMXC__SVMX_Job_Logs__c>();
            Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapRuleToExpr = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
            
            lstNotificationConfigs = [select Id, CreatedDate, SVMXC__Active__c, SVMXC__Profile_Name__c, SVMXC__Object_Name__c, SVMXC__Profile__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Advance_Expression__c, SVMXC__Parameter_Name__c, SVMXC__Parameter_Value__c, SVMXC__Internal_Value__c, SVMXC__Description__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND SVMXC__Display_Type__c = 'Push Notification' AND SVMXC__Object_Name__c = :strObjectName and SVMXC__Active__c = true AND (SVMXC__Display_Value__c = :strAlertType OR SVMXC__Display_Value__c = '3')];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
            for(SVMXC__ServiceMax_Config_Data__c eachNotificationId : lstNotificationConfigs)
            {
                lstCreatedDtOfNtfctn.add(eachNotificationId.CreatedDate);
                setNtfctnCnfgsName.add(eachNotificationId.SVMXC__Profile_Name__c);
                if(eachNotificationId.SVMXC__Dispatch_Process__c != null)
                {
                    mapNotificationToExpr.put(eachNotificationId.Id, eachNotificationId.SVMXC__Dispatch_Process__c);
                }
                else
                {
                    //to do 
                }
            }
            lstCreatedDtOfNtfctn.sort();
            if(lstCreatedDtOfNtfctn.size() > 0)
                dt = lstCreatedDtOfNtfctn[0];
            intLimit = lstNotificationConfigs.size();
            system.debug(LoggingLevel.WARN, 'intLimit = ' + intLimit + '; Minimum Date = ' + dt);
            
            lstExpressions = [select Id, SVMXC__Field_Name__c, SVMXC__Field_Relationship_Name__c, SVMXC__Display_Type__c, SVMXC__RecordType_Name__c, SVMXC__Expression_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Operand__c, SVMXC__Operator__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' AND SVMXC__Expression_Rule__c IN :mapNotificationToExpr.values()];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
            for(SVMXC__ServiceMax_Config_Data__c eachExpr : lstExpressions)
            {
                if(!mapRuleToExpr.containsKey(eachExpr.SVMXC__Expression_Rule__c))
                {
                    mapRuleToExpr.put(eachExpr.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>{eachExpr});
                }
                else
                {
                    mapRuleToExpr.get(eachExpr.SVMXC__Expression_Rule__c).add(eachExpr);
                }
            }
            
            lstSVMXPushNotfctnLogs= [SELECT Id, Name, LastModifiedDate, SVMXC__Apex_CPU_Time__c, SVMXC__Log_Category__c, SVMXC__Log_level__c, SVMXC__Call_Status__c, SVMXC__Event_Name__c, SVMXC__Log_Context__c, SVMXC__Message__c, SVMXC__Operation__c FROM SVMXC__SVMX_Job_Logs__c WHERE (SVMXC__Operation__c = 'PUSH NOTIFICATION' AND SVMXC__Event_Name__c IN :setNtfctnCnfgsName AND CreatedDate >= :dt AND (SVMXC__Log_Category__c = 'Salesforce' OR SVMXC__Log_Category__c = '')) Order By Id limit :intLimit];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__SVMX_Job_Logs__c eachPushLog : lstSVMXPushNotfctnLogs)
            {
                mapNotificationNameTorecord.put(eachPushLog.SVMXC__Event_Name__c, eachPushLog);
            }
            lstSNSPushNotfctnLogs= [SELECT Id, Name, LastModifiedDate, SVMXC__Apex_CPU_Time__c,SVMXC__Log_Category__c ,SVMXC__Log_level__c, SVMXC__Call_Status__c, SVMXC__Event_Name__c, SVMXC__Log_Context__c, SVMXC__Message__c, SVMXC__Operation__c FROM SVMXC__SVMX_Job_Logs__c WHERE (SVMXC__Operation__c = 'PUSH NOTIFICATION' AND SVMXC__Event_Name__c IN :setNtfctnCnfgsName AND CreatedDate >= :dt AND SVMXC__Log_Category__c = 'Servicemax') Order By Id limit :intLimit];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__SVMX_Job_Logs__c eachPushLog : lstSVMXPushNotfctnLogs)
            {
                mapSNSNotificationNameTorecord.put(eachPushLog.SVMXC__Event_Name__c, eachPushLog);
            }
            system.debug(LoggingLevel.WARN, 'mapRuleToExpr = ' + mapRuleToExpr);
            mapUserData.put('ACTION', '1');//1 - download, 0-not download
            mapUserData.put('ACTION_TAG', 'DOWNLOAD');
            
            for(Id eachId : newMapOfIdToSObj.keySet())
            {
                system.debug(LoggingLevel.WARN, 'eachId = ' + eachId + '; Value = ' + newMapOfIdToSObj.get(eachId));
                mapUserData.put('ID', eachId);
                mapUserData.put('OBJECT_NAME', String.valueOf(eachId.getSobjectType().getDescribe().getLabel()));
                for(SVMXC__ServiceMax_Config_Data__c eachNotfctn : lstNotificationConfigs)
                {
                    system.debug(LoggingLevel.WARN, 'eachNotfctn = ' + eachNotfctn);
                    Integer intCount = 0;
                    if(SVMX_ExpressionParsing(newMapOfIdToSObj.get(eachId), mapRuleToExpr.get(eachNotfctn.SVMXC__Dispatch_Process__c), eachNotfctn.SVMXC__Dispatch_Process__r.SVMXC__Advance_Expression__c))
                    {
                        system.debug(LoggingLevel.WARN, 'ID = ' + eachId + ' satisfies the configuration = ' + eachNotfctn.SVMXC__Profile_Name__c);
                        Set<String> setUserIds = new Set<String>();
                        String strSubject = '', strText = '', strOtherUsers = '', strAssignedUsers = '';
                        
                        strSubject = eachNotfctn.SVMXC__Internal_Value__c;
                        strText = eachNotfctn.SVMXC__Description__c;
                        strOtherUsers = eachNotfctn.SVMXC__Profile__c;
                        strAssignedUsers = eachNotfctn.SVMXC__Lookup_Field_API_Name__c;
                        mapUserData.put('TITLE', strSubject);
                        //mapUserData.put('STYLE', eachNotfctn.SVMXC__Parameter_Value__c);
                        if(eachNotfctn.SVMXC__Object_Name__c == 'SVMXC__Service_Order__c')
                            mapUserData.put('PRIORITY', newMapOfIdToSObj.get(eachId).get('SVMXC__Priority__c'));
                        
                        system.debug(LoggingLevel.WARN,'strText = ' + strText);
                        Map<String,Schema.SObjectField> mapfieldMap = eachId.getSObjectType().getDescribe().fields.getMap();
                        for(string fld: mapfieldMap.keyset())
                        {
                            String strEachFieldName = '';
                            Schema.DescribeFieldResult fldDescribe = mapfieldMap.get(fld).getDescribe();
                            strEachFieldName = fldDescribe.getName();
                            system.debug(LoggingLevel.WARN, 'Field Name =' + strEachFieldName + '; Reference to =' + fldDescribe.getReferenceTo() + '; Type = ' + fldDescribe.getType() + '; Relationship Name = ' + fldDescribe.getRelationshipName() + '; isNameField = ' + fldDescribe.isNameField());
                            String strFieldInText = '[$' + strEachFieldName + ']';
                            if(strText!= null && strText.contains(strFieldInText))
                            {
                                if(newMapOfIdToSObj.get(eachId).get(strEachFieldName) != null)
                                {
                                    if(fldDescribe.getType() == Schema.DisplayType.Reference)
                                    {
                                        List<Schema.sObjectType> lstReferenceFlds = fldDescribe.getReferenceTo();
                                        if(lstReferenceFlds != null && lstReferenceFlds.size() > 0)
                                        {
                                            if(String.valueOf(lstReferenceFlds[0]) == 'CASE')
                                                strText = strText.replace(strFieldInText, String.valueOf(newMapOfIdToSObj.get(eachId).getsObject(fldDescribe.getRelationshipName()).get('CaseNumber')));
                                            else
                                                strText = strText.replace(strFieldInText, String.valueOf(newMapOfIdToSObj.get(eachId).getsObject(fldDescribe.getRelationshipName()).get('Name')));
                                                //if(getReferenceNameField(lstReferenceFlds[0],fldDescribe.getRelationshipName()) != null)
                                                    //strText = strText.replace(strFieldInText, String.valueOf(newMapOfIdToSObj.get(eachId).get(getReferenceNameField(lstReferenceFlds[0],fldDescribe.getRelationshipName()))));
                                        }
                                    }
                                    else if(fldDescribe.getType() == Schema.DisplayType.DateTime)
                                    {
                                        strText = strText.replace(strFieldInText, 'GMT: '+String.valueOf(newMapOfIdToSObj.get(eachId).get(strEachFieldName)));
                                    }
                                    else
                                    {
                                        strText = strText.replace(strFieldInText, String.valueOf(newMapOfIdToSObj.get(eachId).get(strEachFieldName)));  
                                    }
                                }
                                else
                                    strText = strText.replace(strFieldInText, 'null');
                            }
                            Set<String> setAssignedUsers = new Set<String>();
                            setAssignedUsers.addAll(strAssignedUsers.split(','));
                            if(setAssignedUsers.contains(strEachFieldName) && newMapOfIdToSObj.get(eachId).get(strEachFieldName) != null)
                            {
                                if(String.valueOf(fldDescribe.getReferenceTo()[0]).toUpperCase() == 'USER' )
                                {
                                    if(!(String.valueOf(newMapOfIdToSObj.get(eachId).get(strEachFieldName)).equals(UserInfo.getUserId())))
                                        setUserIds.add(String.valueOf(newMapOfIdToSObj.get(eachId).get(strEachFieldName)));
                                }
                                else if(String.valueOf(fldDescribe.getReferenceTo()[0]) == 'SVMXC__Service_Group_Members__c')
                                {
                                    if(newMapOfIdToSObj.get(eachId).getsObject(fldDescribe.getRelationshipName()).get('SVMXC__Salesforce_User__c') != null && !(String.valueOf(newMapOfIdToSObj.get(eachId).getsObject(fldDescribe.getRelationshipName()).get('SVMXC__Salesforce_User__c')).equals(UserInfo.getUserId())))
                                        setUserIds.add(String.valueOf(newMapOfIdToSObj.get(eachId).getsObject(fldDescribe.getRelationshipName()).get('SVMXC__Salesforce_User__c')));
                                }
                                else
                                    setUserIds.add(String.valueOf(newMapOfIdToSObj.get(eachId).get(strEachFieldName)));
                                system.debug(LoggingLevel.WARN,'strAssignedUsers = ' + strAssignedUsers + ' contains ' + strEachFieldName + '; setUserIds = ' + setUserIds);
                            }
                        }
                        system.debug(LoggingLevel.WARN,'strText = ' + strText);
                        
                        system.debug(LoggingLevel.WARN, 'Email Limits used = ' + Limits.getEmailInvocations());
                        if(strOtherUsers != null && strOtherUsers != '' && Limits.getEmailInvocations() < Limits.getLimitEmailInvocations())
                        {
                            Messaging.SingleEmailMessage mailHandler = new Messaging.SingleEmailMessage();
                            mailHandler.setToAddresses(strOtherUsers.split(','));
                            mailHandler.setSubject(strSubject);
                            mailHandler.setHtmlBody(strText);
                            Messaging.sendEmail(new Messaging.Email[] {mailHandler}, false);
                        }
                        
                        system.debug(LoggingLevel.WARN, 'Push Limits used = ' + Limits.getMobilePushApexCalls());
                        setUserIds.remove(null);
                        if(setUserIds != null && setUserIds.size() > 0 && Limits.getMobilePushApexCalls() < Limits.getLimitMobilePushApexCalls())
                        {
                            Integer intPayloadSize = 256;
                            system.debug(LoggingLevel.WARN,'List of User Ids to which notification will be sent is = ' + setUserIds);
                            SVMXC__SVMX_Job_Logs__c logNotification = new SVMXC__SVMX_Job_Logs__c();
                            system.debug(LoggingLevel.WARN,'Setting MOBN001_SET004 = ' + mapEachSetting.get('MOBN001_SET004') + 'Setting MOBN001_SET005 = ' + mapEachSetting.get('MOBN001_SET005'));
                            if(mapEachSetting.containskey('MOBN001_SET004') && mapEachSetting.get('MOBN001_SET004') != null)
                                mapUserData.put('APP', mapEachSetting.get('MOBN001_SET004'));
                            else
                                mapUserData.put('APP', 'sum16'); //'sum15');
                                
                            String strCurrentTime = String.valueOfGMT(DateTime.now()) + ':' + DateTime.now().millisecondGmt();
                            system.debug(LoggingLevel.WARN,'strCurrentTime = ' + strCurrentTime);
                            mapUserData.put('DATE_TIME', strCurrentTime);
                            Messaging.PushNotification msg = new Messaging.PushNotification();
                            Map<String, Object> payload;
                            payload = Messaging.PushNotificationPayload.apple(strText, 'default', null, mapUserData);
                            
                            system.debug(LoggingLevel.WARN,'Payload = ' + payload + '; Size = ' + JSON.serialize(payload).length());
                            if(mapEachSetting.containskey('MOBN001_SET005') && mapEachSetting.get('MOBN001_SET005') != null)
                                intPayloadSize = Integer.valueOf(mapEachSetting.get('MOBN001_SET005'));
                            else
                                intPayloadSize = 2000;
                                
                            String strPayLoad = JSON.serialize(payload);
                            if(strPayLoad.length() >= intPayloadSize)
                            {
                                payload= null;
                                Integer intCharsToDel = strPayLoad.length() - intPayloadSize;
                                system.debug(LoggingLevel.WARN,'strText = ' + strText + '; Title = ' + mapUserData.get('TITLE') + '; intCharsToDel = ' + intCharsToDel);
                                if(strText != null && strText.length() > 0)
                                {
                                    Integer intTextLen = strText.length();
                                    if(intTextLen - intCharsToDel >= 0)
                                    {
                                        strText = strText.substring(0, intTextLen - intCharsToDel);
                                        intCharsToDel = 0;
                                    }
                                    else
                                    {
                                        strText = strText.substring(0, 0);
                                        intCharsToDel = intCharsToDel - intTextLen;
                                    }
                                }
                                system.debug(LoggingLevel.WARN,'strText = ' + strText + '; Title = ' + mapUserData.get('TITLE') + '; intCharsToDel = ' + intCharsToDel);
                                if(mapUserData.get('TITLE') != null && String.valueOf(mapUserData.get('TITLE')).length() > 0)
                                {
                                    String strSub = String.valueOf(mapUserData.get('TITLE'));
                                    if(strSub.length() - intCharsToDel >= 0)
                                    {
                                        strSub = strSub.substring(0, strSub.length() - intCharsToDel);
                                        mapUserData.put('TITLE', strSub);
                                    }
                                    else
                                    {
                                        strSub = strSub.substring(0, 0);
                                        mapUserData.put('TITLE', strSub);
                                    }
                                }
                                system.debug(LoggingLevel.WARN,'strText = ' + strText + '; Title = ' + mapUserData.get('TITLE') + '; intCharsToDel = ' + intCharsToDel);
                            }
                            if(strText == null || strText == '' || strText.length() <=0)
                                strText = ' ';
                            system.debug(LoggingLevel.WARN,'strText = ' + strText);
                            payload = Messaging.PushNotificationPayload.apple(strText, 'default', null, mapUserData);
                            Map<String, Object> aps =(Map<String,Object>) payload.get('aps');
                            aps.put('content-available','1');
                            payload.put('aps',aps);
                            msg.setPayload(payload);
                            
                            system.debug(LoggingLevel.WARN,'Payload = ' + payload + '; Size = ' + JSON.serialize(payload).length() + ' aps = ' + aps);
                            
                            if(eachNotfctn.SVMXC__Parameter_Name__c == 'Immediately')
                            {
                                system.debug(LoggingLevel.WARN,'Delivery Schedule = ' + eachNotfctn.SVMXC__Parameter_Name__c);
                                if(isSFDCPN)
                                {
                                    System.debug(LoggingLevel.WARN,'Push notification sent before'+msg);
                                    msg.send('ServiceMax_Mobile_for_APNS_Notifications', setUserIds);
                                    System.debug(LoggingLevel.WARN,'Push notification sent after'+msg);
                                    if(mapNotificationNameTorecord.containsKey(eachNotfctn.SVMXC__Profile_Name__c))
                                    {
                                        logNotification = mapNotificationNameTorecord.get(eachNotfctn.SVMXC__Profile_Name__c);
                                        if(logNotification.SVMXC__Apex_CPU_Time__c != null)
                                        {
                                            intCount = Integer.valueOf(logNotification.SVMXC__Apex_CPU_Time__c);
                                            system.debug(LoggingLevel.WARN,'logNotification.SVMXC__Apex_CPU_Time__c = ' + logNotification.SVMXC__Apex_CPU_Time__c);
                                        }
                                        system.debug(LoggingLevel.WARN,'logNotification.LastModifiedDate = ' + logNotification.LastModifiedDate + '; Date.TODAY() = ' + Date.TODAY());
                                        if(logNotification.LastModifiedDate < Date.TODAY())
                                        {
                                            logNotification.SVMXC__Log_level__c = 1;
                                        }
                                        else
                                            logNotification.SVMXC__Log_level__c = intCount + 1;
                                            
                                        logNotification.SVMXC__Apex_CPU_Time__c = intCount + 1;
                                        system.debug(LoggingLevel.WARN,'intCount = ' + intCount);
                                        system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);
                                    }
                                    else
                                    {
                                        logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
                                        logNotification.SVMXC__Log_level__c = 1;
                                        logNotification.SVMXC__Apex_CPU_Time__c = 1;
                                        logNotification.SVMXC__Message__c = strText;
                                        logNotification.SVMXC__Log_Category__c ='Salesforce';
                                        logNotification.SVMXC__Log_Context__c = strSubject;
                                        logNotification.SVMXC__Event_Name__c = eachNotfctn.SVMXC__Profile_Name__c;
                                        logNotification.SVMXC__Event_Type__c = eachNotfctn.SVMXC__Object_Name__c;
                                    }
                                    logNotification.SVMXC__Call_Status__c = 'SENT';
                                    lstUpsertPushLogs.add(logNotification);
                                    system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);                                    
                                }
                                else
                                {
                                    setOfAllUserIds.addAll(setUserIds);
                                    PayloadMessage newMessage = new PayloadMessage();
                                    List<PayloadMessage> listOfTempMessage = new List<PayloadMessage>();                                
                                    if(mapOfRecordAndItsMessage.containsKey(eachId+';'+eachNotfctn.SVMXC__Profile_Name__c))
                                    {
                                        listOfTempMessage = mapOfRecordAndItsMessage.get(eachId+';'+eachNotfctn.SVMXC__Profile_Name__c);
                                    }
                                    newMessage.message = new Map<String,Object>();
                                    System.debug('&&&&&'+payload);
                                    newMessage.message.putAll(payload);
                                    newMessage.setOfUserIds = new Set<String>();
                                    newMessage.setOfUserIds.addAll(setUserIds);
                                    listOfTempMessage.add(newMessage);
                                    mapOfRecordAndItsMessage.put(eachId+';'+eachNotfctn.SVMXC__Profile_Name__c,listOfTempMessage);
                                    if(mapSNSNotificationNameTorecord.containsKey(eachNotfctn.SVMXC__Profile_Name__c))
                                    {
                                        logNotification = mapSNSNotificationNameTorecord.get(eachNotfctn.SVMXC__Profile_Name__c);
                                        if(logNotification.SVMXC__Apex_CPU_Time__c != null)
                                        {
                                            intCount = Integer.valueOf(logNotification.SVMXC__Apex_CPU_Time__c);
                                            system.debug(LoggingLevel.WARN,'logNotification.SVMXC__Apex_CPU_Time__c = ' + logNotification.SVMXC__Apex_CPU_Time__c);
                                        }
                                        system.debug(LoggingLevel.WARN,'logNotification.LastModifiedDate = ' + logNotification.LastModifiedDate + '; Date.TODAY() = ' + Date.TODAY());
                                        if(logNotification.LastModifiedDate < Date.TODAY())
                                        {
                                            logNotification.SVMXC__Log_level__c = 1;
                                        }
                                        else
                                            logNotification.SVMXC__Log_level__c = intCount + 1;
                                            
                                        logNotification.SVMXC__Apex_CPU_Time__c = intCount + 1;
                                        system.debug(LoggingLevel.WARN,'intCount = ' + intCount);
                                        system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);
                                    }
                                    else
                                    {
                                        logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
                                        logNotification.SVMXC__Log_level__c = 1;
                                        logNotification.SVMXC__Apex_CPU_Time__c = 1;
                                        logNotification.SVMXC__Message__c = strText;
                                        logNotification.SVMXC__Log_Category__c ='Servicemax';                                        
                                        logNotification.SVMXC__Log_Context__c = strSubject;
                                        logNotification.SVMXC__Event_Name__c = eachNotfctn.SVMXC__Profile_Name__c;
                                        logNotification.SVMXC__Event_Type__c = eachNotfctn.SVMXC__Object_Name__c;
                                    }
                                    logNotification.SVMXC__Call_Status__c = 'SENT';
                                    lstUpsertPushLogs.add(logNotification);
                                    system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);                                                                        
                                    /**** Code modified to implement aws sns service - code end***/                                
                                }
                            }
                            else if(eachNotfctn.SVMXC__Parameter_Name__c == 'Business Hours')
                            {
                                system.debug(LoggingLevel.WARN,'Delivery Schedule = ' + eachNotfctn.SVMXC__Parameter_Name__c);
                                List<User> lstUsers = new List<User>();
                                List<BusinessHours> lstBusinessHrs = new List<BusinessHours>();
                                map<String, String> mapGrpProfileToSetting = new map<String, String>();
                                map<String, String> mapBusinessHrsNameToId = new map<String, String>();
                                map<String, String> mapUserIdToSFDCProfile = new map<String, String>();
                                map<String, String> mapSFProfileToGrpProfile = new map<String, String>();
                                map<Id, BusinessHours> mapIdToBusinessHrs = new map<Id, BusinessHours>();
                                List<SVMXC__ServiceMax_Config_Data__c> lstBussHrSettings = new List<SVMXC__ServiceMax_Config_Data__c>();
                                List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                                
                                lstBusinessHrs= [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                for(BusinessHours eachBussHr : lstBusinessHrs)
                                {
                                    mapBusinessHrsNameToId.put(eachBussHr.Name, eachBussHr.Id);
                                }
                                lstUsers = [SELECT Id, FirstName, IsActive, LastName, ProfileId FROM User WHERE IsActive = true and ID IN:setUserIds];
                                for(User eachUser : lstUsers)
                                {
                                    mapUserIdToSFDCProfile.put(eachUser.Id, eachUser.ProfileId);
                                }
                                
                                profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c, SVMXC__Profile__c FROM SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Access' AND SVMXC__Profile__c IN :mapUserIdToSFDCProfile.values() AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = True];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                for(SVMXC__ServiceMax_Config_Data__c eachGrpProfile : profileAccessLst)
                                {
                                    mapSFProfileToGrpProfile.put(eachGrpProfile.SVMXC__Profile__c, eachGrpProfile.SVMXC__Access_Configuration_Profile__c);
                                }   
                            
                                lstBussHrSettings = [select SVMXC__Setting_Unique_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Setting Value' AND (SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c IN ('MOBN001_SET006')) AND (SVMXC__Setting_Configuration_Profile__c IN :mapSFProfileToGrpProfile.values() OR SVMXC__Setting_ID__r.SVMXC__Search_Order__c = 'Global') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                for(SVMXC__ServiceMax_Config_Data__c eachGrpSetting : lstBussHrSettings)
                                {
                                    mapGrpProfileToSetting.put(eachGrpSetting.SVMXC__Setting_Configuration_Profile__c, eachGrpSetting.SVMXC__Internal_Value__c);
                                }
                                DateTime dtCurrentTime = DateTime.now();
                                
                                for(String eachUser : setUserIds)
                                {
                                    Set<String> setUsers = new Set<String>();
                                    String strGrpProfile = mapSFProfileToGrpProfile.get(mapUserIdToSFDCProfile.get(eachUser));//this will give the Group Profile of the User.
                                    String strBussHrSettingForGrpPrfl = mapBusinessHrsNameToId.get(mapGrpProfileToSetting.get(strGrpProfile));
                                    system.debug(LoggingLevel.WARN,'strBussHrSettingForGrpPrfl = ' + strBussHrSettingForGrpPrfl + '; Each User = ' + eachUser);
                                    //if(Test.isRunningTest() || strBussHrSettingForGrpPrfl != null)
                                    if(strBussHrSettingForGrpPrfl != null)
                                    {
                                        //if(Test.isRunningTest() || BusinessHours.isWithin(strBussHrSettingForGrpPrfl, dtCurrentTime))
                                        if(BusinessHours.isWithin(strBussHrSettingForGrpPrfl, dtCurrentTime))
                                        {
                                            if(isSFDCPN)
                                            {                                            
                                                setUsers.add(eachUser);
                                                system.debug(LoggingLevel.WARN,'Within Business Hour' + '; Set of Users = ' + setUsers);                                                
                                                msg.send('ServiceMax_Mobile_for_APNS_Notifications', setUsers);
                                                if(mapNotificationNameTorecord.containsKey(eachNotfctn.SVMXC__Profile_Name__c))
                                                {
                                                    logNotification = mapNotificationNameTorecord.get(eachNotfctn.SVMXC__Profile_Name__c);
                                                    if(logNotification.SVMXC__Apex_CPU_Time__c != null)
                                                    {
                                                        intCount = Integer.valueOf(logNotification.SVMXC__Apex_CPU_Time__c);
                                                        system.debug(LoggingLevel.WARN,'logNotification.SVMXC__Apex_CPU_Time__c = ' + logNotification.SVMXC__Apex_CPU_Time__c);
                                                    }
                                                    system.debug(LoggingLevel.WARN,'logNotification.LastModifiedDate = ' + logNotification.LastModifiedDate + '; Date.TODAY() = ' + Date.TODAY());
                                                    if(logNotification.LastModifiedDate < Date.TODAY())
                                                    {
                                                        logNotification.SVMXC__Log_level__c = 1;
                                                    }
                                                    else
                                                        logNotification.SVMXC__Log_level__c = intCount + 1;
                                                        
                                                    logNotification.SVMXC__Apex_CPU_Time__c = intCount + 1;
                                                    system.debug(LoggingLevel.WARN,'intCount = ' + intCount);
                                                    system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);
                                                }
                                                else
                                                {
                                                    logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
                                                    logNotification.SVMXC__Group_Id__c = eachUser;
                                                    logNotification.SVMXC__Message__c = strText;
                                                    logNotification.SVMXC__Log_Context__c = strSubject;
                                                    logNotification.SVMXC__Log_Category__c ='Salesforce';                                                                                            
                                                    logNotification.SVMXC__Event_Name__c = eachNotfctn.SVMXC__Profile_Name__c;
                                                    logNotification.SVMXC__Event_Type__c = eachNotfctn.SVMXC__Object_Name__c;
                                                    logNotification.SVMXC__Log_level__c = intCount++;
                                                    logNotification.SVMXC__Apex_CPU_Time__c = 1;
                                                }
                                                logNotification.SVMXC__Call_Status__c = 'SENT';                                                
                                            }
                                            else
                                            {

                                                setOfAllUserIds.addAll(setUserIds);
                                                PayloadMessage newMessage = new PayloadMessage();
                                                List<PayloadMessage> listOfTempMessages = new List<PayloadMessage>();                                
                                                if(mapOfRecordAndItsMessage.containsKey(eachId+';'+eachNotfctn.SVMXC__Profile_Name__c))
                                                {
                                                    listOfTempMessages = mapOfRecordAndItsMessage.get(eachId+';'+eachNotfctn.SVMXC__Profile_Name__c);
                                                }
                                                newMessage.message = new Map<String,Object>();
                                                newMessage.message.putAll(payload);
                                                newMessage.setOfUserIds = new Set<String>();
                                                newMessage.setOfUserIds.add(eachUser);
                                                listOfTempMessages.add(newMessage);
                                                mapOfRecordAndItsMessage.put(eachId+';'+eachNotfctn.SVMXC__Profile_Name__c,listOfTempMessages);  
                                                if(mapSNSNotificationNameTorecord.containsKey(eachNotfctn.SVMXC__Profile_Name__c))
                                                {
                                                    logNotification = mapSNSNotificationNameTorecord.get(eachNotfctn.SVMXC__Profile_Name__c);
                                                    if(logNotification.SVMXC__Apex_CPU_Time__c != null)
                                                    {
                                                        intCount = Integer.valueOf(logNotification.SVMXC__Apex_CPU_Time__c);
                                                        system.debug(LoggingLevel.WARN,'logNotification.SVMXC__Apex_CPU_Time__c = ' + logNotification.SVMXC__Apex_CPU_Time__c);
                                                    }
                                                    system.debug(LoggingLevel.WARN,'logNotification.LastModifiedDate = ' + logNotification.LastModifiedDate + '; Date.TODAY() = ' + Date.TODAY());
                                                    if(logNotification.LastModifiedDate < Date.TODAY())
                                                    {
                                                        logNotification.SVMXC__Log_level__c = 1;
                                                    }
                                                    else
                                                        logNotification.SVMXC__Log_level__c = intCount + 1;
                                                        
                                                    logNotification.SVMXC__Apex_CPU_Time__c = intCount + 1;
                                                    system.debug(LoggingLevel.WARN,'intCount = ' + intCount);
                                                    system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);
                                                }
                                                else
                                                {
                                                    logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
                                                    logNotification.SVMXC__Group_Id__c = eachUser;
                                                    logNotification.SVMXC__Message__c = strText;
                                                    logNotification.SVMXC__Log_Context__c = strSubject;
                                                    logNotification.SVMXC__Log_Category__c ='Servicemax';                                                                                            
                                                    logNotification.SVMXC__Event_Name__c = eachNotfctn.SVMXC__Profile_Name__c;
                                                    logNotification.SVMXC__Event_Type__c = eachNotfctn.SVMXC__Object_Name__c;
                                                    logNotification.SVMXC__Log_level__c = intCount++;
                                                    logNotification.SVMXC__Apex_CPU_Time__c = 1;
                                                }
                                                logNotification.SVMXC__Call_Status__c = 'SENT'; 
                                                system.debug(LoggingLevel.WARN,'logNotification = ' + logNotification);                                                                                    
                                            }
                                        }
                                    }
                                    else
                                    {
                                        String strUser = '';
                                        system.debug(LoggingLevel.WARN,'Not in Business Hour');
                                        if(isSFDCPN)
                                        {
                                            if(mapNotificationNameTorecord.containsKey(eachNotfctn.SVMXC__Profile_Name__c))
                                            {
                                                logNotification = mapNotificationNameTorecord.get(eachNotfctn.SVMXC__Profile_Name__c);
                                                if(logNotification.SVMXC__Log_level__c != null)
                                                    intCount += Integer.valueOf(logNotification.SVMXC__Log_level__c);
                                                logNotification.SVMXC__Log_level__c = intCount + 1;
                                                logNotification.SVMXC__Call_Status__c = 'NOT_SENT';
                                                if(logNotification.SVMXC__Group_Id__c != null)
                                                    strUser = logNotification.SVMXC__Group_Id__c + ','; 
                                                logNotification.SVMXC__Group_Id__c = strUser + eachUser;
                                            }
                                            else
                                            {
                                                logNotification.SVMXC__Call_Status__c = 'NOT_SENT';
                                                logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
                                                logNotification.SVMXC__Group_Id__c = eachUser;
                                                logNotification.SVMXC__Message__c = strText;
                                                logNotification.SVMXC__Log_Category__c ='Salesforce';                                                                                        
                                                logNotification.SVMXC__Log_Context__c = strSubject;
                                                logNotification.SVMXC__Event_Name__c = eachNotfctn.SVMXC__Profile_Name__c;
                                                logNotification.SVMXC__Event_Type__c = eachNotfctn.SVMXC__Object_Name__c;
                                            }                                                
                                        }
                                        else
                                        {
                                            if(mapSNSNotificationNameTorecord.containsKey(eachNotfctn.SVMXC__Profile_Name__c))
                                            {
                                                logNotification = mapSNSNotificationNameTorecord.get(eachNotfctn.SVMXC__Profile_Name__c);
                                                if(logNotification.SVMXC__Log_level__c != null)
                                                    intCount += Integer.valueOf(logNotification.SVMXC__Log_level__c);
                                                logNotification.SVMXC__Log_level__c = intCount + 1;
                                                logNotification.SVMXC__Call_Status__c = 'NOT_SENT';
                                                if(logNotification.SVMXC__Group_Id__c != null)
                                                    strUser = logNotification.SVMXC__Group_Id__c + ','; 
                                                logNotification.SVMXC__Group_Id__c = strUser + eachUser;
                                            }
                                            else
                                            {
                                                logNotification.SVMXC__Call_Status__c = 'NOT_SENT';
                                                logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
                                                logNotification.SVMXC__Group_Id__c = eachUser;
                                                logNotification.SVMXC__Message__c = JSON.serialize(payload);
                                                logNotification.SVMXC__Log_Category__c ='Servicemax';                                                                                        
                                                logNotification.SVMXC__Log_Context__c = strSubject;
                                                logNotification.SVMXC__Event_Name__c = eachNotfctn.SVMXC__Profile_Name__c;
                                                logNotification.SVMXC__Event_Type__c = eachNotfctn.SVMXC__Object_Name__c;
                                            }
                                        }
                                    }
                                }
                                lstUpsertPushLogs.add(logNotification);
                            }
                        }
                        else
                        { 
                            system.debug(LoggingLevel.WARN,'Reached the maximum number of push notification method calls allowed per Apex transaction = ' + Limits.getMobilePushApexCalls());
                            system.debug(LoggingLevel.WARN,' No Users to send Notification = ' + setUserIds);
                        }
                    }
                }
            }
            system.debug(LoggingLevel.WARN,'lstUpsertPushLogs = ' + lstUpsertPushLogs);
            upsert(lstUpsertPushLogs);   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug('End of SVMX_PushNotification::sendNotification():No of Queries used in this handler code so far: ' + Limits.getQueries());
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            system.debug(LoggingLevel.WARN,'Exception = ' + customException.getDetailedErrorMsg());
        }
        
        List<MicroService> listOfServices = new List<MicroService>();
        if(!isSFDCPN)            
        {
            Map<Id,List<SVMXC__SM_SNS_Detail__c>> mapOfUserAndItsDetails = new Map<Id,List<SVMXC__SM_SNS_Detail__c>>();                        
            for(SVMXC__SM_SNS_Detail__c newDetails:[Select Id,Name, SVMXC__SM_User__c,SVMXC__SM_TargetArn__c From SVMXC__SM_SNS_Detail__c Where SVMXC__SM_User__c in:setOfAllUserIds and SVMXC__SM_Status__c='Registered' and SVMXC__SM_IsActive__c=true])
            {            
                //mapOfUserIdAndItsDetails.put(newDetails.SVMXC__SM_User__c,newDetails);
                List<SVMXC__SM_SNS_Detail__c>listOfTempDetails = new List<SVMXC__SM_SNS_Detail__c>();
                if(mapOfUserAndItsDetails.containsKey(newDetails.SVMXC__SM_User__c))
                {
                    listOfTempDetails = mapOfUserAndItsDetails.get(newDetails.SVMXC__SM_User__c);
                }
                listOfTempDetails.add(newDetails);
                mapOfUserAndItsDetails.put(newDetails.SVMXC__SM_User__c,listOfTempDetails);                
            }
            System.debug(LoggingLevel.WARN,' MapOfSNSDetails = ' + mapOfUserAndItsDetails);            
            System.debug(LoggingLevel.WARN,' mapOfRecordAndItsMessage = ' + mapOfRecordAndItsMessage);              
            for(String recordId:mapOfRecordAndItsMessage.keyset())
            {
                for(PayloadMessage newMessage:mapOfRecordAndItsMessage.get(recordId))
                {
                    for(String newUserId:newMessage.setOfUserIds)
                    {
                        if(mapOfUserAndItsDetails.containsKey(newUserId))
                        {
                            for(SVMXC__SM_SNS_Detail__c newDetails:mapOfUserAndItsDetails.get(newUserId))
                            {
                                Map<String,String> mapOfPayloadCore = new Map<String,String>();
                                String jsonMessaged = JSON.serialize(newMessage.message);                                    
                                MicroService newServices = new MicroService();
                                newServices.message = jsonMessaged;
                                newServices.arnList = new List<String>();
                                newServices.arnList.add(newDetails.SVMXC__SM_TargetArn__c);
                                listOfServices.add(newServices);
                            }
                        }    
                    }
                } 
                if(!listOfServices.isEmpty())
                {
                    String microServiceBody = JSON.serialize(listOfServices);
                    System.debug(LoggingLevel.WARN,' Final Payload'+microServiceBody);  
                    SNSCallout.callingOut(microServiceBody);
                }                                      
                System.debug(LoggingLevel.WARN,' After Calling Out ');                                      
            }
        }
    }
    
    public class PayloadMessage
    {
        public Map<String,Object> message;
        public Set<String> setOfUserIds;
    }
    
    public class MicroService
    {
        public String message;
        public List<String> arnList;
    }
    public map<Id, SObject> getObjectDefinition(map<Id, SObject> newMapOfIdToSObjTrigger, String strObjectName, map<String, String> mapEachSetting)
    {
        Set<Id> lstIds = new Set<Id>();
        Integer intLimitRelationshipFields = 40;
        set<String> setRefObjToSkip = new set<String>();
        INTF_GetObjectDefinition objectDefinition = new INTF_GetObjectDefinition();
        objectDefinition.objectName = strObjectName;
        List<String> lstFieldsName = new List<String>();
        map<Id, SObject> newMapOfIdToSObj = new map<Id, SObject>();
        INTF_WebServicesDef.SVMXMap objDef = objectDefinition.INTF_GetObjectDefinition();
        if(mapEachSetting.containskey('IPAD018_SET004') && mapEachSetting.get('IPAD018_SET004') != null)
        {
            system.debug(LoggingLevel.WARN, 'mapEachSetting.get IPAD018_SET004 = ' + mapEachSetting.get('IPAD018_SET004'));
            for(String strEachValue : mapEachSetting.get('IPAD018_SET004').split(','))
            {
                setRefObjToSkip.add(strEachValue.toUpperCase());
            }
            system.debug(LoggingLevel.WARN, 'setRefObjToSkip = ' + setRefObjToSkip);
        }
        else
        {
            setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
            setRefObjToSkip.add('USER');
            setRefObjToSkip.add('FEEDPOST');
            setRefObjToSkip.add('SOLUTION');
        }
        setRefObjToSkip.remove('USER');
        system.debug(LoggingLevel.WARN, 'setRefObjToSkip = ' + setRefObjToSkip);
        if(mapEachSetting.containskey('IPAD018_SET013') && mapEachSetting.get('IPAD018_SET013') != null)
            intLimitRelationshipFields = integer.valueOf(mapEachSetting.get('IPAD018_SET013'));
        else
            intLimitRelationshipFields = 40;
        if(objDef != NULL) 
        {
            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
            {
                if(objProp.key=='FIELDPROPERTY')
                {
                    Integer refFieldCount = 0;
                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                    {
                        system.debug(LoggingLevel.WARN, 'lstField.value = ' + lstField.value);
                        //lstFieldsName.add(lstField.value);
                        if(refFieldCount == intLimitRelationshipFields)
                            continue;
                        String strReferenceTo = (new INTF_DataUtilityServices()).GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                        if(strReferenceTo != null)
                        {
                            String strRelationshipName = (new INTF_DataUtilityServices()).GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                            if(strRelationshipName != null)
                            {
                                system.debug(LoggingLevel.WARN, 'strReferenceTo = ' + strReferenceTo);
                                if(strReferenceTo == 'Case')
                                {
                                    lstFieldsName.add(strRelationshipName + '.CaseNumber');
                                    refFieldCount++;
                                }
                                else if(strReferenceTo == 'SVMXC__Service_Group_Members__c')
                                {
                                    lstFieldsName.add(strRelationshipName + '.SVMXC__Salesforce_User__c');
                                    lstFieldsName.add(strRelationshipName + '.Name');
                                    refFieldCount++;
                                }
                                else if(setRefObjToSkip.contains(strReferenceTo.toUpperCase()))
                                    continue;
                                else
                                {
                                    lstFieldsName.add(strRelationshipName + '.Name');
                                    refFieldCount++;
                                }
                            }
                        }
                    }
                }
            }
        }
        lstIds = newMapOfIdToSObjTrigger.keySet();
        lstFieldsName = (new COMM_Utils_V2()).checkDuplicateFields(lstFieldsName, strObjectName); //Remove duplicate API Fields
        String strFldNames =  objectDefinition.getObjectFieldNames(lstFieldsName);
        String strQry = 'Select ' + strFldNames + ' FROM '+ strObjectName + ' WHERE Id IN :lstIds';
        system.debug(LoggingLevel.WARN, 'strQry = ' + strQry);
        newMapOfIdToSObj.putAll(Database.query('Select ' + strFldNames + ' FROM '+ strObjectName + ' WHERE Id IN :lstIds'));
        //return newMapOfIdToSObj;
        
        map<Id, SObject> mapOfIdToSObjResult = getMergeSobjectResult(newMapOfIdToSObjTrigger, newMapOfIdToSObj, strObjectName);
        return mapOfIdToSObjResult;
    }
    
    public map<Id, SObject> getMergeSobjectResult(map<Id, SObject> newMapOfIdToSObjTrigger, map<Id, SObject> newMapOfIdToSObj, String objectName){
            map<Id, SObject> mapOfIdToSObjResult = new Map<Id, SObject>();
            for(Id recId : newMapOfIdToSObjTrigger.keySet()){
                Map<String,Object> mapFieldAndValueOfRecord1 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(newMapOfIdToSObjTrigger.get(recId)));
                if(newMapOfIdToSObj.containsKey(recID) && newMapOfIdToSObj.get(recID) != NULL){
                    Map<String,Object> mapFieldAndValueOfRecord2 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(newMapOfIdToSObj.get(recID)));
                    for(String strKey: mapFieldAndValueOfRecord2.keySet()){
                        mapFieldAndValueOfRecord1.put(strKey,mapFieldAndValueOfRecord2.get(strKey) );
                    }
                }
                type stype= type.forName(objectName);
                Sobject resultSobject = (Sobject)JSON.deserialize(JSON.serialize(mapFieldAndValueOfRecord1), stype);
                mapOfIdToSObjResult.put(resultSobject.Id, resultSobject);
            }
            return mapOfIdToSObjResult;
    }
    
    /*public String getReferenceNameField(Schema.Sobjecttype sobjRefObject, String relname)
    {
        String nameField = null;
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        system.debug(LoggingLevel.WARN, 'sobjRefObject = ' + sobjRefObject + '; Relationship Name = ' + relname);
        FieldMap = sobjRefObject.getDescribe().fields.getMap();
        for(String s :FieldMap.keyset())
        {
            Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
            if(fieldDesc.isNameField())
            {
                nameField = fieldDesc.getName();
                break;
            }
        }
        system.debug(LoggingLevel.WARN, 'nameField = ' + nameField);
        if(nameField != null)
            return relname+'.'+nameField;
        else 
            return null;    
    }*/
    
    public Boolean SVMX_ExpressionParsing(SObject Rec, list<SVMXC__ServiceMax_Config_Data__c> lstExpressions, string AdvExp)
    {
        if(lstExpressions == null || lstExpressions.size() == 0)
            return true;
        Map<Double,string> mapResult = new Map<Double,string>(); 
        string ExpVal;
        integer ExpKey;
        lstExpressions = sortingExpressionList(lstExpressions);
        for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
        {
            mapResult.put(oExpression.SVMXC__Sequence__c,'F');
            string FieldType = oExpression.SVMXC__Display_Type__c ;
            
            if(FieldType != null && FieldType.length() > 0 && oExpression.SVMXC__Operator__c != null && oExpression.SVMXC__Operator__c.length() > 0)
            {
                string strOperater = oExpression.SVMXC__Operator__c.ToUpperCase();
                
                string strFieldType = FieldType.ToUpperCase();
                if(strFieldType == 'STRING' || strFieldType == 'COMBOBOX' || strFieldType == 'PICKLIST' || strFieldType == 'PHONE' || strFieldType == 'URL' || strFieldType == 'TEXTAREA')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');                  
                    }
                    string Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        if(Val == oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'STARTS' )
                    {
                        if(Val != null)
                        {
                            if(Val.startsWith(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'CONTAINS')
                    {
                        if(Val != null)
                        {
                            if(Val.contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'NOTCONTAINS' || strOperater == 'NOTCONTAIN')
                    {
                        if(Val != null)
                        {
                            if(!Val.contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<string> setValues = new set<string>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(str);
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'BOOLEAN')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    string Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = string.valueOf(Rec.get(oExpression.SVMXC__Field_Name__c));
                    if(strOperater == 'EQ')
                    {
                        if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)Rec.get(oExpression.SVMXC__Field_Name__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)Rec.get(oExpression.SVMXC__Field_Name__c)))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if('TRUE' == oExpression.SVMXC__Operand__c.ToUpperCase() && !((boolean)Rec.get(oExpression.SVMXC__Field_Name__c)))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if('FALSE' == oExpression.SVMXC__Operand__c.ToUpperCase() && (boolean)Rec.get(oExpression.SVMXC__Field_Name__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'INTEGER')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Integer Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = ((Decimal)Rec.get(oExpression.SVMXC__Field_Name__c)).IntValue();
                    if(strOperater == 'EQ')
                    {
                        if(Val == Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= Integer.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<Integer> setValues = new set<Integer>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(integer.valueOf(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'CURRENCY' || strFieldType == 'DECIMAL')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DECIMAL Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = Decimal.valueOf(((Double)Rec.get(oExpression.SVMXC__Field_Name__c)));
                    if(strOperater == 'EQ')
                    {
                        if(Val == DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= DECIMAL.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<DECIMAL> setValues = new set<DECIMAL>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(DECIMAL.valueOf(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'DOUBLE')
                {
                    
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DOUBLE Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (DOUBLE)Rec.get(oExpression.SVMXC__Field_Name__c);
                    if(strOperater == 'EQ')
                    {
                        if(Val == DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= DOUBLE.valueOf(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<DOUBLE> setValues = new set<DOUBLE>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(DOUBLE.valueOf(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'ID' || strFieldType == 'REFERENCE')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    String Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null && Rec.getsObject(oExpression.SVMXC__Field_Relationship_Name__c).get(oExpression.SVMXC__FKey_Name_Field__c) != null)
                        val = string.valueOf(Rec.getsObject(oExpression.SVMXC__Field_Relationship_Name__c).get(oExpression.SVMXC__FKey_Name_Field__c));
                    system.debug(LoggingLevel.WARN, 'val = ' + val + '; oExpression.SVMXC__Operand__c = ' + oExpression.SVMXC__Operand__c);       
                    if(strOperater == 'EQ')
                    {
                        if(Val == oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != oExpression.SVMXC__Operand__c)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'CONTAINS')
                    {
                        if(Val != null)
                        {
                            if(Val.contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'NOTCONTAINS' || strOperater == 'NOTCONTAIN')
                    {
                        if(Val != null)
                        {
                            if(!Val.contains(oExpression.SVMXC__Operand__c))
                                mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        }
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<string> setValues = new set<string>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add((Id)str);
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c, 'T');
                    }
                }
                else if(strFieldType == 'DATE')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    Date Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (date)Rec.get(oExpression.SVMXC__Field_Name__c);
                    if(strOperater == 'EQ')
                    {
                        if(Val == getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val != getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= getDate(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<Date> setValues = new set<Date>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add(getDate(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
                else if(strFieldType == 'DATETIME')
                {
                    if(strOperater == 'ISNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) == null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NOTNULL' || strOperater == 'ISNOTNULL')
                    {
                        if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    DateTime Val;
                    if(Rec.get(oExpression.SVMXC__Field_Name__c) != null)
                        val = (DateTime)Rec.get(oExpression.SVMXC__Field_Name__c);
                    system.debug(LoggingLevel.WARN, 'Field val = ' + val + '; Operand val = ' + getDateTimeStart(oExpression.SVMXC__Operand__c) + '; ' + getDateTimeEnd(oExpression.SVMXC__Operand__c));
                    if(strOperater == 'EQ')
                    {
                        if(Val >= getDateTimeStart(oExpression.SVMXC__Operand__c) && Val <= getDateTimeEnd(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'NE')
                    {
                        if(Val < getDateTimeStart(oExpression.SVMXC__Operand__c) || Val > getDateTimeEnd(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LT')
                    {
                        if(Val < getDateTimeStart(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GT')
                    {
                        if(Val > getDateTimeEnd(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'LE')
                    {
                        if(Val <= getDateTimeStart(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'GE')
                    {
                        if(Val >= getDateTimeEnd(oExpression.SVMXC__Operand__c))
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                    else if(strOperater == 'IN' || strOperater == 'NOTIN')
                    {
                        String[] multValues = oExpression.SVMXC__Operand__c.split(',');
                        set<object> setValues = new set<object>();
                        if(multValues != null)
                        {
                            for(string str: multValues)
                            {
                                setValues.add((object)getDateTimeStart(str));
                            }
                        }
                        if(setValues.contains(Val) && strOperater == 'IN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                        if(!setValues.contains(Val) && strOperater == 'NOTIN')
                            mapResult.put(oExpression.SVMXC__Sequence__c,'T');
                    }
                }
            }
        }
        if(!isValidString(AdvExp))
        {
            set<string> setTemp = new set<string>();
            setTemp.addAll(mapResult.values());
            if(setTemp.size() == 0 || setTemp.Contains('F'))
                return false;
            else
                return true;
        }
        AdvExp = AdvExp.ToUpperCase();
        AdvExp = AdvExp.replaceAll('AND', ' && ');
        AdvExp = AdvExp.replaceAll('OR', ' || ');
        AdvExp = AdvExp.replaceAll('NOT', ' ! ');
        AdvExp = ' ' + AdvExp + ' ';
        for(integer k = 0; k < lstExpressions.size(); k++)
        {
            AdvExp = AdvExp.replace(string.valueOf(k+1),' ~' + string.valueOf(k+1) + '~ ');
        }
        for(integer k=0;k<lstExpressions.size();k++)
        {
            if(mapResult.containsKey(lstExpressions[k].SVMXC__Sequence__c) && lstExpressions[k].SVMXC__Sequence__c != null)
                AdvExp = AdvExp.replace('~' + string.valueOf(lstExpressions[k].SVMXC__Sequence__c.intValue()) + '~', mapResult.get(lstExpressions[k].SVMXC__Sequence__c));               
        }
        AdvExp = AdvExp.replaceAll(' ','');  
        String Temp = '';
        do
        {
            Temp = AdvExp;
            AdvExp  = AdvExp.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
        }
        while(Temp != AdvExp);
        if(AdvExp=='T')
            return true;
        else
            return false;
    }
    
    public boolean isValidString(string str)
    {
        if(str != null && str.length() > 0)
            return true;
        return false;
    }
        
    private Date getDate(String str)
    {
        try
        {
            if(str != null && (str.toUpperCase() == 'TODAY' || str.toUpperCase() == 'SVMX.NOW'))
                return Date.today();
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Date.today().addDays(1);
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Date.today().addDays(-1);
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1]) );
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1]) );
            else 
                return Date.parse(str);
        }
        catch(exception ex)
        {
            SmaxException customException = new SmaxException(null, ex);
            system.debug(LoggingLevel.WARN,'Exception = ' + customException.getDetailedErrorMsg());
            return null;
        }
    }
    private DateTime getDateTimeStart(String str)
    {
        try
        {
            if(str != null && str.toUpperCase() == 'SVMX.NOW')
                return DateTime.now();
            else if(str != null && str.toUpperCase() == 'TODAY' )
                return Datetime.newInstanceGMT(Date.today(), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Datetime.newInstanceGMT(Date.today().addDays(1), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Datetime.newInstanceGMT(Date.today().addDays(-1), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Datetime.newInstanceGMT(Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Datetime.newInstanceGMT(Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(0, 0, 0, 0));
            else
                return Datetime.parse(str.replace('/','-'));
        }
        catch(exception ex)
        {
            SmaxException customException = new SmaxException(null, ex);
            system.debug(LoggingLevel.WARN,'Exception = ' + customException.getDetailedErrorMsg());
            return null;
        }
    }
    
    private DateTime getDateTimeEnd(String str)
    {
        try
        {
            if(str != null && str.toUpperCase() == 'SVMX.NOW')
                return DateTime.now();
            else if(str != null && str.toUpperCase() == 'TODAY' )
                return Datetime.newInstanceGMT(Date.today(), time.newInstance(23, 59, 59, 999));
            else if(str != null && str.toUpperCase() == 'TOMORROW')
                return Datetime.newInstanceGMT(Date.today().addDays(1), time.newInstance(23, 59, 59, 999));
            else if(str != null && str.toUpperCase() == 'YESTERDAY')
                return Datetime.newInstanceGMT(Date.today().addDays(-1), time.newInstance(23, 59, 59, 999));
            else if(str != null && str.toUpperCase().contains('NEXT_N_DAYS:'))
                return Datetime.newInstanceGMT(Date.today().addDays(Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(23, 59, 59, 999));
            else if(str != null && str.toUpperCase().contains('LAST_N_DAYS:'))
                return Datetime.newInstanceGMT(Date.today().addDays(-1 * Integer.ValueOf(str.toUpperCase().split(':')[1])), time.newInstance(23, 59, 59, 999));
            else
                return Datetime.parse(str.replace('/','-'));
        }
        catch(exception ex)
        {
            SmaxException customException = new SmaxException(null, ex);
            system.debug(LoggingLevel.WARN,'Exception = ' + customException.getDetailedErrorMsg());
            return null;
        }
    }
    
    private List<SVMXC__ServiceMax_Config_Data__c> sortingExpressionList(List<SVMXC__ServiceMax_Config_Data__c> lstexp)
    {
        list<Integer> lstTemp = new list<Integer>();
        map<Integer, SVMXC__ServiceMax_Config_Data__c> mapTemp = new map<Integer, SVMXC__ServiceMax_Config_Data__c>();
        
        for(SVMXC__ServiceMax_Config_Data__c oExp :lstexp)
        {
            mapTemp.put(oExp.SVMXC__Sequence__c.intValue(),oExp);
        }
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        lstexp.clear();
        for(Integer iIndex: lstTemp)
        {
            lstexp.add(mapTemp.get(iIndex));
        }
        return lstexp;
    }
    
    public void routingPN(map<Id, SObject> newMapOfIdToSObjTrigger, String strObjectName, String strAlertType, map<String, String> mapEachSetting)
    {
        Boolean settingValue=false;
        String SFDCOrSVMX ='Salesforce';
        if(mapEachSetting!=NULL && mapEachSetting.containsKey('MOBN001_SET002'))
        {
            SFDCOrSVMX = mapEachSetting.get('MOBN001_SET002');
        }
        if(SFDCOrSVMX=='Salesforce')
        {
            settingValue = true;
        }
        sendNotification(newMapOfIdToSObjTrigger, strObjectName, strAlertType, mapEachSetting, settingValue);
    }
}