@RestResource(urlMapping='/svmx/rest/ProductIQServiceIntf/*')
global class ProductIQServiceIntf {
    
    @HttpGet
    global static void doGet() {
        
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            ProductIQServiceImpl impl = new ProductIQServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex)
        {
           // throw new SVMXDEV.SFM_WrapperDef.PMaxException(ex); 
           throw ex;
        } 
    }
    
    @HttpPost
    global static void doPost() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            ProductIQServiceImpl impl = new ProductIQServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex)
        {
            // throw new SVMXDEV.SFM_WrapperDef.PMaxException(ex); 
            throw ex;
        } 
    }
}