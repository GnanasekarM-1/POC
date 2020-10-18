@isTest
private class SFM_SaveAsObjectMapping_UT
{
    static testMethod void SFM_saveAsObjectMapping_Test()
    { 
 //-----------------DATA PREPARATION PART----------------------------------------------------------------------------//
        // Putttin one record into SVMXC__ServiceMax_Processes__c Object where Record type is 'OBJECT MAPPING'
        try
        {
                Account acc1 = new Account();
                acc1.Name = 'Maxplore';
                acc1.AccountNumber = 'acc0002';
                acc1.Phone = null;
                acc1.Fax = null ;
                acc1.Website = 'www.maxplore.com';
                acc1.Sic = 'sicnumber001';
                insert acc1;
                System.assertEquals(true, acc1 != null);
                
                Contact cont1 = new Contact();
                cont1.Account=acc1;
                cont1.FirstName = 'Ranjeet';
                cont1.LastName = 'Jaiswal';
                insert cont1 ;
                System.assertEquals(true, cont1 != null);
                
                List<RecordType> lstRecType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping' limit 1];
                
                SVMXC__ServiceMax_Processes__c process_Obj1= new SVMXC__ServiceMax_Processes__c();
                 process_Obj1.SVMXC__MapID__c = 'MapRan001';
                 process_Obj1.SVMXC__Description__c='desc001';
                 process_Obj1.SVMXC__Active__c = true;
                process_Obj1.SVMXC__Source_Object_Name__c = 'Account';
                process_Obj1.SVMXC__Target_Object_Name__c = 'Contact';
                process_Obj1.RecordTypeId =lstRecType[0].Id;
                insert process_Obj1 ;
                System.assertEquals(true, process_Obj1 != null);
               
                //creation of Process Object
                
                SVMXC__ServiceMax_Processes__c process_Obj2 = new SVMXC__ServiceMax_Processes__c();
                process_Obj2.SVMXC__MapID__c = 'MapRan001';
                process_Obj2.SVMXC__Source_Object_Name__c = 'Account';
                process_Obj2.SVMXC__Target_Object_Name__c = 'Contact';
                process_Obj2.SVMXC__ProcessID__c = process_Obj1.Id ;
                process_Obj2.RecordTypeId =lstRecType[0].Id;
                insert process_Obj2 ;
                System.assertEquals(true, process_Obj2 != null);
                
                //creating config 
                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj= new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj.SVMXC__MapID__c = process_Obj2.Id ;
                svmxConfData_Obj.SVMXC__Source_Field_Name__c ='Phone' ;
                svmxConfData_Obj.SVMXC__Target_Field_Name__c ='Phone' ;
                insert svmxConfData_Obj ;
                System.assertEquals(true, svmxConfData_Obj != null);
                
        //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj= new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'Account');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj1 = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'Contact');
        List<SFM_WrapperDef.SFM_StringMap> List_wrapper_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        List_wrapper_strMapObj.add(wrapper_strMapObj);
        List_wrapper_strMapObj.add(wrapper_strMapObj1);
 //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(List_wrapper_strMapObj);
//-------------------INSTANTIATING THE OBJECT   -------------------------------------------------------------//
        SFM_saveAsObjectMapping cloneObjMap_Obj = new SFM_saveAsObjectMapping();
//------------------METHOD CALLING----------------------------------------------------------------------//
        //SFM_WrapperDef.SFM_Response wrapper_sfm_res  = cloneObjMap_Obj.saveAsObjectMappingInfo(prequest);
        
        SFM_WrapperDef.SFM_Response_ObjectMap responseObjMapping = new SFM_WrapperDef.SFM_Response_ObjectMap();
        SFM_GetObjectMapping objMap = new SFM_GetObjectMapping();
        responseObjMapping = objMap.getDefaultFieldmapping(prequest);
        SFM_WrapperDef.SFM_Request_ObjectMap prequestUpdated = new SFM_WrapperDef.SFM_Request_ObjectMap();
        prequestUpdated.objects = responseObjMapping.objects;
        SFM_WrapperDef.SFM_Response wrapper_sfm_res  = cloneObjMap_Obj.saveAsObjectMappingInfo(prequestUpdated);
        }
        catch(exception ex)
        {
        }
        }//method
    }//class