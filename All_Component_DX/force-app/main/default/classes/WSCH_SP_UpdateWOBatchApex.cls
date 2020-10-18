/*

    No more required after code refactoring done. Now Work order batch apex does all the requirement regarding work order update.
    No need to have this file any more in org. Should be deleted !!
*/

global class WSCH_SP_UpdateWOBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {






 
    public boolean hasPendingObjects() {
     /*   List<SVMXC__Service_Order__c> pendingWorkOrders = [Select ID from SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c = 'OPT_UPDATE_BATCH' Limit 1];
        if(pendingWorkOrders.size() > 0) {
            return true;
        }*/
        return false;
    }


    public void startBatch() {
     //   WSCH_SP_UpdateWOBatchApex.startTheBatch();
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.UPDATE_WO_BATCH_QUERY_STRING);
    }


    global void execute(Database.BatchableContext BC, List<SVMXC__Service_Order__c> workOrders){
    /*  List<String> workOrderIds = new List<String>();
        for(SVMXC__Service_Order__c workOrder:workOrders) {
            workOrderIds.add(workOrder.ID);

        }
        List<SVMXC__Service_Order__c> updateWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.updateWorkOrders(updateWorkOrderList); */
    }


    global void finish(Database.BatchableContext BC){
     //   WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.UPDATE_WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
    }


    public static void startTheBatch()
    {
      /*  WSCH_SP_UpdateWOBatchApex workOrderUpdateBatchApex = new WSCH_SP_UpdateWOBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(workOrderUpdateBatchApex, WSCH_Constants.UPDATE_WO_BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.UPDATE_WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
        }*/
    }


}