@isTest
public class DCX_Utils_UT {

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
  }
  @isTest static void getDateTimeInTimezone_test() {
    DCX_Utils utils = new DCX_Utils();
    utils.getDateTimeInTimezone(system.today(), Time.newInstance(4, 2, 3, 4), 'Asia/Kolkata');
  }

  @isTest static void SVMX_getAllFieldMap_test() {
    Schema.SObjectType objTSVMXEvent = SVMX_Event__c.sObjectType;
    Map<String,Schema.SObjectField> fldMap = objTSVMXEvent.getDescribe().fields.getMap();
    DCX_Utils utils = new DCX_Utils();
    utils.SVMX_getAllFieldMap(fldMap);
  }

  @isTest static void SVMX_getGlobalReferenceMap_test() {
    DCX_Utils utils = new DCX_Utils();
    utils.SVMX_getGlobalReferenceMap();
  }

  @isTest static void SVMX_getReferenceFields_test() {
    DCX_Utils utils = new DCX_Utils();
    Schema.SObjectType objTSVMXEvent = SVMXC__Service_Order__c.sObjectType;
    Map<String,Schema.SObjectField> fldMap = objTSVMXEvent.getDescribe().fields.getMap();
    utils.SVMX_getReferenceFields(fldMap, true);
  }

  @isTest static void getBHStartEndDateTime_test() {
    // Get the default business hours
    DCX_Utils utils = new DCX_Utils();
    BusinessHours bh = [SELECT CreatedById,CreatedDate,FridayEndTime,FridayStartTime,Id,IsActive,LastModifiedById,LastModifiedDate,LastViewedDate,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,SystemModstamp,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
    utils.getBHStartEndDateTime('Asia/Kolkata', system.today(), bh);
  }

  @isTest static void doTZConversion_test() {
    DCX_Utils.doTZConversion(DateTime.now(), 'Asia/Kolkata', 'Pacific/Auckland');
  }

  @isTest static void getConfiguredEventUpdateFieldsMap() {
    DCX_Utils.getConfiguredEventUpdateFieldsMap();
    DCX_Utils.ExpertisevalidationClause('test');
    DCX_Utils.getConfiguredEventFields();
    try{
      DCX_Utils.getConfiguredEventUpdateFieldsMap('1234');
    }
    catch(exception e) {}
  }
  

}