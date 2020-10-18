@isTest(seeAllData=true)
public class SGAT_ValidateCache_UT {
  //NOT IN USE ANY-MORE
  //This class supposed to be deleted in future.
  /*
    static testMethod void testValidateCache()
    {
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addDays(1))));

      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      sgateValidateCache.validateCache(request);
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode',String.valueOf(sgateValidateCache.getTagsHashCode())));
      sgateValidateCache.validateCache(request);

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','SETTINGS'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithEmptyRequest() {
      List<SGAT_WebServicesDef.SVMXMap> valueMap1 = new List<SGAT_WebServicesDef.SVMXMap>();
      valueMap1.add(new SGAT_WebServicesDef.SVMXMap('test','test'));
      SGAT_WebServicesDef.SGAT_Request request1 = new SGAT_WebServicesDef.SGAT_Request(valueMap1);

      Test.StartTest();
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      sgateValidateCache.validateCache(request1);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithEmptySyncTimeRequest() {
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      SGAT_WebServicesDef.SGAT_Request request1 = new SGAT_WebServicesDef.SGAT_Request(valueMap);

      Test.StartTest();
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      sgateValidateCache.validateCache(request1);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithOldercofigTime()
    {
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addDays(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));

      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('objectHashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedWizard()
    {
      update [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Wizard'  limit 10];
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));

      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);

      update [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Wizard Access' AND SVMXC__Access_Configuration_Profile__c =: configProfile[0].Id  limit 10];

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedSFA()
    {
      update [SELECT Id FROM SVMXC__SM_SFA_Process__c limit 10];
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));
 
      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);
 
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }
 
    static testMethod void testValidateCacheWithChangedExpressionForSFA()
    {
      List<SVMXC__SM_SFA_Process__c> lstSFA = [SELECT SVMXC__SM_Expression__c FROM SVMXC__SM_SFA_Process__c where SVMXC__SM_Expression__c != null AND SVMXC__SM_Expression__r.SVMXC__IsStandard__c = false limit 10];
      if(lstSFA != null && lstSFA.size() > 0) {
        update [select Id from SVMXC__ServiceMax_Processes__c where id =: lstSFA[0].SVMXC__SM_Expression__c];
      }
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));
 
      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);
 
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }
 
    static testMethod void testValidateCacheWithChangedExpressionDetailForSFA()
    {
      List<SVMXC__SM_SFA_Process__c> lstSFA = [SELECT SVMXC__SM_Expression__c FROM SVMXC__SM_SFA_Process__c where SVMXC__SM_Expression__c != null AND SVMXC__SM_Expression__r.SVMXC__IsStandard__c = false limit 10];
      if(lstSFA != null && lstSFA.size() > 0) {
        update [select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: lstSFA[0].SVMXC__SM_Expression__c];
      }
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));
 
      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);
 
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedSFM()
    {
      update [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' limit 10];
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));

      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);

      update [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Service Flow Access' AND SVMXC__Access_Configuration_Profile__c =: configProfile[0].Id  limit 10];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedSFMSearch()
    {
      update [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH' limit 10];
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));

      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);

      update [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Search Access' AND SVMXC__Access_Configuration_Profile__c =: configProfile[0].Id  limit 10];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedMobileConfig()
    {
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      String profileId = configProfile[0].Id;
      update [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Access_Configuration_Profile__c != null AND SVMXC__RecordType_Name__c = 'Mobile Configuration' AND SVMXC__Access_Configuration_Profile__c =: profileId limit 10];
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',profileId));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));

      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','SETTINGS'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedSettings()
    {
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      String profileId = configProfile[0].Id;
      update [Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Setting Value' AND SVMXC__Setting_ID__r.SVMXC__Search_Order__c IN ('Global', 'Group, Global', 'Group,Global') AND SVMXC__Setting_Configuration_Profile__c = :profileId limit 10];
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',profileId));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addHours(-1))));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode','300'));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('tagsHashCode','300'));

      Test.StartTest();
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      sgateValidateCache.validateCache(request);

      valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','SETTINGS'));
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedCodeSnippets()
    {
        List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
        String profileId = configProfile[0].Id;
        SVMXC__Page_Layout__c pageLayout = new SVMXC__Page_Layout__c();
        insert pageLayout;
        SVMXC__Page_Layout_Detail__c pageDetail = new SVMXC__Page_Layout_Detail__c();
        pageDetail.SVMXC__Detail_Type__c = 'Button';
        pageDetail.SVMXC__Page_Layout__c = pageLayout.Id;
        insert pageDetail;

        SVMXC__SFM_Event__c sfmEvent = new SVMXC__SFM_Event__c();
        sfmEvent.SVMXC__Page_Layout_Detail__c = pageDetail.Id;
        sfmEvent.SVMXC__Event_Call_Type__c = 'JAVASCRIPT';
        insert sfmEvent;

        SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
        List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();

        valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',profileId));
        valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addDays(-1))));

        Test.StartTest();
        valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
        SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
        SGAT_WebServicesDef.SGAT_Response response = sgateValidateCache.validateCache(request);
        system.debug('Response: ' + response);
        system.assert(response != null);
        system.assert(response.valueMap.size() > 0);
        Set<String> valuemapKeys = new Set<String>();
        for (SGAT_WebServicesDef.SVMXMap vm: response.valueMap) {
            if (vm.key == 'componentName') {
                valuemapKeys.addAll(vm.values);
            }
        }
        system.debug('Keys: ' + valuemapKeys);
        system.assert(valuemapKeys.contains('CODE_SNIPPET'));

        valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','SETTINGS'));
        response = sgateValidateCache.validateCache(request);

        Test.StopTest();
    }

    static testMethod void testValidateCacheWithChangedApplicationFilters()
    {
        List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
        String profileId = configProfile[0].Id;
        SVMXC__ServiceMax_Processes__c applicationFilter = new SVMXC__ServiceMax_Processes__c();
        applicationFilter.SVMXC__ProcessID__c = 'testingDataProcessId';
        applicationFilter.SVMXC__Values__c = 'testingDataProcessValues';
        applicationFilter.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Application Profile'][0].Id;
        applicationFilter.SVMXC__IsStandard__c = true;
        insert applicationFilter;

        SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
        List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();

        valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',profileId));
        valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addDays(-1))));

        Test.StartTest();
        valueMap.add(new SGAT_WebServicesDef.SVMXMap('hashCode',String.valueOf(sgateValidateCache.getDescribeHashCode())));
        SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
        SGAT_WebServicesDef.SGAT_Response response = sgateValidateCache.validateCache(request);
        system.debug('Response: ' + response);
        system.assert(response != null);
        system.assert(response.valueMap.size() > 0);
        Set<String> valuemapKeys = new Set<String>();
        for (SGAT_WebServicesDef.SVMXMap vm: response.valueMap) {
            if (vm.key == 'componentName') {
                valuemapKeys.addAll(vm.values);
            }
        }
        system.debug('Keys: ' + valuemapKeys);
        system.assert(valuemapKeys.contains('APPLICATION_FILTER'));

        valueMap.add(new SGAT_WebServicesDef.SVMXMap('BATCH-API','SETTINGS'));
        response = sgateValidateCache.validateCache(request);
        sgateValidateCache.addCallBackToResponse(1, new List<String>{'Account', 'Case', 'Product2'}, response.valueMap);
        Test.StopTest();

    }

    static testMethod void testValidateCacheWithCallBack() {
      SGAT_ValidateCache sgateValidateCache = new SGAT_ValidateCache();
      List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      List<SVMXC__ServiceMax_Config_Data__c> configProfile = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Configuration_Type__c = 'Group' AND SVMXC__IsDefault__c = true];
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('svmxProfileId',configProfile[0].Id));
      valueMap.add(new SGAT_WebServicesDef.SVMXMap('lastSyncTime',String.valueOf(DateTime.now().addDays(1))));
      SGAT_WebServicesDef.SVMXMap batchAPI = new SGAT_WebServicesDef.SVMXMap('BATCH-API','OBJ-PARAM-SFM');
      SGAT_WebServicesDef.SVMXMap callBackMap = new SGAT_WebServicesDef.SVMXMap('CALLBACK','true');
      callBackMap.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      callBackMap.valueMap.add(new SGAT_WebServicesDef.SVMXMap('STEP','1', new List<String>{'Account', 'Case', 'Product2'}));
      batchAPI.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
      batchAPI.valueMap.add(callBackMap);
      batchAPI.valueMap.add(new SGAT_WebServicesDef.SVMXMap('RESOURCE-PERCENT', '20'));
      valueMap.add(batchAPI);
      SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);
      Test.StartTest();
      sgateValidateCache.validateCache(request);
      Test.StopTest();
    }
    */
}