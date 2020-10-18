public class SFMExpressionBuilderImpl extends SFMExpressionBuilderBase{

	public SFMExpressionBuilderImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
	override public Object getParentObjectList() {
		
		SFMExpressionBuilderImpl.ParentObjectListRequest reqObj = (SFMExpressionBuilderImpl.ParentObjectListRequest) 
					deserializeRequestTo(SFMExpressionBuilderImpl.ParentObjectListRequest.class);
					
		SVMXC.SFM_WrapperDef.SFM_Request prequest = new SVMXC.SFM_WrapperDef.SFM_Request();
		SVMXC.SFM_getGlobalObjectList obj  = new SVMXC.SFM_getGlobalObjectList(); 
		List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = prequest.StringMap;
        
        for(Integer i = 0;i<reqObj.kvp.size();i++) {
        	KeyValuePair kvp = reqObj.kvp[i];
        	stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap(kvp.Key, kvp.Value));
        }
        
        return obj.GetParetnObjects(prequest);
		
	}
	
	override public Object getOperators() {
		SVMXC.SFM_WrapperDef.SFM_Request prequest = new SVMXC.SFM_WrapperDef.SFM_Request();
		SVMXC.SFM_getOperators getoperators = new SVMXC.SFM_getOperators();
		List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = prequest.StringMap;
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OPERATORTYPE', 'ALL'));
        return getoperators.SFM_GetOperatorsList(prequest);
	}
	
	override public Object getObjectFieldList() {
		SFMExpressionBuilderImpl.ObjectFieldListRequest reqObj = (SFMExpressionBuilderImpl.ObjectFieldListRequest) 
					deserializeRequestTo(SFMExpressionBuilderImpl.ObjectFieldListRequest.class);
                
		SVMXC.SFM_WrapperDef.SFM_Request prequest = new SVMXC.SFM_WrapperDef.SFM_Request();
		SVMXC.SFM_getObjectFieldList fieldMap = new SVMXC.SFM_getObjectFieldList();
		List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = prequest.StringMap;
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OBJECTNAME', reqObj.name));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'EXPRESSION'));
        return fieldMap.getObjectFieldList(prequest);
	}
	
	override public Object getNamedExpressionList() {
		SFMExpressionBuilderImpl.NamedExpressionListRequest reqObj = (SFMExpressionBuilderImpl.NamedExpressionListRequest) 
					deserializeRequestTo(SFMExpressionBuilderImpl.NamedExpressionListRequest.class);
		
		SVMXC.SFM_WrapperDef.SFM_Request prequest = new SVMXC.SFM_WrapperDef.SFM_Request();			
		SVMXC.SFM_getNamedExpressionList Expression = new SVMXC.SFM_getNamedExpressionList();
		List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = prequest.StringMap;
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OBJECTNAME', reqObj.name));
        return Expression.SFM_getNamedExpressionList(prequest);
	}
	
	public class ParentObjectListRequest{
		public List<KeyValuePair> kvp;
	}
	
	public class KeyValuePair{
		public String Key;
		public String Value;
	}
	
	public class ObjectFieldListRequest{
		public String name;
	}
	
	public class NamedExpressionListRequest{
		public String name;
	}
}