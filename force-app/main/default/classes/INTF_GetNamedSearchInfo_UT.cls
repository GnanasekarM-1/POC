@isTest
private class INTF_GetNamedSearchInfo_UT
{
    static testMethod void INTF_getNamedSearchInfo_Test()
    {
    //-----------------DATA PREPARATION PART----------------------------------------------------------------------------//
       
           List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Named Search'];
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
           processobj2.SVMXC__Sequence__c = 12345 ;
           processobj2.SVMXC__IsDefault__C = false ;
           processobj2.SVMXC__Rule_Type__c='NAMEDSEARCH';
           insert processobj2;// We should use Test.startTest and Test.stopTest method
           System.assertEquals(true, processobj2 != null);
         
          SVMXC__ServiceMax_Config_Data__c configDataObj1 = new SVMXC__ServiceMax_Config_Data__c();
          configDataObj1.SVMXC__Search_Object_Field_Type__c = 'Result';
          configDataObj1.SVMXC__Expression_Rule__c = processobj1.Id ;
          SVMXC__ServiceMax_Config_Data__c configDataObj2 = new SVMXC__ServiceMax_Config_Data__c();
          configDataObj2.SVMXC__Search_Object_Field_Type__c = 'Buble';
          configDataObj2.SVMXC__Expression_Rule__c = processobj1.Id ;
          SVMXC__ServiceMax_Config_Data__c configDataObj3 = new SVMXC__ServiceMax_Config_Data__c();
          configDataObj3.SVMXC__Search_Object_Field_Type__c = 'Search';
          configDataObj3.SVMXC__Expression_Rule__c = processobj1.Id ;
          List<SVMXC__ServiceMax_Config_Data__c> LstconfigDataObj = new List<SVMXC__ServiceMax_Config_Data__c>();
          LstconfigDataObj.add(configDataObj1);
          LstconfigDataObj.add(configDataObj2);
          LstconfigDataObj.add(configDataObj3);
          insert LstconfigDataObj ;
          System.assertEquals(true, LstconfigDataObj != null);
          System.assertNotEquals(configDataObj1, configDataObj2 );
          System.assertNotEquals(configDataObj3, configDataObj2 );
          System.assertNotEquals(configDataObj3, configDataObj1 );
          
          INTF_WebServicesDef.INTF_StringMap wrapper_stringMapObj1 = new INTF_WebServicesDef.INTF_StringMap();
          wrapper_stringMapObj1.key = 'RECORDID' ;
          wrapper_stringMapObj1.value = processobj1.Id ;
          
          INTF_WebServicesDef.INTF_StringMap wrapper_stringMapObj2 = new INTF_WebServicesDef.INTF_StringMap();
          wrapper_stringMapObj2.key = 'RECORDID' ;
          wrapper_stringMapObj2.value = processobj2.Id ;
          
          List<INTF_WebServicesDef.INTF_StringMap> wrapperList_stringMapObj1 = new List<INTF_WebServicesDef.INTF_StringMap>();
          wrapperList_stringMapObj1.add(wrapper_stringMapObj1);
          wrapperList_stringMapObj1.add(wrapper_stringMapObj2);
          
          
          
          
          INTF_WebServicesDef.INTF_Request prequest1 = new INTF_WebServicesDef.INTF_Request();
          prequest1.setstringMap(wrapperList_stringMapObj1);
        
      INTF_WebServicesDef.INTF_Request prequest2 = new INTF_WebServicesDef.INTF_Request();
          prequest1.setstringMap(wrapperList_stringMapObj1);
          
         //INSTANTIATING THE CLASS
         INTF_getNamedSearchInfo namedSearchInfo_Obj = new INTF_getNamedSearchInfo();
        
        //CALLING THE METHODS
         INTF_WebServicesDef.INTF_Response_NamedSearchInfo  wrapper_sfmRes_nserInfo_Obj= namedSearchInfo_Obj.getNamedSearchInfo(prequest1);
    }//method
}//class