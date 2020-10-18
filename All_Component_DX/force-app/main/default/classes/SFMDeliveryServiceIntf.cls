@RestResource(urlMapping='/svmx/rest/SFMDeliveryServiceIntf/*')
global class SFMDeliveryServiceIntf {
	
	@HttpGet
	global static void doGet() {
		
		try{
            RestRequest req = RestContext.request;
			RestResponse res = RestContext.response;
			SFMDeliveryServiceImpl impl = new SFMDeliveryServiceImpl(req, res);
			impl.invokePost();
        }catch(Exception ex)
        {
           // throw new SVMXC.SFM_WrapperDef.PMaxException(ex); 
           throw ex;
        } 
	}
	
	@HttpPost
	global static void doPost() {
		try{
            RestRequest req = RestContext.request;
			RestResponse res = RestContext.response;
			SFMDeliveryServiceImpl impl = new SFMDeliveryServiceImpl(req, res);
			impl.invokePost();
        }catch(Exception ex)
        {
            // throw new SVMXC.SFM_WrapperDef.PMaxException(ex); 
            throw ex;
        } 
	}
}