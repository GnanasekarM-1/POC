global with sharing class IOTSetup {

    @RemoteAction
    global static Object JsrGetSetupMetadata(String requestStr){ 
           
       IOTSetupImpl iotImpl = new IOTSetupImpl();     
       return JSON.serialize(iotImpl.getSetupMetadata());   
    }
    
    
    @RemoteAction
    global static Object JsrSave(String requestStr){ 
           
       IOTSetupImpl iotImpl = new IOTSetupImpl();     
       return JSON.serialize(iotImpl.save(requestStr));   
    }
    
    @RemoteAction
    global static pagereference JsrBackToSetupHome(String requestStr)
    {
        String location = '/apex/CONF_SetupHome';
        PageReference pr = new PageReference(location);
        pr.setredirect(true);
        return pr;

    }
    @RemoteAction
    global static Object JsrDescribeObject(String requestStr){ 
           
       IOTSetupImpl iotImpl = new IOTSetupImpl();     
       return JSON.serialize(iotImpl.describeObject(requestStr));   
    }
}