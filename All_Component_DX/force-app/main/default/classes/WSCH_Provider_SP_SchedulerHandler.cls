public with sharing class WSCH_Provider_SP_SchedulerHandler implements WSCH_Provider_SP_Scheduler.WSCH_SP_IScheduleDispatched {

    public void execute(SchedulableContext sc)
    {
        //Starting the Get Changes Batch Apex.
        WSCH_SP_GetChangesBatchApex.startTheBatch();

        //Starts the continuous schedueler if configured in the settings.
        String settingValue = WSCH_CommonUtils.getSettingValue('DCON004', 'SET006');
        WSCH_AuditLogger.debug('WSCH_Provider_SP_SchedulerHandler::execute()::settingValue:-'+settingValue);
        Boolean startContinuousScheduler = false; //Default Value.
        if(String.isNotBlank(settingValue)) {
            startContinuousScheduler = Boolean.valueOf(settingValue);
        }
        if(startContinuousScheduler) {
            WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME='WSCH_Provider_SP_WOUpdatesBatchApex';
            WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(10);
        }       

        //Check if Push notification is enabled then skip the get changed workorders call.
        if('True' == WSCH_CommonUtils.getSettingValue('DCON004','SET010')){
            //Starts the push failure schedueler if "RelatedTo" setting is false.
            String settingValueForPush = WSCH_CommonUtils.getSettingValue('DCON005', 'SET001');
            WSCH_AuditLogger.debug('WSCH_Provider_SP_SchedulerHandler::execute()::Related to Setting value:-'+settingValueForPush);
            Boolean startPushScheduler = false; //Default Value.
            if(String.isNotBlank(settingValueForPush)) {
                startPushScheduler = Boolean.valueOf(settingValueForPush);
            }
            if(!startPushScheduler && !startContinuousScheduler) {
                WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME='WSCH_Provider_SP_ChangedItems_BatchApex';
                WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(10);
            }
        }

        //Retrying the failed work orders.
        Set<String> failedStates = new Set<String>{WSCH_Constants.STATUS_OPT_FAIL,WSCH_Constants.STATUS_OPT_ERROR};
        List<SVMXC__Service_Order__c> failedWorkOrders = [SELECT ID FROM SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c IN :failedStates AND (SVMXC__Scheduling_Retry_Count__c = null OR SVMXC__Scheduling_Retry_Count__c < 4)];
        if(null != failedWorkOrders && failedWorkOrders.size() > 0) {
            List<String> workOrderIds = new List<String>();
            for(SVMXC__Service_Order__c workOrder:failedWorkOrders) {
                workOrderIds.add(workOrder.ID);
            }
            retryFailedWOs(workOrderIds);
        }

        //Retrying the failed non work orders.
        List<SVMXC__SVMX_Optimizer__c> optimizersList = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :failedStates  AND SVMXC__WhatType__c='NON_WO_EVENT' AND (SVMXC__Optimizer_Retry_Count__c = null OR    SVMXC__Optimizer_Retry_Count__c < 4)];
        if(optimizersList !=null && optimizersList.size() > 0) {
            List<String> optimizerIds = new List<String>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizersList) {
                optimizerIds.add(optimizer.Id);
            }
            retryFailedOptimizers(optimizerIds);
        }

        //Retrying the deletion of Work orders.
        List<SVMXC__SVMX_Optimizer__c> cancelWOList = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :failedStates  AND SVMXC__WhatType__c='WORK_ORDER' AND (SVMXC__Optimizer_Retry_Count__c = null OR    SVMXC__Optimizer_Retry_Count__c < 4)];
        if(cancelWOList !=null && cancelWOList.size() > 0) {
            List<String> optimizerIds = new List<String>();
            for(SVMXC__SVMX_Optimizer__c optimizer : cancelWOList) {
                optimizerIds.add(optimizer.Id);
            }
            retryCancelWorkOrders(optimizerIds);
        }
    }

    @future(callout=true)
    private static void retryFailedWOs(List<String> workOrderIds) {

        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__Service_Order__c> workOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
        WSCH_OptimizedSchedulingService.manageWorkOrders(workOrderList);
    }

    /*
        Below method can be called for retrying the failed Non WorkOrder Events  and will be re-submited  to SP for processing again.
    */
    @future(callout=true)
    public static void retryFailedOptimizers(List<String> optimizerIds) {

        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__SVMX_Optimizer__c> optimizersList = WSCH_CommonUtils.fetchSVMXOptimizerById(optimizerIds);
        WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(optimizersList);

    }

    /*
        Below method can be called for retrying the failed WorkOrders and will be re-submited  to SP for processing again .
    */
    @future(callout=true)
    public static void retryCancelWorkOrders(List<String> optimizerIds) {

        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__SVMX_Optimizer__c> optimizersList = WSCH_CommonUtils.fetchSVMXOptimizerById(optimizerIds);
        WSCH_OptimizedSchedulingService.cancelWorkOrders(optimizersList);

    }
}