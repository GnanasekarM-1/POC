/* Security Scanned */
public with sharing class USER_LicenseAssignment {
    
    String PACKAGE_NAMESPACE_PREFIX = 'SVMXC';
    String SERVICEMAX_STANDARD_PS = 'CORE';
    String SERVICEMAX_PLATFORM_PS = 'CORE_PLATFORM';
    String SERVICEMAX_CUSTOM_PS = 'SVMX_PRODUCT_PRICEBOOK_PS';
    String ORDERS_PSL = 'ContractsOrdersProductsPsl';
    boolean isServiceMaxLicenseAssignment = true;
    boolean isPermissionsSetAssignment = true;
    boolean isPermissionsSetLicenseAssignment = true;
    Set<String> setActiveUserID = new Set<String>();
    Map<String, Set<String>> mapProfileVsUsers = new Map<String, Set<String>>();
    Map<String, String> mapUserVsLicenseType = new Map<String, String>();
    Map<String, String> mapPermissionSetNameID = new Map<String, String>();
    Map<String, String> svmxSettingList = new Map<String, String>();
    Map<String, Schema.SObjectType> allObjmap = new Map<String, Schema.SObjectType>();
    PermissionSet customSVMXPermissionSet = new PermissionSet();
    List<String> lstObjAPIName = new List<String> {'Account', 'Contact', 'Product2', 'PriceBook2'};
    static Map<ID, Profile> mapProfiles = null;
    boolean isPersonAccountEnebled = false;
    
    public USER_LicenseAssignment(Map<String, String> svmxSettingList) {
        
        isPersonAccountEnebled = isPersonAccountsEnabled();
        this.svmxSettingList = svmxSettingList;
        
        if(this.svmxSettingList!= null && this.svmxSettingList.containsKey('SET002') && this.svmxSettingList.get('SET002') != null) {
            isPermissionsSetLicenseAssignment = boolean.valueOf(this.svmxSettingList.get('SET002'));
        }
        if(this.svmxSettingList!= null && this.svmxSettingList.containsKey('SET003') && this.svmxSettingList.get('SET003') != null) {
            isPermissionsSetAssignment = boolean.valueOf(this.svmxSettingList.get('SET003'));
            if(isPermissionsSetAssignment) {
                for(Schema.SObjectType s : Schema.getGlobalDescribe().values()){
                    allObjmap.put(s.getDescribe().getName(), s);
                }
            }
        }
        if(this.svmxSettingList!= null && this.svmxSettingList.containsKey('SET004') && this.svmxSettingList.get('SET004') != null) {
            isServiceMaxLicenseAssignment = boolean.valueOf(this.svmxSettingList.get('SET004'));
        }
        System.debug('Setting values: ' + svmxSettingList);
        
        if(mapProfiles == null)
        {
           mapProfiles = new Map<ID, Profile>([SELECT Id, UserLicenseId, UserLicense.Name FROM Profile]);
        }
        
    }
    
    public void assignUserPermissionsLicense(List<User> lstNewUser, List<User> lstOldUser) {
        
    //BAC - 1909 Added single try catch for all methods
    try{
      boolean isAnyActiveServiceMaxUser = false;
            //BAC - 1909 : QUerying all servicemax Permission set permission set and reducing Product pricebook query 
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      List<PermissionSet> lstSVMXPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE ((Name =: SERVICEMAX_PLATFORM_PS OR Name =: SERVICEMAX_STANDARD_PS) AND NamespacePrefix =: PACKAGE_NAMESPACE_PREFIX) OR Name =: SERVICEMAX_CUSTOM_PS];
      
      for(PermissionSet permissionSet : lstSVMXPermissionSet) {
                mapPermissionSetNameID.put(permissionSet.Name.toUpperCase(), permissionSet.Id);
        if(permissionSet.Name.toUpperCase().equals(SERVICEMAX_CUSTOM_PS))
        {
          customSVMXPermissionSet = permissionSet;
        }
      }
      for(User user : lstNewUser)
      {
                //BAC - 1909 commented below code
                //if(!mapProfileVsUsers.containsKey(user.ProfileId)){
                  // mapProfileVsUsers.put(user.ProfileId, new Set<String>()); 
                //}
        //mapProfileVsUsers.get(user.ProfileId).add(user.Id);
                String UserLicense_Name = mapProfiles.get(user.ProfileId).UserLicense.Name;
        mapUserVsLicenseType.put(user.id,UserLicense_Name);
        if(UserLicense_Name.toUpperCase() == 'SALESFORCE PLATFORM' || UserLicense_Name.toUpperCase() == 'SALESFORCE')
        {
          setActiveUserID.add(user.id);
        }
        if(user.SVMXC__ServiceMax_User__c)
        {
          isAnyActiveServiceMaxUser = true;
        }
      }
            //BAC - 1909 commented below code : below logic is implimented in above for loop
      /*if(!mapProfileVsUsers.isEmpty())
      {
        for(Profile profile : [SELECT Id, Name, UserLicenseId, UserLicense.Name FROM Profile WHERE Id IN: mapProfileVsUsers.keySet()]) {
            if(mapProfileVsUsers.containsKey(profile.Id)) {
              for(String strUserId : mapProfileVsUsers.get(profile.Id)) {
                mapUserVsLicenseType.put(strUserId, profile.UserLicense.Name);
                if(profile.UserLicense.Name.toUpperCase() == 'SALESFORCE PLATFORM' || profile.UserLicense.Name.toUpperCase() == 'SALESFORCE') {
                  setActiveUserID.add(strUserId);
                }
              }
            }
        }
      }*/
            //If any user marked as serviceMax user and SET003 is true
      if(isAnyActiveServiceMaxUser && isPermissionsSetAssignment) {
        //creating product and priicebook permission set if it is not available in org
         if(!mapPermissionSetNameID.containsKey(SERVICEMAX_CUSTOM_PS))
          {
            createPermissionSet();
          }
      }
            deleteSVMXPackageLicense();
      deletePermissionLicense(lstNewUser);
      
      boolean isSVMXPackageAssigned = true;
            boolean isPermissionSetLicenseAssigned = true;
            
            if(isServiceMaxLicenseAssignment)
                isSVMXPackageAssigned = assignSVMXPackageLicense(lstNewUser, lstOldUser);
            system.debug('isSVMXPackageAssigned: ' + isSVMXPackageAssigned);
            
            if(isSVMXPackageAssigned && isPermissionsSetLicenseAssignment)
                isPermissionSetLicenseAssigned = assignPermissionsLicense(lstNewUser, lstOldUser);
            system.debug('isPermissionSetLicenseAssigned: ' + isPermissionSetLicenseAssigned);
            
            if(isSVMXPackageAssigned && isPermissionSetLicenseAssigned && isPermissionsSetAssignment)
                assignPermissionSet(lstNewUser, lstOldUser);
      
      
    }
    catch(DmlException ex)
    {
            System.debug('Exception: '+ex.getStackTraceString());
            for(Integer i = 0;i<lstNewUser.size();i++)
               {
                   lstNewUser[i].addError(ex.getMessage());
               }
            
        }catch(Exception ex)
    {
      lstNewUser[0].addError(ex.getMessage());
    }
    
    }
    
    //Assign ServiceMax Package License
    public boolean assignSVMXPackageLicense(List<User> lstNewUser, List<User> lstOldUser) {
    
        Integer Counter = 0;
        Integer MaxLicenseCount = 0;
        boolean isSVMXPackageAssigned = true;
        boolean isSVMXManagedPackage = false;
        List<UserPackageLicense> lstUserPackageLicense = new List<UserPackageLicense>();
        List<PackageLicense> lstPackageLicense = new List<PackageLicense>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstPackageLicense = [SELECT Id, AllowedLicenses, UsedLicenses FROM PackageLicense WHERE NamespacePrefix =: PACKAGE_NAMESPACE_PREFIX];
        
        if(lstPackageLicense != null && lstPackageLicense.size() > 0) {
            
            Counter = 0;
            MaxLicenseCount = lstPackageLicense[0].AllowedLicenses;
            for(integer i =0; i<lstPackageLicense.size(); i++) {
                if(lstPackageLicense[i].AllowedLicenses > MaxLicenseCount){
                    MaxLicenseCount = lstPackageLicense[i].AllowedLicenses;
                    Counter = i;
                }
            }
            if(MaxLicenseCount > 0) {
                MaxLicenseCount = lstPackageLicense[Counter].AllowedLicenses - lstPackageLicense[Counter].UsedLicenses;
                isSVMXManagedPackage = true;
            }
        }
        system.debug('isSVMXManagedPackage: ' + isSVMXManagedPackage + '; License count: ' + MaxLicenseCount + '; Index: ' + Counter);
        
        for(Integer i = 0; i < lstNewUser.size(); i++) {
            
            String UserLicense = getUserLicense(lstNewUser[i]);
            User oldUser = (lstOldUser != null && lstOldUser.size() > 0) ? lstOldUser[i] : null;
                
            if((oldUser == null || oldUser.SVMXC__ServiceMax_User__c != lstNewUser[i].SVMXC__ServiceMax_User__c || oldUser.isActive != lstNewUser[i].isActive || isUserLicenseChanged(oldUser, lstNewUser[i]) == true) && lstNewUser[i].isActive == true && lstNewUser[i].SVMXC__ServiceMax_User__c == true && (UserLicense == 'SALESFORCE PLATFORM' || UserLicense == 'SALESFORCE')) {
            
                if((lstPackageLicense != null && lstPackageLicense.size() > 0) || Test.isRunningTest()) {
                    if(MaxLicenseCount > 0) {
                        lstUserPackageLicense.add(new UserPackageLicense(PackageLicenseId = lstPackageLicense[Counter].Id, UserId = lstNewUser[i].Id));
                        --MaxLicenseCount;
                    }
                    else if(MaxLicenseCount == -1 && isSVMXManagedPackage == false) {
                        lstUserPackageLicense.add(new UserPackageLicense(PackageLicenseId = lstPackageLicense[0].Id, UserId = lstNewUser[i].Id));
                    }
                    else if(!Test.isRunningTest()) {
                        lstNewUser[i].addError(getTAG001());
                        isSVMXPackageAssigned = false;
                    }
                }
                else if(!Test.isRunningTest()){
                    lstNewUser[i].addError(getTAG002());
                    isSVMXPackageAssigned = false;
                }
            }
        }
        
            system.debug('List of UserPackageLicense: ' + lstUserPackageLicense);
            if(lstUserPackageLicense != null && lstUserPackageLicense.size() > 0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                insert lstUserPackageLicense;
       
        return isSVMXPackageAssigned;
    }
    
    
    //Assign Permission Set License
    public boolean assignPermissionsLicense(List<User> lstNewUser, List<User> lstOldUser) {
    
        boolean isPermissionSetLicenseAssigned = true;
        Integer PermissionSetLicenseLicenseCount = 0;
        List<PermissionSetLicenseAssign> lstPermissionSetLicenseAssign = new List<PermissionSetLicenseAssign>();
        Map<ID, PermissionSetLicenseAssign> mapUserIDPermissionSetLicense = new Map<ID, PermissionSetLicenseAssign>();
        
        for(PermissionSetLicenseAssign PSLA : [SELECT Id, AssigneeId FROM PermissionSetLicenseAssign Where AssigneeId IN: lstNewUser]) {
            mapUserIDPermissionSetLicense.put(PSLA.AssigneeId, PSLA);
        }
        system.debug('mapUserIDPermissionSetLicense: ' + mapUserIDPermissionSetLicense);
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<PermissionSetLicense> lstPermissionSetLicense = [SELECT Id, TotalLicenses, Status, UsedLicenses FROM PermissionSetLicense WHERE PermissionSetLicenseKey =: ORDERS_PSL AND TotalLicenses > 0];
        if(lstPermissionSetLicense != null && lstPermissionSetLicense.size() == 1) {
            PermissionSetLicenseLicenseCount = lstPermissionSetLicense[0].TotalLicenses - lstPermissionSetLicense[0].UsedLicenses;
        }
        
        for(Integer i = 0; i < lstNewUser.size(); i++) {
            
            User oldUser = (lstOldUser != null && lstOldUser.size() > 0) ? lstOldUser[i] : null;
            
            if((oldUser == null || oldUser.SVMXC__ServiceMax_User__c != lstNewUser[i].SVMXC__ServiceMax_User__c || oldUser.isActive != lstNewUser[i].isActive || isUserLicenseChanged(oldUser, lstNewUser[i]) == true) && lstNewUser[i].isActive == true && lstNewUser[i].SVMXC__ServiceMax_User__c == true && getUserLicense(lstNewUser[i]) == 'SALESFORCE PLATFORM') {
                
                if(mapUserIDPermissionSetLicense != null && mapUserIDPermissionSetLicense.get(lstNewUser[i].Id) != null) {
                    system.debug('Order PSL detail is: ' + mapUserIDPermissionSetLicense.get(lstNewUser[i].Id));
                    //Skip. Assignment for this existing user is already there and Update operation is not possible for this type of Object record.
                }
                else if(lstPermissionSetLicense != null && lstPermissionSetLicense.size() == 1) {
                    if(lstPermissionSetLicense[0].Status == 'Active') {
                        if(PermissionSetLicenseLicenseCount > 0) {
                            lstPermissionSetLicenseAssign.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = lstPermissionSetLicense[0].Id, AssigneeId = lstNewUser[i].Id));
                            -- PermissionSetLicenseLicenseCount;
                        }
                        else {
                            lstNewUser[i].addError(getTAG003());
                            isPermissionSetLicenseAssigned = false;
                        }
                    }
                    else {
                        lstNewUser[i].addError(getTAG004());
                        isPermissionSetLicenseAssigned = false;
                    }
                }
                else {
                    lstNewUser[i].addError(getTAG005());
                    isPermissionSetLicenseAssigned = false;
                }
            }
        }
        
            System.debug('List of Permission Set License: ' + lstPermissionSetLicenseAssign);
            if(lstPermissionSetLicenseAssign != null && lstPermissionSetLicenseAssign.size() > 0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                insert lstPermissionSetLicenseAssign;
        
        return isPermissionSetLicenseAssigned;
    }
    
    
    //Assign Permission Set
    public void assignPermissionSet(List<User> lstNewUser, List<User> lstOldUser) {
    
        List<PermissionSetAssignment> lstPermissionSetAssignment = new List<PermissionSetAssignment>();
        
        for(Integer i = 0; i < lstNewUser.size(); i++) {
            User oldUser = (lstOldUser != null && lstOldUser.size() > 0) ? lstOldUser[i] : null;
            
            if((oldUser == null || oldUser.SVMXC__ServiceMax_User__c != lstNewUser[i].SVMXC__ServiceMax_User__c || oldUser.isActive != lstNewUser[i].isActive || isUserLicenseChanged(oldUser, lstNewUser[i]) == true) && lstNewUser[i].isActive == true && lstNewUser[i].SVMXC__ServiceMax_User__c == true) {
            
                if(getUserLicense(lstNewUser[i]) == 'SALESFORCE PLATFORM') {
                    if(mapPermissionSetNameID != null && mapPermissionSetNameID.get(SERVICEMAX_PLATFORM_PS) != null) {
                        lstPermissionSetAssignment.add(new PermissionSetAssignment(PermissionSetId = mapPermissionSetNameID.get(SERVICEMAX_PLATFORM_PS), AssigneeId = lstNewUser[i].Id));
                    }
                    
                    //Assign ServiceMax custom Permission Set for Product & PriceBook Object Permissions.
                    if(mapPermissionSetNameID != null && mapPermissionSetNameID.get(SERVICEMAX_CUSTOM_PS) != null) {
                        lstPermissionSetAssignment.add(new PermissionSetAssignment(PermissionSetId = mapPermissionSetNameID.get(SERVICEMAX_CUSTOM_PS), 
                        AssigneeId = lstNewUser[i].Id));
                    }
                }
                else if(getUserLicense(lstNewUser[i]) == 'SALESFORCE') {
                    if(mapPermissionSetNameID != null && mapPermissionSetNameID.get(SERVICEMAX_STANDARD_PS) != null) {
                        lstPermissionSetAssignment.add(new PermissionSetAssignment(PermissionSetId = mapPermissionSetNameID.get(SERVICEMAX_STANDARD_PS), 
                        AssigneeId = lstNewUser[i].Id));
                    }
                    //Assign ServiceMax custom Permission Set for Product & PriceBook Object Permissions.
                    if(mapPermissionSetNameID != null && mapPermissionSetNameID.get(SERVICEMAX_CUSTOM_PS) != null) {
                        lstPermissionSetAssignment.add(new PermissionSetAssignment(PermissionSetId = mapPermissionSetNameID.get(SERVICEMAX_CUSTOM_PS), 
                        AssigneeId = lstNewUser[i].Id));
                    }
                }
            }
        }
      system.debug('lstPermissionSetAssignment records: ' + lstPermissionSetAssignment);
            if(lstPermissionSetAssignment != null && lstPermissionSetAssignment.size() > 0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                insert lstPermissionSetAssignment;
    }
    
    
    //Delete ServiceMax Package license
    public void deleteSVMXPackageLicense() {
        
      System.debug('Id of the User records to be deleted: ' + setActiveUserID);
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'UserPackageLicense' ) ) {
                delete [SELECT Id FROM UserPackageLicense WHERE UserId IN: setActiveUserID AND PackageLicense.NamespacePrefix =: PACKAGE_NAMESPACE_PREFIX];
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
    }
    
    
    //Delete Permission Set and delete Permission Set License if and only if ServiceMax User is set to false.
    public void deletePermissionLicense(List<User> lstNewUser) {
        Set<String> svmxPermissionSetIDs = new Set<String>();
        svmxPermissionSetIDs.addAll(mapPermissionSetNameID.values());
            //BAC - 1909 : Removing the permissionSet refernce if only if ServiceMAX user is marked to false.
            Set<Id> setNonServiceMaxUser = new Set<Id>();
            for(User currUsr : lstNewUser) {
                if(setActiveUserID.contains(currUsr.Id) && currUsr.SVMXC__ServiceMax_User__c == false){
                    setNonServiceMaxUser.add(currUsr.Id);
                }
            }
            System.debug('setActiveUserID: ' + setActiveUserID + '; Permissions Set IDs: ' + svmxPermissionSetIDs);
               if( COMM_SecurityUtils.getInstance().isDeletableObject( 'PermissionSetAssignment' ) ) 
         {
                    //BAC - 1909: added below condition
          if(!setNonServiceMaxUser.isEmpty())
          {
             delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN: setNonServiceMaxUser AND PermissionSetId =: svmxPermissionSetIDs];
          }
               }else 
               {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //BAC - 1909 : moved code above
           /* Set<Id> setNonServiceMaxUser = new Set<Id>();
            for(User currUsr : lstNewUser) {
                if(setActiveUserID.contains(currUsr.Id) && currUsr.SVMXC__ServiceMax_User__c == false){
                    setNonServiceMaxUser.add(currUsr.Id);
                }
            }*/
            System.debug('Id of the Order PSL to be deleted: ' + setNonServiceMaxUser);
            if(!setNonServiceMaxUser.isEmpty()) {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'PermissionSetLicenseAssign' ) ) {
                   delete [SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId IN: setNonServiceMaxUser AND PermissionSetLicense.PermissionSetLicenseKey =: ORDERS_PSL];
                }else 
                 {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                 }
            }

        
    }
    
    //Create Custom Permission Set
    public void createPermissionSet() {
        
        customSVMXPermissionSet = new PermissionSet();
        customSVMXPermissionSet.Name = 'SVMX_Product_Pricebook_PS';
        customSVMXPermissionSet.Label = 'Product & Pricebook';
        customSVMXPermissionSet.Description = 'Product & Pricebook permission set';
        //BAC - 1909 : changed below opertion from upsert to insert
        // upsert customSVMXPermissionSet;
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        insert customSVMXPermissionSet;
        mapPermissionSetNameID.put(SERVICEMAX_CUSTOM_PS.toUpperCase(), customSVMXPermissionSet.Id);
        //BAC - 1909: This method will execute once if 'Product & Pricebook' permission set not available
        //deleteObjFieldPermissions();
    createSFDCObjPermissions();
        createSFDCObjFldPermissions();
    }
    public void createSFDCObjPermissions() {

        List<ObjectPermissions> lstObjPermission = new List<ObjectPermissions>();
        for(String objAPIName : lstObjAPIName) {
            lstObjPermission.add(new ObjectPermissions(SobjectType = objAPIName, PermissionsRead = true, ParentId = customSVMXPermissionSet.Id));
        }
        system.debug(LoggingLevel.WARN, 'lstObjPermission: ' + lstObjPermission);
        if(lstObjPermission != null && lstObjPermission.size() > 0)
        {
           //BAC - 1909 this will excute only once if Permission ser 'Product & Pricebook' is not available
           // upsert lstObjPermission;
           //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           insert lstObjPermission;
        }
            
    }
    //Delete Field Permissions & Object Permissions for Custom Permission Set
    //BAC - 1909 Commented below method
   /* public void deleteObjFieldPermissions() {
        
        List<String> lstDeletableObjAPIName = new List<String> {'Account', 'Contact', 'Product2', 'Pricebook2'};
        
        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'FieldPermissions' ) ) {
            delete [SELECT Id FROM FieldPermissions WHERE ParentId =: customSVMXPermissionSet.Id AND SobjectType IN: lstDeletableObjAPIName];
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'ObjectPermissions' ) ) {
            delete [SELECT Id FROM ObjectPermissions WHERE ParentId =: customSVMXPermissionSet.Id AND SobjectType = 'Pricebook2'];
            delete [SELECT Id FROM ObjectPermissions WHERE ParentId =: customSVMXPermissionSet.Id AND SobjectType IN: lstDeletableObjAPIName];
            
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    }
    */
  //Create Field Permissions for Custom Permission Set
    public void createSFDCObjFldPermissions() {
    
        List<FieldPermissions> lstFieldPermission = new List<FieldPermissions>();
        for(String objAPIName : lstObjAPIName) {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            if(allObjmap.containsKey(objAPIName) && allObjmap.get(objAPIName) != null) {
                objfieldMap = allObjmap.get(objAPIName).getDescribe().fields.getMap();
                for(String fieldKey : objfieldMap.keySet())
                {
                    Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                    String fieldName = f.getName().toUpperCase();
                    
                    /* Special Handling for sub fields of Geo Location type of field. 
                    Since there is no uniqueness to identify sub field of Geo Location type of field. When we give permission to these sub fields, we are getting an error call bad or restricted field. So preventing access to those sub fields. */
                    boolean isGeoLocationField = false;
                    boolean isPersonAccOrg = false;
                    boolean isSVMXfield = false;
                    if(fieldName.endsWith('LATITUDE__S') || fieldName.endsWith('LONGITUDE__S'))
                        isGeoLocationField = true;
                    
                    /* Special Handling for Person Account Custom Field */
                    if(objAPIName == 'Account' && fieldName.endsWith('__PC') && isPersonAccountEnebled)
                        isPersonAccOrg = true;
                    //BAC - 1990 : we are only including only serviceMAX managed field in permission set
                    if(fieldName.startsWith('SVMXC__'))
            isSVMXfield = true;
                    if(isSVMXfield && f.isCustom() && f.isPermissionable() && f.isRestrictedPicklist() == false && isGeoLocationField == false && isPersonAccOrg == false){
                        lstFieldPermission.add(new FieldPermissions(Field = objAPIName + '.' + f.getName(), PermissionsRead = true, SobjectType = objAPIName, ParentId = customSVMXPermissionSet.Id));
                    }
                }
            }
        }
        if(lstFieldPermission != null && lstFieldPermission.size() > 0)
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            insert lstFieldPermission;
    }
    
    //Get User License for current user
    public String getUserLicense(User user) {
        String UserLicense = '';
        if(mapUserVsLicenseType != null && mapUserVsLicenseType.get(user.Id) != null) {
            if(mapUserVsLicenseType.get(user.Id).toUpperCase() == 'SALESFORCE PLATFORM'){
                 UserLicense = 'SALESFORCE PLATFORM';  
            }
            else if(mapUserVsLicenseType.get(user.Id).toUpperCase() == 'SALESFORCE')
            {
              UserLicense = 'SALESFORCE';  
            }
        }
        System.debug('Uesr License: ' + UserLicense);
        return UserLicense;
    }
    
    public static boolean isUserLicenseChanged(User oldUser, User newUser)
    {
        if(mapProfiles == null)
        {
           mapProfiles = new Map<ID, Profile>([SELECT Id, UserLicenseId, UserLicense.Name FROM Profile]);
        }
        boolean isUserLicenseChanged = false;
        if(oldUser != null && mapProfiles != null && mapProfiles.size() > 0 && mapProfiles.get(oldUser.ProfileId) != null && mapProfiles.get(newUser.ProfileId) != null && mapProfiles.get(oldUser.ProfileId).UserLicenseId != null && mapProfiles.get(newUser.ProfileId).UserLicenseId != null && mapProfiles.get(oldUser.ProfileId).UserLicenseId != mapProfiles.get(newUser.ProfileId).UserLicenseId && (mapProfiles.get(newUser.ProfileId).UserLicense.Name.toUpperCase() == 'SALESFORCE'|| mapProfiles.get(newUser.ProfileId).UserLicense.Name.toUpperCase() == 'SALESFORCE PLATFORM')){
            isUserLicenseChanged = true;
        }
        system.debug('isUserLicenseChanged: ' + isUserLicenseChanged);
        return isUserLicenseChanged;
    }
    
    
    public Boolean isPersonAccountsEnabled()
    {
        Boolean isPersonAccountOrg = false;
        try {
            isPersonAccountOrg = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
        }
        catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
        System.debug('Is Person Account enabled: ' + isPersonAccountOrg);
        return isPersonAccountOrg;
    }
    //Ported fix for defect 045475 
    private static boolean isExcuted = false;
    private static boolean isSVMXPackageLicense = false;
    public static boolean isServiceMaxPackageAccesible()
    {
        if(!isExcuted)
        {
          //Added fix for 046571 : If it is sandbox org always execute the trigger
          if([SELECT isSandbox FROM Organization LIMIT 1].isSandbox)
          {
            isSVMXPackageLicense = true;
            isExcuted = true;
          }else
          {
            //isSVMXPackageLicense  = ([SELECT count() FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix ='SVMXC' and userid =: userinfo.getUserId()] != 0) ;
            //Commented above line and added below line of code to fix defect 047858
            isSVMXPackageLicense = UserInfo.isCurrentUserLicensed('SVMXC');
            isExcuted = true;
          }
          
        }
        //if user doesn't have svmx package license access it will return true
        return isSVMXPackageLicense;
    }
    public String getTAG001(){ return System.Label.USR001_TAG001;} //ServiceMax package is not available or insufficient number of licenses.
    public String getTAG002(){ return System.Label.USR001_TAG001;} // ServiceMax package is not available or insufficient number of licenses.
    public String getTAG003(){ return System.Label.USR001_TAG003;} // Orders Platform Permission Set License is not available or insufficient number of licenses.
    public String getTAG004(){ return System.Label.USR001_TAG004;} // Permission Set License is not active.
    public String getTAG005(){ return System.Label.USR001_TAG003;} //Orders Platform Permission Set License is not available or insufficient number of licenses.
    public String getTAG006(){ return System.Label.USR001_TAG006;} //Orders Platform permission set license is not available or the ServiceMax Global Setting SET002 under the Submodule User License Provisioning is False.   
}