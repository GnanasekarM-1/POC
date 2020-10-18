@isTest(seeAllData = true)
private class WSCH_OptimizedScheduling_API_UT {

    static testMethod void bookJobTest() {
        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrders.add(workOrder);   
        
        WSCH_OptimizedScheduling_API.ManageWorkOrdersRequest request = new WSCH_OptimizedScheduling_API.ManageWorkOrdersRequest();
        request.workOrders = workOrders;
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedScheduling_API.manageWorkOrders(request);
    }
    
    static testMethod void offerAppointmentTest() {
    	WSCH_OptimizedScheduling_API.GetAvailableAppointmentsRequest offerReq= new WSCH_OptimizedScheduling_API.GetAvailableAppointmentsRequest();
    	offerReq.apptBatchNumber=1;
    	offerReq.apptBatchSize=5;
    	offerReq.workOrderNumber='Testwo';
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        try{
        	WSCH_OptimizedScheduling_API.getAvailableAppointments(offerReq);	
        }catch(Exception ex){
        	//do Nothing. Expected.
        }
        
    }

    static testMethod void bookAppointmentTest() {
        WSCH_Appointment appt = new WSCH_Appointment();
        appt.setOfferToken('00045326f374000000014faffffffff0000000000054000');

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        
    	WSCH_OptimizedScheduling_API.BookAppointmentRequest bookApptReq = new WSCH_OptimizedScheduling_API.BookAppointmentRequest();
    	bookApptReq.apptSlot = appt;
    	bookApptReq.workOrder = workOrder;
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        try{
        	WSCH_OptimizedScheduling_API.bookAppointment(bookApptReq);	
        }catch(Exception ex){
        	//do Nothing. Expected.
        }
    }
    	static testMethod void OptimizedSchedulingAPI_Test(){
	
		List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrder = createWO('75001', 'Open', 60, 'CHANGE_CREATE_WO');
		workOrders.add(workOrder);
		WSCH_OptimizedScheduling_API.ManageWorkOrdersRequest mWo = new WSCH_OptimizedScheduling_API.ManageWorkOrdersRequest();
		mWo.workOrders= workOrders;
		WSCH_OptimizedScheduling_API.manageWorkOrders(mWo);
		
		WSCH_OptimizedScheduling_API.GetAvailableAppointmentsRequest gAAR = new WSCH_OptimizedScheduling_API.GetAvailableAppointmentsRequest();
		gAAR.workOrderNumber = String.valueOf(workOrder.Name);
		gAAR.apptBatchSize = 1;
		gAAR.apptBatchNumber = 1;
		WSCH_ApptParam wParam = new WSCH_ApptParam();
		wParam.startDateTime = Datetime.now().addDays(2);
		wParam.endDateTime = Datetime.now().addDays(7);
		gAAR.apptParams = wParam;	
	}
	
	
	/*Helper method to create Work Order*/
	private static SVMXC__Service_Order__c createWO(String woZip, String woStatus, Integer woServDuran, String woToken){
		SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
		workOrder.SVMXC__Zip__c = woZip;
		workOrder.SVMXC__Order_Status__c= woStatus;
		workOrder.SVMXC__Service_Duration__c = woServDuran;
		workOrder.SVMXC__Scheduling_Change_Token__c = woToken;
		return workOrder;
	}
}