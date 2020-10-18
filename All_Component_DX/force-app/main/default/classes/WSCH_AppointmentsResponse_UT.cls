@isTest
public with sharing class WSCH_AppointmentsResponse_UT {

	static testMethod void WSCH_AppointmentsResponse_Test(){
	
	WSCH_AppointmentsResponse res = new WSCH_AppointmentsResponse();
	res.statusCode=0;
	res.statusMessage='status message';
	WSCH_Appointment appointment = new WSCH_Appointment();
	List<WSCH_Appointment> appointmentList = new List<WSCH_Appointment>();
	appointmentList.add(appointment);
	res.appointmentList= appointmentList;
	}
}