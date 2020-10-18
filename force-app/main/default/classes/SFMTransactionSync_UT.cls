@isTest(SeeAllData=false)
public with sharing class SFMTransactionSync_UT{

    static private string grpProfileId;
    static private string sfdcProfileId, defaultMobConfigID;
    static private Id targetMgrRecordTypeId, mobConfigRecordTypeId, configProfileRecordTypeId, confAccessRecTypeId, procNodeObjRecTypeId, serviceAccessFlowRecTypeId, svmxRuleRecTypeID, expressionRecTypeId, settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId;
    static private SVMXC__ServiceMax_Config_Data__c configProfile; 
    
    public static void insertConfigData(){
        grpProfileId = '';
        sfdcProfileId = userinfo.getProfileId();
        
        Set<String> configDataRecTypes = new Set<String>{'Mobile_Configuration','Configuration_Profile','Configuration_Access', 'Service_Flow_Access', 'Expressions', 'Setting_Value'};
        Set<String> svmxProcessRecTypes = new Set<String>{'Target_Manager','Process_Node_Objects','SVMX_Rule', 'Settings', 'Module', 'Submodule'};
        
        List<RecordType> recordTypeList = [select Id, DeveloperName, SobjectType from Recordtype where (SobjectType =: 'SVMXC__ServiceMax_Processes__c' and DeveloperName IN: svmxProcessRecTypes) OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' And DeveloperName IN: configDataRecTypes)];
        if(recordTypeList <> NULL && !recordTypeList.isEmpty()){
                for(RecordType rType : recordTypeList){
                    if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c'){
                        if(rType.DeveloperName =='Target_Manager'){
                            targetMgrRecordTypeId = rType.Id;
                        }else if(rType.DeveloperName =='Process_Node_Objects'){
                            procNodeObjRecTypeId = rType.Id;
                        }else if(rType.DeveloperName =='SVMX_Rule'){
                            svmxRuleRecTypeID = rType.Id;
                        }else if(rType.DeveloperName == 'Settings'){
                            settingRecTypeId = rType.Id;
                        }else if(rType.DeveloperName == 'Module'){
                            moduleRecTypeId = rType.Id;
                        }else if(rType.DeveloperName == 'Submodule'){
                            subModuleRecTypeId = rType.Id;
                        }
                    }else if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c'){
                        if(rType.DeveloperName =='Mobile_Configuration'){
                            mobConfigRecordTypeId = rType.Id;
                        }else if(rType.DeveloperName =='Configuration_Profile'){
                            configProfileRecordTypeId = rType.Id;
                        }else if(rType.DeveloperName =='Configuration_Access'){
                            confAccessRecTypeId = rType.Id;
                        }else if(rType.DeveloperName =='Service_Flow_Access'){
                            serviceAccessFlowRecTypeId = rType.Id;
                        }else if(rType.DeveloperName == 'Expressions'){
                            expressionRecTypeId = rType.Id;
                        }else if(rType.DeveloperName == 'Setting_Value'){
                            settingValueRecTypeId = rType.Id;
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
        system.debug('1. '+configProfile.Id);
        
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c =: sfdcProfileId AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = true];
        grpProfileId = profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
        system.debug('2. '+grpProfileId);
        
         //Insert device_Mobile_Config
        SVMXC__SM_Device_Mobile_Config__c defaultSetting = new SVMXC__SM_Device_Mobile_Config__c(SVMXC__SM_Name__c = 'Default Setting' , SVMXC__SM_IsDefault__c = TRUE, SVMXC__SM_Device_Type__c = 'iPad; iPhone; Android Tablet; Android Phone; Windows', SVMXC__SM_Access_Configuration_Profile__c = grpProfileId );
        insert defaultSetting;
        
        List<SVMXC__SM_Device_Mobile_Config__c> mobDeviceSetting = [select Id from SVMXC__SM_Device_Mobile_Config__c where SVMXC__SM_IsDefault__c = TRUE ];
        defaultMobConfigID = mobDeviceSetting[0].ID;
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Rule_Type__c = 'Adv Criteria Exp', SVMXC__Source_Object_Name__c = 'Attachment', SVMXC__Parent_Object_Criteria__c = 'ParentId IN (\':SVMXC__Service_Order__c\',\'Id\')' );
        insert advDCProcess;
        
        SVMXC__ServiceMax_Config_Data__c expressionForADC2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id, SVMXC__Display_Type__c = 'REFERENCE', SVMXC__Field_Relationship_Name__c = 'Parent', SVMXC__Field_Name__c = 'ParentId', SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c', SVMXC__Source_Field_Name__c = 'Id');
        configDataList.add(expressionForADC2);
        
        //ADC config data
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Attachment', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToGetEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventChecklist);
            
        SVMXC__ServiceMax_Config_Data__c syncToRemEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemEventChecklist);
        
        //ADC For files
        CONF_MobileConfig.FileConfig configForFile = new CONF_MobileConfig.FileConfig(true,'25','html,jpg','one');
        SVMXC__ServiceMax_Config_Data__c adcConfigData1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Files', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID, SVMXC__SM_Files_Config__c = json.serialize(configForFile) );
        configDataList.add(adcConfigData1);
        
        insert configDataList;
    }
    
    public static void createIPADSetting(){
        
        String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        
        List<SVMXC__ServiceMax_Processes__c> processList = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //Module - IPAD
        SVMXC__ServiceMax_Processes__c modProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = moduleRecTypeId, SVMXC__Name__c = 'ServiceMax iPad Client',SVMXC__ModuleID__c = 'IPAD',
        SVMXC__Installation_Key__c = strInstlltnKey, SVMXC__Description__c = 'The iPad client for ServiceMax allows field technicians to view their work order assignments, SLA commitments, enter time & material, capture customer signature, update the work order status etc. In addition, technicians can also access the knowledge base and product manuals, as well as use chatter to collaborate with other users in the organization');
        insert modProcess;
        
         //Submodule
        SVMXC__ServiceMax_Processes__c subModProcess = new SVMXC__ServiceMax_Processes__c( RecordtypeId = subModuleRecTypeId, SVMXC__Name__c = 'Synchronization',SVMXC__Installation_Key__c = strInstlltnKey,
        SVMXC__SubmoduleID__c = 'IPAD018',SVMXC__Module__c = modProcess.Id,SVMXC__ModuleID__c = 'IPAD',SVMXC__Description__c = 'This submodule represents all functionality in the iPad client related to Synchronization');
        insert subModProcess;
        
        //Setting - IPAD018_SET004
        SVMXC__ServiceMax_Processes__c settingProcess1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Reference Salesforce Objects to be skipped', 
        SVMXC__Search_Order__c = 'Global',SVMXC__Setting_Type__c = 'Global',SVMXC__Values__c = '',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Text',SVMXC__Default_Value__c = 'PartnerNetworkConnection,User,FeedPost,Solution',SVMXC__Description__c = 'Setting defines all the Salesforce Objects that need to be skipped while downloading records.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET004',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess1);
        
        //Setting - IPAD018_SET013
        SVMXC__ServiceMax_Processes__c settingProcess2 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Maximum number of lookup fields for which name field can be queried', 
        SVMXC__Search_Order__c = 'Global',SVMXC__Setting_Type__c = 'Global',SVMXC__Values__c = '35',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Number',SVMXC__Default_Value__c = '35',SVMXC__Description__c = 'Salesforce limit for name field queries during data sync.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET013',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess2);
        
        //Setting - IPAD018_SET016
        SVMXC__ServiceMax_Processes__c settingProcess3 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Advanced conflict resolution during data synchronization', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = 'True~|~False',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'False',SVMXC__Description__c = 'When set to true, during data synchronization between client and server only modified field values are pushed to server. ',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET016',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess3);
        
        insert processList;
        
        //Setting Value - SET004
        SVMXC__ServiceMax_Config_Data__c settingValueConfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess1.Id, SVMXC__Internal_Value__c = 'PartnerNetworkConnection,User,FeedPost,Solution');
        configDataList.add(settingValueConfig1);
        
        //Setting Value - SET013
        SVMXC__ServiceMax_Config_Data__c settingValueConfig2 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess2.Id, SVMXC__Internal_Value__c = '35');
        configDataList.add(settingValueConfig2);
        
        //Setting Value - SET016
        SVMXC__ServiceMax_Config_Data__c settingValueConfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess3.Id, SVMXC__Internal_Value__c = 'TRUE');
        configDataList.add(settingValueConfig3);
        
        insert configDataList;
    }
    
    
    static testMethod void updateRecord(){
        SVMXC.INTF_WebServicesDef.INTF_Response resp = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_Request req = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        req.userId = UserInfo.getUserId();
        req.profileId = 'DEVICE_UDID';
        req.groupId = 'CLIENT_REQUEST_ID';

        req.stringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
    
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Problem_Description__c = 'Update from SFMTransactionSync_UT';
        insert wo;
        
        SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
        wo1.SVMXC__Problem_Description__c = 'Update from SFMTransactionSync_UT';
        insert wo1;

        req.stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('Key', wo.Id));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', wo.Id));
        
        Datetime dt = system.now();
        boolean isClockPaused = false;
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap('Parent_Object_Name', 'SVMXC__Service_Order__c');
        obj1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('RECORD_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action \",\"Id\":\"' + wo.Id + '\"}'));
        obj1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LOCAL_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action - new Insert \",\"SVMXC__First_Assigned_DateTime__c\":\"' + dt + '\",\"SVMXC__Clock_Paused_Forever__c\":\"'+ isClockPaused + '\"}'));
        req.valueMap.add(obj1);
        
        /*SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap('Parent_Object_Name', 'SVMXC__Service_Order__c');
        obj2.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LOCAL_ID', 'CLIENT_Local_123'));
        obj2.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('RECORD_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action Insert \"}'));
        req.valueMap.add(obj2);*/

        system.debug(LoggingLevel.WARN, 'Request = :' + req);
        resp = (new SFMTransactionSync()).updateRecord(req, resp);
        resp = (new SFMTransactionSync()).getRecord(resp);
        system.debug(LoggingLevel.WARN, 'Response = :' + resp);     
    }
    
    static testMethod void duplicateInsertCheck(){
        
        SVMXC.INTF_WebServicesDef.INTF_Response resp = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_Request req = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        req.userId = UserInfo.getUserId();
        req.profileId = 'DEVICE_UDID';
        req.groupId = 'CLIENT_REQUEST_ID';

        req.stringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
    
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Problem_Description__c = 'Insert from SFMTransactionSync_UT';
        insert wo;
        
        req.stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('Key', wo.Id));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', wo.Id));
        
        SVMXC__SM_SFMTransactionSync__c insertedRec = new SVMXC__SM_SFMTransactionSync__c();
        insertedRec.SVMXC__SM_Client_Sync_Request_Id__c = 'CLIENT_REQUEST_ID';
        Map<string, string> localIdByRecIdMap = new Map<String,String>();
        localIdByRecIdMap.put('LOCAL_ID',String.ValueOf(wo.Id));
        insertedRec.SVMXC__SM_Local_and_Platform_Id__c = json.serialize(localIdByRecIdMap);
        insertedRec.SVMXC__SM_User_Id__c = UserInfo.getUserID();
        insertedRec.SVMXC__SM_Device_UDID__c = 'DEVICE_UDID';
        insertedRec.SVMXC__SM_Operation_Type__c = 'INSERT';
        insert insertedRec;
        system.debug(LoggingLevel.WARN,'insertedRec = '+insertedRec);
        
        
        Datetime dt = system.now();
        boolean isClockPaused = false;
        Date dtToday = system.today();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap('Parent_Object_Name', 'SVMXC__Service_Order__c');
        obj1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('RECORD_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action \",\"Id\":\"' + wo.Id + '\",\"SVMXC__Scheduled_Date__c\":\"'+dtToday+'\",\"SVMXC__Scheduling_Retry_Count__c\":\"1\",\"SVMXC__Rate_Pricing_Rule__c\":\"0.0\"}'));
        obj1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LOCAL_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action - new Insert \",\"SVMXC__First_Assigned_DateTime__c\":\"' + dt + '\",\"SVMXC__Clock_Paused_Forever__c\":\"'+ isClockPaused + '\"}'));
        req.valueMap.add(obj1);
        
        system.debug(LoggingLevel.WARN, 'Request = :' + req);
        resp = (new SFMTransactionSync()).updateRecord(req, resp);
        resp = (new SFMTransactionSync()).getRecord(resp);
        system.debug(LoggingLevel.WARN, 'Response = :' + resp);     
    }
    
    static testMethod void handleExceptionCheck(){
        
        SVMXC.INTF_WebServicesDef.INTF_Response resp = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_Request req = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        req.userId = UserInfo.getUserId();
        req.profileId = 'DEVICE_UDID';
        req.groupId = 'CLIENT_REQUEST_ID';

        req.stringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
    
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Problem_Description__c = 'Insert from SFMTransactionSync_UT';
        insert wo;
        
        req.stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('Key', wo.Id));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', wo.Id));
        
        SVMXC__SM_SFMTransactionSync__c insertedRec = new SVMXC__SM_SFMTransactionSync__c();
        insertedRec.SVMXC__SM_Client_Sync_Request_Id__c = 'CLIENT_REQUEST_ID';
        Map<string, string> localIdByRecIdMap = new Map<String,String>();
        localIdByRecIdMap.put('LOCAL_ID',String.ValueOf(wo.Id));
        insertedRec.SVMXC__SM_Local_and_Platform_Id__c = json.serialize(localIdByRecIdMap);
        insertedRec.SVMXC__SM_User_Id__c = UserInfo.getUserID();
        insertedRec.SVMXC__SM_Device_UDID__c = 'DEVICE_UDID';
        insertedRec.SVMXC__SM_Operation_Type__c = 'INSERT';
        insert insertedRec;
        system.debug(LoggingLevel.WARN,'insertedRec = '+insertedRec);
        
        
        Datetime dt = system.now();
        boolean isClockPaused = false;
        Date dtToday = system.today();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap('Parent_Object_Name', 'SVMXC__Service_Order__c');
        obj1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('RECORD_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action \",\"Id\":\"' + wo.Id + '\",\"SVMXC__Scheduled_Date__c\":\"TRUE\",\"SVMXC__Scheduling_Retry_Count__c\":\"1\",\"SVMXC__Rate_Pricing_Rule__c\":\"0.0\"}'));
        //obj1.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LOCAL_ID', '{\"SVMXC__Problem_Description__c\":\"Test Custom Action - new Insert \",\"SVMXC__First_Assigned_DateTime__c\":\"' + dt + '\",\"SVMXC__Clock_Paused_Forever__c\":\"'+ isClockPaused + '\"}'));
        req.valueMap.add(obj1);
        
        try{
            resp = (new SFMTransactionSync()).updateRecord(req, resp);
            resp = (new SFMTransactionSync()).getRecord(resp);
        }catch(Exception Ex){
                system.debug(LoggingLevel.WARN, 'Exception is = :' + ex.getMessage());    
        }
            system.debug(LoggingLevel.WARN, 'Response = :' + resp);     
    }
    
    
    static testMethod void targetedSync_Update(){
        
        insertConfigData();
        createIPADSetting();
                
         //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
            
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutUpdate.eventName = 'PUT_UPDATE';
        req_PutUpdate.eventType = 'SYNC';
        req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'object_name';
        objVM.Value ='SVMXC__Service_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',Record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 30');
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = 'UPDATE';
        valuesVM.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM.ValueMap.add(valuesVM);
        
        fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 29');
        
        INTF_WebServicesDef.SVMXMap beforeSaveValuesVM = new INTF_WebServicesDef.SVMXMap();
        beforeSaveValuesVM.Key = 'BEFORE_SAVE';
        beforeSaveValuesVM.Values = new List<string>{JSON.serialize(fieldsFromClientMap)};
        fieldVM.ValueMap.add(beforeSaveValuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutUpdate.valueMap.add(objVM);
        
        
        INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
        putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
        req.valueMap.add(putUpdateVM);
        
        resp = (new SFMTransactionSync()).targetedSync(req);
        
        system.assertEquals(resp.success,true);
    }
    
    
    static testMethod void targetedSync_Insert(){
        
         //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
            
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutInsert = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutInsert.eventName = 'PUT_INSERT';
        req_PutInsert.eventType = 'SYNC';
        req_PutInsert.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Child object
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'Child_Object';
        objVM.Value ='SVMXC__Service_Order_Line__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('SVMXC__Is_Entitlement_Performed__c','false');
        fieldsFromClientMap.put('Id','a1K_local_1522658192613_1');
        fieldsFromClientMap.put('SVMXC__Service_Order__c',record_id);
        fieldsFromClientMap.put('SVMXC__Is_Billable__c','false');
        fieldsFromClientMap.put('SVMXC__Billable_Line_Price__c','150');
        fieldsFromClientMap.put('SVMXC__Date_Received__c','2018-04-02');
        fieldsFromClientMap.put('SVMXC__Start_Date_and_Time__c','2018-04-02 08:55:00');
        
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = 'a1K_local_1522658192613_1';
        valuesVM.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM.ValueMap.add(valuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutInsert.valueMap.add(objVM);
        
        //Parent object
        INTF_WebServicesDef.SVMXMap parentObjVM = new INTF_WebServicesDef.SVMXMap();
        parentObjVM.Key = 'Parent_Object';
        parentObjVM.Value ='SVMXC__Service_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM2 = new INTF_WebServicesDef.SVMXMap();
        fieldVM2.Key = 'Fields';
        
        fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('Id','a1K_local_1522658192618_1');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 30');
        fieldsFromClientMap.put('SVMXC__City__c','Bangalore');
        fieldsFromClientMap.put('SVMXC__Customer_Down__c', 'false');
        fieldsFromClientMap.put('SVMXC__Preferred_End_Time__c', '2018-04-02 08:55:00');
        fieldsFromClientMap.put('SVMXC__Rate_Pricing_Rule__c', '1400.50');
        fieldsFromClientMap.put('SVMXC__SM_Scheduled_Duration__c', '180.50');
        fieldsFromClientMap.put('SVMXC__Scheduled_Date__c', '2018-04-02');
        
        
        INTF_WebServicesDef.SVMXMap valuesVM2 = new INTF_WebServicesDef.SVMXMap();
        valuesVM2.Key = 'a1K_local_1522658192618_1';
        valuesVM2.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM2.ValueMap.add(valuesVM2);
        
        parentObjVM.valueMap.add(fieldVM2);
        req_PutInsert.valueMap.add(parentObjVM);
        
        INTF_WebServicesDef.SVMXMap putInsertVM = new INTF_WebServicesDef.SVMXMap('PUT_INSERT','');
        putInsertVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutInsert};
        req.valueMap.add(putInsertVM);
        
        resp = (new SFMTransactionSync()).targetedSync(req);
        
        system.assertEquals(resp.success,true);
    }
    
    static testMethod void targetedSync_Delete(){
        
         //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
            
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '123456710';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutDelete = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutDelete.eventName = 'PUT_DELETE';
        req_PutDelete.eventType = 'SYNC';
        req_PutDelete.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'Object_Name';
        objVM.Value ='SVMXC__Service_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = '';
        valuesVM.Value = record_Id;
        fieldVM.ValueMap.add(valuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutDelete.valueMap.add(objVM);
        
        INTF_WebServicesDef.SVMXMap putDeleteVM = new INTF_WebServicesDef.SVMXMap('PUT_DELETE','');
        putDeleteVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutDelete};
        req.valueMap.add(putDeleteVM);
        
        resp = (new SFMTransactionSync()).targetedSync(req);
        
        system.assertEquals(resp.success,true);
    }
    
    static testMethod void targetedSync_Exception(){
        
         //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
            
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutUpdate.eventName = 'PUT_UPDATE';
        req_PutUpdate.eventType = 'SYNC';
        req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'object_name';
        objVM.Value ='SVMXC__Work_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',Record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 30');
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = 'UPDATE';
        valuesVM.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM.ValueMap.add(valuesVM);
        
        fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 29');
        
        INTF_WebServicesDef.SVMXMap beforeSaveValuesVM = new INTF_WebServicesDef.SVMXMap();
        beforeSaveValuesVM.Key = 'BEFORE_SAVE';
        beforeSaveValuesVM.Values = new List<string>{JSON.serialize(fieldsFromClientMap)};
        fieldVM.ValueMap.add(beforeSaveValuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutUpdate.valueMap.add(objVM);
        
        
        INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
        putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
        req.valueMap.add(putUpdateVM);
        
        resp = (new SFMTransactionSync()).targetedSync(req);
        
        system.assertEquals(resp.success,false);
    }
    
    static testMethod void TS_Update_Conflict(){
        
        insertConfigData();
        createIPADSetting();
        
        //Conflict Setting
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Conflict Resolution', SVMXC__Internal_value__c = 'Allow user to choose', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
                
         //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
        
        SVMXC__Service_Order_Line__c wd1 = new SVMXC__Service_Order_Line__c();
        wd1.SVMXC__Service_Order__c = record_id;
        wd1.SVMXC__Line_Type__c = 'Labor';
        insert wd1;
        
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        Map<String, Datetime> mapRecordIdToLST = new Map<string, Datetime>();
        mapRecordIdToLST.put(record_id, System.Now()-2);
        
        INTF_WebServicesDef.SVMXMap valueMapTS = new INTF_WebServicesDef.SVMXMap('TS_KEYS', Json.serialize(mapRecordIdToLST));
        req.valueMap.add(valueMapTS);
        
        //Reference_Data
        INTF_WebServicesDef.SVMXMap valueMapReference = new INTF_WebServicesDef.SVMXMap('REFERENCE_DATA', '');
        
        INTF_WebServicesDef.SVMXMap objectVM = new INTF_WebServicesDef.SVMXMap('SVMXC__Service_Order__c', record_id);
        objectVM.values = new List<string>{'SVMXC__Service_Order_Line__c'};
        valueMapReference.valueMap.add(objectVM);
       
        req.valueMap.add(valueMapReference);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutUpdate.eventName = 'PUT_UPDATE';
        req_PutUpdate.eventType = 'SYNC';
        req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'object_name';
        objVM.Value ='SVMXC__Service_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',Record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 30');
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = 'UPDATE';
        valuesVM.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM.ValueMap.add(valuesVM);
        
        fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 29');
        
        INTF_WebServicesDef.SVMXMap beforeSaveValuesVM = new INTF_WebServicesDef.SVMXMap();
        beforeSaveValuesVM.Key = 'BEFORE_SAVE';
        beforeSaveValuesVM.Values = new List<string>{JSON.serialize(fieldsFromClientMap)};
        fieldVM.ValueMap.add(beforeSaveValuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutUpdate.valueMap.add(objVM);
        
        
        INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
        putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
        req.valueMap.add(putUpdateVM);
        
        resp = (new SFMTransactionSync()).targetedSync(req);
    }
    
    static testMethod void targeted_Attachment_Download(){
        
        insertConfigData();
        createIPADSetting();
        
        //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.DurationInMinutes = 60;
        evntObj.WhatId = record_id;
        insert evntObj;
        system.debug('-------'+evntObj);
        
        //Insert servicemax event
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
        svmxEvent.SVMXC__WhatId__c = record_id;
        insert svmxEvent;
        system.debug('-------'+svmxEvent);
        
        //Add attachment:
        Attachment attachment = new Attachment();
        string body1 = '';
        attachment.Body = Blob.valueOf(body1);
        attachment.Name = String.valueOf('testclass.txt');
        attachment.ParentId = record_id;
        insert attachment;
        
        //Insert files
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        INTF_SFDCFilesUtilityServices_UT.insertFiles(record_id);
        
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '123456789';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutUpdate.eventName = 'PUT_UPDATE';
        req_PutUpdate.eventType = 'SYNC';
        req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'object_name';
        objVM.Value ='SVMXC__Service_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 30');
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = 'UPDATE';
        valuesVM.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM.ValueMap.add(valuesVM);
        
        fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 29');
        
        INTF_WebServicesDef.SVMXMap beforeSaveValuesVM = new INTF_WebServicesDef.SVMXMap();
        beforeSaveValuesVM.Key = 'BEFORE_SAVE';
        beforeSaveValuesVM.Values = new List<string>{JSON.serialize(fieldsFromClientMap)};
        fieldVM.ValueMap.add(beforeSaveValuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutUpdate.valueMap.add(objVM);
        
        INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
        putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
        req.valueMap.add(putUpdateVM);
        
        INTF_WebServicesDef.SVMXMap refData = new INTF_WebServicesDef.SVMXMap('REFERENCE_DATA','');
        refData.ValueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Service_Order__c', String.ValueOF(record_id)));
        req.valueMap.add(refData);
        
        resp = (new SFMTransactionSync()).targetedSync(req);
        
        system.assertEquals(resp.success,true);
    }
    
    static testMethod void targeted_Checklist_Download(){
        
        insertConfigData();
        createIPADSetting();
        
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
        
        SVMXC__ServiceMax_Config_Data__c syncToGetEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventChecklist);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemEventChecklist = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemEventChecklist);
        
        //create process for Checklist
        SVMXC__ServiceMax_Processes__c checklistTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'CHECKLIST', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234');
        insert checklistTarMgrProcess;
        
        //create Config Data for Service Access Flow
        SVMXC__ServiceMax_Config_Data__c checkListConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId,SVMXC__Dispatch_Process__c = checklistTarMgrProcess.Id );
        configDataList.add(checkListConfigData);
        
        insert configDataList;
        
         //Insert data
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;

        String record_id = '';
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();//[select id from SVMXC__Service_Order__c limit 1];
        workOrder.SVMXC__Company__c = acc.Id;
        workOrder.SVMXC__Product__c = product1.Id;
        workOrder.SVMXC__City__c = 'Bangalore';
        Database.SaveResult Result = Database.insert(workOrder);
        record_id = Result.getId();
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = record_id;
        insert evntObj;
        
        //insert checklist record
        SVMXC__Checklist__c chkData = new SVMXC__Checklist__c();
        chkData.SVMXC__ChecklistProcessID__c = checklistTarMgrProcess.Id;
        chkData.SVMXC__Work_Order__c = record_id;
        chkData.SVMXC__ChecklistJSON__c  = 'testData';
        chkData.SVMXC__Status__c = 'Completed';
        chkData.SVMXC__What_Id__c = record_id;
        insert chkData;
        
        SVMXC__SM_Checklist_Attachment__c chkAttachment = new SVMXC__SM_Checklist_Attachment__c();
        chkAttachment.SVMXC__SM_Attachment_ID__c = 'Att1';
        chkAttachment.SVMXC__SM_Attachment_Name__c = 'testAtt';
        chkAttachment.SVMXC__SM_Checklist__c = chkData.Id;
        insert chkAttachment;
        
        //Insert files
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        INTF_SFDCFilesUtilityServices_UT.insertFiles(record_id);
        
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.SVMXClient clInfo = new INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:3.2.0', 'appname:iPad','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>{clInfo};
                
        req.eventType = 'SYNC';
        req.eventName = 'TARGETED_SYNC';
        req.value = '12345678901';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap valueMap1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.ValueOf(System.Now()-1));
        req.valueMap.add(valueMap1);
        
        INTF_WebServicesDef.INTF_SFMRequest req_PutUpdate = new INTF_WebServicesDef.INTF_SFMRequest();
        req_PutUpdate.eventName = 'PUT_UPDATE';
        req_PutUpdate.eventType = 'SYNC';
        req_PutUpdate.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap objVM = new INTF_WebServicesDef.SVMXMap();
        objVM.Key = 'object_name';
        objVM.Value ='SVMXC__Service_Order__c';
        
        INTF_WebServicesDef.SVMXMap fieldVM = new INTF_WebServicesDef.SVMXMap();
        fieldVM.Key = 'Fields';
        
        Map<String,string> fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',Record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 30');
        
        INTF_WebServicesDef.SVMXMap valuesVM = new INTF_WebServicesDef.SVMXMap();
        valuesVM.Key = 'UPDATE';
        valuesVM.Value = JSON.serialize(fieldsFromClientMap);
        fieldVM.ValueMap.add(valuesVM);
        
        fieldsFromClientMap = new Map<String,string>(); 
        fieldsFromClientMap.put('Id',record_id);
        fieldsFromClientMap.put('SVMXC__Priority__c','High');
        fieldsFromClientMap.put('SVMXC__Problem_Description__c','TS 29');
        
        INTF_WebServicesDef.SVMXMap beforeSaveValuesVM = new INTF_WebServicesDef.SVMXMap();
        beforeSaveValuesVM.Key = 'BEFORE_SAVE';
        beforeSaveValuesVM.Values = new List<string>{JSON.serialize(fieldsFromClientMap)};
        //fieldVM.ValueMap.add(beforeSaveValuesVM);
        
        objVM.valueMap.add(fieldVM);
        req_PutUpdate.valueMap.add(objVM);
        
        INTF_WebServicesDef.SVMXMap putUpdateVM = new INTF_WebServicesDef.SVMXMap('PUT_UPDATE','');
        putUpdateVM.lstInternal_Request = new List<INTF_WebServicesDef.INTF_SFMRequest>{req_PutUpdate};
        req.valueMap.add(putUpdateVM);
        
        INTF_WebServicesDef.SVMXMap refData = new INTF_WebServicesDef.SVMXMap('REFERENCE_DATA','');
        refData.ValueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Service_Order__c', String.ValueOF(record_id)));
        req.valueMap.add(refData);
        
        Test.startTest();
                resp = (new SFMTransactionSync()).targetedSync(req);
        Test.stopTest();
        
        system.assertEquals(resp.success,true);
        
            
    }
   
}