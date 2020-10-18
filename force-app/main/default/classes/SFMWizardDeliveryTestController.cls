global with sharing class SFMWizardDeliveryTestController {

	public SFMWizardDeliveryTestController(){}
	
	@RemoteAction
    global static Object JsrGetWizardInfo(String requestStr){
        
        SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest wir = (SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest.class);

        return JSON.serialize(new SVMXC.SFMWizardDeliveryServiceImpl().getWizardInfoInternal(wir));
    }
}