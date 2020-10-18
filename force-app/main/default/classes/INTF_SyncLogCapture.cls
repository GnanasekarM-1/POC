public with sharing class INTF_SyncLogCapture
{
    public static SVMXC__SVMX_Job_Logs__c syncLogObj;
    public static boolean isLoggingEnabled;
    public static boolean isLoggingFinished;
    
    public static INTF_WebServicesDef.INTF_SFMResponse createMaster(INTF_WebServicesDef.INTF_SFMRequest reqToLog)
    {
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        res.eventName = reqToLog.eventName;
        res.eventType = reqToLog.eventType;
        res.success = true;
        res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        try{
            INTF_SyncLogCapture.isLoggingFinished = false;
            INTF_ConfigSync confSync = new INTF_ConfigSync();
            string svmxGrpProfileId = confSync.getSVMXGrpProfileId(null);
            INTF_SyncLogCapture.isLoggingEnabled = INTF_SyncLogCapture.isLoggingEnabled(svmxGrpProfileId, res, reqToLog);
            
            if(!INTF_SyncLogCapture.isLoggingEnabled)
                return res;
            
            string clientType = '', clientVersion = '', callType = '', svmxGrpProfileName = '', userName = '', syncRequestId = reqToLog.value;
            List<INTF_WebServicesDef.SVMXMap> lstReqVMap = new List<INTF_WebServicesDef.SVMXMap>();
            if(reqToLog.valueMap != null && reqToLog.valueMap.size() > 0)
                lstReqVMap = reqToLog.valueMap;
            List<INTF_WebServicesDef.SVMXClient> clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
            
            if(reqToLog.clientInfo != null && reqToLog.clientInfo.size() > 0)
                clientInfo = reqToLog.clientInfo;
                
            if(clientInfo != null && clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient client: clientInfo)
                {
                    clientType = client.clientType;
                    for(string str: client.clientInfo)
                        if(str.contains('appversion'))
                        {
                            List<string> versionStr = str.split(':');
                            clientVersion = versionStr[1];
                        } 
                    break;
                }
            }
            
            if(clientType == null || clientType.length() == 0)
            {
                INTF_SyncLogCapture.isLoggingEnabled = false;
                return res;
            }
            
            system.debug(loggingLevel.WARN, '=Client Type=: ' + clientType + ' =Client Version=: ' + clientVersion);
            
            for(INTF_WebServicesDef.SVMXMap reqVM: lstReqVMap)
            {
                if(reqVM.key == 'SVMX_TIME_LOG')
                {
                    for(INTF_WebServicesDef.SVMXMap internalVM : reqVM.valueMap)
                    {
                        if(internalVM.key == 'SVMX_LOG_CONTEXT')
                        {
                            callType = internalVM.value;
                            break;
                        }
                    }
                }
            }
            
            if((callType != 'CONFIG SYNC' && callType != 'INCREMENTAL DATA SYNC' && callType != 'INITIAL SYNC') || (clientType != 'MFL' && clientType != 'ANDROID' && clientType != 'IPAD' && clientType != 'IPHONE' && clientType != 'ANDROID TABLET' && clientType != 'ANDROID PHONE'))
            {
                INTF_SyncLogCapture.isLoggingEnabled = false;
                return res;
            }
            
            string masterType = 'MASTER_'+ clientType.toUpperCase();
            if(clientType == 'ANDROID TABLET' || clientType == 'ANDROID PHONE' )
                masterType = 'MASTER_ANDROID';
            
            if(UserInfo.getFirstName() != null)
                userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            else
                userName = UserInfo.getLastName();
            
            svmxGrpProfileName = [SELECT Id,SVMXC__Profile_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE Id =:svmxGrpProfileId][0].SVMXC__Profile_Name__c;
            
            system.debug(loggingLevel.WARN, 'Sync Request Id: ' + syncRequestId);
            List<SVMXC__SVMX_Job_Logs__c> olderSyncWithSameId = new List<SVMXC__SVMX_Job_Logs__c>();
            for(SVMXC__SVMX_Job_Logs__c olderLogWithSameSyncReqId: [select id, SVMXC__Operation__c, SVMXC__Type__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Operation__c =: syncRequestId]){
                olderLogWithSameSyncReqId.SVMXC__Operation__c = olderLogWithSameSyncReqId.SVMXC__Operation__c + '_Failed';
                olderSyncWithSameId.add(olderLogWithSameSyncReqId);
            }
            system.debug(loggingLevel.WARN, 'Job logs with the Sync Request Id same as current sync: ' + olderSyncWithSameId);
            if(olderSyncWithSameId != null && olderSyncWithSameId.size() > 0)
                update olderSyncWithSameId;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SVMXC__SVMX_Job_Logs__c masterSyncLogRec = new SVMXC__SVMX_Job_Logs__c(SVMXC__Type__c = masterType,
                                                                                    SVMXC__Call_Status__c = 'InProgress',
                                                                                    SVMXC__Profile_Id__c =  svmxGrpProfileName,
                                                                                    SVMXC__Log_Category__c = callType,
                                                                                    SVMXC__Operation__c = syncRequestId,
                                                                                    SVMXC__Group_Id__c = userName,
                                                                                    SVMXC__Log_Timestamp__c = system.now(),
                                                                                    SVMXC__Client_Version__c = clientVersion,
                                                                                    SVMXC__Event_Type__c = '0',
                                                                                    SVMXC__Log_Context__c = '0',
                                                                                    SVMXC__Message__c = '0',
                                                                                    SVMXC__Apex_CPU_Time__c = 0,
                                                                                    SVMXC__Event_Name__c = '0'
                                                                                );
            insert masterSyncLogRec;   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            
            // Added to mark the older Master logs to Failed if the status is in-progress.
            map<string, List<SVMXC__SVMX_Job_Logs__c>> mapSyncReqToLstLogs = new map<string, List<SVMXC__SVMX_Job_Logs__c>>();
            map<string, SVMXC__SVMX_Job_Logs__c> mapSyncReqToMasterLogs = new map<string, SVMXC__SVMX_Job_Logs__c>();
            list<string> failedOperationIds = new List<string>();
            
            for(SVMXC__SVMX_Job_Logs__c failedjobLogMasters : [select SVMXC__Operation__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Type__c =: masterType AND SVMXC__Group_Id__c =: userName AND SVMXC__Call_Status__c = 'InProgress' AND Id !=: masterSyncLogRec.Id])
            {
                failedOperationIds.add(failedjobLogMasters.SVMXC__Operation__c);
            }
            
            for(SVMXC__SVMX_Job_Logs__c jobLogForMaster : [select SVMXC__Log_Category__c, SVMXC__Log_Timestamp__c, SVMXC__Request_Received_Timestamp__c, SVMXC__Response_Returned_Timestamp__c, SVMXC__Client_Response_Receive_Timestamp__c, SVMXC__Client_Response_Processing_Timestamp__c, SVMXC__Apex_CPU_Time__c, SVMXC__Call_Status__c, SVMXC__Event_Name__c, SVMXC__Event_Type__c, SVMXC__Group_Id__c, SVMXC__Log_Context__c, SVMXC__Type__c, SVMXC__Operation__c, SVMXC__Client_Version__c, SVMXC__Profile_Id__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Operation__c =: failedOperationIds Order By SVMXC__Log_Timestamp__c])
            {
                if(jobLogForMaster.SVMXC__Type__c != null && jobLogForMaster.SVMXC__Type__c.contains('MASTER_'))
                {
                    jobLogForMaster.SVMXC__Call_Status__c = 'Failed';
                    mapSyncReqToMasterLogs.put(jobLogForMaster.SVMXC__Operation__c, jobLogForMaster);
                    continue;
                }
                    
                if(mapSyncReqToLstLogs.size() == 0 || !mapSyncReqToLstLogs.containsKey(jobLogForMaster.SVMXC__Operation__c))
                    mapSyncReqToLstLogs.put(jobLogForMaster.SVMXC__Operation__c, new List<SVMXC__SVMX_Job_Logs__c>());
                mapSyncReqToLstLogs.get(jobLogForMaster.SVMXC__Operation__c).add(jobLogForMaster);
            }
            
            if((mapSyncReqToLstLogs != null && mapSyncReqToLstLogs.size() > 0) || (mapSyncReqToMasterLogs != null && mapSyncReqToMasterLogs.size() > 0))
                INTF_SyncLogCapture.calculateTimingsAndUpdateMasterRec(mapSyncReqToLstLogs, mapSyncReqToMasterLogs);
                
            
        }catch(Exception ex){
            res.success = false;
            res.message = ex.getMessage();
        }       
        return res;
    }
    
    public static boolean isLoggingEnabled(string svmxGrpProfileId, INTF_WebServicesDef.INTF_SFMResponse res, INTF_WebServicesDef.INTF_SFMRequest req)
    {
        boolean isLogEnabled = false;
        String logKey = '', userOption = '';
        //Device Specific Mobile Config
        string strDeviceType = (new INTF_ConfigSync()).getDeviceName(req);
        system.debug(LoggingLevel.WARN,' Device from Request isLoggingEnabled = '+strDeviceType);
        
        String strMobConfQuery  = 'select SVMXC__Internal_Value__c, SVMXC__Display_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =: svmxGrpProfileId AND (SVMXC__Display_Type__c = \'Enable Logging\' OR SVMXC__Display_Type__c = \'Enable Usage Logging\' OR SVMXC__Display_Type__c = \'Usage Logging User Option\')';
        
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, strDeviceType);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for isLoggingEnabled = '+strMobConfQuery);
         
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfig = Database.Query(strMobConfQuery);
        system.debug(loggingLevel.WARN, 'Mobile config queried are size: ' + lstMobileConfig.size() + ' :actual value: ' + lstMobileConfig);
        
        if(lstMobileConfig != null && lstMobileConfig.size() > 0 ){
            for(SVMXC__ServiceMax_Config_Data__c mobConfig : lstMobileConfig){
                if(mobConfig.SVMXC__Display_Type__c == 'Enable Logging')
                    isLogEnabled = boolean.valueOf(mobConfig.SVMXC__Internal_Value__c);
                else if(mobConfig.SVMXC__Display_Type__c == 'Enable Usage Logging')
                    logKey = mobConfig.SVMXC__Internal_Value__c;
                else if(mobConfig.SVMXC__Display_Type__c == 'Usage Logging User Option')
                    userOption = mobConfig.SVMXC__Internal_Value__c;
            }
        }
        
        if(res != null){
            
            res.valueMap.add(new INTF_WebServicesDef.SVMXMap('USAGE_LOGGING_ENABLED', validateKey(logKey, userOption)));
            String toolsServerURL = getToolsServerURL();
            res.valueMap.add(new INTF_WebServicesDef.SVMXMap('TOOLS_SERVER_URL', toolsServerURL != null && toolsServerURL.length() > 0 
                                                                    ? toolsServerURL : 'https://mtools.servicemax-api.com'));
        }
        
        return isLogEnabled;
    }

    private static String getToolsServerURL(){
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> settingList = commSettings.SVMX_getSettingList('GLOB001');
        String toolsServerURL = settingList.get('GBL032');
        return toolsServerURL;
    }
    
    private static String validateKey(String key, String userOption){
        String type = 'never';
        try{
            if(key == null || key.length() == 0) return type;
            Blob encryptedKey = EncodingUtil.base64Decode(key);
            String orgId = UserInfo.getOrganizationId();
            Blob aes = EncodingUtil.base64Decode('DHrjCunJBoQvVjRjvWJLnBKIvPNHO0cuWciRhy8mARQ=');
            Blob decrypted = Crypto.decryptWithManagedIV('AES256', aes, encryptedKey);
            String decryptedString = decrypted.toString();
            List<String> keys = decryptedString.split('\\|\\|');
            Date da = Date.valueOf(keys[1]);
            if(keys[0].subString(0, 15) == orgId.subString(0, 15) && da >= System.today()){
                type = userOption;
            }
            return type;
        }catch(Exception ex){
            return type;
        }
    }

    public static void initiateLogging(INTF_WebServicesDef.INTF_SFMRequest reqToLog)
    {
        //Check the setting Values for Enable/Disable logging
        INTF_ConfigSync confSync = new INTF_ConfigSync();
        string svmxGrpProfileId = confSync.getSVMXGrpProfileId(null);
    
        if(INTF_SyncLogCapture.isLoggingEnabled == null)            
            INTF_SyncLogCapture.isLoggingEnabled = INTF_SyncLogCapture.isLoggingEnabled(svmxGrpProfileId, null, reqToLog);
        
        if(!INTF_SyncLogCapture.isLoggingEnabled || reqToLog.value ==null || reqToLog.value == '')
            return;
            
        dateTime timeT2 = dateTime.now(), timeT1, timeT3, timeT4, timeT5;
        INTF_SyncLogCapture.isLoggingFinished = false;
        List<INTF_WebServicesDef.SVMXMap> lstReqVMap = new List<INTF_WebServicesDef.SVMXMap>();
        if(reqToLog.valueMap != null && reqToLog.valueMap.size() > 0)
            lstReqVMap = reqToLog.valueMap;
        List<INTF_WebServicesDef.SVMXClient> clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        SVMXC__SVMX_Job_Logs__c masterSyncLogRec = new SVMXC__SVMX_Job_Logs__c();
        
        if(reqToLog.clientInfo != null && reqToLog.clientInfo.size() > 0)
            clientInfo = reqToLog.clientInfo;
        
        string clientType = '', SVMXLogId = '', callType = '', clientVersion = '';
        
        if(clientInfo != null && clientInfo.size() > 0)
        {
            for(INTF_WebServicesDef.SVMXClient client: clientInfo)
            {
                clientType = client.clientType;
                for(string str: client.clientInfo)
                    if(str.contains('appversion'))
                    {
                        List<string> versionStr = str.split(':');
                        clientVersion = versionStr[1];
                    } 
                break;
            }
        }
        
        if(clientType == null || clientType.length() == 0)
        {
            INTF_SyncLogCapture.isLoggingEnabled = false;
            return;
        }
        system.debug(loggingLevel.WARN, '=Client Type=: ' + clientType + ' =Client Version=: ' + clientVersion);
        
        string syncRequestId;
        
        if(!(reqToLog.eventName == 'SFM_METADATA' && reqToLog.eventType == 'SYNC'))
                syncRequestId = reqToLog.value;
        
        for(INTF_WebServicesDef.SVMXMap reqVM: lstReqVMap)
        {
            if(reqVM.key == 'SVMX_TIME_LOG')
            {
                for(INTF_WebServicesDef.SVMXMap internalVM : reqVM.valueMap)
                {
                    if(internalVM.key == 'SVMX_LOG_CONTEXT')
                    {
                        callType = internalVM.value;
                    }
                    else if(internalVM.key == 'SVMX_LOG_T1')
                    {
                        timeT1 = dateTime.valueOfGMT(internalVM.value.replace('T', ' '));
                    }
                    if(internalVM.key == 'SVMX_LOG_ID')
                    {
                        SVMXLogId = internalVM.value;
                        if(internalVM.valueMap != null && internalVM.valueMap.size() > 0)
                        {
                            for(INTF_WebServicesDef.SVMXMap vm: internalVM.valueMap)
                            {
                                if(vm.key == 'SVMX_LOG_T4')
                                    timeT4 = dateTime.valueOfGMT(vm.value.replace('T', ' '));
                                else if(vm.key == 'SVMX_LOG_T5')
                                    timeT5 = dateTime.valueOfGMT(vm.value.replace('T', ' '));
                            }
                        }
                    }
                }
            }
            else if(reqToLog.eventName == 'SFM_METADATA' && reqToLog.eventType == 'SYNC'  && reqVM.key == 'SYNC_REQUEST_ID')
            {
                syncRequestId = reqVM.value;
            }
        }
        
        if((callType != 'CONFIG SYNC' && callType != 'INCREMENTAL DATA SYNC' && callType != 'INITIAL SYNC') || (clientType != 'MFL' && clientType != 'ANDROID' && clientType != 'IPAD' && clientType != 'IPHONE' && clientType != 'ANDROID TABLET' && clientType != 'ANDROID PHONE'))
        {
            INTF_SyncLogCapture.syncLogObj = null;
            return;
        }
        
        system.debug(loggingLevel.WARN, '=Sync Request Id=: ' + syncRequestId + ' =Log Context=: ' + callType + ';=SVMX_LOG_ID = ' + SVMXLogId);
        
        string masterType = 'MASTER_'+ clientType.toUpperCase();
        if(clientType == 'ANDROID TABLET'  || clientType == 'ANDROID PHONE')
            masterType = 'MASTER_ANDROID';
                
        dateTime T5OfLastCall, T1OfFirstCall;
            
        List<SVMXC__SVMX_Job_Logs__c> syncLogQueried = new List<SVMXC__SVMX_Job_Logs__c>();
        syncLogQueried = [select id, SVMXC__Apex_CPU_Time__c, SVMXC__Event_Name__c, SVMXC__Event_Type__c, SVMXC__Log_Timestamp__c, SVMXC__Request_Received_Timestamp__c, SVMXC__Response_Returned_Timestamp__c, SVMXC__Client_Response_Receive_Timestamp__c, SVMXC__Client_Response_Processing_Timestamp__c, SVMXC__Call_Status__c, SVMXC__Log_Context__c, SVMXC__Client_Version__c, SVMXC__Type__c, SVMXC__Operation__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Operation__c =: syncRequestId AND SVMXC__Operation__c != null order by SVMXC__Log_Timestamp__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        system.debug(loggingLevel.WARN, '=Sync Log Queried=: ' + syncLogQueried.size() + ' =Records are=: ' + syncLogQueried);
        boolean isOlderSyncUpdated = false;
        
        if(syncLogQueried != null && syncLogQueried.size() > 0)
        {
            for(SVMXC__SVMX_Job_Logs__c syncLogToUpdate :syncLogQueried)
            {
                //Update the older SVMX Log Record
                if(SVMXLogId != null && SVMXLogId.length() > 0 && SVMXLogId == syncLogToUpdate.Id)
                {
                    system.debug(LoggingLevel.WARN, 'Before Conversion T4: ' + timeT4 + ' :T5: ' + timeT5);
                    if(timeT4 != null)
                    {
                        syncLogToUpdate.SVMXC__Client_Response_Receive_Timestamp__c = timeT4;
                    }
                    if(timeT5 != null)
                    {
                        syncLogToUpdate.SVMXC__Client_Response_Processing_Timestamp__c = timeT5;
                        T5OfLastCall = timeT5;
                    }
                    system.debug('After Conversion T4: ' + timeT4 + ' :T5: ' + timeT5);
                    
                    Database.Saveresult result = Database.update(syncLogToUpdate, false);
                    if(!result.isSuccess())
                    {
                        system.debug(LoggingLevel.WARN, 'Operation Failed for ' + result.getId() + ';syncLogToUpdate =  ' + syncLogToUpdate + '; Error is ' + result.getErrors());
                    }
                    isOlderSyncUpdated = true;
                }
            
                if(syncLogToUpdate.SVMXC__Type__c == masterType){
                    
                    system.debug(loggingLevel.WARN, '=Master Record=: ' + syncLogToUpdate);
                    masterSyncLogRec = syncLogToUpdate;
                }
            }
                
            if(T5OfLastCall == null)
                T5OfLastCall = syncLogQueried[syncLogQueried.size() -1].SVMXC__Client_Response_Processing_Timestamp__c;
                
            timeT3 = syncLogQueried[syncLogQueried.size() -1].SVMXC__Response_Returned_Timestamp__c;
            T1OfFirstCall = syncLogQueried[0].SVMXC__Log_Timestamp__c;
        }
        
        if(isOlderSyncUpdated == false && SVMXLogId != null && SVMXLogId != '' && SVMXLogId.length() > 0)
        {
            List<SVMXC__SVMX_Job_Logs__c> olderSyncRecToUpdate = [select id from SVMXC__SVMX_Job_Logs__c where Id=: SVMXLogId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(olderSyncRecToUpdate != null && olderSyncRecToUpdate.size() > 0 && olderSyncRecToUpdate.size() == 1)
            {
                system.debug('Before Conversion T4: ' + timeT4 + ' :T5: ' + timeT5);
                if(timeT4 != null)
                {
                    olderSyncRecToUpdate[0].SVMXC__Client_Response_Receive_Timestamp__c = timeT4;
                }
                if(timeT5 != null)
                {
                    olderSyncRecToUpdate[0].SVMXC__Client_Response_Processing_Timestamp__c = timeT5;
                }
                system.debug('After Conversion T4: ' + timeT4 + ' :T5: ' + timeT5);
                update olderSyncRecToUpdate[0];
                isOlderSyncUpdated = true;
            }
        }
        
        INTF_SyncLogCapture.syncLogObj = new SVMXC__SVMX_Job_Logs__c(SVMXC__Call_Status__c = 'InProgress', 
                                                                     SVMXC__Event_Name__c = reqToLog.eventName, 
                                                                     SVMXC__Event_Type__c = reqToLog.eventType, 
                                                                     SVMXC__Group_Id__c = UserInfo.getUserId(),
                                                                     SVMXC__Profile_Id__c =  svmxGrpProfileId, 
                                                                     SVMXC__Log_Category__c = callType, 
                                                                     SVMXC__Type__c = clientType, 
                                                                     SVMXC__Operation__c = syncRequestId, 
                                                                     SVMXC__Request_Received_Timestamp__c = timeT2,
                                                                     SVMXC__Client_Version__c = clientVersion
                                                                     );
        if(timeT1 != null)
        {
            INTF_SyncLogCapture.syncLogObj.SVMXC__Log_Timestamp__c = timeT1;
            
            if(T1OfFirstCall == null)
                T1OfFirstCall = timeT1;
        }
        
        insert INTF_SyncLogCapture.syncLogObj;
        
        system.debug(loggingLevel.WARN, '=Current Sync Log=: ' + INTF_SyncLogCapture.syncLogObj);
        
        if(masterSyncLogRec == null || masterSyncLogRec.Id == null || T1OfFirstCall == null)
        {
            string userName;
            if(UserInfo.getFirstName() != null)
                userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            else
                userName = UserInfo.getLastName();
            string svmxGrpProfileName = [SELECT Id,SVMXC__Profile_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE Id =:svmxGrpProfileId][0].SVMXC__Profile_Name__c;
            
            double latencyToAdd = 0;
            if(timeT2 != null && timeT1 != null)
                latencyToAdd = (timeT2.getTime() - timeT1.getTime())/1000;
                
            masterSyncLogRec = new SVMXC__SVMX_Job_Logs__c(SVMXC__Type__c = masterType,
                                                                                SVMXC__Call_Status__c = 'InProgress',
                                                                                SVMXC__Profile_Id__c =  svmxGrpProfileName,
                                                                                SVMXC__Log_Category__c = callType,
                                                                                SVMXC__Operation__c = syncRequestId,
                                                                                SVMXC__Group_Id__c = userName,
                                                                                SVMXC__Log_Timestamp__c = system.now(),
                                                                                SVMXC__Client_Version__c = clientVersion,
                                                                                SVMXC__Event_Type__c = string.valueOf(latencyToAdd)
                                                                                );
            insert masterSyncLogRec;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        
    }
    
    public static void finishLogging(boolean isSuccessFinish)
    {
        if(INTF_SyncLogCapture.syncLogObj == null)
            return;
            
        dateTime dateTimeNow = dateTime.now();
        if(!INTF_SyncLogCapture.isLoggingEnabled || INTF_SyncLogCapture.isLoggingFinished)
            return;
        
        if(isSuccessFinish)
            INTF_SyncLogCapture.syncLogObj.SVMXC__Call_Status__c = 'Completed';
        else
            INTF_SyncLogCapture.syncLogObj.SVMXC__Call_Status__c = 'Failed';
            
        INTF_SyncLogCapture.syncLogObj.SVMXC__Response_Returned_Timestamp__c = dateTimeNow;
        INTF_SyncLogCapture.syncLogObj.SVMXC__Apex_CPU_Time__c = Limits.getCpuTime();
        

        Database.Saveresult result = Database.update(INTF_SyncLogCapture.syncLogObj, false);
        if(!result.isSuccess())
        {
            system.debug(LoggingLevel.WARN, 'Operation Failed for ' + result.getId() + ';syncLogToUpdate =  ' + INTF_SyncLogCapture.syncLogObj + '; Error is ' + result.getErrors());
        }
        
        INTF_SyncLogCapture.isLoggingFinished = true;
    }
    
    public static INTF_WebServicesDef.INTF_SFMResponse updateResponseWithLoggingInfo(INTF_WebServicesDef.INTF_SFMResponse resToUpdate)
    {
        if(INTF_SyncLogCapture.isLoggingEnabled == null || INTF_SyncLogCapture.isLoggingFinished == null || INTF_SyncLogCapture.syncLogObj == null)
            return resToUpdate;
        
        if(INTF_SyncLogCapture.syncLogObj == null)
            return resToUpdate;
            
        if(INTF_SyncLogCapture.isLoggingEnabled && INTF_SyncLogCapture.isLoggingFinished && INTF_SyncLogCapture.syncLogObj != null && INTF_SyncLogCapture.syncLogObj.Id != null)
        {
            INTF_WebServicesDef.SVMXMap resVM = new INTF_WebServicesDef.SVMXMap();
            resVM.key = 'SVMX_LOG_ID';
            resVM.value = INTF_SyncLogCapture.syncLogObj.Id;
            
            if(resToUpdate == null)
                resToUpdate = new INTF_WebServicesDef.INTF_SFMResponse();
                
            if(resToUpdate.valueMap == null)
                resToUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            resToUpdate.valueMap.add(resVM);
        }
        return resToUpdate;
    }
    
    public static INTF_WebServicesDef.INTF_SFMResponse updateSyncTimeLogs(INTF_WebServicesDef.INTF_SFMRequest reqToUpdate)
    {
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        set<string> lstSyncRequestIds = new set<string>();
        set<string> lstFailedSyncLogs = new set<string>();
        string jsonStrForRecords;
        if(reqToUpdate.value != null && reqToUpdate.value != '')
            lstSyncRequestIds.add(reqToUpdate.value);
        
        map<string, List<SVMXC__SVMX_Job_Logs__c>> mapSyncReqToLstLogs = new map<string, List<SVMXC__SVMX_Job_Logs__c>>();
        map<string, SVMXC__SVMX_Job_Logs__c> mapSyncReqToMasterLogs = new map<string, SVMXC__SVMX_Job_Logs__c>();
        
        res.eventName = reqToUpdate.eventName;
        res.eventType = reqToUpdate.eventType;
        res.success = true;
        res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap resVM = new INTF_WebServicesDef.SVMXMap('SVMX_Job_Log','');
        resVM.values = new List<string>();
        res.valueMap.add(resVM);
        for(INTF_WebServicesDef.SVMXMap reqVM:reqToUpdate.valueMap)
        {
            if(reqVM.key == 'SVMX_Job_Log')
                jsonStrForRecords = reqVM.value;
            if(reqVM.key == 'SVMX_Log_Failed')
                lstFailedSyncLogs.addAll(reqVM.values);
        }
        if(jsonStrForRecords == null || jsonStrForRecords.length() == 0)
        {
            res.success = false;
            res.message = 'No Records to update.';
            return res;
        }
        try
        {
            List<SVMXC__SVMX_Job_Logs__c> lstJobLogs = (List<SVMXC__SVMX_Job_Logs__c>)JSON.deserialize(jsonStrForRecords, List<SVMXC__SVMX_Job_Logs__c>.class);
            if(lstJobLogs != null && lstJobLogs.size() > 0)
            {
                for (Database.SaveResult sr : Database.update(lstJobLogs, false))
                {
                    if(sr.isSuccess())
                        resVM.values.add(string.valueOf(sr.getId()));
                }
                
                if(resVM.values != null && resVM.values.size() > 0)
                {
                    for(SVMXC__SVMX_Job_Logs__c jobLogOpp : [select SVMXC__Operation__c from SVMXC__SVMX_Job_Logs__c where Id IN: resVM.values])
                        lstSyncRequestIds.add(jobLogOpp.SVMXC__Operation__c);
                        
                    if(lstFailedSyncLogs != null && lstFailedSyncLogs.size() > 0)
                        lstSyncRequestIds.addAll(lstFailedSyncLogs);
                        
                    if(lstSyncRequestIds != null && lstSyncRequestIds.size() > 0)
                    {
                        for(SVMXC__SVMX_Job_Logs__c jobLogForMaster : [select SVMXC__Log_Category__c, SVMXC__Log_Timestamp__c, SVMXC__Request_Received_Timestamp__c, SVMXC__Response_Returned_Timestamp__c, SVMXC__Client_Response_Receive_Timestamp__c, SVMXC__Client_Response_Processing_Timestamp__c, SVMXC__Apex_CPU_Time__c, SVMXC__Call_Status__c, SVMXC__Event_Name__c, SVMXC__Event_Type__c, SVMXC__Group_Id__c, SVMXC__Log_Context__c, SVMXC__Type__c, SVMXC__Operation__c, SVMXC__Client_Version__c, SVMXC__Profile_Id__c from SVMXC__SVMX_Job_Logs__c where SVMXC__Operation__c IN: lstSyncRequestIds Order By SVMXC__Log_Timestamp__c])
                        {
                            if(jobLogForMaster.SVMXC__Type__c != null && jobLogForMaster.SVMXC__Type__c.contains('MASTER_'))
                            {
                                if(lstFailedSyncLogs.contains(jobLogForMaster.SVMXC__Operation__c))
                                    jobLogForMaster.SVMXC__Call_Status__c = 'Failed';
                                mapSyncReqToMasterLogs.put(jobLogForMaster.SVMXC__Operation__c, jobLogForMaster);
                                continue;
                            }
                                
                            if(mapSyncReqToLstLogs.size() == 0 || !mapSyncReqToLstLogs.containsKey(jobLogForMaster.SVMXC__Operation__c))
                                mapSyncReqToLstLogs.put(jobLogForMaster.SVMXC__Operation__c, new List<SVMXC__SVMX_Job_Logs__c>());
                            mapSyncReqToLstLogs.get(jobLogForMaster.SVMXC__Operation__c).add(jobLogForMaster);
                        }
                        
                        if((mapSyncReqToLstLogs != null && mapSyncReqToLstLogs.size() > 0) || (mapSyncReqToMasterLogs != null && mapSyncReqToMasterLogs.size() > 0))
                            INTF_SyncLogCapture.calculateTimingsAndUpdateMasterRec(mapSyncReqToLstLogs, mapSyncReqToMasterLogs);
                    }
                }
            }
        }catch(Exception ex)
        {
            res.success = false;
            res.message = ex.getMessage();
            system.debug(loggingLevel.WARN, 'Error Message - ' + ex.getMessage());
            return res;
        }
        return res;
    }
    
    public static void calculateTimingsAndUpdateMasterRec(map<string, List<SVMXC__SVMX_Job_Logs__c>> mapSyncReqToLstLogs, map<string, SVMXC__SVMX_Job_Logs__c> mapSyncReqToMasterLogs)
    {
        List<SVMXC__SVMX_Job_Logs__c> lstJobLogMasterToCreate = new List<SVMXC__SVMX_Job_Logs__c>();
        
        for(string strsyncId : mapSyncReqToMasterLogs.keyset())
        {
            double totalCPUTime = 0, serverProcessingTime = 0, latency = 0, clientProcessing = 0, totalSyncTime = 0, databaseOpTime = 0;
            string callStatus = 'Completed', svmxGroupId, clientVersion, userId, logContext, clientType;
            if(mapSyncReqToLstLogs.get(strsyncId) != null && mapSyncReqToLstLogs.get(strsyncId).size() > 0)
            {
                integer totalnoOfCalls = mapSyncReqToLstLogs.get(strsyncId).size();
                for(SVMXC__SVMX_Job_Logs__c jobLogToProcess: mapSyncReqToLstLogs.get(strsyncId))
                {
                    if(jobLogToProcess.SVMXC__Log_Timestamp__c != null && jobLogToProcess.SVMXC__Request_Received_Timestamp__c != null && jobLogToProcess.SVMXC__Response_Returned_Timestamp__c != null && jobLogToProcess.SVMXC__Client_Response_Receive_Timestamp__c != null && jobLogToProcess.SVMXC__Client_Response_Processing_Timestamp__c != null && jobLogToProcess.SVMXC__Apex_CPU_Time__c != null)
                    {
                        totalCPUTime += jobLogToProcess.SVMXC__Apex_CPU_Time__c;
                        serverProcessingTime += (jobLogToProcess.SVMXC__Response_Returned_Timestamp__c.getTime() - jobLogToProcess.SVMXC__Request_Received_Timestamp__c.getTime());
                        latency += ((jobLogToProcess.SVMXC__Request_Received_Timestamp__c.getTime() - jobLogToProcess.SVMXC__Log_Timestamp__c.getTime()) + (jobLogToProcess.SVMXC__Client_Response_Receive_Timestamp__c.getTime() - jobLogToProcess.SVMXC__Response_Returned_Timestamp__c.getTime()));
                        clientProcessing += (jobLogToProcess.SVMXC__Client_Response_Processing_Timestamp__c.getTime() - jobLogToProcess.SVMXC__Client_Response_Receive_Timestamp__c.getTime());
                        if(jobLogToProcess.SVMXC__Call_Status__c != null && jobLogToProcess.SVMXC__Call_Status__c != 'Completed' && callStatus != 'Failed')
                            callStatus = jobLogToProcess.SVMXC__Call_Status__c;
                        if(jobLogToProcess.SVMXC__Log_Category__c != null)
                            logContext = jobLogToProcess.SVMXC__Log_Category__c;
                        if(jobLogToProcess.SVMXC__Client_Version__c != null)
                            clientVersion = jobLogToProcess.SVMXC__Client_Version__c;
                        if(jobLogToProcess.SVMXC__Type__c != null)
                            clientType = jobLogToProcess.SVMXC__Type__c;
                    }
                }
                
                if(mapSyncReqToLstLogs.get(strsyncId)[totalnoOfCalls-1].SVMXC__Client_Response_Processing_Timestamp__c != null && mapSyncReqToLstLogs.get(strsyncId)[0].SVMXC__Log_Timestamp__c != null)
                    totalSyncTime = (mapSyncReqToLstLogs.get(strsyncId)[totalnoOfCalls-1].SVMXC__Client_Response_Processing_Timestamp__c.getTime() - mapSyncReqToLstLogs.get(strsyncId)[0].SVMXC__Log_Timestamp__c.getTime())/1000;
            }
            
            totalCPUTime = totalCPUTime/1000;
            serverProcessingTime = serverProcessingTime/1000;
            latency = latency/1000;
            clientProcessing = clientProcessing/1000;
            databaseOpTime = serverProcessingTime - totalCPUTime;
            
            if(totalSyncTime <= 0)
                totalSyncTime = serverProcessingTime + latency + clientProcessing;
            
            if(callStatus == 'InProgress' || callStatus == 'In Progress')
                callStatus = 'Failed';
            
            SVMXC__SVMX_Job_Logs__c masterJobLog = mapSyncReqToMasterLogs.get(strsyncId);
            if(masterJobLog.SVMXC__Call_Status__c != 'Failed')
                masterJobLog.SVMXC__Call_Status__c = callStatus;
                
            masterJobLog.SVMXC__Apex_CPU_Time__c = totalCPUTime;
            masterJobLog.SVMXC__Event_Name__c = string.valueOf(serverProcessingTime);
            masterJobLog.SVMXC__Event_Type__c = string.valueOf(latency);
            masterJobLog.SVMXC__Log_Context__c = string.valueOf(clientProcessing);
            masterJobLog.SVMXC__Message__c = string.valueOf(totalSyncTime);
            masterJobLog.SVMXC__Log_level__c = databaseOpTime;
            if(logContext != null)
                masterJobLog.SVMXC__Log_Category__c = logContext;
            
            lstJobLogMasterToCreate.add(masterJobLog);
        }
        update lstJobLogMasterToCreate;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
}