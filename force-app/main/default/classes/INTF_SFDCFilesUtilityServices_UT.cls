@isTest(seeAllData = false)
public with sharing class INTF_SFDCFilesUtilityServices_UT {
    static testMethod void testCreateFiles() {
    
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();

        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'SYNC_SALESFORCE_FILES';
        req.value = 'Sync_1522662799145_784';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();

        INTF_WebServicesDef.SVMXMap firstVM = new INTF_WebServicesDef.SVMXMap('Object_Name', 'ContentVersion');


        INTF_WebServicesDef.SVMXMap fieldsVM = new INTF_WebServicesDef.SVMXMap();
        fieldsVM.Key = 'a1K_local_1523341490029_6';

        Map<String,string> fieldsPerRecordMap = new Map<String,string>();
        fieldsPerRecordMap.put('Title','File_webservice');
        fieldsPerRecordMap.put('Description','Testing files webservice');
        fieldsPerRecordMap.put('PathOnClient','/Test/data');
        fieldsPerRecordMap.put('isMajorVersion','false');

        INTF_WebServicesDef.SVMXMap secndVM = new INTF_WebServicesDef.SVMXMap('a1L0G000004m7x2', String.valueOf(JSON.serialize(fieldsPerRecordMap)));

        fieldsVM.valueMap.add(secndVM);
        firstVM.valueMap.add(fieldsVM);
        req.valueMap.add(firstVM);


        resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
    }
    
    
    static testMethod void testFilesDownload(){
    
        
        INTF_DataUtilityServices_UT.insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        CONF_MobileConfig.FileConfig configForFile = new CONF_MobileConfig.FileConfig(true,'25','html,jpg','one');
        //ADC For files
        //SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Files', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID, SVMXC__SM_Files_Config__c = '{\"maxFileSize\":\"25\",\"isFilesEnabled\":true,\"fileTypes\":\"jpg,html\",\"fileTags\":\"\"}' );
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Files', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID, SVMXC__SM_Files_Config__c = json.serialize(configForFile) );
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        //Insert Events
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        insert wo;
    
        Task tskObj = new Task();
        tskObj.OwnerId = UserInfo.getUserId();
        tskObj.ActivityDate = DateTime.now().date();
        insert tskObj;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.SVMXC__Active__c = true;
        team.Name = 'Test Team';
        insert team;
    
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Test Technician';
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        technician.SVMXC__Service_Group__c = team.Id;
        technician.SVMXC__Active__c = true;
        insert technician;
    
        SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.Name = 'Test Subject';
        svmxEvent.SVMXC__StartDateTime__c = DateTime.now();
        svmxEvent.SVMXC__EndDateTime__c = DateTime.now().addHours(1);
        svmxEvent.SVMXC__Technician__c = technician.Id;
        svmxEvent.SVMXC__WhatId__c = wo.Id;
        insert svmxEvent;
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        insert evntObj;
        
        Map<String,String> mapOfEventAndIds = new Map<string,string>();
        mapOfEventAndIds.put('ALL_EVENTS', json.serialize(new List<String>{svmxEvent.id}));
        mapOfEventAndIds.put('MODIFIED_EVENTS', json.serialize(new List<String>{svmxEvent.id}));
        
        SVMXC__SM_Request_Cache__c requestCache = new SVMXC__SM_Request_Cache__c(SVMXC__SM_Device_UDID__c = '123456789', SVMXC__SM_User_Id__c = UserInfo.getUserId(), SVMXC__SM_Client_Sync_Request_Id__c = 'test345');
        requestCache.SVMXC__SM_Event_What_IDs__c = Json.serialize(mapOfEventAndIds);
        Database.SaveResult Result2 = Database.insert(requestCache);  //Request cache with the event Ids
            
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        
        insertFiles(wo.Id);
        
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'DOWNLOAD_EVENT_FILES';
        req.value = 'test345';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();

        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);

        INTF_WebServicesDef.SVMXMap valueMap2 = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'TRUE');
        valueMap2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_LASTID', '000000000000000000'));
        //req.valueMap.add(valueMap2);

        resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
    }
    
    static testMethod void testChecklistFileDownload(){
        
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();

        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
        INTF_DataUtilityServices_UT.insertConfigData();
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            SVMXC__ServiceMax_Config_Data__c isChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Enable Checklist', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(isChecklist);
            
            SVMXC__ServiceMax_Config_Data__c inProgressChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'InProgress Checklists', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(inProgressChecklist);
            
            //Svmx process for ADC - SVMX_Rule
            SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = INTF_DataUtilityServices_UT.svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
            insert advDCProcess;
        
            //Svmx config Data for expression
            SVMXC__ServiceMax_Config_Data__c expressionConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id);
            configDataList.add(expressionConfigData);
            
            //Another expression for Reference
            SVMXC__ServiceMax_Config_Data__c refExpConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id, SVMXC__Display_Type__c = 'REFERENCE', SVMXC__Object_Name__c = 'Account' , SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c', SVMXC__Source_Field_Name__c ='SVMXC__Company__c');
            configDataList.add(refExpConfigData);
            
            //adding a config data for ADC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID );
            configDataList.add(adcConfigData);
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(dcConfigData);
            
            SVMXC__ServiceMax_Config_Data__c completedChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Completed Checklists', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(completedChecklist);
            
            SVMXC__ServiceMax_Config_Data__c syncToGetEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '1', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(syncToGetEventChecklist);
            
            SVMXC__ServiceMax_Config_Data__c syncToRemEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '1', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(syncToRemEventChecklist);
            
            SVMXC__ServiceMax_Config_Data__c downloadCritChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Internal_Value__c = '', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(downloadCritChecklist);
            
            SVMXC__ServiceMax_Config_Data__c advDCChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Internal_Value__c = '', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(advDCChecklist);
        
            //create process for Checklist
            SVMXC__ServiceMax_Processes__c checklistTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = INTF_DataUtilityServices_UT.targetMgrRecordTypeId, SVMXC__Purpose__c = 'CHECKLIST', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234');
            insert checklistTarMgrProcess;
            
            //create Config Data for Service Access Flow
            SVMXC__ServiceMax_Config_Data__c checkListConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId,SVMXC__Dispatch_Process__c = checklistTarMgrProcess.Id );
            configDataList.add(checkListConfigData);
            
            //Mobile Config for 'Synchronization to get and Remove Events'
            SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(syncToGetEventConfigData);
        
            SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
            configDataList.add(syncToRemoveEventConfigData);
            
            insert configDataList;
            
            SVMXC__ServiceMax_Processes__c procNodeObjProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c', RecordTypeId = INTF_DataUtilityServices_UT.procNodeObjRecTypeId,SVMXC__Process__c = checklistTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234');
            insert procNodeObjProcess;
            
            SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
            WO.SVMXC__City__c = 'Bangalore';
            insert wo;
            
            ContentVersion testCV = new ContentVersion();
                testCV.PathOnClient = '/test/Class';
                testCV.isMajorVersion = false;
                testCV.Title = 'test CV';
                testCV.VersionData = Blob.Valueof('SVMX');
                insert testCV;
                
                List<ContentVersion> cvList = [select id,ContentDocumentId from ContentVersion where Id =: testCV.Id];
                
                ContentDocumentLink cdlRecord =new ContentDocumentLink();
            cdlRecord.LinkedEntityId = wo.Id;
            cdlRecord.ContentDocumentId = cvList[0].ContentDocumentId;
            cdlRecord.ShareType = 'I';
            cdlRecord.Visibility = 'AllUsers'; 
            insert cdlRecord;
            
            req.eventType = 'SYNC';
            req.eventName = 'DOWNLOAD_CHECKLIST_FILES';
            req.value = 'test345';
            req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('CDL_IDS','',new List<String>{cdlRecord.Id}));
            
            INTF_WebServicesDef.SVMXMap callbackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'True');
            callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_LASTID', '000000000000000000'));
            req.valuemap.add(callbackVM);
            
            Test.StartTest();
                resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
            Test.StopTest();
    }
    
    public static void insertFiles(String recordId){
            ContentVersion testCV = new ContentVersion();
            testCV.PathOnClient = '/test/Class';
            testCV.isMajorVersion = false;
            testCV.Title = 'test CV';
            testCV.VersionData = Blob.Valueof('SVMX');
            insert testCV;
            
            List<ContentVersion> cvList = [select id,ContentDocumentId from ContentVersion where Id =: testCV.Id];
            
            ContentDocumentLink cdlRecord =new ContentDocumentLink();
        cdlRecord.LinkedEntityId = recordId;
        cdlRecord.ContentDocumentId = cvList[0].ContentDocumentId;
        cdlRecord.ShareType = 'I';
        cdlRecord.Visibility = 'AllUsers'; 
        insert cdlRecord;
     }
     
     static testMethod void testPIQFileDownload(){
     
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();

        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
        INTF_DataUtilityServices_UT.insertConfigData();
        INTF_DataUtilityServices_UT.createIPADSetting();
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.SVMXC__Status__c = 'Installed';
        Database.SaveResult resul = Database.insert(IB);
        String IBId = resul.getId();
            
        Attachment att = new Attachment();
        att.ParentId = IBId;
        att.Name = 'Test Attachment for Parent';
        att.Body = Blob.valueOf('Test Data');
     
        insert(att);
        
        insertFiles(IBId);   
        
        req.eventType = 'SYNC';
        req.eventName = 'SYNC_PIQ_FILES';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();

        SVMXC.INTF_WebServicesDef.SVMXMap valueMap1 = new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);

        SVMXC.INTF_WebServicesDef.SVMXMap valueMap2 = new SVMXC.INTF_WebServicesDef.SVMXMap('CALL_BACK', 'TRUE');
        valueMap2.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('CDL_LASTID', '000000000000000000'));
        req.valueMap.add(valueMap2);

        SVMXC.INTF_WebServicesDef.SVMXMap valueMap3 = new SVMXC.INTF_WebServicesDef.SVMXMap('TX_OBJECT', 'SVMXC__Installed_Product__c',new List<String>{IBId});
        req.valueMap.add(valueMap3);

        SVMXC.INTF_WebServicesDef.SVMXMap valueMap4 = new SVMXC.INTF_WebServicesDef.SVMXMap('MODIFIED_OBJECT', 'SVMXC__Installed_Product__c',new List<String>{IBId});
        req.valueMap.add(valueMap4);

        Test.StartTest();
            resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
        Test.StopTest();
                 
     }
     
     static testMethod void testDownloadOnDemand(){
     
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();

        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
        INTF_DataUtilityServices_UT.insertConfigData();
        INTF_DataUtilityServices_UT.createIPADSetting();
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.SVMXC__Status__c = 'Installed';
        Database.SaveResult result = Database.insert(IB);
        String IBId = result.getId();
            
        insertFiles(IBId);   
        
        req.eventType = 'GET_DATA';
        req.eventName = 'DATA_ON_DEMAND';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();

        SVMXC.INTF_WebServicesDef.SVMXMap valMap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        valMap1.key = 'Object_Name';
        valMap1.value = 'SVMXC__Installed_Product__c';
        valMap1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('Id', IBId));
        req.valueMap.add(valMap1);

        Test.StartTest();
            resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
        Test.StopTest();
                 
     }
     
    static testMethod void testSubmitDocument()
     {
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
         
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};      
        
        req.eventType = 'SYNC';
        req.eventName = 'SUBMIT_DOCUMENT_FILES';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap vm1 = new INTF_WebServicesDef.SVMXMap('HTMLID','');
        INTF_WebServicesDef.SVMXMap svmxMap = new INTF_WebServicesDef.SVMXMap();
        svmxMap.key = 'ContentVersion';
        svmxMap.values.add( 'HTMLID' );        
        vm1.valueMap.add( svmxMap );
         
        INTF_WebServicesDef.SVMXMap vm2 = new INTF_WebServicesDef.SVMXMap('SIGNATURE','');
        INTF_WebServicesDef.SVMXMap svmxMap2 = new INTF_WebServicesDef.SVMXMap();
        svmxMap2.key = 'ContentVersion';
        svmxMap2.values.add( 'signature' );        
        vm2.valueMap.add( svmxMap2 );
        
        svmxMap2 = new INTF_WebServicesDef.SVMXMap();
        svmxMap2.key = 'Attachment';
        svmxMap2.values.add( 'attachment' );
        vm2.valueMap.add( svmxMap2 );
        
        req.valueMap.add( vm1 );
        req.valueMap.add( vm2 );
        
        Test.StartTest();
            resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
        Test.StopTest();
    }
    
    static testMethod void testGeneratePDF()
     {
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
         
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};      
        
        req.eventType = 'SYNC';
        req.eventName = 'GENERATE_PDF_FILES';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        Database.SaveResult result = Database.insert(wo);
        String woID = result.getId();
        
        //Insert HTML 
        ContentVersion testCV = new ContentVersion();
            testCV.PathOnClient = '/test/Class';
            testCV.isMajorVersion = false;
            testCV.Title = 'file.html';
            testCV.VersionData = Blob.Valueof('SVMX');
            insert testCV;
            
            List<ContentVersion> cvList = [select id,ContentDocumentId from ContentVersion where Id =: testCV.Id];
            
        ContentDocumentLink cdlRecord =new ContentDocumentLink();
        cdlRecord.LinkedEntityId = woID;
        cdlRecord.ContentDocumentId = cvList[0].ContentDocumentId;
        cdlRecord.ShareType = 'I';
        cdlRecord.Visibility = 'AllUsers'; 
        Database.SaveResult result2 = Database.insert(cdlRecord);
        String htmlID = result2.getId();
        
        //Insert Signature 
        testCV = new ContentVersion();
            testCV.PathOnClient = '/test/Class';
            testCV.isMajorVersion = false;
            testCV.Title = 'sig.png';
            testCV.VersionData = Blob.Valueof('SVMX');
            insert testCV;
            
            List<ContentVersion> cvList1 = [select id,ContentDocumentId from ContentVersion where Id =: testCV.Id];
            
        ContentDocumentLink cdlRecord2 =new ContentDocumentLink();
        cdlRecord2.LinkedEntityId = woID;
        cdlRecord2.ContentDocumentId = cvList1[0].ContentDocumentId;
        cdlRecord2.ShareType = 'I';
        cdlRecord2.Visibility = 'AllUsers'; 
        insert cdlRecord2;
        
        INTF_WebServicesDef.SVMXMap vm1 = new INTF_WebServicesDef.SVMXMap('HTMLID','',new List<String>{htmlID});
        INTF_WebServicesDef.SVMXMap svmxMap = new INTF_WebServicesDef.SVMXMap();
        svmxMap.key = 'PROCESS_ID';
        svmxMap.value = 'Process1';        
        vm1.valueMap.add( svmxMap );
        
        svmxMap = new INTF_WebServicesDef.SVMXMap('VERSION_ENABLED','true');
        vm1.valueMap.add( svmxMap );
        
        INTF_WebServicesDef.SVMXMap vm2 = new INTF_WebServicesDef.SVMXMap('SIGNATURE','');
        INTF_WebServicesDef.SVMXMap svmxMap2 = new INTF_WebServicesDef.SVMXMap();
        svmxMap2.key = 'ContentDocument';
        svmxMap2.values.add(cvList1[0].ContentDocumentId);        
        vm2.valueMap.add( svmxMap2 );
        
        req.valueMap.add( vm1 );
        req.valueMap.add( vm2 );
        
        Test.StartTest();
            resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
            INTF_SFDCFilesUtilityServices testInstance = new INTF_SFDCFilesUtilityServices();
            
            //INTF_SFDCFilesUtilityServices.ParsedHTML testString= new INTF_SFDCFilesUtilityServices.ParsedHTML('testHTML', new Map<Integer, String>());
            
            String testDocument = '<html><head><style type=\"text/css\"> <img src="picture.jpg"></style></head></html>';  
            INTF_SFDCFilesUtilityServices.ParsedHTML testString = testInstance.parseHTMLForImages(testDocument);
            
            String testParsing = testInstance.ReplaceHTMLImagesSrc(testDocument,new Map<String, String>(), new Map<String, String>());
            List<String> parseForStyleStr = testInstance.parseForStyle(testDocument);
            Map<String,String> docPerIdMap = testInstance.QueryDocumentObject(new List<String>{'Doc1'}); 
        Test.StopTest();
    }
    
    static testMethod void testFilesDownloadWithoutCache(){
    
        
        INTF_DataUtilityServices_UT.insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        CONF_MobileConfig.FileConfig configForFile = new CONF_MobileConfig.FileConfig(true,'25','html,jpg','one');
        //ADC For files
        //SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Files', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID, SVMXC__SM_Files_Config__c = '{\"maxFileSize\":\"25\",\"isFilesEnabled\":true,\"fileTypes\":\"jpg,html\",\"fileTags\":\"\"}' );
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = INTF_DataUtilityServices_UT.mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = INTF_DataUtilityServices_UT.grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Files', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = INTF_DataUtilityServices_UT.defaultMobConfigID, SVMXC__SM_Files_Config__c = json.serialize(configForFile) );
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        //Insert Events
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        insert wo;
    
        Task tskObj = new Task();
        tskObj.OwnerId = UserInfo.getUserId();
        tskObj.ActivityDate = DateTime.now().date();
        insert tskObj;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.SVMXC__Active__c = true;
        team.Name = 'Test Team';
        insert team;
    
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Test Technician';
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        technician.SVMXC__Service_Group__c = team.Id;
        technician.SVMXC__Active__c = true;
        insert technician;
    
        SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.Name = 'Test Subject';
        svmxEvent.SVMXC__StartDateTime__c = DateTime.now();
        svmxEvent.SVMXC__EndDateTime__c = DateTime.now().addHours(1);
        svmxEvent.SVMXC__Technician__c = technician.Id;
        svmxEvent.SVMXC__WhatId__c = wo.Id;
        insert svmxEvent;
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        insert evntObj;
           
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        
        insertFiles(wo.Id);
        
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'DOWNLOAD_EVENT_FILES';
        req.value = 'test345';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();

        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);

        INTF_WebServicesDef.SVMXMap valueMap2 = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'TRUE');
        valueMap2.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_LASTID', '000000000000000000'));
        req.valueMap.add(valueMap2);

        resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
    }
    
}