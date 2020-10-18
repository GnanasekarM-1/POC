global virtual class WSCH_DefaultAppointmentHook {
    global enum ProcessWOActions{FORCE_TO_UNRESOURCED, DO_NOTHING, BOOK_SLA_JOB}
    global virtual Boolean canShowAppointmentsPage(SVMXC__Service_Order__c workOrder,List<WSCH_Appointment> appts){
        return true;
    }
    global virtual PageReference displayCustomPage(){
        return null;
    }
    global virtual ProcessWOActions processWorkOrder(){
        return ProcessWOActions.FORCE_TO_UNRESOURCED;
    }
}