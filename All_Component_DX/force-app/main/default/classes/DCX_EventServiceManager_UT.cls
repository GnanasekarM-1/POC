/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more informaOSertion about Testing and Code Coverage.
 */

@isTest ()
private class DCX_EventServiceManager_UT {

    @testSetup static void setup() {
        SVMXC__ServiceMax_Config_Data__c globalProfile = new SVMXC__ServiceMax_Config_Data__c(); 
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = 
            new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> settingValues = new List<SVMXC__ServiceMax_Processes__c>();

        list<BusinessHours> BHour = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];


        globalProfile.recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
        globalProfile.SVMXC__Configuration_Type__c = 'Global';
        globalProfile.SVMXC__Active__c = true;
        insert globalProfile;

        SVMXC__ServiceMax_Processes__c dcon001Process = new SVMXC__ServiceMax_Processes__c();
        dcon001Process.SVMXC__SubmoduleID__c = 'DCON001';
         dcon001Process.SVMXC__MapID__c = 'dcon001Process';
        insert dcon001Process;

        SVMXC__ServiceMax_Processes__c set001Process = new SVMXC__ServiceMax_Processes__c();
        set001Process.SVMXC__SettingID__c = 'SET001';
        set001Process.SVMXC__Submodule__c = dcon001Process.Id;
         set001Process.SVMXC__MapID__c = 'set001Process';
        settingValues.add(set001Process);

        SVMXC__ServiceMax_Processes__c set004Process = new SVMXC__ServiceMax_Processes__c();
        set004Process.SVMXC__SettingID__c = 'SET004';
        set004Process.SVMXC__Submodule__c = dcon001Process.Id;
         set004Process.SVMXC__MapID__c = 'set004Process';
        settingValues.add(set004Process);

        SVMXC__ServiceMax_Processes__c set024Process = new SVMXC__ServiceMax_Processes__c();
        set024Process.SVMXC__SettingID__c = 'SET024';
        set024Process.SVMXC__Submodule__c = dcon001Process.Id;
         set024Process.SVMXC__MapID__c = 'set024Process';
        settingValues.add(set024Process);

        SVMXC__ServiceMax_Processes__c set025Process = new SVMXC__ServiceMax_Processes__c();
        set025Process.SVMXC__SettingID__c = 'SET025';
        set025Process.SVMXC__Submodule__c = dcon001Process.Id;
         set025Process.SVMXC__MapID__c = 'set025Process';
        settingValues.add(set025Process);

        SVMXC__ServiceMax_Processes__c set026Process = new SVMXC__ServiceMax_Processes__c();
        set026Process.SVMXC__SettingID__c = 'SET026';
        set026Process.SVMXC__Submodule__c = dcon001Process.Id;
         set026Process.SVMXC__MapID__c = 'set026Process';
        settingValues.add(set026Process);

        SVMXC__ServiceMax_Processes__c set028Process = new SVMXC__ServiceMax_Processes__c();
        set028Process.SVMXC__SettingID__c = 'SET028';
        set028Process.SVMXC__Submodule__c = dcon001Process.Id;
         set028Process.SVMXC__MapID__c = 'set028Process';
        settingValues.add(set028Process);

        SVMXC__ServiceMax_Processes__c set033Process = new SVMXC__ServiceMax_Processes__c();
        set033Process.SVMXC__SettingID__c = 'SET033';
        set033Process.SVMXC__Submodule__c = dcon001Process.Id;
         set033Process.SVMXC__MapID__c = 'set033Process';
        settingValues.add(set033Process);

        SVMXC__ServiceMax_Processes__c set034Process = new SVMXC__ServiceMax_Processes__c();
        set034Process.SVMXC__SettingID__c = 'SET034';
        set034Process.SVMXC__Submodule__c = dcon001Process.Id;
         set034Process.SVMXC__MapID__c = 'set034Process';
        settingValues.add(set034Process);

        SVMXC__ServiceMax_Processes__c set038Process = new SVMXC__ServiceMax_Processes__c();
        set038Process.SVMXC__SettingID__c = 'SET038';
        set038Process.SVMXC__Submodule__c = dcon001Process.Id;
         set038Process.SVMXC__MapID__c = 'set038Process';
        settingValues.add(set038Process);

        SVMXC__ServiceMax_Processes__c set039Process = new SVMXC__ServiceMax_Processes__c();
        set039Process.SVMXC__SettingID__c = 'SET039';
        set039Process.SVMXC__Submodule__c = dcon001Process.Id;
         set039Process.SVMXC__MapID__c = 'set039Process';
        settingValues.add(set039Process);

        SVMXC__ServiceMax_Processes__c set040Process = new SVMXC__ServiceMax_Processes__c();
        set040Process.SVMXC__SettingID__c = 'SET040';
        set040Process.SVMXC__Submodule__c = dcon001Process.Id;
         set040Process.SVMXC__MapID__c = 'set040Process';
        settingValues.add(set040Process);

        SVMXC__ServiceMax_Processes__c set041Process = new SVMXC__ServiceMax_Processes__c();
        set041Process.SVMXC__SettingID__c = 'SET041';
        set041Process.SVMXC__Submodule__c = dcon001Process.Id;
         set041Process.SVMXC__MapID__c = 'set041Process';
        settingValues.add(set041Process);

        SVMXC__ServiceMax_Processes__c set042Process = new SVMXC__ServiceMax_Processes__c();
        set042Process.SVMXC__SettingID__c = 'SET042';
        set042Process.SVMXC__Submodule__c = dcon001Process.Id;
         set042Process.SVMXC__MapID__c = 'set042Process';
        settingValues.add(set042Process);

        SVMXC__ServiceMax_Processes__c set043Process = new SVMXC__ServiceMax_Processes__c();
        set043Process.SVMXC__SettingID__c = 'SET043';
        set043Process.SVMXC__Submodule__c = dcon001Process.Id;
         set043Process.SVMXC__MapID__c = 'set043Process';
        settingValues.add(set043Process);

        SVMXC__ServiceMax_Processes__c set044Process = new SVMXC__ServiceMax_Processes__c();
        set044Process.SVMXC__SettingID__c = 'SET044';
        set044Process.SVMXC__Submodule__c = dcon001Process.Id;
         set044Process.SVMXC__MapID__c = 'set044Process';
        settingValues.add(set044Process);

        SVMXC__ServiceMax_Processes__c set045Process = new SVMXC__ServiceMax_Processes__c();
        set045Process.SVMXC__SettingID__c = 'SET045';
        set045Process.SVMXC__Submodule__c = dcon001Process.Id;
         set045Process.SVMXC__MapID__c = 'set045Process';
        settingValues.add(set045Process);

        SVMXC__ServiceMax_Processes__c set046Process = new SVMXC__ServiceMax_Processes__c();
        set046Process.SVMXC__SettingID__c = 'SET046';
        set046Process.SVMXC__Submodule__c = dcon001Process.Id;
         set046Process.SVMXC__MapID__c = 'set046Process';
        settingValues.add(set046Process);

        SVMXC__ServiceMax_Processes__c set047Process = new SVMXC__ServiceMax_Processes__c();
        set047Process.SVMXC__SettingID__c = 'SET047';
        set047Process.SVMXC__Submodule__c = dcon001Process.Id;
         set047Process.SVMXC__MapID__c = 'set047Process';
        settingValues.add(set047Process);

        SVMXC__ServiceMax_Processes__c set062Process = new SVMXC__ServiceMax_Processes__c();
        set062Process.SVMXC__SettingID__c = 'SET062';
        set062Process.SVMXC__Submodule__c = dcon001Process.Id;
         set062Process.SVMXC__MapID__c = 'set062Process';
        settingValues.add(set062Process);

        SVMXC__ServiceMax_Processes__c set070Process = new SVMXC__ServiceMax_Processes__c();
        set070Process.SVMXC__SettingID__c = 'SET070';
        set070Process.SVMXC__Submodule__c = dcon001Process.Id;
        set070Process.SVMXC__MapID__c = 'set070Process';
        settingValues.add(set070Process);
        
        insert settingValues;

        String settingValueRecordTypeId = 
            COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');

        SVMXC__ServiceMax_Config_Data__c set001Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set001Setting.SVMXC__Internal_Value__c = '5';
        set001Setting.SVMXC__Display_Value__c = '5';
        set001Setting.recordtypeid = settingValueRecordTypeId;
        set001Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set001Setting.SVMXC__Setting_ID__c = set001Process.Id;
        configDataList.add(set001Setting);

        SVMXC__ServiceMax_Config_Data__c set004Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set004Setting.SVMXC__Internal_Value__c = 'TEAM';
        set004Setting.SVMXC__Display_Value__c = 'TEAM';
        set004Setting.recordtypeid = settingValueRecordTypeId;
        set004Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set004Setting.SVMXC__Setting_ID__c = set004Process.Id;
        configDataList.add(set004Setting);

        SVMXC__ServiceMax_Config_Data__c set024Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set024Setting.SVMXC__Internal_Value__c = 'False';
        set024Setting.SVMXC__Display_Value__c = 'False';
        set024Setting.recordtypeid = settingValueRecordTypeId;
        set024Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set024Setting.SVMXC__Setting_ID__c = set024Process.Id;
        configDataList.add(set024Setting);

        SVMXC__ServiceMax_Config_Data__c set025Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set025Setting.SVMXC__Internal_Value__c = 'DISALLOW';
        set025Setting.SVMXC__Display_Value__c = 'DISALLOW';
        set025Setting.recordtypeid = settingValueRecordTypeId;
        set025Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set025Setting.SVMXC__Setting_ID__c = set025Process.Id;
        configDataList.add(set025Setting);

        SVMXC__ServiceMax_Config_Data__c set026Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set026Setting.SVMXC__Internal_Value__c = 'TRUE';
        set026Setting.SVMXC__Display_Value__c = 'TRUE';
        set026Setting.recordtypeid = settingValueRecordTypeId;
        set026Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set026Setting.SVMXC__Setting_ID__c = set026Process.Id;
        configDataList.add(set026Setting);

        SVMXC__ServiceMax_Config_Data__c set028Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set028Setting.SVMXC__Internal_Value__c = 'TRUE';
        set028Setting.SVMXC__Display_Value__c = 'TRUE';
        set028Setting.recordtypeid = settingValueRecordTypeId;
        set028Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set028Setting.SVMXC__Setting_ID__c = set028Process.Id;
        configDataList.add(set028Setting);

        SVMXC__ServiceMax_Config_Data__c set033Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set033Setting.SVMXC__Internal_Value__c = '10';
        set033Setting.SVMXC__Display_Value__c = '10';
        set033Setting.recordtypeid = settingValueRecordTypeId;
        set033Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set033Setting.SVMXC__Setting_ID__c = set033Process.Id;
        configDataList.add(set033Setting);

        SVMXC__ServiceMax_Config_Data__c set034Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set034Setting.SVMXC__Internal_Value__c = '10';
        set034Setting.SVMXC__Display_Value__c = '10';
        set034Setting.recordtypeid = settingValueRecordTypeId;
        set034Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set034Setting.SVMXC__Setting_ID__c = set034Process.Id;
        configDataList.add(set034Setting);

        SVMXC__ServiceMax_Config_Data__c set038Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set038Setting.SVMXC__Internal_Value__c = 'Event.SVMXC__SM_Status__c';
        set038Setting.SVMXC__Display_Value__c = 'Event.SVMXC__SM_Status__c';
        set038Setting.recordtypeid = settingValueRecordTypeId;
        set038Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set038Setting.SVMXC__Setting_ID__c = set038Process.Id;
        configDataList.add(set038Setting);

        SVMXC__ServiceMax_Config_Data__c set039Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set039Setting.SVMXC__Internal_Value__c = 'Event.SVMXC__SM_Longitude__c';
        set039Setting.SVMXC__Display_Value__c = 'Event.SVMXC__SM_Longitude__c';
        set039Setting.recordtypeid = settingValueRecordTypeId;
        set039Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set039Setting.SVMXC__Setting_ID__c = set039Process.Id;
        configDataList.add(set039Setting);

        SVMXC__ServiceMax_Config_Data__c set040Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set040Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set040Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set040Setting.recordtypeid = settingValueRecordTypeId;
        set040Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set040Setting.SVMXC__Setting_ID__c = set040Process.Id;
        configDataList.add(set040Setting);

        SVMXC__ServiceMax_Config_Data__c set041Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set041Setting.SVMXC__Internal_Value__c = 'Event.SVMXC__Service_Duration__c';
        set041Setting.SVMXC__Display_Value__c = 'Event.SVMXC__Service_Duration__c';
        set041Setting.recordtypeid = settingValueRecordTypeId;
        set041Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set041Setting.SVMXC__Setting_ID__c = set041Process.Id;
        configDataList.add(set041Setting);

        SVMXC__ServiceMax_Config_Data__c set042Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set042Setting.SVMXC__Internal_Value__c = 'Event.SVMXC__Driving_Time__c';
        set042Setting.SVMXC__Display_Value__c = 'Event.SVMXC__Driving_Time__c';
        set042Setting.recordtypeid = settingValueRecordTypeId;
        set042Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set042Setting.SVMXC__Setting_ID__c = set042Process.Id;
        configDataList.add(set042Setting);

        SVMXC__ServiceMax_Config_Data__c set043Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set043Setting.SVMXC__Internal_Value__c = 'SVMXC__Dispatch_Status__c';
        set043Setting.SVMXC__Display_Value__c = 'SVMXC__Dispatch_Status__c';
        set043Setting.recordtypeid = settingValueRecordTypeId;
        set043Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set043Setting.SVMXC__Setting_ID__c = set043Process.Id;
        configDataList.add(set043Setting);

        SVMXC__ServiceMax_Config_Data__c set044Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set044Setting.SVMXC__Internal_Value__c = 'SVMXC__Longitude__c';
        set044Setting.SVMXC__Display_Value__c = 'SVMXC__Longitude__c';
        set044Setting.recordtypeid = settingValueRecordTypeId;
        set044Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set044Setting.SVMXC__Setting_ID__c = set044Process.Id;
        configDataList.add(set044Setting);

        SVMXC__ServiceMax_Config_Data__c set045Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set045Setting.SVMXC__Internal_Value__c = 'SVMXC__Latitude__c';
        set045Setting.SVMXC__Display_Value__c = 'SVMXC__Latitude__c';
        set045Setting.recordtypeid = settingValueRecordTypeId;
        set045Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set045Setting.SVMXC__Setting_ID__c = set045Process.Id;
        configDataList.add(set045Setting);

        SVMXC__ServiceMax_Config_Data__c set046Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set046Setting.SVMXC__Internal_Value__c = 'SVMXC__Scheduled_Date__c';
        set046Setting.SVMXC__Display_Value__c = 'SVMXC__Scheduled_Date__c';
        set046Setting.recordtypeid = settingValueRecordTypeId;
        set046Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set046Setting.SVMXC__Setting_ID__c = set046Process.Id;
        configDataList.add(set046Setting);

        SVMXC__ServiceMax_Config_Data__c set047Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set047Setting.SVMXC__Internal_Value__c = 'SVMXC__Scheduled_Date_Time__c';
        set047Setting.SVMXC__Display_Value__c = 'SVMXC__Scheduled_Date_Time__c';
        set047Setting.recordtypeid = settingValueRecordTypeId;
        set047Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set047Setting.SVMXC__Setting_ID__c = set047process.Id;
        configDataList.add(set047Setting);

        SVMXC__ServiceMax_Config_Data__c set062Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set062Setting.SVMXC__Internal_Value__c = 'True';
        set062Setting.SVMXC__Display_Value__c = 'True';
        set062Setting.recordtypeid = settingValueRecordTypeId;
        set062Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set062Setting.SVMXC__Setting_ID__c = set062Process.Id;
        configDataList.add(set062Setting);

        SVMXC__ServiceMax_Config_Data__c set070Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set070Setting.SVMXC__Internal_Value__c = '1000';
        set070Setting.SVMXC__Display_Value__c = '1000';
        set070Setting.recordtypeid = settingValueRecordTypeId;
        set070Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set070Setting.SVMXC__Setting_ID__c = set070Process.Id;
        configDataList.add(set070Setting);

        insert configDataList;

        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
                
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        objTerritory.SVMXC__Territory_s_Business_Hours__c  = BHour[0].Id;
        insert objTerritory;
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = UserInfo.getUserId()
                                            );
        insert objTechnician;

        List<String> techs = new List<String>();
        techs.add(objTechnician.Id);
        Account objAccount = new Account(Name ='Account'  ); 
        insert objAccount;
        

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        
        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        Datetime t = system.now();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician.Id,
                                            SVMXC__Preferred_Start_Time__c = t.addHours(4),
                                            SVMXC__Preferred_Business_Hours__c = BHour[0].Id
                                            );
        insert objWorkOrder;

    }

    static testMethod void testFetchEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Date d = system.now().date();
        Datetime t = d;
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e1);
        Event e2 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(24),
                             DurationInMinutes = 1440, Subject = 'test svmx',
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e2);
        Event e3 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             isAlldayEvent = true,
                             DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e3);
        Event e4 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(24),
                             isAlldayEvent = true,
                             DurationInMinutes = 1440, Subject = 'test svmx',
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e4);
        

        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        DCX_Wrapper.SVMX_StringMap stringMapDateValue = 
            new DCX_Wrapper.SVMX_StringMap('SET046','date');
        DCX_Wrapper.SVMX_StringMap stringMapDateTimeValue =
            new DCX_Wrapper.SVMX_StringMap('SET047','datetime');
        DCX_Wrapper.SVMX_StringMap stringMapPickListValue =
            new DCX_Wrapper.SVMX_StringMap('SET040','Open');
        DCX_Wrapper.SVMX_StringMap stringMapEventServiceDurationValue =
            new DCX_Wrapper.SVMX_StringMap('SET041','10');
        DCX_Wrapper.SVMX_StringMap stringMapEventStatusValue =
            new DCX_Wrapper.SVMX_StringMap('SET038','Confirmed');
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        stringMapDateValue.DateValue = Date.Valueof('2019-11-14');
        lstKeyValue.add(stringMapDateValue);
        stringMapDateTimeValue.DateTimeValue = DateTime.Valueof('2019-11-14 00:00:00');
        lstKeyValue.add(stringMapDateTimeValue);
        lstKeyValue.add(stringMapPickListValue);
        lstKeyValue.add(stringMapEventServiceDurationValue);
        lstKeyValue.add(stringMapEventStatusValue);
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
        
        Test.startTest();
            DCX_EventServiceManager.DCEventHover_WP eventWrapperClass = 
                new DCX_EventServiceManager.DCEventHover_WP();
            DCX_EventServiceManager.DCEventHover_Wrapper eventHoverWrapperClass = 
                new DCX_EventServiceManager.DCEventHover_Wrapper();
            DCX_EventServiceManager.getEvtandWofields();
            DCX_CommonServiceManager.DCEvent_WO_WP createdEvents = 
                DCX_EventServiceManager.createEvents(lstObjSFEvents,objUser.TimeZoneSidKey,lstKeyValue,objTechnician.Id,true,false,null,null);
                DCX_EventServiceManager.fetchEventsOnLaunch();
                techIds.add(objTechnician.Id);
                DCX_EventServiceManager.fetchEvents1(userinfo.getUserId(),'2010-02-11','2010-02-14',null,'Asia@pacific',techIds);
                eventWrapperClass.sequence = 10;
                eventWrapperClass.fieldName = 'service_order__c';
                eventWrapperClass.operator = 'add';
                eventWrapperClass.fieldValue = '10';
                eventWrapperClass.displayType = 'Duration';
                eventWrapperClass.expressionRule = '1 OR 2';
                eventWrapperClass.advExpression = '1 OR 2';
                eventWrapperClass.hoverDisplayFields = 'Id,Name';
                eventHoverWrapperClass.lines = evLines;
                eventHoverWrapperClass.advExpression = '1 OR 2';
                eventHoverWrapperClass.advExpression = 'target';
                evLine.fieldName = 'status__c';
                evLine.operator = 'add';
                evLine.fieldValue = '10';

        Test.stopTest();
    }

    static testMethod void testUpsertEvent() {
        list<Event> lstObjSFEvents = new list<Event>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>();
        List<String> sfEventIds = new List<String>();
        List<DateTime> lstDateTime = new List<DateTime>();
        Date d = system.now().date();
        Datetime t = d;
        Schema.Describesobjectresult discResUser = User.sObjectType.getDescribe();
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        lstDateTime.add(t);
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));


        Event e = new Event(ActivityDate = d.addDays(1),
                             StartDateTime = t.addDays(1),
                             ActivityDateTime = t.addDays(1), 
                             EndDateTime = t.addHours(25),
                             isAlldayEvent = true,
                             DurationInMinutes = 1440, Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e);
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = t.addHours(1),
                             DurationInMinutes = 60, Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e1);
        Event e2 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = t.addHours(1),
                             DurationInMinutes = 60, Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e2);
        insert lstObjSFEvents;

        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 00:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 00:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id,
                                                    SVMXC__SM_Latitude__c = 10,
                                                    SVMXC__IsAllDayEvent__c = true
                                                    );
        lstSVMXEvent.add(SMAX_Event1);
        SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 00:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 00:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstSVMXEvent.add(SMAX_Event2);
        SVMXC__SVMX_Event__c SMAX_Event3 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 00:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 00:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstSVMXEvent.add(SMAX_Event3);
        insert lstSVMXEvent;

        sfEventIds.add(e1.Id);
        sfEventIds.add(SMAX_Event1.Id);
        lstObjSFEvents.clear();
        lstObjSFEvents.add(e);
        DCX_EventServiceManager.upsertEventOnTechChange(lstObjSFEvents,objWorkOrder.Id,
                                                        objUser.TimeZoneSidKey,lstKeyValue,
                                                        objTechnician.Id,true,false,null,false,null);
        DCX_EventServiceManager.GetExistingSFSVMXEvents(lstObjSFEvents,objUser.TimeZoneSidKey,
                                                        discResUser.getKeyPrefix());
        
        map<String ,DCX_EventServiceManager.TechEvent_WP> techMapEvent = 
            DCX_EventServiceManager.getmapTechEvent(lstObjSFEvents,lstSVMXEvent);
        DCX_EventServiceManager.getOverlappingEventDetails(e,techMapEvent.get(DCX_EventServiceManager.getTechId(e.OwnerId)),
                                                           objUser.TimeZoneSidKey);
        DCX_EventServiceManager.findOverlappingEvents(techMapEvent,lstObjSFEvents,discResUser.getKeyPrefix(),objUser.TimeZoneSidKey);
        DCX_EventServiceManager.getLeastDateTime(lstDateTime);
        DCX_EventServiceManager.getEventHoverRules();
        DCX_EventServiceManager.getWOEvents(lstObjSFEvents);
        DCX_EventServiceManager.getWOEvents(lstSVMXEvent);
        DCX_EventServiceManager.getTechName(objTechnician.Id);
        DCX_EventServiceManager.eventSubject(objWorkOrder.Id+','+objTechnician.SVMXC__Salesforce_User__c);
        DCX_EventServiceManager.DCX_Delete_Events_WS(UserInfo.getUserId(),sfEventIds);
        sfEventIds.clear();
        sfEventIds.add(e2.Id);
        sfEventIds.add(SMAX_Event3.Id);
        DCX_EventServiceManager.deleteEvents(sfEventIds);
        //DCX_EventServiceManager.deleteEventForWO(objWorkOrder.Id);
    }

    static testMethod void testUpdateEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Date d = system.now().date();
        Map<String,String> settingVals = new Map<String,String>();
        Datetime t = d;
        List<String> woIds = new List<String>();
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e1);
        Event e2 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(24),
                             DurationInMinutes = 1440, Subject = 'test svmx',
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e2);

        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        DCX_Wrapper.SVMX_StringMap stringMapDateValue = 
            new DCX_Wrapper.SVMX_StringMap('SET046','date');
        DCX_Wrapper.SVMX_StringMap stringMapDateTimeValue =
            new DCX_Wrapper.SVMX_StringMap('SET047','datetime');
        DCX_Wrapper.SVMX_StringMap stringMapPickListValue =
            new DCX_Wrapper.SVMX_StringMap('SET040','Open');
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        stringMapDateValue.DateValue = Date.Valueof('2019-11-14');
        lstKeyValue.add(stringMapDateValue);
        stringMapDateTimeValue.DateTimeValue = DateTime.Valueof('2019-11-14 00:00:00');
        lstKeyValue.add(stringMapDateTimeValue);
        lstKeyValue.add(stringMapPickListValue);
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));

        Test.startTest();
            woIds.add(objWorkOrder.Id);
            DCX_EventServiceManager.retrieveWorkOrdersForIds(woIds,settingVals,null);
            DCX_EventServiceManager.DCX_Upsert_Events_WS4(userinfo.getUserId(),lstObjSFEvents,objUser.TimeZoneSidKey,lstKeyValue,objTechnician.Id,null,null);
        Test.stopTest();
        
    }

    static testMethod void testUpdateOnExistingEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Date d = system.now().date();
        Datetime t = d;
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             //EndDateTime = system.now().addHours(1),
                             isAlldayEvent = true,
                             //DurationInMinutes = 60, 
                             Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e1;
        e1.OwnerId = objTechnician.Id;
        e1.DurationInMinutes = 1440;
        e1.EndDateTime = system.now().addHours(24);
        lstObjSFEvents.add(e1);
        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        DCX_Wrapper.SVMX_StringMap stringMapDateValue = 
            new DCX_Wrapper.SVMX_StringMap('SET046','date');
        DCX_Wrapper.SVMX_StringMap stringMapDateTimeValue =
            new DCX_Wrapper.SVMX_StringMap('SET047','datetime');
        DCX_Wrapper.SVMX_StringMap stringMapPickListValue =
            new DCX_Wrapper.SVMX_StringMap('SET040','Open');
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        stringMapDateValue.DateValue = Date.Valueof('2019-11-14');
        lstKeyValue.add(stringMapDateValue);
        stringMapDateTimeValue.DateTimeValue = DateTime.Valueof('2019-11-14 00:00:00');
        lstKeyValue.add(stringMapDateTimeValue);
        lstKeyValue.add(stringMapPickListValue);
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));

        Test.startTest();
           DCX_EventServiceManager.DCX_Upsert_Events_WS4(userinfo.getUserId(),lstObjSFEvents,objUser.TimeZoneSidKey,lstKeyValue,objTechnician.Id,null,null);
        Test.stopTest();
        
    }

    static testMethod void testUpdateTechChangeSVMXEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Date d = system.now().date();
        Datetime t = d;
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             //EndDateTime = system.now().addHours(1),
                             isAlldayEvent = true,
                             //DurationInMinutes = 60, 
                             Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e1;
        e1.OwnerId = objTechnician.Id;
        e1.DurationInMinutes = 1440;
        e1.EndDateTime = system.now().addHours(24);
        lstObjSFEvents.add(e1);
        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        DCX_Wrapper.SVMX_StringMap stringMapDateValue = 
            new DCX_Wrapper.SVMX_StringMap('SET046','date');
        DCX_Wrapper.SVMX_StringMap stringMapDateTimeValue =
            new DCX_Wrapper.SVMX_StringMap('SET047','datetime');
        DCX_Wrapper.SVMX_StringMap stringMapPickListValue =
            new DCX_Wrapper.SVMX_StringMap('SET040','Open');
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        stringMapDateValue.DateValue = Date.Valueof('2019-11-14');
        lstKeyValue.add(stringMapDateValue);
        stringMapDateTimeValue.DateTimeValue = DateTime.Valueof('2019-11-14 00:00:00');
        lstKeyValue.add(stringMapDateTimeValue);
        lstKeyValue.add(stringMapPickListValue);
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));

        Test.startTest();
           DCX_EventServiceManager.upsertEventOnTechChange(lstObjSFEvents,objWorkOrder.Id,
                                                        objUser.TimeZoneSidKey,lstKeyValue,
                                                        objTechnician.Id,true,false,null,false,null);
        Test.stopTest();
        
    }

    static testMethod void testDeleteEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Date d = system.now().date();
        Datetime t = d;
        List<String> eventIds = new List<String>();
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             //EndDateTime = t.addHours(24),
                             isAlldayEvent = true,
                             //DurationInMinutes = 1440, 
                             Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e1;
        Event e2 = new Event(ActivityDate = Date.Valueof('2010-02-11 00:00:00'),
                             StartDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                             ActivityDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                             EndDateTime = Datetime.valueOf('2010-02-11 01:00:00'),
                             DurationInMinutes = 60, Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e2;
        eventIds.add(e2.Id);
        SVMXC__SVMX_Event__c SMAX_Event = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 1440,
                                                    SVMXC__IsAllDayEvent__c = true,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        insert SMAX_Event;
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        insert SMAX_Event1;
        eventIds.add(SMAX_Event1.Id);

        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        DCX_Wrapper.SVMX_StringMap stringMapDateValue = 
            new DCX_Wrapper.SVMX_StringMap('SET046','date');
        DCX_Wrapper.SVMX_StringMap stringMapDateTimeValue =
            new DCX_Wrapper.SVMX_StringMap('SET047','datetime');
        DCX_Wrapper.SVMX_StringMap stringMapPickListValue =
            new DCX_Wrapper.SVMX_StringMap('SET040','Open');
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        stringMapDateValue.DateValue = Date.Valueof('2019-11-14');
        lstKeyValue.add(stringMapDateValue);
        stringMapDateTimeValue.DateTimeValue = DateTime.Valueof('2019-11-14 00:00:00');
        lstKeyValue.add(stringMapDateTimeValue);
        lstKeyValue.add(stringMapPickListValue);
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));

        Test.startTest();
             DCX_EventServiceManager.fetchEventsOnLaunch();
             techIds.add(objTechnician.Id);
             DCX_EventServiceManager.fetchEvents1(userinfo.getUserId(),'2010-02-11','2010-02-14',null,'Asia@pacific',techIds);
             DCX_EventServiceManager.fetchEventsAndWOInfo(userinfo.getUserId(),'2010-02-11','2010-02-14',null,'Asia@pacific',techIds);
             DCX_EventServiceManager.deleteEventsAndUpdateWO(eventIds);
            //DCX_EventServiceManager.deleteEventForWO(objWorkOrder.Id,null);
            
        Test.stopTest();
        
    }
static testMethod void testFetchEventWarning() {
   SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];

    DCX_EventServiceManager.DCEventWarningReq_WP req =  new DCX_EventServiceManager.DCEventWarningReq_WP();
    req.EventEndDateTime = Datetime.valueOf('2010-02-11 01:00:00');
    req.EventStartDateTime =Datetime.valueOf('2010-02-11 01:00:00');
    req.WorkOrderId =objWorkOrder.Id;
    req.TechId = objTechnician.Id;
    req.timeZone='Asia@pacific';
    req.isMachineAccessHrsEnabled=false;
    req.isBusinessHrsEnabled=false;
    req.isBasicWH=true;

    DCX_EventServiceManager.DCEventWarningReq_WP req23=  new DCX_EventServiceManager.DCEventWarningReq_WP(objWorkOrder.Id,objTechnician.Id,Datetime.valueOf('2010-02-11 01:00:00'),Datetime.valueOf('2010-02-11 01:00:00'),'Asia@pacific',false,false,false);

    DCX_EventServiceManager.DCEventWarningReq_WP req2 =  new DCX_EventServiceManager.DCEventWarningReq_WP();
    req2.EventEndDateTime = Datetime.valueOf('2010-02-11 01:00:00');
    req2.EventStartDateTime = Datetime.valueOf('2010-02-11 01:00:00');
    req2.WorkOrderId =objWorkOrder.Id;
    req2.TechId = objTechnician.Id;
    req2.timeZone='Asia@pacific';
    req2.isMachineAccessHrsEnabled=false;
    req2.isBusinessHrsEnabled=false;
    req2.isBasicWH=false;

    DCX_EventServiceManager.DCX_EventWarnings_WS (req);
     DCX_EventServiceManager.DCX_EventWarnings_WS (req2);                                                                                                                                                                                          

}

static testMethod void retrieveWorkOrdersForIds() {

    SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        DCX_EventServiceManager.retrieveWorkOrdersForIds(woids);

}


static testMethod void callWrapper() {
    DCX_EventServiceManager.DCEventWarningResp_WP DCEventWarningResp = new DCX_EventServiceManager.DCEventWarningResp_WP();
    Date dt = system.now().date();
    DCEventWarningResp.STOutsideBusinessHrs = dt;
    DCEventWarningResp.ETOutsideBusinessHrs = dt;
    DCEventWarningResp.STOutsideMachineAccesshrs = dt;
    DCEventWarningResp.ETOutsideMachineAccesshrs = dt;
    DCX_EventServiceManager.DCEventWarningResp_WP DCEventWarningResp1 = new DCX_EventServiceManager.DCEventWarningResp_WP(
        dt,dt,dt,dt );

    DCX_EventServiceManager.SVMX_BuisnessHourAttribute BhAttribute1 = new DCX_EventServiceManager.SVMX_BuisnessHourAttribute('','','');

}

static testMethod void DCON_EventWarnings_WS() {

    SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);

        DCX_EventServiceManager.DCEventWarningReq_WP request = new DCX_EventServiceManager.DCEventWarningReq_WP();
        DCX_EventServiceManager.DCEventWarningResp_WP response = new DCX_EventServiceManager.DCEventWarningResp_WP();
        request.TechId = objTechnician.Id;
        request.WorkOrderId = objWorkOrder.Id;
        request.timeZone = 'Asia/Calcutta';
        request.EventStartDateTime =Datetime.valueOf('2010-02-11 01:00:00');
        request.EventEndDateTime = Datetime.valueOf('2010-02-11 02:00:00');
        request.isMachineAccessHrsEnabled = true;
        request.isBusinessHrsEnabled = true;
        request.isBasicWH = false;

        DCX_EventServiceManager.DCON_EventWarnings_WS(request);

        request.isBasicWH = true;

        DCX_EventServiceManager.DCON_EventWarnings_WS(request);

}

static testMethod void delteeventutil(){
    Date d = system.now().date();
        Datetime t = d;

    SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];

    Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             //EndDateTime = t.addHours(24),
                             isAlldayEvent = true,
                             //DurationInMinutes = 1440, 
                             Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e1;
        Event e2 = new Event(ActivityDate = Date.Valueof('2010-02-11 00:00:00'),
                             StartDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                             ActivityDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                             EndDateTime = Datetime.valueOf('2010-02-11 01:00:00'),
                             DurationInMinutes = 60, Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e2;
        SVMXC__SVMX_Event__c SMAX_Event = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 1440,
                                                    SVMXC__IsAllDayEvent__c = true,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        insert SMAX_Event;
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        insert SMAX_Event1;
        Map<String,String> setting = new Map<String,String>();
       //SVMXC.DCX_EventServiceManager.deleteEventForWOUtil(String.valueof(objWorkOrder.Id) ,String.valueof(e1.Id),String.valueof(objTechnician.Id),String.valueof(objTechnician.Id),setting);
      // SVMXC.DCX_EventServiceManager.deleteEventForWOUtil(String.valueof(objWorkOrder.Id) ,String.valueof(SMAX_Event1.Id),String.valueof(objTechnician.Id),String.valueof(objTechnician.Id),setting);
        List<String> eventsiId = new List<String>();
        eventsiId.add(SMAX_Event1.Id);
        List<String> status = new List<String>();
        status.add('New');
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);

        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        DCX_EventServiceManager.GetEventWOInfo_WS(eventsiId,objUser.Id,null,objUser.Id,status,'Asia/Kolkata@MM/DD/YYYY hh:mm a',woids);
}
static testMethod void getScheduledTech1() {
    SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
    SVMXC__Service_Group_Members__c
    where Name = 'TECH 1'];
    SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
    SVMXC__Group_Member__c = :objTechnician.Id];

    List<String> woids = new List<String>();
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);
    woids.add(objWorkOrder.Id);





    List<String> tech = new List<String>();
    tech.add(objTechnician.Id);
    DCX_EventServiceManager.getListOfTechScheduled(woids);

    User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        DCX_EventServiceManager.DCON_Fetch_All_Events_WS(woids,objUser.Id,tech,'Asia/Kolkata@MM/DD/YYYY hh:mm a');
        DCX_EventServiceManager.DCON_Retrieve_WO_Events_WS(objUser.Id,'2010-02-11 01:00:00','2010-02-11 02:00:00','Asia/Kolkata@MM/DD/YYYY hh:mm a',objWorkOrder.Id);

}
static testMethod void getScheduledTech() {

    SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];

        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        
        



        List<String> tech = new List<String>();
        tech.add(objTechnician.Id);
       // DCX_EventServiceManager.getListOfTechScheduled(woids);

        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
       // DCX_EventServiceManager.DCON_Fetch_All_Events_WS(woids,objUser.Id,tech,'Asia/Kolkata@MM/DD/YYYY hh:mm a');
       // DCX_EventServiceManager.DCON_Retrieve_WO_Events_WS(objUser.Id,'2010-02-11 01:00:00','2010-02-11 02:00:00','Asia/Kolkata@MM/DD/YYYY hh:mm a',objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        woids.add(objWorkOrder.Id);
        DCX_EventServiceManager.DCON_Fetch_All_Events_WS(woids,objUser.Id,tech,'Asia/Kolkata@MM/DD/YYYY hh:mm a');


}
    static testMethod void testFetchEventIds() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Date d = system.now().date();
        Datetime t = d;
        List<String> eventIds = new List<String>();
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM 1'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = d,
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             //EndDateTime = t.addHours(24),
                             isAlldayEvent = true,
                             //DurationInMinutes = 1440, 
                             Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e1;
        Event e2 = new Event(ActivityDate = Date.Valueof('2010-02-11 00:00:00'),
                             StartDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                             ActivityDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                             EndDateTime = Datetime.valueOf('2010-02-11 01:00:00'),
                             DurationInMinutes = 60, Subject = 'test', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        insert e2;
        eventIds.add(e2.Id);
        SVMXC__SVMX_Event__c SMAX_Event = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 1440,
                                                    SVMXC__IsAllDayEvent__c = true,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        insert SMAX_Event;
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        insert SMAX_Event1;
        eventIds.add(SMAX_Event1.Id);

        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        DCX_Wrapper.SVMX_StringMap stringMapDateValue = 
            new DCX_Wrapper.SVMX_StringMap('SET046','date');
        DCX_Wrapper.SVMX_StringMap stringMapDateTimeValue =
            new DCX_Wrapper.SVMX_StringMap('SET047','datetime');
        DCX_Wrapper.SVMX_StringMap stringMapPickListValue =
            new DCX_Wrapper.SVMX_StringMap('SET040','Open');
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        stringMapDateValue.DateValue = Date.Valueof('2019-11-14');
        lstKeyValue.add(stringMapDateValue);
        stringMapDateTimeValue.DateTimeValue = DateTime.Valueof('2019-11-14 00:00:00');
        lstKeyValue.add(stringMapDateTimeValue);
        lstKeyValue.add(stringMapPickListValue);
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
        Map<String,String> fieldMap = new Map<String,String>();
        fieldMap.put('SET038','SET038');
        fieldMap.put('SET039','SET039');
        fieldMap.put('SET040','SET040');
        fieldMap.put('SET041','SET041');
        fieldMap.put('SET042','SET042');
        fieldMap.put('SET043','SET043');
        fieldMap.put('SET044','SET044');
        fieldMap.put('SET045','SET045');
        fieldMap.put('SET046','SET046');
        fieldMap.put('SET047','SET047');
        
        Test.startTest();
             DCX_EventServiceManager.fetchEventsOnLaunch();
             techIds.add(objTechnician.Id);
             DCX_EventServiceManager.DCX_EventServiceManager_Util eventServUtil = new DCX_EventServicemanager.DCX_EventServiceManager_Util();
             DCX_EventServiceManager.getConfiguredEventWOFieldsSET38To47(fieldMap);
             Set<Id> evtIds = DCX_EventServiceManager.fetchEventIds(userinfo.getUserId(),'2010-02-11','2010-02-14',null,'Asia@pacific',techIds);
             DCX_EventServiceManager.fetchEventsAndWOInfoForIds(userinfo.getUserId(),'Asia@pacific',eventIds);
             DCX_EventServiceManager.fetchEventsForIds(userinfo.getUserId(),'Asia@pacific',eventIds);
             eventServUtil.deleteEventForWOUtil(String.ValueOf(objWorkOrder.Id),String.ValueOf(e2.Id),String.ValueOf(objTechnician.Id),String.ValueOf(objTechnician.SVMXC__Salesforce_User__c),fieldMap);
             //DCX_EventServiceManager.fetchEventsAndWOInfo(userinfo.getUserId(),'2010-02-11','2010-02-14',null,'Asia@pacific',techIds);
             
        Test.stopTest();
        
    }

static testMethod void fetchDeltaEventsAndWOInfo() {
        
    list<Event> lstObjSFEvents = new list<Event>();
    Date d = system.now().date();
    Datetime t = d;
    List<String> eventIds = new List<String>();
    List<String> techIds = new List<String>();
    User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
    SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                       Name = 'TEAM 1'];
    SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                     SVMXC__Service_Group_Members__c
                                                     where Name = 'TECH 1'];
                                                     techIds.add(objTechnician.Id);
    SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                            SVMXC__Group_Member__c = :objTechnician.Id];
    Event e1 = new Event(ActivityDate = d,
                         StartDateTime = t,
                         ActivityDateTime = t, 
                         //EndDateTime = t.addHours(24),
                         isAlldayEvent = true,
                         //DurationInMinutes = 1440, 
                         Subject = 'test', 
                         OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                         WhatId=objWorkOrder.Id, Description='Test Desc',
                         SVMXC__Service_Duration__c = 60);
    insert e1;
    Event e2 = new Event(ActivityDate = Date.Valueof('2010-02-11 00:00:00'),
                         StartDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                         ActivityDateTime = Datetime.valueOf('2010-02-11 00:00:00'),
                         EndDateTime = Datetime.valueOf('2010-02-11 01:00:00'),
                         DurationInMinutes = 60, Subject = 'test', 
                         OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                         WhatId=objWorkOrder.Id, Description='Test Desc',
                         SVMXC__Service_Duration__c = 60);
    insert e2;
    eventIds.add(e2.Id);
    SVMXC__SVMX_Event__c SMAX_Event = new SVMXC__SVMX_Event__c(
                                                SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                SVMXC__DurationInMinutes__c = 1440,
                                                SVMXC__IsAllDayEvent__c = true,
                                                SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                SVMXC__Technician__c = objTechnician.Id,
                                                SVMXC__WhatId__c = objWorkOrder.Id
                                                );
    insert SMAX_Event;
    SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                SVMXC__ActivityDate__c = Date.valueOf('2010-02-11 01:00:00'), 
                                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                SVMXC__DurationInMinutes__c = 60,
                                                SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                SVMXC__Technician__c = objTechnician.Id,
                                                SVMXC__WhatId__c = objWorkOrder.Id
                                                );
    insert SMAX_Event1;
    eventIds.add(SMAX_Event1.Id);

    

   
    DCX_EventServiceManager.fetchDeltaEventsAndWOInfo('2020-03-27T00:00:00+05:30','2020-04-03T23:59:59+05:30','2020-03-27T09:00:00+05:30','Asia/Kolkata@MM/DD/YYYY hh:mm a',techIds);
        //DCX_EventServiceManager.deleteEventForWO(objWorkOrder.Id,null);
        
   
    
}
    



}