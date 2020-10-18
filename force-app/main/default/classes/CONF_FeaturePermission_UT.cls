@isTest(seeAllData = false)
public  class CONF_FeaturePermission_UT
{
    static testMethod void getMetadata_test()
    {
        CONF_FeaturePermission fPermission = new CONF_FeaturePermission();
        insertSvmxConfigData();
         CONF_FeaturePermission.JsrGetMetadata('');
    }
    static testMethod void getUserData_test()
    {
        CONF_FeaturePermission fPermission = new CONF_FeaturePermission();
         String profileId = insertSvmxConfigData();
         CONF_FeaturePermission.JsrGetUserData('{"profileId":"'+profileId+'","searchValue":""}');

   


    }
    static testMethod void saveData_delete_test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert_feature_permission1(usr.Id);
        String saveRequest = '[{"userName":"","isChecklistEnabled":true,"name":"","userId":'+ usr.Id+'}]';
        CONF_FeaturePermission.JsrSaveData(saveRequest);
    }
    static testMethod void saveData_add_test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert_feature_permission(usr.Id);
        String saveRequest = '[{"userName":"","isChecklistEnabled":false,"name":"","userId":'+ usr.Id+'}]';
        CONF_FeaturePermission.JsrSaveData(saveRequest);
    }
    static String insert_UserData(){

        User usr = new User();
        insert usr;
        return usr.Id;
    }
    static String insertSvmxConfigData(){
        
        RecordType rType = [SELECT Id FROM RecordType WHERE Name = 'Configuration Profile'];
        SVMXC__ServiceMax_Config_Data__c svmxConfig = new SVMXC__ServiceMax_Config_Data__c();
        svmxConfig.SVMXC__PROFILE_NAME__c = 'svmx profile';
        svmxConfig.SVMXC__Active__c = true;
        svmxConfig.SVMXC__CONFIGURATION_TYPE__c = 'Group';
        svmxConfig.RecordtypeId = rType.Id;
        insert svmxConfig;
       return svmxConfig.Id; 

    }

    static String insert_feature_permission(String uId){
        String afId = insert_application_feature();
        SVMXC__SM_Feature_Permission__c fp = new SVMXC__SM_Feature_Permission__c();
        fp.SVMXC__SM_Application_Feature__c = afId;
        fp.SVMXC__SM_User__c = uId;
        insert fp;
        return fp.Id;
    }

    static String insert_feature_permission1(String uId){
        SVMXC__SM_Feature_Permission__c fp = new SVMXC__SM_Feature_Permission__c();
        fp.SVMXC__SM_User__c = uId;
        insert fp;
        return fp.Id;
    }
    static String insert_application_feature(){
        SVMXC__SM_Application_Feature__c af = new SVMXC__SM_Application_Feature__c();
        af.SVMXC__SM_Feature_Description__c = '';
        af.SVMXC__SM_Feature_Name__c = 'CHECKLIST';
        insert af;
        return af.Id;
    }
}