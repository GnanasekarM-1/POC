@isTest
Private with sharing class SFM_DeleteExpression_UT
 {
   static testMethod void SFM_deleteExpression_UT_Test()
   {
        //.......Data Creation........
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        list<RecordType> RtypeLst = [SELECT Id, Name,SobjectType,IsActive from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name='Named Search' limit 1];
        System.assertEquals(true, RtypeLst != null);
        
        processObj.RecordTypeId=RtypeLst[0].Id;
        processObj.SVMXC__ProcessID__c='PROCESS11';
        processObj.SVMXC__SettingId__c = 'PROCESS11';
        processObj.SVMXC__MapID__c='PROCESS11';
        processObj.SVMXC__Name__c = 'PROCESS22';
        
        insert processObj;
        System.assertEquals(true, processObj != null);
        
        List<String>  Stringlist = new List<String>();
        Stringlist.add(processObj.id);
        SFM_WrapperDef.SFM_StringListMap StrMap = new SFM_WrapperDef.SFM_StringListMap('RECORDID', Stringlist);
        List<SFM_WrapperDef.SFM_StringListMap> StrMapLst = new List<SFM_WrapperDef.SFM_StringListMap>();
        StrMapLst.add(StrMap);
        SFM_WrapperDef.SFM_Request reqmap = new SFM_WrapperDef.SFM_Request();
        
        //.........class instantiation and calling methods..........
        list<SFM_WrapperDef.SFM_Request>  requestLst = new list<SFM_WrapperDef.SFM_Request> ();
        requestLst.add(reqmap);
        System.assertEquals(true, requestLst != null);
        
        requestLst[0].StringListMap = StrMapLst;
        SFM_deleteExpression DelExpObj= new SFM_deleteExpression();
        DelExpObj.SFM_deleteExpression(requestLst[0]);
  }
  static testMethod void SFM_deleteExpression_UT_Test1()
   {
        //.......Data Creation........
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        list<RecordType> RtypeLst = [SELECT Id, Name,SobjectType,IsActive from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name='Named Search' limit 1];
        System.assertEquals(true, RtypeLst != null);
        
        processObj1.RecordTypeId=RtypeLst[0].Id;
        processObj1.SVMXC__ProcessID__c='PROCESS11';
        processObj1.SVMXC__SettingId__c = 'PROCESS11';
        processObj1.SVMXC__MapID__c='PROCESS11';
        processObj1.SVMXC__Name__c = 'PROCESS22';
        
        insert processObj1;
        System.assertEquals(true, processObj1 != null);
        
        List<String>  Stringlist = new List<String>();
        Stringlist.add(processObj1.id);
        SFM_WrapperDef.SFM_StringListMap StrMap = new SFM_WrapperDef.SFM_StringListMap('RECORDID', Stringlist);
        List<SFM_WrapperDef.SFM_StringListMap> StrMapLst = new List<SFM_WrapperDef.SFM_StringListMap>();
        StrMapLst.add(StrMap);
        SFM_WrapperDef.SFM_Request reqmap = new SFM_WrapperDef.SFM_Request();
        
        //.........class instantiation and calling methods..........
        list<SFM_WrapperDef.SFM_Request>  requestLst = new list<SFM_WrapperDef.SFM_Request> ();
        requestLst.add(reqmap);
        System.assertEquals(true, requestLst != null);
        
        requestLst[0].StringListMap = StrMapLst;
        SFM_deleteExpression DelExpObj= new SFM_deleteExpression();
        DelExpObj.SFM_deleteExpression(requestLst[0]);
  }
  static testMethod void SFM_deleteExpression_UT_Test2()
   {
        //.......Data Creation........
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        list<RecordType> RtypeLst = [SELECT Id, Name,SobjectType,IsActive from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name='Named Search' limit 1];
        System.assertEquals(true, RtypeLst != null);
        
        processObj1.RecordTypeId=RtypeLst[0].Id;
        processObj1.SVMXC__ProcessID__c='PROCESS11';
        processObj1.SVMXC__SettingId__c = 'PROCESS11';
        processObj1.SVMXC__MapID__c='PROCESS11';
        processObj1.SVMXC__Name__c = 'PROCESS22';
        
        insert processObj1;
        System.assertEquals(true, processObj1 != null);
        
        List<String>  Stringlist = new List<String>();
        Stringlist.add(processObj1.id);
        SFM_WrapperDef.SFM_StringListMap StrMap = new SFM_WrapperDef.SFM_StringListMap('RECORDID', Stringlist);
        List<SFM_WrapperDef.SFM_StringListMap> StrMapLst = new List<SFM_WrapperDef.SFM_StringListMap>();
        StrMapLst.add(StrMap);
        SFM_WrapperDef.SFM_Request reqmap = new SFM_WrapperDef.SFM_Request();
        
        //.........class instantiation and calling methods..........
        list<SFM_WrapperDef.SFM_Request>  requestLst = new list<SFM_WrapperDef.SFM_Request> ();
        requestLst.add(reqmap);
        System.assertEquals(true, requestLst != null);
        
        requestLst[0].StringListMap = StrMapLst;
        SFM_deleteExpression DelExpObj= new SFM_deleteExpression();
        DelExpObj.SFM_deleteExpression(null);
  }
 }