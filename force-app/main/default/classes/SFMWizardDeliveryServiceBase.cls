public virtual class SFMWizardDeliveryServiceBase extends SVMXRestBase {

	protected SFMWizardDeliveryServiceBase(RestRequest req, RestResponse res){
		super(req, res, 'SFMWizardDeliveryServiceIntf');
	}
	
	protected SFMWizardDeliveryServiceBase(){}
	
	override public Object invokeMethod(SVMXRestMethodInfo mi){
		Object res = null;
		
		if(mi.MethodName.equals('getWizardInfo')) res = getWizardInfo();
		else if(mi.MethodName.equals('getWizardInfoOlder')) res = getWizardInfoOlder();
		else if(mi.MethodName.equals('getWizardInfoOldest')) res = getWizardInfoOldest();

		else res = invokeMissingMethod();
		
		return res;
	}
	
	public virtual Object getWizardInfo() { return null; }
	public virtual Object getWizardInfoOlder() { return getWizardInfo(); }
	public virtual Object getWizardInfoOldest() { return getWizardInfoOlder(); }
}