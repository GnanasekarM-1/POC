@isTest
private with sharing class SFM_DeleteNamedSearch_UT 
 {
  static testMethod void SFM_deleteNamedSearch_UT_Test()
  { 
  
        //........Data Creation.........
        list<RecordType> records = [SELECT Id, Name,SobjectType,IsActive from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Named Search' limit 1];
        System.assertEquals(true, records != null);
        
        SVMXC__ServiceMax_Processes__c processobj = new SVMXC__ServiceMax_Processes__c();
        processobj.SVMXC__ProcessID__c='PROCESS12';
        processobj.SVMXC__SettingId__c = 'PROCESS12';
        processobj.SVMXC__MapID__c='PROCESS12';
        processobj.SVMXC__Name__c = 'PROCESS22';
        processobj.RecordTypeId=records[0].Id;
        processobj.SVMXC__Source_Object_Name__c='Account';
        processobj.SVMXC__Sequence__c=1.00;
        processobj.SVMXC__IsStandard__c=false;
        insert processobj;  
        System.assertEquals(true, processobj != null);
        
        SVMXC__ServiceMax_Processes__c processobj1 = new SVMXC__ServiceMax_Processes__c();
        processobj1.SVMXC__ProcessID__c='PROCESS11';
        processobj1.SVMXC__SettingId__c = 'PROCESS11';
        processobj1.SVMXC__MapID__c='PROCESS11';
        processobj1.SVMXC__Name__c = 'PROCESS21';
        processobj1.RecordTypeId=records[0].Id;
        processobj1.SVMXC__Module__c=processobj.id;
        insert processobj1;
        System.assertEquals(true, processobj1 != null);
        
        //list<RecordType> records = [SELECT Id, Name,SobjectType,IsActive from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' limit 1];
        
        List<String>  Stringlist = new List<String>();
        Stringlist.add(processobj.id);
        SFM_WrapperDef.SFM_StringListMap StrLstMap = new SFM_WrapperDef.SFM_StringListMap('RECORDID', Stringlist);
        List<SFM_WrapperDef.SFM_StringListMap> StrLstMap_List = new List<SFM_WrapperDef.SFM_StringListMap>();
        StrLstMap_List.add(StrLstMap);
        SFM_WrapperDef.SFM_Request Wrap_request = new SFM_WrapperDef.SFM_Request();

        //........class instantiation and calling various methods............
        list<SFM_WrapperDef.SFM_Request> requestLst = new list<SFM_WrapperDef.SFM_Request>();
        requestLst.add(Wrap_request);
        requestLst[0].StringListMap = StrLstMap_List;
        SFM_deleteNamedSearch  deleteobj= new SFM_deleteNamedSearch();
        deleteobj.deleteNamedSearch(requestLst[0]);
   }
 }