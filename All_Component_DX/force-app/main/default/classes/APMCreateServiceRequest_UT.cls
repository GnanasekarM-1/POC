@isTest
private class APMCreateServiceRequest_UT{

    static String insertConfigData(){
        SVMXC__IOTConfiguration__c insertEvevnt = new SVMXC__IOTConfiguration__c();
        insertEvevnt.SVMXC__Type__c = 'Event';
        insertEvevnt.SVMXC__Contents__c = '{"eventName":"APMCreateServiceRequest","eventId":"","className":"APMCreateServiceRequest"}';
        insertEvevnt.SVMXC__Name__c = 'APMCreateServiceRequest';
        upsert insertEvevnt;

        SVMXC__IOTConfiguration__c compositeKeyInsert = new SVMXC__IOTConfiguration__c();
        compositeKeyInsert.SVMXC__Type__c = 'CompositeKey';
        compositeKeyInsert.SVMXC__Contents__c = '{"ibFields":[{"sequence":1,"name":"SVMXC__Serial_Lot_Number__c"}],"externalFields":[{"sequence":1,"name":"fname"},{"sequence":2,"name":"sname"}]}';
        compositeKeyInsert.SVMXC__Name__c = '';
        upsert compositeKeyInsert;

        SVMXC__Installed_Product__c iBInsert = new SVMXC__Installed_Product__c();
        iBInsert.Name = 'APM IB';
        iBInsert.SVMXC__Serial_Lot_Number__c = '1010';
        upsert iBInsert;
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( iBInsert, COMM_SecurityUtils.Access.Createable ) ) {
                upsert iBInsert;
            } 
            return iBInsert.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }

    static testMethod void createServiceRequest_Test_Valid_Data(){
    
        String iBId = insertConfigData();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/APMCreateServiceRequest/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{"Subject":" test case","Description":"Need to fix air quality","Priority":"Low","EventTime":"2017-11-01 09: 51: 02.000","AlertType":"Depot Repair"},"Others":{"RecordID":"a0N1I0000012BMY","FamilyID":"MI_OPR_REC","CurrentStateID":"MI_PROPOSED","RecommendationId":"REC-57195","RecommendationType":"GENERAL","RelatedAlert":"MI_PROPOSED","ConnectionType":"SVMX","SystemID":"XXXXXX","SystemName":"YYYYYY","AssetDescription":"thing","StateKey":"64255992427","GenerateWorkRequest":"TRUE","LocationID":"a2H1I000000QT4h","fname":"10","sname":"10","PreferredStartTime":"2013-01-30T07:38:44.268Z"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void createServiceRequest_Test_Invalid_Data(){
    
        String iBId = insertConfigData();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/APMCreateServiceRequest/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event1":{"Subject":" test case","Description":"Need to fix air quality","Priority":"Low","EventTime":"2017-11-01 09: 51: 02.000","AlertType":"Depot Repair"},"Others":{"RecordID":"a0N1I0000012BMY","FamilyID":"MI_OPR_REC","CurrentStateID":"MI_PROPOSED","RecommendationId":"REC-57195","RecommendationType":"GENERAL","RelatedAlert":"MI_PROPOSED","ConnectionType":"SVMX","SystemID":"XXXXXX","SystemName":"YYYYYY","AssetDescription":"thing","StateKey":"64255992427","GenerateWorkRequest":"TRUE","LocationID":"a2H1I000000QT4h","fname":"10","sname":"10"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }

}