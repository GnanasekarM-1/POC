public virtual class MobEntServiceBase extends ComRestBase
{
    public MobEntServiceBase()   {}
    
    public MobEntServiceBase(RestRequest req, RestResponse res)
    {
        super(req, res, 'svmx/MobEntServiceIntf');
    }
    
    public virtual Object getSvmxVersion()      { return getSvmxVersion(); }
    public virtual Object updateEvents()        { return updateEvents(); }
    public virtual Object addRecords()          { return addRecords(); }
    public virtual Object saveTargetRecords()   { return saveTargetRecords(); }
    public virtual Object getTags()             { return getTags(); }
    public virtual Object getTasks()            { return getTasks(); }
    public virtual Object getViewLayouts()      { return getViewLayouts(); }
    public virtual Object getWorkOrderMapView() { return getWorkOrderMapView(); }
    public virtual Object getStandaloneCreateLayouts()  { return getStandaloneCreateLayouts(); }
    public virtual Object getEvents()                   { return getEvents(); }
    public virtual Object getPageLayouts()              { return getPageLayouts(); }
    public virtual Object savePageLayouts()             { return savePageLayouts  (); }
    public virtual Object getLookupConfigWithData()     { return getLookupConfigWithData  (); }
    public virtual Object getAccountHistory()           { return getAccountHistory  (); }
    public virtual Object getProductHistory()           { return getProductHistory  (); }
    public virtual Object getPREQGEtPrice()             { return getPREQGEtPrice  (); }
    
    override public Object invokeMethod(ComRestMethodInfo mi)
    {
        Object res = null;
        if(mi.MethodName.equals('getSvmxVersion'))
            res = getSvmxVersion();
        else if(mi.MethodName.equals('updateEvents')) 
            res = updateEvents();
        else if(mi.MethodName.equals('addRecords')) 
            res = addRecords();
        else if(mi.MethodName.equals('saveTargetRecords')) 
            res = saveTargetRecords();
        else if(mi.MethodName.equals('getTags')) 
            res = getTags();
        else if(mi.MethodName.equals('getTasks')) 
            res = getTasks();
        else if(mi.MethodName.equals('getViewLayouts')) 
            res = getViewLayouts();
        else if(mi.MethodName.equals('getWorkOrderMapView')) 
            res = getWorkOrderMapView();
        else if(mi.MethodName.equals('getStandaloneCreateLayouts')) 
            res = getStandaloneCreateLayouts();
        else if(mi.MethodName.equals('getEvents')) 
            res = getEvents();
        else if(mi.MethodName.equals('getPageLayouts')) 
            res = getPageLayouts();
        else if(mi.MethodName.equals('savePageLayouts')) 
            res = savePageLayouts();
        else if(mi.MethodName.equals('getLookupConfigWithData')) 
            res = getLookupConfigWithData();
        else if(mi.MethodName.equals('getAccountHistory')) 
            res = getAccountHistory();
        else if(mi.MethodName.equals('getProductHistory')) 
            res = getProductHistory();
        else if(mi.MethodName.equals('getPREQGEtPrice')) 
            res = getPREQGEtPrice();                                                                         
        else 
            res = invokeMissingMethod();
        
    return res;
    }
}