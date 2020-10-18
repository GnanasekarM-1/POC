@isTest (SeeAllData=false)
private class IOTServiceIntf_UT {
        
    static testMethod void IOTService_Test()
    {
        Product2 prod = new Product2();
        prod.Name = 'thingName';
        insert prod;
        IOTServiceImpl impl = new IOTServiceImpl();
        IOTRestMethodInfo info = new IOTRestMethodInfo();
        info = new IOTRestMethodInfo('','','');
        
        RestRequest req = new RestRequest(); 
         string alerttimeStr = string.valueOf(datetime.now());
         string strReq = '{"thingName": "thingName","asset": {"serialNumber": "SRNUMBER"}, "alert": {"name": "newagain", "priority": null, "message": "unittesting", "description": "unittesting", "type": "test", "sourceProperty": "test", "alertTime": "' + alerttimeStr + '", "eventProperties": [{"name": "newname", "value": "newValue"}]}}';
         
        req.requestBody = Blob.valueof(strReq);
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // pass the req and resp objects to the method     
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/createSR/1.0/';  
        req.httpMethod = 'POST';
        
        IOTServiceIntf.doGet();
        IOTServiceIntf.doPost();

        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/createCase/1.0/';  
        req.httpMethod = 'POST';
        
        IOTServiceIntf.doPost();       
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/alertHandler/1.0/';
        IOTServiceIntf.doPost();       
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/missing/1.0/';
        IOTServiceIntf.doPost();
        
        strReq = '{"Asset": {"ThingName": "MRI - Machine - 1234","ProductName": "MRI Machine","InstalledProductName": "MRI Machine #1234","SerialNumber": "XYZ123"},' +
                    '"Event": {'+
                    '"Subject": "Vibration detected during machine operation.",'+
                    '"Description": "5.0 <= 5.5",'+
                    '"Priority": "1",'+
                    '"Time": "2015-12-29 22: 27: 06.006",'+
                    '"Type": "Above",'+
                    '"Property": "Vibration",'+
                    '"ServiceSessionID": "DSBBB0056"'+
                    '},"Others": {"Priority": "Critical"}}';
        req.requestBody = Blob.valueof(strReq);
        res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateWorkOrder/2.0/';
        //IOTServiceIntf.doPost();
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateCase/2.0/';
        //IOTServiceIntf.doPost();
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateServiceRequest/2.0/';
        //IOTServiceIntf.doPost();
        
        strReq = '{"Asset": {"ThingName": "MRI - Machine - 1234","ProductName": "MRI Machine","InstalledProductName": "MRI Machine #1234","SerialNumber": "XYZ123"},' +
                    '"Event": {'+
                    '"Subject": "Vibration detected during machine operation.",'+
                    '"Description": "5.0 <= 5.5",'+
                    '"Priority": "2",'+
                    '"Time": "2015-12-29 22: 27: 06.006",'+
                    '"Type": "Above",'+
                    '"Property": "Vibration",'+
                    '"ServiceSessionID": "DSBBB0056"'+
                    '},"Others": {"Priority": "Critical"}}';
        req.requestBody = Blob.valueof(strReq);
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateWorkOrder/2.0/';
        //IOTServiceIntf.doPost();
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateCase/2.0/';
        //IOTServiceIntf.doPost();
        
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateServiceRequest/2.0/';
        //IOTServiceIntf.doPost();
        
    }
    
    static testMethod void IOTService_Event_Creation_CreateWorkOrder() {
        Product2 prod = new Product2();
        prod.Name = 'thingName';
        insert prod;
        
        SVMXC__IOTConfiguration__c sobj = new SVMXC__IOTConfiguration__c(
          SVMXC__Contents__c = '{"eventName":"CreateWorkOrder","className":"CreateWorkOrder"}',// Contents
          SVMXC__Is_Standard__c = true,                                                          // Is Standard
          SVMXC__Name__c = 'CreateWorkOrder',                                                    // Name
          SVMXC__Type__c = 'Event'                                                              // Type
        );
        insert sobj;
        
        
        SVMXC__IOTConfiguration__c sobj1 = new SVMXC__IOTConfiguration__c(
          SVMXC__Contents__c = '{"ibFields":[],"externalFields":[]}',// Contents
          SVMXC__Is_Standard__c = false,                               // Is Standard
          SVMXC__Type__c = 'CompositeKey'                             // Type
        );
        insert sobj1;
        
        RestRequest req = new RestRequest(); 
        string alerttimeStr = string.valueOf(datetime.now());
        string strReq = '{"Asset":{"ThingName":"MRI - Machine - 1234","ProductName":"MRI Machine","InstalledProductName":"MRI Machine #1234","SerialNumber":"XYZ123"},"Event":{"Subject":"Vibration detected during machine operation.","Description":"5.0 <= 5.5","Priority":"Medium","Time":"2015-12-29 22: 27: 06.006","Type":"Above","Property":"Vibration","ServiceSessionID":"DSBBB0056"},"Others":{"Priority":"Critical"}}';
         
        req.requestBody = Blob.valueof(strReq);
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
	        
        // pass the req and resp objects to the method     
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateWorkOrder/2.0/';  
        req.httpMethod = 'POST';
        IOTServiceIntf.doPost();   
        
        List<SVMXC__SM_IOT_Event__c> events = [select Id, SVMXC__SM_Status__c, SVMXC__SM_Alert_Event__c from SVMXC__SM_IOT_Event__c order by CreatedDate desc limit 1];
        System.assert (events != null);
        System.assertEquals(events.get(0).SVMXC__SM_Alert_Event__c, 'CreateWorkOrder');
        System.assertEquals(events.get(0).SVMXC__SM_Status__c, 'COMPLETED');
        
    }
    
    static testMethod void IOTService_Event_Creation_CreateCase() {
        Product2 prod = new Product2();
        prod.Name = 'thingName';
        insert prod;
        
        SVMXC__IOTConfiguration__c sobj = new SVMXC__IOTConfiguration__c(
          SVMXC__Contents__c = '{"eventName":"CreateCase","className":"CreateCase"}',// Contents
          SVMXC__Is_Standard__c = true,                                                          // Is Standard
          SVMXC__Name__c = 'CreateCase',                                                    // Name
          SVMXC__Type__c = 'Event'                                                              // Type
        );
        insert sobj;
        
        SVMXC__IOTConfiguration__c sobj1 = new SVMXC__IOTConfiguration__c(
          SVMXC__Contents__c = '{"ibFields":[],"externalFields":[]}',// Contents
          SVMXC__Is_Standard__c = false,                               // Is Standard
          SVMXC__Type__c = 'CompositeKey'                             // Type
        );
        insert sobj1;
        
        RestRequest req = new RestRequest(); 
        string alerttimeStr = string.valueOf(datetime.now());
        string strReq = '{"Asset":{"ThingName":"MRI - Machine - 1234","ProductName":"MRI Machine","InstalledProductName":"MRI Machine #1234","SerialNumber":"XYZ123"},"Event":{"Subject":"Vibration detected during machine operation.","Description":"5.0 <= 5.5","Priority":"Medium","Time":"2015-12-29 22: 27: 06.006","Type":"Above","Property":"Vibration","ServiceSessionID":"DSBBB0056"},"Others":{"Priority":"Critical"}}';
         
        req.requestBody = Blob.valueof(strReq);
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
	        
        // pass the req and resp objects to the method     
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateCase/2.0/';  
        req.httpMethod = 'POST';
        IOTServiceIntf.doPost();   
        
        List<SVMXC__SM_IOT_Event__c> events = [select Id, SVMXC__SM_Status__c, SVMXC__SM_Alert_Event__c from SVMXC__SM_IOT_Event__c order by CreatedDate desc limit 1];
        System.assert (events != null);
        System.assertEquals(events.get(0).SVMXC__SM_Alert_Event__c, 'CreateCase');
        System.assertEquals(events.get(0).SVMXC__SM_Status__c, 'COMPLETED');
    }
    
    static testMethod void IOTService_Event_Creation_CreateServiceRequest() {
        Product2 prod = new Product2();
        prod.Name = 'thingName';
        insert prod;
        
        SVMXC__IOTConfiguration__c sobj = new SVMXC__IOTConfiguration__c(
          SVMXC__Contents__c = '{"eventName":"CreateServiceRequest","className":"CreateServiceRequest"}',// Contents
          SVMXC__Is_Standard__c = true,                                                          // Is Standard
          SVMXC__Name__c = 'CreateServiceRequest',                                                    // Name
          SVMXC__Type__c = 'Event'                                                              // Type
        );
        insert sobj;

        SVMXC__IOTConfiguration__c sobj1 = new SVMXC__IOTConfiguration__c(
          SVMXC__Contents__c = '{"ibFields":[],"externalFields":[]}',// Contents
          SVMXC__Is_Standard__c = false,                               // Is Standard
          SVMXC__Type__c = 'CompositeKey'                             // Type
        );
        insert sobj1;
        
        RestRequest req = new RestRequest(); 
        string alerttimeStr = string.valueOf(datetime.now());
        string strReq = '{"Asset":{"ThingName":"MRI - Machine - 1234","ProductName":"MRI Machine","InstalledProductName":"MRI Machine #1234","SerialNumber":"XYZ123"},"Event":{"Subject":"Vibration detected during machine operation.","Description":"5.0 <= 5.5","Priority":"Medium","Time":"2015-12-29 22: 27: 06.006","Type":"Above","Property":"Vibration","ServiceSessionID":"DSBBB0056"},"Others":{"Priority":"Critical"}}';
         
        req.requestBody = Blob.valueof(strReq);
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
	        
        // pass the req and resp objects to the method     
        req.requestURI = 'https://na5.salesforce.com/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/CreateServiceRequest/2.0/';  
        req.httpMethod = 'POST';
        IOTServiceIntf.doPost();  
        
        List<SVMXC__SM_IOT_Event__c> events = [select Id, SVMXC__SM_Status__c, SVMXC__SM_Alert_Event__c from SVMXC__SM_IOT_Event__c order by CreatedDate desc limit 1];
        System.assert (events != null);
        System.assertEquals(events.get(0).SVMXC__SM_Alert_Event__c, 'CreateServiceRequest');
        System.assertEquals(events.get(0).SVMXC__SM_Status__c, 'COMPLETED');
    }
}