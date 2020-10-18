/**
 * The TOOL_SeedAppSettingHandler class will get json files from static resource
 * and perform insert/update of seed components.
 *
 * @author D B Sathish Kumar
 * @version Sum 17
 * @created 20/03/2017
 * @updated 08/01/2020
 */

global without sharing class TOOL_SeedAppSettingHandler {

    static List<SVMXC__SERVICEMAX_PROCESSES__C> newSettingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
    static List<SVMXC__SERVICEMAX_PROCESSES__C> oldHoverDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
    static List<SVMXC__SERVICEMAX_PROCESSES__C> oldSFActionList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
    static Map<String, String> freshSettingMap = new Map<String, String>();
    static Map<String, String> snippetMap = new Map<String, String>();
    static String confJobId = '';
    static String seedLog = '';
    static String mailBody = '';

    static String profile= '';
    static String module = '';
    static String submodule = '';
    static String settings = '';
    static String settingValue = '';
    static String codeSnippet = '';
    static String codeSnippetManifest = '';
    static String macroDefnition = '';
    static String applicationFilter = '';
    static String propertyElement = '';
    static String mapHoverJson = '';
    static String mapHoverDetail = '';
    static String seedKey = '';
    static boolean isFreshInstall = false;
    static String defaultBusinessHours = '';
    static String serviceFlowActions = '';
    static String serviceFlowActionParameters = '';
    static String priceFields = '';
    static String iotConfigurationJson = '';
    static String offlineProfileJson = '';
    static String inventoryProcessJson = '';
    static String inventoryExpressionJson = '';
    static String optimaxSettingJson = '';
    static String expressionJson = '';
    static String expressionDetailJson = '';
    static String objectMappingJson = '';
    static String fieldMappingJson = '';
    static String woBillingJson = '';
    static String pmProcessJson = '';
    static String dcViewJson = '';
    static String dcViewConfigJson = '';
    static String quickBookConfigJson = '';
    static String smartObjectJson = '';
    static boolean isDCViewExists = false;
    static String imageData = null;
    static String customSettingValueUpdateJson = '';
    static String aplReceiveJson = '';
    static String aplReturnJson = '';
    static String aplShipmentJson = '';
    static String aplSourceUpdatesJson = '';
    static String googleAPICustomSettingJson = '';
    
    static Map<String, String> moduleMap = new Map<String, String>();
    static Map<String, String> subModuleMap = new Map<String, String>();
    Static Map<String, String> aplExpressionMap = new Map<String, String>();
	Static Map<String, String> aplObjectMap = new Map<String, String>();
    @future(callout=true)
    public static void onSeedInstall(String key, String emailId, boolean isManual) {
        try{
            seedKey = key;
            String filePath = getStaticResourcePath();
            boolean profileStatus=false,moduleStatus=false,submoduleStatus=false,settingStatus=false,settingValueStatus=false,macroDefStatus=false,codeSnippetStatus=false,filterStatus=false,hoverStatus=false,sfActionStaus=false,expressionStatus=false,mappingStatus=false,inventoryStatus=false,aplStatus=false;
            if(filePath != null){
                //get all json data from static resource
                getJsonData(filePath);
                //insert log record in servicemax job
                insertLogAttachment();
                //check fresh install
                checkFreshInstall();
                //get default bussiness hour
                getBusinessHoursDefaultValue();
                //create custom setting 
                createCustomSetting();
                //process profiles
                profileStatus = processProfiles();
                //process modules
                moduleStatus = processModules();
                //process submodules
                if(moduleStatus){
                    submoduleStatus = processSubmodules();
                }else {
                    setLogMessage(false, 'Submodules');
                }
                //process Setting Definition
                deleteIpadSetting();
                if(submoduleStatus){
                    settingStatus = processSettings();
                }else {
                    setLogMessage(false, 'Settings');
                }
                //process Setting Values
                if(profileStatus && settingStatus){
                   settingValueStatus = processSettingValues();
                }else {
                   setLogMessage(false, 'Setting Values');
                }
                //process macro definition
                macroDefStatus = processMacros();
                //process Code Snippet
                codeSnippetStatus = processCodeSnippet();
                //process Code Snippet Manifest
                if(codeSnippetStatus){
                    processCodeSnippetManifest();
                }
                //process Application Filter
                filterStatus = processApplicationFilter();
                //process Map Hovers
                hoverStatus = processMapHover();
                //process Map Hover Details
                if(hoverStatus){
                    processMapHoverDetail();
                }else{
                    setLogMessage(false, 'Hover Details');
                }
                //process servicemax property elements
                processPropertyElement();
                //process SF Actions(Custom Actions)
                sfActionStaus = processServiceFlowAction();
                //process SF Action Parameters
                if(sfActionStaus){
                    processServiceFlowActionParameter();
                }else{
                    setLogMessage(false, 'ServiceFlow Action Parameters');
                }
                //process get price fields
                processGetPriceFields();
                //TOOL-2290 Managed Trigger
                processManagedTrigger();
                //TOOL-2293 process IOT Configuration
                processIOTConfiguration();
                //TOOL-2198 process Offline Profile
                processOfflineProfile();
                //TOOL-2198 process Inventory Processes
                inventoryStatus = processInventoryProcesses();
                if(inventoryStatus){
                    processInventoryExpression();
                }else{
                    setLogMessage(false, 'Inventory Expressions');
                }
                //TOOL-2198 process Offline Profile
                processOptimaxCustomSetting();
                //TOOL-2198 process Named Expression
                expressionStatus = processNamedExpressions();
                //TOOL-2198 process Expression Detail
                if(expressionStatus){
                    processExpressionDetail();
                }
                else{
                    setLogMessage(false, 'Expression Details');
                }
                //TOOL-2198 process Object Mapping
                mappingStatus = processObjectMapping();
                //TOOL-2198 process Field Mapping
                if(mappingStatus){
                    processFieldMapping();
                }
                else{
                    setLogMessage(false, 'Field Mapping');
                }
                //TOOL-2198 process WOBilling
				processWOBilling();
				//TOOL-2198 process PMProcess
				processPMProcess();
				//TOOL-2271 process DC Views
				processDCViews();
				//TOOL-2271 process DC View Config
				processDCViewConfig();
				//TOOL-2271 process QuickBook Configuration
				processQuickBookConfiguration();
				//TOOL-2271 process Smart Objects
				processSmartObjects();
                processTimesheetProfileConfiguration(); 
                processServicemaxLogo(); 
                processPlatformCacheConfiguration();
                aplStatus = processAPLReceiveReturnShipment();
                processAPLSourceUpdates();
				//  TOOL-2457 process Batch/Lot settings in custom Inventory
                processBatchLotSetCustInventory(); 
                system.debug(LoggingLevel.INFO, 'Number of Queries used before SFM update : ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
                system.debug(LoggingLevel.INFO, 'Number of Dml Rows used before SFM update : ' + Limits.getDmlRows()+' Out of '+Limits.getLimitDMLRows());
                system.debug(LoggingLevel.INFO, 'Number of DML Statements used before SFM update : ' + Limits.getDmlStatements()+' Out of '+Limits.getLimitDMLStatements());
                //TOOL-2350 SFM LMD update for Decimnal changes
                updateSfmForDecimalChange();
                system.debug(LoggingLevel.INFO, 'Number of Queries used after SFM update : ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
                system.debug(LoggingLevel.INFO, 'Number of Dml Rows used after SFM update : ' + Limits.getDmlRows()+' Out of '+Limits.getLimitDMLRows());
                system.debug(LoggingLevel.INFO, 'Number of DML Statements used after SFM update : ' + Limits.getDmlStatements()+' Out of '+Limits.getLimitDMLStatements());
            	//TOOL-2466 Google map api settings
                createGoogleAPICustomSettings();
            }else{
                seedLog += System.now()+' File path is null  \n';
            }
            seedLog += System.now()+' Seed Component Execution Completed  \n';
         }
        catch(Exception e) {
            seedLog += System.now()+' Error in onSeedInstall '+e.getMessage()+' '+e.getStackTraceString()+'\n';
            System.debug('Error in onSeedInstall ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        seedLog += System.now()+' isManual - '+isManual+'\n';
        //update license type custom setting
        if(isFreshInstall){
            updateLicenseTypeSetting();
        }
        updateLogFile();
        if(Test.isRunningTest()){
            isManual = true;
        }
        if(isManual){
            updateCustomSetting();
            //sendConfiguratorEmail(emailId);
        }
        sendConfiguratorEmail(emailId);        
    }

    public static void getJsonData(String filePath) {
        try {
            Map<String, String> jsonMap = new Map<String, String>();
            PageReference seedPageReference = new PageReference(filePath + 'SeedFile.json');
            String seedJson;
            if(Test.isRunningTest()){
                seedJson = '{"files":[{"Name":"profile","FileName":"configprofiles.json"},{"Name":"module","FileName":"modules.json"},{"Name":"submodule","FileName":"submodules.json"},{"Name":"settings","FileName":"settings.json"},{"Name":"settingValue","FileName":"settingvalues.json"},{"Name":"codeSnippet","FileName":"CodeSnippet.xml"},{"Name":"codeSnippetManifest","FileName":"CodeSnippetManifest.json"},{"Name":"macroDefnition","FileName":"MacroDef.json"},{"Name":"applicationFilter","FileName":"ApplicationFilter.json"},{"Name":"propertyElement","FileName":"propertyelements.json"},{"Name":"mapHover","FileName":"MapHover.json"},{"Name":"mapHoverDetail","FileName":"HoverDetail.json"},{"Name":"sfActions","FileName":"serviceflowaction.json"},{"Name":"sfActionParameters","FileName":"sfactionparameters.json"},{"Name":"priceFields","FileName":"GetPriceFields.json"},{"Name":"iotconfiguration","FileName":"IOTConfiguration.json"},{"Name":"offlineprofile","FileName":"OfflineProfiles.json"},{"Name":"inventoryprocess","FileName":"InventoryProcess.json"},{"Name":"optimaxSettings","FileName":"OptimaxCustomSettings.json"},{"Name":"expression","FileName":"NamedExpression.json"},{"Name":"expressionDetail","FileName":"ExpressionDetail.json"},{"Name":"objectMapping","FileName":"Objectmap.json"},{"Name":"fieldMapping","FileName":"Fieldmap.json"},{"Name":"WOBilling","FileName":"WOBilling.json"},{"Name":"PMProcess","FileName":"PMProcess.json"},{"Name":"DCView","FileName":"DCViews.json"},{"Name":"DCViewConfig","FileName":"DCViewConfig.json"},{"Name":"QuickBookConfig","FileName":"QuickbookConfiguration.json"},{"Name":"SmartObject","FileName":"SmartObjects.json"}]}';
            }else{
                seedJson = seedPageReference.getContent().toString();
            }
            System.debug('Seed File Json - '+seedJson.trim());
            TOOL_SeedWrapper.SeedFile seedFileJson =  (TOOL_SeedWrapper.SeedFile)System.JSON.deserialize(seedJson.trim(), TOOL_SeedWrapper.SeedFile.class);
            for(TOOL_SeedWrapper.SeedData seedData : seedFileJson.files){
                jsonMap.put(seedData.Name, seedData.FileName);
            }

            for(String jsonName : jsonMap.keySet()){
                PageReference pageReference = new PageReference(filePath + jsonMap.get(jsonName));
                String jsonData;
                if(Test.isRunningTest()){
                    jsonData = '';
                }else{
                     if('ServicemaxLogo'.equals(jsonName)){
                        seedLog += System.now()+' ServicemaxLogo : '+filePath + jsonMap.get(jsonName)+'\n';
                        Blob blobImage = pageReference.getContent();
                        imageData  = EncodingUtil.base64Encode(blobImage);
                    }
                    else{
                        jsonData = pageReference.getContent().toString();
                    }
                }
                if('profile'.equals(jsonName)){
                    profile = jsonData;
                }else if('module'.equals(jsonName)){
                    module = jsonData;
                }else if('submodule'.equals(jsonName)){
                    submodule = jsonData;
                }else if('settings'.equals(jsonName)){
                    settings = jsonData;
                }else if('settingValue'.equals(jsonName)){
                    settingValue = jsonData;
                }else if('codeSnippet'.equals(jsonName)){
                    codeSnippet = jsonData;
                }else if('codeSnippetManifest'.equals(jsonName)){
                    codeSnippetManifest = jsonData;
                }else if('macroDefnition'.equals(jsonName)){
                    macroDefnition = jsonData;
                }else if('applicationFilter'.equals(jsonName)){
                    applicationFilter = jsonData;
                }else if('propertyElement'.equals(jsonName)){
                    propertyElement = jsonData;
                }else if('mapHover'.equals(jsonName)){
                    mapHoverJson = jsonData;
                }else if('mapHoverDetail'.equals(jsonName)){
                    mapHoverDetail = jsonData;
                }else if('sfActions'.equals(jsonName)){
                    serviceFlowActions = jsonData;
                }else if('sfActionParameters'.equals(jsonName)){
                    serviceFlowActionParameters = jsonData;
                }else if('priceFields'.equals(jsonName)){
                    priceFields = jsonData;
                }else if('iotconfiguration'.equals(jsonName)){
                    iotConfigurationJson = jsonData;
                }else if('offlineprofile'.equals(jsonName)){
                    offlineProfileJson = jsonData;
                }else if('inventoryprocess'.equals(jsonName)){
                    inventoryProcessJson = jsonData;
                }else if('inventoryexpression'.equals(jsonName)){
                    inventoryExpressionJson = jsonData;
                }else if('optimaxSettings'.equals(jsonName)){
                    optimaxSettingJson = jsonData;
                }else if('expression'.equals(jsonName)){
                    expressionJson = jsonData;
                }else if('expressionDetail'.equals(jsonName)){
                    expressionDetailJson = jsonData;
                }else if('objectMapping'.equals(jsonName)){
                    objectMappingJson = jsonData;
                }else if('fieldMapping'.equals(jsonName)){
                    fieldMappingJson = jsonData;
                }else if('WOBilling'.equals(jsonName)){
                    woBillingJson = jsonData;
                }else if('PMProcess'.equals(jsonName)){
                    pmProcessJson = jsonData;
                }else if('DCView'.equals(jsonName)){
                    dcViewJson = jsonData;
                }else if('DCViewConfig'.equals(jsonName)){
                    dcViewConfigJson = jsonData;
                }else if('QuickBookConfig'.equals(jsonName)){
                    quickBookConfigJson = jsonData;
                }else if('SmartObject'.equals(jsonName)){
                    smartObjectJson = jsonData;
                }else if('CustomSettingValueUpdate'.equals(jsonName)){
                    customSettingValueUpdateJson = jsonData;
                }
                else if('APLReceive'.equals(jsonName)){
                    aplReceiveJson = jsonData;
                }
                else if('APLReturn'.equals(jsonName)){
                    aplReturnJson = jsonData;
                }
                else if('APLShipment'.equals(jsonName)){
                    aplShipmentJson = jsonData;
                }
                else if('APLSourceUpdates'.equals(jsonName)){
                    aplSourceUpdatesJson = jsonData;
                }
                else if('GoogleAPICustomSettings'.equals(jsonName)){
                	googleAPICustomSettingJson = jsonData;
                }
            }
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while processing Json files : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing json data ' + e.getStackTraceString());
        }
    }

    public static String getStaticResourcePath() {
    String staticResourcePath = null;
    try {
            StaticResource staticResource = [SELECT Id,Name,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'TOOL_AppSetting' LIMIT 1];
            String nameSpacePrefix = staticResource.NamespacePrefix;
            if( String.isblank(nameSpacePrefix) ) {
                nameSpacePrefix = '';
            } else {
                //If has NamespacePrefix
                nameSpacePrefix += '__';
            }
            staticResourcePath = '/resource/' + staticResource.SystemModstamp.getTime() + '/' + nameSpacePrefix + staticResource.Name + '/Default/';
            System.debug('seed location path : '+staticResourcePath);
            seedLog += System.now()+' Seed location path : '+staticResourcePath+'\n';
        }
        catch (Exception e) {
           seedLog += System.now()+' Error while Static resource path '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n'; 
           System.debug('Error while processing static resource ' + e.getStackTraceString());
        }
        return staticResourcePath;
    }

    public static void createCustomSetting() {
        try{
            List<SVMXC__ServiceMax_Properties__c> propertyList = [Select Name from SVMXC__ServiceMax_Properties__c where Name = 'TOOL001' Limit 1];
            if(propertyList != null && propertyList.size() > 0){
                seedLog += System.now()+' Custom setting TOOL001 already exists  \n';
            }else{
                List<SVMXC__ServiceMax_Properties__c> customSettingList = new List<SVMXC__ServiceMax_Properties__c>();
                SVMXC__ServiceMax_Properties__c customSetting = new SVMXC__ServiceMax_Properties__c();
                customSetting.Name = 'TOOL001';
                customSetting.SVMXC__Key__c = 'Tool_Seed_Status';
                customSetting.SVMXC__Value__c = 'Completed';
                customSettingList.add(customSetting);
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( customSettingList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert customSettingList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                seedLog += System.now()+' Custom setting created successfully  \n';
            }
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while creating custom setting : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while creating custom setting ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    public static void updateCustomSetting() {
        try{
            SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('TOOL001');
            if(objProperties != null){
                List<SVMXC__ServiceMax_Properties__c> propertyList = new List<SVMXC__ServiceMax_Properties__c>();
                objProperties.SVMXC__Value__c = 'Completed';
                propertyList.add(objProperties);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( propertyList, COMM_SecurityUtils.Access.Updateable ) ) {
                    update propertyList;
                    seedLog += System.now()+' Updated custom setting value as Completed\n';
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                seedLog += System.now()+' Custom setting not available \n';
            }
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while updating custom setting : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while updating custom setting ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    public static void updateLicenseTypeSetting() {
        try{
            SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('PROP001');
            if(objProperties != null){
                List<SVMXC__ServiceMax_Properties__c> propertyList = new List<SVMXC__ServiceMax_Properties__c>();
                objProperties.SVMXC__Value__c = 'Enterprise';
                propertyList.add(objProperties);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( propertyList, COMM_SecurityUtils.Access.Updateable ) ) {
                    update propertyList;
                    seedLog += System.now()+' Updated License Type custom setting value as Enterprise\n';
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                SVMXC__ServiceMax_Properties__c property = new SVMXC__ServiceMax_Properties__c();
                property.Name = 'PROP001';
                property.SVMXC__Key__c = 'License Type';
                property.SVMXC__Value__c = 'Enterprise';
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( property, COMM_SecurityUtils.Access.Createable ) ) {
                    insert property;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                seedLog += System.now()+' Created License Type Custom setting \n';
            }
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while updating License Type custom setting : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while updating License Type custom setting ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    public static boolean processProfiles() {
    boolean installStatus = true;
    Savepoint savePoint = null;
    try {
          System.debug('Started Processing Profiles');

          seedLog += System.now()+' Started Processing Profiles \n';
          if(Test.isRunningTest()){
              profile = '{"profiles":[{"SVMXC_PROFILE_NAME_C":"Default","SVMXC_DESCRIPTION_C":"This is the default org-wide configuration profile automatically loaded when ServiceMax is installed. This is a global (org-wide) profile that contains default values for all the configurable parameters of ServiceMax application. In order to configure ServiceMax for your organization, clone this profile using a name you can easily identify and modify the cloned profile.","SVMXC_CONFIGURATION_TYPE_C":"Global","SVMXC_ACTIVE_C":"True","SVMXC_ISDEFAULT_C":"True"}]}';
          }
            if(profile != null && !String.isBlank(profile)){
                savePoint = Database.setSavepoint();
                RecordType configRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Configuration Profile'];

                TOOL_SeedWrapper.Profile profileContent =  (TOOL_SeedWrapper.Profile)System.JSON.deserialize(profile.trim(), TOOL_SeedWrapper.Profile.class);
                seedLog += System.now()+' Processed Profile Json \n';

                List<SVMXC__ServiceMax_Config_Data__c> existingProfileList = [SELECT Id,SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Configuration Profile' AND SVMXC__Profile_Name__c IN ('Default','Default Group Profile')];
                seedLog += 'existing profile size : '+ existingProfileList.size() + '\n';
                Map<String, String> profileMap = new Map<String, String>();
                for(SVMXC__ServiceMax_Config_Data__c profileConfigData : existingProfileList){
                    profileMap.put(profileConfigData.SVMXC__Profile_Name__c, profileConfigData.Id);
                }

                List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
                seedLog += 'wrapper profile data : ' + profileContent.profiles.size() + '\n';
                for(TOOL_SeedWrapper.ProfileData profiledata : profileContent.profiles) {
                    String profileName = profiledata.SVMXC_PROFILE_NAME_C;
                    SVMXC__ServiceMax_Config_Data__c cofigProfileData = new SVMXC__ServiceMax_Config_Data__c();
                    if(profileMap.size() > 0 && profileMap.containsKey(profileName)) {
                        cofigProfileData.Id = profileMap.get(profileName);
                        cofigProfileData.SVMXC__DESCRIPTION__C = profiledata.SVMXC_DESCRIPTION_C;
                        cofigProfileData.RecordTypeId = configRecordType.Id;
                        cofigProfileData.SVMXC__INSTALLATION_KEY__C = seedKey;
                    }
                    else {
                        cofigProfileData.SVMXC__PROFILE_NAME__C = profiledata.SVMXC_PROFILE_NAME_C;
                        cofigProfileData.SVMXC__DESCRIPTION__C = profiledata.SVMXC_DESCRIPTION_C;
                        cofigProfileData.SVMXC__CONFIGURATION_TYPE__C = profiledata.SVMXC_CONFIGURATION_TYPE_C;
                        cofigProfileData.SVMXC__ACTIVE__C = Boolean.valueOf(profiledata.SVMXC_ACTIVE_C);
                        cofigProfileData.SVMXC__ISDEFAULT__C = Boolean.valueOf(profiledata.SVMXC_ISDEFAULT_C);
                        cofigProfileData.RecordTypeId = configRecordType.Id;
                        cofigProfileData.SVMXC__INSTALLATION_KEY__C = seedKey;
                    }
                    configDataList.add(cofigProfileData);
                }

                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configDataList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert configDataList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else{
                installStatus = false;
                seedLog += System.now()+' Profile Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Profiles \n\n';
            System.debug('End of Processing Profiles');
        }
        catch(Exception e){
            installStatus = false;
            seedLog += System.now()+' Error while processing Profiles : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Profiles : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Profiles');
        return installStatus;
    }

    public static boolean processModules() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try {
            System.debug('Started Processing Modules');
            seedLog += System.now()+' Started Processing Modules \n';
            if(Test.isRunningTest()){
                module = '{"modules":[{"SVMXC_MODULEID_C":"CASE","SVMXC_NAME_C":"Case","SVMXC_DESCRIPTION_C":"This module is a collection of ServiceMax functionality related to the Case screen excluding entitlement verification.","SVMXC_ISSTANDARD_C":"True"}]}';
            }
            if(module != null && !String.isBlank(module)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Module'];

                TOOL_SeedWrapper.Module moduleContent =  (TOOL_SeedWrapper.Module)System.JSON.deserialize(module.trim(), TOOL_SeedWrapper.Module.class);
                seedLog += System.now()+' Processed Module Json \n';

                List<SVMXC__SERVICEMAX_PROCESSES__C> existingmoduleList = [SELECT Id,SVMXC__ModuleID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Module' and SVMXC__ISSTANDARD__C = true];
                Map<String, String> moduleMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C moduleProcessData : existingmoduleList){
                    moduleMap.put(moduleProcessData.SVMXC__ModuleID__c, moduleProcessData.Id);
                }

                List<SVMXC__SERVICEMAX_PROCESSES__C> processDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.ModuleData moduleData : moduleContent.modules) {
                    SVMXC__SERVICEMAX_PROCESSES__C processModuleData = new SVMXC__SERVICEMAX_PROCESSES__C();
                    if(moduleMap.size() > 0 && moduleMap.containsKey(moduleData.SVMXC_MODULEID_C)) {
                        processModuleData.Id = moduleMap.get(moduleData.SVMXC_MODULEID_C);
                        processModuleData.SVMXC__Name__c = moduleData.SVMXC_NAME_C;
                        processModuleData.SVMXC__DESCRIPTION__C = moduleData.SVMXC_DESCRIPTION_C;
                        processModuleData.RecordTypeId = processRecordType.Id;
                        processModuleData.SVMXC__INSTALLATION_KEY__C = seedKey;
                    }
                    else {
                        processModuleData.SVMXC__ModuleID__c = moduleData.SVMXC_MODULEID_C;
                        processModuleData.SVMXC__Name__c = moduleData.SVMXC_NAME_C;
                        processModuleData.SVMXC__DESCRIPTION__C = moduleData.SVMXC_DESCRIPTION_C;
                        processModuleData.SVMXC__ISSTANDARD__C = Boolean.valueOf(moduleData.SVMXC_ISSTANDARD_C);
                        processModuleData.RecordTypeId = processRecordType.Id;
                        processModuleData.SVMXC__INSTALLATION_KEY__C = seedKey;
                    }
                    processDataList.add(processModuleData);
                }  
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( processDataList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert processDataList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' Module Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Modules \n\n';
            System.debug('End of Processing Modules');
        }
        catch(Exception e){
            installStatus = false;
            Database.rollback(savePoint);
            seedLog += System.now()+' Error while processing Modules : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Modules' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'Modules');
        return installStatus;
    }

    public static boolean processSubmodules() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try {
            System.debug('Started Processing Submodules');
            seedLog += System.now()+' Started Processing Submodules \n';
            if(Test.isRunningTest()){
                submodule = '{"submodules":[{"SVMXC_MODULEID_C":"CASE","SVMXC_SUBMODULEID_C":"CASE001","SVMXC_NAME_C":"Select Booking Window","SVMXC_DESCRIPTION_C":"This feature displays your organization&apos;s territory structure and allows your call center users to commit an appropriate booking window to the customer based on technician availability in the selected territory.","SVMXC_ISSTANDARD_C":"True"}]}';
            }
            if(submodule != null && !String.isBlank(submodule)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Submodule'];

                //fetching all modules
                List<SVMXC__SERVICEMAX_PROCESSES__C> moduleList = [Select Id, SVMXC__ModuleID__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Module' and SVMXC__ISSTANDARD__C = true];

                if(moduleList != null && moduleList.size() > 0){
                    for(SVMXC__SERVICEMAX_PROCESSES__C moduleData : moduleList) {
                        moduleMap.put(moduleData.SVMXC__ModuleID__c, moduleData.Id);
                    }
                    TOOL_SeedWrapper.Submodule subModuleContent =  (TOOL_SeedWrapper.Submodule)System.JSON.deserialize(submodule.trim(), TOOL_SeedWrapper.Submodule.class);
                    seedLog += System.now()+' Processed Submodule Json \n';

                    List<SVMXC__SERVICEMAX_PROCESSES__C> existingSubmodule = [SELECT Id,SVMXC__SubmoduleID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Submodule' and SVMXC__ISSTANDARD__C = true];
                    Map<String, String> submoduleMap = new Map<String, String>();
                    for(SVMXC__SERVICEMAX_PROCESSES__C submoduleProcess : existingSubmodule){
                        submoduleMap.put(submoduleProcess.SVMXC__SubmoduleID__c, submoduleProcess.Id);
                    }

                    List<SVMXC__SERVICEMAX_PROCESSES__C> subModuleList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                    for(TOOL_SeedWrapper.SubmoduleData submoduleData : subModuleContent.submodules){
                        SVMXC__SERVICEMAX_PROCESSES__C processSubModuleData = new SVMXC__SERVICEMAX_PROCESSES__C();
                        if(submoduleMap.size() > 0 && submoduleMap.containsKey(submoduleData.SVMXC_SUBMODULEID_C)) {
                            processSubModuleData.Id = submoduleMap.get(submoduleData.SVMXC_SUBMODULEID_C);
                            processSubModuleData.SVMXC__Name__c = submoduleData.SVMXC_NAME_C;
                            processSubModuleData.SVMXC__DESCRIPTION__C = submoduleData.SVMXC_DESCRIPTION_C;
                            processSubModuleData.RecordTypeId = processRecordType.Id;
                            processSubModuleData.SVMXC__INSTALLATION_KEY__C = seedKey;
                        }
                        else {
                            processSubModuleData.SVMXC__Module__c = moduleMap.get(submoduleData.SVMXC_MODULEID_C);
                            processSubModuleData.SVMXC__ModuleID__c = submoduleData.SVMXC_MODULEID_C;
                            processSubModuleData.SVMXC__SUBMODULEID__C = submoduleData.SVMXC_SUBMODULEID_C;
                            processSubModuleData.SVMXC__NAME__C = submoduleData.SVMXC_NAME_C;
                            processSubModuleData.SVMXC__DESCRIPTION__C = submoduleData.SVMXC_DESCRIPTION_C;
                            processSubModuleData.SVMXC__ISSTANDARD__C = Boolean.valueOf(submoduleData.SVMXC_ISSTANDARD_C);
                            processSubModuleData.RecordTypeId = processRecordType.Id;
                            processSubModuleData.SVMXC__INSTALLATION_KEY__C = seedKey;
                        }
                        subModuleList.add(processSubModuleData);  
                    }
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( subModuleList, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert subModuleList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                else {
                    System.debug('processSubmodules() -- module list size -- '+moduleList.size());
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' Submodule Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Submodules \n\n';
            System.debug('End of Processing Submodules');
        }
        catch(Exception e){
            installStatus = false;
            Database.rollback(savePoint);
            seedLog += System.now()+' Error while processing Submodules : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Submodules' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'Submodules');
        return installStatus;
    }

    public static boolean processSettings() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try {
            System.debug('Started Processing Setting Def');
            seedLog += System.now()+' Started Processing Setting Def \n';
            if(Test.isRunningTest()){
                settings = '{"settings":[{"SVMXC_SUBMODULEID_C":"CASE001","SVMXC_SETTINGID_C":"SET002","SVMXC_SETTINGS_NAME_C":"Default Booking Window Start","SVMXC_DATA_TYPE_C":"Picklist","SVMXC_VALUES_C":"TODAY~|~TOMORROW","SVMXC_DEFAULT_VALUE_C":"TODAY","SVMXC_SETTING_TYPE_C":"Global","SVMXC_SEARCH_ORDER_C":"Global","SVMXC_DESCRIPTION_C":"Setting controls how the start date is calculated on Booking Window selection screen","SVMXC_ISPRIVATE_C":"False","SVMXC_ISSTANDARD_C":"True","SVMXC_ACTIVE_C":"True","SVMXC_SUBMODULE_C":"CASE001"}]}';
            }
            if(settings != null && !String.isBlank(settings)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Settings'];

                //fetching all submodules
                List<SVMXC__SERVICEMAX_PROCESSES__C> subModuleList = [Select Id,SVMXC__SubmoduleID__c  from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Submodule' and SVMXC__ISSTANDARD__C = true];

                if(subModuleList != null  && subModuleList.size() > 0) {
                    for(SVMXC__SERVICEMAX_PROCESSES__C submoduleData : subModuleList) {
                        subModuleMap.put(submoduleData.SVMXC__SubmoduleID__c, submoduleData.Id);
                    }
                    TOOL_SeedWrapper.Setting settingDef =  (TOOL_SeedWrapper.Setting)System.JSON.deserialize(settings.trim(), TOOL_SeedWrapper.Setting.class);
                    seedLog += System.now()+' Processed Settings Json  \n';

                    List<SVMXC__SERVICEMAX_PROCESSES__C> existingSetting = [Select Id,SVMXC__SubmoduleID__c,SVMXC__SettingID__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' and SVMXC__IsStandard__c = true];
                    Map<String, String> settingMap = new Map<String, String>();
                    for(SVMXC__SERVICEMAX_PROCESSES__C settingProcess : existingSetting){
                        String settingId = settingProcess.SVMXC__SubmoduleID__c + '_' + settingProcess.SVMXC__SettingID__c;
                        settingMap.put(settingId, settingProcess.Id);
                    }

                    List<SVMXC__SERVICEMAX_PROCESSES__C> settingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                    for(TOOL_SeedWrapper.SettingData settingData : settingDef.settings){
                        String settingUniqueId = settingData.SVMXC_SUBMODULEID_C + '_' + settingData.SVMXC_SETTINGID_C;
                        SVMXC__SERVICEMAX_PROCESSES__C processSettingDef = new SVMXC__SERVICEMAX_PROCESSES__C();

                        if(settingMap.size() > 0 && settingMap.containsKey(settingUniqueId)){
                            processSettingDef.Id = settingMap.get(settingUniqueId);
                            processSettingDef.SVMXC__SETTINGS_NAME__C = settingData.SVMXC_SETTINGS_NAME_C;
                            processSettingDef.SVMXC__DATA_TYPE__C = settingData.SVMXC_DATA_TYPE_C;
                            processSettingDef.SVMXC__VALUES__C = settingData.SVMXC_VALUES_C;
                            if('IPAD018_SET018'.equals(settingUniqueId) || 'MOBN001_SET006'.equals(settingUniqueId)){
                                processSettingDef.SVMXC__DEFAULT_VALUE__C = defaultBusinessHours;
                            }
                            else{
                                processSettingDef.SVMXC__DEFAULT_VALUE__C = settingData.SVMXC_DEFAULT_VALUE_C;
                            }
                            processSettingDef.SVMXC__SETTING_TYPE__C = settingData.SVMXC_SETTING_TYPE_C;
                            processSettingDef.SVMXC__SEARCH_ORDER__C = settingData.SVMXC_SEARCH_ORDER_C;
                            processSettingDef.SVMXC__ISPRIVATE__C = Boolean.valueOf(settingData.SVMXC_ISPRIVATE_C);
                            processSettingDef.SVMXC__ACTIVE__C = Boolean.valueOf(settingData.SVMXC_ACTIVE_C);
                            processSettingDef.SVMXC__DESCRIPTION__C = settingData.SVMXC_DESCRIPTION_C;
                            processSettingDef.RecordTypeId = processRecordType.Id;
                            processSettingDef.SVMXC__INSTALLATION_KEY__C = seedKey;
                        }
                        else {
                            processSettingDef.SVMXC__SUBMODULEID__C = settingData.SVMXC_SUBMODULEID_C;
                            processSettingDef.SVMXC__SETTINGID__C = settingData.SVMXC_SETTINGID_C;
                            processSettingDef.SVMXC__SETTINGS_NAME__C = settingData.SVMXC_SETTINGS_NAME_C;
                            processSettingDef.SVMXC__DATA_TYPE__C = settingData.SVMXC_DATA_TYPE_C;
                            processSettingDef.SVMXC__VALUES__C = settingData.SVMXC_VALUES_C;
                            if(isFreshInstall && Boolean.valueOf(settingData.IsFreshInstall)) {
                                freshSettingMap.put(settingData.SVMXC_SUBMODULEID_C + '_' + settingData.SVMXC_SETTINGID_C, settingData.FreshInstallValue);
                                processSettingDef.SVMXC__DEFAULT_VALUE__C = settingData.FreshInstallValue;
                            }else if('IPAD018_SET018'.equals(settingUniqueId) || 'MOBN001_SET006'.equals(settingUniqueId)){
                                processSettingDef.SVMXC__DEFAULT_VALUE__C = defaultBusinessHours;
                            }
                            else{
                                processSettingDef.SVMXC__DEFAULT_VALUE__C = settingData.SVMXC_DEFAULT_VALUE_C;
                            }
                            processSettingDef.SVMXC__SETTING_TYPE__C = settingData.SVMXC_SETTING_TYPE_C;
                            processSettingDef.SVMXC__SEARCH_ORDER__C = settingData.SVMXC_SEARCH_ORDER_C;
                            processSettingDef.SVMXC__ISPRIVATE__C = Boolean.valueOf(settingData.SVMXC_ISPRIVATE_C);
                            processSettingDef.SVMXC__ACTIVE__C = Boolean.valueOf(settingData.SVMXC_ACTIVE_C);
                            processSettingDef.SVMXC__DESCRIPTION__C = settingData.SVMXC_DESCRIPTION_C;
                            processSettingDef.SVMXC__ISSTANDARD__C = Boolean.valueOf(settingData.SVMXC_ISSTANDARD_C);
                            processSettingDef.SVMXC__SUBMODULE__C = subModuleMap.get(settingData.SVMXC_SUBMODULEID_C);
                            processSettingDef.RecordTypeId = processRecordType.Id;
                            processSettingDef.SVMXC__INSTALLATION_KEY__C = seedKey;
                            newSettingList.add(processSettingDef);
                        }
                        settingList.add(processSettingDef);
                    }
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( settingList, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert settingList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                else {
                    System.debug('processSettings() -- submodule list size -- '+subModuleList.size());
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' Settings Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Setting Def \n\n';
            System.debug('End of Processing Setting Def');
        }
        catch(Exception e){
            installStatus = false;
            Database.rollback(savePoint);
            seedLog += System.now()+' Error while processing Settings : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Settings' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'Setting Def');
        return installStatus;
    }

    public static boolean processSettingValues() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try {
            System.debug('Started Processing Setting Values');
            seedLog += System.now()+' Started Processing Setting Values \n';
            if(Test.isRunningTest()){
                settingValue = '{"settingValues":[{"SVMXC_SETTING_CONFIGURATION_PROFILE_C":"Default","SVMXC_SETTING_ID_C":"CASE001_SET002","SVMXC_INTERNAL_VALUE_C":"TODAY","SVMXC_DISPLAY_VALUE_C":"TODAY","SVMXC_ACTIVE_C":"True","SVMXC_ISDEFAULT_C":"True","PROFILETYPE":"Global","SETTINGTYPE":"Global"}]}';
            }
            if(settingValue != null && !String.isBlank(settingValue)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Setting Value'];

                //get standard profiles
                List<SVMXC__ServiceMax_Config_Data__c> profileList = [select Id,SVMXC__Profile_Name__c,SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Profile'];
                Map<String, String> profileMap = new Map<String, String>();
                Map<String, String> customProfileMap = new Map<String, String>();
                List<String> customProfiles = new List<String>();
                if(profileList != null && profileList.size() > 0) {
                    for(SVMXC__ServiceMax_Config_Data__c profileData : profileList) {
                        if('Default'.equals(profileData.SVMXC__Profile_Name__c) || 'Default Group Profile'.equals(profileData.SVMXC__Profile_Name__c)){
                            profileMap.put(profileData.SVMXC__Profile_Name__c, profileData.Id);
                        }
                        else {
                            customProfileMap.put(profileData.SVMXC__Profile_Name__c, profileData.Id + '_' + profileData.SVMXC__Configuration_Type__c);
                        	customProfiles.add(profileData.SVMXC__Profile_Name__c);
                        }
                    }
                    //get Setting details
                    List<SVMXC__SERVICEMAX_PROCESSES__C> settingList = [Select Id,SVMXC__SUBMODULEID__C,SVMXC__SETTINGID__C from SVMXC__SERVICEMAX_PROCESSES__C where RecordType.Name = 'Settings' and SVMXC__ISSTANDARD__C = true];
                    Map<String, String> settingMap = new Map<String, String>();
                    for(SVMXC__SERVICEMAX_PROCESSES__C settingData : settingList) {
                        settingMap.put(settingData.SVMXC__SUBMODULEID__C + '_' + settingData.SVMXC__SETTINGID__C, settingData.Id);
                    }
    
                    List<SVMXC__ServiceMax_Config_Data__c> settingValuesList = new List<SVMXC__ServiceMax_Config_Data__c>();
                    TOOL_SeedWrapper.SettingValue settingValueContent =  (TOOL_SeedWrapper.SettingValue)System.JSON.deserialize(settingValue.trim(), TOOL_SeedWrapper.SettingValue.class);
                    seedLog += System.now()+' Processed SettingValue Json \n';

                    List<SVMXC__ServiceMax_Config_Data__c> existingValue = [select Id,SVMXC__SETTING_UNIQUE_ID__C,SVMXC__CONFIG_PROFILE_NAME__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Setting Value' and SVMXC__CONFIG_PROFILE_NAME__c in ('Default','Default Group Profile')];
                    Map<String, String> settingValueMap = new Map<String, String>();
                    for(SVMXC__ServiceMax_Config_Data__c settingValueConfig : existingValue){
                        settingValueMap.put(settingValueConfig.SVMXC__SETTING_UNIQUE_ID__C + '_' + settingValueConfig.SVMXC__CONFIG_PROFILE_NAME__c, settingValueConfig.Id);
                    }

                    for(TOOL_SeedWrapper.SettingValueData settingValueData : settingValueContent.settingValues) {
                        String settingType = settingValueData.SETTINGTYPE;
                        String profileType = settingValueData.PROFILETYPE;

                        if((settingType.equals('Global') && profileType.equals('Global')) ||
                        (settingType.equals('Group') && (profileType.equals('Group') || profileType.equals('Global')) ||
                        (settingType.equals('User') && (profileType.equals('User') || profileType.equals('Group') || profileType.equals('Global'))))) {

                            SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c();
                            if(settingValueMap.size() > 0 && settingValueMap.containsKey(settingValueData.SVMXC_SETTING_ID_C + '_' + settingValueData.SVMXC_SETTING_CONFIGURATION_PROFILE_C)){
                                settingValueConfig.Id = settingValueMap.get(settingValueData.SVMXC_SETTING_ID_C + '_' + settingValueData.SVMXC_SETTING_CONFIGURATION_PROFILE_C);
                                if('IPAD018_SET018'.equals(settingValueData.SVMXC_SETTING_ID_C) || 'MOBN001_SET006'.equals(settingValueData.SVMXC_SETTING_ID_C)){
                                    settingValueConfig.SVMXC__INTERNAL_VALUE__C = defaultBusinessHours;
                                    settingValueConfig.SVMXC__DISPLAY_VALUE__C = defaultBusinessHours;
                                }else{
                                    settingValueConfig.SVMXC__INTERNAL_VALUE__C = settingValueData.SVMXC_INTERNAL_VALUE_C;
                                    settingValueConfig.SVMXC__DISPLAY_VALUE__C = settingValueData.SVMXC_DISPLAY_VALUE_C;
                                }
                                settingValueConfig.SVMXC__ACTIVE__C = Boolean.valueOf(settingValueData.SVMXC_ACTIVE_C);
                                settingValueConfig.RecordTypeId = processRecordType.Id;
                                settingValueConfig.SVMXC__INSTALLATION_KEY__C = seedKey;
                            }
                            else {
                                settingValueConfig.SVMXC__SETTING_CONFIGURATION_PROFILE__C = profileMap.get(settingValueData.SVMXC_SETTING_CONFIGURATION_PROFILE_C);
                                settingValueConfig.SVMXC__SETTING_ID__C = settingMap.get(settingValueData.SVMXC_SETTING_ID_C);
                                if(freshSettingMap.size() > 0 && freshSettingMap.containsKey(settingValueData.SVMXC_SETTING_ID_C)){
                                    settingValueConfig.SVMXC__INTERNAL_VALUE__C = freshSettingMap.get(settingValueData.SVMXC_SETTING_ID_C);
                                    settingValueConfig.SVMXC__DISPLAY_VALUE__C = freshSettingMap.get(settingValueData.SVMXC_SETTING_ID_C);
                                }else if('IPAD018_SET018'.equals(settingValueData.SVMXC_SETTING_ID_C) || 'MOBN001_SET006'.equals(settingValueData.SVMXC_SETTING_ID_C)){
                                    settingValueConfig.SVMXC__INTERNAL_VALUE__C = defaultBusinessHours;
                                    settingValueConfig.SVMXC__DISPLAY_VALUE__C = defaultBusinessHours;
                                }
                                else{
                                    settingValueConfig.SVMXC__INTERNAL_VALUE__C = settingValueData.SVMXC_INTERNAL_VALUE_C;
                                    settingValueConfig.SVMXC__DISPLAY_VALUE__C = settingValueData.SVMXC_DISPLAY_VALUE_C;
                                }
                                settingValueConfig.SVMXC__ACTIVE__C = Boolean.valueOf(settingValueData.SVMXC_ACTIVE_C);
                                settingValueConfig.SVMXC__ISDEFAULT__C = Boolean.valueOf(settingValueData.SVMXC_ISDEFAULT_C);
                                settingValueConfig.RecordTypeId = processRecordType.Id;
                                settingValueConfig.SVMXC__INSTALLATION_KEY__C = seedKey;
                            }
                            settingValuesList.add(settingValueConfig);  
                        }
                    }
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( settingValuesList, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert settingValuesList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    //process setting values of new settings for custom profiles
                    if(customProfileMap.size() > 0) {
                        if(Test.isRunningTest()){
                            SVMXC__SERVICEMAX_PROCESSES__C processSettingDef = new SVMXC__SERVICEMAX_PROCESSES__C();
                            processSettingDef.SVMXC__SUBMODULEID__C = 'CASE001';
                            processSettingDef.SVMXC__SETTINGID__C = 'SET002';
                            processSettingDef.SVMXC__SETTINGS_NAME__C = 'Default Booking Window Start';
                            processSettingDef.SVMXC__SETTING_TYPE__C = 'Global';
                            processSettingDef.SVMXC__DEFAULT_VALUE__C = 'TODAY';
                            newSettingList.add(processSettingDef);
                        }
                        List<SVMXC__ServiceMax_Config_Data__c> newCustomProfileValues = new List<SVMXC__ServiceMax_Config_Data__c>();
                        for(SVMXC__SERVICEMAX_PROCESSES__C settingData : newSettingList){
                            String settingUniqueId = settingData.SVMXC__SUBMODULEID__C + '_' + settingData.SVMXC__SETTINGID__C;
                            String strSettingType = settingData.SVMXC__SETTING_TYPE__C;
                            for(String profileName : customProfileMap.keySet()){
                                String profileValue = customProfileMap.get(profileName);
                                String strProfileType = profileValue.split('_')[1];
                                if((strSettingType.equals('Global') && strProfileType.equals('Global')) ||
                                  (strSettingType.equals('Group') && (strProfileType.equals('Group') || strProfileType.equals('Global')) ||
                                  (strSettingType.equals('User') && (strProfileType.equals('User') || strProfileType.equals('Group') || strProfileType.equals('Global'))))){
                                    SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c();
                                    settingValueConfig.SVMXC__SETTING_CONFIGURATION_PROFILE__C  = profileValue.split('_')[0];
                                    settingValueConfig.SVMXC__SETTING_ID__C = settingData.Id;
                                    if('IPAD018_SET018'.equals(settingUniqueId) || 'MOBN001_SET006'.equals(settingUniqueId)){
                                        settingValueConfig.SVMXC__INTERNAL_VALUE__C = defaultBusinessHours;
                                        settingValueConfig.SVMXC__DISPLAY_VALUE__C = defaultBusinessHours;
                                    }else{
                                        settingValueConfig.SVMXC__INTERNAL_VALUE__C = settingData.SVMXC__DEFAULT_VALUE__C;
                                        settingValueConfig.SVMXC__DISPLAY_VALUE__C = settingData.SVMXC__DEFAULT_VALUE__C;
                                    }  
                                    settingValueConfig.SVMXC__ACTIVE__C = True;
                                    settingValueConfig.SVMXC__ISDEFAULT__C = True;
                                    settingValueConfig.RecordTypeId = processRecordType.Id;
                                    settingValueConfig.SVMXC__INSTALLATION_KEY__C = seedKey;
                                    newCustomProfileValues.add(settingValueConfig);
                                }
                            }   
                        }
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newCustomProfileValues, COMM_SecurityUtils.Access.Createable ) ) {
                            insert newCustomProfileValues;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
                    if(Test.isRunningTest()){
                		customSettingValueUpdateJson = '{"customSettingValueUpdateJson":[{"SettingId":"USR001_SET003","SettingValue":"True","NewInternalValue":"False"}]}';
           			 }
                    // Process Custom Profiles Setting Values Update.
                    if(CustomSettingValueUpdateJson != null && !String.isBlank(CustomSettingValueUpdateJson)){
                        TOOL_SeedWrapper.CustomSettingValue customSettingValueContent =  (TOOL_SeedWrapper.CustomSettingValue)System.JSON.deserialize(customSettingValueUpdateJson.trim(), TOOL_SeedWrapper.CustomSettingValue.class);
                        seedLog += System.now()+' Processed Custom SettingValues Json \n';
                        List<String> updateSettings = new List<String>();
                        Map<String,Map<String,String>> settingUniqueIds = new Map<String, Map<String,String>>();
                        for(TOOL_SeedWrapper.CustomSettingValueData customSettingValueData: customSettingValueContent.customSettingValues){
                            if(customSettingValueData != null){
                                updateSettings.add(customSettingValueData.SettingId);
                                Map<String, String> internalValues = new Map<String, String>();
                                internalValues.put(customSettingValueData.SettingValue, customSettingValueData.NewInternalValue);
                                settingUniqueIds.put(customSettingValueData.SettingId, internalValues);
                            }
                        }
                        if(customProfiles.size() > 0 && updateSettings.size() > 0){
                            List<SVMXC__ServiceMax_Config_Data__c> updateSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
                            for(SVMXC__ServiceMax_Config_Data__c settingValues :[SELECT Id,SVMXC__Display_Value__c,SVMXC__Internal_Value__c,SVMXC__Setting_Configuration_Profile__c,SVMXC__Setting_ID__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'setting value' and SVMXC__Setting_Unique_ID__c IN : updateSettings and SVMXC__Setting_Configuration_Profile__r.SVMXC__Profile_Name__c IN : customProfiles]){
                                if(settingValues != null && settingUniqueIds != null && settingUniqueIds.size() > 0 && settingUniqueIds.containsKey(settingValues.SVMXC__Setting_Unique_ID__c)){
                                    Map<String, String> internalValue = settingUniqueIds.get(settingValues.SVMXC__Setting_Unique_ID__c);
                                    if(internalValue != null && internalValue.size() > 0 && (internalValue.containsKey(settingValues.SVMXC__Internal_Value__c) || internalValue.containsKey(settingValues.SVMXC__Display_Value__c))){
                                       SVMXC__ServiceMax_Config_Data__c newInternalValue = new SVMXC__ServiceMax_Config_Data__c();
                                       newInternalValue.SVMXC__Display_Value__c = internalValue.get(settingValues.SVMXC__Internal_Value__c);
                                       newInternalValue.SVMXC__Internal_Value__c = internalValue.get(settingValues.SVMXC__Internal_Value__c);
                                       newInternalValue.Id = settingValues.Id;
                                       updateSettingValues.add(newInternalValue);
                                    }
                                }
                            }
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( updateSettingValues, COMM_SecurityUtils.Access.updateable ) ) {
                                update updateSettingValues;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                            }
                        }
                    }
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' SettingValue Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Setting Values \n\n';
            System.debug('End of Processing Setting Values');
        }
        catch(Exception e){
            installStatus = false;
            Database.rollback(savePoint);
            seedLog += System.now()+' Error while processing Setting Values : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Setting Values : ' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'Setting Values');
        return installStatus;
    }

    public static boolean processMacros() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Macro Definition');
            seedLog += System.now()+' Started Processing Macro Definition \n';
            if(Test.isRunningTest()){
                macroDefnition = '{"macroDefinition":[{"SVMXC_Type_c":"Conditional","SVMXC_Macro_Id_c":"Conditional_BOOL_C","SVMXC_Macro_Name_c":"BOOL","SVMXC_Description_c":"Returns True if all the non-null values, false otherwise.","SVMXC_Syntax_c":"$F.BOOL(<value>)","SVMXC_Example_c":"$F.BOOL($D.WorkOrder.Id)","SVMXC_IsStandard_c":"True","SVMXC_IsActive_c":"True"}]}';
            }
            if(macroDefnition != null && !String.isBlank(macroDefnition)){
                savePoint = Database.setSavepoint();
                TOOL_SeedWrapper.MacroDefinition macros =  (TOOL_SeedWrapper.MacroDefinition)System.JSON.deserialize(macroDefnition.trim(), TOOL_SeedWrapper.MacroDefinition.class);
                seedLog += System.now()+' Processed MacroDef Json Content \n';

                List<SVMXC__Function_Definition__c> existingMacroList = [Select Id from SVMXC__Function_Definition__c where SVMXC__IsStandard__c = true];

                if(existingMacroList != null && existingMacroList.size() > 0){
                    delete existingMacroList;
                }
                List<SVMXC__Function_Definition__c> macroList = new List<SVMXC__Function_Definition__c>();
                for(TOOL_SeedWrapper.MacroDefinitionData macroData : macros.macroDefinition) {
                    SVMXC__Function_Definition__c functionDefinition = new SVMXC__Function_Definition__c();
                    functionDefinition.SVMXC__Description__c = macroData.SVMXC_Description_c;
                    functionDefinition.SVMXC__Macro_Name__c = macroData.SVMXC_Macro_Name_c;
                    functionDefinition.SVMXC__IsStandard__c = Boolean.valueOf(macroData.SVMXC_IsStandard_c);
                    functionDefinition.SVMXC__Syntax__c = macroData.SVMXC_Syntax_c;
                    functionDefinition.SVMXC__Type__c = macroData.SVMXC_Type_c;
                    functionDefinition.SVMXC__Example__c = macroData.SVMXC_Example_c;
                    functionDefinition.SVMXC__SM_Entity_Type__c = macroData.SVMXC_SM_Entity_Type_c;
                    functionDefinition.SVMXC__IsActive__c = Boolean.valueOf(macroData.SVMXC_IsActive_c);
                    macroList.add(functionDefinition);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( macroList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert macroList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' MacroDefnition Json is empty \n';
            }
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Macro Def : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Macro Definition : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        seedLog += System.now()+' End of Processing Macro Definition \n\n';
        System.debug('End of Processing Macro Definition');
        setLogMessage(installStatus, 'Macro Definition');
        return installStatus;
    }

    public static boolean processCodeSnippet() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Code Snippet');
            seedLog += System.now()+' Started Processing Code Snippet \n';
            if(Test.isRunningTest()){
                codeSnippet = '<?xml version="1.0" encoding="UTF-8"?><CodeSnippet><Snippet><SVMXC__Name__c>Third party apps</SVMXC__Name__c><SVMXC__Data__c>[{"url_scheme_name": "docscan","app_display_name":"DocScan","url_prameters": "sendto=SVMXC__Invoice_Number__c&amp;goto=SVMXC__Zip__c"},{"url_scheme_name": "docscan1","app_display_name": "DocScan1","url_prameters": "sendto=SVMXC__Invoice_Number__c&amp;goto=SVMXC__Zip__c"}]</SVMXC__Data__c><SVMXC__SnippetId__c>Code008</SVMXC__SnippetId__c><SVMXC__Description__c>To integrate sharing with other apps</SVMXC__Description__c><SVMXC__IsStandard__c>True</SVMXC__IsStandard__c><SVMXC__Type__c>JSON</SVMXC__Type__c></Snippet></CodeSnippet>';
            }
            savePoint = Database.setSavepoint();
            if(codeSnippet != null && !String.isBlank(codeSnippet)){
                //get existing code snippet
                List<SVMXC__Code_Snippet__c> existingSnippet = [SELECT Id,SVMXC__SnippetId__c FROM SVMXC__Code_Snippet__c where SVMXC__IsStandard__c = True];
                if(existingSnippet != null && existingSnippet.size() > 0){
                    for(SVMXC__Code_Snippet__c snippetData : existingSnippet){
                        snippetMap.put(snippetData.SVMXC__SnippetId__c, snippetData.Id);
                    }
                }
                DOM.Document domXML = new DOM.Document();
                domXML.load(codeSnippet.trim());
                seedLog += System.now()+' Processed CodeSnippet XML Content \n';

                Dom.XMLNode codeSnippetNode = domXML.getRootElement();
                List<SVMXC__Code_Snippet__c> snippetList = new List<SVMXC__Code_Snippet__c>();
                for(Dom.XMLNode childNode : codeSnippetNode.getChildElements()){
                    SVMXC__Code_Snippet__c snippetCode = new SVMXC__Code_Snippet__c();
                    String snippetId = childNode.getChildElement('SVMXC__SnippetId__c', null).getText();
                    System.debug('Snippet Id ----- '+snippetId);
                    seedLog += 'Snippet Id ----- '+snippetId +'\n';
                    if(snippetMap.size() > 0 && snippetMap.containsKey(snippetId)){
                    	if(snippetId != 'Code009' && snippetId != 'Code010'){
	                        snippetCode.Id = snippetMap.get(snippetId);
	                        snippetCode.SVMXC__Name__c = childNode.getChildElement('SVMXC__Name__c', null).getText();
	                        snippetCode.SVMXC__Description__c = childNode.getChildElement('SVMXC__Description__c', null).getText();
	                        snippetCode.SVMXC__IsStandard__c = Boolean.valueOf(childNode.getChildElement('SVMXC__IsStandard__c', null).getText());
	                        snippetCode.SVMXC__Data__c = childNode.getChildElement('SVMXC__Data__c', null).getText();
	                        snippetCode.SVMXC__Type__c = childNode.getChildElement('SVMXC__Type__c', null).getText();
                    		snippetList.add(snippetCode);
                        }
                        else if(snippetId.equals('Code009')){
                            snippetCode.Id = snippetMap.get(snippetId);
	                        snippetCode.SVMXC__Name__c = childNode.getChildElement('SVMXC__Name__c', null).getText();
                            snippetList.add(snippetCode);
                        }
                    }
                    else{
                        snippetCode.SVMXC__SnippetId__c = childNode.getChildElement('SVMXC__SnippetId__c', null).getText();
                        snippetCode.SVMXC__Name__c = childNode.getChildElement('SVMXC__Name__c', null).getText();
                        snippetCode.SVMXC__Description__c = childNode.getChildElement('SVMXC__Description__c', null).getText();
                        snippetCode.SVMXC__IsStandard__c = Boolean.valueOf(childNode.getChildElement('SVMXC__IsStandard__c', null).getText());
                        snippetCode.SVMXC__Data__c = childNode.getChildElement('SVMXC__Data__c', null).getText();
                        snippetCode.SVMXC__Type__c = childNode.getChildElement('SVMXC__Type__c', null).getText();
                    	snippetList.add(snippetCode);
                    }
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( snippetList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert snippetList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else {
                installStatus = false;
                seedLog += System.now()+' Code Snippet is not found\n';
                System.debug('Code Snippet is not found');
            }
            seedLog += System.now()+' End of Processing Code Snippet \n\n';
            System.debug('End of Processing Code Snippet');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Code Snippet : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Code Snippet : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Code Snippet');
        return installStatus;
    }

    public static boolean processCodeSnippetManifest() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Code Snippet Manifest');
            seedLog += System.now()+' Started Processing Code Snippet Manifest \n';
            if(Test.isRunningTest()){
                codeSnippetManifest = '{"codeSnippetManifest":[{"SVMXC_Code_Snippet_c":"Code001","SVMXC_Referenced_Code_Snippet_c":"Code002"}]}';
            }
            if(codeSnippetManifest != null && !String.isBlank(codeSnippetManifest)){
                savePoint = Database.setSavepoint();
                TOOL_SeedWrapper.SnippetManifest snippetManifest =  (TOOL_SeedWrapper.SnippetManifest)System.JSON.deserialize(codeSnippetManifest.trim(), TOOL_SeedWrapper.SnippetManifest.class);
                seedLog += System.now()+' Processed CodeSnippetManifest Json \n';

                if(snippetMap.size() > 0){
                    List<String> snippetList = new List<String>();
                    for(String snippetId : snippetMap.keySet()){
                        snippetList.add(snippetMap.get(snippetId));
                    }
                    List<SVMXC__Code_Snippet_Manifest__c> existingManifest = [Select Id from SVMXC__Code_Snippet_Manifest__c where SVMXC__Code_Snippet__c In :snippetList];
                    if(existingManifest != null && existingManifest.size() > 0){
                        delete existingManifest;
                    }
                }
                List<SVMXC__Code_Snippet__c> codeSnippetData = [SELECT Id,SVMXC__SnippetId__c FROM SVMXC__Code_Snippet__c where SVMXC__IsStandard__c = True];
                Map<String, String> codeSnippetMap = new Map<String, String>();
                if(codeSnippetData != null && codeSnippetData.size() > 0){
                    for(SVMXC__Code_Snippet__c snippetCode : codeSnippetData){
                        codeSnippetMap.put(snippetCode.SVMXC__SnippetId__c, snippetCode.Id);
                    }
                }

                List<SVMXC__Code_Snippet_Manifest__c> configDataList = new List<SVMXC__Code_Snippet_Manifest__c>();
                for(TOOL_SeedWrapper.ManifestData manifestdata : snippetManifest.codeSnippetManifest) {
                    SVMXC__Code_Snippet_Manifest__c snippetData = new SVMXC__Code_Snippet_Manifest__c();
                    snippetData.SVMXC__Code_Snippet__c = codeSnippetMap.get(manifestdata.SVMXC_Code_Snippet_c);
                    snippetData.SVMXC__Referenced_Code_Snippet__c = codeSnippetMap.get(manifestdata.SVMXC_Referenced_Code_Snippet_c);
                    configDataList.add(snippetData);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configDataList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert configDataList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' CodeSnippetManifest Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Code Snippet Manifest \n\n';
            System.debug('End of Processing Code Snippet Manifest');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Code Snippet Manifest : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Code Snippet Manifest : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Code Snippet Manifest');
        return installStatus;
    }

    public static boolean processApplicationFilter() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Application Filter');
            seedLog += System.now()+' Started Processing Application Filter \n';
            if(Test.isRunningTest()){
                applicationFilter = '{"applicationFilter":[{"SVMXC_ProcessID_c":"APPPRO001","SVMXC_Name_c":"ServiceMax Online","SVMXC_Description_c":"","SVMXC_Values_c":"","SVMXC_IsStandard_c":"True"}]}';
            }
            if(applicationFilter != null && !String.isBlank(applicationFilter)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Application Profile'];
                TOOL_SeedWrapper.ApplicationFilter filterData =  (TOOL_SeedWrapper.ApplicationFilter)System.JSON.deserialize(applicationFilter.trim(), TOOL_SeedWrapper.ApplicationFilter.class);
                seedLog += System.now()+' Processed ApplicationFilter Json \n';

                //fetch existing filter data
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingFilter = [SELECT Id,SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Application Profile' and SVMXC__IsStandard__c = true];

                if(existingFilter != null && existingFilter.isEmpty()){
                    List<SVMXC__SERVICEMAX_PROCESSES__C> filterDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                    for(TOOL_SeedWrapper.ApplicationFilterData appFilter : filterData.applicationFilter) {
                        SVMXC__SERVICEMAX_PROCESSES__C processFilterData = new SVMXC__SERVICEMAX_PROCESSES__C();
                        processFilterData.SVMXC__ProcessID__c = appFilter.SVMXC_ProcessID_c;
                        processFilterData.SVMXC__Name__c = appFilter.SVMXC_Name_c;
                        processFilterData.SVMXC__Description__c = appFilter.SVMXC_Description_c;
                        processFilterData.SVMXC__Values__c = appFilter.SVMXC_Values_c;
                        processFilterData.SVMXC__IsStandard__c = Boolean.valueOf(appFilter.SVMXC_IsStandard_c);
                        processFilterData.RecordTypeId = processRecordType.Id;
                        processFilterData.SVMXC__INSTALLATION_KEY__C = seedKey;
                        filterDataList.add(processFilterData);
                    }
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( filterDataList, COMM_SecurityUtils.Access.Createable ) ) {
                        insert filterDataList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                else{
                    seedLog += System.now()+' Org has records in Application Filter details \n';
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' ApplicationFilter Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Application Filter \n\n';
            System.debug('End of Processing Application Filter');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Application Filter : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Application Filter : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Application Filter');
        return installStatus;
    }

    public static boolean processMapHover() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing MapHovers');
            seedLog += System.now()+' Started Processing MapHovers \n';
            if(Test.isRunningTest()){
                mapHoverJson = '{"mapHover":[{"SVMXC_NAME_C":"Map Hover For Work Order","SVMXC_Rule_Type_c":"Column Info","SVMXC_Source_Object_Name_c":"SVMXC__Service_Order__c","SVMXC_ProcessID_c":"MAPHOV01","SVMXC_ISSTANDARD_C":"True"}]}';
            }
            if(mapHoverJson != null && !String.isBlank(mapHoverJson)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'SVMX Rule'];
                TOOL_SeedWrapper.MapHover mapHoverData =  (TOOL_SeedWrapper.MapHover)System.JSON.deserialize(mapHoverJson.trim(), TOOL_SeedWrapper.MapHover.class);
                seedLog += System.now()+' Processed MapHover Json \n';

                //fetch existing mapHover data
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingHovers = [SELECT Id,SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'SVMX Rule' and SVMXC__IsStandard__c = true];
                Map<String, String> existingMap = new Map<String, String>();
                if(existingHovers != null && existingHovers.size() > 0){
                    for(SVMXC__SERVICEMAX_PROCESSES__C hoverData : existingHovers){
                        existingMap.put(hoverData.SVMXC__ProcessID__c, hoverData.Id);
                    }
                }

                List<SVMXC__SERVICEMAX_PROCESSES__C> hoverDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                    for(TOOL_SeedWrapper.MapHoverData hoverDetails : mapHoverData.mapHover) {
                        SVMXC__SERVICEMAX_PROCESSES__C processHoverData = new SVMXC__SERVICEMAX_PROCESSES__C();
                        if(existingMap.size() > 0 && existingMap.containsKey(hoverDetails.SVMXC_ProcessID_c)){
                            processHoverData.Id = existingMap.get(hoverDetails.SVMXC_ProcessID_c);
                            processHoverData.SVMXC__NAME__C = hoverDetails.SVMXC_NAME_C;
                            processHoverData.SVMXC__Rule_Type__c = hoverDetails.SVMXC_Rule_Type_c;
                            processHoverData.SVMXC__Source_Object_Name__c = hoverDetails.SVMXC_Source_Object_Name_c;
                            processHoverData.SVMXC__ISSTANDARD__C = Boolean.valueOf(hoverDetails.SVMXC_ISSTANDARD_C);
                            processHoverData.RecordTypeId = processRecordType.Id;
                            processHoverData.SVMXC__INSTALLATION_KEY__C = seedKey;
                            oldHoverDataList.add(processHoverData);
                        }else{
                            processHoverData.SVMXC__NAME__C = hoverDetails.SVMXC_NAME_C;
                            processHoverData.SVMXC__Rule_Type__c = hoverDetails.SVMXC_Rule_Type_c;
                            processHoverData.SVMXC__Source_Object_Name__c = hoverDetails.SVMXC_Source_Object_Name_c;
                            processHoverData.SVMXC__ProcessID__c = hoverDetails.SVMXC_ProcessID_c;
                            processHoverData.SVMXC__ISSTANDARD__C = Boolean.valueOf(hoverDetails.SVMXC_ISSTANDARD_C);
                            processHoverData.RecordTypeId = processRecordType.Id;
                            processHoverData.SVMXC__INSTALLATION_KEY__C = seedKey;
                        }
                        hoverDataList.add(processHoverData);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( hoverDataList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert hoverDataList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' MapHoverJson Json is empty \n';
            }
            seedLog += System.now()+' End of Processing MapHovers \n\n';
            System.debug('End of Processing MapHovers');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing MapHovers : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing MapHovers : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Map Hover');
        return installStatus;
    }

    public static boolean processMapHoverDetail() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing MapHover Details');
            seedLog += System.now()+' Started Processing MapHovers Details \n';
            if(Test.isRunningTest()){
                mapHoverDetail = '{"mapHoverDetails":[{"SVMXC_Expression_Rule_c":"MAPHOV01","SVMXC_Expression_Type_c":"Column Field","SVMXC_Sequence_c":"1","SVMXC_Field_Name_c":"Name","SVMXC_Display_Type_c":"STRING","SVMXC_Field_Relationship_Name_c":"","SVMXC_FKey_Name_Field_c":""}]}';
            }
            if(mapHoverDetail != null && !String.isBlank(mapHoverDetail)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'EXPRESSIONS'];
                TOOL_SeedWrapper.HoverDetail hoverDetailData =  (TOOL_SeedWrapper.HoverDetail)System.JSON.deserialize(mapHoverDetail.trim(), TOOL_SeedWrapper.HoverDetail.class);
                seedLog += System.now()+' Processed MapHoverDetails Json Content \n';

                Map<String, String> hoverMap = new Map<String, String>();
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingHovers = [SELECT Id,SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'SVMX Rule' and SVMXC__IsStandard__c = true];
                if(existingHovers != null && existingHovers.size() > 0){
                    if(oldHoverDataList.size() > 0){
                        List<SVMXC__ServiceMax_Config_Data__c> mapHoverDetailList = [SELECT Id FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE RecordTypeId =: processRecordType.Id  AND SVMXC__Expression_Type__c = 'Column Field' AND SVMXC__Expression_Rule__c IN : oldHoverDataList];
                        if(mapHoverDetailList != null && mapHoverDetailList.size() > 0){
                            delete mapHoverDetailList;
                        }
                    }
                    for(SVMXC__SERVICEMAX_PROCESSES__C hoverDetail : existingHovers){
                        hoverMap.put(hoverDetail.SVMXC__ProcessID__c, hoverDetail.Id);
                    }

                    List<SVMXC__SERVICEMAX_CONFIG_DATA__C> configList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
                    for(TOOL_SeedWrapper.HoverDetailData detailData : hoverDetailData.mapHoverDetails){
                        SVMXC__SERVICEMAX_CONFIG_DATA__C mapHoverDetailData = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
                        mapHoverDetailData.SVMXC__Expression_Rule__c = hoverMap.get(detailData.SVMXC_Expression_Rule_c);
                        mapHoverDetailData.SVMXC__Field_Name__c = detailData.SVMXC_Field_Name_c;
                        mapHoverDetailData.SVMXC__Sequence__c = Decimal.valueOf(detailData.SVMXC_Sequence_c);
                        mapHoverDetailData.SVMXC__Expression_Type__c = detailData.SVMXC_Expression_Type_c;
                        mapHoverDetailData.SVMXC__Display_Type__c = detailData.SVMXC_Display_Type_c;
                        mapHoverDetailData.SVMXC__Field_Relationship_Name__c = detailData.SVMXC_Field_Relationship_Name_c;
                        mapHoverDetailData.SVMXC__FKey_Name_Field__c = detailData.SVMXC_FKey_Name_Field_c;
                        mapHoverDetailData.RecordTypeId = processRecordType.Id;
                        mapHoverDetailData.SVMXC__INSTALLATION_KEY__C = seedKey;
                        configList.add(mapHoverDetailData);
                    }   
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configList, COMM_SecurityUtils.Access.Createable ) ) {
                        insert configList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' MapHoverDetail Json is empty \n';
            }
            seedLog += System.now()+' End of Processing MapHovers Details \n\n';
            System.debug('End of Processing MapHover Details');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing MapHover Details : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing MapHover Details : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Map Hover Details');
        return installStatus;
    }

    public static boolean processPropertyElement() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Property Elements');
            seedLog += System.now()+' Started Processing Property Elements \n';
            if(Test.isRunningTest()){
                propertyElement = '{"propertyElements":[{"SVMXC_NAME_C":"PELE001","SVMXC_Property_Key_c":"Titanium","SVMXC_Element_Type_c":"Allowed Object","SVMXC_Element_Value_c":"Account"}]}';
            }
            if(propertyElement != null && !String.isBlank(propertyElement)){
                savePoint = Database.setSavepoint();
    
                TOOL_SeedWrapper.PropertyElement propertyElementData =  (TOOL_SeedWrapper.PropertyElement)System.JSON.deserialize(propertyElement.trim(), TOOL_SeedWrapper.PropertyElement.class);
                seedLog += System.now()+' Processed PropertyElement Json Content \n';
                List<SVMXC__ServiceMax_Property_Elements__c> propElementList = new List<SVMXC__ServiceMax_Property_Elements__c>();
                List<String> propertyNameList = new List<String>();
                for(TOOL_SeedWrapper.ElementData element : propertyElementData.propertyElements){
                    SVMXC__ServiceMax_Property_Elements__c propElement = new SVMXC__ServiceMax_Property_Elements__c();
                    propertyNameList.add(element.SVMXC_NAME_C);
                    propElement.NAME = element.SVMXC_NAME_C;
                    propElement.SVMXC__Property_Key__c = element.SVMXC_Property_Key_c;
                    propElement.SVMXC__Element_Type__c = element.SVMXC_Element_Type_c;
                    propElement.SVMXC__Element_Value__c = element.SVMXC_Element_Value_c;
                    propElementList.add(propElement);
                }
                propertyNameList.add('PELE533');
                propertyNameList.add('PELE539');
                propertyNameList.add('PELE545');
                propertyNameList.add('PELE551');
                List<SVMXC__ServiceMax_Property_Elements__c> existingElementList = [SELECT Id FROM SVMXC__ServiceMax_Property_Elements__c where NAME in : propertyNameList];
                if(existingElementList != null && existingElementList.size() > 0){
                    delete existingElementList;
                }
                else{
                    seedLog += System.now()+' Property Elements not available in org \n';
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( propElementList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert propElementList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else{
                installStatus = false;
                seedLog += System.now()+' Property Element Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Property Elements \n\n';    
            System.debug('End of Processing Property Elements');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Property Elements : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Property Elements : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Property Elements');
        return installStatus;
    }
    
    public static void insertLogAttachment(){
        try{
            List<SVMXC__SVMX_Jobs__c> jobList = new List<SVMXC__SVMX_Jobs__c>();
            SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
            svmxJob.SVMXC__Start_Time__c = System.now();
            svmxJob.SVMXC__Type__c = 'Push-Upgrade';
            jobList.add(svmxJob);
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( jobList, COMM_SecurityUtils.Access.Createable ) ) {
                insert jobList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            confJobId = svmxJob.id;
        }
        catch(Exception e){
          System.debug('Error while inserting log details : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
      }
    }
    
    public static void setLogMessage(boolean status, String process) {
        if(status){
            mailBody += 'Processing ' + process + ' : Success \n\n';
        }else{
            mailBody += 'Processing ' + process + ' : Failure \n\n';
        }
    }

    public static void sendConfiguratorEmail(String userMail) {
        try {
            if(userMail != null && userMail != ''){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(userMail);
                mail.setToAddresses(sendTo);
                mail.setSenderDisplayName('Servicemax Configurator');
                mail.setSubject('ServiceMax Configuration Status');
                mail.setPlainTextBody('Your request for loading the default configuration of ServiceMax is completed \n\n'+ mailBody);
                if(seedLog != null && seedLog.length() > 0){
                    seedLog = seedLog.replaceFirst('\n\n', '');
                    Messaging.EmailFileAttachment objFileAttachment = new Messaging.EmailFileAttachment();
                    objFileAttachment.setFileName('Servicemax Seed Log.txt');
                    objFileAttachment.setBody(Blob.valueof(seedLog));
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {objFileAttachment});
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            else {
                System.debug('User Mail Id not found : ' + userMail);
            }
        }
        catch(Exception e) {
            System.debug('Error while sending mail : ' + e.getStackTraceString());
        }
    }
    
    public static void checkFreshInstall() {
        try{
            List<SVMXC__SERVICEMAX_PROCESSES__C> processList = [SELECT Id FROM SVMXC__SERVICEMAX_PROCESSES__C limit 1];
            if(processList != null && processList.size() > 0){
                isFreshInstall = false;
            }else{
                isFreshInstall = true;
            }
            seedLog += System.now()+' Fresh Install - '+isFreshInstall+'\n';
        }catch(Exception e) {
            seedLog += System.now()+' Error while checking fresh install : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while checking fresh install : ' + e.getStackTraceString());
        }
    }
    
    public static void getBusinessHoursDefaultValue() {
        try{
            BusinessHours bussinessHour = [SELECT Name FROM BusinessHours WHERE IsDefault = true limit 1];
            if(bussinessHour != null){
                defaultBusinessHours = bussinessHour.Name;
                seedLog += System.now()+' Default Bussiness hour - '+defaultBusinessHours+'\n';
            }else{
                seedLog += System.now()+' Bussiness hour is null \n';
            }
        }catch(Exception e) {
            seedLog += System.now()+' Error while getting default bussiness hour : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while getting default bussiness hour : ' + e.getStackTraceString());
        }
    }
    
    public static boolean processServiceFlowAction() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Service Flow Actions');
            seedLog += System.now()+' Started Processing Service Flow Actions \n';
            if(Test.isRunningTest()){
                serviceFlowActions = '{"sfactions":[{"RecordTypeName":"SF Action","SVMXC_ProcessID_c":"OTH000","SVMXC_Name_c":"View Configuration","SVMXC_Description_c":"View Configuration","SVMXC_Target_Type_c":"Existing Window","SVMXC_Target_URL_c":"/apex/SVMXC__IPRD_IBTree","SVMXC_IsStandard_c":"True","SVMXC_Window_Height_c":"330","SVMXC_Window_Width_c":"900","SVMXC_Active_c":"True","SVMXC_Open_As_Full_Window_c":"False","SVMXC_Source_Object_Name_c":"SVMXC__Installed_Product__c","SVMXC_Custom_Action_Type_c":"URL","SVMXC_Service_Namespace_c":"","SVMXC_Service_Class_Name_c":"","SVMXC_Service_Method_Name_c":""},{"RecordTypeName":"SF Action","SVMXC_ProcessID_c":"OTH001","SVMXC_Name_c":"Modify Configuration","SVMXC_Description_c":"Modify Configuration","SVMXC_Target_Type_c":"Existing Window","SVMXC_Target_URL_c":"/apex/SVMXC__IPRD_IBTree","SVMXC_IsStandard_c":"True","SVMXC_Window_Height_c":"330","SVMXC_Window_Width_c":"900","SVMXC_Active_c":"True","SVMXC_Open_As_Full_Window_c":"False","SVMXC_Source_Object_Name_c":"SVMXC__Installed_Product__c","SVMXC_Custom_Action_Type_c":"URL","SVMXC_Service_Namespace_c":"","SVMXC_Service_Class_Name_c":"","SVMXC_Service_Method_Name_c":""}]}';
            }
            if(serviceFlowActions != null && !String.isBlank(serviceFlowActions)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'SF ACTION'];
                TOOL_SeedWrapper.ServiceFlowAction sfActionContent =  (TOOL_SeedWrapper.ServiceFlowAction)System.JSON.deserialize(serviceFlowActions.trim(), TOOL_SeedWrapper.ServiceFlowAction.class);
                seedLog += System.now()+' Processed Service Flow Actions Json \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingSFActionList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'SF ACTION' and SVMXC__ISSTANDARD__C = true];
                Map<String, String> sfActionMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C sfActionData : existingSFActionList){
                    sfActionMap.put(sfActionData.SVMXC__ProcessID__c, sfActionData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> processDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.SFActionData sfAction : sfActionContent.sfactions) {
                    SVMXC__SERVICEMAX_PROCESSES__C processData = new SVMXC__SERVICEMAX_PROCESSES__C();
                    if(sfActionMap.size() > 0 && sfActionMap.containsKey(sfAction.SVMXC_ProcessID_c)) {
                        processData.Id = sfActionMap.get(sfAction.SVMXC_ProcessID_c);
                        processData.SVMXC__Name__c = sfAction.SVMXC_Name_c;
                        processData.SVMXC__Description__c = sfAction.SVMXC_Description_c;
                        processData.SVMXC__IsStandard__c = Boolean.valueOf(sfAction.SVMXC_IsStandard_c);
                        processData.SVMXC__Active__c = Boolean.valueOf(sfAction.SVMXC_Active_c);
                        processData.SVMXC__Source_Object_Name__c = sfAction.SVMXC_Source_Object_Name_c;
                        processData.SVMXC__Target_Type__c = sfAction.SVMXC_Target_Type_c;
                        processData.SVMXC__Target_URL__c = sfAction.SVMXC_Target_URL_c;
                        processData.SVMXC__Window_Height__c = Decimal.valueOf(sfAction.SVMXC_Window_Height_c);
                        processData.SVMXC__Window_Width__c = Decimal.valueOf(sfAction.SVMXC_Window_Width_c);
                        processData.SVMXC__Installation_Key__c = seedKey;
                        processData.SVMXC__Open_As_Full_Window__c = Boolean.valueOf(sfAction.SVMXC_Open_As_Full_Window_c);
                        processData.SVMXC__Custom_Action_Type__c = sfAction.SVMXC_Custom_Action_Type_c;
                        processData.SVMXC__Service_Namespace__c = sfAction.SVMXC_Service_Namespace_c;
                        processData.SVMXC__Service_Class_Name__c = sfAction.SVMXC_Service_Class_Name_c;
                        processData.SVMXC__Service_Method_Name__c = sfAction.SVMXC_Service_Method_Name_c;
                        processData.RecordTypeId = processRecordType.Id;
                        oldSFActionList.add(processData);
                        
                    }
                    else {
                        processData.SVMXC__ProcessID__c = sfAction.SVMXC_ProcessID_c;
                        processData.SVMXC__Name__c = sfAction.SVMXC_Name_c;
                        processData.SVMXC__Description__c = sfAction.SVMXC_Description_c;
                        processData.SVMXC__IsStandard__c = Boolean.valueOf(sfAction.SVMXC_IsStandard_c);
                        processData.SVMXC__Active__c = Boolean.valueOf(sfAction.SVMXC_Active_c);
                        processData.SVMXC__Source_Object_Name__c = sfAction.SVMXC_Source_Object_Name_c;
                        processData.SVMXC__Target_Type__c = sfAction.SVMXC_Target_Type_c;
                        processData.SVMXC__Target_URL__c = sfAction.SVMXC_Target_URL_c;
                        processData.SVMXC__Window_Height__c = Decimal.valueOf(sfAction.SVMXC_Window_Height_c);
                        processData.SVMXC__Window_Width__c = Decimal.valueOf(sfAction.SVMXC_Window_Width_c);
                        processData.SVMXC__Installation_Key__c = seedKey;
                        processData.SVMXC__Open_As_Full_Window__c = Boolean.valueOf(sfAction.SVMXC_Open_As_Full_Window_c);
                        processData.SVMXC__Custom_Action_Type__c = sfAction.SVMXC_Custom_Action_Type_c;
                        processData.SVMXC__Service_Namespace__c = sfAction.SVMXC_Service_Namespace_c;
                        processData.SVMXC__Service_Class_Name__c = sfAction.SVMXC_Service_Class_Name_c;
                        processData.SVMXC__Service_Method_Name__c = sfAction.SVMXC_Service_Method_Name_c;
                        processData.RecordTypeId = processRecordType.Id;
                    }
                    processDataList.add(processData);
                }  
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( processDataList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert processDataList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' Service Flow Actions Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Service Flow Actions \n\n';
            System.debug('End of Processing Service Flow Actions');     
        }catch(Exception e) {
            installStatus = false;
            Database.rollback(savePoint);
            seedLog += System.now()+' Error while processing ServiceFlowAction : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing ServiceFlowAction' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'ServiceFlowAction');
        return installStatus;   
    }

    public static boolean processServiceFlowActionParameter() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Service Flow Action Parameters');
            seedLog += System.now()+' Started Processing Service Flow Action Parameters \n';
            if(Test.isRunningTest()){
                serviceFlowActionParameters = '{"sfactionparameters":[{"RecordTypeName":"SF Action Parameter","SVMXC_Dispatch_Process_c":"OTH001","SVMXC_Parameter_Name_c":"Id","SVMXC_Parameter_Type_c":"Field Name","SVMXC_Parameter_Value_c":"Id"}]}';
            }
            if(serviceFlowActionParameters != null && !String.isBlank(serviceFlowActionParameters)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
                TOOL_SeedWrapper.ServiceFlowActionParameter sfActionContent =  (TOOL_SeedWrapper.ServiceFlowActionParameter)System.JSON.deserialize(serviceFlowActionParameters.trim(), TOOL_SeedWrapper.ServiceFlowActionParameter.class);
                seedLog += System.now()+' Processed Service Flow Action Parameters Json \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingSFActionList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'SF ACTION' and SVMXC__ISSTANDARD__C = true];
                if(existingSFActionList != null && existingSFActionList.size() > 0){
                    Map<String, String> sfActionMap = new Map<String, String>();
                    for(SVMXC__SERVICEMAX_PROCESSES__C sfActionData : existingSFActionList){
                        sfActionMap.put(sfActionData.SVMXC__ProcessID__c, sfActionData.Id);
                    }
                    
                    if(oldSFActionList.size() > 0){
                        List<SVMXC__ServiceMax_Config_Data__c> sfActionParameterList = [SELECT Id FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE RecordTypeId =: processRecordType.Id AND SVMXC__Dispatch_Process__c IN : oldSFActionList];
                        if(sfActionParameterList != null && sfActionParameterList.size() > 0){
                            delete sfActionParameterList;
                        }
                    }
                    
                    List<SVMXC__SERVICEMAX_CONFIG_DATA__C> configList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
                    for(TOOL_SeedWrapper.SFActionParameterData detailData : sfActionContent.sfactionparameters){
                        SVMXC__SERVICEMAX_CONFIG_DATA__C sfActionParameter = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
                        sfActionParameter.SVMXC__Dispatch_Process__c = sfActionMap.get(detailData.SVMXC_Dispatch_Process_c);
                        sfActionParameter.SVMXC__Parameter_Name__c = detailData.SVMXC_Parameter_Name_c;
                        sfActionParameter.SVMXC__Parameter_Type__c = detailData.SVMXC_Parameter_Type_c;
                        sfActionParameter.SVMXC__Parameter_Value__c = detailData.SVMXC_Parameter_Value_c;
                        sfActionParameter.RecordTypeId = processRecordType.Id;
                        sfActionParameter.SVMXC__INSTALLATION_KEY__C = seedKey;
                        configList.add(sfActionParameter);
                    }   
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configList, COMM_SecurityUtils.Access.Createable ) ) {
                        insert configList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }else{
                installStatus = false;
                seedLog += System.now()+' Service Flow Action Parameters Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Service Flow Action Parameters \n\n';
            System.debug('End of Processing Service Flow Action Parameters');       
        }catch(Exception e) {
            installStatus = false;
            Database.rollback(savePoint);
            seedLog += System.now()+' Error while processing ServiceFlowActionParameters : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing ServiceFlowActionParameters' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'ServiceFlowActionParameters');
        return installStatus;   
    }
    
    public static void updateLogFile() {
        try{
            if(confJobId != null && !String.isBlank(confJobId)){
                //update end time
                List<SVMXC__SVMX_Jobs__c> jobList = new List<SVMXC__SVMX_Jobs__c>();
                SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
                svmxJob.id = confJobId;
                svmxJob.SVMXC__End_Time__c = System.now();
                jobList.add(svmxJob);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( jobList, COMM_SecurityUtils.Access.Updateable ) ) {
                    update jobList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                ContentVersion contentVersion = COMM_FileHandlerUtilities.createContentVersionInstance(null, 'PushUpgradeLog.txt', seedLog, null);
                Id contentVersionId = COMM_FileHandlerUtilities.insertOneContentVersion(contentVersion);
                Map<Id,Id> contentVerionMap = new Map<Id,Id>();
                contentVerionMap.put(contentVersionId, confJobId);
                COMM_FileHandlerUtilities.getContentDocumentData(contentVerionMap);
            }
                
        }catch(Exception e){
            System.debug('Error while processing log file : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
        }
    }
    
    public static boolean processGetPriceFields() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
            System.debug('Started Processing Get Price Fields');
            seedLog += System.now()+' Started Processing Get Price Fields \n';
            if(Test.isRunningTest()){
                priceFields = '{"getpricefields":[{"Name":"GP001","SVMXC_Code_Snippet_ID_c":"Code001","SVMXC_Object_API_Name_c":"SVMXC__Service_Order__c","SVMXC_Field_API_Name_List_c":"SVMXC__Rate_Pricing_Rule__c,SVMXC__Rate_Type_Pricing_Rule__c,SVMXC__Total_Work_Order_Cost__c,SVMXC__Travel_Rate__c,SVMXC__Total_Billable_Amount__c,SVMXC__Total_Estimate__c,SVMXC__Is_Entitlement_Performed__c,SVMXC__Top_Level__c"}]}';
            }
            if(priceFields != null && !String.isBlank(priceFields)){
                savePoint = Database.setSavepoint();
    
                TOOL_SeedWrapper.GetPriceField priceFieldDetails = (TOOL_SeedWrapper.GetPriceField)System.JSON.deserialize(priceFields.trim(), TOOL_SeedWrapper.GetPriceField.class);
                seedLog += System.now()+' Processed GetPriceField Json Content \n';
                List<SVMXC__GetPrice_Fields__c> priceFieldList = new List<SVMXC__GetPrice_Fields__c>();
                List<String> fieldNameList = new List<String>();
                for(TOOL_SeedWrapper.PriceFieldData element : priceFieldDetails.getpricefields){
                    SVMXC__GetPrice_Fields__c priceField = new SVMXC__GetPrice_Fields__c();
                    fieldNameList.add(element.Name);
                    priceField.Name = element.Name;
                    priceField.SVMXC__Code_Snippet_ID__c = element.SVMXC_Code_Snippet_ID_c;
                    priceField.SVMXC__Object_API_Name__c = element.SVMXC_Object_API_Name_c;
                    priceField.SVMXC__Field_API_Name_List__c = element.SVMXC_Field_API_Name_List_c;
                    priceFieldList.add(priceField);
                }
                
                List<SVMXC__GetPrice_Fields__c> existingFieldList = [SELECT Id FROM SVMXC__GetPrice_Fields__c where NAME in : fieldNameList];
                if(existingFieldList != null && existingFieldList.size() > 0){
                    delete existingFieldList;
                }
                else{
                    seedLog += System.now()+' Get Price Fields not available in org \n';
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( priceFieldList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert priceFieldList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else{
                installStatus = false;
                seedLog += System.now()+' Get Price Fields Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Get Price Fields \n\n';    
            System.debug('End of Processing Get Price Fields');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Get Price Fields : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Get Price Fields : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Get Price Fields');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2290
    * This method will update the new trigger control values based on old trigger values
    */
    public static boolean processManagedTrigger() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
        	System.debug('Started Processing Trigger Control');
            seedLog += System.now()+' Started Processing Trigger Control \n';
            SVMXC__ServiceMax_Properties__c triggerProperty = SVMXC__ServiceMax_Properties__c.getValues('TriggerControl');
            savePoint = Database.setSavepoint();
            if(!isFreshInstall && triggerProperty == null){
                SVMXC__ServiceMax_Property_Elements__c caseProperty = SVMXC__ServiceMax_Property_Elements__c.getValues('PELE528');
                SVMXC__ServiceMax_Property_Elements__c workOrderProperty = SVMXC__ServiceMax_Property_Elements__c.getValues('PELE565');
                List<SVMXC__SM_ServiceMax_Trigger_Control__c> triggerControlList = new List<SVMXC__SM_ServiceMax_Trigger_Control__c>();
                if(caseProperty != null){
                	SVMXC__SM_ServiceMax_Trigger_Control__c caseControl = SVMXC__SM_ServiceMax_Trigger_Control__c.getInstance('Case');
                	boolean isCaseEnabled = caseProperty.SVMXC__Element_Value__c == 'ENABLED' ? true : false;
            		SVMXC__SM_ServiceMax_Trigger_Control__c caseTriggerControl = new SVMXC__SM_ServiceMax_Trigger_Control__c();
                	if(caseControl != null){
                		caseTriggerControl.Id = caseControl.Id;
                		caseTriggerControl.SVMXC__SM_Is_Enabled__c = isCaseEnabled;
                	}
                	else{
                		caseTriggerControl.Name = 'Case';
                		caseTriggerControl.SVMXC__SM_Object_Name__c = 'Case';
                		caseTriggerControl.SVMXC__SM_Is_Enabled__c = isCaseEnabled;
                	}
                    if(!isCaseEnabled){
                        caseTriggerControl.SVMXC__SM_Type__c = 'Global';
                    }
            		triggerControlList.add(caseTriggerControl);
                }
                if(workOrderProperty != null){
                	SVMXC__SM_ServiceMax_Trigger_Control__c workOrderControl = SVMXC__SM_ServiceMax_Trigger_Control__c.getInstance('SVMXC__Service_Order__c');
                	boolean isWorkOrderEnabled = workOrderProperty.SVMXC__Element_Value__c == 'ENABLED' ? true : false;
            		SVMXC__SM_ServiceMax_Trigger_Control__c workOrderTriggerControl = new SVMXC__SM_ServiceMax_Trigger_Control__c();
                	if(workOrderControl != null){
                		workOrderTriggerControl.Id = workOrderControl.Id;
                		workOrderTriggerControl.SVMXC__SM_Is_Enabled__c = isWorkOrderEnabled;
                	}
                	else{
                		workOrderTriggerControl.Name = 'SVMXC__Service_Order__c';
                		workOrderTriggerControl.SVMXC__SM_Object_Name__c = 'SVMXC__Service_Order__c';
                		workOrderTriggerControl.SVMXC__SM_Is_Enabled__c = isWorkOrderEnabled;
                	}
                    if(!isWorkOrderEnabled){
                        workOrderTriggerControl.SVMXC__SM_Type__c = 'Global';
                    }
            		triggerControlList.add(workOrderTriggerControl);
                }
                
                if(triggerControlList.size() > 0){
                	if( COMM_SecurityUtils.getInstance().verifyFieldAccess( triggerControlList, COMM_SecurityUtils.Access.Upsertable ) ) {
	                    upsert triggerControlList;
	                } else {
	                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
	                }
                }
                
                List<SVMXC__ServiceMax_Properties__c> customSettingList = new List<SVMXC__ServiceMax_Properties__c>();
                SVMXC__ServiceMax_Properties__c customSetting = new SVMXC__ServiceMax_Properties__c();
                customSetting.Name = 'TriggerControl';
                customSetting.SVMXC__Key__c = 'TriggerControl';
                customSetting.SVMXC__Value__c = 'Updated';
                customSettingList.add(customSetting);
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( customSettingList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert customSettingList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else{
            	seedLog += System.now()+' Trigger Control updation already processed \n';
            }
            seedLog += System.now()+' End of Processing Trigger Control \n\n';    
            System.debug('End of Processing Trigger Control');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Trigger Control : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Trigger Control : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Trigger Control');
        return installStatus;
    }
    
    /**
    *Story : BAC-5178
    * This method will process IOT Configuration
    */
    public static boolean processIOTConfiguration() {
        boolean installStatus = true;
        Savepoint savePoint = null;
        try{
        	System.debug('Started Processing IOT Configuration');
            seedLog += System.now()+' Started Processing IOT Configuration \n';
            if(Test.isRunningTest()){
                iotConfigurationJson = '{"iotconfiguration":[{"SVMXC_Contents_c":"{\'eventName\':\'CreateCase\',\'className\':\'CreateCase\'}","SVMXC_Name_c":"CreateCase","SVMXC_Type_c":"Event","SVMXC_IsStandard_c":"True"}]}';
            }
            if(iotConfigurationJson != null && !String.isBlank(iotConfigurationJson)){
                savePoint = Database.setSavepoint();
            	
            	//fetch existing iotconfiguration
                List<SVMXC__IOTConfiguration__c> existingIot = [SELECT Id,SVMXC__Name__c FROM SVMXC__IOTConfiguration__c WHERE SVMXC__Is_Standard__c = true AND SVMXC__Type__c = 'Event'];
                Map<String, String> existingMap = new Map<String, String>();
                if(existingIot != null && existingIot.size() > 0){
                    for(SVMXC__IOTConfiguration__c iotData : existingIot){
                        existingMap.put(iotData.SVMXC__Name__c, iotData.Id);
                    }
                }
                
                TOOL_SeedWrapper.IOTConfiguration iotDetails = (TOOL_SeedWrapper.IOTConfiguration)System.JSON.deserialize(iotConfigurationJson.trim(), TOOL_SeedWrapper.IOTConfiguration.class);
                seedLog += System.now()+' Processed IOT Configuration Json Content \n';
                List<SVMXC__IOTConfiguration__c> iotConfigurationList = new List<SVMXC__IOTConfiguration__c>();
                for(TOOL_SeedWrapper.IOTData iotJsonData : iotDetails.iotConfiguration){
                	SVMXC__IOTConfiguration__c iotConfigurationData = new SVMXC__IOTConfiguration__c();
                	if(existingMap.size() > 0 && existingMap.containsKey(iotJsonData.SVMXC_Name_c)){
                		iotConfigurationData.Id = existingMap.get(iotJsonData.SVMXC_Name_c);
                		iotConfigurationData.SVMXC__Contents__c = iotJsonData.SVMXC_Contents_c.replaceAll('\'','\"');
                		iotConfigurationData.SVMXC__Type__c = iotJsonData.SVMXC_Type_c;
                	}
                	else{
                		iotConfigurationData.SVMXC__Name__c = iotJsonData.SVMXC_Name_c;
                		iotConfigurationData.SVMXC__Contents__c = iotJsonData.SVMXC_Contents_c.replaceAll('\'','\"');
                		iotConfigurationData.SVMXC__Type__c = iotJsonData.SVMXC_Type_c;
                		iotConfigurationData.SVMXC__Is_Standard__c = Boolean.valueOf(iotJsonData.SVMXC_IsStandard_c);
                	}
            		iotConfigurationList.add(iotConfigurationData);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( iotConfigurationList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert iotConfigurationList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else{
            	installStatus = false;
                seedLog += System.now()+' IOT Configuration Json is empty \n';
            }
            seedLog += System.now()+' End of Processing IOT Configuration \n\n';
            System.debug('End of Processing IOT Configuration');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing IOT Configuration : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing IOT Configuration : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'IOT Configuration');
        return installStatus;  
    }
    
     /**
    *Story : TOOL-2198
    * This method will process Offline profiles
    */
    public static boolean processOfflineProfile() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	  System.debug('Started Processing Offline Profiles');
	          seedLog += System.now()+' Started Processing Offline Profiles \n';
	          if(Test.isRunningTest()){
	          	offlineProfileJson = '{"profiles":[{"SVMXC_PROFILE_NAME_C":"Default","SVMXC_DESCRIPTION_C":"This is the default offline profile automatically loaded when ServiceMax Offline is installed. In order to configure ServiceMax Offline Client for your organization, clone this profile using a name you can easily identify and modify the cloned profile.","SVMXC_CONFIGURATION_TYPE_C":"Global","SVMXC_ACTIVE_C":"True","SVMXC_ISDEFAULT_C":"True","SVMXC_Enable_Calendar_c":"True"}]}';
	          }
	          
	          if(offlineProfileJson != null && !String.isBlank(offlineProfileJson)){
	          	savePoint = Database.setSavepoint();
                List<RecordType> configRecordTypeList = [Select Id,Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name in ('Offline Profile','Configuration Access')];
                
                if(configRecordTypeList != null && configRecordTypeList.size() > 0){
                	String offlineRecordTypeId = null;
                	String accessRecordTypeId = null;
                	for(RecordType recordType : configRecordTypeList){
                		if('Offline Profile'.equals(recordType.Name)){
                			offlineRecordTypeId = recordType.Id;
                		}
                		else{
                			accessRecordTypeId = recordType.Id;
                		}
                	}
	                TOOL_SeedWrapper.Profile offlineProfileContent =  (TOOL_SeedWrapper.Profile)System.JSON.deserialize(offlineProfileJson.trim(), TOOL_SeedWrapper.Profile.class);
	                seedLog += System.now()+' Processed Offline Profile Json \n';
	                
	                List<SVMXC__ServiceMax_Config_Data__c> existingProfileList = [SELECT Id,SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Offline Profile' and SVMXC__Profile_Name__c = 'Default'];
	                Map<String, String> profileMap = new Map<String, String>();
	                for(SVMXC__ServiceMax_Config_Data__c profileConfigData : existingProfileList){
	                    profileMap.put(profileConfigData.SVMXC__Profile_Name__c, profileConfigData.Id);
	                }
	                
	                List<SVMXC__ServiceMax_Config_Data__c> offlineProfileList = new List<SVMXC__ServiceMax_Config_Data__c>();
	                boolean isUpdate = false;
	                for(TOOL_SeedWrapper.ProfileData profiledata : offlineProfileContent.profiles) {
	                    String profileName = profiledata.SVMXC_PROFILE_NAME_C;
	                    SVMXC__ServiceMax_Config_Data__c offlineProfileData = new SVMXC__ServiceMax_Config_Data__c();
	                    if(profileMap.size() > 0 && profileMap.containsKey(profileName)) {
	                        offlineProfileData.Id = profileMap.get(profileName);
	                        offlineProfileData.SVMXC__DESCRIPTION__C = profiledata.SVMXC_DESCRIPTION_C;
	                        isUpdate = true;
	                    }
	                    else {
	                        offlineProfileData.SVMXC__PROFILE_NAME__C = profiledata.SVMXC_PROFILE_NAME_C;
	                        offlineProfileData.SVMXC__DESCRIPTION__C = profiledata.SVMXC_DESCRIPTION_C;
	                        offlineProfileData.SVMXC__CONFIGURATION_TYPE__C = profiledata.SVMXC_CONFIGURATION_TYPE_C;
	                        offlineProfileData.SVMXC__ACTIVE__C = Boolean.valueOf(profiledata.SVMXC_ACTIVE_C);
	                        offlineProfileData.SVMXC__ISDEFAULT__C = Boolean.valueOf(profiledata.SVMXC_ISDEFAULT_C);
	                        offlineProfileData.SVMXC__Enable_Calendar__c = Boolean.valueOf(profiledata.SVMXC_Enable_Calendar_c);
	                        offlineProfileData.RecordTypeId = offlineRecordTypeId;
	                        offlineProfileData.SVMXC__INSTALLATION_KEY__C = seedKey;
	                    }
	                    offlineProfileList.add(offlineProfileData);
	                }
	
	                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( offlineProfileList, COMM_SecurityUtils.Access.Upsertable ) ) {
	                    upsert offlineProfileList;
	                } else {
	                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
	                }
	                
	                //offline profile access
	                List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                	List<SVMXC__ServiceMax_Config_Data__c> existingOfflineProfileList = [SELECT Id,SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Offline Profile' and SVMXC__Profile_Name__c = 'Default'];
	                if(!isUpdate && profileList != null && profileList.size() > 0 && existingOfflineProfileList != null && existingOfflineProfileList.size() > 0){
	                	SVMXC__SERVICEMAX_CONFIG_DATA__C offlineProfileAccess = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
	                	offlineProfileAccess.SVMXC__ACCESS_CONFIGURATION_PROFILE__C = existingOfflineProfileList[0].Id;
	                	offlineProfileAccess.SVMXC__PROFILE__C = profileList[0].Id;
	                	offlineProfileAccess.SVMXC__INSTALLATION_KEY__C = seedKey;
	                	offlineProfileAccess.RecordTypeId = accessRecordTypeId;
	                	
	                	List<SVMXC__ServiceMax_Config_Data__c> offlineProfileAccessList = new List<SVMXC__ServiceMax_Config_Data__c>();
	                	offlineProfileAccessList.add(offlineProfileAccess);
	                	
	                	if( COMM_SecurityUtils.getInstance().verifyFieldAccess( offlineProfileAccessList, COMM_SecurityUtils.Access.Createable ) ) {
		                    insert offlineProfileAccessList;
		                } else {
		                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
		                }
	                }
                }
          }
          else{
                installStatus = false;
                seedLog += System.now()+'Offline Profile Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Offline Profiles \n\n';
            System.debug('End of Processing Offline Profiles');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Offline Profiles : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Offline Profiles : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Offline Profiles');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Inventory Processes
    */
    public static boolean processInventoryProcesses() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Inventory Processes');
	    	seedLog += System.now()+' Started Processing Inventory Processes \n';
			if(Test.isRunningTest()){
				inventoryProcessJson = '{"inventoryprocess":[{"SVMXC_PROCESSID_C":"CASETEST001","SVMXC_MODULE_C":"PORD","SVMXC_SUBMODULE_C":"PORD007","SVMXC_NAME_C":"Process Shipments (Basic) for Shipment Order","SVMXC_DESCRIPTION_C":"This functionality displays a list of pending items to be shipped on a shipment order, allows user to enter ship quantity and/or short-close remaining lines.","SVMXC_ISSTANDARD_C":"True","SVMXC_PARENT_OBJECT_CRITERIA_C":"SVMXC__Order_Status__c=\'Open\'","SVMXC_CHILD_OBJECT_CRITERIA_C":"SVMXC__Line_Status__c=\'Open\'","SVMXC_Tag_Keys_c":"PROCESS_SHIPMENTS_(BASIC)_FOR_SHIPMENT_ORDER;PORD007_DESC;THIS_PARTS_ORDER_HAS_BEEN_CLOSED_OR_CANCELED.;NO_OPEN_LINES_AVAILABLE_IN_THIS_PARTS_ORDER.;","SVMXC_Parent_Error_Msg_c":"This Parts Order has been closed or canceled.","SVMXC_Child_Error_Msg_c":"No open lines available in this parts order."},{"SVMXC_PROCESSID_C":"CASETEST002","SVMXC_MODULE_C":"PORD","SVMXC_SUBMODULE_C":"PORD007","SVMXC_NAME_C":"Process Shipments (Basic) for Shipment Order","SVMXC_DESCRIPTION_C":"This functionality displays a list of pending items to be shipped on a shipment order, allows user to enter ship quantity and/or short-close remaining lines.","SVMXC_ISSTANDARD_C":"True","SVMXC_PARENT_OBJECT_CRITERIA_C":"SVMXC__Order_Status__c=\'Open\'","SVMXC_CHILD_OBJECT_CRITERIA_C":"SVMXC__Line_Status__c=\'Open\'","SVMXC_Tag_Keys_c":"PROCESS_SHIPMENTS_(BASIC)_FOR_SHIPMENT_ORDER;PORD007_DESC;THIS_PARTS_ORDER_HAS_BEEN_CLOSED_OR_CANCELED.;NO_OPEN_LINES_AVAILABLE_IN_THIS_PARTS_ORDER.;","SVMXC_Parent_Error_Msg_c":"This Parts Order has been closed or canceled.","SVMXC_Child_Error_Msg_c":"No open lines available in this parts order."}]}';
			}
			savePoint = Database.setSavepoint();  
			if(inventoryProcessJson != null && !String.isBlank(inventoryProcessJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Inventory Process'];
				TOOL_SeedWrapper.InventoryProcess inventoryProcessDetails = (TOOL_SeedWrapper.InventoryProcess)System.JSON.deserialize(inventoryProcessJson.trim(), TOOL_SeedWrapper.InventoryProcess.class);
                seedLog += System.now()+' Processed Inventory Processes Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingInventoryList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Inventory Process' and SVMXC__ISSTANDARD__C = true];
                Map<String, String> inventoryMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C inventoryData : existingInventoryList){
                    inventoryMap.put(inventoryData.SVMXC__ProcessID__c, inventoryData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> inventoryProcessList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.InventoryProcessData inventoryJsonData : inventoryProcessDetails.inventoryprocess){
                	SVMXC__SERVICEMAX_PROCESSES__C processData = new SVMXC__SERVICEMAX_PROCESSES__C();
                    if(inventoryMap.size() > 0 && inventoryMap.containsKey(inventoryJsonData.SVMXC_ProcessID_c)) {
                    	processData.Id = inventoryMap.get(inventoryJsonData.SVMXC_ProcessID_c);
                    	processData.SVMXC__MODULE__C = moduleMap.get(inventoryJsonData.SVMXC_MODULE_C);
                    	processData.SVMXC__SUBMODULE__C = subModuleMap.get(inventoryJsonData.SVMXC_SUBMODULE_C);
                    	processData.SVMXC__NAME__C = inventoryJsonData.SVMXC_NAME_C;
                    	processData.SVMXC__DESCRIPTION__C = inventoryJsonData.SVMXC_DESCRIPTION_C;
                    	processData.SVMXC__PARENT_OBJECT_CRITERIA__C = inventoryJsonData.SVMXC_PARENT_OBJECT_CRITERIA_C;
                    	processData.SVMXC__CHILD_OBJECT_CRITERIA__C = inventoryJsonData.SVMXC_CHILD_OBJECT_CRITERIA_C;
                    	processData.SVMXC__Parent_Error_Msg__c = inventoryJsonData.SVMXC_Parent_Error_Msg_c;
                    	processData.SVMXC__Child_Error_Msg__c = inventoryJsonData.SVMXC_Child_Error_Msg_c;
                    	processData.SVMXC__INSTALLATION_KEY__C = seedKey;
                        processData.SVMXC__IsStandard__c = Boolean.valueOf(inventoryJsonData.SVMXC_ISSTANDARD_C);
                    	processData.SVMXC__Tag_Keys__c = inventoryJsonData.SVMXC_Tag_Keys_c;
                    }
                    else{
                    	processData.SVMXC__ProcessID__c = inventoryJsonData.SVMXC_PROCESSID_C;
                    	processData.SVMXC__MODULE__C = moduleMap.get(inventoryJsonData.SVMXC_MODULE_C);
                    	processData.SVMXC__SUBMODULE__C = subModuleMap.get(inventoryJsonData.SVMXC_SUBMODULE_C);
                    	processData.SVMXC__NAME__C = inventoryJsonData.SVMXC_NAME_C;
                    	processData.SVMXC__DESCRIPTION__C = inventoryJsonData.SVMXC_DESCRIPTION_C;
                    	processData.SVMXC__PARENT_OBJECT_CRITERIA__C = inventoryJsonData.SVMXC_PARENT_OBJECT_CRITERIA_C;
                    	processData.SVMXC__CHILD_OBJECT_CRITERIA__C = inventoryJsonData.SVMXC_CHILD_OBJECT_CRITERIA_C;
                    	processData.SVMXC__Parent_Error_Msg__c = inventoryJsonData.SVMXC_Parent_Error_Msg_c;
                    	processData.SVMXC__Child_Error_Msg__c = inventoryJsonData.SVMXC_Child_Error_Msg_c;
                    	processData.SVMXC__INSTALLATION_KEY__C = seedKey;
                    	processData.SVMXC__Tag_Keys__c = inventoryJsonData.SVMXC_Tag_Keys_c;
                        processData.SVMXC__IsStandard__c = Boolean.valueOf(inventoryJsonData.SVMXC_ISSTANDARD_C);
                    	processData.RecordTypeId = processRecordType.Id;
                    }
                    inventoryProcessList.add(processData);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( inventoryProcessList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert inventoryProcessList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
	    	else{
                installStatus = false;
                seedLog += System.now()+' Inventory Process Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Inventory Processes \n\n';
            System.debug('End of Processing Inventory Processes');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Inventory Processes : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Inventory Processes : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Inventory Processes');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Inventory Expression
    */
    public static boolean processInventoryExpression() {
        boolean installStatus = true;
	    Savepoint savePoint = null;
        try {
            System.debug('Started Processing Inventory Expressions');
	    	seedLog += System.now()+' Started Processing Inventory Expressions \n';
			if(Test.isRunningTest()){
				inventoryExpressionJson = '{"inventoryexpression":[{"SVMXC_INVENTORY_PROCESS_C":"CASETEST001","SVMXC_EXPRESSION_TYPE_C":"INV_Header_Closure_Action","SVMXC_SEQUENCE_C":"1","SVMXC_OBJECT_NAME_C":"","SVMXC_FKey_Name_Field_c":"","SVMXC_FIELD_NAME_C":"SVMXC__Closed_On__c","SVMXC_Display_Type_c":"DATETIME","SVMXC_OPERATOR_C":"eq","SVMXC_OPERAND_C":"SVMX.NOW","SVMXC_Lookup_Field_API_Name_c":""}]}';
			}
			savePoint = Database.setSavepoint();  
            if(inventoryExpressionJson != null && !String.isBlank(inventoryExpressionJson)){
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'Expressions'];
                TOOL_SeedWrapper.InventoryExpression inventoryExpressionDetails = (TOOL_SeedWrapper.InventoryExpression)System.JSON.deserialize(inventoryExpressionJson.trim(), TOOL_SeedWrapper.InventoryExpression.class);
                seedLog += System.now()+' Processed Inventory Expression Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingInventoryList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Inventory Process' and SVMXC__ISSTANDARD__C = true];
                Map<String, String> inventoryMap = new Map<String, String>();
                List<String> inventoryList = new List<String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C inventoryData : existingInventoryList){
                    inventoryList.add(inventoryData.Id);
                    inventoryMap.put(inventoryData.SVMXC__ProcessID__c, inventoryData.Id);
                }
                
                if(inventoryList.size() > 0){
                    List<SVMXC__SERVICEMAX_CONFIG_DATA__C> existingInventoryExpList = [SELECT Id FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE RecordType.Name = 'Expressions' AND SVMXC__INVENTORY_PROCESS__C IN : inventoryList];
                    if(existingInventoryExpList != null && existingInventoryExpList.size() > 0){
                        delete existingInventoryExpList;
                    }
                    
                    List<SVMXC__SERVICEMAX_CONFIG_DATA__C> inventoryExpressionList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
                    for(TOOL_SeedWrapper.InventoryExpressionData expressionJsonData : inventoryExpressionDetails.inventoryexpression){
                        SVMXC__SERVICEMAX_CONFIG_DATA__C inventoryExpression = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
                        inventoryExpression.SVMXC__INVENTORY_PROCESS__C = inventoryMap.get(expressionJsonData.SVMXC_INVENTORY_PROCESS_C);
                        inventoryExpression.SVMXC__EXPRESSION_TYPE__C = expressionJsonData.SVMXC_EXPRESSION_TYPE_C;
                        inventoryExpression.SVMXC__SEQUENCE__C = Decimal.valueOf(expressionJsonData.SVMXC_SEQUENCE_C);
                        inventoryExpression.SVMXC__OBJECT_NAME__C = expressionJsonData.SVMXC_OBJECT_NAME_C;
                        inventoryExpression.SVMXC__FKey_Name_Field__c = expressionJsonData.SVMXC_FKey_Name_Field_c;
                        inventoryExpression.SVMXC__FIELD_NAME__C = expressionJsonData.SVMXC_FIELD_NAME_C;
                        inventoryExpression.SVMXC__Display_Type__c = expressionJsonData.SVMXC_Display_Type_c;
                        inventoryExpression.SVMXC__OPERATOR__C = expressionJsonData.SVMXC_OPERATOR_C;
                        inventoryExpression.SVMXC__OPERAND__C = expressionJsonData.SVMXC_OPERAND_C;
                        inventoryExpression.SVMXC__Lookup_Field_API_Name__c = expressionJsonData.SVMXC_Lookup_Field_API_Name_c;
                        inventoryExpression.RecordTypeId = processRecordType.Id;
                        inventoryExpression.SVMXC__Installation_Key__c = seedKey;
						inventoryExpressionList.add(inventoryExpression);
                    }
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( inventoryExpressionList, COMM_SecurityUtils.Access.Createable ) ) {
	                    insert inventoryExpressionList;
	                } else {
	                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
	                }
                }
            }
            else{
                installStatus = false;
                seedLog += System.now()+' Inventory Expression Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Inventory Expression \n\n';
            System.debug('End of Processing Inventory Expression');
        }
        catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Inventory Expressions : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Inventory Expressions : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Inventory Expressions');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Optimax Custom Settings
    */
    public static boolean processOptimaxCustomSetting() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Optimax Custom Settings');
	    	seedLog += System.now()+' Started Processing Optimax Custom Settings \n';
			if(Test.isRunningTest()){
				optimaxSettingJson = '{"customsetting":[{"Name":"1","SVMXC_Source_Key_c":"Custom","SVMXC_Source_Type_c":"SVMXC__Optimization_Goals__c","SVMXC_Target_Key_c":"SVMXC__Weight_Node_Type__c","SVMXC_Target_Value_c":"0"},{"Name":"2","SVMXC_Source_Key_c":"Custom","SVMXC_Source_Type_c":"SVMXC__Optimization_Goals__c","SVMXC_Target_Key_c":"SVMXC__Weight_Route_Distance__c","SVMXC_Target_Value_c":"0"}]}';
			}
			savePoint = Database.setSavepoint();  
			if(optimaxSettingJson != null && !String.isBlank(optimaxSettingJson)){
				TOOL_SeedWrapper.OptimaxCustomSetting optimaxSettingDetails = (TOOL_SeedWrapper.OptimaxCustomSetting)System.JSON.deserialize(optimaxSettingJson.trim(), TOOL_SeedWrapper.OptimaxCustomSetting.class);
                seedLog += System.now()+' Processed Optimax Custom Settings Json Content \n';
                
                Map<String, String> existingSettingMap = new Map<String, String>();
                
                for(SVMXC__Field_Default_Rules__c rule : SVMXC__Field_Default_Rules__c.getall().values()){
					existingSettingMap.put(rule.Name, rule.Id);
				}
                
                List<SVMXC__Field_Default_Rules__c> fieldRuleList = new List<SVMXC__Field_Default_Rules__c>();
                for(TOOL_SeedWrapper.OptimaxSettingData fieldRule : optimaxSettingDetails.customsetting){
                	SVMXC__Field_Default_Rules__c fieldRuleData = new SVMXC__Field_Default_Rules__c();
                    if(existingSettingMap.size() > 0 && existingSettingMap.containsKey(fieldRule.Name)) {
                    	fieldRuleData.Id = existingSettingMap.get(fieldRule.Name);
                    	fieldRuleData.SVMXC__Source_Key__c = fieldRule.SVMXC_Source_Key_c;
                    	fieldRuleData.SVMXC__Source_Type__c = fieldRule.SVMXC_Source_Type_c;
                    	fieldRuleData.SVMXC__Target_Key__c = fieldRule.SVMXC_Target_Key_c;
                    	fieldRuleData.SVMXC__Target_Value__c = fieldRule.SVMXC_Target_Value_c;
                    }
                    else{
                    	fieldRuleData.Name = fieldRule.Name;
                    	fieldRuleData.SVMXC__Source_Key__c = fieldRule.SVMXC_Source_Key_c;
                    	fieldRuleData.SVMXC__Source_Type__c = fieldRule.SVMXC_Source_Type_c;
                    	fieldRuleData.SVMXC__Target_Key__c = fieldRule.SVMXC_Target_Key_c;
                    	fieldRuleData.SVMXC__Target_Value__c = fieldRule.SVMXC_Target_Value_c;
                    }
                    fieldRuleList.add(fieldRuleData);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( fieldRuleList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert fieldRuleList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Optimax Custom Settings Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Optimax Custom Settings \n\n';
            System.debug('End of Processing Optimax Custom Settings');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Optimax Custom Settings : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Optimax Custom Settings : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Optimax Custom Settings');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Named Expressions
    */
    public static boolean processNamedExpressions() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Named Expressions');
	    	seedLog += System.now()+' Started Processing Named Expressions \n';
			if(Test.isRunningTest()){
				expressionJson = '{"expression":[{"RecordTypeName":"SVMX Rule","SVMXC_Rule_Type_c":"Named Expression","SVMXC_Source_Object_Name_c":"SVMXC__Service_Order__c","SVMXC_ProcessID_c":"EXPR060","SVMXC_NAME_C":"SVMXSTD: Closed Work Orders","SVMXC_DESCRIPTION_C":"Expression to select Closed Work Order only","SVMXC_ISSTANDARD_C":"True","SVMXC_Advance_Expression_c":"","SVMXC_Parent_Object_Criteria_c":"SVMXC__Order_Status__c=\'Closed\'"},{"RecordTypeName":"SVMX Rule","SVMXC_Rule_Type_c":"Named Expression","SVMXC_Source_Object_Name_c":"SVMXC__Service_Order__c","SVMXC_ProcessID_c":"EXPR071","SVMXC_NAME_C":"SVMXSTD: Closed Work Orders","SVMXC_DESCRIPTION_C":"Expression to select Closed Work Order only","SVMXC_ISSTANDARD_C":"True","SVMXC_Advance_Expression_c":"","SVMXC_Parent_Object_Criteria_c":"SVMXC__Order_Status__c=\'Closed\'"}]}';
			}
			savePoint = Database.setSavepoint();
			if(expressionJson != null && !String.isBlank(expressionJson)){
				String parentErrorMessage = 'This record does not meet the qualification criteria for this SFM Transaction';
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'SVMX RULE'];
				TOOL_SeedWrapper.NamedExpression namedExpressionData = (TOOL_SeedWrapper.NamedExpression)System.JSON.deserialize(expressionJson.trim(), TOOL_SeedWrapper.NamedExpression.class);
                seedLog += System.now()+' Processed Named Expressions Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingExpressionList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'SVMX RULE' and SVMXC__ProcessID__c IN ('EXPR060','EXPR071','EXPR076','EXPR077','EXPR005','EXPR052','EXPR010','EXPR011','EXPR012','EXPR053','EXPR054') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> expressionMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C expressionData : existingExpressionList){
                    expressionMap.put(expressionData.SVMXC__ProcessID__c, expressionData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> expressionList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.ExpressionData expressionJsonData : namedExpressionData.expression){
                	SVMXC__SERVICEMAX_PROCESSES__C expression = new SVMXC__SERVICEMAX_PROCESSES__C();
                    System.debug('Named Expressions SeedKey - '+seedKey);
                	if(expressionMap.size() > 0 && expressionMap.containsKey(expressionJsonData.SVMXC_ProcessID_c)) {
                		expression.Id = expressionMap.get(expressionJsonData.SVMXC_ProcessID_c);
                		expression.SVMXC__DESCRIPTION__C = expressionJsonData.SVMXC_DESCRIPTION_C;
                		expression.SVMXC__Source_Object_Name__c = expressionJsonData.SVMXC_Source_Object_Name_c;
                		expression.SVMXC__Advance_Expression__c = expressionJsonData.SVMXC_Advance_Expression_c;
                		expression.SVMXC__Parent_Object_Criteria__c = expressionJsonData.SVMXC_Parent_Object_Criteria_c;
                		expression.SVMXC__ISSTANDARD__C = Boolean.valueOf(expressionJsonData.SVMXC_ISSTANDARD_C);
                		expression.SVMXC__INSTALLATION_KEY__C = seedKey;
                		expression.SVMXC__Rule_Type__c = expressionJsonData.SVMXC_Rule_Type_c;
                		expression.SVMXC__NAME__C = expressionJsonData.SVMXC_NAME_C;
                		expression.SVMXC__Parent_Error_Msg__c = parentErrorMessage;
                        expression.RecordTypeId = processRecordType.Id;
                	}
                	else{
                		expression.SVMXC__NAME__C = expressionJsonData.SVMXC_NAME_C;
                		expression.SVMXC__ProcessID__c = expressionJsonData.SVMXC_ProcessID_c;
                		expression.SVMXC__DESCRIPTION__C = expressionJsonData.SVMXC_DESCRIPTION_C;
                		expression.SVMXC__Source_Object_Name__c = expressionJsonData.SVMXC_Source_Object_Name_c;
                		expression.SVMXC__Advance_Expression__c = expressionJsonData.SVMXC_Advance_Expression_c;
                		expression.SVMXC__Parent_Object_Criteria__c = expressionJsonData.SVMXC_Parent_Object_Criteria_c;
                		expression.SVMXC__ISSTANDARD__C = Boolean.valueOf(expressionJsonData.SVMXC_ISSTANDARD_C);
                		expression.SVMXC__INSTALLATION_KEY__C = seedKey;
                		expression.SVMXC__Rule_Type__c = expressionJsonData.SVMXC_Rule_Type_c;
                		expression.SVMXC__Parent_Error_Msg__c = parentErrorMessage;
                		expression.RecordTypeId = processRecordType.Id;
                	}
                	expressionList.add(expression);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( expressionList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert expressionList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Named Expressions Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Named Expressions \n\n';
            System.debug('End of Processing Named Expressions');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Named Expressions : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Named Expressions : ' + e.getMessage() + 'Error Type : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Named Expressions');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Expression Detail
    */
    public static boolean processExpressionDetail() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Expression Detail');
	    	seedLog += System.now()+' Started Processing Expression Detail \n';
			if(Test.isRunningTest()){
				expressionDetailJson = '{"expressiondetail":[{"RecordTypeName":"Expressions","SVMXC_Expression_Rule_c":"EXPR060","SVMXC_Expression_Type_c":"EXP_Named","SVMXC_Sequence_c":"1","SVMXC_Field_Name_c":"SVMXC__Order_Status__c","SVMXC_Operator_c":"eq","SVMXC_Object_Name_c":"SVMXC__Service_Order__c","SVMXC_Operand_c":"Closed","SVMXC_Display_Type_c":"picklist","SVMXC_Object_Name2_c":"","SVMXC_FKey_Name_Field_c":"","SVMXC_Field_Relationship_Name_c":"","SVMXC_Parameter_Type_c":"","SVMXC_Internal_Value_c":"","SVMXC_Source_Field_Name_c":""}]}';
			}
			savePoint = Database.setSavepoint();
			if(expressionDetailJson != null && !String.isBlank(expressionDetailJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'Expressions'];
				TOOL_SeedWrapper.ExpressionDetail expressionDetailData = (TOOL_SeedWrapper.ExpressionDetail)System.JSON.deserialize(expressionDetailJson.trim(), TOOL_SeedWrapper.ExpressionDetail.class);
                seedLog += System.now()+' Processed Expression Detail Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingExpressionList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'SVMX RULE' and SVMXC__ProcessID__c IN ('EXPR060','EXPR071','EXPR076','EXPR077','EXPR005','EXPR052','EXPR010','EXPR011','EXPR012','EXPR053','EXPR054') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> expressionMap = new Map<String, String>();
                List<String> expressionList = new List<String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C expressionData : existingExpressionList){
                	expressionList.add(expressionData.Id);
                    expressionMap.put(expressionData.SVMXC__ProcessID__c, expressionData.Id);
                    aplExpressionMap.put(expressionData.SVMXC__ProcessID__c, expressionData.Id);
                }
                
                if(expressionList.size() > 0){
	                List<SVMXC__SERVICEMAX_CONFIG_DATA__C> existingExpressionDetailList = [SELECT Id FROM SVMXC__SERVICEMAX_CONFIG_DATA__C Where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c IN : expressionList];
                	if(existingExpressionDetailList != null && existingExpressionDetailList.size() > 0){
                		delete existingExpressionDetailList;
                	}
                	
                	List<SVMXC__SERVICEMAX_CONFIG_DATA__C> expressionDetailList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
	                for(TOOL_SeedWrapper.ExpressionDetailData expressionDetailJsonData : expressionDetailData.expressiondetail){
	                	SVMXC__SERVICEMAX_CONFIG_DATA__C expressionDetail = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
	                	expressionDetail.SVMXC__Expression_Rule__c = expressionMap.get(expressionDetailJsonData.SVMXC_Expression_Rule_c);
	                	expressionDetail.SVMXC__Field_Name__c = expressionDetailJsonData.SVMXC_Field_Name_c;
	                	expressionDetail.SVMXC__Operator__c = expressionDetailJsonData.SVMXC_Operator_c;
	                	expressionDetail.SVMXC__Operand__c = expressionDetailJsonData.SVMXC_Operand_c;
	                	expressionDetail.SVMXC__Sequence__c = Decimal.valueOf(expressionDetailJsonData.SVMXC_Sequence_c);
	                	expressionDetail.SVMXC__Expression_Type__c = expressionDetailJsonData.SVMXC_Expression_Type_c;
	                	expressionDetail.SVMXC__Object_Name__c = expressionDetailJsonData.SVMXC_Object_Name_c;
	                	expressionDetail.SVMXC__Display_Type__c = expressionDetailJsonData.SVMXC_Display_Type_c;
	                	expressionDetail.SVMXC__Object_Name2__c = expressionDetailJsonData.SVMXC_Object_Name2_c;
	                	expressionDetail.SVMXC__FKey_Name_Field__c = expressionDetailJsonData.SVMXC_FKey_Name_Field_c;
	                	expressionDetail.SVMXC__Field_Relationship_Name__c = expressionDetailJsonData.SVMXC_Field_Relationship_Name_c;
	                	expressionDetail.SVMXC__Parameter_Type__c = expressionDetailJsonData.SVMXC_Parameter_Type_c;
	                	expressionDetail.SVMXC__Internal_Value__c = expressionDetailJsonData.SVMXC_Internal_Value_c;
	                	expressionDetail.SVMXC__Source_Field_Name__c = expressionDetailJsonData.SVMXC_Source_Field_Name_c;
	                	expressionDetail.SVMXC__Installation_Key__c = seedKey;
	                	expressionDetail.RecordTypeId = processRecordType.Id;
		                expressionDetailList.add(expressionDetail);
	                }
	                
	                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( expressionDetailList, COMM_SecurityUtils.Access.Createable ) ) {
	                    insert expressionDetailList;
	                } else {
	                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
	                }
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Expression Detail Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Expression Detail \n\n';
            System.debug('End of Processing Expression Detail');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Expression Detail : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Expression Detail : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Expression Detail');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Object Mapping
    */
    public static boolean processObjectMapping() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Object Mapping');
	    	seedLog += System.now()+' Started Processing Object Mapping \n';
			if(Test.isRunningTest()){
				objectMappingJson = '{"objmapping":[{"SVMXC_MAPID_C":"MAP023","SVMXC_NAME_C":"SVMXSTD: Installed Product To Work Order","SVMXC_DESCRIPTION_C":"Field mapping to be used when Work Order is created from an Installed Product","SVMXC_SOURCE_OBJECT_NAME_C":"SVMXC__Installed_Product__c","SVMXC_TARGET_OBJECT_NAME_C":"SVMXC__Service_Order__c","SVMXC_TARGET_RECORD_TYPE_C":"","SVMXC_ISSTANDARD_C":"True","SVMXC_ACTIVE_C":"True"},{"SVMXC_MAPID_C":"MAP024","SVMXC_NAME_C":"SVMXSTD: Installed Product To Work Order","SVMXC_DESCRIPTION_C":"Field mapping to be used when Work Order is created from an Installed Product","SVMXC_SOURCE_OBJECT_NAME_C":"SVMXC__Installed_Product__c","SVMXC_TARGET_OBJECT_NAME_C":"SVMXC__Service_Order__c","SVMXC_TARGET_RECORD_TYPE_C":"","SVMXC_ISSTANDARD_C":"True","SVMXC_ACTIVE_C":"True"}]}';
			}
			savePoint = Database.setSavepoint();
			if(objectMappingJson != null && !String.isBlank(objectMappingJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'OBJECT MAPPING'];
				TOOL_SeedWrapper.ObjectMapping expressionData = (TOOL_SeedWrapper.ObjectMapping)System.JSON.deserialize(objectMappingJson.trim(), TOOL_SeedWrapper.ObjectMapping.class);
                seedLog += System.now()+' Processed Object Mapping Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingMappingList = [SELECT Id,SVMXC__MAPID__C from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'OBJECT MAPPING' and SVMXC__MAPID__C IN ('MAP023','MAP_TaskTemplateToTask','MAP_ReqPartstoWorkDet','LOC_MAP001','MAP007','APL_MAP001','MAP047','APL_MAP002','MAP041','MAP042') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> objectMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C mapData : existingMappingList){
                    objectMap.put(mapData.SVMXC__MAPID__C, mapData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> objectMapppingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.ObjectMapData mappingJsonData : expressionData.objmapping){
                	SVMXC__SERVICEMAX_PROCESSES__C objectMapping = new SVMXC__SERVICEMAX_PROCESSES__C();
                	if(objectMap.size() > 0 && objectMap.containsKey(mappingJsonData.SVMXC_MAPID_C)) {
                		objectMapping.Id = objectMap.get(mappingJsonData.SVMXC_MAPID_C);
                		objectMapping.SVMXC__NAME__C = mappingJsonData.SVMXC_NAME_C;
                		objectMapping.SVMXC__DESCRIPTION__C = mappingJsonData.SVMXC_DESCRIPTION_C;
                		objectMapping.SVMXC__ACTIVE__C = Boolean.valueOf(mappingJsonData.SVMXC_ACTIVE_C);
                		objectMapping.SVMXC__SOURCE_OBJECT_NAME__C = mappingJsonData.SVMXC_SOURCE_OBJECT_NAME_C;
                		objectMapping.SVMXC__TARGET_OBJECT_NAME__C = mappingJsonData.SVMXC_TARGET_OBJECT_NAME_C;
                		objectMapping.SVMXC__TARGET_RECORD_TYPE__C = mappingJsonData.SVMXC_TARGET_RECORD_TYPE_C;
                		objectMapping.RecordTypeId = processRecordType.Id;
                		objectMapping.SVMXC__Installation_Key__c = seedKey;
                	}
                	else{
                		objectMapping.SVMXC__MAPID__C = mappingJsonData.SVMXC_MAPID_C;
                		objectMapping.SVMXC__NAME__C = mappingJsonData.SVMXC_NAME_C;
                		objectMapping.SVMXC__DESCRIPTION__C = mappingJsonData.SVMXC_DESCRIPTION_C;
                		objectMapping.SVMXC__ACTIVE__C = Boolean.valueOf(mappingJsonData.SVMXC_ACTIVE_C);
                		objectMapping.SVMXC__SOURCE_OBJECT_NAME__C = mappingJsonData.SVMXC_SOURCE_OBJECT_NAME_C;
                		objectMapping.SVMXC__TARGET_OBJECT_NAME__C = mappingJsonData.SVMXC_TARGET_OBJECT_NAME_C;
                		objectMapping.SVMXC__TARGET_RECORD_TYPE__C = mappingJsonData.SVMXC_TARGET_RECORD_TYPE_C;
                		objectMapping.SVMXC__ISSTANDARD__C = Boolean.valueOf(mappingJsonData.SVMXC_ISSTANDARD_C);
                		objectMapping.RecordTypeId = processRecordType.Id;
                		objectMapping.SVMXC__Installation_Key__c = seedKey;
                	}
                	objectMapppingList.add(objectMapping);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objectMapppingList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert objectMapppingList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Object Mapping Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Object Mapping \n\n';
            System.debug('End of Processing Object Mapping');
	    }
    	catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Object Mapping : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Object Mapping : ' + e.getMessage() + 'Error Type : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Object Mapping');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process Field Mapping
    */
    public static boolean processFieldMapping() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Field Mapping');
	    	seedLog += System.now()+' Started Processing Field Mapping \n';
			if(Test.isRunningTest()){
				fieldMappingJson = '{"fieldmapping":[{"SVMXC_MAPID_C":"MAP023","SVMXC_SOURCE_FIELD_NAME_C":"SVMXC__Company__c","SVMXC_TARGET_FIELD_NAME_C":"SVMXC__Company__c","SVMXC_ACTIVE_C":"True","SVMXC_Parameter_Type_c":"","SVMXC_Display_Value_c":"","SVMXC_Preference_3_c":"","SVMXC_Configuration_Type_c":"Field Mapping","SVMXC_Preference_2_c":"","SVMXC_ISDEFAULT_C":"True"}]}';
			}
			savePoint = Database.setSavepoint();
			if(fieldMappingJson != null && !String.isBlank(fieldMappingJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'FIELD MAPPING'];
				TOOL_SeedWrapper.FieldMapping fieldMappingData = (TOOL_SeedWrapper.FieldMapping)System.JSON.deserialize(fieldMappingJson.trim(), TOOL_SeedWrapper.FieldMapping.class);
                seedLog += System.now()+' Processed Field Mapping Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingMappingList = [SELECT Id,SVMXC__MAPID__C from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'OBJECT MAPPING' and SVMXC__MAPID__C IN ('MAP023','MAP_TaskTemplateToTask','MAP_ReqPartstoWorkDet','LOC_MAP001','MAP007','APL_MAP001','MAP047','APL_MAP002','MAP041','MAP042') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> objectMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C mapData : existingMappingList){
                    objectMap.put(mapData.SVMXC__MAPID__C, mapData.Id);
                    aplObjectMap.put(mapData.SVMXC__MAPID__C, mapData.Id);
                }
                
            	List<SVMXC__SERVICEMAX_CONFIG_DATA__C> existingFieldMappingList = [SELECT Id,SVMXC__DISPLAY_MAP_ID__C,SVMXC__TARGET_FIELD_NAME__C FROM SVMXC__SERVICEMAX_CONFIG_DATA__C Where RecordType.Name = 'FIELD MAPPING' AND SVMXC__DISPLAY_MAP_ID__C IN ('MAP023','MAP_TaskTemplateToTask','MAP_ReqPartstoWorkDet','LOC_MAP001')];
            	Map<String, String> existingfieldMap = new Map<String, String>();
            	for(SVMXC__SERVICEMAX_CONFIG_DATA__C fieldMapData : existingFieldMappingList){
            		existingfieldMap.put(fieldMapData.SVMXC__DISPLAY_MAP_ID__C+fieldMapData.SVMXC__TARGET_FIELD_NAME__C, fieldMapData.Id);
            	}
            	
            	List<SVMXC__SERVICEMAX_CONFIG_DATA__C> fieldMappingList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
                for(TOOL_SeedWrapper.FieldMapData fieldMapJsonData : fieldMappingData.fieldmapping){
                	SVMXC__SERVICEMAX_CONFIG_DATA__C fieldMapping = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
                	if(existingfieldMap.size() > 0 && existingfieldMap.containsKey(fieldMapJsonData.SVMXC_MAPID_C+fieldMapJsonData.SVMXC_TARGET_FIELD_NAME_C)) {
                		fieldMapping.Id = existingfieldMap.get(fieldMapJsonData.SVMXC_MAPID_C+fieldMapJsonData.SVMXC_TARGET_FIELD_NAME_C);
                		fieldMapping.SVMXC__SOURCE_FIELD_NAME__C = fieldMapJsonData.SVMXC_SOURCE_FIELD_NAME_C;
                		fieldMapping.SVMXC__ACTIVE__C = Boolean.valueOf(fieldMapJsonData.SVMXC_ACTIVE_C);
                		fieldMapping.SVMXC__Preference_2__c = fieldMapJsonData.SVMXC_Preference_2_c;
                		fieldMapping.SVMXC__Preference_3__c = fieldMapJsonData.SVMXC_Preference_3_c;
                		fieldMapping.SVMXC__Configuration_Type__c = fieldMapJsonData.SVMXC_Configuration_Type_c;
                		fieldMapping.SVMXC__Display_Value__c = fieldMapJsonData.SVMXC_Display_Value_c;
                		fieldMapping.SVMXC__Parameter_Type__c = fieldMapJsonData.SVMXC_Parameter_Type_c;
                		fieldMapping.RecordTypeId = processRecordType.Id;
                		fieldMapping.SVMXC__Installation_Key__c = seedKey;
                	}
                	else{
                		fieldMapping.SVMXC__MAPID__C = objectMap.get(fieldMapJsonData.SVMXC_MAPID_C);
                		fieldMapping.SVMXC__SOURCE_FIELD_NAME__C = fieldMapJsonData.SVMXC_SOURCE_FIELD_NAME_C;
                		fieldMapping.SVMXC__TARGET_FIELD_NAME__C = fieldMapJsonData.SVMXC_TARGET_FIELD_NAME_C;
                		fieldMapping.SVMXC__ACTIVE__C = Boolean.valueOf(fieldMapJsonData.SVMXC_ACTIVE_C);
                		fieldMapping.SVMXC__ISDEFAULT__C = Boolean.valueOf(fieldMapJsonData.SVMXC_ISDEFAULT_C);
                		fieldMapping.SVMXC__Preference_2__c = fieldMapJsonData.SVMXC_Preference_2_c;
                		fieldMapping.SVMXC__Preference_3__c = fieldMapJsonData.SVMXC_Preference_3_c;
                		fieldMapping.SVMXC__Configuration_Type__c = fieldMapJsonData.SVMXC_Configuration_Type_c;
                		fieldMapping.SVMXC__Display_Value__c = fieldMapJsonData.SVMXC_Display_Value_c;
                		fieldMapping.SVMXC__Parameter_Type__c = fieldMapJsonData.SVMXC_Parameter_Type_c;
                		fieldMapping.RecordTypeId = processRecordType.Id;
                		fieldMapping.SVMXC__Installation_Key__c = seedKey;
                	}
                	fieldMappingList.add(fieldMapping);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( fieldMappingList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert fieldMappingList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Field Mapping Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Field Mapping \n\n';
            System.debug('End of Processing Field Mapping');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Field Mapping : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Field Mapping : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Field Mapping');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process WO Billing
    */
    public static boolean processWOBilling() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing WO Billing Process');
	    	seedLog += System.now()+' Started Processing WO Billing Process \n';
			if(Test.isRunningTest()){
				woBillingJson = '{"wobilling":[{"SVMXC_ProcessID_c":"PINV001_Work_Order","SVMXC_Name_c":"Sample Work Order Proforma Invoice Process","SVMXC_Description_c":"This process generates one proforma invoice for each closed work order.","SVMXC_Invoice_Scope_c":"Work Order","SVMXC_Module_c":"EXPR060","SVMXC_Submodule_c":"","SVMXC_Primary_Consolidation_Rule_c":"Per Record","SVMXC_Secondary_Consolidation_Rule_c":"","SVMXC_Tertiary_Consolidation_Rule_c":"","SVMXC_Include_Product_c":"True","SVMXC_Node_Parent_c":null,"SVMXC_Process_c":null,"SVMXC_Capture_Log_c":"False","SVMXC_Email_On_Success_c":"","SVMXC_Email_On_Error_c":"","SVMXC_IsStandard_c":"True","SVMXC_Active_c":"True"}]}';
			}
			savePoint = Database.setSavepoint();
			if(woBillingJson != null && !String.isBlank(woBillingJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'WORK ORDER BILLING PROCESS'];
				TOOL_SeedWrapper.WOBilling woBillingData = (TOOL_SeedWrapper.WOBilling)System.JSON.deserialize(woBillingJson.trim(), TOOL_SeedWrapper.WOBilling.class);
                seedLog += System.now()+' Processed WO Billing Process Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingBillingList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'WORK ORDER BILLING PROCESS' and SVMXC__ProcessID__c IN ('PINV001_Work_Order','PINV002_Case') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> woBillingMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C billingData : existingBillingList){
                    woBillingMap.put(billingData.SVMXC__ProcessID__c, billingData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingExpressionList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'SVMX RULE' and SVMXC__ProcessID__c IN ('EXPR060','EXPR071') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> expressionMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C expressionData : existingExpressionList){
                    expressionMap.put(expressionData.SVMXC__ProcessID__c, expressionData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> woBillingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.WOBillingData billingJsonData : woBillingData.wobilling){
                	SVMXC__SERVICEMAX_PROCESSES__C woBilling = new SVMXC__SERVICEMAX_PROCESSES__C();
                	if(woBillingMap.size() > 0 && woBillingMap.containsKey(billingJsonData.SVMXC_ProcessID_c)) {
                		woBilling.Id = woBillingMap.get(billingJsonData.SVMXC_ProcessID_c);
                		woBilling.SVMXC__Name__c = billingJsonData.SVMXC_Name_c;
                		woBilling.SVMXC__Description__c = billingJsonData.SVMXC_Description_c;
                		woBilling.SVMXC__Primary_Consolidation_Rule__c = billingJsonData.SVMXC_Primary_Consolidation_Rule_c;
                		woBilling.SVMXC__Secondary_Consolidation_Rule__c = billingJsonData.SVMXC_Secondary_Consolidation_Rule_c;
                		woBilling.SVMXC__Tertiary_Consolidation_Rule__c = billingJsonData.SVMXC_Tertiary_Consolidation_Rule_c;
                		woBilling.SVMXC__Include_Product__c = Boolean.valueOf(billingJsonData.SVMXC_Include_Product_c);
                		woBilling.SVMXC__Invoice_Scope__c = billingJsonData.SVMXC_Invoice_Scope_c;
                		woBilling.RecordTypeId = processRecordType.Id;
                		woBilling.SVMXC__Installation_Key__c = seedKey;
                	}
                	else{
                		woBilling.SVMXC__Name__c = billingJsonData.SVMXC_Name_c;
                		woBilling.SVMXC__ProcessID__c = billingJsonData.SVMXC_ProcessID_c;
                		woBilling.SVMXC__Module__c = expressionMap.get(billingJsonData.SVMXC_Module_c);
                		woBilling.SVMXC__Submodule__c = expressionMap.get(billingJsonData.SVMXC_Submodule_c);
                		woBilling.SVMXC__Node_Parent__c = null;
                		woBilling.SVMXC__Process__c = null;
                		woBilling.SVMXC__Capture_Log__c = Boolean.valueOf(billingJsonData.SVMXC_Capture_Log_c);
                		woBilling.SVMXC__Email_On_Success__c = billingJsonData.SVMXC_Email_On_Success_c;
                		woBilling.SVMXC__Email_On_Error__c = billingJsonData.SVMXC_Email_On_Error_c;
                		woBilling.SVMXC__IsStandard__c = Boolean.valueOf(billingJsonData.SVMXC_IsStandard_c);
                		woBilling.SVMXC__Active__c = Boolean.valueOf(billingJsonData.SVMXC_Active_c);
                		woBilling.SVMXC__Description__c = billingJsonData.SVMXC_Description_c;
                		woBilling.SVMXC__Primary_Consolidation_Rule__c = billingJsonData.SVMXC_Primary_Consolidation_Rule_c;
                		woBilling.SVMXC__Secondary_Consolidation_Rule__c = billingJsonData.SVMXC_Secondary_Consolidation_Rule_c;
                		woBilling.SVMXC__Tertiary_Consolidation_Rule__c = billingJsonData.SVMXC_Tertiary_Consolidation_Rule_c;
                		woBilling.SVMXC__Include_Product__c = Boolean.valueOf(billingJsonData.SVMXC_Include_Product_c);
                		woBilling.SVMXC__Invoice_Scope__c = billingJsonData.SVMXC_Invoice_Scope_c;
                		woBilling.RecordTypeId = processRecordType.Id;
                		woBilling.SVMXC__Installation_Key__c = seedKey;
                	}
                	woBillingList.add(woBilling);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( woBillingList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert woBillingList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' WO Billing Process Json is empty \n';
            }
            seedLog += System.now()+' End of Processing WO Billing Process \n\n';
            System.debug('End of Processing WO Billing Process');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing WO Billing Process : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing WO Billing Process : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'WO Billing Process');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2198
    * This method will process PMProcess
    */
    public static boolean processPMProcess() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing PMProcess');
	    	seedLog += System.now()+' Started Processing PMProcess \n';
			if(Test.isRunningTest()){
				pmProcessJson = '{"pmprocess":[{"SVMXC_Name_c":"Sample Preventive Maintenance Process","SVMXC_ProcessID_c":"PREV001_SamplePMProcess","SVMXC_Description_c":"Sample Preventive Maintenance Process","SVMXC_Active_c":"True","SVMXC_Frequency_c":"7","SVMXC_Module_c":null,"SVMXC_Create_Work_Order_c":"One Per Product","SVMXC_Node_Parent_c":"MAP023","SVMXC_Assign_Work_Order_To_c":"Primary Technician","SVMXC_Assign_To_Service_Team_c":null,"SVMXC_Target_Object_Name_c":"Task","SVMXC_Process1_c":"MAP_TaskTemplateToTask","SVMXC_Process2_c":"MAP_ReqPartstoWorkDet","SVMXC_Process3_c":"LOC_MAP001","SVMXC_Include_Parent_c":"False","SVMXC_Process_c":null,"SVMXC_Assign_Case_To_c":"","SVMXC_Case_Assign_To_User_c":null,"SVMXC_IsStandard_c":"True"}]}';
			}
			savePoint = Database.setSavepoint();
			if(pmProcessJson != null && !String.isBlank(pmProcessJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'PM PROCESS'];
				TOOL_SeedWrapper.PmProcess pmProcessData = (TOOL_SeedWrapper.PmProcess)System.JSON.deserialize(pmProcessJson.trim(), TOOL_SeedWrapper.PmProcess.class);
                seedLog += System.now()+' Processed PMProcess Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingProcessList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'PM PROCESS' and SVMXC__ProcessID__c IN ('PREV001_SamplePMProcess') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> pmProcessMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C pmData : existingProcessList){
                    pmProcessMap.put(pmData.SVMXC__ProcessID__c, pmData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingMappingList = [SELECT Id,SVMXC__MAPID__C from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'OBJECT MAPPING' and SVMXC__MAPID__C IN ('MAP023','MAP_TaskTemplateToTask','MAP_ReqPartstoWorkDet','LOC_MAP001') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> objectMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C mapData : existingMappingList){
                    objectMap.put(mapData.SVMXC__MAPID__C, mapData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> pmProcessList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.PmProcessData pmJsonData : pmProcessData.pmprocess){
                	SVMXC__SERVICEMAX_PROCESSES__C pmProcess = new SVMXC__SERVICEMAX_PROCESSES__C();
                	if(pmProcessMap.size() > 0 && pmProcessMap.containsKey(pmJsonData.SVMXC_ProcessID_c)) {
                		pmProcess.Id = pmProcessMap.get(pmJsonData.SVMXC_ProcessID_c);
                		pmProcess.SVMXC__Name__c = pmJsonData.SVMXC_Name_c;
                		pmProcess.SVMXC__Description__c = pmJsonData.SVMXC_Description_c;
                		pmProcess.SVMXC__Frequency__c = Decimal.valueOf(pmJsonData.SVMXC_Frequency_c);
                		pmProcess.SVMXC__Create_Work_Order__c = pmJsonData.SVMXC_Create_Work_Order_c;
                		pmProcess.SVMXC__Node_Parent__c = objectMap.get(pmJsonData.SVMXC_Node_Parent_c);
                		pmProcess.SVMXC__Assign_Work_Order_To__c = pmJsonData.SVMXC_Assign_Work_Order_To_c;
                		pmProcess.SVMXC__Target_Object_Name__c = pmJsonData.SVMXC_Target_Object_Name_c;
                		pmProcess.SVMXC__Process1__c = objectMap.get(pmJsonData.SVMXC_Process1_c);
                		pmProcess.SVMXC__Process2__c = objectMap.get(pmJsonData.SVMXC_Process2_c);
                		pmProcess.SVMXC__Process3__c = objectMap.get(pmJsonData.SVMXC_Process3_c);
                		pmProcess.SVMXC__Include_Parent__c = Boolean.valueOf(pmJsonData.SVMXC_Include_Parent_c);
                		pmProcess.SVMXC__Assign_Case_To__c = pmJsonData.SVMXC_Assign_Case_To_c;
                		pmProcess.SVMXC__IsStandard__c = Boolean.valueOf(pmJsonData.SVMXC_IsStandard_c);
                		pmProcess.RecordTypeId = processRecordType.Id;
                		pmProcess.SVMXC__Installation_Key__c = seedKey;
                	}
                	else{
                		pmProcess.SVMXC__Name__c = pmJsonData.SVMXC_Name_c;
                		pmProcess.SVMXC__ProcessID__c = pmJsonData.SVMXC_ProcessID_c;
                		pmProcess.SVMXC__Active__c = Boolean.valueOf(pmJsonData.SVMXC_Active_c);
                		pmProcess.SVMXC__Description__c = pmJsonData.SVMXC_Description_c;
                		pmProcess.SVMXC__Frequency__c = Decimal.valueOf(pmJsonData.SVMXC_Frequency_c);
                        //expression not assigned for standard pm process
                		pmProcess.SVMXC__Module__c = null;
                		pmProcess.SVMXC__Create_Work_Order__c = pmJsonData.SVMXC_Create_Work_Order_c;
                		pmProcess.SVMXC__Node_Parent__c = objectMap.get(pmJsonData.SVMXC_Node_Parent_c);
                		pmProcess.SVMXC__Assign_Work_Order_To__c = pmJsonData.SVMXC_Assign_Work_Order_To_c;
                        //team not assigned for standard pm process
                		pmProcess.SVMXC__Assign_To_Service_Team__c = null;
                		pmProcess.SVMXC__Target_Object_Name__c = pmJsonData.SVMXC_Target_Object_Name_c;
                		pmProcess.SVMXC__Process1__c = objectMap.get(pmJsonData.SVMXC_Process1_c);
                		pmProcess.SVMXC__Process2__c = objectMap.get(pmJsonData.SVMXC_Process2_c);
                		pmProcess.SVMXC__Process3__c = objectMap.get(pmJsonData.SVMXC_Process3_c);
                		pmProcess.SVMXC__Include_Parent__c = Boolean.valueOf(pmJsonData.SVMXC_Include_Parent_c);
                        //process not assigned for standard pm process
                		pmProcess.SVMXC__Process__c = null;
                		pmProcess.SVMXC__Assign_Case_To__c = pmJsonData.SVMXC_Assign_Case_To_c;
                        //user not assigned for standard pm process
                		pmProcess.SVMXC__Case_Assign_To_User__c = null;
                		pmProcess.SVMXC__IsStandard__c = Boolean.valueOf(pmJsonData.SVMXC_IsStandard_c);
                		pmProcess.RecordTypeId = processRecordType.Id;
                		pmProcess.SVMXC__Installation_Key__c = seedKey;
                	}
                	pmProcessList.add(pmProcess);
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( pmProcessList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert pmProcessList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' PMProcess Json is empty \n';
            }
            seedLog += System.now()+' End of Processing PMProcess \n\n';
            System.debug('End of Processing PMProcess');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing PMProcess : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing PMProcess : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'PMProcess');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2271
    * This method will process DC Views
    */
    public static boolean processDCViews() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing DC Views');
	    	seedLog += System.now()+' Started Processing DC Views \n';
			if(Test.isRunningTest()){
				dcViewJson = '{"dcviews":[{"SVMXC_Source_Object_Name_c":"SVMXC__Service_Order__c","SVMXC_Name_c":"My Open Work Orders","SVMXC_ProcessID_c":"WO_DC_View1","SVMXC_Description_c":"This view will display all work orders where \'Order Status\' is set to Open.","SVMXC_View_For_c":"Grid And Map","SVMXC_Ownership_Type_c":"User\'s Records","SVMXC_Parent_Object_Criteria_c":"SVMXC__Order_Status__c=\'Open\'","SVMXC_Record_Type_Name_c":"View Definition","SVMXC_Values_c":"Name,SVMXC__Company__r.Name,SVMXC__Contact__r.Name,SVMXC__Case__r.CaseNumber,SVMXC__Priority__c,SVMXC__Order_Status__c,SVMXC__Order_Type__c,SVMXC__Dispatch_Status__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Component__r.Name,SVMXC__Customer_Down_Status__c,SVMXC__Billing_Type__c","SVMXC_Advance_Expression_c":"","SVMXC_Rule_Type_c":"Custom View","SVMXC_IsStandard_c":"True"}]}';
			}
			savePoint = Database.setSavepoint();
			if(dcViewJson != null && !String.isBlank(dcViewJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'VIEW DEFINITION'];
				TOOL_SeedWrapper.DcView dcViewData = (TOOL_SeedWrapper.DcView)System.JSON.deserialize(dcViewJson.trim(), TOOL_SeedWrapper.DcView.class);
                seedLog += System.now()+' Processed DC View Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingViewList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'VIEW DEFINITION' and SVMXC__ISSTANDARD__C = true and SVMXC__ProcessID__c = 'WO_DC_View'];
                Map<String, String> dcViewMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C viewData : existingViewList){
                    dcViewMap.put(viewData.SVMXC__ProcessID__c, viewData.Id);
                    isDCViewExists = true;
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> dcViewList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.DcViewData dcViewJsonData : dcViewData.dcviews){
                	SVMXC__SERVICEMAX_PROCESSES__C dcView = new SVMXC__SERVICEMAX_PROCESSES__C();
                	if(!dcViewMap.containsKey(dcViewJsonData.SVMXC_ProcessID_c)) {
                		dcView.SVMXC__Source_Object_Name__c = dcViewJsonData.SVMXC_Source_Object_Name_c;
                		dcView.SVMXC__Name__c = dcViewJsonData.SVMXC_Name_c;
                		dcView.SVMXC__ProcessID__c = dcViewJsonData.SVMXC_ProcessID_c;
                		dcView.SVMXC__Description__c = dcViewJsonData.SVMXC_Description_c;
                		dcView.SVMXC__View_For__c = dcViewJsonData.SVMXC_View_For_c;
                		dcView.SVMXC__Ownership_Type__c = dcViewJsonData.SVMXC_Ownership_Type_c;
                		dcView.SVMXC__Parent_Object_Criteria__c = dcViewJsonData.SVMXC_Parent_Object_Criteria_c;
                		dcView.SVMXC__Values__c = dcViewJsonData.SVMXC_Values_c;
                		dcView.SVMXC__Advance_Expression__c = dcViewJsonData.SVMXC_Advance_Expression_c;
                		dcView.SVMXC__Rule_Type__c = dcViewJsonData.SVMXC_Rule_Type_c;
                		dcView.RecordTypeId = processRecordType.Id;
                		dcView.SVMXC__IsStandard__c = Boolean.valueOf(dcViewJsonData.SVMXC_IsStandard_c);
                        dcViewList.add(dcView);
                	}
                }
                
                if(dcViewList.size() > 0){
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( dcViewList, COMM_SecurityUtils.Access.Createable ) ) {
                        insert dcViewList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' DC View Json is empty \n';
            }
            seedLog += System.now()+' End of Processing DC View \n\n';
            System.debug('End of Processing DC View');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing DC Views : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing DC Views : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'DC Views');
        return installStatus;
    }
    
    
    /**
    *Story : TOOL-2271
    * This method will process DCView Config
    */
    public static boolean processDCViewConfig() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing DCView Config');
	    	seedLog += System.now()+' Started Processing DCView Config \n';
			if(Test.isRunningTest()){
				dcViewConfigJson = '{"dcviewconfigdata":[{"RecordTypeName":"Expressions","SVMXC_Expression_Type_c":"SRCH_Object_Prefilter_Criteria","SVMXC_Expression_Rule_c":"WO_DC_View","SVMXC_Field_Name_c":"SVMXC__Order_Status__c","SVMXC_Operator_c":"eq","SVMXC_Operand_c":"Open","SVMXC_Display_Type_c":"","SVMXC_Sequence_c":"1","SVMXC_Object_Name_c":"","SVMXC_FKey_Name_Field_c":"","SVMXC_Object_Name2_c":"SVMXC__Service_Order__c","SVMXC_Lookup_Field_API_Name_c":"","SVMXC_Field_Relationship_Name_c":"","SVMXC_Ownership_Type_c":"My Records"}]}';
			}
			savePoint = Database.setSavepoint();
			if(dcViewConfigJson != null && !String.isBlank(dcViewConfigJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'EXPRESSIONS'];
				TOOL_SeedWrapper.DcViewConfig dcViewConfigData = (TOOL_SeedWrapper.DcViewConfig)System.JSON.deserialize(dcViewConfigJson.trim(), TOOL_SeedWrapper.DcViewConfig.class);
                seedLog += System.now()+' Processed DCView Config Json Content \n';
                
                if(!isDCViewExists){
                    List<SVMXC__SERVICEMAX_PROCESSES__C> existingViewList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'VIEW DEFINITION' and SVMXC__ISSTANDARD__C = true and SVMXC__ProcessID__c = 'WO_DC_View'];
                    Map<String, String> dcViewMap = new Map<String, String>();
                    for(SVMXC__SERVICEMAX_PROCESSES__C viewData : existingViewList){
                        dcViewMap.put(viewData.SVMXC__ProcessID__c, viewData.Id);
                    }
                    
                	List<SVMXC__SERVICEMAX_CONFIG_DATA__C> dcViewConfigList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
	                for(TOOL_SeedWrapper.DcViewConfigData dcViewConfigJsonData : dcViewConfigData.dcviewconfigdata){
	                	SVMXC__SERVICEMAX_CONFIG_DATA__C dcViewConfig = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
	                	dcViewConfig.SVMXC__Expression_Type__c = dcViewConfigJsonData.SVMXC_Expression_Type_c;
	                	dcViewConfig.SVMXC__Expression_Rule__c = dcViewMap.get(dcViewConfigJsonData.SVMXC_Expression_Rule_c);
	                	dcViewConfig.SVMXC__Field_Name__c = dcViewConfigJsonData.SVMXC_Field_Name_c;
	                	dcViewConfig.SVMXC__Operator__c = dcViewConfigJsonData.SVMXC_Operator_c;
	                	dcViewConfig.SVMXC__Operand__c = dcViewConfigJsonData.SVMXC_Operand_c;
	                	dcViewConfig.SVMXC__Display_Type__c = dcViewConfigJsonData.SVMXC_Display_Type_c;
	                	dcViewConfig.SVMXC__Sequence__c = Decimal.valueOf(dcViewConfigJsonData.SVMXC_Sequence_c);
	                	dcViewConfig.SVMXC__Object_Name__c = dcViewConfigJsonData.SVMXC_Object_Name_c;
	                	dcViewConfig.SVMXC__FKey_Name_Field__c = dcViewConfigJsonData.SVMXC_FKey_Name_Field_c;
	                	dcViewConfig.SVMXC__Object_Name2__c = dcViewConfigJsonData.SVMXC_Object_Name2_c;
	                	dcViewConfig.SVMXC__Lookup_Field_API_Name__c = dcViewConfigJsonData.SVMXC_Lookup_Field_API_Name_c;
	                	dcViewConfig.SVMXC__Field_Relationship_Name__c = dcViewConfigJsonData.SVMXC_Field_Relationship_Name_c;
	                	dcViewConfig.SVMXC__Ownership_Type__c = dcViewConfigJsonData.SVMXC_Ownership_Type_c;
	                	dcViewConfig.RecordTypeId = processRecordType.Id;
	                	dcViewConfigList.add(dcViewConfig);
	                }
                    
                    if(dcViewConfigList.size() > 0){
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( dcViewConfigList, COMM_SecurityUtils.Access.Createable ) ) {
                            insert dcViewConfigList;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
                }
                else{
                	seedLog += System.now()+' DCView already exists in org  \n';
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' DCView Config Json is empty \n';
            }
            seedLog += System.now()+' End of Processing DCView Config \n\n';
            System.debug('End of Processing DCView Config');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing DCView Config : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing DCView Config : ' + e.getMessage() + 'Error Type : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'DCView Config');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2271
    * This method will process QuickBook Configuration
    */
    public static boolean processQuickBookConfiguration() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Quick Book Configuration');
	    	seedLog += System.now()+' Started Processing Quick Book Configuration \n';
			if(Test.isRunningTest()){
				quickBookConfigJson = '{"quickbookconfiguration":[{"SVMXC_Name_c":"Export Work Order","SVMXC_ProcessID_c":"EX_WO_001","SVMXC_Export_Configuration_c":"{\'headerObjectAPIName\':\'SVMXC__Service_Order__c\',\'childObjectAPIName\':\'SVMXC__Service_Order_Line__c\',\'headerEligibilityCriteriaID\':\'EXPR076\',\'childEligibilityCriteriaID\':\'EXPR077\',\'filterDateField\':\'SVMXC__Closed_On__c\',\'defaultSortingField\':\'SVMXC__Closed_On__c\'}","SVMXC_IsDefault_c":"True","SVMXC_IsStandard_c":"True"}]}';
			}
			savePoint = Database.setSavepoint();
			if(quickBookConfigJson != null && !String.isBlank(quickBookConfigJson)){
				RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'EXPORT CONFIGURATION'];
				TOOL_SeedWrapper.QuickBookConfig quickBookData = (TOOL_SeedWrapper.QuickBookConfig)System.JSON.deserialize(quickBookConfigJson.trim(), TOOL_SeedWrapper.QuickBookConfig.class);
                seedLog += System.now()+' Processed Quick Book Configuration Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingQuickBookList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'EXPORT CONFIGURATION' and SVMXC__ISSTANDARD__C = true];
                Map<String, String> quickBookMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C bookData : existingQuickBookList){
                    quickBookMap.put(bookData.SVMXC__ProcessID__c, bookData.Id);
                }
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> quickBookConfigList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                for(TOOL_SeedWrapper.QuickBookConfigData quickBookJsonData : quickBookData.quickbookconfiguration){
                	SVMXC__SERVICEMAX_PROCESSES__C quickBookConfig = new SVMXC__SERVICEMAX_PROCESSES__C();
                	if(quickBookMap.size() > 0 && quickBookMap.containsKey(quickBookJsonData.SVMXC_ProcessID_c)){
                		quickBookConfig.Id = quickBookMap.get(quickBookJsonData.SVMXC_ProcessID_c);
                		quickBookConfig.SVMXC__Name__c = quickBookJsonData.SVMXC_Name_c;
                		quickBookConfig.SVMXC__Export_Configuration__c = quickBookJsonData.SVMXC_Export_Configuration_c.replaceAll('\'','\"');
                		quickBookConfig.SVMXC__IsStandard__c = Boolean.valueOf(quickBookJsonData.SVMXC_IsStandard_c);
                		quickBookConfig.SVMXC__Installation_Key__c = seedKey;
                		quickBookConfig.RecordTypeId = processRecordType.Id;
                	}
                	else{
                		quickBookConfig.SVMXC__Name__c = quickBookJsonData.SVMXC_Name_c;
                		quickBookConfig.SVMXC__ProcessID__c = quickBookJsonData.SVMXC_ProcessID_c;
                		quickBookConfig.SVMXC__IsDefault__c = Boolean.valueOf(quickBookJsonData.SVMXC_IsDefault_c);
                		quickBookConfig.SVMXC__Export_Configuration__c = quickBookJsonData.SVMXC_Export_Configuration_c.replaceAll('\'','\"');
                		quickBookConfig.SVMXC__IsStandard__c = Boolean.valueOf(quickBookJsonData.SVMXC_IsStandard_c);
                		quickBookConfig.SVMXC__Installation_Key__c = seedKey;
                		quickBookConfig.RecordTypeId = processRecordType.Id;
                	}
                	quickBookConfigList.add(quickBookConfig);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( quickBookConfigList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert quickBookConfigList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Quick Book Configuration Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Quick Book Configuration \n\n';
            System.debug('End of Processing Quick Book Configuration');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Quick Book Configuration : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Quick Book Configuration : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Quick Book Configuration');
        return installStatus;
    }
    
    /**
    *Story : TOOL-2271
    * This method will process Smart Objects
    */
    public static boolean processSmartObjects() {
    	boolean installStatus = true;
	    Savepoint savePoint = null;
	    try {
	    	System.debug('Started Processing Smart Objects');
	    	seedLog += System.now()+' Started Processing Smart Objects \n';
			if(Test.isRunningTest()){
				smartObjectJson = '{"smartobject":[{"SVMXC_Object_API_Name_c":"Offer_Appointment_Request","SVMXC_Object_Label_c":"Offer Appointment Request","SVMXC_Schema_c":"{\'name\':\'Offer_Appointment_Request\',\'label\':\'Appointment Offer Request\',\'createable\':\'true\'}","SVMXC_Description_c":"This is the smart object used to map Offer Appointment request for Linx for ServicePower Integration"}]}';
			}
			savePoint = Database.setSavepoint();
			if(smartObjectJson != null && !String.isBlank(smartObjectJson)){
				TOOL_SeedWrapper.SmartObject smartObjectData = (TOOL_SeedWrapper.SmartObject)System.JSON.deserialize(smartObjectJson.trim(), TOOL_SeedWrapper.SmartObject.class);
                seedLog += System.now()+' Processed Smart Objects Json Content \n';
                
                List<SVMXC__Object_Cache__c> existingSmartObjectList = [SELECT Id,SVMXC__Object_API_Name__c from SVMXC__Object_Cache__c Where SVMXC__Object_API_Name__c != null];
                Map<String, String> smartObjectMap = new Map<String, String>();
                for(SVMXC__Object_Cache__c objectData : existingSmartObjectList){
                    smartObjectMap.put(objectData.SVMXC__Object_API_Name__c, objectData.Id);
                }
                
                List<SVMXC__Object_Cache__c> smartObjectList = new List<SVMXC__Object_Cache__c>();
                for(TOOL_SeedWrapper.SmartObjectData smartObjectJsonData : smartObjectData.smartobject){
                	SVMXC__Object_Cache__c smartObject = new SVMXC__Object_Cache__c();
                	if(smartObjectMap.size() > 0 && smartObjectMap.containsKey(smartObjectJsonData.SVMXC_Object_API_Name_c)){
                		smartObject.Id = smartObjectMap.get(smartObjectJsonData.SVMXC_Object_API_Name_c);
                		smartObject.SVMXC__Object_Label__c = smartObjectJsonData.SVMXC_Object_Label_c;
                		smartObject.SVMXC__Schema__c = smartObjectJsonData.SVMXC_Schema_c.replaceAll('\'','\"');
                		smartObject.SVMXC__Description__c = smartObjectJsonData.SVMXC_Description_c;
                	}
                	else{
                		smartObject.SVMXC__Object_API_Name__c = smartObjectJsonData.SVMXC_Object_API_Name_c;
                		smartObject.SVMXC__Object_Label__c = smartObjectJsonData.SVMXC_Object_Label_c;
                		smartObject.SVMXC__Schema__c = smartObjectJsonData.SVMXC_Schema_c.replaceAll('\'','\"');
                		smartObject.SVMXC__Description__c = smartObjectJsonData.SVMXC_Description_c;
                	}
                	smartObjectList.add(smartObject);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( smartObjectList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert smartObjectList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                installStatus = false;
                seedLog += System.now()+' Smart Objects Json is empty \n';
            }
            seedLog += System.now()+' End of Processing Smart Objects \n\n';
            System.debug('End of Processing Smart Objects');
	    }
	    catch(Exception e) {
            installStatus = false;
            seedLog += System.now()+' Error while processing Smart Objects : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing Smart Objects : ' + e.getMessage() + 'Error Type : ' + e.getTypeName());
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'Smart Objects');
        return installStatus;
    }
    
    public static void deleteIpadSetting() {
		try{
            List<SVMXC__SERVICEMAX_PROCESSES__C> inventorySetting = [Select Id,SVMXC__Settings_Name__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' and SVMXC__Settings_Name__c='Enable Parts on FSA' and SVMXC__Submodule__c = '' and SVMXC__IsStandard__c = true];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(inventorySetting != null && inventorySetting.size() > 0){							
                List<SVMXC__SERVICEMAX_CONFIG_DATA__C> settingValueList = [Select Id,SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Setting Value' and SVMXC__Setting_ID__c IN : inventorySetting];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
				if(settingValueList != null && settingValueList.size() > 0){
					delete settingValueList;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
				}
				delete inventorySetting;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        }catch(Exception e) {
            seedLog += System.now()+' Error while deleteIpadSetting : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while deleteIpadSetting : ' + e.getStackTraceString());
        }
	}
    
    public static void processTimesheetProfileConfiguration() {
        try{
            System.debug('Started Processing Timesheet Access');
	    	seedLog += System.now()+' Started Processing Timesheet Access \n';
            SVMXC__ServiceMax_Properties__c timesheetProperty = SVMXC__ServiceMax_Properties__c.getValues('TimesheetAccess');
            if(timesheetProperty == null){
                List<SVMXC__ServiceMax_Config_Data__c> listTimesheetConfigData = [select id, SVMXC__Access_Configuration_Profile__c, SVMXC__SM_Scope__c,SVMXC__Profile__c, SVMXC__RecordType_Name__c from SVMXC__ServiceMax_Config_Data__c where (SVMXC__RecordType_Name__c ='Timesheet Access' or SVMXC__RecordType_Name__c='Configuration Access') and SVMXC__Access_Configuration_Profile__c != null];
        
                Map<String,List<String>> mapConfigWithSFDCProfile = new Map<String,List<String>>();
                List<SVMXC__ServiceMax_Config_Data__c> listTimesheetConfigrecords = new List<SVMXC__ServiceMax_Config_Data__c>();
                List<String> setProfileIds = new List<String>();
                for(SVMXC__ServiceMax_Config_Data__c configDataVar: listTimesheetConfigData){
                    if(configDataVar.SVMXC__RecordType_Name__c.equalsIgnoreCase('Configuration Access') && configDataVar.SVMXC__Profile__c!= null){
                        if(mapConfigWithSFDCProfile.containsKey(configDataVar.SVMXC__Access_Configuration_Profile__c)){
                            mapConfigWithSFDCProfile.get(configDataVar.SVMXC__Access_Configuration_Profile__c).add(configDataVar.SVMXC__Profile__c);
                        }else{
                            List<String> listProfileIds = new List<String>();
                            listProfileIds.add(configDataVar.SVMXC__Profile__c);
                            mapConfigWithSFDCProfile.put(configDataVar.SVMXC__Access_Configuration_Profile__c, listProfileIds);
                        }
                        setProfileIds.add(configDataVar.SVMXC__Profile__c);
                    }else if(configDataVar.SVMXC__RecordType_Name__c.equalsIgnoreCase('Timesheet Access') && configDataVar.SVMXC__SM_Scope__c == null){
                        listTimesheetConfigrecords.add(configDataVar);
                    }
                }
                System.debug('mapConfigWithSFDCProfile '+mapConfigWithSFDCProfile);
                Map<ID, Profile> mapProfile = new Map<ID, Profile>([SELECT Id, Name FROM Profile where Id IN: setProfileIds]);
                for(SVMXC__ServiceMax_Config_Data__c configDataVar:listTimesheetConfigrecords){
                    
                    if(mapProfile != null && mapProfile.size() > 0 && mapConfigWithSFDCProfile.containsKey(configDataVar.SVMXC__Access_Configuration_Profile__c)){
                        TMST_WrapperDef.SalesforceProfileInfo sfdcProfileInfoWrap = new TMST_WrapperDef.SalesforceProfileInfo();
                        List<TMST_WrapperDef.ObjectInfo> listSFDCProfiles = new List<TMST_WrapperDef.ObjectInfo>();
                        for(String sfProfileIds : mapConfigWithSFDCProfile.get(configDataVar.SVMXC__Access_Configuration_Profile__c)){
                            TMST_WrapperDef.ObjectInfo wrapObjectInfo = new TMST_WrapperDef.ObjectInfo();
                            wrapObjectInfo.Id = sfProfileIds;
                            wrapObjectInfo.name = mapProfile.get(sfProfileIds).Name;
                            listSFDCProfiles.add(wrapObjectInfo);
                        }
                        sfdcProfileInfoWrap.salesforceProfileIds = listSFDCProfiles;
                        configDataVar.SVMXC__SM_Scope__c = JSON.serialize(sfdcProfileInfoWrap);
                    }
                }
                System.debug('listTimesheetConfigrecords '+listTimesheetConfigrecords);
                upsert listTimesheetConfigrecords;
                
                List<SVMXC__ServiceMax_Properties__c> customSettingList = new List<SVMXC__ServiceMax_Properties__c>();
                SVMXC__ServiceMax_Properties__c customSetting = new SVMXC__ServiceMax_Properties__c();
                customSetting.Name = 'TimesheetAccess';
                customSetting.SVMXC__Key__c = 'TimesheetAccess';
                customSetting.SVMXC__Value__c = 'Updated';
                customSettingList.add(customSetting);
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( customSettingList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert customSettingList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                seedLog += System.now()+' End of Processing Timesheet Access \n\n';
            	System.debug('End of Processing Timesheet Access');
            }
            else{
                seedLog += System.now()+' Timesheet Access updation already processed \n';
            }
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while updating Timesheet Access : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while updating Timesheet Access : ' + e.getStackTraceString());
        }    
    }
    /**
     * This Method is used to create or update 
     * the servicemax logo in servicemax setup Home. 
     * 
     */
    public static void processServicemaxLogo() {
        SavePoint savePoint = null;
        try{
            savePoint = Database.setSavepoint();
            if(imageData != null){
                String status = 'New';
                String sdFolder = 'EMPTY';
                seedLog += System.now()+' Processing ServiemaxLogo \n';
                Document document = new Document();
                for(Document doc : [Select Id, Name, Body, FolderId From Document Where Name ='ServiceMax Logo']){
                    if(doc != null){
                       document.Id = doc.Id;
                       status = 'Existing';
                    }
                }
                for(Folder folder :[Select Id, Name from Folder Where Name = 'ServiceMax Documents']){
                    if(folder != null){
                    	document.FolderId=folder.Id;
                        sdFolder = 'Existing';
                    }
                }
                if(sdFolder.equals('Existing')){
                    if(status.equals('New')){
                        document.Name ='ServiceMax Logo';
                        document.DeveloperName = 'ServiceMaxLogo';
                        document.IsPublic = true;
                    }     
                    document.Description = 'ServiceMax Logo';
                    document.Keywords = 'SFM_OUTPUT_DOCUMENT';
                    document.Body = EncodingUtil.base64Decode(imageData);
                    document.Type ='png';
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( document, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert document;
                    }
                    else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                else{
                    seedLog += System.now()+' Cannot process ServiemaxLogo because ServiceMax Documents Folder is not available \n';
                }
            }
            else{
                seedLog += System.now()+' ServiemaxLogo is empty \n';
            }
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while updating ServicemaxLogo : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while updating ServicemaxLogo : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
    }
    
    /**
     * This method is used to create platform cache configuration if not exists on 
     * post installation. Default setting value is set to false.
     */
    private static void processPlatformCacheConfiguration() {
        System.debug(System.LoggingLevel.DEBUG, 'processPlatformCacheConfiguration() - enter' );
        try {
            final List<SVMXC__ServiceMax_Properties__c> pcRecordList = [Select SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name ='PC001'];
            final List<SVMXC__ServiceMax_Properties__c> smsClientList = [Select SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name ='SMS_CLIENT_TOKEN'];
        
            // Check whether the servicemax property exists or not.
            if( pcRecordList.isEmpty() ) {
                SVMXC__ServiceMax_Properties__c pcRecord = new SVMXC__ServiceMax_Properties__c();
                pcRecord.SVMXC__Value__c = 'false';
                pcRecord.Name = 'PC001';
                pcRecord.SVMXC__Key__c = 'Enable_Platform_Cache';
                
                // Creste and insert new instance of Servicemax property custom settings for Platform Cache.
                insert pcRecord;
                
                System.debug(System.LoggingLevel.INFO, 'processPlatformCacheConfiguration() : Created Platform cache configuration' );
                setLogMessage(true, 'Platform Cache');
            }
            
            if(smsClientList.isEmpty()){
                SVMXC__ServiceMax_Properties__c smsClient = new SVMXC__ServiceMax_Properties__c();
                smsClient.SVMXC__Value__c = '65866EB535D52583A923286CA9F63';
                smsClient.Name = 'SMS_CLIENT_TOKEN';
                smsClient.SVMXC__Key__c = 'SMS_CLIENT_TOKEN';
                
                insert smsClient;
                
                System.debug(System.LoggingLevel.INFO, 'processPlatformCacheConfiguration() : Created SMS client Token' );
                setLogMessage(true, 'SMS client Token');
            }
        }
        catch(Exception e ){
            System.debug(System.LoggingLevel.ERROR, 'processPlatformCacheConfiguration() : Failed to create Platform Cache Configuration.' + e.getStackTraceString() );
            setLogMessage(false, 'Platform Cache');
        }
        finally {
            System.debug(System.LoggingLevel.DEBUG, 'processPlatformCacheConfiguration() - exit' );
        }
    }
    
    /* 
     * TOOL-2323 
     * Processing APL Receives, APL Return and APL Shipment.
     * */
    public static boolean processAPLReceiveReturnShipment(){
        boolean installStatus = true;
        SavePoint savePoint = null;
        try{
            System.debug('Started Processing processAPLReceive Return Shipment');
	    	seedLog += System.now()+' Started Processing processAPLReceive Return Shipment \n';
			if(Test.isRunningTest()){
				aplReceiveJson = '{"aplreceive":[{"SVMXC_Name_c":"Sample Receiving Process","SVMXC_ProcessID_c":"APL002_SAMPLE_RECEIPT","SVMXC_Description_c":"Sample Receipt Process for all RMAs. Work Orders are created on Receipt.","SVMXC_APL_Action_On_Unexpected_SN_c":"ADD","SVMXC_APL_Action_On_Unexpected_Product_c":"ADD","SVMXC_APL_Action_On_Excess_Qty_c":"ADD","SVMXC_APL_Action_On_Less_Qty_c":"DO NOTHING", "SVMXC_APL_Create_Work_Order_On_c":"RECEIPT","SVMXC_APL_Group_Work_Order_By_c":"ONE_PRODUCT","SVMXC_APL_Serial_Number_Source_c":"LINE_TXT_SN","SVMXC_Parent_Error_Msg_c":"This RMA does not match the criteria for receiving.","SVMXC_Child_Error_Msg_c":"No RMA lines match the criteria for receiving.","SVMXC_Parent_Error_Msg2_c":"This RMA does not match the criteria for delivery.","SVMXC_Child_Error_Msg2_c":"No RMA lines match the criteria for delivery.","SVMXC_APL_Perform_Entitlement_c":"True","SVMXC_Node_Parent_c":"EXPR010","SVMXC_Submodule_c":"EXPR011","SVMXC_Module_c":"EXPR010","SVMXC_Final_Exception_Process_c":"EXPR011","SVMXC_APL_Split_Lines_c":"False","SVMXC_Parent_Object_c":"MAP047","SVMXC_Process_c":"APL_MAP002","SVMXC_APL_Create_WO_Preference_c":"APPLY_ORDER_FIRST","SVMXC_IsStandard_c":"True""}]}';
				aplReturnJson = '	{"aplreturn":[{"SVMXC_Name_c":"SVMXSTD: Sample Return","SVMXC_ProcessID_c":"APL001_SAMPLE_RETURN","SVMXC_Description_c":"This is a sample APL returns process.","SVMXC_Node_Parent_c":"EXPR005","SVMXC_Submodule_c":"EXPR052","SVMXC_Parent_Error_Msg_c":"This Case does not qualify for this returns process.","SVMXC_Child_Error_Msg_c":"There are no products to return for processing.","SVMXC_APL_Perform_Entitlement_c":"True","SVMXC_Module_c":"EXPR005","SVMXC_Final_Exception_Process_c":"EXPR052","SVMXC_APL_Perform_Route_Calculations_c":"False","SVMXC_Consider_Location_From_Object_c":"Case","SVMXC_Consider_Location_From_c":"SVMXC__Site__c","SVMXC_Parent_Object_c":"","SVMXC_Process_c":"","SVMXC_Process1_c":"MAP007","SVMXC_Process2_c":"APL_MAP001","SVMXC_APL_Print_RMA_Template_c":"","SVMXC_IsStandard_c":"True"}]}}';
				aplShipmentJson = '	{"aplshipment":[{"SVMXC_Name_c":"Sample Shipping Process","SVMXC_ProcessID_c":"APL003_SAMPLE_SHIPMENT","SVMXC_Description_c":"This is a sample shipment process.","SVMXC_APL_Serial_Number_Source_c":"LINE_TXT_SN","SVMXC_Parent_Error_Msg_c":"This RMA does not match the criteria for pick and move.","SVMXC_Child_Error_Msg_c":"No RMA lines match the criteria for pick and move.","SVMXC_Parent_Error_Msg2_c":"This Shipment does not match the criteria for pack and ship.","SVMXC_Child_Error_Msg2_c":"No Shipment lines match the criteria for pack and ship.","SVMXC_APL_Create_Internal_RMA_c":"True","SVMXC_APL_Create_Supplier_RMA_c":"True","SVMXC_Parent_Object_c":"MAP041","SVMXC_Process_c":"MAP042","SVMXC_Process1_c":"MAP041","SVMXC_Process2_c":"MAP042","SVMXC_Node_Parent_c":"EXPR012","SVMXC_Submodule_c":"EXPR053","SVMXC_Module_c":"EXPR012","SVMXC_Final_Exception_Process_c":"EXPR054","SVMXC_IsStandard_c":"True"}]}}';
			}
			if(aplReceiveJson != null && !String.isBlank(aplReceiveJson) && aplReturnJson != null && !String.isBlank(aplReturnJson) && aplShipmentJson != null && !String.isBlank(aplShipmentJson)){
				savePoint = Database.setSavepoint();
                List<RecordType> aplRecordTypes = [Select Id, Name From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name IN ('Receiving Process','Initiate Return Process','Shipping Process')];
                Map<String, String> aplRecordTypeMap = new Map<String, String>();
                if(aplRecordTypes != null && aplRecordTypes.size() > 0){
                    for(RecordType aplRecordType : aplRecordTypes){
                        aplRecordTypeMap.put(aplRecordType.Name, aplRecordType.Id);
                    }
                }
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingAPLList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name IN ('Receiving Process','Initiate Return Process','Shipping Process') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> aplExistingMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C aplExistingData : existingAPLList){
                    aplExistingMap.put(aplExistingData.SVMXC__ProcessID__c, aplExistingData.Id);
                }
                List<SVMXC__SERVICEMAX_PROCESSES__C> aplReceiveandReturnandShipmentValueList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
                TOOL_SeedWrapper.APLReceiveValue aplReceiveData = (TOOL_SeedWrapper.APLReceiveValue)System.JSON.deserialize(aplReceiveJson.trim(), TOOL_SeedWrapper.APLReceiveValue.class);
                seedLog += System.now()+' Processed APL Receive Configuration Json Content \n';
                for(TOOL_SeedWrapper.APLReceiveReturnShipmentData aplReceiveJsonData : aplReceiveData.aplreceive){
                    aplReceiveandReturnandShipmentValueList.add(aplProcessingData(aplReceiveJsonData, aplExistingMap, aplRecordTypeMap.get('Receiving Process')));
                }
                TOOL_SeedWrapper.APLReturnValue aplReturnData = (TOOL_SeedWrapper.APLReturnValue)System.JSON.deserialize(aplReturnJson.trim(), TOOL_SeedWrapper.APLReturnValue.class);
                seedLog += System.now()+' Processed APL Return Configuration Json Content \n';
                for(TOOL_SeedWrapper.APLReceiveReturnShipmentData aplReceiveJsonData : aplReturnData.aplreturn){
                    aplReceiveandReturnandShipmentValueList.add(aplProcessingData(aplReceiveJsonData, aplExistingMap, aplRecordTypeMap.get('Initiate Return Process')));
                }
                TOOL_SeedWrapper.APLShipmentValue aplShipmentData = (TOOL_SeedWrapper.APLShipmentValue)System.JSON.deserialize(aplShipmentJson.trim(), TOOL_SeedWrapper.APLShipmentValue.class);
                seedLog += System.now()+' Processed APL Shipment Configuration Json Content \n';
                for(TOOL_SeedWrapper.APLReceiveReturnShipmentData aplReceiveJsonData : aplShipmentData.aplshipment){
                    aplReceiveandReturnandShipmentValueList.add(aplProcessingData(aplReceiveJsonData, aplExistingMap, aplRecordTypeMap.get('Shipping Process')));
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( aplReceiveandReturnandShipmentValueList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert aplReceiveandReturnandShipmentValueList;
                }
                else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                seedLog += System.now()+' APL Receive Return Shipment Json is empty \n';
                installStatus = false;
            }
            seedLog += System.now()+' End of Processing APL Receive Return Shipment \n\n';
            System.debug('End of Processing APL Receive Return Shipment');
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while processing APLReceive : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing APLReceive : ' + e.getStackTraceString());
            installStatus = false;
            Database.rollback(savePoint);
        }
        setLogMessage(installStatus, 'APL Receive, APL Return, APL Shipment ');
        return installStatus;
    }
    
    private static SVMXC__SERVICEMAX_PROCESSES__C aplProcessingData(TOOL_SeedWrapper.APLReceiveReturnShipmentData aplReceiveJsonData, Map<String, String> aplExistingMap, String recordType){
        SVMXC__SERVICEMAX_PROCESSES__C aplReceive = new SVMXC__SERVICEMAX_PROCESSES__C();
        if(aplExistingMap.size() > 0 && aplExistingMap.containsKey(aplReceiveJsonData.SVMXC_ProcessID_c)){
            aplReceive.Id = aplExistingMap.get(aplReceiveJsonData.SVMXC_ProcessID_c);
            aplReceive.SVMXC__Name__c = aplReceiveJsonData.SVMXC_Name_c;
            aplReceive.SVMXC__Description__c = aplReceiveJsonData.SVMXC_Description_c;
            aplReceive.SVMXC__APL_Action_On_Unexpected_SN__c = aplReceiveJsonData.SVMXC_APL_Action_On_Unexpected_SN_c;
            aplReceive.SVMXC__APL_Action_On_Unexpected_Product__c = aplReceiveJsonData.SVMXC_APL_Action_On_Unexpected_Product_c;
            aplReceive.SVMXC__APL_Action_On_Excess_Qty__c = aplReceiveJsonData.SVMXC_APL_Action_On_Excess_Qty_c;
            aplReceive.SVMXC__APL_Action_On_Less_Qty__c = aplReceiveJsonData.SVMXC_APL_Action_On_Less_Qty_c;
            aplReceive.SVMXC__APL_Create_Work_Order_On__c = aplReceiveJsonData.SVMXC_APL_Create_Work_Order_On_c;
            aplReceive.SVMXC__APL_Group_Work_Order_By__c = aplReceiveJsonData.SVMXC_APL_Group_Work_Order_By_c;
            aplReceive.SVMXC__APL_Serial_Number_Source__c = aplReceiveJsonData.SVMXC_APL_Serial_Number_Source_c;
            aplReceive.SVMXC__Parent_Error_Msg__c = aplReceiveJsonData.SVMXC_Parent_Error_Msg_c;
            aplReceive.SVMXC__Child_Error_Msg__c = aplReceiveJsonData.SVMXC_Child_Error_Msg_c;
            aplReceive.SVMXC__Parent_Error_Msg2__c = aplReceiveJsonData.SVMXC_Parent_Error_Msg2_c;
            aplReceive.SVMXC__Child_Error_Msg2__c = aplReceiveJsonData.SVMXC_Child_Error_Msg2_c;
            aplReceive.SVMXC__APL_Perform_Entitlement__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_APL_Perform_Entitlement_c);
            aplReceive.SVMXC__Node_Parent__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Node_Parent_c);
            aplReceive.SVMXC__Submodule__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Submodule_c);
            aplReceive.SVMXC__Module__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Module_c);
            aplReceive.SVMXC__Final_Exception_Process__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Final_Exception_Process_c);
            aplReceive.SVMXC__APL_Split_Lines__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_APL_Split_Lines_c);
            aplReceive.SVMXC__Parent_Object__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Parent_Object_c);
            aplReceive.SVMXC__Process__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Process_c);
            aplReceive.SVMXC__APL_Create_WO_Preference__c = aplReceiveJsonData.SVMXC_APL_Create_WO_Preference_c;
            aplReceive.SVMXC__IsStandard__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_IsStandard_c);
       	 	aplReceive.SVMXC__Consider_Location_From_Object__c = aplReceiveJsonData.SVMXC_Consider_Location_From_Object_c;
        	aplReceive.SVMXC__Consider_Location_From__c = aplReceiveJsonData.SVMXC_Consider_Location_From_c;
        	aplReceive.SVMXC__Process1__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Process1_c);
        	aplReceive.SVMXC__Process2__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Process2_c);
       		aplReceive.SVMXC__APL_Print_RMA_Template__c = aplReceiveJsonData.SVMXC_APL_Print_RMA_Template_c;
            aplReceive.SVMXC__APL_Perform_Route_Calculations__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_APL_Perform_Route_Calculations_c);
            aplReceive.RecordTypeId = recordType;
        }
        else{
            aplReceive.SVMXC__ProcessID__c = aplReceiveJsonData.SVMXC_ProcessID_c;
            aplReceive.SVMXC__Name__c = aplReceiveJsonData.SVMXC_Name_c;
            aplReceive.SVMXC__Description__c = aplReceiveJsonData.SVMXC_Description_c;
            aplReceive.SVMXC__APL_Action_On_Unexpected_SN__c = aplReceiveJsonData.SVMXC_APL_Action_On_Unexpected_SN_c;
            aplReceive.SVMXC__APL_Action_On_Unexpected_Product__c = aplReceiveJsonData.SVMXC_APL_Action_On_Unexpected_Product_c;
            aplReceive.SVMXC__APL_Action_On_Excess_Qty__c = aplReceiveJsonData.SVMXC_APL_Action_On_Excess_Qty_c;
            aplReceive.SVMXC__APL_Action_On_Less_Qty__c = aplReceiveJsonData.SVMXC_APL_Action_On_Less_Qty_c;
            aplReceive.SVMXC__APL_Create_Work_Order_On__c = aplReceiveJsonData.SVMXC_APL_Create_Work_Order_On_c;
            aplReceive.SVMXC__APL_Group_Work_Order_By__c = aplReceiveJsonData.SVMXC_APL_Group_Work_Order_By_c;
            aplReceive.SVMXC__APL_Serial_Number_Source__c = aplReceiveJsonData.SVMXC_APL_Serial_Number_Source_c;
            aplReceive.SVMXC__Parent_Error_Msg__c = aplReceiveJsonData.SVMXC_Parent_Error_Msg_c;
            aplReceive.SVMXC__Child_Error_Msg__c = aplReceiveJsonData.SVMXC_Child_Error_Msg_c;
            aplReceive.SVMXC__Parent_Error_Msg2__c = aplReceiveJsonData.SVMXC_Parent_Error_Msg2_c;
            aplReceive.SVMXC__Child_Error_Msg2__c = aplReceiveJsonData.SVMXC_Child_Error_Msg2_c;
            aplReceive.SVMXC__APL_Perform_Entitlement__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_APL_Perform_Entitlement_c);
            aplReceive.SVMXC__Node_Parent__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Node_Parent_c);
            aplReceive.SVMXC__Submodule__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Submodule_c);
            aplReceive.SVMXC__Module__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Module_c);
            aplReceive.SVMXC__Final_Exception_Process__c = aplExpressionMap.get(aplReceiveJsonData.SVMXC_Final_Exception_Process_c);
            aplReceive.SVMXC__APL_Split_Lines__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_APL_Split_Lines_c);
            aplReceive.SVMXC__Parent_Object__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Parent_Object_c);
            aplReceive.SVMXC__Process__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Process_c);
            aplReceive.SVMXC__APL_Create_WO_Preference__c = aplReceiveJsonData.SVMXC_APL_Create_WO_Preference_c;
            aplReceive.SVMXC__IsStandard__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_IsStandard_c);
            aplReceive.SVMXC__Consider_Location_From_Object__c = aplReceiveJsonData.SVMXC_Consider_Location_From_Object_c;
        	aplReceive.SVMXC__Consider_Location_From__c = aplReceiveJsonData.SVMXC_Consider_Location_From_c;
        	aplReceive.SVMXC__Process1__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Process1_c);
        	aplReceive.SVMXC__Process2__c = aplObjectMap.get(aplReceiveJsonData.SVMXC_Process2_c);
       		aplReceive.SVMXC__APL_Print_RMA_Template__c = aplReceiveJsonData.SVMXC_APL_Print_RMA_Template_c;
            aplReceive.SVMXC__APL_Perform_Route_Calculations__c = Boolean.valueOf(aplReceiveJsonData.SVMXC_APL_Perform_Route_Calculations_c);
            aplReceive.RecordTypeId = recordType;
        }
        return aplReceive;
    }
    
    /*
     * TOOL-2323  Processing APLSource Updates.
     * */
    public static void processAPLSourceUpdates(){
        Savepoint savePoint = null;
        try{
	    	System.debug('Started Processing APL Source Updates');
	    	seedLog += System.now()+' Started Processing APL Source Updates \n';
			if(Test.isRunningTest()){
				aplSourceUpdatesJson = '{"aplsourceupdates":[{"SVMXC_Dispatch_Process_c":"APL001_SAMPLE_RETURN","SVMXC_Configuration_Type_c":"LINE_UPD_ON_ENTITLEMENT","SVMXC_Sequence_c":"1","SVMXC_Field_Name_c":"","SVMXC_Action_c":"Set","SVMXC_Display_Value_c":"Entitled","SVMXC_Target_Field_Name_c":"SVMXC__Line_Status__c","SVMXC_Field_Relationship_Name_c":"","SVMXC_Object_Name_c":"","SVMXC_FKey_Name_Field_c":""}]}';
			}
			
			if(aplSourceUpdatesJson != null && !String.isBlank(aplSourceUpdatesJson)){
                savePoint = Database.setSavepoint();
                RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'Field Mapping'];
				TOOL_SeedWrapper.SourceUpdatesValue aplSourceUpdateData = (TOOL_SeedWrapper.SourceUpdatesValue)System.JSON.deserialize(aplSourceUpdatesJson.trim(), TOOL_SeedWrapper.SourceUpdatesValue.class);
                seedLog += System.now()+' Processed APL Source Updates Json Content \n';
                
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingAplList = [SELECT Id, SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name IN ('Receiving Process','Initiate Return Process','Shipping Process') and SVMXC__ISSTANDARD__C = true];
                Map<String, String> aplExistingMap = new Map<String, String>();
                for(SVMXC__SERVICEMAX_PROCESSES__C objectData : existingAplList){
                    aplExistingMap.put(objectData.SVMXC__ProcessID__c, objectData.Id);
                }
                List<SVMXC__ServiceMax_Config_Data__c> existingaplSourceUpdateList = [SELECT Id, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = 'Field Mapping' and  SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c IN('APL001_SAMPLE_RETURN','APL003_SAMPLE_SHIPMENT','APL002_SAMPLE_RECEIPT')];
                delete existingaplSourceUpdateList;
                
                List<SVMXC__ServiceMax_Config_Data__c> aplSourceUpdateList = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(TOOL_SeedWrapper.SourceUpdatesData aplSourceJsonData : aplSourceUpdateData.aplsourceupdates){
                    SVMXC__ServiceMax_Config_Data__c aplSourceUpdate = new SVMXC__ServiceMax_Config_Data__c();
                    aplSourceUpdate.SVMXC__Dispatch_Process__c = aplExistingMap.get(aplSourceJsonData.SVMXC_Dispatch_Process_c);
                    aplSourceUpdate.SVMXC__Configuration_Type__c = aplSourceJsonData.SVMXC_Configuration_Type_c;
                    aplSourceUpdate.SVMXC__Field_Name__c = aplSourceJsonData.SVMXC_Field_Name_c;
                    aplSourceUpdate.SVMXC__Action__c = aplSourceJsonData.SVMXC_Action_c;
                    aplSourceUpdate.SVMXC__Display_Value__c = aplSourceJsonData.SVMXC_Display_Value_c;
                    aplSourceUpdate.SVMXC__Target_Field_Name__c = aplSourceJsonData.SVMXC_Target_Field_Name_c;
                    aplSourceUpdate.SVMXC__Field_Relationship_Name__c = aplSourceJsonData.SVMXC_Field_Relationship_Name_c;
                    aplSourceUpdate.SVMXC__Object_Name__c = aplSourceJsonData.SVMXC_Object_Name_c;
                    aplSourceUpdate.SVMXC__FKey_Name_Field__c = aplSourceJsonData.SVMXC_FKey_Name_Field_c;
                    aplSourceUpdate.RecordTypeId = processRecordType.Id;
                    aplSourceUpdateList.add(aplSourceUpdate);
                   
                }
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( aplSourceUpdateList, COMM_SecurityUtils.Access.Createable)) {
                    insert aplSourceUpdateList;
                } 
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
			}
			else{
                seedLog += System.now()+' APL Source Updates Json is empty \n';
            }
            seedLog += System.now()+' End of Processing APL Source Updates \n\n';
            System.debug('End of Processing APL Source Updates');
            
        }
        catch(Exception e) {
            seedLog += System.now()+' Error while processing APLSource Updates : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while processing APLSource Updates : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
    }

    /**
     *  TOOL-2350 Update LMD of SFM for Decimal field changes
     */
    public static void updateSfmForDecimalChange() {
        Savepoint savePoint;
        try {
            savePoint = Database.setSavepoint();
            System.debug('Started Processing SFM update for deciaml changes');
	    	seedLog += System.now()+' Started Processing SFM update for deciaml changes \n';
            List<SVMXC__ServiceMax_Properties__c> propertyList = [Select Name from SVMXC__ServiceMax_Properties__c where Name = 'SFMDecimalChange' Limit 1];
            if(propertyList != null && propertyList.size() > 0){
                seedLog += System.now()+' SFM LMD update already processed  \n';
            }else{
                //Object list
                List<String> objectList = new List<String>();
                objectList.add('SVMXC__Product_Stock__c');
                objectList.add('SVMXC__Parts_Discount__c');
                objectList.add('SVMXC__Quote_Line__c');
                objectList.add('SVMXC__Service_Order_Line__c');
                //Field list
                List<String> fieldList = new List<String>();
                fieldList.add('SVMXC__Available_Qty__c');
                fieldList.add('SVMXC__Quantity2__c');
                fieldList.add('SVMXC__Discount_Percentage__c');
                fieldList.add('SVMXC__Discount__c');
                fieldList.add('SVMXC__Billable_Quantity__c');
                fieldList.add('SVMXC__Estimated_Quantity2__c');
                fieldList.add('SVMXC__Actual_Quantity2__c');
                fieldList.add('SVMXC__Quantity_Shipment_Initiated2__c');
                fieldList.add('SVMXC__Quantity_Shipped2__c');
                fieldList.add('SVMXC__Received_Quantity2__c');
                fieldList.add('SVMXC__Requested_Quantity2__c');
                fieldList.add('SVMXC__Billable_Line_Price__c');

                List<SVMXC__Page_Layout_Detail__c> pageFieldRecords = [select SVMXC__Page_Layout__c,SVMXC__Page_Layout__r.SVMXC__Type__c,SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c from SVMXC__Page_Layout_Detail__c Where SVMXC__Detail_Type__c  = 'Field' AND SVMXC__Field_API_Name__c IN: fieldList AND SVMXC__Page_Layout__r.SVMXC__Object_Name__c IN: objectList];
                if(pageFieldRecords != null && pageFieldRecords.size() > 0){
                    Set<String> pageLayoutId = new Set<String>();
                    for(SVMXC__Page_Layout_Detail__c pageField : pageFieldRecords){
                        if(pageField.SVMXC__Page_Layout__r.SVMXC__Type__c == 'Header'){
                            pageLayoutId.add(pageField.SVMXC__Page_Layout__c);
                        }
                        else{
                            pageLayoutId.add(pageField.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c);
                        }
                    }
                    system.debug('pageLayoutId : '+pageLayoutId);
                    List<SVMXC__ServiceMax_Processes__c> sfmProcessList = [Select Id, SVMXC__ProcessID__c, SVMXC__Installation_Key__c  From  SVMXC__ServiceMax_Processes__c Where RecordType.Name = 'Target Manager' AND SVMXC__Page_Layout__c IN: pageLayoutId];
                    system.debug('sfmProcessList : '+sfmProcessList);
                    if(sfmProcessList != null && sfmProcessList.size() > 0 && sfmProcessList.size() < (Limits.getLimitDmlRows() - Limits.getDmlRows())){
                        System.debug('SFM Update count : '+sfmProcessList.size());
	    	            seedLog += System.now()+ 'SFM Update count : '+sfmProcessList.size()+'\n';
                        for(SVMXC__ServiceMax_Processes__c sfmData : sfmProcessList){
                            sfmData.SVMXC__Installation_Key__c = seedKey;
                        }
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( sfmProcessList, COMM_SecurityUtils.Access.Updateable ) ) {
                            update sfmProcessList;
                        }
                        else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }

                        List<SVMXC__ServiceMax_Properties__c> customSettingList = new List<SVMXC__ServiceMax_Properties__c>();
                        SVMXC__ServiceMax_Properties__c customSetting = new SVMXC__ServiceMax_Properties__c();
                        customSetting.Name = 'SFMDecimalChange';
                        customSetting.SVMXC__Key__c = 'SFMDecimalChange';
                        customSetting.SVMXC__Value__c = 'Updated';
                        customSettingList.add(customSetting);
                        
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( customSettingList, COMM_SecurityUtils.Access.Createable ) ) {
                            insert customSettingList;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        seedLog += System.now()+' Custom setting SFMDecimalChange created successfully  \n';                        
                    }
                    else if(sfmProcessList != null && sfmProcessList.size() > 0){
                        System.debug('SFM Update count : '+sfmProcessList.size()+' greater than available limit : '+(Limits.getLimitDmlRows() - Limits.getDmlRows()));
	    	            seedLog += System.now()+ 'SFM Update count : '+sfmProcessList.size()+' greater than available limit : '+(Limits.getLimitDmlRows() - Limits.getDmlRows())+'\n';
                    }
                    setLogMessage(true, 'SFM Decimal Change Update');
                }
            }
            
        } catch (Exception e) {
            seedLog += System.now()+' Error while Updating SFM for Deciaml Changes : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while Updating SFM for Deciaml Changes : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
    }
    /*
     *TOOL-2457 - Update Batch/Lot settings for the custom Inventory Processes in post install script. 
     * 
     */
    public static void processBatchLotSetCustInventory(){
        Savepoint savePoint;
        try {
            savePoint = Database.setSavepoint();
            System.debug('Started Processing Batch/Lot Setting Custom Inventory');
	    	seedLog += System.now()+' Started Processing Batch/Lot Setting Custom Inventory \n';
            List<SVMXC__SERVICEMAX_PROCESSES__C> existingInventoryList = [SELECT Id, SVMXC__Submodule__c, SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Inventory Process' and SVMXC__ISSTANDARD__C = false];
            List<SVMXC__SERVICEMAX_PROCESSES__C> SettingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
            List<String> moduleIds = new List<String>();
            RecordType processSettingRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Settings'];
            for(SVMXC__SERVICEMAX_PROCESSES__C inventoryData : existingInventoryList){
                List<SVMXC__SERVICEMAX_PROCESSES__C> existingSettingList = [SELECT Id, SVMXC__Settings_Name__c, SVMXC__SettingID__c, SVMXC__Submodule__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Settings' AND SVMXC__SETTINGID__C = 'SET043' AND SVMXC__Submodule__c = :inventoryData.SVMXC__Submodule__c];
                if(existingSettingList != null && existingSettingList.isEmpty()){
                    moduleIds.add(inventoryData.SVMXC__Submodule__c);
                    SVMXC__SERVICEMAX_PROCESSES__C processSettingDef = new SVMXC__SERVICEMAX_PROCESSES__C();
                    processSettingDef.SVMXC__SETTINGID__C = 'SET043';
                    processSettingDef.SVMXC__SETTINGS_NAME__C = 'AllowInactiveBatchLot';
                    processSettingDef.SVMXC__DATA_TYPE__C = 'Boolean';
                    processSettingDef.SVMXC__VALUES__C = 'True~|~False';
                    processSettingDef.SVMXC__DEFAULT_VALUE__C = 'False';
                    processSettingDef.SVMXC__SETTING_TYPE__C = 'Global';
                    processSettingDef.SVMXC__SEARCH_ORDER__C = 'Global';
                    processSettingDef.SVMXC__ISPRIVATE__C = False;
                    processSettingDef.SVMXC__ACTIVE__C = True;
                    processSettingDef.SVMXC__DESCRIPTION__C = 'Indicates if user is allowed to process inactive batch/lot';
                    processSettingDef.SVMXC__ISSTANDARD__C = True;
                    processSettingDef.SVMXC__SUBMODULE__C = inventoryData.SVMXC__Submodule__c;
                    processSettingDef.RecordTypeId = processSettingRecordType.Id;
                    processSettingDef.SVMXC__INSTALLATION_KEY__C = seedKey;
                    //processSettingDef.OwnerId = userId;
                    newSettingList.add(processSettingDef);
                }
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newSettingList, COMM_SecurityUtils.Access.Createable)) {
                   insert newSettingList;
            } 
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            RecordType processSetValueRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Setting Value'];
            List<SVMXC__ServiceMax_Config_Data__c> profileList = [select Id,SVMXC__Profile_Name__c,SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Global'];
            List<SVMXC__SERVICEMAX_PROCESSES__C> existingSettingList = [SELECT Id, SVMXC__Settings_Name__c, SVMXC__SettingID__c, SVMXC__Submodule__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Settings' AND SVMXC__Submodule__c IN :moduleIds AND SVMXC__SETTINGID__C = 'SET043'];
            List<SVMXC__ServiceMax_Config_Data__c> settingValueList = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__SERVICEMAX_PROCESSES__C setValue : existingSettingList){
                for(SVMXC__ServiceMax_Config_Data__c profiles : profileList){
                    SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c();
                    settingValueConfig.SVMXC__SETTING_CONFIGURATION_PROFILE__C = profiles.Id;
                    settingValueConfig.SVMXC__SETTING_ID__C = setValue.Id;
                    settingValueConfig.SVMXC__INTERNAL_VALUE__C = 'False';
                    settingValueConfig.SVMXC__DISPLAY_VALUE__C = 'False';
                    settingValueConfig.SVMXC__ACTIVE__C = True;
                    settingValueConfig.SVMXC__ISDEFAULT__C = True;
                    settingValueConfig.RecordTypeId = processSetValueRecordType.Id;
                    settingValueConfig.SVMXC__INSTALLATION_KEY__C = seedKey;
                    //settingValueConfig.OwnerId = userId;
                	settingValueList.add(settingValueConfig);
                }
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( settingValueList, COMM_SecurityUtils.Access.Createable)) {
                    insert settingValueList;
            } 
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            seedLog += System.now()+' End of Processing Batch/Lot Setting Custom Inventory \n\n';
            System.debug('End of Processing Batch/Lot Setting Custom Inventory');
        } 
        catch (Exception e) {
            seedLog += System.now()+' Error while Creating Batch/Lot Setting Custom Inventory : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while Updating Batch/Lot Setting Custom Inventory : ' + e.getStackTraceString());
            Database.rollback(savePoint);
        }
    }
    /*
     * TOOL-2466 Google map api settings
     */
    public static void createGoogleAPICustomSettings() {
        boolean installStatus = true;
        Savepoint savePoint;
        try {
            savePoint = Database.setSavepoint();
            Map<String, String> exisingSettings = new Map<String, String>();
            if(Test.isRunningTest()){
                googleAPICustomSettingJson = '{"googleapicustomsettings":[{"Name":"MAPS_API_KEY_CORE","SVMXC_Key_c":"MAPS_API_KEY_CORE"}]}';
            }
            List<SVMXC__ServiceMax_Properties__c> propertyList = [Select Id,Name from SVMXC__ServiceMax_Properties__c where Name IN ('MAPS_API_KEY_CORE','MAPS_API_KEY_DC',
           				'MAPS_API_KEY_FSA_ANDROID','MAPS_API_KEY_FSA_IOS','MAPS_API_KEY_FSA_WINDOWS','MAPS_API_KEY_GO_ANDROID','MAPS_API_KEY_GO_IOS','MAPS_API_KEY_SB')];
            if(propertyList != null && propertyList.size() > 0){
                for(SVMXC__ServiceMax_Properties__c property : propertyList){
                    exisingSettings.put(property.Name, property.Id);
                }
            }

            TOOL_SeedWrapper.CustomSetting settingContent =  (TOOL_SeedWrapper.CustomSetting)System.JSON.deserialize(googleAPICustomSettingJson.trim(), TOOL_SeedWrapper.CustomSetting.class);
            seedLog += System.now()+' Processed Google API Custom Json \n';
            List<SVMXC__ServiceMax_Properties__c> googleAPICustomSettingList = new List<SVMXC__ServiceMax_Properties__c>();
            for(TOOL_SeedWrapper.CustomSettingData customSettingdata : settingContent.googleapicustomsettings) {
                SVMXC__ServiceMax_Properties__c googleAPICustomSetting = new SVMXC__ServiceMax_Properties__c();
                if(exisingSettings.containsKey(customSettingdata.Name)){
                    googleAPICustomSetting.Id = exisingSettings.get(customSettingdata.Name);
                    googleAPICustomSetting.SVMXC__Value__c = customSettingdata.SVMXC_Value_c;
                }
                else{
                    googleAPICustomSetting.Name = customSettingdata.Name;
                    googleAPICustomSetting.SVMXC__Key__c = customSettingdata.SVMXC_Key_c;
                    googleAPICustomSetting.SVMXC__Value__c = customSettingdata.SVMXC_Value_c;
                }
                googleAPICustomSettingList.add(googleAPICustomSetting);
            }
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( googleAPICustomSettingList, COMM_SecurityUtils.Access.Upsertable ) ) {
                upsert googleAPICustomSettingList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            seedLog += System.now()+' Google API Custom settings created successfully  \n';
        }
        catch(Exception e) {
            Database.rollback(savePoint);
            installStatus = true;
            seedLog += System.now()+' Error while creating Google API custom settings : '+ e.getMessage() + ' '+ e.getStackTraceString() + '\n';
            System.debug('Error while creating Google API custom settings ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        setLogMessage(installStatus, 'Google Api Settings');
    }
}