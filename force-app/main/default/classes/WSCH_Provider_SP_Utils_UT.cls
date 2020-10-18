@isTest
private class WSCH_Provider_SP_Utils_UT {

    static testMethod void bookJobUT() {
    	WSCH_Provider_SP_Utils.sp sp = new WSCH_Provider_SP_Utils.sp();
    	sp.BookJob();	
    }
    
    static testMethod void getMockedTechEventUT() {
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        insert workOrder;
    	WSCH_Provider_SP_Utils.getMockedTechEvent(workOrder.Id);
    }
    
}