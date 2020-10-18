@isTest
private with sharing class MobEntServiceIntf_UT
{
    static testMethod void testDoPost1()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobEntServiceIntf/getSvmxVersion';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobEntServiceIntf.doPost();
    }
    
    static testMethod void testDoPost2()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobEntServiceIntf/Test';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobEntServiceIntf.doPost();
    }
    
    static testMethod void testDoPost3()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobEntServiceIntf/getProductHistory';
        req.requestBody = Blob.valueOf('{"historyReqInfo":[{"key":"CurrentWrkOrderId","value":"a0q700000018BWFAA2"}]}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobEntServiceIntf.doPost();
    }
    
    static testMethod void testDoPost4()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobEntServiceIntf/getViewLayouts';
        req.requestBody = Blob.valueOf('{}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobEntServiceIntf.doPost();
    }
    
    static testMethod void testDoPost5()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/MobEntServiceIntf/getAccountHistory';
        req.requestBody = Blob.valueOf('{"historyReqInfo":[{"key":"CurrentWrkOrderId","value":"a0q700000018BWFAA2"}]}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        MobEntServiceIntf.doPost();
    }
}