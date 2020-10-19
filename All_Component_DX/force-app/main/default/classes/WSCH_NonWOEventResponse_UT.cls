@isTest
public with sharing class WSCH_NonWOEventResponse_UT {

	static testMethod void testNonWOSvmxEventCreate() {
		Test.startTest();
		
		WSCH_NonWOEventResponse nonWoEventResponse = new WSCH_NonWOEventResponse();
		
		SVMXC__SVMX_Optimizer__c svmxOptimizerEvent = new SVMXC__SVMX_Optimizer__c();
		List<SVMXC__SVMX_Optimizer__c> lstOfSvmxOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
		lstOfSvmxOptimizerEvent.add(svmxOptimizerEvent);
		
		nonWoEventResponse.setEvents(lstOfSvmxOptimizerEvent);
		nonWoEventResponse.getEvents();
		
		WSCH_TechnicianEvent technicianEvent = new WSCH_TechnicianEvent();
		List<WSCH_TechnicianEvent> lstOfTechEvents = new List<WSCH_TechnicianEvent>();
		lstOfTechEvents.add(technicianEvent);
		
		nonWoEventResponse.setTechEvents(lstOfTechEvents);
		nonWoEventResponse.getTechEvents();
		
		Test.stopTest();
	}
}