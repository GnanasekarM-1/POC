@isTest
private with sharing class INTF_ServiceEventUtility_UT {
    static testMethod void INTF_ServiceEventUtilityTest1() 
    {
        SVMXC__ServiceMax_Processes__c pro = new SVMXC__ServiceMax_Processes__c();
        pro.SVMXC__Values__c = '{"wizards":["Checklist","Checklist for iPhone"],"sfms":["sfm_for_unit_test"],"sfactions":["other_action_for_UT"]}';
        pro.RecordTypeId = [select id from RecordType where Name = 'Application Profile'][0].Id;
        pro.SVMXC__ProcessID__c = 'iPad';
        pro.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        insert pro;
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        INTF_WebServicesDef.SVMXClient cl = new INTF_WebServicesDef.SVMXClient();
        cl.clientType = 'iPad';
        inputRequest.clientInfo.add(cl);
        
        inputRequest.eventType = 'INITIAL_SYNC';
        inputRequest.eventName = 'SFM_METADATA';
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
        
        cl.clientType = 'MFL';
        
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_METADATA';
        inputRequest.value = '';
        clsEventUtils.eventController(inputRequest);
        
        cl.clientType = 'Android';
        clsEventUtils.eventController(inputRequest);
        
        ID docTemplateID = [select id from SVMXC__Doc_Template__c LIMIT 1].ID;  
        set<Id> docIdSet = new set<Id>();
        docIdSet.add(docTemplateID);
          
        Sync_Utility clsUtility = new Sync_Utility();
        INTF_WebServicesDef.SVMXMap wrpDocTemp = clsUtility.getServiceFlowDocTemplates(docIdSet);
        
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'OBJECT_PERMISSIONS';
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest2() 
    {
        SVMXC__ServiceMax_Processes__c pro = new SVMXC__ServiceMax_Processes__c();
        pro.SVMXC__Values__c = '{"wizards":["Checklist","Checklist for iPhone"],"sfms":["sfm_for_unit_test"],"sfactions":["other_action_for_UT"]}';
        pro.RecordTypeId = [select id from RecordType where Name = 'Application Profile'][0].Id;
        pro.SVMXC__ProcessID__c = 'iPad';
        pro.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        insert pro;
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        inputRequest.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        INTF_WebServicesDef.SVMXClient cl = new INTF_WebServicesDef.SVMXClient();
        cl.clientType = 'iPhone';
        inputRequest.clientInfo.add(cl);
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFW_METADATA';
        System.assertEquals(true, inputRequest != null);
        Sync_Utility clsUtility = new Sync_Utility();
        Map<Id, SVMXC__ServiceMax_Processes__c> processAccess = clsUtility.getAllowedSFW(null);
        response.valueMap  = clsUtility.getServiceFlowWizards(processAccess, '16.49.002');
        clsEventUtils.eventController(inputRequest);
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'MOBILE_DEVICE_TAGS';
        clsEventUtils.eventController(inputRequest);
            
        //inserting test data for Device Mobile Setting
        INTF_DataUtilityServices_UT.insertConfigData();
       
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'MOBILE_DEVICE_SETTINGS';
        clsEventUtils.eventController(inputRequest);
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_PAGEDATA';
        list<String> processedPageIds = new list<String>();
        processedPageIds.add('PAGE001');
        inputRequest.values = processedPageIds;
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest3() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC__ServiceMax_Processes__c process1 = [select Id from SVMXC__ServiceMax_Processes__c where RecordType.Name='Target Manager' Limit 1];
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_OBJECT_DEFINITIONS';
        inputRequest.values = new List<String>();
        inputRequest.values.add(process1.Id);
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_BATCH_OBJECT_DEFINITIONS';
        clsEventUtils.eventController(inputRequest);
        //for SFM SEARCH
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_SEARCH';
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest4() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'GROUP_PROFILE';
        inputRequest.eventName = 'VALIDATE_PROFILE';
        System.assertEquals(true, inputRequest != null);
        inputRequest.value = '';
            
        //inserting test data for Device Mobile Setting
        INTF_DataUtilityServices_UT.insertConfigData();
       
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest5() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_PICKLIST_DEFINITIONS';
        System.assertEquals(true, inputRequest != null);
        inputRequest.values = new List<String>{'SVMXC__Service_Order__c'};
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest6() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'PRICE_CALC_OBJECTS';
        System.assertEquals(true, inputRequest != null);
        inputRequest.values = new List<String>{'SVMXC__Service_Order__c'};
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest7() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'PRICE_CALC_CODE_SNIPPET';
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
    }

    static testMethod void INTF_ServiceEventUtilityTest8() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'CODE_SNIPPET';
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void INTF_ServiceEventUtilityTest9() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SVMX_LIBRARY';
        List<String> lstClientVersion = new List<String>{'iosversion:7.0', 'appversion:13.1.0', 'deviceversion:x86_64'};
        INTF_WebServicesDef.SVMXClient client = new INTF_WebServicesDef.SVMXClient();
        client.clientType = 'iPad';
        client.clientInfo = lstClientVersion;
        inputRequest.clientInfo = new List<INTF_WebServicesDef.SVMXClient>();
        inputRequest.clientInfo.add(client);
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void IpadLog_Test9() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'MOBILE_CLIENT_LOGS';
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.saveClientLogs(inputRequest);
    }
    
    static testMethod void testConfigLastModifiedDate() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SYNC_CONFIG_LMD';
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
    }
    
    static testMethod void GetSFMObjectNames() 
    {
        INTF_ServiceEventUtility clsEventUtils = new INTF_ServiceEventUtility();
        INTF_WebServicesDef.INTF_SFMRequest inputRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC__ServiceMax_Processes__c process1 = [select Id from SVMXC__ServiceMax_Processes__c where RecordType.Name='Target Manager' Limit 1];
        inputRequest.eventType = 'SYNC';
        inputRequest.eventName = 'SFM_OBJECT_NAMES';
        inputRequest.values = new List<String>();
        inputRequest.values.add(process1.Id);
        System.assertEquals(true, inputRequest != null);
        clsEventUtils.eventController(inputRequest);
    }
 }