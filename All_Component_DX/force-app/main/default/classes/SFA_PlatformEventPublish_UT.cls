/*****************************************************************************
*                       Copyright (C) 2019 ServiceMax, Inc
*                               All rights reserved
*****************************************************************************/

/**
* The UT class for SFA_Platform_Event_publish, SFA_PlatformTriggerHandler
*
* @author Jaysukh Patel
* @version 19.2
* @since 2019
*/
/*****************************************************************************************************
*   Name                   Date              Comment
*****************************************************************************************************
*   Jaysukh Patel        20 March 2019       Created.
*   Soumyaranjan Pati    1st June 2019       Added for SFA_PlatformTriggerHandler
*****************************************************************************************************/

@isTest(seeAlldata=false)
public class SFA_PlatformEventPublish_UT
{
    @testsetup static void setup() {
        String GlobalProfileId = createGlobalProfileId();
        createSFASettings(GlobalProfileId);

        SVMXC__ServiceMax_Processes__c objSFMScheduledProcess = new SVMXC__ServiceMax_Processes__c();
        objSFMScheduledProcess.SVMXC__Name__c = 'SVMXSTD Closed Work Orders';
        objSFMScheduledProcess.SVMXC__ProcessID__c = 'SVMXSTD__Closed_Work_Orders';
        objSFMScheduledProcess.SVMXC__Description__c = 'SFM_Scheduled';
        objSFMScheduledProcess.SVMXC__Capture_Log__c = true;
        objSFMScheduledProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        objSFMScheduledProcess.SVMXC__Assign_To_Dispatcher__c =  UserInfo.getUserId();
        objSFMScheduledProcess.RecordTypeId = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        objSFMScheduledProcess.SVMXC__IsStandard__c = false;
        objSFMScheduledProcess.SVMXC__Active__c = true;
        objSFMScheduledProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c=\'Open\'';
        insert objSFMScheduledProcess;

        SVMXC__ServiceMax_Config_Data__c exprDtl = new SVMXC__ServiceMax_Config_Data__c();
        exprDtl.RecordTypeId = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1].Id;
        exprDtl.SVMXC__Expression_Type__c = 'EXP_Named';
        exprDtl.SVMXC__Expression_Rule__c = objSFMScheduledProcess.Id;
        exprDtl.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        exprDtl.SVMXC__Display_Type__c = 'String';
        insert exprDtl;

        List<SVMXC__SM_SFA_Process__c> lstSFA = new List<SVMXC__SM_SFA_Process__c>();
        SVMXC__SM_SFA_Process__c sfaWO = new SVMXC__SM_SFA_Process__c();
        sfaWO.SVMXC__SM_Expression__c = objSFMScheduledProcess.id;
        sfaWO.SVMXC__SM_Action_Type__c = 'Push Notification';
        sfaWO.SVMXC__SM_Description__c ='Test description';
        sfaWO.SVMXC__SM_Enabled__c = true;
        sfaWO.SVMXC__SM_Event_Type__c = 'Salesforce Event';
        sfaWO.SVMXC__SM_Object_API_Name__c = 'SVMXC__Service_Order__c';
        sfaWO.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"PUBNUB","Screen_To_Load":"SFM_VIEW","Recipient_Field_API_Names":["OwnerId","SVMXC__Preferred_Technician__c"],"RelatedList_Recipients":[{"RelatedList_Object_API_Name":"SVMXC__Service_Order_Line__c","RelatedList_Field_API_Name":"SVMXC__Service_Order__c","Relationship_Name":"SVMXC__Service_Order_Line__r","RelatedList_Recipient_Field":["SVMXC__Global_Member__c","SVMXC__Canceled_By__c"]},{"RelatedList_Object_API_Name":"SVMXC__Checklist__c","RelatedList_Field_API_Name":"SVMXC__Work_Order__c","Relationship_Name":"SVMXC__Checklists__r","RelatedList_Recipient_Field":["SVMXC__Completed_By__c"]}],"Message_Title":"Test title","Message_Body":"this is for testing Soumyaranjan [$Name] for [$SVMXC__Company__c]","Display_Object_Record":"SVMXC__Service_Order__c","Client_App_Name":"SVMXGO"}';
        sfaWO.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type":"Record_Created","Preview_Field_List":["Name","SVMXC__Order_Status__c","SVMXC__Company__r.Name","SVMXC__Contact__r.Name","SVMXC__Street__c ","SVMXC__City__c","SVMXC__State__c","SVMXC__Zip__c","SVMXC__Country__c","SVMXC__Priority__c"],"Object_API_Name":"SVMXC__Service_Order__c","Event_Trigger_Fields":null}';
        sfaWO.SVMXC__SM_SFA_Process_Id__c ='Test_WO_Process';
        sfaWO.SVMXC__SM_SFA_Process_Name__c = 'Test Wo Process';
        lstSFA.add(sfaWO);
        SVMXC__SM_SFA_Process__c  sfaWO1 = new SVMXC__SM_SFA_Process__c();
        sfaWO1.SVMXC__SM_Action_Type__c = 'Push Notification';
        sfaWO1.SVMXC__SM_Description__c ='Test description';
        sfaWO1.SVMXC__SM_Enabled__c = true;
        sfaWO1.SVMXC__SM_Event_Type__c = 'Salesforce Event';
        sfaWO1.SVMXC__SM_Object_API_Name__c = 'SVMXC__Service_Order__c';
        sfaWO1.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"PUBNUB","Screen_To_Load":"SFM_VIEW","Recipient_Field_API_Names":["OwnerId","SVMXC__Preferred_Technician__c"],"RelatedList_Recipients":[{"RelatedList_Object_API_Name":"SVMXC__Service_Order_Line__c","RelatedList_Field_API_Name":"SVMXC__Service_Order__c","Relationship_Name":"SVMXC__Service_Order_Line__r","RelatedList_Recipient_Field":["SVMXC__Global_Member__c","SVMXC__Canceled_By__c"]},{"RelatedList_Object_API_Name":"SVMXC__Checklist__c","RelatedList_Field_API_Name":"SVMXC__Work_Order__c","Relationship_Name":"SVMXC__Checklists__r","RelatedList_Recipient_Field":["SVMXC__Completed_By__c"]}],"Message_Title":"Test title","Message_Body":"this is for testing Anil [$Name]","Display_Object_Record":"SVMXC__Service_Order__c","Client_App_Name":"SVMXGO"}';
        sfaWO1.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type":"Record_Field_Updated","Preview_Field_List":["Name","SVMXC__Order_Status__c","SVMXC__Company__r.Name","SVMXC__Contact__r.Name","SVMXC__Street__c ","SVMXC__City__c","SVMXC__State__c","SVMXC__Zip__c","SVMXC__Country__c","SVMXC__Priority__c"],"Object_API_Name":"SVMXC__Service_Order__c","Event_Trigger_Fields":["SVMXC__Street__c"]}';
        sfaWO1.SVMXC__SM_SFA_Process_Id__c ='Test_WO_Process';
        sfaWO1.SVMXC__SM_SFA_Process_Name__c = 'Test Wo Process';
        lstSFA.add(sfaWO1);
        SVMXC__SM_SFA_Process__c sfaSMSWO = new SVMXC__SM_SFA_Process__c();
        sfaSMSWO.SVMXC__SM_Action_Type__c = 'SMS';
        sfaSMSWO.SVMXC__SM_Description__c ='Test description';
        sfaSMSWO.SVMXC__SM_Enabled__c = true;
        sfaSMSWO.SVMXC__SM_Event_Type__c = 'Salesforce Event';
        sfaSMSWO.SVMXC__SM_Object_API_Name__c = 'SVMXC__Service_Order__c';
        sfaSMSWO.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"SMS","Recipients":[{"relatedRefNameField":"SVMXC__Company__r","relatedObject":"Account","relatedField":["Phone","Fax"],"relatedCountryField":"BillingCountry","field":"SVMXC__Company__c","country":null,"contactnumber":null},{"relatedRefNameField":"SVMXC__Contact__r","relatedObject":"Contact","relatedField":["Fax","MobilePhone"],"relatedCountryField":"MailingCountry","field":"SVMXC__Contact__c","country":null,"contactnumber":null},{"relatedRefNameField":"SVMXC__Global_Member__r","relatedObject":"SVMXC__Service_Group_Members__c","relatedField":["SVMXC__Phone__c"],"relatedCountryField":"SVMXC__Country__c","field":"SVMXC__Global_Member__c","country":null,"contactnumber":null},{"relatedRefNameField":null,"relatedObject":null,"relatedField":null,"relatedCountryField":null,"field":"addition_number","country":"US","contactnumber":"9258767676"}],"Message_Body":"some text  [$SVMXC__Company__c] [$SVMXC__Age__c] [$SVMXC__Age_Bucket__c]","Display_Object_Record":"SVMXC__Service_Order__c"}';
        sfaSMSWO.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type": "Record_Created_or_Updated","Preview_Field_List": ["Name","SVMXC__Order_Status__c","SVMXC__Company__r.Name","SVMXC__Contact__r.Name","SVMXC__Street__c ","SVMXC__City__c","SVMXC__State__c","SVMXC__Zip__c","SVMXC__Country__c","SVMXC__Priority__c"],"Object_API_Name": "SVMXC__Service_Order__c","Event_Trigger_Fields": null}';
        sfaSMSWO.SVMXC__SM_SFA_Process_Id__c ='SMS_CONFIG_TEST';
        sfaSMSWO.SVMXC__SM_SFA_Process_Name__c = 'sms config test';
        lstSFA.add(sfaSMSWO);

        SVMXC__SM_SFA_Process__c sfaInterativeActionWO = new SVMXC__SM_SFA_Process__c();
        sfaInterativeActionWO.SVMXC__SM_Expression__c = objSFMScheduledProcess.id;
        sfaInterativeActionWO.SVMXC__SM_Action_Type__c = 'Push Notification';
        sfaInterativeActionWO.SVMXC__SM_Description__c ='Test description';
        sfaInterativeActionWO.SVMXC__SM_Enabled__c = true;
        sfaInterativeActionWO.SVMXC__SM_Event_Type__c = 'Salesforce Event';
        sfaInterativeActionWO.SVMXC__SM_Object_API_Name__c = 'SVMXC__Service_Order__c';
        sfaInterativeActionWO.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"PUBNUB","Screen_To_Load":"SFM_VIEW","Recipient_Related_Field_API_Names":null,"Recipient_Field_API_Names":["OwnerId"],"RelatedList_Recipients":[{"RelatedList_Object_API_Name":"SVMXC__Service_Order_Line__c","RelatedList_Field_API_Name":"SVMXC__Service_Order__c","Relationship_Name":"SVMXC__Service_Order_Line__r","RelatedList_Recipient_Field":["SVMXC__Global_Member__c","SVMXC__Canceled_By__c"]},{"RelatedList_Object_API_Name":"SVMXC__Checklist__c","RelatedList_Field_API_Name":"SVMXC__Work_Order__c","Relationship_Name":"SVMXC__Checklists__r","RelatedList_Recipient_Field":["SVMXC__Completed_By__c"]}],"Message_Title":"Test Interactive Action Vasu","Message_Body":"Test Interactive Action Vasu ","IsInteractiveAction":true,"InteractiveActions":[{"Target_Process_Id":"a122I00000Dq70BQAR","Process_Type":"SFM","Is_Background":false,"Button_Title":"Test Button 1","Button_Id":"SFA_Action_bf21cce0-1b92-11ea-b4c1-f9d16387e8f7"},{"Target_Process_Id":"a122I00000E1UoZQAV","Process_Type":"SFM","Is_Background":false,"Button_Title":"Test Button 2","Button_Id":"SFA_Action_c50b9ff0-1b92-11ea-b4c1-f9d16387e8f7"},{"Target_Process_Id":"a122I00000E3Q44QAF","Process_Type":"SFM","Is_Background":false,"Button_Title":"Test Button 3","Button_Id":"SFA_Action_cb942400-1b92-11ea-b4c1-f9d16387e8f7"}],"Display_Object_Record":"SVMXC__Service_Order__c","Client_App_Name":"SVMXGO"}';
        sfaInterativeActionWO.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type":"Record_Created_or_Updated","Preview_Field_List":["Name","SVMXC__Order_Status__c","SVMXC__Company__r.Name","SVMXC__Contact__r.Name","SVMXC__Street__c ","SVMXC__City__c","SVMXC__State__c","SVMXC__Zip__c","SVMXC__Country__c","SVMXC__Priority__c"],"Object_API_Name":"SVMXC__Service_Order__c","Event_Trigger_Fields":null}';
        sfaInterativeActionWO.SVMXC__SM_SFA_Process_Id__c ='SFA_INTERACTIVE_ACTION_CONFIG_TEST';
        sfaInterativeActionWO.SVMXC__SM_SFA_Process_Name__c = 'SFA_INTERACTIVE_ACTION_CONFIG_TEST';
        lstSFA.add(sfaInterativeActionWO);

        insert lstSFA;

        SVMXC__ServiceMax_Properties__c smsProperty = new SVMXC__ServiceMax_Properties__c();
        smsProperty.SVMXC__Value__c = 'SMS_Client_Token_001';
        smsProperty.Name = 'SMS_CLIENT_TOKEN';
        smsProperty.SVMXC__Key__c = 'SMS_CLIENT_TOKEN';
        insert smsProperty;

        SVMXC__SM_SFA_Process__c sfaWOFieldUpdate = new SVMXC__SM_SFA_Process__c();
        sfaWOFieldUpdate.SVMXC__SM_Action_Type__c = 'Push Notification';
        sfaWOFieldUpdate.SVMXC__SM_Description__c ='Field Update SFA Test for unit testing';
        sfaWOFieldUpdate.SVMXC__SM_Enabled__c = true;
        sfaWOFieldUpdate.SVMXC__SM_Event_Type__c = 'Salesforce Event';
        sfaWOFieldUpdate.SVMXC__SM_Object_API_Name__c = 'SVMXC__Service_Order__c';
        sfaWOFieldUpdate.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"PUBNUB","Screen_To_Load":"SFM_VIEW","Recipient_Related_Field_API_Names":null,"Recipient_Field_API_Names":["OwnerId"],"RelatedList_Recipients":[{"RelatedList_Object_API_Name":"SVMXC__Service_Order_Line__c","RelatedList_Field_API_Name":"SVMXC__Service_Order__c","Relationship_Name":"SVMXC__Service_Order_Line__r","RelatedList_Recipient_Field":["SVMXC__Global_Member__c","SVMXC__Canceled_By__c"]},{"RelatedList_Object_API_Name":"SVMXC__Checklist__c","RelatedList_Field_API_Name":"SVMXC__Work_Order__c","Relationship_Name":"SVMXC__Checklists__r","RelatedList_Recipient_Field":["SVMXC__Completed_By__c"]}],"Message_Title":"Field Update SFA Test","Message_Body":"Field Update SFA Test date field value [$SVMXC__Scheduled_Date__c] \ndate time field value [$SVMXC__Canceled_Date_Time__c]","IsInteractiveAction":true,"InteractiveActions":[{"Target_Process_Id":"046339_Check_fields_not_inPL","Process_Type":"SFM","Is_Background":false,"Button_Title":"Button-1","Button_Id":"SFA_Action_1bcf5d90-5f18-11ea-9d9d-ab2990bd3338"}],"Display_Object_Record":"SVMXC__Service_Order__c","Client_App_Name":"SVMXGO"}';
        sfaWOFieldUpdate.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type":"Record_Field_Updated","Preview_Field_List":["Name","SVMXC__Order_Status__c","SVMXC__Company__r.Name","SVMXC__Contact__r.Name","SVMXC__Street__c ","SVMXC__City__c","SVMXC__State__c","SVMXC__Zip__c","SVMXC__Country__c","SVMXC__Priority__c"],"Object_API_Name":"SVMXC__Service_Order__c","Event_Trigger_Fields":["SVMXC__Age__c","SVMXC__Billing_Type__c","SVMXC__City__c"]}';
        sfaWOFieldUpdate.SVMXC__SM_SFA_Process_Id__c ='FIELD_UPDATE_SFA_TEST';
        sfaWOFieldUpdate.SVMXC__SM_SFA_Process_Name__c = 'Field Update SFA Test';
        lstSFA.add(sfaWOFieldUpdate);
    }

    static testMethod void PublishEventUpdateInsertWORD_UT()
    {
        String objectName = 'SVMXC__Service_Order__c';
        String query=getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_WORD');
        System.debug(query);
        SFA_PlatformEventPublish sfAplaformevent= new SFA_PlatformEventPublish();
        List<SVMXC__Service_Order__c> woLst = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c objtoinsert = new SVMXC__Service_Order__c();
        objtoinsert.SVMXC__City__c = 'Ahmedabad';
        woLst.add(objtoinsert);
        insert woLst;
        String ids = woLst[0].id;
        query = query +' from '+objectName + ' where ' +'id =\''+ ids +'\'';
        System.debug(query);
        List<SVMXC__Service_Order__c> lstWo = Database.query(query);
        SFA_PlatformEventpublish sfplatevent = new SFA_PlatformEventpublish();
        sfplatevent.publishEventAfterInsert(lstWo,objectName);
        List<SVMXC__Service_Order__c> woLst1 = woLst;
        woLst1[0].SVMXC__City__c ='Bangalore';
        update woLst1[0];
        sfplatevent.publishEventAfterUpdate(woLst1,woLst1,objectName);
    }

    static testMethod void PublishEventUpdateInsertEvent_UT()
    {
        String objectName = 'Event';
        String query=getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_EVENT');
        System.debug(query);
        SFA_PlatformEventPublish sfAplaformevent= new SFA_PlatformEventPublish();
        List<Event> evLst = new List<Event>();
        Event objtoinsert = new Event();
        objtoinsert.StartDateTime = System.today();
        objtoinsert.EndDateTime = System.today()+2;
        evLst.add(objtoinsert);
        insert evLst;
        String ids = evLst[0].id;
        query = query +' from '+objectName + ' where ' +'id =\''+ ids +'\'';
        System.debug(query);
        List<Event> lsteve = Database.query(query);
        SFA_PlatformEventpublish sfplatevent = new SFA_PlatformEventpublish();
        sfplatevent.publishEventAfterInsert(lsteve,objectName);
        List<Event> evLst1 = evLst;
        evLst1[0].StartDateTime = System.today()+1;
        update evLst1[0];
        sfplatevent.publishEventAfterUpdate(evLst1,evLst1,objectName);
    }

    static testMethod void PublishEventUpdateInsertSVMXEvent_UT()
    {
        String objectName = 'SVMXC__SVMX_Event__c';
        String query=getFieldSetFields(objectName,'SVMXC__SM_SFA_Fields_SVMXEVENT');
        System.debug(query);
        SFA_PlatformEventPublish sfAplaformevent= new SFA_PlatformEventPublish();
        List<SVMXC__SVMX_Event__c> evLst = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c objtoinsert = new SVMXC__SVMX_Event__c();
        objtoinsert.SVMXC__StartDateTime__c = System.today();
        objtoinsert.SVMXC__EndDateTime__c = System.today()+2;
        evLst.add(objtoinsert);
        insert evLst;
        String ids = evLst[0].id;
        query = query +' from '+objectName + ' where ' +'id =\''+ ids +'\'';
        System.debug(query);
        List<SVMXC__SVMX_Event__c> lstWo = Database.query(query);
        SFA_PlatformEventpublish sfplatevent = new SFA_PlatformEventpublish();
        sfplatevent.publishEventAfterInsert(lstWo,objectName);
        List<SVMXC__SVMX_Event__c> evLst1 = evLst;
        evLst1[0].SVMXC__StartDateTime__c = System.today()+1;
        update evLst1[0];
        sfplatevent.publishEventAfterUpdate(evLst1,evLst1,objectName);
    }

      public static String getFieldSetFields(String objectname,String fieldSetName) {
          String query = 'SELECT ID,';
          Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
          Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
          Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

          Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
          List<Schema.FieldSetMember> fields = fieldSetObj.getFields();
          //List<String> lstOfField= new List<String>();
          if(fields!=null && fields.size() >0)
          {
              for(Schema.FieldSetMember member:fields )
              {
                  if(member.getFieldPath().equalsIgnoreCase('ID'))
                  {
                      continue;
                  }
                  //lstOfField.add(member.getFieldPath());
                  query = query + member.getFieldPath()+',';
              }
          }
          String query1 = query.substring(0, query.length()-1);
          return query1;
      }

      static testMethod void trigger_SFA_Push_Notifiaction_UT() {
          SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
          plEvent.SVMXC__New_Record_JSON__c = 'TestJSon';
          plEvent.SVMXC__Record_Id__c = '123456789710';
          plEvent.SVMXC__Event_Type__c = 'Inserted';
          plEvent.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
          Test.startTest();
          Database.SaveResult sr = EventBus.publish(plEvent);
          Test.stopTest();
          System.assertEquals(true, sr.isSuccess());
      }

      static testMethod void trigger_SFA_Push_Notifiaction_TriggerHandler(){
          SVMXC__Service_Group__c sgm = new SVMXC__Service_Group__c();
          sgm.Name = 'Bhubaneswar tech';
          sgm.SVMXC__Active__c = true;
          insert sgm;
          SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
          tech.Name = 'Test Service members';
          tech.SVMXC__Service_Group__c = sgm.id;
          insert tech;
          SVMXC__Service_Order__c objtoinsert = new SVMXC__Service_Order__c();
          objtoinsert.SVMXC__City__c = 'Bhubaneswar';
          objtoinsert.SVMXC__Order_Status__c ='Open';
          objtoinsert.SVMXC__Preferred_Technician__c = tech.id;
          insert objtoinsert;
          SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
          plEvent.SVMXC__New_Record_JSON__c = 'TestJSon';
          plEvent.SVMXC__Record_Id__c = String.valueOf(objtoinsert.id);
          plEvent.SVMXC__Event_Type__c = 'Inserted';
          plEvent.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
          Test.startTest();
          Database.SaveResult sr = EventBus.publish(plEvent);
          Test.stopTest();
          System.assertEquals(true, sr.isSuccess());
      }

      static testMethod void trigger_SFA_Push_Notifiaction_TriggerHandlerforEvents(){
          SVMXC__SM_SFA_Process__c  sfaWO = new SVMXC__SM_SFA_Process__c();
          sfaWO.SVMXC__SM_Action_Type__c = 'Push Notification';
          sfaWO.SVMXC__SM_Description__c ='Test description';
          sfaWO.SVMXC__SM_Enabled__c = true;
          sfaWO.SVMXC__SM_Event_Type__c = 'Salesforce Event';
          sfaWO.SVMXC__SM_Object_API_Name__c = 'Event';
          sfaWO.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"PUBNUB","Screen_To_Load":"SFM_VIEW","Recipient_Field_API_Names":["OwnerId"],"Message_Title":"Test Salesforce events","Message_Body":"This is a test message for Salesforce events  [$Subject]","Display_Object_Record":"Event","Client_App_Name":"SVMXGO"}';
          sfaWO.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type":"Record_Created","Preview_Field_List":["StartDateTime","EndDateTime","Name","SVMXC__Order_Status__c","SVMXC__Company__r.Name","SVMXC__Contact__r.Name","SVMXC__Street__c","SVMXC__City__c","SVMXC__State__c","SVMXC__Zip__c","SVMXC__Country__c","SVMXC__Priority__c"],"Object_API_Name":"Event","Event_Trigger_Fields":["WhoId"]}';
          sfaWO.SVMXC__SM_SFA_Process_Id__c ='Test_WO_Process';
          sfaWO.SVMXC__SM_SFA_Process_Name__c = 'Test Wo Process';
          insert sfaWO;
          SVMXC__Service_Order__c objtoinsert = new SVMXC__Service_Order__c();
          objtoinsert.SVMXC__City__c = 'Bhubaneswar';
          objtoinsert.SVMXC__Order_Status__c ='Open';
          insert objtoinsert;
          Event noAppointmentKept = new Event(StartDateTime=system.today(),EndDateTime=system.today()+5,Subject = 'Call', WhatId = objtoinsert.id);

          insert noAppointmentkept;
          SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
          plEvent.SVMXC__New_Record_JSON__c = 'TestJSon';
          plEvent.SVMXC__Record_Id__c = String.valueOf(noAppointmentkept.id);
          plEvent.SVMXC__Event_Type__c = 'Inserted';
          plEvent.SVMXC__Object_Name__c = 'Event';
          Test.startTest();
          Database.SaveResult sr = EventBus.publish(plEvent);
          Test.stopTest();
          System.assertEquals(true, sr.isSuccess());
      }

      static testMethod void trigger_SFA_Push_Notifiaction_TriggerHandlerforSVMXEvents(){
          SVMXC__SM_SFA_Process__c  sfaWO = new SVMXC__SM_SFA_Process__c();
          sfaWO.SVMXC__SM_Action_Type__c = 'Push Notification';
          sfaWO.SVMXC__SM_Description__c ='Test description';
          sfaWO.SVMXC__SM_Enabled__c = true;
          sfaWO.SVMXC__SM_Event_Type__c = 'Salesforce Event';
          sfaWO.SVMXC__SM_Object_API_Name__c = 'SVMXC__SVMX_Event__c';
          sfaWO.SVMXC__SM_SFA_Action_JSON__c = '{"Service_Provider":"PUBNUB","Screen_To_Load":"SFM_VIEW","Recipient_Field_API_Names":["OwnerId"],"Message_Title":"Test Salesforce events","Message_Body":"This is a test message for Salesforce events  [$Name]","Display_Object_Record":"SVMXC__SVMX_Event__c","Client_App_Name":"SVMXGO"}';
          sfaWO.SVMXC__SM_SFA_Event_JSON__c = '{"SFDC_Data_Event_Type":"Record_Created","Preview_Field_List":["SVMXC__StartDateTime__c","SVMXC__EndDateTime__c","SVMXC__Service_Order__r.Name","SVMXC__Service_Order__r.SVMXC__Company__r.Name","SVMXC__Service_Order__r.SVMXC__Contact__r.Name","SVMXC__Service_Order__r.SVMXC__Order_Status__c","SVMXC__Service_Order__r.SVMXC__Street__c ","SVMXC__Service_Order__r.SVMXC__City__c","SVMXC__Service_Order__r.SVMXC__State__c","SVMXC__Service_Order__r.SVMXC__Zip__c","SVMXC__Service_Order__r.SVMXC__Country__c","SVMXC__Service_Order__r.SVMXC__Priority__c"],"Object_API_Name":"SVMXC__SVMX_Event__c","Event_Trigger_Fields":null}';
          sfaWO.SVMXC__SM_SFA_Process_Id__c ='Test_WO_Process';
          sfaWO.SVMXC__SM_SFA_Process_Name__c = 'Test Wo Process';
          insert sfaWO;
          SVMXC__Service_Order__c objtoinsert = new SVMXC__Service_Order__c();
          objtoinsert.SVMXC__City__c = 'Bhubaneswar';
          objtoinsert.SVMXC__Order_Status__c ='Open';
          insert objtoinsert;
          SVMXC__SVMX_Event__c noAppointmentKept = new SVMXC__SVMX_Event__c(SVMXC__StartDateTime__c=system.today(),SVMXC__EndDateTime__c=system.today()+5,Name = 'Call', SVMXC__Service_Order__c = objtoinsert.id);

          insert noAppointmentkept;
          SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
          plEvent.SVMXC__New_Record_JSON__c = 'TestJSon';
          plEvent.SVMXC__Record_Id__c = String.valueOf(noAppointmentkept.id);
          plEvent.SVMXC__Event_Type__c = 'Inserted';
          plEvent.SVMXC__Object_Name__c = 'SVMXC__SVMX_Event__c';
          Test.startTest();
          Database.SaveResult sr = EventBus.publish(plEvent);
          Test.stopTest();
          System.assertEquals(true, sr.isSuccess());
      }

      static testMethod void trigger_SFA_Push_Notifiaction_TriggerHandlerWoEdit(){
          SVMXC__Service_Group__c sgm = new SVMXC__Service_Group__c();
          sgm.Name = 'Bhubaneswar tech';
          sgm.SVMXC__Active__c = true;
          insert sgm;
          SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
          tech.Name = 'Test Service members';
          tech.SVMXC__Service_Group__c = sgm.id;
          insert tech;
          SVMXC__Service_Order__c objtoinsert = new SVMXC__Service_Order__c();
          objtoinsert.SVMXC__City__c = 'Bhubaneswar';
          objtoinsert.SVMXC__Order_Status__c ='Open';
          objtoinsert.SVMXC__Preferred_Technician__c = tech.id;
          insert objtoinsert;

          SFA_WrapperDef.SFA_RecordWrapper old_Record = new SFA_WrapperDef.SFA_RecordWrapper();
          SFA_WrapperDef.SFA_RecordWrapper new_Record = new SFA_WrapperDef.SFA_RecordWrapper();

          old_Record.mapfieldNameValues.put('SVMXC__Street__c','Bhubaneswar');
          new_Record.mapfieldNameValues.put('SVMXC__Street__c','Cuttack');

          String strOldObjJson = JSON.serialize(old_Record);
          String strNewObjJson = JSON.serialize(new_Record);
          SVMXC__SFA_Platform_Event__e plEvent = new SVMXC__SFA_Platform_Event__e();
          plEvent.SVMXC__New_Record_JSON__c = strOldObjJson;
          plEvent.SVMXC__Old_Record_JSON__c = strNewObjJson;
          plEvent.SVMXC__Record_Id__c = String.valueOf(objtoinsert.id);
          plEvent.SVMXC__Event_Type__c = 'Updated';
          plEvent.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
          Test.startTest();
          Database.SaveResult sr = EventBus.publish(plEvent);
          Test.stopTest();
          System.assertEquals(true, sr.isSuccess());
      }

      private static String createGlobalProfileId() {
        SVMXC__ServiceMax_Config_Data__c GlobalProfile = new SVMXC__ServiceMax_Config_Data__c();
        GlobalProfile.RecordTypeId = [select Id from RecordType Where Name = 'Configuration Profile' limit 1][0].Id;
        GlobalProfile.SVMXC__Configuration_Type__c = 'Global';
        GlobalProfile.SVMXC__Profile_Name__c = 'Global Profile For Unit Testing';
        GlobalProfile.SVMXC__Description__c = 'Global Profile For Unit Testing';
        GlobalProfile.SVMXC__IsDefault__c = false;
        GlobalProfile.SVMXC__Active__c = true;
        insert GlobalProfile;

        SVMXC__ServiceMax_Config_Data__c GlobalProfileAccess = new SVMXC__ServiceMax_Config_Data__c();
        GlobalProfileAccess.RecordTypeId = [select Id from RecordType Where Name = 'Configuration Access' limit 1][0].Id;
        GlobalProfileAccess.SVMXC__Access_Configuration_Profile__c = GlobalProfile.Id;
        GlobalProfileAccess.SVMXC__Active__c = true;
        GlobalProfileAccess.SVMXC__Profile__c = UserInfo.getProfileId();
        insert GlobalProfileAccess;

        return GlobalProfile.Id;
      }
      private static void createSFASettings(String GlobalProfileId) {
        String installationKey = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) ));
        String settingRecordTypeId = [SELECT Id from RecordType where Name = 'Settings'][0].Id;
        String settingValueRecordTypeId = [SELECT Id from RecordType where Name = 'Setting Value'][0].Id;

        SVMXC__ServiceMax_Processes__c subModuleProcess = new SVMXC__ServiceMax_Processes__c();
        subModuleProcess.SVMXC__SubmoduleID__c = 'SFA001';
        subModuleProcess.RecordTypeId = [SELECT Id from RecordType where Name = 'Submodule'][0].Id;
        subModuleProcess.SVMXC__Installation_Key__c = installationKey;
        insert subModuleProcess;

        List<SVMXC__ServiceMax_Processes__c> settingsProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c sfaSet001Process = new SVMXC__ServiceMax_Processes__c();
        sfaSet001Process.SVMXC__Submodule__c = subModuleProcess.Id;
        sfaSet001Process.SVMXC__Active__c = true;
        sfaSet001Process.SVMXC__SettingID__c = 'SET001';
        sfaSet001Process.SVMXC__Setting_Type__c = 'Global';
        sfaSet001Process.SVMXC__Search_Order__c = 'Global';
        sfaSet001Process.SVMXC__Data_Type__c = 'Boolean';
        sfaSet001Process.RecordTypeId = settingRecordTypeId;
        sfaSet001Process.SVMXC__Installation_Key__c = installationKey;
        settingsProcesses.add(sfaSet001Process);
        SVMXC__ServiceMax_Processes__c sfaSet002Process = new SVMXC__ServiceMax_Processes__c();
        sfaSet002Process.SVMXC__Submodule__c = subModuleProcess.Id;
        sfaSet002Process.SVMXC__Active__c = true;
        sfaSet002Process.SVMXC__SettingID__c = 'SET002';
        sfaSet002Process.SVMXC__Setting_Type__c = 'Global';
        sfaSet002Process.SVMXC__Search_Order__c = 'Global';
        sfaSet002Process.SVMXC__Data_Type__c = 'Text';
        sfaSet002Process.RecordTypeId = settingRecordTypeId;
        sfaSet002Process.SVMXC__Installation_Key__c = installationKey;
        settingsProcesses.add(sfaSet002Process);
        SVMXC__ServiceMax_Processes__c sfaSet003Process = new SVMXC__ServiceMax_Processes__c();
        sfaSet003Process.SVMXC__Submodule__c = subModuleProcess.Id;
        sfaSet003Process.SVMXC__Active__c = true;
        sfaSet003Process.SVMXC__SettingID__c = 'SET003';
        sfaSet003Process.SVMXC__Setting_Type__c = 'Global';
        sfaSet003Process.SVMXC__Search_Order__c = 'Global';
        sfaSet003Process.SVMXC__Data_Type__c = 'Text';
        sfaSet003Process.RecordTypeId = settingRecordTypeId;
        sfaSet003Process.SVMXC__Installation_Key__c = installationKey;
        settingsProcesses.add(sfaSet003Process);
        SVMXC__ServiceMax_Processes__c sfaSet004Process = new SVMXC__ServiceMax_Processes__c();
        sfaSet004Process.SVMXC__Submodule__c = subModuleProcess.Id;
        sfaSet004Process.SVMXC__Active__c = true;
        sfaSet004Process.SVMXC__SettingID__c = 'SET004';
        sfaSet004Process.SVMXC__Setting_Type__c = 'Global';
        sfaSet004Process.SVMXC__Search_Order__c = 'Global';
        sfaSet004Process.SVMXC__Data_Type__c = 'Text';
        sfaSet004Process.RecordTypeId = settingRecordTypeId;
        sfaSet004Process.SVMXC__Installation_Key__c = installationKey;
        settingsProcesses.add(sfaSet004Process);
        SVMXC__ServiceMax_Processes__c sfaSet005Process = new SVMXC__ServiceMax_Processes__c();
        sfaSet005Process.SVMXC__Submodule__c = subModuleProcess.Id;
        sfaSet005Process.SVMXC__Active__c = true;
        sfaSet005Process.SVMXC__SettingID__c = 'SET005';
        sfaSet005Process.SVMXC__Setting_Type__c = 'Global';
        sfaSet005Process.SVMXC__Search_Order__c = 'Global';
        sfaSet005Process.SVMXC__Data_Type__c = 'Text';
        sfaSet005Process.RecordTypeId = settingRecordTypeId;
        sfaSet005Process.SVMXC__Installation_Key__c = installationKey;
        settingsProcesses.add(sfaSet005Process);
        SVMXC__ServiceMax_Processes__c sfaSet006Process = new SVMXC__ServiceMax_Processes__c();
        sfaSet006Process.SVMXC__Submodule__c = subModuleProcess.Id;
        sfaSet006Process.SVMXC__Active__c = true;
        sfaSet006Process.SVMXC__SettingID__c = 'SET006';
        sfaSet006Process.SVMXC__Setting_Type__c = 'Global';
        sfaSet006Process.SVMXC__Search_Order__c = 'Global';
        sfaSet006Process.SVMXC__Data_Type__c = 'Text';
        sfaSet006Process.RecordTypeId = settingRecordTypeId;
        sfaSet006Process.SVMXC__Installation_Key__c = installationKey;
        settingsProcesses.add(sfaSet006Process);
        insert settingsProcesses;

        List<SVMXC__ServiceMax_Config_Data__c> settingValuesConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c setValue001Config = new SVMXC__ServiceMax_Config_Data__c();
        setValue001Config.SVMXC__Setting_ID__c = sfaSet001Process.Id;
        setValue001Config.SVMXC__Internal_Value__c = 'true';
        setValue001Config.RecordTypeId = settingValueRecordTypeId;
        setValue001Config.SVMXC__Setting_Configuration_Profile__c = GlobalProfileId;
        setValue001Config.SVMXC__Active__c = true;
        settingValuesConfigData.add(setValue001Config);
        SVMXC__ServiceMax_Config_Data__c setValue002Config = new SVMXC__ServiceMax_Config_Data__c();
        setValue002Config.SVMXC__Setting_ID__c = sfaSet002Process.Id;
        setValue002Config.SVMXC__Internal_Value__c = 'SET002-Value';
        setValue002Config.RecordTypeId = settingValueRecordTypeId;
        setValue002Config.SVMXC__Setting_Configuration_Profile__c = GlobalProfileId;
        setValue002Config.SVMXC__Active__c = true;
        settingValuesConfigData.add(setValue002Config);
        SVMXC__ServiceMax_Config_Data__c setValue003Config = new SVMXC__ServiceMax_Config_Data__c();
        setValue003Config.SVMXC__Setting_ID__c = sfaSet003Process.Id;
        setValue003Config.SVMXC__Internal_Value__c = 'SET003-Value';
        setValue003Config.RecordTypeId = settingValueRecordTypeId;
        setValue003Config.SVMXC__Setting_Configuration_Profile__c = GlobalProfileId;
        setValue003Config.SVMXC__Active__c = true;
        settingValuesConfigData.add(setValue003Config);
        SVMXC__ServiceMax_Config_Data__c setValue004Config = new SVMXC__ServiceMax_Config_Data__c();
        setValue004Config.SVMXC__Setting_ID__c = sfaSet004Process.Id;
        setValue004Config.SVMXC__Internal_Value__c = 'SET004-Value';
        setValue004Config.RecordTypeId = settingValueRecordTypeId;
        setValue004Config.SVMXC__Setting_Configuration_Profile__c = GlobalProfileId;
        setValue004Config.SVMXC__Active__c = true;
        settingValuesConfigData.add(setValue004Config);
        SVMXC__ServiceMax_Config_Data__c setValue005Config = new SVMXC__ServiceMax_Config_Data__c();
        setValue005Config.SVMXC__Setting_ID__c = sfaSet005Process.Id;
        setValue005Config.SVMXC__Internal_Value__c = 'SET005-Value';
        setValue005Config.RecordTypeId = settingValueRecordTypeId;
        setValue005Config.SVMXC__Setting_Configuration_Profile__c = GlobalProfileId;
        setValue005Config.SVMXC__Active__c = true;
        settingValuesConfigData.add(setValue005Config);
        SVMXC__ServiceMax_Config_Data__c setValue006Config = new SVMXC__ServiceMax_Config_Data__c();
        setValue006Config.SVMXC__Setting_ID__c = sfaSet006Process.Id;
        setValue006Config.SVMXC__Internal_Value__c = 'SET006-Value';
        setValue006Config.RecordTypeId = settingValueRecordTypeId;
        setValue006Config.SVMXC__Setting_Configuration_Profile__c = GlobalProfileId;
        setValue006Config.SVMXC__Active__c = true;
        settingValuesConfigData.add(setValue006Config);
        insert settingValuesConfigData;
      }
}