@isTest
private class WSCH_Provider_ECO_SchedulerHandler_UT {

    static testMethod void WSCH_Provider_ECO_SchedulerHandler_UT1() {
        Test.startTest();
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__OptiMax_Status__c = 'OPT_ERROR';
        workOrder1.SVMXC__Scheduling_Retry_Count__c = 2;
        insert workOrder1;
        WSCH_Provider_ECO_SchedulerHandler.startRetry();
        
        Test.stopTest();        
    }
    
    static testMethod void WSCH_Provider_ECO_SchedulerHandler_UT2() {
        Test.startTest();
        
        SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
        optimizerObj.SVMXC__Optimizer_Status__c = 'OPT_ERROR';
        optimizerObj.SVMXC__WhatType__c = 'WORK_ORDER';
        optimizerObj.SVMXC__Optimizer_Retry_Count__c = 2;
        insert optimizerObj;    
        WSCH_Provider_ECO_SchedulerHandler.startRetry();
        
        Test.stopTest();        
    }
    
    static testMethod void WSCH_Provider_ECO_SchedulerHandler_UT3() {
        Test.startTest();
        
        SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
        optimizerObj.SVMXC__Optimizer_Status__c = 'OPT_ERROR';
        optimizerObj.SVMXC__WhatType__c = 'NON_WO_EVENT';
        optimizerObj.SVMXC__Optimizer_Retry_Count__c = 2;
        insert optimizerObj;    
        WSCH_Provider_ECO_SchedulerHandler.startRetry();
        
        Test.stopTest();        
    }
    
    static testMethod void WSCH_Provider_ECO_SchedulerHandler_UT4() {
        Test.startTest();
        
        SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
        optimizerObj.SVMXC__Optimizer_Status__c = 'OPT_ERROR';
        optimizerObj.SVMXC__WhatType__c = 'Technician';
        optimizerObj.SVMXC__Optimizer_Retry_Count__c = 2;
        insert optimizerObj;    
        WSCH_Provider_ECO_SchedulerHandler.startRetry();
        
        Test.stopTest();        
    }
    
    static testMethod void WSCH_Provider_ECO_SchedulerHandler_UT5() {
        Test.startTest();
        WSCH_Provider_ECO_SchedulerHandler.startRetryCronJob(30);
        Test.stopTest();
    }
}