@isTest
public class SB_IntegrationService_UT
{
    static testMethod void getOrgInfo()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/integration/v1/orginfo';
        req.requestBody = Blob.valueOf('{}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res; 
        SB_IntegrationService.doPost();
        RestResponse response = RestContext.response;
    }
    
    static testMethod void updateSettings1()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/integration/v1/updatesettings';
        req.requestBody = Blob.valueOf('{"tenant":"www"}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res; 
        SB_IntegrationService.doPost();
        RestResponse response = RestContext.response;
    }
    
    static testMethod void updateSettings2()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/integration/v1/updatesettings';
        req.requestBody = Blob.valueOf('{"tenant":"www"}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res; 
        insertSettings();
        SB_IntegrationService.doPost();
        RestResponse response = RestContext.response;
    }
    
    static testMethod void getSettings()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/integration/v1/getsettings';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SB_IntegrationService.doGet();
        RestResponse response = RestContext.response;
    }
    
    private static void insertSettings()
    {
        List<SVMXC__ServiceMax_Properties__c> lstsvmxProps = new List<SVMXC__ServiceMax_Properties__c>();
        lstsvmxProps.add(new SVMXC__ServiceMax_Properties__c(Name = 'SP_SB_001', SVMXC__Key__c = 'URL for Max', SVMXC__Value__c = 'www.google.com'));
        lstsvmxProps.add(new SVMXC__ServiceMax_Properties__c(Name = 'SP_SB_002', SVMXC__Key__c = 'Max username', SVMXC__Value__c = 'im_usr'));
        lstsvmxProps.add(new SVMXC__ServiceMax_Properties__c(Name = 'SP_SB_003', SVMXC__Key__c = 'Max password', SVMXC__Value__c = '2wsx'));
        insert lstsvmxProps;
    }
}