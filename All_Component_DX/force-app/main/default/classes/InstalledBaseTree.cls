global with sharing class InstalledBaseTree {

    public InstalledBaseTree() {

    }
    @RemoteAction
    global static String JsrGetMetadata(String request){     
        InstalledBaseTreeImpl ibImpl = new InstalledBaseTreeImpl();     
        return JSON.serialize(ibImpl.getMetadata(request));

     }

     @RemoteAction
     global static String JsrGetTreeViewData(String request){     
        InstalledBaseTreeImpl ibImpl = new InstalledBaseTreeImpl();     
        return JSON.serialize(ibImpl.getTreeViewData(request));
     }

     @RemoteAction
     global static String JsrGetLocationTreeViewData(String request){     
        InstalledBaseTreeImpl ibImpl = new InstalledBaseTreeImpl();     
        return JSON.serialize(ibImpl.getLocationTreeViewData(request));
     }

     @RemoteAction
     global static String JsrSaveConfiguredColumnsForIB(String request){     
        InstalledBaseTreeImpl ibImpl = new InstalledBaseTreeImpl();     
        return JSON.serialize(ibImpl.saveConfiguredColumnsForIB(request));
     }

     @RemoteAction
     global static String JsrGetChildren(String request){     
        InstalledBaseTreeImpl ibImpl = new InstalledBaseTreeImpl();     
        return JSON.serialize(ibImpl.getChildren(request));
     }
}