@isTest 
private class INTF_IG_Reconcile_UT {

    static testMethod void testServiceAvailability() {


      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      String requestJson = '{"ReconcileDate": "2018-08-18T00:00:00Z"}';
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(requestJson);
      RestContext.request = req;
      RestContext.response= res;

      Test.startTest();
      INTF_IG_ServiceInterface.doPost();
      Test.stopTest();

      System.debug('Response: ' + res);
      System.assertEquals(res.statusCode, 200);

    }

    static testMethod void testServiceForMandatoryFieldsAvailability() {
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      String requestJson = '{}';
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(requestJson);
      RestContext.request = req;
      RestContext.response= res;

      Test.startTest();
      INTF_IG_ServiceInterface.doPost();
      Test.stopTest();

      String responseBody = res.responseBody.toString();
      INTF_IG_ServiceInterface.IGResponse reconList = (INTF_IG_ServiceInterface.IGResponse)JSON.deserializeStrict(responseBody, INTF_IG_ServiceInterface.IGResponse.class);
      System.assertEquals(reconList.Status, 'Failed');
      System.assertEquals(reconList.ErrorDetails, 'Please provide a reconcile date.');
      System.assertEquals(res.statusCode, 200);
    }

    static testMethod void testIfJobIdExistsAndInValid() {
      
      INTF_IG_ServiceInterface.IGResponse reconList = invokeReconcileAndReturnStatus('000123456xyz');
      System.assertEquals(reconList.Status, 'Failed');
      System.assertEquals(reconList.ErrorDetails, 'Invalid JobId.');
    }

    static testMethod void testIfJobIdExistsAndValid() {


      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      String requestJson = '{"ReconcileDate": "2018-08-18T00:00:00Z"}';
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(requestJson);
      RestContext.request = req;
      RestContext.response= res;
      INTF_IG_ServiceInterface.doPost();

      System.assertEquals(res.statusCode, 200);

      String responseBody = res.responseBody.toString();
      INTF_IG_ServiceInterface.IGResponse reconList = (INTF_IG_ServiceInterface.IGResponse)JSON.deserializeStrict(responseBody, INTF_IG_ServiceInterface.IGResponse.class);
      reconList = invokeReconcileAndReturnStatus(reconList.JobId);
      System.assertEquals(reconList.Status, 'Success');
    }

    static testMethod void testGetStatus(){
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      String requestJson = '{"ReconcileDate": "2018-08-18T00:00:00Z"}';
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(requestJson);
      RestContext.request = req;
      RestContext.response= res;
      INTF_IG_ServiceInterface.doPost();

      System.assertEquals(res.statusCode, 200);

      String responseBody = res.responseBody.toString();
      INTF_IG_ServiceInterface.IGResponse reconList = (INTF_IG_ServiceInterface.IGResponse)JSON.deserializeStrict(responseBody, INTF_IG_ServiceInterface.IGResponse.class);
      reconList = invokeReconcileGetStatus(reconList.JobId);
    }

    static testMethod void testGetStatusInvalidId(){
      INTF_IG_ServiceInterface.IGResponse reconList = invokeReconcileGetStatus('wrongjobid');
      System.assertEquals(reconList.Status, 'Failed');
      System.assertEquals(reconList.ErrorDetails, 'Invalid JobId');
    }

    /*static testMethod void testGetStatusUntilCompleted(){
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      String requestJson = '{"ReconcileDate": "2018-08-18T00:00:00Z"}';
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(requestJson);
      RestContext.request = req;
      RestContext.response= res;
      INTF_IG_ServiceInterface.doPost();

      System.assertEquals(res.statusCode, 200);

      String responseBody = res.responseBody.toString();
      INTF_IG_ServiceInterface.IGResponse reconList = (INTF_IG_ServiceInterface.IGResponse)JSON.deserializeStrict(responseBody, INTF_IG_ServiceInterface.IGResponse.class);
      reconList = invokeReconcileGetStatus(reconList.JobId);

      while(reconList.Status != 'Completed'){
        sleep(2000);
        reconList = invokeReconcileGetStatus(reconList.JobId);
      }
    }

    private static void sleep(integer milliseconds) 
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliseconds);      
    }*/

    private static INTF_IG_ServiceInterface.IGResponse invokeReconcileAndReturnStatus(String jobId){
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      String requestJson = '{"JobId":"' + jobId + '"}';
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/';
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(requestJson);
      RestContext.request = req;
      RestContext.response= res;

      Test.startTest();
      INTF_IG_ServiceInterface.doPost();
      Test.stopTest();

      String responseBody = res.responseBody.toString();
      INTF_IG_ServiceInterface.IGResponse reconList = (INTF_IG_ServiceInterface.IGResponse)JSON.deserializeStrict(responseBody, INTF_IG_ServiceInterface.IGResponse.class);
      return reconList;
    }

    private static INTF_IG_ServiceInterface.IGResponse invokeReconcileGetStatus(String jobId){
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
      req.requestURI = '/services/apexrest/SVMXC/svmx/rest/IG/1.0/reconcile/getStatus/' + jobId + '/';
      req.httpMethod = 'GET';
      RestContext.request = req;
      RestContext.response= res;

      //Test.startTest();
      INTF_IG_ServiceInterface.doGet();
      //Test.stopTest();
      
      System.assertEquals(res.statusCode, 200);

      String responseBody = res.responseBody.toString();
      System.debug('Response Body: ' + responseBody);
      INTF_IG_ServiceInterface.IGResponse reconList = (INTF_IG_ServiceInterface.IGResponse)JSON.deserializeStrict(responseBody, INTF_IG_ServiceInterface.IGResponse.class);
      return reconList;
    }

    static testMethod void testOneInstalledProductForMappingFields() {



      INTF_IG_ServiceInterface.IGRequest request = new INTF_IG_ServiceInterface.IGRequest();
      request.ReconcileDate = (DateTime.Now()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

      createAccount();
      createLocation();
      createInstalledProduct();
      Test.StartTest();

      INTF_IG_Reconcile.reconcileSVMX(request);

      Test.StopTest();


      List<String> ibExternalIds = new List<String>{'IB-00001'};
      List<SVMXC__Installed_Product__c> validateIB = [Select Id, SVMXC__SM_External_ID__c, 
                SVMXC__Company__r.SVMXC__SM_External_ID__c, SVMXC__Parent__r.SVMXC__SM_External_ID__c, 
                SVMXC__Top_Level__r.SVMXC__SM_External_ID__c from SVMXC__Installed_Product__c where SVMXC__SM_External_ID__c In: ibExternalIds];

      for(SVMXC__Installed_Product__c ib : validateIB){
          System.assertEquals(ib.SVMXC__Company__r.SVMXC__SM_External_ID__c, 'ACC-00001');

      }
       
    }

    static testMethod void testInstalledProductForMappingFields() {

      createAccount();
      createLocation();
      createInstalledProduct();
      createParentInstalledProduct();
      createTopLevelInstalledProduct();
      //TODO: Create product and include tests

      INTF_IG_ServiceInterface.IGRequest request = new INTF_IG_ServiceInterface.IGRequest();
      request.ReconcileDate = (DateTime.Now()-0.1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
      Test.StartTest();

      INTF_IG_Reconcile.reconcileSVMX(request);

      Test.StopTest();


      List<String> ibExternalIds = new List<String>{'IB-00001', 'IB-00002', 'IB-00003'};
      List<SVMXC__Installed_Product__c> validateIB = [Select Id, SVMXC__SM_External_ID__c, 
                SVMXC__Company__r.SVMXC__SM_External_ID__c, SVMXC__Parent__r.SVMXC__SM_External_ID__c, 
                SVMXC__Top_Level__r.SVMXC__SM_External_ID__c from SVMXC__Installed_Product__c where SVMXC__SM_External_ID__c In: ibExternalIds];

      for(SVMXC__Installed_Product__c ib : validateIB){
          System.assertEquals(ib.SVMXC__Company__r.SVMXC__SM_External_ID__c, 'ACC-00001');
          
          if(ib.SVMXC__SM_External_ID__c == 'IB-00001'){
            System.assertEquals(ib.SVMXC__Parent__r.SVMXC__SM_External_ID__c, 'IB-00002');
            System.assertEquals(ib.SVMXC__Top_Level__r.SVMXC__SM_External_ID__c, 'IB-00003');

          } else if(ib.SVMXC__SM_External_ID__c == 'IB-00002'){
            System.assertEquals(ib.SVMXC__Parent__r.SVMXC__SM_External_ID__c, 'IB-00003');
            System.assertEquals(ib.SVMXC__Top_Level__r.SVMXC__SM_External_ID__c, 'IB-00003');

          }
      }
       
    }

    static testMethod void testLocationForMappingFields() {
      createAccount();
      createLocation();
      createParentLocation();

      INTF_IG_ServiceInterface.IGRequest request = new INTF_IG_ServiceInterface.IGRequest();
      request.ReconcileDate = (DateTime.Now()-0.1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
      Test.StartTest();

      INTF_IG_Reconcile.reconcileSVMX(request);

      Test.StopTest();

      List<String> ibExternalIds = new List<String>{'LOC-00001', 'LOC-00002'};
      List<SVMXC__Installed_Product__c> validateIB = [Select Id, SVMXC__SM_External_ID__c, 
                SVMXC__Company__r.SVMXC__SM_External_ID__c, SVMXC__Parent__r.SVMXC__SM_External_ID__c, 
                SVMXC__Top_Level__r.SVMXC__SM_External_ID__c from SVMXC__Installed_Product__c where SVMXC__SM_External_ID__c In: ibExternalIds];

      for(SVMXC__Installed_Product__c ib : validateIB){
          System.assertEquals(ib.SVMXC__Company__r.SVMXC__SM_External_ID__c, 'ACC-00001');
          
          if(ib.SVMXC__SM_External_ID__c == 'LOC-00001'){
            System.assertEquals(ib.SVMXC__Parent__r.SVMXC__SM_External_ID__c, 'LOC-00002');

          } 
      }
    
    }

    private static void createAccount() {
      Account acc = new Account();
      acc.SVMXC__SM_External_ID__c = 'ACC-00001';
      acc.Name = 'External Account';
      insert Acc;
    }

    private static void createInstalledProduct(){
      SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
      ib.SVMXC__SM_External_ID__c = 'IB-00001';
      ib.SVMXC__SM_External_Company__c = 'ACC-00001';
      ib.SVMXC__SM_External_Parent__c = 'IB-00002';
      ib.SVMXC__SM_External_Top_Level__c = 'IB-00003';
      insert ib;
    }

    private static void createParentInstalledProduct(){
      SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
      ib.SVMXC__SM_External_ID__c = 'IB-00002';
      ib.SVMXC__SM_External_Company__c = 'ACC-00001';
      ib.SVMXC__SM_External_Parent__c = 'IB-00003';
      ib.SVMXC__SM_External_Top_Level__c = 'IB-00003';
      insert ib;
    }

    private static void createLocation(){
      SVMXC__Site__c location = new SVMXC__Site__c();
      location.SVMXC__SM_External_ID__c = 'LOC-00001';
      location.SVMXC__SM_External_Company__c = 'ACC-00001';
      location.SVMXC__SM_External_Parent__c = 'LOC-00002';
      insert location;
    }

    private static void createParentLocation(){
      SVMXC__Site__c location = new SVMXC__Site__c();
      location.SVMXC__SM_External_ID__c = 'LOC-00002';
      location.SVMXC__SM_External_Company__c = 'ACC-00001';
      insert location;
    }

    private static void createTopLevelInstalledProduct(){
      SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
      ib.SVMXC__SM_External_ID__c = 'IB-00003';
      ib.SVMXC__SM_External_Company__c = 'ACC-00001';
      insert ib;
    }
}