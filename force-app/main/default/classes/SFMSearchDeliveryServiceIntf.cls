@RestResource(urlMapping='/svmx/rest/SFMSearchDeliveryServiceIntf/*')
global with sharing class SFMSearchDeliveryServiceIntf {

    @HttpGet
    global static void doGet() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            SFMSearchDeliveryServiceImpl impl = new SFMSearchDeliveryServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex){ 
            throw ex;
        } 
    }
    
    @HttpPost
    global static void doPost() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            SFMSearchDeliveryServiceImpl impl = new SFMSearchDeliveryServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex){ 
            throw ex;
        } 
    }
}