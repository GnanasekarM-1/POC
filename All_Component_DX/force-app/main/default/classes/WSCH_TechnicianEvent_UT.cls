/**
 Unit Test class for WSCH_TechnicianEvent
**/

@isTest
public with sharing class WSCH_TechnicianEvent_UT {

	private static String workOrderID;
    private static String technicianID;
    private static DateTime startTime;
    private static DateTime arrivalTime;
    private static DateTime finishTime;
    private static String dispatchStatus;
    private static Boolean isFixed;

	static testMethod void testTechnicianEvent() {

		workOrderID = 'wo1234';
		technicianID = 'tech1234';

		String start = DateTime.now().getTime().format();
		String arrival = start;
		String finish = DateTime.now().addHours(1).getTime().format();
		dispatchStatus = 'completed';

		Test.startTest();

		SVMXC.WSCH_TechnicianEvent technicianEvent = new SVMXC.WSCH_TechnicianEvent();

		technicianEvent.setWorkOrderID(workOrderID);
		technicianEvent.getWorkOrderID();

		technicianEvent.setTechnicianExternalID(technicianID);
		technicianEvent.getTechnicianExternalID();

		technicianEvent.setStartDateTime(DateTime.now());
		technicianEvent.getStartDateTime();

		technicianEvent.setArrivalDateTime(DateTime.now().addHours(1));
		technicianEvent.getArrivalDateTime();

		technicianEvent.setFinishDateTime(DateTime.now().addHours(2));
		technicianEvent.getFinishDateTime();

		technicianEvent.setDispatchStatus(technicianID);
		technicianEvent.getDispatchStatus();
		
		technicianEvent.setViolationMessage('');
		technicianEvent.getViolationMessage();
		
		technicianEvent.getFinishDateTimeGmt();
		
		technicianEvent.setIsFixed(true);
		technicianEvent.getIsFixed();
		
		technicianEvent.getStartDateTimeGmt();
		technicianEvent.getArrivalDateTimeGmt();
		
		Double returnHomeDrivingTime=0.0;
		technicianEvent.setReturnHomeDrivingTime(returnHomeDrivingTime);

		Test.stopTest();

	}
}