/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class WSCH_Provider_SP_ChangedItems_UT {

    static testMethod void processRequestTest() {
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;
        
        String jsonStr='{"workItems":[{"id":"'+wo.Name+'", "booking":{"start":"21-07-2014 09:00", "arr":"21-07-2014 09:00", "end":"21-07-2014 17:00", "tech":"T004"}, "task":{"action":"NOTIFIED", "tied":"true"}, "atRisk":{"type":"Allocation Issue", "offset":"20"}}]}';
        
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(jsonStr);        
    }
    
    static testMethod void processRequestTest_Job(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;

        //Job State
        String request ='{"state":"NOTIFIED","workItems":[{"id":"'+wo.Name+'","type":"JOB","booking":{"start":"2015-01-06 08:25","end":"2015-01-06 11:30","arr":"2015-01-06 08:30","tech":"T001"},"location":{"postalCode":"WC2N 6LU"}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);

        String request2 ='{"state":"DENOTIFIED","workItems":[{"id":"'+wo.Name+'","type":"JOB","booking":{"start":"2015-01-06 08:25","end":"2015-01-06 11:30","arr":"2015-01-06 08:30","tech":"NHESLOP"},"location":{"postalCode":"WC2N 6LU"}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);
        
        //Action 
        String request1 = '{"workItems":[{"id":"'+wo.Name+'","type":"JOB","task":{"action":"NOTIFIED","tied":false},"booking":{"start":"2015-01-06 11:30","end":"2015-01-06 15:35","arr":"2015-01-06 11:35","tech":"T010"},"atRisk":{"type":"Dispatch Issue","offset":0}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request1);
    }
    
    static testMethod void processRequestTest_Activity(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;
        
        //Activity State
        String request ='{"state":"NOTIFIED","workItems":[{"id":"'+wo.Name+'","type":"JOB","booking":{"start":"2015-01-06 08:25","end":"2015-01-06 11:30","arr":"2015-01-06 08:30","tech":"T001"},"location":{"postalCode":"WC2N 6LU"}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);
        
        String request2 ='{"state":"DENOTIFIED","workItems":[{"id":"'+wo.Name+'","type":"JOB","booking":{"start":"2015-01-06 08:25","end":"2015-01-06 11:30","arr":"2015-01-06 08:30","tech":"T001"},"location":{"postalCode":"WC2N 6LU"}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);

        //Action 
        String request1 = '{"workItems":[{"id":"38562","type":"ACTIVITY","task":{"action":"PLANNED","tied":true},"booking":{"start":"2015-01-02 16:00","end":"2015-01-02 18:00","arr":"2015-01-02 16:00","tech":"T006"},"atRisk":{"offset":0}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request1);
        
    }

    static testMethod void processRequestTest_Break(){
        //Break State
        String request ='{"state":"NOTIFIED","workItems":[{"id":"MA007_Standup_2015-01-06T10:00","type":"BREAK","booking":{"start":"2015-01-06 10:00","tech":"MA007"},"location":{"postalCode":""}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);

        String request2 ='{"state":"DENOTIFIED","workItems":[{"id":"MA007_Standup_2015-01-06T10:00","type":"BREAK","booking":{"start":"2015-01-06 10:00","tech":"T001"},"location":{"postalCode":""}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);

    }
    
    static testMethod void processDeAllocateJobs(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;

        String request = '{"workItems":[{"id":"'+wo.Name+'","type":"JOB"}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);
    }
    
    static testMethod void processFailureNotifications(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;
        
        List<SVMXC__SVMX_Optimizer__c> lstOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
        optimizerObj.SVMXC__Optimizer_Error_Text__c = '{"workItems":[{"id":"'+wo.Name+'","type":"JOB","task":{"action":"NOTIFIED","tied":false},"booking":{"start":"2015-01-06 11:30","end":"2015-01-06 15:35","arr":"2015-01-06 11:35","tech":"T010"},"atRisk":{"type":"Dispatch Issue","offset":0}}],"rowver":0}';
        optimizerObj.SVMXC__WhatType__c = 'PUSH_REQUEST_JSON';
        lstOptimizer.add(optimizerObj);
        
        SVMXC__SVMX_Optimizer__c optimizerObj1 = new SVMXC__SVMX_Optimizer__c();
        optimizerObj1.SVMXC__Optimizer_Error_Text__c = '{"workItems":[{"id":"38562","type":"ACTIVITY","task":{"action":"PLANNED","tied":true},"booking":{"start":"2015-01-02 16:00","end":"2015-01-02 18:00","arr":"2015-01-02 16:00","tech":"T006"},"atRisk":{"offset":0}}],"rowver":0}';
        optimizerObj1.SVMXC__WhatType__c = 'PUSH_REQUEST_JSON';
        lstOptimizer.add(optimizerObj1);
        
        SVMXC__SVMX_Optimizer__c optimizerObj2 = new SVMXC__SVMX_Optimizer__c();
        optimizerObj2.SVMXC__Optimizer_Error_Text__c = '{"state":"NOTIFIED","workItems":[{"id":"MA007_Standup_2015-01-06T10:00","type":"BREAK","booking":{"start":"2015-01-06 10:00","tech":"T001"},"location":{"postalCode":""}}],"rowver":0}';
        optimizerObj2.SVMXC__WhatType__c = 'PUSH_REQUEST_JSON';
        lstOptimizer.add(optimizerObj2);
        
        SVMXC__SVMX_Optimizer__c optimizerObj3 = new SVMXC__SVMX_Optimizer__c();
        optimizerObj3.SVMXC__Optimizer_Error_Text__c = '{"state":"DENOTIFIED","workItems":[{"id":"MA007_Standup_2015-01-06T10:00","type":"BREAK","booking":{"start":"2015-01-06 10:00","tech":"T001"},"location":{"postalCode":""}}],"rowver":0}';
        optimizerObj3.SVMXC__WhatType__c = 'PUSH_REQUEST_JSON';
        lstOptimizer.add(optimizerObj3);

        WSCH_Provider_SP_ChangedItems_Helper.doProcessRequest(lstOptimizer);
    }
    
    static testMethod void testRestRequest(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;
        
        String jsonStr='{"workItems":[{"id":"'+wo.Name+'", "booking":{"start":"21-07-2014 09:00", "arr":"21-07-2014 09:00", "end":"21-07-2014 17:00", "tech":"T004"}, "task":{"action":"NOTIFIED", "tied":"true"}, "atRisk":{"type":"Allocation Issue", "offset":"20"}}]}';
        
        Integer testvalue1 = WSCH_Provider_SP_ChangedItems.doProcessRestRequest(jsonStr); 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://testrestservice';  
        req.httpMethod = 'GET';
        
        req.RequestBody = Blob.valueof(wo.Id);
        RestContext.request = req;
        Integer testValue = WSCH_Provider_SP_ChangedItems.doPost();
    }
    
    static testMethod void processPullNonWOEvents(){
        List<WSCH_Provider_SP_Push_Stubs.WorkItem> lstWorkItem = new List<WSCH_Provider_SP_Push_Stubs.WorkItem>();
        WSCH_Provider_SP_Push_Stubs.WorkItem workItem;
        WSCH_Provider_SP_Push_Stubs.Booking booking;
        WSCH_Provider_SP_Push_Stubs.Task task;              
        //1. Activity - Notified
        booking = new WSCH_Provider_SP_Push_Stubs.Booking();
        task = new WSCH_Provider_SP_Push_Stubs.Task();
        booking.tech='NHESLOP';
        booking.start='2015-03-12 05:30';
        booking.arr='2015-03-12 05:30';
        booking.end_x='2015-03-13 00:00';
        task.action = 'NOTIFIED';
        task.tied = false;
        workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                    
        workItem.id = '41269';
        workItem.task = task;
        workItem.Booking = booking;
        workItem.type = 'ACTIVITY';
        
        lstWorkItem.add(workItem);      
        
        //2. Activity planned
        booking = new WSCH_Provider_SP_Push_Stubs.Booking();
        task = new WSCH_Provider_SP_Push_Stubs.Task();
        booking.tech='T001';
        booking.start='2015-03-12 05:30';
        booking.arr='2015-03-12 05:30';
        booking.end_x='2015-03-13 00:00';
        task.action = 'PLANNED';
        task.tied = false;
        workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                    
        workItem.id = '41270';
        workItem.task = task;
        workItem.Booking = booking;
        workItem.type = 'ACTIVITY';

        lstWorkItem.add(workItem);
                
        //3. Activity Denotified
        booking = new WSCH_Provider_SP_Push_Stubs.Booking();
        task = new WSCH_Provider_SP_Push_Stubs.Task();
        booking.tech='NHESLOP';
        booking.start='2015-03-12 05:30';
        booking.arr='2015-03-12 05:30';
        booking.end_x='2015-03-13 00:00';
        task.action = 'DENOTIFIED';
        task.tied = false;
        workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                    
        workItem.id = '4127';
        workItem.task = task;
        workItem.Booking = booking;
        workItem.type = 'ACTIVITY';

        lstWorkItem.add(workItem);
        
        //4. break Denotified
        booking = new WSCH_Provider_SP_Push_Stubs.Booking();
        task = new WSCH_Provider_SP_Push_Stubs.Task();
        booking.tech='NHESLOP';
        booking.start='2015-03-12 05:30';
        booking.arr='2015-03-12 05:30';
        booking.end_x='2015-03-13 00:00';
        task.action = 'DENOTIFIED';
        task.tied = false;
        workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                    
        workItem.id = 'NHESLOP_Lunch_2015-03-13';
        workItem.task = task;
        workItem.Booking = booking;
        workItem.type = 'BREAK';
        
        lstWorkItem.add(workItem);

        //5. break Notified
        booking = new WSCH_Provider_SP_Push_Stubs.Booking();
        task = new WSCH_Provider_SP_Push_Stubs.Task();
        booking.tech='NHESLOP';
        booking.start='2015-03-12 05:30';
        booking.arr='2015-03-12 05:30';
        booking.end_x='2015-03-13 00:00';
        task.action = 'NOTIFIED';
        task.tied = false;
        workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                    
        workItem.id = 'NHESLOP_Lunch_2015-03-13';
        workItem.task = task;
        workItem.Booking = booking;
        workItem.type = 'BREAK';

        lstWorkItem.add(workItem);

        WSCH_Provider_SP_Push_Stubs.PushRequest req = new WSCH_Provider_SP_Push_Stubs.PushRequest();
        req.workItems=lstWorkItem;
        WSCH_Provider_SP_ChangedItems_Helper.doProcessRequest(req);
    }    
    
    static testMethod void testChangeItemsHelper() {
    
     test.StartTest();   
     
        List<SVMXC__ServiceMax_Config_Data__c> configSetting1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> configSetting = new List<SVMXC__ServiceMax_Config_Data__c>();
        configSetting = [SELECT id,SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Unique_ID__c In ('DCON002_SET001')];
        ///for(SVMXC__ServiceMax_Config_Data__c config: configSetting){
            //config.SVMXC__Internal_Value__c = 'false';
            //configSetting1.add(config);
        //}
        delete configSetting; 
        
        WSCH_Provider_SP_Push_Stubs.WorkItem workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();
        WSCH_Provider_SP_Push_Stubs.Booking booking = new WSCH_Provider_SP_Push_Stubs.Booking();
        WSCH_Provider_SP_Push_Stubs.Task task = new WSCH_Provider_SP_Push_Stubs.Task();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;
        
        booking.tech='NHESLOP';
        booking.start='2015-03-12 05:30';
        booking.arr='2015-04-12 05:30';
        booking.end_x='2015-04-13 00:00';
        task.action = 'NOTIFIED';
        task.tied = false;
        workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();                    
        workItem.id = '41269';
        workItem.task = task;
        workItem.Booking = booking;
        workItem.type = 'ACTIVITY';
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c(Name = 'TEAM 1');
        insert objTeam;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Optimizer_External_ID__c = 'NHESLOP',
                                            SVMXC__Salesforce_User__c = userinfo.getUserId()
                                            );
        insert tech1;
        
        String woId = String.valueof(wo.id);
                
        String jsonStr='{"workItems":[{"id":"'+wo.Name+'", "booking":{"start":"21-07-2014 09:00", "arr":"21-07-2014 09:00", "end":"21-07-2014 17:00", "tech":"T004"}, "task":{"action":"NOTIFIED", "tied":"true"}, "atRisk":{"type":"Allocation Issue", "offset":"20"}}]}';
        
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(jsonStr);      
        
        account acc = new account();
        acc.name ='ABC';
        insert acc;
        
        event sfEvent = new event();
        sfEvent.WhatId = acc.id;
        sfEvent.StartDateTime = DateTime.now();
        sfEvent.EndDateTime = DateTime.now().addHours(1);
        sfEvent.ownerid = userinfo.getuserid();
        insert sfEvent;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        insert technician;
        
      /*  SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.SVMXC__StartDateTime__c = DateTime.now();
        svmxEvent.SVMXC__DurationInMinutes__c = 30;
        svmxEvent.SVMXC__Technician__c = technician.Id;
        svmxEvent.SVMXC__WhatId__c = acc.Id;*/
        
        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = sfEvent.Id;
        svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);
        insert svmxOptimizer;
        
        WSCH_Provider_SP_ChangedItems_Helper ChangedItems_Helper = new WSCH_Provider_SP_ChangedItems_Helper();
        WSCH_Provider_SP_ChangedItems_Helper.doProcessActivities(workItem, 'denotified', '2016-08-11 09:10');
        WSCH_Provider_SP_ChangedItems_Helper.doProcessBreakInfo(workItem, 'denotified', '2016-08-11 09:10');
          
        WSCH_Provider_SP_ChangedItems_Helper.updateDripFeedEvents(sfEvent, true);  
        WSCH_Provider_SP_ChangedItems_Helper.updateDripFeedBreakEvents(sfEvent);
        WSCH_Provider_SP_ChangedItems_Helper.doDeleteBreak(sfEvent);
     test.StopTest();
    }
}