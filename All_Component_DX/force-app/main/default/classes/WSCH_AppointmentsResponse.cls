global with sharing class WSCH_AppointmentsResponse {
    global Integer statusCode {get; set;}
    global String statusMessage {get; set;}
    global List<WSCH_Appointment> appointmentList {get; set;}
    global Boolean viewMore {get; set;}
}