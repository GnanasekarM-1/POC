public virtual class SFMSearchDeliveryServiceBase extends SVMXRestBase{

    protected SFMSearchDeliveryServiceBase(RestRequest req, RestResponse res){
        super(req, res, 'SFMSearchDeliveryServiceIntf');
    }
    
    protected SFMSearchDeliveryServiceBase(){}
    
    override public Object invokeMethod(SVMXRestMethodInfo mi){
        Object res = null;
        
        if(mi.MethodName.equals('getSearchInfo')) res = getSearchInfo();
        else if(mi.MethodName.equals('getSearchInfoOlder')) res = getSearchInfoOlder();
        else if(mi.MethodName.equals('getSearchInfoOldest')) res = getSearchInfoOldest();
        
        else if(mi.MethodName.equals('getSearchResult')) res = getSearchResult();
        else if(mi.MethodName.equals('getSearchResultOlder')) res = getSearchResultOlder();
        else if(mi.MethodName.equals('getSearchResultOldest')) res = getSearchResultOldest();
        
        else if(mi.MethodName.equals('getUserInfo')) res = getUserInfo();
        else if(mi.MethodName.equals('getUserInfoOlder')) res = getUserInfoOlder();
        else if(mi.MethodName.equals('getUserInfoOldest')) res = getUserInfoOldest();

        else res = invokeMissingMethod();
        
        return res;
    }
    
    public virtual Object getSearchInfo() { return null; }
    public virtual Object getSearchInfoOlder() { return getSearchInfo(); }
    public virtual Object getSearchInfoOldest() { return getSearchInfoOlder(); }
    
    public virtual Object getSearchResult() { return null; }
    public virtual Object getSearchResultOlder() { return getSearchResult(); }
    public virtual Object getSearchResultOldest() { return getSearchResultOlder(); }

    public virtual Object getUserInfo() { return null; }
    public virtual Object getUserInfoOlder() { return getUserInfo(); }
    public virtual Object getUserInfoOldest() { return getUserInfoOlder(); }    
}