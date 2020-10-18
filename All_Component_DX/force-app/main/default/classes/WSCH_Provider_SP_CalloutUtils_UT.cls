@isTest(SeeAllData=true)
public with sharing class WSCH_Provider_SP_CalloutUtils_UT {
    
    public static SVMXC__Service_Order__c getWorkOrder(){
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Zip__c = '75001';
        wo.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        wo.SVMXC__Preferred_Start_Time__c = startTime;
        wo.SVMXC__Preferred_End_Time__c = endTime;
        return wo;
    }
    
    static testMethod void bookJobCallOutTest() {
        
        /** Book Job request **/
        Test.startTest();
        WSCH_Status statusObj = new WSCH_Status();
        
        SVMXC__Service_Order__c wo = getWorkOrder();
        WSCH_Provider_SP_StubsV91.JobBookRequest request_x = new WSCH_Provider_SP_StubsV91.JobBookRequest();
        request_x.jobID = 'Test1';     //must be unique unless 'allowRebook'(other attribute) is true
        request_x.jobType = 'Field Repair';
        request_x.postcode = '';
        request_x.allowRebook = true;       //it is false unless if the same work order is being sent to book it again
        request_x.extraDuration = '60';
        
        WSCH_Provider_SP_CalloutUtils.bookJob(wo, request_x,statusObj);     
        Test.stopTest();  
    }
    
    static testMethod void callOutExceptionTest() {
        
        /** Book Job request **/
        Test.startTest();
        WSCH_Status statusObj = new WSCH_Status();
        SVMXC__Service_Order__c wo = getWorkOrder();
        WSCH_Provider_SP_StubsV91.JobBookRequest request_x = new WSCH_Provider_SP_StubsV91.JobBookRequest();
        request_x.jobID = 'Test1';     //must be unique unless 'allowRebook'(other attribute) is true
        request_x.jobType = 'Field Repair';
        request_x.postcode = '';
        request_x.allowRebook = true;       //it is false unless if the same work order is being sent to book it again
        request_x.extraDuration = '60';
        WSCH_Provider_SP_StubsV91.JobBookResponse response=WSCH_Provider_SP_CalloutUtils.bookJob(wo, request_x,statusObj);
        //Asserting
        System.assertEquals(null,response);
        Test.stopTest();
    }  
    
    static testMethod void CallOutTest() {
        
        /** Book Job request **/
        Test.startTest();
        WSCH_Status statusObj = new WSCH_Status();
        
        SVMXC__Service_Order__c wo = getWorkOrder();
        WSCH_Provider_SP_StubsV91.JobBookRequest request_x = new WSCH_Provider_SP_StubsV91.JobBookRequest();
        request_x.jobID = 'Test1';     //must be unique unless 'allowRebook'(other attribute) is true
        request_x.jobType = 'Field Repair';
        request_x.postcode = '';
        request_x.allowRebook = true;       //it is false unless if the same work order is being sent to book it again
        request_x.extraDuration = '60';
        
        SVMXC__SVMX_Optimizer__c svmxOpt = new SVMXC__SVMX_Optimizer__c();
        svmxOpt.SVMXC__WhatType__c = 'Work Order';
        svmxOpt.SVMXC__WhatId__c = wo.Name;
        insert svmxOpt;
        
        
        WSCH_Provider_SP_CalloutUtils.getAppointments(wo, request_x,statusObj); 
        WSCH_Provider_SP_StubsV91.ApptBookResponse testBookAppt = WSCH_Provider_SP_CalloutUtils.bookAppointment(wo, request_x,statusObj); 
        System.debug('testBookAppt-->'+testBookAppt);
        WSCH_Provider_SP_CalloutUtils.changeWorkItemStatus(wo, request_x,statusObj); 
        WSCH_Provider_SP_CalloutUtils.getJobStatus(wo, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.stdActivityCreate(svmxOpt, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.stdActivityUpdate(svmxOpt, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.cancelJob(svmxOpt, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.stdActivityDelete(svmxOpt, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.updateJob(wo, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.cancelJob(wo, request_x,statusObj);
        WSCH_Provider_SP_CalloutUtils.forceFixJob(wo, request_x,statusObj);
        
        Test.stopTest();
    }
    
    static testMethod void testDependencyGroup() {
     System.Test.StartTest();
    SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
    workOrder1.SVMXC__Zip__c = '75001';
    workOrder1.SVMXC__Order_Status__c = 'Open';
    workOrder1.SVMXC__Service_Duration__c = 3600;
    workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder1;
    SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
    workOrder2.SVMXC__Zip__c = '75001';
    workOrder2.SVMXC__Order_Status__c='Open';
    workOrder2.SVMXC__Service_Duration__c = 3600;
    workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder2;
    SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
    dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
    insert dependencyManagement;
    SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
    dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
    dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
    dependencyRecord.SVMXC__Time_Dependency__c = 'Start Times Of Both Depend On Each Other';
    dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
    dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 30;
    dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 60;
    dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
    dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
    dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
    insert dependencyRecord;
    
    List<Service_Order_Dependency__c> serviceOrderList = new List<Service_Order_Dependency__c>();
    serviceOrderList.add(dependencyRecord);
    WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse response;
    WSCH_Provider_SP_RealTimeOptimizer realtimeoptimizer = new WSCH_Provider_SP_RealTimeOptimizer();
    response = realtimeoptimizer.manageDependencyGroup(dependencyManagement.Id, serviceOrderList);
    
    WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest bdgRequest;
    try{
        bdgRequest = WSCH_Provider_SP_DataMapper.mapBookDependencyGroupRequest('BDG-01', serviceOrderList);
    } catch(Exception ex) {
        system.debug('Exception occured');
    }
    
    WSCH_Status statusObj = new WSCH_Status();
    WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse responseBGD = WSCH_Provider_SP_CalloutUtils.bookDependencyGroup(dependencyManagement, serviceOrderList, bdgRequest, statusObj);
    test.StopTest();
    }

}