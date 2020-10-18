@RestResource(urlMapping='/svmx/rest/IOTServiceIntf/*')
global class IOTServiceIntf {
    
    @HttpGet
    global static void doGet() {
        
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            IOTServiceImpl impl = new IOTServiceImpl(req, res);
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
            IOTServiceImpl impl = new IOTServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex)
        {
            // throw new SVMXDEV.SFM_WrapperDef.PMaxException(ex); 
            throw ex;
        } 
    }
}