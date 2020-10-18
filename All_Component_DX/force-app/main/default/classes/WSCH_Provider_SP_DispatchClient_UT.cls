@isTest(seeAllData = true)
public with sharing class WSCH_Provider_SP_DispatchClient_UT {

	static testMethod void testDispatchClient() {

		Test.startTest();
		SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
		bookJobWorkOrder.SVMXC__OptiMax_Status__c = 'OPT_COMPLETED';
		insert bookJobWorkOrder;
		bookJobWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(bookJobWorkOrder.Id);
		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        insert technician;
        Event sfEvent = new Event();
        sfEvent.WhatId =  bookJobWorkOrder.Id;
        sfEvent.StartDateTime = DateTime.now();
        sfEvent.DurationInMinutes = 60;
        insert sfEvent;
        SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.SVMXC__WhatId__c = bookJobWorkOrder.Id;
        svmxEvent.SVMXC__StartDateTime__c = DateTime.now();
        svmxEvent.SVMXC__DurationInMinutes__c = 60;
        insert svmxEvent;
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_DispatchClient.DispOutputRequest dispReq = new WSCH_Provider_SP_DispatchClient.DispOutputRequest();
        WSCH_Provider_SP_DispatchClient.LoginRequest loginReq = new WSCH_Provider_SP_DispatchClient.LoginRequest();
        WSCH_Provider_SP_DispatchClient.BreakTimes breakTimes = new WSCH_Provider_SP_DispatchClient.BreakTimes();
		WSCH_Provider_SP_DispatchClient.DispJobEarmarked jobInfo = new WSCH_Provider_SP_DispatchClient.DispJobEarmarked();
		jobInfo.ETS = '2014-02-21T8:00';
		jobInfo.ETA = '2014-02-21T8:30';
		jobInfo.ETF = '2014-02-21T9:00';
		jobInfo.jobID = WSCH_CommonUtils.getWorkItemId('Name',bookJobWorkOrder);
		jobInfo.empID = technician.SVMXC__Optimizer_External_ID__c;
		jobInfo.earmarkType = 'SA-Earmark';
		WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
		jobInfo.earmarkType = 'Earmark';
		WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
		jobInfo.earmarkType = 'UnEarmark';
		WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
		WSCH_Provider_SP_DispatchClient.DispOutput(null);
		jobInfo.ETS = '2014/02/21T8:00';
		WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
		Test.stopTest();
	}
}