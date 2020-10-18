@isTest
Private class INVT_WrapperDef_UT{

    static testMethod void INVT_WrapperDef_Test(){
		SVMXC.INVT_WrapperDef obj = new SVMXC.INVT_WrapperDef();
		
		SVMXC.INVT_WrapperDef.SVMXMessage obj1 = new SVMXC.INVT_WrapperDef.SVMXMessage();
		SVMXC.INVT_WrapperDef.SVMXMessage obj2 = new SVMXC.INVT_WrapperDef.SVMXMessage('','');
		SVMXC.INVT_WrapperDef.SVMXMessage obj3 = new SVMXC.INVT_WrapperDef.SVMXMessage('','','');
		
		SVMXC.INVT_WrapperDef.INVT_StringMap obj4 = new SVMXC.INVT_WrapperDef.INVT_StringMap();
		SVMXC.INVT_WrapperDef.INVT_StringMap obj5 = new SVMXC.INVT_WrapperDef.INVT_StringMap('','');
		
		SVMXC.INVT_WrapperDef.INVT_StringListMap obj6 = new SVMXC.INVT_WrapperDef.INVT_StringListMap();
		SVMXC.INVT_WrapperDef.INVT_StringListMap obj7 = new SVMXC.INVT_WrapperDef.INVT_StringListMap('', new List<String>());
		obj7.getvalueList();
		obj7.setvalueList(new List<String>());
		
		SVMXC.INVT_WrapperDef.INVT_Request obj8 = new SVMXC.INVT_WrapperDef.INVT_Request();
		obj8.getListOfStringMap();
		obj8.setListOfStringMap(new List<SVMXC.INVT_WrapperDef.INVT_StringMap>());
		obj8.getListOfStringlistMap();
		obj8.setListOfStringlistMap(new List<SVMXC.INVT_WrapperDef.INVT_StringListMap>());
		
		SVMXC.INVT_WrapperDef.INVT_Response obj9 = new SVMXC.INVT_WrapperDef.INVT_Response();
		obj9.getSuccess();
		obj9.setSuccess(true);
		obj9.getListOfMessage();
		obj9.setListOfMessage(new List<SVMXC.INVT_WrapperDef.SVMXMessage>());
		obj9.getValidationSuccess();
		obj9.setValidationSuccess(true);
    }
}