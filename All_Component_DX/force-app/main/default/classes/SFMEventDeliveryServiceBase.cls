/**
 * SFM Event Delivery service base
 *
 * @author      Eric Ingram
 * @date        02.22.2013 
 */
public virtual class SFMEventDeliveryServiceBase extends SVMXRestBase {
  
    protected SFMEventDeliveryServiceBase(RestRequest req, RestResponse res){
        super(req, res, 'SFMEventDeliveryServiceIntf');
    }
  
    protected SFMEventDeliveryServiceBase(){}
  
    override public Object invokeMethod(SVMXRestMethodInfo mi){
        Object res = null;
    
        if(mi.MethodName.equals('getData')) res = getData();
        else res = invokeMissingMethod();
    
        return res;
    }
    
    public virtual Object getData() { return null; }
    public virtual Object getDataOlder() { return getData(); }
    public virtual Object getDataOldest() { return getDataOlder(); }
}