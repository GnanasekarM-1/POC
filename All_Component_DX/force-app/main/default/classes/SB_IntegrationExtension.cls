global with sharing class SB_IntegrationExtension{
    
    global void getServiceBoardSettings(){
        // placeholder
        
    }
    
    global map<String, String> getSBSettings(Set<String> setModuleIds){
        string svmxGrpProfileId = getSVMXGrpProfileId(UserInfo.getProfileId());
        map<String, String> mapSettings = getSettings(setModuleIds, svmxGrpProfileId);
        return mapSettings;
    }
    
    private map<String, String> getSettings(set<string> settingSubmoduleIds, string svmxGrpProfileId){
        
        map<String, String> mapSettings = new map<String, String>();
        for(SVMXC__ServiceMax_Properties__c svmxProps : [Select Id, Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name IN ('SP_SB_001','SP_SB_002','SP_SB_003')]) {
            system.debug(loggingLevel.WARN, 'each setting value = ' + svmxProps);
            mapSettings.put(svmxProps.Name, svmxProps.SVMXC__Value__c);
        }
        
        string strSettingsQry = 'select SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = \'Setting Value\' AND (SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c IN: settingSubmoduleIds';
        
        if(svmxGrpProfileId != null && svmxGrpProfileId.length() > 0)
            strSettingsQry += ') AND (SVMXC__Setting_Configuration_Profile__c =: svmxGrpProfileId OR SVMXC__Setting_ID__r.SVMXC__Search_Order__c = \'Global\') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true';
        else
            strSettingsQry += ') AND SVMXC__Setting_ID__r.SVMXC__Search_Order__c = \'Global\' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true';
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Settings: ' + strSettingsQry);
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = database.query(strSettingsQry);
        system.debug(loggingLevel.WARN, 'Settings Queried: ' + lstSettings + ' :: ' + lstSettings.size());
        
        if(lstSettings != NULL && !lstSettings.isEmpty()){
            for(SVMXC__ServiceMax_Config_Data__c eachSetting : lstSettings){
                mapSettings.put(eachSetting.SVMXC__Setting_Unique_ID__c, eachSetting.SVMXC__Internal_Value__c);
            }
        }
        return mapSettings;
    }
    
    private string getSVMXGrpProfileId(string sfdcProfileId){
        if(sfdcProfileId == null)
            sfdcProfileId = userinfo.getProfileId();
            
        List<SVMXC__ServiceMax_Config_Data__c> profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Configuration Access' AND SVMXC__Profile__c =: sfdcProfileId AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c='Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = true];
        system.debug(loggingLevel.WARN, 'Configuration Access: ' + profileAccessLst + ' :: ' + profileAccessLst.size());
        
        if(profileAccessLst == null || profileAccessLst.size() == 0 || profileAccessLst.size() > 1){
            return null;
        }else{
            return profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
        }
    }
}