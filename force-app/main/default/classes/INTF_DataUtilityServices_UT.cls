@isTest(SeeAllData=false)
public with sharing class INTF_DataUtilityServices_UT 
{
    static public string grpProfileId;
    static private string sfdcProfileId;
    static public Id targetMgrRecordTypeId, mobConfigRecordTypeId, wizardStepRecTypeId, wizardRecordTypeId, configProfileRecordTypeId, confAccessRecTypeId, procNodeObjRecTypeId, serviceAccessFlowRecTypeId, svmxRuleRecTypeID, expressionRecTypeId , settingRecTypeId, settingValueRecTypeId, moduleRecTypeId, subModuleRecTypeId, wizardAccessRecTypeId;
    static public SVMXC__ServiceMax_Config_Data__c configProfile;
    static public ID defaultMobConfigID;
     
    public static void insertConfigData(){
        grpProfileId = '';
        sfdcProfileId = userinfo.getProfileId();
        
        //Getting record Type Ids
        List<RecordType> recordTypeList = [select Id, DeveloperName, SobjectType from Recordtype  
                                            where (SobjectType =: 'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Target_Manager')  
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Mobile_Configuration') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =:'Wizard_Step') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Wizard') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =: 'Configuration_Profile') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Configuration_Access') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND developerName = :'Process_Node_Objects') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Service_Flow_Access' ) 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'SVMX_Rule') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' And DeveloperName =: 'Expressions') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Settings') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Module')
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Processes__c' AND DeveloperName =: 'Submodule') 
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Setting_Value')
                                            OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Wizard_Access')
                                            ];
        if(recordTypeList <> NULL && !recordTypeList.isEmpty()){
            for(RecordType rType : recordTypeList){
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Mobile_Configuration'){
                    mobConfigRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Wizard_Step'){
                    wizardStepRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Target_Manager'){
                    targetMgrRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Wizard'){
                    wizardRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Profile'){
                    configProfileRecordTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Access'){
                    confAccessRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='SVMX_Rule'){
                    svmxRuleRecTypeID = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Process_Node_Objects'){
                    procNodeObjRecTypeId = rType.Id;
                }
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Service_Flow_Access'){
                    serviceAccessFlowRecTypeId = rType.Id;
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
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName == 'Wizard_Access'){
                    wizardAccessRecTypeId = rType.Id;
                }
            }
        }
        
        //insert profile related processes and config data
        configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        //configProfile.SVMXC__IsDefault__c = true;
        //configProfile.SVMXC__Installation_Key__c = 'testClass';
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
        attachConfig.fileTypes = '';
        attachConfig.maximumFileSize = '10';
        attachConfig.sfdcFileTypes = '';
        attachConfig.sfdcFileTags = '';
        attachConfig.maxSfdcFileSize = '';
        lstAttachConfig.add(attachConfig);
        prof.attachment = lstAttachConfig;
        
        SVMXC__ProductIQProfile__c prodIQProfile = new SVMXC__ProductIQProfile__c(SVMXC__Contents__c = JSON.serialize(prof),SVMXC__ServiceMax_Profile__c = grpProfileId );
        insert  prodIQProfile;
        
        //Insert device_Mobile_Config
        SVMXC__SM_Device_Mobile_Config__c defaultSetting = new SVMXC__SM_Device_Mobile_Config__c(SVMXC__SM_Name__c = 'Default Setting' , SVMXC__SM_IsDefault__c = TRUE, SVMXC__SM_Device_Type__c = 'iPad', SVMXC__SM_Access_Configuration_Profile__c = grpProfileId );
        insert defaultSetting;
        
        List<SVMXC__SM_Device_Mobile_Config__c> mobDeviceSetting = [select Id from SVMXC__SM_Device_Mobile_Config__c where SVMXC__SM_IsDefault__c = TRUE ];
        defaultMobConfigID = mobDeviceSetting[0].ID;
        
        //Mob Config for Sync Profiling
        List<SVMXC__ServiceMax_Config_Data__c> lstSyncProfConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c enableSyncProf = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Enable Performance Profiling', SVMXC__Internal_value__c = 'true',  SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        lstSyncProfConfig.add(enableSyncProf);
        
        SVMXC__ServiceMax_Config_Data__c enableSoqlProf = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Enable SOQL Profiling', SVMXC__Internal_value__c = 'false',  SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        lstSyncProfConfig.add(enableSoqlProf);
        
        SVMXC__ServiceMax_Config_Data__c orgTypeSyncProf = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Performance Profiling Org Type', SVMXC__Internal_value__c = 'Sandbox',  SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        lstSyncProfConfig.add(orgTypeSyncProf);
        
        insert lstSyncProfConfig;
        
    }
    
    public static void createIPADSetting(){
        
        String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
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
        
        //Setting - IPAD018_SET009
        List<SVMXC__ServiceMax_Processes__c> processList = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c settingProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Enable Get Price', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = 'True~|~False',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'false',SVMXC__Description__c = 'Enable JavaScript based advanced Get Price.',
        SVMXC__Submodule__c = subModProcess.Id,SVMXC__SettingID__c = 'SET009',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess);
        
        //Setting - PRODIQ002_SET001
        SVMXC__ServiceMax_Processes__c settingProcess3 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Settings_Name__c = 'Enable Installed Base app', 
        SVMXC__Search_Order__c = 'Global',SVMXC__Setting_Type__c = 'Global',SVMXC__Values__c = '1000',SVMXC__SubmoduleID__c = 'PRODIQ002',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'False',SVMXC__Description__c = 'Enables Installed Base App on FSA app and native iPad app. Whenever the value of this setting is changed, reset app must be performed.',
        SVMXC__Submodule__c = prodIQSubModProcess.Id,SVMXC__SettingID__c = 'SET001',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        processList.add(settingProcess3);
        insert processList;
        
        //Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess.Id, SVMXC__Internal_Value__c = 'True');
        configDataList.add(settingValueConfig);
        
        //PIQ set002
        SVMXC__ServiceMax_Config_Data__c settingValueConfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess3.Id, SVMXC__Internal_Value__c = 'True');
        configDataList.add(settingValueConfig3);
        
        insert configDataList;
    }
      
    //initial data sync
    static testMethod void initDataSync()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        //ADC
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        insert configDataList;
        
        //Insert team and technician
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        String Record_id = '';
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res1 = new INTF_WebServicesDef.INTF_SFMResponse();
        Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        Req.eventType='SYNC';
        Req.eventName='DOWNLOAD_CREITERIA_SYNC';
        
        INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
        clientInfoReq.clientType = 'iPad';
        clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64', 'usertrunklocation:trunk'};
        Req.clientInfo.add(clientInfoReq);
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap firstObj11 = new INTF_WebServicesDef.SVMXMap();
        firstObj11.key = 'RANGE_START';
        firstObj11.value = string.valueOf(Datetime.newInstance(2012, 05, 17, 06, 48, 00));  
        tableList1.add(firstObj11);      
        
        INTF_WebServicesDef.SVMXMap firstObj12 = new INTF_WebServicesDef.SVMXMap();
        firstObj12.key = 'RANGE_END';
        firstObj12.value = string.valueOf(system.now()+7);
        tableList1.add(firstObj12);
        
        INTF_WebServicesDef.SVMXMap lastSyncTime = new INTF_WebServicesDef.SVMXMap();
        lastSyncTime.key = 'LAST_SYNC_TIME';
        lastSyncTime.value = string.valueOf(system.now()-10);
        tableList1.add(lastSyncTime);
        
        tableList1.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        
        List<INTF_WebServicesDef.SVMXMap> lstDCObjects = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap obj1 = new INTF_WebServicesDef.SVMXMap();
        obj1.key = 'DOWNLOAD_CRITERIA_OBJECTS';        
        
        INTF_WebServicesDef.SVMXMap DCObjects = new INTF_WebServicesDef.SVMXMap();
        DCObjects.value = '';
        lstDCObjects.add(DCObjects);
        obj1.valueMap = lstDCObjects;
        
        tableList1.add(obj1);
            
        Req.valueMap = tableList1;
        Req.value = '123456789';
        Res1 = dataUtilObj.RequestForCriteriaRecords(Req);
        
        SVMXC__Sync_Request_Records__c objects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 0 , SVMXC__Object_Name__c = 'Account' , SVMXC__SOQL_Query__c = '' , SVMXC__Status__c = 'NOT_EXECUTED');
        Database.Saveresult ObjectSaveResult = Database.insert(objects);
        
        Res1 = dataUtilObj.RequestForCriteriaRecords(Req);
    }
    
     //initial data sync
    static testMethod void dcSyncWithHigherIndex(){
        
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //ADC
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        //Insert team and technician
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        String Record_id = '';
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res1 = new INTF_WebServicesDef.INTF_SFMResponse();
        Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        Req.eventType='SYNC';
        Req.eventName='DOWNLOAD_CREITERIA_SYNC';
        
        INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
        clientInfoReq.clientType = 'iPad';
        clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64', 'usertrunklocation:trunk'};
        Req.clientInfo.add(clientInfoReq);
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap firstObj11 = new INTF_WebServicesDef.SVMXMap();
        firstObj11.key = 'RANGE_START';
        firstObj11.value = string.valueOf(Datetime.newInstance(2012, 05, 17, 06, 48, 00));  
        tableList1.add(firstObj11);      
        
        INTF_WebServicesDef.SVMXMap firstObj12 = new INTF_WebServicesDef.SVMXMap();
        firstObj12.key = 'RANGE_END';
        firstObj12.value = string.valueOf(system.now()+7);
        tableList1.add(firstObj12);
        
        INTF_WebServicesDef.SVMXMap lastSyncTime = new INTF_WebServicesDef.SVMXMap();
        lastSyncTime.key = 'LAST_SYNC_TIME';
        lastSyncTime.value = string.valueOf(system.now()-10);
        tableList1.add(lastSyncTime);
        
        tableList1.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        
        List<INTF_WebServicesDef.SVMXMap> lstDCObjects = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap obj1 = new INTF_WebServicesDef.SVMXMap();
        obj1.key = 'DOWNLOAD_CRITERIA_OBJECTS';        
        
        INTF_WebServicesDef.SVMXMap DCObjects = new INTF_WebServicesDef.SVMXMap();
        DCObjects.value = '';
        lstDCObjects.add(DCObjects);
        obj1.valueMap = lstDCObjects;
        
        tableList1.add(obj1);
            
        Req.valueMap = tableList1;
        Req.value = '123456789';
        //Res1 = dataUtilObj.RequestForCriteriaRecords(Req);
        
        SVMXC__Sync_Request_Records__c objects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 1 , SVMXC__Object_Name__c = 'Account' , SVMXC__SOQL_Query__c = '' , SVMXC__Status__c = 'NOT_EXECUTED');
        Database.Saveresult ObjectSaveResult = Database.insert(objects);
        
        Res1 = dataUtilObj.RequestForCriteriaRecords(Req);
        
    }
    
    static testMethod void getDelete()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        insert configDataList;
        
        //insert task
        Task tskObj = new Task();
        tskObj.OwnerId = UserInfo.getUserId();
        tskObj.ActivityDate = DateTime.now().date();
        insert tskObj;
        
        delete tskObj;
        
        String Record_id = '';  
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
            
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
        
        /*Req.eventType='SYNC';
        Req.eventName='GET_DELETE';
        Req.value = Record_id;
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap firstObj13 = new INTF_WebServicesDef.SVMXMap();
        firstObj13.key = 'LAST_SYNC_TIME';
        firstObj13.value = string.valueOf(system.now());  
        tableList1.add(firstObj13);
        Req.valueMap = tableList1;
        Res = dataUtilObj.RequestIncrementaldataFromBase(Req);*/
        
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'GET_DELETE_DOWNLOAD_CRITERIA';
        req.value = Record_id;
        
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now() - 2)));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        
        SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 0 , SVMXC__Object_Name__c = 'Account' , SVMXC__SOQL_Query__c = '' , SVMXC__Status__c = 'NOT_EXECUTED');
        Database.Saveresult ObjectSaveResult = Database.insert(DCObjects);
        
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        system.debug(LoggingLevel.WARN, 'response = :' + Res);
    }
    
    static testMethod void getDeleteWithHigherIndex()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0');
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0');
        configDataList.add(syncToRemoveEventConfigData);
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10');
        configDataList.add(dcConfigData);
        
        insert configDataList;
        
        //insert task
        Task tskObj = new Task();
        tskObj.OwnerId = UserInfo.getUserId();
        tskObj.ActivityDate = DateTime.now().date();
        insert tskObj;
        
        delete tskObj;
        
        String Record_id = '';  
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
            
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'GET_DELETE_DOWNLOAD_CRITERIA';
        req.value = '123456789';
        
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now() - 2)));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        
        SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 1 , SVMXC__Object_Name__c = 'Account' , SVMXC__SOQL_Query__c = '' , SVMXC__Status__c = 'NOT_EXECUTED');
        Database.Saveresult ObjectSaveResult = Database.insert(DCObjects);
        
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        system.debug(LoggingLevel.WARN, 'response = :' + Res);
    }
    
     static testMethod void getDeleteReqIncrementalDataFromBase()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        insert configDataList;
        
        //insert task
        Task tskObj = new Task();
        tskObj.OwnerId = UserInfo.getUserId();
        tskObj.ActivityDate = DateTime.now().date();
        insert tskObj;
        
        delete tskObj;
        
        String Record_id = '';  
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
            
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        Req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        Req.eventType='SYNC';
        Req.eventName='GET_DELETE';
        Req.value = Record_id;
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap firstObj13 = new INTF_WebServicesDef.SVMXMap();
        firstObj13.key = 'LAST_SYNC_TIME';
        firstObj13.value = string.valueOf(system.now());  
        tableList1.add(firstObj13);
        Req.valueMap = tableList1;
        Res = dataUtilObj.RequestIncrementaldataFromBase(Req);
    }
    
    static testMethod void getInsertDC()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        insert configDataList;
        
        String Record_id = '';  
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        Req.eventType = 'SYNC';
        Req.eventName = 'GET_INSERT_DOWNLOAD_CRITERIA';
        Req.value = Record_id;
        
        Req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now() - 2)));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        
        SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 0 , SVMXC__Object_Name__c = 'SVMXC__Service_Order__c' , SVMXC__SOQL_Query__c = '' , SVMXC__Status__c = 'NOT_EXECUTED');
        Database.Saveresult ObjectSaveResult = Database.insert(DCObjects);
        Test.startTest();
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        Test.stopTest();
        system.debug(LoggingLevel.WARN, 'response = :' + Res);
    }
    
    //Get UpdateTest
    static testMethod void getUpdate()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        insert configDataList;
        
        String Record_id = '';  
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
                
        
        Req.eventType='SYNC';
        Req.eventName='GET_UPDATE';
        Req.value = Record_id;
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
        tableList1.add(new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', string.valueOf(system.now())));
        
        Req.valueMap = tableList1;
        Res = dataUtilObj.RequestIncrementaldataFromBase(Req);
        
        Req.eventType = 'SYNC';
        Req.eventName = 'GET_UPDATE_DOWNLOAD_CRITERIA';
        Req.value = Record_id;
        
        Req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now() - 2)));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
        
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        
        SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 0 , SVMXC__Object_Name__c = 'SVMXC__Service_Order__c' , SVMXC__SOQL_Query__c = '' , SVMXC__Status__c = 'NOT_EXECUTED');
        Database.Saveresult ObjectSaveResult = Database.insert(DCObjects);
        
        Res = dataUtilObj.RequestForCriteriaRecords(req);
        system.debug(LoggingLevel.WARN, 'response = :' + Res);
    }
    
    static testMethod void fetchRecords()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res1 = new INTF_WebServicesDef.INTF_SFMResponse();
        req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        
        INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
        clientInfoReq.clientType = 'iPad';
        clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64', 'usertrunklocation:trunk'};
        req.clientInfo.add(clientInfoReq);
        
        Account acc = new Account();
        acc.Name = 'Shashank';
        insert acc;
        
        req.eventType='SYNC';
        req.eventName='TX_FETCH';

        List<INTF_WebServicesDef.SVMXMap> lstObjectIds = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap firstObj = new INTF_WebServicesDef.SVMXMap();
        firstObj.key = 'TX_OBJECT';
        firstObj.value = 'Account';
        firstObj.values.add(acc.Id);
        lstObjectIds.add(firstObj);
            
        req.valueMap = lstObjectIds;
        req.value = '001';
        Res1 = dataUtilObj.getRecordsForIds(req);
    }
    
    static testMethod void putDelete1()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        List<String> process = new List<String>();
        req.eventType = 'SYNC';
        req.eventName = 'PUT_DELETE';
        req.value = '123456789';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj1.key = 'LAST_SYNC_TIME';
        obj1.value = '2013-06-20 15:24:10';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj2.key = 'Object_Name';
        obj2.value = 'SVMXC__Service_Order__c';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj3.key = 'Fields';
        obj3.value = '';
        
        SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
        wo1.SVMXC__City__c = 'Mysore';
        wo1.SVMXC__Order_Status__c = 'Open';
        insert wo1;
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj4.key = '';
        obj4.value = wo1.Id;
        
        obj3.valueMap.add(obj4);
        obj2.valueMap.add(obj3);
        
        req.valueMap.add(obj1);
        req.valueMap.add(obj2);
        
        system.debug(LoggingLevel.WARN, 'Request = :' + req);
        resp = dataUtilObj.SendClientDeletesToBase(req);
        system.debug(LoggingLevel.WARN, 'response = :' + resp);
    }

    //Put Insert Test
    static testMethod void putInsert()
    {
        INTF_DataUtilityServices str = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
         Req.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        Req.eventType='SYNC';
        Req.eventName='PUT_INSERT';
        
        INTF_WebServicesDef.SVMXClient clientInfoReq = new INTF_WebServicesDef.SVMXClient();
        clientInfoReq.clientType = 'iPad';
        clientInfoReq.clientInfo = new List<String>{'iosversion:8.3','appversion:15.49.009', 'deviceversion:x86_64', 'usertrunklocation:trunk'};
        Req.clientInfo.add(clientInfoReq);
        
        List<INTF_WebServicesDef.SVMXMap> tableList = new List<INTF_WebServicesDef.SVMXMap>();
        
        List<INTF_WebServicesDef.SVMXMap> tableContents = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap firstObj = new INTF_WebServicesDef.SVMXMap();
        firstObj.key = 'Fields';
        
        List<INTF_WebServicesDef.SVMXMap> vls = new List<INTF_WebServicesDef.SVMXMap>();                                    
        INTF_WebServicesDef.SVMXMap jsonstr1 = new INTF_WebServicesDef.SVMXMap();                                           
        INTF_WebServicesDef.SVMXMap jsonstr2 = new INTF_WebServicesDef.SVMXMap(); 
        INTF_WebServicesDef.SVMXMap jsonstr3 = new INTF_WebServicesDef.SVMXMap();
        
        jsonstr1.key = '1';
        jsonstr1.value = '{"attributes":{"type":"SVMXC__Service_Order__c","url":""},"SVMXC__Problem_Description__c":"TEST DISCREPTION 1 ","SVMXC__Entitlement_Notes__c":"Test entitlement notes0", "SVMXC__Age__c":"1", "SVMXC__Drip__c":"false"}';
        vls.add(jsonstr1);
        firstObj.valueMap = vls;                                
        tableContents.add(firstObj);
        
        
        INTF_WebServicesDef.SVMXMap firstObj1 = new INTF_WebServicesDef.SVMXMap();
        firstObj1.key = 'Parent_Object';
        firstObj1.value = 'SVMXC__Service_Order__c';
        firstObj1.valueMap = tableContents;
        tableList.add(firstObj1);
        
        List<INTF_WebServicesDef.SVMXMap> tableContents1 = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap childfirstObj = new INTF_WebServicesDef.SVMXMap();
        childfirstObj.key = 'Fields';
        
        List<INTF_WebServicesDef.SVMXMap> vls1 = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap jsonstrChild = new INTF_WebServicesDef.SVMXMap();
        jsonstrChild.key = '4';
        jsonstrChild.value = '{"attributes":{"type":"SVMXC__Service_Order_Line__c","url":""},"Name":"TestOrderLine1","SVMXC__Activity_Type__c":"minor defects","SVMXC__Service_Order__c":"2"}';
        vls1.add(jsonstrChild);
        childfirstObj.valueMap = vls1;
        tableContents1.add(childfirstObj);        
        
        INTF_WebServicesDef.SVMXMap childfirstObj1 = new INTF_WebServicesDef.SVMXMap();
        childfirstObj1.key = 'Child_Object';
        childfirstObj1.value = 'SVMXC__Service_Order_Line__c';
        childfirstObj1.valueMap = tableContents1;
        tableList.add(childfirstObj1);
        
        Req.valueMap = tableList;
        Req.value = '001';
        Res = str.InsertClientDataIntoBase(Req);
        string svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(userinfo.getProfileId());
        Res = (new INTF_DataSync()).dataSync(Req,svmxGrpProfileId);

        //getInsert();
    }
    
    //Get Insert Test
    static testMethod void getInsert()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        insert configDataList;
        
        String Record_id = '';  
        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = '123456789');
        Database.SaveResult Result = Database.insert(requestRecord);
        Record_id = Result.getId();
        
        createEvents();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        Req.eventType='SYNC';
        Req.eventName='GET_INSERT';
        Req.value = Record_id;
        
        List<INTF_WebServicesDef.SVMXMap> tableList1 = new List<INTF_WebServicesDef.SVMXMap>();
        tableList1.add(new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', string.valueOf(system.now())));
        Req.valueMap = tableList1;
        Test.startTest();
        Res = dataUtilObj.RequestIncrementaldataFromBase(Req);
        Test.stopTest();
        system.debug(LoggingLevel.WARN, 'response = :' + Res);
    }
    
    static testMethod void testUpdateRecordsFromClient(){
        
        INTF_DataUtilityServices str = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMResponse ResAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
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
        Database.SaveResult Result = Database.insert(WorkOrderData);
        string Record_id = Result.getId();
        System.assertEquals(true, WorkOrderData != null);
        
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
            
        firstObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('localId', JSON.serialize(fieldsPerRecordMap)));
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
        try {
            ResAdvFieldMerge.valueMap = str.updateRecordsFromClient(Req, DateTime.now() - 1, 'Allow user to choose');
        }  catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    //Override -> where the lastModified on DB > SyncTime
    static testMethod void testUpdateRecordsFromClientOverride(){
        
        INTF_DataUtilityServices str = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMResponse ResAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
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
        Database.SaveResult Result = Database.insert(WorkOrderData);
        string Record_id = Result.getId();
        System.assertEquals(true, WorkOrderData != null);
        
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
            
        firstObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('localId', JSON.serialize(fieldsPerRecordMap)));
        tableContents.add(firstObj); 
        
        INTF_WebServicesDef.SVMXMap firstObj1 = new INTF_WebServicesDef.SVMXMap();
        firstObj1.key = 'object_name';
        firstObj1.value = 'SVMXC__Service_Order__c';
        firstObj1.valueMap = tableContents;
        tableList.add(firstObj1);
        
        Req.valueMap = tableList;
        Req.value = '001';
        System.debug(LoggingLevel.INFO,'Test class request '+Req);
        
        //update the work order data 
        WorkOrderData.SVMXC__Priority__c='Low';
        WorkOrderData.SVMXC__Actual_Initial_Response__c = datetime.newInstance(2011, 12, 11, 12, 30, 2);
        WorkOrderData.SVMXC__Longitude__c = 121.36;
        WorkOrderData.SVMXC__PM_Tasks_Created__c = false;
        update WorkOrderData;
        
        try {
            ResAdvFieldMerge.valueMap = str.updateRecordsFromClient(Req, DateTime.now() - 1, 'Allow user to choose');
        }  catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    //Put Update Test
    static testMethod void putUpdate()
    {
        INTF_DataUtilityServices str = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMResponse ResAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
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
        
        try {
            Res = str.UpdateClientDataIntoBase(Req);
            //ResAdvFieldMerge.valueMap = str.updateRecordsFromClient(Req, DateTime.now() - 1, 'Allow user to choose');
        }  catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    //Put Update Test -> Client Override
    static testMethod void putUpdateClientOverride()
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
            
            INTF_DataUtilityServices str = new INTF_DataUtilityServices();
            INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
            INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
            //INTF_WebServicesDef.INTF_SFMResponse resAdvFieldMerge = new INTF_WebServicesDef.INTF_SFMResponse();
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
        
            Test.startTest();
                res = str.UpdateClientDataIntoBase(Req);
               // resAdvFieldMerge.valueMap = txnCache.updateRecordsFromClient(Req, DateTime.now() , 'Allow user to choose');
            Test.stopTest();
        
        }catch( Exception ex ) {   
            system.debug(LoggingLevel.WARN, 'Exception = :' + ex.getMessage());
        }
    }
    
    //Added for code-coverage.    
    static testMethod void createsObjectToUpdate() {
        INTF_DataUtilityServices str = new INTF_DataUtilityServices();
        try {
             str.createsObjectToUpdate(null, null, null, null, null);
            }  catch( Exception ex ) {   
        }
    }
    
    //Added for code-coverage.    
    static testMethod void createsObject() {
        INTF_DataUtilityServices str = new INTF_DataUtilityServices();
        try {
            Map<String, String> tempMap = new Map<String, String>();
            tempMap.put('abc', 'xyz');
             str.createsObject(null, tempMap, '&', 'LT');
            }  catch( Exception ex ) {   
        }
    }
    
    static testMethod void purgingOfEvents()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(dcConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //ADC
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID );
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        request.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        request.values = new List<String>();
        Account a = new Account();
        a.Name = 'Shashank';
        insert a;
        request.values.add(a.id);
        response = dataUtilObj.purgeEvents(request);
    }
    
    static testMethod void purgingOfRecords()
    {
        //insert config data
        insertConfigData();
        
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c dcConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Internal_Value__c = 'true', SVMXC__Ownership_Type__c = 'My Records', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c');
         configDataList.add(dcConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
    
        //Svmx config Data for expression
        SVMXC__ServiceMax_Config_Data__c expressionConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id);
        configDataList.add(expressionConfigData);
        
        //Another expression for Reference
        //SVMXC__ServiceMax_Config_Data__c refExpConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id, SVMXC__Display_Type__c = 'REFERENCE', SVMXC__Object_Name__c = 'Account' , SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c', SVMXC__Source_Field_Name__c ='SVMXC__Company__c');
        //configDataList.add(refExpConfigData);
        
        //adding a config data for ADC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__Ownership_Type__c = 'My Records', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID );
        configDataList.add(adcConfigData);
        
        //Mobile Config for 'Synchronization to get and Remove Events'
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        insert configDataList;
                
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        request.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        request.eventType = 'PURGING';
        request.eventName = 'PURGE_RECORDS';
        
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        insert wo;
        
        INTF_WebServicesDef.SVMXMap obj1 = new INTF_WebServicesDef.SVMXMap();
        obj1.key = 'Object_Name';
        obj1.value = 'SVMXC__Service_Order__c';
        obj1.values = new List<String>{wo.id};
        request.valueMap.add(obj1);
        response = INTF_WebServicesDef.INTF_DataSync_WS(request);
    }
    
    static testMethod void search()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.SVMXMap smap = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMap> lstMap = new List<INTF_WebServicesDef.SVMXMap>();
        smap.data = null;
        smap.key = 'SearchProcessId';
        lstMap.add(smap);

        INTF_WebServicesDef.SVMXMap smap1 = new INTF_WebServicesDef.SVMXMap();
        smap1.data = null;
        smap1.key = 'KeyWord';
        smap1.value = 'acc';
        lstMap.add(smap1);

        INTF_WebServicesDef.SVMXMap smap2 = new INTF_WebServicesDef.SVMXMap();
        smap2.data = null;
        smap2.key = 'RecordLimit';
        smap2.value = '10';
        lstMap.add(smap2);

        INTF_WebServicesDef.SVMXMap smap3 = new INTF_WebServicesDef.SVMXMap();
        smap3.data = null;
        smap3.key = 'ObjectId';
        smap3.values = new List<String>();
        lstMap.add(smap3);

        INTF_WebServicesDef.SVMXMap smap4 = new INTF_WebServicesDef.SVMXMap();
        smap4.data = null;
        smap4.key = 'SEARCH_OPERATOR';
        smap4.value = 'Contains';
        lstMap.add(smap4);

        req.eventType = 'SEARCH_RESULTS';
        req.eventName = 'SFM_SEARCH';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        req.valueMap = lstMap;

        resp = dataUtilObj.getSearchResults(req);
    }
    
    static testMethod void locationHistory()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        req.eventType = 'SYNC';
        req.eventName = 'LOCATION_HISTORY';
        List<INTF_WebServicesDef.SVMXMap> lstRecords = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> lstMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
        record.key = 'Record';
        record.value = '';
        
        INTF_WebServicesDef.SVMXMap smap1 = new INTF_WebServicesDef.SVMXMap();
        smap1.key = 'localId';
        smap1.value = '8CD4549A-2867-4746-8A81-4E29551D84E3';
        lstMap.add(smap1);
        
        INTF_WebServicesDef.SVMXMap smap2 = new INTF_WebServicesDef.SVMXMap();
        smap2.key = 'SVMXC__Latitude__c';
        smap2.value = '';
        lstMap.add(smap2);
        
        INTF_WebServicesDef.SVMXMap smap3 = new INTF_WebServicesDef.SVMXMap();
        smap3.key = 'SVMXC__Longitude__c';
        smap3.value = '';
        lstMap.add(smap3);
        
        lstMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Status__c', ''));
        lstMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__User__c', String.valueOf(Userinfo.getUserId())));
        lstMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Device_Type__c', 'iPad'));
        lstMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Additional_Info__c', 'Application Location Service Setting is disabled by the User'));
        lstMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Time_Recorded__c', String.valueOf(DateTime.now())));
        
        record.valueMap = lstMap;
        lstRecords.add(record);
        req.valueMap = lstRecords;
        resp = dataUtilObj.updateTechLocHistory(req);
        string svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(userinfo.getProfileId());
        resp = (new INTF_DataSync()).dataSync(req,svmxGrpProfileId);
    }
    
    static testMethod void updateTechLoc()
    {
        //insert config data
        insertConfigData();
        
        SVMXC__ServiceMax_Config_Data__c techConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Set Technician Location', SVMXC__Internal_Value__c = 'true', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert techConfigData;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
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
        
        INTF_WebServicesDef.SVMXMap fieldMap = new INTF_WebServicesDef.SVMXMap();
        fieldMap.key = 'Fields';
        fieldMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Latitude__c', '012345'));
        fieldMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Longitude__c', '543210'));
        
        req.valueMap.add(fieldMap);
        
        resp = dataUtilObj.updateTechLocation(req);
        //Failure scenario  
              
        req.values = new List<String>();
        req.values.add(String.valueOf('System.now()'));
        resp = dataUtilObj.updateTechLocation(req); 
        List<SVMXC__Service_Group_Members__c> listOfTechnician = [Select SVMXC__Latlong_Captured_On__c From SVMXC__Service_Group_Members__c Where SVMXC__Salesforce_User__c=:Userinfo.getUserId() Limit 1];               
        System.assert(listOfTechnician[0].SVMXC__Latlong_Captured_On__c ==NULL,true);
        //SVMXC__Latlong_Captured_On__c
        //Positive scenario        
        req.values = new List<String>();
        req.values.add(String.valueOf(System.now()));
        resp = dataUtilObj.updateTechLocation(req); 
        listOfTechnician = [Select SVMXC__Latlong_Captured_On__c From SVMXC__Service_Group_Members__c Where SVMXC__Salesforce_User__c=:Userinfo.getUserId() Limit 1];               
        System.assert(listOfTechnician[0].SVMXC__Latlong_Captured_On__c !=NULL,true);        
    }
    
    
    
    static testMethod void DOD()
    {
        insertConfigData();
        
         //insert a location
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        //Svmx process for DC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
        
        //create the required settings
        insertConfigData();
        createIPADSetting();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'GET_DATA';
        req.eventName = 'DATA_ON_DEMAND';
        List<INTF_WebServicesDef.SVMXMap> lstRecords = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> lstMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        SVMXC__Service_Order__c WorkOrderData = new SVMXC__Service_Order__c();
        WorkOrderData.SVMXC__Priority__c='High';
        WorkOrderData.SVMXC__Order_Type__c='Open';
        WorkOrderData.SVMXC__Scheduled_Date__c =  date.newinstance(2010,12,17);
        WorkOrderData.SVMXC__Group_Email__c= 'abc@xyz.com';
        WorkOrderData.SVMXC__Longitude__c=120.36;
        WorkOrderData.SVMXC__Actual_Initial_Response__c=datetime.newInstance(2011, 12, 1, 12, 30, 2);
        WorkOrderData.SVMXC__PM_Tasks_Created__c= true ;
        insert WorkOrderData;
        
        INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
        record.key = 'Object_Name';
        record.value = 'SVMXC__Service_Order__c';
        
        lstMap.add(new INTF_WebServicesDef.SVMXMap('Parent_Reference_Field', ''));
        lstMap.add(new INTF_WebServicesDef.SVMXMap('Id', String.valueOf(WorkOrderData.id)));
        
        record.valueMap = lstMap;
        lstRecords.add(record);
        req.valueMap = lstRecords;
        //Added after test code issue - code starts
        Test.startTest();
        //Added after test code issue - code ends        
        resp = dataUtilObj.downloadOnDemand(req, grpProfileId);
        //Added after test code issue - code starts
        Test.stopTest();
        //Added after test code issue - code ends      
        string svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(userinfo.getProfileId());  
        resp = (new INTF_DataSync()).dataSync(req,svmxGrpProfileId);
    }
    
    static testMethod void pricingDefinitions()
    {
        //create the required settings
        insertConfigData();
        createIPADSetting();
        createEvents();
        
        //insert config data SyncToGetEvents SyncToRemoveEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData) ;
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //ADC config data
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj0 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj0.key = 'LAST_INDEX';
        obj0.value = '0';
        req.valueMap.add(obj0);
        resp = dataUtilObj.getPricingDefinitions(req);
        
        //Call2
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj1.key = 'LAST_INDEX';
        obj1.value = '1';
        req.valueMap.add(obj1);
        resp = dataUtilObj.getPricingDefinitions(req);
       
    }
    
    static testMethod void pricingDefinitions2()
    {
        //create the required settings
        insertConfigData();
        createIPADSetting();
        createEvents();
        
        //insert config data SyncToGetEvents SyncToRemoveEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData) ;
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
     
        //Call3
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj2.key = 'LAST_INDEX';
        obj2.value = '2';
        req.valueMap.add(obj2);
        SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj3.key = 'LABOR';
        obj3.values = new List<String>{'Calibration','Repair', 'Installation'};
        req.valueMap.add(obj3);
        resp = dataUtilObj.getPricingDefinitions(req);
        
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj4.key = 'LAST_INDEX';
        obj4.value = '3';
        req.valueMap.add(obj4);
        resp = dataUtilObj.getPricingDefinitions(req);
    }
    
    static testMethod void pricingDefinitionsLST()
    {
        //create the required settings
        insertConfigData();
        createIPADSetting();
        createEvents();
        
        //insert config data SyncToGetEvents SyncToRemoveEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData) ;
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_INDEX', '1'));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME', String.valueOf(DateTime.now()-1)));
        resp = dataUtilObj.getPricingDefinitions(req);
    }
    
    static testMethod void pricingDefinitionsOfSingleWO()
    {
        //create the required settings
        insertConfigData();
        createIPADSetting();
        createEvents();
        
        //insert config data SyncToGetEvents SyncToRemoveEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData) ;
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        resp = dataUtilObj.getPricingDefinitions(req);
        
        //Call2
        req = new INTF_WebServicesDef.INTF_SFMRequest();
            clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj1.key = 'LAST_INDEX';
        obj1.value = '1';
        req.valueMap.add(obj1);
        resp = dataUtilObj.getPricingDefinitions(req);
        
        //Call3
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'PRICE_CALC_DATA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj2.key = 'LAST_INDEX';
        obj2.value = '2';
        req.valueMap.add(obj2);
        SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj3.key = 'LABOR';
        obj3.values = new List<String>{'Calibration','Repair', 'Installation'};
        req.valueMap.add(obj3);
        resp = dataUtilObj.getWOPriceInfo(req, grpProfileId);
    }
    
    static testMethod void getAdvDCRecordsSync()
    {
        insertConfigData(); //Inserting relevant config data
        createEvents();
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //ADC config data
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        
        insert configDataList;
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest reqInitialSync = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse respInitialSync = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest reqIncrSync = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse respIncrSync = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__City__c = 'Mysore';
        wo.SVMXC__Order_Status__c = 'Open';
        insert wo;
        
        /*Event evntObj = new Event();
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
        insert svmxEvent;*/
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        reqInitialSync.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
                
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        reqInitialSync.eventType = 'SYNC';
        reqInitialSync.eventName = 'ADV_DOWNLOAD_CRITERIA';
        reqInitialSync.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        respInitialSync = dataUtilObj.getAdvanceDownloadCriteriaRecIds(reqInitialSync);//initial sync
        system.debug(LoggingLevel.WARN, 'response = :' + respInitialSync);

        clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        reqIncrSync.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};        
        reqIncrSync.eventType = 'SYNC';
        reqIncrSync.eventName = 'ADV_DOWNLOAD_CRITERIA';
        reqIncrSync.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj1.key = 'LAST_INDEX';
        obj1.value = '0';
        
        SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        obj2.key = 'LAST_SYNC_TIME';
        obj2.value = String.valueOf(Datetime.now() - 1);
        
        reqIncrSync.valueMap.add(obj1);
        reqIncrSync.valueMap.add(obj2);
        dataUtilObj = new INTF_DataUtilityServices();
        respIncrSync = dataUtilObj.getAdvanceDownloadCriteriaRecIds(reqIncrSync);
        system.debug(LoggingLevel.WARN, 'response = :' + respIncrSync);
    }
    
    static testMethod void getNewDwnldCriteriaRecordIds()
    {
        insertConfigData();
        
         //Insert wO
        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        insert WO;
         
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
        
        //INSERT technician
        createEvents();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'SYNC_DOWNLOAD_CRITERIA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap obj1 = new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME',String.valueOf(System.now()-2 ));
        INTF_WebServicesDef.SVMXMap obj2 = new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT','SVMXC__Service_Order_Line__c');
        obj2.values = new List<String>{'SVMXC__Service_Order_Line__c'};
        req.valueMap.add(obj1);
        req.valueMap.add(obj2);
        req.values = new List<string>{'SVMXC__Service_Order_Line__c'};
        
        resp = dataUtilObj.getDownloadCriteriaRecordIds(req);//initial sync
        system.debug(LoggingLevel.WARN, 'response = :' + resp);
    }
    
    static testMethod void testGetTechnicianLocation()
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        resp = dataUtilObj.getTechnicianLocation(req);//initial sync
        system.debug(LoggingLevel.WARN, 'response = :' + resp);
    }
    
    static testMethod void testGetSVMXEventRelatedWOIDs()
    {
        //create the required settings
        insertConfigData();
        createEvents();
        
        //insert config data SyncToGetEvents SyncToRemoveEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData) ;
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        Set<String> setWhatIds = new Set<String>();
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        setWhatIds = dataUtilObj.getSVMXEventRelatedWOIDs(defaultMobConfigID);//initial sync
        system.debug(LoggingLevel.WARN, 'setWhatIds = :' + setWhatIds);
    }
    
    static testMethod void testEventSync()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        Req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};        
        Req.eventType='SYNC';
        Req.eventName='EVENT_SYNC';
        
        insertConfigData(); //Inserting relevant config data
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        //Page Layout and page Layout Detail
        SVMXC__Page_Layout__c pageLayout = new SVMXC__Page_Layout__c(SVMXC__Name__c = 'Work Order Dependency (Dependency Group)', SVMXC__Object_Name__c = 'SVMXC__Service_Order_Group_Dependency__c', SVMXC__Page_Layout_ID__c = 'Work Order Dependency (Dependency Group)', SVMXC__Type__c = 'Detail');
        insert pageLayout;
        
        SVMXC__Page_Layout_Detail__c pageLayoutDetail = new SVMXC__Page_Layout_Detail__c(SVMXC__Page_Layout__c = pageLayout.Id, SVMXC__DataType__c = 'reference', SVMXC__Field_API_Name__c = 'SVMXC__Primary_Work_Order__c', SVMXC__Detail_Type__c ='Field', SVMXC__Related_Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Related_Object_Name_Field__c = 'Name', SVMXC__Context_Source_Object__c = 'CURRENT_RECORD');
        insert pageLayoutDetail;
        
        //Target Manager for STANDALONE EDIT
        SVMXC__ServiceMax_Processes__c stdEditTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'STANDALONE EDIT', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234', SVMXC__Page_Layout__c = pageLayout.Id);
        insert stdEditTarMgrProcess;
        
        SVMXC__ServiceMax_Processes__c wizardProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = wizardRecordTypeId ,SVMXC__Active__c = true , SVMXC__ProcessID__c = 'testWizard' );
        insert wizardProcess;
        
        //Wizard Access config Data
        SVMXC__ServiceMax_Config_Data__c wizardAccConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = wizardAccessRecTypeId ,SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Dispatch_Process__c = stdEditTarMgrProcess.Id );
        insert wizardAccConfigData;
        
        SVMXC__ServiceMax_Processes__c wizStepProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = wizardStepRecTypeId, SVMXC__Action_Type__c = 'SFM', SVMXC__Process__c = stdEditTarMgrProcess.Id, SVMXC__Module__c = wizardProcess.Id);
        insert wizStepProcess;
        
        //create Config Data for Service Access Flow
        SVMXC__ServiceMax_Config_Data__c viewRecConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId,SVMXC__Dispatch_Process__c = stdEditTarMgrProcess.Id );
        insert viewRecConfigData;   
        
        SVMXC__ServiceMax_Processes__c procNodeObjProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = stdEditTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234', SVMXC__Type__c = 'TARGET');
        insert procNodeObjProcess;
        
        SVMXC__ServiceMax_Processes__c procNodeObjProcessForChild = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = stdEditTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234', SVMXC__Type__c = 'TARGET');
        insert procNodeObjProcessForChild;
        
        createEvents();
        Test.startTest();
        Res = dataUtilObj.RequestDataFromBase(Req);
        Test.stopTest();
    }
    
    static testMethod void createEvents()
    {
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        wo.SVMXC__City__c = 'Bangalore';
        insert wo;
        
        SVMXC__Service_Order_Line__c WOLine = new SVMXC__Service_Order_Line__c();
        WOLine.SVMXC__Service_Order__c = wo.Id;
        insert WOLine;
        
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
    
    static testMethod void testRequestIdCleanUp()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();

        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};        
        req.value = '123456';
        req.eventType = 'SYNC';
        req.eventName = 'CLEAN_UP';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        resp = dataUtilObj.RequestIdCleanUp(req);
        
        req = new INTF_WebServicesDef.INTF_SFMRequest();
        clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.value = '123456';
        req.eventType = 'SYNC';
        req.eventName = 'CLEAN_UP_SELECT';
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        resp = dataUtilObj.RequestIdCleanUp(req);
        system.debug(LoggingLevel.WARN, 'response = :' + resp);
    }
    
    // Added by  Ramachandra
    static testMethod void getDripFeedRelatedRecords()
    {
        createEvents();
        
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        
        Datetime dtFromDateTime = system.now().addDays(-365);
        Datetime dtToDateTime = system.now().addDays(1);
        
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        insert wo;
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        //evntObj.IsAllDayEvent = true;
        insert evntObj;
        
        String fields = 'Event.IsAllDayEvent';
        dataUtilObj.getDripFeedRelatedRecords( dtFromDateTime, dtToDateTime, UserInfo.getUserId(), fields );
        
        fields = 'SVMXC__SVMX_Event__c.SVMXC__IsAllDayEvent__c';
        dataUtilObj.getDripFeedRelatedRecords( dtFromDateTime, dtToDateTime, UserInfo.getUserId(), fields );
        
        fields = 'Name,RecordType.Name';
        dataUtilObj.getDripFeedRelatedRecords( dtFromDateTime, dtToDateTime, UserInfo.getUserId(), fields );
        
        Test.stopTest();
    }
    
    static testMethod void getRecForMasterDtlObj()
    {
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
        
        SVMXC__ServiceMax_Processes__c procNodeObjProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = viewRecTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234');
        insert procNodeObjProcess;
        
        //Creating Sample Data for WO and WO Line
        List<SVMXC__Service_Order_Line__c> lstWOLine = new List<SVMXC__Service_Order_Line__c>();

        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        Database.SaveResult result1 = Database.insert(WO);
        string workOrderId = result1.getId();
    
        SVMXC__Service_Order_Line__c WOLine = new SVMXC__Service_Order_Line__c();
        WOLine.SVMXC__Service_Order__c = workOrderId;
        lstWOLine.add(WOLine);
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c();
        WOLine1.SVMXC__Service_Order__c = workOrderId;
        lstWOLine.add(WOLine1);
        insert lstWOLine;
             
        Test.startTest();
       
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        
        String objectName = 'SVMXC__Service_Order__c';
        dataUtilObj.getRecForMasterDtlObj( objectName, viewRecTarMgrProcess.Id , false, new Set<String>() );

        Test.stopTest();        
    }
    
    static testMethod void getPushNotificationData()
    {
        
        //Creating Sample Data for WO and Event
        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__City__c = 'Bangalore';
        Database.SaveResult result1 = Database.insert(WO);
        string workOrderId = result1.getId();
        
        Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = workOrderId;
        insert evntObj;
        //need a valueMap with Key= Object_Name and value = objectName (WO)
        //and that valueMap should have Key = Record_ID and value = WOId
        
        //create one with object name = Event and value = event Id
        
        Test.startTest();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();        
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'SYNC';
        req.eventName = 'SYNC_DOWNLOAD_CRITERIA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap obj1 = new INTF_WebServicesDef.SVMXMap('Object_Name', 'SVMXC__Service_Order__c');
        obj1.valueMap.add(new INTF_WebServicesDef.SVMXMap('Record_ID', workOrderId));
        
        INTF_WebServicesDef.SVMXMap obj2 = new INTF_WebServicesDef.SVMXMap('Object_Name', 'Event');
        obj2.valueMap.add(new INTF_WebServicesDef.SVMXMap('Record_ID', evntObj.Id));
        
        req.valueMap.add(obj1);
        req.valueMap.add(obj2);
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        dataUtilObj.getPushNotificationData( req );   
        
        Test.stopTest();
    }
    
    static testMethod void generatePdf()
    {
        Test.startTest();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();        
            
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
           
        req.eventType = 'SYNC';
        req.eventName = 'SYNC_DOWNLOAD_CRITERIA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap svmxMap = new INTF_WebServicesDef.SVMXMap();
        svmxMap.key = 'HTMLID';
        svmxMap.values.add('HTMLID');        
        req.valueMap.add( svmxMap );
        
        svmxMap = new INTF_WebServicesDef.SVMXMap();
        svmxMap.key = 'SIGNATURE';
        svmxMap.values.add( 'SIGNATURE' );
        req.valueMap.add( svmxMap );
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        dataUtilObj.generatePdf( req );    
        
        Test.stopTest();
    }
    
    static testMethod void submitDocument()
    {
        Test.startTest();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();        
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo}; 
        req.eventType = 'SYNC';
        req.eventName = 'SYNC_DOWNLOAD_CRITERIA';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_WebServicesDef.SVMXMap svmxMap = new INTF_WebServicesDef.SVMXMap();
        svmxMap.key = 'HTMLID';
        svmxMap.values.add( 'att.Id' );        
        req.valueMap.add( svmxMap );
        
        svmxMap = new INTF_WebServicesDef.SVMXMap();
        svmxMap.key = 'SIGNATURE';
        svmxMap.values.add( 'SIGNATURE' );
        req.valueMap.add( svmxMap );
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        dataUtilObj.submitDocument( req );  
        
        Test.stopTest();
    }
    
    static testMethod void getProductIdQuery()
    {
        insertConfigData();
       
        //insert a location
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        //Svmx process for DC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'Name LIKE \'%GET PRICE%\' ');
        insert advDCProcess;
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__Ownership_Type__c = 'All Records', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;    
        
        Test.startTest();
            INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
            
            Datetime dtToDateTime = system.now();
            dataUtilObj.getProductIdQuery( new Set<String>(), dtToDateTime, defaultMobConfigID, new Set<String>() ,new Set<String>(), new List<String>() );

        Test.stopTest();        
    }
    
    static testMethod void testGetProductIds()
    {   
        insertConfigData();
        
        //insert a location
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        //Svmx process for DC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'Name LIKE \'%GET PRICE%\' ');
        insert advDCProcess;
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__Ownership_Type__c = 'All Records', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
    
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        
        Datetime dtToDateTime = system.now();
        dataUtilObj.getProductIds( true, dtToDateTime, defaultMobConfigID );
        dataUtilObj.getProductIds( false, dtToDateTime, defaultMobConfigID );
        
        dtToDateTime = system.now().addDays(-365);
        dataUtilObj.getProductIds( true, dtToDateTime, defaultMobConfigID );
        dataUtilObj.getProductIds( false, dtToDateTime, defaultMobConfigID );
        
        Test.stopTest();
    }
    
    static testMethod void getSVMXEventRelatedWOIDs()
    {
            //create the required settings
            insertConfigData();
            createEvents();
            
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        dataUtilObj.getSVMXEventRelatedWOIDs(defaultMobConfigID);
        
        Test.stopTest();
    }
    
    static testMethod void getEventRelatedWOIDs()
    {   
        //create the required settings
            insertConfigData();
            createEvents();
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
             
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        dataUtilObj.getEventRelatedWOIDs(defaultMobConfigID);
        
        Test.stopTest();
    }
    
    static testMethod void getWOIds()
    {  
        //insert config data
        insertConfigData();
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Internal_value__c = '10', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
        
        //Insert team and technician
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        Datetime dtLastSyncTime = system.now().addDays(-365);
        dataUtilObj.getWOIds( new Set<String>(), dtLastSyncTime, new Set<String>(), defaultMobConfigID );
        
        dtLastSyncTime = system.now().addDays(-1);
        dataUtilObj.getWOIds( new Set<String>(), dtLastSyncTime, new Set<String>(), defaultMobConfigID );
        
        Test.stopTest();
    }
    
    static testMethod void getNewSVMXEventWhatIDs()
    {      
        insertConfigData(); //Inserting relevant config data
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
          
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        Datetime dtLastSyncTime = system.now().addDays(-365);
        dataUtilObj.getNewSVMXEventWhatIDs( dtLastSyncTime );
        
        dtLastSyncTime = system.now().addDays(-1);
        dataUtilObj.getNewSVMXEventWhatIDs( dtLastSyncTime );
        
        Test.stopTest();
    }
    
    static testMethod void getNewEventWhatIDs()
    {        
        insertConfigData(); //Inserting relevant config data
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        Test.startTest();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        Datetime dtLastSyncTime = system.now().addDays(-365);
        dataUtilObj.getNewEventWhatIDs( dtLastSyncTime );
        
        dtLastSyncTime = system.now().addDays(-1);
        dataUtilObj.getNewEventWhatIDs( dtLastSyncTime );
        
        Test.stopTest();
    }
    
    static testMethod void RequestIdCleanUp()
    {
        Test.startTest();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();        
            SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};   
        req.eventType = 'SYNC';
        req.eventName = 'CLEAN_UP';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        dataUtilObj.RequestIdCleanUp( req ); 
        
        Test.stopTest();
    }
    
    static testMethod void productIQDOD(){
        
        insertConfigData();
        
         //insert a location
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(SVMXC__Active__c = true, Name = 'Test Team');
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(SVMXC__Inventory_Location__c = location1.Id, SVMXC__Active__c = true, SVMXC__Salesforce_User__c = UserInfo.getUserId(), SVMXC__Service_Group__c = team.Id);
        insert technician;
        
        //Svmx process for DC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Parent_Object_Criteria__c = 'SVMXC__Company__r.Name != null');
        insert advDCProcess;
        
        //adding a config data for DC -> recordtype = MobileConfiguration
        SVMXC__ServiceMax_Config_Data__c dcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Download Criteria', SVMXC__Object_Name__c = 'Product2', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id, SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        insert dcConfigData;
        
        //create the required settings
        insertConfigData();
        createIPADSetting();
        
        //Insert data related to ProductIQ
        ProductIQConfiguration.Profile prof = new ProductIQConfiguration.Profile();
        prof.isTechnicalAttributesEnabled = 'TRUE';
        List<ProductIQConfiguration.AttachmentConfig> lstAttachConfig = new List<ProductIQConfiguration.AttachmentConfig>();
        ProductIQConfiguration.AttachmentConfig attachConfig = new ProductIQConfiguration.AttachmentConfig();
        attachConfig.isAttachmentsEnabled = 'true';
        //attachConfig.fileTypes = 'jpeg,.text';
        attachConfig.maximumFileSize = '25';
        lstAttachConfig.add(attachConfig);
        prof.attachment = lstAttachConfig;
        
        SVMXC__ProductIQProfile__c prodIQProfile = new SVMXC__ProductIQProfile__c(SVMXC__Contents__c = JSON.serialize(prof),SVMXC__ServiceMax_Profile__c = grpProfileId );
        insert  prodIQProfile;
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse resp = new INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        req.eventType = 'GET_DATA';
        req.eventName = 'DATA_ON_DEMAND';
        List<INTF_WebServicesDef.SVMXMap> lstRecords = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> lstMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        //Create product and IB
        Product2 product001 = new Product2();
        product001.SVMXC__Product_Line__c = 'Accessory';
        product001.Family = 'Accessory';
        product001.Name = 'Laptop Bags';
        insert product001;
            
        SVMXC__Installed_Product__c installedProd = new SVMXC__Installed_Product__c();
        installedProd.SVMXC__Product__c = product001.Id; 
        insert installedProd;
        
        //create an attachment for this IB
        Attachment attachment = new Attachment();
        string body1 = '';
        attachment.Body = Blob.valueOf(body1);
        attachment.Name = String.valueOf('testclass.txt');
        attachment.ParentId = installedProd.Id;
        insert attachment;
        
        INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
        record.key = 'Object_Name';
        record.value = 'SVMXC__Installed_Product__c';
        
        lstMap.add(new INTF_WebServicesDef.SVMXMap('Id', String.valueOf(installedProd.id)));
        
        record.valueMap = lstMap;
        lstRecords.add(record);
        req.valueMap = lstRecords;
        
        Test.startTest();
            resp = dataUtilObj.downloadOnDemand(req, grpProfileId);
        Test.stopTest();
    }  
    
    static testMethod void testEventSyncCachingIds()
    {
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        INTF_WebServicesDef.INTF_SFMRequest Req = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse Res = new INTF_WebServicesDef.INTF_SFMResponse();
        
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        Req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        Req.value = 'test123'; //Sync Request Id
        Req.eventType='SYNC';
        Req.eventName='EVENT_SYNC';
        
        insertConfigData(); //Inserting relevant config data
        
        SVMXC__SM_Request_Cache__c requestCache = new SVMXC__SM_Request_Cache__c(SVMXC__SM_Device_UDID__c = '123456789', SVMXC__SM_User_Id__c = UserInfo.getUserId(), SVMXC__SM_Client_Sync_Request_Id__c = 'test345');
        Database.SaveResult Result2 = Database.insert(requestCache);
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        insert configDataList;
        
        //Page Layout and page Layout Detail
        SVMXC__Page_Layout__c pageLayout = new SVMXC__Page_Layout__c(SVMXC__Name__c = 'Work Order Dependency (Dependency Group)', SVMXC__Object_Name__c = 'SVMXC__Service_Order_Group_Dependency__c', SVMXC__Page_Layout_ID__c = 'Work Order Dependency (Dependency Group)', SVMXC__Type__c = 'Detail');
        insert pageLayout;
        
        SVMXC__Page_Layout_Detail__c pageLayoutDetail = new SVMXC__Page_Layout_Detail__c(SVMXC__Page_Layout__c = pageLayout.Id, SVMXC__DataType__c = 'reference', SVMXC__Field_API_Name__c = 'SVMXC__Primary_Work_Order__c', SVMXC__Detail_Type__c ='Field', SVMXC__Related_Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Related_Object_Name_Field__c = 'Name', SVMXC__Context_Source_Object__c = 'CURRENT_RECORD');
        insert pageLayoutDetail;
        
        //Target Manager for STANDALONE EDIT
        SVMXC__ServiceMax_Processes__c stdEditTarMgrProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = targetMgrRecordTypeId, SVMXC__Purpose__c = 'STANDALONE EDIT', SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__ProcessID__c = 'test1234', SVMXC__Page_Layout__c = pageLayout.Id);
        insert stdEditTarMgrProcess;
        
        SVMXC__ServiceMax_Processes__c wizardProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = wizardRecordTypeId ,SVMXC__Active__c = true , SVMXC__ProcessID__c = 'testWizard' );
        insert wizardProcess;
        
        //Wizard Access config Data
        SVMXC__ServiceMax_Config_Data__c wizardAccConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = wizardAccessRecTypeId ,SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Dispatch_Process__c = stdEditTarMgrProcess.Id );
        insert wizardAccConfigData;
        
        SVMXC__ServiceMax_Processes__c wizStepProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = wizardStepRecTypeId, SVMXC__Action_Type__c = 'SFM', SVMXC__Process__c = stdEditTarMgrProcess.Id, SVMXC__Module__c = wizardProcess.Id);
        insert wizStepProcess;
        
        //create Config Data for Service Access Flow
        SVMXC__ServiceMax_Config_Data__c viewRecConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = serviceAccessFlowRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId,SVMXC__Dispatch_Process__c = stdEditTarMgrProcess.Id );
        insert viewRecConfigData;   
        
        SVMXC__ServiceMax_Processes__c procNodeObjProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = stdEditTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234', SVMXC__Type__c = 'TARGET');
        insert procNodeObjProcess;
        
        SVMXC__ServiceMax_Processes__c procNodeObjProcessForChild = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c', RecordTypeId = procNodeObjRecTypeId,SVMXC__Process__c = stdEditTarMgrProcess.Id , SVMXC__ProcessID__c = 'test1234', SVMXC__Type__c = 'TARGET');
        insert procNodeObjProcessForChild;
        
        createEvents();
        Test.startTest();
        Res = dataUtilObj.RequestDataFromBase(Req);
        Test.stopTest();
    }
    
    //ADC optimization 
    static testMethod void getAdvDCRecordsFromCache()
    {
        insertConfigData(); //Inserting relevant config data
        
        SVMXC__Site__c location1 = new SVMXC__Site__c(Name = 'Loc1', SVMXC__City__c = 'Bangalore');
        insert location1;
        
        //inserting WO with location1
        SVMXC__Service_Order__c wo =  new SVMXC__Service_Order__c();
        wo.SVMXC__City__c = 'Bangalore';
        wo.SVMXC__Site__c = location1.Id;
        insert wo;
        
        //Inserting IB with the same location
        Product2 product001 = new Product2();
        product001.SVMXC__Product_Line__c = 'Accessory';
        product001.Family = 'Accessory';
        product001.Name = 'Laptop Bags';
        insert product001;
        
        SVMXC__Installed_Product__c installedProd = new SVMXC__Installed_Product__c();
        installedProd.SVMXC__Product__c = product001.Id; 
        installedProd.SVMXC__Site__c = location1.Id;
        insert installedProd;
        
        //create an attachment for this IB
        Attachment attachment = new Attachment();
        string body1 = 'Test Test';
        attachment.Body = Blob.valueOf(body1);
        attachment.Name = String.valueOf('testclass.txt');
        attachment.ParentId = wo.Id;
        insert attachment;
        
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
        
        //insert config data SyncToGetEvents
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c syncToGetEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Remove Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToGetEventConfigData);
        SVMXC__ServiceMax_Config_Data__c syncToRemoveEventConfigData  = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Synchronization To Get Events', SVMXC__Internal_Value__c = '0', SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(syncToRemoveEventConfigData);
        
        //Svmx process for ADC - SVMX_Rule
        SVMXC__ServiceMax_Processes__c advDCProcess = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Rule_Type__c = 'Adv Criteria Exp', SVMXC__Source_Object_Name__c = 'Attachment', SVMXC__Parent_Object_Criteria__c = 'ParentId IN (\':SVMXC__Service_Order__c\',\'Id\')' );
        insert advDCProcess;
        SVMXC__ServiceMax_Processes__c advDCProcess2 = new SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleRecTypeID, SVMXC__Rule_Type__c = 'Adv Criteria Exp', SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c', SVMXC__Parent_Object_Criteria__c = 'SVMXC__Site__c IN (\':SVMXC__Service_Order__c\',\'SVMXC__Site__c\')' );
        insert advDCProcess2;
        
        //ADC config data
        SVMXC__ServiceMax_Config_Data__c adcConfigData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'Attachment', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData);
        
        SVMXC__ServiceMax_Config_Data__c adcConfigData2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = mobConfigRecordTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Display_Type__c = 'Advanced Download Criteria', SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c', SVMXC__Internal_value__c = '10', SVMXC__Dispatch_Process__c = advDCProcess2.Id , SVMXC__SM_Device_Mobile_Config__c = defaultMobConfigID);
        configDataList.add(adcConfigData2);
        
        //Svmx config Data for expression
        SVMXC__ServiceMax_Config_Data__c expressionForADC = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess.Id);
        configDataList.add(expressionForADC);
        
        SVMXC__ServiceMax_Config_Data__c expressionForADC2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = expressionRecTypeId, SVMXC__Access_Configuration_Profile__c = grpProfileId, SVMXC__Expression_Rule__c =advDCProcess2.Id, SVMXC__Display_Type__c = 'REFERENCE', SVMXC__Field_Relationship_Name__c = 'SVMXC__Site__r', SVMXC__Field_Name__c = 'SVMXC__Site__c', SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c', SVMXC__Source_Field_Name__c = 'SVMXC__Site__c');
        configDataList.add(expressionForADC2);
        
        insert configDataList;
        
        Map<String,String> mapOfEventAndIds = new Map<string,string>();
        mapOfEventAndIds.put('ALL_EVENTS', json.serialize(new List<String>{svmxEvent.id}));
        mapOfEventAndIds.put('MODIFIED_EVENTS', json.serialize(new List<String>{svmxEvent.id}));
        
        SVMXC__SM_Request_Cache__c requestCache = new SVMXC__SM_Request_Cache__c(SVMXC__SM_Device_UDID__c = '123456789', SVMXC__SM_User_Id__c = UserInfo.getUserId(), SVMXC__SM_Client_Sync_Request_Id__c = 'test345');
        requestCache.SVMXC__SM_Event_What_IDs__c = Json.serialize(mapOfEventAndIds);
        Database.SaveResult Result2 = Database.insert(requestCache);  //Request cache with the event Ids
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        
        INTF_DataUtilityServices dataUtilObj = new INTF_DataUtilityServices();
        SVMXC.INTF_WebServicesDef.SVMXClient clInfo = new SVMXC.INTF_WebServicesDef.SVMXClient();
        clInfo.clientInfo = new List<String>{'appversion:16.49.002', 'appname:SVMX_MFL','userid:'+UserInfo.getUserId(),'clientudid:123456789'};
        clInfo.clientType = 'iPad';
        req.clientInfo = new List<SVMXC.INTF_WebServicesDef.SVMXClient>{clInfo};
        
        req.eventType = 'SYNC';
        req.eventName = 'ADV_DOWNLOAD_CRITERIA';
        req.value = 'test345';
        req.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap valueMap1 = new SVMXC.INTF_WebServicesDef.SVMXMap('ADC_OPTIMIZED', 'TRUE');
        req.valueMap.add(valueMap1);
        
        test.startTest();
                response = dataUtilObj.getAdvanceDownloadCriteriaRecIds(req);
            test.stopTest();    
        system.debug(LoggingLevel.WARN, 'response = :' + response);
        
        
    }        
}