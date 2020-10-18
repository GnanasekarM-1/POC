@isTest (SeeAllData=false)

private class DCX_UserSettingMigrator_UT {
    @testSetup static void setup() {
        User u = [SELECT id,LocaleSidKey from User where id = :UserInfo.getUserId()];
        String userXML = '';
        Set<String> setTechFields = new Set<String>();
        User DispatcherRecord = [Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id =:Userinfo.getUserId()];

        userXML = DispatcherRecord.SVMXC__Dispatch_Console_Settings__c;
        if(userXML == null || userXML.length() == 0)
            userXML = DCON_Service_Org_WS.getDefaultUserSettings(); 
        DCON_Configuration_WS.DCON_Update_User_Settings_WS(u.Id,userXML);
    }
    
     static testMethod void testXMLtoJSON() {
        DCX_UserSettingMigrator.DCX_MigrationRequest a = new DCX_UserSettingMigrator.DCX_MigrationRequest();
        a.city = 'Bengaluru';
        system.debug(a);
        DCX_UserSettingMigrator.migrateAll();
     }
}