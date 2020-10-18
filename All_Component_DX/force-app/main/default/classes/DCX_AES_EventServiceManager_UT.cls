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

@isTest ()
private class DCX_AES_EventServiceManager_UT {

      public static String userId ='';
      public static  SVMXC__Service_Group_Members__c objTechnician; 
      public static SVMXC__Service_Order__c objWorkOrder;
    @testSetup static void setup() {
        SVMXC__ServiceMax_Config_Data__c globalProfile = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> configDataList =  
            new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> processes = 
            new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> settingValues = new List<SVMXC__ServiceMax_Processes__c>();

        globalProfile.recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
        globalProfile.SVMXC__Configuration_Type__c = 'Global';
        globalProfile.SVMXC__Active__c = true;
        insert globalProfile;

        SVMXC__ServiceMax_Processes__c dcon001Process = new SVMXC__ServiceMax_Processes__c();
        dcon001Process.SVMXC__SubmoduleID__c = 'DCON001';
        dcon001Process.SVMXC__MapID__c = 'dcon001Process';
        processes.add(dcon001Process);

        SVMXC__ServiceMax_Processes__c dcon005Process = new SVMXC__ServiceMax_Processes__c();
        dcon005Process.SVMXC__SubmoduleID__c = 'DCON005';
        dcon005Process.SVMXC__MapID__c = 'dcon005Process';
        processes.add(dcon005Process);

        insert processes;

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

        SVMXC__ServiceMax_Processes__c set022Process = new SVMXC__ServiceMax_Processes__c();
        set022Process.SVMXC__SettingID__c = 'SET022';
        set022Process.SVMXC__MapID__c = 'set022Process';
        set022Process.SVMXC__Submodule__c = dcon001Process.Id;
        settingValues.add(set022Process);

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

        SVMXC__ServiceMax_Processes__c dcon005Set009Process = new SVMXC__ServiceMax_Processes__c();
        dcon005Set009Process.SVMXC__SettingID__c = 'SET009';
        dcon005Set009Process.SVMXC__MapID__c = 'dcon005Set009Process';
        dcon005Set009Process.SVMXC__Submodule__c = dcon005Process.Id;
        settingValues.add(dcon005Set009Process);
        
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

        SVMXC__ServiceMax_Config_Data__c set022Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set022Setting.SVMXC__Internal_Value__c = 'False';
        set022Setting.SVMXC__Display_Value__c = 'False';
        set022Setting.recordtypeid = settingValueRecordTypeId;
        set022Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set022Setting.SVMXC__Setting_ID__c = set022Process.Id;
        configDataList.add(set022Setting);

        SVMXC__ServiceMax_Config_Data__c set024Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set024Setting.SVMXC__Internal_Value__c = 'True';
        set024Setting.SVMXC__Display_Value__c = 'True';
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

        SVMXC__ServiceMax_Config_Data__c dcon005Set005Setting =  new SVMXC__ServiceMax_Config_Data__c();
        dcon005Set005Setting.SVMXC__Internal_Value__c = '14';
        dcon005Set005Setting.SVMXC__Display_Value__c = '14';
        dcon005Set005Setting.recordtypeid = settingValueRecordTypeId;
        dcon005Set005Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        dcon005Set005Setting.SVMXC__Setting_ID__c = dcon005Set009Process.Id;
        configDataList.add(dcon005Set005Setting);

        insert configDataList;

        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (Name = 'TEAM1');
        insert objTeam;
                
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;

        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        BusinessHours defaultbh = lstdefaultbh.get(0);
        
        List<SVMXC__Service_Group_Members__c> techList = new  List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Order__c> woList = new  List<SVMXC__Service_Order__c>();
         objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Salesforce_User__c = UserInfo.getUserId()
                                            );
        techList.add(objTechnician) ;

        SVMXC__Service_Group_Members__c objTechnician1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 2' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Salesforce_User__c = UserInfo.getUserId()
                                            );
        techList.add(objTechnician1) ;
        insert techList;

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
         objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician.Id,
                                            SVMXC__Preferred_Start_Time__c = t.addHours(4),
                                            SVMXC__Preferred_Business_Hours__c = defaultbh.Id,
                                            SVMXC__SM_Estimated_Duration__c = 7200 
                                            );
        woList.add(objWorkOrder);

        SVMXC__Service_Order__c objWorkOrder1 = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician1.Id,
                                            SVMXC__Preferred_Start_Time__c = t.addHours(4),
                                            SVMXC__Preferred_Business_Hours__c = defaultbh.Id,
                                            SVMXC__SM_Estimated_Duration__c = 60 
                                            );
        woList.add(objWorkOrder1);
        insert woList;

        List<Event> SFEvent = new List<Event>();
        Event e1 = new Event(ActivityDate = Date.Today(),
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             DurationInMinutes = 60, Subject = 'test',// OwnerId = objTechnician1.Id, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        SFEvent.add(e1);
        Event e2 = new Event(ActivityDate = Date.Today(),
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(24),
                             DurationInMinutes = 1440, Subject = 'test svmx',
                          //   OwnerId = objTechnician1.SVMXC__Salesforce_User__c, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        SFEvent.add(e2);

        insert SFEvent;


      List<SVMXC__SVMX_Event__c> SVMXEvent = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.Today(), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 1440,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician1.Id,
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
                                                    SVMXC__Technician__c = objTechnician1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXEvent.add(SMAX_Event2);
        SVMXC__SVMX_Event__c SMAX_Event3 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.Today(), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-11 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-11 01:00:00') ,
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-11 02:00:00') ,
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXEvent.add(SMAX_Event3);
        insert SVMXEvent;
        

    }

    static testMethod void testAESEvent() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
        e1.SVMXC__Driving_Time_Home__c = 10;
        e1.SVMXC__Overhead_Time_After__c = 0;
        e1.SVMXC__Overhead_Time_Before__c = 0;
        e1.SVMXC__Break_Time_Total__c = 0;
        e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 151200;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,true,true,false,true,lstKeyValue,false,false,null,null);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);

        DCX_AES_EventServiceManager.DCX_UnAssignAssign_Work_Order_To_MultiTech_WS3(String.valueOf(objUser.Id),woids,Tech1.Id,timeZone,lstAESEvents,true,lstKeyValue,null,null);

        
    }

    static testMethod void testAESEvent_1() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
        e1.SVMXC__Driving_Time_Home__c = 10;
        e1.SVMXC__Overhead_Time_After__c = 0;
        e1.SVMXC__Overhead_Time_Before__c = 0;
        e1.SVMXC__Break_Time_Total__c = 0;
        e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 151200;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,false,false,true,false,lstKeyValue,true,true,null,null);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);


        
    }

    static testMethod void testAESEvent_2() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
        e1.SVMXC__Driving_Time_Home__c = 10;
        e1.SVMXC__Overhead_Time_After__c = 0;
        e1.SVMXC__Overhead_Time_Before__c = 0;
        e1.SVMXC__Break_Time_Total__c = 0;
        e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 151200;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,true,false,false,true,lstKeyValue,false,false,null,null);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);


        
    }

static testMethod void testAESEvent1_2() {
        
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
       // e1.SVMXC__Driving_Time_Home__c = 10;
      //  e1.SVMXC__Overhead_Time_After__c = 0;
       // e1.SVMXC__Overhead_Time_Before__c = 0;
      //  e1.SVMXC__Break_Time_Total__c = 0;
      //  e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 151200;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,false,true,false,true,lstKeyValue,false,false,null,null);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);
        
    }

    static testMethod void testAESEvent1() {
    User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
     SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
         DCX_AES_EventServiceManager.DCX_Unassign_Work_Order_WS1(String.valueOf(objUser.Id),woids);
        DCX_AES_EventServiceManager.DCX_Unschedule_Work_Order_WS(String.valueOf(objUser.Id),woids);
        DCX_AES_EventServiceManager.DCX_Unassign_Work_Order_WS(String.valueOf(objUser.Id),woids);
  }

    static testMethod void testAESEvent2() {
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 2'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
     //   e1.SVMXC__Driving_Time_Home__c = 10;
     //   e1.SVMXC__Overhead_Time_After__c = 0;
      //  e1.SVMXC__Overhead_Time_Before__c = 0;
     //   e1.SVMXC__Break_Time_Total__c = 0;
      //  e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 720;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 120;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,'',lsttechId,eventMinDuration,true,true,isOverlappingEnabled,false,lstKeyValue,false,false,null,null);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);
    }

    static testMethod void testAESEvent1_3() {
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 2'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
     //   e1.SVMXC__Driving_Time_Home__c = 10;
     //   e1.SVMXC__Overhead_Time_After__c = 0;
      //  e1.SVMXC__Overhead_Time_Before__c = 0;
     //   e1.SVMXC__Break_Time_Total__c = 0;
      //  e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 720;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 120;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,'',lsttechId,eventMinDuration,false,false,true,false,lstKeyValue,false,false,null,null);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);
    }

    static testMethod void testAESEvent1_6() {
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 2'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
        e1.SVMXC__Driving_Time_Home__c = 10;
        e1.SVMXC__Overhead_Time_After__c = 0;
       e1.SVMXC__Overhead_Time_Before__c = 0;
        e1.SVMXC__Break_Time_Total__c = 0;
       e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 720;
        lstAESEvents.add(e1);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 120;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        List<string> Assigned  = new List<string>();
        Assigned.add('Assigned');
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,'',lsttechId,eventMinDuration,false,false,false,false,lstKeyValue,false,false,null,Assigned);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);
    }

    static testMethod void testAESEvent1_4() {
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 2'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
     //   e1.SVMXC__Driving_Time_Home__c = 10;
     //   e1.SVMXC__Overhead_Time_After__c = 0;
      //  e1.SVMXC__Overhead_Time_Before__c = 0;
     //   e1.SVMXC__Break_Time_Total__c = 0;
      //  e1.SVMXC__Driving_Time__c = 10;   
        e1.SVMXC__Service_Duration__c = 720;
        lstAESEvents.add(e1);
        
        String timeZone = '';
        Integer eventMinDuration = 120;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        List<string> Assigned  = new List <string>();
        Assigned.add('Assigned');
        
        DCX_AES_EventServiceManager.AES_Request req1 = new DCX_AES_EventServiceManager.AES_Request();
        DCX_AES_EventServiceManager.AES_Request req;
        DCX_AES_EventServiceManager.AES_Response resp = new DCX_AES_EventServiceManager.AES_Response();

        req = new DCX_AES_EventServiceManager.AES_Request(String.valueOf(objUser.Id),lstAESEvents,'',lsttechId,eventMinDuration,true,false,false,true,lstKeyValue,true,true,null,Assigned);
        DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);
    }

    static testMethod void testAESEvent1_8() {
        list<Event> lstObjSFEvents = new list<Event>();
        Datetime t = system.now();
        List<DCX_EventServiceManager.eventLine> evLines = new List<DCX_EventServiceManager.eventLine>();
        DCX_EventServiceManager.eventLine evLine = new DCX_EventServiceManager.eventLine();
        List<String> techIds = new List<String>();
        List<String> lsttechId = new List<String>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 2'];
        lsttechId.add(String.valueOf(Tech1.Id));
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];
        List<String> woids = new List<String>();
        woids.add(objWorkOrder.Id);
        Date date1 = System.today();
        
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCX_Wrapper.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCX_Wrapper.SVMX_StringMap datTest1 = new DCX_Wrapper.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCX_Wrapper.SVMX_StringMap datTest2 = new DCX_Wrapper.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e1 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e1.IsAllDayEvent = false;
        e1.SVMXC__Service_Duration__c = 720;
        lstAESEvents.add(e1);
        String timeZone = 'Asia/Kolkata';
                DCX_AES_EventServiceManager.DCX_Assign_Work_Order_To_MultiTech_WS2(String.valueOf(objUser.Id),woids,Tech1.Id,timeZone,lstAESEvents,true,lstKeyValue,null,null);

        
    }

    static testMethod void testAESEvent1_9() {

      SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM1'];
        SVMXC__Service_Group_Members__c Tech1 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'TECH 1'];
        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Group_Member__c = :Tech1.Id];

        List<String> woids = new List<String> ();
        woids.add(objWorkOrder.Id);
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
Datetime t = system.today();
String timeZone = 'Asia/Kolkata';
 User objUser = new User();
objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
         List<Event> SFEvent = new List<Event>();
       /* Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-9'),
                                StartDateTime = Datetime.valueOf('2010-02-9 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-9 01:00:00'), IsAllDayEvent =true,
                                DurationInMinutes = 1440, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
SFEvent.add(e1);
SFEvent.add(e2);
SFEvent.add(e3);*/
Event e1 = new Event(ActivityDate = Date.Today(),
                             StartDateTime = t,
                             ActivityDateTime = t, 
                             EndDateTime = system.now().addHours(1),
                             DurationInMinutes = 60, Subject = 'test',// OwnerId = objTechnician1.Id, 
                             WhatId=objWorkOrder.Id, Description='Test Desc',
                             SVMXC__Service_Duration__c = 60);
        SFEvent.add(e1);
      //insert SFEvent;


        List<SVMXC__SVMX_Event__c>  svmxEvents = [Select SVMXC__DurationInMinutes__c,SVMXC__IsAllDayEvent__c,SVMXC__StartDateTime__c from SVMXC__SVMX_Event__c];
        List<Event>  ssfEvents = [Select IsAllDayEvent,StartDateTime,DurationInMinutes from Event];

        DCX_AES_EventServiceManager.mergeSFSVMXEvents(ssfEvents,svmxEvents,timeZone);

          DCX_AES_EventServiceManager.DCX_Unschedule_Work_Order_WS(String.valueOf(objUser.Id),woids);
          List<String> woi = new List<String>();

         // DCX_AES_EventServiceManager.DCX_Unschedule_Work_Order_WS(String.valueOf(objUser.Id),woi);


   //     DCX_AES_EventServiceManager.DCX_AES_Create_Events_WS(req);

    }

   static testMethod void testAESEvent1_10() {
                List<datetime> dateT = new List<datetime>();
                dateT.add(system.today());
                Datetime t1 =system.today();
                Datetime t2 = t1.addDays(1);
                dateT.add(t2);
                DCX_AES_EventServiceManager.StartEndTime stTime = new DCX_AES_EventServiceManager.StartEndTime();
                Datetime t = system.today();
                t = t.addDays(7); 
                stTime.startTime = system.today();
                stTime.endTime =  t;
                 DCX_AES_EventServiceManager.StartEndTime stTime1 = new DCX_AES_EventServiceManager.StartEndTime(system.today(),t);
                  List<DCX_AES_EventServiceManager.StartEndTime> sDatetime = new List<DCX_AES_EventServiceManager.StartEndTime>();
              sDatetime.add(stTime1);
              DCX_AES_EventServiceManager.splitOnExistingEvents(dateT,sDatetime);

              Datetime todayD = system.today();
              Datetime todayD1 = todayD.addDays(2);
              List<DateTime> time1 =  new List<DateTime>();
              List<DateTime> time2 =  new List<DateTime>();
              time1.add(todayD);
               time1.add(todayD1);

                Datetime todayY = system.today();
              Datetime todayY1 = todayD.addDays(4);

              time2.add(todayY);
               time2.add(todayY1);

              DCX_AES_EventServiceManager.overlappingTimeSlots(time2,time1);
              
              

    }


    
}