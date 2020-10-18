@isTest
Private with sharing class SFM_DeployMapping_UT
 {
    static testMethod void SFM_DeployMapping_UT_Test()
    {
        String RTypeId = '';
       RecordType Rtype;
       String RTypeId1 = '';
       RecordType Rtype1;
       
       Rtype1 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Object Mapping' Limit 1];
       RTypeId1 = Rtype1.Id;
       
       Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Field Mapping' Limit 1];
       RTypeId = Rtype.Id;
        
       SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
       process1.SVMXC__Name__c = 'process001';
       process1.SVMXC__Rule_Type__c = 'Named Expression';
       process1.SVMXC__ProcessID__c = 'process001';
       process1.SVMXC__SettingID__c = 'setting001';
       process1.RecordTypeId = RTypeId1;
       process1.SVMXC__MapID__c = 'MAPTest001';
       
       insert process1;  
       System.assertEquals(true, process1 != null);
       
       SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c();
       process2.SVMXC__Name__c = 'process002';
       process2.SVMXC__Rule_Type__c = 'Named Expression';
       process2.SVMXC__ProcessID__c = 'process022';
       process2.SVMXC__SettingID__c = 'setting001';
       process2.RecordTypeId = RTypeId1;
       process2.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
       process1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
       process2.SVMXC__MapID__c = 'MAPTestMAPID';
       
       insert process2;
       System.assertEquals(true, process1 != null);
       SFM_WrapperDef.SFM_Request_ObjectMap request = new SFM_WrapperDef.SFM_Request_ObjectMap();

       List<SFM_WrapperDef.SFM_ObjectMap> ObjMapLst = new List<SFM_WrapperDef.SFM_ObjectMap>();
       SFM_WrapperDef.SFM_ObjectMap objectMapObj = new SFM_WrapperDef.SFM_ObjectMap();
       SFM_WrapperDef.SFM_ObjectMap objectMapObj1 = new SFM_WrapperDef.SFM_ObjectMap();

       objectMapObj.objectMap = process2;
       objectMapObj.fields = new List<SFM_WrapperDef.SFM_FieldMapping>();
       objectMapObj1.objectMap = process1;

       ObjMapLst.add(objectMapObj);
       ObjMapLst.add(objectMapObj1);

       request.objects = ObjMapLst;

       SFM_WrapperDef.SFM_Request requestObj = new SFM_WrapperDef.SFM_Request();
       request.request = requestObj;

       SFM_DeployMapping deployMap = new SFM_DeployMapping();
       deployMap.SFM_DeployMapping(request);
       process1.SVMXC__IsStandard__c = true;
       update process1;
        objectMapObj1.objectMap = null;
        objectMapObj1.objectMap = process1;
        ObjMapLst.clear();
        ObjMapLst.add(objectMapObj1);
        request.objects = ObjMapLst;
        deployMap.SFM_DeployMapping(request);
        
     }
 }