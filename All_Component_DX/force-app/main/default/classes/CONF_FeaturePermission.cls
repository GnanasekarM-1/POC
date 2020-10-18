global with sharing class CONF_FeaturePermission {

@RemoteAction
/* This function provide the metada for initial page load, which include profile details ... */
    global static String JsrGetMetadata(String requestStr){     
        CONF_FeaturePermissionImpl featurepermissionImpl = new CONF_FeaturePermissionImpl();     
        return JSON.serialize(featurepermissionImpl.getMetadata());
     }
 @RemoteAction
 /* This function provide the all user for given profile ID.*/
    global static String JsrGetUserData(String requestStr){     
        CONF_FeaturePermissionImpl featurepermissionImpl = new CONF_FeaturePermissionImpl();     
        return JSON.serialize(featurepermissionImpl.getUsersData(requestStr));
     }
  @RemoteAction
  /*This function add / delete the recods from feature permission oobject.*/
    global static String JsrSaveData(String requestStr){     
        CONF_FeaturePermissionImpl featurepermissionImpl = new CONF_FeaturePermissionImpl();     
        return JSON.serialize(featurepermissionImpl.saveData(requestStr));
     }
}