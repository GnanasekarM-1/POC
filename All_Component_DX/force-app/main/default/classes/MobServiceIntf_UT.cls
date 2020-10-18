@isTest
private with sharing class MobServiceIntf_UT
{
    static testMethod void testDoPost1()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf/getSVMXVersion';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost2()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf//DataSyncRequest';
        req.requestBody = Blob.valueOf('{"clientInfo":[{"clientInfo":["OS:iPadOS","R4B2"],"clientType":"iPad"}],"eventName":"EVENT_SYNC","eventType":"SYNC","groupId":"00DT0000000GmSbMAK","profileId":"00eA0000000WXv1IAG","userId":"005T0000001WnsBIAS","value":"","valueMap":[{"key":"RANGE_START","value":"2012-08-11 18:30:00"},{"key":"RANGE_END","value":"2012-08-12 18:30:00"}]}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost3()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf//MetaSyncRequest';
        req.requestBody = Blob.valueOf('{"clientInfo":[{"clientInfo":["OS:iPadOS","R4B2"],"clientType":"iPad"}],"eventName":"SFM_OBJECT_DEFINITIONS","eventType":"SYNC","groupId":"00DT0000000GmSbMAK","profileId":"00eA0000000WXv1IAG","userId":"005T0000001WnsBIAS","value":""}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost4()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf//TestRequest';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost5()
    {
        ComRestMethodInfo mi = new ComRestMethodInfo('a', 'b');
    }
    
    static testMethod void testDoPost6()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf/retrieveDisplayTags';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost7()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf/getUserInfo';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost8()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf//getLookUpResults';
        req.requestBody = Blob.valueOf('{"lookupRequest":{"Operator":"contains","KeyWord":"","LookupDef":{"objectName":"Product2","lookupDefDetail":{"queryColumns":"Id,Name","searchFields":[{"sequence":0,"apiName":"Name"}],"numberOfRecs":10,"displayFields":[{"sequence":0,"apiName":"Name"}],"defaultLookupColumn":"Name"},"advFilters":[{"filterObject":"SVMXC__Product_Stock__c","allowOverride":true,"filterCriteriaFields":[],"lookupField":"SVMXC__Product__c"}],"lookUpObject":"Product2"}}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
    
    static testMethod void testDoPost9()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobServiceIntf//SNSMobClientData';
        req.requestBody = Blob.valueOf('{"clientInfo":[{"clientInfo":["OS:iPadOS","R4B2"],"clientType":"iPad"}],"eventName":"LOGGEDIN","eventType":"PULSE","groupId":"00DT0000000GmSbMAK","profileId":"00eA0000000WXv1IAG","userId":"005T0000001WnsBIAS","value":"","valueMap":[{"key":"RANGE_START","value":"2012-08-11 18:30:00"},{"key":"RANGE_END","value":"2012-08-12 18:30:00"}]}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobServiceIntf.doPost();
    }
}