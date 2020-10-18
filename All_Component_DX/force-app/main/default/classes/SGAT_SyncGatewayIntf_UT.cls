@isTest(seeAllData=false)
public class SGAT_SyncGatewayIntf_UT {
    static testMethod void testDoPost()
    {
        Account ac = new Account();
        ac.Name = 'TestAccount';
        insert ac;

        List<String> lstIds = new List<String>();
        lstIds.add(ac.Id);
        List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SVMXMap vm = new SGAT_WebServicesDef.SVMXMap('query', 'select Name from Account where ID IN ({{ids}})', lstIds);
        valueMap.add(vm);
        SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/SGAT_SyncGatewayIntf/SGExecuteQuery';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SGAT_SyncGatewayIntf.doPost();

        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/SGAT_SyncGatewayIntf/SGValidateCache';
        SGAT_SyncGatewayIntf.doPost();

        request.valueMap = null;
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        SGAT_SyncGatewayIntf.doPost();
    }

    static testMethod void testDoPostError()
    {
        List<SGAT_WebServicesDef.SVMXMap> valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(valueMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/SGAT_SyncGatewayIntf/SGExecuteQuery';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SGAT_SyncGatewayIntf.doPost();
    }

    static testMethod void testDoGet()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/SGAT_SyncGatewayIntf/SGDisplayTags';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SGAT_SyncGatewayIntf.doGet();
    }

    static testMethod void testExecuteQueries() {
        Account ac = new Account();
        ac.Name = 'TestAccount1';
        insert ac;
        Account ac1 = new Account();
        ac1.Name = 'TestAccount2';
        insert ac1;

        List<SGAT_WebServicesDef.SVMXMap> reqValueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SVMXMap resourceVM = new SGAT_WebServicesDef.SVMXMap('RESOURCE_PERCENT', '80');
        SGAT_WebServicesDef.SVMXMap queriesVM = new SGAT_WebServicesDef.SVMXMap('QUERIES', '');
        SGAT_WebServicesDef.SVMXMap queryVM = new SGAT_WebServicesDef.SVMXMap('account', 'SELECT Id from Account');
        queryVM.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SVMXMap isDeletedVM = new SGAT_WebServicesDef.SVMXMap('IS_DELETED', 'true');
        queryVM.valueMap.add(isDeletedVM);

        SGAT_WebServicesDef.SVMXMap queryVM1 = new SGAT_WebServicesDef.SVMXMap('contact', 'SELECT Id from Contact');

        queriesVM.valueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        queriesVM.valueMap.add(queryVM);
        queriesVM.valueMap.add(queryVM1);

        reqValueMap.add(resourceVM);
        reqValueMap.add(queriesVM);

        SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(reqValueMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/SGAT_SyncGatewayIntf/SGExecuteQuery';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SGAT_SyncGatewayIntf.doPost();

        SGAT_WebServicesDef.SVMXMap lastIdVM = new SGAT_WebServicesDef.SVMXMap('LAST_ID', ac.Id);
        queryVM.valueMap.add(lastIdVM);
        resourceVM.value = '1';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        SGAT_SyncGatewayIntf.doPost();

        queryVM.value = 'SELECT Id from Account Where Name != null';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        SGAT_SyncGatewayIntf.doPost();
    }

    static testMethod void deleteRecords() {
        Test.startTest();
        SVMXC__Checklist__c checklistForTest = new SVMXC__Checklist__c();
        insert checklistForTest;
        String checklistId = checklistForTest.Id;

        List<SGAT_WebServicesDef.SVMXMap> reqValueMap = new List<SGAT_WebServicesDef.SVMXMap>();
        SGAT_WebServicesDef.SVMXMap objectVM = new SGAT_WebServicesDef.SVMXMap();
        objectVM.key = 'SVMXC__Checklist__c';
        objectVM.values = new List<String>{checklistForTest.Id, (String.valueOf(checklistForTest.Id)).substring(0, 14)+'1', 'abcd'};
        reqValueMap.add(objectVM);
        SGAT_WebServicesDef.SVMXMap object2VM = new SGAT_WebServicesDef.SVMXMap();
        object2VM.key = 'abcd';
        object2VM.values = new List<String>{'abcd'};
        reqValueMap.add(object2VM);
        SGAT_WebServicesDef.SGAT_Request request = new SGAT_WebServicesDef.SGAT_Request(reqValueMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/SGAT_SyncGatewayIntf/SGDeleteRecords';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SGAT_SyncGatewayIntf.doPost();
        SGAT_WebServicesDef.SGAT_Response response = (SGAT_WebServicesDef.SGAT_Response)JSON.deserialize(res.responseBody.toString(), SGAT_WebServicesDef.SGAT_Response.class);
        system.debug('Response: ' + response);
        System.assert(response != null);
        System.assert(response.valueMap[0].key == 'SVMXC__Checklist__c');
        System.assert(response.valueMap[0].valueMap[0].key == 'success');
        System.assert(response.valueMap[0].valueMap[0].values.size() > 0);
        System.assert(response.valueMap[0].valueMap[0].values[0] == checklistId);
        System.assert(response.valueMap[0].valueMap[1].key == 'error');

        SGAT_WebServicesDef.SGAT_Request invalidRequest = new SGAT_WebServicesDef.SGAT_Request(new List<SGAT_WebServicesDef.SVMXMap>());
        res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(invalidRequest));
        RestContext.request = req;
        RestContext.response = res;
        SGAT_SyncGatewayIntf.doPost();
        response = (SGAT_WebServicesDef.SGAT_Response)JSON.deserialize(res.responseBody.toString(), SGAT_WebServicesDef.SGAT_Response.class);
        System.assert(response.valueMap[0].key == 'ERROR');
        System.assert(response.valueMap[0].value == 'Request not Valid');

        Test.stopTest();
    }
}