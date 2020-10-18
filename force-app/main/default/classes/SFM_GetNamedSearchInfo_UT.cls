@isTest(SeeAllData=true)
private class SFM_GetNamedSearchInfo_UT{
    static testMethod void SFM_getNamedSearchInfo_Test()
    {
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Named Search'];
        RecordType configRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' limit 1];
        SVMXC__ServiceMax_Processes__c processobj1 = new SVMXC__ServiceMax_Processes__c();
        processobj1.RecordTypeId = lstRecType[0].Id;
        processobj1.SVMXC__Name__C = 'Headerprocess';
        processobj1.SVMXC__Description__c ='this is header process';
        processobj1.SVMXC__ProcessID__c = 'process001';
        processobj1.SVMXC__Rule_Type__c ='Automatic';
        processobj1.SVMXC__Active__c = true;
        insert processobj1;
        System.assertEquals(true, processobj1 != null);
           
        SVMXC__ServiceMax_Processes__c processobj2 = new SVMXC__ServiceMax_Processes__c();
        processobj2.RecordTypeId = lstRecType[0].Id ;                                                //required
        processobj2.SVMXC__ProcessID__c='PROCESS11';
        processobj2.SVMXC__SettingId__c = 'PROCESS11';
        processobj2.SVMXC__MapID__c='PROCESS11';
        processobj2.SVMXC__Name__c = 'PROCESS22';
        processobj2.SVMXC__Process__c = processobj1.Id ;
        processobj2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processobj2.SVMXC__Module__c = processobj1.Id ;
        processobj2.SVMXC__IsDefault__C = false ;
        processobj2.SVMXC__Rule_Type__c='SRCH_OBJECT';
        processobj2.SVMXC__Parent_Object_Criteria__c = 'Name != null';
        insert processobj2;// We should use Test.startTest and Test.stopTest method
        System.assertEquals(true, processobj2 != null);
            
        SVMXC__ServiceMax_Processes__c processobj3 = new SVMXC__ServiceMax_Processes__c();
        processobj3.RecordTypeId = lstRecType[0].Id ;                                                //required
        processobj3.SVMXC__Name__c = 'Search Criteria';
        processobj3.SVMXC__ProcessID__c='SearchCriteriaPROCESS11';
        processobj3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processobj3.SVMXC__Module__c = processobj1.Id ;
        processobj3.SVMXC__Rule_Type__c='SRCH_CRITERIA';
        insert processobj3;         
        
        SVMXC__ServiceMax_Config_Data__c configDataObj1 = new SVMXC__ServiceMax_Config_Data__c();
        configDataObj1.SVMXC__Search_Object_Field_Type__c = 'Result';
        configDataObj1.SVMXC__Expression_Rule__c = processobj2.Id ;
        configDataObj1.RecordTypeId = configRecType.id;
        configDataObj1.SVMXC__Expression_Type__c =  'SRCH_Object_Fields';
        SVMXC__ServiceMax_Config_Data__c configDataObj2 = new SVMXC__ServiceMax_Config_Data__c();
        configDataObj2.SVMXC__Search_Object_Field_Type__c = 'Buble';
        configDataObj2.SVMXC__Expression_Rule__c = processobj2.Id ;
        configDataObj2.RecordTypeId = configRecType.id;
        configDataObj2.SVMXC__Expression_Type__c =  'SRCH_Object_Fields';
        SVMXC__ServiceMax_Config_Data__c configDataObj3 = new SVMXC__ServiceMax_Config_Data__c();
        configDataObj3.SVMXC__Search_Object_Field_Type__c = 'Search';
        configDataObj3.SVMXC__Expression_Rule__c = processobj2.Id ;
        configDataObj3.RecordTypeId = configRecType.id;
        configDataObj3.SVMXC__Expression_Type__c =  'SRCH_Object_Fields';
        //
        SVMXC__ServiceMax_Config_Data__c configDataObj4 = new SVMXC__ServiceMax_Config_Data__c();
        configDataObj4.SVMXC__Expression_Rule__c = processobj2.Id ;
        configDataObj4.RecordTypeId = configRecType.id;
        configDataObj4.SVMXC__Expression_Type__c =  'LKUP_Prefilter_Criteria';
        
        SVMXC__ServiceMax_Config_Data__c configDataObj5 = new SVMXC__ServiceMax_Config_Data__c();
        configDataObj5.SVMXC__Expression_Rule__c = processobj3.Id ;
        configDataObj5.RecordTypeId = configRecType.id;
        configDataObj5.SVMXC__Expression_Type__c =  'LKUP_Criteria';
        
        
        List<SVMXC__ServiceMax_Config_Data__c> LstconfigDataObj = new List<SVMXC__ServiceMax_Config_Data__c>();
        LstconfigDataObj.add(configDataObj1);
        LstconfigDataObj.add(configDataObj2);
        LstconfigDataObj.add(configDataObj3);
        LstconfigDataObj.add(configDataObj4);
        LstconfigDataObj.add(configDataObj5);
        insert LstconfigDataObj ;
        System.assertEquals(true, LstconfigDataObj != null);
        System.assertNotEquals(configDataObj1, configDataObj2 );
        System.assertNotEquals(configDataObj3, configDataObj2 );
        System.assertNotEquals(configDataObj3, configDataObj1 );
          
        SFM_WrapperDef.SFM_StringMap stringMap = new SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'RECORDID' ;
        stringMap.value = processobj1.Id ;
        
        list<SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        request.stringMap = lstStringMap;
        SFM_getNamedSearchInfo nameSearchInfo = new SFM_getNamedSearchInfo();
        nameSearchInfo.getNamedSearchInfo(request);
        
    }//method
}//class