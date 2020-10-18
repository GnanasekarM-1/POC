@isTest
Private with sharing class SFM_DeployNamedSearch_UT
 {
    static testMethod void SFM_DeployNamedSearch_UT_Test()
    {
       String RTypeId = '';
       RecordType Rtype;
       String RTypeId1 = '';
       RecordType Rtype1;
       
       Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Named Search' Limit 1];
       RTypeId = Rtype.Id;
       
       Rtype1 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Field Mapping' Limit 1];
       RTypeId1 = Rtype1.Id;
       
        
       SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
       process.SVMXC__Name__c = 'process001';
       process.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
       process.SVMXC__ProcessID__c = 'process001';
       process.SVMXC__SettingID__c = 'setting001';
       process.RecordTypeId = RTypeId;
       insert process;
       
       System.assertEquals(process!=null,true);
       
       SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
       process1.SVMXC__Name__c = 'process001';
       process1.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
       process1.SVMXC__ProcessID__c = 'process001';
       process1.SVMXC__SettingID__c = 'setting001';
       process1.RecordTypeId = RTypeId;
       insert process1;
       
       System.assertEquals(process1!=null,true);
       
       List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
       SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c();
       expDtl.RecordTypeId = RTypeId1;
       expDtl.SVMXC__Expression_Rule__c = process.Id;
       fields.add(expDtl);
       
       System.assertEquals(fields!=null,true);
       
       List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> ();
       SFM_WrapperDef.SFM_NamedSearchInfoDetail field1 = new SFM_WrapperDef.SFM_NamedSearchInfoDetail(process,fields);
       namedSearchDetails.add(field1);
       
       System.assertEquals(namedSearchDetails!=null,true);
       
       String userId;
       String groupId;
       String profileId;
       List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
       SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap();
       stringMap.add(stringMap1);
       
       System.assertEquals(stringMap!=null,true);
       
       SFM_WrapperDef.SFM_Request req = new SFM_WrapperDef.SFM_Request(userId,groupId,profileId,stringMap);
       
       List<SFM_WrapperDef.SFM_NamedSearchInfo> namedSearch = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
       SFM_WrapperDef.SFM_NamedSearchInfo namedSrchInfo2 = new SFM_WrapperDef.SFM_NamedSearchInfo(process,namedSearchDetails);
       namedSearch.add(namedSrchInfo2);
       
       System.assertEquals(namedSearch!=null,true);
       
       SFM_WrapperDef.SFM_Request_NamedSearchInfo request = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(namedSearch);
       request.request = req;
       
       System.assertEquals(request!=null,true);
       
       SFM_DeployNamedSearch deployMap = new SFM_DeployNamedSearch();
       SFM_WrapperDef.SFM_Response response = deployMap.SFM_DeployNamedSearch(request);
    }
    
    static testMethod void SFM_DeployNamedSearch_UT_Test1()
    {
       SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
       process.SVMXC__Name__c = 'process001';
       process.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
       process.SVMXC__ProcessID__c = 'process001';
       process.SVMXC__SettingID__c = 'setting001';
       
       System.assertEquals(process!=null,true);
       
       List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
       SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c();
       fields.add(expDtl);
       
       System.assertEquals(fields!=null,true);
       
       List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> ();
       SFM_WrapperDef.SFM_NamedSearchInfoDetail field1 = new SFM_WrapperDef.SFM_NamedSearchInfoDetail(process,fields);
       namedSearchDetails.add(field1);
       
       System.assertEquals(namedSearchDetails!=null,true);
       
       String userId;
       String groupId;
       String profileId;
       List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
       SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap();
       stringMap.add(stringMap1);
       
       System.assertEquals(stringMap!=null,true);
       
       SFM_WrapperDef.SFM_Request req = new SFM_WrapperDef.SFM_Request(userId,groupId,profileId,stringMap);
       
       List<SFM_WrapperDef.SFM_NamedSearchInfo> namedSearch = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
       SFM_WrapperDef.SFM_NamedSearchInfo namedSrchInfo2 = new SFM_WrapperDef.SFM_NamedSearchInfo(process,namedSearchDetails);
       namedSearch.add(namedSrchInfo2);
       
       SFM_WrapperDef.SFM_Request_NamedSearchInfo request = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(namedSearch);
       request.request = req;
       
       System.assertEquals(request!=null,true);
       
       SFM_DeployNamedSearch deployMap = new SFM_DeployNamedSearch();
       SFM_WrapperDef.SFM_Response response = deployMap.SFM_DeployNamedSearch(request);
    }
 }