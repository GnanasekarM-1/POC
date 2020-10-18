@isTest
private class SFM_GetObjectMapping_UT
{
    static testMethod void SFM_getObjectMapping_Test1()
    {   
 //-----------------DATA PREPARATION PART----------------------------------------------------------------------------// 
               //creation of Process Object
            try{
                List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
                List<RecordType> lstRecType1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Field Mapping'];
                System.assertEquals(true, lstRecType != NULL);

                SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(); 
                process_Obj.SVMXC__Source_Object_Name__c = 'SVMXC_Site__c';
                process_Obj.SVMXC__Target_Object_Name__c = 'SVMXC__Site__c';
                process_Obj.SVMXC__MapID__c='Custom-RMap001';
                process_Obj.RecordTypeId =lstRecType[0].Id;
                insert process_Obj ;
                System.assertEquals(true, process_Obj != NULL);
 
                Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        );
                insert account;
                SVMXC__Site__c sourceLocation,destLocation;   
                list<SVMXC__Site__c> siteloc = new list<SVMXC__Site__c>();
                sourceLocation = new SVMXC__Site__c(
                                                SVMXC__Zip__c ='90909090',
                                                SVMXC__Street__c ='ABC',
                                                SVMXC__State__c ='ABC',
                                                SVMXC__Country__c ='ABC',
                                                SVMXC__City__c ='ABC',
                                                SVMXC__Account__c=account.Id
                                                );
                siteloc.add(sourceLocation);
                
                destLocation = new SVMXC__Site__c(
                                                SVMXC__Zip__c ='90909090',
                                                SVMXC__Street__c ='ABC',
                                                SVMXC__State__c ='ABC',
                                                SVMXC__Country__c ='ABC',
                                                SVMXC__City__c ='ABC',
                                                SVMXC__Account__c=account.Id
                                                );
                siteloc.add(destLocation);

                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj= new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj.SVMXC__Source_Field_Name__c ='SVMXC__Country__c' ;
                svmxConfData_Obj.SVMXC__Target_Field_Name__c ='SVMXC__Country__c' ;
                insert svmxConfData_Obj ;
                System.assertEquals(true,svmxConfData_Obj != NULL);
                
              //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj= new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMap1_Obj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj);
        wrapperList_strMapObj.add(wrapper_strMap1_Obj);
 //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj2 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj3 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj1.add(wrapper_strMapObj2);
        wrapperList_strMapObj1.add(wrapper_strMapObj3);
//---------------- Putting data into SFM_WrapperDef.SFM_Request object----------------------//
        SFM_WrapperDef.SFM_Request prequest1 = new SFM_WrapperDef.SFM_Request();
        prequest1.setstringMap(wrapperList_strMapObj1);
        
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj4 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj5 = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj2 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj2.add(wrapper_strMapObj4);
        wrapperList_strMapObj2.add(wrapper_strMapObj5);
//---------------- Putting data into SFM_WrapperDef.SFM_Request object------------------------//
        SFM_WrapperDef.SFM_Request prequest2 = new SFM_WrapperDef.SFM_Request();
        prequest2.setstringMap(wrapperList_strMapObj2);
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj9 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj10 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj11= new SFM_WrapperDef.SFM_StringMap('OBJECTMAPNAME' , NULL);//need to check
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj12= new SFM_WrapperDef.SFM_StringMap('RECORDID' ,process_Obj.Id);
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj4 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj4.add(wrapper_strMapObj9);
        wrapperList_strMapObj4.add(wrapper_strMapObj10);
        wrapperList_strMapObj4.add(wrapper_strMapObj11);
        wrapperList_strMapObj4.add(wrapper_strMapObj12);
//------------------- Putting data into SFM_WrapperDef.SFM_Request object-----------------------//
        SFM_WrapperDef.SFM_Request prequest4 = new SFM_WrapperDef.SFM_Request();
        prequest4.setstringMap(wrapperList_strMapObj4);
//---------------------------------------INSTANCIATING THE OBJECT---------------------------------//
         SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
//-------------------------CALLING THE METHODS OF THIS OBJECT-----------------------//
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List = objectMap_Obj.SFM_getAllObjectMap(prequest);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List1 = objectMap_Obj.SFM_getAllObjectMap(prequest1);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List2 = objectMap_Obj.SFM_getAllObjectMap(prequest2);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj5 =  objectMap_Obj.getDefaultFieldmapping(prequest4);//method2 is called
        objectMap_Obj.selectAppropriateMatch('SVMXC__Site__c',wrapperList_strMapObj4);
        objectMap_Obj.getOnlyObjectMapping(prequest4);
        }
        catch(exception ex){
        
        }
      }//method1
      static testMethod void SFM_getObjectMapping_Test2()
      {   
 //-----------------DATA PREPARATION PART----------------------------------------------------------------------------// 
               //creation of Process Object
        try{
                List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
                List<RecordType> lstRecType1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Field Mapping'];
                System.assertEquals(true, lstRecType != NULL);

                SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(); 
                process_Obj.SVMXC__Source_Object_Name__c = 'SVMXC_Site__c';
                process_Obj.SVMXC__Target_Object_Name__c = 'SVMXC__Site__c';
                process_Obj.SVMXC__MapID__c='Custom-RMap001';
                process_Obj.RecordTypeId =lstRecType[0].Id;
                insert process_Obj ;
                System.assertEquals(true, process_Obj != NULL);
 
                Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        );
                insert account;
                SVMXC__Site__c sourceLocation,destLocation;   
                list<SVMXC__Site__c> siteloc = new list<SVMXC__Site__c>();
                sourceLocation = new SVMXC__Site__c(
                                                SVMXC__Zip__c ='90909090',
                                                SVMXC__Street__c ='ABC',
                                                SVMXC__State__c ='ABC',
                                                SVMXC__Country__c ='ABC',
                                                SVMXC__City__c ='ABC',
                                                SVMXC__Account__c=account.Id
                                                );
                siteloc.add(sourceLocation);
                
                destLocation = new SVMXC__Site__c(
                                                SVMXC__Zip__c ='90909090',
                                                SVMXC__Street__c ='ABC',
                                                SVMXC__State__c ='ABC',
                                                SVMXC__Country__c ='ABC',
                                                SVMXC__City__c ='ABC',
                                                SVMXC__Account__c=account.Id
                                                );
                siteloc.add(destLocation);

                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj= new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj.SVMXC__Source_Field_Name__c ='SVMXC__Country__c' ;
                svmxConfData_Obj.SVMXC__Target_Field_Name__c ='SVMXC__Country__c' ;
                insert svmxConfData_Obj;
                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj1 = new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj1.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj1.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj1.SVMXC__Source_Field_Name__c ='SVMXC__Latitude__c';
                svmxConfData_Obj1.SVMXC__Target_Field_Name__c ='SVMXC__Latitude__c';
                insert svmxConfData_Obj1;
                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj2 = new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj2.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj2.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj2.SVMXC__Source_Field_Name__c ='SVMXC__Zip__c';
                svmxConfData_Obj2.SVMXC__Target_Field_Name__c ='SVMXC__Zip__c';
                insert svmxConfData_Obj2;
                System.assertEquals(true,svmxConfData_Obj != NULL);
                
              //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj= new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMap1_Obj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj);
        wrapperList_strMapObj.add(wrapper_strMap1_Obj);
 //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj2 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj3 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj1.add(wrapper_strMapObj2);
        wrapperList_strMapObj1.add(wrapper_strMapObj3);
//---------------- Putting data into SFM_WrapperDef.SFM_Request object----------------------//
        SFM_WrapperDef.SFM_Request prequest1 = new SFM_WrapperDef.SFM_Request();
        prequest1.setstringMap(wrapperList_strMapObj1);
        
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj4 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj5 = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj2 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj2.add(wrapper_strMapObj4);
        wrapperList_strMapObj2.add(wrapper_strMapObj5);
//---------------- Putting data into SFM_WrapperDef.SFM_Request object------------------------//
        SFM_WrapperDef.SFM_Request prequest2 = new SFM_WrapperDef.SFM_Request();
        prequest2.setstringMap(wrapperList_strMapObj2);
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj9 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj10 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj11= new SFM_WrapperDef.SFM_StringMap('OBJECTMAPNAME' , NULL);//need to check
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj12= new SFM_WrapperDef.SFM_StringMap('RECORDID' ,process_Obj.Id);
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj4 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj4.add(wrapper_strMapObj9);
        wrapperList_strMapObj4.add(wrapper_strMapObj10);
        wrapperList_strMapObj4.add(wrapper_strMapObj11);
        wrapperList_strMapObj4.add(wrapper_strMapObj12);
//------------------- Putting data into SFM_WrapperDef.SFM_Request object-----------------------//
        SFM_WrapperDef.SFM_Request prequest4 = new SFM_WrapperDef.SFM_Request();
        prequest4.setstringMap(wrapperList_strMapObj4);
//---------------------------------------INSTANCIATING THE OBJECT---------------------------------//
         SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
//-------------------------CALLING THE METHODS OF THIS OBJECT-----------------------//
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List = objectMap_Obj.SFM_getAllObjectMap(prequest);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List1 = objectMap_Obj.SFM_getAllObjectMap(prequest1);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List2 = objectMap_Obj.SFM_getAllObjectMap(prequest2);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj5 =  objectMap_Obj.getDefaultFieldmapping(prequest4);//method2 is called
        objectMap_Obj.selectAppropriateMatch('SVMXC__Site__c',wrapperList_strMapObj4);
        objectMap_Obj.getOnlyObjectMapping(prequest4);
        }
        catch(exception ex){}
      }//method2
      static testMethod void SFM_getObjectMapping_Test3()
    {   
 //-----------------DATA PREPARATION PART----------------------------------------------------------------------------// 
        //creation of Process Object
        try{
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
        List<RecordType> lstRecType1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Field Mapping'];
        System.assertEquals(true, lstRecType != NULL);
        
        SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(); 
        process_Obj.SVMXC__Source_Object_Name__c = 'SVMXC_Site__c';
        process_Obj.SVMXC__Target_Object_Name__c = 'SVMXC__Site__c';
        process_Obj.SVMXC__MapID__c='Custom-RMap001';
        process_Obj.RecordTypeId =lstRecType[0].Id;
        insert process_Obj ;
        System.assertEquals(true, process_Obj != NULL);
        
        Account account = new Account(
                                Name ='Account',
                                ShippingStreet='ABC',
                                ShippingCity='PQR ',
                                ShippingState = 'XYZ',
                                ShippingPostalCode='111',
                                ShippingCountry='XYZ',
                                BillingStreet='ABC',
                                BillingCity='PQR ',
                                BillingState = 'XYZ',
                                BillingPostalCode='111',
                                BillingCountry='XYZ'
                                );
        insert account;
        SVMXC__Site__c sourceLocation,destLocation;   
        list<SVMXC__Site__c> siteloc = new list<SVMXC__Site__c>();
        sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        siteloc.add(sourceLocation);
        
        destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        siteloc.add(destLocation);
        
        SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj= new SVMXC__ServiceMax_Config_Data__c();
        svmxConfData_Obj.RecordTypeId = lstRecType1[0].Id;
        svmxConfData_Obj.SVMXC__MapID__c = process_Obj.Id;
        svmxConfData_Obj.SVMXC__Source_Field_Name__c ='SVMXC__Site_Phone__c';
        svmxConfData_Obj.SVMXC__Target_Field_Name__c ='SVMXC__Site_Phone__c';
        insert svmxConfData_Obj;
        SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj1 = new SVMXC__ServiceMax_Config_Data__c();
        svmxConfData_Obj1.RecordTypeId = lstRecType1[0].Id;
        svmxConfData_Obj1.SVMXC__MapID__c = process_Obj.Id;
        svmxConfData_Obj1.SVMXC__Source_Field_Name__c ='SVMXC__Stocking_Location__c';
        svmxConfData_Obj1.SVMXC__Target_Field_Name__c ='SVMXC__Stocking_Location__c';
        insert svmxConfData_Obj1;
        SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj2 = new SVMXC__ServiceMax_Config_Data__c();
        svmxConfData_Obj2.RecordTypeId = lstRecType1[0].Id;
        svmxConfData_Obj2.SVMXC__MapID__c = process_Obj.Id;
        svmxConfData_Obj2.SVMXC__Source_Field_Name__c ='SVMXC__Email__c';
        svmxConfData_Obj2.SVMXC__Target_Field_Name__c ='SVMXC__Email__c';
        insert svmxConfData_Obj2;
        System.assertEquals(true,svmxConfData_Obj != NULL);
        
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj6 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj7 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj8 = new SFM_WrapperDef.SFM_StringMap('OBJECTMAPNAME' , 'Custom-RMap001');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj3 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj3.add(wrapper_strMapObj6);
        wrapperList_strMapObj3.add(wrapper_strMapObj7);
        wrapperList_strMapObj3.add(wrapper_strMapObj8);
//------------------- Putting data into SFM_WrapperDef.SFM_Request object-----------------------//
        SFM_WrapperDef.SFM_Request prequest3 = new SFM_WrapperDef.SFM_Request();
        prequest3.setstringMap(wrapperList_strMapObj3);        
 //--------------------------------------INSTANCIATING THE OBJECT---------------------------------//
         SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
         
        //-------------------------CALLING THE METHODS OF THIS OBJECT-----------------------//
       SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj4 =  objectMap_Obj.getDefaultFieldmapping(prequest3);//method2 is called
       }
       catch(exception ex){}
       }//method3
        static testMethod void SFM_getObjectMapping_Test4()
      {   
 //-----------------DATA PREPARATION PART----------------------------------------------------------------------------// 
      try{
               //creation of Process Object

                List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
                List<RecordType> lstRecType1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Field Mapping'];
                System.assertEquals(true, lstRecType != NULL);

                SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(); 
                process_Obj.SVMXC__Source_Object_Name__c = 'SVMXC_Site__c';
                process_Obj.SVMXC__Target_Object_Name__c = 'SVMXC__Site__c';
                process_Obj.SVMXC__MapID__c='Custom-RMap001';
                process_Obj.RecordTypeId =lstRecType[0].Id;
                insert process_Obj ;
                System.assertEquals(true, process_Obj != NULL);
 
                Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        );
                insert account;
                SVMXC__Site__c sourceLocation,destLocation;   
                list<SVMXC__Site__c> siteloc = new list<SVMXC__Site__c>();
                sourceLocation = new SVMXC__Site__c(
                                                SVMXC__Zip__c ='90909090',
                                                SVMXC__Street__c ='ABC',
                                                SVMXC__State__c ='ABC',
                                                SVMXC__Country__c ='ABC',
                                                SVMXC__City__c ='ABC',
                                                SVMXC__Account__c=account.Id
                                                );
                siteloc.add(sourceLocation);
                
                destLocation = new SVMXC__Site__c(
                                                SVMXC__Zip__c ='90909090',
                                                SVMXC__Street__c ='ABC',
                                                SVMXC__State__c ='ABC',
                                                SVMXC__Country__c ='ABC',
                                                SVMXC__City__c ='ABC',
                                                SVMXC__Account__c=account.Id
                                                );
                siteloc.add(destLocation);

                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj= new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj.SVMXC__Source_Field_Name__c ='SVMXC__Country__c' ;
                svmxConfData_Obj.SVMXC__Target_Field_Name__c ='SVMXC__Country__c' ;
                insert svmxConfData_Obj;
                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj1 = new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj1.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj1.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj1.SVMXC__Source_Field_Name__c ='SVMXC__Latitude__c';
                svmxConfData_Obj1.SVMXC__Target_Field_Name__c ='SVMXC__Latitude__c';
                insert svmxConfData_Obj1;
                SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj2 = new SVMXC__ServiceMax_Config_Data__c();
                svmxConfData_Obj2.RecordTypeId = lstRecType1[0].Id;
                svmxConfData_Obj2.SVMXC__MapID__c = process_Obj.Id;
                svmxConfData_Obj2.SVMXC__Source_Field_Name__c ='SVMXC__Zip__c';
                svmxConfData_Obj2.SVMXC__Target_Field_Name__c ='SVMXC__Zip__c';
                insert svmxConfData_Obj2;
                System.assertEquals(true,svmxConfData_Obj != NULL);
                
              //--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj= new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMap1_Obj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj);
        wrapperList_strMapObj.add(wrapper_strMap1_Obj);
 //--------------- Putting data into SFM_WrapperDef.SFM_Request object------------------//
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj2 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj3 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj1 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj1.add(wrapper_strMapObj2);
        wrapperList_strMapObj1.add(wrapper_strMapObj3);
//---------------- Putting data into SFM_WrapperDef.SFM_Request object----------------------//
        SFM_WrapperDef.SFM_Request prequest1 = new SFM_WrapperDef.SFM_Request();
        prequest1.setstringMap(wrapperList_strMapObj1);
        
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj4 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj5 = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj2 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj2.add(wrapper_strMapObj4);
        wrapperList_strMapObj2.add(wrapper_strMapObj5);
//---------------- Putting data into SFM_WrapperDef.SFM_Request object------------------------//
        SFM_WrapperDef.SFM_Request prequest2 = new SFM_WrapperDef.SFM_Request();
        prequest2.setstringMap(wrapperList_strMapObj2);
//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//        
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj9 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj10 = new SFM_WrapperDef.SFM_StringMap('TARGET' , NULL);
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj11= new SFM_WrapperDef.SFM_StringMap('OBJECTMAPNAME' , NULL);//need to check
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj12= new SFM_WrapperDef.SFM_StringMap('RECORDID' ,process_Obj.Id);
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj4 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj4.add(wrapper_strMapObj9);
        wrapperList_strMapObj4.add(wrapper_strMapObj10);
        wrapperList_strMapObj4.add(wrapper_strMapObj11);
        wrapperList_strMapObj4.add(wrapper_strMapObj12);
//------------------- Putting data into SFM_WrapperDef.SFM_Request object-----------------------//
        SFM_WrapperDef.SFM_Request prequest4 = new SFM_WrapperDef.SFM_Request();
        prequest4.setstringMap(wrapperList_strMapObj4);
//---------------------------------------INSTANCIATING THE OBJECT---------------------------------//
         SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
//-------------------------CALLING THE METHODS OF THIS OBJECT-----------------------//
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List = objectMap_Obj.SFM_getAllObjectMap(prequest);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List1 = objectMap_Obj.SFM_getAllObjectMap(prequest1);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMapLIst wrapper_resObj_Map_List2 = objectMap_Obj.SFM_getAllObjectMap(prequest2);//method1 is called
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj5 =  objectMap_Obj.getDefaultFieldmapping(prequest4);//method2 is called
        objectMap_Obj.selectAppropriateMatch('SVMXC__Site__c',wrapperList_strMapObj4);
        objectMap_Obj.getOnlyObjectMapping(prequest4);
        }catch(exception ex){}
      }//method2
    static testMethod void SFM_getObjectMapping_Test5()
    {
 //-----------------DATA PREPARATION PART----------------------------------------------------------------------------// 
        //creation of Process Object
        try{
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Object Mapping'];
        List<RecordType> lstRecType1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Field Mapping'];
        System.assertEquals(true, lstRecType != NULL);
        
        SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c(); 
        process_Obj.SVMXC__Source_Object_Name__c = 'SVMXC_Site__c';
        process_Obj.SVMXC__Target_Object_Name__c = 'SVMXC__Site__c';
        process_Obj.SVMXC__MapID__c='Custom-RMap001';
        process_Obj.RecordTypeId =lstRecType[0].Id;
        insert process_Obj ;
        System.assertEquals(true, process_Obj != NULL);
        
        Account account = new Account(
                                Name ='Account',
                                ShippingStreet='ABC',
                                ShippingCity='PQR ',
                                ShippingState = 'XYZ',
                                ShippingPostalCode='111',
                                ShippingCountry='XYZ',
                                BillingStreet='ABC',
                                BillingCity='PQR ',
                                BillingState = 'XYZ',
                                BillingPostalCode='111',
                                BillingCountry='XYZ'
                                );
        insert account;
        SVMXC__Site__c sourceLocation,destLocation;   
        list<SVMXC__Site__c> siteloc = new list<SVMXC__Site__c>();
        sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        siteloc.add(sourceLocation);
        
        destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        siteloc.add(destLocation);
        
        SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj= new SVMXC__ServiceMax_Config_Data__c();
        svmxConfData_Obj.RecordTypeId = lstRecType1[0].Id;
        svmxConfData_Obj.SVMXC__MapID__c = process_Obj.Id;
        svmxConfData_Obj.SVMXC__Source_Field_Name__c ='SVMXC__Site_Phone__c';
        svmxConfData_Obj.SVMXC__Target_Field_Name__c ='SVMXC__Site_Phone__c';
        insert svmxConfData_Obj;
        SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj1 = new SVMXC__ServiceMax_Config_Data__c();
        svmxConfData_Obj1.RecordTypeId = lstRecType1[0].Id;
        svmxConfData_Obj1.SVMXC__MapID__c = process_Obj.Id;
        svmxConfData_Obj1.SVMXC__Source_Field_Name__c ='SVMXC__Stocking_Location__c';
        svmxConfData_Obj1.SVMXC__Target_Field_Name__c ='SVMXC__Stocking_Location__c';
        insert svmxConfData_Obj1;
        SVMXC__ServiceMax_Config_Data__c svmxConfData_Obj2 = new SVMXC__ServiceMax_Config_Data__c();
        svmxConfData_Obj2.RecordTypeId = lstRecType1[0].Id;
        svmxConfData_Obj2.SVMXC__MapID__c = process_Obj.Id;
        svmxConfData_Obj2.SVMXC__Source_Field_Name__c ='SVMXC__Email__c';
        svmxConfData_Obj2.SVMXC__Target_Field_Name__c ='SVMXC__Email__c';
        insert svmxConfData_Obj2;
        System.assertEquals(true,svmxConfData_Obj != NULL);

//--------- ----Preparation for SFM_WrapperDef.SFM_Request Class------//
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj6 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Site__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj7 = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Site__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj3 = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj3.add(wrapper_strMapObj6);
        wrapperList_strMapObj3.add(wrapper_strMapObj7);

//------------------- Putting data into SFM_WrapperDef.SFM_Request object-----------------------//
        SFM_WrapperDef.SFM_Request prequest3 = new SFM_WrapperDef.SFM_Request();
        prequest3.setstringMap(wrapperList_strMapObj3);        
 //--------------------------------------INSTANCIATING THE OBJECT---------------------------------//
         SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
         
        //-------------------------CALLING THE METHODS OF THIS OBJECT-----------------------//
       SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj4 =  objectMap_Obj.getDefaultFieldmapping(prequest3);//method2 is called
       }catch(exception ex){}
    }//method4
    
    public static void createDataForSmartObject(){
        SVMXC__Object_Cache__c objSmartObject = new SVMXC__Object_Cache__c();
        objSmartObject.SVMXC__Object_API_Name__c = 'ApptOfferRequest__sm';
        objSmartObject.SVMXC__Object_Label__c = 'ApptOfferRequest';
        objSmartObject.SVMXC__Description__c = 'This is Test description';
        objSmartObject.SVMXC__Schema__c = '{"name": "ApptOfferRequest__sm", "label": "ApptOfferRequest",  "createable": "true",    "fields": [{ "name": "Login__sm",  "label": "Login",  "type": "STRING",  "createable": "false", "custom": "false",   "length": "50",  "updateable": "false",  "precision": "null", "nameField": "false", "referenceTo": "null", "relationshipName": "null",  "picklistValues": "null" },  {  "name": "NumReq__sm", "label": "NumReq",  "type": "DOUBLE",  "createable": "false", "custom": "false",   "length": "4",  "updateable": "false", "precision": "2", "nameField": "false", "referenceTo": "null", "relationshipName": "null", "picklistValues": "null" },  {  "name": "Job_Is_Fixed__sm", "label": "Job Is Fixed",  "type": "BOOLEAN",  "createable": "false", "custom": "false",   "length": "null",  "updateable": "false", "precision": "null", "nameField": "false", "referenceTo": "null", "relationshipName": "null", "picklistValues": "null" }]}';
        insert objSmartObject;
        System.assert(objSmartObject.SVMXC__Object_API_Name__c == 'ApptOfferRequest__sm');
    }
    static testMethod void TestMethod_For_SmartObject1(){
        createDataForSmartObject();
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj1 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'SVMXC__Service_Order__c');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'ApptOfferRequest__sm');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj1);
        wrapperList_strMapObj.add(wrapper_strMapObj);
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
        SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj4 =  objectMap_Obj.getDefaultFieldmapping(prequest);
    }
    static testMethod void TestMethod_For_SmartObject2(){
        createDataForSmartObject();
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj1 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'ApptOfferRequest__sm');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'SVMXC__Service_Order__c');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj1);
        wrapperList_strMapObj.add(wrapper_strMapObj);
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
        SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj4 =  objectMap_Obj.getDefaultFieldmapping(prequest);
    }
    static testMethod void TestMethod_For_SmartObject3(){
        createDataForSmartObject();
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj1 = new SFM_WrapperDef.SFM_StringMap('SOURCE' , 'ApptOfferRequest__sm');
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'ApptOfferRequest__sm');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj1);
        wrapperList_strMapObj.add(wrapper_strMapObj);
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
        SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj4 =  objectMap_Obj.getDefaultFieldmapping(prequest);
    }
    static testMethod void TestMethod_For_SmartObject4(){
        createDataForSmartObject();
        SFM_WrapperDef.SFM_StringMap wrapper_strMapObj = new SFM_WrapperDef.SFM_StringMap('TARGET' , 'ApptOfferRequest__sm');
        List<SFM_WrapperDef.SFM_StringMap> wrapperList_strMapObj = new List<SFM_WrapperDef.SFM_StringMap>();
        wrapperList_strMapObj.add(wrapper_strMapObj);
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        prequest.setstringMap(wrapperList_strMapObj);
        SFM_getObjectMapping objectMap_Obj = new SFM_getObjectMapping();
        SFM_WrapperDef.SFM_Response_ObjectMap wrapper_resMapObj4 =  objectMap_Obj.getDefaultFieldmapping(prequest);
    }
}//class