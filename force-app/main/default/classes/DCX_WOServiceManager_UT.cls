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
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (SeeAllData=false)

private class DCX_WOServiceManager_UT {
@testSetup static void setup() {
        SVMXC__ServiceMax_Config_Data__c globalProfile = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = 
            new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> settingValues = new List<SVMXC__ServiceMax_Processes__c>();

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
        set001Process.SVMXC__MapID__c = 'set001Process';
        set001Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set001Process);

        SVMXC__ServiceMax_Processes__c set004Process = new SVMXC__ServiceMax_Processes__c();
        set004Process.SVMXC__SettingID__c = 'SET004';
        set004Process.SVMXC__MapID__c = 'set004Process';
        set004Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set004Process);

        SVMXC__ServiceMax_Processes__c set024Process = new SVMXC__ServiceMax_Processes__c();
        set024Process.SVMXC__SettingID__c = 'SET024';
        set024Process.SVMXC__MapID__c = 'set024Process';
        set024Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set024Process);

        SVMXC__ServiceMax_Processes__c set025Process = new SVMXC__ServiceMax_Processes__c();
        set025Process.SVMXC__SettingID__c = 'SET025';
        set025Process.SVMXC__MapID__c = 'set025Process';
        set025Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set025Process);

        SVMXC__ServiceMax_Processes__c set026Process = new SVMXC__ServiceMax_Processes__c();
        set026Process.SVMXC__SettingID__c = 'SET026';
        set026Process.SVMXC__MapID__c = 'set026Process';
        set026Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set026Process);

        SVMXC__ServiceMax_Processes__c set028Process = new SVMXC__ServiceMax_Processes__c();
        set028Process.SVMXC__SettingID__c = 'SET028';
        set028Process.SVMXC__MapID__c = 'set028Process';
        set028Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set028Process);

        SVMXC__ServiceMax_Processes__c set033Process = new SVMXC__ServiceMax_Processes__c();
        set033Process.SVMXC__SettingID__c = 'SET033';
        set033Process.SVMXC__MapID__c = 'set033Process';
        set033Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set033Process);

        SVMXC__ServiceMax_Processes__c set034Process = new SVMXC__ServiceMax_Processes__c();
        set034Process.SVMXC__SettingID__c = 'SET034';
        set034Process.SVMXC__MapID__c = 'set034Process';
        set034Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set034Process);

        SVMXC__ServiceMax_Processes__c set038Process = new SVMXC__ServiceMax_Processes__c();
        set038Process.SVMXC__SettingID__c = 'SET038';
        set038Process.SVMXC__MapID__c = 'set038Process';
        set038Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set038Process);

        SVMXC__ServiceMax_Processes__c set039Process = new SVMXC__ServiceMax_Processes__c();
        set039Process.SVMXC__SettingID__c = 'SET039';
        set039Process.SVMXC__MapID__c = 'set039Process';
        set039Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set039Process);

        SVMXC__ServiceMax_Processes__c set040Process = new SVMXC__ServiceMax_Processes__c();
        set040Process.SVMXC__SettingID__c = 'SET040';
        set040Process.SVMXC__MapID__c = 'set040Process';
        set040Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set040Process);

        SVMXC__ServiceMax_Processes__c set041Process = new SVMXC__ServiceMax_Processes__c();
        set041Process.SVMXC__SettingID__c = 'SET041';
        set041Process.SVMXC__MapID__c = 'set041Process';
        set041Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set041Process);

        SVMXC__ServiceMax_Processes__c set042Process = new SVMXC__ServiceMax_Processes__c();
        set042Process.SVMXC__SettingID__c = 'SET042';
        set042Process.SVMXC__MapID__c = 'set042Process';
        set042Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set042Process);

        SVMXC__ServiceMax_Processes__c set043Process = new SVMXC__ServiceMax_Processes__c();
        set043Process.SVMXC__SettingID__c = 'SET043';
        set043Process.SVMXC__MapID__c = 'set043Process';
        set043Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set043Process);

        SVMXC__ServiceMax_Processes__c set044Process = new SVMXC__ServiceMax_Processes__c();
        set044Process.SVMXC__SettingID__c = 'SET044';
        set044Process.SVMXC__MapID__c = 'set044Process';
        set044Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set044Process);

        SVMXC__ServiceMax_Processes__c set045Process = new SVMXC__ServiceMax_Processes__c();
        set045Process.SVMXC__SettingID__c = 'SET045';
        set045Process.SVMXC__MapID__c = 'set045Process';
        set045Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set045Process);

        SVMXC__ServiceMax_Processes__c set046Process = new SVMXC__ServiceMax_Processes__c();
        set046Process.SVMXC__SettingID__c = 'SET046';
        set046Process.SVMXC__MapID__c = 'set046Process';
        set046Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set046Process);

        SVMXC__ServiceMax_Processes__c set047Process = new SVMXC__ServiceMax_Processes__c();
        set047Process.SVMXC__SettingID__c = 'SET047';
        set047Process.SVMXC__MapID__c = 'set047Process';
        set047Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set047Process);

        SVMXC__ServiceMax_Processes__c set062Process = new SVMXC__ServiceMax_Processes__c();
        set062Process.SVMXC__SettingID__c = 'SET062';
        set062Process.SVMXC__MapID__c = 'set062Process';
        set062Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set062Process);

        SVMXC__ServiceMax_Processes__c set073Process = new SVMXC__ServiceMax_Processes__c();
        set073Process.SVMXC__SettingID__c = 'SET073';
        set073Process.SVMXC__MapID__c = 'set073Process';
        set073Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set073Process);

        SVMXC__ServiceMax_Processes__c set007Process = new SVMXC__ServiceMax_Processes__c();
        set007Process.SVMXC__SettingID__c = 'SET007';
        set007Process.SVMXC__MapID__c = 'set007Process';
        set007Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set007Process);

        SVMXC__ServiceMax_Processes__c set022Process = new SVMXC__ServiceMax_Processes__c();
        set022Process.SVMXC__SettingID__c = 'SET022';
        set022Process.SVMXC__MapID__c = 'set007Process';
        set022Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set022Process);
        
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
        set025Setting.SVMXC__Internal_Value__c = 'ALLOW';
        set025Setting.SVMXC__Display_Value__c = 'ALLOW';
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
        set038Setting.SVMXC__Internal_Value__c = 'Event.SVMXC__SM_Latitude__c';
        set038Setting.SVMXC__Display_Value__c = 'Event.SVMXC__SM_Latitude__c';
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
        set041Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set041Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set041Setting.recordtypeid = settingValueRecordTypeId;
        set041Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set041Setting.SVMXC__Setting_ID__c = set041Process.Id;
        configDataList.add(set041Setting);

        SVMXC__ServiceMax_Config_Data__c set042Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set042Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set042Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set042Setting.recordtypeid = settingValueRecordTypeId;
        set042Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set042Setting.SVMXC__Setting_ID__c = set042Process.Id;
        configDataList.add(set042Setting);

        SVMXC__ServiceMax_Config_Data__c set043Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set043Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set043Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set043Setting.recordtypeid = settingValueRecordTypeId;
        set043Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set043Setting.SVMXC__Setting_ID__c = set043Process.Id;
        configDataList.add(set043Setting);

        SVMXC__ServiceMax_Config_Data__c set044Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set044Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set044Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set044Setting.recordtypeid = settingValueRecordTypeId;
        set044Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set044Setting.SVMXC__Setting_ID__c = set044Process.Id;
        configDataList.add(set044Setting);

        SVMXC__ServiceMax_Config_Data__c set045Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set045Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set045Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set045Setting.recordtypeid = settingValueRecordTypeId;
        set045Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set045Setting.SVMXC__Setting_ID__c = set045Process.Id;
        configDataList.add(set045Setting);

        SVMXC__ServiceMax_Config_Data__c set046Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set046Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set046Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set046Setting.recordtypeid = settingValueRecordTypeId;
        set046Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set046Setting.SVMXC__Setting_ID__c = set046Process.Id;
        configDataList.add(set046Setting);

         SVMXC__ServiceMax_Config_Data__c set047Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set047Setting.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
        set047Setting.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
        set047Setting.recordtypeid = settingValueRecordTypeId;
        set047Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set047Setting.SVMXC__Setting_ID__c = set047Process.Id;
        configDataList.add(set047Setting);

        SVMXC__ServiceMax_Config_Data__c set062Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set062Setting.SVMXC__Internal_Value__c = 'True';
        set062Setting.SVMXC__Display_Value__c = 'True';
        set062Setting.recordtypeid = settingValueRecordTypeId;
        set062Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set062Setting.SVMXC__Setting_ID__c = set062Process.Id;
        configDataList.add(set062Setting);

        SVMXC__ServiceMax_Config_Data__c set073Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set073Setting.SVMXC__Internal_Value__c = '100';
        set073Setting.SVMXC__Display_Value__c = '100';
        set073Setting.recordtypeid = settingValueRecordTypeId;
        set073Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set073Setting.SVMXC__Setting_ID__c = set073Process.Id;
        configDataList.add(set073Setting);

        SVMXC__ServiceMax_Config_Data__c set007Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set007Setting.SVMXC__Internal_Value__c = 'Assigned,Queued';
        set007Setting.SVMXC__Display_Value__c = 'Assigned,Queued';
        set007Setting.recordtypeid = settingValueRecordTypeId;
        set007Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set007Setting.SVMXC__Setting_ID__c = set007Process.Id;
        configDataList.add(set007Setting);

        SVMXC__ServiceMax_Config_Data__c set022Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set022Setting.SVMXC__Internal_Value__c = 'True';
        set022Setting.SVMXC__Display_Value__c = 'True';
        set022Setting.recordtypeid = settingValueRecordTypeId;
        set022Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set022Setting.SVMXC__Setting_ID__c = set022Process.Id;
        configDataList.add(set022Setting);

        insert configDataList;

        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (Name = 'TEAM1A');
        insert objTeam;
                
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY1B');
        insert objTerritory;
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH1A' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = UserInfo.getUserId(),
                                            SVMXC__City__c ='Bangalore'
                                            );
        insert objTechnician;

        List<String> techs = new List<String>();
        techs.add(objTechnician.Id);
        Account objAccount = new Account(Name ='AccountAA'  ); 
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
                                            SVMXC__Preferred_Start_Time__c = t.addHours(4)
                                            );
        insert objWorkOrder;

        User u = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<SVMXC__Dispatcher_Access__c> listDisp = new List<SVMXC__Dispatcher_Access__c> ();
        SVMXC__Dispatcher_Access__c dispatcherAccess = new SVMXC__Dispatcher_Access__c();
        dispatcherAccess.SVMXC__Territory__c = objTerritory.Id;
        dispatcherAccess.SVMXC__Dispatcher__c = u.Id;
        listDisp.add(dispatcherAccess);
        //insert dispatcherAccess;

        User u2 = [SELECT id,LocaleSidKey from User where id != :UserInfo.getUserId() limit 1];
        SVMXC__Dispatcher_Access__c dispatcherAccess2 = new SVMXC__Dispatcher_Access__c();
        dispatcherAccess2.SVMXC__Territory__c = objTerritory.Id;
        dispatcherAccess2.SVMXC__Service_Team__c = objTeam.Id;
        dispatcherAccess2.SVMXC__Dispatcher__c = u2.Id;
        listDisp.add(dispatcherAccess2);


        insert listDisp;

        

    }
    static testMethod void testFetchEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<String> techIds = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];
        SVMXC__Service_Group_Members__c objTechnician = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :objTechnician.Id];
        Event e1 = new Event(ActivityDate = Date.Today(),
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e1);
        Event e2 = new Event(ActivityDate = Date.Today(),
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             DurationInMinutes = 60, Subject = 'test svmx', 
                             OwnerId = objTechnician.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        lstObjSFEvents.add(e2);

        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
            
                RecordType RTNameSearch = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'View Definition' Limit 1];
        
         SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.RecordTypeId = RTNameSearch.id;
        objSVMXPrcss.SVMXC__Select__c = true;
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__View_For__c = 'Grid';
        objSVMXPrcss.SVMXC__Values__c = 'Id,Name,SVMXC__Company__r.Name,SVMXC__Contact__r.Name';
        objSVMXPrcss.SVMXC__Parent_Object_Criteria__c = 'Name != \'ABC\'';
       objSVMXPrcss.SVMXC__Ownership_Type__c ='User\'s Records';
        insert objSVMXPrcss;


        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
        List<String> dispStatus = new List<String>();
        List<String> Woids = new List<String>();
        List<Event> SFEvent = new List<Event>();
        List<String> EventIds = new List<String>();
         List<DCX_Wrapper.SVMX_StringMap> lstKeyValue1 = new List<DCX_Wrapper.SVMX_StringMap>();


        Woids.add(objWorkOrder.Id);
        dispStatus.add('NEW');
        dispStatus.add('ASSIGNED');
        SFEvent.add(e1);
        String str = e1.Id;
        EventIds.add(str);
        lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '60'));

        DCX_WOServiceManager.DCON_WO_MultiAssign_Request req = new DCX_WOServiceManager.DCON_WO_MultiAssign_Request();
        req.workOrderIds = Woids;
        req.technicianIds = TechIds;
        req.operationType = 'WO_UNASSIGN_12';
        req.timezone = 'America/Indiana/Indianapolis';
        req.Eventlist = SFEvent;
        req.EventIds = EventIds;
        req.lstKeyValue = lstKeyValue1;
        req.getworkOrderIds();
        req.setworkOrderIds(Woids);
        req.getEventlist();
        req.setEventlist(SFEvent);


        Test.startTest();
        DCX_WOServiceManager.retrieveWorkOrders( objSVMXPrcss.id,true,false , dispStatus, NULL,NULL,'Name',true,'Name','0');
        DCX_WOServiceManager.retrieveWorkOrders ('', true,false, dispStatus, Woids, '100', 'Name', true, 'Name', '0');

        DCX_WOServiceManager.singleWO(objWorkOrder.Id,true);
         //DCX_WOServiceManager.retrieveWorkOrdersForIds(Woids);

DCX_WOServiceManager.DCX_Manage_Work_Order_MultiAssign_WS(req);
        Test.stopTest();
    }

    
     @isTest 
   public static void testUT()
    {
        SVMXC__Service_Order__c obj = new SVMXC__Service_Order__c();
        obj.SVMXC__Order_Type__c='Field Service';
        List<SVMXC__Service_Order__c> objLst =new List<SVMXC__Service_Order__c>();
        objLst.add(obj);
        Integer i =10;
        Long l =1005555555;
        List<String> str = new List<String>();
        List<DCX_WOServiceManager.DC_StringListMap> objMap = new List<DCX_WOServiceManager.DC_StringListMap>();
        DCX_WOServiceManager.workorderDCx objworkorderDCx= new DCX_WOServiceManager.workorderDCx(i,true,'/apex/conf_setupHome',l,objLst,null,'ServiceMAX',null,null);
        DCX_WOServiceManager.workorderDCx_INT objworkorderDCx1= new DCX_WOServiceManager.workorderDCx_INT(i,true,'/apex/conf_setupHome',objLst);
        DCX_WOServiceManager.LocalTimeZone objworkorderDCx2= new DCX_WOServiceManager.LocalTimeZone('','','','');

        DCX_WOServiceManager.DC_StringListMap StringListMap= new DCX_WOServiceManager.DC_StringListMap();
        StringListMap.key = '';
        StringListMap.valueList = null;
        StringListMap.fieldsToNull=null;
        StringListMap.getvalueList();
        StringListMap.setvalueList(str);
         DCX_WOServiceManager.DC_StringListMap StringListMap1= new DCX_WOServiceManager.DC_StringListMap('',str);
        //DCxWOServiceManager.retrieveWorkOrdersJsr('');


        DCX_WOServiceManager.DCON_WO_MultiAssign_Response resp= new DCX_WOServiceManager.DCON_WO_MultiAssign_Response();
        resp.getlstTechEventDetails();
        resp.setlstTechEventDetails(objMap);
    }
    @isTest 
    public static void testUT_121()
      {
          SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                             Name = 'TEAM1A'];
          SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                           SVMXC__Service_Group_Members__c
                                                           where Name = 'TECH1A'];
          SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                  SVMXC__Group_Member__c = :Tech1.Id];
  
          List<String> woids = new List<String> ();
          woids.add(objWorkOrder.Id);
  
          List<String> techIds = new List<String> ();
          techIds.add(Tech1.Id);
           List<SVMXC__SVMX_Event__c> SVMXEvent = new List<SVMXC__SVMX_Event__c>();
          SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                      SVMXC__ActivityDate__c = Date.Today(), 
                                                      SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                      SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                      SVMXC__DurationInMinutes__c = 1440,
                                                      SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                      SVMXC__Technician__c = Tech1.Id,
                                                      SVMXC__WhatId__c = objWorkOrder.Id,
                                                      SVMXC__SM_Latitude__c = 10,
                                                      SVMXC__IsAllDayEvent__c = true
                                                      );
          SVMXEvent.add(SMAX_Event1);
          SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                      SVMXC__ActivityDate__c = Date.Today(), 
                                                      SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                      SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                      SVMXC__DurationInMinutes__c = 60,
                                                      SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                      SVMXC__Technician__c = Tech1.Id,
                                                      SVMXC__WhatId__c = objWorkOrder.Id
                                                      );
          SVMXEvent.add(SMAX_Event2);
          SVMXC__SVMX_Event__c SMAX_Event3 = new SVMXC__SVMX_Event__c(
                                                      SVMXC__ActivityDate__c = Date.Today(), 
                                                      SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                      SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                      SVMXC__DurationInMinutes__c = 60,
                                                      SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                      SVMXC__Technician__c = Tech1.Id,
                                                      SVMXC__WhatId__c = objWorkOrder.Id
                                                      );
          SVMXEvent.add(SMAX_Event3);
          insert SVMXEvent;
  User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
           List<Event> SFEvent = new List<Event>();
          Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                  StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                  ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                  DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                  WhatId=objWorkOrder.Id, Description='Test Desc');
          Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                  StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                  ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                  DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                  WhatId=objWorkOrder.Id, Description='Test Desc');
          Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-9 00:00:00'),
                                  StartDateTime = Datetime.valueOf('2010-02-9 01:00:00') ,
                                  ActivityDateTime = Datetime.valueOf('2010-02-9 01:00:00'), IsAllDayEvent =true,
                                  DurationInMinutes = 1440, Subject = 'test', OwnerId = objUser.Id, 
                                  WhatId=objWorkOrder.Id, Description='Test Desc');
  SFEvent.add(e1);
  SFEvent.add(e2);
  SFEvent.add(e3);
       // insert SFEvent;
        List<String> SFIds = new List<String>();
        List<String> SVMXIds = new List<String>();
  
        SFIds.add(e1.Id);
        SVMXIds.add(SMAX_Event3.Id);
  
        DCX_WOServiceManager.deleteEvents(SFIds);
        DCX_WOServiceManager.deleteEvents(SVMXIds);
  
         List<DCX_Wrapper.SVMX_StringMap> lstKeyValue1 = new List<DCX_Wrapper.SVMX_StringMap>();
  
  
          Woids.add(objWorkOrder.Id);
  
          SFEvent.add(e1);
          String str = e1.Id;
          lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
          lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
          lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '60'));
  
          DCX_WOServiceManager.DCON_WO_MultiAssign_Request req = new DCX_WOServiceManager.DCON_WO_MultiAssign_Request();
          req.workOrderIds = woids;
          req.technicianIds = techIds;
          req.operationType = 'WO_UNASSIGN_NO';
          req.timezone = 'America/Indiana/Indianapolis';
          req.Eventlist = SFEvent;
          req.EventIds = SFIds;
          req.lstKeyValue = lstKeyValue1;
          req.getworkOrderIds();
          req.setworkOrderIds(woids);
          req.getEventlist();
          req.setEventlist(SFEvent);
  
          req.operationType = 'WO_UNASSIGN_YES';
          DCX_WOServiceManager.DCX_Manage_Work_Order_MultiAssign_WS(req);
  
      }
    @isTest 
  public static void testUT_12()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];

        List<String> woids = new List<String> ();
        woids.add(objWorkOrder.Id);

        List<String> techIds = new List<String> ();
        techIds.add(Tech1.Id);
         List<SVMXC__SVMX_Event__c> SVMXEvent = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.Today(), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 1440,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id,
                                                    SVMXC__SM_Latitude__c = 10,
                                                    SVMXC__IsAllDayEvent__c = true
                                                    );
        SVMXEvent.add(SMAX_Event1);
        SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.Today(), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXEvent.add(SMAX_Event2);
        SVMXC__SVMX_Event__c SMAX_Event3 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.Today(), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXEvent.add(SMAX_Event3);
        insert SVMXEvent;
User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
         List<Event> SFEvent = new List<Event>();
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-9 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-9 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-9 01:00:00'), IsAllDayEvent =true,
                                DurationInMinutes = 1440, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
SFEvent.add(e1);
SFEvent.add(e2);
SFEvent.add(e3);
     // insert SFEvent;
      List<String> SFIds = new List<String>();
      List<String> SVMXIds = new List<String>();

      SFIds.add(e1.Id);
      SVMXIds.add(SMAX_Event3.Id);

      DCX_WOServiceManager.deleteEvents(SFIds);
      DCX_WOServiceManager.deleteEvents(SVMXIds);

       List<DCX_Wrapper.SVMX_StringMap> lstKeyValue1 = new List<DCX_Wrapper.SVMX_StringMap>();


        Woids.add(objWorkOrder.Id);

        SFEvent.add(e1);
        String str = e1.Id;
        lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue1.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '60'));

        DCX_WOServiceManager.DCON_WO_MultiAssign_Request req = new DCX_WOServiceManager.DCON_WO_MultiAssign_Request();
        req.workOrderIds = woids;
        req.technicianIds = techIds;
        req.operationType = 'WO_UNASSIGN_NO';
        req.timezone = 'America/Indiana/Indianapolis';
        req.Eventlist = SFEvent;
        req.EventIds = SFIds;
        req.lstKeyValue = lstKeyValue1;
        req.getworkOrderIds();
        req.setworkOrderIds(woids);
        req.getEventlist();
        req.setEventlist(SFEvent);

        DCX_WOServiceManager.DCX_Manage_Work_Order_MultiAssign_WS(req);
       

    }

    static testMethod void assignWOTech() {

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        
        DCX_WOServiceManager.assignWOTeam_Request req = new DCX_WOServiceManager.assignWOTeam_Request();
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        req.WorkOrderIds=woids;
        req.TeamId=objTeam.Id;
        req.SetOwner =false;
        req.dispatchStatus = 'New';
        req.unassignWorkorder=true;
        DCX_WOServiceManager.assignWOTeam_Request req1 = new DCX_WOServiceManager.assignWOTeam_Request( woids,'' , false,'',false);
        
        DCX_WOServiceManager.assignWOTeam_Request req2 = new DCX_WOServiceManager.assignWOTeam_Request();
        req2.WorkOrderIds=woids;
        req2.TeamId=Tech1.Id;
        req2.SetOwner =false;
        req2.dispatchStatus = 'New';
        req2.unassignWorkorder=true;

        DCX_WOServiceManager.assignWOTech(req);
        DCX_WOServiceManager.assignWOTech(req2);

    }
    static testMethod void DCON_Unassign_Work_Order_WS() {

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<String> woid = new List<String>();
        woid.add(objWorkOrder.Id);
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Unassign_Work_Order_WS(objUser.Id,woid);
        WOUtil.DCON_Unschedule_Work_Order_WS(objUser.Id,woid);
        WOUtil.DCON_Assign_Work_Order_To_Tech_WS(objUser.Id,woid,Tech1.Id,false);
        WOUtil.DCON_Assign_Work_Order_To_Tech_WS(objUser.Id,woid,Tech1.Id,true);
        WOUtil.DCON_Assign_Work_Order_To_Team_WS(objUser.Id,woid,objTeam.Id,false);
        WOUtil.DCON_Assign_Work_Order_To_Team_WS(objUser.Id,woid,objTeam.Id,true);

    }

    static testMethod void DCON_Keyword_Search_WS() {

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        User u = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<String> woid = new List<String>();
        woid.add(objWorkOrder.Id);


        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'TERRITORY,Name', 'ANY');
        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TEAM', 'TERRITORY,Name', 'ALL');
        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'EXPERTISE,Name', 'ANY');
        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'a,i', 'TECHNICIAN', 'SVMXC__City__c,Name', 'ANY'); 
        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'Bangalore,Te', 'TECHNICIAN', 'SVMXC__City__c,Name', 'ANY');        
        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TECHNICIAN', 'PRODUCT,EXPERTISE,', 'ALL');
        DCX_WOServiceManager.DCON_Keyword_Search_WS(u.Id, 'TECH', 'TEAM', 'PRODUCT,EXPERTISE,', 'ALL');
    }

    static testMethod void DCON_Retrieve_Eliminated_Work_Order_Info() {

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
          User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<String> woid = new List<String>();
        woid.add(objWorkOrder.Id);
        DCX_WOServiceManager.DCON_Retrieve_Eliminated_Work_Order_Info(objUser.Id,'Asia/Kolkata@MM/DD/YYYY hh:mm a',woid);


    }


    static testMethod void DCON_WO_Dependency_WS_UT_Test(){  
         
    String usid=UserInfo.getUserId();
    system.assert(usid!=null);
    User u = [SELECT id from User where id = :UserInfo.getUserId()];
    
    List<SVMXC__Dependency_Management__c> lstdg = new List<SVMXC__Dependency_Management__c>();
    
    SVMXC__Dependency_Management__c dg1 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency1');
    
    SVMXC__Dependency_Management__c dg2 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency2');
    
    SVMXC__Dependency_Management__c dg3 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency3');
    
    SVMXC__Dependency_Management__c dg4 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency4');
    
    SVMXC__Dependency_Management__c dg5 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency5');
    
    SVMXC__Dependency_Management__c dg6 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency6');
    
    lstdg.add(dg1);
    lstdg.add(dg2);
    lstdg.add(dg3);
    lstdg.add(dg4);
    lstdg.add(dg5);
    lstdg.add(dg6);
    
    insert lstdg;
    
    SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                        Name = 'TEAM 1'
                                        );
                        
    insert team1;
    
    List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
    
    SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                        Name = 'TECH 1' ,
                                        SVMXC__Service_Group__c = team1.Id,SVMXC__Salesforce_User__c = u.id);
    SVMXC__Service_Group_Members__c tech2 = new SVMXC__Service_Group_Members__c (
                                        Name = 'TECH 2' ,
                                        SVMXC__Service_Group__c = team1.Id);  
    SVMXC__Service_Group_Members__c tech3 = new SVMXC__Service_Group_Members__c (
                                        Name = 'TECH 3' ,
                                        SVMXC__Service_Group__c = team1.Id);
    SVMXC__Service_Group_Members__c tech4 = new SVMXC__Service_Group_Members__c (
                                        Name = 'TECH 4' ,
                                        SVMXC__Service_Group__c = team1.Id);                                  
    SVMXC__Service_Group_Members__c tech5 = new SVMXC__Service_Group_Members__c (
                                        Name = 'TECH 5' ,
                                        SVMXC__Service_Group__c = team1.Id);
    SVMXC__Service_Group_Members__c tech6 = new SVMXC__Service_Group_Members__c (
                                        Name = 'TECH 6' ,
                                        SVMXC__Service_Group__c = team1.Id);  
    lsttech.add(tech1);
    lsttech.add(tech2);
    lsttech.add(tech3);
    lsttech.add(tech4);
    lsttech.add(tech5);
    lsttech.add(tech6);
    insert lsttech;
    
    List<SVMXC__Service_Order__c> lstwo = new List<SVMXC__Service_Order__c>();  
    SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech1.Id, SVMXC__Dependency_Group__c = dg1.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo1);
    
    SVMXC__Service_Order__c wo2 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg1.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo2);
    
    SVMXC__Service_Order__c wo3 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech2.Id, SVMXC__Dependency_Group__c = dg2.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo3);
    
    SVMXC__Service_Order__c wo4 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg2.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo4);
    
    SVMXC__Service_Order__c wo5 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech3.Id, SVMXC__Dependency_Group__c = dg3.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo5);
    
    SVMXC__Service_Order__c wo6 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg3.Id, SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo6);
    
    SVMXC__Service_Order__c wo7 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech4.Id, SVMXC__Dependency_Group__c = dg4.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo7);
    
    SVMXC__Service_Order__c wo8 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg4.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo8);
    
    SVMXC__Service_Order__c wo9 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech5.Id, SVMXC__Dependency_Group__c = dg5.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo9);
    
    SVMXC__Service_Order__c wo10 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg5.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo10);
    
    SVMXC__Service_Order__c wo11 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech6.Id, SVMXC__Dependency_Group__c = dg6.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo11);
    
    SVMXC__Service_Order__c wo12 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg6.Id , SVMXC__Locked_By_DC__c = true);
    lstwo.add(wo12);
    
    insert lstwo;
    
    List<SVMXC__Service_Order_Dependency__c> lstdependencies = new List<SVMXC__Service_Order_Dependency__c>();
    SVMXC__Service_Order_Dependency__c dependency1 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg1.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo1.Id, SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo2.Id,SVMXC__Time_Dependency__c = 'Start to Start');
    lstdependencies.add(dependency1);
    
    SVMXC__Service_Order_Dependency__c dependency2 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg2.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo3.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo4.id,SVMXC__Time_Dependency__c = 'Start to Finish');
    lstdependencies.add(dependency2);
    
    SVMXC__Service_Order_Dependency__c dependency3 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg3.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo5.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo6.id,SVMXC__Time_Dependency__c = 'Finish to Start');
    lstdependencies.add(dependency3);
    
    SVMXC__Service_Order_Dependency__c dependency4 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg4.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo7.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo8.id,SVMXC__Time_Dependency__c = 'Finish to Finish');
    lstdependencies.add(dependency4);
    
    SVMXC__Service_Order_Dependency__c dependency5 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg5.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo9.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo10.id,SVMXC__Time_Dependency__c = 'Start Unison');
    lstdependencies.add(dependency5);
    
    SVMXC__Service_Order_Dependency__c dependency6 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg6.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo11.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo12.id,SVMXC__Time_Dependency__c = 'Finish Unison');
    lstdependencies.add(dependency6);
    
    insert lstdependencies;
    
    test.starttest();
    List<Event> lstSFEvents = new List<Event>();
    String timezone = 'GMT';
    Event e1 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test1', 
                            WhatId=wo2.id, Description='Test Desc1', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
    lstSFEvents.add(e1);                        
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req1 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    System.debug('req:'+ req1);
    DCX_WOServiceManager.Workorder_Dependency_Response response1 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req1);
    System.debug('response:'+ response1);
    
    Event e2 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test2', 
                            WhatId=wo4.id, Description='Test Desc2', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
                            
    lstSFEvents.clear();
    lstSFEvents.add(e2);                        
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req2= new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response2 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req2);
    
    Event e3 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test3', 
                            WhatId=wo6.id, Description='Test Desc3', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
    lstSFEvents.clear();
    lstSFEvents.add(e3);                        
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req3 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response3 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req3);                        
                            
    Event e4 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test4', 
                            WhatId=wo8.id, Description='Test Desc4', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
    lstSFEvents.clear();
    lstSFEvents.add(e4);                        
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req4 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response4 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req4);
    
    Event e5 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test5', 
                            WhatId=wo10.id, Description='Test Desc5', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
    lstSFEvents.clear();
    lstSFEvents.add(e5);                        
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req5 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response5 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req5);    
    
    Event e6 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test6', 
                            WhatId=wo12.id, Description='Test Desc6', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
    lstSFEvents.clear();
    lstSFEvents.add(e6);                        
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req6 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response6 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req6);
    
    Event e7 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                            StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                            EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                            ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                            DurationInMinutes = 60, Subject = 'test7', 
                            WhatId=wo2.id, Description='Test Desc7', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
    lstSFEvents.clear();
    lstSFEvents.add(e7); 
    insert lstSFEvents;
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req7 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response7 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req7);    
    
    List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
    SVMXC__SVMX_Event__c e8 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60,
                            SVMXC__Overhead_Time_Before__c =30,
                           
                            SVMXC__Break_Time_Total__c = 30,
                            SVMXC__WhatId__c=wo2.id, SVMXC__Description__c='Test Desc1', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech1.id);
    lstSVMXEvents.add(e8);                      
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req8 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response8 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req8);
                            
    SVMXC__SVMX_Event__c e9 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, 
                            SVMXC__WhatId__c=wo4.id, SVMXC__Description__c='Test Desc2', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech2.id);
    lstSVMXEvents.clear();
    lstSVMXEvents.add(e9);                      
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req9 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response9 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req9);
                            
    SVMXC__SVMX_Event__c e10 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, 
                            SVMXC__WhatId__c=wo6.id, SVMXC__Description__c='Test Desc3', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech3.id);
    lstSVMXEvents.clear();
    lstSVMXEvents.add(e10);                     
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req10 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response10 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req10);                      
                            
    SVMXC__SVMX_Event__c e11 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, 
                            SVMXC__WhatId__c=wo8.id, SVMXC__Description__c='Test Desc4', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech1.id);
    lstSVMXEvents.clear();
    lstSVMXEvents.add(e11);                     
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req12 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response12 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req12);
                            
    SVMXC__SVMX_Event__c e12 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, 
                            SVMXC__WhatId__c=wo10.id, SVMXC__Description__c='Test Desc5', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech2.id);
    lstSVMXEvents.clear();
    lstSVMXEvents.add(e12);                     
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req13 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response13 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req13);
                            
    SVMXC__SVMX_Event__c e13 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, 
                            SVMXC__WhatId__c=wo12.id, SVMXC__Description__c='Test Desc6', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech3.id);
    lstSVMXEvents.clear();
    lstSVMXEvents.add(e13);                     
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req14 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response14 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req14);
                            
    SVMXC__SVMX_Event__c e14 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                            SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                            SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                            SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                            SVMXC__DurationInMinutes__c = 60, 
                            SVMXC__WhatId__c=wo8.id, SVMXC__Description__c='Test Desc7', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech4.id);
    lstSVMXEvents.clear();
    lstSVMXEvents.add(e14);  
    insert lstSVMXEvents;
    SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req15 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
    DCX_WOServiceManager.Workorder_Dependency_Response response15 = DCX_WOServiceManager.DCON_WO_Dependency_Check_WS(req15); 
    
    test.stoptest();
}

static testMethod void DCON_WO_Dependency_WS_UT_Test2()
    {
        
         
        String usid=UserInfo.getUserId();
        system.assert(usid!=null);
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        
        List<SVMXC__Dependency_Management__c> lstdg = new List<SVMXC__Dependency_Management__c>();
        
        SVMXC__Dependency_Management__c dg7 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency1');
        
        SVMXC__Dependency_Management__c dg8 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency2');
        
        SVMXC__Dependency_Management__c dg9 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency3');
        
        SVMXC__Dependency_Management__c dg10 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency4');
        
        SVMXC__Dependency_Management__c dg11 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency5');
        
        SVMXC__Dependency_Management__c dg12 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency6');
        
        lstdg.add(dg7);
        lstdg.add(dg8);
        lstdg.add(dg9);
        lstdg.add(dg10);
        lstdg.add(dg11);
        lstdg.add(dg12);
        
        insert lstdg;
        
        SVMXC__Service_Group__c team2 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 2'
                                            );
                            
        insert team2;
        
        List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
        
        SVMXC__Service_Group_Members__c tech7 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 7' ,
                                            SVMXC__Service_Group__c = team2.Id,SVMXC__Salesforce_User__c = u.id);
        SVMXC__Service_Group_Members__c tech8 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 8' ,
                                            SVMXC__Service_Group__c = team2.Id);  
        SVMXC__Service_Group_Members__c tech9 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 9' ,
                                            SVMXC__Service_Group__c = team2.Id);
        SVMXC__Service_Group_Members__c tech10 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 10' ,
                                            SVMXC__Service_Group__c = team2.Id);                                  
        SVMXC__Service_Group_Members__c tech11 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 11' ,
                                            SVMXC__Service_Group__c = team2.Id);
        SVMXC__Service_Group_Members__c tech12 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 12' ,
                                            SVMXC__Service_Group__c = team2.Id);  
        lsttech.add(tech7);
        lsttech.add(tech8);
        lsttech.add(tech9);
        lsttech.add(tech10);
        lsttech.add(tech11);
        lsttech.add(tech12);
        insert lsttech;
        List<String> lw = new List<String>();
        List<SVMXC__Service_Order__c> lstwo = new List<SVMXC__Service_Order__c>(); 
          
        SVMXC__Service_Order__c wo21 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech7.Id, SVMXC__Dependency_Group__c = dg7.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo21);
        
        
        SVMXC__Service_Order__c wo22 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg7.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo22);
        
        
        SVMXC__Service_Order__c wo23 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech8.Id, SVMXC__Dependency_Group__c = dg8.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo23);
        
        
        SVMXC__Service_Order__c wo24 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg8.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo24);
        
        
        SVMXC__Service_Order__c wo25 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech9.Id, SVMXC__Dependency_Group__c = dg9.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo25);
        
        
        SVMXC__Service_Order__c wo26 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg9.Id, SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo26);
        
        SVMXC__Service_Order__c wo27 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech10.Id, SVMXC__Dependency_Group__c = dg10.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo27);
        
        SVMXC__Service_Order__c wo28 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg10.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo28);
       
        
        SVMXC__Service_Order__c wo29 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech11.Id, SVMXC__Dependency_Group__c = dg11.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo29);
        
        
        SVMXC__Service_Order__c wo30 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg11.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo30);
        
        SVMXC__Service_Order__c wo31 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech12.Id, SVMXC__Dependency_Group__c = dg12.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo31);
                
        SVMXC__Service_Order__c wo32 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg12.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo32);
       
        insert lstwo;
        for(SVMXC__Service_Order__c lws : lstwo)
        {
            lw.add(lws.id);
        }
        
        List<SVMXC__Service_Order_Dependency__c> lstdependencies = new List<SVMXC__Service_Order_Dependency__c>();
        SVMXC__Service_Order_Dependency__c dependency7 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg7.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo21.Id, SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo22.Id,SVMXC__Time_Dependency__c = 'Start to Start');
        lstdependencies.add(dependency7);
        
        SVMXC__Service_Order_Dependency__c dependency8 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg8.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo23.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo24.id,SVMXC__Time_Dependency__c = 'Start to Finish');
        lstdependencies.add(dependency8);
        
        SVMXC__Service_Order_Dependency__c dependency9 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg9.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo25.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo26.id,SVMXC__Time_Dependency__c = 'Finish to Start');
        lstdependencies.add(dependency9);
        
        SVMXC__Service_Order_Dependency__c dependency10 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg10.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo27.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo28.id,SVMXC__Time_Dependency__c = 'Finish to Finish');
        lstdependencies.add(dependency10);
        
        SVMXC__Service_Order_Dependency__c dependency11 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg11.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo29.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo30.id,SVMXC__Time_Dependency__c = 'Start Unison');
        lstdependencies.add(dependency11);
        
        SVMXC__Service_Order_Dependency__c dependency12 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg12.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo31.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo32.id,SVMXC__Time_Dependency__c = 'Finish Unison');
        lstdependencies.add(dependency12);
        
        insert lstdependencies;
        
        test.starttest();
        List<Event> lstSFEvents = new List<Event>();
        String timezone = 'GMT';
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c e21 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__Driving_Time_Home__c = 30,
                                SVMXC__Driving_Time__c=30,
                                SVMXC__Overhead_Time_Before__c =30,
                                SVMXC__Overhead_Time_After__c = 30,
                                SVMXC__Break_Time_Total__c = 30,
                                SVMXC__Service_Order__c=wo22.id, SVMXC__Description__c='Test Desc6', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech9.id);
        lstSVMXEvents.add(e21);
        insert lstSVMXEvents;
        system.debug('inserted lstsvmxevents');
                               
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req11 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        System.debug('req:'+ req11);
        //DCX_WOServiceManager.Workorder_Dependency_Response response11 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req11);
        //System.debug('response:'+ response11);
        
        Event e22 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                SVMXC__Overhead_Time_Before__c =30,
                                SVMXC__Overhead_Time_After__c = 30,
                              SVMXC__Driving_Time_Home__c = 30,
                              SVMXC__Driving_Time__c=30,
                                SVMXC__Break_Time_Total__c = 30,
                                DurationInMinutes = 60, Subject = 'test2', 
                                
                                WhatId=wo24.id, Description='Test Desc2', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
                                
        
        lstSFEvents.add(e22);                        
        
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req12= new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCX_WOServiceManager.Workorder_Dependency_Response response12 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req12);
        
        Event e23 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test3', 
                                WhatId=wo26.id, Description='Test Desc3', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        
        lstSFEvents.add(e23);                        
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req13 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCX_WOServiceManager.Workorder_Dependency_Response response13 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req13);                        
                                
        Event e24 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test4', 
                                WhatId=wo28.id, Description='Test Desc4', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e24);                        
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req14 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCX_WOServiceManager.Workorder_Dependency_Response response14 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req14);
        
        Event e25 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test5', 
                                WhatId=wo30.id, Description='Test Desc5', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e25);                        
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req15 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCX_WOServiceManager.Workorder_Dependency_Response response15 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req15);    
        
        Event e26 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test6', 
                                WhatId=wo32.id, Description='Test Desc6', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e26);  
        insert lstSFEvents;
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req16 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCX_WOServiceManager.Workorder_Dependency_Response response16 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req16);          
        List<DCX_WOServiceManager.Dependency_Details> response = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req11);
        test.stoptest();
    }
    static testMethod void DCON_WO_Dependency_WS_UT_Test3()
    {
        
         
        String usid=UserInfo.getUserId();
        system.assert(usid!=null);
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        
        List<SVMXC__Dependency_Management__c> lstdg = new List<SVMXC__Dependency_Management__c>();
        
        SVMXC__Dependency_Management__c dg7 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency1');
        
        SVMXC__Dependency_Management__c dg8 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency2');
        
        SVMXC__Dependency_Management__c dg9 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency3');
        
        SVMXC__Dependency_Management__c dg10 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency4');
        
        SVMXC__Dependency_Management__c dg11 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency5');
        
        SVMXC__Dependency_Management__c dg12 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency6');
        
        lstdg.add(dg7);
        lstdg.add(dg8);
        lstdg.add(dg9);
        lstdg.add(dg10);
        lstdg.add(dg11);
        lstdg.add(dg12);
        
        insert lstdg;
        
        SVMXC__Service_Group__c team2 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 2'
                                            );
                            
        insert team2;
        
        List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
        
        SVMXC__Service_Group_Members__c tech7 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 7' ,
                                            SVMXC__Service_Group__c = team2.Id,SVMXC__Salesforce_User__c = u.id);
        SVMXC__Service_Group_Members__c tech8 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 8' ,
                                            SVMXC__Service_Group__c = team2.Id);  
        SVMXC__Service_Group_Members__c tech9 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 9' ,
                                            SVMXC__Service_Group__c = team2.Id);
        SVMXC__Service_Group_Members__c tech10 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 10' ,
                                            SVMXC__Service_Group__c = team2.Id);                                  
        SVMXC__Service_Group_Members__c tech11 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 11' ,
                                            SVMXC__Service_Group__c = team2.Id);
        SVMXC__Service_Group_Members__c tech12 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 12' ,
                                            SVMXC__Service_Group__c = team2.Id);  
        lsttech.add(tech7);
        lsttech.add(tech8);
        lsttech.add(tech9);
        lsttech.add(tech10);
        lsttech.add(tech11);
        lsttech.add(tech12);
        insert lsttech;
        List<String> lw = new List<String>();
        List<SVMXC__Service_Order__c> lstwo = new List<SVMXC__Service_Order__c>(); 
          
        SVMXC__Service_Order__c wo21 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech7.Id, SVMXC__Dependency_Group__c = dg7.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo21);
        
        
        SVMXC__Service_Order__c wo22 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg7.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo22);
        
        
        SVMXC__Service_Order__c wo23 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech8.Id, SVMXC__Dependency_Group__c = dg8.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo23);
        
        
        SVMXC__Service_Order__c wo24 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg8.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo24);
        
        
        SVMXC__Service_Order__c wo25 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech9.Id, SVMXC__Dependency_Group__c = dg9.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo25);
        
        
        SVMXC__Service_Order__c wo26 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg9.Id, SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo26);
        
        SVMXC__Service_Order__c wo27 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech10.Id, SVMXC__Dependency_Group__c = dg10.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo27);
        
        SVMXC__Service_Order__c wo28 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg10.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo28);
       
        
        SVMXC__Service_Order__c wo29 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech11.Id, SVMXC__Dependency_Group__c = dg11.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo29);
        
        
        SVMXC__Service_Order__c wo30 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg11.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo30);
        
        SVMXC__Service_Order__c wo31 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech12.Id, SVMXC__Dependency_Group__c = dg12.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo31);
                
        SVMXC__Service_Order__c wo32 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg12.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo32);
       
        insert lstwo;
        for(SVMXC__Service_Order__c lws : lstwo)
        {
            lw.add(lws.id);
        }
        
        List<SVMXC__Service_Order_Dependency__c> lstdependencies = new List<SVMXC__Service_Order_Dependency__c>();
        SVMXC__Service_Order_Dependency__c dependency7 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg7.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo21.Id, SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo22.Id,SVMXC__Time_Dependency__c = 'Start to Start');
        lstdependencies.add(dependency7);
        
        SVMXC__Service_Order_Dependency__c dependency8 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg8.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo23.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo24.id,SVMXC__Time_Dependency__c = 'Start to Finish');
        lstdependencies.add(dependency8);
        
        SVMXC__Service_Order_Dependency__c dependency9 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg9.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo25.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo26.id,SVMXC__Time_Dependency__c = 'Finish to Start');
        lstdependencies.add(dependency9);
        
        SVMXC__Service_Order_Dependency__c dependency10 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg10.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo27.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo28.id,SVMXC__Time_Dependency__c = 'Finish to Finish');
        lstdependencies.add(dependency10);
        
        SVMXC__Service_Order_Dependency__c dependency11 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg11.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo29.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo30.id,SVMXC__Time_Dependency__c = 'Start Unison');
        lstdependencies.add(dependency11);
        
        SVMXC__Service_Order_Dependency__c dependency12 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg12.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo31.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo32.id,SVMXC__Time_Dependency__c = 'Finish Unison');
        lstdependencies.add(dependency12);
        
        insert lstdependencies;
        
        test.starttest();
        List<Event> lstSFEvents = new List<Event>();
        String timezone = 'GMT';
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c e21 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__Driving_Time_Home__c = 30,
                                SVMXC__Driving_Time__c=30,
                                SVMXC__Overhead_Time_Before__c =30,
                                SVMXC__Overhead_Time_After__c = 30,
                                SVMXC__Break_Time_Total__c = 30,
                                SVMXC__Service_Order__c=wo22.id, SVMXC__Description__c='Test Desc6', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech9.id);
        lstSVMXEvents.add(e21);
        SVMXC__SVMX_Event__c e211 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
        SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
        SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
        SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
        SVMXC__DurationInMinutes__c = 60, 
        SVMXC__Driving_Time_Home__c = 30,
        SVMXC__Driving_Time__c=30,
        SVMXC__Overhead_Time_Before__c =30,
        SVMXC__Overhead_Time_After__c = 30,
        SVMXC__Break_Time_Total__c = 30,
        SVMXC__Service_Order__c=wo22.id, SVMXC__Description__c='Test Desc6', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech9.id);
lstSVMXEvents.add(e211);
        insert lstSVMXEvents;
        system.debug('inserted lstsvmxevents');
                               
        
        Event e22 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                SVMXC__Overhead_Time_Before__c =30,
                                SVMXC__Overhead_Time_After__c = 30,
                              SVMXC__Driving_Time_Home__c = 30,
                              SVMXC__Driving_Time__c=30,
                                SVMXC__Break_Time_Total__c = 30,
                                DurationInMinutes = 60, Subject = 'test2', 
                                
                                WhatId=wo24.id, Description='Test Desc2', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
                                
        
        lstSFEvents.add(e22);                        
        
        
        Event e23 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test3', 
                                WhatId=wo21.id, Description='Test Desc3', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        
        lstSFEvents.add(e23);                        
                                
        Event e24 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test4', 
                                WhatId=wo28.id, Description='Test Desc4', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e24);   
        
        Event e212 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test4', 
                                WhatId=wo21.id, Description='Test Desc4', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e212); 
        
        Event e25 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test5', 
                                WhatId=wo30.id, Description='Test Desc5', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e25);                        
        
        Event e26 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test6', 
                                WhatId=wo21.id, Description='Test Desc6', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e26);  
        insert lstSFEvents;
        List<Event> ev = new List<Event>();
        ev.add(e22);
        ev.add(e23);
        ev.add(e24);
        ev.add(e25);
        ev.add(e26);

        List<SVMXC__SVMX_Event__c> ev1 = new List<SVMXC__SVMX_Event__c>();
        ev1.add(e21);

        List<String> wo = new List<String>();
        wo.add(wo21.Id);
        wo.add(wo22.Id);
        wo.add(wo30.Id);
        wo.add(wo24.Id);
        wo.add(wo26.Id);
        wo.add(wo28.Id);
        wo.add(wo22.Id);

 
        SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request req11 = new SVMXC.DCX_WOServiceManager.Workorder_Dependency_Request(lstSFEvents,lstSVMXEvents,timezone,u.id,wo);
        //DCX_WOServiceManager.Workorder_Dependency_Response response16 = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req16);          
        List<DCX_WOServiceManager.Dependency_Details> response = DCX_WOServiceManager.DCON_WO_Get_Dependency_Details_WS(req11);
        test.stoptest();
    }

    static testMethod void assignWOTeam()
    {
        DCX_WOServiceManager.assignWOTeam_Request assnt = new DCX_WOServiceManager.assignWOTeam_Request();
        list<String> woids = new List<String>();
        assnt.WorkOrderIds = woids;
        assnt.TeamId = '';
        assnt.SetOwner = false;
        assnt.dispatchStatus = 'New';
        assnt.unassignWorkorder = false;
        DCX_WOServiceManager.assignWOTeam_Request assnt1 = new DCX_WOServiceManager.assignWOTeam_Request(woids,'',false,'New',false);
        DCX_WOServiceManager.assignWOTeam(assnt);


    }
    static testMethod void DCON_ViewWoCount_WS()
    {
        
        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__Ownership_Type__c = 'User\'s Records';
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__ProcessID__c = 'testing1234';
        objSVMXPrcss.SVMXC__Name__c = 'testing1234';
        objSVMXPrcss.SVMXC__Advance_Expression__c = '';
        objSVMXPrcss.SVMXC__IsStandard__c = false;
        objSVMXPrcss.RecordTypeId = RTProcess.Id;
        insert objSVMXPrcss;

        DCX_Wrapper.ViewWoCountReq re = new DCX_Wrapper.ViewWoCountReq ();
        re.viewId = objSVMXPrcss.Id;
        DCX_Wrapper.ViewWoCountReq req = new DCX_Wrapper.ViewWoCountReq (objSVMXPrcss.Id);

        DCX_WOServiceManager.DCON_ViewWoCount_WS(re);

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
          User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<String> woid = new List<String>();
        woid.add(objWorkOrder.Id);
        List<String> status = new List<String>();
        status.add('New');
        List<String> status1 = new List<String>();
        status1.add('RESPONSETYPE|COMPLETEINFO');
        User u = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];

        DCX_WOServiceManager.DCON_Retrieve_Work_Orders(u.Id,'',status,'Asia/Kolkata',woid,status1);
        DCX_WOServiceManager.DCON_Retrieve_Work_Orders(u.Id,u.Id,status,'Asia/Kolkata',woid,status1);
    }
    static testMethod void DCON_ViewWoCount_WS1()
    {
        
        RecordType RTProcess = [select Id from RecordType where Name = 'View Definition' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTCfgDta = [select Id from RecordType where Name = 'View Access' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objSVMXPrcss = new SVMXC__ServiceMax_Processes__c();
        objSVMXPrcss.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSVMXPrcss.SVMXC__Ownership_Type__c = 'User\'s Records';
        objSVMXPrcss.SVMXC__Rule_Type__c = 'Custom View';
        objSVMXPrcss.SVMXC__ProcessID__c = 'testing1234';
        objSVMXPrcss.SVMXC__Name__c = 'testing1234';
        objSVMXPrcss.SVMXC__Advance_Expression__c = '';
        objSVMXPrcss.SVMXC__IsStandard__c = false;
        objSVMXPrcss.RecordTypeId = RTProcess.Id;
        insert objSVMXPrcss;

        DCX_Wrapper.ViewWoCountReq re = new DCX_Wrapper.ViewWoCountReq ();
        re.viewId = objSVMXPrcss.Id;
        DCX_Wrapper.ViewWoCountReq req = new DCX_Wrapper.ViewWoCountReq (objSVMXPrcss.Id);


        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
          User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<String> woid = new List<String>();
        woid.add(objWorkOrder.Id);
        List<String> status = new List<String>();
        status.add('New');
        List<String> status1 = new List<String>();
        status1.add('RESPONSETYPE|COMPLETEINFO');
        User u = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        try{
            DCX_WOServiceManager.DCON_Retrieve_Work_Orders(u.Id,'',status,'Asia/Kolkata',null,status1);
        }
        catch(exception e) {}
        
        DCX_WOServiceManager.DCON_Retrieve_Work_Orders(u.Id,objWorkOrder.Id,status,'Asia/Kolkata',woid,status1);
    }

    static testMethod void callingWrapper()
    {
        DCX_WOServiceManager.Preferrable_Workorder_Timings preTime = new DCX_WOServiceManager.Preferrable_Workorder_Timings();
        DCX_WOServiceManager.Dependency_Details details = new DCX_WOServiceManager.Dependency_Details();
        details.woId = '';
        details.isPrimaryWorkOrder = true;
        details.dependencyGroup= '';
        details.maximumDeviation= '';
        details.maximumDeviationUnits= '';
        details.minimumDeviation= '';
        details.minimumDeviationUnits= '';
        details.primaryWorkOrder= '';
        details.secondaryWorkOrder= '';
        details.primaryWorkOrderName= '';
        details.secondaryWorkOrderName= '';
        details.resourceDependency= '';
        details.timeDependency= '';
        details.technicianId= '';
        details.technicianName= '';
        details.scheduledStartTime= '';
        details.serviceDuration= '';
        details.breakTime= '';
        details.driveTimeBefore= '';
        details.driveTimeAfter= '';
        details.overHeadTimeBefore= '';
        details.overHeadTimeAfter= '';
        details.primaryWOName= '';
        details.dependencyGroupName= '';

        DCX_WOServiceManager.Dependency_Details details1 = new DCX_WOServiceManager.Dependency_Details('',false,'','','','','','','','','');
        
    }
    static testMethod void SVMX_getDispatcherList_WS()
    {
        string K;
        string v;
        DCX_Wrapper.SVMX_StringMap stringMap = new DCX_Wrapper.SVMX_StringMap(k,v);
        DCX_Wrapper.SVMX_Response res = new DCX_Wrapper.SVMX_Response();
        DCX_WOServiceManager.SVMX_getDispatcherList_WS(stringMap);

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                Name = 'TEAM1A'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                      SVMXC__Service_Group_Members__c
                      where Name = 'TECH1A'];//
        SVMXC__Territory__c objTerr = [Select Id from  SVMXC__Territory__c
                      where Name = 'TERRITORY1B'];

        User u = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        stringMap.Value = u.Id;
        DCX_WOServiceManager.SVMX_getDispatcherList_WS(stringMap);
        User u2 = [SELECT id,LocaleSidKey from User where id != :UserInfo.getUserId() limit 1];
        stringMap.Value = u2.Id;
        DCX_WOServiceManager.SVMX_getDispatcherList_WS(stringMap);

    }

    static testMethod void ValidateFieldType()
    {
        DCX_WOServiceManager.ValidateFieldType('BOOLEAN','test');
        DCX_WOServiceManager.ValidateFieldType('INTEGER','test');
        DCX_WOServiceManager.ValidateFieldType('CURRENCY','test');
    }
    static testMethod void DCON_UnAssign_WO()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];

                                                SVMXC__SVMX_Event__c e1 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2016-06-11 00:00:00'),
                                                SVMXC__StartDateTime__c = Date.valueOf('2016-06-11 01:00:00'),
                                                SVMXC__ActivityDateTime__c = Date.valueOf('2016-06-11 00:00:00'), 
                                                SVMXC__DurationInMinutes__c = 60, SVMXC__Technician__c = Tech1.Id, 
                                                SVMXC__WhatId__c=objWorkOrder.Id);
                            insert e1;
        DCX_Wrapper.DCTech_WO_WP objWoWp = new DCX_Wrapper.DCTech_WO_WP(objWorkOrder.Id, tech1.Id, tech1.Id, true, e1.SVMXC__StartDateTime__c, 'Asia/Kolkata','',false,e1.id,true);

        DCX_WOServiceManager.DCON_UnAssign_WO(objWoWp);
    }

    static testMethod void DCON_UnAssign_WO_1()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];

                                                SVMXC__SVMX_Event__c e1 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2016-06-11 00:00:00'),
                                                SVMXC__StartDateTime__c = Date.valueOf('2016-06-11 01:00:00'),
                                                SVMXC__ActivityDateTime__c = Date.valueOf('2016-06-11 00:00:00'), 
                                                SVMXC__DurationInMinutes__c = 60, SVMXC__Technician__c = Tech1.Id, 
                                                SVMXC__WhatId__c=objWorkOrder.Id);
                            insert e1;
        DCX_Wrapper.DCTech_WO_WP objWoWp = new DCX_Wrapper.DCTech_WO_WP(objWorkOrder.Id, Tech1.Id, Tech1.Id, true, e1.SVMXC__StartDateTime__c, 'Asia/Kolkata','',false,e1.id,true);

        DCX_WOServiceManager.DCON_UnAssign_WO(objWoWp);

        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                        SVMXC__Latitude__c = 40.739582 , 
                                                        SVMXC__Longitude__c = -73.980772, 
                                                        SVMXC__Order_Status__c = 'Open',
                                                        SVMXC__Priority__c ='Medium',
                                                        SVMXC__Order_Type__c='Field Service',
                                                        SVMXC__Locked_By_DC__c = true,
                                                        SVMXC__SM_Estimated_Duration__c = 100,
                                                        SVMXC__SM_Scope_Change__c = 0,
                                                        SVMXC__SM_Variance__c = 0,
                                                        SVMXC__SM_Scheduled_Duration__c = 20,
                                                        SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                        SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                    );
        insert svo;
        DCX_Wrapper.DCTech_WO_WP objWoWp1 = new DCX_Wrapper.DCTech_WO_WP(svo.Id, Tech1.Id, Tech1.Id, true, e1.SVMXC__StartDateTime__c, 'Asia/Kolkata','',false,e1.id,true);
        DCX_WOServiceManager.DCON_UnAssign_WO(objWoWp1);

    }

    static testMethod void DCON_AES_Unassign_WO_WS()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];

                                                SVMXC__SVMX_Event__c e1 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2016-06-11 00:00:00'),
                                                SVMXC__StartDateTime__c = Date.valueOf('2016-06-11 01:00:00'),
                                                SVMXC__ActivityDateTime__c = Date.valueOf('2016-06-11 00:00:00'), 
                                                SVMXC__DurationInMinutes__c = 60, SVMXC__Technician__c = Tech1.Id, 
                                                SVMXC__WhatId__c=objWorkOrder.Id);
                            insert e1;
        DCX_Wrapper.DCTech_WO_WP objWoWp = new DCX_Wrapper.DCTech_WO_WP(objWorkOrder.Id, Tech1.Id, '', false, DateTime.valueOf('2016-06-11 00:00:00'),'Asia/Kolkata',e1.Id,false,'',true);


        DCX_WOServiceManager.DCON_AES_Unassign_WO_WS(objWoWp);
    }

    static testMethod void DCON_AES_Unassign_WO_WS1()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                            SVMXC__Latitude__c = 40.739582 , 
                                                            SVMXC__Longitude__c = -73.980772, 
                                                            SVMXC__Order_Status__c = 'Open',
                                                            SVMXC__Priority__c ='Medium',
                                                            SVMXC__Order_Type__c='Field Service',
                                                            SVMXC__Locked_By_DC__c = true,
                                                            SVMXC__SM_Estimated_Duration__c = 100,
                                                            SVMXC__SM_Scope_Change__c = 0,
                                                            SVMXC__SM_Variance__c = 0,
                                                            SVMXC__SM_Scheduled_Duration__c = 20,
                                                            SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                            SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                        );
            insert svo;

            Event e1 = new Event(ActivityDate = Date.valueOf('2016-06-11 00:00:00'),
            StartDateTime = Datetime.valueOf('2016-06-11 01:00:00') ,
            ActivityDateTime = Datetime.valueOf('2016-06-11 01:00:00'), 
            DurationInMinutes = 60, Subject = 'test', OwnerId = Tech1.Id, 
            WhatId=svo.Id, Description='Test Desc');

            DCX_Wrapper.DCTech_WO_WP objWoWp = new DCX_Wrapper.DCTech_WO_WP(svo.Id, Tech1.Id, '', true, DateTime.valueOf('2016-06-11 00:00:00'),'Asia/Kolkata',e1.Id,true,'',false);
            try {   
            //Delete event for a given technician Id
             DCX_WOServiceManager.DCON_AES_Unassign_WO_WS(objWoWp);
            }
            catch(exception e) {}

    }
    static testMethod void DCON_AES_Unassign_WO_WS2()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                            SVMXC__Latitude__c = 40.739582 , 
                                                            SVMXC__Longitude__c = -73.980772, 
                                                            SVMXC__Order_Status__c = 'Open',
                                                            SVMXC__Priority__c ='Medium',
                                                            SVMXC__Order_Type__c='Field Service',
                                                            SVMXC__Locked_By_DC__c = true,
                                                            SVMXC__SM_Estimated_Duration__c = 100,
                                                            SVMXC__SM_Scope_Change__c = 0,
                                                            SVMXC__SM_Variance__c = 0,
                                                            SVMXC__SM_Scheduled_Duration__c = 20,
                                                            SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                            SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                        );
            insert svo;

            Event e1 = new Event(ActivityDate = Date.valueOf('2016-06-11 00:00:00'),
            StartDateTime = Datetime.valueOf('2016-06-11 01:00:00') ,
            ActivityDateTime = Datetime.valueOf('2016-06-11 01:00:00'), 
            DurationInMinutes = 60, Subject = 'test', OwnerId = Tech1.Id, 
            WhatId=svo.Id, Description='Test Desc');

            DCX_Wrapper.DCTech_WO_WP objWoWp = new DCX_Wrapper.DCTech_WO_WP(svo.Id, Tech1.Id, '', true, null,'Asia/Kolkata',e1.Id,true,'',false);
            try {   
            //Delete event for a given technician Id
             DCX_WOServiceManager.DCON_AES_Unassign_WO_WS(objWoWp);
            }
            catch(exception e) {}

    }

    static testMethod void DCON_AES_Unassign_WO_WS3()
    {
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                            SVMXC__Latitude__c = 40.739582 , 
                                                            SVMXC__Longitude__c = -73.980772, 
                                                            SVMXC__Order_Status__c = 'Open',
                                                            SVMXC__Priority__c ='Medium',
                                                            SVMXC__Order_Type__c='Field Service',
                                                            SVMXC__Locked_By_DC__c = true,
                                                            SVMXC__SM_Estimated_Duration__c = 100,
                                                            SVMXC__SM_Scope_Change__c = 0,
                                                            SVMXC__SM_Variance__c = 0,
                                                            SVMXC__SM_Scheduled_Duration__c = 20,
                                                            SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4,
                                                            SVMXC__SM_Scheduling_Options__c = 'JDM and LJS Enabled'
                                                        );
            insert svo;

            Event e1 = new Event(ActivityDate = Date.valueOf('2016-06-11 00:00:00'),
            StartDateTime = Datetime.valueOf('2016-06-11 01:00:00') ,
            ActivityDateTime = Datetime.valueOf('2016-06-11 01:00:00'), 
            DurationInMinutes = 60, Subject = 'test', OwnerId = Tech1.Id, 
            WhatId=svo.Id, Description='Test Desc');

            DCX_Wrapper.DCTech_WO_WP objWoWp = new DCX_Wrapper.DCTech_WO_WP(svo.Id, Tech1.Id, '', true, null,'Asia/Kolkata',e1.Id,false,'',false);
            try {   
            //Delete event for a given technician Id
             DCX_WOServiceManager.DCON_AES_Unassign_WO_WS(objWoWp);
            }
            catch(exception e) {}

    }
    static testMethod void trycatch()
    {
        List<String> wo4 = new List<String>();
        try {
        DCX_WOServiceManager.DCON_Retrieve_Views('12345');
    }
    catch(exception e) {}
    try {
        List<String> wo = new List<String>();
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Unassign_Work_Order_WS('12345',wo);
    }
    catch(exception e) {}
    try {
        List<String> wo1 = new List<String>();
        wo1.add('1234');
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Unassign_Work_Order_WS('12345',wo1);
    }
    catch(exception e) {}

    try {
        List<String> wo2= new List<String>();
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Unschedule_Work_Order_WS('12345',wo2);
    }
    catch(exception e) {}
    try {
        List<String> wo3 = new List<String>();
        wo3.add('1234');
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Unschedule_Work_Order_WS('12345',wo3);
    }
    catch(exception e) {}
    try {
       wo4 = new List<String>();
       DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Assign_Work_Order_To_Tech_WS('12345',wo4,'',false);
        wo4.add('1234');
        WOUtil.DCON_Assign_Work_Order_To_Tech_WS('12345',wo4,'',false);
        WOUtil.DCON_Assign_Work_Order_To_Tech_WS('12345',wo4,'12345',false);
    }
    catch(exception e) {}
    try {
        wo4 = new List<String>();
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Assign_Work_Order_To_Team_WS('12345',wo4,'',false);
         wo4.add('1234');
         WOUtil.DCON_Assign_Work_Order_To_Team_WS('12345',wo4,'',false);
         WOUtil.DCON_Assign_Work_Order_To_Team_WS('12345',wo4,'12345',false);
     }
     catch(exception e) {}
     try {
        wo4 = new List<String>();
        DCX_WOServiceManager.getWO(wo4);
     }
     catch(exception e) {}
    
    }

    static testMethod void DCON_Unassign_Work_Order_WS1() {

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1A'];

        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH1A'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        Event e1 = new Event(ActivityDate = Date.valueOf('2016-06-11 00:00:00'),
            StartDateTime = Datetime.valueOf('2016-06-11 01:00:00') ,
            ActivityDateTime = Datetime.valueOf('2016-06-11 01:00:00'), 
            DurationInMinutes = 60, Subject = 'test', OwnerId = Tech1.Id, 
            WhatId=objWorkOrder.Id, Description='Test Desc');
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        List<String> woid = new List<String>();
        woid.add(objWorkOrder.Id);
        DCX_WOServiceManager.DCX_WOServiceManager_Util WOUtil = new DCX_WOServiceManager.DCX_WOServiceManager_Util();
        WOUtil.DCON_Unschedule_Work_Order_WS(objUser.Id,woid);
       // DCX_WOServiceManager.getWO(woid);
    }

    

    
}