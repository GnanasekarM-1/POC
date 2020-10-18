public class INTF_TxnCache {
    public static Boolean isRequestCache = true;
    private static Map<String,Object> cache = new Map<String,Object>();
    private static SVMXC__SM_Request_Cache__c singleCacheRec;
    private static map<String, String> mapClientDetails = new map<String, String>();
    public static datetime dt_PutUpdate;
    public Boolean isInternalBatch = false;
    public Boolean intBatchEnabled = false;
    
    public static Object get(String key, String objectType) {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('get');
        INTF_DataSync.logMethodEndTS(intMethodCount,'get');
        return cache.get(objectType+'::'+key);
        //return null;
    }
    
    public static void remove(String key, String objectType) {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('remove');
        cache.remove(objectType+'::'+key);
        INTF_DataSync.logMethodEndTS(intMethodCount,'remove');
    }
    
    public static void put (String key, Object value, String objectType) {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('put');
        cache.put (objectType+'::'+key, value);
        INTF_DataSync.logMethodEndTS(intMethodCount,'put');
    }
    
    public static void save (String syncRequestId) {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('save');
        if(cache == null || cache.size() == 0 || syncRequestId == null || syncRequestId == null || syncRequestId.length() == 0){
            INTF_DataSync.logMethodEndTS(intMethodCount,'save');
            return;
        }
        
        List<SVMXC__Sync_Request__c> cache_Server = new List<SVMXC__Sync_Request__c>();
        List<SVMXC__Sync_Request_Records__c> lst_CacheServerRec = new List<SVMXC__Sync_Request_Records__c>();
        
        INTF_DataSync.logSOQL(intMethodCount,'select id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c =: syncRequestId');
        cache_Server = [select id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c =: syncRequestId];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(cache_Server == null || cache_Server.size() == 0)
        {
            SVMXC__Sync_Request__c cache_Create = new SVMXC__Sync_Request__c();
            cache_Create.SVMXC__Client_Request_Id__c = syncRequestId;
            insert cache_Create;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            cache_Server.add(cache_Create);
        }
        else
        {
            INTF_DataSync.logSOQL(intMethodCount,'select id from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c =: cache_Server[0].Id AND SVMXC__Operation_Type__c = \'Cache\'');
            lst_CacheServerRec = [select id from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c =: cache_Server[0].Id AND SVMXC__Operation_Type__c = 'Cache'];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lst_CacheServerRec != null && lst_CacheServerRec.size() > 0)
                delete lst_CacheServerRec;     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        
        lst_CacheServerRec = new List<SVMXC__Sync_Request_Records__c>();
        
        for(string key: cache.keySet())
        {
            SVMXC__Sync_Request_Records__c rec_Cache = new SVMXC__Sync_Request_Records__c();
            rec_Cache.SVMXC__Sync_Request__c = cache_Server[0].Id;
            rec_Cache.SVMXC__Object_Name__c = key;
            rec_Cache.SVMXC__SOQL_Query__c = JSON.serialize(cache.get(key));
            rec_Cache.SVMXC__Operation_Type__c = 'Cache';
            lst_CacheServerRec.add(rec_Cache);
            system.debug(LoggingLevel.WARN, 'Each Sync_Request_Records rec_Cache = ' + rec_Cache);
        }
        
        if(lst_CacheServerRec != null && lst_CacheServerRec.size() > 0)
        {
            Database.Saveresult [] result = Database.insert(lst_CacheServerRec, false);
            for(Database.Saveresult eachRecordRes : result)
            {
                if(!eachRecordRes.isSuccess())
                {
                    system.debug(LoggingLevel.WARN, 'Insert Failed');
                    for(Database.Error err : eachRecordRes.getErrors())
                        system.debug(LoggingLevel.WARN, 'Insert of Sync_Request_Records Failed:' + err);
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'save');
    }
    
    public static void restore (String syncRequestId) {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('restore');
        if(syncRequestId == null || syncRequestId.length() == 0){
            INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
            return;
        }
            
        List<SVMXC__Sync_Request__c> cache_Server = new List<SVMXC__Sync_Request__c>();
        INTF_DataSync.logSOQL(intMethodCount , 'select id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c =: syncRequestId');
        cache_Server = [select id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c =: syncRequestId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(cache_Server == null || cache_Server.size() == 0 || cache_Server.size() > 1){
            INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
            return;
        }
        
        List<SVMXC__Sync_Request_Records__c> lst_CacheServerRec = new List<SVMXC__Sync_Request_Records__c>();
        INTF_DataSync.logSOQL(intMethodCount ,'select SVMXC__SOQL_Query__c, SVMXC__Object_Name__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c =: cache_Server[0].Id AND SVMXC__Operation_Type__c = \'Cache\'');
        lst_CacheServerRec = [select SVMXC__SOQL_Query__c, SVMXC__Object_Name__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c =: cache_Server[0].Id AND SVMXC__Operation_Type__c = 'Cache'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lst_CacheServerRec == null || lst_CacheServerRec.size() == 0){
            INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
            return;
        }
        
        for(SVMXC__Sync_Request_Records__c cacheRec : lst_CacheServerRec)
        {
            system.debug(LoggingLevel.Debug, 'cacheRec = ' + cacheRec);
            List<string> lstTypeKey = cacheRec.SVMXC__Object_Name__c.split('::');
            type t = type.forName(lstTypeKey[0]);
            Object obj = JSON.deserialize(cacheRec.SVMXC__SOQL_Query__c, t);
            cache.put(cacheRec.SVMXC__Object_Name__c, obj);
            system.debug(LoggingLevel.Debug, 'cache = ' + cache);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
    }
    
    public static void save(map<String, String> mapClientInfo, String strSyncReqId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('save');
        String strUserId = null, strDeviceUDID = null, strSyncStartTime = null;
        strUserId = mapClientInfo.get('userid');
        strDeviceUDID = mapClientInfo.get('clientudid');
        strSyncStartTime = mapClientInfo.get('syncstarttime'); 
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        
        system.debug(LoggingLevel.WARN, 'mapClientInfo = ' + mapClientInfo + '; strSyncReqId = ' + strSyncReqId);
        
        //for backporting add this condition as well allObjs.get('sm_request_cache__c') == null
        if(allObjs.get('svmxc__sm_request_cache__c') == null || strUserId == null || strDeviceUDID == null)
        {
            isRequestCache = false;
            save(strSyncReqId);
            INTF_DataSync.logMethodEndTS(intMethodCount,'save');
            return;
        }
        
        List<SVMXC__SM_Request_Cache__c> lstRequestCache = new List<SVMXC__SM_Request_Cache__c>();
        
        INTF_DataSync.logSOQL(intMethodCount, 'SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c, SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID');
        lstRequestCache = [Select Id, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c, SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(lstRequestCache != null && lstRequestCache.size() >= 1)
        {
            if(lstRequestCache[0].SVMXC__SM_Client_Sync_Request_Id__c != strSyncReqId)
            {
                //make all txn fields blank or null
                singleCacheRec = lstRequestCache[0];
                singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
                singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
                singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
                singleCacheRec.SVMXC__SM_Application_Filters__c = '';
                singleCacheRec.SVMXC__SM_Application_Name__c = '';
                singleCacheRec.SVMXC__SM_Application_Version__c = '';
                singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c = '';
                singleCacheRec.SVMXC__SM_Device_Type__c = '';
                singleCacheRec.SVMXC__SM_Doc_Template_IDs__c = '';
                singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Download_Criteria_Object_List__c = '';
                singleCacheRec.SVMXC__SM_Expression_IDs__c = '';
                singleCacheRec.SVMXC__SM_Group_Profile_Id__c = '';
                singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c = '';
                singleCacheRec.SVMXC__SM_Object_Access__c = '';
                singleCacheRec.SVMXC__SM_Object_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Page_Layout_IDs__c = '';
                singleCacheRec.SVMXC__SM_Picklist_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Settings__c = '';
                singleCacheRec.SVMXC__SM_SFM_Mappings__c = '';
                singleCacheRec.SVMXC__SM_SFM_Process_IDs__c = '';
                singleCacheRec.SVMXC__SM_SFM_Translations__c = '';
                singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c = '';
                singleCacheRec.SVMXC__SM_SFW_Translations__c = '';
                singleCacheRec.SVMXC__SM_SOQL_Query__c = '';
                singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = ''; 
                singleCacheRec.SVMXC__SM_Event_What_IDs__c = '';                
            }
            else
            {
                //use the record as it is because the earlier sync would have not completed somehow as the request id is same
                singleCacheRec = lstRequestCache[0];
            }
        }
        else
        {
            //create new
            singleCacheRec = new SVMXC__SM_Request_Cache__c();
            singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
            singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
            singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
        }
        system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
        (new INTF_TxnCache()).addCacheToObject();
        INTF_DataSync.logMethodEndTS(intMethodCount,'save');
    }
    
    public static void restore(map<String, String> mapClientInfo, String strSyncReqId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('restore');
        String strUserId = null, strDeviceUDID = null;
        strUserId = mapClientInfo.get('userid');
        strDeviceUDID = mapClientInfo.get('clientudid');
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        singleCacheRec = new SVMXC__SM_Request_Cache__c();
        List<SVMXC__SM_Request_Cache__c> lstRequestCache = new List<SVMXC__SM_Request_Cache__c>();
        system.debug(LoggingLevel.WARN, 'strUserId = ' + strUserId + '; strDeviceUDID = ' + strDeviceUDID + '; strSyncReqId = ' + strSyncReqId);
        
        if(allObjs.get('svmxc__sm_request_cache__c') == null || strUserId == null || strDeviceUDID == null)
        {
            isRequestCache = false;
            restore(strSyncReqId);
            INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
            return;
        }
        
        INTF_DataSync.logSOQL(intMethodCount , 'Select Id,SVMXC__SM_Application_Filters__c,SVMXC__SM_Application_Name__c,SVMXC__SM_Application_Version__c,SVMXC__SM_Checklist_Wizard_Objects__c,SVMXC__SM_Client_Sync_Request_Id__c,SVMXC__SM_Device_Type__c,SVMXC__SM_Device_UDID__c,SVMXC__SM_Doc_Template_IDs__c,SVMXC__SM_Download_Criteria_Object_Definitions__c,SVMXC__SM_Download_Criteria_Object_List__c,SVMXC__SM_Expression_IDs__c,SVMXC__SM_Group_Profile_Id__c,SVMXC__SM_Mobile_Config_Settings__c,SVMXC__SM_Object_Access__c,SVMXC__SM_Object_Definitions__c,SVMXC__SM_Object_Name__c,SVMXC__SM_Page_Layout_IDs__c,SVMXC__SM_Picklist_Definitions__c,SVMXC__SM_Settings__c,SVMXC__SM_SFM_Mappings__c,SVMXC__SM_SFM_Process_IDs__c,SVMXC__SM_SFM_Translations__c,SVMXC__SM_SFM_Wizard_SFM_Ids__c,SVMXC__SM_SFW_Translations__c,SVMXC__SM_SOQL_Query__c,SVMXC__SM_Sync_Start_Time__c,SVMXC__SM_User_id__c, SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID');
        lstRequestCache = [Select Id,SVMXC__SM_Application_Filters__c,SVMXC__SM_Application_Name__c,SVMXC__SM_Application_Version__c,SVMXC__SM_Checklist_Wizard_Objects__c,SVMXC__SM_Client_Sync_Request_Id__c,SVMXC__SM_Device_Type__c,SVMXC__SM_Device_UDID__c,SVMXC__SM_Doc_Template_IDs__c,SVMXC__SM_Download_Criteria_Object_Definitions__c,SVMXC__SM_Download_Criteria_Object_List__c,SVMXC__SM_Expression_IDs__c,SVMXC__SM_Group_Profile_Id__c,SVMXC__SM_Mobile_Config_Settings__c,SVMXC__SM_Object_Access__c,SVMXC__SM_Object_Definitions__c,SVMXC__SM_Object_Name__c,SVMXC__SM_Page_Layout_IDs__c,SVMXC__SM_Picklist_Definitions__c,SVMXC__SM_Settings__c,SVMXC__SM_SFM_Mappings__c,SVMXC__SM_SFM_Process_IDs__c,SVMXC__SM_SFM_Translations__c,SVMXC__SM_SFM_Wizard_SFM_Ids__c,SVMXC__SM_SFW_Translations__c,SVMXC__SM_SOQL_Query__c,SVMXC__SM_Sync_Start_Time__c,SVMXC__SM_User_id__c, SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        system.debug(LoggingLevel.WARN, 'Size of lstRequestCache = ' + lstRequestCache.size());
        
        if(lstRequestCache == null || lstRequestCache.size() == 0 || lstRequestCache.size() > 1){
            INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
            return;
        }
            
        if(lstRequestCache != null && lstRequestCache.size() == 1)
        {
                if(lstRequestCache[0].SVMXC__SM_Client_Sync_Request_Id__c == strSyncReqId){
                singleCacheRec = lstRequestCache[0];
                dt_PutUpdate = singleCacheRec.SVMXC__SM_Sync_Start_Time__c;
                system.debug(LoggingLevel.WARN, 'restore dt_PutUpdate = ' + dt_PutUpdate + '; singleCacheRec = ' + singleCacheRec);
                map<String, String> mapCachedData = new map<String, String>();
                
                if(singleCacheRec.SVMXC__SM_Settings__c != NULL && singleCacheRec.SVMXC__SM_Settings__c != ''){
                    mapCachedData.putAll((map<String, String>)JSON.deserialize(singleCacheRec.SVMXC__SM_Settings__c, map<String, String>.Class));
                }
                if(singleCacheRec.SVMXC__SM_Page_Layout_Ids__c != NULL && singleCacheRec.SVMXC__SM_Page_Layout_Ids__c != ''){
                    mapCachedData.putAll((map<String, String>)JSON.deserialize(singleCacheRec.SVMXC__SM_Page_Layout_Ids__c, map<String, String>.Class));
                }
                if(singleCacheRec.SVMXC__SM_Object_Access__c != NULL && singleCacheRec.SVMXC__SM_Object_Access__c != ''){
                    mapCachedData.putAll((map<String, String>)JSON.deserialize(singleCacheRec.SVMXC__SM_Object_Access__c, map<String, String>.Class));
                }
                if(singleCacheRec.SVMXC__SM_Doc_Template_Ids__c != NULL && singleCacheRec.SVMXC__SM_Doc_Template_Ids__c != ''){
                    mapCachedData.putAll((map<String, String>)JSON.deserialize(singleCacheRec.SVMXC__SM_Doc_Template_Ids__c, map<String, String>.Class));
                }
                if(singleCacheRec.SVMXC__SM_SFM_Process_Ids__c != NULL && singleCacheRec.SVMXC__SM_SFM_Process_Ids__c != ''){
                    mapCachedData.putAll((map<String, String>)JSON.deserialize(singleCacheRec.SVMXC__SM_SFM_Process_Ids__c, map<String, String>.Class));
                }
                if(singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c != NULL && singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c != ''){
                    mapCachedData.putAll((map<String, String>)JSON.deserialize(singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c, map<String, String>.Class));
                }
                
                for(String eachCacheData : mapCachedData.keySet())
                {
                    system.debug(LoggingLevel.WARN, 'eachCacheData = ' + eachCacheData); 
                    type t = type.forName(eachCacheData.split('::')[0]);
                    Object obj = JSON.deserialize(mapCachedData.get(eachCacheData), t);
                    cache.put(eachCacheData, obj);
                }
                
                if(singleCacheRec.SVMXC__SM_Group_Profile_Id__c != null && singleCacheRec.SVMXC__SM_Group_Profile_Id__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_Group_Profile_Id__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Group_Profile_Id__c.split('::::')[1], string.Class));
                
                if(singleCacheRec.SVMXC__SM_SFM_Mappings__c != null && singleCacheRec.SVMXC__SM_SFM_Mappings__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_SFM_Mappings__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_SFM_Mappings__c.split('::::')[1], set<string>.Class));
                
                if(singleCacheRec.SVMXC__SM_Expression_Ids__c != null && singleCacheRec.SVMXC__SM_Expression_Ids__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_Expression_Ids__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Expression_Ids__c.split('::::')[1], set<string>.Class));
                
                if(singleCacheRec.SVMXC__SM_Object_Definitions__c != null && singleCacheRec.SVMXC__SM_Object_Definitions__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_Object_Definitions__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Object_Definitions__c.split('::::')[1], Map<String, String>.Class));
                
                if(singleCacheRec.SVMXC__SM_SFM_Translations__c!= null && singleCacheRec.SVMXC__SM_SFM_Translations__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_SFM_Translations__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_SFM_Translations__c.split('::::')[1], I18N_TranslationDelivery.Class));
                
                if(singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c != null && singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c.split('::::')[1], set<string>.Class));
                
                if(singleCacheRec.SVMXC__SM_SFW_Translations__c != null && singleCacheRec.SVMXC__SM_SFW_Translations__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_SFW_Translations__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_SFW_Translations__c.split('::::')[1], I18N_TranslationDelivery.Class));
                
                if(singleCacheRec.SVMXC__SM_PickList_Definitions__c != null && singleCacheRec.SVMXC__SM_PickList_Definitions__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_PickList_Definitions__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_PickList_Definitions__c.split('::::')[1], Map<String, Set<String>>.Class));
                
                if(singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c!= null && singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c.split('::::')[1], set<string>.Class));
                
                if(singleCacheRec.SVMXC__SM_Application_Filters__c != null && singleCacheRec.SVMXC__SM_Application_Filters__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_Application_Filters__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Application_Filters__c.split('::::')[1], APFT_Schema.Filters.Class));
                
                if(singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c != null && singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c.split('::::')[1], Map<String, INTF_WebServicesDef.SVMXMap>.Class));
                
                if(singleCacheRec.SVMXC__SM_SOQL_Query__c != null && singleCacheRec.SVMXC__SM_SOQL_Query__c.split('::::').size() == 2)
                    cache.put(singleCacheRec.SVMXC__SM_SOQL_Query__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_SOQL_Query__c.split('::::')[1], map<String, map<String, String>>.Class));
                    
                if(singleCacheRec.SVMXC__SM_Question_Bank_IDs__c != NULL && singleCacheRec.SVMXC__SM_Question_Bank_IDs__c.split('::::').size() == 2){       
                    cache.put(singleCacheRec.SVMXC__SM_Question_Bank_IDs__c.split('::::')[0], JSON.deserialize(singleCacheRec.SVMXC__SM_Question_Bank_IDs__c.split('::::')[1], Set<string>.Class));     
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'restore');
    }
    
    public void addCacheToObject()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCacheToObject');
        
        map<String, String> mapObjectsToSave = new map<String, String>();
        mapObjectsToSave.put('Set<String>::SET_ACCESSIBLE_OBJECTS', JSON.serialize(cache.get('Set<String>::SET_ACCESSIBLE_OBJECTS')));
        mapObjectsToSave.put('set<String>::NON_ACCESSIBLE_OBJECTS', JSON.serialize(cache.get('set<String>::NON_ACCESSIBLE_OBJECTS')));
    
        map<String, String> mapMobConfigToSave = new map<String, String>();
        mapMobConfigToSave.put('List<SVMXC__ServiceMax_Config_Data__c>::SYNC_MOBILE_CONFIG', JSON.serialize(cache.get('List<SVMXC__ServiceMax_Config_Data__c>::SYNC_MOBILE_CONFIG')));
        mapMobConfigToSave.put('String::CONFLICT_STRING', JSON.serialize(cache.get('String::CONFLICT_STRING')));
    
        map<String, String> mapSFMProcessIds = new map<String, String>();
        mapSFMProcessIds.put('set<string>::SET_PROCESS_EXCLUDE', JSON.serialize(cache.get('set<string>::SET_PROCESS_EXCLUDE')));
        mapSFMProcessIds.put('set<string>::SET_PROCESS_TM', JSON.serialize(cache.get('set<string>::SET_PROCESS_TM')));
    
        map<String, String> mapPageIds = new map<String, String>();
        mapPageIds.put('set<string>::SET_NON_ACCESSIBLE_PAGELAYOUT', JSON.serialize(cache.get('set<string>::SET_NON_ACCESSIBLE_PAGELAYOUT')));
        mapPageIds.put('set<string>::SET_PAGELAYOUT_ID', JSON.serialize(cache.get('set<string>::SET_PAGELAYOUT_ID')));
    
        map<String, String> mapDocTmpltIds = new map<String, String>();
        mapDocTmpltIds.put('set<string>::SET_NON_ACCESSIBLE_DOCTEMPLATE', JSON.serialize(cache.get('set<string>::SET_NON_ACCESSIBLE_DOCTEMPLATE')));
        mapDocTmpltIds.put('set<string>::SET_DOC_TEMPLATE_ID', JSON.serialize(cache.get('set<string>::SET_DOC_TEMPLATE_ID')));
    
        map<String, String> generalSettings = new map<String, String>();
        generalSettings.put('integer::LIMIT_QUERY', JSON.serialize(cache.get('integer::LIMIT_QUERY')));
        generalSettings.put('Boolean::IPAD018_SET009', JSON.serialize(cache.get('Boolean::IPAD018_SET009')));
        generalSettings.put('Boolean::IPAD018_SET008', JSON.serialize(cache.get('Boolean::IPAD018_SET008')));
        generalSettings.put('Map<String, String>::IPAD018_SET006', JSON.serialize(cache.get('Map<String, String>::IPAD018_SET006')));
        generalSettings.put('set<String>::Tx_Fetch_setRefObjToSkip', JSON.serialize(cache.get('set<String>::Tx_Fetch_setRefObjToSkip')));
        generalSettings.put('Integer::Tx_Fetch_LimitLookupFields', JSON.serialize(cache.get('Integer::Tx_Fetch_LimitLookupFields')));
        generalSettings.put('Boolean::CHECKLIST_FEATURE', JSON.serialize(cache.get('Boolean::CHECKLIST_FEATURE')));
        
        singleCacheRec.SVMXC__SM_Download_Criteria_Object_List__c = '';
        singleCacheRec.SVMXC__SM_Settings__c = JSON.serialize(generalSettings);
        singleCacheRec.SVMXC__SM_Page_Layout_Ids__c = JSON.serialize(mapPageIds);
        singleCacheRec.SVMXC__SM_Object_Access__c = JSON.serialize(mapObjectsToSave);
        singleCacheRec.SVMXC__SM_Doc_Template_Ids__c = JSON.serialize(mapDocTmpltIds);
        singleCacheRec.SVMXC__SM_SFM_Process_Ids__c = JSON.serialize(mapSFMProcessIds);
        singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c = JSON.serialize(mapMobConfigToSave);
        
        if(cache.get('string::GROUP_PROFILE_ID') != null)
            singleCacheRec.SVMXC__SM_Group_Profile_Id__c = 'string::GROUP_PROFILE_ID::::' + JSON.serialize(cache.get('string::GROUP_PROFILE_ID'));
        if(cache.get('set<string>::SET_MAP_ID') != null)
            singleCacheRec.SVMXC__SM_SFM_Mappings__c = 'set<string>::SET_MAP_ID::::' + JSON.serialize(cache.get('set<string>::SET_MAP_ID'));
        if(cache.get('set<string>::SET_EXPRESSION_ID') != null)
            singleCacheRec.SVMXC__SM_Expression_Ids__c = 'set<string>::SET_EXPRESSION_ID::::' + JSON.serialize(cache.get('set<string>::SET_EXPRESSION_ID'));
        if(cache.get('Map<String, String>::MAP_OBJECT_DEF') != null)
            singleCacheRec.SVMXC__SM_Object_Definitions__c = 'Map<String, String>::MAP_OBJECT_DEF::::' + JSON.serialize(cache.get('Map<String, String>::MAP_OBJECT_DEF'));
        if(cache.get('set<string>::SET_QUESTION_ID') != null){      
            singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = 'set<string>::SET_QUESTION_ID::::' + JSON.serialize(cache.get('set<string>::SET_QUESTION_ID'));     
        }
        
        if(cache.get('I18N_TranslationDelivery::SFM_TRANSLATION_OBJ') != null ){
            if(JSON.serialize(cache.get('I18N_TranslationDelivery::SFM_TRANSLATION_OBJ')).length() < 131000){
                singleCacheRec.SVMXC__SM_SFM_Translations__c = 'I18N_TranslationDelivery::SFM_TRANSLATION_OBJ::::' + JSON.serialize(cache.get('I18N_TranslationDelivery::SFM_TRANSLATION_OBJ'));
            }else{
                singleCacheRec.SVMXC__SM_SFM_Translations__c = '';
            }
        }
        if(cache.get('set<string>::SET_PROCESS_FROM_WIZARD_STEP') != null)
            singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c = 'set<string>::SET_PROCESS_FROM_WIZARD_STEP::::' + JSON.serialize(cache.get('set<string>::SET_PROCESS_FROM_WIZARD_STEP'));
        if(cache.get('I18N_TranslationDelivery::WIZARD_TRANSLATION_OBJ') != null){
            if(JSON.serialize(cache.get('I18N_TranslationDelivery::WIZARD_TRANSLATION_OBJ')).length() < 131000){
                singleCacheRec.SVMXC__SM_SFW_Translations__c = 'I18N_TranslationDelivery::WIZARD_TRANSLATION_OBJ::::' + JSON.serialize(cache.get('I18N_TranslationDelivery::WIZARD_TRANSLATION_OBJ'));
            }else{
                singleCacheRec.SVMXC__SM_SFW_Translations__c = '';
            }
        }
        if(cache.get('Map<String, Set<String>>::MAP_OBJECT_PICKLIST') != null)
            singleCacheRec.SVMXC__SM_PickList_Definitions__c = 'Map<String, Set<String>>::MAP_OBJECT_PICKLIST::::' + JSON.serialize(cache.get('Map<String, Set<String>>::MAP_OBJECT_PICKLIST'));
        if(cache.get('set<string>::SET_CHECKLIST_WIZARD_OBJ') != null)
            singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c = 'set<string>::SET_CHECKLIST_WIZARD_OBJ::::' + JSON.serialize(cache.get('set<string>::SET_CHECKLIST_WIZARD_OBJ'));
        if(cache.get('APFT_Schema.Filters::APPLICATION_FILTERS') != null)
            singleCacheRec.SVMXC__SM_Application_Filters__c = 'APFT_Schema.Filters::APPLICATION_FILTERS::::' + JSON.serialize(cache.get('APFT_Schema.Filters::APPLICATION_FILTERS'));
        if(cache.get('Map<String, INTF_WebServicesDef.SVMXMap>::DOWNLOAD_CRITERIA_OBJ_DEF') != null)
            singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c = 'Map<String, INTF_WebServicesDef.SVMXMap>::DOWNLOAD_CRITERIA_OBJ_DEF::::' + JSON.serialize(cache.get('Map<String, INTF_WebServicesDef.SVMXMap>::DOWNLOAD_CRITERIA_OBJ_DEF'));
        if(cache.get('map<String, map<String, String>>::DC_PARTIAL_EXEC_OBJECTS') != null)
            singleCacheRec.SVMXC__SM_SOQL_Query__c = 'map<String, map<String, String>>::DC_PARTIAL_EXEC_OBJECTS::::' + JSON.serialize(cache.get('map<String, map<String, String>>::DC_PARTIAL_EXEC_OBJECTS'));
        
        if(singleCacheRec.SVMXC__SM_Object_Name__c == null || singleCacheRec.SVMXC__SM_Object_Name__c == '')
            singleCacheRec.SVMXC__SM_Object_Name__c = ''; 
            
        system.debug(LoggingLevel.WARN, 'singleCacheRec before update = ' + singleCacheRec);
        Database.Upsertresult result = Database.upsert(singleCacheRec, false);
        if(!result.isSuccess())
        {
            system.debug(LoggingLevel.WARN, 'Update Failed');
            for(Database.Error err : result.getErrors())
                system.debug(LoggingLevel.WARN, 'Update of Sync_Request_Records Failed:' + err);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'addCacheToObject');
    }

    public map<String, map<String, String>> getCachedLocalIdsForInsertAndDel(SVMXC__SM_Request_Cache__c singleCacheRec){
        
        map<String, map<String, String>> mapInsertOperationToIds = new map<String, map<String, String>>(); 
        system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec );

        String allIdsCombinedJson = '';
        if(singleCacheRec.SVMXC__SM_Object_Name__c != null && singleCacheRec.SVMXC__SM_Object_Name__c != '')
            allIdsCombinedJson = singleCacheRec.SVMXC__SM_Object_Name__c;

        if(singleCacheRec.SVMXC__SM_Question_Bank_IDs__c != null && singleCacheRec.SVMXC__SM_Question_Bank_IDs__c != ''){
            allIdsCombinedJson += singleCacheRec.SVMXC__SM_Question_Bank_IDs__c;
        } 

        if(singleCacheRec.SVMXC__SM_SFM_Translations__c != null && singleCacheRec.SVMXC__SM_SFM_Translations__c != ''){
            allIdsCombinedJson += singleCacheRec.SVMXC__SM_SFM_Translations__c;
        }  
        system.debug(LoggingLevel.WARN, 'JSON String = ' + allIdsCombinedJson); 
        
        if(!String.isBlank(allIdsCombinedJson)){
            mapInsertOperationToIds = (map<String, map<String, String>>)JSON.deserialize(allIdsCombinedJson, map<String, map<String, String>>.Class);
        }
        
        system.debug(LoggingLevel.WARN, 'mapInsertOperationToIds = ' + mapInsertOperationToIds);
        return mapInsertOperationToIds;
    }

    public SVMXC__SM_Request_Cache__c updateLocalIdsIntoCache(map<String, map<String, String>> mapInsertOperationToIds,SVMXC__SM_Request_Cache__c singleCacheRec ){
        
        Integer maxLength = 131070;   //max field length is 131072
        system.debug(LoggingLevel.WARN, 'mapInsertOperationToIds = ' + mapInsertOperationToIds);
        String completeJson = JSON.serialize(mapInsertOperationToIds);
        system.debug(LoggingLevel.WARN, 'completeJson = ' + completeJson);

        if(completeJson.length() > maxlength){
            singleCacheRec.SVMXC__SM_Object_Name__c = completeJson.substring(0, maxlength);
            completeJson = completeJson.substring(maxlength);

            if(completeJson.length() > maxlength){
                singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = completeJson.substring(0, maxlength); //Putting the second chunk in field SVMXC__SM_Question_Bank_IDs__c
                completeJson = completeJson.substring(maxlength);

                singleCacheRec.SVMXC__SM_SFM_Translations__c = completeJson; //Updating the remaining chunk in the third field i.e. SVMXC__SM_SFM_Translations__c

            }else{
                singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = completeJson;
            }
        }else{
            singleCacheRec.SVMXC__SM_Object_Name__c = completeJson; //JSON length did not exceed 131072 characters - so update the field as it is
        }
        return singleCacheRec;
    }
    
    
    public boolean isLimitReached()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('isLimitReached');
        integer intLimitPercent = (integer)INTF_TxnCache.get('LIMIT_QUERY', 'integer');
        if(intLimitPercent == null)
        {
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            List<String> lstSettingId = new list<String>{'SET011'};
            Map<String, String> mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
                intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
            else
                intLimitPercent = 70;
                
            INTF_TxnCache.put('LIMIT_QUERY', intLimitPercent, 'integer');
        }
        Integer intCPUTimeLimit = intLimitPercent * Limits.getLimitCpuTime()/100;
        Integer intHeapLimit = intLimitPercent * Limits.getLimitHeapSize()/100;
        Integer intQueriesLimit = intLimitPercent *  Limits.getLimitQueries()/100;
        system.debug(LoggingLevel.WARN, 'CPU Limit = ' + intCPUTimeLimit + '; Heap Limit = ' + intHeapLimit + '; Query Limit = ' + intQueriesLimit);
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        
        if(Limits.getQueries() >= intQueriesLimit || Limits.getHeapSize() >= intHeapLimit || Limits.getCpuTime() >= intCPUTimeLimit){
            INTF_DataSync.logMethodEndTS(intMethodCount,'isLimitReached');
            return true;
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'isLimitReached');
        return false;
    }

    //Keeping this method mininal as it is being called from putInsert and putUpdate - no EMPP logging, no debug logs and called for internal batching between each record processing
    public boolean isInternalLimitReached(){
        integer intLimitPercent = (integer)INTF_TxnCache.get('LIMIT_QUERY', 'integer');
        if(intLimitPercent == null)
        {
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String, String> mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', new list<String>{'SET011'});
            if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
                intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
            else
                intLimitPercent = 70;
            INTF_TxnCache.put('LIMIT_QUERY', intLimitPercent, 'integer');
        }
        Integer intCPUTimeLimit = intLimitPercent * Limits.getLimitCpuTime()/100;
        Integer intHeapLimit = intLimitPercent * Limits.getLimitHeapSize()/100;

        if(Limits.getHeapSize() >= intHeapLimit || Limits.getCpuTime() >= intCPUTimeLimit){
            return true;
        }
        return false;
    }
    
    public string getRecIdfromJSON(string strJSON)
    {
        string recId;
        Map<String, Object> mapJSON = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        recId = (string)mapJSON.get('Id');
        return recId;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse oneCallSync(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('oneCallSync');
        system.debug(loggingLevel.WARN, ' Inside One Call sync: ' + system.now());
        boolean isCallBack = false;
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        string strCallBackContext, strUserId = null, strDeviceUDID = null, strSyncReqId = '';
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        if(inputRequest == null)
        {
            response.success = false;
            response.message = 'Empty request. Unable to perform sync.';
            INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
            return response;
        }
        
        mapClientDetails = (new INTF_ConfigSync()).getClientData(inputRequest);
        system.debug(loggingLevel.WARN, 'mapClientDetails = ' + mapClientDetails);
        
        for(INTF_WebServicesDef.SVMXMap reqVM : inputRequest.valueMap)
        {
            system.debug(loggingLevel.WARN, 'Each ValueMap in request: ' + reqVM);
            if(reqVM.key == 'CALL_BACK')
            {
                isCallBack = boolean.valueOf(reqVM.value);
                if(isCallBack)
                {
                    INTF_TxnCache.restore(mapClientDetails, inputRequest.value);
                    if(reqVM.valueMap != null)
                    {
                        for(INTF_WebServicesDef.SVMXMap innerVM : reqVM.valueMap)
                        {
                            if(innerVM.key == 'CALL_BACK_CONTEXT')
                                strCallBackContext = innerVM.value;
                            else if(innerVM.key == 'PUT_INSERT_TIME_STAMP')
                                dt_PutUpdate = dateTime.valueOf(innerVM.value);
                        }
                    }
                }
                break;
            }
        }
        
        system.debug(loggingLevel.WARN, '1. Call Back information: ' + isCallBack + ' :Call Back Context: ' + strCallBackContext);
        
        strUserId = mapClientDetails.get('userid');
        strDeviceUDID = mapClientDetails.get('clientudid');
        strSyncReqId = inputRequest.value;
        
        if(!isCallBack)
        {
            if(allObjs.get('svmxc__sm_request_cache__c') == null || strUserId == null || strDeviceUDID == null)
            {
                isRequestCache = false;
                List<SVMXC__Sync_Request__c> sync_requests = (List<SVMXC__Sync_Request__c>)INTF_TxnCache.get('SYNC_REQUEST_REC', 'List<SVMXC__Sync_Request__c>');
                dt_PutUpdate = (dateTime)INTF_TxnCache.get('SYNC_START_TIME', 'dateTime');
                system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dt_PutUpdate);
                if(sync_requests == null || sync_requests.size() == 0)
                {
                    INTF_DataSync.logSOQL(intMethodCount, 'Select Id, CreatedDate,SVMXC__Client_Request_Id__c from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
                    sync_requests =[Select Id, CreatedDate,SVMXC__Client_Request_Id__c from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    INTF_TxnCache.put('SYNC_REQUEST_REC', sync_requests, 'List<SVMXC__Sync_Request__c>');
                }
                else if(sync_requests[0].SVMXC__Client_Request_Id__c != inputRequest.value)
                {
                    INTF_DataSync.logSOQL(intMethodCount, 'Select Id, CreatedDate, SVMXC__Client_Request_Id__c from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
                    sync_requests =[Select Id, CreatedDate, SVMXC__Client_Request_Id__c from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    INTF_TxnCache.put('SYNC_REQUEST_REC', sync_requests, 'List<SVMXC__Sync_Request__c>');
                }
                if (sync_requests == null || sync_requests.size() <= 0)
                {
                    sync_requests = new List<SVMXC__Sync_Request__c>();
                    SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = inputRequest.value);
                    Database.SaveResult Result = Database.insert(requestRecord);
                    INTF_DataSync.logSOQL(intMethodCount, 'Select Id, CreatedDate, SVMXC__Client_Request_Id__c from SVMXC__Sync_Request__c where Id = :Result.getId() limit 1');
                    SVMXC__Sync_Request__c newRequestRecord = [Select Id, CreatedDate, SVMXC__Client_Request_Id__c from SVMXC__Sync_Request__c where Id = :Result.getId() limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    dt_PutUpdate = newRequestRecord.CreatedDate;
                    sync_requests.add(newRequestRecord);
                    INTF_TxnCache.put('SYNC_REQUEST_REC', sync_requests, 'List<SVMXC__Sync_Request__c>');
                    INTF_TxnCache.put('SYNC_START_TIME', dt_PutUpdate, 'dateTime');
                }
                else
                {
                    INTF_TxnCache.put('SYNC_START_TIME', sync_requests[0].CreatedDate, 'dateTime');
                    dt_PutUpdate = sync_requests[0].CreatedDate;
                }
            }
            else
            {
                isRequestCache = true;
                DateTime dtNewSyncStartTime = DateTime.now();
                List<SVMXC__SM_Request_Cache__c> lstRequestCache = new List<SVMXC__SM_Request_Cache__c>();
                INTF_DataSync.logSOQL(intMethodCount, 'Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID');
                lstRequestCache = [Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                if(lstRequestCache != null && lstRequestCache.size() >= 1)
                {
                    system.debug(LoggingLevel.WARN, 'request id =  ' + lstRequestCache[0].SVMXC__SM_Client_Sync_Request_Id__c + '; strSyncReqId = '  + strSyncReqId);
                    if(lstRequestCache[0].SVMXC__SM_Client_Sync_Request_Id__c != strSyncReqId)
                    {
                        //make all txn fields blank or null
                        singleCacheRec = lstRequestCache[0];
                        system.debug(LoggingLevel.WARN, 'singleCacheRec id =  ' + singleCacheRec.Id);
                        singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
                        singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
                        singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
                        singleCacheRec.SVMXC__SM_Sync_Start_Time__c = dtNewSyncStartTime;
                        singleCacheRec.SVMXC__SM_Application_Filters__c = '';
                        singleCacheRec.SVMXC__SM_Application_Name__c = '';
                        singleCacheRec.SVMXC__SM_Application_Version__c = '';
                        singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c = '';
                        singleCacheRec.SVMXC__SM_Device_Type__c = '';
                        singleCacheRec.SVMXC__SM_Doc_Template_IDs__c = '';
                        singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c = '';
                        singleCacheRec.SVMXC__SM_Download_Criteria_Object_List__c = '';
                        singleCacheRec.SVMXC__SM_Expression_IDs__c = '';
                        singleCacheRec.SVMXC__SM_Group_Profile_Id__c = '';
                        singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c = '';
                        singleCacheRec.SVMXC__SM_Object_Access__c = '';
                        singleCacheRec.SVMXC__SM_Object_Definitions__c = '';
                        singleCacheRec.SVMXC__SM_Object_Name__c = '';
                        singleCacheRec.SVMXC__SM_Page_Layout_IDs__c = '';
                        singleCacheRec.SVMXC__SM_Picklist_Definitions__c = '';
                        singleCacheRec.SVMXC__SM_Settings__c = '';
                        singleCacheRec.SVMXC__SM_SFM_Mappings__c = '';
                        singleCacheRec.SVMXC__SM_SFM_Process_IDs__c = '';
                        singleCacheRec.SVMXC__SM_SFM_Translations__c = '';
                        singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c = '';
                        singleCacheRec.SVMXC__SM_SFW_Translations__c = '';
                        singleCacheRec.SVMXC__SM_SOQL_Query__c = '';
                        singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = '';  
                        singleCacheRec.SVMXC__SM_Event_What_IDs__c = '';                      
                        dt_PutUpdate = dtNewSyncStartTime;
                        Database.Upsertresult result = Database.upsert(singleCacheRec, false);
                        INTF_DataSync.logSOQL(intMethodCount,'Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where ID =:result.getId()');
                        singleCacheRec = [Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where ID =:result.getId()];
                        system.debug(LoggingLevel.WARN, 'singleCacheRec =  ' + singleCacheRec);
                    }
                    else
                    {
                        //use the record as it is because the earlier sync would have not completed somehow as the request id is same
                        singleCacheRec = lstRequestCache[0];
                        dt_PutUpdate = singleCacheRec.SVMXC__SM_Sync_Start_Time__c;
                    }
                }
                else
                {
                    //create new
                    singleCacheRec = new SVMXC__SM_Request_Cache__c();
                    singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
                    singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
                    singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
                    singleCacheRec.SVMXC__SM_Sync_Start_Time__c = dtNewSyncStartTime;
                    dt_PutUpdate = dtNewSyncStartTime;
                    Database.Upsertresult result = Database.upsert(singleCacheRec, false);
                }
                system.debug(LoggingLevel.WARN, 'dtNewSyncStartTime = ' + dtNewSyncStartTime);
            }
        }
        
        system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dt_PutUpdate + '; singleCacheRec = ' + singleCacheRec);
        
        if(isCallBack && strCallBackContext != null && strCallBackContext.length() > 0)
        {
            if(strCallBackContext == 'GET_DELETE_DC_OPTIMZED'){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
                return executeSync(2, inputRequest, response);
            }else if(strCallBackContext == 'PUT_DELETE'){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
                return executeSync(3, inputRequest, response);
            }else if(strCallBackContext == 'PUT_INSERT'){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
                return executeSync(4, inputRequest, response);
            }else if(strCallBackContext == 'PUT_UPDATE'){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
                return executeSync(5, inputRequest, response);
            }else if(strCallBackContext == 'GET_UPDATE'){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
                return executeSync(6, inputRequest, response);
            }else if(strCallBackContext == 'GET_UPDATE_DC_OPTIMZED'){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
                return executeSync(7, inputRequest, response);
            }
        }
        else
        {
            INTF_WebServicesDef.SVMXMap syncTime = new INTF_WebServicesDef.SVMXMap('LAST_SYNC', String.valueOf(Datetime.now()));
            response.valueMap.add(syncTime);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'oneCallSync');
        return executeSync(1, inputRequest, response);
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse executeSync(integer executeFrom, INTF_WebServicesDef.INTF_SFMRequest inputRequest, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('executeSync');
        INTF_WebServicesDef.INTF_SFMRequest putUpdateReq;
        INTF_WebServicesDef.INTF_SFMRequest putDeleteReq;
        INTF_WebServicesDef.INTF_SFMRequest putInsertReq;
        Map<String, DateTime> mapIdToRecordLST = new map<String, Datetime>();
        dateTime putUpdateLST;
        //device specific setting
        string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);                
        for(INTF_WebServicesDef.SVMXMap reqVM : inputRequest.valueMap)
        {
            if(reqVM.key == 'PUT_UPDATE' && reqVM.lstInternal_Request != null && reqVM.lstInternal_Request.size() > 0 && reqVM.lstInternal_Request[0].eventName == 'PUT_UPDATE')
                putUpdateReq = reqVM.lstInternal_Request[0];
            else if(reqVM.key == 'PUT_DELETE' && reqVM.lstInternal_Request != null && reqVM.lstInternal_Request.size() > 0 && reqVM.lstInternal_Request[0].eventName == 'PUT_DELETE')
                putDeleteReq = reqVM.lstInternal_Request[0];
            else if(reqVM.key == 'PUT_INSERT' && reqVM.lstInternal_Request != null && reqVM.lstInternal_Request.size() > 0 && reqVM.lstInternal_Request[0].eventName == 'PUT_INSERT')
                putInsertReq = reqVM.lstInternal_Request[0];
            else if(reqVM.key == 'TS_KEYS' && reqVM.value != NULL && reqVM.Value != ''){
                    mapIdToRecordLST = (Map<String, Datetime>)JSON.deserialize(reqVM.value, Map<String, Datetime>.Class);
            }else if(reqVM.key == 'BATCHING_ENABLED' && reqVM.value != NULL && reqVM.Value != ''){
                intBatchEnabled = Boolean.valueof(reqVM.value);
            } 
        }
        
        system.debug(loggingLevel.WARN, '2. Sync is being executed from: ' + executeFrom + '; isRequestCache = ' + isRequestCache);
        
        //Get Delete
        if(executeFrom <= 1)
        {
            system.debug(loggingLevel.WARN, '3. Executing Get Delete.');
            inputRequest.eventName = 'GET_DELETE';
            INTF_DataSync.logEventStartTS('GET_DELETE');
            response = getEventsAndRelatedRecords(inputRequest, response);
            INTF_DataSync.updateMethodList();
            INTF_DataSync.logEventEndTS('GET_DELETE');
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
        }
        
        //Get Delete Download Criteria
        if(executeFrom <= 2)
        {
            if(limitCheck(inputRequest.value, 'GET_DELETE_DC_OPTIMZED', response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            
            system.debug(loggingLevel.WARN, '4. Executing Get Delete DC.');
            inputRequest.eventName = 'GET_DELETE_DC_OPTIMZED';
            
            INTF_DataSync.logEventStartTS('GET_DELETE_DC_OPTIMZED');
            if(isRequestCache)
                response = getIncrementalDCrecords(inputRequest, response);
            else    
                response = getCriteriaRecords(inputRequest, response);
            INTF_DataSync.updateMethodList();    
            INTF_DataSync.logEventEndTS('GET_DELETE_DC_OPTIMZED');
                
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            if(isInternalCallBack(inputRequest.value, response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
        }
        
        //Put Delete
        if(executeFrom <= 3 && putDeleteReq != null)
        {
            if(limitCheck(inputRequest.value, 'PUT_DELETE', response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            
            system.debug(loggingLevel.WARN, '5. Executing Put Delete.');
            INTF_DataSync.logEventStartTS('PUT_DELETE');
            response = putDelete(putDeleteReq, response);
            INTF_DataSync.updateMethodList();
            INTF_DataSync.logEventEndTS('PUT_DELETE');
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
        }
        
        //Put Insert
        if(executeFrom <= 4 && putInsertReq != null)
        {
            if(limitCheck(inputRequest.value, 'PUT_INSERT', response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            
            system.debug(loggingLevel.WARN, '6. Executing Put Insert Request : ' + putInsertReq);
            INTF_DataSync.logEventStartTS('PUT_INSERT');
            response = putInsert(putInsertReq, response);
            INTF_DataSync.updateMethodList();
            INTF_DataSync.logEventEndTS('PUT_INSERT');
            
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            if(isInternalBatch){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                addCallBackContext(inputRequest.value, 'PUT_INSERT', response);
                return response;
            }
            for(INTF_WebServicesDef.SVMXMap webServiceVM: putInsertReq.valueMap)
            {
                system.debug(loggingLevel.WARN, 'Put Insert Value Map =  : ' + webServiceVM);
                //If AFter Insert webservice OR newly created record in client, in these two cases break the sync.
                if(webServiceVM.key == 'After_Insert_Web_Service' && webServiceVM.value == 'true')
                {
                    addCallBackContext(inputRequest.value, 'PUT_UPDATE', response);
                    return response;
                }
            }
        }
        
        //Put Update
        if(executeFrom <= 5 && putUpdateReq != null)
        {
            if(limitCheck(inputRequest.value, 'PUT_UPDATE', response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }

            system.debug(loggingLevel.WARN, '7. Executing Put Update.' + putUpdateReq);
            INTF_DataSync.logEventStartTS('PUT_UPDATE');
            response = putUpdate(putUpdateReq, response,strDeviceType, mapIdToRecordLST);
            INTF_DataSync.updateMethodList();
            INTF_DataSync.logEventEndTS('PUT_UPDATE');
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            if(isInternalBatch){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                addCallBackContext(inputRequest.value, 'PUT_UPDATE', response);
                return response;
            }
        }
        //Get Update
        if(executeFrom <= 6)
        {
            if(limitCheck(inputRequest.value, 'GET_UPDATE', response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            system.debug(loggingLevel.WARN, '8. Executing Get Update.');
            inputRequest.eventName = 'GET_UPDATE';
            INTF_DataSync.logEventStartTS('GET_UPDATE');
            response = getEventsAndRelatedRecords(inputRequest, response);
            INTF_DataSync.updateMethodList();
            INTF_DataSync.logEventEndTS('GET_UPDATE');
            
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            
            for(INTF_WebServicesDef.SVMXMap reqVM : inputRequest.valueMap)
            {
                if(reqVM.key == 'LAST_INDEX')
                {
                    reqVM.value = '0';
                    break;
                }
            }
        }
        
        //Get Update Download Criteria
        if(executeFrom <= 7)
        {
            if(limitCheck(inputRequest.value, 'GET_UPDATE_DC_OPTIMZED', response))
            {
                for(INTF_WebServicesDef.SVMXMap resVM : response.valueMap)
                {
                    if(resVM.key == 'LAST_INDEX')
                    {
                        resVM.value = '0';
                        break;
                    }
                }
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
            system.debug(loggingLevel.WARN, '9. Executing Get Update DC.');
            inputRequest.eventName = 'GET_UPDATE_DC_OPTIMZED';
            
            INTF_DataSync.logEventStartTS('GET_UPDATE_DC_OPTIMZED');
            if(isRequestCache)
                response = getIncrementalDCrecords(inputRequest, response);
            else    
                response = getCriteriaRecords(inputRequest, response);
                
            INTF_DataSync.updateMethodList(); 
            INTF_DataSync.logEventEndTS('GET_UPDATE_DC_OPTIMZED');
            
            if(response.success == false){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
         
            if(isInternalCallBack(inputRequest.value, response)){
                INTF_DataSync.eventCount = 1;
                INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
                return response;
            }
        }
        response.eventName = 'ONE_CALL_SYNC';
        INTF_DataSync.eventCount = 1;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'executeSync');
        return response;
    }
    
    public boolean isInternalCallBack(string syncReqId, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('isInternalCallBack');
        for(INTF_WebServicesDef.SVMXMap resVM: response.valueMap)
        {
            if(resVM.key == 'GET_DELETE_DC_OPTIMZED' || resVM.key == 'GET_UPDATE_DC_OPTIMZED')
            {
                for(INTF_WebServicesDef.SVMXMap innerVM : resVM.valueMap)
                {
                    if(innerVM.key == 'CALL_BACK')
                    {
                        addCallBackContext(syncReqId, resVM.key, response);
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'isInternalCallBack');
                        return true;
                    }
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'isInternalCallBack');
        return false;
    }
    
    public void addLimitVM(string strContext, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        INTF_WebServicesDef.SVMXMap limitVm = new INTF_WebServicesDef.SVMXMap();
        limitVm.key = 'Limits after Call of ' + strContext;
        limitVm.value = '1. SOQL : ' + Limits.getQueries() + ' : 2. Heap Size : ' + Limits.getHeapSize();
        response.valueMap.add(limitVm);
    }
    
    public boolean limitCheck(string syncReqId, string strContext, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('limitCheck');
        system.debug(LoggingLevel.WARN, 'Sync Request Id = ' + syncReqId);
        if(isLimitReached())
        {
            addCallBackContext(syncReqId, strContext, response);
            INTF_DataSync.logMethodEndTS(intMethodCount, 'limitCheck');
            return true;
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'limitCheck');
        return false;
    }
    
    public void addCallBackContext(string syncReqId, string strContext, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCallBackContext');
        if(isRequestCache)
            INTF_TxnCache.save(mapClientDetails, syncReqId);
        else
            INTF_TxnCache.save(syncReqId);
        INTF_WebServicesDef.SVMXMap call_back_Context = new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT', strContext);
        INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
        call_back.valueMap = new List<INTF_WebServicesDef.SVMXMap>{call_back_Context};
        response.valueMap.add(call_back);
        
        if(strContext == 'PUT_UPDATE' && dt_PutUpdate != null)
        {
            INTF_WebServicesDef.SVMXMap put_insert_DT = new INTF_WebServicesDef.SVMXMap('PUT_INSERT_TIME_STAMP', string.valueOf(dt_PutUpdate));
            call_back.valueMap.add(put_insert_DT);  
        }
        response.eventName = 'ONE_CALL_SYNC';
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addCallBackContext');
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse putUpdate(INTF_WebServicesDef.INTF_SFMRequest putUpdateReq, INTF_WebServicesDef.INTF_SFMResponse response,string strDeviceType, Map<String, DateTime> mapIdToRecordLST)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('putUpdate');
        INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap();
        putUpdateVM.key = 'PUT_UPDATE';
        putUpdateVM.lstInternal_Response = new List<INTF_WebServicesDef.INTF_SFMResponse>();
        INTF_WebServicesDef.INTF_SFMResponse res = UpdateClientDataIntoBase(putUpdateReq,strDeviceType,mapIdToRecordLST);
        putUpdateVM.lstInternal_Response.add(res);
        response.valueMap.add(putUpdateVM);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'putUpdate');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse putInsert(INTF_WebServicesDef.INTF_SFMRequest putInsertReq, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('putInsert');
        INTF_WebServicesDef.INTF_SFMResponse res;
        if(isRequestCache)
            res = insertClientData(putInsertReq);
        else
            res = (new INTF_DataUtilityServices()).InsertClientDataIntoBase(putInsertReq);
        
        INTF_WebServicesDef.SVMXMap putInsertResVM = new INTF_WebServicesDef.SVMXMap();
        putInsertResVM.key = 'PUT_INSERT';
        putInsertResVM.lstInternal_Response = new List<INTF_WebServicesDef.INTF_SFMResponse>();
        putInsertResVM.lstInternal_Response.add(res);
        response.valueMap.add(putInsertResVM);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'putInsert');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse putDelete(INTF_WebServicesDef.INTF_SFMRequest putDeleteReq, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('putDelete');
        INTF_WebServicesDef.INTF_SFMResponse res;
        if(isRequestCache)
            res = deleteClientData(putDeleteReq);
        else
            res = (new INTF_DataUtilityServices()).SendClientDeletesToBase(putDeleteReq);
        
        INTF_WebServicesDef.SVMXMap putDeleteResVM = new INTF_WebServicesDef.SVMXMap();
        putDeleteResVM.key = 'PUT_DELETE';
        putDeleteResVM.lstInternal_Response = new List<INTF_WebServicesDef.INTF_SFMResponse>();
        putDeleteResVM.lstInternal_Response.add(res);
        response.valueMap.add(putDeleteResVM);
        INTF_DataSync.logMethodEndTS(intMethodCount,'putDelete');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getCriteriaRecords(INTF_WebServicesDef.INTF_SFMRequest inputRequest, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getCriteriaRecords');
        INTF_WebServicesDef.SVMXMap mainVMDC = new INTF_WebServicesDef.SVMXMap();
        mainVMDC.key = inputRequest.eventName;
        mainVMDC.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        Datetime LastSynchTime;
        String strOldTechLocId = '', Record_id;
        List<String> recordIds = new List<String>();
        List<String> lstUserTrunk = new List<String>();
        List<INTF_WebServicesDef.SVMXMap> masterWrapList;
        Set<String> setOldPriceBookIds = new Set<String>();
        Set<String> setOldServicePriceBookIds = new Set<String>();
        List<INTF_WebServicesDef.SVMXMap> reqValMap = inputRequest.valueMap;
        Iterator<INTF_WebServicesDef.SVMXMap> inputIterator = reqValMap.iterator();
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__Sync_Request_Records__c> criteriaObjects = new List<SVMXC__Sync_Request_Records__c>();
        Datetime dtCurrentTime = Datetime.now();
        String strDeviceName = '';  
                
        if(inputRequest.values != null)
            recordIds = inputRequest.values;
        else
            recordIds.add(null);
            
        for(INTF_WebServicesDef.SVMXMap TimeStampMap : inputRequest.valueMap)
        {
            system.debug(LoggingLevel.WARN, 'Each ValueMap in request of DC = ' + TimeStampMap);
            if(TimeStampMap.key == 'LAST_SYNC_TIME')
            {
                LastSynchTime = Datetime.valueOf(TimeStampMap.value);
                //break;
            }
            else if(TimeStampMap.key == 'PRICEBOOK_IDs')
            {
                if(TimeStampMap.values != null && TimeStampMap.values.size() > 0)
                    setOldPriceBookIds.addAll(TimeStampMap.values);
            }
            else if(TimeStampMap.key == 'SERVICE_PRICEBOOK_IDs')
            {
                if(TimeStampMap.values != null && TimeStampMap.values.size() > 0)
                    setOldServicePriceBookIds.addAll(TimeStampMap.values);
            }
        }
        
        if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
        {
            for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
            {
                for(String strInfo : clientInform.clientInfo)
                {
                    if(strInfo != null && strInfo.length() > 0 && strInfo.contains('usertrunklocation'))
                    {
                        lstUserTrunk = strInfo.split(':');
                        if(lstUserTrunk != null && lstUserTrunk.size() == 2)
                            strOldTechLocId = lstUserTrunk[1];
                    }
                }
                //Get Device type       
                if(clientInform.clientType != null){        
                    strDeviceName = clientInform.clientType;        
                }                   
            }
        }
        system.debug(LoggingLevel.WARN, 'Technician Location Id = ' + strOldTechLocId);
        List<SVMXC__Sync_Request__c> Sync_request_id = (List<SVMXC__Sync_Request__c>)INTF_TxnCache.get('SYNC_REQUEST_REC', 'List<SVMXC__Sync_Request__c>');
        if(Sync_request_id == null || Sync_request_id.size() == 0)
        {
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
            Sync_request_id =[Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            INTF_TxnCache.put('SYNC_REQUEST_REC', Sync_request_id, 'List<SVMXC__Sync_Request__c>');
        }
        //added here as used internally also
        Record_id = Sync_request_id[0].id;
        
        if(Sync_request_id.size()>0){
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Iteration_Index__c, SVMXC__Object_Name__c, SVMXC__SOQL_Query__c, SVMXC__Status__c, SVMXC__Record_Id__c, SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Operation_Type__c = \'Select\' and SVMXC__Sync_Request__c =: Sync_request_id[0].id');
            criteriaObjects = [Select Id, SVMXC__Iteration_Index__c, SVMXC__Object_Name__c, SVMXC__SOQL_Query__c, SVMXC__Status__c, SVMXC__Record_Id__c, SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Operation_Type__c = 'Select' and SVMXC__Sync_Request__c =: Sync_request_id[0].id];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        try
        {
            if(criteriaObjects.size() <= 0)
            {
                masterWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                List<SVMXC__Sync_Request_Records__c> DCObjectList = new List<SVMXC__Sync_Request_Records__c>();
                String deltaClause;
                Set<String> setDCPriceCalcObjects = new Set<String>();
                Set<String> setPriceCalObjects = new Set<String>{'SVMXC__Entitlement_History__c', 'SVMXC__Warranty__c', 'SVMXC__Service_Contract__c', 'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c', 'Pricebook2', 'PricebookEntry', 'SVMXC__Service_Pricebook__c', 'SVMXC__Service_Pricebook_Entry__c', 'SVMXC__Custom_Coverage__c'};
                
                if (inputRequest.eventName == 'GET_UPDATE_DC_OPTIMZED')
                    deltaClause = ' LastModifiedDate >= :LastSynchTime and isDeleted = false ';
                else if (inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                {
                    deltaClause = ' LastModifiedDate >= :LastSynchTime and isDeleted = true ';
                    
                    Boolean isGetPriceEnabled = (boolean)INTF_TxnCache.get('IPAD018_SET009', 'Boolean');
                    if(isGetPriceEnabled == null)
                    {
                        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                        List<String> lstSettingId = new list<String>();
                        lstSettingId.add('SET009');
                        Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
                        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
                        if(mapSettingsForIPAD018.containskey('SET009') && mapSettingsForIPAD018.get('SET009') != null)
                        {
                            isGetPriceEnabled = Boolean.valueOf(mapSettingsForIPAD018.get('SET009'));
                        }
                        else
                            isGetPriceEnabled = false;
                        
                        INTF_TxnCache.put('IPAD018_SET009', isGetPriceEnabled, 'Boolean');
                    }
                    
                    if(isGetPriceEnabled)   
                        setDCPriceCalcObjects.addAll(setPriceCalObjects);
                }
                String strCurrTechLocId = '';
                INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
                for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
                {
                    if(eachTech.SVMXC__Inventory_Location__c != null)
                        strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
                }
                Map<String, INTF_WebServicesDef.SVMXMap> mapDownloadCriteriaObjDefns = new Map<String, INTF_WebServicesDef.SVMXMap>(); 
                mapDownloadCriteriaObjDefns = getDownloadCriteriaObjDefns(strDeviceName);
                
                setDCPriceCalcObjects.addAll(mapDownloadCriteriaObjDefns.keySet());
                system.debug(LoggingLevel.WARN, 'Set of Objects' + setDCPriceCalcObjects);
                if(mapDownloadCriteriaObjDefns != null && !mapDownloadCriteriaObjDefns.isEmpty())
                {
                    List<String> objs_clauses = new List<String>();
                    for(String objName: setDCPriceCalcObjects)
                    {
                        system.debug(LoggingLevel.WARN, ' DC Object Name = ' + objName + ', value = ' + mapDownloadCriteriaObjDefns.get(objName));
                        if(objName == 'User')
                        {
                            deltaClause = deltaClause.replace('isDeleted = false','isActive = true');
                            deltaClause = deltaClause.replace('isDeleted = true','isActive = false');
                        }
                        else 
                        {
                            deltaClause = deltaClause.replace('isActive = true','isDeleted = false');
                            deltaClause = deltaClause.replace('isActive = false','isDeleted = true');
                        }
                        String strQuery = 'SELECT Id FROM ' + objName + ' WHERE ';
                        if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                        {
                            if(mapDownloadCriteriaObjDefns.get(objName) != NULL)
                            {
                                if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                {
                                    strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                }
                            }
                            strQuery += deltaClause + ' and ';
                        }
                        else if(inputRequest.eventName == 'GET_UPDATE_DC_OPTIMZED')
                        {
                            if(mapDownloadCriteriaObjDefns.get(objName).values != null && mapDownloadCriteriaObjDefns.get(objName).values.size() > 0)
                            {
                                if(Datetime.valueOfGmt(mapDownloadCriteriaObjDefns.get(objName).values[0]) > LastSynchTime)
                                {
                                    if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                    }
                                }
                                else if(mapDownloadCriteriaObjDefns.get(objName).record != null)
                                { 
                                    if(((SVMXC__ServiceMax_Processes__c)mapDownloadCriteriaObjDefns.get(objName).record).LastModifiedDate > LastSynchTime)
                                    {
                                        if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                        {
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                        }
                                    }
                                    else if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        if(mapDownloadCriteriaObjDefns.get(objName).value.containsIgnoreCase('USERTRUNK') && strCurrTechLocId != strOldTechLocId)
                                        {
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                        }
                                        else if(objName == 'Pricebook2')
                                            strQuery +=  ' ((' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID IN:setOldPriceBookIds AND ' + deltaClause + ') OR (' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID NOT IN:setOldPriceBookIds)) AND ';
                                        else if(objName == 'SVMXC__Service_Pricebook__c')
                                            strQuery +=  ' ((' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID IN:setOldServicePriceBookIds AND ' + deltaClause + ') OR (' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID NOT IN:setOldServicePriceBookIds)) AND ';
                                        else
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ' + deltaClause + ' and ';
                                    }
                                }
                                else
                                {
                                    if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                    }
                                    strQuery += deltaClause + ' and ';
                                }
                            }
                        }
                        
                        system.debug(LoggingLevel.WARN, ' Query for Each DC Object' + strQuery);
                        strQuery = strQuery.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                        strQuery = strQuery.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());
                        strQuery = strQuery.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                        strQuery = strQuery.replace('SVMX.USERTRUNK', strCurrTechLocId);
                        
                        Map<String, String> mapSFCSToValue = (new INTF_DataUtilityServices()).replaceLiteralWithValue(strQuery);
                        for(String eachLiteral : mapSFCSToValue.keySet())
                        {
                            system.debug(LoggingLevel.Debug, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                            if(mapSFCSToValue.get(eachLiteral) !=null && mapSFCSToValue.get(eachLiteral) !=''){
                                    strQuery = strQuery.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                            }else{
                                    strQuery = strQuery.replace(eachLiteral, '');
                            }
                        }
                        system.debug(LoggingLevel.Debug, 'After Replace = ' + strQuery);
                        
                        if(inputRequest.eventName == 'GET_UPDATE_DC_OPTIMZED' || inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                        {
                            SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select', SVMXC__Iteration_Index__c = 0, SVMXC__Object_Name__c = objName, SVMXC__SOQL_Query__c = strQuery, SVMXC__Status__c = 'NOT_EXECUTED');
                            DCObjectList.add(DCObjects);
                        }
                        if(mapDownloadCriteriaObjDefns.get(objName) != null)
                        {
                            String werClause = mapDownloadCriteriaObjDefns.get(objName).value;
                            Blob blobStr = blob.valueOf(werClause);
                            String encodeStr = EncodingUtil.base64Encode(blobStr); 
                            objs_clauses.add(objName + ',' + encodeStr);
                        }
                    }
                    
                    INTF_WebServicesDef.SVMXMap DC_Objects = new INTF_WebServicesDef.SVMXMap();
                    DC_Objects.key = 'DOWNLOAD_CRITERIA_OBJECTS';
                    DC_Objects.values = objs_clauses;
                    masterWrapList.add(DC_Objects);
                    System.debug(LoggingLevel.WARN, 'master wrap list' + masterWrapList);
                }
                mainVMDC.valueMap.addAll(masterWrapList);
                List<Database.Saveresult> ObjectSaveResult = Database.insert(DCObjectList);
                system.debug(loggingLevel.WARN, 'DC Object List=: ' + DCObjectList);
                criteriaObjects.addAll(DCObjectList);
            }
            //else
            if(criteriaObjects.size() > 0)
            {
                system.debug(loggingLevel.WARN, '===Criteria Objects=: ' + criteriaObjects);
                List<String> SFDC_Records = new List<String>();
                INTF_DataSync.logSOQL(intMethodCount, 'Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = :inputRequest.value and SVMXC__Operation_Type__c != \'Select\'');
                for(SVMXC__Sync_Request_Records__c request_record : [Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = :inputRequest.value and SVMXC__Operation_Type__c != 'Select'])
                {
                    if(request_record.SVMXC__SFDC_Record_Id__c != null)
                        SFDC_Records.add(request_record.SVMXC__SFDC_Record_Id__c);
                }
                system.debug(loggingLevel.WARN, '===SFDC Records=: ' + SFDC_Records);
                
                List<INTF_WebServicesDef.SVMXMap> multiWrapList;
                Integer batch_index, current_batch_index;
                String HighestId , LowestId;
                Integer recordsLimit = 35000; 
                
                map<String, String> mapSettingsForIPAD018 = (map<String, String>)INTF_TxnCache.get('IPAD018_SET006', 'Map<String, String>');
                if(mapSettingsForIPAD018 == null || mapSettingsForIPAD018.size() == 0)
                {
                    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                    list<String> lstSettingId = new list<String>();
                    lstSettingId.add('SET006');
                    mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                    
                    INTF_TxnCache.put('IPAD018_SET006', mapSettingsForIPAD018, 'Map<String, String>');
                }
                
                if(mapSettingsForIPAD018.containskey('SET006') && mapSettingsForIPAD018.get('SET006') != null && mapSettingsForIPAD018.get('SET006').length() > 0)
                    recordsLimit = Integer.valueOf(mapSettingsForIPAD018.get('SET006'));
                
                system.debug(loggingLevel.WARN, '===Records Limit=: ' + recordsLimit);
                
                if(recordsLimit < 1)
                    recordsLimit = 35000;
                
                while(inputIterator.hasNext())
                {
                    INTF_WebServicesDef.SVMXMap selObject = new  INTF_WebServicesDef.SVMXMap();
                    selObject = inputIterator.next();
                    System.debug(LoggingLevel.WARN,'sb object---'+selObject);
                    if(selObject.key == 'LAST_INDEX')
                    {
                        if(selObject != null && selObject.value != null && selObject.value.length() > 0)
                            batch_index = Integer.valueOf(selObject.value);
                        else
                            batch_index = 0;
                        current_batch_index = batch_index + 1;
                    }
                }
                
                system.debug(loggingLevel.WARN, '===Current Batch Index=: ' + current_batch_index);
                
                List<Integer> ser_batch_indexes = new List<Integer>();
                for(Integer i = 0 ; i< criteriaObjects.size(); i++)
                {
                    system.debug(loggingLevel.WARN, '===Iteration Index=: ' + criteriaObjects[i].SVMXC__Iteration_Index__c);
                    ser_batch_indexes.add(Integer.valueOf(criteriaObjects[i].SVMXC__Iteration_Index__c));
                }
                
                system.debug(loggingLevel.WARN, '===Server Batch Index List=: ' + ser_batch_indexes);
                
                ser_batch_indexes.sort();
                Integer siz = ser_batch_indexes.size();
                Integer server_higestIndex = ser_batch_indexes[siz-1];
                Integer record_count = 0;
                Boolean callBack = false;
                String strLastId = '';
                
                if(server_higestIndex == batch_index)
                {
                    for(Integer j=0 ; j < criteriaObjects.size() ; j++)
                    {
                        callBack = true;
                        if(criteriaObjects[j].SVMXC__Status__c != 'EXECUTED')
                        {
                            system.debug(LoggingLevel.WARN, 'Record Limit ' + recordsLimit);
                            if(record_count == 35000)
                            {
                                break;
                            } 
                            String query = criteriaObjects[j].SVMXC__SOQL_Query__c; 
                            HighestId = criteriaObjects[j].SVMXC__SFDC_Record_Id__c;
                            LowestId =  criteriaObjects[j].SVMXC__Record_Id__c;
                            if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && criteriaObjects[j].SVMXC__SFDC_Record_Id__c != null && criteriaObjects[j].SVMXC__SFDC_Record_Id__c.length() > 0)
                            {
                                strLastId = criteriaObjects[j].SVMXC__SFDC_Record_Id__c;
                            }
                            if(HighestId == null || HighestId == '')
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                    {
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                        query += ' Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                }
                                else 
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ALL ROWS';
                                    }
                                    else
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                    {
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                        query += ' Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                }
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ALL ROWS';
                                    }
                                    else
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            
                            system.debug(LoggingLevel.WARN, 'Query string ' + query);
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            system.debug(LoggingLevel.WARN, 'Query string ' + queryResult);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = criteriaObjects[j].SVMXC__Object_Name__c;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            system.debug(LoggingLevel.WARN,'Records limit' + recordsLimit + 'no of rows ' + queryResult.size());
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                System.debug(LoggingLevel.WARN,'In result > recordsLIMIT');
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                criteriaObjects[j].SVMXC__Record_Id__c = LowestId;
                                criteriaObjects[j].SVMXC__SFDC_Record_Id__c = HighestId;
                                criteriaObjects[j].SVMXC__Status__c = 'PARTIAL_EXECUTED';
                                criteriaObjects[j].SVMXC__Iteration_Index__c = current_batch_index;
                                update(criteriaObjects[j]);
                                
                                INTF_WebServicesDef.SVMXMap NotIn_Ids = new INTF_WebServicesDef.SVMXMap();
                                NotIn_Ids.key = 'PARTIAL_EXECUTED_OBJECT';
                                NotIn_Ids.value = criteriaObjects[j].SVMXC__Object_Name__c;
                                masterResponse.add(NotIn_Ids);
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.WARN,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                                
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                criteriaObjects[j].SVMXC__Record_Id__c = LowestId;
                                criteriaObjects[j].SVMXC__SFDC_Record_Id__c = HighestId;
                                criteriaObjects[j].SVMXC__Status__c = 'EXECUTED';
                                criteriaObjects[j].SVMXC__Iteration_Index__c = current_batch_index;
                                update(criteriaObjects[j]);
                            }
                            else if(queryResult.size() == 0)
                            {
                                System.debug(LoggingLevel.WARN,'In result == 0');
                                criteriaObjects[j].SVMXC__Status__c = 'EXECUTED';
                                criteriaObjects[j].SVMXC__Iteration_Index__c = current_batch_index;
                                update(criteriaObjects[j]);
                            }
                            if(j == criteriaObjects.size() - 1 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }                  
                    }
                    
                    if(callBack)
                    {
                        INTF_TxnCache.save(inputRequest.value);
                        INTF_WebServicesDef.SVMXMap call_back_Context = new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT', inputRequest.eventName);
                        INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack));
                        call_back.valueMap = new List<INTF_WebServicesDef.SVMXMap>{call_back_Context};
                        masterResponse.add(call_back);
                    }
                    
                    INTF_WebServicesDef.SVMXMap server_batch_index = new INTF_WebServicesDef.SVMXMap();
                    server_batch_index.key = 'LAST_INDEX';
                    server_batch_index.value = String.valueOf(current_batch_index);
                    masterResponse.add(server_batch_index);
                }
                else if(server_higestIndex > batch_index)
                {
                    for(Integer i = 0; i< criteriaObjects.size(); i++)
                    {
                        callBack = true;
                        Integer bt_Index = Integer.valueOf(criteriaObjects[i].SVMXC__Iteration_Index__c);
                        if(bt_Index == current_batch_index)
                        {
                            System.debug(LoggingLevel.WARN, 'Inside mismatch loop------');
                            if(record_count == 35000)
                            {
                                break;
                            }
                            String query = criteriaObjects[i].SVMXC__SOQL_Query__c;
                            HighestId = criteriaObjects[i].SVMXC__SFDC_Record_Id__c;
                            LowestId =  criteriaObjects[i].SVMXC__Record_Id__c;
                            
                            if(recordIds != null)
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(recordIds.size() > 0)
                                    {
                                        recordIds.sort();
                                        strLastId = recordIds[recordIds.size() - 1];
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                        query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                }
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                    {
                                        if(recordIds.size() > 0)
                                        {
                                            recordIds.sort();
                                            strLastId = recordIds[recordIds.size() - 1];
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ALL ROWS';
                                    }
                                    else
                                    {
                                        if(recordIds.size() > 0)
                                        {
                                            recordIds.sort();
                                            strLastId = recordIds[recordIds.size() - 1];
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                    query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                        query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ALL ROWS';
                                    else
                                        query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                }
                            }
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = criteriaObjects[i].SVMXC__Object_Name__c;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);  
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                INTF_WebServicesDef.SVMXMap NotIn_Ids = new INTF_WebServicesDef.SVMXMap();
                                NotIn_Ids.key = 'PARTIAL_EXECUTED_OBJECT';
                                NotIn_Ids.value = criteriaObjects[i].SVMXC__Object_Name__c;
                                masterResponse.add(NotIn_Ids);
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.WARN,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                            }
                            if(i == criteriaObjects.size() - 1 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }
                        
                        if(callBack)
                        {
                            INTF_TxnCache.save(inputRequest.value);
                            INTF_WebServicesDef.SVMXMap call_back_Context = new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT', inputRequest.eventName);
                            INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack));
                            call_back.valueMap = new List<INTF_WebServicesDef.SVMXMap>{call_back_Context};
                            masterResponse.add(call_back);
                        }
                        
                        INTF_WebServicesDef.SVMXMap server_batch_index = new INTF_WebServicesDef.SVMXMap();
                        server_batch_index.key = 'LAST_INDEX';
                        server_batch_index.value = String.valueOf(current_batch_index);
                        masterResponse.add(server_batch_index);
                    }
                }
                
                mainVMDC.valueMap.addAll(masterResponse);
                response.valueMap.add(mainVMDC);
                
                System.debug(LoggingLevel.WARN, 'Call Back = ' + callBack);
                
                //Call for Clean up Select
                if(!callBack)
                {
                    INTF_DataSync.logSOQL(intMethodCount,'Select id from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = : inputRequest.value and SVMXC__Operation_Type__c = \'Select\'');
                    List<SVMXC__Sync_Request_Records__c> sync_req_rec = [Select id from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = : inputRequest.value and SVMXC__Operation_Type__c = 'Select'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(sync_req_rec != null && sync_req_rec.size() > 0)
                        delete sync_req_rec;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug(LoggingLevel.WARN, 'inputRequest.eventName = ' + inputRequest.eventName);
                }
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getCriteriaRecords');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse deleteClientData(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('deleteClientData');
        system.debug(LoggingLevel.WARN, ' inputRequest = ' + inputRequest);
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> reqMap = inputRequest.valueMap;
        Iterator<INTF_WebServicesDef.SVMXMap> reqMapIterator = reqMap.Iterator();
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        map<String, map<String, String>> mapDelOperationToIds = new map<String, map<String, String>>();
        List<INTF_WebServicesDef.SVMXMAP> respValueMap;
        ErrorHeader.key = 'ERROR';
        try
        {   
            List<String> lstSFIDs = new List<String>();
            
            mapDelOperationToIds = getCachedLocalIdsForInsertAndDel(singleCacheRec); 
            
            if(mapDelOperationToIds.get('DELETE') != null && mapDelOperationToIds.get('DELETE').size() > 0)
                lstSFIDs.addAll(mapDelOperationToIds.get('DELETE').values());
            
            system.debug(LoggingLevel.WARN, 'lstSFIDs = ' + lstSFIDs + '; mapDelOperationToIds = ' + mapDelOperationToIds);
                
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_DELETE')
            {        
                List<INTF_WebServicesDef.SVMXMap> errorList = new List<INTF_WebServicesDef.SVMXMap>();
                respValueMap = new List<INTF_WebServicesDef.SVMXMap>();  
                while(reqMapIterator.hasNext())
                {
                    INTF_WebServicesDef.SVMXMap selMap = new INTF_WebServicesDef.SVMXMap();
                    selMap = reqMapIterator.next();
                    if(selMap.key == 'Object_Name')
                    {
                        List<Sobject> sobjList = new List<Sobject>();
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = selMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        Iterator<INTF_WebServicesDef.SVMXMap> secondMapIterator = selMap.valueMap.Iterator();
                        List<INTF_WebServicesDef.SVMXMap> idValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                        INTF_WebServicesDef.SVMXMAP parentMap = new INTF_WebServicesDef.SVMXMAP();
                        List<INTF_WebServicesDef.SVMXMAP> objValueMap;
                        while(secondMapIterator.hasNext())
                        {
                            INTF_WebServicesDef.SVMXMap selRecMap = new INTF_WebServicesDef.SVMXMap();
                            selRecMap = secondMapIterator.next();
                            if(selRecMap.key == 'Fields')
                            {
                                idValueMap = selRecMap.valueMap;
                                Iterator<INTF_WebServicesDef.SVMXMap> idMapIterator = idValueMap.Iterator();
                                while(idMapIterator.hasNext())
                                {
                                    objValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                                    Boolean idExist = false;
                                    INTF_WebServicesDef.SVMXMap selRec = new INTF_WebServicesDef.SVMXMap();
                                    selRec = idMapIterator.next();
                                    String idToDelete = selRec.value;
                                    if(lstSFIDs != null && idToDelete != null)
                                    {
                                        for(String id : lstSFIDs)
                                        {
                                            if(id.equals(idToDelete))
                                            {
                                                INTF_WebServicesDef.SVMXMAP existMap = new INTF_WebServicesDef.SVMXMAP();
                                                existMap.value = id;
                                                objValueMap.add(existMap);
                                                idExist = true;
                                                break;
                                            }
                                        }
                                    }
                                    sObject selObject;
                                    if(!idExist && idToDelete !='')
                                    {
                                            //Post API upgrade Schema.getGlobalDescribe().get() is expecting Objectname+Namespace
                                        selObject = Schema.getGlobalDescribe().get(selMap.value).newSObject(idToDelete);
                                        sobjList.add(selObject);
                                    }
                                }          
                                INTF_WebServicesDef.SVMXMap ErrorObj;
                                system.debug(LoggingLevel.WARN, 'sobjList = ' + sobjList);
                                Database.Deleteresult[] delResult = Database.delete(sobjList,false);
                                for(Database.Deleteresult selResult : delResult)
                                {
                                    INTF_WebServicesDef.SVMXMAP recordMap = new INTF_WebServicesDef.SVMXMAP();
                                    String success = 'true';
                                    if(selResult.isSuccess())
                                    {
                                        success = 'Sucess';
                                        recordMap.key = success;
                                        recordMap.value = String.valueOf(selResult.getId());
                                        objValueMap.add(recordMap);
                                        
                                        map<String, String> mapObjectToIds = new map<String, String>();
                                        mapObjectToIds.put(selMap.value, selResult.getId());
                                        
                                        if(!mapDelOperationToIds.containsKey('DELETE'))
                                            mapDelOperationToIds.put('DELETE', mapObjectToIds);
                                        else
                                            mapDelOperationToIds.get('DELETE').putAll(mapObjectToIds);
                                    }
                                    else
                                    {
                                        success = 'Fail';
                                        ErrorObj = new INTF_WebServicesDef.SVMXMap();
                                        ErrorObj.key = selMap.value;
                                        Database.Error[] err = selResult.getErrors();
                                        ErrorObj.value = err[0].getMessage();
                                        
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                        child.key = '';
                                        child.value = selResult.getId();
                                        errChild.add(child);
                                        ErrorObj.valueMap = errChild;
                                        errorList.add(ErrorObj);
                                    }
                                }
                                system.debug(LoggingLevel.WARN, 'mapDelOperationToIds = ' + mapDelOperationToIds);
                                if(mapDelOperationToIds != null && mapDelOperationToIds.size() > 0)
                                {
                                    singleCacheRec = updateLocalIdsIntoCache(mapDelOperationToIds, singleCacheRec);
                                    Database.Upsertresult result = Database.upsert(singleCacheRec);
                                }
                            }
                        }
                        parentMap.valueMap = objValueMap;
                        parentMap.key = 'Object_Name';
                        parentMap.value = selMap.value;
                        respValueMap.add(parentMap);
                    }
                }
                ErrorHeader.valueMap = errorList;
                respValueMap.add(ErrorHeader);
            }
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, 'e = ' + e);
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = respValueMap;
        INTF_DataSync.logMethodEndTS(intMethodCount,'deleteClientData');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse insertClientData(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('insertClientData');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<String> localIdsParent = new List<String>();
        List<String> localIdsChild = new List<String>();
        Map<String, String> localIdMapToSFIDParent = new Map<String, String>();
        Map<String, String> localIdMapToSFIDChild = new Map<String, String>();
        Database.Saveresult [] parentsaveresult;
        Database.Saveresult [] childrensaveresult;
        map<String, map<String, String>> mapInsertOperationToIds = new map<String, map<String, String>>();
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        responseValueMap.add(new INTF_WebServicesDef.SVMXMap('PUT_INSERT_TIME', String.valueOf(DateTime.now())));
        system.debug(LoggingLevel.WARN, 'PUT_INSERT_TIME = ' + responseValueMap + 'Put Insert Request = ' + inputRequest);
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        ErrorHeader.key = 'ERROR';
        Boolean isInsertCallback = false;
        
        try
        {
            String strClientType = '';
            Map<String,String> localSFMap = new Map<String,String>();
            system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec + '; Request id = ' + inputRequest.value);
            mapInsertOperationToIds = getCachedLocalIdsForInsertAndDel(singleCacheRec); 
            system.debug(LoggingLevel.WARN, 'mapInsertOperationToIds = ' + mapInsertOperationToIds);
            
            if(mapInsertOperationToIds.get('INSERT') != null && mapInsertOperationToIds.get('INSERT').size() > 0)
                localSFMap = mapInsertOperationToIds.get('INSERT');
                        
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strClientType = clientInform.clientType;
                        break;
                    }
                }
            }

            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_INSERT'){
                List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                INTF_WebServicesDef.SVMXMap successInsertedIds = new INTF_WebServicesDef.SVMXMap('SUCCESS_RECIDS','');
                for(INTF_WebServicesDef.SVMXMap firstLevel: inputRequest.valueMap){
                    if(isInternalBatch){
                        break;
                    }
                    INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
                    List<INTF_WebServicesDef.SVMXMap> listresponseSVMXMap = new List<INTF_WebServicesDef.SVMXMap>();
                    //Large records: Maintain a map <objectName, list of IDs inserted> to send to the client
                    INTF_WebServicesDef.SVMXMap localIDMap = new INTF_WebServicesDef.SVMXMap(String.Valueof(firstLevel.value),'');

                    if(firstLevel.key == 'Parent_Object'){

                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevel.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();

                        MAP<String,String> fieldsType = new Map<String,String>();
                        Map<String, String> fieldCreateable = new Map<String, String>(); 

                        Schema.SObjectType objecttype = Schema.getGlobalDescribe().get(firstLevel.value);
                        
                        if(objDef != NULL) 
                        {
                            List<INTF_WebServicesDef.SVMXMap> objProps;
                            objProps = objdef.valueMap;
                            for(INTF_WebServicesDef.SVMXMap objProp : objProps)
                            {
                                if(objProp.key == 'FIELDPROPERTY')
                                {   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                    {
                                        for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                        {
                                            if(fldObj.key == 'TYPE')
                                                fieldsType.put(lstField.value, fldObj.value);
                                            if(fldObj.key == 'CREATEABLE')
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                        }
                                    }
                                }
                            }
                        }

                        List<sObject> sobjListParent = new List<sObject>(); 
                        for(INTF_WebServicesDef.SVMXMap secondLevel: firstlevel.valueMap){
                            if(secondLevel.key == 'Fields'){
                                sObject sObj = null;
                                String localId = null;

                                for(INTF_WebServicesDef.SVMXMap selectedObj: secondLevel.valueMap){
                                    
                                    if(intBatchEnabled && isInternalLimitReached()){   //terminate and continue with the processing
                                        system.debug(LoggingLevel.DEBUG, 'Entered limit check - Yes Limit reached');
                                        isInternalBatch = true;
                                        break;
                                    } 

                                    String SFIDIfExists = localSFMap.get(selectedObj.key);  
                                    if(SFIDIfExists != null)
                                    {
                                        localIdMapToSFIDParent.put(selectedObj.key,SFIDIfExists);
                                        listresponseSVMXMap.add(new INTF_WebServicesDef.SVMXMap(selectedObj.key, SFIDIfExists));
                                    }else{
                                        localId = selectedObj.key;
                                        localIdsParent.add(localId);

                                        sObj = objecttype.newSObject();  //create new instance 

                                        String jstr = selectedObj.value;
                                        if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                            jstr = jstr.replace('&quot;', '"');

                                        Map<string, String> nameToValueMap = (Map<string, String>)JSON.deserialize(jstr, Map<String, String>.Class);

                                        if(nameToValueMap != NULL && nameToValueMap.keySet().size() > 0){
                                            for(String fldName : nameToValueMap.keySet() ){
                                                String fldValue = nameToValueMap.get(fldName);

                                                if(fieldCreateable.get(fldName) == 'true'){
                                                    sObj = createSObject(sObj,fieldsType, fldName, fldValue );
                                                }
                                            }
                                        }
                                    }
                                    
                                    system.debug(LoggingLevel.WARN, 'Each Parent Record : ' + sObj);
                                    if(sObj != null)
                                        sobjListParent.add(sObj);
  
                                }
                                
                                system.debug(LoggingLevel.WARN, 'Printing all parent records to insert : ' + sObj);
                                //Insert these records
                                INTF_WebServicesDef.SVMXMap Error;
                                try
                                {
                                    parentsaveresult = Database.insert(sobjListParent,false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.Saveresult res : parentsaveresult)
                                    {
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(res.isSuccess())
                                        {
                                            objMap.key = localIdsParent[i];
                                            objMap.value = res.getId();
                                            listresponseSVMXMap.add(objMap);
                                            localIdMapToSFIDParent.put(localIdsParent[i], res.getId());
                                            localIDMap.values.add(localIdsParent[i]);
                                            
                                            if(!mapInsertOperationToIds.containsKey('INSERT'))
                                                mapInsertOperationToIds.put('INSERT', localIdMapToSFIDParent);
                                            else
                                                mapInsertOperationToIds.get('INSERT').putAll(localIdMapToSFIDParent);
                                        }
                                        else
                                        {
                                            Error = new INTF_WebServicesDef.SVMXMap(); 
                                            Database.Error err = res.getErrors()[0];
                                            Error.key = firstlevel.value;
                                            Error.value = err.getMessage();
                                            
                                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                            child.key = localIdsParent[i];
                                            child.value = localIdsParent[i];
                                            errChild.add(child);
                                            Error.valueMap = errChild;
                                            ErrorList.add(Error);
                                        }
                                        i++;
                                    }
                                }
                                catch(DMLException e)
                                {
                                    Error = new INTF_WebServicesDef.SVMXMap(); 
                                    Error.key = firstLevel.value;
                                    Error.value = e.getMessage();
                                    system.debug(LoggingLevel.WARN, 'Exception caught:' + e.getMessage());
                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                    child.key = localId;
                                    child.value = localId;
                                    errChild.add(child);
                                    Error.valueMap = errChild;
                                    ErrorList.add(Error);
                                }
                                sobjListParent.clear();
                                localIdsParent.clear();
                            
                            }
                        }

                        singleCacheRec = updateLocalIdsIntoCache( mapInsertOperationToIds, singleCacheRec );
                        system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
                        Database.Upsertresult result = Database.upsert(singleCacheRec);

                    }else if(firstLevel.key == 'Child_Object'){
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevel.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();

                        MAP<String,String> fieldsType = new Map<String,String>();
                        Map<String, String> fieldCreateable = new Map<String, String>(); 
                        Map<String, String> fieldReferenceto = new Map<String, String>();

                        Schema.SObjectType objecttype = Schema.getGlobalDescribe().get(firstLevel.value);

                        if(objDef != NULL) 
                        {
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                            {
                                if (objProp.key == 'FIELDPROPERTY')
                                {   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                    {
                                        List<INTF_WebServicesDef.SVMXMap> fldObjs = lstField.valueMap;
                                        Iterator<INTF_WebServicesDef.SVMXMap> it = fldObjs.iterator();
                                        while(it.hasNext())
                                        {
                                            INTF_WebServicesDef.SVMXMap checkMap = it.next();
                                            if(checkMap.key == 'REFERENCETO')
                                                fieldReferenceto.put(lstField.value, checkMap.key);
                                                //fieldReferenceto.put(checkMap.value, checkMap.key);
                                        }
                                        String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', fldObjs);
                                        if (reference_to != null)
                                            String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldObjs);
                                        for(INTF_WebServicesDef.SVMXMap fldObj : fldObjs)
                                        {
                                            if(fldObj.key == 'TYPE')
                                                fieldsType.put(lstField.value, fldObj.value);
                                            if(fldObj.key == 'CREATEABLE')
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                            
                                        }
                                    }
                                }
                            }
                        }

                        List<sObject> sobjListChild = new List<sObject>(); 
                        for(INTF_WebServicesDef.SVMXMap secondLevelMap: firstlevel.valueMap){
                                if(secondLevelMap.key == 'Fields'){
                                    sObject sObj = null;
                                    String localIdChild = null;
                                    for(INTF_WebServicesDef.SVMXMap selectedObj: secondLevelMap.valueMap){
                                        
                                        if(intBatchEnabled && isInternalLimitReached()){  //terminate and continue with the processing
                                            system.debug(LoggingLevel.DEBUG, 'Entered limit check - Yes Limit reached');
                                            isInternalBatch = true;
                                            break;
                                        } 

                                        String SFIDIfExists = localSFMap.get(selectedObj.key);  
                                        if (SFIDIfExists != null)
                                        {
                                            localIdMapToSFIDChild.put(selectedObj.key,SFIDIfExists);
                                            listresponseSVMXMap.add(new INTF_WebServicesDef.SVMXMap(selectedObj.key, SFIDIfExists));
                                        }else{
                                            localIdChild = selectedObj.key;
                                            localIdsChild.add(selectedObj.key);
                                            String SFIDParent = localIdMapToSFIDParent.get(selectedObj.key);
                                            if (SFIDParent != null)
                                                selectedObj.key = SFIDParent;
                                            
                                            sObj = objecttype.newSObject();  //create new instance 

                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');

                                            Map<string, String> nameToValueMap = (Map<string, String>)JSON.deserialize(jstr, Map<String, String>.Class);

                                            if(nameToValueMap != NULL && nameToValueMap.keySet().size() > 0){
                                                for(String fldName : nameToValueMap.keySet() ){
                                                    String fldValue = nameToValueMap.get(fldName);

                                                    system.debug(LoggingLevel.WARN, 'fldValue = :' + fldValue);
                                                    system.debug(LoggingLevel.WARN, 'fieldCreateable.get(fldName) = :' + fieldCreateable.get(fldName));

                                                    if(fieldCreateable.get(fldName) == 'true')
                                                    {
                                                        if(fieldReferenceto.containsKey(fldName)){
                                                            if(fldValue != null && fldValue != '')
                                                            {
                                                                String fldValueMapped = localIdMapToSFIDParent.get(fldValue);
                                                                if (fldValueMapped != null)
                                                                    fldValue = fldValueMapped;
                                                            }
                                                            sObj.put(fldName, fldValue);
                                                        }else{
                                                            sObj = createSObject(sObj,fieldsType, fldName, fldValue);
                                                        }
                                                    }

                                                }
                                            }
                                        }
                                        system.debug(LoggingLevel.WARN, 'Each Child Record : ' + sObj);
                                        if(sObj != null)
                                            sobjListChild.add(sObj);

                                    }
                                    system.debug(LoggingLevel.WARN, 'List of Child Records to insert: ' + sobjListChild);
                                    INTF_WebServicesDef.SVMXMap Error;
                                    try
                                    {   
                                        
                                        childrensaveresult = Database.insert(sobjListChild, false);
                                        Integer i = 0;
                                        INTF_WebServicesDef.SVMXMap objMap;
                                        for(Database.Saveresult resChildrec : childrensaveresult)
                                        {
                                            objMap = new INTF_WebServicesDef.SVMXMap();
                                            if(resChildrec.isSuccess())
                                            {
                                                objMap.key = localIdsChild[i];
                                                objMap.value = resChildrec.getId();
                                                listresponseSVMXMap.add(objMap);
                                                localIdMapToSFIDChild.put(localIdsChild[i], resChildrec.getId());
                                                localIDMap.values.add(localIdsChild[i]);

                                                if(!mapInsertOperationToIds.containsKey('INSERT'))
                                                    mapInsertOperationToIds.put('INSERT', localIdMapToSFIDChild);
                                                else
                                                    mapInsertOperationToIds.get('INSERT').putAll(localIdMapToSFIDChild);
                                            }
                                            else
                                            {
                                                Error = new INTF_WebServicesDef.SVMXMap(); 
                                                Database.Error[] err = resChildrec.getErrors();
                                                Error.key = firstLevel.value;
                                                Error.value = err[0].getMessage();
                                                
                                                List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                                child.key = localIdsChild[i];
                                                child.value = resChildrec.getId();
                                                errChild.add(child);
                                                Error.valueMap = errChild;
                                                ErrorList.add(Error);
                                            }
                                            i++;
                                        }
                                    }
                                    catch(DMLException e)
                                    {
                                        Error = new INTF_WebServicesDef.SVMXMap(); 
                                        Error.key = firstLevel.value;
                                        Error.value = e.getMessage();
                                        
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                        
                                        child.key = localIdChild;
                                        child.value = '';
                                        errChild.add(child);
                                        Error.valueMap = errChild;
                                        ErrorList.add(Error);
                                    }
                                    sobjListChild.clear();
                                    localIdsChild.clear();

                                }
                        }
                        singleCacheRec = updateLocalIdsIntoCache( mapInsertOperationToIds, singleCacheRec );
                        system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
                        Database.Upsertresult result = Database.upsert(singleCacheRec);

                    }
                    responseSVMXMap.key = firstLevel.key;
                    responseSVMXMap.value = firstLevel.value;
                    responseSVMXMap.valueMap = listresponseSVMXMap;
                    responseValueMap.add(responseSVMXMap);

                    successInsertedIds.valueMap.add(localIDMap); //add the successful Local Ids to the response
                }
                ErrorHeader.valueMap = ErrorList;
                responseValueMap.add(ErrorHeader);
                responseValueMap.add(successInsertedIds);  
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = responseValueMap;
        system.debug(LoggingLevel.WARN, 'Response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'insertClientData');
        return response;
    }
    /*public INTF_WebServicesDef.INTF_SFMResponse insertClientData(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('insertClientData');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<String> localIdsParent = new List<String>();
        List<String> localIdsChild = new List<String>();
        Map<String, String> localIdMapToSFIDParent = new Map<String, String>();
        Map<String, String> localIdMapToSFIDChild = new Map<String, String>();
        Database.Saveresult [] parentsaveresult;
        Database.Saveresult [] childrensaveresult;
        map<String, map<String, String>> mapInsertOperationToIds = new map<String, map<String, String>>();
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        responseValueMap.add(new INTF_WebServicesDef.SVMXMap('PUT_INSERT_TIME', String.valueOf(DateTime.now())));
        system.debug(LoggingLevel.WARN, 'PUT_INSERT_TIME = ' + responseValueMap + 'Put Insert Request = ' + inputRequest);
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        ErrorHeader.key = 'ERROR';
        try
        {
            String strClientType = '';
            Map<String,String> localSFMap = new Map<String,String>();
            system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec + '; Request id = ' + inputRequest.value);
            mapInsertOperationToIds = getCachedLocalIdsForInsertAndDel(singleCacheRec); 
            system.debug(LoggingLevel.WARN, 'mapInsertOperationToIds = ' + mapInsertOperationToIds);
            
            if(mapInsertOperationToIds.get('INSERT') != null && mapInsertOperationToIds.get('INSERT').size() > 0)
                localSFMap = mapInsertOperationToIds.get('INSERT');
                        
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strClientType = clientInform.clientType;
                        break;
                    }
                }
            }
            
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_INSERT')
            {
                List<INTF_WebServicesDef.SVMXMap> inputList = inputRequest.valueMap;
                List<INTF_WebServicesDef.SVMXMap> fieldsMapList;
                Iterator<INTF_WebServicesDef.SVMXMap> inputListIterator = inputList.iterator();
                List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                
                INTF_WebServicesDef.SVMXMap firstLevelMap;
                while(inputListIterator.hasNext())
                {
                    firstLevelMap = inputListIterator.next();
                    system.debug(LoggingLevel.WARN, ' Each Value Map in Request: ' + firstLevelMap);
                    INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
                    List<INTF_WebServicesDef.SVMXMap> listresponseSVMXMap = new List<INTF_WebServicesDef.SVMXMap>();
                    
                    if(firstLevelMap.key == 'Parent_Object')
                    {
                        fieldsMapList = firstLevelMap.valueMap;
                        List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                        Iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                        INTF_WebServicesDef.SVMXMap secondLevelMap;
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        MAP<String,String> fieldsType = new Map<String,String>();
                        Map<String, String> fieldCreateable = new Map<String, String>(); 
                        
                        if(objDef != NULL) 
                        {
                            List<INTF_WebServicesDef.SVMXMap> objProps;
                            objProps = objdef.valueMap;
                            for(INTF_WebServicesDef.SVMXMap objProp : objProps)
                            {
                                if(objProp.key == 'FIELDPROPERTY')
                                {   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                    {
                                        for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                        {
                                            if(fldObj.key == 'TYPE')
                                                fieldsType.put(lstField.value, fldObj.value);
                                            if(fldObj.key == 'CREATEABLE')
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                        }
                                    }
                                }
                            }
                        }
                            
                        List<sObject> sobjListParent = new List<sObject>(); 
                        while(fieldsMapIterator.hasNext())
                        {
                            secondLevelMap = fieldsMapIterator.next();
                            INTF_WebServicesDef.SVMXMap tableValueMap = new INTF_WebServicesDef.SVMXMap();
                            List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
                            
                            if(secondLevelMap.key == 'Fields')
                            {
                                fieldValues = secondLevelMap.valueMap;//fieldValues - each record to insert
                                Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                sObject sObj = null;
                                String localId = null;
                                while(it.hasNext())
                                {
                                    INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                    String SFIDIfExists = localSFMap.get(selectedObj.key);  
                                    if(SFIDIfExists != null)
                                    {
                                        localIdMapToSFIDParent.put(selectedObj.key,SFIDIfExists);
                                        INTF_WebServicesDef.SVMXMap existRecordMap = new INTF_WebServicesDef.SVMXMap();
                                        existRecordMap.key = selectedObj.key;
                                        existRecordMap.value = SFIDIfExists;
                                        listresponseSVMXMap.add(existRecordMap);
                                    }
                                    else
                                    {
                                        localId = selectedObj.key;
                                        localIdsParent.add(localId);
                                        String jstr = selectedObj.value;
                                        if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                            jstr = jstr.replace('&quot;', '"');
                                        JSONParser jsp = JSON.createParser(jstr);
                                        sObj = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject();
                                        while(jsp.nextToken() != null)
                                        {
                                            if(jsp.getCurrentToken() == JSONToken.FIELD_NAME) 
                                            {  
                                                String fldName = jsp.getText();
                                                if(jsp.nextToken() == JSONToken.VALUE_STRING)
                                                {
                                                    String fldValue = jsp.getText();
                                                    if(fieldCreateable.get(fldName) == 'true')
                                                    {
                                                        if(fldValue != null && fldValue != '')
                                                        {
                                                            system.debug(LoggingLevel.Debug, ' fldName = ' + fldName + ';fldValue = ' + fldValue);
                                                            if(fldValue != null && fldValue != '')
                                                            {
                                                                if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                                {
                                                                    fldValue = fldValue.replace('&amp;', '&');
                                                                    fldValue = fldValue.replace('&apos;', '\'');
                                                                    fldValue = fldValue.replace('&lt;', '<');
                                                                    fldValue = fldValue.replace('&gt;', '>');
                                                                    fldValue = fldValue.replace('&quot;', '"');
                                                                }
                                                            }
                                                            if(fieldsType.get(fldName) == 'DATETIME' && fldValue != '')
                                                            {
                                                                fldValue = fldValue.replace('T', ' ');
                                                                fldValue = fldValue.replace('Z', ' ');
                                                                sObj.put(fldName, Datetime.valueOfGmt(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DATE' && fldValue != '')
                                                            {
                                                                system.debug(LoggingLevel.Debug, ' Date fldName = ' + fldName + ';fldValue = ' + fldValue);
                                                                sObj.put(fldName, Date.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'TIME')
                                                            {
                                                                continue;
                                                            }
                                                            else if(fieldsType.get(fldName) == 'BOOLEAN')
                                                            {
                                                                sObj.put(fldName, Boolean.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DOUBLE')
                                                            {
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DECIMAL'|| fieldsType.get(fldName) == 'CURRENCY' || fieldsType.get(fldName) == 'PERCENT')
                                                            {
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'INTEGER')
                                                            {
                                                                sObj.put(fldName, Integer.valueOf(fldValue));
                                                            }
                                                            else
                                                            {
                                                                sObj.put(fldName, fldValue);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN, 'Each Parent Record : ' + sObj);
                                    if(sObj != null)
                                        sobjListParent.add(sObj);
                                }
                                INTF_WebServicesDef.SVMXMap Error;
                                try
                                {
                                    parentsaveresult = Database.insert(sobjListParent,false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.Saveresult res : parentsaveresult)
                                    {
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(res.isSuccess())
                                        {
                                            objMap.key = localIdsParent[i];
                                            objMap.value = res.getId();
                                            listresponseSVMXMap.add(objMap);
                                            localIdMapToSFIDParent.put(localIdsParent[i], res.getId());
                                            
                                            if(!mapInsertOperationToIds.containsKey('INSERT'))
                                                mapInsertOperationToIds.put('INSERT', localIdMapToSFIDParent);
                                            else
                                                mapInsertOperationToIds.get('INSERT').putAll(localIdMapToSFIDParent);
                                        }
                                        else
                                        {
                                            Error = new INTF_WebServicesDef.SVMXMap(); 
                                            Database.Error err = res.getErrors()[0];
                                            Error.key = firstLevelMap.value;
                                            Error.value = err.getMessage();
                                            
                                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                            child.key = localIdsParent[i];
                                            child.value = localIdsParent[i];
                                            errChild.add(child);
                                            Error.valueMap = errChild;
                                            ErrorList.add(Error);
                                        }
                                        i++;
                                    }
                                }
                                catch(DMLException e)
                                {
                                    Error = new INTF_WebServicesDef.SVMXMap(); 
                                    Error.key = firstLevelMap.value;
                                    Error.value = e.getMessage();
                                    system.debug(LoggingLevel.WARN, 'Exception caught:' + e.getMessage());
                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                    child.key = localId;
                                    child.value = localId;
                                    errChild.add(child);
                                    Error.valueMap = errChild;
                                    ErrorList.add(Error);
                                }
                                sobjListParent.clear();
                                localIdsParent.clear();
                            }
                        }
                        singleCacheRec = updateLocalIdsIntoCache( mapInsertOperationToIds, singleCacheRec );
                        system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
                        Database.Upsertresult result = Database.upsert(singleCacheRec);
                    }
                    else if(firstLevelMap.key == 'Child_Object')
                    {
                        DateTime dt = datetime.now();
                        String strdt = String.valueOf(dt);
                        fieldsMapList = firstLevelMap.valueMap;
                        List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                        Iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                        INTF_WebServicesDef.SVMXMap secondLevelMap;
                        
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        
                        MAP<String,String> fieldsType = new Map<String,String>();
                        Map<String, String> fieldUpdateable = new Map<String, String>();
                        Map<String, String> fieldCreateable = new Map<String, String>(); 
                        Map<String, String> fieldReferenceto = new Map<String, String>();
                            
                        if(objDef != NULL) 
                        {
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                            {
                                if (objProp.key == 'FIELDPROPERTY')
                                {   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                    {
                                        List<INTF_WebServicesDef.SVMXMap> fldObjs = lstField.valueMap;
                                        Iterator<INTF_WebServicesDef.SVMXMap> it = fldObjs.iterator();
                                        while(it.hasNext())
                                        {
                                            INTF_WebServicesDef.SVMXMap checkMap = it.next();
                                            if(checkMap.key == 'REFERENCETO')
                                                fieldReferenceto.put(lstField.value, checkMap.key);
                                                //fieldReferenceto.put(checkMap.value, checkMap.key);
                                        }
                                        String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', fldObjs);
                                        if (reference_to != null)
                                            String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldObjs);
                                        for(INTF_WebServicesDef.SVMXMap fldObj : fldObjs)
                                        {
                                            if(fldObj.key == 'TYPE')
                                                fieldsType.put(lstField.value, fldObj.value);
                                            if(fldObj.key == 'CREATEABLE')
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                            if(fldObj.key == 'UPDATEABLE')
                                                fieldUpdateable.put(lstField.value,fldObj.value);
                                        }
                                    }
                                }
                            }
                        }
                        List<sObject> sobjListChild = new List<sObject>(); 
                        while(fieldsMapIterator.hasNext())
                        {
                            secondLevelMap = fieldsMapIterator.next();
                            if(secondLevelMap.key == 'Fields')
                            {
                                fieldValues = secondLevelMap.valueMap;
                                Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                sObject sObj = null;
                                String localIdChild = null;
                                while(it.hasNext())
                                {
                                    INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                    String SFIDIfExists = localSFMap.get(selectedObj.key);  
                                    if (SFIDIfExists != null)
                                    {
                                        localIdMapToSFIDChild.put(selectedObj.key,SFIDIfExists);
                                        INTF_WebServicesDef.SVMXMap existRecordMap = new INTF_WebServicesDef.SVMXMap();
                                        existRecordMap.key = selectedObj.key;
                                        existRecordMap.value = SFIDIfExists;
                                        listresponseSVMXMap.add(existRecordMap);
                                    }
                                    else
                                    {
                                        localIdChild = selectedObj.key;
                                        localIdsChild.add(selectedObj.key);
                                        String SFIDParent = localIdMapToSFIDParent.get(selectedObj.key);
                                        if (SFIDParent != null)
                                            selectedObj.key = SFIDParent;
                                        String jstr = selectedObj.value;
                                        if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                            jstr = jstr.replace('&quot;', '"');
                                        JSONParser jsp = JSON.createParser(jstr);
                                        
                                        sObj = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject();
                                        while(jsp.nextToken() != null)
                                        {
                                            if(jsp.getCurrentToken() == JSONToken.FIELD_NAME) 
                                            {  
                                                String fldName = jsp.getText();
                                                system.debug(LoggingLevel.WARN, 'fldName = :' + fldName);
                                                if(jsp.nextToken() == JSONToken.VALUE_STRING)
                                                {
                                                    String fldValue = jsp.getText();
                                                    system.debug(LoggingLevel.WARN, 'fldValue = :' + fldValue);
                                                    system.debug(LoggingLevel.WARN, 'fieldCreateable.get(fldName) = :' + fieldCreateable.get(fldName));
                                                    if(fieldCreateable.get(fldName) == 'true')
                                                    {
                                                        if(fldValue != null && fldValue != '')
                                                        {
                                                            if(fldValue != null && fldValue != '')
                                                            {
                                                                if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                                {   
                                                                    fldValue = fldValue.replace('&amp;', '&');
                                                                    fldValue = fldValue.replace('&apos;', '\'');
                                                                    fldValue = fldValue.replace('&lt;', '<');
                                                                    fldValue = fldValue.replace('&gt;', '>');
                                                                    fldValue = fldValue.replace('&quot;', '"');
                                                                }
                                                            }
                                                            if(fieldsType.get(fldName) == 'DATETIME' && fldValue != '')
                                                            {
                                                                fldValue = fldValue.replace('T', ' ');
                                                                fldValue = fldValue.replace('Z', ' ');
                                                                sObj.put(fldName, Datetime.valueOfGmt(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DATE' && fldValue != '')
                                                            {
                                                                sObj.put(fldName, Date.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'TIME')
                                                            {
                                                                continue;
                                                            }
                                                            else if(fieldsType.get(fldName) == 'BOOLEAN')
                                                            {
                                                                sObj.put(fldName, Boolean.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DOUBLE')
                                                            {
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DECIMAL' || fieldsType.get(fldName) == 'CURRENCY' || fieldsType.get(fldName) == 'PERCENT')
                                                            {
                                                                system.debug(LoggingLevel.WARN, 'decimal.valueOf(fldValue) = :' + decimal.valueOf(fldValue));
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'INTEGER')
                                                            {
                                                                sObj.put(fldName, Integer.valueOf(fldValue));
                                                            }
                                                            else
                                                            {
                                                                if(fieldReferenceto.containsKey(fldName))
                                                                {
                                                                    if(fldValue != null && fldValue != '')
                                                                    {
                                                                        String fldValueMapped = localIdMapToSFIDParent.get(fldValue);
                                                                        if (fldValueMapped != null)
                                                                            fldValue = fldValueMapped;
                                                                    }
                                                                }
                                                                sObj.put(fldName, fldValue);
                                                            }
                                                        }
                                                    }
                                                }                                   
                                            }
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN, 'Each Child Record : ' + sObj);
                                    if(sObj != null)
                                        sobjListChild.add(sObj);
                                }
                                INTF_WebServicesDef.SVMXMap Error;
                                try
                                {
                                    childrensaveresult = Database.insert(sobjListChild, false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.Saveresult resChildrec : childrensaveresult)
                                    {
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(resChildrec.isSuccess())
                                        {
                                            objMap.key = localIdsChild[i];
                                            objMap.value = resChildrec.getId();
                                            listresponseSVMXMap.add(objMap);
                                            localIdMapToSFIDChild.put(localIdsChild[i], resChildrec.getId());
                                            
                                            if(!mapInsertOperationToIds.containsKey('INSERT'))
                                                mapInsertOperationToIds.put('INSERT', localIdMapToSFIDChild);
                                            else
                                                mapInsertOperationToIds.get('INSERT').putAll(localIdMapToSFIDChild);
                                        }
                                        else
                                        {
                                            Error = new INTF_WebServicesDef.SVMXMap(); 
                                            Database.Error[] err = resChildrec.getErrors();
                                            Error.key = firstLevelMap.value;
                                            Error.value = err[0].getMessage();
                                            
                                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                            child.key = localIdsChild[i];
                                            child.value = resChildrec.getId();
                                            errChild.add(child);
                                            Error.valueMap = errChild;
                                            ErrorList.add(Error);
                                        }
                                        i++;
                                    }
                                }
                                catch(DMLException e)
                                {
                                    Error = new INTF_WebServicesDef.SVMXMap(); 
                                    Error.key = firstLevelMap.value;
                                    Error.value = e.getMessage();
                                    
                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                    
                                    child.key = localIdChild;
                                    child.value = '';
                                    errChild.add(child);
                                    Error.valueMap = errChild;
                                    ErrorList.add(Error);
                                }
                                sobjListChild.clear();
                                localIdsChild.clear();
                            }
                        }
                        singleCacheRec = updateLocalIdsIntoCache( mapInsertOperationToIds, singleCacheRec );
                        system.debug(LoggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
                        Database.Upsertresult result = Database.upsert(singleCacheRec);
                    }
                    responseSVMXMap.key = firstLevelMap.key;
                    responseSVMXMap.value = firstLevelMap.value;
                    responseSVMXMap.valueMap = listresponseSVMXMap;
                    responseValueMap.add(responseSVMXMap);
                }
                ErrorHeader.valueMap = ErrorList;
                responseValueMap.add(ErrorHeader);
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = responseValueMap;
        system.debug(LoggingLevel.WARN, 'Response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'insertClientData');
        return response;
    }*/
    
    // we can remove this method when luma starts using this method getDownloadCriteriaRecordIds
    public INTF_WebServicesDef.INTF_SFMResponse getDownloadCriteriaRecords(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaRecords');
        List<String> recordIds = new List<String>();
        map<String, map<String, String>> mapObjToQry;
        String strUserId = null, strDeviceUDID = null, strSyncReqId = null;
        List<INTF_WebServicesDef.SVMXMap> masterWrapList;
        map<String, String> mapClientInfo = new map<String, String>();
        List<INTF_WebServicesDef.SVMXMap> reqValMap = inputRequest.valueMap;
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Iterator<INTF_WebServicesDef.SVMXMap> inputIterator = reqValMap.iterator();
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        String strDeviceName = (new INTF_ConfigSync()).getDeviceName(inputRequest);     
             
        if(inputRequest.values != null)
            recordIds = inputRequest.values;
        else
            recordIds.add(null);
        
        mapClientInfo = (new INTF_ConfigSync()).getClientData(inputRequest);
        system.debug(LoggingLevel.WARN, 'mapClientInfo = ' + mapClientInfo);
        
        strUserId = mapClientInfo.get('userid');
        strDeviceUDID = mapClientInfo.get('clientudid');
        strSyncReqId = inputRequest.value;
        
        if(allObjs.get('svmxc__sm_request_cache__c') == null || strUserId == null || strDeviceUDID == null)
        {
            isRequestCache = false;
            return (new INTF_DataUtilityServices()).RequestForCriteriaRecords(inputRequest);
        }
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID');
        List<SVMXC__SM_Request_Cache__c> lstRequestCache = [Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstRequestCache != null && !lstRequestCache.isEmpty())
        {
                if(lstRequestCache[0].SVMXC__SM_Client_Sync_Request_Id__c != strSyncReqId){  
                    singleCacheRec = lstRequestCache[0];
                singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
                singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
                singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
                singleCacheRec.SVMXC__SM_Application_Filters__c = '';
                singleCacheRec.SVMXC__SM_Application_Name__c = '';
                singleCacheRec.SVMXC__SM_Application_Version__c = '';
                singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c = '';
                singleCacheRec.SVMXC__SM_Device_Type__c = '';
                singleCacheRec.SVMXC__SM_Doc_Template_IDs__c = '';
                singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Download_Criteria_Object_List__c = '';
                singleCacheRec.SVMXC__SM_Expression_IDs__c = '';
                singleCacheRec.SVMXC__SM_Group_Profile_Id__c = '';
                singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c = '';
                singleCacheRec.SVMXC__SM_Object_Access__c = '';
                singleCacheRec.SVMXC__SM_Object_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Page_Layout_IDs__c = '';
                singleCacheRec.SVMXC__SM_Picklist_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Settings__c = '';
                singleCacheRec.SVMXC__SM_SFM_Mappings__c = '';
                singleCacheRec.SVMXC__SM_SFM_Process_IDs__c = '';
                singleCacheRec.SVMXC__SM_SFM_Translations__c = '';
                singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c = '';
                singleCacheRec.SVMXC__SM_SFW_Translations__c = '';
                singleCacheRec.SVMXC__SM_SOQL_Query__c = '';
                singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = '';
                singleCacheRec.SVMXC__SM_Event_What_IDs__c = '';
                }else{
                    singleCacheRec = lstRequestCache[0];
                }
        }else{
            SVMXC__SM_Request_Cache__c cacheRec = new SVMXC__SM_Request_Cache__c();
            cacheRec.SVMXC__SM_User_Id__c = strUserId;
            cacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
            cacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
            cacheRec.SVMXC__SM_Sync_Start_Time__c = Datetime.now();
            Database.insert(cacheRec);
            INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__SM_SOQL_Query__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID limit 1');
            singleCacheRec = [Select Id, SVMXC__SM_SOQL_Query__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID limit 1];
        }
        
        if(singleCacheRec.SVMXC__SM_SOQL_Query__c != null && singleCacheRec.SVMXC__SM_SOQL_Query__c != '')
            mapObjToQry = (map<String, map<String, String>>)JSON.deserialize(singleCacheRec.SVMXC__SM_SOQL_Query__c, map<String, map<String, String>>.Class);
        system.debug(loggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec + '; mapObjToQry = ' + mapObjToQry);
        
        try
        {
            if(mapObjToQry == null || mapObjToQry.size() <= 0)
            {
                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                {
                    mapObjToQry = new map<String, map<String, String>>();
                    masterWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                    Map<String, INTF_WebServicesDef.SVMXMap> mapDownloadCriteriaObjDefns = new Map<String, INTF_WebServicesDef.SVMXMap>();
                    mapDownloadCriteriaObjDefns = getDownloadCriteriaObjDefns(strDeviceName);
                    List<String> objs_clauses = new List<String>();
                    
                    String strTechLocId = '';
                    INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
                    for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
                    {
                        if(eachTech.SVMXC__Inventory_Location__c != null)
                            strTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
                    }
                    system.debug(LoggingLevel.WARN,'mapDownloadCriteriaObjDefns is empty = '+ mapDownloadCriteriaObjDefns.isEmpty() + '; mapDownloadCriteriaObjDefns.size() = ' + mapDownloadCriteriaObjDefns.size());
                    if(mapDownloadCriteriaObjDefns != null && !mapDownloadCriteriaObjDefns.isEmpty() && mapDownloadCriteriaObjDefns.size() > 0)
                    {
                        for(String objName: mapDownloadCriteriaObjDefns.keySet())
                        {
                            System.debug(LoggingLevel.WARN,'DC object name : '+objName);
                            String strQuery = 'SELECT Id FROM ' + objName + ' WHERE ';
                            if (mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                strQuery +=  ' (' + mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                            
                            strQuery = strQuery.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                            strQuery = strQuery.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());
                            strQuery = strQuery.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                            strQuery = strQuery.replace('SVMX.USERTRUNK', strTechLocId);
                            
                            Map<String, String> mapSFCSToValue = (new INTF_DataUtilityServices()).replaceLiteralWithValue(strQuery);
                            for(String eachLiteral : mapSFCSToValue.keySet())
                            {
                                system.debug(LoggingLevel.Debug, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                                if(mapSFCSToValue.get(eachLiteral) !=null && mapSFCSToValue.get(eachLiteral) !=''){
                                        strQuery = strQuery.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                                }else{
                                        strQuery = strQuery.replace(eachLiteral, '');
                                }
                            }
                            system.debug(LoggingLevel.Debug, 'After Replace = ' + strQuery);
                            
                            map<String, String> mapDCObjToDetails = new map<String, String>();
                            mapDCObjToDetails.put('OperationType', 'Select');
                            mapDCObjToDetails.put('IterationIndex', '0');
                            mapDCObjToDetails.put('ObjectName', objName);
                            mapDCObjToDetails.put('SOQLQuery', strQuery);
                            mapDCObjToDetails.put('Status', 'NOT_EXECUTED');
                            
                            mapObjToQry.put(objName, mapDCObjToDetails);
                            system.debug(LoggingLevel.Debug, 'mapObjToQry = ' + mapObjToQry);
                            
                            String werClause = mapDownloadCriteriaObjDefns.get(objName).value;
                            Blob blobStr = blob.valueOf(werClause);
                            String encodeStr = EncodingUtil.base64Encode(blobStr);
                            objs_clauses.add(objName+','+encodeStr);
                        }
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'True'));
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
                        singleCacheRec.SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry);
                        system.debug(loggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
                        Database.Upsertresult upsertResult = Database.upsert(singleCacheRec);
                    }
                    masterWrapList.add(new INTF_WebServicesDef.SVMXMap('DOWNLOAD_CRITERIA_OBJECTS', '', objs_clauses));
                    response.valueMap = masterWrapList;
                }
            }
            else
            {
                List<String> SFDC_Records = new List<String>();
                map<String, String> mapDCObjToDetails = new map<String, String>();
                system.debug(loggingLevel.WARN, 'mapObjToQry = ' + mapObjToQry);
                
                for(String strObjName : mapObjToQry.keySet())
                {
                    mapDCObjToDetails = mapObjToQry.get(strObjName);
                    if(mapDCObjToDetails != null && mapDCObjToDetails.get('SFDCRecordId') != null && mapDCObjToDetails.get('OperationType') != 'SELECT')
                        SFDC_Records.add(mapDCObjToDetails.get('SFDCRecordId'));
                }
                
                String HighestId, LowestId;
                List<INTF_WebServicesDef.SVMXMap> multiWrapList;
                Integer recordsLimit = 35000, batch_index, current_batch_index;
                
                map<String, String> mapSettingsForIPAD018 = new map<String, String>();
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                list<String> lstSettingId = new list<String>();
                lstSettingId.add('SET006');
                mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                
                if(mapSettingsForIPAD018.containskey('SET006') && mapSettingsForIPAD018.get('SET006') != null && mapSettingsForIPAD018.get('SET006').length() > 0)
                    recordsLimit = Integer.valueOf(mapSettingsForIPAD018.get('SET006'));
    
                if(recordsLimit < 1)
                    recordsLimit = 35000;
                    
                while(inputIterator.hasNext())
                {
                    INTF_WebServicesDef.SVMXMap selObject = new  INTF_WebServicesDef.SVMXMap();
                    selObject = inputIterator.next();
                    System.debug(LoggingLevel.WARN,'sb object---'+selObject);
                    if(selObject.key == 'LAST_INDEX')
                    {
                        batch_index = Integer.valueOf(selObject.value);
                        current_batch_index = batch_index + 1;
                        System.debug(LoggingLevel.WARN,'Current batch index-- '+current_batch_index); 
                    }
                }
                
                List<Integer> ser_batch_indexes = new List<Integer>();
                
                for(String eachObject : mapObjToQry.keySet())
                    ser_batch_indexes.add(Integer.valueOf(mapObjToQry.get(eachObject).get('IterationIndex')));
                    
                ser_batch_indexes.sort();
                String strLastId = '';
                Integer record_count = 0;
                Boolean callBack = false;
                Integer siz = ser_batch_indexes.size();
                Integer server_higestIndex = ser_batch_indexes[siz-1];
                
                if(server_higestIndex == batch_index)
                {
                    for(String eachObject : mapObjToQry.keySet())
                    {

                        mapDCObjToDetails = mapObjToQry.get(eachObject);
                        callBack = true;
                        if(mapDCObjToDetails.get('Status') != 'EXECUTED')
                        {                   
                            system.debug(LoggingLevel.WARN, 'Record Limit ' + recordsLimit);
                            if(record_count == 35000)
                                break;
                                
                            String query = mapDCObjToDetails.get('SOQLQuery');
                            HighestId = mapDCObjToDetails.get('SFDCRecordId');
                            LowestId =  mapDCObjToDetails.get('RecordId');
                            
                            if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && mapDCObjToDetails.get('SFDCRecordId') != null && mapDCObjToDetails.get('SFDCRecordId').length() > 0)
                                strLastId = mapDCObjToDetails.get('SFDCRecordId');
                                
                            if(HighestId == null || HighestId == '')
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    else
                                    {
                                        query = query.trim();
                                        query = query.removeEnd('WHERE');
                                        query = query.removeEnd('and');
                                        query += ' Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    else
                                    {
                                        query = query.trim();
                                        query = query.removeEnd('WHERE');
                                        query = query.removeEnd('and');
                                        query += ' Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            
                            system.debug(LoggingLevel.WARN, 'Query string ' + query);
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            system.debug(LoggingLevel.WARN, 'Query string ' + queryResult);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = eachObject;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            system.debug(LoggingLevel.WARN,'Records limit' + recordsLimit + 'no of rows ' + queryResult.size());
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                system.debug(LoggingLevel.WARN,'In result > recordsLIMIT');
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                mapDCObjToDetails.put('RecordId', LowestId);
                                mapDCObjToDetails.put('SFDCRecordId', HighestId);
                                mapDCObjToDetails.put('Status', 'PARTIAL_EXECUTED');
                                mapDCObjToDetails.put('IterationIndex', String.valueOf(current_batch_index));
                                mapObjToQry.get(eachObject).putAll(mapDCObjToDetails);
                                singleCacheRec.SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry);
                                update(singleCacheRec);
                                masterResponse.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObject));
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                system.debug(LoggingLevel.WARN,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                mapObjToQry.remove(eachObject);
                                singleCacheRec.SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry);
                                update(singleCacheRec);
                            }
                            else if(queryResult.size() == 0)
                            {
                                system.debug(LoggingLevel.WARN,'In result == 0');
                                mapObjToQry.remove(eachObject);
                                singleCacheRec.SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry);
                                update(singleCacheRec);
                            }
                            if(mapObjToQry.size() <=0 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }                  
                    }
                    masterResponse.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack)));
                    masterResponse.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(current_batch_index)));
                }
                else if(server_higestIndex > batch_index)
                {
                    for(String eachObject : mapObjToQry.keySet())
                    {
                        callBack = true;
                        mapDCObjToDetails = mapObjToQry.get(eachObject);
                        Integer bt_Index = Integer.valueOf(mapDCObjToDetails.get('IterationIndex'));
                        
                        if(bt_Index == current_batch_index)
                        {
                            System.debug(LoggingLevel.WARN, 'Inside mismatch loop------');
                            if(record_count == 35000)
                                break;
                                
                            String query = mapDCObjToDetails.get('SOQLQuery');
                            HighestId = mapDCObjToDetails.get('SFDCRecordId');
                            LowestId =  mapDCObjToDetails.get('RecordId');
                            
                            if(recordIds != null)
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(recordIds.size() > 0)
                                    {
                                        recordIds.sort();
                                        strLastId = recordIds[recordIds.size() - 1];
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                    {
                                        query = query.trim();
                                        query = query.removeEnd('WHERE');
                                        query = query.removeEnd('and');
                                        query += ' Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                    query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                            }
                            
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = eachObject;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);  
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                masterResponse.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObject));
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.WARN,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                            }
                            if(mapObjToQry.size() <= 0 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }
                        masterResponse.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack)));
                        masterResponse.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(current_batch_index)));
                    }
                }
                response.valueMap = masterResponse;
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        system.debug(LoggingLevel.WARN, 'response of DC = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getDownloadCriteriaRecords');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getIncrementalDCrecords(INTF_WebServicesDef.INTF_SFMRequest inputRequest, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getIncrementalDCrecords');
        INTF_WebServicesDef.SVMXMap mainVMDC = new INTF_WebServicesDef.SVMXMap();
        mainVMDC.key = inputRequest.eventName;
        mainVMDC.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        Datetime LastSynchTime;
        List<String> recordIds = new List<String>();
        map<String, map<String, String>> mapObjToQry;
        List<String> lstUserTrunk = new List<String>();
        List<INTF_WebServicesDef.SVMXMap> masterWrapList;
        Set<String> setOldPriceBookIds = new Set<String>();
        Set<String> setOldServicePriceBookIds = new Set<String>();
        List<INTF_WebServicesDef.SVMXMap> reqValMap = inputRequest.valueMap;
        Iterator<INTF_WebServicesDef.SVMXMap> inputIterator = reqValMap.iterator();
        String strOldTechLocId = '', Record_id, strUserId = null, strDeviceUDID = null;
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        String strDeviceName = (new INTF_ConfigSync()).getDeviceName(inputRequest);        
        
        if(inputRequest.values != null)
            recordIds = inputRequest.values;
        else
            recordIds.add(null);
        
        strUserId = mapClientDetails.get('userid');
        strDeviceUDID = mapClientDetails.get('clientudid');
            
        for(INTF_WebServicesDef.SVMXMap TimeStampMap : inputRequest.valueMap)
        {
            system.debug(LoggingLevel.WARN, 'Each ValueMap in request of DC = ' + TimeStampMap);
            if(TimeStampMap.key == 'LAST_SYNC_TIME')
            {
                LastSynchTime = Datetime.valueOf(TimeStampMap.value);
                //break;
            }
            else if(TimeStampMap.key == 'PRICEBOOK_IDs')
            {
                if(TimeStampMap.values != null && TimeStampMap.values.size() > 0)
                    setOldPriceBookIds.addAll(TimeStampMap.values);
            }
            else if(TimeStampMap.key == 'SERVICE_PRICEBOOK_IDs')
            {
                if(TimeStampMap.values != null && TimeStampMap.values.size() > 0)
                    setOldServicePriceBookIds.addAll(TimeStampMap.values);
            }
        }
        
        strOldTechLocId = mapClientDetails.get('usertrunklocation');
        
        mapObjToQry = (map<String, map<String, String>>)INTF_TxnCache.get('DC_PARTIAL_EXEC_OBJECTS', 'map<String, map<String, String>>');
        system.debug(loggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec + '; mapObjToQry = ' + mapObjToQry + '; Technician Location Id = ' + strOldTechLocId);
        
        try
        {
            if(mapObjToQry == null || mapObjToQry.size() <= 0)
            {
                String deltaClause;
                mapObjToQry = new map<String, map<String, String>>();
                Set<String> setDCPriceCalcObjects = new Set<String>();
                masterWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                Set<String> setPriceCalObjects = new Set<String>{'SVMXC__Entitlement_History__c', 'SVMXC__Warranty__c', 'SVMXC__Service_Contract__c', 'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c', 'Pricebook2', 'PricebookEntry', 'SVMXC__Service_Pricebook__c', 'SVMXC__Service_Pricebook_Entry__c', 'SVMXC__Custom_Coverage__c'};
                
                if (inputRequest.eventName == 'GET_UPDATE_DC_OPTIMZED')
                    deltaClause = ' LastModifiedDate >= :LastSynchTime and isDeleted = false ';
                else if (inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                {
                    deltaClause = ' LastModifiedDate >= :LastSynchTime and isDeleted = true ';
                    
                    Boolean isGetPriceEnabled = (boolean)INTF_TxnCache.get('IPAD018_SET009', 'Boolean');
                    if(isGetPriceEnabled == null)
                    {
                        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                        List<String> lstSettingId = new list<String>();
                        lstSettingId.add('SET009');
                        Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
                        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
                        
                        if(mapSettingsForIPAD018.containskey('SET009') && mapSettingsForIPAD018.get('SET009') != null)
                            isGetPriceEnabled = Boolean.valueOf(mapSettingsForIPAD018.get('SET009'));
                        else
                            isGetPriceEnabled = false;
                        
                        INTF_TxnCache.put('IPAD018_SET009', isGetPriceEnabled, 'Boolean');
                    }
                    
                    if(isGetPriceEnabled)   
                        setDCPriceCalcObjects.addAll(setPriceCalObjects);
                }
                String strCurrTechLocId = '';
                INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
                for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
                {
                    if(eachTech.SVMXC__Inventory_Location__c != null)
                        strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
                }
                Map<String, INTF_WebServicesDef.SVMXMap> mapDownloadCriteriaObjDefns = new Map<String, INTF_WebServicesDef.SVMXMap>(); 
                mapDownloadCriteriaObjDefns = getDownloadCriteriaObjDefns(strDeviceName);
                
                setDCPriceCalcObjects.addAll(mapDownloadCriteriaObjDefns.keySet());
                system.debug(LoggingLevel.WARN, 'Set of Objects' + setDCPriceCalcObjects);
                if(mapDownloadCriteriaObjDefns != null && !mapDownloadCriteriaObjDefns.isEmpty())
                {
                    List<String> objs_clauses = new List<String>();
                    for(String objName: setDCPriceCalcObjects)
                    {
                        system.debug(LoggingLevel.WARN, ' DC Object Name = ' + objName + ', value = ' + mapDownloadCriteriaObjDefns.get(objName));
                        if(objName == 'User')
                        {
                            deltaClause = deltaClause.replace('isDeleted = false','isActive = true');
                            deltaClause = deltaClause.replace('isDeleted = true','isActive = false');
                        }
                        else 
                        {
                            deltaClause = deltaClause.replace('isActive = true','isDeleted = false');
                            deltaClause = deltaClause.replace('isActive = false','isDeleted = true');
                        }
                        String strQuery = 'SELECT Id FROM ' + objName + ' WHERE ';
                        if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                        {
                            if(mapDownloadCriteriaObjDefns.get(objName) != NULL)
                            {
                                if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                {
                                    strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                }
                            }
                            strQuery += deltaClause + ' and ';
                        }
                        else if(inputRequest.eventName == 'GET_UPDATE_DC_OPTIMZED')
                        {
                            if(mapDownloadCriteriaObjDefns.get(objName).values != null && mapDownloadCriteriaObjDefns.get(objName).values.size() > 0)
                            {
                                if(Datetime.valueOfGmt(mapDownloadCriteriaObjDefns.get(objName).values[0]) > LastSynchTime)
                                {
                                    if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                    }
                                }
                                else if(mapDownloadCriteriaObjDefns.get(objName).record != null)
                                { 
                                    if(((SVMXC__ServiceMax_Processes__c)mapDownloadCriteriaObjDefns.get(objName).record).LastModifiedDate > LastSynchTime)
                                    {
                                        if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                        {
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                        }
                                    }
                                    else if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        if(mapDownloadCriteriaObjDefns.get(objName).value.containsIgnoreCase('USERTRUNK') && strCurrTechLocId != strOldTechLocId)
                                        {
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                        }
                                        else if(objName == 'Pricebook2')
                                            strQuery +=  ' ((' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID IN:setOldPriceBookIds AND ' + deltaClause + ') OR (' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID NOT IN:setOldPriceBookIds)) AND ';
                                        else if(objName == 'SVMXC__Service_Pricebook__c')
                                            strQuery +=  ' ((' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID IN:setOldServicePriceBookIds AND ' + deltaClause + ') OR (' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID NOT IN:setOldServicePriceBookIds)) AND ';
                                        else
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ' + deltaClause + ' and ';
                                    }
                                }
                                else
                                {
                                    if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                    }
                                    strQuery += deltaClause + ' and ';
                                }
                            }
                        }
                        
                        system.debug(LoggingLevel.WARN, ' Query for Each DC Object' + strQuery);
                        strQuery = strQuery.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                        strQuery = strQuery.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());
                        strQuery = strQuery.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                        strQuery = strQuery.replace('SVMX.USERTRUNK', strCurrTechLocId);
                       
                        Map<String, String> mapSFCSToValue = (new INTF_DataUtilityServices()).replaceLiteralWithValue(strQuery);
                        for(String eachLiteral : mapSFCSToValue.keySet())
                        {
                            system.debug(LoggingLevel.Debug, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                            if(mapSFCSToValue.get(eachLiteral) !=null && mapSFCSToValue.get(eachLiteral) !=''){
                                    strQuery = strQuery.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                            }else{
                                    strQuery = strQuery.replace(eachLiteral, '');
                            }
                        }
                        system.debug(LoggingLevel.Debug, 'After Replace = ' + strQuery);
                        
                        if(inputRequest.eventName == 'GET_UPDATE_DC_OPTIMZED' || inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                        {
                            map<String, String> mapDCObjToDetails = new map<String, String>();
                            mapDCObjToDetails.put('OperationType', 'Select');
                            mapDCObjToDetails.put('IterationIndex', '0');
                            mapDCObjToDetails.put('ObjectName', objName);
                            mapDCObjToDetails.put('SOQLQuery', strQuery);
                            mapDCObjToDetails.put('Status', 'NOT_EXECUTED');
                            
                            mapObjToQry.put(objName, mapDCObjToDetails);
                            system.debug(LoggingLevel.Debug, 'mapObjToQry = ' + mapObjToQry);
                            
                        }
                        if(mapDownloadCriteriaObjDefns.get(objName) != null)
                        {
                            String werClause = mapDownloadCriteriaObjDefns.get(objName).value;
                            Blob blobStr = blob.valueOf(werClause);
                            String encodeStr = EncodingUtil.base64Encode(blobStr); 
                            objs_clauses.add(objName + ',' + encodeStr);
                        }
                    }
                    
                    INTF_WebServicesDef.SVMXMap DC_Objects = new INTF_WebServicesDef.SVMXMap();
                    DC_Objects.key = 'DOWNLOAD_CRITERIA_OBJECTS';
                    DC_Objects.values = objs_clauses;
                    masterWrapList.add(DC_Objects);
                    System.debug(LoggingLevel.WARN, 'master wrap list' + masterWrapList);
                }
                mainVMDC.valueMap.addAll(masterWrapList);
                system.debug(loggingLevel.WARN, 'singleCacheRec = ' + singleCacheRec);
            }
            if(mapObjToQry != null && mapObjToQry.size() > 0)
            {
                List<String> SFDC_Records = new List<String>();
                map<String, String> mapDCObjToDetails = new map<String, String>();
                for(String strObjName : mapObjToQry.keySet())
                {
                    mapDCObjToDetails = mapObjToQry.get(strObjName);
                    if(mapDCObjToDetails != null && mapDCObjToDetails.get('SFDCRecordId') != null && mapDCObjToDetails.get('OperationType') != 'SELECT')
                        SFDC_Records.add(mapDCObjToDetails.get('SFDCRecordId'));
                }
                
                system.debug(loggingLevel.WARN, 'mapObjToQry = ' + mapObjToQry);
                
                String HighestId, LowestId;
                List<INTF_WebServicesDef.SVMXMap> multiWrapList;
                Integer recordsLimit = 35000, batch_index, current_batch_index;
                
                map<String, String> mapSettingsForIPAD018 = (map<String, String>)INTF_TxnCache.get('IPAD018_SET006', 'Map<String, String>');
                if(mapSettingsForIPAD018 == null || mapSettingsForIPAD018.size() == 0)
                {
                    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                    list<String> lstSettingId = new list<String>();
                    lstSettingId.add('SET006');
                    mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                    
                    INTF_TxnCache.put('IPAD018_SET006', mapSettingsForIPAD018, 'Map<String, String>');
                }
                
                if(mapSettingsForIPAD018.containskey('SET006') && mapSettingsForIPAD018.get('SET006') != null && mapSettingsForIPAD018.get('SET006').length() > 0)
                    recordsLimit = Integer.valueOf(mapSettingsForIPAD018.get('SET006'));
                
                system.debug(loggingLevel.WARN, '===Records Limit=: ' + recordsLimit);
                
                if(recordsLimit < 1)
                    recordsLimit = 35000;
                
                while(inputIterator.hasNext())
                {
                    INTF_WebServicesDef.SVMXMap selObject = new  INTF_WebServicesDef.SVMXMap();
                    selObject = inputIterator.next();
                    System.debug(LoggingLevel.WARN,'sb object---'+selObject);
                    if(selObject.key == 'LAST_INDEX')
                    {
                        if(selObject != null && selObject.value != null && selObject.value.length() > 0)
                            batch_index = Integer.valueOf(selObject.value);
                        else
                            batch_index = 0;
                        current_batch_index = batch_index + 1;
                    }
                }
                
                List<Integer> ser_batch_indexes = new List<Integer>();
                for(String eachObject : mapObjToQry.keySet())
                    ser_batch_indexes.add(Integer.valueOf(mapObjToQry.get(eachObject).get('IterationIndex')));
                
                system.debug(loggingLevel.WARN, '===Server Batch Index List=: ' + ser_batch_indexes + ' ===Current Batch Index=: ' + current_batch_index);
                
                ser_batch_indexes.sort();
                String strLastId = '';
                Boolean callBack = false;
                Integer record_count = 0;
                Integer server_higestIndex = ser_batch_indexes[ser_batch_indexes.size() - 1];
                
                if(server_higestIndex == batch_index)
                {
                    for(String eachObject : mapObjToQry.keySet())
                    {
                        mapDCObjToDetails = mapObjToQry.get(eachObject);
                        system.debug(loggingLevel.WARN, 'eachObject = ' + eachObject + '; mapDCObjToDetails' + mapDCObjToDetails);
                        callBack = true;
                        
                        if(mapDCObjToDetails.get('Status') != 'EXECUTED')
                        {
                            system.debug(LoggingLevel.WARN, 'Record Limit ' + recordsLimit);
                            if(record_count == 35000)
                                break;
                                
                            String query = mapDCObjToDetails.get('SOQLQuery'); 
                            HighestId = mapDCObjToDetails.get('SFDCRecordId');
                            LowestId =  mapDCObjToDetails.get('RecordId');
                            
                            if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && mapDCObjToDetails.get('SFDCRecordId') != null && mapDCObjToDetails.get('SFDCRecordId').length() > 0)
                                strLastId = mapDCObjToDetails.get('SFDCRecordId');
                                
                            if(HighestId == null || HighestId == '')
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    else
                                        query += ' Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                }
                                else 
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                    {
                                        if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        else
                                            query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ALL ROWS';
                                    }
                                    else
                                    {
                                        if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        else
                                            query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    else
                                        query += ' Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                }
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                    {
                                        if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ALL ROWS';
                                    }
                                    else
                                    {
                                        if(mapDCObjToDetails.get('Status') == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            
                            system.debug(LoggingLevel.WARN, 'Query string ' + query);
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            system.debug(LoggingLevel.WARN, 'Query string ' + queryResult);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = eachObject;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            system.debug(LoggingLevel.WARN,'Records limit' + recordsLimit + 'no of rows ' + queryResult.size());
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                System.debug(LoggingLevel.WARN,'In result > recordsLIMIT');
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                mapDCObjToDetails.put('RecordId', LowestId);
                                mapDCObjToDetails.put('SFDCRecordId', HighestId);
                                mapDCObjToDetails.put('Status', 'PARTIAL_EXECUTED');
                                mapDCObjToDetails.put('IterationIndex', String.valueOf(current_batch_index));
                                mapObjToQry.get(eachObject).putAll(mapDCObjToDetails);
                                INTF_TxnCache.put('DC_PARTIAL_EXEC_OBJECTS', mapObjToQry, 'map<String, map<String, String>>');
                                masterResponse.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObject));
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.WARN,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                mapObjToQry.remove(eachObject);
                                system.debug(LoggingLevel.WARN,'singleCacheRec = ' + singleCacheRec);
                            }
                            else if(queryResult.size() == 0)
                            {
                                system.debug(LoggingLevel.WARN,'In result == 0');
                                mapObjToQry.remove(eachObject);
                                system.debug(LoggingLevel.WARN,'singleCacheRec = ' + singleCacheRec);
                            }
                            system.debug(LoggingLevel.WARN,'mapObjToQry.size() =  ' + mapObjToQry.size() + ';recordsLimit = ' + recordsLimit);
                            if(mapObjToQry.size() <= 0 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }             
                    }
                    
                    if(callBack)
                    {
                        INTF_TxnCache.save(mapClientDetails, inputRequest.value);
                        INTF_WebServicesDef.SVMXMap call_back_Context = new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT', inputRequest.eventName);
                        INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack));
                        call_back.valueMap = new List<INTF_WebServicesDef.SVMXMap>{call_back_Context};
                        masterResponse.add(call_back);
                    }
                    
                    masterResponse.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(current_batch_index)));
                }
                else if(server_higestIndex > batch_index)
                {
                    for(String eachObject : mapObjToQry.keySet())
                    {
                        callBack = true;
                        mapDCObjToDetails = mapObjToQry.get(eachObject);
                        Integer bt_Index = Integer.valueOf(mapDCObjToDetails.get('IterationIndex'));
                        
                        if(bt_Index == current_batch_index)
                        {
                            System.debug(LoggingLevel.WARN, 'Inside mismatch loop------');
                            if(record_count == 35000)
                                break;
                            
                            String query = mapDCObjToDetails.get('SOQLQuery');
                            HighestId = mapDCObjToDetails.get('SFDCRecordId');
                            LowestId =  mapDCObjToDetails.get('RecordId');
                            
                            if(recordIds != null)
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(recordIds.size() > 0)
                                    {
                                        recordIds.sort();
                                        strLastId = recordIds[recordIds.size() - 1];
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                        query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                }
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                    {
                                        if(recordIds.size() > 0)
                                        {
                                            recordIds.sort();
                                            strLastId = recordIds[recordIds.size() - 1];
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ALL ROWS';
                                    }
                                    else
                                    {
                                        if(recordIds.size() > 0)
                                        {
                                            recordIds.sort();
                                            strLastId = recordIds[recordIds.size() - 1];
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                            query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                    query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DC_OPTIMZED')
                                        query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ALL ROWS';
                                    else
                                        query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                }
                            }
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = eachObject;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);  
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                masterResponse.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObject));
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.WARN,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                            }
                            if(mapObjToQry.size() <= 0 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }
                        
                        if(callBack)
                        {
                            INTF_TxnCache.save(inputRequest.value);
                            INTF_WebServicesDef.SVMXMap call_back_Context = new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT', inputRequest.eventName);
                            INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack));
                            call_back.valueMap = new List<INTF_WebServicesDef.SVMXMap>{call_back_Context};
                            masterResponse.add(call_back);
                        }
                        masterResponse.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(current_batch_index)));
                    }
                }
                
                mainVMDC.valueMap.addAll(masterResponse);
                response.valueMap.add(mainVMDC);
                
                system.debug(LoggingLevel.WARN, 'Call Back = ' + callBack);
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getIncrementalDCrecords');
        return response;
    }
    
    //To get events for requested range
    public List<Event> GetObjsTaggedToEvents(Datetime dtFromDateTime, Datetime dtToDateTime, Set<String> setAllowedObjects)
    {
        List<Event> lstEvents = new List<Event>();
        INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
        clsObjectDef.objectName = 'Event';
        INTF_WebServicesDef.SVMXMap objDef = clsObjectDef.INTF_GetObjectDefinition();
        if (objDef != NULL)
        {
            String strQuery = 'SELECT Id , What.Type , WhatId FROM EVENT ';
            if (dtToDateTime != null)
            {
                if (dtFromDateTime == null)
                {
                    //If start date is not available then set start day as end day - 10
                    Datetime dtCalculatedFromDate = dtToDateTime.addDays(-10);
                    strQuery += ' WHERE (((EndDateTime <= :dtToDateTime AND EndDateTime >= :dtCalculatedFromDate) OR (StartDateTime <= :dtToDateTime AND StartDateTime >= :dtCalculatedFromDate) OR (StartDateTime <= :dtCalculatedFromDate AND EndDateTime >= :dtToDateTime))';
                }
                else if (dtFromDateTime != null)
                {
                    System.debug(LoggingLevel.WARN,'Start date : '+dtFromDateTime + 'End date : '+dtToDateTime);
                    strQuery += ' WHERE (((StartDateTime <= :dtToDateTime AND StartDateTime >= :dtFromDateTime) OR (EndDateTime <= :dtToDateTime AND EndDateTime >= :dtFromDateTime) OR (StartDateTime <= :dtFromDateTime AND EndDateTime >= :dtToDateTime))';
                }
            }
            else if (dtToDateTime == null)
            {
                Datetime dn = datetime.now().addDays(30);
                strQuery += ' WHERE (EndDateTime <= :dn';
            }
            if(setAllowedObjects != null && setAllowedObjects.size() > 0)
                strQuery += ' AND OwnerId = ' + '\'' + Userinfo.getUserId() + '\'' + ' AND What.Type IN:setAllowedObjects) ';
            else
                strQuery += ' AND OwnerId = ' + '\'' + Userinfo.getUserId() + '\')';
            
            string set012 = getsettingIPAD018SET012();
            if(set012 != null)
                strQuery += ' ' + set012;
            system.debug(loggingLevel.WARN, 'Event Query: ' + strQuery);
            
            lstEvents = Database.query(strQuery);
        }
        return lstEvents;
    }
    
    //Get the download criteria in wrapper structure expected by client
    public Map<String, INTF_WebServicesDef.SVMXMap> getDownloadCriteriaObjDefns(String strDeviceType)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaObjDefns');
        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = (Map<String, INTF_WebServicesDef.SVMXMap>)INTF_TxnCache.get('DOWNLOAD_CRITERIA_OBJ_DEF', 'Map<String, INTF_WebServicesDef.SVMXMap>');
        if(mapObjDefinitions == null || mapObjDefinitions.size() == 0)
        {
            mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
            for(INTF_WebServicesDef.SVMXMap eachprocessObj : getDownloadCriteriaObjects(strDeviceType))
            {
                INTF_WebServicesDef.SVMXMap tmpObj = new INTF_WebServicesDef.SVMXMap();
                tmpObj.key = eachprocessObj.key;
                tmpObj.value = eachprocessObj.value;
                tmpObj.record = eachprocessObj.record;
                tmpObj.values = eachprocessObj.values;
                if(!mapObjDefinitions.containsKey(tmpObj.key))
                      mapObjDefinitions.put(tmpObj.key, tmpObj);
            }
            INTF_TxnCache.put('DOWNLOAD_CRITERIA_OBJ_DEF', mapObjDefinitions, 'Map<String, INTF_WebServicesDef.SVMXMap>');
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getDownloadCriteriaObjDefns');
        return mapObjDefinitions;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> getDownloadCriteriaObjects(String strDeviceType)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaObjects');
        Set<String> setAccessibleObjs = new Set<String>();  
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfigForGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapIdSVMXRuleProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        List<INTF_WebServicesDef.SVMXMap> response = (List<INTF_WebServicesDef.SVMXMap>)INTF_TxnCache.get('getDownloadCriteriaObjects', 'List<INTF_WebServicesDef.SVMXMap>');
        if(response != null && response.size() > 0)
            return response;
        
        response = new List<INTF_WebServicesDef.SVMXMap>();
        
        Id grpProfileId = (Id)INTF_TxnCache.get('GROUP_PROFILE_ID', 'Id');
        if(grpProfileId == null)
        {
            Sync_Utility clsUtility = new Sync_Utility();
            grpProfileId = clsUtility.getGroupProfileId(null, true);
            INTF_TxnCache.put('GROUP_PROFILE_ID', grpProfileId, 'Id');
        }
                
        system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);      
        String strMobConfQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';      
                    
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);       
        if(strDevConfId != NULL && strDevConfId != ''){     
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
        }       
        system.debug(LoggingLevel.WARN,'Query formed for getDownloadCriteriaObjects TxnCache = '+strMobConfQuery);              
        INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
        lstMobileConfigForGrpProfile = Database.Query(strMobConfQuery);         
        List<SVMXC__ServiceMax_Config_Data__c> lstDefaultGrpProf = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(lstMobileConfigForGrpProfile == null  || lstMobileConfigForGrpProfile.size() == 0 )
        {
            INTF_DataSync.logSOQL(intMethodCount,'Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = \'Configuration Profile\'  and SVMXC__Configuration_Type__c = \'Group\' and SVMXC__IsDefault__c = true');
            lstDefaultGrpProf = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile'  and SVMXC__Configuration_Type__c = 'Group' and SVMXC__IsDefault__c = true];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(lstDefaultGrpProf != null  && lstDefaultGrpProf.size() == 1 ){
                String strDefaultId = lstDefaultGrpProf[0].Id;  
                strMobConfQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =: strDefaultId';        
                if(strDevConfId != NULL && strDevConfId != ''){     
                    strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
                }       
                system.debug(LoggingLevel.WARN,'Second Query formed for getDownloadCriteriaObjects TxnCache = '+strMobConfQuery);       
                INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);      
                lstMobileConfigForGrpProfile = Database.Query(strMobConfQuery);                
            }
        }
        INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, LastModifiedDate FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= \'SVMX Rule\'');
        mapIdSVMXRuleProcess.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, LastModifiedDate FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'SVMX Rule']);
        
        setAccessibleObjs = (Set<String>)INTF_TxnCache.get('SET_ACCESSIBLE_OBJECTS', 'Set<String>');
        if(setAccessibleObjs == null || setAccessibleObjs.size() == 0)
        {
            setAccessibleObjs = new Set<String>();
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            allObjs = Schema.getGlobalDescribe();
            for(String objName : allObjs.keySet())
            {
                try
                {
                    if(allObjs.get(objName).getDescribe().isAccessible())
                        setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.WARN, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }
            
            INTF_TxnCache.put('SET_ACCESSIBLE_OBJECTS', setAccessibleObjs, 'Set<String>');
        }
        
        // Identify allowed objects and criteria
        if(lstMobileConfigForGrpProfile != NULL && lstMobileConfigForGrpProfile.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c profile: lstMobileConfigForGrpProfile)
            {
                INTF_WebServicesDef.SVMXMap objCriteria = new INTF_WebServicesDef.SVMXMap();
                if(profile.SVMXC__Object_Name__c != null && setAccessibleObjs.contains(profile.SVMXC__Object_Name__c.toLowerCase()))
                {
                    objCriteria.key = profile.SVMXC__Object_Name__c;
                    objCriteria.value = '';
                    String sCriteria = '';
                    String sUserId = UserInfo.getUserId();
                    if(String.ValueOf(profile.SVMXC__Ownership_Type__c) == 'My Records')
                        sCriteria = ' OwnerId = \'' + sUserId + '\'';
                    
                    if(mapIdSVMXRuleProcess.containsKey(profile.SVMXC__Dispatch_Process__c))
                    {
                        objCriteria.key = mapIdSVMXRuleProcess.get(profile.SVMXC__Dispatch_Process__c).SVMXC__Source_Object_Name__c;
                        objCriteria.record = mapIdSVMXRuleProcess.get(profile.SVMXC__Dispatch_Process__c);
                        if(sCriteria != '')
                            sCriteria += ' AND ';
                        sCriteria += '(' + mapIdSVMXRuleProcess.get(profile.SVMXC__Dispatch_Process__c).SVMXC__Parent_Object_Criteria__c + ')';
                    }
                    objCriteria.value = sCriteria;
                    objCriteria.values.add(String.valueOfGmt(profile.LastModifiedDate));
                    response.add(objCriteria);
                }
                else
                    system.debug(LoggingLevel.WARN, 'Object in Download Criteria which is not accessible is : ' + profile.SVMXC__Object_Name__c);
            }
        }
        
        INTF_TxnCache.put('getDownloadCriteriaObjects', response, 'List<INTF_WebServicesDef.SVMXMap>');
        INTF_DataSync.logMethodEndTS(intMethodCount,'getDownloadCriteriaObjects');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getRecordsForIds(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Map<String, String> mapErrorMessage = new Map<String, String>();
        boolean isLastBatch = false;
        try
        {
            List<INTF_WebServicesDef.SVMXMap> inputList = inputRequest.valueMap;
            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
            set<String> setRefObjToSkip = (set<String>)INTF_TxnCache.get('Tx_Fetch_setRefObjToSkip', 'set<String>');
            Integer intLimitRelationshipFields = (Integer)INTF_TxnCache.get('Tx_Fetch_LimitLookupFields', 'Integer');
            List<String> lstVersionInfo = new List<String>();
            List<String> lstExpectedVersionInfo = new List<String>{'13','1','0','9'};
            String strVersion = '';
            Boolean isCompatible = false;
            if(setRefObjToSkip == null || setRefObjToSkip.size() == 0)
            {
                setRefObjToSkip = new set<String>();
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                list<String> lstSettingId = new list<String>();
                lstSettingId.add('SET004');
                map<String, String> mapSettingsForIPAD018 = new map<String, String>();
                mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
                if(mapSettingsForIPAD018.containskey('SET004') && mapSettingsForIPAD018.get('SET004') != null)
                {
                    String strValue = mapSettingsForIPAD018.get('SET004');
                    list<String> lstValue = new list<String>();
                    lstValue = strValue.split(',');
                    if(lstValue.size() > 0)
                    {
                        for(Integer i = 0; i < lstValue.size(); i++)
                        {
                            setRefObjToSkip.add(lstValue[i].toUpperCase());
                        }
                    }
                }
                else
                {
                    setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
                    setRefObjToSkip.add('USER');
                    setRefObjToSkip.add('FEEDPOST');
                    setRefObjToSkip.add('SOLUTION');
                }
                INTF_TxnCache.put('Tx_Fetch_setRefObjToSkip', setRefObjToSkip, 'set<String>');
            }
            
            if(intLimitRelationshipFields == null || intLimitRelationshipFields < 1)
            {
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                list<String> lstSettingId = new list<String>{'SET013'};
                map<String, String> mapSettingsForIPAD018 = new map<String, String>();
                mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
                
                if(mapSettingsForIPAD018.containskey('SET013') && mapSettingsForIPAD018.get('SET013') != null)
                    intLimitRelationshipFields = integer.valueOf(mapSettingsForIPAD018.get('SET013'));
                else
                    intLimitRelationshipFields = 35;
                
                INTF_TxnCache.put('Tx_Fetch_LimitLookupFields', intLimitRelationshipFields, 'Integer');
            }
            
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    for(String strVersionInfo : clientInform.clientInfo)
                    {
                        if(strVersionInfo != null && strVersionInfo.length() > 0 && strVersionInfo.contains('appversion'))
                        {
                            List<String> lstVersion = new List<String>();
                            lstVersion = strVersionInfo.split(':');
                            if(lstVersion != null && lstVersion.size() == 2)
                            {
                                strVersion = lstVersion[1];
                                system.debug(LoggingLevel.WARN, 'Version = ' + strVersion);
                                strVersion = strVersion.replace('.', ':');
                                system.debug(LoggingLevel.WARN, 'Version = ' + strVersion);
                                lstVersionInfo = strVersion.split(':');
                                if(lstVersionInfo != null && lstVersionInfo.size() < 4)
                                {
                                    while(lstVersionInfo.size() < 4)
                                    {
                                        lstVersionInfo.add('0');
                                    }
                                }
                                for(Integer i = 0; i < 4; i++)
                                {
                                    system.debug(LoggingLevel.WARN,'Client Version = ' + lstVersionInfo[i] + '; Expected Version = ' + lstExpectedVersionInfo[i]);
                                    if(Integer.valueOf(lstVersionInfo[i]) > Integer.valueOf(lstExpectedVersionInfo[i]))
                                    {
                                        isCompatible = true;
                                        break;
                                    }
                                }
                            }   
                        }
                    }
                    if(isCompatible)
                        break;
                }
            }
    
            if(inputRequest.valueMap != null && inputRequest.valueMap.size() != 0)
            {
                for(INTF_WebServicesDef.SVMXMap TimeStampMap : inputRequest.valueMap)
                {
                    if(TimeStampMap.key == 'LAST_BATCH')
                        isLastBatch = boolean.valueOf(TimeStampMap.value);
                }
                Iterator<INTF_WebServicesDef.SVMXMap> reqMapIterator = inputList.Iterator();
                List<INTF_WebServicesDef.SVMXMap> secondLevelMap = new List<INTF_WebServicesDef.SVMXMap>();
                Integer response_size = 0;
                String strErrObjNames = '';
                if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'TX_FETCH_OPTIMZED')
                {
                    while(reqMapIterator.hasNext())
                    {
                        INTF_WebServicesDef.SVMXMap selObj = new INTF_WebServicesDef.SVMXMap();
                        INTF_WebServicesDef.SVMXMap selMap = new INTF_WebServicesDef.SVMXMap();
                        selMap = reqMapIterator.next();
                        if(selMap.key == 'LAST_BATCH')
                            continue;
                        String tableName = selMap.value;
                        List<String> SFIDList = selMap.values;
                        System.debug(LoggingLevel.WARN, 'Retrieving ' + SFIDList.size() + ' records for Object ' + tableName + ' with ID list ' +  SFIDList);
                        System.debug(LoggingLevel.WARN, 'Before retrieving fields - Heap size: ' + Limits.getHeapSize());
                        if(tableName != '' && tableName != null)
                        {
                            clsObjectDefinition.objectName = tableName;
                            try
                            {
                                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition(); 
                                List<String> fieldsName = new List<String>();
                                if (objDef != NULL) 
                                {
                                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                                    {
                                        if (objProp.key=='FIELDPROPERTY')
                                        {
                                            Integer refFieldCount = 0;
                                           for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                           {
                                                if(tableName == 'Attachment' && lstField.value == 'Body')
                                                {
                                                    system.debug(LoggingLevel.WARN, 'Attachment Object - do not query Body field');
                                                }
                                                else
                                                    fieldsName.add(lstField.value);
                                                if(refFieldCount == intLimitRelationshipFields)
                                                    continue;
                                                List<INTF_WebServicesDef.SVMXMap> fldProps = new List<INTF_WebServicesDef.SVMXMap>();
                                                fldProps = lstField.valueMap;
                                                String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', fldProps);
                                                if (reference_to != null)
                                                {
                                                    String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldProps);
                                                    String s;
                                                    if (reference_to == 'Case')
                                                    {
                                                        fieldsName.add(relationship_name + '.CaseNumber');
                                                        refFieldCount++;
                                                    }
                                                    else if (setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == null)
                                                        continue;
                                                    else
                                                    {
                                                        fieldsName.add(relationship_name + '.Name');
                                                        refFieldCount++;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
        
                                System.debug(LoggingLevel.WARN, 'Before retrieving records - Heap size: ' + Limits.getHeapSize());
                                List<INTF_WebServicesDef.SVMXMap> tableValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                                fieldsName = (new COMM_Utils_V2()).checkDuplicateFields(fieldsName , tableName); //Remove duplicate API fields
                                String strFldNames =  clsObjectDefinition.getObjectFieldNames(fieldsName);
                                objdef.valueMap.clear();
                                fieldsName.clear();
                                system.debug(LoggingLevel.WARN, 'Heap size before adding the retrieved records to response object : ' + Limits.getHeapSize());
                                for(Sobject selectedSobj : Database.query('Select ' + strFldNames + ' FROM '+ tableName + ' WHERE Id IN :SFIDList'))
                                {
                                    INTF_WebServicesDef.SVMXMap objMap = new INTF_WebServicesDef.SVMXMap();
                                    objMap.value = JSON.serialize(selectedSobj);
                                    tableValueMap.add(objMap);
                                    response_size += objMap.value.length();
                                    if (response_size > 3000000 || Limits.getHeapSize() > 5500000 || Limits.getCpuTime() > 7000)
                                    { 
                                        isLastBatch = false;
                                        break;
                                    }
                                }
                                system.debug(LoggingLevel.WARN, 'Heap size after adding the retrieved records to response object : ' + Limits.getHeapSize());
                                system.debug(LoggingLevel.WARN, 'Web Service response size: ' + response_size);
                                
                                selObj.value = tableName;
                                selObj.valueMap = tableValueMap;
                                secondLevelMap.add(selObj);
                                if (response_size > 3000000 || Limits.getHeapSize() > 5500000 || Limits.getCpuTime() > 7000)
                                { 
                                    isLastBatch = false;
                                    break;
                                }
                            }
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN, 'Error when trying to describe object ' + tableName + ':-' + ex.getMessage());
                                if(strErrObjNames != '') strErrObjNames += ',';
                                strErrObjNames += ' ' + tableName;
                                continue;
                            }
                        }
                    }
                }
                
                if(isLastBatch)
                {
                    //-----------Call Clean up------------
                    string strSyncQuery = 'Select Id from SVMXC__Sync_Request__c ';
                    dateTime dt = system.now().addHours(-6);
                    string strSyncReqId = inputRequest.value;
                    if(strSyncReqId != null && strSyncReqId.length() > 0)
                        strSyncQuery += 'where SVMXC__Client_Request_Id__c = :strSyncReqId OR LastModifiedDate <=: dt';
                    else
                        strSyncQuery += 'where LastModifiedDate <=: dt';
                    integer limitNoOfRecords = Limits.getLimitDMLRows() - Limits.getDMLRows() - 500;
                    if(limitNoOfRecords > 0)
                    {
                        strSyncQuery += ' limit :limitNoOfRecords';
                        List<SVMXC__Sync_Request__c> lstSyncRequest = database.query(strSyncQuery);
                        if(lstSyncRequest != null && lstSyncRequest.size() > 0)
                            delete lstSyncRequest;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            
                        integer remainingLimitNoOfRecords = Limits.getLimitDMLRows() - Limits.getDMLRows() - 100;
                        if(remainingLimitNoOfRecords!= null && remainingLimitNoOfRecords > 0)
                        {
                            integer noOfDays = 30;
                            INTF_ConfigSync confSync = new INTF_ConfigSync();
                            string svmxGrpProfileId = confSync.getSVMXGrpProfileId(userinfo.getProfileId());
                            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = confSync.getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET015'}, svmxGrpProfileId);
                            if(lstSettings != null && lstSettings.size() > 0){
                                for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                                    noOfDays = integer.valueOf(cnf.SVMXC__Internal_Value__c);
                            }
                            noOfDays = -noOfDays;
                            dateTime dtToDelete = system.now().addDays(noOfDays);
                            string strSVMXJobLogQuery = 'Select Id from SVMXC__SVMX_Job_Logs__c where (SVMXC__Type__c = \'iPad\' OR SVMXC__Type__c = \'iPhone\') AND LastModifiedDate <=: dtToDelete limit: remainingLimitNoOfRecords';
                            system.debug(loggingLevel.WARN, '=Query to delete the Job log Data=: ' + strSVMXJobLogQuery);
                            List<SVMXC__SVMX_Job_Logs__c> lstSVMXJobLogs = database.query(strSVMXJobLogQuery);
                            system.debug(loggingLevel.WARN, '=Queried data to delete the Job log=: ' + lstSVMXJobLogs);
                            if(lstSVMXJobLogs != null && lstSVMXJobLogs.size() > 0)
                                delete lstSVMXJobLogs;    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        }
                    }
                    //-----------------------------------   
                }
                else
                {
                    INTF_TxnCache.save(inputRequest.value);
                }
                
                if(response_size == 0)
                {
                    system.debug(LoggingLevel.WARN, 'Objects with Errors = ' + strErrObjNames + '; isCompatible = ' + isCompatible);
                    if((strErrObjNames != null && strErrObjNames.length() > 0) || !isCompatible)
                    {
                        mapErrorMessage.put(system.label.IPAD018_TAG054, strErrObjNames + system.label.IPAD018_TAG055);
                        throw new SmaxException();
                    }
                    else
                    {
                        INTF_WebServicesDef.SVMXMap objSafeToDelete = new INTF_WebServicesDef.SVMXMap();
                        objSafeToDelete.key = 'SAFE_TO_DELETE';
                        for(INTF_WebServicesDef.SVMXMap eachObj : inputRequest.valueMap)
                        {
                            if(eachObj.key == 'TX_OBJECT')
                            {
                                List<String> lstSuspectedIds = eachObj.values;
                                List<String> lstDeletedIds = new List<String>();
                                for(sobject eachRecord : Database.query('Select Id, isDeleted FROM '+ eachObj.value + ' WHERE Id IN :lstSuspectedIds ALL ROWS'))
                                {
                                    if(eachRecord.get('isDeleted') == true)
                                    {
                                        lstDeletedIds.add(String.valueOf(eachRecord.get('Id')));
                                    }
                                }
                                system.debug(LoggingLevel.WARN, 'Total deleted Ids during Sync are = ' + lstDeletedIds.size() + '; Ids are = ' + lstDeletedIds);
                                objSafeToDelete.valueMap.add(new INTF_WebServicesDef.SVMXMap(eachObj.value, '', lstDeletedIds));
                            }
                        }
                        secondLevelMap.add(objSafeToDelete);
                    }
                }
                response.valueMap = secondLevelMap;
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(mapErrorMessage, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        return response;
    }
    
    public String GetValueForKeyInSVMXMapList(String Key, List<INTF_WebServicesDef.SVMXMap> SVMXMapList)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('GetValueForKeyInSVMXMapList');
        for (INTF_WebServicesDef.SVMXMap svmxmapIter : SVMXMapList)
        {
            if (svmxmapIter.key == Key){
                INTF_DataSync.logMethodEndTS(intMethodCount, 'GetValueForKeyInSVMXMapList');
                return svmxmapIter.value;
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'GetValueForKeyInSVMXMapList');
        return null;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getEventsAndRelatedRecords(INTF_WebServicesDef.INTF_SFMRequest inputRequest, INTF_WebServicesDef.INTF_SFMResponse response)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getEventsAndRelatedRecords');
        dateTime getUpdateStartTime = dateTime.now();
        system.debug(loggingLevel.WARN, 'Event Name = ' + inputRequest.eventName);
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> multiWrapList;
        List<Event> lstAllEvents = new List<Event>();
        List<Event> lstModifiedEvents = new List<Event>();
        List<Task> lstModifiedTasks = new List<Task>();
        List<String> recordIDs = new List<String>();
        List<SVMXC__SVMX_Event__c> lstModifiedSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        Set<String> setAccessibleObjs = new Set<String>();
        String strEventQry = '', strTaskQry = '', strTimeClause = '', strSVMXEventSOQL = '';
        String strUserId = UserInfo.getUserId();
        Datetime dtToDate, dtFromDate, dtLastSyncTime, dtMovingDate;
        Date ToDate, FromDate;
        Datetime currentTime = Datetime.now();
        
        for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
        {
            if(eachReqParam.key == 'LAST_SYNC_TIME' && eachReqParam.value != null && eachReqParam.value.length() > 0)
            {
                dtLastSyncTime = Datetime.valueOf(eachReqParam.value);
                break;
            }
        }
        strTimeClause = ' and LastModifiedDate >= :dtLastSyncTime ';
        
        Id idGrpProfile = (Id)INTF_TxnCache.get('GROUP_PROFILE_ID', 'Id');
        if(idGrpProfile == null)
        {
            idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, true);
            INTF_TxnCache.put('GROUP_PROFILE_ID', idGrpProfile, 'Id');
        }
        
        setAccessibleObjs = getAllowedSetOfObjects(idGrpProfile);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfig = (List<SVMXC__ServiceMax_Config_Data__c>)INTF_TxnCache.get('SYNC_MOBILE_CONFIG', 'List<SVMXC__ServiceMax_Config_Data__c>');
        if(lstMobileConfig == null || lstMobileConfig.size() == 0)
        {
            //Get Device specific settings:
            string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);  
            system.debug(LoggingLevel.WARN,' Device in getEventsAndRelatedRecords strDeviceType = '+strDeviceType);     
            String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';      
                
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(idGrpProfile, strDeviceType);       
            if(strDevConfId != NULL && strDevConfId != ''){     
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
            }       
            system.debug(LoggingLevel.WARN,'Query formed for getEventsAndRelatedRecords = '+strMobConfQuery);       
                
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);      
            lstMobileConfig = Database.Query(strMobConfQuery);
            INTF_TxnCache.put('SYNC_MOBILE_CONFIG', lstMobileConfig, 'List<SVMXC__ServiceMax_Config_Data__c>');
        }

        for(SVMXC__ServiceMax_Config_Data__c objConfigData : lstMobileConfig)
        {
            Integer intValue = 10;
            if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Remove Events')
            {
                if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                {
                    intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                    if(intValue < 1)
                        intValue = 10;
                }   
                dtFromDate = currentTime - (intValue + 1);
                FromDate = Date.valueOf(currentTime - (intValue + 1));
            }   
            else if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Get Events')
            {
                if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                {
                    intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                    if(intValue < 1)
                        intValue = 10;
                }   
                dtToDate = currentTime + intValue + 1;
                ToDate = Date.valueOf(currentTime + intValue + 1);

                dtMovingDate = dtLastSyncTime + intValue + 1;
            }
            if(objConfigData.LastModifiedDate > dtLastSyncTime && inputRequest.eventName == 'GET_UPDATE')
            {
                strTimeClause = '';//do not apply lastsync in query
            }
        }

        /*FromDate = Date.valueOf(dtFromDate); --> these values have been set earlier after querying event window
        ToDate = Date.valueOf(dtToDate);*/
        system.debug(LoggingLevel.WARN,'Dates for task - ToDate = '+ToDate + ' - FromDate = '+FromDate);  
        system.debug(loggingLevel.WARN, 'Moving Date: ' + dtMovingDate + ' :To date: ' + dtToDate + ' :From Date: ' + dtFromDate + ' :Last Sync Time: ' + dtLastSyncTime);
        
        string set012 = getsettingIPAD018SET012();

        
        /************Service Power - Drip Feed***************/
        Boolean isDripFeed = false;
        String strListObjandFields = '';
        Set<Id> setIdsToRemove = new Set<Id>();
        Set<Id> setEventIdsToRemove = new Set<Id>();
        Map<Id, List<Id>> mapEventIdToWhatId = new Map<Id, List<Id>>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<String> lstSettingId = new list<String>{'SET001','SET002'};
        map<String, String> mapSettForDispatch = new map<String, String>();
        mapSettForDispatch = commSettings.SVMX_getSettingList('DCON002', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettForDispatch);
        if(mapSettForDispatch.containskey('SET001') && mapSettForDispatch.get('SET001') != null && mapSettForDispatch.get('SET001').length() > 0)
        {
            isDripFeed = Boolean.valueOf(mapSettForDispatch.get('SET001'));
        }
        if(mapSettForDispatch.containskey('SET002') && mapSettForDispatch.get('SET002') != null && mapSettForDispatch.get('SET002').length() > 0)
        {
            strListObjandFields = String.valueOf(mapSettForDispatch.get('SET002'));
        }
        system.debug(LoggingLevel.WARN, 'isDripFeed = ' + isDripFeed + '; List of Objects configured = ' + strListObjandFields);
        
        if(isDripFeed)
        {
            mapEventIdToWhatId = (new INTF_DataUtilityServices()).getDripFeedRelatedRecords(dtToDate, dtFromDate, strUserId, strListObjandFields);
            setIdsToRemove.addAll(mapEventIdToWhatId.keySet());
            for(Id eachId : mapEventIdToWhatId.keySet())
                setEventIdsToRemove.addAll(mapEventIdToWhatId.get(eachId));
        }
        /***************************/
        
        if(inputRequest.eventName == 'GET_UPDATE')
        {
            strEventQry = 'Select Id from Event where (OwnerId = :strUserId  and ((((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) ' + strTimeClause + ' ) OR ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate))) and Id NOT IN :setEventIdsToRemove)';
            strTaskQry = 'Select Id from Task where OwnerId= :strUserId and (ActivityDate <= : ToDate And ActivityDate >= :FromDate) ' + strTimeClause;
            strSVMXEventSOQL = 'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) ' + strTimeClause + ') OR ((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate))) AND SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' +' AND Id NOT IN :setEventIdsToRemove)';
            
            if(set012 != null)
            {
                strEventQry += ' ' + set012;
                strSVMXEventSOQL += ' ' + set012;
            }
            system.debug(loggingLevel.WARN, 'Event Query: ' + strEventQry);
        }   
        
        else if(inputRequest.eventName == 'GET_DELETE')
        {
            strEventQry = 'Select Id from Event where (OwnerId = :strUserId and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and isDeleted = true ' + strTimeClause + ' and Id NOT IN :setEventIdsToRemove)';
            strTaskQry = 'Select Id from Task where OwnerId= :strUserId and (ActivityDate <= : ToDate And ActivityDate >= :FromDate ) and isDeleted = true ' + strTimeClause + ' All ROWS ';
            strSVMXEventSOQL = 'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' + ' and isDeleted = true ' + strTimeClause + ' AND Id NOT IN :setEventIdsToRemove)';
            
            if(set012 != null)
            {
                strEventQry += ' ' + set012;
                strSVMXEventSOQL += ' ' + set012;
            }
            strEventQry += ' ALL ROWS';
            strSVMXEventSOQL += ' ALL ROWS';
        }
        
        system.debug(loggingLevel.WARN, 'Event Query: ' + strEventQry + ' :Task Query: ' + strTaskQry);
        system.debug(loggingLevel.WARN, 'SVMX Events Query : ' + strSVMXEventSOQL);
        
        INTF_DataSync.logSOQL(intMethodCount,strEventQry);
        lstModifiedEvents = Database.query(strEventQry);
        
        INTF_DataSync.logSOQL(intMethodCount,strSVMXEventSOQL);
        lstModifiedSVMXEvents = Database.query(strSVMXEventSOQL);
        
        INTF_DataSync.logSOQL(intMethodCount,strTaskQry);
        lstModifiedTasks = Database.query(strTaskQry);
        
        if(lstModifiedTasks != null && lstModifiedTasks.size() > 0)
        {
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap taskWrap = new INTF_WebServicesDef.SVMXMap('Parent_Object', 'Task');
            multiWrapList.add(new INTF_WebServicesDef.SVMXMap('Fields', Json.serialize(lstModifiedTasks)));
            taskWrap.valueMap = multiWrapList;
            masterResponse.add(taskWrap);
        }
        
        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap EachObjDef = new INTF_WebServicesDef.SVMXMap();
        INTF_GetObjectDefinition objDef = new INTF_GetObjectDefinition();
        List<ID> lstRecIdsOfModifiedEvents = new List<ID>();
        List<sObject> lstsObjects = new List<sObject>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        
        if(set012 == null)
            set012 = '';
            
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, WhatId, What.Type from Event where OwnerId = :strUserId  and (What.Type IN :setAccessibleObjs OR What.Type = null) and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and Id NOT IN :setEventIdsToRemove ' + set012);
        for (Event evt: Database.query('Select Id, WhatId, What.Type from Event where OwnerId = :strUserId  and (What.Type IN :setAccessibleObjs OR What.Type = null) and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and Id NOT IN :setEventIdsToRemove ' + set012))
        {
            lstAllEvents.add(evt);
            if(evt.What.Type != null)
            {
                if(mapObjDefinitions.size() == 0 || (!mapObjDefinitions.containsKey(evt.What.Type)))
                {
                    objDef.objectName = evt.What.Type;
                    EachObjDef = objDef.INTF_GetMasterChildDefinition();
                    mapObjDefinitions.put(evt.What.Type, EachObjDef);
                }
                recordIDs.add(evt.WhatID);
            }
        }
        
        INTF_DataSync.logSOQL(intMethodCount,'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' + ' and Id NOT IN :setEventIdsToRemove) ' + set012);
        lstSVMXEvents = Database.query('SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' + ' and Id NOT IN :setEventIdsToRemove) ' + set012);
        
        for (SVMXC__SVMX_Event__c evt: lstSVMXEvents)
        {
            if(evt.SVMXC__WhatId__c != null && evt.SVMXC__WhatId__c != '' && Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType() != null)
            {
                if(mapObjDefinitions.size() == 0 || (!mapObjDefinitions.containsKey(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()))))
                {
                    objDef.objectName = String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType());
                    EachObjDef = objDef.INTF_GetMasterChildDefinition();
                    mapObjDefinitions.put(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()), EachObjDef);
                }
                recordIDs.Add(evt.SVMXC__WhatId__c);
            }   
        }
        
        if(inputRequest.eventName == 'GET_UPDATE')
        {
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap allEvents = new INTF_WebServicesDef.SVMXMap('ALL_EVENTS', 'Event');
            multiWrapList.add(new INTF_WebServicesDef.SVMXMap('REC_IDS', Json.serialize(lstAllEvents)));
            allEvents.valueMap = multiWrapList;
            masterResponse.add(allEvents);
            
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap allSVMXEvents = new INTF_WebServicesDef.SVMXMap('ALL_SVMXEVENTS', 'SVMXC__SVMX_Event__c');
            multiWrapList.add(new INTF_WebServicesDef.SVMXMap('REC_IDS', Json.serialize(lstSVMXEvents)));
            allSVMXEvents.valueMap = multiWrapList;
            masterResponse.add(allSVMXEvents);
        }
        
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, WhatId, What.Type from Event where OwnerId = :strUserId  and ID IN :lstModifiedEvents and What.Type IN :setAccessibleObjs');
        for (Event evt: [Select Id, WhatId, What.Type from Event where OwnerId = :strUserId  and ID IN :lstModifiedEvents and What.Type IN :setAccessibleObjs])
        {
            lstRecIdsOfModifiedEvents.add(evt.WhatID);
        }
        
        for (SVMXC__SVMX_Event__c svmxEvt: lstModifiedSVMXEvents)
        {
            if(svmxEvt.SVMXC__WhatId__c != null && svmxEvt.SVMXC__WhatId__c != '' && setAccessibleObjs.contains(String.valueOf(Id.valueOf(svmxEvt.SVMXC__WhatId__c).getsObjectType())))
            {
                lstRecIdsOfModifiedEvents.add(svmxEvt.SVMXC__WhatId__c);
            }
        }
        
        for(String objName: mapObjDefinitions.keySet())
        {
            if (recordIDs.size() > 0 || lstRecIdsOfModifiedEvents.size() > 0)
            {
                system.debug(loggingLevel.WARN, '==Master Obj: ' + objName);
                for(INTF_WebServicesDef.SVMXMap objProp : mapObjDefinitions.get(objName).valueMap)
                {
                    if(objProp.key=='OBJECTPROPERTY')
                    {
                        for(INTF_WebServicesDef.SVMXMap eachMasterDetail : objProp.valueMap)
                        {
                            for(INTF_WebServicesDef.SVMXMap masterDetail : eachMasterDetail.valueMap)
                            {
                                if(masterdetail.key=='MASTERDETAILS')
                                {
                                    for(INTF_WebServicesDef.SVMXMap lstChild: masterdetail.valueMap)
                                    {
                                        system.debug(loggingLevel.WARN, '==Child Obj: ' + lstChild.key);
                                        if(setAccessibleObjs.contains(lstChild.key))
                                        {
                                            String childQuery;
                                            if(inputRequest.eventName == 'GET_DELETE')
                                                childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE isDeleted = true AND ' + lstChild.Value + ' IN :recordIDs ' + strTimeClause + ' All Rows ';
                                            else if(inputRequest.eventName == 'GET_UPDATE')
                                                childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE (' + lstChild.Value + ' IN :recordIDs ' + strTimeClause + ') OR (' + lstChild.Value + ' IN :lstRecIdsOfModifiedEvents)';
                                            system.debug(LoggingLevel.WARN, 'Child Query = ' + childQuery);
                                            INTF_DataSync.logSOQL(intMethodCount,childQuery);
                                            List<SObject> qryChildResult = Database.query(childQuery);
                                            if( qryChildResult!=null && qryChildResult.size() > 0 )
                                            {
                                                masterWrap = new INTF_WebServicesDef.SVMXMap('Child_Object', lstChild.key);
                                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                                multiWrapList.add(new INTF_WebServicesDef.SVMXMap('Fields', Json.serialize(qryChildResult))); 
                                                masterWrap.valueMap = multiWrapList;    
                                                masterResponse.add(masterWrap);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                String strParentQuery;
                if(inputRequest.eventName == 'GET_DELETE')
                    strParentQuery = 'SELECT Id FROM ' + objName + ' WHERE Id IN :recordIDs AND isDeleted = true ' + strTimeClause + ' All Rows ';
                else if(inputRequest.eventName == 'GET_UPDATE')
                    strParentQuery = 'SELECT Id FROM ' + objName + ' WHERE (Id IN :recordIDs ' + strTimeClause + ') OR (Id IN : lstRecIdsOfModifiedEvents)';
                system.debug(LoggingLevel.WARN, 'Parent Query = ' + strParentQuery);
                INTF_DataSync.logSOQL(intMethodCount,strParentQuery);
                List<SObject> qryResult = Database.query(strParentQuery);
                lstsObjects.addAll(qryResult);
                if (qryResult != null && qryResult.size() > 0)
                {
                    masterWrap = new INTF_WebServicesDef.SVMXMap('Parent_Object', objName);
                    multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                    multiWrapList.add(new INTF_WebServicesDef.SVMXMap('Fields', Json.serialize(qryResult)));
                    masterWrap.valueMap = multiWrapList;
                    masterResponse.add(masterWrap);
                }
            }
        }
        
        INTF_DataSync.logSOQL(intMethodCount,'select Id from Event where OwnerId = :strUserId and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and whatId IN:lstsObjects and Id NOT IN:lstModifiedEvents');
        for(Event eachEvent : [select Id from Event where OwnerId = :strUserId and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and whatId IN:lstsObjects and Id NOT IN:lstModifiedEvents])
        {
            lstModifiedEvents.add(eachEvent);
        }
        system.debug(LoggingLevel.Warn, 'All Events which are modified and whose Whatids are modified = ' + lstModifiedEvents);
        if (lstModifiedEvents != null && lstModifiedEvents.size() > 0)
        {
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap eventWrap = new INTF_WebServicesDef.SVMXMap('Parent_Object', 'Event');
            multiWrapList.add(new INTF_WebServicesDef.SVMXMap('Fields', Json.serialize(lstModifiedEvents)));
            eventWrap.valueMap = multiWrapList;
            masterResponse.add(eventWrap);
        }
        
        if(lstModifiedSVMXEvents != null && lstModifiedSVMXEvents.size() > 0 )
            masterResponse.add(new INTF_WebServicesDef.SVMXMap('SVMXC__SVMX_Event__c', JSON.serialize(lstModifiedSVMXEvents)));
        
        if(response.success == null)
            response.success = true; 
        
        INTF_WebServicesDef.SVMXMap mainVM = new INTF_WebServicesDef.SVMXMap();
        mainVM.key = inputRequest.eventName;
        mainVM.valueMap = masterResponse;
        
        if(inputRequest.eventName == 'GET_UPDATE')
            mainVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('GET_UPDATE_LST', string.valueOf(getUpdateStartTime)));
            
        response.valueMap.add(mainVM);
        
        //DC/ADC optimization -> cache the eventIds
        if(inputRequest.eventName == 'GET_UPDATE'){   //Execute this during get_update because during GET_DELETE we get the deleted event Ids
            if(!recordIDs.isEmpty() || !lstRecIdsOfModifiedEvents.isEmpty()){
                    (new INTF_DataUtilityServices()).updateEventIdsInRequestCache(recordIDs, lstRecIdsOfModifiedEvents, inputRequest);
            }  
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getEventsAndRelatedRecords');
        return response;
    }
    
    public Set<String> getAllowedSetOfObjects(Id idGrpProfile)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAllowedSetOfObjects');
        Map<Id, SVMXC__ServiceMax_Processes__c> mapIdProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapIdAllProcesses = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Set<String> setAllowedObjects = new Set<String>();
        Set<String> setAccessibleObjs;
        List<String> lstProcessTypes = new List<String>{'VIEW RECORD', 'STANDALONE CREATE', 'STANDALONE EDIT', 'SOURCE TO TARGET ALL', 'SOURCE TO TARGET CHILD', 'OUTPUT DOCUMENT'};
        
        setAccessibleObjs = (Set<String>)INTF_TxnCache.get('SET_ACCESSIBLE_OBJECTS', 'Set<String>');
        if(setAccessibleObjs == null || setAccessibleObjs.size() == 0)
        {
            setAccessibleObjs = new Set<String>();
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            allObjs = Schema.getGlobalDescribe();
            for(String objName : allObjs.keySet())
            {
                try
                {
                    if(allObjs.get(objName).getDescribe().isAccessible())
                        setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.WARN, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }   
            INTF_TxnCache.put('SET_ACCESSIBLE_OBJECTS', setAccessibleObjs, 'Set<String>');
        }
        INTF_DataSync.logSOQL(intMethodCount,'Select Id, Name, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c, SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= \'Target Manager\' AND SVMXC__Purpose__c IN :lstProcessTypes AND SVMXC__Dispatch_Process_Status__c = \'Complete\'');
        mapIdAllProcesses.putAll([Select Id, Name, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c, SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'Target Manager' AND SVMXC__Purpose__c IN :lstProcessTypes AND SVMXC__Dispatch_Process_Status__c = 'Complete']);
    
        system.debug(LoggingLevel.Warn, 'Group Profile = ' + idGrpProfile + ', Number of processes returned = ' + mapIdAllProcesses.size());
    
        if(mapIdAllProcesses != null && mapIdAllProcesses.size() > 0)
        {
            Set<Id> setAllAccessProcessId = new Set<Id>();
            setAllAccessProcessId.addAll(mapIdAllProcesses.keyset());
            if(idGrpProfile != null)
            {
                set<Id> setAssignedProcess = new set<Id>();
                set<Id> setNotAssignedProcess = new set<Id>();
                INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Service Flow Access\' AND SVMXC__Dispatch_Process__c In: setAllAccessProcessId');
                for (SVMXC__ServiceMax_Config_Data__c ConfigObj : [Select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Service Flow Access' AND SVMXC__Dispatch_Process__c In: setAllAccessProcessId])
                {
                    if(ConfigObj.SVMXC__Access_Configuration_Profile__c != null)
                    {
                        if(idGrpProfile == ConfigObj.SVMXC__Access_Configuration_Profile__c)
                            setAssignedProcess.add(ConfigObj.SVMXC__Dispatch_Process__c);
                        else
                            setNotAssignedProcess.add(ConfigObj.SVMXC__Dispatch_Process__c);
                    }
                }
                setAllAccessProcessId.removeAll(setNotAssignedProcess);
                setAllAccessProcessId.addAll(setAssignedProcess);
            }
            for(Id SFMprocessId : setAllAccessProcessId)
                mapIdProcess.put(SFMprocessId, mapIdAllProcesses.get(SFMprocessId));
                
            system.debug(LoggingLevel.Warn, 'Assigned Number of processes = ' + mapIdProcess.size());
            
            if(mapIdProcess != null && mapIdProcess.size() > 0)
            {
                INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' And SVMXC__Process__c IN :mapIdProcess.keySet()');
                for(SVMXC__ServiceMax_Processes__c process : [Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Process Node Objects' And SVMXC__Process__c IN :mapIdProcess.keySet()])
                {
                    if(process.SVMXC__Source_Object_Name__c != null && process.SVMXC__Source_Object_Name__c != '')
                    {
                        if(setAccessibleObjs.contains(process.SVMXC__Source_Object_Name__c.toLowerCase()))
                        {
                            setAllowedObjects.add(process.SVMXC__Source_Object_Name__c);
                        }
                    }   
                }
                Set<Id> setPageLayoutIds = new Set<Id>();
                for(SVMXC__ServiceMax_Processes__c SFMprocess : mapIdProcess.values())
                {
                    setPageLayoutIds.add(SFMprocess.SVMXC__Page_Layout__c);
                }   
    
                INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN (Select Id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN :setPageLayoutIds OR Id IN :setPageLayoutIds) AND SVMXC__DataType__c = \'reference\'');
                for(SVMXC__Page_Layout_Detail__c pageLayoutDetail : [Select Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Related_Object_Name__c from SVMXC__Page_Layout_Detail__c where SVMXC__Page_Layout__c IN (Select Id from SVMXC__Page_Layout__c where SVMXC__Header_Page_Layout__c IN :setPageLayoutIds OR Id IN :setPageLayoutIds) AND SVMXC__DataType__c = 'reference'])
                {
                    if(pageLayoutDetail.SVMXC__Related_Object_Name__c != null && pageLayoutDetail.SVMXC__Related_Object_Name__c != '')
                    {
                        if(setAccessibleObjs.contains(pageLayoutDetail.SVMXC__Related_Object_Name__c.toLowerCase()) && !setAllowedObjects.contains(pageLayoutDetail.SVMXC__Related_Object_Name__c))
                        {
                            setAllowedObjects.add(pageLayoutDetail.SVMXC__Related_Object_Name__c);
                        }
                    }
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getAllowedSetOfObjects');
        return setAllowedObjects;
    }

    public INTF_WebServicesDef.INTF_SFMResponse UpdateClientDataIntoBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest,string strDeviceType, Map<String, DateTime> mapIdToRecordLST)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('UpdateClientDataIntoBase');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Database.Saveresult[] parentsaveresult;
        List<INTF_WebServicesDef.SVMXError> errors = new List<INTF_WebServicesDef.SVMXError>(); 
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        ErrorHeader.key = 'ERROR'; 
        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap();
        conflictHeader.key = 'CONFLICT';
        try
        {
            Boolean isFieldLevelSyncConflict = false;
            String strSyncConflict = '', strClientType = '';
            list<String> lstSettingId = new list<String>{'SET016'};
            map<String, String> mapSettingsForIPAD018 = new map<String, String>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            
            Id grpProfileId = (Id)INTF_TxnCache.get('GROUP_PROFILE_ID', 'Id');
            if(grpProfileId == null)
            {
                grpProfileId = (new Sync_Utility()).getGroupProfileId(null, true);
                INTF_TxnCache.put('GROUP_PROFILE_ID', grpProfileId, 'Id');
            }
            
            mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            if(mapSettingsForIPAD018.containskey('SET016') && mapSettingsForIPAD018.get('SET016') != null && mapSettingsForIPAD018.get('SET016').length() > 0)
                isFieldLevelSyncConflict = Boolean.valueOf(mapSettingsForIPAD018.get('SET016'));
            
            strSyncConflict = (String)INTF_TxnCache.get('CONFLICT_STRING', 'String');
            if(strSyncConflict == null)
            {
                system.debug(LoggingLevel.WARN,' Device from Request UpdateClientDataIntoBase = '+strDeviceType);
                String strMobConfQuery  = 'select SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'Conflict Resolution\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
         
                String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
                if(strDevConfId != NULL && strDevConfId != ''){
                    strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                }
                strMobConfQuery += ' LIMIT 1';
                system.debug(LoggingLevel.WARN,'Query formed for UpdateClientDataIntoBase = '+strMobConfQuery);
        
                INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
                for(SVMXC__ServiceMax_Config_Data__c confgData : Database.Query(strMobConfQuery))    
                    strSyncConflict = confgData.SVMXC__Internal_Value__c;
                    
                INTF_TxnCache.put('CONFLICT_STRING', strSyncConflict, 'String');
            }
            
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strClientType = clientInform.clientType;
                        break;
                    }
                }
            }
        
            system.debug(loggingLevel.WARN, 'Conflict Resolution Config String: ' + strSyncConflict + '; ; Field Level Sync Conflict =' + isFieldLevelSyncConflict + '; Client Type = ' + strClientType);
            
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_UPDATE')
            {
                if(isFieldLevelSyncConflict)
                    responseValueMap = updateRecordsFromClient(inputRequest, dt_PutUpdate, strSyncConflict, mapIdToRecordLST);
                else
                {
                    
                    List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
                    List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                    INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
                    Datetime LastSynchTime ;
                    INTF_WebServicesDef.SVMXMap successUpdatedIds = new INTF_WebServicesDef.SVMXMap('SUCCESS_RECIDS','');
                    
                    for(INTF_WebServicesDef.SVMXMap firstLevelMap : inputRequest.valueMap)
                    {
                        if(isInternalBatch){
                            break;
                        }
                        
                        system.debug(LoggingLevel.WARN, 'Each Value Map in Request: ' + firstLevelMap);
                        INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap(); 
                        List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
                        
                        if(firstLevelMap.key == 'SYNC_TIME_STAMP')
                            LastSynchTime = Datetime.valueOf(firstLevelMap.value);
                        
                        system.debug(loggingLevel.WARN, 'SYNC_TIME_STAMP = ' + LastSynchTime + ', Sync Start Time = ' + dt_PutUpdate);
                            
                        if(firstLevelMap.key == 'object_name') 
                        {
                            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                            clsObjectDefinition.objectName = firstLevelMap.value;
                            
                            INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                            MAP<String,String> fieldsType = new Map<String,String>();
                            Map<String, String> fieldUpdateable = new Map<String, String>();

                            Schema.SObjectType objecttype = Schema.getGlobalDescribe().get(firstLevelMap.value);
                            INTF_WebServicesDef.SVMXMap successfulIDMap = new INTF_WebServicesDef.SVMXMap(String.Valueof(firstLevelMap.value),'');

                            if (objDef != NULL)
                            {
                                for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                                {
                                    if (objProp.key=='FIELDPROPERTY')
                                    {
                                        for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                        {
                                            for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                            {
                                                if(fldObj.key == 'TYPE')
                                                    fieldsType.put(lstField.value, fldObj.value);
                                                if(fldObj.key == 'UPDATEABLE')
                                                    fieldUpdateable.put(lstField.value,fldObj.value);
                                            }
                                        }
                                    }
                                }
                            }

                            system.debug(loggingLevel.WARN, 'Map of Field Type: ' + fieldsType);
                            system.debug(loggingLevel.WARN, 'Map of field updateable: ' + fieldUpdateable);
                            
                            List<sObject> sobjList = new List<sObject>(); 
                            
                            for(INTF_WebServicesDef.SVMXMap secondLevelMap : firstLevelMap.valueMap)
                            {
                                
                                Set<String> setDeletedIds = new Set<String>();
                                if(secondLevelMap.key == 'Fields')
                                {
                                    system.debug(LoggingLevel.WARN, 'Inside Fields');
                                    List<String> RequestSFIDs = new List<String>();
                                    List<String> RecSfids = new List<String>();
                                    
                                    for(INTF_WebServicesDef.SVMXMap selectedObj : secondLevelMap.valueMap)
                                    {
                                        system.debug(LoggingLevel.WARN, 'selectedObj = ' + selectedObj);
                                        if(selectedObj.key != 'BEFORE_SAVE')
                                        {
                                            String conflictHandle =  selectedObj.key;
                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');

                                            Map<string, String> nameToValueMap = (Map<string, String>)JSON.deserialize(jstr, Map<String, String>.Class);
    
                                            if(conflictHandle != 'CLIENT_OVERRIDE')
                                            {
                                                for(String fldName : nameToValueMap.keySet() ){
                                                    if(fldName == 'Id' && nameToValueMap.get(fldName) != NULL)
                                                        RecSfids.add(nameToValueMap.get(fldName));
                                                   
                                                }
                                            }
                                        }
                                    }
                                    INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids and isDeleted = true All Rows');
                                    for(sobject eachRec : Database.query('SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids and isDeleted = true All Rows'))
                                        setDeletedIds.add(String.valueOf(eachRec.get('Id')));
                                        
                                    deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, JSON.serialize(setDeletedIds)));
                                    system.debug(LoggingLevel.WARN,'Deleted Records = ' + deletedRecIds);
                                    String stringQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids';
                                    system.debug(LoggingLevel.WARN,'10. Query  = ' + stringQuery + 'RecSfids = ' + RecSfids);      
                                    INTF_DataSync.logSOQL(intMethodCount,stringQuery);                          
                                    List<SObject> queryResult = Database.query(stringQuery);
                                    system.debug(LoggingLevel.WARN,'11. Data Queried  = ' + queryResult);
                                    DateTime newModifiedDate = System.now();
                                    system.debug(LoggingLevel.WARN,' dt_PutUpdate  = ' + dt_PutUpdate);
                                    if(dt_PutUpdate != null)
                                        newModifiedDate = dt_PutUpdate;
                                    else
                                        newModifiedDate = dateTime.now();
                                        
                                    Integer a = 0;

                                    for(INTF_WebServicesDef.SVMXMap selectedObj : secondLevelMap.valueMap){
                                        
                                        if(intBatchEnabled && isInternalLimitReached()){  //terminate and continue with the processing
                                            system.debug(LoggingLevel.DEBUG, 'Entered limit check - Yes Limit reached');
                                            isInternalBatch = true;
                                            break;
                                        }

                                        if(selectedObj.key == 'CLIENT_OVERRIDE' || selectedObj.key != 'BEFORE_SAVE'){    
                                            String conflictHandle =  selectedObj.key;
                                            String currentId ;
                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');

                                            Map<string, String> nameToValueMap = (Map<string, String>)JSON.deserialize(jstr, Map<String, String>.Class);

                                            for(String fldName : nameToValueMap.keySet() ){
                                                String fldValue = nameToValueMap.get(fldName);
                                                if(fldName == 'Id' && !setDeletedIds.contains(fldValue)){
                                                    RequestSFIDs.add(fldValue); 
                                                    currentId = fldValue;
                                                }
                                            }

                                            List<String> idToDelete = new List<String>();
                                            if(conflictHandle != 'CLIENT_OVERRIDE' && (strSyncConflict == 'Allow user to choose' || strSyncConflict =='ServiceMax online data') && queryResult != null && queryResult.size() > 0)
                                            {
                                                //get targeted Sync time for this record
                                                String recordSfId = String.ValueOf(queryResult[a].get('Id'));
                                                if(mapIdToRecordLST!= NULL && mapIdToRecordLST.containsKey(recordSfId) && mapIdToRecordLST.get(recordSfId)!= NULL){
                                                        LastSynchTime = mapIdToRecordLST.get(recordSfId);
                                                }
                                            
                                                INTF_WebServicesDef.SVMXMap conflict;
                                                DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                                                String sUserId = UserInfo.getUserId();
                                                if(dbLastModified > LastSynchTime)
                                                {
                                                    system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + newModifiedDate + ', Last Modified Date of Record = ' + dbLastModified);
                                                    if(((dbLastModified < newModifiedDate) || queryResult[a].get('LastModifiedById') != sUserId))
                                                    {
                                                        idToDelete.add((String)queryResult[a].get('Id'));
                                                        if(strSyncConflict != 'ServiceMax online data')
                                                        {
                                                            conflict = new INTF_WebServicesDef.SVMXMap();
                                                            conflict.key = firstLevelMap.value;
                                                            conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(LastSynchTime);
                                                            
                                                            List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                    
                                                            child.value = (String)queryResult[a].get('Id');
                                                            confChild.add(child);
                                                            conflict.valueMap = confChild;
                                                            ConflictList.add(conflict);
                                                        }
                                                        else
                                                        {
                                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                                            INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
                                                            record.value = (String)queryResult[a].get('Id');
                                                            listValueMaps.add(record);
                                                        }
                                                    }
                                                }
                                            }

                                            system.debug(LoggingLevel.WARN, 'currentId =' + currentId);
                                            sObject sObj;
                                            
                                            if(RequestSFIDs.size() > 0 && currentId!= null)
                                                sObj = objecttype.newSObject(currentId);  //create new instance 


                                            if(sObj != null && currentId != null)
                                            {
                                                for(String fldName : nameToValueMap.keySet() ){
                                                    String fldValue = nameToValueMap.get(fldName);
                                                    if(fieldUpdateable.get(fldName) == 'true'){
                                                        sObj = createSObject(sObj,fieldsType, fldName, fldValue);
                                                    }
                                                }
                                                a++;
                                                
                                                system.debug(LoggingLevel.WARN,'idToDelete = ' + idToDelete);

                                                if(!idToDelete.contains(String.valueof(sObj.get('Id')))){
                                                    sObjList.add(sObj);
                                                }    
                                            }
                                        }
                                    }

                                    system.debug(LoggingLevel.WARN, 'sObjList =' + sObjList);
                                    INTF_WebServicesDef.SVMXMap Error;
                                    try
                                    {
                                        system.debug(LoggingLevel.WARN,'12. Object List to update = ' + sObjList);
                                        parentsaveresult = Database.update(sObjList, false);
                                    }
                                    catch(DmlException e)
                                    {   
                                        Error = new INTF_WebServicesDef.SVMXMap(); 
                                        Error.key = firstLevelMap.value;
                                        Error.value = e.getMessage();
                                        
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                        
                                        child.key = '';
                                        errChild.add(child);
                                        ErrorList.add(Error);   
                                    }
                                    finally
                                    {
                                        List<String> sfids = new List<String>();
                                        if(parentsaveresult != null)
                                        {
                                            Integer i=0;
                                            for(Database.Saveresult parentSave : parentsaveresult)
                                            {
                                                INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
                                                sfids.add(parentSave.getId());
                                                String status;
                                                if(parentSave.isSuccess())
                                                {
                                                    status = 'Success';
                                                    record.value = parentSave.getId();
                                                    listValueMaps.add(record);
                                                    successfulIDMap.values.add(String.valueOf(parentSave.getId()));
                                                }
                                                else
                                                {
                                                    status = 'Fail';
                                                    Error = new INTF_WebServicesDef.SVMXMap();
                                                    Error.key = firstLevelMap.value;
                                                    Database.Error[] err = parentSave.getErrors();                                      
                                                    Error.value = err[0].getMessage();
                                                    
                                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                                    child.key = '';
                                                    child.value = String.valueOf(sObjList[i].Id);
                                                    errChild.add(child);
                                                    Error.valueMap = errChild;
                                                                    
                                                    ErrorList.add(Error);
                                                }
                                                i++;
                                            }
                                        }
                                    }
                                }
                            }
                            successUpdatedIds.valueMap.add(successfulIDMap); 
                            responseSVMXMap.key = firstLevelMap.key;
                            responseSVMXMap.value = firstLevelMap.value;
                            responseSVMXMap.values = null;
                            responseSVMXMap.valueMap = listValueMaps;   
                        }
                        responseValueMap.add(responseSVMXMap);
                    }
                    responseValueMap.add(deletedRecIds);
                    responseValueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_TIME_STAMP', String.valueOf(Datetime.now())));
                    conflictHeader.valueMap = ConflictList;
                    ErrorHeader.valueMap = ErrorList;
                    responseValueMap.add(conflictHeader);
                    responseValueMap.add(ErrorHeader);
                    responseValueMap.add(successUpdatedIds);  

                }
            }
        }
        
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = responseValueMap;
        system.debug(LoggingLevel.WARN, ' Response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount,'UpdateClientDataIntoBase');
        return response;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> updateRecordsFromClient(INTF_WebServicesDef.INTF_SFMRequest inputRequest, DateTime dtSyncStartTime, String strSyncConflict, Map<String, DateTime> mapIdToRecordLST)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('updateRecordsFromClient');
        Datetime dtLastSyncTime;
        Database.Saveresult[] parentsaveresult;
        List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXError> errors = new List<INTF_WebServicesDef.SVMXError>(); 
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR', '');
        List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap('CONFLICT', '');
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap successUpdatedIds = new INTF_WebServicesDef.SVMXMap('SUCCESS_RECIDS','');
        
        for(INTF_WebServicesDef.SVMXMap firstLevelMap : inputRequest.valueMap)
        {
            if(isInternalBatch){
                break;
            }
            system.debug(LoggingLevel.WARN, ' Each Value Map in Request: ' + firstLevelMap);
            INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
            List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
            
            
            if(firstLevelMap.key == 'SYNC_TIME_STAMP')
                dtLastSyncTime = Datetime.valueOf(firstLevelMap.value);
    
            if(firstLevelMap.key == 'object_name') 
            {
                List<sObject> sobjList = new List<sObject>();
                INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                clsObjectDefinition.objectName = firstLevelMap.value;
                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                MAP<String,String> mapFieldAndItsType = new Map<String,String>();
                MAP<String,Integer> mapFieldAndItsScale = new Map<String,Integer>();
                Set<String> setUpdatableFieldNames = new Set<String>();
                INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
                Schema.SObjectType objecttype = Schema.getGlobalDescribe().get(firstLevelMap.value);
                INTF_WebServicesDef.SVMXMap successfulIDMap = new INTF_WebServicesDef.SVMXMap(String.Valueof(firstLevelMap.value),'');

                if(objDef != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                    {
                        if (objProp.key=='FIELDPROPERTY')
                        {
                            for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                            {
                                for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                {
                                    if(fldObj.key == 'TYPE')
                                    {
                                        mapFieldAndItsType.put(lstField.value, fldObj.value);
                                    }
                                    if(fldObj.key == 'UPDATEABLE' && fldObj.value == 'true')
                                    {
                                        setUpdatableFieldNames.add(lstField.value);
                                    }
                                    if(fldObj.key == 'SCALE' && fldObj.value != null && Integer.valueOf(fldObj.value) != 0)
                                    {
                                        system.debug(LoggingLevel.WARN, 'Field = ' + lstField.value + '; Scale = ' + fldObj.value);
                                        mapFieldAndItsScale.put(lstField.value, Integer.valueOf(fldObj.value)); 
                                    }
                                }
                            }
                        }
                    }
                }
                
                for(INTF_WebServicesDef.SVMXMap secondLevelMap : firstLevelMap.valueMap)
                {
                    if(secondLevelMap.key == 'Fields')
                    {
                        system.debug(LoggingLevel.WARN, 'Inside Fields');
                        DateTime newModifiedDate;
                        Set<String> setSFIds = new Set<String>();
                        Set<String> setDeletedIds = new Set<String>();
                        Map<String, String> mapIdToRecordReqKey = new Map<String, String>();
                        Map<String, Map<String, String>> mapIdAndBeforeSaveRecord = new Map<String, Map<String, String>>();
                        Map<String, Map<String, String>> mapIdAndRecordToBeUpdated = new Map<String, Map<String, String>>();
                        
                        for(INTF_WebServicesDef.SVMXMap eachRecordToUpdate : secondLevelMap.valueMap)
                        {
                            system.debug(LoggingLevel.WARN, ' Each Record to Update in Request: ' + eachRecordToUpdate);
                            if(eachRecordToUpdate.key != 'BEFORE_SAVE')
                            {
                                Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(eachRecordToUpdate.value, Map<String, String>.Class);
                                system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                mapIdAndRecordToBeUpdated.put(mapFieldValue.get('Id'), mapFieldValue);
                                mapIdToRecordReqKey.put(mapFieldValue.get('Id'), eachRecordToUpdate.key);
                                system.debug(LoggingLevel.WARN, 'Id = ' + mapFieldValue.get('Id') + '; eachRecordToUpdate.key = ' + eachRecordToUpdate.key);
                            }
                            else if(eachRecordToUpdate.key == 'BEFORE_SAVE')
                            {
                                for(String strJsonBeforeSave : eachRecordToUpdate.values)
                                {
                                    Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(strJsonBeforeSave, Map<String, String>.Class);
                                    system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                    mapIdAndBeforeSaveRecord.put(mapFieldValue.get('Id'), mapFieldValue);
                                }   
                            }
                        }
                        
                        setSFIds.addAll(mapIdAndRecordToBeUpdated.keySet());
                        INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds and isDeleted = true All Rows');
                        for(sobject eachRec : Database.query('SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds and isDeleted = true All Rows'))
                        {
                            setDeletedIds.add(String.valueOf(eachRec.get('Id')));
                            mapIdAndRecordToBeUpdated.keySet().remove(String.valueOf(eachRec.get('Id')));
                        }
                        deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, JSON.serialize(setDeletedIds)));
                        setSFIds.removeAll(setDeletedIds);
                        system.debug(LoggingLevel.WARN,'List of Record Ids to be updated = ' + setSFIds + '; Deleted Records = ' + deletedRecIds);
                        
                        String strQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds';
                        INTF_DataSync.logSOQL(intMethodCount, strQuery);
                        List<SObject> queryResult = Database.query(strQuery);
                        system.debug(LoggingLevel.WARN,'Query  = ' + strQuery + '; setSFIds = ' + setSFIds + '; Query Results = ' + queryResult);
                        system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dtSyncStartTime + ', Current Time = ' + DateTime.now());
                        
                        if(dtSyncStartTime != null)
                            newModifiedDate = dtSyncStartTime;
                        else
                            newModifiedDate = DateTime.now();


                        Integer a = 0;
                        for(String strRecordId : setSFIds)
                        {
                            if(intBatchEnabled && isInternalLimitReached()){  //terminate and continue with the processing
                                system.debug(LoggingLevel.DEBUG, 'Entered limit check - Yes Limit reached');
                                isInternalBatch = true;
                                break;
                            } 

                            String strClientOvrde = '';
                            Boolean strConflict = false;
                            //Post API upgrade Schema.getGlobalDescribe().get() is expecting Objectname+Namespace
                            //sObject sObj = Schema.getGlobalDescribe().get(clsObjectDefinition.objectName).newSObject(strRecordId);

                            sObject sObj = objecttype.newSObject(strRecordId);  //create new instance 
                            system.debug(LoggingLevel.WARN, 'strRecordId =' + strRecordId + '; sObject = ' + sObj);
                            String sUserId = UserInfo.getUserId();
                            
                            if(queryResult != NULL && queryResult.size() > 0 && queryResult[a] != NULL){
                                        
                                DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                                
                                //get targeted Sync time for this record
                                if(mapIdToRecordLST!= NULL && mapIdToRecordLST.containsKey(strRecordId) && mapIdToRecordLST.get(strRecordId)!= NULL){
                                        dtLastSyncTime = mapIdToRecordLST.get(strRecordId);
                                }
                                
                                system.debug(LoggingLevel.WARN,'LMD of Record = ' + dbLastModified + ', Last Sync = ' + dtLastSyncTime + ', New Modified Date = ' + newModifiedDate);
                                if(mapIdToRecordReqKey != null)
                                    strClientOvrde = mapIdToRecordReqKey.get(strRecordId);
                                system.debug(LoggingLevel.WARN,'strClientOvrde = ' + strClientOvrde);
                                
                                if(strClientOvrde != 'CLIENT_OVERRIDE' && (dbLastModified > dtLastSyncTime) && ( dbLastModified < newModifiedDate || queryResult[a].get('LastModifiedById') != sUserId  ) && queryResult != null && queryResult.size() > 0)
                                {
                                    INTF_WebServicesDef.SVMXMap conflict;                               
                                    if(mapIdAndRecordToBeUpdated.containsKey(strRecordId) && mapIdAndBeforeSaveRecord.containsKey(strRecordId))
                                    {
                                        List<String> updatableFieldNames = (new COMM_Utils_V2()).checkDuplicateFields(new List<String>(setUpdatableFieldNames), firstLevelMap.value);
                                        String strFieldNamesToQry =  clsObjectDefinition.getObjectFieldNames(updatableFieldNames);
                                        INTF_DataSync.logSOQL(intMethodCount, 'Select ' + strFieldNamesToQry + ' from ' + firstLevelMap.value + ' where Id = \'' +  strRecordId + '\'');
                                        sObject eachRecord = Database.query('Select ' + strFieldNamesToQry + ' from ' + firstLevelMap.value + ' where Id = \'' +  strRecordId + '\'');
                                        
                                        for(String eachField : mapIdAndBeforeSaveRecord.get(strRecordId).keySet())
                                        {
                                            if(setUpdatableFieldNames.contains(eachField))
                                            {
                                                String strFldValFrmClient = mapIdAndBeforeSaveRecord.get(strRecordId).get(eachField);
                                                String strFldValAtSrvr = String.valueOf(eachRecord.get(eachField));
                                                system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Type = ' + mapFieldAndItsType.get(eachField) + '; Field Value at Client Before Save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                                
                                                strFldValFrmClient = (new SFMTransactionSync()).formatFieldValue(eachField, strFldValFrmClient,mapFieldAndItsType, mapFieldAndItsScale );
                                                
                                                if(strFldValAtSrvr == null)
                                                    strFldValAtSrvr = '';
                                                    
                                                system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Field Value at Client before save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                                String strFieldValueToSave = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);

                                                strFieldValueToSave = (new SFMTransactionSync()).formatFieldValue(eachField, strFieldValueToSave,mapFieldAndItsType, mapFieldAndItsScale );
                                                
                                                system.debug(LoggingLevel.WARN, 'Field value to be updated from client = ' + strFieldValueToSave + 'Field value at server = ' + strFldValAtSrvr);
                                                
                                                if(!strFldValFrmClient.equals(strFldValAtSrvr) && strFieldValueToSave != strFldValAtSrvr)
                                                {
                                                    system.debug(LoggingLevel.WARN,'Conflict in field = ' + eachField + ' and Sync Conflict = ' + strSyncConflict);
                                                    if(strSyncConflict == 'Allow user to choose')
                                                    {
                                                        system.debug(LoggingLevel.WARN,'Conflict when Allow user to choose');
                                                        conflict = new INTF_WebServicesDef.SVMXMap();
                                                        conflict.key = firstLevelMap.value;
                                                        conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                                
                                                        List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                        confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                        conflict.valueMap = confChild;
                                                        ConflictList.add(conflict);
                                                        strConflict = true;
                                                        break;  
                                                    }
                                                    else if(strSyncConflict == 'ServiceMax online data')
                                                    {
                                                        if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                        {
                                                            sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFldValAtSrvr);
                                                        }
                                                    }
                                                    else if(strSyncConflict == 'Mobile device data')
                                                    {
                                                        if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                        {
                                                            String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                            sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFieldValue);
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                    {
                                                        String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                        sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFieldValue);
                                                    }
                                                }
                                            }
                                        }
                                        if(!strConflict)
                                            sObjList.add(sobj);
                                        system.debug(LoggingLevel.WARN,'sObj to UPDATE = ' + sObj);
                                    }
                                    else
                                    {
                                        if(strSyncConflict != 'ServiceMax online data')
                                        {
                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax NOT online data');
                                            conflict = new INTF_WebServicesDef.SVMXMap();
                                            conflict.key = firstLevelMap.value;
                                            conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                        
                                            List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                            conflict.valueMap = confChild;
                                            ConflictList.add(conflict);
                                        }
                                        else
                                        {
                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                            listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                        }
                                    }
                                }
                                else
                                {
                                    sObjList.add(createsObjectToUpdate(strRecordId, sObj, setUpdatableFieldNames, mapIdAndRecordToBeUpdated, mapFieldAndItsType));  
                                }
                            }
                            a++;
                        }
                        system.debug(LoggingLevel.WARN, 'sObjList =' + sObjList);
                        INTF_WebServicesDef.SVMXMap Error;
                        try
                        {
                            parentsaveresult = Database.update(sObjList,false);
                        }
                        catch(DmlException e)
                        {
                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                            errChild.add(new INTF_WebServicesDef.SVMXMap('', ''));
                            ErrorList.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, e.getMessage()));   
                        }
                        finally
                        {
                            List<String> sfids = new List<String>();
                            if(parentsaveresult != null)
                            {
                                Integer i=0;
                                for(Database.Saveresult parentSave : parentsaveresult)
                                {
                                    sfids.add(parentSave.getId());
                                    if(parentSave.isSuccess())
                                    {
                                        listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', parentSave.getId()));
                                        system.debug(LoggingLevel.WARN, 'Update is Successfull');
                                        successfulIDMap.values.add(String.valueOf(parentSave.getId()));
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.WARN, 'Problem in Update');   
                                        Error = new INTF_WebServicesDef.SVMXMap();
                                        Error.key = firstLevelMap.value;
                                        Database.Error[] err = parentSave.getErrors();                                      
                                        Error.value = err[0].getMessage();
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        errChild.add(new INTF_WebServicesDef.SVMXMap('', String.valueOf(sObjList[i].Id)));
                                        Error.valueMap = errChild;
                                        ErrorList.add(Error);
                                    }
                                    i++;
                                }
                            }
                        }
                    }
                }
                responseValueMap.add(deletedRecIds);  
                successUpdatedIds.valueMap.add(successfulIDMap);   
            }
            responseSVMXMap.key = firstLevelMap.key;
            responseSVMXMap.value = firstLevelMap.value;
            responseSVMXMap.values = null;
            responseSVMXMap.valueMap = listValueMaps;
            responseValueMap.add(responseSVMXMap);
        }
        conflictHeader.valueMap = ConflictList;
        ErrorHeader.valueMap = ErrorList;
        responseValueMap.add(conflictHeader);
        responseValueMap.add(ErrorHeader);
        responseValueMap.add(successUpdatedIds);  

        INTF_DataSync.logMethodEndTS(intMethodCount,'updateRecordsFromClient');
        return responseValueMap;
    }
    
    /*public INTF_WebServicesDef.INTF_SFMResponse UpdateClientDataIntoBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest,string strDeviceType, Map<String, DateTime> mapIdToRecordLST)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('UpdateClientDataIntoBase');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Database.Saveresult[] parentsaveresult;
        List<INTF_WebServicesDef.SVMXError> errors = new List<INTF_WebServicesDef.SVMXError>(); 
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        ErrorHeader.key = 'ERROR'; 
        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap();
        conflictHeader.key = 'CONFLICT';
        try
        {
            Boolean isFieldLevelSyncConflict = false;
            String strSyncConflict = '', strClientType = '';
            list<String> lstSettingId = new list<String>{'SET016'};
            map<String, String> mapSettingsForIPAD018 = new map<String, String>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            
            Id grpProfileId = (Id)INTF_TxnCache.get('GROUP_PROFILE_ID', 'Id');
            if(grpProfileId == null)
            {
                grpProfileId = (new Sync_Utility()).getGroupProfileId(null, true);
                INTF_TxnCache.put('GROUP_PROFILE_ID', grpProfileId, 'Id');
            }
            
            mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            if(mapSettingsForIPAD018.containskey('SET016') && mapSettingsForIPAD018.get('SET016') != null && mapSettingsForIPAD018.get('SET016').length() > 0)
                isFieldLevelSyncConflict = Boolean.valueOf(mapSettingsForIPAD018.get('SET016'));
            
            strSyncConflict = (String)INTF_TxnCache.get('CONFLICT_STRING', 'String');
            if(strSyncConflict == null)
            {
                system.debug(LoggingLevel.WARN,' Device from Request UpdateClientDataIntoBase = '+strDeviceType);      
                String strMobConfQuery  = 'select SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'Conflict Resolution\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';      
                
                String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);       
                if(strDevConfId != NULL && strDevConfId != ''){     
                    strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
                }       
                strMobConfQuery += ' LIMIT 1';      
                system.debug(LoggingLevel.WARN,'Query formed for UpdateClientDataIntoBase = '+strMobConfQuery);     
                
                INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);      
                //for(SVMXC__ServiceMax_Config_Data__c confgData : [select SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND SVMXC__Display_Type__c = 'Conflict Resolution' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId limit 1])     
                for(SVMXC__ServiceMax_Config_Data__c confgData : Database.Query(strMobConfQuery))           
                    strSyncConflict = confgData.SVMXC__Internal_Value__c;                                    
                INTF_TxnCache.put('CONFLICT_STRING', strSyncConflict, 'String');
            }
            
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strClientType = clientInform.clientType;
                        break;
                    }
                }
            }
        
            system.debug(loggingLevel.WARN, 'Conflict Resolution Config String: ' + strSyncConflict + '; ; Field Level Sync Conflict =' + isFieldLevelSyncConflict + '; Client Type = ' + strClientType);
            
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_UPDATE')
            {
                if(isFieldLevelSyncConflict)
                    responseValueMap = updateRecordsFromClient(inputRequest, dt_PutUpdate, strSyncConflict, mapIdToRecordLST);
                else
                {
                    List<INTF_WebServicesDef.SVMXMap> inputList = inputRequest.valueMap;
                    List<INTF_WebServicesDef.SVMXMap> fieldsMapList;
                    Iterator<INTF_WebServicesDef.SVMXMap> inputListIterator = inputList.iterator();
                    List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
                    List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                    INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
                    Datetime LastSynchTime ;
                    INTF_WebServicesDef.SVMXMap firstLevelMap;
                    
                    while(inputListIterator.hasNext())
                    {
                        firstLevelMap = inputListIterator.next();
                        system.debug(LoggingLevel.WARN, 'Each Value Map in Request: ' + firstLevelMap);
                        INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap(); 
                        List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
                        
                        if(firstLevelMap.key == 'SYNC_TIME_STAMP')
                            LastSynchTime = Datetime.valueOf(firstLevelMap.value);
                        
                        system.debug(loggingLevel.WARN, 'SYNC_TIME_STAMP = ' + LastSynchTime + ', Sync Start Time = ' + dt_PutUpdate);
                            
                        if(firstLevelMap.key == 'object_name') 
                        {
                            fieldsMapList = firstLevelMap.valueMap;
                            List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                            Iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                            INTF_WebServicesDef.SVMXMap secondLevelMap;
                            
                            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                            clsObjectDefinition.objectName = firstLevelMap.value;
                            
                            INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                            MAP<String,String> fieldsType = new Map<String,String>();
                            Map<String, String> fieldUpdateable = new Map<String, String>();
                            
                            if (objDef != NULL)
                            {
                                for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                                {
                                    if (objProp.key=='FIELDPROPERTY')
                                    {
                                        for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                        {
                                            for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                            {
                                                if(fldObj.key == 'TYPE')
                                                    fieldsType.put(lstField.value, fldObj.value);
                                                if(fldObj.key == 'UPDATEABLE')
                                                    fieldUpdateable.put(lstField.value,fldObj.value);
                                            }
                                        }
                                    }
                                }
                            }
                            
                            system.debug(loggingLevel.WARN, 'Map of Field Type: ' + fieldsType);
                            system.debug(loggingLevel.WARN, 'Map of field updateable: ' + fieldUpdateable);
                            
                            List<sObject> sobjList = new List<sObject>(); 
                            while(fieldsMapIterator.hasNext())
                            {
                                MAP<String,Sobject> idSobjectMap = new MAP<String,Sobject>();
                                Set<String> setDeletedIds = new Set<String>();
                                secondLevelMap = fieldsMapIterator.next();
                                if(secondLevelMap.key == 'Fields')
                                {
                                    system.debug(LoggingLevel.WARN, 'Inside Fields');
                                    fieldValues = secondLevelMap.valueMap;
                                    Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                    List<String> RequestSFIDs = new List<String>();
                                    List<String> RecSfids = new List<String>();
                                    Iterator<INTF_WebServicesDef.SVMXMap> it1 = fieldValues.iterator();
                                    while(it1.hasNext())
                                    {
                                        INTF_WebServicesDef.SVMXMap selectedObj = it1.next();
                                        system.debug(LoggingLevel.WARN, 'selectedObj = ' + selectedObj);
                                        if(selectedObj.key != 'BEFORE_SAVE')
                                        {
                                            String conflictHandle =  selectedObj.key;
                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');
                                            JSONParser newjsp = JSON.createParser(jstr);
                                            if(conflictHandle != 'CLIENT_OVERRIDE')
                                            {
                                                while(newjsp.nextToken()!=null)
                                                {
                                                    if (newjsp.getCurrentToken() == JSONToken.FIELD_NAME ) 
                                                    {  
                                                        String fldName = newjsp.getText();
                                                        if(fldName=='type' || fldName=='url')
                                                        {
                                                            newjsp.nextToken();
                                                            continue;
                                                        }
                                                        
                                                        if(newjsp.nextToken()==JSONToken.VALUE_STRING)
                                                        {
                                                            String fldValue = newjsp.getText();
                                                            if(fldName == 'Id')
                                                                RecSfids.add(fldValue);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids and isDeleted = true All Rows');
                                    for(sobject eachRec : Database.query('SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids and isDeleted = true All Rows'))
                                        setDeletedIds.add(String.valueOf(eachRec.get('Id')));
                                        
                                    deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, JSON.serialize(setDeletedIds)));
                                    system.debug(LoggingLevel.WARN,'Deleted Records = ' + deletedRecIds);
                                    String stringQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids';
                                    system.debug(LoggingLevel.WARN,'10. Query  = ' + stringQuery + 'RecSfids = ' + RecSfids);                                
                                    INTF_DataSync.logSOQL(intMethodCount,stringQuery);
                                    List<SObject> queryResult = Database.query(stringQuery);
                                    system.debug(LoggingLevel.WARN,'11. Data Queried  = ' + queryResult);
                                    DateTime newModifiedDate = System.now();
                                    if(dt_PutUpdate != null)
                                        newModifiedDate = dt_PutUpdate;
                                    else
                                        newModifiedDate = dateTime.now();
                                        
                                    Integer a = 0;
                                    while(it.hasNext())
                                    {
                                        INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                        if(selectedObj.key == 'CLIENT_OVERRIDE' || selectedObj.key != 'BEFORE_SAVE')
                                        {    
                                            String conflictHandle =  selectedObj.key;
                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');
                                            JSONParser jsp = JSON.createParser(jstr);
                                            JSONParser newjsp = JSON.createParser(jstr);
                                            String currentId ;
                                            while(newjsp.nextToken()!=null)
                                            {
                                                if (newjsp.getCurrentToken() == JSONToken.FIELD_NAME ) 
                                                {  
                                                    String fldName = newjsp.getText();
                                                    if(newjsp.nextToken()==JSONToken.VALUE_STRING)
                                                    {
                                                        String fldValue = newjsp.getText();
                                                        if(fldName == 'Id' && !setDeletedIds.contains(fldValue))
                                                        {
                                                            RequestSFIDs.add(fldValue); 
                                                            currentId = fldValue;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            List<String> idToDelete = new List<String>();
                                            if(conflictHandle != 'CLIENT_OVERRIDE' && (strSyncConflict == 'Allow user to choose' || strSyncConflict =='ServiceMax online data') && queryResult != null && queryResult.size() > 0 && queryResult[a] != NULL)
                                            {
                                                    //get targeted Sync time for this record
                                                String recordSfId = String.ValueOf(queryResult[a].get('Id'));
                                                if(mapIdToRecordLST!= NULL && mapIdToRecordLST.containsKey(recordSfId) && mapIdToRecordLST.get(recordSfId)!= NULL){
                                                        LastSynchTime = mapIdToRecordLST.get(recordSfId);
                                                }
                                            
                                                INTF_WebServicesDef.SVMXMap conflict;
                                                DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                                                String sUserId = UserInfo.getUserId();
                                                if(dbLastModified > LastSynchTime)
                                                {
                                                    system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + newModifiedDate + ', Last Modified Date of Record = ' + dbLastModified);
                                                    if(((dbLastModified < newModifiedDate) || queryResult[a].get('LastModifiedById') != sUserId))
                                                    {
                                                        idToDelete.add((String)queryResult[a].get('Id'));
                                                        if(strSyncConflict != 'ServiceMax online data')
                                                        {
                                                            conflict = new INTF_WebServicesDef.SVMXMap();
                                                            conflict.key = firstLevelMap.value;
                                                            conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(LastSynchTime);
                                                            
                                                            List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                    
                                                            child.value = (String)queryResult[a].get('Id');
                                                            confChild.add(child);
                                                            conflict.valueMap = confChild;
                                                            ConflictList.add(conflict);
                                                        }
                                                        else
                                                        {
                                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                                            INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
                                                            record.value = (String)queryResult[a].get('Id');
                                                            listValueMaps.add(record);
                                                        }
                                                    }
                                                }
                                            }
                                            system.debug(LoggingLevel.WARN, 'currentId =' + currentId);
                                            sObject sObj;
                                            
                                            if(RequestSFIDs.size() > 0 && currentId!= null)
                                                    sObj = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject(currentId);
                                            
                                            if(sObj != null && currentId != null)
                                            {
                                                while(jsp.nextToken()!=null && currentId != null)
                                                {
                                                    if(jsp.getCurrentToken() == JSONToken.FIELD_NAME ) 
                                                    {  
                                                        String fldName = jsp.getText();
                                                        if(jsp.nextToken()==JSONToken.VALUE_STRING)
                                                        {
                                                            String fldValue = jsp.getText();
                                                            if(fieldUpdateable.get(fldName) == 'true')
                                                            {
                                                                if(fldValue == null || fldValue == '')
                                                                {
                                                                    sObj.put(fldName, null);
                                                                }
                                                                else
                                                                {
                                                                    if(fldValue != null && fldValue != '')
                                                                    {
                                                                        if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                                        {
                                                                            fldValue = fldValue.replace('&amp;', '&');
                                                                            fldValue = fldValue.replace('&apos;', '\'');
                                                                            fldValue = fldValue.replace('&lt;', '<');
                                                                            fldValue = fldValue.replace('&gt;', '>');
                                                                            fldValue = fldValue.replace('&quot;', '"');
                                                                        }
                                                                    }
                                                                    if(fieldsType.get(fldName)=='DATETIME' && fldValue != '')
                                                                    {
                                                                        fldValue = fldValue.replace('T', ' ');
                                                                        fldValue = fldValue.replace('Z', ' ');
                                                                        sObj.put(fldName, Datetime.valueOfGmt(fldValue));
                                                                    }
                                                                    else if(fieldsType.get(fldName)=='DATE' && fldValue != '')
                                                                    {
                                                                        sObj.put(fldName, Date.valueOf(fldValue));
                                                                    }
                                                                    else if(fieldsType.get(fldName)=='BOOLEAN')
                                                                    {
                                                                        sObj.put(fldName, Boolean.valueOf(fldValue));
                                                                    }
                                                                    else if(fieldsType.get(fldName)=='DOUBLE')
                                                                    {
                                                                        sObj.put(fldName, decimal.valueOf(fldValue));
                                                                    }
                                                                    else if(fieldsType.get(fldName)=='DECIMAL' || fieldsType.get(fldName)== 'CURRENCY' || fieldsType.get(fldName)== 'PERCENT')
                                                                    {
                                                                        sObj.put(fldName, decimal.valueOf(fldValue));
                                                                    }
                                                                    else if(fieldsType.get(fldName)=='INTEGER')
                                                                    {
                                                                        sObj.put(fldName, Integer.valueOf(fldValue));
                                                                    }
                                                                    else
                                                                    {
                                                                        sObj.put(fldName, fldValue);
                                                                    }
                                                                }      
                                                            }
                                                            if(fldName == 'Id')
                                                            {
                                                                idSobjectMap.put(fldValue,sObj);
                                                            }
                                                        }                                       
                                                    }
                                                }
                                                a++;
                                                Boolean updateIt = true;
                                                system.debug(LoggingLevel.WARN,'idToDelete = ' + idToDelete);
                                                if(!idToDelete.isEmpty()) 
                                                {
                                                    for(String id : idToDelete)
                                                    {
                                                        if(sObj.get('Id') == id)
                                                            updateIt = false;
                                                    }
                                                }
                                                if(updateIt && RequestSFIDs != null)
                                                    sObjList.add(sObj);
                                            }
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN, 'sObjList =' + sObjList);
                                    INTF_WebServicesDef.SVMXMap Error;
                                    try
                                    {
                                        system.debug(LoggingLevel.WARN,'12. Object List to update = ' + sObjList);
                                        parentsaveresult = Database.update(sObjList, false);
                                    }
                                    catch(DmlException e)
                                    {   
                                        Error = new INTF_WebServicesDef.SVMXMap(); 
                                        Error.key = firstLevelMap.value;
                                        Error.value = e.getMessage();
                                        
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                        
                                        child.key = '';
                                        errChild.add(child);
                                        ErrorList.add(Error);   
                                    }
                                    finally
                                    {
                                        List<String> sfids = new List<String>();
                                        if(parentsaveresult != null)
                                        {
                                            Integer i=0;
                                            for(Database.Saveresult parentSave : parentsaveresult)
                                            {
                                                INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
                                                sfids.add(parentSave.getId());
                                                String status;
                                                if(parentSave.isSuccess())
                                                {
                                                    status = 'Success';
                                                    record.value = parentSave.getId();
                                                    listValueMaps.add(record);
                                                }
                                                else
                                                {
                                                    status = 'Fail';
                                                    Error = new INTF_WebServicesDef.SVMXMap();
                                                    Error.key = firstLevelMap.value;
                                                    Database.Error[] err = parentSave.getErrors();                                      
                                                    Error.value = err[0].getMessage();
                                                    
                                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                                    child.key = '';
                                                    child.value = String.valueOf(sObjList[i].Id);
                                                    errChild.add(child);
                                                    Error.valueMap = errChild;
                                                                    
                                                    ErrorList.add(Error);
                                                }
                                                i++;
                                            }
                                        }
                                    }
                                }
                            }
                            responseSVMXMap.key = firstLevelMap.key;
                            responseSVMXMap.value = firstLevelMap.value;
                            responseSVMXMap.values = null;
                            responseSVMXMap.valueMap = listValueMaps;   
                        }
                        responseValueMap.add(responseSVMXMap);
                    }
                    responseValueMap.add(deletedRecIds);
                    responseValueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_TIME_STAMP', String.valueOf(Datetime.now())));
                    conflictHeader.valueMap = ConflictList;
                    ErrorHeader.valueMap = ErrorList;
                    responseValueMap.add(conflictHeader);
                    responseValueMap.add(ErrorHeader);
                }
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = responseValueMap;
        system.debug(LoggingLevel.WARN, ' Response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount,'UpdateClientDataIntoBase');
        return response;
    }*/
    
    /*public List<INTF_WebServicesDef.SVMXMap> updateRecordsFromClient(INTF_WebServicesDef.INTF_SFMRequest inputRequest, DateTime dtSyncStartTime, String strSyncConflict, Map<String, DateTime> mapIdToRecordLST)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('updateRecordsFromClient');
        Datetime dtLastSyncTime;
        Database.Saveresult[] parentsaveresult;
        List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXError> errors = new List<INTF_WebServicesDef.SVMXError>(); 
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR', '');
        List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap('CONFLICT', '');
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        for(INTF_WebServicesDef.SVMXMap firstLevelMap : inputRequest.valueMap)
        {
            system.debug(LoggingLevel.WARN, ' Each Value Map in Request: ' + firstLevelMap);
            INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
            List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
            
            if(firstLevelMap.key == 'SYNC_TIME_STAMP')
                dtLastSyncTime = Datetime.valueOf(firstLevelMap.value);
    
            if(firstLevelMap.key == 'object_name') 
            {
                List<sObject> sobjList = new List<sObject>();
                INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                clsObjectDefinition.objectName = firstLevelMap.value;
                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                MAP<String,String> mapFieldAndItsType = new Map<String,String>();
                MAP<String,Integer> mapFieldAndItsScale = new Map<String,Integer>();
                Set<String> setUpdatableFieldNames = new Set<String>();
                INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
                
                if(objDef != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                    {
                        if (objProp.key=='FIELDPROPERTY')
                        {
                            for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                            {
                                for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                {
                                    if(fldObj.key == 'TYPE')
                                    {
                                        mapFieldAndItsType.put(lstField.value, fldObj.value);
                                    }
                                    if(fldObj.key == 'UPDATEABLE' && fldObj.value == 'true')
                                    {
                                        setUpdatableFieldNames.add(lstField.value);
                                    }
                                    if(fldObj.key == 'SCALE' && fldObj.value != null && Integer.valueOf(fldObj.value) != 0)
                                    {
                                        system.debug(LoggingLevel.WARN, 'Field = ' + lstField.value + '; Scale = ' + fldObj.value);
                                        mapFieldAndItsScale.put(lstField.value, Integer.valueOf(fldObj.value)); 
                                    }
                                }
                            }
                        }
                    }
                }
                
                for(INTF_WebServicesDef.SVMXMap secondLevelMap : firstLevelMap.valueMap)
                {
                    if(secondLevelMap.key == 'Fields')
                    {
                        system.debug(LoggingLevel.WARN, 'Inside Fields');
                        DateTime newModifiedDate;
                        Set<String> setSFIds = new Set<String>();
                        Set<String> setDeletedIds = new Set<String>();
                        Map<String, String> mapIdToRecordReqKey = new Map<String, String>();
                        Map<String, Map<String, String>> mapIdAndBeforeSaveRecord = new Map<String, Map<String, String>>();
                        Map<String, Map<String, String>> mapIdAndRecordToBeUpdated = new Map<String, Map<String, String>>();
                        
                        for(INTF_WebServicesDef.SVMXMap eachRecordToUpdate : secondLevelMap.valueMap)
                        {
                            system.debug(LoggingLevel.WARN, ' Each Record to Update in Request: ' + eachRecordToUpdate);
                            if(eachRecordToUpdate.key != 'BEFORE_SAVE')
                            {
                                Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(eachRecordToUpdate.value, Map<String, String>.Class);
                                system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                mapIdAndRecordToBeUpdated.put(mapFieldValue.get('Id'), mapFieldValue);
                                mapIdToRecordReqKey.put(mapFieldValue.get('Id'), eachRecordToUpdate.key);
                                system.debug(LoggingLevel.WARN, 'Id = ' + mapFieldValue.get('Id') + '; eachRecordToUpdate.key = ' + eachRecordToUpdate.key);
                            }
                            else if(eachRecordToUpdate.key == 'BEFORE_SAVE')
                            {
                                for(String strJsonBeforeSave : eachRecordToUpdate.values)
                                {
                                    Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(strJsonBeforeSave, Map<String, String>.Class);
                                    system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                    mapIdAndBeforeSaveRecord.put(mapFieldValue.get('Id'), mapFieldValue);
                                }   
                            }
                        }
                        
                        setSFIds.addAll(mapIdAndRecordToBeUpdated.keySet());
                        INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds and isDeleted = true All Rows');
                        for(sobject eachRec : Database.query('SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds and isDeleted = true All Rows'))
                        {
                            setDeletedIds.add(String.valueOf(eachRec.get('Id')));
                            mapIdAndRecordToBeUpdated.keySet().remove(String.valueOf(eachRec.get('Id')));
                        }
                        deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, JSON.serialize(setDeletedIds)));
                        setSFIds.removeAll(setDeletedIds);
                        system.debug(LoggingLevel.WARN,'List of Record Ids to be updated = ' + setSFIds + '; Deleted Records = ' + deletedRecIds);
                        
                        String strQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds';
                        INTF_DataSync.logSOQL(intMethodCount, strQuery);
                        List<SObject> queryResult = Database.query(strQuery);
                        system.debug(LoggingLevel.WARN,'Query  = ' + strQuery + '; setSFIds = ' + setSFIds + '; Query Results = ' + queryResult);
                        system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dtSyncStartTime + ', Current Time = ' + DateTime.now());
                        
                        if(dtSyncStartTime != null)
                            newModifiedDate = dtSyncStartTime;
                        else
                            newModifiedDate = DateTime.now();
    
                        Integer a = 0;
                        for(String strRecordId : setSFIds)
                        {
                            String strClientOvrde = '';
                            Boolean strConflict = false;
                            sObject sObj = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject(strRecordId);
                            system.debug(LoggingLevel.WARN, 'strRecordId =' + strRecordId + '; sObject = ' + sObj);
                            String sUserId = UserInfo.getUserId();

                            if(queryResult != NULL && queryResult.size() > 0 && queryResult[a] != NULL){
                                DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                                //get targeted Sync time for this record
                                if(mapIdToRecordLST!= NULL && mapIdToRecordLST.containsKey(strRecordId) && mapIdToRecordLST.get(strRecordId)!= NULL){
                                        dtLastSyncTime = mapIdToRecordLST.get(strRecordId);
                                }
                                system.debug(LoggingLevel.WARN,'LMD of Record = ' + dbLastModified + ', Last Sync = ' + dtLastSyncTime + ', New Modified Date = ' + newModifiedDate);
                                if(mapIdToRecordReqKey != null)
                                    strClientOvrde = mapIdToRecordReqKey.get(strRecordId);
                                system.debug(LoggingLevel.WARN,'strClientOvrde = ' + strClientOvrde);
                                
                                if(strClientOvrde != 'CLIENT_OVERRIDE' && (dbLastModified > dtLastSyncTime) && ( (dbLastModified < newModifiedDate) || queryResult[a].get('LastModifiedById') != sUserId ) && queryResult != null && queryResult.size() > 0)
                                {
                                    INTF_WebServicesDef.SVMXMap conflict;                               
                                    if(mapIdAndRecordToBeUpdated.containsKey(strRecordId) && mapIdAndBeforeSaveRecord.containsKey(strRecordId))
                                    {
                                        String strFieldNamesToQry =  clsObjectDefinition.getObjectFieldNames(new List<String>(setUpdatableFieldNames));
                                        INTF_DataSync.logSOQL(intMethodCount, 'Select ' + strFieldNamesToQry + ' from ' + firstLevelMap.value + ' where Id = \'' +  strRecordId + '\'');
                                        sObject eachRecord = Database.query('Select ' + strFieldNamesToQry + ' from ' + firstLevelMap.value + ' where Id = \'' +  strRecordId + '\'');
                                        
                                        for(String eachField : mapIdAndBeforeSaveRecord.get(strRecordId).keySet())
                                        {
                                            if(setUpdatableFieldNames.contains(eachField))
                                            {
                                                String strFldValFrmClient = mapIdAndBeforeSaveRecord.get(strRecordId).get(eachField);
                                                String strFldValAtSrvr = String.valueOf(eachRecord.get(eachField));
                                                system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Type = ' + mapFieldAndItsType.get(eachField) + '; Field Value at Client Before Save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                                if(mapFieldAndItsType.get(eachField) == 'DATETIME' && strFldValFrmClient != '')
                                                {
                                                    strFldValFrmClient = strFldValFrmClient.replace('T', ' ');
                                                    strFldValFrmClient = strFldValFrmClient.replace('Z', ' ');
                                                    strFldValFrmClient = String.valueOfGmt(DateTime.valueOfGmt(strFldValFrmClient));    
                                                }
                                                if(mapFieldAndItsType.get(eachField) == 'DATE' && strFldValFrmClient != '')
                                                {
                                                    strFldValFrmClient = String.valueOfGmt(Date.valueOf(strFldValFrmClient));
                                                }
                                                if(mapFieldAndItsType.get(eachField) == 'TIME' )
                                                {
                                                    continue;
                                                }
                                                if((mapFieldAndItsType.get(eachField) == 'DOUBLE' || mapFieldAndItsType.get(eachField) == 'DECIMAL' || mapFieldAndItsType.get(eachField) == 'CURRENCY' || mapFieldAndItsType.get(eachField) == 'PERCENT') && strFldValFrmClient != '')
                                                {
                                                    String strTempFldVal = strFldValFrmClient;
                                                    strTempFldVal = strTempFldVal.replace('.',':');
                                                    List<String> lstDecimal = strTempFldVal.split(':');
                                                    if(lstDecimal != null && lstDecimal.size() >= 2)
                                                    {
                                                        if(mapFieldAndItsScale.get(eachField) != null)
                                                        {
                                                            for(Integer i = 0; i< mapFieldAndItsScale.get(eachField) - lstDecimal[1].length(); i++)
                                                                strFldValFrmClient += '0';
                                                        }
                                                        else
                                                        {
                                                            strFldValFrmClient = lstDecimal[0];
                                                        }
                                                    }
                                                }
                                                
                                                if(strFldValAtSrvr == null)
                                                    strFldValAtSrvr = '';
                                                    
                                                system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Field Value at Client before save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                                String strFieldValueToSave = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                if(mapFieldAndItsType.get(eachField) == 'DATETIME' && strFieldValueToSave != null && strFieldValueToSave != '')
                                                {
                                                    strFieldValueToSave = strFieldValueToSave.replace('T', ' ');
                                                    strFieldValueToSave = strFieldValueToSave.replace('Z', ' ');
                                                    strFieldValueToSave = String.valueOfGmt(DateTime.valueOfGmt(strFieldValueToSave));  
                                                }
                                                if(mapFieldAndItsType.get(eachField) == 'DATE' && strFieldValueToSave != null && strFieldValueToSave != '')
                                                {
                                                    system.debug(LoggingLevel.WARN, 'strFieldValueToSave = ' + strFieldValueToSave);
                                                    strFieldValueToSave = strFieldValueToSave.replace('T', ' ');
                                                    strFieldValueToSave = strFieldValueToSave.replace('Z', ' ');
                                                    strFieldValueToSave = String.valueOfGmt(Date.valueOf(strFieldValueToSave));
                                                    system.debug(LoggingLevel.WARN, 'strFieldValueToSave = ' + strFieldValueToSave);  
                                                }
                                                if((mapFieldAndItsType.get(eachField) == 'DOUBLE' || mapFieldAndItsType.get(eachField) == 'DECIMAL' || mapFieldAndItsType.get(eachField) == 'CURRENCY' || mapFieldAndItsType.get(eachField) == 'PERCENT') && strFieldValueToSave != null && strFieldValueToSave != '')
                                                {
                                                    String strTempFldVal = strFieldValueToSave;
                                                    strTempFldVal = strTempFldVal.replace('.',':');
                                                    List<String> lstDecimal = strTempFldVal.split(':');
                                                    if(lstDecimal != null && lstDecimal.size() >= 2)
                                                    {
                                                        if(mapFieldAndItsScale.get(eachField) != null)
                                                        {
                                                            for(Integer i = 0; i< mapFieldAndItsScale.get(eachField) - lstDecimal[1].length(); i++)
                                                                strFieldValueToSave += '0';
                                                        }
                                                        else
                                                        {
                                                            strFieldValueToSave = lstDecimal[0];
                                                        }
                                                    }
                                                }
                                                system.debug(LoggingLevel.WARN, 'Field value to be updated from client = ' + strFieldValueToSave + 'Field value at server = ' + strFldValAtSrvr);
                                                
                                                if(!strFldValFrmClient.equals(strFldValAtSrvr) && strFieldValueToSave != strFldValAtSrvr)
                                                {
                                                    system.debug(LoggingLevel.WARN,'Conflict in field = ' + eachField + ' and Sync Conflict = ' + strSyncConflict);
                                                    if(strSyncConflict == 'Allow user to choose')
                                                    {
                                                        system.debug(LoggingLevel.WARN,'Conflict when Allow user to choose');
                                                        conflict = new INTF_WebServicesDef.SVMXMap();
                                                        conflict.key = firstLevelMap.value;
                                                        conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                                
                                                        List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                        confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                        conflict.valueMap = confChild;
                                                        ConflictList.add(conflict);
                                                        strConflict = true;
                                                        break;  
                                                    }
                                                    else if(strSyncConflict == 'ServiceMax online data')
                                                    {
                                                        if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                        {
                                                            sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFldValAtSrvr);
                                                        }
                                                    }
                                                    else if(strSyncConflict == 'Mobile device data')
                                                    {
                                                        if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                        {
                                                            String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                            sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFieldValue);
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                    {
                                                        String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                        sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFieldValue);
                                                    }
                                                }
                                            }
                                        }
                                        if(!strConflict)
                                            sObjList.add(sobj);
                                        system.debug(LoggingLevel.WARN,'sObj to UPDATE = ' + sObj);
                                    }
                                    else
                                    {
                                        if(strSyncConflict != 'ServiceMax online data')
                                        {
                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax NOT online data');
                                            conflict = new INTF_WebServicesDef.SVMXMap();
                                            conflict.key = firstLevelMap.value;
                                            conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                        
                                            List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                            conflict.valueMap = confChild;
                                            ConflictList.add(conflict);
                                        }
                                        else
                                        {
                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                            listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                        }
                                    }
                                }
                                else
                                {
                                    sObjList.add(createsObjectToUpdate(strRecordId, sObj, setUpdatableFieldNames, mapIdAndRecordToBeUpdated, mapFieldAndItsType));  
                                }
                            }
                            a++;
                        }
                        system.debug(LoggingLevel.WARN, 'sObjList =' + sObjList);
                        INTF_WebServicesDef.SVMXMap Error;
                        try
                        {
                            parentsaveresult = Database.update(sObjList,false);
                        }
                        catch(DmlException e)
                        {
                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                            errChild.add(new INTF_WebServicesDef.SVMXMap('', ''));
                            ErrorList.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, e.getMessage()));   
                        }
                        finally
                        {
                            List<String> sfids = new List<String>();
                            if(parentsaveresult != null)
                            {
                                Integer i=0;
                                for(Database.Saveresult parentSave : parentsaveresult)
                                {
                                    sfids.add(parentSave.getId());
                                    if(parentSave.isSuccess())
                                    {
                                        listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', parentSave.getId()));
                                        system.debug(LoggingLevel.WARN, 'Update is Successfull');
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.WARN, 'Problem in Update');   
                                        Error = new INTF_WebServicesDef.SVMXMap();
                                        Error.key = firstLevelMap.value;
                                        Database.Error[] err = parentSave.getErrors();                                      
                                        Error.value = err[0].getMessage();
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        errChild.add(new INTF_WebServicesDef.SVMXMap('', String.valueOf(sObjList[i].Id)));
                                        Error.valueMap = errChild;
                                        ErrorList.add(Error);
                                    }
                                    i++;
                                }
                            }
                        }
                    }
                }
                responseValueMap.add(deletedRecIds);     
            }
            responseSVMXMap.key = firstLevelMap.key;
            responseSVMXMap.value = firstLevelMap.value;
            responseSVMXMap.values = null;
            responseSVMXMap.valueMap = listValueMaps;
            responseValueMap.add(responseSVMXMap);
        }
        conflictHeader.valueMap = ConflictList;
        ErrorHeader.valueMap = ErrorList;
        responseValueMap.add(conflictHeader);
        responseValueMap.add(ErrorHeader);
        INTF_DataSync.logMethodEndTS(intMethodCount,'updateRecordsFromClient');
        return responseValueMap;
    }*/
    
    public sObject createsObjectToUpdate(String strRecordId, sObject sObj, Set<String> setUpdatableFieldNames, Map<String, Map<String, String>> mapIdAndRecordToBeUpdated, map<String,String> mapFieldAndItsType)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('createsObjectToUpdate');
        system.debug(LoggingLevel.WARN, 'sObj = ' + sObj);
        if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
        {
            for(String strFieldName : mapIdAndRecordToBeUpdated.get(strRecordId).keySet())
            {
                String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(strFieldName);
                if(setUpdatableFieldNames.contains(strFieldName))
                {
                    system.debug(LoggingLevel.WARN, 'sObj before = ' + sObj);
                    sObj = createsObject(sObj, mapFieldAndItsType, strFieldName, strFieldValue);
                    system.debug(LoggingLevel.WARN, 'sObj after = ' + sObj);
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'createsObjectToUpdate');
        return sObj;
    }
    
    public sObject createsObject(sObject sObj, map<String,String> mapFieldAndItsType, String strFieldName, String strFieldValue)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('createsObject');
        if(strFieldValue == null || strFieldValue == '')
            sObj.put(strFieldName, null);
        else
        {
            strFieldValue = strFieldValue.replace('&amp;', '&');
            strFieldValue = strFieldValue.replace('&apos;', '\'');
            strFieldValue = strFieldValue.replace('&lt;', '<');
            strFieldValue = strFieldValue.replace('&gt;', '>');
            strFieldValue = strFieldValue.replace('&quot;', '"');
        
            if(mapFieldAndItsType.get(strFieldName) == 'DATETIME')
            {
                strFieldValue = strFieldValue.replace('T', ' ');
                strFieldValue = strFieldValue.replace('Z', ' ');
                sObj.put(strFieldName, Datetime.valueOfGmt(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DATE')
            {
                sObj.put(strFieldName, Date.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'TIME')
            {
                //do nothing as we do not support time field
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'BOOLEAN')
            {
                sObj.put(strFieldName, Boolean.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DOUBLE')
            {
                sObj.put(strFieldName, decimal.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DECIMAL' || mapFieldAndItsType.get(strFieldName) == 'CURRENCY' || mapFieldAndItsType.get(strFieldName) == 'PERCENT')
            {
                sObj.put(strFieldName, decimal.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'INTEGER')
            {
                sObj.put(strFieldName, Integer.valueOf(strFieldValue));
            }
            else
            {
                sObj.put(strFieldName, strFieldValue);
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'createsObject');
        return sObj;
    }
    
    public string getsettingIPAD018SET012()
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getsettingIPAD018SET012');
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        List<String> lstSettingId = new list<String>();
        lstSettingId.add('SET012');
        Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
        if(mapSettingsForIPAD018.containskey('SET012') && mapSettingsForIPAD018.get('SET012') != null && mapSettingsForIPAD018.get('SET012').length() > 0)
        {
            INTF_DataSync.logMethodEndTS(intMethodCount, 'getsettingIPAD018SET012');
            return mapSettingsForIPAD018.get('SET012');
        }else{
            INTF_DataSync.logMethodEndTS(intMethodCount, 'getsettingIPAD018SET012');
            return null;
        }
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getProductIQData(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductIQData');
        system.debug(LoggingLevel.Debug, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        if(inputRequest.eventName == 'SYNC_PRODUCTIQ_DATA')
        {
            Set<String> setAccessibleObjs = new Set<String>();
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            Set<String> setRequiredObjs = new Set<String>{'svmxc__site__c', 'svmxc__installed_product__c', 'Product2', 'Account'};
            allObjs = Schema.getGlobalDescribe();
            
            for(String objName : setRequiredObjs)
            {
                try
                {
                    if(allObjs.get(objName).getDescribe().isAccessible())
                        setAccessibleObjs.add(objName);
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.Debug, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }
            system.debug(LoggingLevel.Debug, 'setAccessibleObjs =  ' + setAccessibleObjs + ';setRequiredObjs = ' + setRequiredObjs);
            
            if(setAccessibleObjs.containsAll(setRequiredObjs))
            {
                Boolean isCallBack = false;
                DateTime dtLastSyncTime = null;
                Set<String> setWhatIds = new Set<String>();
                Map<String, String> mapDCObjToCriteria = new Map<String, String>();
                Map<String, String> mapADCObjToCriteria = new Map<String, String>();
                Integer intLevel = 0, intLastIndex = 0, intLimit = 10000, intBatchLimit = 5000;
                String strLastIdForCurrLvlLocClause = '', strLastIdForNxtLvlLocClause = '', strOrderByClause = '', strLocCriteria = '', strLocCriteriaInWOQry = '', strHierarchyIBLastIDClause = '';
                String strLastNxtLvlLocId = '', strLastCurrLvlLocId = '', strSOQL = '', strLastIdOfLoc = '', strLastIdOfIB = '', strLastIdOfIBClause = '', strLastIdOfLocClause = '', strTimeClause = '', strLastIdOfHierarchyID = '';
                
                for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
                {
                    system.debug(LoggingLevel.Debug, 'Each ValueMap in request = ' + eachReqParam);
                    if(eachReqParam.key == 'LAST_INDEX' && eachReqParam.value != null)
                    {
                        intLastIndex = Integer.valueOf(eachReqParam.value);
                    }
                    else if(eachReqParam.key == 'PRODUCTIQ_LAST_SYNC' && eachReqParam.value != null && eachReqParam.value != '')
                    {
                        dtLastSyncTime = Datetime.valueOf(eachReqParam.value);
                    }
                    else if(eachReqParam.key == 'CALL_BACK' && eachReqParam.value == 'true')
                    {
                        for(INTF_WebServicesDef.SVMXMap eachCallBackParam : eachReqParam.valueMap)
                        {
                            system.debug(LoggingLevel.Debug, 'Each ValueMap in CallBack = ' + eachCallBackParam);
                            if(eachCallBackParam.key == 'CURRENT_LEVEL_LOCATION_ID' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0 && eachCallBackParam.values != null && eachCallBackParam.values.size() > 0)
                            {
                                strLastCurrLvlLocId = eachCallBackParam.values[0];
                            }
                            else if((eachCallBackParam.key == 'NEXT_LEVEL_LOCATION_ID' || eachCallBackParam.key =='PARTIAL_EXECUTED_OBJECT_WO') && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0 && eachCallBackParam.values != null && eachCallBackParam.values.size() > 0)
                            {
                                strLastNxtLvlLocId = eachCallBackParam.values[0];
                            }
                            else if(eachCallBackParam.key == 'PARTIAL_EXECUTED_OBJECT_IB' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0 && eachCallBackParam.values != null && eachCallBackParam.values.size() > 0)
                            {
                                strLastIdOfIB = eachCallBackParam.values[0];
                                strLastIdOfIBClause = ' AND ID > :strLastIdOfIB ';
                            }
                            else if(eachCallBackParam.key == 'PARTIAL_EXECUTED_OBJECT_LOC' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0 && eachCallBackParam.values != null && eachCallBackParam.values.size() > 0)
                            {
                                strLastIdOfLoc = eachCallBackParam.values[0];
                                strLastIdOfLocClause = ' AND ID > :strLastIdOfLoc ';
                            }
                            else if(eachCallBackParam.key ==  'PARTIAL_EXECUTED_HIERARCHY_IB'&& eachCallBackParam.value != null && eachCallBackParam.value.length() > 0 && eachCallBackParam.values != null && eachCallBackParam.values.size() > 0)
                            {        
                                strLastIdOfHierarchyID = eachCallBackParam.values[0];       
                                strHierarchyIBLastIDClause = ' AND ID >: strLastIdOfHierarchyID ';      
                            }
                        }
                    }   
                    else if(eachReqParam.key == 'LEVEL' && eachReqParam.value != null && eachReqParam.value.length() > 0)
                    {
                        intLevel = Integer.valueOf(eachReqParam.value);
                    }
                }
                
                if(strLastNxtLvlLocId != null && strLastNxtLvlLocId.length() > 0)
                {
                    if(dtLastSyncTime != null || intLevel > 0 || intLastIndex==2)
                        strLastIdForNxtLvlLocClause = ' Id > :strLastNxtLvlLocId ';
                    else
                        strLastIdForNxtLvlLocClause = ' SVMXC__Parent__c > :strLastNxtLvlLocId ';
                }
                
                if(strLastCurrLvlLocId != null && strLastCurrLvlLocId.length() > 0)
                    strLastIdForCurrLvlLocClause = ' AND ID > :strLastCurrLvlLocId ';
                
                List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (List<SVMXC__ServiceMax_Config_Data__c>)INTF_TxnCache.get('IPAD018_SET006', 'List<SVMXC__ServiceMax_Config_Data__c>');
                if(lstSettings == null || lstSettings.size() == 0)
                {
                    lstSettings = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET006'}, grpProfileId);
                
                    if(lstSettings != null && lstSettings.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                            intLimit = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                    }
                    INTF_TxnCache.put('IPAD018_SET006', lstSettings, 'List<SVMXC__ServiceMax_Config_Data__c>');
                }
                
                if(intLastIndex == 0)
                {
                    if(intLevel > 0)
                        intBatchLimit = intLimit/(intLevel + 1);
                    else
                        intBatchLimit = intLimit;
                }
                else
                    intBatchLimit = intLimit/(intLevel + 2);
                
                Integer intBatchLimit1 = intBatchLimit;  
                    
                if(dtLastSyncTime != null)
                {
                    strSOQL = ' Id, ';
                    strTimeClause = ' AND LastModifiedDate >:dtLastSyncTime ';
                    strLocCriteria = ' OR (SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime) ';
                    strLocCriteriaInWOQry = ' (SVMXC__Site__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Site__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Site__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime OR SVMXC__Site__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate >= :dtLastSyncTime) ';
                }
                strOrderByClause = ' ORDER BY Id limit :intBatchLimit ';
                    
                String strWOQuery = '', strWODataSyncQry = '';
                Set<String> setMdfdWhatIds = new Set<String>();
                Set<String> setIsModifiedFlag = new Set<String>();
                Set<String> setAllLocationIds = new Set<String>();
                Set<String> setFifthLvlLocationIds = new Set<String>();
                Set<String> setObjNames = new Set<String>{'SVMXC__Service_Order__c'};
                List<SVMXC__Site__c> lstLocationIds = new List<SVMXC__Site__c>();
                List<SVMXC__Site__c> lstFirstLvlLocationIds = new List<SVMXC__Site__c>();
                INTF_WebServicesDef.SVMXMap callBackObj = new INTF_WebServicesDef.SVMXMap();
                INTF_WebServicesDef.SVMXMap partialExecObj = new INTF_WebServicesDef.SVMXMap();
                INTF_WebServicesDef.SVMXMap partialExecObj1 = new INTF_WebServicesDef.SVMXMap();
                
                Set<String> setAllQueriedLocationIds = new Set<String>();
                
                //Device Specific Mobile config                    
                String strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);     
                String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);       
                
                setWhatIds = (new Sync_Utility()).getEventRelatedWOIDs(grpProfileId, dtLastSyncTime, setIsModifiedFlag, setMdfdWhatIds, strDevConfId);      
                system.debug(LoggingLevel.Debug, 'setMdfdWhatIds = ' + setMdfdWhatIds + ';setWhatIds =  ' + setWhatIds);
                mapDCObjToCriteria = (new Sync_Utility()).getDownloadCriteriaForAnyObject(setObjNames, grpProfileId, dtLastSyncTime, setIsModifiedFlag, strDevConfId);
                mapADCObjToCriteria = (new Sync_Utility()).getAdvDownloadCriteriaForAnyObject(setObjNames, grpProfileId, setWhatIds, dtLastSyncTime, setIsModifiedFlag, strDevConfId);
                
                if(mapDCObjToCriteria.containsKey('SVMXC__Service_Order__c') && mapDCObjToCriteria.get('SVMXC__Service_Order__c') == '')
                {
                    strWOQuery = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null';
                    strWODataSyncQry = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null ' + strTimeClause;
                }
                else
                {
                    String strADCQry = '';
                    if(mapDCObjToCriteria.get('SVMXC__Service_Order__c') != null && mapDCObjToCriteria.get('SVMXC__Service_Order__c') != '' && mapDCObjToCriteria.get('SVMXC__Service_Order__c').length() > 0)
                    {
                        strWOQuery = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null AND ((' + mapDCObjToCriteria.get('SVMXC__Service_Order__c') + ')';
                        strWODataSyncQry = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null AND ((((' + mapDCObjToCriteria.get('SVMXC__Service_Order__c') + ')';
                    }
                    
                    system.debug(LoggingLevel.Debug, 'DC WO Query = ' + strWOQuery + '; WO Data Sync Query = ' + strWODataSyncQry);
                    if(mapADCObjToCriteria.get('SVMXC__Service_Order__c') != null && mapADCObjToCriteria.get('SVMXC__Service_Order__c') != '' && mapADCObjToCriteria.get('SVMXC__Service_Order__c').length() > 0)
                    {
                        if(strWOQuery != null && strWOQuery != '' && strWOQuery.length() > 0)
                        {
                            strWOQuery += ' OR ' + mapADCObjToCriteria.get('SVMXC__Service_Order__c');
                            strADCQry += ' OR ' + mapADCObjToCriteria.get('SVMXC__Service_Order__c') + ')';
                        }
                        else
                        {
                            strWOQuery = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null AND (' + mapADCObjToCriteria.get('SVMXC__Service_Order__c');
                            strADCQry = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null AND ((' + mapADCObjToCriteria.get('SVMXC__Service_Order__c');
                        }
                    } 
                    
                    system.debug(LoggingLevel.Debug, 'WO Query = ' + strWOQuery + ';WO Data Sync Query = ' + strWODataSyncQry);
                    
                    if(strWOQuery != null && strWOQuery != '' && strWOQuery.length() > 0)
                        strWOQuery += ' OR ID IN:setWhatIds) ';
                    else
                        strWOQuery = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null AND ID IN:setWhatIds';
                    
                    if(dtLastSyncTime != null)
                    {
                        if(strWODataSyncQry != null && strWODataSyncQry != '' && strWODataSyncQry.length() > 0)
                        {
                            if(strADCQry != '' && strADCQry.length() > 0)
                                strWODataSyncQry += strADCQry + strTimeClause + ')' + ' OR ID IN:setMdfdWhatIds OR ' + strLocCriteriaInWOQry + ' ) ';
                            else
                                strWODataSyncQry += strTimeClause + '))' + ' OR ID IN:setMdfdWhatIds OR ' + strLocCriteriaInWOQry + ' ) ';  
                        }
                        else
                            strWODataSyncQry = 'Select SVMXC__Site__c from SVMXC__Service_Order__c where SVMXC__Site__c != null AND ID IN:setMdfdWhatIds';
                    }
                }
                    
                system.debug(LoggingLevel.Debug, 'WO Query = ' + strWOQuery + ';WO Data Sync Query = ' + strWODataSyncQry);
                system.debug(LoggingLevel.Debug, 'intLastIndex = ' + intLastIndex + '; Level = ' + intLevel + '; intLimit = ' + intLimit + '; intBatchLimit = ' + intBatchLimit + 'Last Sync Time = ' + dtLastSyncTime);
                system.debug(LoggingLevel.Debug, 'Last IB Id = ' + strLastIdOfIBClause + '; Last Location Id = ' + strLastIdOfLocClause);
                system.debug(LoggingLevel.Debug, 'strLastIdForNxtLvlLocClause = ' + strLastIdForNxtLvlLocClause + '; strLastIdForCurrLvlLocClause = ' + strLastIdForCurrLvlLocClause);
                
                if(setIsModifiedFlag.contains('true'))
                {
                    strTimeClause = '';
                    strLocCriteria = '';
                    dtLastSyncTime = null;
                }
                
                if(intLastIndex == 0)
                {
                    List<SVMXC__Site__c> lstNextLocationIds = new List<SVMXC__Site__c>();
                    setAllQueriedLocationIds = new Set<String>();
                    
                    for(Integer intCurrLevel=0; intCurrLevel<=intLevel; intCurrLevel++)
                    {
                        system.debug(LoggingLevel.Debug, 'Current Level = ' + intCurrLevel);
                        if((intLimit > 0) && (Limits.getQueries() < Limits.getLimitQueries()-10) && (Limits.getHeapSize() < Limits.getLimitHeapSize()-1000) && (Limits.getCpuTime() < Limits.getLimitCpuTime()-1000))
                        {
                            if(intCurrLevel == 0)
                            {
                                if(dtLastSyncTime != null)
                                {
                                    if(intCurrLevel == intLevel){
                                        INTF_DataSync.logSOQL(intMethodCount , 'Select ' + strSOQL + ' SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWODataSyncQry + ')' + strLastIdForCurrLvlLocClause + strOrderByClause);
                                        lstFirstLvlLocationIds = Database.query('Select ' + strSOQL + ' SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWODataSyncQry + ')' + strLastIdForCurrLvlLocClause + strOrderByClause);
                                    }else{
                                        INTF_DataSync.logSOQL(intMethodCount , 'Select ' + strSOQL + ' SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ') ' + strLastIdForCurrLvlLocClause + strOrderByClause);
                                        lstFirstLvlLocationIds = Database.query('Select ' + strSOQL + ' SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ') ' + strLastIdForCurrLvlLocClause + strOrderByClause);
                                    }
                                }   
                                else{
                                    INTF_DataSync.logSOQL(intMethodCount , 'Select ' + strSOQL + ' SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ') ' + strTimeClause + strLastIdForCurrLvlLocClause + strOrderByClause);
                                    lstFirstLvlLocationIds = Database.query('Select ' + strSOQL + ' SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ') ' + strTimeClause + strLastIdForCurrLvlLocClause + strOrderByClause);
                                } 
                                
                                if(lstFirstLvlLocationIds != NULL){
                                    for(SVMXC__Site__c eachLoc: lstFirstLvlLocationIds){
                                        setAllQueriedLocationIds.add(eachLoc.ID);
                                        setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__c);
                                        setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__c);
                                        setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                        setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                        setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    }
                                } 
                                  
                            }
                            intLimit = intLimit - lstFirstLvlLocationIds.size();
                            
                            system.debug(LoggingLevel.Debug, 'lstFirstLvlLocationIds = ' + lstFirstLvlLocationIds.size() + ';' + lstFirstLvlLocationIds);
                            if(intCurrLevel < intLevel)
                            {
                                setFifthLvlLocationIds.clear();
                                setAllQueriedLocationIds.remove(null);
                                
                                for(SVMXC__Site__c loc : lstFirstLvlLocationIds)
                                {
                                    if(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c != null && !setAllQueriedLocationIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c))
                                        setFifthLvlLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                }
                                system.debug(LoggingLevel.Debug, 'setFifthLvlLocationIds = ' + setFifthLvlLocationIds);
                                if(setFifthLvlLocationIds != null && setFifthLvlLocationIds.size() > 0)
                                {
                                    INTF_DataSync.logSOQL(intMethodCount ,'Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where (ID IN :setFifthLvlLocationIds ' + strLocCriteria + ') ' + strLastIdForNxtLvlLocClause + strOrderByClause);
                                    lstFirstLvlLocationIds = Database.query('Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where (ID IN :setFifthLvlLocationIds ' + strLocCriteria + ') ' + strLastIdForNxtLvlLocClause + strOrderByClause);
                                    intLimit = intLimit - lstFirstLvlLocationIds.size();
                                    intBatchLimit1 = intBatchLimit1 - lstFirstLvlLocationIds.size();
                                    system.debug(LoggingLevel.Debug, 'lstFirstLvlLocationIds = ' + lstFirstLvlLocationIds.size() + ';' + lstFirstLvlLocationIds);
                                    
                                    if(lstFirstLvlLocationIds != NULL){
                                        for(SVMXC__Site__c eachLoc: lstFirstLvlLocationIds){
                                            setAllQueriedLocationIds.add(eachLoc.ID);
                                            setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__c);
                                            setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__c);
                                            setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                            setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                            setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                        }
                                    }
                                }
                                else
                                    lstFirstLvlLocationIds.clear();
                                system.debug(LoggingLevel.Debug, 'lstFirstLvlLocationIds = ' + lstFirstLvlLocationIds.size() + ';' + lstFirstLvlLocationIds);   
                            }
                            if(intCurrLevel == intLevel && intLevel > 0)
                            {
                                lstNextLocationIds.addAll(lstFirstLvlLocationIds);
                                intLimit = intLimit - lstNextLocationIds.size();
                                intBatchLimit1 = intBatchLimit1 - lstNextLocationIds.size();
                                system.debug(LoggingLevel.Debug, 'lstNextLocationIds = ' + lstNextLocationIds.size() + ';' + lstNextLocationIds);
                                setAllQueriedLocationIds.clear();
                            }
                        }
                        else
                            break;
                    }
                    
                    if(intLevel == 0)
                        lstLocationIds.addAll(lstFirstLvlLocationIds);
                    else
                        lstLocationIds.addAll(lstNextLocationIds);
                        
                    for(SVMXC__Site__c eachLvlLoc : lstLocationIds)
                    {
                        if(dtLastSyncTime != null || intLevel > 0)
                            setAllLocationIds.add(eachLvlLoc.Id);
                                
                        setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__c);
                        setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__c);
                        setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                        setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                        setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                    }
                    setAllLocationIds.remove(null);
                    
                    callBackObj.key = 'CALL_BACK';
                    
                    if(lstNextLocationIds.size() > 0 && (intLimit <= 0 || intBatchLimit1 <= 0))
                    {
                        isCallBack = true;
                        partialExecObj.key = 'NEXT_LEVEL_LOCATION_ID';
                        partialExecObj.value = 'SVMXC__Site__c';
                        partialExecObj.values.add(String.valueOf(lstNextLocationIds[lstNextLocationIds.size() - 1].Id)); 
                        callBackObj.valueMap.add(partialExecObj);
                    }
                    else if(lstFirstLvlLocationIds.size() > 0)
                    {
                        if(intLimit <= 0 || intBatchLimit1 <= 0)
                        {
                            isCallBack = true;
                            partialExecObj.key = 'CURRENT_LEVEL_LOCATION_ID';
                            partialExecObj.value = 'SVMXC__Site__c';
                            partialExecObj.values.add(String.valueof(lstFirstLvlLocationIds[lstFirstLvlLocationIds.size() - 1].Id));
                            callBackObj.valueMap.add(partialExecObj);
                        }
                        else
                        {
                            isCallBack = true;
                            intLevel++;
                        }
                    }
                    else if(lstNextLocationIds.size() <= 0 && lstFirstLvlLocationIds.size() <= 0 && intLevel > 0)
                    {
                        isCallBack = false;
                        intLastIndex++;
                    }
                    else
                    {
                        isCallBack = true;
                        intLevel++;
                    }
                        
                    callBackObj.value = String.valueOf(isCallBack);
                    INTF_WebServicesDef.SVMXMap siteIds = new INTF_WebServicesDef.SVMXMap();
                    siteIds.key = 'SVMXC__Site__c';
                    siteIds.values.addAll(setAllLocationIds); 
                    response.valueMap.add(siteIds);
                }
                else if(intLastIndex == 1)
                {
                    Set<String> setHierarchyIBIds = new Set<String>();
                    Set<String> setMdfdLocationIds = new Set<String>();
                    List<SVMXC__Site__c> lstMdfdFirstLvlLocationIds = new List<SVMXC__Site__c>();
                    List<SVMXC__Installed_Product__c> lstIBIds = new List<SVMXC__Installed_Product__c>();
                    List<SVMXC__Installed_Product__c> lstHierarchyIBIds = new List<SVMXC__Installed_Product__c>();
                    setAllQueriedLocationIds = new Set<String>();
                    
                    for(Integer intCurrLevel=0; intCurrLevel<=intLevel; intCurrLevel++)
                    {
                        system.debug(LoggingLevel.Debug, 'Current Level = ' + intCurrLevel);
                        if((intLimit > 0) && (Limits.getQueries() < Limits.getLimitQueries()-10) && (Limits.getHeapSize() < Limits.getLimitHeapSize()-1000) && (Limits.getCpuTime() < Limits.getLimitCpuTime()-1000))
                        {
                            if(setFifthLvlLocationIds != null && setFifthLvlLocationIds.size() > 0){
                                INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN:setFifthLvlLocationIds ' + strLastIdOfLocClause + ' ORDER BY ID limit :intBatchLimit');
                                lstFirstLvlLocationIds = Database.query('Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN:setFifthLvlLocationIds ' + strLastIdOfLocClause + ' ORDER BY ID limit :intBatchLimit');
                            }
                            else if(intCurrLevel == 0)
                            {
                                INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ')' + strLastIdOfLocClause + ' ORDER BY ID limit :intBatchLimit');
                                lstFirstLvlLocationIds = Database.query('Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ')' + strLastIdOfLocClause + ' ORDER BY ID limit :intBatchLimit');
                                if(dtLastSyncTime != null){
                                    INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWOQuery + ')' + strLastIdOfLocClause + ' ORDER BY ID limit :intBatchLimit');
                                    lstMdfdFirstLvlLocationIds = Database.query('Select Id, SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ID IN (' + strWODataSyncQry + ')' + strLastIdOfLocClause + ' ORDER BY ID limit :intBatchLimit');
                                }
                            }
                            else
                            {
                                lstFirstLvlLocationIds.clear();
                                lstMdfdFirstLvlLocationIds.clear();
                            }
        
                            intLimit = intLimit - lstFirstLvlLocationIds.size();
                            intLimit = intLimit - lstMdfdFirstLvlLocationIds.size();
                            
                            if(lstFirstLvlLocationIds != NULL){
                                for(SVMXC__Site__c eachLoc: lstFirstLvlLocationIds){
                                    setAllQueriedLocationIds.add(eachLoc.ID);
                                    setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__c);
                                    setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setAllQueriedLocationIds.add(eachLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    }
                            }
                               
                            if(intCurrLevel < intLevel)
                            {
                                setFifthLvlLocationIds.clear();
                                setAllQueriedLocationIds.remove(null);
                                for(SVMXC__Site__c loc : lstFirstLvlLocationIds)
                                {
                                    if(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c != null && !setAllQueriedLocationIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c))
                                        setFifthLvlLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                }
                                system.debug(LoggingLevel.Debug, 'setFifthLvlLocationIds = ' + setFifthLvlLocationIds);
                            }   
                            if(intCurrLevel == intLevel)
                            {
                                for(SVMXC__Site__c eachLvlLoc : lstFirstLvlLocationIds)
                                {
                                    setAllLocationIds.add(eachLvlLoc.Id);
                                    setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__c);
                                    setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setAllLocationIds.add(eachLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                }
                                for(SVMXC__Site__c eachMdfdLvlLoc : lstMdfdFirstLvlLocationIds)
                                {
                                    setMdfdLocationIds.add(eachMdfdLvlLoc.Id);
                                    setMdfdLocationIds.add(eachMdfdLvlLoc.SVMXC__Parent__c);
                                    setMdfdLocationIds.add(eachMdfdLvlLoc.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setMdfdLocationIds.add(eachMdfdLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setMdfdLocationIds.add(eachMdfdLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                    setMdfdLocationIds.add(eachMdfdLvlLoc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);
                                }
                                setAllLocationIds.remove(null);
                                setMdfdLocationIds.remove(null);
                                
                                system.debug(LoggingLevel.Debug, 'setAllLocationIds = ' + setAllLocationIds.size());
                                system.debug(LoggingLevel.Debug, 'setMdfdLocationIds = ' + setMdfdLocationIds.size());
                                
                                if(dtLastSyncTime != null){
                                    INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c where (((SVMXC__Site__c IN :setAllLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN :setAllLocationIds) ' + strTimeClause + ') OR SVMXC__Site__c IN :setMdfdLocationIds) ' + strLastIdOfIBClause + ' ORDER BY ID limit :intBatchLimit');
                                    lstIBIds = Database.query('Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c where (((SVMXC__Site__c IN :setAllLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN :setAllLocationIds) ' + strTimeClause + ') OR SVMXC__Site__c IN :setMdfdLocationIds) ' + strLastIdOfIBClause + ' ORDER BY ID limit :intBatchLimit');
                                }else{
                                    INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c where (SVMXC__Site__c IN :setAllLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN :setAllLocationIds) ' + strLastIdOfIBClause + strTimeClause + ' ORDER BY ID limit :intBatchLimit');
                                    lstIBIds = Database.query('Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c where (SVMXC__Site__c IN :setAllLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN :setAllLocationIds) ' + strLastIdOfIBClause + strTimeClause + ' ORDER BY ID limit :intBatchLimit');
                                }
                                intLimit = intLimit - lstIBIds.size();
                                
                                for(SVMXC__Installed_Product__c eachIB : lstIBIds)
                                {
                                    if(eachIB.SVMXC__Top_Level__r.SVMXC__Company__c != null)
                                        setHierarchyIBIds.add(eachIB.SVMXC__Top_Level__r.SVMXC__Company__c);
                                }
                                
                                system.debug(LoggingLevel.Debug, 'setHierarchyIBIds = ' + setHierarchyIBIds);
                                
                                if(setHierarchyIBIds != null && setHierarchyIBIds.size() > 0){
                                    INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c from SVMXC__Installed_Product__c where SVMXC__Top_Level__r.SVMXC__Company__c IN :setHierarchyIBIds AND SVMXC__Site__c = null ' + strTimeClause + ' ORDER BY ID limit :intBatchLimit');
                                    lstHierarchyIBIds = Database.query('Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c from SVMXC__Installed_Product__c where SVMXC__Top_Level__r.SVMXC__Company__c IN :setHierarchyIBIds AND SVMXC__Site__c = null ' + strTimeClause + ' ORDER BY ID limit :intBatchLimit');
                                }
                                intLimit = intLimit - lstHierarchyIBIds.size();
                            }
                        }
                        else
                            break;
                    }
                    
                    setAllQueriedLocationIds.clear();
                    
                    callBackObj.key = 'CALL_BACK';
    
                    if(intLimit <= 0 && lstIBIds.size() > 0)
                    {
                        isCallBack = true;
                        partialExecObj.key = 'PARTIAL_EXECUTED_OBJECT_IB';
                        partialExecObj.value = 'SVMXC__Installed_Product__c';
                        partialExecObj.values.add(String.valueOf(lstIBIds[lstIBIds.size() - 1].Id));
                        callBackObj.valueMap.add(partialExecObj);
                        
                        if(strLastIdOfLocClause != null && strLastIdOfLocClause != '' && strLastIdOfLocClause.length() > 0)
                        {
                            partialExecObj1.key = 'PARTIAL_EXECUTED_OBJECT_LOC';
                            partialExecObj1.value = 'SVMXC__Site__c';
                            partialExecObj1.values.add(strLastIdOfLoc);
                            callBackObj.valueMap.add(partialExecObj1);
                        }
                        system.debug(LoggingLevel.Debug, 'callBackObj = ' + callBackObj);
                    }
                    else if(intLimit <= 0 && lstFirstLvlLocationIds.size() > 0)
                    {
                        isCallBack = true;
                        partialExecObj.key = 'PARTIAL_EXECUTED_OBJECT_LOC';
                        partialExecObj.value = 'SVMXC__Site__c';
                        partialExecObj.values.add(String.valueOf(lstFirstLvlLocationIds[lstFirstLvlLocationIds.size() - 1].Id));
                        callBackObj.valueMap.add(partialExecObj);
                    }
                    else if(lstIBIds.size() <= 0 && lstFirstLvlLocationIds.size() <= 0)
                    {
                        isCallBack = false;
                        intLastIndex++;                         
                    }
                    else
                    {
                        isCallBack = true;
                        intLevel++;
                    }
                    
                    lstIBIds.addAll(lstHierarchyIBIds); 
                    callBackObj.value = String.valueOf(isCallBack);
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Installed_Product__c', String.valueOf(JSON.serialize(lstIBIds))));            
                    system.debug(LoggingLevel.Debug, 'Size of lstIBIds = ' + lstIBIds.size() + '; Limit = ' + intLimit);
                }
                else if(intLastIndex == 2)      
                {       
                    system.debug('Request ='+inputRequest);     
                            
                    Integer locationBatchLimit, workBatchLimit, ibBatchLimit, parentIBBatchLimit;       
                    
                    locationBatchLimit = workBatchLimit =  ibBatchLimit = parentIBBatchLimit = intLimit/4;      
                            
                    Set<String> setQueriedLocationIDs = new Set<String>();      
                    List<SVMXC__Site__c> lstQueriedLocations= new List<SVMXC__Site__c>();       
                    Set<String> setModifiedLocIds = new Set<String>();      
                    Set<String> setLocationIds = new Set<String>();     
                    Set<String> setLocIDToSend = new Set<String>();     
                    Set<String> setHierarchyIBIds = new Set<String>();      
                    Set<String> setIBIdsToSend = new Set<String>();     
                    List<SVMXC__Installed_Product__c> lstIBsToSend = new List<SVMXC__Installed_Product__c>();       
                    List<SVMXC__Installed_Product__c> lstHierarchyIBs = new List<SVMXC__Installed_Product__c>();        
                    string strLastIDWOClause = '';      
                            
                    if(strLastNxtLvlLocId !=NULL && strLastNxtLvlLocId!='' ){       
                        strLastIDWOClause = ' AND Id > :strLastNxtLvlLocId ';  //Last WORK ORDER ID         
                    }       
                            
                    /********** Handle Work Orders *********/       
                            
                    //Get the location IDs from all WOs         
                    strWOQuery = strWOQuery.replace('Select', 'Select LastModifiedDate,'); //To include lastModifiedDate        
                    System.debug('Last Sync time Work Order query = '+strWOQuery+strLastIDWOClause+' ORDER BY Id limit :workBatchLimit ');      
                    INTF_DataSync.logSOQL(intMethodCount , strWOQuery+strLastIDWOClause+' ORDER BY Id limit :workBatchLimit ');                                                 
                
                    List<SVMXC__Service_Order__c> lstAllWorkOrder = Database.query(strWOQuery+strLastIDWOClause+' ORDER BY Id limit :workBatchLimit ');     
                    system.debug(LoggingLevel.WARN, '*** lstAllWorkOrder size = '+lstAllWorkOrder.size());      
                            
                    workBatchLimit -= lstAllWorkOrder.size();       
                            
                    if(lstAllWorkOrder != NULL){        
                        for(SVMXC__Service_Order__c wo : lstAllWorkOrder){      
                            setQueriedLocationIDs.add(wo.SVMXC__Site__c);  //All Location IDs       
                                    
                            if(dtLastSyncTime != null){         
                                if(wo.LastModifiedDate > dtLastSyncTime || setMdfdWhatIds.contains(wo.ID) ){        
                                    setModifiedLocIds.add(wo.SVMXC__Site__c); //Modified loc ids        
                                }       
                            }       
                        }       
                    }       
                            
                    /******** Handle Locations *********/       
                            
                    //Query all locations       
                    INTF_DataSync.logSOQL(intMethodCount ,'Select Id, LastModifiedDate, SVMXC__Parent__c, SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ( ID IN: setQueriedLocationIDs OR SVMXC__Parent__c IN: setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs ) ' + strLastIdOfLocClause + ' ORDER BY Id limit :locationBatchLimit ');     
                    lstQueriedLocations = Database.Query('Select Id, LastModifiedDate, SVMXC__Parent__c, SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate, SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c from SVMXC__Site__c where ( ID IN: setQueriedLocationIDs OR SVMXC__Parent__c IN: setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs OR SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c IN :setQueriedLocationIDs ) ' + strLastIdOfLocClause + ' ORDER BY Id limit :locationBatchLimit ');      
                            
                    locationBatchLimit -= lstQueriedLocations.size();       
                            
                    for(SVMXC__Site__c loc: lstQueriedLocations){       
                        setLocationIds.add(loc.ID);     
                        setLocationIds.add(loc.SVMXC__Parent__c);       
                        setLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__c);      
                        setLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);     
                        setLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);        
                        setLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);       
                        setLocationIds.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);      
                            
                        //To send in response - send all if LastsyncTime = NULL - or send only modified locations       
                        if(dtLastSyncTime != NULL){ //send only modified Locations  
                            if(setModifiedLocIds.contains(loc.Id) || setModifiedLocIds.contains(loc.SVMXC__Parent__c) || setModifiedLocIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__c) || setModifiedLocIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c) || setModifiedLocIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c) || setModifiedLocIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c) || setModifiedLocIds.contains(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c) || (loc.LastModifiedDate > dtLastSyncTime || loc.SVMXC__Parent__r.LastModifiedDate > dtLastSyncTime || loc.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate > dtLastSyncTime || loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate > dtLastSyncTime || loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate > dtLastSyncTime || loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.LastModifiedDate > dtLastSyncTime)){    
                                //locations have been modified - get all the IBs for these      
                                setLocIDToSend.add(loc.Id);     
                                setLocIDToSend.add(loc.SVMXC__Parent__c);       
                                setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__c);      
                                setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);     
                                setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);        
                                setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);       
                                setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);      
                            }       
                        }else{      
                            //Not incremental sync - send all location IDs      
                            setLocIDToSend.add(loc.Id);     
                            setLocIDToSend.add(loc.SVMXC__Parent__c);       
                            setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__c);      
                            setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);     
                            setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);        
                            setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);       
                            setLocIDToSend.add(loc.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__r.SVMXC__Parent__c);      
                        }       
                    }       
                    setLocationIds.remove(NULL);        
                    setLocIDToSend.remove(NULL);        
                            
                    //add location Ids to response      
                    setAllLocationIds.addAll(setLocIDToSend);       
                            
                    /******** Handle Installed Product *********/       
                            
                    //Query all IBs for these setLocationIds        
                    system.debug(LoggingLevel.WARN, 'Query formed for IB = '+'Select Id, LastModifiedDate, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c  where ( SVMXC__Site__c IN: setLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN : setLocationIds )' + strLastIdOfIBClause + ' ORDER BY ID limit :ibBatchLimit');       
                    INTF_DataSync.logSOQL(intMethodCount , 'Select Id, LastModifiedDate, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c  where ( SVMXC__Site__c IN: setLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN : setLocationIds )' + strLastIdOfIBClause + ' ORDER BY ID limit :ibBatchLimit');     
                    List<SVMXC__Installed_Product__c> lstQueriedIBs = Database.Query('Select Id, LastModifiedDate, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c, SVMXC__Top_Level__r.SVMXC__Company__c from SVMXC__Installed_Product__c  where ( SVMXC__Site__c IN: setLocationIds OR SVMXC__Top_Level__r.SVMXC__Site__c IN : setLocationIds )' + strLastIdOfIBClause + ' ORDER BY ID limit :ibBatchLimit');       
                            
                    system.debug(LoggingLevel.WARN, 'IBs queried size = '+lstQueriedIBs.size());        
                    ibBatchLimit -= lstQueriedIBs.size();       
                            
                    for(SVMXC__Installed_Product__c ib : lstQueriedIBs){        
                                
                        if(dtLastSyncTime != NULL){ //send only modified Locations      
                            if(setLocIDToSend.contains(ib.SVMXC__Site__c) || ib.LastModifiedDate > dtLastSyncTime){  //related location was modified OR IB was modified-> send all the IBs for these        
                                setIBIdsToSend.add(ib.ID);      
                                lstIBsToSend.add(ib);       
                            }       
                        }else{      
                            //Not incremental Sync - send all IB ids        
                            setIBIdsToSend.add(ib.Id);      
                            lstIBsToSend.add(ib);       
                        }       
                    }       
                            
                    /******** Handle Hierarchy Installed Product *********/     
                            
                    Set<String> setModifiedIBAccIDs = new Set<String>();        
                    Set<String> setNotModifiedIBAccIDs = new Set<String>();     
                            
                    for(SVMXC__Installed_Product__c eachIB : lstQueriedIBs)     
                    {       
                        if(eachIB.SVMXC__Top_Level__r.SVMXC__Company__c != null){       
                            if(setIBIdsToSend.contains(eachIB.ID)){    //Modified IBs - query all Hierarchy Ibs for these       
                                setModifiedIBAccIDs.add(eachIB.SVMXC__Top_Level__r.SVMXC__Company__c);          
                            }else{      
                                setNotModifiedIBAccIDs.add(eachIB.SVMXC__Top_Level__r.SVMXC__Company__c); //Query only modified IBs for these       
                            }       
                        }       
                    }       
                            
                    //Query Hierarchy IBs       
                    if( setModifiedIBAccIDs.size() > 0 || setNotModifiedIBAccIDs.size() > 0 ){      
                        INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c from SVMXC__Installed_Product__c where SVMXC__Site__c = null AND ( (SVMXC__Top_Level__r.SVMXC__Company__c IN :setModifiedIBAccIDs )  OR (SVMXC__Top_Level__r.SVMXC__Company__c IN :setNotModifiedIBAccIDs '+ strTimeClause + ')) '+ strHierarchyIBLastIDClause + ' ORDER BY ID limit :parentIBBatchLimit');        
                        lstHierarchyIBs = Database.query('Select Id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Sub_Location__c, SVMXC__Top_Level__c from SVMXC__Installed_Product__c where SVMXC__Site__c = null AND ( (SVMXC__Top_Level__r.SVMXC__Company__c IN :setModifiedIBAccIDs )  OR (SVMXC__Top_Level__r.SVMXC__Company__c IN :setNotModifiedIBAccIDs '+ strTimeClause + ')) '+ strHierarchyIBLastIDClause + ' ORDER BY ID limit :parentIBBatchLimit');      
                    }       
                            
                    parentIBBatchLimit = parentIBBatchLimit - lstHierarchyIBs.size();       
                            
                    //Call back     
                    callBackObj.key = 'CALL_BACK';      
                    if(parentIBBatchLimit <= 0){   //If there are pending hierarchy IB ids      
                        isCallBack = true;     //Change the Key     
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_HIERARCHY_IB', 'SVMXC__Installed_Product__c',String.valueOf(lstHierarchyIBs[lstHierarchyIBs.size() - 1].Id) ));        
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_IB', 'SVMXC__Installed_Product__c',strLastIdOfIB));     
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_LOC', 'SVMXC__Site__c',strLastIdOfLoc));        
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_WO', 'SVMXC__Service_Order__c',strLastNxtLvlLocId));        
                    }else if(ibBatchLimit <= 0 ){       
                        isCallBack = true;      
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_IB', 'SVMXC__Installed_Product__c',String.valueOf(lstQueriedIBs[lstQueriedIBs.size() - 1].Id) ));       
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_LOC', 'SVMXC__Site__c',strLastIdOfLoc));        
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_WO', 'SVMXC__Service_Order__c',strLastNxtLvlLocId));        
                    }else if(locationBatchLimit <= 0){      
                        isCallBack = true;              
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_LOC', 'SVMXC__Site__c',String.valueOf(lstQueriedLocations[lstQueriedLocations.size() - 1].Id) ));       
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_WO', 'SVMXC__Service_Order__c',strLastNxtLvlLocId));        
                    }else if(workBatchLimit <= 0){      
                        isCallBack = true;      
                        callBackObj.valueMap.add(addCallBackContextPIQ('PARTIAL_EXECUTED_OBJECT_WO', 'SVMXC__Service_Order__c',String.valueOf(lstAllWorkOrder[lstAllWorkOrder.size() - 1].Id) ));       
                    }else{      
                        isCallBack = false;         
                    }       
                    callBackObj.value=String.valueOf(isCallBack);           
                            
                            
                    //Add IB to response        
                    lstIBsToSend.addAll(lstHierarchyIBs);       
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Installed_Product__c', String.valueOf(JSON.serialize(lstIBsToSend)))); 
                    
                    INTF_WebServicesDef.SVMXMap siteIds = new INTF_WebServicesDef.SVMXMap();
                    siteIds.key = 'SVMXC__Site__c';
                    siteIds.values.addAll(setAllLocationIds); 
                    response.valueMap.add(siteIds);                     
                            
                }                
                response.valueMap.add(callBackObj);
                response.valueMap.add(new INTF_WebServicesDef.SVMXMap('LEVEL', String.valueOf(intLevel)));
                response.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(intLastIndex)));
                system.debug(LoggingLevel.Debug, 'Response Call back = ' + callBackObj);
            }
            else
                system.debug(LoggingLevel.Debug, 'Permissions not available for these objects = ' + setRequiredObjs);
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', String.valueOf(DateTime.now())));
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getProductIQData');
        return response;
    }
    INTF_WebServicesDef.SVMXMap addCallBackContextPIQ(String key, string value, String values){     
        INTF_WebServicesDef.SVMXMap partialExecObj = new INTF_WebServicesDef.SVMXMap();     
        partialExecObj.key = key;       
        partialExecObj.value = value;       
        partialExecObj.values.add(values);      
        return partialExecObj;      
    }     
    /*public INTF_WebServicesDef.INTF_SFMResponse getDeletedProductIQData(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDeletedProductIQData');
        system.debug(LoggingLevel.Debug, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        if(inputRequest.eventName == 'GET_DELETE_PRODUCTIQ_DATA')
        {
            Integer intLimit = 10000;
            Datetime dtLastSynchTime = null;
            Set<String> setExecObjects = new Set<String>();
            String strPartialExecObjName = '', strLastIdForPartialExcObj = '';
            Set<String> setObjectNames = new Set<String>{'SVMXC__Site__c', 'SVMXC__Installed_Product__c', 'Product2', 'Account', 'SVMXC__Sub_Location__c'};
               
            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (List<SVMXC__ServiceMax_Config_Data__c>)INTF_TxnCache.get('IPAD018_SET006', 'List<SVMXC__ServiceMax_Config_Data__c>');
            if(lstSettings == null || lstSettings.size() == 0)
            {
                lstSettings = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET006'}, grpProfileId);
            
                if(lstSettings != null && lstSettings.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                        intLimit = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                }
                INTF_TxnCache.put('IPAD018_SET006', lstSettings, 'List<SVMXC__ServiceMax_Config_Data__c>');
            }
                 
            for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
            {
                if(eachReqParam.key == 'PRODUCTIQ_LAST_SYNC' && eachReqParam.value != null && eachReqParam.value != '')
                {
                    dtLastSynchTime = Datetime.valueOf(eachReqParam.value);
                }
                else if(eachReqParam.key == 'PARTIAL_EXECUTED_OBJECT' && eachReqParam.value != null && eachReqParam.value.length() > 0)
                {
                    strPartialExecObjName = eachReqParam.value;
                    strLastIdForPartialExcObj = eachReqParam.values[eachReqParam.values.size() - 1];
                }
            }
           
            if(inputRequest.values != null && inputRequest.values.size() > 0)
            {
                setExecObjects.addAll(inputRequest.values);
            }
            setObjectNames.removeAll(setExecObjects);
           
            system.debug(LoggingLevel.Debug, 'Limit = ' + intLimit + '; setExecObjects = ' + setExecObjects + '; setObjectNames = ' + setObjectNames + '; Last Sync Time = ' + dtLastSynchTime);
           
            for(String strEachObjName : setObjectNames)
            {
                String strLastIdClause = '';
                List<sObject> lstDeletedIds = new List<sObject>();
                INTF_WebServicesDef.SVMXMap partialExecObj = new INTF_WebServicesDef.SVMXMap();
                INTF_WebServicesDef.SVMXMap eachObjectRecords = new INTF_WebServicesDef.SVMXMap();
                system.debug(LoggingLevel.Debug, 'Object Name = ' + strEachObjName);
                
                if(strEachObjName == strPartialExecObjName && strLastIdForPartialExcObj != null && strLastIdForPartialExcObj.length() > 0)
                {
                    strLastIdClause = ' AND ID > :strLastIdForPartialExcObj ';
                    system.debug(LoggingLevel.WARN, 'Partial Executed Object = ' + strPartialExecObjName + '; strLastIdClause = ' + strLastIdClause);
                }
                
                INTF_DataSync.logSOQL(intMethodCount , 'Select Id FROM ' + strEachObjName + ' where isDeleted = true AND LastModifiedDate >:dtLastSynchTime ' + strLastIdClause + ' Order By Id limit :intLimit ALL ROWS ');
                lstDeletedIds = Database.query('Select Id FROM ' + strEachObjName + ' where isDeleted = true AND LastModifiedDate >:dtLastSynchTime ' + strLastIdClause + ' Order By Id limit :intLimit ALL ROWS ');
                intLimit -= lstDeletedIds.size();
                system.debug(LoggingLevel.Debug, 'Size = ' + lstDeletedIds.size());
                eachObjectRecords.key = strEachObjName;
                eachObjectRecords.value = JSON.serialize(lstDeletedIds);
                if(intLimit <= 0)
                {
                    partialExecObj.key = 'PARTIAL_EXECUTED_OBJECT';
                    partialExecObj.value = strEachObjName;
                    partialExecObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_DELETED_ID', lstDeletedIds[lstDeletedIds.size() - 1].Id));
                    response.valueMap.add(partialExecObj);
                    response.valueMap.add(eachObjectRecords);
                    break;
                }
                else
                {
                    response.values.add(strEachObjName);
                    response.valueMap.add(eachObjectRecords);
                }
                system.debug(LoggingLevel.Debug, 'Each Object response = ' + eachObjectRecords + '; response.values = ' + response.values);
            }
            response.values.addAll(setExecObjects);
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        system.debug(LoggingLevel.Debug, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getDeletedProductIQData');
        return response;
    }*/
    
    public INTF_WebServicesDef.INTF_SFMResponse getDeletedProductIQData(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDeletedProductIQData');
        system.debug(LoggingLevel.Debug, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        if(inputRequest.eventName == 'GET_DELETE_PRODUCTIQ_DATA')
        {
                map<String, List<String>> mapObjToIds = new map<String, List<String>>();
            Integer intLimit = 10000;
            Datetime dtLastSynchTime = null;
            Set<String> setExecObjects = new Set<String>();
            String strPartialExecObjName = '', strLastIdForPartialExcObj = '';
            Set<String> setObjectNames = new Set<String>{'SVMXC__Site__c', 'SVMXC__Installed_Product__c', 'Product2', 'Account', 'SVMXC__Sub_Location__c'};
               
            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (List<SVMXC__ServiceMax_Config_Data__c>)INTF_TxnCache.get('IPAD018_SET006', 'List<SVMXC__ServiceMax_Config_Data__c>');
            if(lstSettings == null || lstSettings.size() == 0)
            {
                lstSettings = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET006'}, grpProfileId);
            
                if(lstSettings != null && lstSettings.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                        intLimit = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                }
                INTF_TxnCache.put('IPAD018_SET006', lstSettings, 'List<SVMXC__ServiceMax_Config_Data__c>');
            }
                 
            for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
            {
                if(eachReqParam.key == 'PRODUCTIQ_LAST_SYNC' && eachReqParam.value != null && eachReqParam.value != '')
                {
                    dtLastSynchTime = Datetime.valueOf(eachReqParam.value);
                }
                else if(eachReqParam.key == 'PARTIAL_EXECUTED_OBJECT' && eachReqParam.value != null && eachReqParam.value.length() > 0)
                {
                    strPartialExecObjName = eachReqParam.value;
                    strLastIdForPartialExcObj = eachReqParam.values[eachReqParam.values.size() - 1];
                }
                else if(eachReqParam.key == 'TX_OBJECT' && eachReqParam.value != null && eachReqParam.value != '')
                {
                    if(!mapObjToIds.containsKey(eachReqParam.value))
                    {
                        List<String> lstIds = new List<String>();
                        lstIds.addAll(eachReqParam.values);
                        mapObjToIds.put(eachReqParam.value, lstIds);
                    }
                    else
                        mapObjToIds.get(eachReqParam.value).addAll(eachReqParam.values);    
                }
            }
           
            
            system.debug(LoggingLevel.Debug, 'Limit = ' + intLimit + '; Last Sync Time = ' + dtLastSynchTime);
           
            for(String strEachObjName : mapObjToIds.keySet())
            {
                String strLastIdClause = '';
                List<sObject> lstDeletedIds = new List<sObject>();
                system.debug(LoggingLevel.Debug, 'Object Name = ' + strEachObjName);
                
                if(strEachObjName == strPartialExecObjName && strLastIdForPartialExcObj != null && strLastIdForPartialExcObj.length() > 0)
                {
                    strLastIdClause = ' AND ID > :strLastIdForPartialExcObj ';
                    system.debug(LoggingLevel.WARN, 'Partial Executed Object = ' + strPartialExecObjName + '; strLastIdClause = ' + strLastIdClause);
                }
                
                List<String> objectIDList = mapObjToIds.get(strEachObjName);
                INTF_DataSync.logSOQL(intMethodCount , 'Select Id FROM ' + strEachObjName + ' where ID IN :objectIDList AND isDeleted = true AND SystemModstamp >:dtLastSynchTime ' + strLastIdClause + ' Order By Id limit :intLimit ALL ROWS ');
                system.debug('Query is = '+ 'Select Id FROM ' + strEachObjName + ' where ID IN :objectIDList AND isDeleted = true AND SystemModstamp >:dtLastSynchTime ' + strLastIdClause + ' Order By Id limit :intLimit ALL ROWS ');
                lstDeletedIds = Database.query('Select Id FROM ' + strEachObjName + ' where ID IN :objectIDList AND isDeleted = true AND SystemModstamp >:dtLastSynchTime ' + strLastIdClause + ' Order By Id limit :intLimit ALL ROWS ');
                intLimit -= lstDeletedIds.size();
                system.debug(LoggingLevel.Debug, 'Size = ' + lstDeletedIds.size());
                
                if(intLimit <= 0)
                {
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', strEachObjName, new List<String>{lstDeletedIds[lstDeletedIds.size() - 1].Id}));
                    break;
                }
                
                response.valueMap.add(new INTF_WebServicesDef.SVMXMap(strEachObjName, JSON.serialize(lstDeletedIds)));
            }
            response.values.addAll(setExecObjects);
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        system.debug(LoggingLevel.Debug, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getDeletedProductIQData');
        return response;
    }
    
    
    public INTF_WebServicesDef.INTF_SFMResponse getCheckListData(INTF_WebServicesDef.INTF_SFMRequest inputRequest, String grpProfileId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getCheckListData');
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries() + '; Rows Queried = ' + Limits.getQueryRows());
        Boolean isChecklist = false;
        String strChklstStatusClause = '', strChklstStatus=  '';
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        //get Device specific mobile config
        string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
        system.debug(LoggingLevel.WARN,' Device from Request getCheckListData = '+strDeviceType);
        String strMobConfQuery  = 'select SVMXC__Display_Type__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =: grpProfileId AND (SVMXC__Display_Type__c = \'Enable Checklist\' OR SVMXC__Display_Type__c = \'Completed Checklists\' OR SVMXC__Display_Type__c = \'InProgress Checklists\') ';
         
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for getCheckListData = '+strMobConfQuery);
        
        INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
        //for(SVMXC__ServiceMax_Config_Data__c eachConf : [select SVMXC__Display_Type__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND SVMXC__Access_Configuration_Profile__c =: grpProfileId AND (SVMXC__Display_Type__c = 'Enable Checklist' OR SVMXC__Display_Type__c = 'Completed Checklists' OR SVMXC__Display_Type__c = 'InProgress Checklists')])
        for(SVMXC__ServiceMax_Config_Data__c eachConf : Database.Query(strMobConfQuery))

        {
            if(eachConf.SVMXC__Display_Type__c == 'Enable Checklist' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != '')
                isChecklist = Boolean.valueOf(eachConf.SVMXC__Internal_Value__c);
            else if(eachConf.SVMXC__Display_Type__c == 'Completed Checklists' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != '')
            {
                if(Boolean.valueOf(eachConf.SVMXC__Internal_Value__c))
                {
                    if(strChklstStatus != '')
                        strChklstStatus += ' OR SVMXC__Status__c = \'Completed\' ';
                    else
                        strChklstStatus = ' SVMXC__Status__c = \'Completed\' ';   
                }
            }
            else if(eachConf.SVMXC__Display_Type__c == 'InProgress Checklists' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != '')
            {
                if(Boolean.valueOf(eachConf.SVMXC__Internal_Value__c))
                {
                    if(strChklstStatus != '')
                        strChklstStatus += ' OR SVMXC__Status__c = \'In Process\' ';
                    else
                        strChklstStatus = ' SVMXC__Status__c = \'In Process\' ';
                }
            }
        }
        if(strChklstStatus != '' && strChklstStatus.length() > 0)
            strChklstStatusClause = ' AND (' + strChklstStatus + ')';
        else
            isChecklist = false;
        
        system.debug(LoggingLevel.WARN, 'strChklstStatusClause = ' + strChklstStatusClause);
        
        if(inputRequest.eventName == 'SYNC_CHECKLIST_DATA' && isChecklist)
        {
            Datetime currentTime = Datetime.now();
            String strUserId = UserInfo.getUserId();
            Set<String> setWhatIds = new Set<String>();
            set<String> setObjects = new set<String>();
            set<String> setExecObjects = new set<String>();
            set<String> setDCEventADCObjects = new set<String>();
            set<String> setSFMProcessIds = new set<String>();
            Set<String> setMdfdEventWhatIds = new Set<String>();
            set<String> setAssgndChklstProcess = new set<String>();
            List<SVMXC__Checklist__c > lstAllChecklists = new List<SVMXC__Checklist__c >();
            List<String> lstAllChkAttachmentIds = new List<String>();       
            List<String> lstAttachmentRecordIds = new List<String>();  
            List<String> lstDocLinkIds = new List<String>();     
            Set<String> setDeletedChkIds = new Set<String>();       
            Set<String> setDeletedChkAttachmentIds = new Set<String>();   
            Set<String> setDeletedCDLIds = new Set<String>();  
            Set<String> setDeletedAttachmentIds = new Set<String>();             
            set<String> setChecklistProPurpose = new set<String>{'CHECKLIST'};
            Datetime dtToDate, dtFromDate, dtMovingDate, dtLastSynchTime = null;
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            Integer intLimit = 10000, intChkLstLimit = 3500, intObjectLimit = 3500, intChkAttachLimit = 3000;    
            String strPartialExecObjName = '', strLastIdForObject = '', strTimeClause = '';
            String strLastIDForChkAttachment = '', strLastIdClauseForChkAttchmt = '', strLastIdForChecklist = '', strLastIdClauseForChklst = '';        
            
            for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
            {
                if(eachReqParam.key == 'LAST_SYNC_TIME' && eachReqParam.value != null && eachReqParam.value != '')
                    dtLastSynchTime = Datetime.valueOf(eachReqParam.value);
                if(eachReqParam.key == 'PARTIAL_EXECUTED_OBJECT' && eachReqParam.value != null && eachReqParam.value.length() > 0 && eachReqParam.values != null && eachReqParam.values.size() > 0)
                {
                    strPartialExecObjName = eachReqParam.value;
                     if(eachReqParam.values[0] != NULL && eachReqParam.values[0] != '')      
                        strLastIdForObject = eachReqParam.values[0];        
                }else if(eachReqParam.key == 'PARTIAL_EXECUTED_CHECKLIST' && eachReqParam.value != null && eachReqParam.value.length() > 0 && eachReqParam.values != null && eachReqParam.values.size() > 0){     
                    if(eachReqParam.values[0] != NULL && eachReqParam.values[0] != ''){     
                        strLastIdForChecklist = eachReqParam.values[0];     
                        strLastIdClauseForChklst = ' AND ID > \'' + eachReqParam.values[0] + '\'';       
                    }           
                }else if(eachReqParam.key == 'PARTIAL_EXECUTED_CHK_ATTACHMENT' && eachReqParam.value != null && eachReqParam.value.length() > 0 && eachReqParam.values != null && eachReqParam.values.size() > 0){        
                    if(eachReqParam.values[0] != NULL && eachReqParam.values[0] != ''){     
                        strLastIDForChkAttachment = eachReqParam.values[0];     
                        strLastIdClauseForChkAttchmt = ' AND ID > \'' + eachReqParam.values[0] + '\'';       
                    }   
                }
            }
            
            if(dtLastSynchTime != null)
                strTimeClause = ' AND LastModifiedDate >: dtLastSynchTime ';
            
            if(inputRequest.values != null && inputRequest.values.size() > 0)
                setExecObjects.addAll(inputRequest.values);
            
            INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: \'Service Flow Access\' AND SVMXC__Access_Configuration_Profile__c = :grpProfileId AND SVMXC__Dispatch_Process__c != null AND SVMXC__Dispatch_Process__r.SVMXC__Purpose__c IN :setChecklistProPurpose');
            for(SVMXC__ServiceMax_Config_Data__c eachAccessRec : [Select SVMXC__Access_Configuration_Profile__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =: 'Service Flow Access' AND SVMXC__Access_Configuration_Profile__c = :grpProfileId AND SVMXC__Dispatch_Process__c != null AND SVMXC__Dispatch_Process__r.SVMXC__Purpose__c IN :setChecklistProPurpose])
                setAssgndChklstProcess.add(eachAccessRec.SVMXC__Dispatch_Process__c);
            
            INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\' AND SVMXC__Process__c IN:setAssgndChklstProcess AND SVMXC__Process__r.SVMXC__Purpose__c IN:setChecklistProPurpose AND SVMXC__Source_Object_Name__c NOT IN: setExecObjects AND SVMXC__Source_Object_Name__c != \'SVMXC__Checklist__c\'');
            for(SVMXC__ServiceMax_Processes__c eachProcess : [Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'Process Node Objects' AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = 'Complete' AND SVMXC__Process__c IN:setAssgndChklstProcess AND SVMXC__Process__r.SVMXC__Purpose__c IN:setChecklistProPurpose AND SVMXC__Source_Object_Name__c NOT IN: setExecObjects AND SVMXC__Source_Object_Name__c != 'SVMXC__Checklist__c'])
            {
                setObjects.add(eachProcess.SVMXC__Source_Object_Name__c);
                setSFMProcessIds.add(eachProcess.SVMXC__Process__c);
            }
            
            List<SVMXC__ServiceMax_Config_Data__c> lst = (new INTF_ConfigSync()).getSettings(null, null, new set<string>{'IPAD018_SET006'}, grpProfileId);
            if(lst != null && lst.size() != 0 && lst.size() == 1)
                intLimit = Integer.valueOf(lst[0].SVMXC__Internal_Value__c);
            
            if((Limits.getLimitQueryRows() - Limits.getQueryRows()) <  intLimit)
                intLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
            
            if(intLimit <= 0)        
                intLimit = 3;       
                    
            intObjectLimit = intLimit/3;        
            intChkLstLimit = intLimit/3;        
            intChkAttachLimit = intLimit/3;  
            
            system.debug(LoggingLevel.WARN, 'intLimit = ' + intLimit + '; intObjectLimit = ' + intObjectLimit +  '; intChkLstLimit = ' + intChkLstLimit + '; setObjects = ' + setObjects);
            strMobConfQuery = 'select Id, SVMXC__Display_Type__c, SVMXC__Internal_value__c, SVMXC__Object_Name__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR SVMXC__Display_Type__c = \'Synchronization To Remove Events\' OR SVMXC__Display_Type__c = \'Download Criteria\' OR SVMXC__Display_Type__c = \'Advanced Download Criteria\')';       
            if(strDevConfId != NULL && strDevConfId != ''){     
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
            }       
            system.debug(LoggingLevel.WARN,'Second Query formed for getCheckListData = '+strMobConfQuery);      
                
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);      
            for(SVMXC__ServiceMax_Config_Data__c objConfigData: Database.Query(strMobConfQuery))        
            { 
                Integer intValue = 10;
                if(objConfigData.SVMXC__Display_Type__c == 'Download Criteria' || objConfigData.SVMXC__Display_Type__c == 'Advanced Download Criteria')
                {
                    setDCEventADCObjects.add(objConfigData.SVMXC__Object_Name__c);
                }
                else
                {
                    if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Remove Events')
                    {
                        if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                        {
                            intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                            if(intValue < 1)
                                intValue = 10;
                        }   
                        dtFromDate = currentTime - (intValue + 1);
                    }   
                    else if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Get Events')
                    {
                        if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                        {
                            intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                            if(intValue < 1)
                                intValue = 10;
                        }   
                        dtToDate = currentTime + intValue + 1;
                        if(dtLastSynchTime != null)
                            dtMovingDate = dtLastSynchTime + intValue + 1;
                    }
                    if(dtLastSynchTime != null && objConfigData.LastModifiedDate > dtLastSynchTime){
                            dtLastSynchTime = NULL;
                        strTimeClause = ' ';
                    }
                }
            }
            INTF_DataSync.logSOQL(intMethodCount,'Select What.Id, What.Type from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null');
            for(Event evt :[Select What.Id, What.Type from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null])
            {
                setDCEventADCObjects.add(evt.What.Type);
                setWhatIds.add(evt.What.Id);
            }
    
            INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
            for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
            {
                setDCEventADCObjects.add(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()));
                setWhatIds.add(evt.SVMXC__WhatId__c);
            }
            
            if(dtLastSynchTime != null && strTimeClause != '')
            {
                INTF_DataSync.logSOQL(intMethodCount,'Select What.Id, What.Type from Event where ((((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) AND LastModifiedDate >: dtLastSynchTime) OR ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate))) and OwnerId = :strUserId and WhatId != null');
                for(Event evt :[Select What.Id, What.Type from Event where ((((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) AND LastModifiedDate >: dtLastSynchTime) OR ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate))) and OwnerId = :strUserId and WhatId != null])
                {
                    setDCEventADCObjects.add(evt.What.Type);
                    setMdfdEventWhatIds.add(evt.What.Id);
                }
                INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) AND LastModifiedDate >: dtLastSynchTime) OR ((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) AND LastModifiedDate >: dtLastSynchTime) OR ((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                {
                    setDCEventADCObjects.add(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()));
                    setMdfdEventWhatIds.add(evt.SVMXC__WhatId__c);
                }
            }
            system.debug(LoggingLevel.WARN, 'setDCEventADCObjects = ' + setDCEventADCObjects);
            setObjects.retainAll(setDCEventADCObjects);//retain only objects which are part of Event/DC/ADC
            
            for(String strObjName : setObjects)
            {
                system.debug(LoggingLevel.WARN, 'Each Object = ' + strObjName);
                if(allObjs.get(strObjName.toLowerCase()).getDescribe().isAccessible())
                {
                    Boolean isDCObjectNoCriteria = false;
                    INTF_WebServicesDef.SVMXMap partialExecObj;
                    Set<String> setChklstWhatIds = new Set<String>();
                    Set<String> setChklstIds = new Set<String>();       
                    List<sObject> lstQryResult = new List<sObject>();
                    List<SVMXC__Checklist__c> lstQryChecklistResult = new List<SVMXC__Checklist__c>();      
                    List<SVMXC__SM_Checklist_Attachment__c> lstChklstAttachmentResult = new List<SVMXC__SM_Checklist_Attachment__c>();
                    String strFinalCriteria = '', strFinalQry = '', strLastIdClauseForObject = '';
                    Set<String> setModEventChkIds = new Set<String>();      
                    Set<String> setModifiedChecklistIds = new Set<String>();  
                    Set<String> SetModifiedRecordIds = new Set<string>();      
                    Set<String> setAllChecklistIds = new Set<String>();     
                    List<SVMXC__Checklist__c> lstChecklistResult = new List<SVMXC__Checklist__c>();     
                    
                    if(strObjName == strPartialExecObjName){        
                        if(strLastIdForObject != null && strLastIdForObject.length() > 0){
                            strLastIdClauseForObject = ' AND ID > :strLastIdForObject ';
                        }
                    }

                    //Device specific setting       
                    strMobConfQuery = 'select Id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Display_Type__c, SVMXC__Internal_value__c, SVMXC__Ownership_Type__c, LastModifiedDate, CreatedDate, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND (SVMXC__Display_Type__c = \'Download Criteria\' OR SVMXC__Display_Type__c = \'Advanced Download Criteria\') AND SVMXC__Object_Name__c != null AND SVMXC__Object_Name__c =:strObjName';        
                    if(strDevConfId != NULL && strDevConfId != ''){     
                        strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
                    }       
                    system.debug(LoggingLevel.WARN,'Third Query formed for getCheckListData = '+strMobConfQuery);       
                
                    INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);      
                    
                    for(SVMXC__ServiceMax_Config_Data__c objConfigData: Database.Query(strMobConfQuery))        
                    {
                        String strCriteria = '';
                        system.debug(LoggingLevel.WARN, 'Each Mobile Config record = ' + objConfigData);
                        if(objConfigData.SVMXC__Display_Type__c == 'Download Criteria')
                        {
                            if(objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null)
                                strCriteria = '((' + objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                        
                            if(objConfigData.SVMXC__Ownership_Type__c == 'My Records')
                            {
                                if(strCriteria != '')
                                    strCriteria += ' and ';
                                else
                                    strCriteria += '(';
                                strCriteria += 'OwnerId = \'' + UserInfo.getUserId() + '\' ';
                            }
                            if(strCriteria != '')
                                strCriteria += ')';
                        
                            strCriteria = strCriteria.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                            strCriteria = strCriteria.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());    
                            strCriteria = strCriteria.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                            //strCriteria = strCriteria.replace('SVMX.USERTRUNK', strCurrTechLocId);
                            system.debug(LoggingLevel.WARN, 'UserInfo.getUserId() = ' + UserInfo.getUserId());
                            Map<String, String> mapSFCSToValue = (new INTF_DataUtilityServices()).replaceLiteralWithValue(strCriteria);
                            for(String eachLiteral : mapSFCSToValue.keySet())
                            {
                                system.debug(LoggingLevel.WARN, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                                if(mapSFCSToValue.get(eachLiteral) !=null && mapSFCSToValue.get(eachLiteral) !=''){
                                        strCriteria = strCriteria.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                                }else{
                                        strCriteria = strCriteria.replace(eachLiteral, '');
                                }
                            }
                                
                            system.debug(LoggingLevel.WARN, 'Final DC Criteria = ' + strCriteria);
                            if(strCriteria == '' && strCriteria.length() <= 0)
                            {
                                isDCObjectNoCriteria = true;
                                break;
                            }
                        }
                        if(objConfigData.SVMXC__Display_Type__c == 'Advanced Download Criteria')
                        {
                            if(objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                            {
                                strCriteria = '((' + objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                                INTF_DataSync.logSOQL(intMethodCount,'select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: objConfigData.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC');
                                for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: objConfigData.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC])
                                {
                                    String strObjNameAndField = '';
                                    if((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null)
                                    {
                                        String strReferenceFieldIds = '';
                                        strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                                        INTF_DataSync.logSOQL(intMethodCount,'Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds');
                                        for(sobject sObj : Database.query('Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds'))
                                        {
                                            if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                            {
                                                if(strReferenceFieldIds != '')
                                                    strReferenceFieldIds += ',';
                                                strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                            }
                                        }
                                        if(strReferenceFieldIds == '')
                                            strReferenceFieldIds = '\'DummyListOfIds1\'';
                                             
                                        strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                                        system.debug(LoggingLevel.WARN, 'strCriteria = ' + strCriteria);
                                    }
                                    else
                                    {
                                        //criteria exists in variable strCriteria.
                                    }
                                }
                            }
                            else
                            {
                                strCriteria = '';
                            }
                            if(objConfigData.SVMXC__Ownership_Type__c == 'My Records')
                            {
                                if(strCriteria != '')
                                    strCriteria = ' ( ' + strCriteria + ' ) and ';
                                else
                                    strCriteria += '(';
                                    
                                strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                            }
                            
                            strCriteria += ') ';    
                            system.debug(LoggingLevel.WARN, 'Final ADC Criteria = ' + strCriteria);
                        }
                        
                        if(strFinalCriteria != '' && strCriteria != '')
                            strFinalCriteria += ' OR ';
                        strFinalCriteria += strCriteria;
                        
                        system.debug(LoggingLevel.WARN, 'LastModifiedDate of Each DC-ADC Record = ' + objConfigData.LastModifiedDate + ', Last Sync Time = ' + dtLastSynchTime);
                        if(dtLastSynchTime != null && (objConfigData.LastModifiedDate > dtLastSynchTime || (objConfigData.SVMXC__Dispatch_Process__c != null && objConfigData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSynchTime))){
                            dtLastSynchTime = NULL;
                            strTimeClause = ' ';
                        }
                        system.debug(LoggingLevel.WARN, 'Final Criteria = ' + strCriteria);
                    }
                        
                    if(isDCObjectNoCriteria)
                    {
                        if(strLastIdClauseForObject != null && strLastIdClauseForObject.length() > 0)
                            strFinalQry += 'Select Id, LastModifiedDate from ' + strObjName + ' where ' + strLastIdClauseForObject.removeStart(' AND') + ' Order By Id limit ' + intObjectLimit;
                        else
                            strFinalQry += 'Select Id, LastModifiedDate from ' + strObjName + ' Order By Id limit ' + intObjectLimit; 
                    }
                    else if(strFinalCriteria != '')
                        strFinalQry += 'Select Id, LastModifiedDate from ' + strObjName + ' where (' + strFinalCriteria + ') ' + strLastIdClauseForObject + ' Order By Id limit ' + intObjectLimit;
                    
                    system.debug(LoggingLevel.WARN, 'Final Query = ' + strFinalQry);
                    
                    if(strFinalQry != null && strFinalQry != '' && strFinalQry.length() > 0)
                    {
                        INTF_DataSync.logSOQL(intMethodCount,strFinalQry);
                        lstQryResult = Database.query(strFinalQry);
                    }
                            
                    for(sObject eachrec : lstQryResult){
                        setChklstWhatIds.add(eachRec.Id);
                        if(dtLastSynchTime != NULL){
                                //Get all the checklists and checklist attachments for records that have been modified
                                if((Datetime)eachrec.get('LastModifiedDate') > dtLastSynchTime){
                                    SetModifiedRecordIds.add(eachrec.Id);
                                }
                        }
                    }  
                      
                    if(lstQryResult != NULL){                  
                        system.debug(LoggingLevel.WARN, 'lstQryResult = ' + lstQryResult.size() + '; setChklstWhatIds = ' + setChklstWhatIds.size());
                        intObjectLimit -= lstQryResult.size();
                    }
                    if(lstQryResult.size() > 0 || setWhatIds.size() > 0 || setMdfdEventWhatIds.size() > 0)
                    {
                                
                        //Query All the checklist       
                        system.debug(LoggingLevel.WARN,' Query prepared for checklist : ' + 'Select Id, SVMXC__What_Id__c, LastModifiedDate from SVMXC__Checklist__c where SVMXC__ChecklistProcessID__c IN: setSFMProcessIds AND (SVMXC__What_Id__c IN :setChklstWhatIds OR SVMXC__What_Id__c IN :setWhatIds OR SVMXC__What_Id__c IN :setMdfdEventWhatIds) ' + strChklstStatusClause + strLastIdClauseForChklst + ' Order By Id limit ' + intChkLstLimit + ' ALL ROWS');        
                        INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__What_Id__c, LastModifiedDate, isDeleted from SVMXC__Checklist__c where SVMXC__ChecklistProcessID__c IN: setSFMProcessIds AND ( SVMXC__What_Id__c IN :setChklstWhatIds OR SVMXC__What_Id__c IN :setWhatIds OR SVMXC__What_Id__c IN :setMdfdEventWhatIds) ' + strChklstStatusClause + strLastIdClauseForChklst + ' Order By Id limit ' + intChkLstLimit + ' ALL ROWS');       
                        lstQryChecklistResult = Database.query('Select Id, SVMXC__What_Id__c, LastModifiedDate, isDeleted from SVMXC__Checklist__c where SVMXC__ChecklistProcessID__c IN: setSFMProcessIds AND ( SVMXC__What_Id__c IN :setChklstWhatIds OR SVMXC__What_Id__c IN :setWhatIds OR SVMXC__What_Id__c IN :setMdfdEventWhatIds) ' + strChklstStatusClause + strLastIdClauseForChklst + ' Order By Id limit ' + intChkLstLimit + ' ALL ROWS');     
        
                        system.debug(LoggingLevel.WARN, 'Checklist result is : '+lstQryChecklistResult.size());     
                        //Identify the modified checklists      
                        for(SVMXC__Checklist__c eachChk: lstQryChecklistResult){        
                                    
                            //get the list of deleted Checklist records     
                            if(eachChk.IsDeleted){      
                                if(dtLastSynchTime != NULL){        
                                    if(eachChk.LastModifiedDate > dtLastSynchTime ){     
                                        setDeletedChkIds.add(eachChk.Id);  //incremental        
                                    }       
                                }else{      
                                    setDeletedChkIds.add(eachChk.Id);  //not incremental - include all the deleted IDs      
                                }           
                            }else{      
                                    
                                if( setChklstWhatIds.contains(eachChk.SVMXC__What_Id__c) || setWhatIds.contains(eachChk.SVMXC__What_Id__c)){        
                                    if(dtLastSynchTime != NULL){        
                                        if(eachChk.LastModifiedDate > dtLastSynchTime){      
                                            setModifiedChecklistIds.add(eachChk.Id); //modified Checklists --> get all attachments       
                                            lstChecklistResult.add(eachChk);        
                                        }else{      
                                            setAllChecklistIds.add(eachChk.Id);  //get only modified attachment for these attachments       
                                        }           
                                    }else{      
                                        //No Last Sync time - Initial sync      
                                        setAllChecklistIds.add(eachChk.Id);         
                                        lstChecklistResult.add(eachChk);        
                                    }       
                                } 
                                      
                                if( (setMdfdEventWhatIds.size() > 0 && setMdfdEventWhatIds.contains(eachChk.SVMXC__What_Id__c)) || (SetModifiedRecordIds.size() > 0 && SetModifiedRecordIds.contains(eachChk.SVMXC__What_Id__c)) ){
                                    setModEventChkIds.add(eachChk.Id);   //Get all the checklist and related attachments for these      
                                    lstChecklistResult.add(eachChk);        
                                }       
                            }       
                                    
                        }           
                                
                        lstAllChecklists.addAll(lstChecklistResult);                  
                        if(lstQryChecklistResult != null )
                        {
                            intChkLstLimit -= lstQryChecklistResult.size();
                        }
                    }
                    if(!setModEventChkIds.isEmpty() || !setModifiedChecklistIds.isEmpty() || !setAllChecklistIds.isEmpty() ){
                    
                        String strAttachmentQry = 'Select Id,SVMXC__SM_Attachment_ID__c, IsDeleted, SVMXC__SM_ContentDocumentLink_ID__c from SVMXC__SM_Checklist_Attachment__c ';
                        String strWhereClause = '';
                        
                        if(!setModEventChkIds.isEmpty()){
                            //there are modified events - get all the attachments
                            strWhereClause += ' (SVMXC__SM_Checklist__c IN: setModEventChkIds) ';
                        }

                        if(!setModifiedChecklistIds.isEmpty()){
                            //there are modified Checklist - get all attachments
                            if(strWhereClause.length() > 0){
                                strWhereClause += ' OR (SVMXC__SM_Checklist__c IN: setModifiedChecklistIds) ';
                            }else{
                                strWhereClause += ' (SVMXC__SM_Checklist__c IN: setModifiedChecklistIds) ';
                            }
                        }

                        if(!setAllChecklistIds.isEmpty()){
                            //get only the modified attachments
                            if(strWhereClause.length() > 0){
                                strWhereClause += ' OR (SVMXC__SM_Checklist__c IN: setAllChecklistIds ' + strTimeClause + ' ) ';
                            }else{
                                strWhereClause += ' (SVMXC__SM_Checklist__c IN: setAllChecklistIds ' + strTimeClause + ' ) ';
                            }
                        }
                        
                        if(strWhereClause != ''){
                            strWhereClause = '( ' + strWhereClause + ' )';
                        }
                        
                        if(strWhereClause != '' || strLastIdClauseForChkAttchmt != ''){
                            strAttachmentQry = strAttachmentQry + ' Where ';
                        }

                        system.debug(LoggingLevel.WARN, '++ Attachment query is = '+strAttachmentQry + strWhereClause + strLastIdClauseForChkAttchmt + ' Order By Id limit ' + intChkAttachLimit + ' ALL ROWS');
                        INTF_DataSync.logSOQL(intMethodCount,strAttachmentQry + strWhereClause +strLastIdClauseForChkAttchmt + ' Order By Id limit ' + intChkAttachLimit + ' ALL ROWS');
                        lstChklstAttachmentResult = Database.query(strAttachmentQry + strWhereClause +strLastIdClauseForChkAttchmt + ' Order By Id limit ' + intChkAttachLimit + ' ALL ROWS');
                        
                        for(SVMXC__SM_Checklist_Attachment__c chkAttchmt : lstChklstAttachmentResult){
                            if(chkAttchmt.isDeleted){
                                setDeletedChkAttachmentIds.add(chkAttchmt.ID);  //Deleted Checklist Attachment Ids
                                if(chkAttchmt.SVMXC__SM_Attachment_ID__c != NULL)
                                        setDeletedAttachmentIds.add(chkAttchmt.SVMXC__SM_Attachment_ID__c); //Deleted Attachment Ids
                                 if(chkAttchmt.SVMXC__SM_ContentDocumentLink_ID__c != NULL)        
                                    setDeletedCDLIds.add(chkAttchmt.SVMXC__SM_ContentDocumentLink_ID__c); //CDL related to deleted checklist attachments        
                            }else{
                                lstAllChkAttachmentIds.add(chkAttchmt.Id);
                                 if(chkAttchmt.SVMXC__SM_Attachment_ID__c != NULL)
                                    lstAttachmentRecordIds.add(chkAttchmt.SVMXC__SM_Attachment_ID__c);
                                if(chkAttchmt.SVMXC__SM_ContentDocumentLink_ID__c != NULL)           
                                    lstDocLinkIds.add(chkAttchmt.SVMXC__SM_ContentDocumentLink_ID__c);
                            }   
                        }
                    }
                    
                    if(lstChklstAttachmentResult != NULL){
                        intChkAttachLimit -= lstChklstAttachmentResult.size();
                    }
                    system.debug(LoggingLevel.WARN, ' Remaining attachment limit = '+intChkAttachLimit);
                    
                    //Batching check:
                    
                    if(intChkAttachLimit <= 0){
                        //There are more chk attachments to be processes
                        addCallBackForChecklist(response, strObjName, new List<String>{strLastIdForObject} , new List<String>{strLastIdForChecklist} , new List<String>{lstChklstAttachmentResult[lstChklstAttachmentResult.size() - 1].Id} );
                    }else if(intChkLstLimit <= 0){
                        addCallBackForChecklist(response, strObjName, new List<String>{strLastIdForObject}, new List<String>{lstQryChecklistResult[lstQryChecklistResult.size() - 1].Id}, NULL );
                    }else if(intObjectLimit <= 0){
                        addCallBackForChecklist(response, strObjName, new List<String>{lstQryResult[lstQryResult.size() - 1].Id}, NULL, NULL );
                    }
                    
                    //update the limit for next object in the loop
                    if(intObjectLimit <= 0 || intChkLstLimit <= 0 || intChkAttachLimit <= 0){
                        break;
                    }else{
                        response.values.add(strObjName);
                        intLimit -= lstQryResult.size();
                        intLimit -= lstQryChecklistResult.size();
                        intLimit -= lstChklstAttachmentResult.size();
                        
                        if(intLimit <= 0 && intLimit/3 <= 0)
                            intLimit = 3;
                        
                        intObjectLimit = intLimit/3;
                        intChkLstLimit = intLimit/3;
                        intChkAttachLimit = intLimit/3;
                    }
                    system.debug(LoggingLevel.WARN, 'intLimit = ' + intLimit + '; intObjectLimit = ' + intObjectLimit + '; intChkLstLimit = ' + intChkLstLimit);
                }
                else
                {
                    system.debug(LoggingLevel.WARN, 'This object is not accessible :' + strObjName);
                    response.values.add(strObjName);
                }
            }
            //add the checklist and checklist Attachment to response
            response.values.addAll(setExecObjects);
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Checklist_Attachment_Ids', JSON.serialize(lstAllChkAttachmentIds)));
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Attachment_Record_Ids', JSON.serialize(lstAttachmentRecordIds)));
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_IDS', JSON.serialize(lstDocLinkIds)));
            
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Deleted_Checklist_Ids', JSON.serialize(setDeletedChkIds)));
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Deleted_Checklist_Attachment_Ids', JSON.serialize(setDeletedChkAttachmentIds)));
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Deleted_Attachment_Ids', JSON.serialize(setDeletedAttachmentIds)));
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Deleted_CDL_Ids', JSON.serialize(setDeletedCDLIds)));
            
            if(String.isBlank(strLastIDForChkAttachment)){
                response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Checklist__c', JSON.serialize(lstAllChecklists)));
            }
        }
        else
        {
            System.debug(LoggingLevel.WARN, 'inputRequest.eventName = ' + inputRequest.eventName + ';isChecklist =  ' + isChecklist);
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries() + '; Rows Queried = ' + Limits.getQueryRows());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getCheckListData');
        return response;
    }
    public void addCallBackForChecklist(INTF_WebServicesDef.INTF_SFMResponse res, String strObjName, List<string> lstObjectLastId, List<string> lstChecklistLastId, List<string> lstChkAttachmentLastId ){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('addCallBackForChecklist');
        
        res.valueMap.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT',strObjName, lstObjectLastId));
        res.valueMap.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_CHECKLIST','SVMXC__Checklist__c', lstChecklistLastId));
        res.valueMap.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_CHK_ATTACHMENT','SVMXC__SM_Checklist_Attachment__c', lstChkAttachmentLastId));
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'addCallBackForChecklist');
    }    
    public INTF_WebServicesDef.INTF_SFMResponse  getProductAttributesTemplates(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId)
    {
        system.debug(loggingLevel.WARN, ' - Request for the Product Attribute and Templates:- ' + inputRequest);
        system.debug(loggingLevel.WARN, ' - Group Profile Id:- ' + grpProfileId);
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        response.success = true;
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
        INTF_WebServicesDef.SVMXMap callBackFromVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK_FROM', '');
        INTF_WebServicesDef.SVMXMap productCallBackVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_CALL_BACK_ID', '');
        INTF_WebServicesDef.SVMXMap productNextCallBackVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_NEXT_CALL_BACK_ID', '');   
        INTF_WebServicesDef.SVMXMap productAttrCallBackVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_ATTRIBUTE_CALL_BACK_ID', '');
        boolean isCallBack = false, isAttributeEnabled = false, isCallBackFromProduct = false, isCallBackFromProductAttr = false;
        integer queryLimitRecords = 17000;
        dateTime dtLastSyncTime;
        string productCallBackId, productAttrCallBackId, productNextCallBackId, callbackFrom;
        
        try
        {
            //Getting the setting value from the ProductIQ Configuration
            SVMXC__ProductIQProfile__c prIqProfileConfig = getProductIQConfigSettings(grpProfileId);
            if(prIqProfileConfig == null || prIqProfileConfig.SVMXC__Contents__c == null){
                response.message = 'Product IQ Profile is not valid.';
                return response;
            }
            string jsonPrIqConfig = prIqProfileConfig.SVMXC__Contents__c;
            
            system.debug('==ProductIQ configuration Profile JSON := ' + jsonPrIqConfig);
            
            ProductIQConfiguration.Profile prIqConfig = (ProductIQConfiguration.Profile)JSON.deserialize(jsonPrIqConfig, ProductIQConfiguration.Profile.Class);
            system.debug('==ProductIQ configuration Object := ' + prIqConfig);
            
            if(prIqConfig != null && prIqConfig.isTechnicalAttributesEnabled != null)
                isAttributeEnabled = boolean.valueOf(prIqConfig.isTechnicalAttributesEnabled);
            
            system.debug(loggingLevel.WARN, ' - Is Product IQ Product Attribute Enabled:- ' + isAttributeEnabled);
            if(!isAttributeEnabled)
            {
                response.message = 'Product Attribute is disbaled for this group Profile.';
                return response;
            }
            
            for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
            {
                if(eachReqParam.key == 'PRODUCTIQ_LAST_SYNC' && eachReqParam.value != null && eachReqParam.value != '')
                {
                    dtLastSyncTime = Datetime.valueOf(eachReqParam.value);
                }
                else if(eachReqParam.key == 'CALL_BACK' && eachReqParam.value == 'true')
                {
                    for(INTF_WebServicesDef.SVMXMap eachCallBackParam : eachReqParam.valueMap)
                    {
                        if(eachCallBackParam.key == 'CALL_BACK_FROM' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0)
                            callbackFrom = eachCallBackParam.value;
                        else if(eachCallBackParam.key == 'PRODUCT_CALL_BACK_ID' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0)
                            productCallBackId = eachCallBackParam.value;
                        else if(eachCallBackParam.key == 'PRODUCT_NEXT_CALL_BACK_ID' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0)
                            productNextCallBackId = eachCallBackParam.value;
                        else if(eachCallBackParam.key == 'PRODUCT_ATTRIBUTE_CALL_BACK_ID' && eachCallBackParam.value != null && eachCallBackParam.value.length() > 0)
                            productAttrCallBackId = eachCallBackParam.value;
                    }
                }
            }
            
            system.debug(LoggingLevel.Debug, ' - Request data - Callback From:- ' + callbackFrom + ' - Product Call back Id:- ' + productCallBackId + ' - Product Next Call back Id:- ' + productNextCallBackId + ' - Product AttributeCallback Id:- ' + productAttrCallBackId);
            
            Set<String> setAccessibleObjs = new Set<String>();
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            Set<String> setRequiredObjs = new Set<String>{'SVMXC__SM_Product_Attributes__c', 'SVMXC__SM_Attributes_Template__c', 'Product2'};
            allObjs = Schema.getGlobalDescribe();
                    
            for(String objName : setRequiredObjs)
            {
                try
                {
                    for(String objDesc : allObjs.keyset())
                    if(allObjs.get(objDesc).getDescribe().getName() == objName && allObjs.get(objDesc).getDescribe().isAccessible())
                        setAccessibleObjs.add(objName);
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.Debug, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }
            system.debug(LoggingLevel.WARN, 'setAccessibleObjs =  ' + setAccessibleObjs + ';setRequiredObjs = ' + setRequiredObjs);
            
            if(!setAccessibleObjs.containsAll(setRequiredObjs))
            {
                response.message = 'Object Permissions missing.';
                return response;
            }
            
            if(callbackFrom != null && callbackFrom.length() > 0)
            {
                if(callbackFrom == 'PRODUCT_ATTRIBUTE')
                {
                    if(productCallBackId == null || productNextCallBackId == null)
                        productCallBackId = null;
                }
                else if(callbackFrom == 'PRODUCT')
                {
                    if(productNextCallBackId != null && productNextCallBackId.length() > 0)
                        productCallBackId = productNextCallBackId;
                }
            }
            
            system.debug(LoggingLevel.Debug, ' - Product Call If after resolving the Callback from:- ' + productCallBackId);
            
            if(productCallBackId != null && productCallBackId.length() > 0)
            {
                productCallBackVM.value = productCallBackId;
                callBackVM.valueMap.add(productCallBackVM);
            }
            
            queryLimitRecords = getQueryRowsUsingSettings(grpProfileId)/2;
            //queryLimitRecords = 2;//for testing call back.
            
            if(queryLimitRecords <= 0)
            {
                response.message = 'Internal Error - Limit for the number of rows to be queried reached before executing query for Products. Please increase the setting IPAD018_SET011';
                return response;
            }
            
            List<string> lstFieldsForProduct = new List<string>{'id', 'Family', 'SVMXC__Product_Line__c', 'LastModifiedDate', 'isDeleted'};
                //Get Device Specific Mobile config     
            string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);     
            system.debug(LoggingLevel.WARN,' Device from Request PIQ = '+strDeviceType);        
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);       
                
            List<Product2> lstProducts = (List<Product2>)getRecordsForObjInDCnADC(grpProfileId, queryLimitRecords, productCallBackId, null, 'Product2', lstFieldsForProduct, strDevConfId);
            
            system.debug(loggingLevel.WARN, ' - List of Products downloaded from DC and ADC:- ' + lstProducts);
            
            if(lstProducts == null || lstProducts.size() == 0)
            {
                response.message = 'No Product are available as part of Download Criteria or Advanced Download Criteria, related to which the Product Attribute or Attribute Template are to be downloaded.';
                return response;
            }
            
            if(lstProducts != null && lstProducts.size() == queryLimitRecords)
            {
                isCallBack = true;
                isCallBackFromProduct = true;
                productNextCallBackVM.value = lstProducts[lstProducts.size()-1].Id;
                callBackVM.valueMap.add(productNextCallBackVM);
            }
            
            system.debug('checking for Config Update. Last sync time before config check is: ' + dtLastSyncTime);
            
            if(dtLastSyncTime != null){
                if(isConfigUpdatedDCnADC(new List<string>{'product2'}, dtLastSyncTime, grpProfileId, strDevConfId)){
                    system.debug('Config Updated and hence setting the lastsync time to null.');
                    dtLastSyncTime = null;
                }
                
                system.debug('Product IQ Last modified Datetime: ' + prIqProfileConfig.LastModifiedDate + ' : AND the Last sync time: ' + dtLastSyncTime);
                if(prIqProfileConfig.LastModifiedDate >= dtLastSyncTime)
                    dtLastSyncTime = null;
                system.debug('Last sync time after config modified datetime: ' + dtLastSyncTime);
            }
            
            system.debug('Last sync time after config check is: ' + dtLastSyncTime);
            
            system.debug(LoggingLevel.Debug, ' - Call back info after Product Query:- ' + isCallBack + ' - Call Back From Product? :- ' + isCallBackFromProduct + ' - Product Next Callback ValueMap:- ' + productNextCallBackVM);
            
            List<SVMXC__SM_Product_Attributes__c> lstProductAttributes = getProductAttributes(lstProducts, queryLimitRecords, productAttrCallBackId, dtLastSyncTime);
            
            system.debug(loggingLevel.WARN, ' - List of Products Attributes:- ' + lstProductAttributes);
            
            if(lstProductAttributes == null && lstProductAttributes.size() == 0)
            {
                response.message = 'Product Attributes are not available to downloaded.';
                return response;
            }
            
            if(lstProductAttributes != null && lstProductAttributes.size() == queryLimitRecords)
            {
                isCallBack = true;
                isCallBackFromProductAttr = true;
                productAttrCallBackVM.value = lstProductAttributes[lstProductAttributes.size()-1].Id;
                callBackVM.valueMap.add(productAttrCallBackVM);
            }
            
            system.debug(LoggingLevel.Debug, ' - Call back info after Product Attribute Query:- ' + isCallBack + ' - Call Back From Product? :- ' + isCallBackFromProductAttr + ' - Product Attribute Callback ValueMap:- ' + productAttrCallBackVM);
            
            set<string> setAttrTemplateIds = new set<string>();
            set<string> setProductAttrIds = new set<string>();
            set<string> setDeletedProductAttrIds = new set<string>();
            set<string> setDeletedAttrTemplateIds = new set<string>();
            for(SVMXC__SM_Product_Attributes__c prodAttr : lstProductAttributes)
            {
                if(prodAttr.SVMXC__SM_Product__r.IsDeleted)
                {
                    setDeletedProductAttrIds.add(prodAttr.Id);
                    setDeletedAttrTemplateIds.add(prodAttr.SVMXC__SM_Attribute_Template_Id__c);
                }else
                {
                    if(prodAttr.IsDeleted)
                        setDeletedProductAttrIds.add(prodAttr.Id);
                    else
                        setProductAttrIds.add(prodAttr.Id);
                    
                    if(prodAttr.SVMXC__SM_Attribute_Template_Id__r.IsDeleted)
                        setDeletedAttrTemplateIds.add(prodAttr.SVMXC__SM_Attribute_Template_Id__c);
                    else
                        setAttrTemplateIds.add(prodAttr.SVMXC__SM_Attribute_Template_Id__c);  
                }
            }
            
            if(isCallBackFromProductAttr)
            {
                callBackFromVM.value = 'PRODUCT_ATTRIBUTE';
                callBackVM.valueMap.add(callBackFromVM);
            }
            else if(isCallBackFromProduct)
            {
                callBackFromVM.value = 'PRODUCT';
                callBackVM.valueMap.add(callBackFromVM);
            }
            
            if(isCallBack)
                response.valueMap.add(callBackVM);
            
            system.debug(loggingLevel.WARN, ' - List of Products Attributes Ids:- ' + setProductAttrIds);
            system.debug(loggingLevel.WARN, ' - List of Attribute Templates Ids:- ' + setAttrTemplateIds);
            
            INTF_WebServicesDef.SVMXMap productAttrVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_ATTRIBUTE', '');
            productAttrVM.values.addAll(setProductAttrIds);
            response.valueMap.add(productAttrVM);
            INTF_WebServicesDef.SVMXMap attrTemplateVM = new INTF_WebServicesDef.SVMXMap('ATTRIBUTE_TEMPLATE', '');
            attrTemplateVM.values.addAll(setAttrTemplateIds);
            response.valueMap.add(attrTemplateVM);
            if(setDeletedProductAttrIds != null && setDeletedProductAttrIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap deletedProductAttrVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_ATTRIBUTE_DELETED', '');
                deletedProductAttrVM.values.addAll(setDeletedProductAttrIds);
                response.valueMap.add(deletedProductAttrVM);
            }
            if(setDeletedAttrTemplateIds != null && setDeletedAttrTemplateIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap deletedAttrTemplateVM = new INTF_WebServicesDef.SVMXMap('ATTRIBUTE_TEMPLATE_DELETED', '');
                deletedAttrTemplateVM.values.addAll(setDeletedAttrTemplateIds);
                response.valueMap.add(deletedAttrTemplateVM);
            }
            
            system.debug(loggingLevel.WARN, ' - Response prepared:- ' + response);
            
            return response;
        }catch(exception ex){
            response.success = false;
            response.message = 'Error occured while processing the Product Attributes with the message:- ' + ex.getMessage();
            return response;
        }
    }
    
    public boolean isConfigUpdatedDCnADC(list<string> lstObjNames, datetime dtLastSyncTime, Id grpProfileId, string strDevConfId){
        String strMobConfQuery  = 'select id from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Download Criteria\' OR SVMXC__Display_Type__c = \'Advanced Download Criteria\') AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND SVMXC__Object_Name__c IN: lstObjNames AND LastModifiedDate >=: dtLastSyncTime';       
        if(strDevConfId != NULL && strDevConfId != ''){     
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
        }       
        system.debug(LoggingLevel.WARN,'Query formed for isConfigUpdatedDCnADC = '+strMobConfQuery);        
                
        for(SVMXC__ServiceMax_Config_Data__c eachDCRec: Database.Query(strMobConfQuery))
        {
            return true;
        }
        return false;
    }
    
    public integer getQueryRowsUsingSettings(Id grpProfileId)
    {
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET011'}, grpProfileId);
            integer limitPercent = 70;
            if(lstSettings != null && lstSettings.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                {
                    limitPercent = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                }
            }
            Integer intQueryRowLimit = limitPercent * Limits.getLimitQueryRows()/100;
            intQueryRowLimit = intQueryRowLimit - Limits.getQueryRows();
            return intQueryRowLimit;
        //return 2;
    }
    
    public List<sObject> getRecordsForObjInDCnADC(Id grpProfileId, integer intLimitQuery, string idLastCallBackProd, dateTime dtLastSyncTime, string objToGetDCnADC, List<string> lstFieldsForObj, String strDevConfId)
    {
        Set<String> setObjNames = new Set<String>{objToGetDCnADC};
        Set<String> setMdfdWhatIds = new Set<String>();
        Set<String> setWhatIds = (new Sync_Utility()).getEventRelatedWOIDs(grpProfileId, dtLastSyncTime, new Set<String>(), setMdfdWhatIds, strDevConfId);
        Map<String, String> mapDCObjToCriteria = (new Sync_Utility()).getDownloadCriteriaForAnyObject(setObjNames, grpProfileId, dtLastSyncTime, new Set<String>(), strDevConfId);
        Map<String, String> mapADCObjToCriteria = (new Sync_Utility()).getAdvDownloadCriteriaForAnyObject(setObjNames, grpProfileId, setWhatIds, dtLastSyncTime, new Set<String>(), strDevConfId);
        string strSOQLObjDCnADC = '';//select id,Family,SVMXC__Product_Line__c,LastModifiedDate from Product2
        string strWhereClauseProduct;
        boolean getAllProductInDC = false, noCriteriaInDC = false;
        
        system.debug(loggingLevel.WARN, ' - Map Of Object and criteria in DC :- ' + mapDCObjToCriteria);
        system.debug(loggingLevel.WARN, ' - Map Of Object and criteria in ADC :- ' + mapADCObjToCriteria);
        
        if(lstFieldsForObj == null || lstFieldsForObj.size() == 0)
        {
            strSOQLObjDCnADC = 'select id from ' + objToGetDCnADC;
        }else{
            for(integer i=0; i<lstFieldsForObj.size(); i++)
            {
                if(i==0)
                    strSOQLObjDCnADC = 'select ' + lstFieldsForObj[i];
                else
                    strSOQLObjDCnADC += ',' + lstFieldsForObj[i];
            }
            strSOQLObjDCnADC += ' from ' + objToGetDCnADC;
        }
        
        system.debug(loggingLevel.WARN, ' - Query before DC n ADC :- ' + strSOQLObjDCnADC);
        
        if((mapDCObjToCriteria == null || !mapDCObjToCriteria.containsKey(objToGetDCnADC)) && (mapADCObjToCriteria == null || !mapADCObjToCriteria.containsKey(objToGetDCnADC)))
        {
            return null;
        }
        
        if(mapDCObjToCriteria != null && mapDCObjToCriteria.containsKey(objToGetDCnADC))
        {
            if(mapDCObjToCriteria.get(objToGetDCnADC) == null || mapDCObjToCriteria.get(objToGetDCnADC).length() == 0)
                noCriteriaInDC = true;
            else
                strWhereClauseProduct = ' (' + mapDCObjToCriteria.get(objToGetDCnADC) + ')';
        }
        
        system.debug(loggingLevel.WARN, ' - Where Clause after DC :- ' + strWhereClauseProduct);
        system.debug(loggingLevel.WARN, ' - No Criteria in DC ? :- ' + noCriteriaInDC);
        
        if(!noCriteriaInDC && mapADCObjToCriteria != null && mapADCObjToCriteria.size() > 0 && mapADCObjToCriteria.containsKey(objToGetDCnADC))
        {
            if(strWhereClauseProduct == null || strWhereClauseProduct.length() == 0)
                strWhereClauseProduct = ' (' + mapADCObjToCriteria.get(objToGetDCnADC) + ')';
            else
                strWhereClauseProduct += ' OR (' + mapADCObjToCriteria.get(objToGetDCnADC) + ')';
        }
        
        system.debug(loggingLevel.WARN, ' - Where Clause after ADC :- ' + strWhereClauseProduct);
        
        if(idLastCallBackProd != null && idLastCallBackProd.length() > 0)
            if(strWhereClauseProduct != null && strWhereClauseProduct.length() > 0)
                strWhereClauseProduct = '(' + strWhereClauseProduct + ') AND Id >: idLastCallBackProd ';
            else
                strWhereClauseProduct = ' Id >: idLastCallBackProd ';
                
        if(strWhereClauseProduct != null && strWhereClauseProduct.length() > 0)
            strSOQLObjDCnADC += ' where (' + strWhereClauseProduct + ')';
        
        
        /*
        
        Place holder for the Product, Product Family and Product Line criteria from the Product Iq Setup - getProductIQConfigSettings()
        
        */
        strSOQLObjDCnADC += ' Order by Id ';
        if(intLimitQuery != null && intLimitQuery > 0)
            strSOQLObjDCnADC += 'LIMIT :intLimitQuery ALL ROWS';
        else
            strSOQLObjDCnADC += 'LIMIT 5000 ALL ROWS';
        
        system.debug(loggingLevel.WARN, ' - Final SOQL Prepared for DC n ADC :- ' + strSOQLObjDCnADC);
            
        return database.query(strSOQLObjDCnADC);
    }
    
    public List<SVMXC__SM_Product_Attributes__c> getProductAttributes(List<Product2> lstProducts, integer intLimitQuery, string idLastCallProdAttr, dateTime dtLastSyncTime)
    {
        system.debug(loggingLevel.WARN, ' - Inside Get Product Attributes with Products:- ' + lstProducts + ' - Query Limit:-' + intLimitQuery + ' - Last Callback Id:- ' + idLastCallProdAttr + ' - Last Sync Time:-' + dtLastSyncTime);
        
        set<string> setProductFamily = new set<string>();
        set<string> setProductLine = new set<string>();
        set<string> setAllProductIds = new set<string>();
        set<string> setModifiedProductIds = new set<string>();
        set<string> setModifiedProductFamily = new set<string>();
        set<string> setModifiedProductLine = new set<string>();
        
        for(Product2 prodDCnADC : lstProducts)
        {
            if(dtLastSyncTime != null && prodDCnADC.LastModifiedDate > dtLastSyncTime)
                setModifiedProductIds.add(prodDCnADC.Id);
            if(prodDCnADC.Family != null && prodDCnADC.Family.length() > 0){
                setProductFamily.add(prodDCnADC.Family);
                if(dtLastSyncTime != null && prodDCnADC.LastModifiedDate > dtLastSyncTime)
                    setModifiedProductFamily.add(prodDCnADC.Family);
            }
                
            if(prodDCnADC.SVMXC__Product_Line__c != null && prodDCnADC.SVMXC__Product_Line__c.length() > 0){
                setProductLine.add(prodDCnADC.SVMXC__Product_Line__c);
                if(dtLastSyncTime != null && prodDCnADC.LastModifiedDate > dtLastSyncTime)
                    setModifiedProductLine.add(prodDCnADC.SVMXC__Product_Line__c);
            }
            
            setAllProductIds.add(prodDCnADC.Id);
        }
        
        system.debug(loggingLevel.WARN, ' - Modified Product Ids :- ' + setModifiedProductIds);
        system.debug(loggingLevel.WARN, ' - Product Family :- ' + setProductFamily);
        system.debug(loggingLevel.WARN, ' - Product Line :- ' + setProductLine);
        system.debug(loggingLevel.WARN, ' - All Product Ids :- ' + setAllProductIds);
        
        string strWhereClauseProdAttr = '', strSOQLProductAttr = 'select Id, SVMXC__SM_Attribute_Template_Id__c, SVMXC__SM_Attribute_Template_Id__r.LastModifiedDate, LastModifiedDate, IsDeleted, SVMXC__SM_Attribute_Template_Id__r.IsDeleted, SVMXC__SM_Product__r.IsDeleted from SVMXC__SM_Product_Attributes__c';
        
        if(setAllProductIds != null && setAllProductIds.size() > 0)
            strWhereClauseProdAttr += ' SVMXC__SM_Product__c IN: setAllProductIds';
        
        system.debug(loggingLevel.WARN, ' - Where Clause All Product Ids :- ' + strWhereClauseProdAttr);
        
        if(setProductFamily != null && setProductFamily.size() > 0)
        {
            if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
                strWhereClauseProdAttr += ' OR SVMXC__SM_Product_Family__c IN: setProductFamily';
            else
                strWhereClauseProdAttr = ' SVMXC__SM_Product_Family__c IN: setProductFamily';
        }
        system.debug(loggingLevel.WARN, ' - Where Clause All Product Family :- ' + strWhereClauseProdAttr);
        
        if(setProductLine != null && setProductLine.size() > 0)
        {
            if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
                strWhereClauseProdAttr += ' OR SVMXC__SM_Product_Line__c IN: setProductLine';
            else
                strWhereClauseProdAttr = ' SVMXC__SM_Product_Line__c IN: setProductLine';
        }
        system.debug(loggingLevel.WARN, ' - Where Clause All Product Line :- ' + strWhereClauseProdAttr);
        
        if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
            if(dtLastSyncTime != null)
                strWhereClauseProdAttr = '((' + strWhereClauseProdAttr + ') AND (LastModifiedDate >: dtLastSyncTime OR SVMXC__SM_Attribute_Template_Id__r.LastModifiedDate >: dtLastSyncTime))';
            else
                strWhereClauseProdAttr = '(' + strWhereClauseProdAttr + ')';
        system.debug(loggingLevel.WARN, ' - Where Clause Modified date :- ' + strWhereClauseProdAttr);
        
        if(setModifiedProductIds != null && setModifiedProductIds.size() > 0)
        {
            if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
                strWhereClauseProdAttr += ' OR (SVMXC__SM_Product__c IN: setModifiedProductIds)';
            else
                strWhereClauseProdAttr += ' (SVMXC__SM_Product__c IN: setModifiedProductIds) ';
        }
        system.debug(loggingLevel.WARN, ' - Where Clause Modified Product Ids :- ' + strWhereClauseProdAttr);
        
        if(setModifiedProductFamily != null && setModifiedProductFamily.size() > 0)
        {
            if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
                strWhereClauseProdAttr += ' OR (SVMXC__SM_Product_Family__c IN: setModifiedProductFamily)';
            else
                strWhereClauseProdAttr += ' (SVMXC__SM_Product_Family__c IN: setModifiedProductFamily) ';
        }
        system.debug(loggingLevel.WARN, ' - Where Clause Modified Product Family :- ' + strWhereClauseProdAttr);
        
        if(setModifiedProductLine != null && setModifiedProductLine.size() > 0)
        {
            if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
                strWhereClauseProdAttr += ' OR (SVMXC__SM_Product_Line__c IN: setModifiedProductLine)';
            else
                strWhereClauseProdAttr += ' (SVMXC__SM_Product_Line__c IN: setModifiedProductLine) ';
        }
        system.debug(loggingLevel.WARN, ' - Where Clause Modified Product Line :- ' + strWhereClauseProdAttr);
        
        if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
            strSOQLProductAttr += ' where (' + strWhereClauseProdAttr + ')';
        
        if(idLastCallProdAttr != null && idLastCallProdAttr.length() > 0)
        {
            if(strWhereClauseProdAttr != null && strWhereClauseProdAttr.length() > 0)
                strSOQLProductAttr += ' AND Id >: idLastCallProdAttr';
            else
                strSOQLProductAttr += ' Where Id >: idLastCallProdAttr';
        }
        
        strSOQLProductAttr += ' Order by Id ';
        if(intLimitQuery != null && intLimitQuery > 0)
            strSOQLProductAttr += ' LIMIT :intLimitQuery ALL ROWS';
        system.debug(loggingLevel.WARN, ' - Query Product Attribute Final :- ' + strSOQLProductAttr);
        
        return (List<SVMXC__SM_Product_Attributes__c>)database.query(strSOQLProductAttr);
    }
    
    public SVMXC__ProductIQProfile__c getProductIQConfigSettings(id svmxGrpProfileId)
    {
        List<SVMXC__ProductIQProfile__c> lstPrIqConfig = [SELECT Id,LastModifiedDate,SVMXC__Contents__c,SVMXC__ServiceMax_Profile__c FROM SVMXC__ProductIQProfile__c WHERE SVMXC__ServiceMax_Profile__c =:svmxGrpProfileId ORDER BY Id DESC NULLS LAST];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        system.debug('==ProductIQ configuration Profile Data := ' + lstPrIqConfig);
        
        if(lstPrIqConfig != null && lstPrIqConfig.size() > 0)
            return lstPrIqConfig[0];
        else
            return null;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse  getIBAttrTemplHistory(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId){
    INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        response.success = true;
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
        INTF_WebServicesDef.SVMXMap ibCallBackVM = new INTF_WebServicesDef.SVMXMap('IB_CALL_BACK_ID', '');
        INTF_WebServicesDef.SVMXMap ibAttrHistoryCallBackVM = new INTF_WebServicesDef.SVMXMap('IB_ATTRIBUTE_HISTORY_CALL_BACK_ID', '');
        boolean isCallBack = false, isAttributeEnabled = false;
        integer queryLimitRecords = 35000;
        dateTime dtLastSyncTime;
        string ibCallBackId, ibAttrCallBackId;
        set<string> lstTopLevelIBIds = new set<string>();
        try{
            //Getting the setting value from the ProductIQ Configuration
            
            SVMXC__ProductIQProfile__c prIqProfileConfig = getProductIQConfigSettings(grpProfileId);
            if(prIqProfileConfig == null || prIqProfileConfig.SVMXC__Contents__c == null){
                response.message = 'Product IQ Profile is not valid.';
                return response;
            }
            string jsonPrIqConfig = prIqProfileConfig.SVMXC__Contents__c;
            
            system.debug('==ProductIQ configuration Profile JSON := ' + jsonPrIqConfig);
            
            ProductIQConfiguration.Profile prIqConfig = (ProductIQConfiguration.Profile)JSON.deserialize(jsonPrIqConfig, ProductIQConfiguration.Profile.Class);
            system.debug('==ProductIQ configuration Object := ' + prIqConfig);
        
            if(prIqConfig != null && prIqConfig.isTechnicalAttributesEnabled != null)
                isAttributeEnabled = boolean.valueOf(prIqConfig.isTechnicalAttributesEnabled);
            
            if(!isAttributeEnabled)
            {
                response.message = 'IB Attribute is disbaled for this group Profile.';
                return response;
            }
            
            for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
            {
                if(eachReqParam.key == 'PRODUCTIQ_LAST_SYNC' && eachReqParam.value != null && eachReqParam.value != '')
                {
                    system.debug(LoggingLevel.WARN, 'Last Sync Time In Request before conversion: ' + eachReqParam.value);
                    dtLastSyncTime = Datetime.valueOf(eachReqParam.value);
                }
                else if(eachReqParam.key == 'CALL_BACK' && eachReqParam.value == 'true')
                {
                    for(INTF_WebServicesDef.SVMXMap eachCallBackParam : eachReqParam.valueMap)
                    {
                        if(eachCallBackParam.key == 'IB_ATTRIBUTE_HISTORY_CALL_BACK_ID' && eachCallBackParam.values != null && eachCallBackParam.values.size() > 0)
                            ibAttrCallBackId = eachCallBackParam.values[0];
                    }
                }
                else if(eachReqParam.key == 'TOP_LEVEL_IB_IDS' && eachReqParam.values != null && eachReqParam.values.size() > 0)
                {
                    lstTopLevelIBIds.addAll(eachReqParam.values);
                }
            }
            
            system.debug(LoggingLevel.WARN, 'Last Sync Time: ' + dtLastSyncTime);
            system.debug(LoggingLevel.WARN, 'Call back Id: ' + ibAttrCallBackId);
            system.debug(LoggingLevel.WARN, 'Top Level IB Ids: ' + lstTopLevelIBIds);
            
            if(lstTopLevelIBIds == null || lstTopLevelIBIds.size() == 0)
            {
                response.message = 'No Top Level IBS in the request.';
                return response;
            }
            Set<String> setAccessibleObjs = new Set<String>();
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            Set<String> setRequiredObjs = new Set<String>{'SVMXC__SM_IB_Attributes_Template_Instance__c', 'SVMXC__SM_IB_Attributes_History__c', 'SVMXC__Installed_Product__c'};
            allObjs = Schema.getGlobalDescribe();
            for(String objName : setRequiredObjs)
            {
                try
                {
                    for(String objDesc : allObjs.keyset())
                    if(allObjs.get(objDesc).getDescribe().getName() == objName && allObjs.get(objDesc).getDescribe().isAccessible())
                        setAccessibleObjs.add(objName);
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.Debug, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }
            system.debug(LoggingLevel.WARN, 'setAccessibleObjs =  ' + setAccessibleObjs + ';setRequiredObjs = ' + setRequiredObjs);
            
            if(!setAccessibleObjs.containsAll(setRequiredObjs))
            {
                response.message = 'Object Permissions missing.';
                return response;
            }
            
            queryLimitRecords = getQueryRowsUsingSettings(grpProfileId)/2;
            //For testing
            //queryLimitRecords = 1;
            
            system.debug(LoggingLevel.WARN, 'Number of record to be queried - Limit remaining: ' + queryLimitRecords);
            
            if(queryLimitRecords <= 0)
            {
                response.message = 'Internal Error - Limit for the number of rows to be queried reached before executing query for Products.';
                return response;
            }
            
            set<string> lstIBAttrIds = new set<string>();
            set<string> lstIBAttrHistoryIds = new set<string>();
            set<string> lstDeletedIBAttrIds = new set<string>();
            set<string> lstDeletedIBAttrHistoryIds = new set<string>();
            
            system.debug('Product IQ Last modified Datetime: ' + prIqProfileConfig.LastModifiedDate + ' : AND the Last sync time: ' + dtLastSyncTime);
            
            if(dtLastSyncTime != null && prIqProfileConfig.LastModifiedDate >= dtLastSyncTime)
                dtLastSyncTime = null;
            system.debug('Last sync time after config modified datetime: ' + dtLastSyncTime);
            
            List<SVMXC__SM_IB_Attributes_History__c> lstIBAttrHistory = getIBAttrHistory(lstTopLevelIBIds, queryLimitRecords, ibAttrCallBackId, dtLastSyncTime);
            
            system.debug(LoggingLevel.WARN, 'List of IB Attribute History queried: ' + lstIBAttrHistory);
            
            if(lstIBAttrHistory != null && lstIBAttrHistory.size() == queryLimitRecords)
            {
                isCallBack = true;
                ibAttrHistoryCallBackVM.values = new List<string>();
                ibAttrHistoryCallBackVM.values.add(lstIBAttrHistory[lstIBAttrHistory.size()-1].Id);
                callBackVM.valueMap.add(ibAttrHistoryCallBackVM);
            }
            
            if(lstIBAttrHistory != null && lstIBAttrHistory.size() > 0)
            {
                for(SVMXC__SM_IB_Attributes_History__c ibAttrHist: lstIBAttrHistory)
                {
                    if(ibAttrHist.IsDeleted)
                        lstDeletedIBAttrHistoryIds.add(ibAttrHist.Id);
                    else
                        lstIBAttrHistoryIds.add(ibAttrHist.Id);
                    
                    if(ibAttrHist.SVMXC__SM_Instance_Template_Id__c != null)
                        lstIBAttrIds.add(ibAttrHist.SVMXC__SM_Instance_Template_Id__c);
                }
            }
            
            INTF_WebServicesDef.SVMXMap ibAttrVM = new INTF_WebServicesDef.SVMXMap('IB_ATTRIBUTE', '');
            ibAttrVM.values.addAll(lstIBAttrIds);
            response.valueMap.add(ibAttrVM);
            INTF_WebServicesDef.SVMXMap ibAttrHistoryVM = new INTF_WebServicesDef.SVMXMap('IB_ATTRIBUTE_HISTORY', '');
            ibAttrHistoryVM.values.addAll(lstIBAttrHistoryIds);
            response.valueMap.add(ibAttrHistoryVM);
            
            if(lstTopLevelIBIds != null && lstTopLevelIBIds.size() > 0 && queryLimitRecords != null && queryLimitRecords > 0)
            {
                datetime dtHistoryNotOlderThan = system.now().addYears(-2);
                string ibAttrTemplInsSOQL = 'select id from SVMXC__SM_IB_Attributes_Template_Instance__c where ((SVMXC__SM_Installed_Product_Id__c IN: lstTopLevelIBIds OR SVMXC__SM_Installed_Product_Id__r.SVMXC__Top_Level__c IN: lstTopLevelIBIds)) AND CreatedDate >=:dtHistoryNotOlderThan AND IsDeleted = true Order by Id LIMIT :queryLimitRecords ALL ROWS';
                for(SVMXC__SM_IB_Attributes_Template_Instance__c ibTemplIns : (List<SVMXC__SM_IB_Attributes_Template_Instance__c>)database.query(ibAttrTemplInsSOQL)){
                    lstDeletedIBAttrIds.add(ibTemplIns.Id);
                }
            }
            
            
            if(lstDeletedIBAttrIds != null && lstDeletedIBAttrIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap deletedIBAttrVM = new INTF_WebServicesDef.SVMXMap('IB_ATTRIBUTE_DELETED', '');
                deletedIBAttrVM.values.addAll(lstDeletedIBAttrIds);
                response.valueMap.add(deletedIBAttrVM);
            }
            if(lstDeletedIBAttrHistoryIds != null && lstDeletedIBAttrHistoryIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap deletedIBAttrHistoryVM = new INTF_WebServicesDef.SVMXMap('IB_ATTRIBUTE_HISTORY_DELETED', '');
                deletedIBAttrHistoryVM.values.addAll(lstDeletedIBAttrHistoryIds);
                response.valueMap.add(deletedIBAttrHistoryVM);
            }
            
            if(isCallBack)
                response.valueMap.add(callBackVM);
            
            return response;
        }catch(exception ex){
            response.success = false;
            response.message = 'Error occured while processing the IB Attributes with the message:- ' + ex.getMessage();
            return response;
        }
}
    
    public List<SVMXC__SM_IB_Attributes_History__c> getIBAttrHistory(set<string> lstTopLevelIds, integer intLimitQuery, string idLastCallProdAttr, dateTime dtLastSyncTime)
    {
        system.debug(loggingLevel.WARN, ' - Inside Get IB Attributes History with Top Level IB Ids:- ' + lstTopLevelIds + ' - Query Limit:-' + intLimitQuery + ' - Last Callback Id:- ' + idLastCallProdAttr + ' - Last Sync Time:-' + dtLastSyncTime);
        
        //string strWhereClauseIbAttrHistory = '', strSOQLIbAttrHistory = 'select Id,SVMXC__SM_Instance_Template_Id__c, SVMXC__SM_Instance_Template_Id__r.LastModifiedDate, LastModifiedDate, IsDeleted, SVMXC__SM_Instance_Template_Id__r.IsDeleted, SVMXC__SM_Installed_Product_Id__r.IsDeleted, SVMXC__SM_Installed_Product_Id__r.SVMXC__Top_Level__r.IsDeleted from SVMXC__SM_IB_Attributes_History__c';
        string strWhereClauseIbAttrHistory = '', strSOQLIbAttrHistory = 'select Id,SVMXC__SM_Instance_Template_Id__c, SVMXC__SM_Instance_Template_Id__r.LastModifiedDate, LastModifiedDate, IsDeleted from SVMXC__SM_IB_Attributes_History__c';
        integer historyNotOlderThan = 2;
        
        if(lstTopLevelIds != null && lstTopLevelIds.size() > 0)
        {
            strWhereClauseIbAttrHistory += ' (SVMXC__SM_Installed_Product_Id__c IN: lstTopLevelIds OR SVMXC__SM_Installed_Product_Id__r.SVMXC__Top_Level__c IN: lstTopLevelIds)';
        }
        
        system.debug(loggingLevel.WARN, ' - Where Clause All IB:- ' + strWhereClauseIbAttrHistory);
        
        if(dtLastSyncTime != null && strWhereClauseIbAttrHistory != null && strWhereClauseIbAttrHistory.length() > 0)
            strWhereClauseIbAttrHistory += ' AND (LastModifiedDate >: dtLastSyncTime OR SVMXC__SM_Instance_Template_Id__r.LastModifiedDate >: dtLastSyncTime)';
        
        system.debug(loggingLevel.WARN, ' - Where Clause All IB Last Modified:- ' + strWhereClauseIbAttrHistory);
        
        if(lstTopLevelIds != null && lstTopLevelIds.size() > 0)
        {
            if(dtLastSyncTime != null)
            {
                if(strWhereClauseIbAttrHistory != null && strWhereClauseIbAttrHistory.length() > 0)
                    strWhereClauseIbAttrHistory = ' (' + strWhereClauseIbAttrHistory + ') OR ((SVMXC__SM_Installed_Product_Id__c IN: lstTopLevelIds AND SVMXC__SM_Installed_Product_Id__r.LastModifiedDate >: dtLastSyncTime) OR (SVMXC__SM_Installed_Product_Id__r.SVMXC__Top_Level__c IN: lstTopLevelIds AND SVMXC__SM_Installed_Product_Id__r.LastModifiedDate >: dtLastSyncTime))';
                else
                    strWhereClauseIbAttrHistory = ' ((SVMXC__SM_Installed_Product_Id__c IN: lstTopLevelIds AND SVMXC__SM_Installed_Product_Id__r.LastModifiedDate >: dtLastSyncTime) OR (SVMXC__SM_Installed_Product_Id__r.SVMXC__Top_Level__c IN: lstTopLevelIds AND SVMXC__SM_Installed_Product_Id__r.LastModifiedDate >: dtLastSyncTime))';
            }
        }   
        
        system.debug(loggingLevel.WARN, ' - Where Clause Modified IBs:- ' + strWhereClauseIbAttrHistory);
        
        if(idLastCallProdAttr != null && idLastCallProdAttr.length() > 0)
            if(strWhereClauseIbAttrHistory != null && strWhereClauseIbAttrHistory.length() > 0)
                strWhereClauseIbAttrHistory = ' (' + strWhereClauseIbAttrHistory + ') AND Id >: idLastCallProdAttr';
            else
                strWhereClauseIbAttrHistory = ' Id >: idLastCallProdAttr';
        
        /*
            Place holder to get the setting for the number of days setting from Product IQ Setup Page
        */
        
        if(historyNotOlderThan != null && historyNotOlderThan > 0)
        {
            datetime dtHistoryNotOlderThan = system.now().addYears(-historyNotOlderThan);
            
            system.debug(loggingLevel.WARN, ' - DateTime before which the IB were created:- ' + strWhereClauseIbAttrHistory);
            
            if(strWhereClauseIbAttrHistory != null && strWhereClauseIbAttrHistory.length() > 0)
                strWhereClauseIbAttrHistory = ' (' + strWhereClauseIbAttrHistory + ') AND CreatedDate >=:dtHistoryNotOlderThan';
            else
                strWhereClauseIbAttrHistory = ' CreatedDate >=:dtHistoryNotOlderThan';
        }
        
        strSOQLIbAttrHistory += ' where ' + strWhereClauseIbAttrHistory + ' Order by Id';
        if(intLimitQuery != null && intLimitQuery > 0)
            strSOQLIbAttrHistory += ' LIMIT :intLimitQuery ALL ROWS';
        
        system.debug(loggingLevel.WARN, ' - Query Prepared for IB attribute Template Instance final:- ' + strSOQLIbAttrHistory);
        
        return (List<SVMXC__SM_IB_Attributes_History__c>)database.query(strSOQLIbAttrHistory);
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getAttachments(INTF_WebServicesDef.INTF_SFMRequest inputRequest, String svmxGrpProfileId)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Map<String, String> mapErrorMessage = new Map<String, String>();
        try
        {
            Boolean isAttachment = false, modifiedRecords = false;
            DateTime dtLastSyncTime = null, dtPIQLastModfdDate;
            map<String, List<String>> mapObjToIds = new map<String, List<String>>();
            Integer intLimit = 10000, intLimitRelationshipFields = 35, intMaxAttachmentSize = 25;
            String strFileTypes = '', strTimeClause = '', strIDClause = '', strFileTypeClause = '', strFileSizeClause = '';
            set<String> setRefObjToSkip = new set<String>{'PARTNERNETWORKCONNECTION', 'USER', 'FEEDPOST', 'SOLUTION'};
            
            String strPIQProfileQry = 'SELECT Id, LastModifiedDate, SVMXC__Contents__c FROM SVMXC__ProductIQProfile__c WHERE SVMXC__ServiceMax_Profile__c =:svmxGrpProfileId ';
            List<sObject> lstPIQProfile = Database.query(strPIQProfileQry);
            
            if(lstPIQProfile != null && lstPIQProfile.size() > 0)
            {
                dtPIQLastModfdDate = DateTime.valueOf(lstPIQProfile[0].get('LastModifiedDate'));
                ProductIQConfiguration.Profile prof = (ProductIQConfiguration.Profile)JSON.deserialize(String.valueOf(lstPIQProfile[0].get('SVMXC__Contents__c')), ProductIQConfiguration.Profile.class);
                if(prof.attachment != null && prof.attachment.size() > 0){
                    ProductIQConfiguration.AttachmentConfig ObjAttchPIQ = prof.attachment[0];
                    if(ObjAttchPIQ.isAttachmentsEnabled != null)
                        isAttachment = Boolean.valueOf(ObjAttchPIQ.isAttachmentsEnabled);
                    
                    strFileTypes = ObjAttchPIQ.fileTypes;
                    if(strFileTypes != null && strFileTypes != '' && strFileTypes.length() > 0){
                        String strFileTypeInnerClause = '';
                        for(String eachType : strFileTypes.remove('.').split(',')){
                            if(strFileTypeInnerClause != '')
                                strFileTypeInnerClause += ' OR ';
                            strFileTypeInnerClause += ' Name like \'%.' + eachType + '\'';
                        }
                        strFileTypeClause += 'AND (' + strFileTypeInnerClause + ') ';
                    }
                    if(ObjAttchPIQ.maximumFileSize != null && ObjAttchPIQ.maximumFileSize != ''){
                        intMaxAttachmentSize = Integer.valueOf(ObjAttchPIQ.maximumFileSize);
                        intMaxAttachmentSize = intMaxAttachmentSize * 1024 * 1024;
                        strFileSizeClause = ' AND BodyLength <=:intMaxAttachmentSize ';
                    }
                }
            }
            system.debug(LoggingLevel.WARN, 'isAttachment = ' + isAttachment + '; strFileTypes = ' + strFileTypes + '; intMaxAttachmentSize = ' + intMaxAttachmentSize);
            if(isAttachment){   
                for(INTF_WebServicesDef.SVMXMap eachObjMap : inputRequest.valueMap)
                {                                   
                    if(eachObjMap.key == 'LAST_SYNC_TIME' && eachObjMap.value != null && eachObjMap.value != '')
                    {
                        dtLastSyncTime = Datetime.valueOf(eachObjMap.value);
                        system.debug(LoggingLevel.WARN, 'dtLastSyncTime = ' + dtLastSyncTime + '; dtPIQLastModfdDate = ' + dtPIQLastModfdDate);
                        if(dtPIQLastModfdDate <= dtLastSyncTime)
                            strTimeClause = ' AND LastModifiedDate >:dtLastSyncTime ';
                    }
                    else if(eachObjMap.key == 'TX_OBJECT' && eachObjMap.value != null && eachObjMap.value != '')
                    {
                        if(!mapObjToIds.containsKey(eachObjMap.value))
                        {
                            List<String> lstIds = new List<String>();
                            lstIds.addAll(eachObjMap.values);
                            mapObjToIds.put(eachObjMap.value, lstIds);
                        }
                        else
                            mapObjToIds.get(eachObjMap.value).addAll(eachObjMap.values);    
                    }
                    else if(eachObjMap.key == 'PARTIAL_EXECUTED_OBJECT' && eachObjMap.value != null && eachObjMap.value != '' && eachObjMap.values != null && eachObjMap.values.size() > 0)
                    {
                        String strLastId = eachObjMap.values[0];
                        strIDClause = ' AND ID >:strLastId ';
                        system.debug(LoggingLevel.WARN, 'strLastId = ' + strLastId);
                    }
                    else if(eachObjMap.key == 'MODIFIED_OBJECT' && eachObjMap.value != null && eachObjMap.value != '')
                    {
                            modifiedRecords = true;
                            if(!mapObjToIds.containsKey(eachObjMap.value))
                        {
                            List<String> lstIds = new List<String>();
                            lstIds.addAll(eachObjMap.values);
                            mapObjToIds.put(eachObjMap.value, lstIds);
                        }
                        else
                            mapObjToIds.get(eachObjMap.value).addAll(eachObjMap.values); 
                    }
                }
                
                if(modifiedRecords){
                        strTimeClause = '';
                }
                
                system.debug(LoggingLevel.WARN, 'strFileTypeClause = ' + strFileTypeClause + '; strFileSizeClause = ' + strFileSizeClause  +'; strTimeClause = ' + strTimeClause + ';strIDClause = ' + strIDClause + ';modifiedRecords = ' + modifiedRecords);
                
                List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getSettings(null, null, new set<string>{'IPAD018_SET004', 'IPAD018_SET006', 'IPAD018_SET013'}, svmxGrpProfileId);
                for(SVMXC__ServiceMax_Config_Data__c eachSett : lstSettings)
                {
                    if(eachSett.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET004' && eachSett.SVMXC__Internal_Value__c != null && eachSett.SVMXC__Internal_Value__c != '')
                    {
                        setRefObjToSkip.clear();
                        setRefObjToSkip = new Set<String>();
                        list<String> lstValue = new list<String>();
                        lstValue = eachSett.SVMXC__Internal_Value__c.split(',');
                        if(lstValue.size() > 0)
                        {
                            for(Integer i = 0; i < lstValue.size(); i++)
                                setRefObjToSkip.add(lstValue[i].toUpperCase());
                        }
                    }
                    else if(eachSett.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET006' && eachSett.SVMXC__Internal_Value__c != null && eachSett.SVMXC__Internal_Value__c != '')
                        intLimit = integer.valueOf(eachSett.SVMXC__Internal_Value__c);
                    
                    else if(eachSett.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET013' && eachSett.SVMXC__Internal_Value__c != null && eachSett.SVMXC__Internal_Value__c != '')
                        intLimitRelationshipFields = integer.valueOf(eachSett.SVMXC__Internal_Value__c);
        
                    system.debug(LoggingLevel.WARN,'setRefObjToSkip = ' + setRefObjToSkip + '; intLimitRelationshipFields = ' + intLimitRelationshipFields);
                }
                
                List<String> lstFieldNames = new List<String>();
                
                INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                clsObjectDefinition.objectName = 'Attachment';
                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition(); 
                if(objDef != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                    {
                        if(objProp.key=='FIELDPROPERTY')
                        {
                            Integer refFieldCount = 0;
                            for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                            {
                                if(lstField.value == 'Body')
                                    system.debug(LoggingLevel.WARN, 'Attachment Object - do not query Body field');
                                else
                                    lstFieldNames.add(lstField.value);
                                    
                                if(refFieldCount == intLimitRelationshipFields)
                                    continue;
                                    
                                String strReferenceTo = GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                                
                                if(strReferenceTo != null)
                                {
                                    String strRelationshipName = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                                    if(strReferenceTo == 'Case')
                                    {
                                        lstFieldNames.add(strRelationshipName + '.CaseNumber');
                                        refFieldCount++;
                                    }
                                    else if (setRefObjToSkip.contains(strReferenceTo.toUpperCase()) || strRelationshipName == null)
                                        continue;
                                    else
                                    {
                                        lstFieldNames.add(strRelationshipName + '.Name');
                                        refFieldCount++;
                                    }
                                }
                            }
                        }
                    }
                }
                
                lstFieldNames = (new COMM_Utils_V2()).checkDuplicateFields(lstFieldNames, 'Attachment'); //Remove duplicate API Fields
                String strFldNames =  clsObjectDefinition.getObjectFieldNames(lstFieldNames);
                List<INTF_WebServicesDef.SVMXMap> lstValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
                
                if(dtLastSyncTime != NULL && inputRequest.EventName == 'SYNC_PIQ_ATTACHMENTS' && !modifiedRecords){
                    
                     //get all the delta attachments related to IB and location for PIQ
                    for(String eachObject : mapObjToIds.KeySet()){
                        system.debug('Query is = '+'Select ' + strFldNames + ' FROM Attachment where Parent.Type = :eachObject ' + strFileTypeClause + strFileSizeClause + strTimeClause + strIDClause + ' Order By Id limit ' + intLimit);
                        List<Sobject> lstsObjects = Database.query('Select ' + strFldNames + ' FROM Attachment where Parent.Type = :eachObject ' + strFileTypeClause + strFileSizeClause + strTimeClause + strIDClause + ' Order By Id limit ' + intLimit);
                        system.debug(LoggingLevel.WARN, 'Result of the query is = '+ lstsObjects);
                        intLimit -= lstsObjects.size();       
                        lstValueMaps.add(new INTF_WebServicesDef.SVMXMap(eachObject, JSON.serialize(lstsObjects))); 
                        system.debug(LoggingLevel.WARN, 'Heap size after querying records = ' + Limits.getHeapSize() + '; intLimit = ' + intLimit);
                        
                         if(intLimit <= 0){
                            lstValueMaps.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObject, new List<String>{lstsObjects[lstsObjects.size() - 1].Id}));
                            break;
                         }
                         
                        if(eachObject != NULL)
                        {
                            INTF_WebServicesDef.SVMXMap objSafeToDelete = new INTF_WebServicesDef.SVMXMap();
                            objSafeToDelete.key = 'SAFE_TO_DELETE';
                            List<Attachment> lstDeletedRecords =  Database.query('Select Id, isDeleted FROM Attachment where Parent.Type = :eachObject and isDeleted = true ' + strTimeClause +' ALL ROWS');
                            system.debug(LoggingLevel.WARN, 'Total deleted attachment Ids during Sync are = ' + lstDeletedRecords.size());
                            objSafeToDelete.valueMap.add(new INTF_WebServicesDef.SVMXMap(eachObject,JSON.serialize(lstDeletedRecords)));
                            lstValueMaps.add(objSafeToDelete);
                        }
                    }
                    response.valueMap = lstValueMaps;
                
                }else{
                    
                    for(String eachObject : mapObjToIds.keySet())
                    {
                        List<String> SFIDList = mapObjToIds.get(eachObject);
                        system.debug(LoggingLevel.WARN, 'Retrieving Attachments for ' + SFIDList.size() + ' Ids of Object ' + eachObject + '; Heap size before retrieving records = ' + Limits.getHeapSize());
                        system.debug(LoggingLevel.WARN,'***Attachment query is - Select ' + strFldNames + ' FROM Attachment where ParentId IN :SFIDList ' + strFileTypeClause + strFileSizeClause + strTimeClause + strIDClause + ' Order By Id limit ' + intLimit);
                        List<Sobject> lstsObjects = Database.query('Select ' + strFldNames + ' FROM Attachment where ParentId IN :SFIDList ' + strFileTypeClause + strFileSizeClause + strTimeClause + strIDClause + ' Order By Id limit ' + intLimit);
                        system.debug(LoggingLevel.WARN, 'Result of the query is = '+ lstsObjects);
                        intLimit -= lstsObjects.size();
                        lstValueMaps.add(new INTF_WebServicesDef.SVMXMap(eachObject, JSON.serialize(lstsObjects)));
                        system.debug(LoggingLevel.WARN, 'Heap size after querying records = ' + Limits.getHeapSize() + '; intLimit = ' + intLimit);
                                
                        if(intLimit <= 0)
                        {
                            lstValueMaps.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObject, new List<String>{lstsObjects[lstsObjects.size() - 1].Id}));
                            break;
                        }
                        
                        if(SFIDList.size() > 0)
                        {
                            INTF_WebServicesDef.SVMXMap objSafeToDelete = new INTF_WebServicesDef.SVMXMap();
                            objSafeToDelete.key = 'SAFE_TO_DELETE';
                            system.debug(LoggingLevel.WARN, 'Attachments not queried for these Ids ' + SFIDList  + ' for object = ' + eachObject);
                            List<sObject> lstDeletedRecords =  Database.query('Select Id, isDeleted FROM Attachment WHERE ParentId IN :SFIDList and isDeleted = true ALL ROWS');
                            system.debug(LoggingLevel.WARN, 'Total deleted Attachment Ids during Sync are = ' + lstDeletedRecords.size());
                            objSafeToDelete.valueMap.add(new INTF_WebServicesDef.SVMXMap(eachObject,JSON.serialize(lstDeletedRecords)));
                            lstValueMaps.add(objSafeToDelete);
                        }
                    }
                    response.valueMap = lstValueMaps;
                }
            }
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, 'Exception = ' + e.getMessage());
            SmaxException customException = new SmaxException(mapErrorMessage, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse  getPIQAttributesTemplates(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId){
    
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        
        boolean isPIQEnabled = false;
        boolean isTechAttributeEnabled = false;
        Integer intLimit = 10000, intProductLimit = 5000, intAttributeLimit = 5000;
        
        try{
    
            //Get the setting values
            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getSettings(new Set<String>(),new Set<String>(),new set<String>{'PRODIQ002_SET001','IPAD018_SET006'},grpProfileId);
            if(lstSettings != NULL && lstSettings.size() > 0 ){
                for(SVMXC__ServiceMax_Config_Data__c eachSetting : lstSettings){
                    if(eachSetting.SVMXC__Setting_Unique_ID__c == 'PRODIQ002_SET001' && eachSetting.SVMXC__Internal_Value__c != NULL && eachSetting.SVMXC__Internal_Value__c != ''){
                        isPIQEnabled = Boolean.valueOf(eachSetting.SVMXC__Internal_Value__c);
                    }else if(eachSetting.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET006' && eachSetting.SVMXC__Internal_Value__c != NULL && eachSetting.SVMXC__Internal_Value__c != ''){
                        intLimit = Integer.valueOf(eachSetting.SVMXC__Internal_Value__c);
                    }
                }
            }
            
            intProductLimit = intLimit/2;
            intAttributeLimit = intLimit/2;
            
            if(!isPIQEnabled){   
                response.message = 'Product IQ not enabled for this profile.';
                return response;
            }
        
            SVMXC__ProductIQProfile__c piqProfileConfig = getProductIQConfigSettings(grpProfileId);
            if(piqProfileConfig == NULL || piqProfileConfig.SVMXC__Contents__c == NULL){
                response.message = 'Product IQ Profile is not valid.';
                return response;
            }
        
            ProductIQConfiguration.Profile productIQContents = (ProductIQConfiguration.Profile)JSON.deserialize(piqProfileConfig.SVMXC__Contents__c, ProductIQConfiguration.Profile.Class);
            if(productIQContents != null && productIQContents.isTechnicalAttributesEnabled != null){
                isTechAttributeEnabled = boolean.valueOf(productIQContents.isTechnicalAttributesEnabled);
            }
        
            if(!isTechAttributeEnabled) {
                response.message = 'Product Attribute is disabled for this group Profile.';
                return response;
            }
            
            //check if the objects are accessible
            Set<String> setRequiredObjs = new Set<String>{'SVMXC__SM_Product_Attributes__c', 'SVMXC__SM_Attributes_Template__c', 'Product2'};
            Set<String> setAccessibleObjs = new Set<String>();
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            allObjs = Schema.getGlobalDescribe();
            
            for(String objName : setRequiredObjs){
                try{
                    if(allObjs.get(objName.toLowerCase()).getDescribe().isAccessible()){
                        setAccessibleObjs.add(objName);
                    }
                }catch(Exception Ex){
                    system.debug(LoggingLevel.WARN, 'Exception while describing Objects  '+objName+' : '+ex.getMessage());
                }
            }
            
            if(!setAccessibleObjs.containsAll(setRequiredObjs)){
                response.message = 'Object Permissions missing.';
                return response;
            }
            
            //parsing the request
            String ObjName = NULL;
            List<Id> lstProductIds = new List<Id>();
            DateTime dtLastSyncTime = null, dtPIQLastModfdDate;
            String strProductLastId = NULL, strAttributeLastId = NULL; 
            
            String strProdLastIdClause = '', strProdAttributeLastIdClause = '' ;
                        
            for(INTF_WebServicesDef.SVMXMap eachObjMap : inputRequest.valueMap){
                if(eachObjMap.Key == 'Object_Name'){
                    if(eachObjMap.value != NULL && eachObjMap.value != ''){
                        ObjName = eachObjMap.value;
                    }
                    if(eachObjMap.values != NULL && !eachObjMap.values.isEmpty()){
                        lstProductIds = eachObjMap.values; 
                    }
                }else if(eachObjMap.Key == 'LAST_SYNC_TIME' && eachObjMap.value != NULL && eachObjMap.value != ''){
                    dtLastSyncTime = Datetime.valueOf(eachObjMap.value);
                }else if(eachObjMap.Key == 'PRODUCT_LASTID' && eachObjMap.value != NULL && eachObjMap.value != ''){
                    strProductLastId = eachObjMap.value;
                    strProdLastIdClause = ' AND ID > \''+ strProductLastId + '\'';
                }else if(eachObjMap.Key == 'PRODUCTATTR_LASTID' && eachObjMap.value != NULL && eachObjMap.value != ''){
                    strAttributeLastId = eachObjMap.value;
                    strProdAttributeLastIdClause = ' AND ID > \''+strAttributeLastId+'\' ';
                }
            }
            
            if(lstProductIds.isEmpty()){
                response.message = 'No Product Id provided in the request related to which the Product Attribute or Attribute Template are to be downloaded.';
                return response;
            }
            
            string strProductQuery = 'select id,Family,SVMXC__Product_Line__c,LastModifiedDate from '+ObjName+' where ID IN: lstProductIds ';
            string strProdOrderByClause = ' ORDER BY ID LIMIT : intProductLimit';
            
            List<Product2> lstProducts = Database.query(strProductQuery + strProdLastIdClause + strProdOrderByClause);
                
            if(lstProducts == null || lstProducts.size() == 0)
            {
                response.message = 'No Product is available related to which the Product Attribute or Attribute Template are to be downloaded.';
                return response;
            }  
            
            intProductLimit -=  lstProducts.size(); 
            
            //if PIQ profile has been modified, do not consider Last Sync time
            if(dtLastSyncTime != null){
                if(piqProfileConfig.LastModifiedDate >= dtLastSyncTime){
                    dtLastSyncTime = null;
                }
            }
            
            set<Id> setModProductsIds = new Set<Id>();
            //Get Device specific mobile config     
            string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);     
            system.debug(LoggingLevel.WARN,' Device from Request PIQ template = '+strDeviceType);       
                
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);            
            //During incremental sync, check if these products were newly downloaded as a part of DC/ADC
            if(dtLastSyncTime != NULL){
                setModProductsIds = getProductsFromDCnADC(grpProfileId, dtLastSyncTime, lstProducts, strDevConfId);
            }
            system.debug(LoggingLevel.WARN, 'setModProductsIds = '+setModProductsIds);
             
            Set<string> setModifiedProductIds = new Set<String>();
            Set<string> setModifiedProductLine = new Set<string>();
            Set<string> setModifiedProductFamily = new Set<string>();
            Set<string> setProductFamily = new Set<string>();
            Set<string> setProductLine = new Set<string>();
            Set<string> setAllProductIds = new Set<string>();
            
            for(Product2 prod : lstProducts){
                if((!setModProductsIds.isEmpty() && setModProductsIds.contains(prod.Id)) || (dtLastSyncTime != NULL && prod.LastModifiedDate > dtLastSyncTime)){
                    //this prod was newly downloaded as part of DC/ADC OR Was modified after last sync time
                    setModifiedProductIds.add(prod.Id);
                    if(prod.Family != NULL && prod.Family.length()>0){
                        setModifiedProductFamily.add(prod.Family);
                    }
                    if(prod.SVMXC__Product_Line__c != NULL && prod.SVMXC__Product_Line__c.length()>0){
                        setModifiedProductLine.add(prod.SVMXC__Product_Line__c);
                    }
                }else{  
                    if(prod.Family != NULL && prod.Family.length()>0){
                        setProductFamily.add(prod.Family);
                    }
                    if(prod.SVMXC__Product_Line__c != NULL && prod.SVMXC__Product_Line__c.length()>0){
                        setProductLine.add(prod.SVMXC__Product_Line__c);
                    }
                    setAllProductIds.add(prod.Id);
                }
            }
            
            string strWhereClauseProdAttr = '', strSOQLProductAttr = 'select Id, SVMXC__SM_Attribute_Template_Id__c, SVMXC__SM_Attribute_Template_Id__r.LastModifiedDate, LastModifiedDate, IsDeleted, SVMXC__SM_Attribute_Template_Id__r.SVMXC__SM_Picklist_Id__c from SVMXC__SM_Product_Attributes__c';
            String strAttributeOrderByClause = ' ORDER BY ID LIMIT :intAttributeLimit ALL ROWS';
            
            //if the product Attribute or template has not been modified
            if(!setAllProductIds.isEmpty()){
                strWhereClauseProdAttr = ' SVMXC__SM_Product__c IN: setAllProductIds ';
            }
            
            if(!setProductFamily.isEmpty()){
                if(strWhereClauseProdAttr.length() > 0){
                    strWhereClauseProdAttr += ' OR SVMXC__SM_Product_Family__c IN: setProductFamily ';
                }else{
                    strWhereClauseProdAttr = ' SVMXC__SM_Product_Family__c IN: setProductFamily ';
                }
            }
            
            if(!setProductLine.isEmpty()){
                if(strWhereClauseProdAttr.length() > 0){
                    strWhereClauseProdAttr += ' OR SVMXC__SM_Product_Line__c IN: setProductLine ';
                }else{
                    strWhereClauseProdAttr = ' SVMXC__SM_Product_Line__c IN: setProductLine ';
                }
            }
            
            if(strWhereClauseProdAttr.length() > 0){
                if(dtLastSyncTime != NULL){
                    strWhereClauseProdAttr = '((' + strWhereClauseProdAttr + ') AND ( LastModifiedDate >: dtLastSyncTime OR SVMXC__SM_Attribute_Template_Id__r.LastModifiedDate >: dtLastSyncTime) )';
                }
            }
            
            //Clause for modified products
            if(!setModifiedProductIds.isEmpty()){
                if(strWhereClauseProdAttr.length() > 0){
                    strWhereClauseProdAttr += ' OR SVMXC__SM_Product__c IN: setModifiedProductIds';
                }else{
                    strWhereClauseProdAttr = ' SVMXC__SM_Product__c IN: setModifiedProductIds';
                }
            }
            
            if(!setModifiedProductFamily.isEmpty()){
                if(strWhereClauseProdAttr.length() > 0){
                    strWhereClauseProdAttr += ' OR SVMXC__SM_Product_Family__c IN: setModifiedProductFamily';
                }else{
                    strWhereClauseProdAttr = ' SVMXC__SM_Product_Family__c IN: setModifiedProductFamily';
                }
            }
            
            if(!setModifiedProductLine.isEmpty()){
                if(strWhereClauseProdAttr.length() > 0){
                    strWhereClauseProdAttr += ' OR SVMXC__SM_Product_Line__c IN: setModifiedProductLine';
                }else{
                    strWhereClauseProdAttr = ' SVMXC__SM_Product_Line__c IN: setModifiedProductLine';
                }
            }
            
            if(strWhereClauseProdAttr.length() > 0){
                strSOQLProductAttr += ' where ('+strWhereClauseProdAttr+' )' ;
            }
            
            List<SVMXC__SM_Product_Attributes__c> lstProductAttributes = database.query(strSOQLProductAttr + strProdAttributeLastIdClause +strAttributeOrderByClause);
            System.debug(LoggingLeveL.DEBUG,'query '+strSOQLProductAttr + strProdAttributeLastIdClause +strAttributeOrderByClause);
            System.debug(LoggingLeveL.DEBUG,'Product Attribute= '+lstProductAttributes);
            if(lstProductAttributes == null && lstProductAttributes.size() == 0)
            {
                response.message = 'Product Attributes are not available to be downloaded.';
                return response;
            }
            
            intAttributeLimit -=  lstProductAttributes.size(); 
            
            if(intAttributeLimit <= 0){
            
                //There are more attributes to be processed - set PRODUCTATTR_LASTID and reset PRODUCT_LASTID to previous value
                INTF_WebServicesDef.SVMXMap productCallBackVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_LASTID', strProductLastId );
                response.valueMap.add(productCallBackVM);
                
                INTF_WebServicesDef.SVMXMap productAttrCallBackVM = new INTF_WebServicesDef.SVMXMap('PRODUCTATTR_LASTID', lstProductAttributes[lstProductAttributes.size()-1].Id);
                response.valueMap.add(productAttrCallBackVM);
                
            }else if(intProductLimit <= 0){
            
                //There are more products to be processed - set Product_LastID
                INTF_WebServicesDef.SVMXMap productCallBackVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_LASTID', lstProducts[lstProducts.size()-1].Id );
                response.valueMap.add(productCallBackVM);
            }
            
            set<string> setAttrTemplateIds = new set<string>();
            set<string> setProductAttrIds = new set<string>();
            set<string> setDeletedProductAttrIds = new set<string>();
            
            for(SVMXC__SM_Product_Attributes__c prodAttr : lstProductAttributes){
                
                if(prodAttr.isDeleted){
                    setDeletedProductAttrIds.add(prodAttr.Id);  
                }else{
                    setProductAttrIds.add(prodAttr.Id);
                }
                 
                if(prodAttr.SVMXC__SM_Attribute_Template_Id__c != NULL){  
                    setAttrTemplateIds.add(prodAttr.SVMXC__SM_Attribute_Template_Id__c);
                }
            }
            
            INTF_WebServicesDef.SVMXMap productAttrVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_ATTRIBUTE', json.serialize(setProductAttrIds));
            response.valueMap.add(productAttrVM);
            
            INTF_WebServicesDef.SVMXMap productAttrTemplateVM = new INTF_WebServicesDef.SVMXMap('ATTRIBUTE_TEMPLATE', json.serialize(setAttrTemplateIds));
            response.valueMap.add(productAttrTemplateVM);
            
            if(!setDeletedProductAttrIds.isEmpty()){
                INTF_WebServicesDef.SVMXMap deletedProductAttrVM = new INTF_WebServicesDef.SVMXMap('PRODUCT_ATTRIBUTE_DELETED', json.serialize(setDeletedProductAttrIds));
                response.valueMap.add(deletedProductAttrVM);
            }
            
            response.eventName = inputRequest.eventName;
            response.eventType = inputRequest.eventType;
            response.success = true;  
            
            system.debug(loggingLevel.WARN, ' - Response prepared:- ' + response);
            
            return response;
        
        }catch(exception ex){
            response.success = false;
            response.message = 'Error occured while processing the Product Attributes and Templates:- ' + ex.getMessage();
            return response;
        }

    }
    
    public Set<Id> getProductsFromDCnADC(Id grpProfileId, DateTime dtLastSyncTime, List<Product2> lstProducts, String strDevConfId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductsFromDCnADC');
        
        Set<Id> setModifiedProdIds = new Set<Id>();
        
        String strDCnADCClause = getModifiedDCnADCCriteriaForProducts(grpProfileId,dtLastSyncTime, strDevConfId);
        
        if(strDCnADCClause != ''){
            String strSOQL = 'Select Id from Product2 where ID IN: lstProducts ';
            strSOQL += ' AND ( '+ strDCnADCClause+ ' )';
            
            system.debug(loggingLevel.WARN,'++++ strSOQL = '+strSOQL);
            List<Product2> lstModifiedProducts = database.query(strSOQL);  //Query products that are a part of DC/ADC
        
            if(lstModifiedProducts != NULL && !lstModifiedProducts.isEmpty()){
                for( Product2 pr : lstModifiedProducts){
                    setModifiedProdIds.add(pr.Id);
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getProductsFromDCnADC');
        return setModifiedProdIds;
    }
    
    public String getModifiedDCnADCCriteriaForProducts( Id grpProfileId, DateTime dtLastSyncTime, String strDevConfId){
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getModifiedDCnADCCriteriaForProducts');
        
        String modifiedDCnADCCriteria = '';
        String strDCCriteria = '';
        String strADCCriteria = '';
        string strCurrTechLocId = '';
        
        INTF_DataSync.logSOQL(intMethodCount , 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true AND SVMXC__Inventory_Location__c != null AND SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true AND SVMXC__Inventory_Location__c != null AND SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        String strMobConfQuery  = 'select Id,SVMXC__Display_Type__c, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND SVMXC__Object_Name__c = \'Product2\' AND (LastModifiedDate >: dtLastSyncTime OR SVMXC__Dispatch_Process__r.LastModifiedDate >: dtLastSyncTime) AND ( SVMXC__Display_Type__c = \'Download Criteria\' OR SVMXC__Display_Type__c = \'Advanced Download Criteria\') ';        
        if(strDevConfId != NULL && strDevConfId != ''){     
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';       
        }       
        system.debug(LoggingLevel.WARN,'Query formed for getModifiedDCnADCCriteriaForProducts = '+strMobConfQuery);        
        //Query DC and ADC records
         List<SVMXC__ServiceMax_Config_Data__c> lstDCSetting = Database.Query(strMobConfQuery);
        
        //If there was no modified DC/ADC return null
        if(lstDCSetting == NULL || lstDCSetting.isEmpty()){
            INTF_DataSync.logMethodEndTS(intMethodCount,'getModifiedDCnADCCriteriaForProducts');
            return modifiedDCnADCCriteria;
        }
        
        Set<String> setWhatIds = (new Sync_Utility()).getEventRelatedWOIDs(grpProfileId, dtLastSyncTime, new Set<String>(), new Set<String>(), strDevConfId);
        
        for(SVMXC__ServiceMax_Config_Data__c configData : lstDCSetting){
            
            if(configData.SVMXC__Display_Type__c == 'Download Criteria'){
            
                if(configData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null)
                    strDCCriteria = configData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c;
            
                if(configData.SVMXC__Ownership_Type__c == 'My Records'){
                    if(strDCCriteria != ''){
                        strDCCriteria = ' ( ' + strDCCriteria + ' ) AND ';
                    }
                    strDCCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                }
                
                strDCCriteria = strDCCriteria.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());    
                strDCCriteria = strDCCriteria.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                strDCCriteria = strDCCriteria.replace('SVMX.USERTRUNK', strCurrTechLocId);
                
            }
            
            if(configData.SVMXC__Object_Name__c != null && configData.SVMXC__Display_Type__c == 'Advanced Download Criteria')
            {
                if(configData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && configData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                {
                    strADCCriteria = '((' + configData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                    
                    INTF_DataSync.logSOQL(intMethodCount , 'select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: configData.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC');
                    for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: configData.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC])
                    {
                        String strObjNameAndField = '';
                        if( ((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null))
                        {
                            String strReferenceFieldIds = '';
                            strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                    
                            INTF_DataSync.logSOQL(intMethodCount ,'Select ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds');
                            for(sobject sObj : Database.query('Select ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds'))
                            {
                                if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                {
                                     if(strReferenceFieldIds != '')
                                         strReferenceFieldIds += ',';
                                     strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                }     
                            }
                    
                            if(strReferenceFieldIds == '')
                                strReferenceFieldIds = '\'DummyListOfIds1\''; 
                         
                            strADCCriteria = strADCCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                        }else {
                            //criteria exists in variable strADCCriteria.
                        }
                    }
                }
                if(configData.SVMXC__Ownership_Type__c == 'My Records'){
                    if(strADCCriteria != '')
                        strADCCriteria = ' ( ' + strADCCriteria + ' ) and ';
                    else
                        strADCCriteria += '(';
                     strADCCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';  
                }
                strADCCriteria += ')';
            }
        }
        
        if(strDCCriteria != ''){
            modifiedDCnADCCriteria = '( '+strDCCriteria+')';
        }
        if(strADCCriteria != ''){
            if(modifiedDCnADCCriteria != ''){
                modifiedDCnADCCriteria += ' OR ';
            }
            modifiedDCnADCCriteria += strADCCriteria;
        }
        
        INTF_DataSync.logMethodEndTS(intMethodCount,'getModifiedDCnADCCriteriaForProducts');
        return modifiedDCnADCCriteria;
    }
    //This is to retrieve Trunk Stock data (Product, Product Stock and Stocked Serial based on configuration) in the Initial Sync, Data Sync .          
    public INTF_WebServicesDef.INTF_SFMResponse getTrunkStock(INTF_WebServicesDef.INTF_SFMRequest request,String groupProfileId)        
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getTrunkStock');                    
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        response.eventName = request.eventName;
        response.eventType=request.eventType;
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        Integer intLimit =10000;
        Integer stockLimit = 3000;
        String serialStockLastId='';
        String stockLastId='';
        String lastSyncTimeClause ='';
        String lastSyncTimeClauseforFile = '';
        Datetime lastModifiedDateTime=NULL;
        List<String> listOfStatuses = new List<String>();
        List<String> listOfIncludeStatus = new List<String>();
        String callBackStockId='';
        String productFileField='';
        Boolean isServicemaxFileEnabled = COMM_FileHandlerUtilities.checkFileSetting();
                
        //Reading Mobile Inventory Configuration         
        INTF_DataSync.logSOQL(intMethodCount , 'Select SVMXC__SM_Content__c,lastModifiedDate From SVMXC__SM_Inventory_Config__c Where SVMXC__SM_ServiceMax_Profile__c =:groupProfileId Limit 1');                                
        List<SVMXC__SM_Inventory_Config__c> listOfConfigs = [Select SVMXC__SM_Content__c,lastModifiedDate From SVMXC__SM_Inventory_Config__c Where SVMXC__SM_ServiceMax_Profile__c =:groupProfileId Limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(!listOfConfigs.isEmpty() && listOfConfigs[0].SVMXC__SM_Content__c !=NULL)
        {
            INVT_SpareParts_Wrapper.SpareParts_Request jsonContent =(INVT_SpareParts_Wrapper.SpareParts_Request) JSON.deserialize(listOfConfigs[0].SVMXC__SM_Content__c,INVT_SpareParts_Wrapper.SpareParts_Request.class);
            if(jsonContent !=NULL && jsonContent.layout !=NULL && jsonContent.layout.downloadcriteria !=NULL && !jsonContent.layout.downloadcriteria.isEmpty())
            {
                for(INVT_SpareParts_Wrapper.DownloadCriteria newWrapper:jsonContent.layout.downloadcriteria)
                {
                    listOfStatuses.add(newWrapper.productstockstatus);
                    if(newWrapper.includeserializedstock)                        
                    {
                        listOfIncludeStatus.add(newWrapper.productstockstatus);
                    }
                }
            }
            if(jsonContent !=NULL && jsonContent.layout !=NULL && jsonContent.layout.attachmentfilename !=NULL && jsonContent.layout.attachmentfilename !='')
            {
                productFileField = jsonContent.layout.attachmentfilename;
            }
            System.debug(LoggingLevel.WARN,'Productfilefield '+productFileField);
            Boolean validField = false;
            if(productFileField !=NULL && productFileField !='')
            {
                validField = true;               
            }                        
            System.debug(LoggingLevel.WARN,'ValidField '+ValidField);            
            //Reading request for parameters for batching and incremental data sync.            
            if(request.valueMap !=NULL)
            {
                for(INTF_WebServicesDef.SVMXMap newMap:request.valueMap)
                {
                    if(newMap.key=='CALL_BACK')
                    {System.debug(LoggingLevel.WARN,'Coming inside call back ');
                        for(INTF_WebServicesDef.SVMXMap innerMap:newMap.valueMap)
                        {
                            if(innerMap.key=='SERIAL_STOCK_LAST_ID')
                            {
                                serialStockLastId=' AND Id > \''+innerMap.value+'\' ';
                                System.debug(LoggingLevel.WARN,'Coming inside serial stock last id call back ');
                            }
                            if(innerMap.key=='STOCK_LAST_ID')
                            {
                                stockLastId=' AND Id > \''+innerMap.value+'\' ';
                                callBackStockId=innerMap.value;
                                System.debug(LoggingLevel.WARN,'Coming inside stock last id call back ');
                            }
                        }
                    }
                    if(newMap.key=='LAST_SYNC_TIME' && newMap.value !=NULL)
                    {
                        lastModifiedDateTime = DateTime.valueOf(newMap.value);
                        lastSyncTimeClause=' AND LastModifiedDate >: lastModifiedDateTime ';    
                        lastSyncTimeClauseforFile = ' AND ContentDocument.SystemModStamp >: lastModifiedDateTime ';                    
                    }
                }
            }System.debug(LoggingLevel.WARN,'stocked serial last id'+serialStockLastId+' = '+stockLastId+'status='+listOfStatuses+'include'+listOfIncludeStatus);

            if(lastModifiedDateTime !=NULL && listOfConfigs[0].lastModifiedDate>lastModifiedDateTime)
            {
                    lastSyncTimeClauseforFile=''; 
                lastSyncTimeClause='';
                lastModifiedDateTime=NULL;
            }    
            //Get the setting values
            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getSettings(new Set<String>(),new Set<String>(),new set<String>{'IPAD018_SET006'},groupProfileId);
            if(lstSettings != NULL && lstSettings.size() > 0 )
            {
                for(SVMXC__ServiceMax_Config_Data__c eachSetting : lstSettings)
                {
                    if(eachSetting.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET006' && eachSetting.SVMXC__Internal_Value__c != NULL && eachSetting.SVMXC__Internal_Value__c != '')
                    {
                        intLimit = Integer.valueOf(eachSetting.SVMXC__Internal_Value__c);
                    }
                }
            }
            if(validField)
            {
                    if(isServicemaxFileEnabled){
                        stockLimit = (Integer)(intLimit/4); 
                    }else{
                        stockLimit = (Integer)(intLimit/3.3);
                    }
            }
            else
            {
                stockLimit  = intLimit/2; 
            }
            INTF_DataSync.logSOQL(intMethodCount , 'Select Id,SVMXC__Inventory_Location__c From SVMXC__Service_Group_Members__c Where SVMXC__Salesforce_User__c=:Userinfo.getUserId() Limit 1');                                         
            List<SVMXC__Service_Group_Members__c> listOfTechnician = [Select Id,SVMXC__Inventory_Location__c From SVMXC__Service_Group_Members__c Where SVMXC__Salesforce_User__c =:Userinfo.getUserId() Limit 1];
            List<String> listOfStocks = new List<String>();
            List<String> listOfModifiedStocks = new List<String>();            
            List<String> listOfSerialStocks = new List<String>(); 
            List<String> listOfProductIds = new List<Id>(); 
            List<String> listOfModifiedProductIds = new List<Id>(); 
            List<String> listOfAttachmentIds = new List<String>();             
            //Retrieving Product, Product Stock and Stocked Serial                                 
            if(!listOfTechnician.isEmpty() && listOfTechnician[0].SVMXC__Inventory_Location__c!=NULL)
            {
                String productStockquery = '';
                if(validField)
                {
                    productStockquery = 'Select Id,SVMXC__Product__c,SVMXC__Product__r.lastmodifieddate,SVMXC__Product__r.'+productFileField+',SVMXC__Status__c,lastModifiedDate From SVMXC__Product_Stock__c Where SVMXC__Location__c =\''+listOfTechnician[0].SVMXC__Inventory_Location__c+'\'  AND SVMXC__Status__c IN:listOfStatuses AND SVMXC__Product__c !=NULL '+stockLastId+' Order By Id Limit '+stockLimit;                    
                }
                else
                {
                    productStockquery = 'Select Id,SVMXC__Product__c,SVMXC__Product__r.lastmodifieddate,SVMXC__Status__c,lastModifiedDate From SVMXC__Product_Stock__c Where SVMXC__Location__c =\''+listOfTechnician[0].SVMXC__Inventory_Location__c+'\'  AND SVMXC__Status__c IN:listOfStatuses AND SVMXC__Product__c !=NULL '+stockLastId+' Order By Id Limit '+stockLimit;                                        
                }                       
                System.debug(LoggingLevel.WARN,productStockquery);
                Map<Id,String> mapOfProductIdAndItsAttachmentName = new Map<Id,String>();
                List<String> listOfFilewithExtensions = new List<String>();
                List<String> listOfFileNames = new List<String>();
                INTF_DataSync.logSOQL(intMethodCount , productStockquery); 
                for(SVMXC__Product_Stock__c newStock:Database.query(productStockquery))
                {
                    listOfStocks.add(newStock.Id);
                    listOfProductIds.add(newStock.SVMXC__Product__c);
                    if(validField)
                    {
                        if((String)(((sObject)newStock).getsObject('SVMXC__Product__r').get(productFileField)) !=NULL)
                        {
                            listOfFilewithExtensions.add((String)(((sObject)newStock).getsObject('SVMXC__Product__r').get(productFileField))+'.jpg');
                            listOfFilewithExtensions.add((String)(((sObject)newStock).getsObject('SVMXC__Product__r').get(productFileField))+'.jpeg');
                            listOfFilewithExtensions.add((String)(((sObject)newStock).getsObject('SVMXC__Product__r').get(productFileField))+'.png');    
                            listOfFileNames.add((String)(((sObject)newStock).getsObject('SVMXC__Product__r').get(productFileField))); //for Files                    
                            mapOfProductIdAndItsAttachmentName.put(newStock.SVMXC__Product__c,(String)(((sObject)newStock).getsObject('SVMXC__Product__r').get(productFileField)));
                        }
                    }
                    if(lastModifiedDateTime!=NULL && (newStock.lastModifiedDate>lastModifiedDateTime || newStock.SVMXC__Product__r.lastmodifieddate>lastmodifiedDateTime))
                    {
                        listOfModifiedStocks.add(newStock.Id);
                        listOfModifiedProductIds.add(newStock.SVMXC__Product__c);
                    }
                }
                System.debug(LoggingLevel.WARN,'Size of product stock ='+listOfStocks.size());
                System.debug(LoggingLevel.WARN,'Select Id,SVMXC__Product__c,lastModifiedDate From SVMXC__Product_Stock__c Where SVMXC__Location__c =\''+listOfTechnician[0].SVMXC__Inventory_Location__c+'\' AND SVMXC__Product__c !=NULL '+serialStockLastId+' Order By Id Limit '+stockLimit);            
                if(lastSyncTimeClause!='' && listOfIncludeStatus!=NULL && !listOfIncludeStatus.isEmpty())
                {
                    System.debug(LoggingLevel.WARN,'Stock Serial query '+'Select Id From SVMXC__Product_Serial__c Where ((SVMXC__Active__c = true AND SVMXC__Product_Stock__c IN:listOfStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+lastSyncTimeClause+serialStockLastId+') OR (SVMXC__Active__c=true AND SVMXC__Product_Stock__c IN:listOfModifiedStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+serialStockLastId+')) Order By Id Limit '+stockLimit);
                    INTF_DataSync.logSOQL(intMethodCount , 'Select Id From SVMXC__Product_Serial__c Where ((SVMXC__Active__c=true AND SVMXC__Product_Stock__c IN:listOfStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+lastSyncTimeClause+serialStockLastId+') OR (SVMXC__Active__c=true AND SVMXC__Product_Stock__c IN:listOfModifiedStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+serialStockLastId+')) Order By Id Limit '+stockLimit);                                        
                    for(SVMXC__Product_Serial__c newSerial:Database.query('Select Id From SVMXC__Product_Serial__c Where ((SVMXC__Active__c = true AND SVMXC__Product_Stock__c IN:listOfStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+lastSyncTimeClause+serialStockLastId+') OR (SVMXC__Active__c=true AND SVMXC__Product_Stock__c IN:listOfModifiedStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+serialStockLastId+')) Order By Id Limit '+stockLimit))
                    {
                        listOfSerialStocks.add(newSerial.Id);
                    }   
                    listOfStocks.clear();
                    listOfProductIds.clear();
                    listOfStocks.addAll(listOfModifiedStocks); 
                    listOfProductIds.addAll(listOfModifiedProductIds);                                
                }
                else if(listOfIncludeStatus!=NULL && !listOfIncludeStatus.isEmpty())
                {
                    INTF_DataSync.logSOQL(intMethodCount , 'Select Id From SVMXC__Product_Serial__c Where SVMXC__Active__c=true AND SVMXC__Product_Stock__c IN:listOfStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+serialStockLastId+' Order By Id Limit: stockLimit');                                        
                    for(SVMXC__Product_Serial__c newSerial:Database.query('Select Id From SVMXC__Product_Serial__c Where SVMXC__Active__c = true AND SVMXC__Product_Stock__c IN:listOfStocks AND SVMXC__Product_Stock__r.SVMXC__Status__c IN:listOfIncludeStatus'+serialStockLastId+' Order By Id Limit: stockLimit'))
                    {
                        listOfSerialStocks.add(newSerial.Id);
                    }
                }
                if(validField)
                {
                    Map<Id,Attachment> mapOfProductIdAndItsAttachment = new Map<Id,Attachment>(); 
                    List<String> listOfFormats = new List<String>();
                    listOfFormats.add('image/jpeg');
                    listOfFormats.add('image/jpg');
                    listOfFormats.add('image/png'); 
                    stockLimit = stockLimit+500;
                    List<Id> listOfAllProductIds = new List<Id>();
                    listOfAllProductIds.addAll(mapOfProductIdAndItsAttachmentName.keySet());
                    System.debug(LoggingLevel.WARN,'Formats '+listOfFormats);
                    System.debug(LoggingLevel.WARN,'Coming inside attachment logic'+'Select Id,Name,ParentId,lastModifiedDate From Attachment Where ((BodyLength <=1000000 AND ContentType In :listOfFormats and Name In :listOfFilewithExtensions) and (ParentId In :listOfProductIds or (ParentId In :listOfAllProductIds '+lastSyncTimeClause+' ))) Order By Id Limit '+stockLimit);                                      
                    INTF_DataSync.logSOQL(intMethodCount , 'Select Id,Name,ParentId,lastModifiedDate From Attachment Where ((BodyLength <=1000000 AND ContentType In :listOfFormats and Name In :listOfFilewithExtensions) and (ParentId In :listOfProductIds or (ParentId In :listOfAllProductIds '+lastSyncTimeClause+' ))) Order By Id Limit '+stockLimit);                                        
                    for(Attachment newAttachment:Database.query('Select Id,Name,ParentId,lastModifiedDate From Attachment Where ((BodyLength <=1000000 AND ContentType In :listOfFormats and Name In :listOfFilewithExtensions) and (ParentId In :listOfProductIds or (ParentId In :listOfAllProductIds '+lastSyncTimeClause+' ))) Order By Id Limit '+stockLimit))
                    {
                        Attachment attachmentRecord = new Attachment();
                        if(mapOfProductIdAndItsAttachment.containsKey(newAttachment.parentId))
                        {
                            mapOfProductIdAndItsAttachment.get(newAttachment.parentId);
                            if(mapOfProductIdAndItsAttachment.get(newAttachment.parentId).lastModifiedDate<newAttachment.lastModifiedDate)
                            {
                                attachmentRecord = newAttachment;
                            }
                        }
                        else
                        {
                            attachmentRecord = newAttachment;
                        }
                        mapOfProductIdAndItsAttachment.put(newAttachment.parentId,attachmentRecord);
                    }
                    
                    for(Attachment newAtt:mapOfProductIdAndItsAttachment.values())
                    {
                        listOfAttachmentIds.add(newAtt.Id);                    
                    }
                    
                    //For Salesforce file
                    if(isServicemaxFileEnabled && (listOfProductIds.size() > 0 || listOfAllProductIds.size() > 0) ){
                        Map<Id,ContentDocumentLink> mapOfProductIdAndItsContentDocument = new Map<Id,ContentDocumentLink>();
                        List<String> listOfContentDocumentLinkIds = new List<String>();
                        List<String> listOfExtensions = new List<String>();
                        listOfExtensions.add('jpeg');
                        listOfExtensions.add('jpg');
                        listOfExtensions.add('png'); 
                        INTF_DataSync.logSOQL(intMethodCount , 'Select Id,ContentDocument.IsDeleted,LinkedEntityId, ContentDocumentId,ContentDocument.LastModifiedDate, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink where ((ContentDocument.ContentSize <= 1000000 and ( ContentDocument.FileType IN : listOfExtensions OR ContentDocument.FileExtension IN : listOfExtensions) and ContentDocument.Title IN:listOfFileNames) and (LinkedEntityId IN:listOfProductIds or (LinkedEntityId IN:listOfAllProductIds '+lastSyncTimeClauseforFile+')))Order By Id Limit '+stockLimit);
                        for(ContentDocumentLink newAttachment:Database.query('Select Id,ContentDocument.IsDeleted,LinkedEntityId, ContentDocumentId,ContentDocument.LastModifiedDate, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink where ((ContentDocument.ContentSize <= 1000000 and (ContentDocument.FileType IN : listOfExtensions OR ContentDocument.FileExtension IN : listOfExtensions) and ContentDocument.Title IN:listOfFileNames) and (LinkedEntityId IN:listOfProductIds or (LinkedEntityId IN:listOfAllProductIds '+lastSyncTimeClauseforFile+')))Order By Id Limit '+stockLimit)){
                            System.debug(LoggingLevel.WARN,'Queried files are '+newAttachment);
                            ContentDocumentLink cdlRecord = new ContentDocumentLink();
                            if(mapOfProductIdAndItsContentDocument.containsKey(newAttachment.LinkedEntityId))
                            {
                                mapOfProductIdAndItsContentDocument.get(newAttachment.LinkedEntityId);
                                if(mapOfProductIdAndItsContentDocument.get(newAttachment.LinkedEntityId).ContentDocument.LastModifiedDate < newAttachment.ContentDocument.LastModifiedDate)
                                {
                                    cdlRecord = newAttachment;
                                }
                            }
                            else
                            {
                                cdlRecord = newAttachment;
                            }
                            mapOfProductIdAndItsContentDocument.put(newAttachment.LinkedEntityId,cdlRecord);
                        }
                        System.debug(LoggingLevel.WARN,'Each contentDocumentlink is '+mapOfProductIdAndItsContentDocument);                    
                        for(ContentDocumentLink newCDL:mapOfProductIdAndItsContentDocument.values())
                        {
                            listOfContentDocumentLinkIds.add(newCDL.id);
                        }
                        
                        //Response
                        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','',listOfContentDocumentLinkIds));      
                        
                        System.debug(LoggingLevel.WARN,'Coming outside File logic'+response);
                    }
                    System.debug(LoggingLevel.WARN,'Coming inside attachment logic'+listOfAttachmentIds);
                    
                }
            }
            //Adding to the response and callback to make it batching.            
            INTF_WebServicesDef.SVMXMap stockResponse = new INTF_WebServicesDef.SVMXMap();
            stockResponse.key = 'SVMXC__Product_Stock__c'; 
            stockResponse.values = new List<String>();
            stockResponse.values.addAll(listOfStocks);
            response.valueMap.add(stockResponse);
    
            INTF_WebServicesDef.SVMXMap serialStockResponse = new INTF_WebServicesDef.SVMXMap();
            serialStockResponse.key = 'SVMXC__Product_Serial__c'; 
            serialStockResponse.values = new List<String>();
            serialStockResponse.values.addAll(listOfSerialStocks);
            response.valueMap.add(serialStockResponse); 
            
            INTF_WebServicesDef.SVMXMap productResponse = new INTF_WebServicesDef.SVMXMap();
            productResponse.key = 'Product2'; 
            productResponse.values = new List<String>();
            productResponse.values.addAll(listOfProductIds);
            response.valueMap.add(productResponse); 
            
            INTF_WebServicesDef.SVMXMap attachmentResponse = new INTF_WebServicesDef.SVMXMap();
            attachmentResponse.key = 'Attachment'; 
            attachmentResponse.values = new List<String>();
            attachmentResponse.values.addAll(listOfAttachmentIds);
            response.valueMap.add(attachmentResponse);            
                                   
            if(!listOfSerialStocks.isEmpty() && listOfSerialStocks.size()>=stockLimit)
            {
                INTF_WebServicesDef.SVMXMap callBackObj = new INTF_WebServicesDef.SVMXMap();
                callBackObj.key = 'CALL_BACK';  
                callBackObj.value = 'true';
    
                INTF_WebServicesDef.SVMXMap callBackSerialStock = new INTF_WebServicesDef.SVMXMap();
                callBackSerialStock.key = 'SERIAL_STOCK_LAST_ID';  
                callBackSerialStock.value = listOfSerialStocks[listOfSerialStocks.size()-1];
                callBackObj.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                callBackObj.valueMap.add(callBackSerialStock);

                if(callBackStockId !='')
                {
                    INTF_WebServicesDef.SVMXMap callBackSerialStockIds = new INTF_WebServicesDef.SVMXMap();
                    callBackSerialStockIds.key = 'STOCK_LAST_ID';  
                    callBackSerialStockIds.value = callBackStockId;
                    callBackObj.valueMap.add(callBackSerialStockIds);            
                    response.valueMap.add(callBackObj);                
                }
            }
            else if(!listOfStocks.isEmpty() && listOfStocks.size()>=stockLimit)
            {
                INTF_WebServicesDef.SVMXMap callBackObj = new INTF_WebServicesDef.SVMXMap();
                callBackObj.key = 'CALL_BACK';  
                callBackObj.value = 'true';
    
                INTF_WebServicesDef.SVMXMap callBackSerialStock = new INTF_WebServicesDef.SVMXMap();
                callBackSerialStock.key = 'STOCK_LAST_ID';  
                callBackSerialStock.value = listOfStocks[listOfStocks.size()-1];
                callBackObj.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                callBackObj.valueMap.add(callBackSerialStock);            
                response.valueMap.add(callBackObj);                
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getTrunkStock');        
        return response;
    }       
    //This is to retrieve Online Technician Search for Name field.      
    public INTF_WebServicesDef.INTF_SFMResponse getTechnician(INTF_WebServicesDef.INTF_SFMRequest request)      
    {
        INTF_WebServicesDef.INTF_SFMResponse newResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        newResponse.eventName=request.eventName;
        newResponse.eventType = request.eventType;
        List<SVMXC__Service_Group_Members__c> listOfTechnicians = new List<SVMXC__Service_Group_Members__c>();
        //Querying Technician and adding it to response.        
        if(request.values !=NULL && !request.values.isEmpty() && request.values[0]!=NULL && request.values[0]!='')
        {        
            String technicianSearchContext = request.values[0];
            listOfTechnicians = Database.query('Select Id,Name,SVMXC__Inventory_Location__c,SVMXC__Service_Group__r.Name,SVMXC__Service_Group__c,SVMXC__Service_Territory__c,SVMXC__Service_Territory__r.Name From SVMXC__Service_Group_Members__c Where SVMXC__Active__c=true AND Name LIKE \'%'+request.values[0]+'%\' AND SVMXC__Inventory_Location__c!=NULL  Order by Name Limit 50000');
        }   
        else
        {
            listOfTechnicians = Database.query('Select Id,Name,SVMXC__Inventory_Location__c,SVMXC__Service_Group__r.Name,SVMXC__Service_Group__c,SVMXC__Service_Territory__c,SVMXC__Service_Territory__r.Name From SVMXC__Service_Group_Members__c Where SVMXC__Active__c=true AND SVMXC__Inventory_Location__c!=NULL  Order by Name Limit 50000');        
        }         
        INTF_WebServicesDef.SVMXMap technicianMap = new INTF_WebServicesDef.SVMXMap();            
        technicianMap.key='Object_Name';
        technicianMap.value='SVMXC__Service_Group_Members__c';
        INTF_WebServicesDef.SVMXMap technicianRecords = new INTF_WebServicesDef.SVMXMap();            
        technicianRecords.value=String.valueOf(JSON.Serialize(listOfTechnicians));
        technicianMap.valueMap.add(technicianRecords);
        newResponse.valueMap.add(technicianMap);
        return newResponse;
    }  
         
    //Querying the Product - Online Search based on keyword.            
    public INTF_WebServicesDef.INTF_SFMResponse getProducts(INTF_WebServicesDef.INTF_SFMRequest request)        
    {                       
        INTF_WebServicesDef.INTF_SFMResponse newResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        newResponse.eventName=request.eventName;
        newResponse.eventType = request.eventType;
        String lastId='';
        List<String> listOfFields = new List<String>();
        String whereClause='';
        String fieldQuery='Select Id';
        String searchText='';
        String orderAndLimit = ' Order by Name Limit 400';
        Set<String> setOfFields = new Set<String>();
        setOfFields.add('Id');
        
        String searchOperator = '';
        
        //Forming the dnamic query based on the field and its field type from the request.
        if(request.values !=NULL && !request.values.isEmpty() && request.values[0]!=NULL && request.values[0]!='')
        { 
            searchText=request.values[0];
        }        
        if(request.valueMap !=NULL)            
        {
            for(INTF_WebServicesDef.SVMXMap newMap:request.valueMap)
            {
                if(newMap.key =='Operator' && newMap.value !=NULL && newMap.value !='')
                {
                    searchOperator = newMap.value;
                }
            }  
        }      
 
        if(request.valueMap !=NULL)            
        {
            for(INTF_WebServicesDef.SVMXMap newMap:request.valueMap)
            {
                if(newMap.key =='Search_Fields' && newMap.valueMap !=NULL)
                {
                    for(INTF_WebServicesDef.SVMXMap fieldMap:newMap.valueMap)
                    {
                        if(fieldMap.value !=NULL && (fieldMap.value.equalsIgnoreCase('String') || fieldMap.value.equalsIgnoreCase('Picklist') || fieldMap.value.equalsIgnoreCase('Url') || fieldMap.value.equalsIgnoreCase('Phone') || fieldMap.value.equalsIgnoreCase('Email')))
                        {  
                            if(!setOfFields.contains(fieldMap.key))
                            {  
                                setOfFields.add(fieldMap.key);
                                fieldQuery=fieldQuery+','+fieldMap.key;
                                if(whereClause !='' && searchText !=NULL && searchText !='')
                                {
                                    if(searchOperator == 'Exact Match')
                                    {
                                        whereClause = whereClause +' OR '+fieldMap.key+ '=' +'\''+request.values[0]+'\'';
                                    }
                                    else if(searchOperator == 'Starts With')
                                    {
                                        whereClause = whereClause+' OR '+fieldMap.key+' like\''+request.values[0]+ '%\'';
                                    }
                                    else if(searchOperator == 'Contains')
                                    {
                                        whereClause = whereClause+' OR '+fieldMap.key+' like \'%'+request.values[0]+'%\'';
                                    }
                                    else if(searchOperator == 'Ends With')
                                    {
                                        whereClause = whereClause+' OR '+fieldMap.key+' like \'%'+request.values[0]+'\'';
                                    }
                                    else
                                    {
                                        whereClause=whereClause+' OR '+fieldMap.key+' LIKE \'%'+request.values[0]+'%\'';                                        
                                    }

                                }
                                else if(searchText !=NULL && searchText !='')
                                {
                                    if(searchOperator == 'Exact Match')
                                    {
                                        whereClause = ' From Product2 Where (('+fieldMap.key+ '=' +'\''+request.values[0]+'\'';
                                    }
                                    else if(searchOperator == 'Starts With')
                                    {
                                        whereClause =' From Product2 Where (('+fieldMap.key+' like\''+request.values[0]+ '%\'';
                                    }
                                    else if(searchOperator == 'Contains')
                                    {
                                        whereClause = ' From Product2 Where (('+fieldMap.key+' like \'%'+request.values[0]+'%\'';
                                    }
                                    else if(searchOperator == 'Ends With')
                                    {
                                        whereClause = ' From Product2 Where (('+fieldMap.key+' like \'%'+request.values[0]+'\'';
                                    }
                                    else
                                    {
                                        whereClause=' From Product2 Where (('+fieldMap.key+' LIKE \'%'+request.values[0]+'%\'';                                        
                                    }                                    
                                }
                            }
                        }
                        else if (fieldMap.value !=NULL && (fieldMap.value.equalsIgnoreCase('Integer') || fieldMap.value.equalsIgnoreCase('Double')))
                        {
                            if(!setOfFields.contains(fieldMap.key))
                            {
                                setOfFields.add(fieldMap.key);                                
                                fieldQuery=fieldQuery+','+fieldMap.key;
                                Decimal decimalCheck;
                                if(whereClause !='' && searchText !=NULL && searchText !='')
                                {
                                    try
                                    {
                                        decimalCheck = Decimal.valueOf(request.values[0]);                                        
                                        if(searchOperator == 'Exact Match')
                                        {
                                            whereClause = whereClause +' OR '+fieldMap.key+ '=' +'\''+request.values[0]+'\'';
                                        }
                                        else if(searchOperator == 'Starts With')
                                        {
                                            whereClause = whereClause+' OR '+fieldMap.key+' like\''+request.values[0]+ '%\'';
                                        }
                                        else if(searchOperator == 'Contains')
                                        {
                                            whereClause = whereClause+' OR '+fieldMap.key+' like \'%'+request.values[0]+'%\'';
                                        }
                                        else if(searchOperator == 'Ends With')
                                        {
                                            whereClause = whereClause+' OR '+fieldMap.key+' like \'%'+request.values[0]+'\'';
                                        }
                                        else
                                        {
                                            whereClause=whereClause+' OR '+fieldMap.key+' LIKE \'%'+request.values[0]+'%\'';                                        
                                        }
                                    }
                                    catch(Exception ex)
                                    {
                                        System.debug(LoggingLevel.WARN,'Exception is '+ex.getMessage());
                                    }
                                }
                                else if(searchText !=NULL && searchText !='')
                                {
                                    try
                                    {
                                        decimalCheck = Decimal.valueOf(request.values[0]);
                                        if(searchOperator == 'Exact Match')
                                        {
                                            whereClause = ' From Product2 Where (('+fieldMap.key+ '=' +'\''+request.values[0]+'\'';
                                        }
                                        else if(searchOperator == 'Starts With')
                                        {
                                            whereClause =' From Product2 Where (('+fieldMap.key+' like\''+request.values[0]+ '%\'';
                                        }
                                        else if(searchOperator == 'Contains')
                                        {
                                            whereClause = ' From Product2 Where (('+fieldMap.key+' like \'%'+request.values[0]+'%\'';
                                        }
                                        else if(searchOperator == 'Ends With')
                                        {
                                            whereClause = ' From Product2 Where (('+fieldMap.key+' like \'%'+request.values[0]+'\'';
                                        }
                                        else
                                        {
                                            whereClause=' From Product2 Where (('+fieldMap.key+' LIKE \'%'+request.values[0]+'%\'';                                        
                                        } 
                                    }
                                    catch(Exception ex)
                                    {
                                        System.debug(LoggingLevel.WARN,'Exception is '+ex.getMessage());
                                    }
                                }
                            }                            
                        }else{
                                //if it is a textarea or date or any other datatype include the field in the query
                                if(!setOfFields.contains(fieldMap.key)){
                                    setOfFields.add(fieldMap.key);                                
                                    fieldQuery=fieldQuery+','+fieldMap.key;
                                }
                        }
                    }
                }
            }
        }
        if(whereClause !='')
        {
            whereClause = whereClause+'))';
        }
        else
        {
            whereClause = whereClause+' From Product2 ';
        }
        if(!setOfFields.contains('SVMXC__Stockable__c'))
        {
            fieldQuery = fieldQuery+',SVMXC__Stockable__c';
        }
        System.debug(LoggingLevel.WARN,'Query = '+fieldQuery+whereClause+orderAndLimit);
        List<Product2> listOfProducts = Database.query(fieldQuery+whereClause+orderAndLimit);
        INTF_WebServicesDef.SVMXMap productMap = new INTF_WebServicesDef.SVMXMap();            
        productMap.key='Object_Name';
        productMap.value='Product2';
        INTF_WebServicesDef.SVMXMap productRecords = new INTF_WebServicesDef.SVMXMap();            
        productRecords.value=String.valueOf(JSON.Serialize(listOfProducts));        
        productMap.valueMap.add(productRecords);            
        newResponse.valueMap.add(productMap);  
        newResponse.success=true;
        return newResponse;
    } 

    public INTF_WebServicesDef.INTF_SFMResponse getDeltaPicklistDef(INTF_WebServicesDef.INTF_SFMRequest inputRequest, Id grpProfileId){

        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Datetime dtLastSynchTime = null;
        List<String> picklistDefIds = new List<String>();
        String strLastIdClause = '';
        List<String> modifiedDefIds = new List<String>();
    
        if(inputRequest.eventName == 'GET_PIQ_PICKLIST_DEFINITION'){
    
            for(INTF_WebServicesDef.SVMXMap eachVM : inputRequest.valueMap){
                if(eachVM.key == 'PRODUCTIQ_LAST_SYNC' && eachVM.value != null && eachVM.value != ''){
                    dtLastSynchTime = Datetime.valueOf(eachVM.value);
                }else if( eachVM.key == 'PICKLIST_DEF_IDS' && eachVM.values != null && eachVM.values.size() > 0){
                    picklistDefIds.addAll(eachVM.values);
                }else if( eachVM.key == 'PICKLIST_DEF_LAST_ID' && !String.isBlank(eachVM.value)){
                    strLastIdClause = ' AND ID > \'' + eachVM.value + '\'';
                }
            }
        }
    
        integer queryLimit = getQueryRowsUsingSettings(grpProfileId);
        //queryLimit = 2; //For testing purpose only
        system.debug(LoggingLevel.debug, 'queryLimit = '+queryLimit);
        if(queryLimit <= 0){
            response.message = 'Internal Error - Limit for the number of rows to be queried reached before executing query for PIQ Picklist Definitions. Please increase the setting IPAD018_SET011';
            return response;
        }
           
        system.debug(LoggingLevel.debug, 'Query being executed = '+'Select Id from SVMXC__SM_TA_Picklist_Definition__c where ID IN :picklistDefIds AND SystemModstamp >:dtLastSynchTime '+ strLastIdClause + ' Order By Id limit :queryLimit ');
        List<SVMXC__SM_TA_Picklist_Definition__c> picklistDefList = Database.Query('Select Id from SVMXC__SM_TA_Picklist_Definition__c where ID IN :picklistDefIds AND SystemModstamp >:dtLastSynchTime '+ strLastIdClause + ' Order By Id limit :queryLimit ');
    
        for(SVMXC__SM_TA_Picklist_Definition__c eachDef: picklistDefList){
            modifiedDefIds.add(eachDef.ID);
        }
    
        queryLimit -= picklistDefList.size();
        if(queryLimit <= 0){
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('PICKLIST_DEF_LAST_ID', String.ValueOf(picklistDefList[picklistDefList.size() - 1].Id)  ));
        }
    
        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELTA_PICKLIST_DEF', JSON.serialize(modifiedDefIds)));
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        return response;
    }
}