public with sharing class WSCH_Provider_ECO_SchedulerHandler implements WSCH_Provider_ECO_Scheduler.WSCH_ECO_IScheduleDispatched {

    public void execute(SchedulableContext sc)
    {
        System.abortJob(sc.getTriggerID()); // Always abort the job on completion
        startRetryCronJob(30);
        startRetry();
    }

    public static void startRetry() {
        Set<String> failedStates = new Set<String>{WSCH_ECO_Constants.STATUS_OPT_FAIL, WSCH_ECO_Constants.STATUS_OPT_ERROR};

        // Retrying the failed work orders.
        try {
            List<SVMXC__Service_Order__c> failedWorkOrders = [SELECT ID FROM SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c IN :failedStates AND (SVMXC__Scheduling_Retry_Count__c = null OR SVMXC__Scheduling_Retry_Count__c < 4)];
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::Number of failed WOs = ' + failedWorkOrders.size());
            if(failedWorkOrders != null && failedWorkOrders.size() > 0) {
                List<String> workOrderIds = new List<String>();
                for(SVMXC__Service_Order__c workOrder : failedWorkOrders) {
                    workOrderIds.add(workOrder.ID);
                }
                retryFailedWOs(workOrderIds);
            }
        } catch(Exception e) {
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: Error retrying failed work orders');
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: ' + e.getMessage() + '\n Stack Trace:: ' + e.getStackTraceString());
        }

        // Retrying the failed non work orders.
        try {
            List<SVMXC__SVMX_Optimizer__c> optimizersList = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :failedStates  AND SVMXC__WhatType__c = 'NON_WO_EVENT' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4)];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::Number of failed non WO events = ' + optimizersList.size());
            if(optimizersList != null && optimizersList.size() > 0) {
                List<String> optimizerIds = new List<String>();
                for(SVMXC__SVMX_Optimizer__c optimizer : optimizersList) {
                    optimizerIds.add(optimizer.Id);
                }
                retryFailedOptimizers(optimizerIds);
            }
        } catch (Exception e) {
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: Error retrying failed non-work order events');
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: ' + e.getMessage() + '\n Stack Trace:: ' + e.getStackTraceString());            
        }

        // Retrying the deletion of Work orders.
        try {
            List<SVMXC__SVMX_Optimizer__c> cancelWOList = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :failedStates  AND SVMXC__WhatType__c = 'WORK_ORDER' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4)];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::Number of failed WO cancellations = ' + cancelWOList.size());
            if(cancelWOList != null && cancelWOList.size() > 0) {
                List<String> optimizerIds = new List<String>();
                for(SVMXC__SVMX_Optimizer__c optimizer : cancelWOList) {
                    optimizerIds.add(optimizer.Id);
                }
                retryCancelWorkOrders(optimizerIds);
            }
        } catch(Exception e) {
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: Error retrying failed work order cancellations');
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: ' + e.getMessage() + '\n Stack Trace:: ' + e.getStackTraceString());
        }
        
        // Retrying the failed Technicians.
        try {
            List<SVMXC__SVMX_Optimizer__c> failedTechList = [SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :failedStates  AND SVMXC__WhatType__c = 'Technician' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4)];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::Number of failed technicians = ' + failedTechList.size());
            if(failedTechList != null && failedTechList.size() > 0) {
                List<String> optimizerIds = new List<String>();
                for(SVMXC__SVMX_Optimizer__c optimizer : failedTechList) {
                    optimizerIds.add(optimizer.Id);
                }
                retryFailedTechnicians(optimizerIds);
            }
        } catch(Exception e) {
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: Error retrying failed technicians');
            WSCH_AuditLogger.error('WSCH_Provider_ECO_SchedulerHandler: ' + e.getMessage() + '\n Stack Trace:: ' + e.getStackTraceString());
        }
        
        WSCH_AuditLogger.finish();
    }
    /*
        Below method is called for retrying failed Work Orders
    */
    @future(callout=true)
    private static void retryFailedWOs(List<String> workOrderIds) {
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__Service_Order__c> workOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
        WSCH_OptimizedSchedulingService.manageWorkOrders(workOrderList);
    }

    /*
        Below method is called for retrying failed Non WorkOrder Events
    */
    @future(callout=true)
    public static void retryFailedOptimizers(List<String> optimizerIds) {
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__SVMX_Optimizer__c> optimizersList = WSCH_CommonUtils.fetchSVMXOptimizerById(optimizerIds);
        WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(optimizersList);
    }

    /*
        Below method is called for retrying failed cancel of Work Orders
    */
    @future(callout=true)
    public static void retryCancelWorkOrders(List<String> optimizerIds) {
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__SVMX_Optimizer__c> optimizersList = WSCH_CommonUtils.fetchSVMXOptimizerById(optimizerIds);
        WSCH_OptimizedSchedulingService.cancelWorkOrders(optimizersList);
    }
    
    /*
        Below method is called for retrying failed Technicians
    */
    @future(callout=true)
    public static void retryFailedTechnicians(List<String> optimizerIds) {
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__SVMX_Optimizer__c> optimizersList = WSCH_CommonUtils.fetchSVMXOptimizerById(optimizerIds);
        WSCH_OptimizedSchedulingService.manageTechnicians(optimizersList);
    }
    
    public static boolean startRetryCronJob(Integer schedulerStartTime){
        String cronJobName = WSCH_ECO_Constants.WSCH_SYNCSCHEDULER_CRONJOB;
        
        // If cron job is running, return false
        Boolean isCronJobRunning = WSCH_CommonUtils.isCronJobRunning(cronJobName);
        if(isCronJobRunning) {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::startRetryCronJob()::isCronJobRunning - ' + isCronJobRunning);          
            return false; // Job running
        }
        
        String retryFreq = WSCH_CommonUtils.getSettingValue('OMAX004', 'SET007');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::startRetryCronJob()::retryFreq - ' + retryFreq);
        if(String.isNotBlank(retryFreq)) {
            schedulerStartTime = Integer.valueOf(retryFreq);
        }
        if (schedulerStartTime == null || schedulerStartTime == 0) {
            schedulerStartTime = 30;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulerHandler::startRetryCronJob()::cronJobName - ' + cronJobName);
        WSCH_AuditLogger.finish();
        
        WSCH_Provider_ECO_Scheduler scheduler = new WSCH_Provider_ECO_Scheduler();
        System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addSeconds(schedulerStartTime)), scheduler);
        
        return true;
    }
    
    public static String getSchedulerExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
}