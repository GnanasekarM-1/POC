@isTest(seeAllData = true)
private class INTF_MobileGetPageLayout_UT {

    static testMethod void INTF_MobileGetPageLayout_TestMethod() {
        INTF_MobileGetPageLayout optimizePageData = new INTF_MobileGetPageLayout();
        set<string> lstPageIds = new set<string>(); 
        string syncReqId = 'ABCDEFGHIJKLMANOPQRSTUVWXYZ';
        for(SVMXC__Page_Layout__c PgData : [select id from SVMXC__Page_Layout__c limit 1])
            lstPageIds.add(PgData.Id);
        
        list<INTF_WebServicesDef.INTF_Response_PageUI> lstResponse = optimizePageData.INTF_GetPageLayout(lstPageIds, syncReqId);
        
        system.debug(loggingLevel.WARN, 'Response Size: ' + lstResponse.size() + ' :Response: ' + lstResponse);
    }
}