/**
    The starting point for the abstraction layer. Encapsulates all the methods related to Real Time Optimization.
    Is invoked either by an Apex trigger or Apex Scheduler.Its purpose is to invoke the necessary plugins and return the response.
    It does not validate the response
*/
public with sharing class WSCH_OptimizedSchedulingService {

    public static boolean triggerExecuted = false;
    public static boolean isCallOutExecuted = false;
    
    //this flag is set to true when DC calling the web service(DCON_Work_Order_WS.DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2) during unassign the tech.
    public static boolean isUnAssignDC = false; 
    
    /**
        Invokes the manageWorkOrders API method of RTO Plugin.
        This method can be invoked either in a Sync call or in an Async call (Future call).
    */
    public static void manageWorkOrders(List<SVMXC__Service_Order__c> workOrders){
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_RealTimeOptimizer.manageWorkOrders(workOrders);
        WSCH_AuditLogger.debug('End of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('End of Future call :heap size - ' + Limits.getHeapSize());
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageWorkOrders :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }
    
    public static void manageDependencyBooking(List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstDependencyWOs) {
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_RealTimeOptimizer.manageDependencyBooking(lstOfServiceOrderGroupDependency,lstDependencyWOs);
        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService:manageDependencyBooking::End of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService:manageDependencyBooking::End of Future call :heap size - ' + Limits.getHeapSize());
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageDependencyGroup :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }

     
     public static void manageDependencyGroup(String multiJobId, List<Service_Order_Dependency__c> serviceOrderList){
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_RealTimeOptimizer.manageDependencyGroup(multiJobId,serviceOrderList);
        WSCH_AuditLogger.debug('End of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('End of Future call :heap size - ' + Limits.getHeapSize());
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageDependencyGroup :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }
     /*@kundan- Commented this code as this functionality is not required for the current release.
    public static void cancelDependencyGroup(List<String> multiJobId, List<String> WorkOrderIds){
        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: cancelDependencyGroup :: dependency group to be deleted list size :: '+ multiJobId.size());
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_RealTimeOptimizer.cancelDependencyGroup(multiJobId, WorkOrderIds);
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: cancelWorkOrders :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        //WSCH_AuditLogger.setAPIName(WSCH_Constants.API_CANCEL_JOB);
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }*/
     /**
        Invokes the getAvailableAppointments API method of RTO Plugin.
    */
    public static WSCH_AppointmentsResponse getAvailableAppointments(String woNumber, WSCH_ApptParam apptParamObj, Integer apptBatchSize, Integer apptBatchNumber){
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        Long startTime = Datetime.now().getTime();
        techSlotResponse=WSCH_Plugin_RealTimeOptimizer.getAvailableAppointments(woNumber,apptParamObj,apptBatchSize,apptBatchNumber);
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: getAvailableAppointments :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setAPIName(WSCH_Constants.API_OFFER_APPT);
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        return techSlotResponse;
    }
    
    /**
        Invokes the getAvailableAppointments API method of RTO Plugin. Without WSCH_ApptParam parameter
    */
    /*public static WSCH_AppointmentsResponse getAvailableAppointments(String woNumber, Integer apptBatchSize, Integer apptBatchNumber){
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        Long startTime = Datetime.now().getTime();
        techSlotResponse=WSCH_Plugin_RealTimeOptimizer.getAvailableAppointments(woNumber,apptBatchSize,apptBatchNumber);
        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: getAvailableAppointments :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        return techSlotResponse;
    }*/
    
    /**
        Invokes the scheduleTechnicianSlot API method of RTO plugin.
        Gets a TechnicianSlotReponse object, which contains the status of the API call (status code & status message)
        along with the list of WSCH_Appointment objects
    */
    public static WSCH_AppointmentsResponse bookAppointment(SVMXC__Service_Order__c workOrder, WSCH_Appointment apptSlot){

        Long startTime = Datetime.now().getTime();
        WSCH_AppointmentsResponse technicianSlotResponse = WSCH_Plugin_RealTimeOptimizer.bookAppointment(workOrder, apptSlot);
        WSCH_AuditLogger.debug('Inside optimizedSchedulingService bookAppt, technicianSlotResponse - ' + technicianSlotResponse);
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: bookAppointment :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setAPIName(WSCH_Constants.API_BOOK_APPT);
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        return technicianSlotResponse;
    }

    /**
        Invokes the getChangedWorkOrders API method of RTO plugin.
        This method can be invoked either in a Sync call or in an Async call (Future call).
    */
    public static void getChangedWorkOrders(SVMXC__Territory__c territory) {

        Long startTime = Datetime.now().getTime();
        //TO DO: need to call SP_RealTimeOptimizer - getWorkOrderUpdates();
        WSCH_Plugin_RealTimeOptimizer.getWorkOrderUpdates(territory);
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: getChangedWorkOrders :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setAPIName(WSCH_Constants.API_GET_CHANGED_WORK_ITEMS);
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }

     /**
        Invokes the manageNonWorkOrderEvents API method of RTO Plugin.
        This method can be invoked either in a Sync call or in an Async call (Future call).
    */
    public static void manageNonWorkOrderEvents(List<SVMXC__SVMX_Optimizer__c> events) {

        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageNonWorkOrderEvents :: Non work order events list size :: '+ events.size());
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_RealTimeOptimizer.manageNonWorkOrderEvents(events);
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageNonWorkOrderEvents :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }


     /**
        Invokes the cancelWorkOrders API method of RTO Plugin.
        This method can be invoked either in a Sync call or in an Async call (Future call).
    */
    public static void cancelWorkOrders(List<SVMXC__SVMX_Optimizer__c> workOrders) {

        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: cancelWorkOrders :: Work orders to be deleted list size :: '+ workOrders.size());
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_RealTimeOptimizer.cancelWorkOrders(workOrders);
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: cancelWorkOrders :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setAPIName(WSCH_Constants.API_CANCEL_JOB);
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    }
    
     /**
        Invokes the manageTechnicians API method of Technician service Plugin.
        This method can be invoked either in a Sync call or in an Async call (Future call).
    */    
    public static void manageTechnicians(List<SVMXC__SVMX_Optimizer__c> technicians){ 
        Long startTime = Datetime.now().getTime();
        WSCH_Plugin_TechnicianService.manageTechnicians(technicians);
        WSCH_AuditLogger.debug('End of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('End of Future call :heap size - ' + Limits.getHeapSize());
        //WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageTechnicians :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
    } 
    
    /**
        Invokes the manageWorkOrdersResult API method of RTO Plugin.
        This method can be invoked either in a Sync call or in an Async call (Future call).
    */
    public static Boolean manageSchedulingResults(String strJobInfo) {
        WSCH_AuditLogger.debug('WSCH_OptimizedSchedulingService :: manageWorkOrdersResult :: strJobInfo :: '+ strJobInfo);
        Boolean isCallSuccess = false;
        Long startTime = Datetime.now().getTime();
        isCallSuccess = WSCH_Plugin_RealTimeOptimizer.manageSchedulingResults(strJobInfo);
        WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        WSCH_AuditLogger.finish();
        return isCallSuccess;
    }
}