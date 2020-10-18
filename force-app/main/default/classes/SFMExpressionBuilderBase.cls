public virtual class SFMExpressionBuilderBase  extends SVMXRestBase{

	protected SFMExpressionBuilderBase(RestRequest req, RestResponse res){
		super(req, res, 'SFMExpressionBuilderIntf');
	}
	
	override public Object invokeMethod(SVMXRestMethodInfo mi){
		Object res = null;
		
		if(mi.MethodName.equals('getParentObjectList')) res = getParentObjectList();
		else if(mi.MethodName.equals('getOperators')) res = getOperators();
		else if(mi.MethodName.equals('getObjectFieldList')) res = getObjectFieldList();
		else if(mi.MethodName.equals('getNamedExpressionList')) res = getNamedExpressionList();
		
		else res = invokeMissingMethod();
		
		return res;
	}
	
	public virtual Object getParentObjectList() { return null; }
	public virtual Object getOperators() { return null; }
	public virtual Object getObjectFieldList() { return null; }
	public virtual Object getNamedExpressionList() { return null; }
}