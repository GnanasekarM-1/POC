/**
 Unit Test class for WSCH_TechnicianEvent
**/

@isTest
public with sharing class WSCH_WorkOrderResponse_UT {

    private List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
    
    private List<WSCH_TechnicianEvent> lstTechEvent = new List<WSCH_TechnicianEvent>();
    
    static testMethod void testTechnicianEvent() {
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
        List<SVMXC__Service_Order__c> lstOfWorkOrder = new List<SVMXC__Service_Order__c>();
        lstOfWorkOrder.add(workOrder1);
        lstOfWorkOrder.add(workOrder2);
        lstOfWorkOrder.add(workOrder3);
        
        
        WSCH_TechnicianEvent technicianEvent1 = new WSCH_TechnicianEvent();
        WSCH_TechnicianEvent technicianEvent2 = new WSCH_TechnicianEvent();
        WSCH_TechnicianEvent technicianEvent3 = new WSCH_TechnicianEvent();
        List<WSCH_TechnicianEvent> lstOfTechnicianEvent = new List<WSCH_TechnicianEvent>();
        lstOfTechnicianEvent.add(technicianEvent1);
        lstOfTechnicianEvent.add(technicianEvent2);
        lstOfTechnicianEvent.add(technicianEvent3);
        
        
        Test.startTest();
        
        WSCH_WorkOrderResponse workOrderResponse = new WSCH_WorkOrderResponse();
        workOrderResponse.setLstWorkOrder(lstOfWorkOrder);
        workOrderResponse.getLstWorkOrder();
        
        workOrderResponse.setLstTechEvent(lstOfTechnicianEvent);
        workOrderResponse.getLstTechEvent();
        
        DateTime dt = DateTime.now();
        workOrderResponse.setChangeTime(dt);
        workOrderResponse.getChangeTime();
        
        Test.stopTest();
        
    }

}