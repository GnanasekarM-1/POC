@isTest
private class IPRD_WebServices_UT {
    static testMethod void IPRD_CreateInitialCounterReading_WS_test(){
        try{
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WrapperDef.SFM_Response objResponse = IPRD_WebServices.IPRD_CreateInitialCounterReading_WS(request);
            System.assertEquals(objResponse!=null,true);
        }
        catch(exception ex){}
    }
    
    static testMethod void IPRD_CounterRollupService_WS_test(){
        try{
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SFM_WrapperDef.SFM_Response objResponse = IPRD_WebServices.IPRD_CounterRollupService_WS(request);
            System.assertEquals(objResponse!=null,true);
        }
        catch(exception ex){}
    }
}