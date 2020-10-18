@RestResource(urlMapping='/integration/v1/*')
global with sharing class SB_IntegrationService{
    
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        system.debug(LoggingLevel.WARN, 'Heap limit = ' + Limits.getHeapSize() + ', CPU limit = ' + Limits.getCPUTime() + ', SOQL limit = ' + Limits.getQueries() + ', Rows limit = ' + Limits.getQueryRows());
        system.debug(LoggingLevel.WARN, 'JSON Request = ' + request.requestBody.toString());
        
        String strURI = request.requestURI;
        
        String strMethodName = strURI.substring(strURI.lastIndexOf('/') + 1);
        system.debug(LoggingLevel.WARN, 'Method Name = ' + strMethodName + '; Request URI = ' + strURI);
        
        if(strMethodName == 'orginfo'){
            map<String, String> mapCurrencyInfo = new map<String, String>();
            if(UserInfo.isMultiCurrencyOrganization()){
                mapCurrencyInfo.put('isMultiCurrency', String.valueOf(UserInfo.isMultiCurrencyOrganization()));
            }
            else{   
                mapCurrencyInfo.put('isMultiCurrency', String.valueOf(UserInfo.isMultiCurrencyOrganization()));
                mapCurrencyInfo.put('DefaultCurrencyIsoCode', UserInfo.getDefaultCurrency());
            }
            system.debug(LoggingLevel.WARN, 'mapCurrencyInfo = ' + mapCurrencyInfo);
            response.responseBody = Blob.valueOf(JSON.serialize(mapCurrencyInfo));
        } else if(strMethodName == 'updatesettings'){
            Map<String, String> mapTenantSettings = (Map<String, String>)JSON.deserialize(request.requestBody.toString(), Map<String, String>.class);
            system.debug(LoggingLevel.WARN, 'mapTenantSettings = ' + mapTenantSettings);
            response.responseBody = Blob.valueOf(JSON.serialize(updateSettings(mapTenantSettings)));
        }
        system.debug(LoggingLevel.WARN, 'Heap limit = ' + Limits.getHeapSize() + ',CPU limit = ' + Limits.getCPUTime() + ', SOQL limit = ' + Limits.getQueries() + ', Rows limit = ' + Limits.getQueryRows());
    }
    
    private static String updateSettings(Map<String, String> mapTenantSettings){
        map<String, String> mapSettings = new map<String, String>();
        String status = 'Success';
        
        List<SVMXC__ServiceMax_Properties__c> svmxProps = [Select Id, Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name IN ('SP_SB_001','SP_SB_002','SP_SB_003')];
        if(!svmxProps.isEmpty()) {
            for(SVMXC__ServiceMax_Properties__c eachSetting : svmxProps) {
                system.debug(loggingLevel.WARN, 'each setting value = ' + eachSetting);
                if(eachSetting.Name == 'SP_SB_001')
                    eachSetting.SVMXC__Value__c = mapTenantSettings.get('tenant_url');
                else if(eachSetting.Name == 'SP_SB_002') {
                    eachSetting.SVMXC__Value__c = mapTenantSettings.get('tenant_login_username');
                } else if(eachSetting.Name == 'SP_SB_003') {
                    eachSetting.SVMXC__Value__c = mapTenantSettings.get('tenant_login_password');
                }
            }
            Database.SaveResult[] updateResultSettingValues = Database.update(svmxProps, true);
        } else {
            List<SVMXC__ServiceMax_Properties__c> lstProps = new List<SVMXC__ServiceMax_Properties__c>();
            lstProps.add(new SVMXC__ServiceMax_Properties__c(Name = 'SP_SB_001', SVMXC__Key__c = 'URL for Max tenant', SVMXC__Value__c = mapTenantSettings.get('tenant_url')));
            lstProps.add(new SVMXC__ServiceMax_Properties__c(Name = 'SP_SB_002', SVMXC__Key__c = 'Max tenant login username', SVMXC__Value__c = mapTenantSettings.get('tenant_login_username')));
            lstProps.add(new SVMXC__ServiceMax_Properties__c(Name = 'SP_SB_003', SVMXC__Key__c = 'Max tenant login password', SVMXC__Value__c = mapTenantSettings.get('tenant_login_password')));
            Database.SaveResult[] insertSettings = Database.insert(lstProps, true);
            for (Database.SaveResult sr : insertSettings) {
                if(!sr.isSuccess()){
                    status = 'Fail';
                }
            }
        }
        return status;
    }
    
    @HttpGet
    global static void doGet(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strURI = request.requestURI;
        String strMethodName = strURI.substring(strURI.lastIndexOf('/') + 1);
        system.debug(LoggingLevel.WARN, 'Method Name = ' + strMethodName + '; Request URI = ' + strURI);
        
        if (strMethodName == 'getsettings'){
            response.responseBody = Blob.valueOf(getGBL025Setting());   
        }
    }
        
    private static String getGBL025Setting(){
        string strSettingsQry = 'select SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = \'Setting Value\' AND (SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c IN (\'GLOB001_GBL025\'))';
        strSettingsQry += ' AND SVMXC__Setting_ID__r.SVMXC__Search_Order__c = \'Global\' AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true';
        
        system.debug(loggingLevel.WARN, 'Query Prepared for Settings: ' + strSettingsQry);
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = database.query(strSettingsQry);
        system.debug(loggingLevel.WARN, 'Settings Queried: ' + lstSettings + ' :: ' + lstSettings.size());
        
        if(lstSettings != NULL && !lstSettings.isEmpty()){
            return String.valueOf(lstSettings[0].SVMXC__Internal_Value__c);
        }
        return '';
    }
}