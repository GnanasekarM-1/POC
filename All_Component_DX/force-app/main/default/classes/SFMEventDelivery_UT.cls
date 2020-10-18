@isTest
private class SFMEventDelivery_UT {

    /*  
  static testMethod void getData_REST_test(){
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = 'getData/';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    
    SVMXC.SFMEventDeliveryServiceIntf.doPost();
  }
  */
  
  static testMethod void getSearchInfo_JSR_test(){
    SVMXC.SFMEventDeliveryController.JsrGetEventData('{}');
  }
  
  static testMethod void JsrGetWizardInfo_JSR_test(){
    SVMXC.SFMEventDeliveryController obj = new SVMXC.SFMEventDeliveryController();
    SVMXC.SFMEventDeliveryController.JsrGetWizardInfo('{}');
  }
}