/*****************************************************************************
 *                       Copyright (C) 2018 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This class provide APIs for feature permission page, which include metadata, all user with/without permission and save action
 *
 *
 */
public  with sharing class CONF_FeaturePermissionImpl{
  public SVMXC.COMM_Utils_V2 comm_utils_v2 = new SVMXC.COMM_Utils_V2();
  public Object getMetadata(){
    GetMetadataResponse metadataResponse = new GetMetadataResponse();
        metadataResponse.setSVMXProfiles(getSVMXProfiles());
        metadataResponse.setTranslations(getTranslations());
        return metadataResponse;
  }


  private List<Profile> getSVMXProfiles(){
    List<Profile> profileList = new List<Profile>();
    List<SObject> profileDataList = exexuteSVMXProfilesQuery();
    Profile objProfile = null;
        String id, profileName;
        for(SObject currRec : profileDataList) {
          id = (String)currRec.get('Id');                 
            profileName = (String)currRec.get('SVMXC__PROFILE_NAME__c');
            objProfile = new Profile(id, profileName);
            profileList.add(objProfile);
        }
    return profileList;

  }
  private List<SObject> exexuteSVMXProfilesQuery() {
         List<String> queryFields = new List<String>{'SVMXC__PROFILE_NAME__c'};
                             if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                             }
        List<SObject> profileDataList = [Select Id, SVMXC__PROFILE_NAME__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Profile' and  SVMXC__Active__c = true and SVMXC__CONFIGURATION_TYPE__c = 'Group' Order By SVMXC__PROFILE_NAME__c]; //SDL-SVMX-READ-FLS-ENFORCED
        return profileDataList;
    }

    public Object getUsersData(String request){

        GetUserRequest getUserRequest =  (GetUserRequest) JSON.deserialize(request, GetUserRequest.class);
    GetUserResponse usersData = new GetUserResponse();
        try{
            usersData.setSVMXUser(getAllUser(getUserRequest));
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                usersData.status = false;
                usersData.message = e.getMessage();
            }catch(Exception ex){
                System.debug('The following exception has occurred: ' + ex.getMessage());
                usersData.status = false;
                usersData.message = ex.getMessage();
        }  
        return usersData;
  }

    public List<SVMXUser> getAllUser(GetUserRequest getUserRequest){
      List<SVMXUser> svmxUserList = new List<SVMXUser>();
      List<String> sfProfileList = new List<String>();
        String svmxProfileId = getUserRequest.profileId;
        String searchValue = getUserRequest.searchValue;
        searchValue = '%'+searchValue+'%';
        List<String> queryFields = new List<String>{'SVMXC__Profile__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
             }
      for(SVMXC__ServiceMax_Config_Data__c configData : [SELECT SVMXC__Profile__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Configuration Access' AND SVMXC__Access_Configuration_Profile__c = :svmxProfileId]){
            sfProfileList.add(configData.SVMXC__Profile__c);
        }


        List<String> userQueryFields = new List<String>{'Username'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'User', userQueryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
             }
      List<User> userList = [SELECT Id,Name,Username FROM User WHERE IsActive = true AND (Name LIKE :searchValue OR Username LIKE :searchValue) AND ProfileId IN :sfProfileList Order By Name]; //SDL-SVMX-READ-FLS-ENFORCED
        svmxUserList = validateFeaturePermission(userList);
      return svmxUserList;
    }

    public List<SVMXUser> validateFeaturePermission(List<User> userList){
      List<SVMXUser> svmxUserList = new List<SVMXUser>();
      String userId, userName, name;
      SVMXUser svmxUser = null;
        List<String> userIdList = new List<String>();
        for(User usr:userList) userIdList.add(usr.Id);
        Map<String,Boolean> userChecklistPermissionMap = comm_utils_v2.getFeaturePermissionInfo('CHECKLIST',userIdList);
        Map<String,Boolean> userSFMdesignerPermissionMap = comm_utils_v2.getFeaturePermissionInfo('SFM_DESIGNER',userIdList);
        for(User userRec: userList){
            Boolean ischecklistEnabled = userChecklistPermissionMap.get(userRec.Id);
            Boolean isSFMEnabled = userSFMdesignerPermissionMap.get(userRec.Id);
            userId = (String)userRec.get('Id');
            userName = (String)userRec.get('Username');
            name = (String)userRec.get('Name');
            svmxUser = new SVMXUser(userId,userName,name,ischecklistEnabled,isSFMEnabled);
            svmxUserList.add(svmxUser);
        }
        return svmxUserList;
    }
    public Object saveData(String request){
            
            AbstractResponse response = new AbstractResponse();
            response.message = 'Saved';
            try{
                List<SVMXUser> svmxUserList = 
                            (List<SVMXUser>)JSON.deserialize(request, List<SVMXUser>.class);
                List<String> deleteChecklistUserIdList = new List<String>();
                Map<String,SVMXUser> addChecklistUserMap = new Map<String,SVMXUser>();

                List<String> deleteSFMUserIdList = new List<String>();
                Map<String,SVMXUser> addSFMUserMap = new Map<String,SVMXUser>();
                for(SVMXUser svmxUser: svmxUserList){
                    //checklist
                    if(svmxUser.isChecklistUpdated != null && svmxUser.isChecklistEnabled){
                        addChecklistUserMap.put(svmxUser.userId,svmxUser);
                        }else if(svmxUser.isChecklistUpdated != null && !svmxUser.isChecklistEnabled){
                        deleteChecklistUserIdList.add(svmxUser.userId);
                        }

                     //sfm   
                     if(svmxUser.isSFMUpdated != null && svmxUser.isSFMEnabled){
                        addSFMUserMap.put(svmxUser.userId,svmxUser);
                        }else if(svmxUser.isSFMUpdated != null && !svmxUser.isSFMEnabled){
                        deleteSFMUserIdList.add(svmxUser.userId);
                        }   
                }
                deleteChecklistUser(deleteChecklistUserIdList);
                addChecklistUser(addChecklistUserMap);

                deleteSFMUser(deleteSFMUserIdList);
                addSFMUser(addSFMUserMap);
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                response.status = false;
                response.message = e.getMessage();
            }catch(Exception ex){
                System.debug('The following exception has occurred: ' + ex.getMessage());
                response.status = false;
                response.message = ex.getMessage();
        }        
       return response;
    }
    public void deleteChecklistUser(List<String> deleteUserIdList){
        String applicationFeatureId = getApplicationFeatureId('CHECKLIST');
        List<SVMXC__SM_Feature_Permission__c> fPermissionList = [SELECT Id FROM SVMXC__SM_Feature_Permission__c WHERE SVMXC__SM_User__c IN :deleteUserIdList AND SVMXC__SM_Application_Feature__c =:applicationFeatureId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(!fPermissionList.isEmpty()) delete fPermissionList; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    public void addChecklistUser(Map<String,SVMXUser> addUserMap){
        system.debug('addUser -- '+addUserMap);
        List<SVMXC__SM_Feature_Permission__c> addUserList = new List<SVMXC__SM_Feature_Permission__c>();
        Set<String> allUserIds = addUserMap.keySet();
        String applicationFeatureId = getApplicationFeatureId('CHECKLIST');
        system.debug('applicationFeatureId -- '+applicationFeatureId);
        for(String userId:allUserIds){
            SVMXUser  userRec = addUserMap.get(userId);
            SVMXC__SM_Feature_Permission__c sM_Feature_Permission = new SVMXC__SM_Feature_Permission__c();
            sM_Feature_Permission.SVMXC__SM_Application_Feature__c = applicationFeatureId;
            sM_Feature_Permission.SVMXC__SM_User__c = userRec.userId;

            /*List<SVMXC__SM_Feature_Permission__c> fPermissionList = [SELECT Id,SVMXC__SM_User__c FROM SVMXC__SM_Feature_Permission__c WHERE SVMXC__SM_User__c =:userRec.userId];
            if(!fPermissionList.isEmpty()){
                sM_Feature_Permission.Id = fPermissionList[0].Id;
            }*/
            addUserList.add(sM_Feature_Permission);
        }
        system.debug('addUserList -- '+addUserList);
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(addUserList, COMM_SecurityUtils.Access.Createable)){
            if(addUserList.size()>0) insert addUserList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            system.debug('addUserList -- after insert '+addUserList);
        }
        else{
            
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
    }

    public void deleteSFMUser(List<String> deleteUserIdList){
         String applicationFeatureId = getApplicationFeatureId('SFM_DESIGNER');
        List<SVMXC__SM_Feature_Permission__c> fPermissionList = [SELECT Id FROM SVMXC__SM_Feature_Permission__c WHERE SVMXC__SM_User__c IN :deleteUserIdList AND SVMXC__SM_Application_Feature__c =:applicationFeatureId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(!fPermissionList.isEmpty()) delete fPermissionList; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    public void addSFMUser(Map<String,SVMXUser> addUserMap){
        System.debug('addSFMUser  +++'+addUserMap);
        List<SVMXC__SM_Feature_Permission__c> addUserList = new List<SVMXC__SM_Feature_Permission__c>();
        Set<String> allUserIds = addUserMap.keySet();
        String applicationFeatureId = getApplicationFeatureId('SFM_DESIGNER');
        for(String userId:allUserIds){
            SVMXUser  userRec = addUserMap.get(userId);
            SVMXC__SM_Feature_Permission__c sM_Feature_Permission = new SVMXC__SM_Feature_Permission__c();
            sM_Feature_Permission.SVMXC__SM_Application_Feature__c = applicationFeatureId;
            sM_Feature_Permission.SVMXC__SM_User__c = userRec.userId;

            /*List<SVMXC__SM_Feature_Permission__c> fPermissionList = [SELECT Id,SVMXC__SM_User__c FROM SVMXC__SM_Feature_Permission__c WHERE SVMXC__SM_User__c =:userRec.userId];
            if(!fPermissionList.isEmpty()){
                sM_Feature_Permission.Id = fPermissionList[0].Id;
            }*/
            addUserList.add(sM_Feature_Permission);
        }
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(addUserList, COMM_SecurityUtils.Access.Upsertable)){
            if(addUserList.size()>0) insert addUserList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            System.debug('addUserList  +++'+addUserList);
        }
        else{
            
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
    }

    public String getApplicationFeatureId(String fName){
        String applicationFeatureId = '';
        List<SVMXC__SM_Application_Feature__c> applicationFeature = [SELECT Id FROM SVMXC__SM_Application_Feature__c WHERE SVMXC__SM_Feature_Name__c = :fName LIMIT 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(applicationFeature.size()>0){
            applicationFeatureId = applicationFeature[0].Id;
        }else{
            SVMXC__SM_Application_Feature__c applicationFeatureRec = new SVMXC__SM_Application_Feature__c();
            applicationFeatureRec.SVMXC__SM_Feature_Description__c = '';
            applicationFeatureRec.SVMXC__SM_Feature_Name__c = fName;
            insert applicationFeatureRec; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            applicationFeatureId = applicationFeatureRec.Id;
        } 
        return applicationFeatureId;
    }   

    /*
        Translations goes here
    */
    
    public List<Translation> getTranslations() {

       List<Translation> translations = new List<Translation>();
       translations.add(new Translation('FEATURE_PERMISSION', system.Label.CONF007_TAG003));//'Feature Permission'
       translations.add(new Translation('SETUP_HOME', system.Label.CONF007_TAG004));// Setup Home
       translations.add(new Translation('PROFILE', system.Label.CONF007_TAG005));//Profile
       translations.add(new Translation('ALL_USER', system.Label.CONF007_TAG006));//ALL User
       translations.add(new Translation('USER_WITH_PERMISSION', system.Label.CONF007_TAG007));//User With Permission
       translations.add(new Translation('NAME', system.Label.CONF007_TAG008));//Name
       translations.add(new Translation('USER_NAME', system.Label.CONF007_TAG009));//User Name
       translations.add(new Translation('CHECKLIST', system.Label.CONF007_TAG010));//Checklist Designer
       translations.add(new Translation('SEARCH_FOR_USERNAME_OR_EMAIL', system.Label.CONF007_TAG011));//Search for user name or email
       translations.add(new Translation('SAVE', system.Label.CONF007_TAG012));// Save
       translations.add(new Translation('CANCEL', system.Label.CONF007_TAG013));//Cancel
       translations.add(new Translation('PAGE', system.Label.CONF007_TAG014));//Page
       translations.add(new Translation('OF', system.Label.CONF007_TAG015));//Of
       translations.add(new Translation('NONE', system.Label.CONF007_TAG016));//--NONE--  
         translations.add(new Translation('ABANDON', system.Label.CONF007_TAG019));//ABANDON 
         translations.add(new Translation('CANCEL_MESSAGE', system.Label.CONF007_TAG018));//You have updated the permission for one or more User. Do you want to abandon these changes and return to previous screen?
         translations.add(new Translation('ABANDON_CHANGES', system.Label.CONF007_TAG017));//Abandon Changes? 
         translations.add(new Translation('NO_USER_FOUND', system.Label.CONF007_TAG020));//No user found. 
         translations.add(new Translation('STATUS', system.Label.CONF007_TAG021));//Saved. 
         translations.add(new Translation('RECORD_SUCCESSFULLY_SAVED', system.Label.CONF007_TAG022));// Changes saved successfully.
         translations.add(new Translation('OK', system.Label.CONF007_TAG023));//Ok 
         translations.add(new Translation('ERROR_PROFILE_CHANGE', system.Label.CONF007_TAG024));//You have updated the permission for one or more User. Do you want to abandon these changes and change the profile?
         translations.add(new Translation('SEARCH', system.Label.CONF007_TAG025));//Search
         translations.add(new Translation('HELP', system.Label.CONF007_TAG026));//Help
         translations.add(new Translation('HELP_URL', system.Label.CONF007_TAG027));//HELP url
         translations.add(new Translation('SFM_DESIGNER', system.Label.CONF007_TAG028));// SFM designer
         translations.add(new Translation('A', system.Label.CONF007_TAG029));// 
         translations.add(new Translation('B', system.Label.CONF007_TAG030));// 
 


       return translations; 
    }
   /* 
        all the request and response declarations goes he
    */            
    public virtual class AbstractResponse{
        
        public Boolean status = true;
        public String message = '';
        public AbstractResponse(){
            
        }       
    }
    
    public class GetMetadataResponse extends AbstractResponse{
        public List<Profile> svmxProfiles; 
        public List<Translation> translations;   
        
        public GetMetadataResponse(){
            
        }
       
        public void setSVMXProfiles(List<Profile> svmxProfiles) {
            this.svmxProfiles = svmxProfiles;
        }

        public void setTranslations(List<Translation> translations) {
            this.translations = translations;
        }        
    }
    public class GetUserResponse extends AbstractResponse{
        public List<SVMXUser> svmxUser; 
        
        public GetUserResponse(){
            
        }
       
        public void setSVMXUser(List<SVMXUser> svmxUser) {
            this.svmxUser = svmxUser;
        }        
    }
    public class Profile {
      public String profileId;
        public String profileName;
        public Profile() {
            
        }
        public Profile(String profileId, String profileName) {
            this.profileId = profileId;
            this.profileName = profileName;         
        }
    }

    public class SVMXUser {
      public String userId;
        public String userName;
        public String name;
        public Boolean isChecklistEnabled;
        public Boolean isSFMEnabled;

        public Boolean isChecklistUpdated;
        public Boolean isSFMUpdated;
        public SVMXUser() {
            
        }
        public SVMXUser(String userId, String userName, String name, Boolean isChecklistEnabled, Boolean isSFMEnabled) {
            this.userId = userId;
            this.userName = userName;
            this.name = name;  
            this.isChecklistEnabled = isChecklistEnabled;
            this.isSFMEnabled = isSFMEnabled; 
            

        }
    }
    public class GetUserRequest {
        public String profileId;
        public String searchValue;

        public GetUserRequest(String profileId, String searchValue){
            this.profileId = profileId;
            this.searchValue = searchValue;
        }
    }
    public class Translation {
        public String Key;
        public String Text;
        
        public Translation(String k, String t){
            this.Key = k;
            this.Text = t;
        }
    }

}