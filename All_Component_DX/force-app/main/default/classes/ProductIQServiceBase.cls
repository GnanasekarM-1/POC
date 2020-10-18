public virtual class ProductIQServiceBase extends SVMXRestBase{
    
    protected ProductIQServiceBase (RestRequest req, RestResponse res){
        super(req, res, 'ProductIQServiceIntf');
    }
    
    protected ProductIQServiceBase (){}
    
    override public Object invokeMethod(SVMXRestMethodInfo mi){
        Object res = null;
        
        if(mi.MethodName.equals('getUserConfiguration')) res = getUserConfiguration();
        else if(mi.MethodName.equals('getUserConfigurationOlder')) res = getUserConfigurationOlder();
        else if(mi.MethodName.equals('getUserConfigurationOldest')) res = getUserConfigurationOldest();
        
        else if(mi.MethodName.equals('getProductIQTemplates')) res = getTemplates();
        else if(mi.MethodName.equals('getProductIQTemplatesOlder')) res = getTemplatesOlder();
        else if(mi.MethodName.equals('getProductIQTemplatesOldest')) res = getTemplatesOldest();
        
        else if(mi.MethodName.equals('getTemplates')) res = getTemplates();
        else if(mi.MethodName.equals('getTemplatesOlder')) res = getTemplatesOlder();
        else if(mi.MethodName.equals('getTemplatesOldest')) res = getTemplatesOldest();
        
        else if(mi.MethodName.equals('getTranslations')) res = getTranslations();
        else if(mi.MethodName.equals('getTranslationsOlder')) res = getTranslationsOlder();
        else if(mi.MethodName.equals('getTranslationsOldest')) res = getTranslationsOldest();
        
        else if(mi.MethodName.equals('insertRecords')) res = insertRecords();
        else if(mi.MethodName.equals('insertRecordsOlder')) res = insertRecordsOlder();
        else if(mi.MethodName.equals('insertRecordsOldest')) res = insertRecordsOldest();
        
        else if(mi.MethodName.equals('updateRecords')) res = updateRecords();
        else if(mi.MethodName.equals('updateRecordsOlder')) res = updateRecordsOlder();
        else if(mi.MethodName.equals('updateRecordsOldest')) res = updateRecordsOldest();
        
        else res = invokeMissingMethod();
        
        return res;
    }
    
    public virtual Object getUserConfiguration() { return null; }
    public virtual Object getUserConfigurationOlder() { return getUserConfiguration(); }
    public virtual Object getUserConfigurationOldest() { return getUserConfigurationOlder(); }
    
    public virtual Object getTemplates() { return null; }
    public virtual Object getTemplatesOlder() { return getTemplates(); }
    public virtual Object getTemplatesOldest() { return getTemplatesOlder(); }
    
    public virtual Object getTranslations() { return null; }
    public virtual Object getTranslationsOlder() { return getTranslations(); }
    public virtual Object getTranslationsOldest() { return getTranslationsOlder(); }
    
    public virtual Object insertRecords() { return null; }
    public virtual Object insertRecordsOlder() { return insertRecords(); }
    public virtual Object insertRecordsOldest() { return insertRecordsOlder(); }
    
    public virtual Object updateRecords() { return null; }
    public virtual Object updateRecordsOlder() { return updateRecords(); }
    public virtual Object updateRecordsOldest() { return updateRecordsOlder(); }
}