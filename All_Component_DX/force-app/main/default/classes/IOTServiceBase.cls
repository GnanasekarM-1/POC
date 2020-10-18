public virtual class IOTServiceBase extends IOTRestBase{
    
    protected IOTServiceBase (RestRequest req, RestResponse res){
        super(req, res, 'IOTServiceIntf');
    }
    
    protected IOTServiceBase (){}
    
    override public Object invokeMethod(IOTRestMethodInfo mi){
        Object res = null;
        
        if(mi.VersionNumber == '1.0'){
            if(mi.MethodName.equals('createSR')) res = createSR();
            else if(mi.MethodName.equals('createCase')) res = createCase(); 
            else if(mi.MethodName.equals('alertHandler')) res = alertHandler();         
            else res = invokeMissingMethod();
        } else if(mi.VersionNumber == '2.0'){
            res = iotGenericHandler(mi.MethodName);
        }
        
        
        return res;
    }
    
    public virtual Object createSR() { return null; }
    public virtual Object createCase() { return null; }
    public virtual Object alertHandler() { return null; }
    public virtual Object iotGenericHandler(String eventName) { return null; }

}