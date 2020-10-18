@RestResource(urlMapping='/svmx/rest/OPDOCDeliveryServiceIntf/*')
global class OPDOCDeliveryServiceIntf {
      
  @HttpGet
  global static void doGet() {
    
    try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            OPDOCDeliveryServiceImpl impl = new OPDOCDeliveryServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex)
        {
           throw ex;
        } 
  }
  
  @HttpPost
  global static void doPost() {
    
    try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            OPDOCDeliveryServiceImpl impl = new OPDOCDeliveryServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex)
        {
            throw ex;
        } 
  }
}