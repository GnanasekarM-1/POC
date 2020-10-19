/**
    A common interface to define all the operations supported by the Real Time Optimization functionality/plugin.
    All the service providers who are providing real time optimization should implement this interface.
*/

public interface WSCH_IRealTimeOptimizer{

    WSCH_WorkOrderResponse manageWorkOrders(List<SVMXC__Service_Order__c> workOrders);

    WSCH_AppointmentsResponse getAvailableAppointments(SVMXC__Service_Order__c workOrder, WSCH_ApptParam apptParamObj, Integer apptBatchSize, Integer apptBatchNumber);
    
    //WSCH_AppointmentsResponse getAvailableAppointments(SVMXC__Service_Order__c workOrder, Integer apptBatchSize, Integer apptBatchNumber);

    WSCH_AppointmentsResponse bookAppointment(SVMXC__Service_Order__c workOrder, WSCH_Appointment apptSlot);

    WSCH_WorkOrderUpdateResponse getWorkOrderUpdates(SVMXC__Territory__c territory);

    WSCH_NonWOEventResponse manageNonWorkOrderEvents(List<SVMXC__SVMX_Optimizer__c> events);

    List<SVMXC__SVMX_Optimizer__c> cancelWorkOrders(List<SVMXC__SVMX_Optimizer__c> workOrders);

    String getJobStatus(SVMXC__Service_Order__c workOrder);
    
    Boolean manageSchedulingResults(String strJobInfo);
    
    WSCH_WorkOrderResponse manageDependencyBooking(List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstDependencyWOs); 

     //WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse manageDependencyGroup(List<Service_Order_Group_Dependency__c> serviceOrderList);
     WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse manageDependencyGroup(String multiJobId, List<Service_Order_Dependency__c> serviceOrderList);
    /*@kundan- Commented this code as this functionality is not required for the current release.
     void cancelDependencyGroup(List<String> multiJobId, List<String> WorkOrderIds);
     */
}