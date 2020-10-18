@isTest(seeAllData = false)
private class COMM_IoTRestApiEngine_UT{
    static String insertIBrecords(){
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
        ib.SVMXC__City__c = 'BengaluruMetro';
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( ib, COMM_SecurityUtils.Access.Createable ) ) {
                upsert ib;
            } 
            return ib.id;
        }
        catch(Exception ex){
            return 'Error';
        }
    }
    static String insertWOrecords(){
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__City__c = 'BengaluruMetro';
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( wo, COMM_SecurityUtils.Access.Createable ) ) {
                upsert wo;
            } 
            return wo.Id;
        }
        catch(Exception ex){
            return 'Error';
        }
    }
    static String insertWOrecordsForName(){
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__City__c = 'BengaluruMetro';
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( wo, COMM_SecurityUtils.Access.Createable ) ) {
                upsert wo;
            } 
            return wo.Name;
        }
        catch(Exception ex){
            return 'Error';
        }
    }
    static void insertIoTConfig_Event(){
        SVMXC__IOTConfiguration__c config = new SVMXC__IOTConfiguration__c();
        config.SVMXC__Contents__c = '{"eventName":"EngineClassUT","eventId":"","className":"COMM_IoTRestApiEngine"}';
        config.SVMXC__Name__c = 'EngineClassUT';
        config.SVMXC__Is_Standard__c = false;
        config.SVMXC__Type__c = 'Event';
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( config, COMM_SecurityUtils.Access.Createable ) ) {
                upsert config;
            } 
            
        }
        catch(Exception ex){
            
        }
    }

    static void insertIoTConfig_CompositKey(){
        SVMXC__IOTConfiguration__c config = new SVMXC__IOTConfiguration__c();
        config.SVMXC__Contents__c = '{"ibFields":[{"sequence":1,"name":"SVMXC__City__c"}],"externalFields":[{"sequence":1,"name":"ff"},{"sequence":2,"name":"sf"}]}';
        config.SVMXC__Name__c = '';
        config.SVMXC__Is_Standard__c = false;
        config.SVMXC__Type__c = 'CompositeKey';
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( config, COMM_SecurityUtils.Access.Createable ) ) {
                upsert config;
            } 
            
        }
        catch(Exception ex){
            
        }
    }

    static void insertIoTFieldMapping(){
        SVMXC__SM_IoT_Field_Mapping__c fieldMap = new SVMXC__SM_IoT_Field_Mapping__c();
        fieldMap.SVMXC__SM_Description__c = 'all text fields';
        fieldMap.SVMXC__SM_Event_Name__c = 'EngineClassUT';
        fieldMap.SVMXC__SM_IoT_Event_Id__c = 'EngineClassUT';
        fieldMap.SVMXC__SM_JSON_Payload__c = '{"objName":"SVMXC__Service_Order__c","objLbl":"WO","fld":[{"fldKey":"city","fldApi":"SVMXC__City__c","fldType":"STRING","isExternalId":false},{"fldKey":"acknowledged","fldApi":"SVMXC__Acknowledged_By_Technician_Date_Time__c","fldType":"DATETIME","isExternalId":false},{"fldKey":"assets","fldApi":"SVMXC__Component__c","fldType":"REFERENCE","refObj":"SVMXC__Installed_Product__c","refFld":"Id","isExternalId":false},{"fldKey":"scheduledDate","fldApi":"SVMXC__Scheduled_Date__c","fldType":"DATE","isExternalId":false},{"fldKey":"recId","fldApi":"Id","fldType":"ID","isExternalId":false},{"fldKey":"namefld","fldApi":"Name","fldType":"AUTONUMBER","isExternalId":false},{"fldKey":"apply_Business","fldApi":"SVMXC__Apply_Business_Hours_For_OptiMax__c","fldType":"BOOLEAN","isExternalId":false},{"fldKey":"auto_Entitlemen","fldApi":"SVMXC__Auto_Entitlement_Status__c","fldType":"PICKLIST","isExternalId":false},{"fldKey":"customer_Failure_Feedback","fldApi":"SVMXC__Customer_Failure_Feedback__c","fldType":"TEXTAREA","isExternalId":false},{"fldKey":"Driving_Time","fldApi":"SVMXC__Driving_Time__c","fldType":"NUMBER","isExternalId":false},{"fldKey":"group_Email","fldApi":"SVMXC__Group_Email__c","fldType":"EMAIL","isExternalId":false},{"fldKey":"zip","fldApi":"SVMXC__Zip__c","fldType":"STRING","isExternalId":false},{"fldKey":"clock_Paused_Forever","fldApi":"SVMXC__Clock_Paused_Forever__c","fldType":"BOOLEAN","isExternalId":false}]}';
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( fieldMap, COMM_SecurityUtils.Access.Createable ) ) {
                upsert fieldMap;
            } 
            
        }
        catch(Exception ex){
            
        }

    }
    static testMethod void test_restAPI_execution_withoutIB(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"Problem_Description":"ut validation"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_fullJSONData(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"city":"yelahanka","acknowledged":"1-jan-2013","actual_Initial":"done","apply_Business":"true","auto_Entitlemen":"not done","customer_Failure_Feedback":"all went well","dispatch_Priority":"101","group_Email":"e@something.com","zip":"571446"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    

    static testMethod void test_restAPI_execution_withoutRequestJSON(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_withoutCustomEvent(){
        insertIBrecords();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"Problem_Description":"ut validation"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
 static testMethod void test_restAPI_execution_withCustomEvent(){
        String ibId = insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"Problem_Description":"ut validation","city":"bengaluru","assets":"'+ ibId+'","apply_Business":"true","auto_Entitlemen":"s","customer_Failure_Feedback":"failure","Driving_Time":"1","group_Email":"a@b.com","zip":"12121"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_IOT_LookUp_for_IB(){
        String ibId = insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"Problem_Description":"ut validation","city":"bengaluru","apply_Business":"true","auto_Entitlemen":"s","customer_Failure_Feedback":"failure","Driving_Time":"1","group_Email":"a@b.com","zip":"12121"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_withoutFieldMappingDetails(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"Problem_Description":"ut validation"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();

    }
     static testMethod void test_restAPI_execution_WrongEventName(){
        insertIBrecords();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/notMe/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{"Problem_Description":"ut validation"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }

    static testMethod void test_restAPI_execution_InvalidDate(){
        insertIBrecords();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "acknowledged": "2013-01-30=-07:38:44.268Z"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_InvalidReferenceRecord(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "assets":"non-id-value"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
     static testMethod void test_restAPI_execution_InvalidNumber(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "Driving_Time":"non-number123"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_InvalidEmailId(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "group_Email":"myweb.com"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_LongtextForTextField(){
        insertIBrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "city":"jhfj fjf ejfhef ejf ejfejkfhekfhehewjrhwejrwehjrwehrkjwehrkjwehrkjwehrwkjhwkejrhwekjrhwejkrhwekjrhwkjrhwkjrhwe kwekr ewkjrhwehrktherwkterkthewrktherkthnerktvhernkterktnerkvnterktverktnvkertnjkerntjknerntjnkerntklrntkjretklertklertkjerhtklerhtklerthklerthkjrtehkjrehkerthkerthklerntkernvtkklterkjvtekrjlhtkljerthjkerhjkltherjktherjklthjekrlthyjkerthyjkerthkjlerthyjkerthklyrthlkhterlkjyhejkrtlyheklrthyjklerthykltewrhy.com"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_ForRecordId(){
        String woId = insertWOrecords();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "recId":"'+woId+'"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
    static testMethod void test_restAPI_execution_ForRecordName(){
        String woName = insertWOrecordsForName();
        insertIoTConfig_Event();
        insertIoTConfig_CompositKey();
        insertIoTFieldMapping();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXC/svmx/rest/IOTServiceIntf/EngineClassUT/2.0/';
        req.requestBody = Blob.valueOf('{"Asset":{},"Event":{},"CustomEvent":{ "recId":"'+woName+'"},"Others":{"ff":"Bengaluru","sf":"Metro"}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IOTServiceIntf.doPost();
    }
}