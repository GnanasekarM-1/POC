@isTest
private class SFMSearchDelivery_UT {
    
    static testMethod void getSearchInfo_REST_test(){
        /*RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        SVMXC.SFMSearchDeliveryServiceIntf.doPost();*/
    }
    
    static testMethod void getSearchResult_REST_test(){
        /*RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        SVMXC.SFMSearchDeliveryServiceIntf.doPost();*/
    }
    
    static testMethod void getSearchInfo_JSR_test(){
        /*SVMXC.SFMSearchDeliveryController.JsrGetSearchInfo('{}');*/
    }
    
    static testMethod void getSearchResult_JSR_test(){
        /*SVMXC.SFMSearchDeliveryController.JsrGetSearchInfo(
        '{"ProcessId":"a0K70000009uK0MEAU","ProcessName":"Closed WO Search","ObjectId":"a0K70000009uK0NEAU","KeyWord":"1","Opertor":"Contains","RecordLimit":20}'
        );*/
    }
    static testMethod void getSearch_test(){
        //Jaysukh :Covered UT for BAC-3517 changes 
        PageReference pageRef = Page.SFMSearchDelivery;
        pageRef.getParameters().put('showHeader','true');
        pageRef.getParameters().put('inline','1');
        Test.setCurrentPage(pageRef);
        
        SVMXC.SFMSearchDelivery obj = new SVMXC.SFMSearchDelivery();
        obj.getUserLocaleKey();
        obj.getUserID();
        obj.getUserOrgID();
        obj.getUserInfo(); //Added for the story BAC-4063
        try{    obj.getSearchInfo();    }
        catch(Exception e){}
        try{    SVMXC.SFMSearchDelivery.JsrGetSearchInfo(''); }
        catch(Exception e){}
        try{    SVMXC.SFMSearchDelivery.JsrGetSearchResult(''); }
        catch(Exception e){}
        try{    SVMXC.SFMSearchDelivery.JsrGetWizardInfo('');   }
        catch(Exception e){}
        
    }
}