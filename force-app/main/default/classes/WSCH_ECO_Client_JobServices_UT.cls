@isTest
private class WSCH_ECO_Client_JobServices_UT {

    static testMethod void ECO_ClientServices_UT1() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/services';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"jobDetails":[{"name":"jobStatus","value":"RUNNING"}]}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_JobServices.doPost();
        Test.stopTest();
        System.assertEquals('Empty or Invalid operation type', response);        
    }
    
    static testMethod void ECO_ClientServices_UT2() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/services';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"RUNNING"}]}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_JobServices.doPost();
        Test.stopTest();
        System.assertEquals('Notification Success', response);        
    }
    
    static testMethod void ECO_ClientService_UT3() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        createJob(prcessObjone.id, territory.id);
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/services';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"SUSPENDED"}]}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_JobServices.doPost();
        Test.stopTest();
        System.assertEquals('Notification Success', response);
    }
    
    static testMethod void ECO_ClientServices_UT4() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/services';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"RUNNING"}]}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        String connectionId = prcessObjone.id + '_' + territory.id;
        String optTranQuery = 'SELECT SVMXC__WhatId__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Connection_ID__c = \'' + connectionId + '\'';
        
        Test.startTest();
        WSCH_ECO_Client_JobServices.doPost();
        List<SVMXC__SVMX_Optimizer__c> trans = Database.query(optTranQuery);
        Integer count1 = trans.size();
        WSCH_ECO_Client_JobServices.doPost();
        trans = Database.query(optTranQuery);
        Integer count2 = trans.size();
        Test.stopTest();
        System.assertEquals(count1, count2);        
    }
    
    static testMethod void ECO_ClientServices_UT5() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        
        RestRequest req = new RestRequest();

        String failedReqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"IDLE"}]}';        
        String runningReqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"RUNNING"}]}';
        req.requestURI = '/services/apexrest/scheduling/eco/services';

        req.requestBody = Blob.valueOf(failedReqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        String connectionId = prcessObjone.id + '_' + territory.id;
        String optTranQuery = 'SELECT SVMXC__WhatId__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Connection_ID__c = \'' + connectionId + '\'';
        
        Test.startTest();
        WSCH_ECO_Client_JobServices.doPost();
        List<SVMXC__SVMX_Optimizer__c> trans = Database.query(optTranQuery);
        Integer count1 = trans.size();
        
        req.requestBody = Blob.valueOf(runningReqBody);
        WSCH_ECO_Client_JobServices.doPost();
        trans = Database.query(optTranQuery);
        Integer count2 = trans.size();
        
        req.requestBody = Blob.valueOf(failedReqBody);
        WSCH_ECO_Client_JobServices.doPost();
        trans = Database.query(optTranQuery);
        Integer count3 = trans.size();
        Test.stopTest();
        System.assertEquals(0, count1);
        //System.assertEquals(1, count2);
        System.assertEquals(0, count3);
    }
    static testMethod void ECO_ClientService_UT6() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        createJobIDLE(prcessObjone.id, territory.id);
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/services';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"RUNNING"}]}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_JobServices.doPost();
        Test.stopTest();
        System.assertEquals('Notification Success', response);
    }
    static testMethod void ECO_ClientService_UT7() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        createTech(territory);
        createJobSuspended(prcessObjone.id, territory.id);
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/services';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","orgGuid":null,"jobInstanceGuid":null,"operation":"NOTIFY_JOB","jobDetails":[{"name":"jobStatus","value":"RUNNING"}]}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_JobServices.doPost();
        Test.stopTest();
        System.assertEquals('Notification Success', response);
    }

    private static SVMXC__Territory__c createTerritory() {
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        BusinessHours bh = [Select Id from BusinessHours where IsDefault=true];
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'ECO_ClientService_UT1_T1';
        Territory1.SVMXC__Territory_s_Business_Hours__c = bh.id;
        Territorylst.add(Territory1);
        insert Territorylst;
        
        return Territorylst[0];
    }
    
    private static SVMXC__ServiceMax_Processes__c createDP(SVMXC__Territory__c territory) {
        List<RecordType> RecType = new  List<RecordType>();
        string DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId = DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test one';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Values__c = territory.id + ':U,';
        prcessObjone.SVMXC__Route_Type__c = 'CLOSED';
        prcessObjone.SVMXC__Dispatch_Threshold__c = 30;
        prcessObjone.SVMXC__Optimizer_Sync_Interval__c = 30;
        insert prcessObjone;
        
        return prcessObjone;
    }
    
    private static void createTech(SVMXC__Territory__c territory) {
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        
        list<SVMXC__Service_Group_Members__c> Techlst = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.name = 'T1';
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Enable_Scheduling__c = true;
        Tech1.SVMXC__Service_Territory__c = territory.id;
        Tech1.SVMXC__Service_Group__c = team.Id;
        Techlst.add(Tech1);
        insert Techlst;
    }
    
    private static void createJob(Id dpId, Id territoryId) {
        List<SVMXC__SVMX_Jobs__c> listJobs = new List<SVMXC__SVMX_Jobs__c>();
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = dpId;
        objSVMXJob.SVMXC__Territory__c = territoryId;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'RUNNING';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Type__c = 'ECO';
        listJobs.add(objSVMXJob);           
        Database.upsert(listJobs);
    }

    private static void createJobSuspended(Id dpId, Id territoryId) {
        List<SVMXC__SVMX_Jobs__c> listJobs = new List<SVMXC__SVMX_Jobs__c>();
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = dpId;
        objSVMXJob.SVMXC__Territory__c = territoryId;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'SUSPENDED';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Type__c = 'ECO';
        listJobs.add(objSVMXJob);           
        Database.upsert(listJobs);
    } 
    
    private static void createJobIDLE(Id dpId, Id territoryId) {
        List<SVMXC__SVMX_Jobs__c> listJobs = new List<SVMXC__SVMX_Jobs__c>();
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = dpId;
        objSVMXJob.SVMXC__Territory__c = territoryId;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'IDLE';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Type__c = 'ECO';
        listJobs.add(objSVMXJob);           
        Database.upsert(listJobs);
    }     
}