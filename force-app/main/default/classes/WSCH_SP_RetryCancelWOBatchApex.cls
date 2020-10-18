/**
 This WSCH_SP_RetryCancelWOBatchApex batch class is used to process the failed cancel work orders . 
 
**/
global  with sharing class WSCH_SP_RetryCancelWOBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {
 
    public boolean hasPendingObjects() {
      
        List<SVMXC__SVMX_Optimizer__c> pendingEvents = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = 'OPT_RETRY_BATCH' AND SVMXC__WhatType__c = 'WORK_ORDER' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4) Limit 1];
        if(pendingEvents.size() > 0) {
            return true;
        }
        return false;
    }
    
    public void startBatch() {
        WSCH_SP_RetryCancelWOBatchApex.startTheBatch();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.RETRY_CANCEL_WO_BATCH_QUERY_STRING);
    }
        
    global void execute(Database.BatchableContext BC, List<SVMXC__SVMX_Optimizer__c> workOrders) {
      List<String> workOrderIds = new List<String>();
      for(SVMXC__SVMX_Optimizer__c workOrder : workOrders) {
        workOrderIds.add(workOrder.ID);
      }
      List<SVMXC__SVMX_Optimizer__c> cancelWOList = WSCH_CommonUtils.fetchSVMXOptimizerById(workOrderIds);
      WSCH_OptimizedSchedulingService.triggerExecuted = true;     
      WSCH_OptimizedSchedulingService.cancelWorkOrders(cancelWOList);
    }
    
    global void finish(Database.BatchableContext BC){
      WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_CANCEL_WO_BATCH_APEX, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
    }
    
    public static void startTheBatch()
    {
        WSCH_SP_RetryCancelWOBatchApex cancelWOBatchApex = new WSCH_SP_RetryCancelWOBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(cancelWOBatchApex, WSCH_Constants.RETRY_CANCEL_WO_BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_CANCEL_WO_BATCH_APEX, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
        }
    }
}