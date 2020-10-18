@isTest
public with sharing class WSCH_WorkOrderUpdateResponse_UT {

    static testMethod void testWOUpdateResponse() {
        test.startTest();
        
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        String timeStampOut = '' + DateTime.now().getTime()/1000;
        boolean more = true;
        
        WSCH_WorkOrderUpdateResponse woUpdateResponse = new WSCH_WorkOrderUpdateResponse();
        woUpdateResponse.getTimeStampOut();
        woUpdateResponse.getWoResponse();
        woUpdateResponse.isMore();
        
        woUpdateResponse.setMore(more);
        woUpdateResponse.setTimeStampOut(timeStampOut);
        woUpdateResponse.setWoResponse(woResponse);
        
        test.stopTest();
    }
}