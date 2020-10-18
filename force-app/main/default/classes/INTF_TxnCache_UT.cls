@isTest(seeAllData = false)
private class INTF_TxnCache_UT {
    
    static private string grpProfileId;
    static private string sfdcProfileId;
    static private Id targetMgrRecordTypeId, mobConfigRecordTypeId, configProfileRecordTypeId, confAccessRecTypeId, procNodeObjRecTypeId, serviceAccessFlowRecTypeId, svmxRuleRecTypeID, expressionRecTypeId, settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId;
    static private SVMXC__ServiceMax_Config_Data__c configProfile;    
    static private SVMXC__Service_Order__c wo;  
    static private ID defaultMobConfigID; 
       
    static void insertConfigData(){
        grpProfileId = '';
        sfdcProfileId = userinfo.getProfileId();
        
        //Getting record Type Ids
        List<RecordType> recordTypeList = [select Id, DeveloperName, SobjectType from Recordtype 
                                            where (SobjectType =: 'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Target_Manager')  
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Mobile_Configuration') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =: 'Configuration_Profile') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Configuration_Access') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND developerName = :'Process_Node_Objects') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Service_Flow_Access' ) 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'SVMX_Rule') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' And DeveloperName =: 'Expressions') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Settings') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Module')
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Submodule') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Setting_Value')];
        if(recordTypeList <> NULL && !recordTypeList.isEmpty()){
            for(RecordType rType : recordTypeList){
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Target_Manager'){
                    targetMgrRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Mobile_Configuration'){
                    mobConfigRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Profile'){
                    configProfileRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Access'){
                    confAccessRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Process_Node_Objects'){
                    procNodeObjRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Service_Flow_Access'){
                    serviceAccessFlowRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='SVMX_Rule'){
                    svmxRuleRecTypeID = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName == 'Expressions'){
                    expressionRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName == 'Settings'){
                     settingRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName == 'Setting_Value'){
                    settingValueRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName == 'Module'){
                    moduleRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName == 'Submodule'){
                    subModuleRecTypeId = rType.Id;
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
        
        //Insert data related to ProductIQ
        ProductIQConfiguration.Profile prof = new ProductIQConfiguration.Profile();
        prof.isTechnicalAttributesEnabled = 'TRUE';
        List<ProductIQConfiguration.AttachmentConfig> lstAttachConfig = new List<ProductIQConfiguration.AttachmentConfig>();
        ProductIQConfiguration.AttachmentConfig attachConfig = new ProductIQConfiguration.AttachmentConfig();
        attachConfig.isAttachmentsEnabled = 'true';
        //attachConfig.fileTypes = 'jpeg,.text';
        attachConfig.maximumFileSize = '10';
        lstAttachConfig.add(attachConfig);
        prof.attachment = lstAttachConfig;
        
        SVMXC__ProductIQProfile__c prodIQProfile = new SVMXC__ProductIQProfile__c(SVMXC__Contents__c = JSON.serialize(prof),SVMXC__ServiceMax_Profile__c = grpProfileId );
        insert  prodIQProfile;
        
         //Insert device_Mobile_Config
        SVMXC__SM_Device_Mobile_Config__c defaultSetting = new SVMXC__SM_Device_Mobile_Config__c(SVMXC__SM_Name__c = 'Default Setting' , SVMXC__SM_IsDefault__c = TRUE, SVMXC__SM_Device_Type__c = 'iPad; iPhone; Android Tablet; Android Phone; Windows', SVMXC__SM_Access_Configuration_Profile__c = grpProfileId );
        insert defaultSetting;
        
        List<SVMXC__SM_Device_Mobile_Config__c> mobDeviceSetting = [select Id from SVMXC__SM_Device_Mobile_Config__c where SVMXC__SM_IsDefault__c = TRUE ];
        defaultMobConfigID = mobDeviceSetting[0].ID;        
    }
    
    static void createIPADSetting(){
        
        String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        
        List<SVMXC__ServiceMax_Processes__c> processList = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //Module - IPAD
        SVMXC__ServiceMax_Processes__c modProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = moduleRecTypeId, SVMXC__Name__c = 'ServiceMax iPad Client',SVMXC__ModuleID__c = 'IPAD',
        SVMXC__Installation_Key__c = strInstlltnKey, SVMXC__Description__c = 'The iPad client for ServiceMax allows field technicians to view their work order assignments, SLA commitments, enter time & material, capture customer signature, update the work order status etc. In addition, technicians can also access the knowledge base and product manuals, as well as use chatter to collaborate with other users in the organization');
        insert modProcess;
        
        //Module - PRODIQ
        SVMXC__ServiceMax_Processes__c prodIQModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = moduleRecTypeId, SVMXC__Name__c = 'Installed Base App',SVMXC__ModuleID__c = 'PRODIQ',
        SVMXC__Installation_Key__c = strInstlltnKey, SVMXC__Description__c = 'Installed Base Management Application');
        insert prodIQModProcess;

        //Submodule
        SVMXC__ServiceMax_Processes__c subModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = subModuleRecTypeId, SVMXC__Name__c = 'Synchronization',SVMXC__Installation_Key__c = strInstlltnKey,
        SVMXC__SubmoduleID__c = 'IPAD018',SVMXC__Module__c = modProcess.Id,SVMXC__ModuleID__c = 'IPAD',SVMXC__Description__c = 'This submodule represents all functionality in the iPad client related to Synchronization');
        insert subModProcess;
        
        //Submodule PRODIQ
        SVMXC__ServiceMax_Processes__c prodIQSubModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = subModuleRecTypeId, SVMXC__Name__c = 'General',SVMXC__Installation_Key__c = strInstlltnKey,
        SVMXC__SubmoduleID__c = 'PRODIQ002',SVMXC__Module__c = prodIQModProcess.Id,SVMXC__ModuleID__c = 'PRODIQ',SVMXC__Description__c = 'This submodule represents all the general functionality in Installed Base App client.');
        insert prodIQSubModProcess;
        
        //Setting - IPAD018_SET004
        SVMXC__ServiceMax_Processes__c settingProcess1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Reference Salesforce Objects to be skipped', 
        SVMXC__Search_Order__c = 'Global',SVMXC__Setting_Type__c = 'Global',SVMXC__Values__c = '',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Text',SVMXC__Default_Value__c = 'PartnerNetworkConnection,User,FeedPost,Solution',SVMXC__Description__c = 'Setting defines all the Salesforce Objects that need to be skipped while downloading records.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET004',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess1);
        
        //Setting - IPAD018_SET006
        SVMXC__ServiceMax_Processes__c settingProcess2 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Record ID batch size', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = '10',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Text',SVMXC__Default_Value__c = '10000',SVMXC__Description__c = 'Internal setting used to fetch Record IDs in multiple batches. Useful when data volumes are high. Reduce this if the default configuration results in Salesforce governor limit exception.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET006',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess2);
        
        //Setting - PRODIQ002_SET001
        SVMXC__ServiceMax_Processes__c settingProcess3 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Enable Installed Base app', 
        SVMXC__Search_Order__c = 'Global',SVMXC__Setting_Type__c = 'Global',SVMXC__Values__c = '1000',SVMXC__SubmoduleID__c = 'PRODIQ002',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'False',SVMXC__Description__c = 'Enables Installed Base App on FSA app and native iPad app. Whenever the value of this setting is changed, reset app must be performed.',
        SVMXC__Submodule__c = prodIQSubModProcess.Id,SVMXC__SettingID__c = 'SET001',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess3);
        
        insert processList;
        
        //Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess1.Id, SVMXC__Internal_Value__c = 'PartnerNetworkConnection,User,FeedPost,Solution');
        configDataList.add(settingValueConfig1);
        
        SVMXC__ServiceMax_Config_Data__c settingValueConfig2 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess2.Id, SVMXC__Internal_Value__c = '4');
        configDataList.add(settingValueConfig2);
        
        //PIQ set002
        SVMXC__ServiceMax_Config_Data__c settingValueConfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess3.Id, SVMXC__Internal_Value__c = 'True');
        configDataList.add(settingValueConfig3);
        
        insert configDataList;

    }
    
    static testMethod void oneCallSyncWithSyncRequest()
    {
        try{
            
            insertConfigData(); 
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            insert dcConfigData;
            
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
            SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = 'ABCDEEFGHIJKLMNOPQRSTUVWXYZ');
            Database.SaveResult Result = Database.insert(requestRecord);
            Record_id = Result.getId();
            
            SVMXC__Sync_Request_Records__c reqRecord = new SVMXC__Sync_Request_Records__c(SVMXC__Operation_Type__c = 'Select', SVMXC__Sync_Request__c = Record_id, SVMXC__SFDC_Record_Id__c = workOrderId );
            insert reqRecord;
        
            //PreParing Request for the One Call Sync
            INTF_WebServicesDef.INTF_SFMRequest req_OneCallSync = new INTF_WebServicesDef.INTF_SFMRequest();
            req_OneCallSync.eventName = 'ONE_CALL_SYNC';
            req_OneCallSync.eventType = 'SYNC';
            req_OneCallSync.value = Record_id;
            req_OneCallSync.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<string>();
            clInfo.clientInfo.add('usertrunklocation:');
            clInfo.clientType = 'iPad';
            req_OneCallSync.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            
            INTF_WebServicesDef.SVMXMap lastSyncTimeVM = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', string.valueOf(DateTime.now().addHours(1)));
            req_OneCallSync.valueMap.add(lastSyncTimeVM);
            
            INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMRequest req_PutInsert = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMRequest req_PutDelete = new INTF_WebServicesDef.INTF_SFMRequest();
            req_PutUpdate.eventName = 'PUT_UPDATE';
            req_PutInsert.eventName = 'PUT_INSERT';
            req_PutDelete.eventName = 'PUT_DELETE';
            req_PutUpdate.eventType = 'SYNC';
            req_PutInsert.eventType = 'SYNC';
            req_PutDelete.eventType = 'SYNC';
            req_PutUpdate.value = Record_id;
            req_PutInsert.value = Record_id;
            req_PutDelete.value = Record_id;
            req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req_PutInsert.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req_PutDelete.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            //Including the ClientInfo related to req_PutUpdate
            INTF_WebServicesDef.SVMXClient internalClInfo = new INTF_WebServicesDef.SVMXClient();
            internalClInfo.clientInfo = new List<String>{'appversion:16.49.002'};
            internalClInfo.clientType = 'iPad';
            req_PutUpdate.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{internalClInfo};
            
            INTF_WebServicesDef.SVMXMap putDeleteVM = new INTF_WebServicesDef.SVMXMap('PUT_DELETE','');
            INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
            INTF_WebServicesDef.SVMXMap putInsertVM = new INTF_WebServicesDef.SVMXMap('PUT_INSERT','');
            putDeleteVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutDelete};
            putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
            putInsertVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutInsert};
        
            req_OneCallSync.valueMap.add(putDeleteVM);
            req_OneCallSync.valueMap.add(putInsertVM);
            req_OneCallSync.valueMap.add(putUpdateVM);
            req_OneCallSync.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0')); //included last index
            
            INTF_WebServicesDef.SVMXMap syncTimeStampVM = new INTF_WebServicesDef.SVMXMap('SYNC_TIME_STAMP', string.valueOf(DateTime.now().addHours(1)));
            req_PutUpdate.valueMap.add(syncTimeStampVM);
            req_PutInsert.valueMap.add(syncTimeStampVM);
            req_PutDelete.valueMap.add(syncTimeStampVM);
            
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
            obj2.value = 'testtesttesttes'; //Error scenario - ID that does not exist  
            
            fieldsVM.valueMap.add(obj1);
            fieldsVM.valueMap.add(obj2);  
                
            deleteVM.valueMap.add(fieldsVM);
            req_PutDelete.valueMap.add(deleteVM);
            
            //PUT INSERT - Parent_Object
            INTF_WebServicesDef.SVMXMap insertParentVM = new INTF_WebServicesDef.SVMXMap('Parent_Object', 'SVMXC__Service_Order__c');
            insertParentVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
            List<INTF_WebServicesDef.SVMXMap> vls = new List<INTF_WebServicesDef.SVMXMap>();                                    
            INTF_WebServicesDef.SVMXMap jsonstr1 = new INTF_WebServicesDef.SVMXMap();                                           
            jsonstr1.key = '1';
            jsonstr1.value = '{"attributes":{"type":"SVMXC__Service_Order__c","url":""},"SVMXC__Problem_Description__c":"TEST DISCREPTION 1 ","SVMXC__Entitlement_Notes__c":"Test entitlement notes0", "SVMXC__Age__c":"1", "SVMXC__Drip__c":"false", "SVMXC__Scheduled_Date_Time__c" : "2016-09-20 08:59:37", "SVMXC__Scheduled_Date__c" : "2016-09-20"}';
            vls.add(jsonstr1);
              
            INTF_WebServicesDef.SVMXMap  parentFieldsVM = new INTF_WebServicesDef.SVMXMap();
            parentFieldsVM.key = 'Fields';
            parentFieldsVM.value = 'SVMXC__Requested_City__c,SVMXC__Billing_Information__c,SVMXC__Received_Location__c,SVMXC__Quantity_Shipped2__c,SVMXC__Applied_Rate_Type__c,Name,SVMXC__Received_Quantity2__c,SystemModstamp,SVMXC__Requested_Country__c,SVMXC__Quantity_Shipment_Initiated2__c,SVMXC__Canceled_On__c,SVMXC__Requested_Zip__c,SVMXC__Is_Billable__c,SVMXC__Received_State__c,SVMXC__Select__c,SVMXC__Total_Estimated_Price__c,SVMXC__Received_Country__c,SVMXC__Include_in_Quote__c,SVMXC__Consumed_From_Location__c,SVMXC__Log_Against__c,SVMXC__Product__c,SVMXC__Group_Member__c,SVMXC__Received_Zip__c,SVMXC__Billable_Quantity__c,SVMXC__Cost_Category__c,Id,SVMXC__Closed_By__c,SVMXC__End_Date_and_Time__c,LastModifiedById,SVMXC__Reference_Information__c,SVMXC__Service_Group__c,SVMXC__Requested_Location__c,SVMXC__Total_Line_Price__c,SVMXC__From_Location__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Expense_Type__c,SVMXC__Line_Type__c,CreatedDate,SVMXC__Actual_Price2__c,SVMXC__Date_Received__c,SVMXC__Work_Detail__c,SVMXC__Estimated_Price2__c,SVMXC__Billable_Line_Price__c,CurrencyIsoCode,SVMXC__Service_Order__c,RecordTypeId,SVMXC__Closed_On__c,SVMXC__Posted_To_Inventory__c,SVMXC__Date_Requested__c,SVMXC__Serial_Number__c,SVMXC__Received_City__c,CreatedById,SVMXC__Covered__c,SVMXC__Estimated_Quantity2__c,SVMXC__Actual_Quantity2__c,SVMXC__Canceled_By__c,SVMXC__Requested_Quantity2__c,LastActivityDate,SVMXC__Requested_Street__c,SVMXC__Received_Street__c,SVMXC__Activity_Type__c,SVMXC__Line_Status__c,LastModifiedDate,IsDeleted,SVMXC__Work_Description__c,SVMXC__Product_Warranty__c,SVMXC__Discount__c,SVMXC__Requested_State__c,SVMXC__Start_Date_and_Time__c';
            parentFieldsVM.valueMap = vls;    
            
            insertParentVM.valueMap.add(parentFieldsVM); 
            req_PutInsert.valueMap.add(insertParentVM);
            
            //Child_Object
            INTF_WebServicesDef.SVMXMap insertChildVM = new INTF_WebServicesDef.SVMXMap('Child_Object', 'SVMXC__Service_Order_Line__c');
            
            List<INTF_WebServicesDef.SVMXMap> vls1 = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap jsonstrChild = new INTF_WebServicesDef.SVMXMap();
            jsonstrChild.key = '4';
            jsonstrChild.value = '{"attributes":{"type":"SVMXC__Service_Order_Line__c","url":""},"Name":"TestOrderLine1","SVMXC__Activity_Type__c":"minor defects","SVMXC__Service_Order__c":"2", "SVMXC__Date_Requested__c" : "2016-09-20 08:59:37"}';
            vls1.add(jsonstrChild);
        
            INTF_WebServicesDef.SVMXMap  childFieldsVM = new INTF_WebServicesDef.SVMXMap();
            childFieldsVM.key = 'Fields';
            childFieldsVM.value = 'SVMXC__Requested_City__c,SVMXC__Billing_Information__c,SVMXC__Received_Location__c,SVMXC__Quantity_Shipped2__c,SVMXC__Applied_Rate_Type__c,Name,SVMXC__Received_Quantity2__c,SystemModstamp,SVMXC__Requested_Country__c,SVMXC__Quantity_Shipment_Initiated2__c,SVMXC__Canceled_On__c,SVMXC__Requested_Zip__c,SVMXC__Is_Billable__c,SVMXC__Received_State__c,SVMXC__Select__c,SVMXC__Total_Estimated_Price__c,SVMXC__Received_Country__c,SVMXC__Include_in_Quote__c,SVMXC__Consumed_From_Location__c,SVMXC__Log_Against__c,SVMXC__Product__c,SVMXC__Group_Member__c,SVMXC__Received_Zip__c,SVMXC__Billable_Quantity__c,SVMXC__Cost_Category__c,Id,SVMXC__Closed_By__c,SVMXC__End_Date_and_Time__c,LastModifiedById,SVMXC__Reference_Information__c,SVMXC__Service_Group__c,SVMXC__Requested_Location__c,SVMXC__Total_Line_Price__c,SVMXC__From_Location__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Expense_Type__c,SVMXC__Line_Type__c,CreatedDate,SVMXC__Actual_Price2__c,SVMXC__Date_Received__c,SVMXC__Work_Detail__c,SVMXC__Estimated_Price2__c,SVMXC__Billable_Line_Price__c,CurrencyIsoCode,SVMXC__Service_Order__c,RecordTypeId,SVMXC__Closed_On__c,SVMXC__Posted_To_Inventory__c,SVMXC__Date_Requested__c,SVMXC__Serial_Number__c,SVMXC__Received_City__c,CreatedById,SVMXC__Covered__c,SVMXC__Estimated_Quantity2__c,SVMXC__Actual_Quantity2__c,SVMXC__Canceled_By__c,SVMXC__Requested_Quantity2__c,LastActivityDate,SVMXC__Requested_Street__c,SVMXC__Received_Street__c,SVMXC__Activity_Type__c,SVMXC__Line_Status__c,LastModifiedDate,IsDeleted,SVMXC__Work_Description__c,SVMXC__Product_Warranty__c,SVMXC__Discount__c,SVMXC__Requested_State__c,SVMXC__Start_Date_and_Time__c';
            childFieldsVM.valueMap = vls1;  
            
            insertChildVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            insertChildVM.valueMap.add(childFieldsVM);
            req_PutInsert.valueMap.add(insertChildVM);
            
            //PUT UPDATE----------------
            INTF_WebServicesDef.SVMXMap updateVM = new INTF_WebServicesDef.SVMXMap('Object_Name', 'SVMXC__Service_Order_Line__c');
            updateVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            SVMXC.INTF_WebServicesDef.SVMXMap updateFieldsVM = new SVMXC.INTF_WebServicesDef.SVMXMap();
            updateFieldsVM.key = 'Fields';
            updateFieldsVM.value = 'SVMXC__Requested_City__c,SVMXC__Billing_Information__c,SVMXC__Received_Location__c,SVMXC__Quantity_Shipped2__c,SVMXC__Applied_Rate_Type__c,Name,SVMXC__Received_Quantity2__c,SystemModstamp,SVMXC__Requested_Country__c,SVMXC__Quantity_Shipment_Initiated2__c,SVMXC__Canceled_On__c,SVMXC__Requested_Zip__c,SVMXC__Is_Billable__c,SVMXC__Received_State__c,SVMXC__Select__c,SVMXC__Total_Estimated_Price__c,SVMXC__Received_Country__c,SVMXC__Include_in_Quote__c,SVMXC__Consumed_From_Location__c,SVMXC__Log_Against__c,SVMXC__Product__c,SVMXC__Group_Member__c,SVMXC__Received_Zip__c,SVMXC__Billable_Quantity__c,SVMXC__Cost_Category__c,Id,SVMXC__Closed_By__c,SVMXC__End_Date_and_Time__c,LastModifiedById,SVMXC__Reference_Information__c,SVMXC__Service_Group__c,SVMXC__Requested_Location__c,SVMXC__Total_Line_Price__c,SVMXC__From_Location__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Expense_Type__c,SVMXC__Line_Type__c,CreatedDate,SVMXC__Actual_Price2__c,SVMXC__Date_Received__c,SVMXC__Work_Detail__c,SVMXC__Estimated_Price2__c,SVMXC__Billable_Line_Price__c,CurrencyIsoCode,SVMXC__Service_Order__c,RecordTypeId,SVMXC__Closed_On__c,SVMXC__Posted_To_Inventory__c,SVMXC__Date_Requested__c,SVMXC__Serial_Number__c,SVMXC__Received_City__c,CreatedById,SVMXC__Covered__c,SVMXC__Estimated_Quantity2__c,SVMXC__Actual_Quantity2__c,SVMXC__Canceled_By__c,SVMXC__Requested_Quantity2__c,LastActivityDate,SVMXC__Requested_Street__c,SVMXC__Received_Street__c,SVMXC__Activity_Type__c,SVMXC__Line_Status__c,LastModifiedDate,IsDeleted,SVMXC__Work_Description__c,SVMXC__Product_Warranty__c,SVMXC__Discount__c,SVMXC__Requested_State__c,SVMXC__Start_Date_and_Time__c';
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj3.key = string.valueOf(DateTime.now().addHours(1));
            obj3.value = '{"IsDeleted":"false","SVMXC__Is_Billable__c":"true","SVMXC__Use_Price_From_Pricebook__c":"true","SVMXC__Line_Type__c":"Parts","SVMXC__Select__c":"false","SVMXC__Total_Line_Price__c":"50000.0","SVMXC__Posted_To_Inventory__c":"false","SVMXC__Total_Estimated_Price__c":"0.0","SVMXC__Actual_Price2__c":"50000.0","SVMXC__Line_Status__c":"Open","Id":"' + WOLine.Id + '","SVMXC__Include_in_Quote__c":"false","SVMXC__Service_Order__c":"' + WO.Id + '","SVMXC__Actual_Quantity2__c":"1.0"}'; 
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj4.key = string.valueOf(DateTime.now().addHours(1));
            obj4.value = '{"IsDeleted":"false","SVMXC__Is_Billable__c":"true","SVMXC__Use_Price_From_Pricebook__c":"true","SVMXC__Line_Type__c":"Parts","SVMXC__Select__c":"false","SVMXC__Total_Line_Price__c":"50000.0","SVMXC__Posted_To_Inventory__c":"false","SVMXC__Total_Estimated_Price__c":"0.0","SVMXC__Actual_Price2__c":"50000.0","SVMXC__Line_Status__c":"Open","Id":"' + WOLine1.Id + '","SVMXC__Include_in_Quote__c":"false","SVMXC__Service_Order__c":"' + WO.Id + '","SVMXC__Actual_Quantity2__c":"1.0"}';
           
            updateFieldsVM.valueMap.add(obj3);
            //updateFieldsVM.valueMap.add(obj4);  //Error scenario - wrong ID specified
                
            updateVM.valueMap.add(updateFieldsVM);
            req_PutUpdate.valueMap.add(updateVM);
            
            createEvents();
            Test.startTest();
            //Executing the Sync
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMResponse response = txnCache.oneCallSync(req_OneCallSync);
            system.debug('Final Response: ' + response);
            
            Boolean isCallBack = false;
            List<INTF_WebServicesDef.SVMXMap> callBackVM = new List<INTF_WebServicesDef.SVMXMap>();
            
            for(INTF_WebServicesDef.SVMXMap eachValueMap : response.valueMap)
            {
                if(eachValueMap.key == 'CALL_BACK' && eachValueMap.value != null && eachValueMap.value != '')
                {
                    isCallBack = Boolean.valueOf(eachValueMap.value);
                    callBackVM = eachValueMap.valueMap;
                    break;
                }   
            }
            if(isCallBack)
            {
                INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
                req.eventName = 'ONE_CALL_SYNC';
                req.eventType = 'SYNC';
                req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                req.value = Record_id+'i';
                INTF_WebServicesDef.SVMXMap callbck2 = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
                callbck2.valueMap = callBackVM;
                req.valueMap.add(callbck2);
                INTF_WebServicesDef.INTF_SFMResponse resp = txnCache.oneCallSync(req);
                
                for(INTF_WebServicesDef.SVMXMap eachValueMap : resp.valueMap)
                {
                    if(eachValueMap.key == 'CALL_BACK' && eachValueMap.value != null && eachValueMap.value != '')
                    {
                        isCallBack = Boolean.valueOf(eachValueMap.value);
                        callBackVM = eachValueMap.valueMap;
                        break;
                    }   
                }
                
                if(isCallBack)
                {
                    INTF_WebServicesDef.INTF_SFMRequest req1 = new INTF_WebServicesDef.INTF_SFMRequest();
                    req1.eventName = 'ONE_CALL_SYNC';
                    req1.eventType = 'SYNC';
                    req1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                    
                    clInfo = new INTF_WebServicesDef.SVMXClient();
                    clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
                    clInfo.clientType = 'iPad';
                    req1.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                    
                    req1.value = Record_id;
                    INTF_WebServicesDef.SVMXMap callbck3 = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
                    callbck3.valueMap = callBackVM;
                    req1.valueMap.add(callbck3);
                    INTF_WebServicesDef.INTF_SFMResponse resp1 = txnCache.oneCallSync(req1);
                }
            }
            
            txnCache.addCallBackContext('ABCDEEFGHIJKLMNOPQRSTUVWXYZ', 'GET_DELETE_DC_OPTIMZED', response);
            txnCache.addCallBackContext('ABCDEEFGHIJKLMNOPQRSTUVWXYZ', 'PUT_UPDATE', response);
            Datetime dtFromDateTime = system.now().addDays(-1);
            Datetime dtToDateTime = system.now().addDays(1);
            txnCache.GetObjsTaggedToEvents(dtFromDateTime, dtToDateTime, new Set<String>{'Account'});
            
            INTF_WebServicesDef.SVMXMap callBackContext = new INTF_WebServicesDef.SVMXMap('CALL_BACK','true');
            callBackContext.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            callBackContext.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT','GET_DELETE_DC_OPTIMZED'));
            req_OneCallSync.valueMap.add(callBackContext);
            response = txnCache.oneCallSync(req_OneCallSync);
            
            txnCache.addLimitVM('CALL_BACK_CONTEXT', response);
            Test.stopTest();
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN, 'Exception = :' + Ex.getMessage());
        }
    }
    
    static testMethod void testGetRecordsForIds()
    {
        try{
             INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMRequest txFetchReq = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.SVMXClient cl1 = new INTF_WebServicesDef.SVMXClient();
            cl1.clientInfo = new List<string>();
            cl1.clientInfo.add('appversion:12');
            txFetchReq.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{cl1};
            
            SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
            //WO.SVMXC__Company__c = acc.Id;
            //WO.SVMXC__Product__c = product1.Id;
            WO.SVMXC__City__c = 'Bangalore';
            insert WO;
            
            txFetchReq.eventType = 'SYNC'; 
            txFetchReq.eventName = 'TX_FETCH_OPTIMZED';
            txFetchReq.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap WOVM = new INTF_WebServicesDef.SVMXMap('TX_OBJECT','SVMXC__Service_Order__c');
            WOVM.values = new List<string>{string.valueOf(WO.Id)};
            txFetchReq.valueMap.add(WOVM);
            INTF_WebServicesDef.SVMXMap lastBatch_vm = new INTF_WebServicesDef.SVMXMap();
            lastBatch_vm.key = 'LAST_BATCH';
            lastBatch_vm.value = 'TRUE';
            txFetchReq.valueMap.add(lastBatch_vm);
            Test.startTest();
            txnCache.getRecordsForIds(txFetchReq);
            Test.stopTest();
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN, 'Exception = :' + Ex.getMessage());
        }
    }
    
    static testMethod void oneCallSyncUTWithRequestCache()
    {
        try{
            
            insertConfigData(); //insert cconfig/setting related data
            
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
            insert WO;
            
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
            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
           
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(dcConfigData);
            
            //Mobile Config for 'Synchronization to get and Remove Events'
            SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(syncToGetEventConfigData);
            
            SVMXC__ServiceMax_Config_Data__c syncToRemEventConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(syncToRemEventConfigData);
            
            insert configDataList;
            
            //Technician with the associated salesforce user
           //  SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId());
          //  insert technician;
           
            //Preparing Request for the One Call Sync
            INTF_WebServicesDef.INTF_SFMRequest req_OneCallSync = new INTF_WebServicesDef.INTF_SFMRequest();
            req_OneCallSync.eventName = 'ONE_CALL_SYNC';
            req_OneCallSync.eventType = 'SYNC';
            req_OneCallSync.value = Record_id;
            req_OneCallSync.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
            clInfo.clientType = 'iPad';
            req_OneCallSync.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
        
            INTF_WebServicesDef.SVMXMap lastSyncTimeVM = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', string.valueOf(DateTime.now().addHours(1)));
            req_OneCallSync.valueMap.add(lastSyncTimeVM);
            
            INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMRequest req_PutInsert = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMRequest req_PutDelete = new INTF_WebServicesDef.INTF_SFMRequest();
            req_PutUpdate.eventName = 'PUT_UPDATE';
            req_PutInsert.eventName = 'PUT_INSERT';
            req_PutDelete.eventName = 'PUT_DELETE';
            req_PutUpdate.eventType = 'SYNC';
            req_PutInsert.eventType = 'SYNC';
            req_PutDelete.eventType = 'SYNC';
            req_PutUpdate.value = Record_id;
            req_PutInsert.value = Record_id;
            req_PutDelete.value = Record_id;
            req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req_PutInsert.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req_PutDelete.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            //Including the ClientInfo related to req_PutUpdate
            INTF_WebServicesDef.SVMXClient internalClInfo = new INTF_WebServicesDef.SVMXClient();
            internalClInfo.clientInfo = new List<String>{'appversion:16.49.002'};
            internalClInfo.clientType = 'iPad';
            req_PutUpdate.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{internalClInfo};
            req_PutInsert.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{internalClInfo};
            req_PutDelete.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{internalClInfo};
            
            INTF_WebServicesDef.SVMXMap syncTimeStampVM = new INTF_WebServicesDef.SVMXMap('SYNC_TIME_STAMP', string.valueOf(DateTime.now().addHours(1)));
            req_PutUpdate.valueMap.add(syncTimeStampVM);
            req_PutInsert.valueMap.add(syncTimeStampVM);
            req_PutDelete.valueMap.add(syncTimeStampVM);
        
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
            
            deleteVM.valueMap.add(fieldsVM);
            req_PutDelete.valueMap.add(deleteVM);
            
            //PUT INSERT - Parent_Object
            INTF_WebServicesDef.SVMXMap insertParentVM = new INTF_WebServicesDef.SVMXMap('Parent_Object', 'SVMXC__Service_Order__c');
            insertParentVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            List<INTF_WebServicesDef.SVMXMap> vls = new List<INTF_WebServicesDef.SVMXMap>();                                    
            INTF_WebServicesDef.SVMXMap jsonstr1 = new INTF_WebServicesDef.SVMXMap();                                           
            jsonstr1.key = '1';
            jsonstr1.value = '{"attributes":{"type":"SVMXC__Service_Order__c","url":""},"SVMXC__Problem_Description__c":"TEST DISCREPTION 1 ","SVMXC__Entitlement_Notes__c":"Test entitlement notes0", "SVMXC__Age__c":"1", "SVMXC__Drip__c":"false", "SVMXC__Scheduled_Date_Time__c" : "2016-09-20 08:59:37", "SVMXC__Scheduled_Date__c" : "2016-09-20"}';
            vls.add(jsonstr1);
              
            INTF_WebServicesDef.SVMXMap  parentFieldsVM = new INTF_WebServicesDef.SVMXMap();
            parentFieldsVM.key = 'Fields';
            parentFieldsVM.value = 'SVMXC__Requested_City__c,SVMXC__Billing_Information__c,SVMXC__Received_Location__c,SVMXC__Quantity_Shipped2__c,SVMXC__Applied_Rate_Type__c,Name,SVMXC__Received_Quantity2__c,SystemModstamp,SVMXC__Requested_Country__c,SVMXC__Quantity_Shipment_Initiated2__c,SVMXC__Canceled_On__c,SVMXC__Requested_Zip__c,SVMXC__Is_Billable__c,SVMXC__Received_State__c,SVMXC__Select__c,SVMXC__Total_Estimated_Price__c,SVMXC__Received_Country__c,SVMXC__Include_in_Quote__c,SVMXC__Consumed_From_Location__c,SVMXC__Log_Against__c,SVMXC__Product__c,SVMXC__Group_Member__c,SVMXC__Received_Zip__c,SVMXC__Billable_Quantity__c,SVMXC__Cost_Category__c,Id,SVMXC__Closed_By__c,SVMXC__End_Date_and_Time__c,LastModifiedById,SVMXC__Reference_Information__c,SVMXC__Service_Group__c,SVMXC__Requested_Location__c,SVMXC__Total_Line_Price__c,SVMXC__From_Location__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Expense_Type__c,SVMXC__Line_Type__c,CreatedDate,SVMXC__Actual_Price2__c,SVMXC__Date_Received__c,SVMXC__Work_Detail__c,SVMXC__Estimated_Price2__c,SVMXC__Billable_Line_Price__c,CurrencyIsoCode,SVMXC__Service_Order__c,RecordTypeId,SVMXC__Closed_On__c,SVMXC__Posted_To_Inventory__c,SVMXC__Date_Requested__c,SVMXC__Serial_Number__c,SVMXC__Received_City__c,CreatedById,SVMXC__Covered__c,SVMXC__Estimated_Quantity2__c,SVMXC__Actual_Quantity2__c,SVMXC__Canceled_By__c,SVMXC__Requested_Quantity2__c,LastActivityDate,SVMXC__Requested_Street__c,SVMXC__Received_Street__c,SVMXC__Activity_Type__c,SVMXC__Line_Status__c,LastModifiedDate,IsDeleted,SVMXC__Work_Description__c,SVMXC__Product_Warranty__c,SVMXC__Discount__c,SVMXC__Requested_State__c,SVMXC__Start_Date_and_Time__c';
            parentFieldsVM.valueMap = vls;    
            
            insertParentVM.valueMap.add(parentFieldsVM); 
            req_PutInsert.valueMap.add(insertParentVM);
            
            //Child_Object
            INTF_WebServicesDef.SVMXMap insertChildVM = new INTF_WebServicesDef.SVMXMap('Child_Object', 'SVMXC__Service_Order_Line__c');
            
            List<INTF_WebServicesDef.SVMXMap> vls1 = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap jsonstrChild = new INTF_WebServicesDef.SVMXMap();
            jsonstrChild.key = '4';
            jsonstrChild.value = '{"attributes":{"type":"SVMXC__Service_Order_Line__c","url":""},"Name":"TestOrderLine1","SVMXC__Activity_Type__c":"minor defects","SVMXC__Service_Order__c":"2", "SVMXC__Date_Requested__c" : "2016-09-20 08:59:37"}';
            vls1.add(jsonstrChild);
            
            INTF_WebServicesDef.SVMXMap  childFieldsVM = new INTF_WebServicesDef.SVMXMap();
            childFieldsVM.key = 'Fields';
            childFieldsVM.value = 'SVMXC__Requested_City__c,SVMXC__Billing_Information__c,SVMXC__Received_Location__c,SVMXC__Quantity_Shipped2__c,SVMXC__Applied_Rate_Type__c,Name,SVMXC__Received_Quantity2__c,SystemModstamp,SVMXC__Requested_Country__c,SVMXC__Quantity_Shipment_Initiated2__c,SVMXC__Canceled_On__c,SVMXC__Requested_Zip__c,SVMXC__Is_Billable__c,SVMXC__Received_State__c,SVMXC__Select__c,SVMXC__Total_Estimated_Price__c,SVMXC__Received_Country__c,SVMXC__Include_in_Quote__c,SVMXC__Consumed_From_Location__c,SVMXC__Log_Against__c,SVMXC__Product__c,SVMXC__Group_Member__c,SVMXC__Received_Zip__c,SVMXC__Billable_Quantity__c,SVMXC__Cost_Category__c,Id,SVMXC__Closed_By__c,SVMXC__End_Date_and_Time__c,LastModifiedById,SVMXC__Reference_Information__c,SVMXC__Service_Group__c,SVMXC__Requested_Location__c,SVMXC__Total_Line_Price__c,SVMXC__From_Location__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Expense_Type__c,SVMXC__Line_Type__c,CreatedDate,SVMXC__Actual_Price2__c,SVMXC__Date_Received__c,SVMXC__Work_Detail__c,SVMXC__Estimated_Price2__c,SVMXC__Billable_Line_Price__c,CurrencyIsoCode,SVMXC__Service_Order__c,RecordTypeId,SVMXC__Closed_On__c,SVMXC__Posted_To_Inventory__c,SVMXC__Date_Requested__c,SVMXC__Serial_Number__c,SVMXC__Received_City__c,CreatedById,SVMXC__Covered__c,SVMXC__Estimated_Quantity2__c,SVMXC__Actual_Quantity2__c,SVMXC__Canceled_By__c,SVMXC__Requested_Quantity2__c,LastActivityDate,SVMXC__Requested_Street__c,SVMXC__Received_Street__c,SVMXC__Activity_Type__c,SVMXC__Line_Status__c,LastModifiedDate,IsDeleted,SVMXC__Work_Description__c,SVMXC__Product_Warranty__c,SVMXC__Discount__c,SVMXC__Requested_State__c,SVMXC__Start_Date_and_Time__c';
            childFieldsVM.valueMap = vls1;  
            
            insertChildVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            insertChildVM.valueMap.add(childFieldsVM);
            req_PutInsert.valueMap.add(insertChildVM);
            
            //PUT UPDATE
            INTF_WebServicesDef.SVMXMap updateVM = new INTF_WebServicesDef.SVMXMap('Object_Name', 'SVMXC__Service_Order_Line__c');
            updateVM.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            SVMXC.INTF_WebServicesDef.SVMXMap updateFieldsVM = new SVMXC.INTF_WebServicesDef.SVMXMap();
            updateFieldsVM.key = 'Fields';
            updateFieldsVM.value = 'SVMXC__Requested_City__c,SVMXC__Billing_Information__c,SVMXC__Received_Location__c,SVMXC__Quantity_Shipped2__c,SVMXC__Applied_Rate_Type__c,Name,SVMXC__Received_Quantity2__c,SystemModstamp,SVMXC__Requested_Country__c,SVMXC__Quantity_Shipment_Initiated2__c,SVMXC__Canceled_On__c,SVMXC__Requested_Zip__c,SVMXC__Is_Billable__c,SVMXC__Received_State__c,SVMXC__Select__c,SVMXC__Total_Estimated_Price__c,SVMXC__Received_Country__c,SVMXC__Include_in_Quote__c,SVMXC__Consumed_From_Location__c,SVMXC__Log_Against__c,SVMXC__Product__c,SVMXC__Group_Member__c,SVMXC__Received_Zip__c,SVMXC__Billable_Quantity__c,SVMXC__Cost_Category__c,Id,SVMXC__Closed_By__c,SVMXC__End_Date_and_Time__c,LastModifiedById,SVMXC__Reference_Information__c,SVMXC__Service_Group__c,SVMXC__Requested_Location__c,SVMXC__Total_Line_Price__c,SVMXC__From_Location__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Expense_Type__c,SVMXC__Line_Type__c,CreatedDate,SVMXC__Actual_Price2__c,SVMXC__Date_Received__c,SVMXC__Work_Detail__c,SVMXC__Estimated_Price2__c,SVMXC__Billable_Line_Price__c,CurrencyIsoCode,SVMXC__Service_Order__c,RecordTypeId,SVMXC__Closed_On__c,SVMXC__Posted_To_Inventory__c,SVMXC__Date_Requested__c,SVMXC__Serial_Number__c,SVMXC__Received_City__c,CreatedById,SVMXC__Covered__c,SVMXC__Estimated_Quantity2__c,SVMXC__Actual_Quantity2__c,SVMXC__Canceled_By__c,SVMXC__Requested_Quantity2__c,LastActivityDate,SVMXC__Requested_Street__c,SVMXC__Received_Street__c,SVMXC__Activity_Type__c,SVMXC__Line_Status__c,LastModifiedDate,IsDeleted,SVMXC__Work_Description__c,SVMXC__Product_Warranty__c,SVMXC__Discount__c,SVMXC__Requested_State__c,SVMXC__Start_Date_and_Time__c';
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj3.key = string.valueOf(DateTime.now().addHours(1));
            obj3.value = '{"IsDeleted":"false","SVMXC__Is_Billable__c":"true","SVMXC__Use_Price_From_Pricebook__c":"true","SVMXC__Line_Type__c":"Parts","SVMXC__Select__c":"false","SVMXC__Total_Line_Price__c":"50000.0","SVMXC__Posted_To_Inventory__c":"false","SVMXC__Total_Estimated_Price__c":"0.0","SVMXC__Actual_Price2__c":"50000.0","SVMXC__Line_Status__c":"Open","Id":"' + WOLine.Id + '","SVMXC__Include_in_Quote__c":"false","SVMXC__Service_Order__c":"' + WO.Id + '","SVMXC__Actual_Quantity2__c":"1.0"}'; 
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj4.key = string.valueOf(DateTime.now().addHours(1));
            obj4.value = '{"IsDeleted":"false","SVMXC__Is_Billable__c":"true","SVMXC__Use_Price_From_Pricebook__c":"true","SVMXC__Line_Type__c":"Parts","SVMXC__Select__c":"false","SVMXC__Total_Line_Price__c":"50000.0","SVMXC__Posted_To_Inventory__c":"false","SVMXC__Total_Estimated_Price__c":"0.0","SVMXC__Actual_Price2__c":"50000.0","SVMXC__Line_Status__c":"Open","Id":"' + 'testtesttesttes' + '","SVMXC__Include_in_Quote__c":"false","SVMXC__Service_Order__c":"' + WO.Id + '","SVMXC__Actual_Quantity2__c":"1.0"}';
           
            updateFieldsVM.valueMap.add(obj3);
            updateFieldsVM.valueMap.add(obj4);  //wrong Id provided to cover error scenario
                
            updateVM.valueMap.add(updateFieldsVM);
            req_PutUpdate.valueMap.add(updateVM);
            
            INTF_WebServicesDef.SVMXMap putDeleteVM = new INTF_WebServicesDef.SVMXMap('PUT_DELETE','');
            INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
            INTF_WebServicesDef.SVMXMap putInsertVM = new INTF_WebServicesDef.SVMXMap('PUT_INSERT','');
            putDeleteVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutDelete};
            putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
            putInsertVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutInsert};
            
            req_OneCallSync.valueMap.add(putDeleteVM);
            req_OneCallSync.valueMap.add(putInsertVM);
            req_OneCallSync.valueMap.add(putUpdateVM);
            req_OneCallSync.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0')); //included last index
        
            Test.startTest();
            //Executing the Sync
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMResponse response = txnCache.oneCallSync(req_OneCallSync);
            system.debug('Final Response: ' + response);
            
            Boolean isCallBack = false;
            List<INTF_WebServicesDef.SVMXMap> callBackVM = new List<INTF_WebServicesDef.SVMXMap>();
            
            for(INTF_WebServicesDef.SVMXMap eachValueMap : response.valueMap)
            {
                if(eachValueMap.key == 'CALL_BACK' && eachValueMap.value != null && eachValueMap.value != '')
                {
                    isCallBack = Boolean.valueOf(eachValueMap.value);
                    callBackVM = eachValueMap.valueMap;
                    break;
                }   
            }
           
            if(isCallBack)
            {
                INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
                req.eventName = 'ONE_CALL_SYNC';
                req.eventType = 'SYNC';
                req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                
                clInfo = new INTF_WebServicesDef.SVMXClient();
                clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:1234567891'};
                clInfo.clientType = 'iPad';
                req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
                req.value = Record_id;
                INTF_WebServicesDef.SVMXMap callbck2 = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
                callbck2.valueMap = callBackVM;
                req.valueMap.add(callbck2);
                INTF_WebServicesDef.INTF_SFMResponse resp = txnCache.oneCallSync(req);
                
                for(INTF_WebServicesDef.SVMXMap eachValueMap : resp.valueMap)
                {
                    if(eachValueMap.key == 'CALL_BACK' && eachValueMap.value != null && eachValueMap.value != '')
                    {
                        isCallBack = Boolean.valueOf(eachValueMap.value);
                        callBackVM = eachValueMap.valueMap;
                        break;
                    }   
                }
                
                if(isCallBack)
                {
                    INTF_WebServicesDef.INTF_SFMRequest req1 = new INTF_WebServicesDef.INTF_SFMRequest();
                    req1.eventName = 'ONE_CALL_SYNC';
                    req1.eventType = 'SYNC';
                    req1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                    
                    clInfo = new INTF_WebServicesDef.SVMXClient();
                    clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:1234567891'};
                    clInfo.clientType = 'iPad';
                    req1.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                    
                    req1.value = Record_id;
                    INTF_WebServicesDef.SVMXMap callbck3 = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
                    callbck3.valueMap = callBackVM;
                    req1.valueMap.add(callbck3);
                    system.debug('++++test Second call back - req1 = '+req1);
                    INTF_WebServicesDef.INTF_SFMResponse resp1 = txnCache.oneCallSync(req1);
                   
                }
            }
            
            txnCache.addCallBackContext('ABCDEEFGHIJKLMNOPQRSTUVWXYZ', 'GET_DELETE_DC_OPTIMZED', response);
            txnCache.addCallBackContext('ABCDEEFGHIJKLMNOPQRSTUVWXYZ', 'PUT_UPDATE', response);
            Datetime dtFromDateTime = system.now().addDays(-1);
            Datetime dtToDateTime = system.now().addDays(1);
            txnCache.GetObjsTaggedToEvents(dtFromDateTime, dtToDateTime, new Set<String>{'Account'});
                   
            //GET UPDATE DC OPTIMIZED
            INTF_WebServicesDef.SVMXMap callBackContext = new INTF_WebServicesDef.SVMXMap('CALL_BACK','true');
            callBackContext.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            callBackContext.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT','GET_UPDATE_DC_OPTIMZED'));
            req_OneCallSync.valueMap.add(callBackContext);
            system.debug('++++test Third call back - req1 = '+req_OneCallSync);
            response = txnCache.oneCallSync(req_OneCallSync);
                
            txnCache.addLimitVM('CALL_BACK_CONTEXT', response);
            Test.stopTest();    
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
    }
    
    static testMethod void testGetProductIQData()
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        Id profileId = UserInfo.getProfileId();
        
        insertConfigData();
        createIPADSetting();        
        system.debug('+++++ grpProfileId = '+grpProfileId);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c dcProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c=\'Open\'', SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c');
        Database.SaveResult result1 = Database.insert(dcProcess);
        Id dcProcessID = result1.getId(); 
         
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = dcProcessID, SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //ADC
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        //insert a location
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        Database.SaveResult result = Database.insert(location1);
        Id locationId = result.getId();     
        
        Account acc1 = new Account();
        acc1.Name = 'Account1';
        result = Database.insert(acc1);
        Id accId = result.getId(); 
                        
        Product2 product001 = new Product2();
        product001.SVMXC__Product_Line__c = 'Accessory';
        product001.Family = 'Accessory';
        product001.Name = 'Laptop Bags';
        insert product001;
        
        //insert a location
        SVMXC__Site__c location2 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore1', SVMXC__Parent__c=locationId);
        result = Database.insert(location2);
        locationId = result.getId();  
        
        //insert a location
        SVMXC__Site__c location3 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore2', SVMXC__Parent__c=locationId);
        result = Database.insert(location3);
        locationId = result.getId();  
        
        //insert a location
        SVMXC__Site__c location4 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore3', SVMXC__Parent__c=locationId);
        result = Database.insert(location4);
        locationId = result.getId();  
        
        //insert a location
        SVMXC__Site__c location5 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore4', SVMXC__Parent__c=locationId);
        result = Database.insert(location5);
        locationId = result.getId();  
        
        //insert a location
        SVMXC__Site__c location6 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore5', SVMXC__Parent__c=locationId);
        result = Database.insert(location6);
        locationId = result.getId();  
        
        //Inserting IB
        SVMXC__Installed_Product__c topLevelInstalledProduct = new SVMXC__Installed_Product__c();
        topLevelInstalledProduct.SVMXC__Product__c = product001.Id; 
        topLevelInstalledProduct.SVMXC__Site__c = locationId;
        insert topLevelInstalledProduct;
        
        //Insert wO
        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        WO.SVMXC__Site__c = locationId;
        WO.SVMXC__Order_Status__c = 'Open';
        WO.SVMXC__Component__c = topLevelInstalledProduct.Id ;
        WO.SVMXC__Company__c = accId;
        insert WO;
            
        //insert a location
        SVMXC__Site__c location7 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore6', SVMXC__Parent__c=locationId);
        result = Database.insert(location7);
        locationId = result.getId();    
        
        SVMXC__Installed_Product__c installedProduct001 = new SVMXC__Installed_Product__c();
        installedProduct001.SVMXC__Top_Level__c = topLevelInstalledProduct.Id; 
        installedProduct001.SVMXC__Product__c = product001.Id; 
        installedProduct001.SVMXC__Site__c = locationId;
        insert installedProduct001;
        
        //insert a location
        SVMXC__Site__c location8 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore7', SVMXC__Parent__c=locationId);
        result = Database.insert(location8);
        locationId = result.getId();  
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        insert evntObj;
        
        try{
            Test.startTest();
        
            //Last Index = 0    
            INTF_TxnCache txnObj = new INTF_TxnCache();
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', string.valueOf(System.now()-10)));
            
            INTF_WebServicesDef.SVMXClient  clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:1234567891'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            
            /*INTF_WebServicesDef.SVMXMap callBackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
            callBackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CURRENT_LEVEL_LOCATION_ID', locationId));
            req.valueMap.add(callBackVM);*/
            
            resp = txnObj.getProductIQData(req, profileId);
            system.debug(LoggingLevel.WARN, 'response = :' + resp);

            //Level = 1, LAST INDEX = 0
            req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('INDEX', '1'));
            resp = txnObj.getProductIQData(req, profileId);
            
            //Level = 1, LAST INDEX = 1
            req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '1'));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('INDEX', '1'));
            resp = txnObj.getProductIQData(req, profileId);
            system.debug(LoggingLevel.WARN, 'response = :' + resp);
            
            //Last Index = 1
            req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '1'));
            resp = txnObj.getProductIQData(req, profileId);
            system.debug(LoggingLevel.WARN, 'response = :' + resp);

            //Last Index = 2            
            req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '2'));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true'));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', '2017-07-21 15:09:48'));
            
            INTF_WebServicesDef.SVMXMap callbackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
            SVMXC.INTF_WebServicesDef.SVMXMap woVM1 = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT_WO', 'SVMXC__Service_Order__c');
            woVM1.values = new List<String>{'a0H0G00000cr118UAA'};
            SVMXC.INTF_WebServicesDef.SVMXMap woVM2 = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT_LOC', 'SVMXC__Site__c');
            woVM2.values = new List<String>{'a0H0G00000cr118UAA'};
            SVMXC.INTF_WebServicesDef.SVMXMap woVM3 = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT_IB', 'SVMXC__Installed_Product__c');
            woVM3.values = new List<String>{'a0H0G00000cr118UAA'};
            
            SVMXC.INTF_WebServicesDef.SVMXMap woVM4 = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_HIERARCHY_IB', 'SVMXC__Installed_Product__c');
            woVM4.values = new List<String>{'a0H0G00000cr118UAA'};
            
            callbackVM.valueMap.add(woVM1);
            callbackVM.valueMap.add(woVM2);
            callbackVM.valueMap.add(woVM3);
            callbackVM.valueMap.add(woVM4);
            
            req.valueMap.add(callbackVM);
            
            resp = txnObj.getProductIQData(req, profileId);
            system.debug(LoggingLevel.WARN, 'response = :' + resp);            
            
            req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'GET_DELETE_PRODUCTIQ_DATA';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', String.valueOf(DateTime.now()-1)));
            resp = txnObj.getDeletedProductIQData(req, profileId);
            system.debug(LoggingLevel.WARN, 'response = :' + resp);

            //Get Picklist definition 

            SVMXC__SM_TA_Picklist_Definition__c pickDef = new SVMXC__SM_TA_Picklist_Definition__c();
            pickDef.SVMXC__SM_Description__c = 'test def';
            pickDef.SVMXC__SM_Name__c = 'test def';
            pickDef.SVMXC__SM_Values__c = 'test class value';
            Database.SaveResult result2 = Database.insert(pickDef);
            String picklistID = result2.getId();      

            req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'GET_PIQ_PICKLIST_DEFINITION';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', String.valueOf(DateTime.now()-10)));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('PICKLIST_DEF_IDS', '', new List<String>{picklistID}));
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('PICKLIST_DEF_LAST_ID', '0'));
            resp = txnObj.getDeltaPicklistDef(req, profileId);

            Test.stopTest();
        }catch(Exception Ex){
                system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }  
    }
    
    static testMethod void productIQProductAttributeTest()
    {
        try{
            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
                
            Product2 product001 = new Product2();
            product001.SVMXC__Product_Line__c = 'Accessory';
            product001.Family = 'Accessory';
            product001.Name = 'Laptop Bags';
            insert product001;
            
            SVMXC__SM_Attributes_Template__c attrTempl = new SVMXC__SM_Attributes_Template__c();
            attrTempl.SVMXC__SM_Active__c = true;
            attrTempl.SVMXC__SM_Attr_Type_Template__c = 'TECHNICAL';
            insert attrTempl;
            
            SVMXC__SM_Product_Attributes__c attrProd = new SVMXC__SM_Product_Attributes__c();
            attrProd.SVMXC__SM_Product__c = product001.Id;
            attrProd.SVMXC__SM_Attribute_Template_Id__c = attrTempl.Id;
            attrProd.SVMXC__SM_Product_Line__c = 'Accessory';
            attrProd.SVMXC__SM_Product_Family__c = 'Accessory';
            insert attrProd;
            
            insertConfigData();
            string svmxGrpProfileId = grpProfileId;
            system.debug('+++++++svmxGrpProfileId = '+svmxGrpProfileId);
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Ownership_Type__c = 'All Records', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(dcConfigData);
        
            //Svmx process for ADC - SVMX_Rule
            SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = ' Name != null ');
            insert advDCProcess;
        
            //ADC
            SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__Ownership_Type__c = 'All Records' , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(adcConfigData);
            
            insert configDataList;
            
            Test.startTest();
        
            INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
            request.eventName = 'SYNC_PRODUCTIQ_PRODUCT_ATTR';
            request.eventType = 'SYNC';
            request.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap lstVM = new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', string.valueOf(DateTime.now().addDays(-1)));
            request.valueMap.add(lstVM);
            
            INTF_WebServicesDef.INTF_SFMResponse response = INTF_WebServicesDef.INTF_DataSync_WS(request);
             //Including Callback
           /* INTF_WebServicesDef.SVMXMap callbackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true');
            callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCT_CALL_BACK_ID', 'test1'));
            callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCT_NEXT_CALL_BACK_ID', 'test2'));
            callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODUCT_ATTRIBUTE_CALL_BACK_ID', 'test3'));
            request.valueMap.add(callbackVM);*/ 
            Test.stopTest();
        
            system.debug(LoggingLevel.WARN, '+++++response = :' + response.message);
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    static testMethod void productIQIBAttributeTest()
    {
        try{
            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            Product2 product001 = new Product2();
            product001.SVMXC__Product_Line__c = 'Accessory';
            product001.Family = 'Accessory';
            product001.Name = 'Laptop Bags';
            insert product001;
            
            SVMXC__Installed_Product__c topLevelInstalledProduct = new SVMXC__Installed_Product__c();
            topLevelInstalledProduct.SVMXC__Product__c = product001.Id; 
            insert topLevelInstalledProduct;
            
            SVMXC__Installed_Product__c installedProduct001 = new SVMXC__Installed_Product__c();
            installedProduct001.SVMXC__Top_Level__c = topLevelInstalledProduct.Id; 
            installedProduct001.SVMXC__Product__c = product001.Id; 
            insert installedProduct001;
            
            SVMXC__SM_IB_Attributes_Template_Instance__c templInst = new SVMXC__SM_IB_Attributes_Template_Instance__c();
            templInst.SVMXC__SM_Attr_Type__c = 'CONFIG';
            templInst.SVMXC__SM_Installed_Product_Id__c = installedProduct001.Id;
            insert templInst;
            
            SVMXC__SM_IB_Attributes_History__c attrHistory = new SVMXC__SM_IB_Attributes_History__c();
            attrHistory.SVMXC__SM_Installed_Product_Id__c = installedProduct001.Id;
            attrHistory.SVMXC__SM_Instance_Template_Id__c = templInst.Id;
            insert attrHistory;
        
            insertConfigData();
            string svmxGrpProfileId = grpProfileId;
            system.debug('+++++++svmxGrpProfileId = '+svmxGrpProfileId);
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Ownership_Type__c = 'All Records', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(dcConfigData);
        
            //Svmx process for ADC - SVMX_Rule
            SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = ' Name != null ');
            insert advDCProcess;
        
            //ADC
            SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__Ownership_Type__c = 'All Records' , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(adcConfigData);
            
            insert configDataList;     
        
            Test.startTest();
        
            List<string> lstTopLevelIBIds = new List<string>();
            lstTopLevelIBIds.add(topLevelInstalledProduct.Id);
            
            INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
            request.eventName = 'SYNC_PRODUCTIQ_IB_ATTR';
            request.eventType = 'SYNC';
            request.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap lstVM = new INTF_WebServicesDef.SVMXMap('PRODUCTIQ_LAST_SYNC', string.valueOf(DateTime.now().addDays(-1)));
            request.valueMap.add(lstVM);
            INTF_WebServicesDef.SVMXMap topLevelIbIdsVM = new INTF_WebServicesDef.SVMXMap('TOP_LEVEL_IB_IDS', '');
            topLevelIbIdsVM.values = lstTopLevelIBIds;
            request.valueMap.add(topLevelIbIdsVM);
            
            INTF_WebServicesDef.INTF_DataSync_WS(request);
            
            Test.stopTest();
        
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    static testMethod void testDownloadCriteria()
    {
        try{

        insertConfigData(); 
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
        
        //insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;
            
        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__Company__c = acc.Id;
        WO.SVMXC__Product__c = product1.Id;
        WO.SVMXC__City__c = 'Bangalore';
        Database.SaveResult result = Database.insert(WO);
        Id workOrderID = result.getId();       
        
        INTF_TxnCache txnCache = new INTF_TxnCache();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res1 = new INTF_WebServicesDef.INTF_SFMResponse();
        Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        Req.eventType='SYNC';
        Req.eventName='DOWNLOAD_CREITERIA_SYNC';
        Req.values=new List<string>{workOrderID};
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
       
        INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
        clientInfoReq.clientType = 'iPad';
        clientInfoReq.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        Req.clientInfo.add(clientInfoReq);
        
        tableList1.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        
        List<INTF_WebServicesDef.SVMXMap> lstDCObjects = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap obj1 = new INTF_WebServicesDef.SVMXMap();
        obj1.key = 'DOWNLOAD_CRITERIA_OBJECTS';        
        
        INTF_WebServicesDef.SVMXMap DCObjects = new INTF_WebServicesDef.SVMXMap();
        DCObjects.value = '';
        lstDCObjects.add(DCObjects);
        obj1.valueMap = lstDCObjects;
        
        tableList1.add(obj1);
        
        map<String, map<String, String>> mapObjToQry = new map<String, map<String, String>>();
            
        Req.valueMap = tableList1;
        Req.value = '123456789';
        SVMXC__SM_Request_Cache__c requestCache = new SVMXC__SM_Request_Cache__c(SVMXC__SM_Device_UDID__c = '123456789', SVMXC__SM_User_Id__c = UserInfo.getUserId(), SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry));
        Database.SaveResult Result2 = Database.insert(requestCache);
        test.startTest();
            Res1 = txnCache.getDownloadCriteriaRecords(Req);
            
            map<String, String> mapDCObjToDetails = new map<String, String>();
            mapDCObjToDetails.put('OperationType', 'Select');
            mapDCObjToDetails.put('IterationIndex', '0');
            mapDCObjToDetails.put('ObjectName', 'SVMXC__Service_Order__c');
            //string strQuery = 'SELECT Id FROM SVMXC__Service_Order__c WHERE LastModifiedDate >= :LastSynchTime and isDeleted = false and ';
            string strQuery = 'SELECT Id FROM SVMXC__Service_Order__c WHERE isDeleted = false and ';
            mapDCObjToDetails.put('SOQLQuery', strQuery);
            mapDCObjToDetails.put('Status', 'NOT_EXECUTED');
            mapObjToQry.put('SVMXC__Service_Order__c', mapDCObjToDetails);
            
            requestCache.SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry);
            update requestCache;
            
            Res1 = txnCache.getDownloadCriteriaRecords(Req);  //Call the method again with the request cache
            
            //Update the index in the MAp
            mapDCObjToDetails.put('IterationIndex','1');
            mapObjToQry.put('SVMXC__Service_Order__c', mapDCObjToDetails);
            
            requestCache.SVMXC__SM_SOQL_Query__c = JSON.serialize(mapObjToQry);
            update requestCache;
            
            Res1 = txnCache.getDownloadCriteriaRecords(Req);  //Call the method again with higher iteration index
            
        test.stopTest();
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    } 
    
    //OneCallSync for GET_UPDATE_DC OPTIMIZED
    static testMethod void oneCallSyncReqCacheGetUpdateDC()
    {
        try{
            
            insertConfigData(); //insert config/setting related data
            
            //Creating Sample Data for the sync to work
            List<SVMXC__Service_Order_Line__c> lstWOLine = new List<SVMXC__Service_Order_Line__c>();
    
            SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
            WO.SVMXC__City__c = 'Bangalore';
            insert WO;
            
            String Record_id = '';
            SVMXC__SM_Request_Cache__c requestRecord2 = new SVMXC__SM_Request_Cache__c(SVMXC__SM_Device_UDID__c = '1234567891', SVMXC__SM_User_Id__c = UserInfo.getUserId());
            Database.SaveResult Result2 = Database.insert(requestRecord2);
            Record_id = Result2.getId();
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            insert dcConfigData;
            
            Test.startTest();
        
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventName = 'ONE_CALL_SYNC';
            req.eventType = 'SYNC';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:1234567891'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
            //GET UPDATE DC OPTIMIZED
            INTF_WebServicesDef.SVMXMap callBackContext = new INTF_WebServicesDef.SVMXMap('CALL_BACK','true');
            callBackContext.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            callBackContext.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT','GET_UPDATE_DC_OPTIMZED'));
            req.valueMap.add(callBackContext);
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0')); // last index
            
            //Executing the Sync    
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMResponse resp = txnCache.oneCallSync(req);
            
            Test.stopTest();
        
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
    }
    
    //OneCallSync - GET_UPDATE_DC OPTIMIZED for Sync Request
    static testMethod void oneCallSyncGetUpdateDCSyncReq()
    {
        try{
            
            insertConfigData(); //insert cconfig/setting related data
            
            //Creating Sample Data for the sync to work
            List<SVMXC__Service_Order_Line__c> lstWOLine = new List<SVMXC__Service_Order_Line__c>();
    
            SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
            WO.SVMXC__City__c = 'Bangalore';
            insert WO;
            
            String Record_id = '';
            SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '1234567891');
            Database.SaveResult Result = Database.insert(requestRecord);
            Record_id = Result.getId();
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            insert dcConfigData;
            
            Test.startTest();
        
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventName = 'ONE_CALL_SYNC';
            req.eventType = 'SYNC';
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            
            //GET UPDATE DC OPTIMIZED
            INTF_WebServicesDef.SVMXMap callBackContext = new INTF_WebServicesDef.SVMXMap('CALL_BACK','true');
            callBackContext.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            callBackContext.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT','GET_UPDATE_DC_OPTIMZED'));
            req.valueMap.add(callBackContext);
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0')); // last index
            
            //Executing the Sync    
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMResponse resp = txnCache.oneCallSync(req);
            
            Test.stopTest();
        
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
    }
    
    static void createEvents()
    {
        wo =  new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        insert wo;
        
        Task tskObj = new Task();
        tskObj.OwnerId = UserInfo.getUserId();
        tskObj.ActivityDate = DateTime.now().date();
        insert tskObj;
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        insert evntObj;
        
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
    }
    
    //Method for PUT_Update --> updateRecordsFromClient
    static testMethod void testUpdateRecordsFromClient()
    {
        try {
            
            Test.startTest();
        
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
            INTF_WebServicesDef.INTF_SFMResponse resAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
            Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
            Req.eventType='SYNC';
            Req.eventName='PUT_UPDATE';
            
            INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
            clientInfoReq.clientType = 'iPad';
            clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64'};
            Req.clientInfo.add(clientInfoReq);
            
            List<INTF_WebServicesDef.SVMXMap> tableList = new List<INTF_WebServicesDef.SVMXMap>();
            
            List<INTF_WebServicesDef.SVMXMap> tableContents = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap firstObj = new INTF_WebServicesDef.SVMXMap();
            firstObj.key = 'Fields';
        
            SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
            WorkOrderData.SVMXC__Priority__c='High';
            WorkOrderData.SVMXC__Order_Type__c='Open';
            WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
            WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
            WorkOrderData.SVMXC__Longitude__c=120.36;
            WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
            WorkOrderData.SVMXC__PM_Tasks_Created__c= true ;
            insert WorkOrderData;
            System.assertEquals(true, WorkOrderData != null);
            
            firstObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('localId', JSON.serialize(WorkOrderData)));
            tableContents.add(firstObj); 
            
            INTF_WebServicesDef.SVMXMap firstObj1 = new INTF_WebServicesDef.SVMXMap();
            firstObj1.key = 'object_name';
            firstObj1.value = 'SVMXC__Service_Order__c';
            firstObj1.valueMap = tableContents;
            tableList.add(firstObj1);
            
            Req.valueMap = tableList;
            Req.value = '001';
            System.debug(LoggingLevel.INFO,'Test class request '+Req);
            //Res = str.UpdateClientDataIntoBase(Req);
            
            Map<String, Datetime> mapRecordIdToLST = new Map<string, Datetime>();
            mapRecordIdToLST.put(WorkOrderData.Id, datetime.now() - 2);
        
            resAdvFieldMerge.valueMap = txnCache.updateRecordsFromClient(Req, DateTime.now() - 1, 'Allow user to choose', mapRecordIdToLST);
            
            Test.stopTest();
        
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    //updateRecordsFromClient  --> client Override
    static testMethod void testUpdateRecordsFromClientOverride()
    {
        try {
            
            //Insert work Order
            SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
            WorkOrderData.SVMXC__Priority__c='High';
            WorkOrderData.SVMXC__Order_Type__c='Open';
            WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
            WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
            WorkOrderData.SVMXC__Longitude__c=120.36;
            WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
            WorkOrderData.SVMXC__PM_Tasks_Created__c= true ;
            WorkOrderData.SVMXC__Proforma_Invoice_Amount__c = 1000.00;
            Database.SaveResult Result = Database.insert(WorkOrderData);
            string Record_id = Result.getId();
            
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
            INTF_WebServicesDef.INTF_SFMResponse resAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
            Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
            Req.eventType='SYNC';
            Req.eventName='PUT_UPDATE';
            
            INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
            clientInfoReq.clientType = 'iPad';
            clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64'};
            Req.clientInfo.add(clientInfoReq);
            
            List<INTF_WebServicesDef.SVMXMap> tableList = new List<INTF_WebServicesDef.SVMXMap>();
            
            //give the syncTimeStamp
            INTF_WebServicesDef.SVMXMap syncTimeStampLine = new INTF_WebServicesDef.SVMXMap('SYNC_TIME_STAMP', String.valueOf(DateTime.now() - 1));
            tableList.add(syncTimeStampLine); 
            
            //form value for Fields
            Map<String,string> fieldsPerRecordMap = new Map<String,string>();
            fieldsPerRecordMap.put('Id',Record_id);
            fieldsPerRecordMap.put('SVMXC__Priority__c','High');
            fieldsPerRecordMap.put('SVMXC__Order_Type__c','Open');
            fieldsPerRecordMap.put('SVMXC__Group_Email__c','abc@xyz.com');
            fieldsPerRecordMap.put('SVMXC__Scheduled_Date__c',string.ValueOf(date.newinstance(2010,12,17)));
            fieldsPerRecordMap.put('SVMXC__PM_Tasks_Created__c','true');  
            fieldsPerRecordMap.put('SVMXC__Longitude__c','120.36');  
            fieldsPerRecordMap.put('SVMXC__Proforma_Invoice_Amount__c','1000.36');  
            fieldsPerRecordMap.put('SVMXC__Actual_Initial_Response__c',String.valueOf(datetime.newInstance(2011, 12, 1, 12, 30, 2)));  
            
            List<INTF_WebServicesDef.SVMXMap> tableContents = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap firstObj = new INTF_WebServicesDef.SVMXMap();
            firstObj.key = 'Fields';
            firstObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('localId', JSON.serialize(fieldsPerRecordMap)));
            
            Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
            fieldsFromClientMap.put('Id',Record_id);
            fieldsFromClientMap.put('SVMXC__Priority__c','High');
            fieldsFromClientMap.put('SVMXC__Order_Type__c','In process');
            fieldsFromClientMap.put('SVMXC__Group_Email__c','abc1@xyz.com');
            fieldsFromClientMap.put('SVMXC__Scheduled_Date__c',string.ValueOf(date.newinstance(2010,12,17)));
            fieldsFromClientMap.put('SVMXC__PM_Tasks_Created__c','false');  
            fieldsFromClientMap.put('SVMXC__Longitude__c','120.36');  
            fieldsFromClientMap.put('SVMXC__Actual_Initial_Response__c',String.valueOf(datetime.newInstance(2011, 12, 11, 12, 30, 2)));    
            
            INTF_WebServicesDef.SVMXMap newObj = new INTF_WebServicesDef.SVMXMap();
            newObj.key = 'BEFORE_SAVE';
            newObj.values = new List<string>{JSON.serialize(fieldsFromClientMap)};
            firstObj.valueMap.add(newObj);
            tableContents.add(firstObj); 
            
            INTF_WebServicesDef.SVMXMap firstObj1 = new INTF_WebServicesDef.SVMXMap();
            firstObj1.key = 'object_name';
            firstObj1.value = 'SVMXC__Service_Order__c';
            firstObj1.valueMap = tableContents;
            tableList.add(firstObj1);
            
            System.assertEquals(true, WorkOrderData != null);
            
            Req.valueMap = tableList;
            Req.value = '001';
            System.debug(LoggingLevel.INFO,'Test class request '+Req);
            //Res = str.UpdateClientDataIntoBase(Req);
            
            //update the work order data 
            WorkOrderData.SVMXC__Priority__c='Low';
            WorkOrderData.SVMXC__Actual_Initial_Response__c = datetime.newInstance(2011, 12, 11, 12, 30, 2);
            WorkOrderData.SVMXC__Longitude__c = 121.36;
            WorkOrderData.SVMXC__PM_Tasks_Created__c = TRUE;
            WorkOrderData.SVMXC__Proforma_Invoice_Amount__c = 1000.50;
            update WorkOrderData;
        
            Map<String, Datetime> mapRecordIdToLST = new Map<string, Datetime>();
            Test.startTest();
        
                resAdvFieldMerge.valueMap = txnCache.updateRecordsFromClient(Req, DateTime.now() , 'Allow user to choose',mapRecordIdToLST);
                
            Test.stopTest();
        
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
  
    //updateRecordsFromClient  --> client Override - scenario2
    static testMethod void testUpdateRecordsFromClientOverride2()
    {
        try {
            
            //Insert work Order
            SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
            WorkOrderData.SVMXC__Priority__c='High';
            WorkOrderData.SVMXC__Order_Type__c='Open';
            WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
            WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
            WorkOrderData.SVMXC__Longitude__c=120.36;
            WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
            WorkOrderData.SVMXC__PM_Tasks_Created__c= true ;
            Database.SaveResult Result = Database.insert(WorkOrderData);
            string Record_id = Result.getId();
            
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
            INTF_WebServicesDef.INTF_SFMResponse resAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
            Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
            Req.eventType='SYNC';
            Req.eventName='PUT_UPDATE';
            
            INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
            clientInfoReq.clientType = 'iPad';
            clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64'};
            Req.clientInfo.add(clientInfoReq);
            
            List<INTF_WebServicesDef.SVMXMap> tableList = new List<INTF_WebServicesDef.SVMXMap>();
            
            //give the syncTimeStamp
            INTF_WebServicesDef.SVMXMap syncTimeStampLine = new INTF_WebServicesDef.SVMXMap('SYNC_TIME_STAMP', String.valueOf(DateTime.now() - 1));
            tableList.add(syncTimeStampLine); 
            
            //form value for Fields
            Map<String,string> fieldsPerRecordMap = new Map<String,string>();
            fieldsPerRecordMap.put('Id',Record_id);
            fieldsPerRecordMap.put('SVMXC__Priority__c','High');
            fieldsPerRecordMap.put('SVMXC__Order_Type__c','Open');
            fieldsPerRecordMap.put('SVMXC__Group_Email__c','abc@xyz.com');
            fieldsPerRecordMap.put('SVMXC__Scheduled_Date__c',string.ValueOf(date.newinstance(2010,12,17)));
            fieldsPerRecordMap.put('SVMXC__PM_Tasks_Created__c','true');  
            fieldsPerRecordMap.put('SVMXC__Longitude__c','120.36');  
            fieldsPerRecordMap.put('SVMXC__Actual_Initial_Response__c',String.valueOf(datetime.newInstance(2011, 12, 1, 12, 30, 2)));  
            
            List<INTF_WebServicesDef.SVMXMap> tableContents = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap firstObj = new INTF_WebServicesDef.SVMXMap();
            firstObj.key = 'Fields';
            firstObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('localId', JSON.serialize(fieldsPerRecordMap)));
           
            Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
            fieldsFromClientMap.put('Id',Record_id);
            fieldsFromClientMap.put('SVMXC__Priority__c','High');
            fieldsFromClientMap.put('SVMXC__Order_Type__c','Open');
            fieldsFromClientMap.put('SVMXC__Group_Email__c','abc1@xyz.com');
            fieldsFromClientMap.put('SVMXC__Scheduled_Date__c',string.ValueOf(date.newinstance(2010,12,17)));
            fieldsFromClientMap.put('SVMXC__PM_Tasks_Created__c','false');  
            fieldsFromClientMap.put('SVMXC__Longitude__c','120.36');  
            fieldsFromClientMap.put('SVMXC__Actual_Initial_Response__c',String.valueOf(datetime.newInstance(2011, 12, 11, 12, 30, 2)));            
            
            INTF_WebServicesDef.SVMXMap newObj = new INTF_WebServicesDef.SVMXMap();
            newObj.key = 'BEFORE_SAVE';
            newObj.values = new List<string>{JSON.serialize(fieldsFromClientMap)};
            firstObj.valueMap.add(newObj);
            tableContents.add(firstObj); 
            
            INTF_WebServicesDef.SVMXMap firstObj1 = new INTF_WebServicesDef.SVMXMap();
            firstObj1.key = 'object_name';
            firstObj1.value = 'SVMXC__Service_Order__c';
            firstObj1.valueMap = tableContents;
            tableList.add(firstObj1);
            
            System.assertEquals(true, WorkOrderData != null);
            
            Req.valueMap = tableList;
            Req.value = '001';
            System.debug(LoggingLevel.INFO,'Test class request '+Req);
            //Res = str.UpdateClientDataIntoBase(Req);
            
            //update the work order data 
            WorkOrderData.SVMXC__Priority__c='Low';
            WorkOrderData.SVMXC__Actual_Initial_Response__c = datetime.newInstance(2011, 12, 11, 12, 30, 2);
            WorkOrderData.SVMXC__Longitude__c = 121.36;
            WorkOrderData.SVMXC__PM_Tasks_Created__c = TRUE;
            update WorkOrderData;
            
            Map<String, Datetime> mapRecordIdToLST = new Map<string, Datetime>();
            Test.startTest();
        
            resAdvFieldMerge.valueMap = txnCache.updateRecordsFromClient(Req, DateTime.now() - 1 , 'Allow user to choose',mapRecordIdToLST); //New LastModifiedDate
            
            Test.stopTest();
        
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    static testMethod void nullRequestTest(){
        INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMRequest req = NULL ;
            INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
            try{
                Test.startTest();
                    res = txnCache.oneCallSync(req);  //NULL Request
                Test.stopTest();    
            }catch( Exception ex ) {   
                 system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
            }   
    } 
    
    static testMethod void getCriteriaSyncRequestTest(){
        try{
            
            insertConfigData(); //insert config/setting related data
            
            //Creating Sample Data for the sync to work
            List<SVMXC__Service_Order_Line__c> lstWOLine = new List<SVMXC__Service_Order_Line__c>();
    
            SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
            WO.SVMXC__City__c = 'Bangalore';
            Database.SaveResult resul = Database.insert(WO);
            String workOrderId = resul.getId();
            
            //inserting another WO record
            SVMXC__Service_Order__c wo2 = new SVMXC__Service_Order__c();
            wo2.SVMXC__City__c = 'Mumbai';
            insert wo2;
            
            String Record_id = '';
            SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '1234567891' );
            Database.SaveResult Result = Database.insert(requestRecord);
            Record_id = Result.getId();
            
            SVMXC__Sync_Request_Records__c reqRecord = new SVMXC__Sync_Request_Records__c(SVMXC__Iteration_Index__c = 2,SVMXC__Operation_Type__c = 'Select', SVMXC__Sync_Request__c = Record_id, SVMXC__SFDC_Record_Id__c = workOrderId );
            insert reqRecord;
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            insert dcConfigData;
            
            Test.startTest();
        
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            req.eventName = 'ONE_CALL_SYNC';
            req.eventType = 'SYNC';
            req.value = '1234567891';
            req.values = new List<String>{workOrderId};
            req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            
            //GET UPDATE DC OPTIMIZED
            INTF_WebServicesDef.SVMXMap callBackContext = new INTF_WebServicesDef.SVMXMap('CALL_BACK','true');
            callBackContext.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            callBackContext.valueMap.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK_CONTEXT','GET_UPDATE_DC_OPTIMZED'));
            req.valueMap.add(callBackContext);
           
            req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '1')); // last index
            //req.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', string.valueOf(DateTime.now().addHours(1) ) ) );
            
            INTF_WebServicesDef.SVMXMap priceBookVM = new INTF_WebServicesDef.SVMXMap();
            priceBookVM.key = 'PRICEBOOK_IDs';
            priceBookVM.values = new List<string>{'test'};
            
            INTF_WebServicesDef.SVMXMap serPriceBookVM = new INTF_WebServicesDef.SVMXMap();
            serPriceBookVM.key = 'SERVICE_PRICEBOOK_IDs';
            serPriceBookVM.values = new List<string>{'test123'};
            
            req.valueMap.add(priceBookVM);
            req.valueMap.add(serPriceBookVM);
            
            //Executing the Sync    
            INTF_TxnCache txnCache = new INTF_TxnCache();
            INTF_WebServicesDef.INTF_SFMResponse resp = txnCache.oneCallSync(req);
            
            Test.stopTest();
        
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
    }
    
    static testMethod void testGetAttachments(){
        try{
            insertConfigData();
            createIPADSetting();
        
            INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            
            SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
            IB.SVMXC__Status__c = 'Installed';
            Database.SaveResult resul = Database.insert(IB);
            String IBId = resul.getId();
            
            Attachment att = new Attachment();
            att.ParentId = IBId;
            att.Name = 'Test Attachment for Parent';
            att.Body = Blob.valueOf('Test Data');
     
            insert(att);
            
            List<String> process = new List<String>();
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PIQ_ATTACHMENTS';
            req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj1.key = 'TX_OBJECT';
            obj1.value = 'SVMXC__Installed_Product__c';
            obj1.values = new List<String>{IBId};
            
            
            SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
            obj2.key = 'LAST_SYNC_TIME';
            obj2.value = String.valueOf(DateTime.now() - 1);
            
            req.valueMap.add(obj1);
            req.valueMap.add(obj2);
            Test.startTest();
            resp = (new INTF_TxnCache()).getAttachments(req, grpProfileId);
            Test.stopTest();
            system.debug(LoggingLevel.WARN, 'response = :' + resp);
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
    }
    
    static testMethod void testGetPIQTemplates(){
        try{
            insertConfigData();
            createIPADSetting();
            
            //adding a config data for DC on Product -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10' , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID, SVMXC__Ownership_Type__c = 'My Records');
            insert dcConfigData;
            
            String productID = '', productID2 = '';  
            Product2 product001 = new Product2();
            product001.SVMXC__Product_Line__c = 'Accessory';
            product001.Family = 'Accessory';
            product001.Name = 'Laptop Bags';
            Database.SaveResult Result = Database.insert(product001);
            productID = Result.getId();
            
            Product2 product002 = new Product2();
            product002.SVMXC__Product_Line__c = 'Network';
            product002.Family = 'Network';
            product002.Name = 'NW';
            Database.SaveResult result1 = Database.insert(product002);
            productID2 = result1.getId();
            
            //Add another product with LMD < LST
            
            SVMXC__SM_Attributes_Template__c attrTempl = new SVMXC__SM_Attributes_Template__c();
            attrTempl.SVMXC__SM_Active__c = true;
            attrTempl.SVMXC__SM_Attr_Type_Template__c = 'TECHNICAL';
            insert attrTempl;
            
            SVMXC__SM_Product_Attributes__c attrProd = new SVMXC__SM_Product_Attributes__c();
            attrProd.SVMXC__SM_Product__c = product001.Id;
            attrProd.SVMXC__SM_Attribute_Template_Id__c = attrTempl.Id;
            attrProd.SVMXC__SM_Product_Line__c = 'Accessory';
            attrProd.SVMXC__SM_Product_Family__c = 'Accessory';
            insert attrProd;
            
            SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
  
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCT_TEMPLATES';
            req.value = '13456789';
            req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
            SVMXC.INTF_WebServicesDef.SVMXMap vm1 = new SVMXC.INTF_WebServicesDef.SVMXMap('Object_Name','Product2');
            vm1.values = new List<string>{productID};

            SVMXC.INTF_WebServicesDef.SVMXMap vm2 = new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME',String.valueOf(System.now().addDays(-1)));

            SVMXC.INTF_WebServicesDef.SVMXMap vm3 = new SVMXC.INTF_WebServicesDef.SVMXMap('PRODUCT_LASTID',NULL);

            SVMXC.INTF_WebServicesDef.SVMXMap vm4 = new SVMXC.INTF_WebServicesDef.SVMXMap('PRODUCTATTR_LASTID',NULL);

            req.valueMap.add(vm1);
            req.valueMap.add(vm2);
            req.valueMap.add(vm3);
            req.valueMap.add(vm4);

            resp = (new INTF_TxnCache()).getPIQAttributesTemplates(req, grpProfileId);
            
            //Where Last Sync time > Product's LMD
            
            req = new INTF_WebServicesDef.INTF_SFMRequest();
            clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_PRODUCT_TEMPLATES';
            req.value = '13456789';
            req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            
            vm1 = new SVMXC.INTF_WebServicesDef.SVMXMap('Object_Name','Product2');
            vm1.values = new List<string>{productID};
            
            vm2 = new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME',String.valueOf(System.now()+1));
            
            req.valueMap.add(vm1);
            req.valueMap.add(vm2);
            req.valueMap.add(vm3);
            req.valueMap.add(vm4);
            
            Test.StartTest();
                resp = (new INTF_TxnCache()).getPIQAttributesTemplates(req, grpProfileId);
            Test.StopTest();
            
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'Exception = :' + e.getMessage());
        }
     } 
    static testMethod void getTechnicianTest()
    {
        Id  configProfileRecordTypeId, confAccessRecTypeId,mobConfigRecordTypeId,settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId , targetMgrRecordTypeId, serviceAccessFlowRecTypeId;
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
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = Userinfo.getProfileId();
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile; 
    
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
        
        Test.startTest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        req.eventType = 'SYNC';
        req.eventName = 'TECHNICIAN_SEARCH';
        req.values = new List<String>();
        req.values.add('Test');
        resp =INTF_WebServicesDef.INTF_DataSync_WS(req);  
        System.assertEquals(true, !resp.valueMap.isEmpty());
        Test.stopTest();      
    
    }  
 
    static testMethod void getTrunkStockTest()
    {
        Id  configProfileRecordTypeId, confAccessRecTypeId,mobConfigRecordTypeId,settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId , targetMgrRecordTypeId, serviceAccessFlowRecTypeId;
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
    
        String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        //insert profile related processes and config data
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = Userinfo.getProfileId();
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile;
        
        //Module - IPAD
        SVMXC__ServiceMax_Processes__c modProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = moduleRecTypeId, SVMXC__Name__c = 'ServiceMax iPad Client',SVMXC__ModuleID__c = 'IPAD',
        SVMXC__Installation_Key__c = strInstlltnKey, SVMXC__Description__c = 'The iPad client for ServiceMax allows field technicians to view their work order assignments, SLA commitments, enter time & material, capture customer signature, update the work order status etc. In addition, technicians can also access the knowledge base and product manuals, as well as use chatter to collaborate with other users in the organization');
        insert modProcess;
        
        //Submodule
        SVMXC__ServiceMax_Processes__c subModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = subModuleRecTypeId, SVMXC__Name__c = 'Synchronization',SVMXC__Installation_Key__c = strInstlltnKey,
        SVMXC__SubmoduleID__c = 'IPAD018',SVMXC__Module__c = modProcess.Id,SVMXC__ModuleID__c = 'IPAD',SVMXC__Description__c = 'This submodule represents all functionality in the iPad client related to Synchronization');
        insert subModProcess;
        
        //Setting - IPAD018_SET006
        SVMXC__ServiceMax_Processes__c settingProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Number of record to process in a batch', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = '',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = '2',SVMXC__Description__c = 'When set to true, access to data for logged in user during data sync (manual/incremental/aggressive) is controlled at record level as per sharing settings. This setting is applicable to all mobile clients.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET006',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        insert settingProcess;
        
        //Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess.Id, SVMXC__Internal_Value__c = '2');
        insert settingValueConfig;    
    
        //Insert team and technician
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;  
        List<Attachment> listOfAttachment = new List<Attachment>();
        Attachment attach=new Attachment(); 
        attach.Name='Laptop.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; 
        attach.parentId=product1.Id; 
        attach.ContentType = 'image/jpg'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        listOfAttachment.add(attach);
        
        Product2 productMobile = new Product2();
        productMobile.Name = 'Mobile';
        insert productMobile; 
        
        Attachment attachMobile=new Attachment(); 
        attachMobile.Name='Mobile.jpg'; 
        bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attachMobile.body=bodyBlob; 
        attachMobile.parentId=productMobile.Id; 
        attachMobile.ContentType = 'image/jpg'; 
        attachMobile.IsPrivate = false; 
        attachMobile.Description = 'Test';        
        listOfAttachment.add(attachMobile);                   
        
        insert listOfAttachment;
        
        SVMXC__Product_Stock__c newStock = new SVMXC__Product_Stock__c();
        newStock.SVMXC__Location__c = location1.Id;
        newStock.SVMXC__Product__c=product1.Id;
        newStock.SVMXC__Status__c ='Available';
        insert newStock;
        
        SVMXC__Product_Stock__c newMobileStock = new SVMXC__Product_Stock__c();
        newMobileStock.SVMXC__Location__c = location1.Id;
        newMobileStock.SVMXC__Product__c=productMobile.Id;
        newMobileStock.SVMXC__Status__c ='Available';
        insert newMobileStock;        
        
        SVMXC__Product_Serial__c newPs = new SVMXC__Product_Serial__c();
        newPs.SVMXC__Product_Stock__c=newStock.Id;
        newPs.SVMXC__Active__c=true;
        insert newPs;
        
        SVMXC__Product_Serial__c newestSerial = new SVMXC__Product_Serial__c();
        newestSerial.SVMXC__Product_Stock__c=newStock.Id;
        newestSerial.SVMXC__Active__c=true;
        insert newestSerial;
        SVMXC__SM_Inventory_Config__c newConfig = new SVMXC__SM_Inventory_Config__c();
        newConfig.SVMXC__SM_ServiceMax_Profile__c=configProfile.Id;
        newConfig.SVMXC__SM_Content__c='{\"locatepartsetup\":{\"isEnabled\":false,\"Radius\":0,\"Distanceinunit\":\"kilometer/ miles\",\"locationtype\":[],\"inventoryprocess\":null},\"layout\":{\"partsfields\":[{\"sequence\":1,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"},{\"sequence\":2,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"}],\"partsdetailfields\":[{\"sequence\":1,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"},{\"sequence\":2,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"}],\"downloadcriteria\":[{\"includeserializedstock\":true,\"productstockstatus\":\"Available\",\"quantityfield\":\"Allocated Qty\"},{\"includeserializedstock\":true,\"productstockstatus\":\"Available\",\"quantityfield\":\"Allocated Qty\"}],\"attachmentFileName\":\"Name\"}}';
        insert newConfig;
                
        Test.startTest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        req.eventType = 'SYNC';
        req.eventName = 'TRUNK_STOCK';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        resp =INTF_WebServicesDef.INTF_DataSync_WS(req);       
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();        
        INTF_WebServicesDef.SVMXMap lastIdMap = new INTF_WebServicesDef.SVMXMap();
        lastIdMap.key='SERIAL_STOCK_LAST_ID';
        lastIdMap.value=''+newPs.Id;  
        INTF_WebServicesDef.SVMXMap callBackMap = new INTF_WebServicesDef.SVMXMap();
        callBackMap.key='CALL_BACK';
        callBackMap.valueMap=new List<INTF_WebServicesDef.SVMXMap>();
        callBackMap.valueMap.add(lastIdMap);
        req.valueMap.add(callBackMap);
        resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();        
        lastIdMap = new INTF_WebServicesDef.SVMXMap();
        lastIdMap.key='STOCK_LAST_ID';
        lastIdMap.value=''+newStock.Id;  
        callBackMap = new INTF_WebServicesDef.SVMXMap();
        callBackMap.key='CALL_BACK';
        callBackMap.valueMap=new List<INTF_WebServicesDef.SVMXMap>();
        callBackMap.valueMap.add(lastIdMap);
        req.valueMap.add(callBackMap);
        resp = INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();  
        INTF_WebServicesDef.SVMXMap LSTMap = new INTF_WebServicesDef.SVMXMap();                       
        LSTMap.key='LAST_SYNC_TIME';
        LSTMap.value=''+System.now().addDays(-1);
        req.valueMap.add(LSTMap);
        resp = INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        Test.stopTest();
                    
    } 
    static testMethod void getTrunkStockTestWithoutImage()
    {
        Id  configProfileRecordTypeId, confAccessRecTypeId,mobConfigRecordTypeId,settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId , targetMgrRecordTypeId, serviceAccessFlowRecTypeId;
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
    
        String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        //insert profile related processes and config data
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = Userinfo.getProfileId();
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile;
        
        //Module - IPAD
        SVMXC__ServiceMax_Processes__c modProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = moduleRecTypeId, SVMXC__Name__c = 'ServiceMax iPad Client',SVMXC__ModuleID__c = 'IPAD',
        SVMXC__Installation_Key__c = strInstlltnKey, SVMXC__Description__c = 'The iPad client for ServiceMax allows field technicians to view their work order assignments, SLA commitments, enter time & material, capture customer signature, update the work order status etc. In addition, technicians can also access the knowledge base and product manuals, as well as use chatter to collaborate with other users in the organization');
        insert modProcess;
        
        //Submodule
        SVMXC__ServiceMax_Processes__c subModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = subModuleRecTypeId, SVMXC__Name__c = 'Synchronization',SVMXC__Installation_Key__c = strInstlltnKey,
        SVMXC__SubmoduleID__c = 'IPAD018',SVMXC__Module__c = modProcess.Id,SVMXC__ModuleID__c = 'IPAD',SVMXC__Description__c = 'This submodule represents all functionality in the iPad client related to Synchronization');
        insert subModProcess;
        
        //Setting - IPAD018_SET006
        SVMXC__ServiceMax_Processes__c settingProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Number of record to process in a batch', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = '',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = '2',SVMXC__Description__c = 'When set to true, access to data for logged in user during data sync (manual/incremental/aggressive) is controlled at record level as per sharing settings. This setting is applicable to all mobile clients.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET006',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        insert settingProcess;
        
        //Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess.Id, SVMXC__Internal_Value__c = '2');
        insert settingValueConfig;    
    
        //Insert team and technician
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;  
        
        Product2 productMobile = new Product2();
        productMobile.Name = 'Mobile';
        insert productMobile; 
        
        
        SVMXC__Product_Stock__c newStock = new SVMXC__Product_Stock__c();
        newStock.SVMXC__Location__c = location1.Id;
        newStock.SVMXC__Product__c=product1.Id;
        newStock.SVMXC__Status__c ='Available';
        insert newStock;
        
        SVMXC__Product_Stock__c newMobileStock = new SVMXC__Product_Stock__c();
        newMobileStock.SVMXC__Location__c = location1.Id;
        newMobileStock.SVMXC__Product__c=productMobile.Id;
        newMobileStock.SVMXC__Status__c ='Available';
        insert newMobileStock;        
        
        SVMXC__Product_Serial__c newPs = new SVMXC__Product_Serial__c();
        newPs.SVMXC__Product_Stock__c=newStock.Id;
        newPs.SVMXC__Active__c=true;
        insert newPs;
        
        SVMXC__Product_Serial__c newestSerial = new SVMXC__Product_Serial__c();
        newestSerial.SVMXC__Product_Stock__c=newStock.Id;
        newestSerial.SVMXC__Active__c=true;
        insert newestSerial;
        SVMXC__SM_Inventory_Config__c newConfig = new SVMXC__SM_Inventory_Config__c();
        newConfig.SVMXC__SM_ServiceMax_Profile__c=configProfile.Id;
        newConfig.SVMXC__SM_Content__c='{\"locatepartsetup\":{\"isEnabled\":false,\"Radius\":0,\"Distanceinunit\":\"kilometer/ miles\",\"locationtype\":[],\"inventoryprocess\":null},\"layout\":{\"partsfields\":[{\"sequence\":1,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"},{\"sequence\":2,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"}],\"partsdetailfields\":[{\"sequence\":1,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"},{\"sequence\":2,\"fieldname\":\"\",\"objectname\":\"\",\"fieldtype\":\"\"}],\"downloadcriteria\":[{\"includeserializedstock\":true,\"productstockstatus\":\"Available\",\"quantityfield\":\"Allocated Qty\"},{\"includeserializedstock\":true,\"productstockstatus\":\"Available\",\"quantityfield\":\"Allocated Qty\"}]}}';
        insert newConfig;
                
        Test.startTest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        req.eventType = 'SYNC';
        req.eventName = 'TRUNK_STOCK';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        resp =INTF_WebServicesDef.INTF_DataSync_WS(req);       
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();        
        INTF_WebServicesDef.SVMXMap lastIdMap = new INTF_WebServicesDef.SVMXMap();
        lastIdMap.key='SERIAL_STOCK_LAST_ID';
        lastIdMap.value=''+newPs.Id;  
        INTF_WebServicesDef.SVMXMap callBackMap = new INTF_WebServicesDef.SVMXMap();
        callBackMap.key='CALL_BACK';
        callBackMap.valueMap=new List<INTF_WebServicesDef.SVMXMap>();
        callBackMap.valueMap.add(lastIdMap);
        req.valueMap.add(callBackMap);
        resp = INTF_WebServicesDef.INTF_DataSync_WS(req);
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();        
        lastIdMap = new INTF_WebServicesDef.SVMXMap();
        lastIdMap.key='STOCK_LAST_ID';
        lastIdMap.value=''+newStock.Id;  
        callBackMap = new INTF_WebServicesDef.SVMXMap();
        callBackMap.key='CALL_BACK';
        callBackMap.valueMap=new List<INTF_WebServicesDef.SVMXMap>();
        callBackMap.valueMap.add(lastIdMap);
        req.valueMap.add(callBackMap);
        resp = INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();  
        INTF_WebServicesDef.SVMXMap LSTMap = new INTF_WebServicesDef.SVMXMap();                       
        LSTMap.key='LAST_SYNC_TIME';
        LSTMap.value=''+System.now().addDays(-1);
        req.valueMap.add(LSTMap);
        resp = INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        Test.stopTest();
                    
    }     
    static testMethod void testCatalogSearch()
    {
        List<Product2> listOfProducts = new List<Product2>();
        for(Integer check=0;check<10;check++)
        {
            Product2 product1 = new Product2();
            product1.Name = 'Laptop'+check;
            listOfProducts.add(product1);
        }
        insert listOfProducts;
             
    
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        
        req.eventType = 'SYNC';
        req.eventName = 'CATALOG_SEARCH';
        req.values = new List<String>();
        req.values.add('Laptop');
        
        List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjs = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj1.key='Search_Fields';
        obj1.valueMap=new List<INTF_WebServicesDef.SVMXMap>();
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj2.key='Name';
        obj2.value='String';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj3.key='Family';
        obj3.value='String';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj4.key='ProductCode';
        obj4.value='String';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj5 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj5.key='SVMXC__TestNumber__c';
        obj5.value='Integer';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj6 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj6.key='Operator';
        obj6.value='Starts With';
        
        obj1.valueMap.add(obj2);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj5);
        lstObjs.add(obj1);
        lstObjs.add(obj6);        
        
        req.valueMap = lstObjs;
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Contains';
        obj1.valueMap.add(obj2);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj5);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Ends With';
        obj1.valueMap.add(obj2);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj5);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        req.values.add('1');
        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Exact Match';
        obj1.valueMap.add(obj2);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj5);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        req.values.add('Laptop1');
        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Exact Match';
        obj1.valueMap.add(obj2);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj5);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Exact Match';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        req.values.add('1'); 
                
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Ends With';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        req.values.add('1');        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Starts With';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        req.values.add('1');        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Contains';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        req.values.add('1');        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Exact Match';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();
        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Ends With';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();        
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Starts With';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();      
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
        resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        
        req.eventType = 'SYNC';
        req.eventName = 'CATALOG_SEARCH';
        
        lstObjs = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Contains';
        obj1.valueMap.add(obj5);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();       
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req);                                                                 
        system.assert(!resp.success);
        resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        
        req.eventType = 'SYNC';
        req.eventName = 'CATALOG_SEARCH';
        
        lstObjs = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        obj6.value='Contains';
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        obj1.valueMap.add(obj2);
        lstObjs.add(obj1);
        lstObjs.add(obj6);    
        req.valueMap = lstObjs;
        req.values = new List<String>();       
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req);                            
    }
    static testmethod void numericCatalogSearch()
    {
    
        List<Product2> listOfProducts = new List<Product2>();
        for(Integer check=0;check<10;check++)
        {
            Product2 product1 = new Product2();
            product1.Name = 'Laptop'+check;
            listOfProducts.add(product1);
        }
        insert listOfProducts;    
    
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        
        req.eventType = 'SYNC';
        req.eventName = 'CATALOG_SEARCH';
        req.values = new List<String>();
        req.values.add('4');
        
        List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjs = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj1.key='Search_Fields';
        obj1.valueMap=new List<INTF_WebServicesDef.SVMXMap>();
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj2.key='Name';
        obj2.value='String';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj3.key='Family';
        obj3.value='String';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj4.key='ProductCode';
        obj4.value='String';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj6 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj6.key='Last_Id';
        obj6.value=''+listOfProducts[0].Id;
        
        obj1.valueMap.add(obj2);
        obj1.valueMap.add(obj3);
        obj1.valueMap.add(obj4);
        lstObjs.add(obj1);
        lstObjs.add(obj6);
        
        
        req.valueMap = lstObjs;
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req);    
    }
    
    static testmethod void negativeCatalogSearch()
    {
    
        List<Product2> listOfProducts = new List<Product2>();
        for(Integer check=0;check<10;check++)
        {
            Product2 product1 = new Product2();
            product1.Name = 'Laptop'+check;
            listOfProducts.add(product1);
        }
        insert listOfProducts;    
    
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        
        req.eventType = 'SYNC';
        req.eventName = 'CATALOG_SEARCH';
        req.values = new List<String>();
        req.values.add('4');
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req);    
    }   
    
    static testMethod void testChecklistDataWithCallBack()
    {
        try{
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
            
            insertConfigData(); //insert config/setting related data
            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            SVMXC__ServiceMax_Config_Data__c isChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Enable Checklist', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(isChecklist);
            
            SVMXC__ServiceMax_Config_Data__c inProgressChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'InProgress Checklists', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(inProgressChecklist);
            
            //Svmx process for ADC - SVMX_Rule
            SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
            insert advDCProcess;
        
            //Svmx config Data for expression
            SVMXC__ServiceMax_Config_Data__c expressionConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id);
            configDataList.add(expressionConfigData);
            
            //Another expression for Reference
            SVMXC__ServiceMax_Config_Data__c refExpConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id, SVMXC__Display_Type__c = 'REFERENCE', SVMXC__Object_Name__c = 'Account' , SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c', SVMXC__Source_Field_Name__c ='SVMXC__Company__c');
            configDataList.add(refExpConfigData);
            
            //adding a config data for ADC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(adcConfigData);
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(dcConfigData);
            
            SVMXC__ServiceMax_Config_Data__c completedChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Completed Checklists', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(completedChecklist);
            
            SVMXC__ServiceMax_Config_Data__c syncToGetEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '1', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(syncToGetEventChecklist);
            
            SVMXC__ServiceMax_Config_Data__c syncToRemEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '1', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(syncToRemEventChecklist);
            
            SVMXC__ServiceMax_Config_Data__c downloadCritChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Internal_Value__c = '', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(downloadCritChecklist);
            
            SVMXC__ServiceMax_Config_Data__c advDCChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Internal_Value__c = '', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(advDCChecklist);
        
            //create process for Checklist
            SVMXC__ServiceMax_Processes__c checklistTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'CHECKLIST', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234');
            insert checklistTarMgrProcess;
            
            //create Config Data for Service Access Flow
            SVMXC__ServiceMax_Config_Data__c checkListConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId,SVMXC__Dispatch_Process__c = checklistTarMgrProcess.Id );
            configDataList.add(checkListConfigData);
            
            insert configDataList;
            
            //SVMXC__ServiceMax_Processes__c targetMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'STANDALONE EDIT', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234');
            //insert targetMgrProcess;
            
            SVMXC__ServiceMax_Processes__c procNodeObjProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = checklistTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234');
            insert procNodeObjProcess;
       
            createEvents();
            
            //insert checklist record
            SVMXC__Checklist__c chkData = new SVMXC__Checklist__c();
            chkData.SVMXC__ChecklistProcessID__c = checklistTarMgrProcess.Id;
            chkData.SVMXC__Work_Order__c = wo.Id;
            chkData.SVMXC__ChecklistJSON__c  = 'testData';
            chkData.SVMXC__Status__c = 'Completed';
            chkData.SVMXC__What_Id__c = wo.Id;
            insert chkData;
            
            SVMXC__Checklist__c chkDataToDelete = new SVMXC__Checklist__c();
            chkDataToDelete.SVMXC__ChecklistProcessID__c = checklistTarMgrProcess.Id;
            chkDataToDelete.SVMXC__Work_Order__c = wo.Id;
            chkDataToDelete.SVMXC__ChecklistJSON__c  = 'testData2';
            chkDataToDelete.SVMXC__Status__c = 'Completed';
            chkDataToDelete.SVMXC__What_Id__c = wo.Id;
            insert chkDataToDelete;
            delete chkDataToDelete;
            
            SVMXC__SM_Checklist_Attachment__c chkAttachment = new SVMXC__SM_Checklist_Attachment__c();
            chkAttachment.SVMXC__SM_Attachment_ID__c = 'Att1';
            chkAttachment.SVMXC__SM_Attachment_Name__c = 'testAtt';
            chkAttachment.SVMXC__SM_Checklist__c = chkData.Id;
            insert chkAttachment;
            
            SVMXC__SM_Checklist_Attachment__c chkAttachmentToDel = new SVMXC__SM_Checklist_Attachment__c();
            chkAttachmentToDel.SVMXC__SM_Attachment_ID__c = 'Att1';
            chkAttachmentToDel.SVMXC__SM_Attachment_Name__c = 'testAtt';
            chkAttachmentToDel.SVMXC__SM_Checklist__c = chkData.Id;
            insert chkAttachmentToDel;
            delete chkAttachmentToDel;
            
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_CHECKLIST_DATA';
            req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now().addDays(-5))));
            
            Test.StartTest();
                try{
                    resp = (new INTF_TxnCache()).getChecklistData(req, grpProfileId);
                    
                    (new INTF_TxnCache()).addCallBackForChecklist(resp, 'SVMXC__Service_Order__c', new List<string>{wo.Id},new List<string>{chkData.Id}, new List<string>{chkAttachment.Id} );
                    system.debug(LoggingLevel.WARN, 'response = :' + resp);
                
                    //CallBack 
                    req = new INTF_WebServicesDef.INTF_SFMRequest();
                    req.eventType = 'SYNC';
                    req.eventName = 'SYNC_CHECKLIST_DATA';
                    req.value = '123456789';
                    
                    INTF_WebServicesDef.SVMXClient  clInfo = new INTF_WebServicesDef.SVMXClient();
                    clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:1234567891'};
                    clInfo.clientType = 'iPad';
                    req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                    
                    SVMXC.INTF_WebServicesDef.SVMXMap LMD = new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now().adddays(-5)));
                    LMD.values = new List<string>{NULL};

                    SVMXC.INTF_WebServicesDef.SVMXMap objVM = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', 'SVMXC__Installed_Product__c');
                    objVM.values = new List<string>{wo.Id};

                    SVMXC.INTF_WebServicesDef.SVMXMap chkVM = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_CHECKLIST', 'SVMXC__Checklist__c');
                    chkVM.values = new List<string>{chkData.Id};

                    SVMXC.INTF_WebServicesDef.SVMXMap attVM = new SVMXC.INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_CHK_ATTACHMENT', 'SVMXC__SM_Checklist_Attachment__c');
                    attVM.values = new List<string>{chkAttachment.Id};

                    req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                    req.valueMap.add(LMD);
                    req.valueMap.add(objVM);
                    req.valueMap.add(chkVM);
                    req.valueMap.add(attVM);

                    resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req);
                    
               }catch(Exception Ex){
                    system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
                }
                
            Test.StopTest();
            system.debug(LoggingLevel.WARN, 'Call Back Response = :' + resp);
        }catch(Exception Ex){
            system.debug(LoggingLevel.WARN, 'Exception = :' + Ex.getMessage());
        }
    } 
    
    static testMethod void testChecklistIncremental()
    {
        try{
            
            INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
            
            insertConfigData(); //insert config/setting related data
            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            SVMXC__ServiceMax_Config_Data__c isChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Enable Checklist', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(isChecklist);
            
            SVMXC__ServiceMax_Config_Data__c inProgressChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'InProgress Checklists', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(inProgressChecklist);
            
            //Svmx process for ADC - SVMX_Rule
            SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
            insert advDCProcess;
        
            //Svmx config Data for expression
            SVMXC__ServiceMax_Config_Data__c expressionConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id);
            configDataList.add(expressionConfigData);
            
            //Another expression for Reference
            SVMXC__ServiceMax_Config_Data__c refExpConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id, SVMXC__Display_Type__c = 'REFERENCE', SVMXC__Object_Name__c = 'Account' , SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c', SVMXC__Source_Field_Name__c ='SVMXC__Company__c');
            configDataList.add(refExpConfigData);
            
            //adding a config data for ADC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(adcConfigData);
            
            //adding a config data for DC -> recordtype = MobileConfiguration
            SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(dcConfigData);
            
            SVMXC__ServiceMax_Config_Data__c completedChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Completed Checklists', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(completedChecklist);
            
            SVMXC__ServiceMax_Config_Data__c syncToGetEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '1', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(syncToGetEventChecklist);
            
            SVMXC__ServiceMax_Config_Data__c syncToRemEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '1', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(syncToRemEventChecklist);
            
            SVMXC__ServiceMax_Config_Data__c downloadCritChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Internal_Value__c = '', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(downloadCritChecklist);
            
            SVMXC__ServiceMax_Config_Data__c advDCChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Internal_Value__c = '', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
            configDataList.add(advDCChecklist);
        
            //create process for Checklist
            SVMXC__ServiceMax_Processes__c checklistTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'CHECKLIST', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234');
            insert checklistTarMgrProcess;
            
            //create Config Data for Service Access Flow
            SVMXC__ServiceMax_Config_Data__c checkListConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId,SVMXC__Dispatch_Process__c = checklistTarMgrProcess.Id );
            configDataList.add(checkListConfigData);
            
            insert configDataList;
            
            SVMXC__ServiceMax_Processes__c procNodeObjProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = checklistTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234');
            insert procNodeObjProcess;
       
            createEvents();
            
            //insert checklist record
            SVMXC__Checklist__c chkData = new SVMXC__Checklist__c();
            chkData.SVMXC__ChecklistProcessID__c = checklistTarMgrProcess.Id;
            chkData.SVMXC__Work_Order__c = wo.Id;
            chkData.SVMXC__ChecklistJSON__c  = 'testData';
            chkData.SVMXC__Status__c = 'Completed';
            chkData.SVMXC__What_Id__c = wo.Id;
            insert chkData;
            
            SVMXC__SM_Checklist_Attachment__c chkAttachment = new SVMXC__SM_Checklist_Attachment__c();
            chkAttachment.SVMXC__SM_Attachment_ID__c = 'Att1';
            chkAttachment.SVMXC__SM_Attachment_Name__c = 'testAtt';
            chkAttachment.SVMXC__SM_Checklist__c = chkData.Id;
            insert chkAttachment;
            
            INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
            clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
            clInfo.clientType = 'iPad';
            req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
            
            req.eventType = 'SYNC';
            req.eventName = 'SYNC_CHECKLIST_DATA';
            req.value = '123456789';
            req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
            
            SVMXC.INTF_WebServicesDef.SVMXMap valueMap1 = new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now().addSeconds(1800)));
            req.valueMap.add(valueMap1);
            
            Test.StartTest();
                    wo.SVMXC__Street__c = 'testStreet';
                    update wo;
                    resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req);
            Test.StopTest();
            
         }catch(Exception Ex){
                system.debug(LoggingLevel.WARN, 'Exception = :' + Ex.getMessage());
         }
     }      
}