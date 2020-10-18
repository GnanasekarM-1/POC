@isTest
private class SFMSearchDeliveryServiceBase_UT {

    class Derived extends SFMSearchDeliveryServiceBase {
        Derived() {
            try {
                super(null,null);
            }   catch( Exception ex ) {}         
        }
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds() {
        
        Test.startTest();
        
        SVMXRestMethodInfo info = new SVMXRestMethodInfo();        
        SFMSearchDeliveryServiceBase base = new Derived();
        
        info.MethodName = 'getSearchInfo';
        base.invokeMethod(info);
        
        info.MethodName = 'getSearchInfoOlder';
        base.invokeMethod(info);
        
        info.MethodName = 'getSearchInfoOldest';
        base.invokeMethod(info);
        
        info.MethodName = 'getSearchResult';
        base.invokeMethod(info);
        
        info.MethodName = 'getSearchResultOlder';
        base.invokeMethod(info);
        
        info.MethodName = 'getSearchResultOldest';
        base.invokeMethod(info);
        
        info.MethodName = 'getUserInfo';
        base.invokeMethod(info);    
        
        info.MethodName = 'getUserInfoOlder';
        base.invokeMethod(info);    

        info.MethodName = 'getUserInfoOldest';
        base.invokeMethod(info);            
        
        info.MethodName = '';
        base.invokeMethod(info);
        
        try {
            SFMSearchDeliveryServiceIntf.doPost();
        } catch( Exception ex ) {}
        
        try {
            SFMSearchDeliveryServiceIntf.doGet();
        } catch( Exception ex ) {}        
                
        SFMSearchDeliveryServiceImpl impl = new SFMSearchDeliveryServiceImpl();
        try {
            impl.getSearchInfo();
        } catch( Exception ex ) {}
        try {
            impl.getSearchResult();
        } catch( Exception ex ) {}
        try {
            impl.getSearchResultInternal(new SFMSearchDeliveryServiceImpl.SearchResultRequest() );
        } catch( Exception ex ) {}
        try {
            impl.getUserInfo();
        } catch( Exception ex ) {}
        Test.stopTest();
    }
}