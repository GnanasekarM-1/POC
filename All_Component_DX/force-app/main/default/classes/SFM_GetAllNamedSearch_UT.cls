@isTest
Private with sharing class SFM_GetAllNamedSearch_UT
 {
   static testMethod void SFM_getAllNamedSearch_UT_Test()
   {
        //.........Creating data................
        list<RecordType> NamedSearchRType = [SELECT Id, Name, SobjectType,IsActive from RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND NAME='Named Search' limit 1];
        Account acc=new Account();
        acc.Name='TestAccount';
        insert acc;
        System.assertEquals(true, acc != null);
        
        SVMXC__ServiceMax_Processes__c processobj = new SVMXC__ServiceMax_Processes__c();
        processobj.RecordtypeId = NamedSearchRType[0].Id;
        processobj.SVMXC__ProcessID__c='PROCESS11';
        processobj.SVMXC__SettingId__c = 'PROCESS11';
        processobj.SVMXC__MapID__c='PROCESS11';
        processobj.SVMXC__Name__c = 'PROCESS22';
        insert processobj;
        System.assertEquals(true, processobj != null);
        
        SVMXC__ServiceMax_Processes__c processobj1 = new SVMXC__ServiceMax_Processes__c();
        processobj1.SVMXC__ProcessID__c='PROCESS11';
        processobj1.SVMXC__SettingId__c = 'PROCESS11';
        processobj1.SVMXC__MapID__c='PROCESS11';
        processobj1.SVMXC__Name__c = 'PROCESS22';
        processobj1.SVMXC__Description__c ='decsription';
        processobj1.SVMXC__Process__c =processobj.Id;
        processobj1.SVMXC__IsStandard__c =false;
        processobj1.SVMXC__Sequence__c =1;
        processobj1.SVMXC__IsDefault__C= true;
        processobj1.SVMXC__Active__c=true;
        processobj1.RecordtypeId = NamedSearchRType[0].Id;
        processobj1.SVMXC__Rule_Type__c='NAMEDSEARCH' ;
        processobj1.SVMXC__Source_Object_Name__c ='Account'; //'SVMXC__Installed_Product__c';
        insert processobj1;
        System.assertEquals(true, processobj1 != null);
        
                
        SVMXC__ServiceMax_Processes__c processobj2 = new SVMXC__ServiceMax_Processes__c();
        processobj2.SVMXC__SettingId__c = 'PROCESS11';
        processobj2.SVMXC__MapID__c='PROCESS11';
        processobj2.SVMXC__Name__c='LOOKUPCONFIG2';
        processobj2.SVMXC__Description__c ='decsription';
        processobj2.SVMXC__Process__c =processobj.Id;
        processobj2.SVMXC__IsStandard__c =false;
        processobj2.SVMXC__Sequence__c =1;
        processobj2.SVMXC__IsDefault__C= true;
        processobj2.SVMXC__ProcessID__c ='LOOKUPCONFIG2';
        processobj2.SVMXC__Active__c=true;
        processobj2.RecordtypeId = NamedSearchRType[0].Id;
        processobj2.SVMXC__Rule_Type__c='LOOKUPCONFIG' ;  
        processobj2.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        insert processobj2;
        System.assertEquals(true, processobj2 != null);
        
        SVMXC__ServiceMax_Processes__c processobj3 = new SVMXC__ServiceMax_Processes__c();
        processobj2.SVMXC__SettingId__c = 'PROCESS11';
        processobj2.SVMXC__MapID__c='PROCESS11';
        processobj3.SVMXC__Name__c='LOOKUPCONFIG2';
        processobj3.SVMXC__Description__c ='decsription';
        processobj3.SVMXC__Process__c =processobj.Id;
        processobj3.SVMXC__IsStandard__c =false;
        processobj3.SVMXC__Sequence__c =1;
        processobj3.SVMXC__IsDefault__C= true;
        processobj3.SVMXC__ProcessID__c ='LOOKUPCONFIG2';
        processobj3.SVMXC__Active__c=true;
        processobj3.RecordtypeId = NamedSearchRType[0].Id;
        processobj3.SVMXC__Rule_Type__c='NAMEDSEARCH' ;  
        processobj3.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        insert processobj3;
        System.assertEquals(true, processobj3 != null);
        
        SFM_WrapperDef.SFM_StringMap StrMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME',processobj1.SVMXC__Source_Object_Name__c );
        SFM_WrapperDef.SFM_StringMap StrMap2 = new SFM_WrapperDef.SFM_StringMap('SEARCHTYPE',processobj2.SVMXC__Rule_Type__c);
        SFM_WrapperDef.SFM_StringMap StrMap3 = new SFM_WrapperDef.SFM_StringMap('SEARCHTYPE',processobj3.SVMXC__Rule_Type__c);
        list<SFM_WrapperDef.SFM_StringMap> StrMapList1 = new list<SFM_WrapperDef.SFM_StringMap>();
        list<SFM_WrapperDef.SFM_StringMap> StrMapList2 = new list<SFM_WrapperDef.SFM_StringMap>();
        list<SFM_WrapperDef.SFM_StringMap> StrMapList3 = new list<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        StrMapList1.add(StrMap1);
        StrMapList2.add(StrMap2);
        StrMapList3.add(StrMap3);
        SFM_WrapperDef.SFM_Request prequest1= new SFM_WrapperDef.SFM_Request();
        prequest1.setstringMap(StrMapList1);
        SFM_WrapperDef.SFM_Request prequest2= new SFM_WrapperDef.SFM_Request();
        prequest2.setstringMap(StrMapList2);
        SFM_WrapperDef.SFM_Request prequest3= new SFM_WrapperDef.SFM_Request();
        prequest3.setstringMap(StrMapList3);   
        
        //.............class instantiation and calling methods...............
        SFM_getAllNamedSearch SearchObj = new SFM_getAllNamedSearch();
        SearchObj.getAllNamedSearch(prequest1);
        SearchObj.getAllNamedSearch(prequest2);
        SearchObj.getAllNamedSearch(prequest3);
    }
 }