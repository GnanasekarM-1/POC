public with Sharing class SFM_Delivery_LightningController {
    public class ConfigInfoWrapperRequest{
        @AuraEnabled public String recordId;
        @AuraEnabled public String processId;
    }
    public class ConfigInfoWrapperResponse{
        @AuraEnabled public String recordId;
        @AuraEnabled public String processId;
        @AuraEnabled public String strLightningTitleProcessName;
        @AuraEnabled public String strLightningTitleSourceRecordValue;
        @AuraEnabled public Boolean salesforceFileGlobalValue;
        @AuraEnabled public String strTabStyleLogoURL;
        @AuraEnabled public String strColorCodeForIcon;
        @AuraEnabled public Boolean isSanitizehtmlEnabled;
        @AuraEnabled public Boolean isUsageStatisticsEnable;
        @AuraEnabled public Boolean isLaunchDesignerEnabled;
        @AuraEnabled public String urlForLaunchDesigner;
        @AuraEnabled public Long numLMD;
        @AuraEnabled public String ProcessTitle;
        @AuraEnabled public String Settings;
        @AuraEnabled public String UserInfo;
        @AuraEnabled public String strSitePrefix;
    }
    public class JWTTokenWrapper{
        @AuraEnabled public String jwtAccessToken;
        @AuraEnabled public Boolean isJWTTokenEnabledforClient;
    }

    @AuraEnabled
    public static String getTokenByVfPage(){
         String strSessionId = '';
         PageReference pageLightningAccess = Page.LightningAccess;
        try{
            String strPageContent = pageLightningAccess.getContent().toString();
            Integer startOfId = strPageContent.indexOf('SVMX_SessionId_Start') + 'SVMX_SessionId_End'.length();
            Integer endOfId = strPageContent.indexOf('SVMX_SessionId_End');
            strSessionId = strPageContent.substring(startOfId, endOfId);
        }
        catch(Exception e){
            System.debug('Exception in getTokenByVfPage: '+e.getMessage());
        }
        return strSessionId;
    }
    
    @AuraEnabled
    public static SFM_Delivery_LightningController.ConfigInfoWrapperResponse getConfigInfo(String recordId, String processId){
        System.debug('Method called: '+ recordId + 'pId' +processId);
        SFMDeliveryController obj = new SFMDeliveryController();
        SFMDeliveryController.SFMRequest req = new SFMDeliveryController.SFMRequest();
        req.processId = processId;
        req.recordId = String.isNotBlank(recordId) ? String.escapeSingleQuotes(recordId) : recordId; //#soqlInjectionFix
        System.debug('Request: '+req);
        SFMDeliveryController.ConfigInfoWrapperResponse response = obj.processConfigInfo(req);
        SFM_Delivery_LightningController.ConfigInfoWrapperResponse objResponse = new SFM_Delivery_LightningController.ConfigInfoWrapperResponse();

        objResponse.recordId = response.recordId;
        objResponse.processId = response.processId;
        objResponse.strLightningTitleProcessName = response.strLightningTitleProcessName;
        objResponse.strLightningTitleSourceRecordValue = response.strLightningTitleSourceRecordValue;
        objResponse.salesforceFileGlobalValue = response.salesforceFileGlobalValue;
        objResponse.strTabStyleLogoURL = response.strTabStyleLogoURL;
        objResponse.strColorCodeForIcon = response.strColorCodeForIcon;
        objResponse.isSanitizehtmlEnabled = response.isSanitizehtmlEnabled;
        objResponse.isUsageStatisticsEnable = response.isUsageStatisticsEnable;
        objResponse.isLaunchDesignerEnabled = response.isLaunchDesignerEnabled;
        objResponse.urlForLaunchDesigner = response.urlForLaunchDesigner;
        objResponse.numLMD = response.numLMD;
        objResponse.ProcessTitle = response.ProcessTitle;
        objResponse.Settings = response.Settings;
        objResponse.UserInfo = response.UserInfo;
        objResponse.strSitePrefix = response.strSitePrefix;
        return objResponse;
    }
}