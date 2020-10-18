/* Security Scanned */
global class SchedulePushNotifications implements Schedulable
{
    global void execute(SchedulableContext scContext)
    {
        Boolean isNotificationEnabled = false;
        String sfdcProfileId = Userinfo.getProfileId();
        List<SVMXC__ServiceMax_Config_Data__c> lstGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstGrpProfile = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c =: sfdcProfileId AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = true];
        system.debug(LoggingLevel.WARN, 'Configuration Access = ' + lstGrpProfile + '; Size = ' + lstGrpProfile.size());
        
        String grpProfile = lstGrpProfile[0].SVMXC__Access_Configuration_Profile__c;
        List<SVMXC__ServiceMax_Config_Data__c> lstPushNotSetting = [Select SVMXC__Setting_Unique_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Setting Value' AND (SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c IN ('MOBN001_SET001')) AND (SVMXC__Setting_Configuration_Profile__c = :grpProfile OR SVMXC__Setting_ID__r.SVMXC__Search_Order__c = 'Global') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true];

        if(lstPushNotSetting != null && lstPushNotSetting.size() > 0)
        {
            system.debug(loggingLevel.WARN, 'lstPushNotSetting = ' + lstPushNotSetting + '; Push Notification setting = ' + lstPushNotSetting[0].SVMXC__Internal_Value__c);
            isNotificationEnabled = Boolean.valueOf(lstPushNotSetting[0].SVMXC__Internal_Value__c);
        }
        system.debug(LoggingLevel.WARN, 'isNotificationEnabled = ' + isNotificationEnabled + '; Scheduleable Context = ' + scContext);
        if(isNotificationEnabled)
        {
            Map<String, Object> mapUserData = new Map<String, Object>();
            List<SVMXC__SVMX_Job_Logs__c> lstUpsertPushLogs = new List<SVMXC__SVMX_Job_Logs__c>();
            List<SVMXC__SVMX_Job_Logs__c> lstSVMXPushNotfctnLogs = new List<SVMXC__SVMX_Job_Logs__c>();
            Messaging.PushNotification msg = new Messaging.PushNotification();
        
            lstSVMXPushNotfctnLogs= [SELECT Id, Name, SVMXC__Profile_Id__c, SVMXC__Event_Type__c, SVMXC__Apex_CPU_Time__c, SVMXC__Log_level__c, SVMXC__Call_Status__c, SVMXC__Event_Name__c, SVMXC__Log_Context__c, SVMXC__Message__c, SVMXC__Operation__c, SVMXC__Type__c, SVMXC__Group_Id__c FROM SVMXC__SVMX_Job_Logs__c WHERE SVMXC__Operation__c = 'PUSH NOTIFICATION' AND (SVMXC__Log_Category__c ='Salesforce' OR SVMXC__Log_Category__c ='') AND SVMXC__Call_Status__c = 'NOT_SENT'];
            for(SVMXC__SVMX_Job_Logs__c eachPushLog : lstSVMXPushNotfctnLogs)
            {
                String strText = '', strSubject = '';
                Set<String> setUserIds = new Set<String>();
                strText = eachPushLog.SVMXC__Message__c;
                strSubject = eachPushLog.SVMXC__Log_Context__c;
                setUserIds.addAll(eachPushLog.SVMXC__Group_Id__c.split(','));
            
                mapUserData.put('OBJECT_NAME', eachPushLog.SVMXC__Event_Type__c);
                mapUserData.put('ACTION', '1');
                mapUserData.put('ACTION_TAG', 'DOWNLOAD');
                mapUserData.put('TITLE', strSubject);
                Map<String, Object> payload = Messaging.PushNotificationPayload.apple(strText, '', null, mapUserData);
                msg.setPayload(payload);
                msg.send('ServiceMax_Mobile_for_APNS_Notifications_SB', setUserIds);
                eachPushLog.SVMXC__Log_level__c = Integer.valueOf(eachPushLog.SVMXC__Log_level__c) + 1;
                eachPushLog.SVMXC__Message__c='';
                eachPushLog.SVMXC__Call_Status__c = 'SENT';
                lstUpsertPushLogs.add(eachPushLog);
            }
            lstSVMXPushNotfctnLogs= [SELECT Id, Name, SVMXC__Profile_Id__c, SVMXC__Event_Type__c, SVMXC__Apex_CPU_Time__c, SVMXC__Log_level__c, SVMXC__Call_Status__c, SVMXC__Event_Name__c, SVMXC__Log_Context__c, SVMXC__Message__c, SVMXC__Operation__c, SVMXC__Type__c, SVMXC__Group_Id__c FROM SVMXC__SVMX_Job_Logs__c WHERE SVMXC__Operation__c = 'PUSH NOTIFICATION' AND (SVMXC__Log_Category__c ='Servicemax') AND SVMXC__Call_Status__c = 'NOT_SENT'];
            Set<String> setUserIds = new Set<String>();
            for(SVMXC__SVMX_Job_Logs__c eachPushLog : lstSVMXPushNotfctnLogs)
            {
                setUserIds.addAll(eachPushLog.SVMXC__Group_Id__c.split(','));
            }  
            Map<Id,List<SVMXC__SM_SNS_Detail__c>> mapOfUserAndItsDetails = new Map<Id,List<SVMXC__SM_SNS_Detail__c>>();                        
            for(SVMXC__SM_SNS_Detail__c newDetails:[Select Id,Name, SVMXC__SM_User__c,SVMXC__SM_TargetArn__c From SVMXC__SM_SNS_Detail__c Where SVMXC__SM_User__c in:setUserIds and SVMXC__SM_Status__c='Registered' and SVMXC__SM_IsActive__c=true])
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
            List<SVMX_PushNotification.MicroService> listOfServices = new List<SVMX_PushNotification.MicroService>();
            for(SVMXC__SVMX_Job_Logs__c eachPushLog : lstSVMXPushNotfctnLogs)
            {
                setUserIds = new Set<String>();
                setUserIds.addAll(eachPushLog.SVMXC__Group_Id__c.split(','));
                if(!setUserIds.isEmpty())                
                {
                    for(Id newId:setUserIds)
                    {
                        if(mapOfUserAndItsDetails.containsKey(newId))
                        {
                            for(SVMXC__SM_SNS_Detail__c newDetail:mapOfUserAndItsDetails.get(newId))
                            {                                   
                                SVMX_PushNotification.MicroService newServices = new SVMX_PushNotification.MicroService();
                                newServices.message = eachpushLog.SVMXC__Message__c;
                                newServices.arnList = new List<String>();
                                newServices.arnList.add(newDetail.SVMXC__SM_TargetArn__c);
                                listOfServices.add(newServices);                                
                            }
                        }
                    }
                }
                eachPushLog.SVMXC__Log_level__c = Integer.valueOf(eachPushLog.SVMXC__Log_level__c) + 1;
                eachPushLog.SVMXC__Call_Status__c = 'SENT';
                eachPushLog.SVMXC__Message__c='';                
                lstUpsertPushLogs.add(eachPushLog);
            }
            upsert(lstUpsertPushLogs);
            if(!listOfServices.isEmpty())
            {
                String microServiceBody = JSON.serialize(listOfServices);
                System.debug(LoggingLevel.WARN,' Final Payload'+microServiceBody);  
                SNSCallout.callingOut(microServiceBody);
            }
        }
        //System.schedule('Schedule Push Notifications', '0 0 0 * * * *' , new SchedulePushNotifications() );
    }
}