public with sharing class InstalledBaseTreeImpl {

    public Object getMetadata(String request) {
        
        InstalledBaseTreeUtils ibObjUtils = new InstalledBaseTreeUtils();   
        return ibObjUtils.getMetadata(request);
               
    } 

    public Object getTreeViewData(String request) {
        
        InstalledBaseTreeUtils ibObjUtils = new InstalledBaseTreeUtils();   
        return ibObjUtils.getTreeViewData(request);        
    } 
    public Object getLocationTreeViewData(String request) {
        
        InstalledBaseTreeUtils ibObjUtils = new InstalledBaseTreeUtils();   
        return ibObjUtils.getLocationTreeViewData(request);        
    } 
    public Object saveConfiguredColumnsForIB(String request) {
        
        InstalledBaseTreeUtils ibObjUtils = new InstalledBaseTreeUtils();   
        return ibObjUtils.saveConfiguredColumnsForIB(request);        
    } 
    public Object getChildren(String request) {
        
        InstalledBaseTreeUtils ibObjUtils = new InstalledBaseTreeUtils();   
        return ibObjUtils.getChildren(request);        
    }

}