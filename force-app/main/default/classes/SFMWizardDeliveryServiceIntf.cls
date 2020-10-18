@RestResource(urlMapping='/svmx/rest/SFMWizardDeliveryServiceIntf/*')
global with sharing class SFMWizardDeliveryServiceIntf {

	@HttpPost
	global static void doPost() {
		try{
           	RestRequest req = RestContext.request;
			RestResponse res = RestContext.response;
			SFMWizardDeliveryServiceImpl impl = new SFMWizardDeliveryServiceImpl(req, res);
			impl.invokePost();
        }catch(Exception ex){ 
            throw ex;
        } 
	}
}