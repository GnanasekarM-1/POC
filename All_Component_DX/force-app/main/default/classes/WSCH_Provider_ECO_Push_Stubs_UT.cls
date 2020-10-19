@isTest(seeAllData = false)
public with sharing class WSCH_Provider_ECO_Push_Stubs_UT {
    
    static testMethod void testEcoPushStubs() {
    	
    	WSCH_Provider_ECO_Push_Stubs.Booking booking = new WSCH_Provider_ECO_Push_Stubs.Booking();
    	booking.arr = 'arr';
		booking.end_x = 'end_x';
		booking.start = 'start';
		booking.tech = 'tech';
		
		WSCH_Provider_ECO_Push_Stubs.WorkItem workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
		workItem.id = 'id';
		workItem.type = 'type';
		workItem.ignored = true;
		workItem.Booking = new WSCH_Provider_ECO_Push_Stubs.Booking();
		
		WSCH_Provider_ECO_Push_Stubs.PushRequest pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
		pushRequest.changeTime = 'changeTime';
		pushRequest.errorCode = 'errorCode';
		pushRequest.state = 'state';
		
		List<WSCH_Provider_ECO_Push_Stubs.WorkItem> lstWorkItem = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
		lstWorkItem.add(workItem);
		pushRequest.workItems = lstWorkItem;
    }
}