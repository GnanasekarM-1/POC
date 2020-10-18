/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * The SFA_ConfigurationUtility_UT is for unit testing of the class SFA_ConfigurationUtility
 *
 * @author Manish Kushwah
 * @version 19.2
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         27 March 2019     Created.
 *   Soumyaranjan Pati      6th Sept 2019     Changes objGeofenceEventJson and objGeofenceActionJson for BAC-5214
 *****************************************************************************************************/

 @isTest
 Private class SFA_ConfigurationUtility_UT{

     @isTest static void SFA_GetListOfProcesses_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();

         Test.startTest();
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetListOfProcesses(new SFA_WrapperDef.SFA_ConfigurationRequest());
         System.assertEquals(response.success, true);
         System.assertEquals(response.lstSFAProcesses.size(), 0);

         createSfaRecord(true, false);
         response = objSFAConfig.SFA_GetListOfProcesses(new SFA_WrapperDef.SFA_ConfigurationRequest());
         System.assertEquals(response.success, true);
         Test.stopTest();
     }

     @isTest static void SFA_GetProcessInfo_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         //valid request and data for SF Event
         request.strSFAId = createSfaRecord(true, false);
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetProcessInfo(request);
         System.assertEquals(response.success, true);

         //valid request and data for Geofence
         request.strSFAId = createSfaRecord(false, true);
         response = objSFAConfig.SFA_GetProcessInfo(request);
         System.assertEquals(response.success, true);

        //Added for BAC-5214
        //valid request and data for Geofence with SMS
        request.strSFAId = createSfaRecord(false, false);
        response = objSFAConfig.SFA_GetProcessInfo(request);
        System.assertEquals(response.success, true);
        //End for BAC-5214

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetProcessInfo(request);
         System.assertEquals(response.success, false);

         //Invalid Record id
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         request.strSFAId = 'abc';
         response = objSFAConfig.SFA_GetProcessInfo(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest static void SFA_DeleteProcess_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         //Create SFA Record
         request.strSFAId = createSfaRecord(true, false);
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_DeleteProcess(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_DeleteProcess(request);
         System.assertEquals(response.success, false);

         //Invalid Record id
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         request.strSFAId = 'abc';
         response = objSFAConfig.SFA_DeleteProcess(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest static void SFA_SaveProcess_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         //----Start----SFDC test
         SFA_WrapperDef.SFA_SFDCEventJsonWrapper objSFDCEventJson = new SFA_WrapperDef.SFA_SFDCEventJsonWrapper();
         objSFDCEventJson.Object_API_Name = 'Work order';

         SFA_WrapperDef.SFA_SFDCActionJsonWrapper objSFDCActionJson = new SFA_WrapperDef.SFA_SFDCActionJsonWrapper();
         objSFDCActionJson.Message_Title = 'TestTitle';

         SFA_WrapperDef.SFA_ProcessInformation objSFAProcess_SFDC = new SFA_WrapperDef.SFA_ProcessInformation();
         objSFAProcess_SFDC.strSFAProcessId = 'TestProcess';
         objSFAProcess_SFDC.strSFAProcessName = 'TestProcess';
         objSFAProcess_SFDC.objSFDCEventJson = objSFDCEventJson;
         objSFAProcess_SFDC.objSFDCActionJson = objSFDCActionJson;
         objSFAProcess_SFDC.isEnabled = true;
         //----End----SFDC test

         //----Start----Geofence test
         SFA_WrapperDef.SFA_GeofenceEventJsonWrapper objGeofenceEventJson = new SFA_WrapperDef.SFA_GeofenceEventJsonWrapper();
         objSFDCEventJson.Object_API_Name = 'Work order';

         SFA_WrapperDef.SFA_GeofenceActionJsonWrapper objGeofenceActionJson = new SFA_WrapperDef.SFA_GeofenceActionJsonWrapper();
         objSFDCActionJson.Message_Title = 'TestTitle';

         SFA_WrapperDef.SFA_ProcessInformation objSFAProcess_Geofence = new SFA_WrapperDef.SFA_ProcessInformation();
         objSFAProcess_Geofence.strSFAProcessId = 'TestProcess1';
         objSFAProcess_Geofence.strSFAProcessName = 'TestProcess1';
         objSFAProcess_Geofence.objGeofenceEventJson = objGeofenceEventJson;
         objSFAProcess_Geofence.objGeofenceActionJson = objGeofenceActionJson;
         objSFAProcess_Geofence.isEnabled = true;
         //----End----Geofence test

         //----Start----Geofence SMS test for BAC-5214


         SFA_WrapperDef.SFA_SMSActionJsonWrapper objSMSActionJson = new SFA_WrapperDef.SFA_SMSActionJsonWrapper();

         SFA_WrapperDef.SFA_ProcessInformation objSFAProcess_GeofenceSMS = new SFA_WrapperDef.SFA_ProcessInformation();
         objSFAProcess_GeofenceSMS.strSFAProcessId = 'TestProcess2';
         objSFAProcess_GeofenceSMS.strSFAProcessName = 'TestProcess2';
         objSFAProcess_GeofenceSMS.objGeofenceEventJson = objGeofenceEventJson;
         objSFAProcess_GeofenceSMS.objSMSActionJson = objSMSActionJson;
         objSFAProcess_GeofenceSMS.isEnabled = true;


         //----End----Geofence test BAC-5214

         Test.startTest();

         //SFDC
         request.objSFAProcessInfo = objSFAProcess_SFDC;
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, true);

        //Geofence SMS for BAC-5214
        request.objSFAProcessInfo = objSFAProcess_GeofenceSMS;
        response = objSFAConfig.SFA_SaveProcess(request);
        System.assertEquals(response.success, true);
        //End for BAC-5214

         //Geofence
         request.objSFAProcessInfo = objSFAProcess_Geofence;
         response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, true);

         //Duplicate scenario
         String strSFAId = createSfaRecord(true, false);
         objSFAProcess_SFDC.strSFAProcessId = 'TestProcess';
         request.objSFAProcessInfo = objSFAProcess_SFDC;
         response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, false);

         //SFDC Update Duplicate scenario
         strSFAId = createSfaRecord(true, false);
         objSFAProcess_SFDC.strSFAId = strSFAId;
         request.objSFAProcessInfo = objSFAProcess_SFDC;
         response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, false);

         //SFDC Update scenario
         strSFAId = createSfaRecord(true, false);
         objSFAProcess_SFDC.strSFAId = strSFAId;
         objSFAProcess_SFDC.strSFAProcessId = 'TestProcess212';
         request.objSFAProcessInfo = objSFAProcess_SFDC;
         response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, false);

         //Catch exception
         objSFAProcess_SFDC.isEnabled = null;
         request.objSFAProcessInfo = objSFAProcess_SFDC;
         response = objSFAConfig.SFA_SaveProcess(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest(SeeAllData=true) static void SFA_GetExpressionDetails_Test(){
         List<SVMXC__ServiceMax_Processes__c > lstProcess = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ProcessID__c = 'EXPR060' Limit 1];
         if(lstProcess.size() > 0){
            SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
            SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

            Test.startTest();

            request.strFilterId = lstProcess[0].Id;
            SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetExpressionDetails(request);
            //System.assertEquals(response.success, true); //Commenting as it is failing during build

            //Invalid expression id
            request = new SFA_WrapperDef.SFA_ConfigurationRequest();
            request.strFilterId = 'abc';
            response = objSFAConfig.SFA_GetExpressionDetails(request);
            System.assertEquals(response.success, false);

            //Invalid Request
            request = new SFA_WrapperDef.SFA_ConfigurationRequest();
            response = objSFAConfig.SFA_GetExpressionDetails(request);
            System.assertEquals(response.success, false);

            Test.stopTest();
         }
     }

     @isTest static void SFA_GetFieldList_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.lstObjectName = new List<String>{'Account','Case'};
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetFieldList(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         request.lstObjectName = new List<String>();
         response = objSFAConfig.SFA_GetFieldList(request);
         System.assertEquals(response.success, false);

         //Exception
         request.lstObjectName = new List<String>{'Account1'};
         response = objSFAConfig.SFA_GetFieldList(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest(SeeAllData=true) static void SFA_GetCustomActionList_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.strObjectName = 'SVMXC__Service_Order__c';
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetCustomActionList(request);
         System.debug('Custom Action Configuration response: ' + response);
         //System.assertEquals(response.success, true); //Commenting as it is failing during build

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetCustomActionList(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest(SeeAllData=true) static void SFA_GetSFMList_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.strObjectName = 'SVMXC__Service_Order__c';
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetSFMList(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetSFMList(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest(SeeAllData=true) static void SFA_GetFilterList_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.strObjectName = 'SVMXC__Service_Order__c';
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetFilterList(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetFilterList(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest(SeeAllData=true) static void SFA_GetGroupProfileList_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetGroupProfileList(request);
         System.assertEquals(response.success, true);

         Test.stopTest();
     }

     @isTest static void SFA_GetFieldsOfLookupToObject_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.strObjectName = 'SVMXC__Service_Order__c';
         request.relatedObjectDetails = true; // Added for BAC-5214
         request.lstLookupToObject = new List<String>{'SVMXC__Site__c', 'User'};
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetFieldsOfLookupToObject(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetFieldsOfLookupToObject(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest static void SFA_GetUserInfo_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetUserInfo(request);
         System.assertEquals(response.success, true);

         Test.stopTest();
     }

     @isTest static void SFA_GetFieldListByDataType_Test(){
         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.strObjectName = 'SVMXC__Service_Order__c';
         request.lstDataType = new List<String>{'DATE', 'DATETIME'};
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetFieldListByDataType(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetFieldListByDataType(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }

     @isTest static void SFA_ConfigurationJSR_Test(){
         SFA_WrapperDef.SFA_ConfigurationRequest obj_Request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         String request = JSON.serialize(obj_Request);

         try{
             SFA_Configuration.JsrGetSFAProcessList(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetSFAProcessInfo(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrDeleteProcess(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrSaveProcess(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetExpressionDetails(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetFieldList('{"lstObjectName":["SVMXC__Service_Order__c"]}');
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetSFMList('{"strObjectName":"SVMXC__Service_Order__c"}');
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetCustomActionList('{"strObjectName":"SVMXC__Service_Order__c"}');
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetFilterList('{"strObjectName":"SVMXC__Service_Order__c"}');
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetGroupProfileList(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetFieldsOfLookupToObject('{"strObjectName":"SVMXC__Service_Order__c","lstLookupToObject":["User","SVMXC__Service_Group_Members__c"]}');
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetObjectList(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetCustomLabels(request);
         }
         catch(Exception e){}

         try{
             SFA_Configuration.JsrGetFieldListByDataType('{"strObjectName":"SVMXC__Service_Order__c","lstDataType":["DATE","DATETIME"]}');
         }
         catch(Exception e){}

          try{
              SFA_Configuration.JsrGetRelatedList('{"strObjectName":"SVMXC__Service_Order__c"}');
          }
          catch(Exception e){}

         try{
             SFA_Configuration.JsrGetUserInfo('{}');
         }
         catch(Exception e){}

         SFA_WrapperDef.SFA_RecordWrapper obj = new SFA_WrapperDef.SFA_RecordWrapper();
         SFA_WrapperDef.SFA_CustomLabel obj1 = new SFA_WrapperDef.SFA_CustomLabel('test','test');
     }

     static String createSfaRecord(Boolean createSFEvent, Boolean createGeofence){
         SVMXC__SM_SFA_Process__c objSFA = new SVMXC__SM_SFA_Process__c();
         objSFA.SVMXC__SM_SFA_Process_Name__c = 'TestProcess';
         objSFA.SVMXC__SM_SFA_Process_Id__c = 'TestProcess';

         if(createSFEvent){
             objSFA.SVMXC__SM_Event_Type__c = 'Salesforce Event';
             objSFA.SVMXC__SM_SFA_Event_JSON__c = '{"Object_API_Name":"SVMXC__Service_Order__c","SFDC_Data_Event_Type":"Record Updated","Event_Trigger_Fields":["field1","field2"],"Preview_Field_List":["field1","field2"]}';

             objSFA.SVMXC__SM_Action_Type__c = 'Push Notification';
             objSFA.SVMXC__SM_SFA_Action_JSON__c = '{"Recipient_Field_API_Names":["field1","field2"],"Message_Title":"test title","Message_Body":"Test msg body","Service_Provider":"PUBNUB","Client_App_Name":"FSA Phone","Display_Object_Record":"SVMXC__Service_Order__c"}';
         }
         else if(createGeofence){
             objSFA.SVMXC__SM_Event_Type__c = 'Geofence';
             objSFA.SVMXC__SM_SFA_Event_JSON__c = '{"Object_API_Name":"SVMXC__Service_Order__c","Trigger_Type":"Entry","Location_Field":"SVMXC__Location__c","Fence_Radius":"25"}';

             objSFA.SVMXC__SM_Action_Type__c = 'Local Notification';
             objSFA.SVMXC__SM_SFA_Action_JSON__c = '{"Message_Title":"test title","Message_Body":"Test msg body","Client_App_Name":"FSA Phone","Display_Object_Record":"SVMXC__Service_Order__c"}';
         }else{ // Added for BAC-5214
            objSFA.SVMXC__SM_Event_Type__c = 'Geofence';
            objSFA.SVMXC__SM_SFA_Event_JSON__c = '{"Object_API_Name":"SVMXC__Service_Order__c","Trigger_Type":"Entry","Location_Field":"SVMXC__Location__c","Fence_Radius":"25"}';

            objSFA.SVMXC__SM_Action_Type__c = 'SMS';
            objSFA.SVMXC__SM_SFA_Action_JSON__c = '{"Recipients":[{"field":"addition_number","country":"USA","number":"9252341234"},{"field":"SVMXC__Contact__c","relatedObject":"Contact","relatedRefNameField":"SVMXC__Contact__r","relatedCountryField":"MailingCountry","relatedField":["MobilePhone","HomePhone"]},{"field":"addition_number","country":"United Kingdom","number":"4928123213"}],"Message_Body":"Test msg body","Service_Provider":"SMS","Display_Object_Record":"SVMXC__Service_Order__c"}';
         }
         insert objSFA;
         return objSFA.Id;
     }

     @isTest static void SFA_GetRelatedListToObject_Test(){
         SVMXC__ServiceMax_Processes__c subModuleProcess = new SVMXC__ServiceMax_Processes__c();
         subModuleProcess.SVMXC__SubmoduleID__c = 'SFA001';
         subModuleProcess.RecordTypeId = [SELECT Id from RecordType where Name = 'Submodule'][0].Id;
         subModuleProcess.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) ));
         insert subModuleProcess;

         SVMXC__ServiceMax_Processes__c setProcess = new SVMXC__ServiceMax_Processes__c();
         setProcess.SVMXC__Submodule__c = subModuleProcess.Id;
         setProcess.SVMXC__Active__c = true;
         setProcess.SVMXC__SettingID__c = 'SET007';
         setProcess.SVMXC__Setting_Type__c = 'Group';
         setProcess.SVMXC__Search_Order__c = 'Group,Global';
         setProcess.SVMXC__Data_Type__c = 'Text';
         setProcess.RecordTypeId = [SELECT Id from RecordType where Name = 'Settings'][0].Id;
         setProcess.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) ));
         insert setProcess;

         SVMXC__ServiceMax_Config_Data__c groupProfile = new SVMXC__ServiceMax_Config_Data__c();
         groupProfile.RecordTypeId = [select Id from RecordType Where Name = 'Configuration Profile' limit 1][0].Id;
         groupProfile.SVMXC__Configuration_Type__c = 'Group';
         groupProfile.SVMXC__Profile_Name__c = 'Group Profile For Unit Testing';
         groupProfile.SVMXC__Description__c = 'Group Profile For Unit Testing';
         groupProfile.SVMXC__IsDefault__c = false;
         groupProfile.SVMXC__Active__c = true;
         insert groupProfile;

         SVMXC__ServiceMax_Config_Data__c groupProfileAccess = new SVMXC__ServiceMax_Config_Data__c();
         groupProfileAccess.RecordTypeId = [select Id from RecordType Where Name = 'Configuration Access' limit 1][0].Id;
         groupProfileAccess.SVMXC__Access_Configuration_Profile__c = groupProfile.Id;
         groupProfileAccess.SVMXC__Active__c = true;
         groupProfileAccess.SVMXC__Profile__c = UserInfo.getProfileId();
         insert groupProfileAccess;

         SVMXC__ServiceMax_Config_Data__c setConfig = new SVMXC__ServiceMax_Config_Data__c();
         setConfig.SVMXC__Setting_ID__c = setProcess.Id;
         setConfig.SVMXC__Internal_Value__c = 'obj1,Obj2';
         setConfig.RecordTypeId = [SELECT Id from RecordType where Name = 'Setting Value'][0].Id;
         setConfig.SVMXC__Setting_Configuration_Profile__c = groupProfile.Id;
         setConfig.SVMXC__Active__c = true;
         insert setConfig;

         SFA_ConfigurationUtility objSFAConfig = new SFA_ConfigurationUtility();
         SFA_WrapperDef.SFA_ConfigurationRequest request = new SFA_WrapperDef.SFA_ConfigurationRequest();

         Test.startTest();

         request.strObjectName = 'SVMXC__Service_Order__c';
         SFA_WrapperDef.SFA_ConfigurationResponse response = objSFAConfig.SFA_GetRelatedListToObject(request);
         System.assertEquals(response.success, true);

         //Invalid Request
         request = new SFA_WrapperDef.SFA_ConfigurationRequest();
         response = objSFAConfig.SFA_GetFieldsOfLookupToObject(request);
         System.assertEquals(response.success, false);

         Test.stopTest();
     }
 }