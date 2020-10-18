@isTest
private class WSCH_DefaultAppointmentHook_UT {

    static testMethod void canShowAppointmentsPageUT() {
        WSCH_DefaultAppointmentHook hook = new WSCH_DefaultAppointmentHook();
		SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
		List<WSCH_Appointment> appts = new List<WSCH_Appointment>();
        hook.canShowAppointmentsPage(workOrder, appts);
    }
    
    static testMethod void displayCustomPageUT() {
        WSCH_DefaultAppointmentHook hook = new WSCH_DefaultAppointmentHook();
        hook.displayCustomPage();
    }
    
    static testMethod void processWorkOrderUT() {
        WSCH_DefaultAppointmentHook hook = new WSCH_DefaultAppointmentHook();
        hook.processWorkOrder();
    }
    
    static testMethod void extensabilityTest(){
    	WSCH_DefaultCalloutHook hook = new WSCH_DefaultCalloutHook();
    	hook.afterCall(null, null, null);
    	hook.configure();
    }
}