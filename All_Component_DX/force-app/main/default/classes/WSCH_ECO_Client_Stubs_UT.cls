@isTest
private class WSCH_ECO_Client_Stubs_UT {

    static testMethod void ECO_Client_Stubs_UT1() {
        Test.startTest();
        WSCH_ECO_Client_Stubs.Params_WP paramObj = new WSCH_ECO_Client_Stubs.Params_WP();
        paramObj.name = 'status';
        paramObj.value = 'RUNNING';
        System.assertEquals('status', paramObj.name);
        System.assertEquals('RUNNING', paramObj.value);
        
        WSCH_ECO_Client_Stubs.JobNotificationRequest_WP jobNotifReqObj = new WSCH_ECO_Client_Stubs.JobNotificationRequest_WP();
        jobNotifReqObj.dispatchProcessGuid = 'DP1';
        jobNotifReqObj.territoryGuid = 'Territory1';
        jobNotifReqObj.orgGuid = 'Org1';
        jobNotifReqObj.jobInstanceGuid = 'Job1';
        jobNotifReqObj.operation = 'NOTIFY_JOB';
        List<WSCH_ECO_Client_Stubs.Params_WP> jobDetails = new List<WSCH_ECO_Client_Stubs.Params_WP>();
        jobDetails.add(paramObj);
        jobNotifReqObj.jobDetails = jobDetails;
        System.assertEquals('DP1', jobNotifReqObj.dispatchProcessGuid);
        System.assertEquals('Territory1', jobNotifReqObj.territoryGuid);
        System.assertEquals('Org1', jobNotifReqObj.orgGuid);
        System.assertEquals('Job1', jobNotifReqObj.jobInstanceGuid);
        System.assertEquals('NOTIFY_JOB', jobNotifReqObj.operation);
        System.assertEquals(1, jobNotifReqObj.jobDetails.size());
        
        Test.stopTest();        
    }
    
    static testMethod void ECO_Client_Stubs_UT2() {
        Test.startTest();
        
        WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP techHorizonUpdateReqObj = new WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP();
        techHorizonUpdateReqObj.dispatchProcessGuid = 'DP1';
        techHorizonUpdateReqObj.territoryGuid = 'Territory1';
        techHorizonUpdateReqObj.operation = 'HORIZON_UPDATE';
        System.assertEquals('DP1', techHorizonUpdateReqObj.dispatchProcessGuid);
        System.assertEquals('Territory1', techHorizonUpdateReqObj.territoryGuid);
        System.assertEquals('HORIZON_UPDATE', techHorizonUpdateReqObj.operation);
        
        Test.stopTest();        
    }
}