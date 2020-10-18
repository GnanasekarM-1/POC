public virtual class MobServiceBase extends ComRestBase
{
    public MobServiceBase()   {}

    public MobServiceBase(RestRequest req, RestResponse res)
    {
        super(req, res, 'svmx/MobServiceIntf');
    }

    public virtual Object DataSyncRequest()         { return DataSyncRequest(); }
    public virtual Object MetaSyncRequest()         { return MetaSyncRequest(); }
    public virtual Object getSVMXVersion()          { return getSVMXVersion(); }
    public virtual Object getUserInfo()             { return null; }
    public virtual Object getCRTemplatesInfo()      { return null; }
    public virtual Object retrieveDisplayTags()     { return null; }
    public virtual Object generateWOInvoice()       { return generateWOInvoice(); }
    public virtual Object getLookUpResults()        { return getLookUpResults(); }
    public virtual Object insertSNSDetails()        { return insertSNSDetails(); }
    
    override public Object invokeMethod(ComRestMethodInfo mi)
    {
        Object res = null;
        if(mi.MethodName.equals('DataSyncRequest'))
            res = DataSyncRequest();
        else if(mi.MethodName.equals('MetaSyncRequest')) 
            res = MetaSyncRequest();
        else if(mi.MethodName.equals('getSVMXVersion')) 
            res = getSVMXVersion();
        else if(mi.MethodName.equals('getUserInfo')) 
            res = getUserInfo();
        else if(mi.MethodName.equals('getCRTemplatesInfo')) 
            res = getCRTemplatesInfo();
        else if(mi.MethodName.equals('retrieveDisplayTags')) 
            res = retrieveDisplayTags();
        else if(mi.MethodName.equals('generateWOInvoice')) 
            res = generateWOInvoice();
        else if(mi.MethodName.equals('getLookUpResults')) 
            res = getLookUpResults();
        else if(mi.MethodName.equals('SNSMobClientData'))
            res = insertSNSDetails();
        else
            res = invokeMissingMethod();

        return res;
    }
}