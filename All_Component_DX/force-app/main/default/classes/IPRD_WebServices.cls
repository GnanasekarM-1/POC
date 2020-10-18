/*--------------------------------------------File Definition ----------------------*/
/*This Class will hold the services related to Installed Products.
Created as part of Sum 15 Sprint 5 for PB-XRAY 107 and 98 requirement*/

global class IPRD_WebServices{
    //Webservice to create initial counter reading for the qualified IBs based on Valid Counter Rule
    Webservice static SFM_WrapperDef.SFM_Response IPRD_CreateInitialCounterReading_WS(SFM_WrapperDef.SFM_Request request){
        SVMXC.IPRD_CreateInitialCounterReading objCounterReading = new SVMXC.IPRD_CreateInitialCounterReading();
        return objCounterReading.executeService(request);           
    }
    
    //This service is used to create the counter rollup
    Webservice static SFM_WrapperDef.SFM_Response IPRD_CounterRollupService_WS(SFM_WrapperDef.SFM_Request request){
        SVMXC.IPRD_CounterRollupService objCounterRollup = new SVMXC.IPRD_CounterRollupService();
        return objCounterRollup.executeService(request);            
    }
}