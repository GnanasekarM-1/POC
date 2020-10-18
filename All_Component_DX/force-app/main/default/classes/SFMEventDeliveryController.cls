global with sharing class SFMEventDeliveryController {

  public SFMEventDeliveryController(){}
  
  @RemoteAction
    global static Object JsrGetEventData(String requestStr){
        
        return JSON.serialize(new SVMXC.SFMEventDeliveryServiceImpl().getDataInternal());
    }
    
    @RemoteAction
    global static Object JsrGetWizardInfo(String requestStr){
        
        SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest wir = (SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMWizardDeliveryServiceImpl.WizardInfoRequest.class);

        return JSON.serialize(new SVMXC.SFMWizardDeliveryServiceImpl().getWizardInfoInternal(wir));
    }
}