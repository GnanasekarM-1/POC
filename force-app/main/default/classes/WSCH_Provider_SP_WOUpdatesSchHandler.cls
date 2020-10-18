/*
    Scheduler Handler to get the updates of the work order from SP.
*/
public class WSCH_Provider_SP_WOUpdatesSchHandler implements WSCH_Provider_SP_WOUpdatesScheduler.WSCH_SP_IScheduleDispatched {
    
    public static String  WO_UPDATES_BATCHAPEX_NAME = '';
    //private static final String  WO_UPDATES_BATCHAPEX_NAME = 'WSCH_Provider_SP_WOUpdatesBatchApex';
    
    public void execute(SchedulableContext sc)
    {
        /*setBatchApexClass();
        system.abortJob(sc.getTriggerID()); // Always abort the job on completion
        Type targetType = Type.forName(WO_UPDATES_BATCHAPEX_NAME);
        if (targetType != null) {
            WSCH_BatchApex_Interface obj = (WSCH_BatchApex_Interface) targetType.NewInstance();
            obj.startBatch();
        }
        //check if the setting for sMax Queue is enabled
        if((WSCH_TriggerHandler.isSmaxQSettingEnabled != null) && (WSCH_TriggerHandler.isSmaxQSettingEnabled)){
            startMaxQ();
        }*/
        String setVal = WSCH_CommonUtils.getSettingValue('DCON004','SET015');
        Boolean isSmaxQEnabled =false;
        if(String.isNotBlank(setVal)){
           isSmaxQEnabled = Boolean.valueOf(setVal);
        }
                
        if((isSmaxQEnabled != null) && (isSmaxQEnabled)){
           startMaxQ();
           system.abortJob(sc.getTriggerID()); // Always abort the job on completion
           startMaxQCronJob(30);
        }
    }
    
    public static void startMaxQ(){
        String strWhatType = 'WORK_ORDER';
        Set<String> setOptTransIDs = new Set<String>();
        String strBATCH_PROCESSING = 'BATCH_PROCESSING';
        String strQuery = 'SELECT ID, SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Retry_Count__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :setStrQueueStatus AND  SVMXC__WhatType__c = :strWhatType AND SVMXC__Optimizer_Retry_Count__c < :RETRY_COUNT ORDER BY LastModifiedDate ASC LIMIT :MAX_SOQL_RECORDS';
        Integer intListSize, RETRY_COUNT = 4, MAX_SOQL_RECORDS = 49999, MAX_FUTURE_CALLS =50, startIndex, endIndex, MAX_RECORDS = getSmaxQBatchSize();
        startIndex = 0;
        endIndex= MAX_RECORDS - 1;
        Set<String> setStrQueueStatus = new Set<String>{'BATCH_QUEUED','BATCH_FAILED'};
        List<SVMXC__SVMX_Optimizer__c> lstQueueOpt = new List<SVMXC__SVMX_Optimizer__c>();
        List<Set<String>> lstOptTransToProcess = new List<Set<String>>();
        try{
            WSCH_AuditLogger.debug('INSIDE WSCH_Provider_SP_WOUpdatesSchHandler :: startMaxQ at: ' + String.valueOf(System.now()));
            //fetch the list of Optimizer Transaction records to e processed
            lstQueueOpt = Database.query(strQuery);
            //check if the list is not empty
            if(!lstQueueOpt.isEmpty()){
                intListSize = lstQueueOpt.size();
                //loop through the list & set the status as PROCESSING
                //create sub-lists of size equivalent to setting SET00888
                for(Integer i=0; i<=intListSize-1 ;i++){
                    if(lstOptTransToProcess.size()< MAX_FUTURE_CALLS){
                        if(i>= startIndex || i<= endIndex){
                            lstQueueOpt[i].SVMXC__Optimizer_Status__c = strBATCH_PROCESSING;
                            setOptTransIDs.add(String.valueOf(lstQueueOpt[i].Id));
                        }
                        if((i== endIndex) ||  (i == (intListSize-1))){
                            lstOptTransToProcess.add(setOptTransIDs);
                            setOptTransIDs = new Set<String>();
                            startIndex = endIndex + 1;
                            endIndex = endIndex + MAX_RECORDS;
                        }
                    }
                }
                //Collect curent datetime on when future call was made.
                Datetime futurePickTime = Datetime.now();
                //send all the sub-lists for processing
                for(Set<String> setOptTrans : lstOptTransToProcess){
                    //invoke the Future call to Process the Optimizer Transaction Operations on Work Orders
                    optimizeBatchProcess(setOptTrans, futurePickTime);
                }
                //update the Optimizer Transaction Records
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstQueueOpt, COMM_SecurityUtils.Access.Updateable)){
                	Database.update(lstQueueOpt);	
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_WOUpdatesSchHandler :: startMaxQ :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    
    @future(callout=true)
    public static void optimizeBatchProcess(Set<String> setOptIds, Datetime futurePickTime){
        String strQuery = 'SELECT ID, SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Retry_Count__c FROM SVMXC__SVMX_Optimizer__c WHERE Id IN :setOptIds';
        List<SVMXC__SVMX_Optimizer__c> lstQueueOpt = new List<SVMXC__SVMX_Optimizer__c>();
        List<SVMXC__SVMX_Optimizer__c> lstUpdateOptTrans = new List<SVMXC__SVMX_Optimizer__c>();
        List<SVMXC__SVMX_Optimizer__c> lstDeleteOptTrans = new List<SVMXC__SVMX_Optimizer__c>();
        List<SVMXC__Service_Order__c> lstWo = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstProcessWo;
        Set<SVMXC__Service_Order__c> setUpdateWo = new Set<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c woToProcess;
        Set<String> setWoIds = new Set<String>();
        WSCH_WorkOrderResponse callOutResponse;
        WSCH_WorkOrderResponse responseToProcess;
        Set<SVMXC__Service_Order__c> setWorkOrder;
        Set<WSCH_TechnicianEvent> setTechEvent;
        Set<WSCH_Provider_SP_Push_Stubs.WorkItem> setWorkItem;
        List<String> lstSchedDetails;
        String strSchedToken = '';
        Map<String, SVMXC__Service_Order__c> mapWoId = new Map<String, SVMXC__Service_Order__c>(); 
        
        try{
            WSCH_AuditLogger.debug('INSIDE WSCH_Provider_SP_WOUpdatesSchHandler :: optimizeBatchProcess at: ' + String.valueOf(System.now()));
            //get the list of all Optimizer Transaction in FAILED or QUEUED Status
            lstQueueOpt = Database.query(strQuery);
            if(!lstQueueOpt.isEmpty()){
                WSCH_Provider_SP_RealTimeOptimizer realTimeOpt = new WSCH_Provider_SP_RealTimeOptimizer();
                responseToProcess = new WSCH_WorkOrderResponse();
                setWorkOrder = new Set<SVMXC__Service_Order__c>();
                setTechEvent = new Set<WSCH_TechnicianEvent>();
                setWorkItem = new Set<WSCH_Provider_SP_Push_Stubs.WorkItem>();             
                for(SVMXC__SVMX_Optimizer__c optTrans: lstQueueOpt){
                    setWoIds.add(optTrans.SVMXC__WhatId__c);
                }
                //get the list of work orders to be processed
                lstWo = WSCH_CommonUtils.fetchWorkOrders(new List<String>(setWoIds));
                for(SVMXC__Service_Order__c woRec: lstWo){
                    mapWoId.put(String.valueOf(woRec.id), woRec);
                }
                //loop through the Optimizer Transaction records to make appropriate callout
                for(SVMXC__SVMX_Optimizer__c optTrans: lstQueueOpt){
                    try{
                        callOutResponse = new WSCH_WorkOrderResponse();
                        lstProcessWo = new List<SVMXC__Service_Order__c>();
                        woToProcess = new SVMXC__Service_Order__c();
                        woToProcess = mapWoId.get(optTrans.SVMXC__WhatId__c);
                        lstSchedDetails = new List<String>();
                        if(woToProcess != null){
                            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler :: optimizeBatchProcess: WO: ' + woToProcess.name + ' OPT_STATUS: ' + optTrans.SVMXC__Optimizer_Status__c);
                            WSCH_AuditLogger.setLogContext(woToProcess.name);
                            //set the Scheduling Change Token of work order as the Token in Optimizer Transaction
                            if((optTrans.SVMXC__Optimizer_Change_Token__c.contains('CHANGE_JOB_FIXED')) && optTrans.SVMXC__Optimizer_Change_Token__c.contains(',')){
                                lstSchedDetails = optTrans.SVMXC__Optimizer_Change_Token__c.split(',',2);
                                strSchedToken = lstSchedDetails[0];
                                if(lstSchedDetails[1] != null){
                                    woToProcess.SVMXC__Scheduled_Date_Time__c = Datetime.valueOfGMT(lstSchedDetails[1]);
                                    WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler ::optimizeBatchProcess + Token: ' + strSchedToken  + ' Value: ' + lstSchedDetails[1]);
                                }
                            }else if((optTrans.SVMXC__Optimizer_Change_Token__c.contains('CHANGE_SERVICE_DURATION')) && optTrans.SVMXC__Optimizer_Change_Token__c.contains(',')){
                                lstSchedDetails = optTrans.SVMXC__Optimizer_Change_Token__c.split(',',2);
                                strSchedToken = lstSchedDetails[0];
                                if(lstSchedDetails[1] != null){
                                    woToProcess.SVMXC__Service_Duration__c = Double.valueOf(lstSchedDetails[1]);
                                    WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler ::optimizeBatchProcess + Token: ' + strSchedToken  + ' Value: ' + lstSchedDetails[1]);
                                }
                            }else if((optTrans.SVMXC__Optimizer_Change_Token__c.contains('CHANGE_SCHEDULING_STATUS')) && optTrans.SVMXC__Optimizer_Change_Token__c.contains(',')){
                                lstSchedDetails = optTrans.SVMXC__Optimizer_Change_Token__c.split(',',2);
                                strSchedToken = lstSchedDetails[0];
                                if(lstSchedDetails[1] != null){
                                    woToProcess.SVMXC__Work_Order_Scheduling_Status__c = lstSchedDetails[1];
                                    WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler ::optimizeBatchProcess + Token: ' + strSchedToken  + ' Value: ' + lstSchedDetails[1]);
                                }
                            }else{
                                strSchedToken = optTrans.SVMXC__Optimizer_Change_Token__c;
                            }
                            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler ::strSchedToken ' + strSchedToken);
                            woToProcess.SVMXC__Scheduling_Change_Token__c = strSchedToken;
                            lstProcessWo.add(woToProcess);
                            //Collect the linx performance metrics
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"WOCREATED"',woToProcess.CreatedDate,null);
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"WOMODIFIED"_"' + strSchedToken.toUpperCase() + '"',woToProcess.lastModifiedDate,null);
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"FUTUREPICK"_"' + strSchedToken.toUpperCase() + '"',futurePickTime,null);
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"CALLOUT"_"' + strSchedToken.toUpperCase() + '"',Datetime.now(),null);
                            
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"MAXQWAITING"_"' + strSchedToken.toUpperCase() + '"', null, (futurePickTime.getTime() - woToProcess.lastModifiedDate.getTime()));
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"FUTUREWAITING"_"' + strSchedToken.toUpperCase() + '"', null, (Datetime.now().getTime() - futurePickTime.getTime()));
                            //perform a callout by sending the work order as a list to WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()
                            callOutResponse = realTimeOpt.manageWorkOrders(lstProcessWo);
                            //check if callout is completed
                            if(callOutResponse != null){
                                //if callout is success(work order OPT_TENTATIVE), then add the optimizer transaction to delete list, done after callout
                                if(checkWoResponse(callOutResponse)){
                                    lstDeleteOptTrans.add(optTrans);
                                }//else update the optimzer transaction record as failed
                                else{
                                    optTrans.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                                    optTrans.SVMXC__Optimizer_Retry_Count__c = optTrans.SVMXC__Optimizer_Retry_Count__c + 1;
                                    optTrans.SVMXC__Optimizer_Error_Text__c = callOutResponse.getLstWorkOrder()[0].SVMXC__OptiMax_Error_Text__c;
                                    //add the list of failed work orders to be updated after callout
                                    lstUpdateOptTrans.add(optTrans);
                                }
                                callOutResponse.getLstWorkOrder()[0].SVMXC__Scheduling_Change_Token__c = strSchedToken;
                                //add the list of work orders to update after callout
                                setUpdateWo.addAll(callOutResponse.getLstWorkOrder());
                            }//else update the optimzer transaction record as failed
                            else{
                                optTrans.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                                optTrans.SVMXC__Optimizer_Retry_Count__c = optTrans.SVMXC__Optimizer_Retry_Count__c + 1;
                                //add the list of failed work orders to be updated after callout
                                lstUpdateOptTrans.add(optTrans);
                            }
                            setWorkOrder.addAll(callOutResponse.getLstWorkOrder());
                            setTechEvent.addAll(callOutResponse.getLstTechEvent());
                            setWorkItem.addAll(callOutResponse.getLstWorkItem());
                        }
                    }catch(Exception ex){
                        optTrans.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                        optTrans.SVMXC__Optimizer_Retry_Count__c = optTrans.SVMXC__Optimizer_Retry_Count__c + 1;
                        //add the list of failed work orders to be updated after callout
                        lstUpdateOptTrans.add(optTrans);
                        WSCH_AuditLogger.error('WSCH_Provider_SP_WOUpdatesSchHandler :: optimizeBatchProcess ::' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                    }
                }
                
                responseToProcess.setLstWorkOrder(new List<SVMXC__Service_Order__c>(setWorkOrder));
                responseToProcess.setLstTechEvent(new List<WSCH_TechnicianEvent>(setTechEvent));
                responseToProcess.setLstWorkItem(new List<WSCH_Provider_SP_Push_Stubs.WorkItem>(setWorkItem));
                
                //Save the linx performance metrics
                WSCH_AuditLogger.savePerformanceMetrics();
                
                //perform the DMLs after the callout completion
                if(!lstDeleteOptTrans.isEmpty()){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Optimizer__c')){
                    	Database.delete(lstDeleteOptTrans);	
                    } 
                }
                if(!lstUpdateOptTrans.isEmpty()){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstUpdateOptTrans, COMM_SecurityUtils.Access.Updateable)){
                    	Database.update(lstUpdateOptTrans);	
                    }
                }
                if(!setUpdateWo.isEmpty()){
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_WorkOrderEventHelper.processWorkOrderResponse(responseToProcess);  
                    //Database.update(new List<SVMXC__Service_Order__c>(setUpdateWo));
                }
                WSCH_AuditLogger.finish();
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_WOUpdatesSchHandler :: optimizeBatchProcess :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    
    public static Boolean checkWoResponse(WSCH_WorkOrderResponse woResp){
        Boolean isWoSuccess = false;
        if(woResp != null){
            for(SVMXC__Service_Order__c woRec: woResp.getLstWorkOrder()){
                if((woRec.SVMXC__OptiMax_Status__c.equals(WSCH_Constants.STATUS_OPT_TENTATIVE)) ||
                (woRec.SVMXC__OptiMax_Status__c.equals(WSCH_Constants.STATUS_OPT_COMPLETED))){
                    isWoSuccess = true;
                }
            }
        }
        return isWoSuccess;
    }
    public static Integer getSmaxQBatchSize(){
        String setVal = '';
        Integer sMaxQBatchSize =40;
        try{
            setVal = WSCH_CommonUtils.getSettingValue('DCON004','SET016');
            if(String.isNotBlank(setVal)){
                sMaxQBatchSize = Integer.valueOf(setVal);
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler: SmaxBatchSize ' + sMaxQBatchSize);
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_WOUpdatesSchHandler:getSmaxBatchSize() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return sMaxQBatchSize;
    }

    private void setBatchApexClass(){
        //Starts the continuous schedueler if configured in the settings.
        String settingValue = WSCH_CommonUtils.getSettingValue('DCON004', 'SET006');
        WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::setBatchApexClass()::settingValue:-'+settingValue);
        Boolean startContinuousScheduler = false; //Default Value.
        if(String.isNotBlank(settingValue)) {
            startContinuousScheduler = Boolean.valueOf(settingValue);
        }
        if(startContinuousScheduler) {
            WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME='WSCH_Provider_SP_WOUpdatesBatchApex';
        }
        
        //Check if Push notification is enabled then skip the get changed workorders call.
        if('True' == WSCH_CommonUtils.getSettingValue('DCON004','SET010')){
            String settingValueForPush = WSCH_CommonUtils.getSettingValue('DCON005', 'SET001');
            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::setBatchApexClass()::RelatedTo setting value:-'+settingValueForPush);
            Boolean startPushScheduler = false; //Default Value.
            if(String.isNotBlank(settingValueForPush)) {
                startPushScheduler = Boolean.valueOf(settingValueForPush);
            }
            if(!startPushScheduler && !startContinuousScheduler) {
                WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME='WSCH_Provider_SP_ChangedItems_BatchApex';
            }
        }
    }
    
    public static String getSchedulerExpression(Datetime dt) {

        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

    private static Boolean scheduledInContext = false;

    public static boolean startBatchApex(Integer schedulerStartTime)
    {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::batch apex class name '+WO_UPDATES_BATCHAPEX_NAME);

        if(scheduledInContext) {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::scheduledInContext- '+scheduledInContext);
            return false;
        }

        //Batch apex not required to run based on the settings. So we need to stop creating cronjobs.
        if(WO_UPDATES_BATCHAPEX_NAME.equalsIgnoreCase('')){
            return false;
        }

        scheduledInContext = true;

        String cronJobName = WO_UPDATES_BATCHAPEX_NAME + '_schedule';
        /*
            Following logic checks if same cron job is running , then returns false.
        */
        Boolean isCronJobRunning = WSCH_CommonUtils.isCronJobRunning(cronJobName);
        if(isCronJobRunning) {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::isCronJobRunning- '+isCronJobRunning);
            return false;    // Already running
        }

        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};

        List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob where ApexClass.Name = :WO_UPDATES_BATCHAPEX_NAME And Status in :activejobstates];
        if(apexjobs.size() > 0) {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::apexjobs.size() - '+apexjobs.size());
            return false;  // The batch is running
        }

        apexjobs = [Select ID, ApexClass.Name from AsyncApexJob where ApexClass.Name = :WSCH_Constants.GET_CHANGES_BATCH_CLASS_NAME And Status in :activejobstates];
        if(apexjobs.size() > 0) {
            String settingValue = WSCH_CommonUtils.getSettingValue('DCON004', 'SET007');
            Integer settingTimeDelay = 30; //Default Value.
            //Considers if getChanges Batch Apex is running as well. Which is part of SyncScheduler following code ensures a delay of time mentioned in the settings.
            if(String.isNotBlank(settingValue)){
                settingTimeDelay = Integer.valueOf(settingValue);
            }
            
            schedulerStartTime =  settingTimeDelay;
        }
        /*MaxQ Start*/
            /*if((WSCH_TriggerHandler.isSmaxQSettingEnabled != null) && (WSCH_TriggerHandler.isSmaxQSettingEnabled)){
                String maxQFreq = WSCH_CommonUtils.getSettingValue('DCON004','SET017');
                if(String.isNotBlank(maxQFreq)){
                    schedulerStartTime = Integer.valueOf(maxQFreq);
                }
            }*/
        /*MaxQ End*/
        if (schedulerStartTime == null || schedulerStartTime == 0) {
            schedulerStartTime = 30;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::cronJobName '+cronJobName);
        WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::apexjobs '+apexjobs);
        //WSCH_AuditLogger.finish();
        WSCH_Provider_SP_WOUpdatesScheduler updatesWOScheduler = new WSCH_Provider_SP_WOUpdatesScheduler();
        System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addSeconds(schedulerStartTime)), updatesWOScheduler);

        return true;
    }
    
     public static boolean startMaxQCronJob(Integer schedulerStartTime){
       String cronJobName = 'MAXQ_schedule';
       
       //Following logic checks if same cron job is running , then returns false.
       
       Boolean isCronJobRunning = WSCH_CommonUtils.isCronJobRunning(cronJobName);
       if(isCronJobRunning) {
           WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startBatchApex()::isCronJobRunning- '+isCronJobRunning);          
            return false;    // Already running
       }
       
       if((WSCH_TriggerHandler.isSmaxQSettingEnabled != null) && (WSCH_TriggerHandler.isSmaxQSettingEnabled)){
           String maxQFreq = WSCH_CommonUtils.getSettingValue('DCON004','SET017');
           WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startMaxQCronJob()::maxQFreq '+maxQFreq );
           if(String.isNotBlank(maxQFreq)){
               schedulerStartTime = Integer.valueOf(maxQFreq);
           }
       }
       
       if (schedulerStartTime == null || schedulerStartTime == 0) {
           schedulerStartTime = 30;
       }
       WSCH_AuditLogger.debug('WSCH_Provider_SP_WOUpdatesSchHandler::startMaxQCronJob()::cronJobName '+cronJobName);
       WSCH_AuditLogger.finish();
       //Start the batch Apex in next 10 seconds.
       WSCH_Provider_SP_WOUpdatesScheduler maxQSchduler = new WSCH_Provider_SP_WOUpdatesScheduler();
       System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addSeconds(schedulerStartTime)), maxQSchduler);
       return true;
   } 

}