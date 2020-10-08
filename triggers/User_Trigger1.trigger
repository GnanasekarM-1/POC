trigger User_Trigger1 on User (after insert, after update) {
        
        //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
        if(!CONF_TriggerControl.isTriggerEnabled('User',userInfo.getUserId(),userInfo.getProfileId())){
            System.debug(Logginglevel.WARN,'User_Trigger1 execution is skipped.');
            return;
        } 
        //BAC - 1909  START
        SVMXC.COMM_Utils_ManageSettings objCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = new Map<String, String>();
        Boolean isUserLicenseAssignmentRequired = false;
        //Defect fixed 043247
        if(Test.isRunningTest())
        {
            svmxSettingList.put('SET001', 'true');
            svmxSettingList.put('SET002', 'true');
            svmxSettingList.put('SET003', 'true');
            svmxSettingList.put('SET004', 'true');
        }else
        {
            //Fixed defect 043991:Added exception handling code
           try{
            svmxSettingList = objCommSettings.SVMX_getSettingList('USR001');       
          }catch(Exception e) {
             System.debug('Exception occurred in User_Trigger1 : ' + e.getMessage());
             svmxSettingList =null;
          } 
        }
        //If User trigger logic execute only when SET001 = true 
        if(svmxSettingList != null && svmxSettingList.containsKey('SET001') && svmxSettingList.get('SET001') != null) {
        
            isUserLicenseAssignmentRequired = boolean.valueOf(svmxSettingList.get('SET001'));
            if(isUserLicenseAssignmentRequired)
            {
                List<User> lstNewUser = new List<USer>();
                List<User> lstoldUser = new List<USer>();
                Integer i =0;
                
                for(User newUser: Trigger.new)
                {
                   // User oldUser =  (Trigger.old != null && Trigger.old.size() > 0) ? Trigger.old[i] : null;
                    User oldUser = (trigger.oldMap != null && trigger.oldMap.containsKey(newUser.id))?  trigger.oldMap.get(newUser.id) : null;
                    //Condition exceute if 1. new user is marked true 2. if exciting user marked true or false 3. User licensce chnaged
                    if((newUser.SVMXC__ServiceMax_User__c != null && newUser.SVMXC__ServiceMax_User__c) ||
                       (Trigger.isUpdate && newUser.SVMXC__ServiceMax_User__c != oldUser.SVMXC__ServiceMax_User__c && !newUser.SVMXC__ServiceMax_User__c))
                       {
                           //BAC - 1909 : Added below condition,this condition removed from user licence method
                            if(oldUser == null || oldUser.SVMXC__ServiceMax_User__c != newUser.SVMXC__ServiceMax_User__c || oldUser.isActive != newUser.isActive || USER_LicenseAssignment.isUserLicenseChanged(oldUser, newUser) == true)
                            {
                                lstNewUser.add(newUser);
                                lstoldUser.add(oldUser);
                            }
                       }
                      //i = i + 1;
                }
                
                if(!lstNewUser.isEmpty())
                {   
                    //USER_LicenseAssignment objLicenseAssignment = new USER_LicenseAssignment(svmxSettingList);
                    //Excluding user which is marked false at insertion time
                    USER_LicenseAssignment objLicenseAssignment = new USER_LicenseAssignment(svmxSettingList);
                    objLicenseAssignment.assignUserPermissionsLicense(lstNewUser,lstOldUser);
                    //svmxSettingList = null;
                }
                
            }
        }
        //BAC - 1909 END
    /*
    if(Trigger.New != null && Trigger.New.size() > 0) {
        
        List<User> lstNewUser = Trigger.New;
        List<User> lstOldUser = Trigger.Old;
        
        for(integer i = 0; i < lstNewUser.size(); i++) {
            try {           
                User oldUser = (lstOldUser != null && lstOldUser.size() > 0) ? lstOldUser[i] : null;
                
                if((lstNewUser[i].SVMXC__ServiceMax_User__c != null && lstNewUser[i].SVMXC__ServiceMax_User__c) || 
                   (!Trigger.isInsert && lstNewUser[i].SVMXC__ServiceMax_User__c != lstOldUser[i].SVMXC__ServiceMax_User__c && 
                    !lstNewUser[i].SVMXC__ServiceMax_User__c)) {
                    System.debug('User : '+ Trigger.New.get(i).Alias + ' : is a servicemax User. Executing User_Trigger1');
                    Boolean isUserLicenseAssignmentRequired = true;
                    SVMXC.COMM_Utils_ManageSettings objCommSettings = new SVMXC.COMM_Utils_ManageSettings();
                    Map<String, String> svmxSettingListUSR001 = new Map<String, String>();
                    List<string> lstSubModules = new List<string>{'USR001'};
                    Map<string, Map<String, String>> AllsvmxSettingList = new Map<string, Map<String, String>>();
                    AllsvmxSettingList = objCommSettings.SVMX_getSettingList(lstSubModules);
                    
                    if(AllsvmxSettingList.containsKey('USR001') && AllsvmxSettingList.get('USR001') != null)
                        svmxSettingListUSR001 = AllsvmxSettingList.get('USR001');
                        
                    if(svmxSettingListUSR001!= null && svmxSettingListUSR001.containsKey('SET001') && svmxSettingListUSR001.get('SET001') != null) {
                        isUserLicenseAssignmentRequired = boolean.valueOf(svmxSettingListUSR001.get('SET001'));
                    }
                    System.debug('isUserLicenseAssignmentRequired: ' + isUserLicenseAssignmentRequired + '; Setting values: ' + svmxSettingListUSR001);
                    
                    if(isUserLicenseAssignmentRequired) {
                        USER_LicenseAssignment  objLicenseAssignment = new USER_LicenseAssignment(svmxSettingListUSR001);
                        objLicenseAssignment.assignUserPermissionsLicense(Trigger.new, Trigger.old);
                    }
                }
            } Catch(Exception e) {
                  System.debug('Stack Trace' + e.getStackTraceString());
                  System.debug('Exception while executing User_Trigger1' + e.getMessage());   
            }    
        }
    }   */       
}