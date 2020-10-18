/*
    WSCH_SP_WorkOrderBatchApex class will be used to manage the work orders in a batch having status OPT_BATCH.
    Manage work orders includes opearations like scheduling and updating the work orders.
*/

global class WSCH_SP_WorkOrderBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {

    public boolean hasPendingObjects() {
        //List<SVMXC__Service_Order__c> pendingWorkOrders = [Select ID from SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c = 'OPT_BATCH' Limit 1];
        //This query is validated as "Selective" Query by adding indexed fields in the Where Clause.
        List<SVMXC__Service_Order__c> pendingWorkOrders = [SELECT ID FROM SVMXC__Service_Order__c WHERE ( SVMXC__Dispatch_Process__c != NULL OR (SVMXC__Group_Member__c != NULL AND SVMXC__Appointment_Promised_Time_Slot__c != NULL )) AND (SVMXC__OptiMax_Status__c != NULL AND SVMXC__OptiMax_Status__c = 'OPT_BATCH') LIMIT 1];
        if(pendingWorkOrders.size() > 0) {
            return true;
        }
        return false;
    }

    public void startBatch() {
        WSCH_SP_WorkOrderBatchApex.startTheBatch();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(WSCH_Constants.WO_BATCH_QUERY_STRING);
    }

    global void execute(Database.BatchableContext BC, List<SVMXC__Service_Order__c> workOrders) {

        List<String> workOrderIds = new List<String>();
        for(SVMXC__Service_Order__c workOrder:workOrders) {
            workOrderIds.add(workOrder.ID);
        }
        List<SVMXC__Service_Order__c> manageWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.manageWorkOrders(manageWorkOrderList);
    }

    global void finish(Database.BatchableContext BC){
        WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
    }

    public static void startTheBatch()
    {
        WSCH_SP_WorkOrderBatchApex workOrderBatchApex = new WSCH_SP_WorkOrderBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(workOrderBatchApex, WSCH_Constants.BATCH_SIZE);
        } else {
            WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.RETRY_BATCH_APEX_START_TIME);
        }
    }
}