/**
 This WSCH_SP_RetryNonWOEventBatchApex batch class is used to process the failed Non work orders events . 
 
**/
global with sharing class WSCH_SP_RetryNonWOEventBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts{

    public boolean hasPendingObjects() {
        
        List<SVMXC__SVMX_Optimizer__c> failedOptimizers = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = 'OPT_RETRY_BATCH' AND SVMXC__WhatType__c='NON_WO_EVENT' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4) Limit 1];
        if(failedOptimizers.size() > 0) {
            return true;
        }
        return false;
    }
    
    public void startBatch() {
        WSCH_SP_RetryNonWOEventBatchApex.startTheBatch();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.RETRY_FAILED_NON_WO_EVENT_QUERY_STRING);
    }
        
    global void execute(Database.BatchableContext BC, List<SVMXC__SVMX_Optimizer__c> failedOptimizers) {
        List<String> optimizerIds = new List<String>();
        for(SVMXC__SVMX_Optimizer__c optimizer:failedOptimizers) {
            optimizerIds.add(optimizer.ID);
        }
        List<SVMXC__SVMX_Optimizer__c> svmx_OptimizerList = WSCH_CommonUtils.fetchSVMXOptimizerById(optimizerIds);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;     
        WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(svmx_OptimizerList);
    }
    
    global void finish(Database.BatchableContext BC){
        WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_FAILED_NON_WO_EVENT_BATCH, WSCH_Constants.BATCH_APEX_START_TIME);
    }
    
    public static void startTheBatch()
    {
        WSCH_SP_RetryNonWOEventBatchApex  optimizerBatchApex = new WSCH_SP_RetryNonWOEventBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(optimizerBatchApex, WSCH_Constants.BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_FAILED_NON_WO_EVENT_BATCH, WSCH_Constants.BATCH_APEX_START_TIME);
        }
    }   

}