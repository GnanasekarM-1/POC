@isTest (seeAllData = true)
private class USER_LicenseAssignment_UT
{

    static testMethod void User_LicenseAssignment_UT_Test()
    {
        List<User> lstUser = new List<User>();
        List<User> lstUser3 = new List<User>();
        List<User> lstUser4 = new List<User>();
        
       Map<String, String> svmxSettingList = new Map<String, String>();
        svmxSettingList.put('SET001', 'true');
        svmxSettingList.put('SET002', 'true');
        svmxSettingList.put('SET003', 'true');
        svmxSettingList.put('SET004', 'true');
        User_LicenseAssignment objLicenseAssignment = new User_LicenseAssignment(svmxSettingList);
        objLicenseAssignment.getTAG001();
        objLicenseAssignment.getTAG002();
        objLicenseAssignment.getTAG003();
        objLicenseAssignment.getTAG004();
        objLicenseAssignment.getTAG005();
        objLicenseAssignment.getTAG006();
        
    Profile thisProfile = [SELECT Id, Name, UserLicenseId, UserLicense.Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        User thisUser = [SELECT Id,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,TimeZoneSidKey,SVMXC__ServiceMax_User__c,isActive, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
        thisUser.SVMXC__ServiceMax_User__c = true;
    
        Profile thisProfile2 = [SELECT Id, Name, UserLicenseId, UserLicense.Name FROM Profile where name = 'Standard User'];
      User user3 = new User();
        user3.IsActive = true;
        user3.SVMXC__ServiceMax_User__c = true;
        user3.ProfileId =thisProfile2.id;
        user3.Username = 'TEST17878788788877878@abc.com';
        user3.Alias = 'TESTUSE';
        user3.LastName = 'TESTLASTNAME';
        user3.Email = 'TEST@abc.com';
        user3.CommunityNickname ='TESTU';
        user3.TimeZoneSidKey =thisUser.TimeZoneSidKey;
        user3.LocaleSidKey = thisUser.LocaleSidKey;
        user3.EmailEncodingKey = thisuser.EmailEncodingKey;
        user3.LanguageLocaleKey = thisuser.LanguageLocaleKey;
        lstUser4.add(user3);
        //insert lstUser4;
        objLicenseAssignment.assignUserPermissionsLicense(lstUser4, null);
        
        
        
    User thisUser1 = [SELECT Id,SVMXC__ServiceMax_User__c, ProfileId FROM User WHERE ID !=: thisUser.id LIMIT 1];
    if(thisUser1 != null)
    {
      thisUser1.SVMXC__ServiceMax_User__c = true;
      lstUser.add(thisUser1);
    }
    lstUser.add(thisUser);
    //update lstUser;
    objLicenseAssignment.assignUserPermissionsLicense(lstUser, null);
        
        thisUser.SVMXC__ServiceMax_User__c = false;
        
        //update thisUser;
        lstUser3.add(thisUser);
        
        objLicenseAssignment.assignUserPermissionsLicense(lstUser3, null);
       
        /*Profile thisProfile1 = [SELECT Id, Name, UserLicenseId, UserLicense.Name FROM Profile WHERE UserLicense.Name = 'SALESFORCE PLATFORM' LIMIT 1];
        List<User> user1 = [SELECT Id,SVMXC__ServiceMax_User__c,isActive,ProfileId FROM User WHERE ID =: user3.id];
        if(user1 !=null && user1.size()>0)
        {
            user1[0].ProfileId = thisProfile1.id;
            user1[0].SVMXC__ServiceMax_User__c = true;
            user1[0].isActive = true;
            //update user1;
       }*/
      /*List<User> lstuser5 = new List<User>();
      user1[0].SVMXC__ServiceMax_User__c = false;
      user1[0].isActive = false;
      lstuser5.add(user1[0]);  */
      User_LicenseAssignment objLicenseAssignment1 = new User_LicenseAssignment(svmxSettingList);  
      //objLicenseAssignment1.assignUserPermissionsLicense(user1, null);
     // User_LicenseAssignment.isUserLicenseChanged(user1[0],user1[0]);
    }
}