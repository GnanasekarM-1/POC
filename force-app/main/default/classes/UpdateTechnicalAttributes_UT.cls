@isTest(seeAllData = false)
private class UpdateTechnicalAttributes_UT{


    static String insertConfigData(){
        SVMXC__IOTConfiguration__c insertEvevnt = new SVMXC__IOTConfiguration__c();
        insertEvevnt.SVMXC__Type__c = 'Event';
        insertEvevnt.SVMXC__Contents__c = '{"eventName":"UpdateTechnicalAttributes","eventId":"a2O0G000000MevCUAS","className":"UpdateTechnicalAttributes"}';
        insertEvevnt.SVMXC__Name__c = 'UpdateTechnicalAttributes';
        upsert insertEvevnt;

        SVMXC__IOTConfiguration__c compositeKeyInsert = new SVMXC__IOTConfiguration__c();
        compositeKeyInsert.SVMXC__Type__c = 'CompositeKey';
        compositeKeyInsert.SVMXC__Contents__c = '{"ibFields":[{"sequence":1,"name":"SVMXC__Serial_Lot_Number__c"}],"externalFields":[{"sequence":1,"name":"Name"},{"sequence":2,"name":"Serial Number"}]}';
        compositeKeyInsert.SVMXC__Name__c = '';
        upsert compositeKeyInsert;

        SVMXC__Installed_Product__c iBInsert = new SVMXC__Installed_Product__c();
        iBInsert.Name = 'TEST 1';
        iBInsert.SVMXC__Serial_Lot_Number__c = 'MRI MachineXYZ123';
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

    static String insertConfigDataWithNumber(){
        SVMXC__IOTConfiguration__c insertEvevnt = new SVMXC__IOTConfiguration__c();
        insertEvevnt.SVMXC__Type__c = 'Event';
        insertEvevnt.SVMXC__Contents__c = '{"eventName":"UpdateTechnicalAttributes","eventId":"a2O0G000000MevCUAS","className":"UpdateTechnicalAttributes"}';
        insertEvevnt.SVMXC__Name__c = 'UpdateTechnicalAttributes';
        upsert insertEvevnt;

        SVMXC__IOTConfiguration__c compositeKeyInsert = new SVMXC__IOTConfiguration__c();
        compositeKeyInsert.SVMXC__Type__c = 'CompositeKey';
        compositeKeyInsert.SVMXC__Contents__c = '{"ibFields":[{"sequence":1,"name":"SVMXC__Latitude__c"}],"externalFields":[{"sequence":1,"name":"Latitude"}]}';
        compositeKeyInsert.SVMXC__Name__c = '';
        upsert compositeKeyInsert;

        SVMXC__Installed_Product__c iBInsert = new SVMXC__Installed_Product__c();
        iBInsert.Name = 'TEST 1';
        iBInsert.SVMXC__Serial_Lot_Number__c = 'MRI MachineXYZ123';
        iBInsert.SVMXC__Latitude__c = 98.91;
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

   static testMethod void AddIBAttributeTestMethod1(){
    
       String iBId = insertConfigData();
       SVMXC.IOTRequest.Asset asset = new SVMXC.IOTRequest.Asset();
       asset.ThingName = 'The Thing';
       asset.ProductName = 'Product';
       asset.InstalledPrductNumber = 'SN001';
       asset.SerialNumber = 'SN001';

       SVMXC.IOTRequest.Event event = new SVMXC.IOTRequest.Event(); 
       event.instancePayload = null;

       SVMXC.IoTRequest.ServiceRequestAlert request = new SVMXC.IoTRequest.ServiceRequestAlert();
       SVMXC.UpdateTechnicalAttributes addIBAttributes = new SVMXC.UpdateTechnicalAttributes();
       addIBAttributes.execute(request);

       request.Asset = asset;
       addIBAttributes.execute(request);
       request.Event = event;
       addIBAttributes.execute(request);
       request.Others = new Map<String, String> {'Name' => 'MRI Machine', 'Serial Number' => 'XYZ123'};
       addIBAttributes.execute(request);

       String jsonString = '{"fields":[]}';
       TechnicalAttributeConfiguration.IbInstancePayload instance = (TechnicalAttributeConfiguration.IbInstancePayload)JSON.deserialize(jsonString, TechnicalAttributeConfiguration.IbInstancePayload.class);
       request.Event.instancePayload = instance;
       addIBAttributes.setRequest(request);
       addIBAttributes.execute(request);

       object instantIndex = addIBAttributes.updateOrInsertInstantTable(jsonString,iBId);
       if(instantIndex != null){
        object historyIndex = addIBAttributes.updateOrInsertHistoryTable(jsonString,iBId,String.valueOf(instantIndex));
      }

       IOTImplInterface objIntf = null;
       Type t = Type.forName('UpdateTechnicalAttributes');
       objIntf = (IOTImplInterface)t.newInstance();
       objIntf.setRequest(request);

   }

   static testMethod void AddIBAttributeTestMethod2()
    {
        String iBId = insertConfigData();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf//UpdateTechnicalAttributes/2.0/';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }

    static testMethod void AddIBAttributeTestMethod3()
    {
        String iBId = insertConfigData();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf//UpdateTechnicalAttributes/2.0/';
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }

    static testMethod void AddIBAttributeTestMethod4()
    {
        String iBId = insertConfigData();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf//UpdateTechnicalAttributes/2.0/';
        req.requestBody = Blob.valueOf('{"Asset": {},"Event": {"instancePayload":{"fields":[]}},"Others": {"Name": "MRI Machine","Serial Number" :"XYZ123"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }

    static testMethod void AddIBAttributeTestMethod5()
    {
        String iBId = insertConfigDataWithNumber();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf//UpdateTechnicalAttributes/2.0/';
        req.requestBody = Blob.valueOf('{"Asset": {},"Event": {"instancePayload":{"fields":[]}},"Others": {"Latitude": "90.78"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }

    static testMethod void AddIBAttributeTestMethod6()
    {
        String iBId = insertConfigDataWithNumber();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf//UpdateTechnicalAttributes/2.0/';
        req.requestBody = Blob.valueOf('{"Asset": {},"Event": {"instancePayload":{"fields":[]}},"Others": {"Latitude": "98.91"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
}