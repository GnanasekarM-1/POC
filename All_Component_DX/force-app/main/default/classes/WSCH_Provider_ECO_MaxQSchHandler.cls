/*
    Scheduler Handler to process the work order and make callout to OptiMax.
*/
public class WSCH_Provider_ECO_MaxQSchHandler implements WSCH_Provider_ECO_MaxQScheduler.WSCH_ECO_IScheduleDispatched{
    
    //public static String  WO_UPDATES_BATCHAPEX_NAME = '';
    
    public void execute(SchedulableContext sc)
    {
        String setVal = WSCH_CommonUtils.getSettingValue('OMAX004','SET004');
        Boolean isSmaxQEnabled =false;
        if(String.isNotBlank(setVal)){
           isSmaxQEnabled = Boolean.valueOf(setVal);
        }
                
        if((isSmaxQEnabled != null) && (isSmaxQEnabled)){
        // comment the below statement and start the maxq after start the next cron trigger.
           //startMaxQ();
           system.abortJob(sc.getTriggerID()); // Always abort the job on completion
           startMaxQCronJob(30);
           startMaxQ();
        }
    }
    
    public static void startMaxQ(){
        //String strWhatType = 'ECO_WORK_ORDER';
        Set<String> setStrWhatType = new Set<String> {'ECO_WORK_ORDER','ECO_EVENT','ECO_TECHNICIAN'};
        Set<String> setOptTransIDs = new Set<String>();
        String strBATCH_PROCESSING = 'BATCH_PROCESSING';
        Integer intListSize, RETRY_COUNT = 3, MAX_SOQL_RECORDS = 49999, MAX_FUTURE_CALLS =50, startIndex, endIndex, MAX_RECORDS = getSmaxQBatchSize();
        startIndex = 0;
        endIndex= MAX_RECORDS - 1;
        Set<String> setStrQueueStatus = new Set<String>{'BATCH_QUEUED','BATCH_FAILED'};

        String strQuery = 'SELECT ID, SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Retry_Count__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c IN :setStrQueueStatus AND  SVMXC__WhatType__c IN :setStrWhatType AND SVMXC__Optimizer_Retry_Count__c < :RETRY_COUNT ORDER BY LastModifiedDate ASC LIMIT :MAX_SOQL_RECORDS';
        List<SVMXC__SVMX_Optimizer__c> lstQueueOpt = new List<SVMXC__SVMX_Optimizer__c>();
        List<Set<String>> lstOptTransToProcess = new List<Set<String>>();
        try{
            WSCH_AuditLogger.debug('INSIDE WSCH_Provider_ECO_MaxQSchHandler :: startMaxQ at: ' + String.valueOf(System.now()));
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
               WSCH_AuditLogger.finish(); 
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_ECO_MaxQSchHandler :: startMaxQ :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
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
        List<SVMXC__Service_Order__c> lstProcessWo = new List<SVMXC__Service_Order__c>();
        Set<SVMXC__Service_Order__c> setUpdateWo = new Set<SVMXC__Service_Order__c>();
        
        Set<String> setOfDependencyGroupIds = new Set<String>();
        
        SVMXC__Service_Order__c woToProcess;
        Set<String> setWoIds = new Set<String>();
        WSCH_WorkOrderResponse callOutResponse = new WSCH_WorkOrderResponse();
        WSCH_NonWOEventResponse eventCallOutResponse = new WSCH_NonWOEventResponse();
        WSCH_TechnicianResponse techCallOutResponse = new WSCH_TechnicianResponse();
        WSCH_WorkOrderResponse responseToProcess;
        Set<SVMXC__Service_Order__c> setWorkOrder;
        Set<WSCH_TechnicianEvent> setTechEvent;
        Set<WSCH_Provider_SP_Push_Stubs.WorkItem> setWorkItem;
        List<String> lstSchedDetails;
        String strSchedToken = '';
        Map<String, SVMXC__Service_Order__c> mapWoId = new Map<String, SVMXC__Service_Order__c>(); 
        Map<String, SVMXC__SVMX_Optimizer__c> mapWoIdOptimizer = new Map<String, SVMXC__SVMX_Optimizer__c>();
        Map<String, SVMXC__SVMX_Optimizer__c> mapEventOptimizerIdObj = new Map<String, SVMXC__SVMX_Optimizer__c>();
        Map<String, SVMXC__SVMX_Optimizer__c> mapTechOptimizerIdObj = new Map<String, SVMXC__SVMX_Optimizer__c>();
        WSCH_Provider_ECO_SchedulingService realTimeOpt = new WSCH_Provider_ECO_SchedulingService();
        try{
            WSCH_AuditLogger.debug('INSIDE WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess at: ' + String.valueOf(System.now()));
            //get the list of all Optimizer Transaction in FAILED or QUEUED Status
            lstQueueOpt = Database.query(strQuery);
            if(!lstQueueOpt.isEmpty()){
                for(SVMXC__SVMX_Optimizer__c optTrans: lstQueueOpt){
                    if('ECO_WORK_ORDER'.equals(optTrans.SVMXC__WhatType__c)){
                        setWoIds.add(optTrans.SVMXC__WhatId__c);
                        mapWoIdOptimizer.put(optTrans.SVMXC__WhatId__c,optTrans);
                    }else if('ECO_EVENT'.equals(optTrans.SVMXC__WhatType__c)){
                        mapEventOptimizerIdObj.put(optTrans.SVMXC__WhatId__c,optTrans);
                    }else if('ECO_TECHNICIAN'.equals(optTrans.SVMXC__WhatType__c)){
                        mapTechOptimizerIdObj.put(optTrans.SVMXC__WhatId__c,optTrans);
                    }
                }    
            }
            
            //if(!lstQueueOpt.isEmpty()){
            if(mapWoIdOptimizer != null && mapWoIdOptimizer.size() > 0){
                //WSCH_Provider_ECO_SchedulingService realTimeOpt = new WSCH_Provider_ECO_SchedulingService();
                responseToProcess = new WSCH_WorkOrderResponse();
                setWorkOrder = new Set<SVMXC__Service_Order__c>();
                setTechEvent = new Set<WSCH_TechnicianEvent>();
                setWorkItem = new Set<WSCH_Provider_SP_Push_Stubs.WorkItem>();             
                // for(SVMXC__SVMX_Optimizer__c optTrans: lstQueueOpt){
                //     setWoIds.add(optTrans.SVMXC__WhatId__c);
                //     mapWoIdOptimizer.put(optTrans.SVMXC__WhatId__c,optTrans);
                // }
                // //get the list of work orders to be processed
                lstWo = WSCH_CommonUtils.fetchWorkOrders(new List<String>(setWoIds));
                for(SVMXC__Service_Order__c woRec: lstWo){
                    mapWoId.put(String.valueOf(woRec.id), woRec);
                }
                //loop through the Optimizer Transaction records to make appropriate callout
                
                for(SVMXC__SVMX_Optimizer__c optTrans: mapWoIdOptimizer.values()){
                    try{
                        //callOutResponse = new WSCH_WorkOrderResponse();
                        //lstProcessWo = new List<SVMXC__Service_Order__c>();
                        woToProcess = new SVMXC__Service_Order__c();
                        woToProcess = mapWoId.get(optTrans.SVMXC__WhatId__c);
                        lstSchedDetails = new List<String>();
                        if(woToProcess != null){
                            WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess: WO: ' + woToProcess.name + ' OPT_STATUS: ' + optTrans.SVMXC__Optimizer_Status__c);
                            WSCH_AuditLogger.setLogContext(woToProcess.name);
                            //set the Scheduling Change Token of work order as the Token in Optimizer Transaction
                            if((optTrans.SVMXC__Optimizer_Change_Token__c.contains('CHANGE_JOB_FIXED')) && optTrans.SVMXC__Optimizer_Change_Token__c.contains(',')){
                                lstSchedDetails = optTrans.SVMXC__Optimizer_Change_Token__c.split(',',2);
                                strSchedToken = lstSchedDetails[0];
                                if(lstSchedDetails[1] != null){
                                    woToProcess.SVMXC__Scheduled_Date_Time__c = Datetime.valueOfGMT(lstSchedDetails[1]);
                                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::optimizeBatchProcess + Token: ' + strSchedToken  + ' Value: ' + lstSchedDetails[1]);
                                }
                            }else if((optTrans.SVMXC__Optimizer_Change_Token__c.contains('CHANGE_SERVICE_DURATION')) && optTrans.SVMXC__Optimizer_Change_Token__c.contains(',')){
                                lstSchedDetails = optTrans.SVMXC__Optimizer_Change_Token__c.split(',',2);
                                strSchedToken = lstSchedDetails[0];
                                if(lstSchedDetails[1] != null){
                                    woToProcess.SVMXC__Service_Duration__c = Double.valueOf(lstSchedDetails[1]);
                                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::optimizeBatchProcess + Token: ' + strSchedToken  + ' Value: ' + lstSchedDetails[1]);
                                }
                            }else if((optTrans.SVMXC__Optimizer_Change_Token__c.contains('CHANGE_SCHEDULING_STATUS')) && optTrans.SVMXC__Optimizer_Change_Token__c.contains(',')){
                                lstSchedDetails = optTrans.SVMXC__Optimizer_Change_Token__c.split(',',2);
                                strSchedToken = lstSchedDetails[0];
                                if(lstSchedDetails[1] != null){
                                    woToProcess.SVMXC__Work_Order_Scheduling_Status__c = lstSchedDetails[1];
                                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::optimizeBatchProcess + Token: ' + strSchedToken  + ' Value: ' + lstSchedDetails[1]);
                                }
                            }else{
                                strSchedToken = optTrans.SVMXC__Optimizer_Change_Token__c;
                            }
                            WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::strSchedToken ' + strSchedToken);
                            woToProcess.SVMXC__Scheduling_Change_Token__c = strSchedToken;
                            
                            //separate out the dependency WOs
                            if(woToProcess.SVMXC__Scheduling_Change_Token__c == 'CREATE_DEPENDENCY_WO' || woToProcess.SVMXC__Scheduling_Change_Token__c == 'CHANGE_DEPENDENCY_WO'){
                                setOfDependencyGroupIds.add(woToProcess.SVMXC__Dependency_Group__c);
                            }else{  
                                lstProcessWo.add(woToProcess);
                            }
                            
                            //Collect the linx performance metrics
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"WOCREATED"',woToProcess.CreatedDate,null);
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"WOMODIFIED"_"' + strSchedToken.toUpperCase() + '"',woToProcess.lastModifiedDate,null);
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"FUTUREPICK"_"' + strSchedToken.toUpperCase() + '"',futurePickTime,null);
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"CALLOUT"_"' + strSchedToken.toUpperCase() + '"',Datetime.now(),null);
                            
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"MAXQWAITING"_"' + strSchedToken.toUpperCase() + '"', null, (futurePickTime.getTime() - woToProcess.lastModifiedDate.getTime()));
                            WSCH_AuditLogger.appendMetrics(woToProcess.Name,'"FUTUREWAITING"_"' + strSchedToken.toUpperCase() + '"', null, (Datetime.now().getTime() - futurePickTime.getTime()));
                            
                           /* //perform a callout by sending the work order as a list to WSCH_Provider_ECO_SchedulingService::manageWorkOrders()
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
                            setWorkItem.addAll(callOutResponse.getLstWorkItem());*/
                        }
                    }catch(Exception ex){
                        optTrans.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                        optTrans.SVMXC__Optimizer_Retry_Count__c = optTrans.SVMXC__Optimizer_Retry_Count__c + 1;
                        //add the list of failed work orders to be updated after callout
                        lstUpdateOptTrans.add(optTrans);
                        WSCH_AuditLogger.error('WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess ::' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                    }
                }
                
                //perform a callout by sending the work order as a list to WSCH_Provider_ECO_SchedulingService::manageWorkOrders()
                if(lstProcessWo.size() > 0) {
                    callOutResponse = realTimeOpt.manageWorkOrders(lstProcessWo);
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler::optimizeBatchProcess::normal WOs:callOutResponse.getLstWorkOrder().size() - ' + callOutResponse.getLstWorkOrder().size());
                }

                //Dependency related processing
                if(setOfDependencyGroupIds.size() > 0) {
                    WSCH_WorkOrderResponse depWOResponse = processDependencyWorkOrders(setOfDependencyGroupIds);
                    //adding the dependency WOs response to the existing callOutResponse object 
                    if(depWOResponse != null) {
                        callOutResponse.getLstWorkOrder().addAll(depWOResponse.getLstWorkOrder());
                        callOutResponse.getLstTechEvent().addAll(depWOResponse.getLstTechEvent());
                        callOutResponse.getLstWorkItem().addAll(depWOResponse.getLstWorkItem());
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler::optimizeBatchProcess::Dependency WOs:callOutResponse.getLstWorkOrder().size() - ' + callOutResponse.getLstWorkOrder().size());
                    }
                }
                
                //check if callout is completed
                if(callOutResponse != null){
                    //if callout is success(work order OPT_TENTATIVE), then add the optimizer transaction to delete list, done after callout
                    for(SVMXC__Service_Order__c woRec: callOutResponse.getLstWorkOrder()){
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess ::woRec:-'+woRec);
                        if(woRec != null && woRec.Id != null){
                            SVMXC__SVMX_Optimizer__c optimizer =mapWoIdOptimizer.get(woRec.Id);

                            //added the below null check for dependency WOs where out of two WOs if only one is changed
                            //that will have the optimizer record created, and for the other dependent WO there is no
                            // optimizer record. In that case null gets added to list of optimizer record.
                            //and exception occurs during DML as null is present in the list.
                            if(optimizer != null) {
                                if(((WSCH_ECO_Constants.STATUS_OPT_TENTATIVE).equals(woRec.SVMXC__OptiMax_Status__c)) || ((WSCH_ECO_Constants.STATUS_OPT_COMPLETED).equals(woRec.SVMXC__OptiMax_Status__c)) || ((WSCH_ECO_Constants.STATUS_OPT_INITIATED).equals(woRec.SVMXC__OptiMax_Status__c)) || ('CHANGE_CANCEL_WO'.equalsIgnoreCase(woRec.SVMXC__Scheduling_Change_Token__c))){
                                    lstDeleteOptTrans.add(optimizer);
                                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess ::In IF optimizer:- '+optimizer + ' , lstDeleteOptTrans :: '+lstDeleteOptTrans);
                                }else{
                                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess ::In ELSE optimizer:- '+optimizer);
                                    optimizer.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                                    optimizer.SVMXC__Optimizer_Retry_Count__c = optimizer.SVMXC__Optimizer_Retry_Count__c + 1;
                                    optimizer.SVMXC__Optimizer_Error_Text__c = callOutResponse.getLstWorkOrder()[0].SVMXC__OptiMax_Error_Text__c;
                                    //add the list of failed work orders to be updated after callout
                                    lstUpdateOptTrans.add(optimizer);    
                                }
                            }
                        }
                        //callOutResponse.getLstWorkOrder()[0].SVMXC__Scheduling_Change_Token__c = strSchedToken; 
                    }
                    //add the list of work orders to update after callout
                    setUpdateWo.addAll(callOutResponse.getLstWorkOrder());
                }//else update the optimzer transaction record as failed
                else{
                    for(SVMXC__SVMX_Optimizer__c optimizer : lstQueueOpt){
                        optimizer.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                        optimizer.SVMXC__Optimizer_Retry_Count__c = optimizer.SVMXC__Optimizer_Retry_Count__c + 1;
                        //add the list of failed work orders to be updated after callout
                        lstUpdateOptTrans.add(optimizer);    
                    }
                }
                setWorkOrder.addAll(callOutResponse.getLstWorkOrder());
                setTechEvent.addAll(callOutResponse.getLstTechEvent());
                setWorkItem.addAll(callOutResponse.getLstWorkItem());                
                responseToProcess.setLstWorkOrder(new List<SVMXC__Service_Order__c>(setWorkOrder));
                responseToProcess.setLstTechEvent(new List<WSCH_TechnicianEvent>(setTechEvent));
                responseToProcess.setLstWorkItem(new List<WSCH_Provider_SP_Push_Stubs.WorkItem>(setWorkItem));
                
                //Save the linx performance metrics
                WSCH_AuditLogger.savePerformanceMetrics();
                
                // //perform the DMLs after the callout completion
                // if(!lstDeleteOptTrans.isEmpty()){
                //     if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Optimizer__c')){
                //         Database.delete(lstDeleteOptTrans);
                //     } 
                // }
                // if(!lstUpdateOptTrans.isEmpty()){
                //     Database.update(lstUpdateOptTrans); 
                // }
                if(!setUpdateWo.isEmpty()){
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(responseToProcess);  
                    //Database.update(new List<SVMXC__Service_Order__c>(setUpdateWo));
                }
                //WSCH_AuditLogger.finish();
            }
            if(mapEventOptimizerIdObj != null && mapEventOptimizerIdObj.size() > 0){
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::No. of events for callout...'+mapEventOptimizerIdObj.size());
                list<SVMXC__SVMX_Optimizer__c> lstEventOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
                List<String> lstOptimizerId = new List<String>(mapEventOptimizerIdObj.keySet());
                lstEventOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerById(lstOptimizerId);
                if(lstEventOptimizer != null && lstEventOptimizer.size() >0 ){
                    eventCallOutResponse = realTimeOpt.manageNonWorkOrderEvents(lstEventOptimizer);
                    //Delete the maxQ transaction after successful callout.
                    //Update the maxQ transaction if any failure occured for retry.
                    if(eventCallOutResponse !=null && eventCallOutResponse.getEvents().size() > 0) {
                        for(SVMXC__SVMX_Optimizer__c optimizerEvent : eventCallOutResponse.getEvents()){
                            SVMXC__SVMX_Optimizer__c optimizer =mapEventOptimizerIdObj.get(optimizerEvent.Id);
                            if('OPT_COMPLETED'.equalsIgnoreCase(optimizerEvent.SVMXC__Optimizer_Status__c)){
                                lstDeleteOptTrans.add(optimizer);
                            }else{
                                optimizer.SVMXC__Optimizer_Status__c = 'BATCH_FAILED';
                                optimizer.SVMXC__Optimizer_Retry_Count__c = optimizer.SVMXC__Optimizer_Retry_Count__c + 1;
                                optimizer.SVMXC__Optimizer_Error_Text__c = optimizerEvent.SVMXC__Optimizer_Error_Text__c;
                                //add the list of failed events to be updated after callout
                                lstUpdateOptTrans.add(optimizer);    
                            }
                        }
                        //update the events optimizer record with corresponding callout success or error details
                        lstUpdateOptTrans.addAll(eventCallOutResponse.getEvents());
                        //WSCH_WorkOrderEventHelper.updateNonWoEvents(eventCallOutResponse.getEvents());
                      }
                      WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
                      if(eventCallOutResponse!= null){
                          woResponse.getLstTechEvent().addAll(eventCallOutResponse.getTechEvents());
                          WSCH_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
                      }
                }
            }
            if(mapTechOptimizerIdObj != null && mapTechOptimizerIdObj.size() > 0){
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::No. of technician for callout...'+mapTechOptimizerIdObj.size());
                WSCH_Provider_ECO_TechnicianService techService = new WSCH_Provider_ECO_TechnicianService();
                list<SVMXC__SVMX_Optimizer__c> lstTechOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
                List<String> lstOptimizerId = new List<String>(mapTechOptimizerIdObj.keySet());
                lstTechOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerById(lstOptimizerId);
                if(lstTechOptimizer != null && lstTechOptimizer.size() >0 ){
                    techCallOutResponse= techService.manageTechnicians(lstTechOptimizer);
                }
            }

            //perform the DMLs after the callout completion
            
            if(!lstDeleteOptTrans.isEmpty()){
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::No. of maxQ Optimizer records completed and deleted...'+lstDeleteOptTrans.size());
                Database.delete(lstDeleteOptTrans);
            }
            if(!lstUpdateOptTrans.isEmpty()){
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler ::No. of maxQ Optimizer records failed with errors...'+lstUpdateOptTrans.size());
                Database.update(lstUpdateOptTrans); 
            }

            WSCH_AuditLogger.finish();
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_ECO_MaxQSchHandler :: optimizeBatchProcess :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    
    public static Boolean checkWoResponse(WSCH_WorkOrderResponse woResp){
        Boolean isWoSuccess = false;
        if(woResp != null){
            for(SVMXC__Service_Order__c woRec: woResp.getLstWorkOrder()){
                if((woRec.SVMXC__OptiMax_Status__c.equals(WSCH_ECO_Constants.STATUS_OPT_TENTATIVE)) ||
                (woRec.SVMXC__OptiMax_Status__c.equals(WSCH_ECO_Constants.STATUS_OPT_COMPLETED)) || (woRec.SVMXC__OptiMax_Status__c.equals(WSCH_ECO_Constants.STATUS_OPT_INITIATED))){
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
            setVal = WSCH_CommonUtils.getSettingValue('OMAX004','SET005');
            if(String.isNotBlank(setVal)){
                sMaxQBatchSize = Integer.valueOf(setVal);
            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: SmaxBatchSize ' + sMaxQBatchSize);
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_ECO_MaxQSchHandler:getSmaxBatchSize() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return sMaxQBatchSize;
    }
    
    public static String getSchedulerExpression(Datetime dt) {

        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
    
    public static boolean startMaxQCronJob(Integer schedulerStartTime){
       String cronJobName = 'MAXQ_schedule';
       
       //Following logic checks if same cron job is running , then returns false.
       
       Boolean isCronJobRunning = WSCH_CommonUtils.isCronJobRunning(cronJobName);
       if(isCronJobRunning) {
           WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler::startMaxQCronJob()::isCronJobRunning- '+isCronJobRunning);          
            return false;    // Already running
       }
       
       if((WSCH_ECO_TriggerHandler.isSmaxQSettingEnabled != null) && (WSCH_ECO_TriggerHandler.isSmaxQSettingEnabled)){
           String maxQFreq = WSCH_CommonUtils.getSettingValue('OMAX004','SET006');
           WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler::startMaxQCronJob()::maxQFreq '+maxQFreq );
           if(String.isNotBlank(maxQFreq)){
               schedulerStartTime = Integer.valueOf(maxQFreq);
           }
       }
       
       if (schedulerStartTime == null || schedulerStartTime == 0) {
           schedulerStartTime = 30;
       }
       WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler::startMaxQCronJob()::cronJobName '+cronJobName);
       WSCH_AuditLogger.finish();
       //Start the batch Apex in next 10 seconds.
       WSCH_Provider_ECO_MaxQScheduler maxQSchduler = new WSCH_Provider_ECO_MaxQScheduler();
       System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addSeconds(schedulerStartTime)), maxQSchduler);
       return true;
   } 
    
    public static WSCH_WorkOrderResponse processDependencyWorkOrders(Set<String> setOfDependencyGroupIds) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler::processDependencyWorkOrders()::Start.');
        //fetching all the related dependencyObjects for a the group Ids fetched above
        List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();
        Map<Id, SVMXC__Service_Order__c> mapOfWOIdWorkOrder = new Map<Id, SVMXC__Service_Order__c>();
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxEcoProcessMap = WSCH_CommonUtils.getEcoDP();
        List<SVMXC__Service_Order_Dependency__c> lstOfFilteredDependencyObj = new List<SVMXC__Service_Order_Dependency__c>();
        Set<SVMXC__Service_Order__c> setOfFilteredDependencyWOs = new Set<SVMXC__Service_Order__c>();
        WSCH_Provider_ECO_SchedulingService realTimeOpt = new WSCH_Provider_ECO_SchedulingService();
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();

        //fetch all the dependency objects for all the groupIds received above
        if(setOfDependencyGroupIds.size() > 0){
            for(Id depGroupId : setOfDependencyGroupIds){
                dependencyGroupList.addAll(WSCH_CommonUtils.fetchGroupDependency(depGroupId));
            }
        }

        //fetch all the WO Ids from the dependency objects
        Set<String> WO_Ids = new Set<String>();
        if(dependencyGroupList.size() > 0) {
            for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
                WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
            }
        }
        //fetch all the WOs from the primary and secondary WO Ids fetched above
        List<String> lstOfWOIds = new List<String>(WO_Ids);
        List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: processDependencyWorkOrders(): dependencyGroupList.size() - ' + dependencyGroupList.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: processDependencyWorkOrders(): woList.size() - ' + woList.size());
        
        //create a map of WOid and WO which is used below to create a filtered list of DependencyObj and DependencyWOs
        for(SVMXC__Service_Order__c eachWO: woList) {
            mapOfWOIdWorkOrder.put(eachWO.Id, eachWO);
        }

        //Create a filtered list of dependencyObj and dependencyWOs if they have RTO DP only.
        if(dependencyGroupList.size() > 0) {
            for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                SVMXC__Service_Order__c primaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Primary_Work_Order__c);
                SVMXC__Service_Order__c secondaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Secondary_Work_Order__c);
                //if both primary and secondary WOs has a valid RTO DP only then add this DependencyObject to the filtered list
                if(svmxEcoProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) &&
                            svmxEcoProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                    lstOfFilteredDependencyObj.add(groupDependencyRecords);
                    //also add the primary and secondary WOs to the new filtered listOfDepWOs
                    setOfFilteredDependencyWOs.add(primaryWO);
                    setOfFilteredDependencyWOs.add(secondaryWO);
                }
            }
        }

        List<SVMXC__Service_Order__c> lstOfFilteredDependencyWOs = new List<SVMXC__Service_Order__c>(setOfFilteredDependencyWOs);

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: processDependencyWorkOrders(): lstOfFilteredDependencyObj.size() - ' + lstOfFilteredDependencyObj.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: processDependencyWorkOrders(): lstOfFilteredDependencyWOs.size() - ' + lstOfFilteredDependencyWOs.size());

        if(lstOfFilteredDependencyObj.size() > 0 && lstOfFilteredDependencyWOs.size() > 0) {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: processDependencyWorkOrders(): Before making manageDependencyBooking() call');
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            woResponse = realTimeOpt.manageDependencyBooking(lstOfFilteredDependencyObj, lstOfFilteredDependencyWOs);
        } else {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_MaxQSchHandler: processDependencyWorkOrders(): could not make the dependencyCall as there are no valid dependency objects');
            WSCH_AuditLogger.finish();
        }
        return woResponse;
    }
}