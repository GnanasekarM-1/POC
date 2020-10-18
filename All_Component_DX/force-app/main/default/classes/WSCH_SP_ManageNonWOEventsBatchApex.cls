global class WSCH_SP_ManageNonWOEventsBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {
		
    public boolean hasPendingObjects() {
    	
        List<SVMXC__SVMX_Optimizer__c> pendingEvents = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = 'OPT_BATCH' AND SVMXC__WhatType__c = 'NON_WO_EVENT' Limit 1];
        if(pendingEvents.size() > 0) {
            return true;
        }
        return false;
    }
    
    public void startBatch() {
        WSCH_SP_ManageNonWOEventsBatchApex.startTheBatch();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.MANAGE_NON_WO_BATCH_QUERY_STRING);
    }
        
    global void execute(Database.BatchableContext BC, List<SVMXC__SVMX_Optimizer__c> events) {
    	List<String> eventIds = new List<String>();
    	for(SVMXC__SVMX_Optimizer__c event : events) {
    		eventIds.add(event.ID);
    	}
    	List<SVMXC__SVMX_Optimizer__c> manageNonWOEventList = WSCH_CommonUtils.fetchSVMXOptimizerById(eventIds);
    	WSCH_OptimizedSchedulingService.triggerExecuted = true;     
        WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(manageNonWOEventList);
    }
    
    global void finish(Database.BatchableContext BC){
        WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.MANAGE_NON_WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
    }
    
    public static void startTheBatch()
    {
        WSCH_SP_ManageNonWOEventsBatchApex manageNonWOEventsBatchApex = new WSCH_SP_ManageNonWOEventsBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(manageNonWOEventsBatchApex, WSCH_Constants.BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.MANAGE_NON_WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
        }
    }
}