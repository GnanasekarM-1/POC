@isTest
private class INTF_MobileDeviceTagsUtility_UT
 {

    static testMethod void INTF_MobileDeviceTagsUtility_Test1() 
    {
        INTF_MobileDeviceTagsUtility mobileDeviceTagsUtilityObj = new INTF_MobileDeviceTagsUtility();
        
        List<INTF_WebServicesDef.SVMXMap> mapLst = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap map1 = new INTF_WebServicesDef.SVMXMap();
        map1.key ='IPAD010';
        map1.value = 'TAG007';
        mapLst.add(map1);
        
        INTF_WebServicesDef.SVMXMap map2 = new INTF_WebServicesDef.SVMXMap();
        map2.key = 'IPAD010';
        map2.value = 'TAG006';
        mapLst.add(map2);
        
        INTF_WebServicesDef.SVMXMap map3 = new INTF_WebServicesDef.SVMXMap();
        map3.key ='IPAD004';
        map3.value = 'TAG034';
        mapLst.add(map3);
        
        INTF_WebServicesDef.INTF_SFMRequest tagsReq = new INTF_WebServicesDef.INTF_SFMRequest();
        tagsReq.valueMap = mapLst;
        
        mobileDeviceTagsUtilityObj.getMobileConfigTags(tagsReq);
        
    }
    
    static testMethod void INTF_MobileDeviceTagsUtility_Test2() 
    {
        INTF_MobileDeviceTagsUtility mobileDeviceTagsUtilityObj = new INTF_MobileDeviceTagsUtility();
        INTF_WebServicesDef.INTF_SFMRequest tagsReq = new INTF_WebServicesDef.INTF_SFMRequest();
        mobileDeviceTagsUtilityObj.getMobileConfigTags(tagsReq);
        
    }
}