@isTest
public class TOOL_SeedAppSettingHandler_UT {

    static String seedKey = '';
    
    public static testMethod void onSeedInstallTestMethod() {
        getSeedKey();
        getSeedKey();
        insertExpression();
        insertObjectMapping();
        TOOL_SeedAppSettingHandler.onSeedInstall(seedKey, UserInfo.getUserEmail(), false);
    }

    public static testMethod void processProfileTestMethod() {
        getSeedKey();
        insertTestProfile();
        TOOL_SeedAppSettingHandler.processProfiles();
    }

    public static testMethod String getStaticResourcePathTestMethod() {
        StaticResource staticResource = [SELECT Id,Name,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'TOOL_AppSetting' LIMIT 1];
        String nameSpacePrefix = staticResource.NamespacePrefix;
        if( String.isEmpty(nameSpacePrefix) ) {
            nameSpacePrefix = '';
        } else {
            //If has NamespacePrefix
            nameSpacePrefix += '__';
        }
        System.debug('Static Resource Path : '+'/resource/' + staticResource.SystemModstamp.getTime() + '/' + nameSpacePrefix + staticResource.Name + '/Default/');
        return '/resource/' + staticResource.SystemModstamp.getTime() + '/' + nameSpacePrefix + staticResource.Name + '/Default/';
    }

    public static testMethod void processModuleTestMethod() {
        getSeedKey();
        inserTestModule();
        TOOL_SeedAppSettingHandler.processModules();
    }

    public static testMethod void processSubModuleTestMethod() {
        getSeedKey();
        inserTestSubModule();
        TOOL_SeedAppSettingHandler.processSubmodules();
    }

    public static testMethod void processSettingTestMethod() {
        getSeedKey();
        insertTestSetting();
        TOOL_SeedAppSettingHandler.processSettings();
    }

    public static testMethod void processSettingValuesTestMethod() {
        getSeedKey();
        insertTestSettingValue();
        TOOL_SeedAppSettingHandler.processSettingValues();
    }

    public static void insertTestProfile() {
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
        RecordType configRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Configuration Profile'];
        SVMXC__ServiceMax_Config_Data__c cofigProfileData = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c profileData = new SVMXC__ServiceMax_Config_Data__c();
        cofigProfileData.SVMXC__PROFILE_NAME__C = 'Default';
        cofigProfileData.SVMXC__DESCRIPTION__C = 'This is the default org-wide configuration profile automatically loaded when ServiceMax is installed. This is a global (org-wide) profile that contains default values for all the configurable parameters of ServiceMax application. In order to configure ServiceMax for your organization, clone this profile using a name you can easily identify and modify the cloned profile.';
        cofigProfileData.SVMXC__CONFIGURATION_TYPE__C = 'Global';
        cofigProfileData.SVMXC__ACTIVE__C = true;
        cofigProfileData.SVMXC__ISDEFAULT__C = true;
        cofigProfileData.RecordTypeId = configRecordType.Id;
        cofigProfileData.SVMXC__INSTALLATION_KEY__C = seedKey;
        configDataList.add(cofigProfileData);
        profileData.SVMXC__PROFILE_NAME__C = 'Clone Default';
        profileData.SVMXC__DESCRIPTION__C = 'This is the default org-wide configuration profile automatically loaded when ServiceMax is installed. This is a global (org-wide) profile that contains default values for all the configurable parameters of ServiceMax application. In order to configure ServiceMax for your organization, clone this profile using a name you can easily identify and modify the cloned profile.';
        profileData.SVMXC__CONFIGURATION_TYPE__C = 'Global';
        profileData.SVMXC__ACTIVE__C = false;
        profileData.SVMXC__ISDEFAULT__C = false;
        profileData.SVMXC__INSTALLATION_KEY__C = seedKey;
        profileData.RecordTypeId = configRecordType.Id;
        configDataList.add(profileData);

        insert configDataList;
    }

    public static void inserTestModule() {
        List<SVMXC__SERVICEMAX_PROCESSES__C> processDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Module'];
        SVMXC__SERVICEMAX_PROCESSES__C moduleData = new SVMXC__SERVICEMAX_PROCESSES__C();
        moduleData.SVMXC__ModuleID__c = 'CASETEST';
        moduleData.SVMXC__Name__c = 'Case';
        moduleData.SVMXC__DESCRIPTION__C = 'This module is a collection of ServiceMax functionality related to the Case screen excluding entitlement verification.';
        moduleData.SVMXC__ISSTANDARD__C = true;
        moduleData.SVMXC__INSTALLATION_KEY__C = seedKey;
        moduleData.RecordTypeId = processRecordType.Id;
        processDataList.add(moduleData);

        insert processDataList;
    }

    public static void inserTestSubModule() {
        inserTestModule();
        List<SVMXC__SERVICEMAX_PROCESSES__C> moduleList = [Select Id, SVMXC__ModuleID__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Module' and SVMXC__ISSTANDARD__C = true];
        if(moduleList != null && moduleList.size() > 0){
            Map<String, String> moduleMap = new Map<String, String>();
            for(SVMXC__SERVICEMAX_PROCESSES__C module : moduleList) {
                moduleMap.put(module.SVMXC__ModuleID__c, module.Id);
            }
            List<SVMXC__SERVICEMAX_PROCESSES__C> processDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
            RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Submodule'];
            SVMXC__SERVICEMAX_PROCESSES__C submoduleData = new SVMXC__SERVICEMAX_PROCESSES__C();
            submoduleData.SVMXC__ModuleID__c = moduleMap.get('CASETEST');
            submoduleData.SVMXC__SUBMODULEID__C = 'CASETEST001';
            submoduleData.SVMXC__NAME__C = 'Select Booking Window';
            submoduleData.SVMXC__DESCRIPTION__C = 'This feature displays your organization&apos;s territory structure and allows your call center users to commit an appropriate booking window to the customer based on technician availability in the selected territory.';
            submoduleData.SVMXC__ISSTANDARD__C = true;
            submoduleData.SVMXC__INSTALLATION_KEY__C = seedKey;
            submoduleData.RecordTypeId = processRecordType.Id;
            processDataList.add(submoduleData);

            insert processDataList;
        }
    }

    public static void insertTestSetting() {
        inserTestSubModule();
        List<SVMXC__SERVICEMAX_PROCESSES__C> subModuleList = [Select Id,SVMXC__SubmoduleID__c  from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Submodule' and SVMXC__ISSTANDARD__C = true];

        if(subModuleList != null  && subModuleList.size() > 0) {
            Map<String, String> submoduleMap = new Map<String, String>();
            for(SVMXC__SERVICEMAX_PROCESSES__C submodule : subModuleList) {
                submoduleMap.put(submodule.SVMXC__SubmoduleID__c, submodule.Id);
            }
            List<SVMXC__SERVICEMAX_PROCESSES__C> processDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
            RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Settings'];
            SVMXC__SERVICEMAX_PROCESSES__C settingData = new SVMXC__SERVICEMAX_PROCESSES__C();
            settingData.SVMXC__SUBMODULEID__C = 'CASETEST001';
            settingData.SVMXC__SETTINGID__C = 'TESTSET002';
            settingData.SVMXC__SETTINGS_NAME__C = 'Default Booking Window Start';
            settingData.SVMXC__DATA_TYPE__C = 'Picklist';
            settingData.SVMXC__VALUES__C = 'TODAY~|~TOMORROW';
            settingData.SVMXC__DEFAULT_VALUE__C = 'TODAY';
            settingData.SVMXC__SETTING_TYPE__C = 'Global';
            settingData.SVMXC__SEARCH_ORDER__C = 'Global';
            settingData.SVMXC__ISPRIVATE__C = false;
            settingData.SVMXC__ACTIVE__C = true;
            settingData.SVMXC__DESCRIPTION__C = 'Setting controls how the start date is calculated on Booking Window selection screen';
            settingData.SVMXC__ISSTANDARD__C = true;
            settingData.SVMXC__SUBMODULE__C = submoduleMap.get('CASETEST001');
            settingData.SVMXC__INSTALLATION_KEY__C = seedKey;
            settingData.RecordTypeId = processRecordType.Id;
            processDataList.add(settingData);

            insert processDataList;
        }
    }

    public static void insertTestSettingValue() {
        insertTestProfile();
        insertTestSetting();
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Setting Value'];
        List<SVMXC__ServiceMax_Config_Data__c> profileList = [select Id,SVMXC__Profile_Name__c,SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Profile'];
        Map<String, String> profileMap = new Map<String, String>();
        Map<String, String> customProfileMap = new Map<String, String>();
        if(profileList != null && profileList.size() > 0) {
            for(SVMXC__ServiceMax_Config_Data__c profile : profileList) {
                if('Default'.equals(profile.SVMXC__Profile_Name__c) || 'Default Group Profile'.equals(profile.SVMXC__Profile_Name__c)){
                    profileMap.put(profile.SVMXC__Profile_Name__c, profile.Id);
                }
                else {
                    customProfileMap.put(profile.SVMXC__Profile_Name__c, profile.Id + '_' + profile.SVMXC__Configuration_Type__c);
                }
            }
            //get Setting details
            List<SVMXC__SERVICEMAX_PROCESSES__C> settingList = [Select Id,SVMXC__SUBMODULEID__C,SVMXC__SETTINGID__C from SVMXC__SERVICEMAX_PROCESSES__C where RecordType.Name = 'Settings' and SVMXC__ISSTANDARD__C = true];
            Map<String, String> settingMap = new Map<String, String>();
            for(SVMXC__SERVICEMAX_PROCESSES__C settings : settingList) {
                settingMap.put(settings.SVMXC__SUBMODULEID__C + '_' + settings.SVMXC__SETTINGID__C, settings.Id);
            }
            List<SVMXC__ServiceMax_Config_Data__c> newSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
            SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c();
            settingValueConfig.SVMXC__SETTING_CONFIGURATION_PROFILE__C = profileMap.get('Default');
            settingValueConfig.SVMXC__SETTING_ID__C = settingMap.get('CASETEST001_TESTSET002');
            settingValueConfig.SVMXC__INTERNAL_VALUE__C = 'TODAY';
            settingValueConfig.SVMXC__DISPLAY_VALUE__C = 'TODAY';
            settingValueConfig.SVMXC__ACTIVE__C = true;
            settingValueConfig.SVMXC__ISDEFAULT__C = true;
            settingValueConfig.SVMXC__INSTALLATION_KEY__C = seedKey;
            settingValueConfig.RecordTypeId = processRecordType.Id;
            newSettingValues.add(settingValueConfig);

            insert newSettingValues;
        }
    }

    public static testMethod void processMacrosTestMethod() {
        TOOL_SeedAppSettingHandler.processMacros();
    }

    public static testMethod void processCodeSnippetTestMethod() {
        insertTestCodeSnippetData();
        TOOL_SeedAppSettingHandler.processCodeSnippet();
    }

    public static testMethod void processManifestTestMethod() {
        TOOL_SeedAppSettingHandler.processCodeSnippetManifest();
    }

    public static void insertTestCodeSnippetData() {
        List<SVMXC__Code_Snippet__c> snippetList = new List<SVMXC__Code_Snippet__c>();
        SVMXC__Code_Snippet__c snippetCode = new SVMXC__Code_Snippet__c();
        snippetCode.SVMXC__SnippetId__c = 'Code001';
        snippetCode.SVMXC__Name__c = 'Third party apps';
        snippetCode.SVMXC__Description__c = 'To integrate sharing with other apps';
        snippetCode.SVMXC__IsStandard__c = true;
        snippetCode.SVMXC__Data__c = '{"data":"test code snippet","SVMXC_IsStandard_c":"True"}';
        snippetCode.SVMXC__Type__c = 'JSON';
        snippetList.add(snippetCode);

        SVMXC__Code_Snippet__c oldSnippetCode = new SVMXC__Code_Snippet__c();
        oldSnippetCode.SVMXC__SnippetId__c = 'Code008';
        oldSnippetCode.SVMXC__Name__c = 'Third party apps';
        oldSnippetCode.SVMXC__Description__c = 'To integrate sharing with other apps';
        oldSnippetCode.SVMXC__IsStandard__c = true;
        oldSnippetCode.SVMXC__Data__c = '{"data":"test code snippet","SVMXC_IsStandard_c":"True"}';
        oldSnippetCode.SVMXC__Type__c = 'JSON';
        snippetList.add(oldSnippetCode);
        
        insert snippetList;
    }

    public static testMethod void processFilterTestMethod() {
        getSeedKey();
        insertApplicationFilter();
        TOOL_SeedAppSettingHandler.processApplicationFilter();
    }

    public static void insertApplicationFilter() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Application Profile'];

        List<SVMXC__SERVICEMAX_PROCESSES__C> filterDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C processFilterData = new SVMXC__SERVICEMAX_PROCESSES__C();
        processFilterData.SVMXC__ProcessID__c = 'APPPRO001';
        processFilterData.SVMXC__Name__c = 'ServiceMax Online';
        processFilterData.SVMXC__Description__c = '';
        processFilterData.SVMXC__Values__c = '';
        processFilterData.SVMXC__IsStandard__c = true;
        processFilterData.SVMXC__INSTALLATION_KEY__C = seedKey;
        processFilterData.RecordTypeId = processRecordType.Id;
        filterDataList.add(processFilterData);

        insert filterDataList;
    }

    public static testMethod void processMapHoverTestMethod() {
        getSeedKey();
        insertMapHover();
        TOOL_SeedAppSettingHandler.processMapHover();
    }

    public static void insertMapHover() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'SVMX Rule'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> newHoverDataList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C processHoverData = new SVMXC__SERVICEMAX_PROCESSES__C();
        processHoverData.SVMXC__NAME__C = 'Map Hover For Work Order';
        processHoverData.SVMXC__Rule_Type__c = 'Column Info';
        processHoverData.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processHoverData.SVMXC__ProcessID__c = 'MAPHOV01';
        processHoverData.SVMXC__ISSTANDARD__C = true;
        processHoverData.SVMXC__INSTALLATION_KEY__C = seedKey;
        processHoverData.RecordTypeId = processRecordType.Id;
        newHoverDataList.add(processHoverData);

        insert newHoverDataList;
    }

    public static testMethod void processHoverDetailTestMethod() {
        TOOL_SeedAppSettingHandler.processMapHoverDetail();
    }
    
    public static testMethod void processPropertyElementTestMethod() {
        TOOL_SeedAppSettingHandler.processPropertyElement();
    }
    
    public static testMethod void deleteIpadSettingTestMethod() {
        TOOL_SeedAppSettingHandler.deleteIpadSetting();
    }
    
    public static void getSeedKey() {
        String orgId = userInfo.getOrganizationId().subString(0,15);
        Blob encodeBlob = blob.valueof(orgId);
        seedKey = EncodingUtil.base64Encode(encodeBlob);
    }
    
    public static testMethod void processServiceFlowActionTestMethod() {
        getSeedKey();
        insertServiceFlowActions();
        TOOL_SeedAppSettingHandler.processServiceFlowAction();
    }
    
    public static void insertServiceFlowActions() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'SF ACTION'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> newSFActionList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C processData = new SVMXC__SERVICEMAX_PROCESSES__C();
        processData.SVMXC__ProcessID__c = 'OTH000';
        processData.SVMXC__Name__c = 'View Configuration';
        processData.SVMXC__Description__c = 'View Configuration';
        processData.SVMXC__IsStandard__c = true;
        processData.SVMXC__Active__c = true;
        processData.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        processData.SVMXC__Target_Type__c = 'Existing Window';
        processData.SVMXC__Target_URL__c = '/apex/SVMXC__IPRD_IBTree';
        processData.SVMXC__Window_Height__c = 330;
        processData.SVMXC__Window_Width__c = 900;
        processData.SVMXC__Installation_Key__c = seedKey;
        processData.SVMXC__Open_As_Full_Window__c = false;
        processData.SVMXC__Custom_Action_Type__c = 'URL';
        processData.SVMXC__Service_Namespace__c = '';
        processData.SVMXC__Service_Class_Name__c = '';
        processData.SVMXC__Service_Method_Name__c = '';
        processData.RecordTypeId = processRecordType.Id;
        processData.SVMXC__INSTALLATION_KEY__C = seedKey;
        newSFActionList.add(processData);

        insert newSFActionList;
    }
    
    public static testMethod void processServiceFlowActionParameterTestMethod() {
        TOOL_SeedAppSettingHandler.processServiceFlowActionParameter();
    }
    
    public static testMethod void processGetPriceFieldsTestMethod() {
        TOOL_SeedAppSettingHandler.processGetPriceFields();
    }
    
    public static void insertCustomSettings() {
        List<SVMXC__ServiceMax_Property_Elements__c> propertyElementList = new List<SVMXC__ServiceMax_Property_Elements__c>();
        SVMXC__ServiceMax_Property_Elements__c propertyElementCase = new SVMXC__ServiceMax_Property_Elements__c();
        propertyElementCase.Name = 'PELE528';
        propertyElementCase.SVMXC__Element_Type__c = 'Packaged Trigger';
        propertyElementCase.SVMXC__Element_Value__c = 'ENABLED';
        propertyElementCase.SVMXC__Property_Key__c = 'SVMXDEV_CASE_Trigger1';
        propertyElementList.add(propertyElementCase);
        
        SVMXC__ServiceMax_Property_Elements__c propertyElement = new SVMXC__ServiceMax_Property_Elements__c();
        propertyElement.Name = 'PELE565';
        propertyElement.SVMXC__Element_Type__c = 'Packaged Trigger';
        propertyElement.SVMXC__Element_Value__c = 'ENABLED';
        propertyElement.SVMXC__Property_Key__c = 'SVMXDEV_WORD_Trigger1';
        propertyElementList.add(propertyElement);
        
        insert propertyElementList;
    }
    
    public static testMethod void processManagedTriggerTestMethod() {
        insertCustomSettings();
        TOOL_SeedAppSettingHandler.processManagedTrigger();
    }
    
    public static testMethod void processIOTConfigurationTestMethod() {
        TOOL_SeedAppSettingHandler.processIOTConfiguration();
    }
    
    public static void insertInventoryProcess() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'Inventory Process'];
    	List<SVMXC__SERVICEMAX_PROCESSES__C> moduleList = [Select Id, SVMXC__ModuleID__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Module' and SVMXC__ISSTANDARD__C = true];
        Map<String, String> moduleMap = new Map<String, String>();
        if(moduleList != null && moduleList.size() > 0){
            for(SVMXC__SERVICEMAX_PROCESSES__C module : moduleList) {
                moduleMap.put(module.SVMXC__ModuleID__c, module.Id);
            }
        }
        
        List<SVMXC__SERVICEMAX_PROCESSES__C> subModuleList = [Select Id,SVMXC__SubmoduleID__c  from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Submodule' and SVMXC__ISSTANDARD__C = true];
        Map<String, String> subModuleMap = new Map<String, String>();
        if(subModuleList != null  && subModuleList.size() > 0) {
            for(SVMXC__SERVICEMAX_PROCESSES__C submodule : subModuleList) {
                subModuleMap.put(submodule.SVMXC__SubmoduleID__c, submodule.Id);
            }
        }
            
    	SVMXC__SERVICEMAX_PROCESSES__C processData = new SVMXC__SERVICEMAX_PROCESSES__C();
    	processData.SVMXC__ProcessID__c = 'CASETEST001';
    	processData.SVMXC__MODULE__C = moduleMap.get('CASETEST');
    	processData.SVMXC__SUBMODULE__C = subModuleMap.get('CASETEST001');
    	processData.SVMXC__NAME__C = 'Post to Inventory - Stock Adjustment';
    	processData.SVMXC__DESCRIPTION__C = 'This functionality performs inventory updates for a stock adjustment transaction. Depending upon stock attributes of the location and product, serial number information is also captured.';
    	processData.SVMXC__PARENT_OBJECT_CRITERIA__C = 'SVMXC__Posted_To_Inventory__c=False';
    	processData.SVMXC__CHILD_OBJECT_CRITERIA__C = '';
    	processData.SVMXC__Parent_Error_Msg__c = 'This Stock adjustment has been posted to inventory.';
    	processData.SVMXC__Child_Error_Msg__c = '';
    	processData.SVMXC__INSTALLATION_KEY__C = seedKey;
        processData.SVMXC__ISSTANDARD__C = true;
    	processData.SVMXC__Tag_Keys__c = 'POST_TO_INVENTORY_-_STOCK_ADJUSTMENT;SADJ001_DESC;THIS_STOCK_ADJUSTMENT_HAS_BEEN_POSTED_TO_INVENTORY.;';
    	processData.RecordTypeId = processRecordType.Id;
        
    	insert processData;
    }
    
    public static testMethod void processInventoryProcessesTestMethod() {
    	getSeedKey();
    	insertInventoryProcess();
        TOOL_SeedAppSettingHandler.processInventoryProcesses();
    }
    
    public static testMethod void processInventoryExpressionTestMethod() {
        getSeedKey();
        insertInventoryProcess();
        TOOL_SeedAppSettingHandler.processInventoryExpression();
    }
    
    public static void insertOptimaxCustomSetting() {
    	List<SVMXC__Field_Default_Rules__c> fieldRuleList = new List<SVMXC__Field_Default_Rules__c>();
    	SVMXC__Field_Default_Rules__c fieldRuleData = new SVMXC__Field_Default_Rules__c();
    	fieldRuleData.Name = '1';
    	fieldRuleData.SVMXC__Source_Key__c = 'Custom';
    	fieldRuleData.SVMXC__Source_Type__c = 'SVMXC__Optimization_Goals__c';
    	fieldRuleData.SVMXC__Target_Key__c = 'SVMXC__Weight_Node_Type__c';
    	fieldRuleData.SVMXC__Target_Value__c = '0';
    	fieldRuleList.add(fieldRuleData);
    	
    	insert fieldRuleList;
    }
    
    public static testMethod void processOptimaxCustomSettingTestMethod() {
    	insertOptimaxCustomSetting();
        TOOL_SeedAppSettingHandler.processOptimaxCustomSetting();
    }
    
    public static void insertExpression() {
    	RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'SVMX RULE'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> expressionList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C expression = new SVMXC__SERVICEMAX_PROCESSES__C();
        expression.SVMXC__NAME__C = 'SVMXSTD: Closed Work Orders';
		expression.SVMXC__ProcessID__c = 'EXPR060';
		expression.SVMXC__DESCRIPTION__C = 'Expression to select Closed Work Order only';
		expression.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
		expression.SVMXC__Advance_Expression__c = '';
		expression.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c=\'Closed\'';
		expression.SVMXC__ISSTANDARD__C = true;
		expression.SVMXC__Installation_Key__c = seedKey;
		expression.SVMXC__Rule_Type__c = 'Named Expression';
		expression.SVMXC__Parent_Error_Msg__c = 'This record does not meet the qualification criteria for this SFM Transaction';
		expression.RecordTypeId = processRecordType.Id;
		expressionList.add(expression);
		
		insert expressionList;
    } 
    
    /*public static testMethod void processNamedExpressionsTestMethod() {
    	getSeedKey();
    	insertExpression();
        TOOL_SeedAppSettingHandler.processNamedExpressions();
    }*/
    
    public static testMethod void processExpressionDetailTestMethod() {
        getSeedKey();
    	insertExpression();
        TOOL_SeedAppSettingHandler.processExpressionDetail();
    }
    
    public static void insertObjectMapping() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'OBJECT MAPPING'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> objectMapppingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C objectMapping = new SVMXC__SERVICEMAX_PROCESSES__C();
        objectMapping.SVMXC__MAPID__C = 'MAP023';
        objectMapping.SVMXC__NAME__C = 'SVMXSTD: Installed Product To Work Order';
        objectMapping.SVMXC__DESCRIPTION__C = 'Field mapping to be used when Work Order is created from an Installed Product';
        objectMapping.SVMXC__ACTIVE__C = true;
        objectMapping.SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__Installed_Product__c';
        objectMapping.SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__Service_Order__c';
        objectMapping.SVMXC__TARGET_RECORD_TYPE__C = '';
        objectMapping.SVMXC__ISSTANDARD__C = true;
        objectMapping.RecordTypeId = processRecordType.Id;
        objectMapping.SVMXC__Installation_Key__c = seedKey;
        objectMapppingList.add(objectMapping);
        
        insert objectMapppingList;
    }    
    
    /*public static testMethod void processObjectMappingTestMethod() {
        getSeedKey();
        insertObjectMapping();
        TOOL_SeedAppSettingHandler.processObjectMapping();
    }*/
    
    public static void insertFieldMapping() {
    	List<SVMXC__SERVICEMAX_PROCESSES__C> existingMappingList = [SELECT Id,SVMXC__MAPID__C from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'OBJECT MAPPING' and SVMXC__MAPID__C IN ('MAP023') and SVMXC__ISSTANDARD__C = true];
        Map<String, String> objectMap = new Map<String, String>();
        for(SVMXC__SERVICEMAX_PROCESSES__C mapData : existingMappingList){
            objectMap.put(mapData.SVMXC__MAPID__C, mapData.Id);
        }
                
    	RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'FIELD MAPPING'];
    	List<SVMXC__SERVICEMAX_CONFIG_DATA__C> fieldMappingList = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
    	SVMXC__SERVICEMAX_CONFIG_DATA__C fieldMapping = new SVMXC__SERVICEMAX_CONFIG_DATA__C();
    	fieldMapping.SVMXC__MAPID__C = objectMap.get('MAP023');
		fieldMapping.SVMXC__SOURCE_FIELD_NAME__C = 'SVMXC__Company__c';
		fieldMapping.SVMXC__TARGET_FIELD_NAME__C = 'SVMXC__Company__c';
		fieldMapping.SVMXC__ACTIVE__C = true;
		fieldMapping.SVMXC__ISDEFAULT__C = true;
		fieldMapping.SVMXC__Preference_2__c = '';
		fieldMapping.SVMXC__Preference_3__c = '';
		fieldMapping.SVMXC__Configuration_Type__c = 'Field Mapping';
		fieldMapping.SVMXC__Display_Value__c = '';
		fieldMapping.SVMXC__Parameter_Type__c = '';
		fieldMapping.RecordTypeId = processRecordType.Id;
		fieldMapping.SVMXC__Installation_Key__c = seedKey;
		fieldMappingList.add(fieldMapping);
		
		insert fieldMappingList;
    }
    
    public static testMethod void processFieldMappingTestMethod() {
    	getSeedKey();
    	insertObjectMapping();
    	insertFieldMapping();
        TOOL_SeedAppSettingHandler.processFieldMapping();
    }
    
    public static void insertWOBilling() {
        insertExpression();
        List<SVMXC__SERVICEMAX_PROCESSES__C> existingExpressionList = [SELECT Id,SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'SVMX RULE' and SVMXC__ProcessID__c IN ('EXPR060') and SVMXC__ISSTANDARD__C = true];
        Map<String, String> expressionMap = new Map<String, String>();
        for(SVMXC__SERVICEMAX_PROCESSES__C expressionData : existingExpressionList){
            expressionMap.put(expressionData.SVMXC__ProcessID__c, expressionData.Id);
        }
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'WORK ORDER BILLING PROCESS'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> woBillingList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C woBilling = new SVMXC__SERVICEMAX_PROCESSES__C();
        woBilling.SVMXC__Name__c = 'Sample Work Order Proforma Invoice Process';
        woBilling.SVMXC__ProcessID__c = 'PINV001_Work_Order';
        woBilling.SVMXC__Module__c = expressionMap.get('EXPR060');
        woBilling.SVMXC__Submodule__c = expressionMap.get('EXPR060');
        woBilling.SVMXC__Node_Parent__c = null;
        woBilling.SVMXC__Process__c = null;
        woBilling.SVMXC__Capture_Log__c = true;
        woBilling.SVMXC__Email_On_Success__c = '';
        woBilling.SVMXC__Email_On_Error__c = '';
        woBilling.SVMXC__IsStandard__c = true;
        woBilling.SVMXC__Active__c = true;
        woBilling.SVMXC__Description__c = '';
        woBilling.SVMXC__Primary_Consolidation_Rule__c = 'Per Record';
        woBilling.SVMXC__Secondary_Consolidation_Rule__c = '';
        woBilling.SVMXC__Tertiary_Consolidation_Rule__c = '';
        woBilling.SVMXC__Include_Product__c = true;
        woBilling.SVMXC__Invoice_Scope__c = 'Work Order';
        woBilling.RecordTypeId = processRecordType.Id;
        woBilling.SVMXC__Installation_Key__c = seedKey;
        woBillingList.add(woBilling);
        
        insert woBillingList;
    }    
    
    public static testMethod void processWOBillingTestMethod() {
    	getSeedKey();
    	insertExpression();
        insertWOBilling();
        TOOL_SeedAppSettingHandler.processWOBilling();
    }
    
    public static void insertPMProcess() {
        insertObjectMapping();
        List<SVMXC__SERVICEMAX_PROCESSES__C> existingMappingList = [SELECT Id,SVMXC__MAPID__C from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'OBJECT MAPPING' and SVMXC__MAPID__C IN ('MAP023') and SVMXC__ISSTANDARD__C = true];
        Map<String, String> objectMap = new Map<String, String>();
        for(SVMXC__SERVICEMAX_PROCESSES__C mapData : existingMappingList){
            objectMap.put(mapData.SVMXC__MAPID__C, mapData.Id);
        }
        
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'PM PROCESS'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> pmProcessList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C pmProcess = new SVMXC__SERVICEMAX_PROCESSES__C();
        pmProcess.SVMXC__Name__c = 'Sample Preventive Maintenance Process';
        pmProcess.SVMXC__ProcessID__c = 'PREV001_SamplePMProcess';
        pmProcess.SVMXC__Active__c = true;
        pmProcess.SVMXC__Description__c = '';
        pmProcess.SVMXC__Frequency__c = 7;
        pmProcess.SVMXC__Module__c = null;
        pmProcess.SVMXC__Create_Work_Order__c = 'One Per Product';
        pmProcess.SVMXC__Node_Parent__c = objectMap.get('MAP023');
        pmProcess.SVMXC__Assign_Work_Order_To__c = 'Primary Technician';
        pmProcess.SVMXC__Assign_To_Service_Team__c = null;
        pmProcess.SVMXC__Target_Object_Name__c = 'Task';
        pmProcess.SVMXC__Process1__c = objectMap.get('MAP023');
        pmProcess.SVMXC__Process2__c = objectMap.get('MAP023');
        pmProcess.SVMXC__Process3__c = objectMap.get('MAP023');
        pmProcess.SVMXC__Include_Parent__c = true;
        pmProcess.SVMXC__Process__c = null;
        pmProcess.SVMXC__Assign_Case_To__c = '';
        pmProcess.SVMXC__Case_Assign_To_User__c = null;
        pmProcess.SVMXC__IsStandard__c = true;
        pmProcess.RecordTypeId = processRecordType.Id;
        pmProcess.SVMXC__Installation_Key__c = seedKey;
        pmProcessList.add(pmProcess);
        
        insert pmProcessList;
    }    
    
    public static testMethod void processPMProcessTestMethod() {
        getSeedKey();
        insertPMProcess();
        TOOL_SeedAppSettingHandler.processPMProcess();
    }
    
    public static void insertDCView() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'VIEW DEFINITION'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> dcViewList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C dcView = new SVMXC__SERVICEMAX_PROCESSES__C();
        dcView.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        dcView.SVMXC__Name__c = 'My Open Work Orders';
        dcView.SVMXC__ProcessID__c = 'WO_DC_View';
        dcView.SVMXC__Description__c = 'This view will display all work orders where \'Order Status\' is set to Open.';
        dcView.SVMXC__View_For__c = 'Grid And Map';
        dcView.SVMXC__Ownership_Type__c = 'User\'s Records';
        dcView.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c=\'Open\'';
        dcView.SVMXC__Values__c = 'Name,SVMXC__Company__r.Name,SVMXC__Contact__r.Name,SVMXC__Case__r.CaseNumber,SVMXC__Priority__c,SVMXC__Order_Status__c,SVMXC__Order_Type__c,SVMXC__Dispatch_Status__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Component__r.Name,SVMXC__Customer_Down_Status__c,SVMXC__Billing_Type__c';
        dcView.SVMXC__Advance_Expression__c = '';
        dcView.SVMXC__Rule_Type__c = 'Custom View';
        dcView.RecordTypeId = processRecordType.Id;
        dcView.SVMXC__IsStandard__c = true;
        dcViewList.add(dcView);
        
        insert dcViewList;
    }    
    
    public static testMethod void processDCViewsTestMethod() {
        insertDCView();
        TOOL_SeedAppSettingHandler.processDCViews();
    }
    
    public static testMethod void processDCViewConfigTestMethod() {
        insertDCView();
        TOOL_SeedAppSettingHandler.processDCViewConfig();
    }
    
    public static void insertQuickBookConfiguration() {
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name = 'EXPORT CONFIGURATION'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> quickBookConfigList = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C quickBookConfig = new SVMXC__SERVICEMAX_PROCESSES__C();
        quickBookConfig.SVMXC__Name__c = 'Export Work Order';
        quickBookConfig.SVMXC__ProcessID__c = 'EX_WO_001';
        quickBookConfig.SVMXC__IsDefault__c = true;
        quickBookConfig.SVMXC__Export_Configuration__c = '{"headerObjectAPIName":"SVMXC__Service_Order__c","childObjectAPIName":"SVMXC__Service_Order_Line__c","headerEligibilityCriteriaID":"EXPR076","childEligibilityCriteriaID":"EXPR077","filterDateField":"SVMXC__Closed_On__c","defaultSortingField":"SVMXC__Closed_On__c"}';
        quickBookConfig.SVMXC__IsStandard__c = true;
        quickBookConfig.SVMXC__Installation_Key__c = seedKey;
        quickBookConfig.RecordTypeId = processRecordType.Id;
        quickBookConfigList.add(quickBookConfig);
        
        insert quickBookConfigList;
    }    
    
    public static testMethod void processQuickBookConfigurationTestMethod() {
        getSeedKey();
        insertQuickBookConfiguration();
        TOOL_SeedAppSettingHandler.processQuickBookConfiguration();
    }
    
    public static void insertSmartObjects() {
		List<SVMXC__Object_Cache__c> smartObjectList = new List<SVMXC__Object_Cache__c>();
		SVMXC__Object_Cache__c smartObject = new SVMXC__Object_Cache__c();
        smartObject.SVMXC__Object_API_Name__c = 'Offer_Appointment_Request';
        smartObject.SVMXC__Object_Label__c = 'Offer Appointment Request';
        smartObject.SVMXC__Schema__c = '{"name":"Offer_Appointment_Request","label":"Appointment Offer Request","createable":"true"}';
        smartObject.SVMXC__Description__c = 'This is the smart object used to map Offer Appointment request for Linx for ServicePower Integration';
		smartObjectList.add(smartObject);

		insert smartObjectList;        
    }    
    
    public static testMethod void processSmartObjectsTestMethod() {
        insertSmartObjects();
        TOOL_SeedAppSettingHandler.processSmartObjects();
    }
    
    public static void insertAPLReceiveReturnShipment(){
        List<RecordType> aplRecordTypes = [Select Id, Name From RecordType where SobjectType = 'SVMXC__SERVICEMAX_PROCESSES__C' and Name IN ('Receiving Process','Initiate Return Process','Shipping Process')];
        Map<String, String> aplRecordTypeMap = new Map<String, String>();
        if(aplRecordTypes != null && aplRecordTypes.size() > 0){
            for(RecordType aplRecordType : aplRecordTypes){
                aplRecordTypeMap.put(aplRecordType.Name, aplRecordType.Id);
            }
        }
   		List<SVMXC__SERVICEMAX_PROCESSES__C> aplProcess = new List<SVMXC__SERVICEMAX_PROCESSES__C>();
        SVMXC__SERVICEMAX_PROCESSES__C aplReceive = new SVMXC__SERVICEMAX_PROCESSES__C();
        aplReceive.SVMXC__ProcessID__c = 'APL002_SAMPLE_RECEIPT';
        aplReceive.SVMXC__Name__c = 'Sample Receiving Process';
        aplReceive.SVMXC__Description__c = 'Sample Receipt Process for all RMAs. Work Orders are created on Receipt.';
        aplReceive.SVMXC__APL_Action_On_Unexpected_SN__c = 'ADD';
        aplReceive.SVMXC__APL_Action_On_Unexpected_Product__c = 'ADD';
        aplReceive.RecordTypeId = aplRecordTypeMap.get('Receiving Process');
        aplProcess.add(aplReceive);
        SVMXC__SERVICEMAX_PROCESSES__C aplRturn = new SVMXC__SERVICEMAX_PROCESSES__C();
        aplRturn.SVMXC__ProcessID__c = 'APL001_SAMPLE_RETURN';
        aplRturn.SVMXC__Name__c = 'SVMXSTD: Sample Return';
        aplRturn.SVMXC__Description__c = 'This is a sample APL returns process.';
        aplRturn.SVMXC__APL_Action_On_Unexpected_SN__c = '';
        aplRturn.SVMXC__APL_Action_On_Unexpected_Product__c = '';
        aplRturn.RecordTypeId = aplRecordTypeMap.get('Initiate Return Process');
        aplProcess.add(aplRturn);
        SVMXC__SERVICEMAX_PROCESSES__C aplShipment = new SVMXC__SERVICEMAX_PROCESSES__C();
        aplShipment.SVMXC__ProcessID__c = 'APL003_SAMPLE_SHIPMENT';
        aplShipment.SVMXC__Name__c = 'Sample Shipping Process';
        aplShipment.SVMXC__Description__c = 'This is a sample shipment process.';
        aplShipment.SVMXC__APL_Action_On_Unexpected_SN__c = '';
        aplShipment.SVMXC__APL_Action_On_Unexpected_Product__c = '';
        aplShipment.RecordTypeId = aplRecordTypeMap.get('Shipping Process');
        aplProcess.add(aplShipment);
        insert aplProcess;
        
    }
    public static testMethod void processAPLReceiveReturnShipmentTestMethod(){
        insertAPLReceiveReturnShipment();
        TOOL_SeedAppSettingHandler.processAPLReceiveReturnShipment();
    }
    
    public static void insertAPLSourceUpdates(){
        RecordType processRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__SERVICEMAX_CONFIG_DATA__C' and Name = 'Field Mapping'];
        List<SVMXC__SERVICEMAX_PROCESSES__C> existingAplList = [SELECT Id, SVMXC__ProcessID__c from SVMXC__SERVICEMAX_PROCESSES__C Where RecordType.Name = 'Receiving Process' and SVMXC__ISSTANDARD__C = true];
        Map<String, String> aplSourceMap = new Map<String, String>();
        for(SVMXC__SERVICEMAX_PROCESSES__C data : existingAplList){
        	aplSourceMap.put(data.SVMXC__ProcessID__c, data.Id);
        }
        SVMXC__ServiceMax_Config_Data__c aplSourceUpdates = new SVMXC__ServiceMax_Config_Data__c();
        aplSourceUpdates.SVMXC__Dispatch_Process__c = aplSourceMap.get('APL002_SAMPLE_RECEIPT');
        aplSourceUpdates.SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RECEIPT';
        aplSourceUpdates.SVMXC__Display_Value__c = 'Received';
        aplSourceUpdates.SVMXC__Action__c = 'Set';
        aplSourceUpdates.SVMXC__Target_Field_Name__c = 'SVMXC__Line_Status__c';
        aplSourceUpdates.RecordTypeId = processRecordType.Id;
        insert aplSourceUpdates;
    }
    public static testMethod void processAPLSourceUpdatesTestMethod(){
        insertAPLSourceUpdates();
        TOOL_SeedAppSettingHandler.processAPLSourceUpdates();
	}
     public static testMethod void processBatchLotSetCustInventoryTestMethod(){
        getSeedKey();
        TOOL_SeedAppSettingHandler.processBatchLotSetCustInventory();
	}
    public static void insertGoogleAPICustomSetting(){
        List<SVMXC__ServiceMax_Properties__c> googleAPICustomSettingList = new List<SVMXC__ServiceMax_Properties__c>();
        SVMXC__ServiceMax_Properties__c googleAPICustomSetting = new SVMXC__ServiceMax_Properties__c();
        googleAPICustomSetting.Name = 'MAPS_API_KEY_CORE';
        googleAPICustomSetting.SVMXC__Key__c = 'MAPS_API_KEY_CORE';
        googleAPICustomSetting.SVMXC__Value__c = '';
        googleAPICustomSettingList.add(googleAPICustomSetting);
        insert googleAPICustomSettingList; 
    }
    public static testMethod void processGoogleAPISettingsTestMethod(){
        insertGoogleAPICustomSetting();
        TOOL_SeedAppSettingHandler.createGoogleAPICustomSettings();
    }
}