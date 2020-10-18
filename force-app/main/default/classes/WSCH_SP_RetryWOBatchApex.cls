global class WSCH_SP_RetryWOBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {
   

    public boolean hasPendingObjects() {

        List<SVMXC__Service_Order__c> failedWorkOrders = [SELECT ID FROM SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c = 'OPT_RETRY_BATCH' AND (SVMXC__Scheduling_Retry_Count__c = null OR SVMXC__Scheduling_Retry_Count__c < 4) Limit 1];
        if(failedWorkOrders.size() > 0) {
            return true;
        }
        return false;
    }

    public void startBatch() {
        WSCH_SP_RetryWOBatchApex.startTheBatch();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.RETRY_WO_BATCH_QUERY_STRING);
    }

    global void execute(Database.BatchableContext BC, List<SVMXC__Service_Order__c> workOrders) {
    	List<String> workOrderIds = new List<String>();
    	for(SVMXC__Service_Order__c workOrder:workOrders) {
    		workOrderIds.add(workOrder.ID);
    	}
    	List<SVMXC__Service_Order__c> retryWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
    	WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.manageWorkOrders(retryWorkOrderList);
    }

    global void finish(Database.BatchableContext BC){
        WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
    }

    public static void startTheBatch()
    {
        WSCH_SP_RetryWOBatchApex workOrderBatchApex = new WSCH_SP_RetryWOBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(workOrderBatchApex, WSCH_Constants.BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
        }
    }

}