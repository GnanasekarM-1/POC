public with sharing class INTF_MobileConfigUtility 
{
    /*Build the Object permission response based on thier object and SFM Puposes*/
    public List<INTF_WebServicesDef.SVMXMap> getObjectPermissions(Map<String,Set<String>> objectsSFMProcess, Map<String,String> objectsSFMPurpose)
    {
        integer intCRUD = 10000;
        List<INTF_WebServicesDef.SVMXMap> lstOfActualAndReqPerm = new List<INTF_WebServicesDef.SVMXMap>();
        String strActualPer,strReqPer = '';
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        String strActualObjName = null;
        try
        {
            Map<String, Schema.SObjectType> mapOfAllObjects = Schema.getGlobalDescribe();
            Map<String,String> mapSFMPurposePermissions = getSFMPurposePermissions();
            INTF_WebServicesDef.SVMXMap objCurrObjAndPer = null;
            String purposeName = null;
            for(String strCurrentObject : objectsSFMProcess.keySet())
            {  
                intCRUD = 10000;
                strActualObjName = utils.getOriginalAPIName(strCurrentObject, mapOfAllObjects);    
                if(!mapOfAllObjects.containsKey(strActualObjName))
                {
                    continue;
                }
                objCurrObjAndPer = new INTF_WebServicesDef.SVMXMap();
                //Preparing to built the Actual Permissions
                Schema.DescribeSObjectResult objDescResult = mapOfAllObjects.get(strActualObjName).getDescribe();
                if(objDescResult.isCreateable())
                {
                    intCRUD += 1000;
                }
                if(objDescResult.isAccessible())
                {
                    intCRUD += 100;
                }
                if(objDescResult.isUpdateable())
                {
                    intCRUD += 10;
                }
                if(objDescResult.isDeletable())
                {
                    intCRUD += 1;
                }
                //Built the Actual Permissions for the user.    
                strActualPer = String.valueOf(intCRUD).substring(1, 5);

                //Now calculating the Required Permissions based on the SFM Purpose for the Object
                strReqPer = '';
                for(String strCurrentProc : objectsSFMProcess.get(strCurrentObject))
                { 
                    purposeName = objectsSFMPurpose.get(strCurrentProc);
                    strReqPer = calculateTwoPermissions(strReqPer,mapSFMPurposePermissions.get(purposeName));
                }
                //End of calculating the required permissions
                objCurrObjAndPer.key = strCurrentObject;
                objCurrObjAndPer.value = strReqPer + ':' +strActualPer;
                lstOfActualAndReqPerm.add(objCurrObjAndPer);
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }
        return lstOfActualAndReqPerm;
    }
    
    /*Get the permissions for SFM Purpose*/
    public Map<String,String> getSFMPurposePermissions()
    {
        Map<String,String> mapSFMPuposePermissions  = new Map<String,String>();
        //HERE the permissions are based on CRUD(CreateReadUpdateDelete); 1 and 0 is for allowed and not allowed
        mapSFMPuposePermissions.put('STANDALONE CREATE','1100');
        mapSFMPuposePermissions.put('STANDALONE EDIT','0110');
        mapSFMPuposePermissions.put('SOURCE TO TARGET ALL','1110');
        mapSFMPuposePermissions.put('SOURCE TO TARGET CHILD','1110');
        mapSFMPuposePermissions.put('GENERATE REPORT','0100');
        mapSFMPuposePermissions.put('VIEW RECORD','0100');
        return mapSFMPuposePermissions;
    }
    
    /* Binary opeariotns i.e., 1011, 1101 = 1111*/
    public String calculateTwoPermissions(String calculated, String current)
    {
        String finalCalc = '';
        String currentChar = '';
        if(calculated == null || calculated.length() == 0 ) return current;
        for(integer i = 0; i <= 3 ; i++)
        {
            system.debug('Calculated: ' + calculated.substring(i,i + 1) + ' Current: ' + current.substring(i,i + 1));
            currentChar = calculated.substring(i,i + 1);
            if(currentChar == '0')
            {
                currentChar = current.substring(i,i + 1);
            }
                finalCalc += currentChar;
        }
        return finalCalc;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getMobileConfig(String profileId, String strDevice, Boolean targetedSyncEnabled)
    {
        INTF_WebServicesDef.INTF_SFMResponse settingResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.svmxError> lstErrors = new List<INTF_WebServicesDef.svmxError>();
        try
        {
            Map<String, String> lstsvmxSettingList = new Map<String, String>();
            List<INTF_WebServicesDef.SVMXMap> lstSettings = new List<INTF_WebServicesDef.SVMXMap>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            //16th October 2012:- When the call with parameter as 'IPAD' is sent then settings for only Service Report was returned,
            //So in order to send the Unique Ids (like IPAD004_SET001)and ensure that previous versions of IPAD work properly we have introduced two
            //calls with parameters as IPAD004 which will send settings as SET001, SET002 ... with which all the settings were not being sent as
            // the key in the map will be unique and 
            //another call with parameter IPAD which will send settings with Unique ID (like IPAD004_SET001) thus making all the settings being sent to client.  
            lstsvmxSettingList = SVMX_getModuleSetting('IPAD004');
            lstsvmxSettingList.putAll(SVMX_getModuleSetting('IPAD'));
            //TargtedSync - send true or false in case targeted sync hasn't been enabled
            if(!targetedSyncEnabled){
                    for(String eachSettingID: lstsvmxSettingList.KeySet()){
                         if(eachSettingID == 'IPAD018_SET019' && lstsvmxSettingList.get(eachSettingID) != NULL){
                            if(lstsvmxSettingList.get(eachSettingID) == 'Full Sync' || lstsvmxSettingList.get(eachSettingID) == 'Smart Sync' ){
                                lstsvmxSettingList.put(eachSettingID, 'True');
                            }else if(lstsvmxSettingList.get(eachSettingID) == 'None'){
                                lstsvmxSettingList.put(eachSettingID, 'False');
                            }
                            break;
                         }
                    }
            }
            lstsvmxSettingList.putAll(SVMX_getModuleSetting('WORD005'));
            lstsvmxSettingList.putAll(SVMX_getModuleSetting('GLOB001'));//multiday event setting
            lstsvmxSettingList.putAll(SVMX_getModuleSetting('SLAT'));

            for(SVMXC__ServiceMax_Config_Data__c configData : getProfileConfigData(profileId, strDevice))
            {
                if(configData.SVMXC__Display_Type__c != NULL && configData.SVMXC__Display_Type__c != '')
                {
                    lstsvmxSettingList.put(configData.SVMXC__Display_Type__c , configData.SVMXC__Internal_Value__c);
                }
            }
            
            if(lstsvmxSettingList != null && lstsvmxSettingList.size() > 0)
            {
                for(String key: lstsvmxSettingList.keySet())
                {
                    lstSettings.add(new INTF_WebServicesDef.SVMXMap(key, lstsvmxSettingList.get(key)));
                }
            }
            else
            {
                INTF_WebServicesDef.svmxError objEror = new INTF_WebServicesDef.svmxError();
                objEror.errorMsg = 'Please specfiy the valid request to get the setting informations.';
                lstErrors.add(objEror);
            }
            settingResponse.success = True;
            settingResponse.eventType = 'DATA';
            settingResponse.eventName = 'MOBILE_DEVICE_SETTINGS';
            settingResponse.valueMap = lstSettings;
        }
        catch(Exception ex)
        {        
            INTF_WebServicesDef.svmxError objEror = new INTF_WebServicesDef.svmxError();
            objEror.errorMsg = ex.getMessage();
            lstErrors.add(objEror);
            settingResponse.success = False;
            settingResponse.eventType = 'DATA';
            settingResponse.eventName = 'MOBILE_DEVICE_SETTINGS';                 
        }
        settingResponse.errors = lstErrors;
        return settingResponse;
    }
    
    public Map<String, String> SVMX_getModuleSetting(String moduleId)
    {
        COMM_Utils_ManageSettings clsSettings = new COMM_Utils_ManageSettings();
        List<SVMXC__ServiceMax_Processes__c> allSetRecs = new List<SVMXC__ServiceMax_Processes__c>();    
        Map<String, String> mapSettings = new Map<String, String>(); // The Result List
        try
        {
            //to maintain backward compatibility until ipad side fix is not made. 
            //When that is done then we will have only one query with moduleId as IPAD  
            if(moduleId == 'IPAD004')
            {
                allSetRecs = [SELECT SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :moduleId))];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                mapSettings = clsSettings.SVMX_GetSettingValueMap(allSetRecs, false);
            }
            else if(moduleId == 'WORD005')
            {
                allSetRecs = [SELECT SVMXC__Setting_Unique_ID__c, SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :moduleId))];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                mapSettings = clsSettings.SVMX_GetSettingValueMap(allSetRecs, true);
            }
            else if(moduleId == 'GLOB001')
            {
                allSetRecs = [SELECT SVMXC__Setting_Unique_ID__c, SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__SubmoduleID__c = :moduleId))];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                mapSettings = clsSettings.SVMX_GetSettingValueMap(allSetRecs, true);
            }
            else
            {
                allSetRecs = [SELECT SVMXC__Setting_Unique_ID__c, SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__Module__r.SVMXC__ModuleID__c = :moduleId))];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                mapSettings = clsSettings.SVMX_GetSettingValueMap(allSetRecs, true);
            }
            if(allSetRecs == null)
                return mapSettings; //Error
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, 'Exception during getting Settings :'+e.getMessage());
        }
        return mapSettings; 
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> getProfileConfigData(String profileId, String strDevice)
    {
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        // If no profile id is passed, get the loged in users profile id and get the sync settings
        if(profileId == NULL || profileId == '')
        {
            profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c = :UserInfo.getProfileId() AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(profileAccessLst.size() > 0)
            {
                profileId = profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
            }
            else
            {
                // If we have not configured the profile, get the default setting values that are defined for the default group profile
                list<SVMXC__ServiceMax_Config_Data__c> LocSVMXprofiles = [Select Id,SVMXC__Profile_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' and SVMXC__IsDefault__c = true];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(LocSVMXprofiles.size() > 0)
                    profileId = LocSVMXprofiles[0].Id;
            }
        }
        system.debug('getProfileConfigData - profileId: ' + profileId);
        List<SVMXC__ServiceMax_Config_Data__c> respnsLstCnfgDta = new List<SVMXC__ServiceMax_Config_Data__c>();
        RecordType RTMobileConfig = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        String strMobConfQuery = 'Select SVMXC__Display_Type__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId = \''+ RTMobileConfig.Id +'\' AND SVMXC__Access_Configuration_Profile__c =: profileId';
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(profileId, strDevice);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed in getMobConfig = '+strMobConfQuery);
        
        for(SVMXC__ServiceMax_Config_Data__c configuredProfileData : Database.Query(strMobConfQuery) )
        {
            if(configuredProfileData.SVMXC__Display_Type__c != null && configuredProfileData.SVMXC__Display_Type__c.length() > 0)
            {
                respnsLstCnfgDta.add(configuredProfileData);
            }
        }
        system.debug(LoggingLevel.WARN, 'getProfileConfigData - response: ' + respnsLstCnfgDta);
        return respnsLstCnfgDta;
    }
}