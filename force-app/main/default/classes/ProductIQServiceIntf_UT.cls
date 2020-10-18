@isTest (SeeAllData=true)
private class ProductIQServiceIntf_UT {
        
    static testMethod void productIQClient_Test()
    {
        ProductIQServiceImpl impl = new ProductIQServiceImpl();
        //impl.getUserConfiguration();
        impl.getTranslations();
        
        SVMXC__ProductIQTemplate__c temp = new SVMXC__ProductIQTemplate__c();
        insert temp;
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();        
        ib.SVMXC__Serial_Lot_Number__c = 'a1234565';
        insert ib;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueof('{}');
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // pass the req and resp objects to the method     
        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/getUserConfiguration/9.0/';  
        req.httpMethod = 'POST';
        
        ProductIQServiceIntf.doGet();
        ProductIQServiceIntf.doPost();

        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/getTranslations/9.0/';  
        req.httpMethod = 'POST';
        
        ProductIQServiceIntf.doGet();       
        
        req.requestBody = Blob.valueof('{"templateIds":["' + temp.id + '"]}');
        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/getTemplates/9.0/';             
        ProductIQServiceIntf.doPost();
        
        req.requestBody = Blob.valueof('{"lastSyncTimestamp": "2015-02-13T00:27:50.735Z","updateRecordsList": [{"objectName": "SVMXC__Installed_Product__c","records": [{"attributes": {"type": "SVMXC__Installed_Product__c"},"Id": "'+ ib.id +'","Name": "Battery0","SVMXC__Status__c": "Installed"}]}]}');
        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/updateRecords/9.0/';                
        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/updateRecordsOlder/9.0/';                
        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/updateRecordsOldest/9.0/';                
        req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/invokeMissingMethod/9.0/';                
        ProductIQServiceIntf.doPost();
    }
    static testMethod void productIQClient_Test1(){
        //Objecu serviceBase = new getUserConfiguration();
		SVMXC__ProductIQTemplate__c temp = new SVMXC__ProductIQTemplate__c();
        insert temp;
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();        
        ib.SVMXC__Serial_Lot_Number__c = 'a1234565';
        insert ib;
		RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueof('{"records":[{"attributes": {"type": "SVMXC__Installed_Product__c"},"Id": "'+ ib.id +'","Name": "Battery0","SVMXC__Status__c": "Installed"}]}');
		req.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/getUserConfiguration/9.0/';
        RestResponse res = new RestResponse();
		ProductIQServiceImpl piqImpl = new ProductIQServiceImpl(req,res);
		piqImpl.insertRecords();
		
		RestRequest req1 = new RestRequest(); 
        req1.requestBody = Blob.valueof('{"lastSyncTimestamp": "2015-02-13T00:27:50.735Z","updateRecordsList": [{"objectName": "SVMXC__Installed_Product__c","records":[{"attributes": {"type": "SVMXC__Installed_Product__c"},"Id": "'+ ib.id +'","Name": "Battery0","SVMXC__Status__c": "Installed"}]}]}');
		req1.requestURI = 'https://cs5.salesforce.com/services/apexrest/SVMXC/svmx/rest/ProductIQServiceIntf/getUserConfiguration/9.0/';
		ProductIQServiceImpl piqImpl1 = new ProductIQServiceImpl(req1,res);
		piqImpl1.updateRecords();

    }

}