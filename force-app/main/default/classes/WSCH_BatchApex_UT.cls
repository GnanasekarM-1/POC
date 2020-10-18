@isTest
//(SeeAllData = true)
public with sharing class WSCH_BatchApex_UT {

    /*public WSCH_BatchApex_UT(){
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;
    }
    static{
        WSCH_BatchApex_UT batApexUT = new WSCH_BatchApex_UT();
    }*/

    static testMethod void commonUtils() {

        Test.startTest();
        WSCH_BA_CommonUtils.canExecuteBatchApex();
        Test.stopTest();
    }

    static testMethod void retryWOBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_RetryWOBatchApex retryWOBatchApex = new WSCH_SP_RetryWOBatchApex();
        retryWOBatchApex.hasPendingObjects();
        retryWOBatchApex.startBatch();
        Database.BatchableContext BC;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrders.add(workOrder);
        retryWOBatchApex.execute(BC,workOrders);
        Test.stopTest();
    }

    static testMethod void getChangesBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_GetChangesBatchApex getChangesBatchApex = new WSCH_SP_GetChangesBatchApex();
        getChangesBatchApex.hasPendingObjects();
        Integer pendingTerritoryCount = [SELECT COUNT() FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null];
        WSCH_Constants.GET_CHANGES_BATCH_SIZE = pendingTerritoryCount + 1;
        getChangesBatchApex.startBatch();
        Test.stopTest();
    }

    static testMethod void retryNonWOEventBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_RetryNonWOEventBatchApex retryNonWOEventBatchApex = new WSCH_SP_RetryNonWOEventBatchApex();
        retryNonWOEventBatchApex.hasPendingObjects();
        retryNonWOEventBatchApex.startBatch();
        Database.BatchableContext BC;
        List<SVMXC__SVMX_Optimizer__c> events  = new List<SVMXC__SVMX_Optimizer__c>();
        SVMXC__SVMX_Optimizer__c event = new SVMXC__SVMX_Optimizer__c();
        events.add(event);
        retryNonWOEventBatchApex.execute(BC,events);
        Test.stopTest();
    }

    static testMethod void updateWOBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_UpdateWOBatchApex updateWOBatchApex = new WSCH_SP_UpdateWOBatchApex();
        WSCH_SP_UpdateWOBatchApex.startTheBatch();      
        updateWOBatchApex.hasPendingObjects();
        updateWOBatchApex.startBatch();
        
        Database.BatchableContext BC;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrders.add(workOrder);      
        updateWOBatchApex.execute(BC, workOrders);
        updateWOBatchApex.finish(BC);
        updateWOBatchApex.start(BC);

        Test.stopTest();
    }

    static testMethod void workOrderBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_WorkOrderBatchApex workOrderBatchApex = new WSCH_SP_WorkOrderBatchApex();
        workOrderBatchApex.hasPendingObjects();
        workOrderBatchApex.startBatch();
        Database.BatchableContext BC;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrders.add(workOrder);
        workOrderBatchApex.execute(BC,workOrders);
        
        Test.stopTest();
    }

    static testMethod void cancelWorkOrderBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_CancelWorkOrderBatchApex cancelWorkOrderBatchApex = new WSCH_SP_CancelWorkOrderBatchApex();
        cancelWorkOrderBatchApex.hasPendingObjects();
        cancelWorkOrderBatchApex.startBatch();
        Database.BatchableContext BC;
        List<SVMXC__SVMX_Optimizer__c> events  = new List<SVMXC__SVMX_Optimizer__c>();
        SVMXC__SVMX_Optimizer__c event = new SVMXC__SVMX_Optimizer__c();
        events.add(event);
        cancelWorkOrderBatchApex.execute(BC,events);
        Test.stopTest();
    }

    static testMethod void manageNonWOEventsBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_ManageNonWOEventsBatchApex manageNonWOEventsBatchApex = new WSCH_SP_ManageNonWOEventsBatchApex();
        manageNonWOEventsBatchApex.hasPendingObjects();
        manageNonWOEventsBatchApex.startBatch();
        Database.BatchableContext BC;
        List<SVMXC__SVMX_Optimizer__c> events  = new List<SVMXC__SVMX_Optimizer__c>();
        SVMXC__SVMX_Optimizer__c event = new SVMXC__SVMX_Optimizer__c();
        events.add(event);
        manageNonWOEventsBatchApex.execute(BC,events);
        Test.stopTest();
    }

    static testMethod void retryCancelWOBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_SP_RetryCancelWOBatchApex retryCancelWOBatchApex = new WSCH_SP_RetryCancelWOBatchApex();
        retryCancelWOBatchApex.hasPendingObjects();
        Database.BatchableContext BC;
        List<SVMXC__SVMX_Optimizer__c> events  = new List<SVMXC__SVMX_Optimizer__c>();
        SVMXC__SVMX_Optimizer__c event = new SVMXC__SVMX_Optimizer__c();
        events.add(event);
        retryCancelWOBatchApex.execute(BC,events);
        WSCH_SP_RetryCancelWOBatchApex.startTheBatch();
        Test.stopTest();
    }

    static testMethod void WOUpdatesBatchApex() {

        //Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_WOUpdatesBatchApex woUpdatesBatchApex = new WSCH_Provider_SP_WOUpdatesBatchApex();
        Integer pendingTerritoryCount = [SELECT COUNT() FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null];
        WSCH_Constants.GET_CHANGES_BATCH_SIZE = pendingTerritoryCount + 1;
        woUpdatesBatchApex.hasPendingObjects();
        woUpdatesBatchApex.startBatch();
        //Test.stopTest();
    }

    static testMethod void WOUpdatesSchHandler() {
        //Test.startTest();
        WSCH_Provider_SP_WOUpdatesSchHandler woUpdateschHandler = new WSCH_Provider_SP_WOUpdatesSchHandler();
        Integer pendingTerritoryCount = [SELECT COUNT() FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null];
        WSCH_Constants.GET_CHANGES_BATCH_SIZE = pendingTerritoryCount + 1;
        WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(10);
        //Test.stopTest();
    }


    static testMethod void WOUpdatesScheduler() {
        //Test.startTest();
        WSCH_Provider_SP_WOUpdatesScheduler woUpdatesScheduler = new WSCH_Provider_SP_WOUpdatesScheduler();
        Integer pendingTerritoryCount = [SELECT COUNT() FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null];
        WSCH_Constants.GET_CHANGES_BATCH_SIZE = pendingTerritoryCount + 1;
        woUpdatesScheduler.startUpdatesWOScheduler();
        //Test.stopTest();
    }
    
    static testMethod void WOChangedItemsBatchApex() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_ChangedItems_BatchApex woChangedItemsBatchApex = new WSCH_Provider_SP_ChangedItems_BatchApex();
        Integer failureNotifications= [SELECT COUNT() FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__WhatType__c = 'PUSH_REQUEST_JSON'];
        WSCH_Constants.GET_PUSH_BATCH_SIZE = failureNotifications + 1;
        woChangedItemsBatchApex .hasPendingObjects();
        woChangedItemsBatchApex .startBatch();
        Test.stopTest();
    }   

}