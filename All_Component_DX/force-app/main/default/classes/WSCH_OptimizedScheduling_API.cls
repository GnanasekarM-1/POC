global with sharing class WSCH_OptimizedScheduling_API
{
   global class ManageWorkOrdersRequest
   {
        global List<SVMXC__Service_Order__c> workOrders {get; set;}
   }
    
   global class GetAvailableAppointmentsRequest
   {
        global String workOrderNumber {get; set;}
        global Integer apptBatchSize {get; set;}
        global Integer apptBatchNumber {get; set;}
        global WSCH_ApptParam apptParams {get; set;}
   }
    
    global class BookAppointmentRequest
    {
        global SVMXC__Service_Order__c workOrder {get; set;}
        global WSCH_Appointment apptSlot {get; set;}
    }
    
    global static void manageWorkOrders(ManageWorkOrdersRequest request)
    {
       WSCH_OptimizedSchedulingService.manageWorkOrders(request.workOrders);
    }
    
    global static WSCH_AppointmentsResponse getAvailableAppointments(GetAvailableAppointmentsRequest request)
    {
        return WSCH_OptimizedSchedulingService.getAvailableAppointments(request.workOrderNumber, request.apptParams, request.apptBatchSize, request.apptBatchNumber);
    }
    
    global static WSCH_AppointmentsResponse bookAppointment(BookAppointmentRequest request)
    {
        return WSCH_OptimizedSchedulingService.bookAppointment(request.workOrder, request.apptSlot);
    }

}