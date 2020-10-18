/**
	Following batch apex will be used when work orders will be deleted in bulk.
*/
global class WSCH_SP_CancelWorkOrderBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {
	
	private static final String BATCH_QUERY_STRING = 'SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = \'OPT_BATCH\' AND SVMXC__WhatType__c = \'WORK_ORDER\'';
    private static final String BATCH_CLASS_NAME = 'WSCH_SP_CancelWorkOrderBatchApex';
    private static final Integer BATCH_APEX_START_TIME = 120;
    private static final Integer BATCH_SIZE = 10;
    
    public boolean hasPendingObjects() {
    	
        List<SVMXC__SVMX_Optimizer__c> pendingEvents = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = 'OPT_BATCH' AND SVMXC__WhatType__c = 'WORK_ORDER' Limit 1];
        if(pendingEvents.size() > 0) {
            return true;
        }
        return false;
    }
    
    public void startBatch() {
        WSCH_SP_CancelWorkOrderBatchApex.startTheBatch();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(BATCH_QUERY_STRING);
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
        WSCH_BA_ScheduleHandler.startBatchApex(BATCH_CLASS_NAME, BATCH_APEX_START_TIME);
    }
    
    public static void startTheBatch()
    {
        WSCH_SP_CancelWorkOrderBatchApex cancelWOBatchApex = new WSCH_SP_CancelWorkOrderBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(cancelWOBatchApex, BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(BATCH_CLASS_NAME, BATCH_APEX_START_TIME);
        }
    }
}