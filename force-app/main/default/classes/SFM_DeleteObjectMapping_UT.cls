@isTest
private class SFM_DeleteObjectMapping_UT
{
    static testMethod void SFM_deleteObjectMapping_Test()
    {     
//----------------------------------DATA PREPARATION PART---------------------------------------------------------------//
        // Putttin one record into SVMXC__ServiceMax_Processes__c Object where Record type is 'OBJECT MAPPING'
           List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
           System.assertEquals(true, lstRecType != null);
           
           SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(RecordTypeId =lstRecType[0].Id,SVMXC__Active__c = true,SVMXC__Name__c = 'ObjMaptest001',SVMXC__MapID__c = 'MapRan001',SVMXC__Source_Object_Name__c='SVMXC__Site__c',SVMXC__Target_Object_Name__c='SVMXC__Installed_Product__c',SVMXC__Description__c='desc001');
          // Test.startTest();
           insert process_Obj;// We should use Test.startTest and Test.stopTest method
         //  Test.stopTest();
         System.assertEquals(true, process_Obj != null);
                  
//--------------------------- Preparation for SFM_WrapperDef.SFM_Request Class with no argumented constructor-------------//
        SFM_WrapperDef.SFM_Request ObjReq= new SFM_WrapperDef.SFM_Request();
//--------------------------- Preparation for SFM_WrapperDef.SFM_Request(key,listOfValue) Class with Argumented constructor-------------//       
        SFM_WrapperDef.SFM_Request  ObjReq1 = new SFM_WrapperDef.SFM_Request();
        String key = 'RECORDID';
        List<String> lstring = new List<String>{'val1','val2','val3'};
        SFM_WrapperDef.SFM_StringListMap wrapper_StrListMapObj= new SFM_WrapperDef.SFM_StringListMap(key,lstring);
        List<SFM_WrapperDef.SFM_StringListMap> wrapperList_StrListMapObj = new List<SFM_WrapperDef.SFM_StringListMap>();
        wrapperList_StrListMapObj.add(wrapper_StrListMapObj);
        ObjReq1.setstringListMap(wrapperList_StrListMapObj);                     
//-----------------------------INSTANCIATING THE OBJECT------------------------------------------------//
         SFM_deleteObjectMapping objectObjMap_Obj= new SFM_deleteObjectMapping();
         
//-----------------------------CALLING THE METHODS OF THIS OBJECT-------------------------------------//
         SFM_WrapperDef.SFM_Response wrapper_resObj1 = objectObjMap_Obj.SFM_deleteObjectMapping(ObjReq1);//method1 is called
         SFM_WrapperDef.SFM_Response wrapper_resObj=  objectObjMap_Obj.SFM_deleteObjectMapping(ObjReq);//method1 is called

         
   }//method
}//class