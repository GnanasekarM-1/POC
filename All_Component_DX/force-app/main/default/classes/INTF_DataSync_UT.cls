@isTest(seeAllData = false)
private class INTF_DataSync_UT {
    
    static private string grpProfileId = '';
    static private string sfdcProfileId = userinfo.getProfileId();
    static private Id  configProfileRecordTypeId, confAccessRecTypeId,mobConfigRecordTypeId,settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId , targetMgrRecordTypeId, serviceAccessFlowRecTypeId;
    static private SVMXC__ServiceMax_Config_Data__c configProfile; 
    
    static void insertConfigData(){
        
        List<RecordType> recordTypeList = [select Id, DeveloperName, SobjectType from Recordtype 
                          where (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and (DeveloperName =: 'Configuration_Profile' OR DeveloperName =: 'Configuration_Access' OR DeveloperName =:'Mobile_Configuration' OR DeveloperName =: 'Setting_Value' OR DeveloperName =: 'Service_Flow_Access'))
                          OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND (DeveloperName =: 'Module' OR DeveloperName =: 'Submodule' OR DeveloperName =: 'Settings' OR DeveloperName =: 'Target_Manager'))];
        
        if(recordTypeList <> NULL && !recordTypeList.isEmpty()){
            for(RecordType rType : recordTypeList){
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c'){
                    if(rType.DeveloperName =='Configuration_Profile'){
                        configProfileRecordTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Configuration_Access'){
                        confAccessRecTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Mobile_Configuration'){
                        mobConfigRecordTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Setting_Value'){
                        settingValueRecTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Service_Flow_Access'){
                        serviceAccessFlowRecTypeId = rType.Id;
                    }
                    
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c'){
                    if(rType.DeveloperName =='Module'){
                        moduleRecTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Submodule'){
                        subModuleRecTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Settings'){
                        settingRecTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Target_Manager'){
                        targetMgrRecordTypeId = rType.Id;
                    }
                }
            }
        }
        
        //insert profile related processes and config data
        configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = sfdcProfileId;
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile;
        
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c =: sfdcProfileId AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = true];
        grpProfileId = profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
        
        //insert device mobile config and mobile config related to sync profiling
        List<SVMXC__SM_Device_Mobile_Config__c> deviceConfigList = new List<SVMXC__SM_Device_Mobile_Config__c>();
        SVMXC__SM_Device_Mobile_Config__c devSetting1 = new SVMXC__SM_Device_Mobile_Config__c(SVMXC__SM_Name__c = 'iPad Setting' , SVMXC__SM_IsDefault__c = FALSE, SVMXC__SM_Device_Type__c = 'iPad', SVMXC__SM_Access_Configuration_Profile__c = grpProfileId );
        deviceConfigList.add(devSetting1);
        SVMXC__SM_Device_Mobile_Config__c defaultSetting = new SVMXC__SM_Device_Mobile_Config__c(SVMXC__SM_Name__c = 'Default Setting' , SVMXC__SM_IsDefault__c = TRUE, SVMXC__SM_Device_Type__c = 'iPhone', SVMXC__SM_Access_Configuration_Profile__c = grpProfileId );
        deviceConfigList.add(defaultSetting);
        
        insert deviceConfigList;
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c enableSyncProfConfData = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = mobConfigRecordTypeId , SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Enable Performance Profiling', SVMXC__Internal_value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = devSetting1.ID);
        configDataList.add(enableSyncProfConfData);
        SVMXC__ServiceMax_Config_Data__c enableSoqlProfConfData = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = mobConfigRecordTypeId , SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Enable SOQL Profiling', SVMXC__Internal_value__c = 'true' ,SVMXC__SM_Device_Mobile_Config__c = devSetting1.ID );
        configDataList.add(enableSoqlProfConfData);
        
        SVMXC__ServiceMax_Config_Data__c orgTypeSyncProf = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Performance Profiling Org Type', SVMXC__Internal_value__c = 'Sandbox',  SVMXC__SM_Device_Mobile_Config__c = devSetting1.ID);
        configDataList.add(orgTypeSyncProf); 
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = devSetting1.ID);
        configDataList.add(dcConfigData);
                   
        insert configDataList;
   }
   
   static void createIPADSharingSetting(){
        
        String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        
        //Module - IPAD
        SVMXC__ServiceMax_Processes__c modProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = moduleRecTypeId, SVMXC__Name__c = 'ServiceMax iPad Client',SVMXC__ModuleID__c = 'IPAD',
        SVMXC__Installation_Key__c = strInstlltnKey, SVMXC__Description__c = 'The iPad client for ServiceMax allows field technicians to view their work order assignments, SLA commitments, enter time & material, capture customer signature, update the work order status etc. In addition, technicians can also access the knowledge base and product manuals, as well as use chatter to collaborate with other users in the organization');
        insert modProcess;
        
        //Submodule
        SVMXC__ServiceMax_Processes__c subModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = subModuleRecTypeId, SVMXC__Name__c = 'Synchronization',SVMXC__Installation_Key__c = strInstlltnKey,
        SVMXC__SubmoduleID__c = 'IPAD018',SVMXC__Module__c = modProcess.Id,SVMXC__ModuleID__c = 'IPAD',SVMXC__Description__c = 'This submodule represents all functionality in the iPad client related to Synchronization');
        insert subModProcess;
        
        //Setting - IPAD018_SET009
        SVMXC__ServiceMax_Processes__c settingProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Apply sharing rules during data sync', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = 'True~|~False',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'false',SVMXC__Description__c = 'When set to true, access to data for logged in user during data sync (manual/incremental/aggressive) is controlled at record level as per sharing settings. This setting is applicable to all mobile clients.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET014',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        insert settingProcess;
        
        //Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess.Id, SVMXC__Internal_Value__c = 'True');
        insert settingValueConfig;
    }
    static testMethod void testOneCallSync()
    {
        try{
            
            insertConfigData(); 
            createIPADSharingSetting();
            
            //create process for View Record
            SVMXC__ServiceMax_Processes__c viewRecTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'VIEW RECORD', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234');
            insert viewRecTarMgrProcess;
            
            //create Config Data for Service Access Flow
            SVMXC__ServiceMax_Config_Data__c viewRecConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId,SVMXC__Dispatch_Process__c = viewRecTarMgrProcess.Id );
            insert viewRecConfigData;
                
            //Creating Sample Data for the sync to work
            List<SVMXC__Service_Order_Line__c> lstWOLine = new List<SVMXC__Service_Order_Line__c>();
    
            Account acc = new Account();
            acc.Name = 'Maxplore';
            insert acc;
            Product2 product1 = new Product2();
            product1.Name = 'Laptop';
            insert product1;
    
            SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
            WO.SVMXC__Company__c = acc.Id;
            WO.SVMXC__Product__c = product1.Id;
            WO.SVMXC__City__c = 'Bangalore';
            Database.SaveResult result1 = Database.insert(WO);
            string workOrderId = result1.getId();
        
            SVMXC__Service_Order_Line__c WOLine = new SVMXC__Service_Order_Line__c();
            WOLine.SVMXC__Service_Order__c = WO.Id;
            lstWOLine.add(WOLine);
            
            SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c();
            WOLine1.SVMXC__Service_Order__c = WO.Id;
            lstWOLine.add(WOLine1);
            insert lstWOLine;
            
            String Record_id = '';
            SVMXC__SM_Request_Cache__c requestRecord2 = new SVMXC__SM_Request_Cache__c(SVMXC__SM_Device_UDID__c = '1234567891', SVMXC__SM_User_Id__c = UserInfo.getUserId());
            Database.SaveResult Result2 = Database.insert(requestRecord2);
            Record_id = Result2.getId();
           
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventName = 'ONE_CALL_SYNC';
            req.eventType = 'SYNC';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:1234567891'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.value = Record_id;
            
            //PUT DELETE
            INTF_WebServicesDef.SVMXMap deleteVM = new INTF_WebServicesDef.SVMXMap('Object_Name', 'SVMXC__Service_Order_Line__c');
            SVMXC.INTF_WebServicesDef.SVMXMap fieldsVM = new SVMXC.INTF_WebServicesDef.SVMXMap();
            fieldsVM.key = 'Fields';
            fieldsVM.value = '';
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj1.key = '';
            obj1.value = WOLine.Id;
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj2.key = '';
            obj2.value = WOLine1.Id;  
            
            fieldsVM.valueMap.add(obj1);
            fieldsVM.valueMap.add(obj2);  
            
            INTF_WebServicesDef.INTF_SFMRequest req_PutDelete = new INTF_WebServicesDef.INTF_SFMRequest();
            req_PutDelete.eventName = 'PUT_DELETE';
            req_PutDelete.eventType = 'SYNC';
            req_PutDelete.value = Record_id;
            req_PutDelete.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            deleteVM.valueMap.add(fieldsVM);
            req_PutDelete.valueMap.add(deleteVM);
            
            req.eventName = 'ONE_CALL_SYNC';
            req.eventType = 'SYNC';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SNSCallout_UT.MockHttpResponseGenerator());
                INTF_WebServicesDef.INTF_SFMResponse response = INTF_WebServicesDef.INTF_DataSync_WS(req);
            Test.stopTest();
        
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
    }
    
    static testMethod void testDownloadCriteria()
    {
        insertConfigData();
        try{

            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
            req.eventType='SYNC';
            req.eventName='DOWNLOAD_CREITERIA_SYNC';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
           
            test.startTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
            test.stopTest();
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testDownloadCriteria '+Ex.getMessage());
        }   
    } 
    
    static testMethod void testPricingDefinitions()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'PRICE_CALC_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            SVMXC.INTF_WebServicesDef.SVMXMap obj0 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj0.key = 'LAST_INDEX';
            obj0.value = '0';
            req.valueMap.add(obj0);
            
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testPricingDefinitions '+Ex.getMessage());
        }    
        //resp = dataUtilObj.getPricingDefinitions(req);
     }
     
     static testMethod void testFetchRecords()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
            INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
            clientInfoReq.clientType = 'iPad';
            clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64', 'usertrunklocation:trunk'};
            req.clientInfo.add(clientInfoReq);
            
            req.eventType='SYNC';
            req.eventName='TX_FETCH';
            req.value = '001';
            
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
            test.StopTest();    
            
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testFetchRecords '+Ex.getMessage());
        }
    }
    
    static testMethod void testAdvancedDownloadCriteria()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'ADV_DOWNLOAD_CRITERIA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testAdvancedDownloadCriteria '+Ex.getMessage());
        }
    } 
    
    static testMethod void testGetChecklistData()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_CHECKLIST_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SYNC_PRODUCTIQ_PRODUCT_ATTR';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SYNC_PRODUCTIQ_IB_ATTR';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'GET_DELETE_PRODUCTIQ_DATA';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'GET_PIQ_PICKLIST_DEFINITION';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testGetChecklistData '+Ex.getMessage());
        }
    }
    
    static testMethod void testProductIQSync()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'TARGETED_SYNC';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'TECH_LOCATION_UPDATE';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'LOCATION_HISTORY';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'DATA_ON_DEMAND';
                req.eventType = 'GET_DATA';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'PUSH_NOTIFICATION';
                req.eventType = 'GET_DATA';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'EVENT_RECORDS';
                req.eventType = 'PURGING';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'PURGE_RECORDS';
                req.eventType = 'PURGING';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testProductIQSync '+Ex.getMessage());
        }
    }
    
    static testMethod void testSyncDownloadCriteria()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_DOWNLOAD_CRITERIA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'CATALOG_SEARCH';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'LOCATE_PART';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'TRUNK_STOCK';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'STOCK_TRANSFER';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SYNC_PRODUCT_TEMPLATES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SYNC_PIQ_ATTACHMENTS';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testSyncDownloadCriteria '+Ex.getMessage());
        }
    } 
    
    static testMethod void testSubmitDocument()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'SUBMIT_DOCUMENT';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
               INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
               req.eventName = 'TX_FETCH_OPTIMZED';
               response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
               req.eventName = 'USER_TRUNK';
               response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
               req.eventName = 'SFM_SEARCH';
               req.eventType = 'SEARCH_RESULTS';
               response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
               req.eventName = 'CLEAN_UP';
               req.eventType = 'CLEAN_UP_SELECT';
               response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
               req.eventName = 'DATA_ON_DEMAND';
               req.eventType = 'GET_PRICE_INFO';
               response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
               req.eventName = 'PURGE_RECORDS';
               req.eventType = 'PURGING';
               response = (new INTF_DataSync()).dataSync(req, grpProfileId);
               
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testSubmitDocument '+Ex.getMessage());
        }
    } 
    
    static testMethod void testGeneratePDF()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'GENERATE_PDF';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'GENERATE_PDF_FILES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SUBMIT_DOCUMENT_FILES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SYNC_PIQ_FILES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'DOWNLOAD_CHECKLIST_FILES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'DOWNLOAD_EVENT_FILES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'SYNC_SALESFORCE_FILES';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testGeneratePDF '+Ex.getMessage());
        }
    } 
    
    static testMethod void testEventSync()
    {
        try{
            //create the required settings
            insertConfigData();
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventType = 'SYNC';
            req.eventName = 'EVENT_SYNC';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            test.StartTest();
                INTF_WebServicesDef.INTF_SFMResponse response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                 
                req.eventName = 'GET_INSERT_DOWNLOAD_CRITERIA';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'PUT_UPDATE';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'PUT_DELETE';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'GET_INSERT';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'PUT_INSERT';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
                req.eventName = 'TECHNICIAN_SEARCH';
                response = (new INTF_DataSync()).dataSync(req, grpProfileId);
                
            test.StopTest();    
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN,'Exception testEventSync '+Ex.getMessage());
        }
    }           
}