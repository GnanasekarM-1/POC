global with sharing class ProductIQSetup {

    @RemoteAction
    global static Object JsrGetSetupMetadata(String requestStr){     
      
      ProductIQSetupImpl objDocDelImpl = new ProductIQSetupImpl();     
      return JSON.serialize(objDocDelImpl.getSetupMetadata());  
    }
    
    @RemoteAction
    global static Object JsrSaveSetupData(String requestStr){     
      
      ProductIQSetupImpl objDocDelImpl = new ProductIQSetupImpl();     
      return JSON.serialize(objDocDelImpl.saveSetupData(requestStr));
    }
    
    @RemoteAction
    global static Object JsrGetTemplateFromIB(String requestStr){
      ProductIQSetupImpl objDocDelImpl = new ProductIQSetupImpl();     
      return JSON.serialize(objDocDelImpl.getTemplateFromIB(requestStr));
    }

    @RemoteAction
    global static Object JsrSaveTechnicalAttributePicklistDefinition(String requestStr){
      ProductIQSetupImpl objDocDelImpl = new ProductIQSetupImpl();     
      return JSON.serialize(objDocDelImpl.saveTechnicalAttributePicklistDefinition(requestStr));
    }

    @RemoteAction
    global static Object JsrDeleteTechnicalAttributePicklistDefinition(String requestStr){
      ProductIQSetupImpl objDocDelImpl = new ProductIQSetupImpl();     
      return JSON.serialize(objDocDelImpl.deleteTechnicalAttributePicklistDefinition(requestStr));
    }
    
    @RemoteAction
    global static pagereference JsrBackToSetupHome(String requestStr)
    {
        String location = '/apex/CONF_SetupHome';
        PageReference pr = new PageReference(location);
        pr.setredirect(true);
        return pr;

    }
}