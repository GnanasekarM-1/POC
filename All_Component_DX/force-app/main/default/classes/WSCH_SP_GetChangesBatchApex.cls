/*
    WSCH_SP_GetChangesBatchApex class will be used only to get updated technician events from SP.
*/

global class WSCH_SP_GetChangesBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts{

    public boolean hasPendingObjects() {
        List<SVMXC__Territory__c> pendingTerritories = [SELECT SVMXC__Optimizer_External_ID__c, SVMXC__Optimizer_Last_Timestamp__c FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null AND SVMXC__Active__c = true];
        if(pendingTerritories.size() > 0) {
            return true;
        }
        return false;
    }

    public void startBatch() {
        WSCH_SP_GetChangesBatchApex.startTheBatch();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.GET_CHANGES_BATCH_QUERY_STRING);
    }

    global void execute(Database.BatchableContext BC, List<SVMXC__Territory__c> territories){
    	WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.getChangedWorkOrders(territories.get(0));
    }

    global void finish(Database.BatchableContext BC){
       // Blank implementation, Not chaining the batch.
    }

    public static void startTheBatch()
    {
        WSCH_SP_GetChangesBatchApex workOrderUpdateBatchApex = new WSCH_SP_GetChangesBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(workOrderUpdateBatchApex, WSCH_Constants.GET_CHANGES_BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.GET_CHANGES_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
        }
    }
}