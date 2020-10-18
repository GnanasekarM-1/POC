@isTest(SeeAllData = false)
private class INTF_SyncLogCapture_UT {

    static testMethod void INTF_SyncLogCapture_UnitTest() {
    
        //insert config data
        INTF_DataUtilityServices_UT.insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c enableLogging = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Logging', SVMXC__Internal_value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(enableLogging);
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Config_Data__c usageLogging = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Usage Logging', SVMXC__Internal_value__c = '3252efsf23355', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(usageLogging);
        //ADC
        SVMXC__ServiceMax_Config_Data__c logOptions = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Usage Logging User Option', SVMXC__Internal_value__c = 'Always', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(logOptions);
        insert configDataList;
        
        SVMXC__SVMX_Job_Logs__c logToUpdate = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        logToUpdate.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Apex_CPU_Time__c = 2;
        insert logToUpdate;
        
        SVMXC__SVMX_Job_Logs__c masterLogToUpdate = new SVMXC__SVMX_Job_Logs__c();
        masterLogToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        masterLogToUpdate.SVMXC__Type__c = 'MASTER_IPAD';
        masterLogToUpdate.SVMXC__Call_Status__c='InProgress';
        String username;
        if(UserInfo.getFirstName() != null)
            userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        else
            userName = UserInfo.getLastName();         
        masterLogToUpdate.SVMXC__Group_Id__c=userName;
        insert masterLogToUpdate;
        
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'Testing Logging';
        req.eventType = 'Test';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        INTF_WebServicesDef.SVMXClient cl = new INTF_WebServicesDef.SVMXClient();
        cl.clientType = 'iPad';
        cl.clientInfo = new List<string>{'appversion:14.20.002'};
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_TIME_LOG', string.valueOf(logToUpdate.Id));
        VMTimeLog.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_ID', string.valueOf(logToUpdate.Id));
        VM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T4', string.valueOf(dateTime.now()));
        INTF_WebServicesDef.SVMXMap VM2 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T5', string.valueOf(dateTime.now()));
        VM.valueMap.add(VM1);
        VM.valueMap.add(VM2);
        INTF_WebServicesDef.SVMXMap VM3 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INCREMENTAL_DATA_SYNC');
        VM.valueMap.add(VM3);
        
        VMTimeLog.valueMap.add(VM);
        
        INTF_WebServicesDef.SVMXMap VMT1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T1', string.valueOf(DateTime.now()));
        VMTimeLog.valueMap.add(VMT1);
        INTF_WebServicesDef.SVMXMap VMLogContext = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INITIAL SYNC');
        VMTimeLog.valueMap.add(VMLogContext);
        
        req.valueMap.add(VMTimeLog);
        
        INTF_SyncLogCapture.createMaster(req);
        INTF_SyncLogCapture.initiateLogging(req);
        INTF_SyncLogCapture.finishLogging(true);
        
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_SyncLogCapture.updateResponseWithLoggingInfo(res);
        
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'SYNC_TIME_LOG';
        req.eventType = 'SYNC';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_Log_Failed','');
        VMTimeLog.values = new List<string>{'ABCDEFGHIJKLMNOPQRSTUVWXYZ'};
        
        SVMXC__SVMX_Job_Logs__c logToUpdate1 = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate1.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Apex_CPU_Time__c = 2;
        logToUpdate1.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        insert logToUpdate1;
        List<SVMXC__SVMX_Job_Logs__c> lstJoblogs = new List<SVMXC__SVMX_Job_Logs__c>();
        lstJoblogs.add(logToUpdate1);
        lstJoblogs.add(logToUpdate);
        INTF_WebServicesDef.SVMXMap VMTimeLog1 = new INTF_WebServicesDef.SVMXMap('SVMX_Job_Log', '');
        VMTimeLog1.value = JSON.serialize(lstJoblogs);
        
        req.valueMap.add(VMTimeLog);
        req.valueMap.add(VMTimeLog1);
        
        INTF_SyncLogCapture.updateSyncTimeLogs(req);
    }
    
    static testMethod void INTF_SyncLogCapture_UnitTestWithKey() {

        //insert config data
        INTF_DataUtilityServices_UT.insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c enableLogging = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Logging', SVMXC__Internal_value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(enableLogging);
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Config_Data__c usageLogging = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Usage Logging', SVMXC__Internal_value__c = 'wd4fmOB3euQprmtjBRuOF3PoX42xhPV930ZbWRXun78wd42SUmAw21LWeBqFmlzz+WwESRZPvR4aA37ERAGSnA==', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(usageLogging);
        //ADC
        SVMXC__ServiceMax_Config_Data__c logOptions = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Usage Logging User Option', SVMXC__Internal_value__c = 'Always', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(logOptions);
        insert configDataList;
    
        SVMXC__SVMX_Job_Logs__c logToUpdate = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        logToUpdate.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Apex_CPU_Time__c = 2;
        insert logToUpdate;
        
        SVMXC__SVMX_Job_Logs__c masterLogToUpdate = new SVMXC__SVMX_Job_Logs__c();
        masterLogToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        masterLogToUpdate.SVMXC__Type__c = 'MASTER_IPAD';
        masterLogToUpdate.SVMXC__Call_Status__c='InProgress';
        String username;
        if(UserInfo.getFirstName() != null)
            userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        else
            userName = UserInfo.getLastName();         
        masterLogToUpdate.SVMXC__Group_Id__c=userName;
        insert masterLogToUpdate;
        
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'Testing Logging';
        req.eventType = 'Test';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        INTF_WebServicesDef.SVMXClient cl = new INTF_WebServicesDef.SVMXClient();
        cl.clientType = 'iPad';
        cl.clientInfo = new List<string>{'appversion:14.20.002'};
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_TIME_LOG', string.valueOf(logToUpdate.Id));
        VMTimeLog.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_ID', string.valueOf(logToUpdate.Id));
        VM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T4', string.valueOf(dateTime.now()));
        INTF_WebServicesDef.SVMXMap VM2 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T5', string.valueOf(dateTime.now()));
        VM.valueMap.add(VM1);
        VM.valueMap.add(VM2);
        INTF_WebServicesDef.SVMXMap VM3 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INCREMENTAL_DATA_SYNC');
        VM.valueMap.add(VM3);
        
        VMTimeLog.valueMap.add(VM);
        
        INTF_WebServicesDef.SVMXMap VMT1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T1', string.valueOf(DateTime.now()));
        VMTimeLog.valueMap.add(VMT1);
        INTF_WebServicesDef.SVMXMap VMLogContext = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INITIAL SYNC');
        VMTimeLog.valueMap.add(VMLogContext);
        
        req.valueMap.add(VMTimeLog);
        
        INTF_SyncLogCapture.createMaster(req);
        INTF_SyncLogCapture.initiateLogging(req);
        INTF_SyncLogCapture.finishLogging(true);
        
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_SyncLogCapture.updateResponseWithLoggingInfo(res);
        
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'SYNC_TIME_LOG';
        req.eventType = 'SYNC';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_Log_Failed','');
        VMTimeLog.values = new List<string>{'ABCDEFGHIJKLMNOPQRSTUVWXYZ'};
        
        SVMXC__SVMX_Job_Logs__c logToUpdate1 = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate1.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Apex_CPU_Time__c = 2;
        logToUpdate1.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        insert logToUpdate1;
        List<SVMXC__SVMX_Job_Logs__c> lstJoblogs = new List<SVMXC__SVMX_Job_Logs__c>();
        lstJoblogs.add(logToUpdate1);
        lstJoblogs.add(logToUpdate);
        INTF_WebServicesDef.SVMXMap VMTimeLog1 = new INTF_WebServicesDef.SVMXMap('SVMX_Job_Log', '');
        VMTimeLog1.value = JSON.serialize(lstJoblogs);
        
        req.valueMap.add(VMTimeLog);
        req.valueMap.add(VMTimeLog1);
        
        INTF_SyncLogCapture.updateSyncTimeLogs(req);
    }
    static testMethod void INTF_SyncLogCapture_UnitTestWithoutLog() {

        //insert config data
        INTF_DataUtilityServices_UT.insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c enableLogging = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Logging', SVMXC__Internal_value__c = 'false', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(enableLogging);
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Config_Data__c usageLogging = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Usage Logging', SVMXC__Internal_value__c = 'wd4fmOB3euQprmtjBRuOF3PoX42xhPV930ZbWRXun78wd42SUmAw21LWeBqFmlzz+WwESRZPvR4aA37ERAGSnA==', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(usageLogging);
        //ADC
        SVMXC__ServiceMax_Config_Data__c logOptions = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Usage Logging User Option', SVMXC__Internal_value__c = 'Always', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(logOptions);
        insert configDataList;
    
        SVMXC__SVMX_Job_Logs__c logToUpdate = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        logToUpdate.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Apex_CPU_Time__c = 2;
        insert logToUpdate;
        
        SVMXC__SVMX_Job_Logs__c masterLogToUpdate = new SVMXC__SVMX_Job_Logs__c();
        masterLogToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        masterLogToUpdate.SVMXC__Type__c = 'MASTER_IPAD';
        masterLogToUpdate.SVMXC__Call_Status__c='InProgress';
        String username;
        if(UserInfo.getFirstName() != null)
            userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        else
            userName = UserInfo.getLastName();         
        masterLogToUpdate.SVMXC__Group_Id__c=userName;
        insert masterLogToUpdate;
        
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'Testing Logging';
        req.eventType = 'Test';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        INTF_WebServicesDef.SVMXClient cl = new INTF_WebServicesDef.SVMXClient();
        cl.clientType = 'iPad';
        cl.clientInfo = new List<string>{'appversion:14.20.002'};
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_TIME_LOG', string.valueOf(logToUpdate.Id));
        VMTimeLog.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_ID', string.valueOf(logToUpdate.Id));
        VM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T4', string.valueOf(dateTime.now()));
        INTF_WebServicesDef.SVMXMap VM2 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T5', string.valueOf(dateTime.now()));
        VM.valueMap.add(VM1);
        VM.valueMap.add(VM2);
        INTF_WebServicesDef.SVMXMap VM3 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INCREMENTAL_DATA_SYNC');
        VM.valueMap.add(VM3);
        
        VMTimeLog.valueMap.add(VM);
        
        INTF_WebServicesDef.SVMXMap VMT1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T1', string.valueOf(DateTime.now()));
        VMTimeLog.valueMap.add(VMT1);
        INTF_WebServicesDef.SVMXMap VMLogContext = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INITIAL SYNC');
        VMTimeLog.valueMap.add(VMLogContext);
        
        req.valueMap.add(VMTimeLog);
        
        INTF_SyncLogCapture.createMaster(req);

        
        INTF_SyncLogCapture.initiateLogging(req);
        INTF_SyncLogCapture.finishLogging(true);


        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_SyncLogCapture.updateResponseWithLoggingInfo(res);
        
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'SYNC_TIME_LOG';
        req.eventType = 'SYNC';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_Log_Failed','');
        VMTimeLog.values = new List<string>{'ABCDEFGHIJKLMNOPQRSTUVWXYZ'};
        
        SVMXC__SVMX_Job_Logs__c logToUpdate1 = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate1.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Apex_CPU_Time__c = 2;
        logToUpdate1.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        insert logToUpdate1;
        List<SVMXC__SVMX_Job_Logs__c> lstJoblogs = new List<SVMXC__SVMX_Job_Logs__c>();
        lstJoblogs.add(logToUpdate1);
        lstJoblogs.add(logToUpdate);
        INTF_WebServicesDef.SVMXMap VMTimeLog1 = new INTF_WebServicesDef.SVMXMap('SVMX_Job_Log', '');
        VMTimeLog1.value = JSON.serialize(lstJoblogs);
        
        req.valueMap.add(VMTimeLog);
        req.valueMap.add(VMTimeLog1);
        
        INTF_SyncLogCapture.updateSyncTimeLogs(req);
        
        req.clientInfo[0].clientType=null;        
        INTF_SyncLogCapture.createMaster(req);        
        
    }
    static testMethod void INTF_SyncLogCapture_UnitTestFSA() {

        //insert config data
        INTF_DataUtilityServices_UT.insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c enableLogging = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Logging', SVMXC__Internal_value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(enableLogging);
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Config_Data__c usageLogging = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Usage Logging', SVMXC__Internal_value__c = 'wd4fmOB3euQprmtjBRuOF3PoX42xhPV930ZbWRXun78wd42SUmAw21LWeBqFmlzz+WwESRZPvR4aA37ERAGSnA==', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(usageLogging);
        //ADC
        SVMXC__ServiceMax_Config_Data__c logOptions = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Usage Logging User Option', SVMXC__Internal_value__c = 'Always', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(logOptions);
        insert configDataList;
    
        SVMXC__SVMX_Job_Logs__c logToUpdate = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        logToUpdate.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate.SVMXC__Apex_CPU_Time__c = 2;
        insert logToUpdate;
        
        SVMXC__SVMX_Job_Logs__c masterLogToUpdate = new SVMXC__SVMX_Job_Logs__c();
        masterLogToUpdate.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        masterLogToUpdate.SVMXC__Type__c = 'MASTER_IPAD';
        masterLogToUpdate.SVMXC__Call_Status__c='InProgress';
        String username;
        if(UserInfo.getFirstName() != null)
            userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        else
            userName = UserInfo.getLastName();         
        masterLogToUpdate.SVMXC__Group_Id__c=userName;
        insert masterLogToUpdate;
        
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'Testing Logging';
        req.eventType = 'Test';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        INTF_WebServicesDef.SVMXClient cl = new INTF_WebServicesDef.SVMXClient();
        cl.clientType = 'ANDROID TABLET';
        cl.clientInfo = new List<string>{'appversion:14.20.002'};
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_TIME_LOG', string.valueOf(logToUpdate.Id));
        VMTimeLog.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_ID', string.valueOf(logToUpdate.Id));
        VM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap VM1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T4', string.valueOf(dateTime.now()));
        INTF_WebServicesDef.SVMXMap VM2 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T5', string.valueOf(dateTime.now()));
        VM.valueMap.add(VM1);
        VM.valueMap.add(VM2);
        INTF_WebServicesDef.SVMXMap VM3 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INCREMENTAL_DATA_SYNC');
        VM.valueMap.add(VM3);
        
        VMTimeLog.valueMap.add(VM);
        
        INTF_WebServicesDef.SVMXMap VMT1 = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_T1', string.valueOf(DateTime.now()));
        VMTimeLog.valueMap.add(VMT1);
        INTF_WebServicesDef.SVMXMap VMLogContext = new INTF_WebServicesDef.SVMXMap('SVMX_LOG_CONTEXT', 'INITIAL_SYNC');
        VMTimeLog.valueMap.add(VMLogContext);
        
        req.valueMap.add(VMTimeLog);
        
        INTF_SyncLogCapture.createMaster(req);

        
        INTF_SyncLogCapture.initiateLogging(req);
        INTF_SyncLogCapture.finishLogging(true);


        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_SyncLogCapture.updateResponseWithLoggingInfo(res);
        
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.value = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        req.eventName = 'SYNC_TIME_LOG';
        req.eventType = 'SYNC';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        req.clientInfo.add(cl);
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        VMTimeLog = new INTF_WebServicesDef.SVMXMap('SVMX_Log_Failed','');
        VMTimeLog.values = new List<string>{'ABCDEFGHIJKLMNOPQRSTUVWXYZ'};
        
        SVMXC__SVMX_Job_Logs__c logToUpdate1 = new SVMXC__SVMX_Job_Logs__c();
        logToUpdate1.SVMXC__Log_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Request_Received_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Response_Returned_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Receive_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Client_Response_Processing_Timestamp__c = system.now().addMinutes(-1);
        logToUpdate1.SVMXC__Apex_CPU_Time__c = 2;
        logToUpdate1.SVMXC__Operation__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        insert logToUpdate1;
        List<SVMXC__SVMX_Job_Logs__c> lstJoblogs = new List<SVMXC__SVMX_Job_Logs__c>();
        lstJoblogs.add(logToUpdate1);
        lstJoblogs.add(logToUpdate);
        INTF_WebServicesDef.SVMXMap VMTimeLog1 = new INTF_WebServicesDef.SVMXMap('SVMX_Job_Log', '');
        VMTimeLog1.value = JSON.serialize(lstJoblogs);
        
        req.valueMap.add(VMTimeLog);
        req.valueMap.add(VMTimeLog1);
        
        INTF_SyncLogCapture.updateSyncTimeLogs(req);
        
        req.clientInfo[0].clientType=null;        
        INTF_SyncLogCapture.createMaster(req);        
        
    }     
}