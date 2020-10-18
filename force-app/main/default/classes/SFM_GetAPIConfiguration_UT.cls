@isTest(SeeAllData = true)
private class SFM_GetAPIConfiguration_UT{
    static testMethod void getAPIConfiguration_Test1(){
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('HEADEROBJECTNAME','ALL'));
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = new SVMXC.SFM_WrapperDef.SFM_Request();
        objRequest.stringMap = lstStringMap;
        
        SVMXC.SFM_GetAPIConfiguration objSFM_GetAPIConfiguration = new SVMXC.SFM_GetAPIConfiguration();
        objSFM_GetAPIConfiguration.getAPIConfiguration(objRequest);
        objSFM_GetAPIConfiguration.getAPIConfiguration(null);
    }
}