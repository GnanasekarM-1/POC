public with sharing class WSCH_Provider_SP_Utils {

	public class sp {

        public WSCH_Provider_SP_StubsV91.JobBookResponse BookJob() {
            system.debug('Entering into mock webserivce call....');
            WSCH_Provider_SP_StubsV91.JobBookResponse response_x= new WSCH_Provider_SP_StubsV91.JobBookResponse();

            //dummy return code
            WSCH_Provider_SP_StubsV91.ReturnCode result = new WSCH_Provider_SP_StubsV91.ReturnCode();
           	result.type_x='OK';
        	result.code=0;
        	result.errNote='Success';

        	//dummy bookJobInfo
            WSCH_Provider_SP_StubsV91.BookInfo bookJobInfo= new WSCH_Provider_SP_StubsV91.BookInfo();
            bookjobInfo.empID='TestEmp1';
            bookjobInfo.FRU='TestFRU1';
            bookJobInfo.IRU='';

			response_x.bookJobInfo=bookJobInfo;
			response_x.result=result;

            return response_x;
        }
	}


	public static WSCH_TechnicianEvent getMockedTechEvent(String workOrderId) {

		WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
		techEvent.setTechnicianExternalID('TestEmp1');
		techEvent.setWorkOrderID(workOrderId);
        techEvent.setStartDateTime(DateTime.now());
        techEvent.setArrivalDateTime(DateTime.now().addMinutes(10));
        techEvent.setFinishDateTime(DateTime.now().addMinutes(60));
       	techEvent.setDispatchStatus('Tentative');

       	return techEvent;
	}
}