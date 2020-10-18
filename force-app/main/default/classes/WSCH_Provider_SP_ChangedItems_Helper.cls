//public class WSCH_Provider_SP_ChangedItems_Helper {
public with sharing class WSCH_Provider_SP_ChangedItems_Helper {
    
    /*public static void doProcessRequest(SVMXC__SVMX_Optimizer__c optimizerObj, WSCH_Provider_SP_Push_Stubs.PushRequest req){
        Boolean result = false;
        try{
            if(req.workItems != null){
                for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
                    WSCH_AuditLogger.setLogContext(workItem.id);
                    if('job'.equalsIgnoreCase(workItem.type)){
                        result = doProcessJobBookings(workItem,req.state);                  
                    }else if('activity'.equalsIgnoreCase(workItem.type)){
                        result = doProcessActivities(workItem,req.state);
                    }else if('break'.equalsIgnoreCase(workItem.type)){
                        result = doProcessBreakInfo(workItem,req.state);
                    }
                }
            }
            //if result is failure(false) then insert the optimizer record.
            if(!result){
                WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Failure Transaction so inserting json request into Optimizer Transaction...');
                insert optimizerObj;
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            insert optimizerObj;
        }
    }*/
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();

    
    public static Boolean doProcessRequest(SVMXC__SVMX_Optimizer__c optimizerObj, WSCH_Provider_SP_Push_Stubs.PushRequest req){
        Boolean result = false;
        try{
            if(req.workItems != null) {
                for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
                        WSCH_AuditLogger.setLogContext(workItem.id);
                        if('job'.equalsIgnoreCase(workItem.type)){
                            
                            //logging if the push request is coming from Dispatch client or Change client
                            if(isDispatchClient(req)) {
                                WSCH_AuditLogger.debug('Processing the request from Dispatch Client');
                            } else {
                                WSCH_AuditLogger.debug('Processing the request from Change Client');
                            }
                            
                            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Processing job when req.state is : ' + req.state);
                            
                            //capturing the timestamps before call
                            Datetime dateTimeBeforeCall = Datetime.now();
                            WSCH_AuditLogger.debug('dateTimeBeforeCall : ' + dateTimeBeforeCall);
                            
                            result = doProcessJobBookings(workItem,req.state,req.changeTime);
                            
                            //If Linx performance metric collection is enabled, then collect metrics for push messages.
                            if(WSCH_AuditLogger.isLinxMetricLogEnabled) {
                                //logging the PUSH_PROCESSTIME
                                WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"PROCESSTIME"', null, (Datetime.now().getTime() - dateTimeBeforeCall.getTime()));
                                
                                //logging the PUSH_DISPATCH or PUSH_STATUS timestamps
                                Datetime pushMsgDatetime;
                                if(String.isNotBlank(req.changeTime)) {
                                    pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(req.changeTime);
                                    WSCH_AuditLogger.debug('pushMsgDatetime : ' + pushMsgDatetime);
                                }
                                
                                if(isDispatchClient(req)) {
                                    WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"DISPATCH"', dateTimeBeforeCall, null);
                                    WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"DISPATCH"_"SPCHANGETIME"', pushMsgDatetime, null);
                                } else  {
                                    WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"STATUS"', dateTimeBeforeCall, null);
                                    WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"STATUS"_"SPCHANGETIME"', pushMsgDatetime, null);
                                }
                                
                                //logging the PUSH_DISPATCH_DIFF or PUSH_STATUS_DIFF in milliseconds
                                if(isDispatchClient(req) && pushMsgDatetime != null) {
                                    WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"DISPATCH_DIFF"', null, (dateTimeBeforeCall.getTime()-pushMsgDatetime.getTime()));
                                } else if(pushMsgDatetime != null) {
                                    WSCH_AuditLogger.appendMetrics(workItem.id, '"PUSH"_"STATUS_DIFF"', null, (dateTimeBeforeCall.getTime()-pushMsgDatetime.getTime()));
                                }
                                
                                WSCH_AuditLogger.savePerformanceMetrics();
                            }
                        }else if('activity'.equalsIgnoreCase(workItem.type)){
                            
                            //logging if the push request is coming from Dispatch client or Change client
                            if(isDispatchClient(req)) {
                                WSCH_AuditLogger.debug('Processing the request from Dispatch Client');
                            } else {
                                WSCH_AuditLogger.debug('Processing the request from Change Client');
                            }
                            
                            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Processing activity when req.state is : ' + req.state);
                            result = doProcessActivities(workItem,req.state,req.changeTime);
                        }else if('break'.equalsIgnoreCase(workItem.type)){
                            
                            //logging if the push request is coming from Dispatch client or Change client
                            if(isDispatchClient(req)) {
                                WSCH_AuditLogger.debug('Processing the request from Dispatch Client');
                            } else {
                                WSCH_AuditLogger.debug('Processing the request from Change Client');
                            }
                            
                            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Processing break when req.state is : ' + req.state);
                            result = doProcessBreakInfo(workItem,req.state,req.changeTime);
                        }
                        
                        //if result is failure(false) then insert the optimizer record.
                        if(!result){
                            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Failure Transaction so inserting json request into Optimizer Transaction...');
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(optimizerObj, COMM_SecurityUtils.Access.Createable)){
					            insert optimizerObj;
							}
                        }
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(optimizerObj, COMM_SecurityUtils.Access.Createable)){
				insert optimizerObj;
			}
        }
        return result;
    }
    
    public static boolean isDispatchClient(WSCH_Provider_SP_Push_Stubs.PushRequest req) {
        if(String.isNotBlank(req.state)) {
            return true;
        } else {
            return false;
        }
    }
    
    /*public static boolean getIsProcessReq(WSCH_Provider_SP_Push_Stubs.PushRequest req, WSCH_Provider_SP_Push_Stubs.WorkItem workItem) {
        
        boolean flag = false;
        if(String.isBlank(req.state)) {
            flag = true;
        } else if(String.isNotBlank(req.state) && 'break'.equalsIgnoreCase(workItem.type)) {
            flag = true;
        }
        return flag;
    }*/
    
    //This method invoked from Get changed workitems api call response    
    public static void doProcessRequest(WSCH_Provider_SP_Push_Stubs.PushRequest req){
        Boolean result = false;
        try{
            if(req.workItems != null){
                for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
                    /*if('job'.equalsIgnoreCase(workItem.type)){
                        result = doProcessJobBookings(workItem,req.state,req.changeTime);                  
                    }else */
                    if('activity'.equalsIgnoreCase(workItem.type)){
                        result = doProcessActivities(workItem,req.state,req.changeTime);
                    }else if('break'.equalsIgnoreCase(workItem.type)){
                        result = doProcessBreakInfo(workItem,req.state,req.changeTime);
                    }
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest(PushRequest)::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    //This method invoked by scheduler for processing the failure push notifications
    public static void doProcessRequest(List<SVMXC__SVMX_Optimizer__c> optimizerObjLst){
        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest(by scheduler)  begins');
        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest:optimizerObjLst - ' + optimizerObjLst);
        try{
            Set<String> setWOName = new Set<String>();
            for(SVMXC__SVMX_Optimizer__c optimizerObj:optimizerObjLst){
                String request = optimizerObj.SVMXC__Optimizer_Error_Text__c;
                WSCH_Provider_SP_Push_Stubs.PushRequest req = (WSCH_Provider_SP_Push_Stubs.PushRequest)JSON.deserialize(request, WSCH_Provider_SP_Push_Stubs.PushRequest.class);            
                if(req.workItems != null){
                    for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
                        if('job'.equalsIgnoreCase(workItem.type)) {
                            setWOName.add(workItem.id);
                        }
                    }
                }
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest:setWOName - ' + setWOName);
            //getting all the WO's by name which are PUSH failed
            List<String> lstWOName = new List<String>();
            List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
            if(!setWOName.isEmpty()) {
                lstWOName = new List<String>(setWOName);
                lstWorkOrders = WSCH_CommonUtils.fetchWorkOrdersByName(lstWOName);
            }
            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest:lstWOName - ' + lstWOName);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest:lstWorkOrders - ' + lstWorkOrders);
            
            List<SVMXC__SVMX_Optimizer__c> lstDelOptimizerObj = new List<SVMXC__SVMX_Optimizer__c>();
            List<SVMXC__SVMX_Optimizer__c> lstUpateOptimizerObj = new List<SVMXC__SVMX_Optimizer__c>();
            
            Map<String, SVMXC__Service_Order__c> mapOfWos = new Map<String, SVMXC__Service_Order__c>();
            if(lstWorkOrders != null && lstWorkOrders.size() > 0) {
                for(SVMXC__Service_Order__c eachWO : lstWorkOrders) {
                    mapOfWos.put(eachWO.Name, eachWO);
                }
            }
            
            WSCH_AuditLogger.debug('mapOfWos - ' + mapOfWos);
            
            for(SVMXC__SVMX_Optimizer__c optimizerObj:optimizerObjLst) {
                Boolean result = false;
                try{
                    String request = optimizerObj.SVMXC__Optimizer_Error_Text__c;
                    WSCH_Provider_SP_Push_Stubs.PushRequest req = (WSCH_Provider_SP_Push_Stubs.PushRequest)JSON.deserialize(request, WSCH_Provider_SP_Push_Stubs.PushRequest.class);
                    if(req.workItems != null){
                        for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
                            if('job'.equalsIgnoreCase(workItem.type))
                                WSCH_AuditLogger.debug('workItem.id - ' + workItem.id);
                            if('job'.equalsIgnoreCase(workItem.type) && mapOfWos.containsKey(workItem.id)){
                                //processing the PUSH failure for WO only if the error json on Optimizer object is latest. That is
                                // the lastModifiedDate of the Optimizer Trans Obj is greater than lastModifiedDate on WO
                                if(optimizerObj.lastModifiedDate > mapOfWos.get(workItem.id).lastModifiedDate) {
                                    result = doProcessJobBookings(workItem,req.state,req.changeTime);
                                }
                            } else if('activity'.equalsIgnoreCase(workItem.type)){
                                result = doProcessActivities(workItem,req.state,req.changeTime);
                            } else if('break'.equalsIgnoreCase(workItem.type)){
                                result = doProcessBreakInfo(workItem,req.state,req.changeTime);
                            }
                        }
                    }
                    if(result){
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Successfull Transaction so Optimizer Transaction will be deleted....');
                        //insert optimizerObj;
                        //delete optimizerObj;
                        lstDelOptimizerObj.add(optimizerObj); //adding this optimizer object to delete after successful processing
                    } else {
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest:: Transaction failed so retry count will be updated....');
                        WSCH_AuditLogger.debug('optimizerObj - ' + optimizerObj);
                        if(optimizerObj.SVMXC__Optimizer_Retry_Count__c != null) {
                            optimizerObj.SVMXC__Optimizer_Retry_Count__c = optimizerObj.SVMXC__Optimizer_Retry_Count__c + 1;
                        } else {
                            optimizerObj.SVMXC__Optimizer_Retry_Count__c = 1;
                        }
                        lstUpateOptimizerObj.add(optimizerObj);
                    }
                } catch(Exception ex){
                    if(optimizerObj.SVMXC__Optimizer_Retry_Count__c != null) {
                            optimizerObj.SVMXC__Optimizer_Retry_Count__c = optimizerObj.SVMXC__Optimizer_Retry_Count__c + 1;
                    } else {
                        optimizerObj.SVMXC__Optimizer_Retry_Count__c = 1;
                    }
                    lstUpateOptimizerObj.add(optimizerObj);
                    WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest(optimizerObjLst)::Inner catch block:Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                }
            }
            if(!lstDelOptimizerObj.isEmpty()) {
                //Database.delete(lstDelOptimizerObj);
                // -CRUD
                if(securityUtils.isDeletableObject( 'SVMXC__SVMX_Optimizer__c' )) 
                    {
                        delete lstDelOptimizerObj;
                    } 
                else 
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
            }
            if(!lstUpateOptimizerObj.isEmpty()) {
                //Database.update(lstUpateOptimizerObj);
                if (!securityUtils.verifyFieldAccess(lstUpateOptimizerObj, COMM_SecurityUtils.Access.Updateable, false))
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {
                        update lstUpateOptimizerObj;
                    }
            }
        } catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest(optimizerObjLst)::Outer catch block:Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } finally{
            WSCH_AuditLogger.finish();
        }
        
        
        /*for(SVMXC__SVMX_Optimizer__c optimizerObj:optimizerObjLst){
            Boolean result = false;
            try{
                String request = optimizerObj.SVMXC__Optimizer_Error_Text__c;
                WSCH_Provider_SP_Push_Stubs.PushRequest req = (WSCH_Provider_SP_Push_Stubs.PushRequest)JSON.deserialize(request, WSCH_Provider_SP_Push_Stubs.PushRequest.class);            
                if(req.workItems != null){
                    for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
                        if('job'.equalsIgnoreCase(workItem.type)){
                            result = doProcessJobBookings(workItem,req.state);                  
                        } else if('activity'.equalsIgnoreCase(workItem.type)){
                            result = doProcessActivities(workItem,req.state);
                        } else if('break'.equalsIgnoreCase(workItem.type)){
                            result = doProcessBreakInfo(workItem,req.state);
                        }
                    }
                }
                //if result is success(true) then delete the optimizer record.
                if(result){
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest::Successfull Transaction so Optimizer Transaction will be deleted....');
                    //insert optimizerObj;
                    delete optimizerObj;
                }
            }catch(Exception ex){
                WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessRequest(optimizerObjLst)::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }finally{
                WSCH_AuditLogger.finish();
            }
        }*/
    }
    
    public static boolean doProcessJobBookings(WSCH_Provider_SP_Push_Stubs.WorkItem workItem, String changedItemState, String changeTime){
        WSCH_WorkOrderResponse workOrderResponse;
        try{
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessJobBookings:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
            //get workOrder from workItem.id
            String workOrderId = WSCH_CommonUtils.getWorkItemIds('Name', new List<String>{workItem.id}).get(workItem.id);       

            if (String.isBlank(workOrderId)) {
                return true;
            }
            
            //Retrieving the WorkOrder using work order Id.
            SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(workOrderId);
            
            //changeTime format: 2015-02-09 15:00
            //convert the string datetime coming from Push message to Datetime object
            Datetime pushMsgDatetime;
            if(String.isNotBlank(changeTime)) {
                pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(changeTime);
            }
            
            //check to see if the push message timestamp > timestamp on Work Order field SVMXC__SM_Optimizer_Message_Creation_Date_Time__c.
            //if not skip the processing of that message
            if(workOrder != null && workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c != null && pushMsgDatetime != null &&
                        (pushMsgDatetime < workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c)) {
                WSCH_AuditLogger.debug('Timestamp received from Push notification is older than Work order timestamp. So skipping this Push message from processing');
                return true;                                            
            }
            //get workorder scheduling status           
            //String workOrderStatus = WSCH_CommonUtils.getServicePowerJobStatus(workOrder.SVMXC__Work_Order_Scheduling_Status__c);
            
            String pushStatus;
            if(workItem.Task != null) {
                WSCH_Provider_SP_Push_Stubs.Task task = workItem.Task;
                if(task != null) {
                    pushStatus = task.action;
                }
            } else if(String.IsNotBlank(changedItemState)) {
                pushStatus = changedItemState;
            }
            
            //For Dispatch Client ----> changedItemState = NotBlank
            //For Change Client -----> changedItemState = Blank
               
            Boolean isProcessPushMsg = false;
            
            if(workOrder != null) {
                //Ignore the push notifications when WO scheduling status is already cancelled.
                if(String.isNotBlank(workOrder.SVMXC__Work_Order_Scheduling_Status__c) && workOrder.SVMXC__Work_Order_Scheduling_Status__c.equalsIgnoreCase('Cancelled')) {
                    WSCH_AuditLogger.debug('Work Order scheduling status is Cancelled. So skipping this push message');
                    isProcessPushMsg = false;
                }
                //If it is a Dispatch Client message or a Change Client message, just process it when wo.timestamp is null for the first time.
                else if(workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c == null) {
                    WSCH_AuditLogger.debug('Work Order timestamp is null. So processing this push message');
                    isProcessPushMsg = true;
                } 
                //If it is Dispatch Client message and WO.timestamp != null and Push.timestamp > WO.timestamp, then process it.
                else if((workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c != null && pushMsgDatetime != null) && 
                    (String.isNotBlank(changedItemState) && pushMsgDatetime >= workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c)) {
                    WSCH_AuditLogger.debug('PushMessage timestamp > WO timestamp. So processing this Dispatch Client message');
                    isProcessPushMsg = true;
                }
                //if it is a Change client Message(CM) and Push message timestamp >= WO timestamp, then process the message,
                //because status updates are received only from CM. 
                else if((workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c != null && pushMsgDatetime != null) && 
                    (String.isBlank(changedItemState) && pushMsgDatetime >= workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c)) {
                    WSCH_AuditLogger.debug('PushMessage timestamp >= WO timestamp. So processing this Change Client message');
                    isProcessPushMsg = true;
                }
            }
            
            if(isProcessPushMsg) {
                WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessJobBookings::Current Status:'+pushStatus);
                if(String.isNotBlank(pushStatus)){
                    String schedulingStatus = pushStatus;
                    if(pushStatus.equalsIgnorecase('denotified')){ 
                        schedulingStatus = 'planned';
                    } else if(pushStatus.equalsIgnorecase('renotified')){
                        schedulingStatus = 'notified';
                    }
                              
                    workOrderResponse = mapBookingRequest(workItem,workOrderId,schedulingStatus);
                    workOrderResponse.setChangeTime(pushMsgDatetime);
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_WorkOrderEventHelper.processWorkOrderResponse(workOrderResponse);
                }
            }
                
            //  Setting the drip feed check box as true in case of earmark and reearmark.
            //  And Setting drip feed check box as false in case of unearmark.
            /*if(String.isNotBlank(changedItemState)){
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                if ('denotified'.equalsIgnoreCase(changedItemState)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessJobBookings:UnEarmarked Job, remove the drip feed....');                  
                    WSCH_Provider_SP_DispatchClientHelper.updateDripFeed(workOrder,false);
                } else {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessJobBookings:Earmarked Job, update the drip feed....');
                    WSCH_Provider_SP_DispatchClientHelper.updateDripFeed(workOrder,true);
                }
            }*/
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessJobBookings::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;           
        }
        return true;
    }
    
    /*public static boolean doProcessActivities(WSCH_Provider_SP_Push_Stubs.WorkItem workItem,String changedItemState){
        try{
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
            SObject  sobjEvent = doProcessEvents(workItem, changedItemState);
            if(sobjEvent != null){
                if(String.isNotBlank(changedItemState)){
                    if ('denotified'.equalsIgnoreCase(changedItemState)) {
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:Denotified Activity, remove the drip feed....');                   
                        updateDripFeedEvents(sobjEvent, false);
                    } else {
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:Notified Activity, update the drip feed....');
                        updateDripFeedEvents(sobjEvent, true);
                    }
                }
            }else{
                return false;
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;           
        }       
        return true;
    }*/
    
    public static boolean doProcessActivities(WSCH_Provider_SP_Push_Stubs.WorkItem workItem,String changedItemState, String changeTime){
        try{
            Boolean isProcessPush = true;
            Datetime eventMsgDatetime = null;
            Datetime pushMsgDatetime = null;
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
            SObject  sobjEvent = doProcessEvents(workItem, changedItemState, changeTime, eventMsgDatetime);
            
            //changeTime format: 2015-02-09 15:00
            //convert the string datetime coming from Push message to Datetime object
            if(String.isNotBlank(changeTime)) {
                pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(changeTime);
            }
            
            if(eventMsgDatetime !=  null && pushMsgDatetime != null && eventMsgDatetime > pushMsgDatetime) { 
                isProcessPush = false;
            }
           
            String pushStatus;
            if(workItem.Task != null) {
                WSCH_Provider_SP_Push_Stubs.Task task = workItem.Task;
                if(task != null) {
                    pushStatus = task.action;
                }
            } else if(String.IsNotBlank(changedItemState)) {
                pushStatus = changedItemState;
            }
            
            if(sobjEvent != null){
                if ('notified'.equalsIgnoreCase(pushStatus) || 'renotified'.equalsIgnoreCase(pushStatus)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:Notified Activity, update the drip feed....');                   
                    updateDripFeedEvents(sobjEvent, true);
                } else if('planned'.equalsIgnoreCase(pushStatus) || 'denotified'.equalsIgnoreCase(pushStatus)){
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:Denotified Activity, remove the drip feed....');
                    updateDripFeedEvents(sobjEvent, false);
                }
            }else{
                if(isProcessPush)
                    return false;       //Return false if push processing has to be processed and the processing has failed
                else
                    return true;        //Return true if push processing should not be processed after timestamp comparison
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;           
        }       
        return true;
    }

    public static boolean doProcessBreakInfo(WSCH_Provider_SP_Push_Stubs.WorkItem workItem, String changedItemState, String changeTime){
        
        try{
            Boolean isProcessPush = true;
            Datetime eventMsgDatetime = null;
            Datetime pushMsgDatetime = null;
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessBreakInfo:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
            SObject  sobjEvent = doProcessEvents(workItem, changedItemState, changeTime, eventMsgDatetime); 
            
            //changeTime format: 2015-02-09 15:00
            //convert the string datetime coming from Push message to Datetime object
            if(String.isNotBlank(changeTime)) {
                pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(changeTime);
            }
            
            if(eventMsgDatetime !=  null && pushMsgDatetime != null && eventMsgDatetime > pushMsgDatetime) { 
                isProcessPush = false;
            }
              
            if(sobjEvent != null){
                WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessBreakInfo::Notified Break for SF Event, drip field already checked when event creation..');
                if(String.isNotBlank(changedItemState)){
                    if ('denotified'.equalsIgnoreCase(changedItemState)) {
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:Denotified Break, delete the break event....');                    
                        //updateDripFeedEvents(sobjEvent, false);
                        doDeleteBreak(sobjEvent);
                    } else {
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessActivities:Notified Break, update the drip feed....');
                        updateDripFeedEvents(sobjEvent, true);
                    }
                }
            }else{
                if(isProcessPush)
                    return false;
                else
                    return true;
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessBreakInfo::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;           
        }
        return true;
    }

    public static SObject doProcessEvents(WSCH_Provider_SP_Push_Stubs.WorkItem workItem, String changedItemState, String changeTime, Datetime eventMsgDatetime){
        SObject resultSObj = null;
        try{
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
            //get technician external id
            WSCH_Provider_SP_Push_Stubs.Booking booking = workItem.booking;
            String technicianExtId = booking.tech;
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents()::technicianExtId...'+technicianExtId);
            
            //get technician object
            List<SVMXC__Service_Group_Members__c> lstTechs = [Select Id, SVMXC__Service_Group__c, SVMXC__Optimizer_External_ID__c, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Optimizer_External_ID__c =: technicianExtId];
            WSCH_AuditLogger.debug('lstTechs...'+lstTechs);
            if(lstTechs == null || lstTechs.size() == 0){
                return null;
            }
                
            boolean isSFEvent = false;
            if(lstTechs[0].SVMXC__Salesforce_User__c != null){
                isSFEvent=true;
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents()::isSFEvent...'+isSFEvent);
                        
            DateTime eventEndDateTime, eventStartDateTime;
            if(String.isNotBlank(booking.start)){
                eventStartDateTime = WSCH_DateUtils.parseSPDateTimeGmt(booking.start);
            }
            
            if(String.isNotBlank(booking.end_x)){
                eventEndDateTime = WSCH_DateUtils.parseSPDateTimeGmt(booking.end_x);
            }else{
                //for break events.
                WSCH_Provider_SP_Push_Stubs.WorkType workType = workItem.workType;
                if(workType != null & workType.dur != null){
                    eventEndDateTime = eventStartDateTime.addMinutes(workType.dur);
                }
            }
            
            Double serviceDuration = WSCH_DateUtils.getDurationInMinutes(eventStartDateTime,eventEndDateTime);
            
            //get Activity id,subject from ServicePower
            String activityId;
            String eventSubject;
            if('break'.equalsIgnoreCase(workItem.type)){
                String breakId = workItem.id;
                activityId = breakId.substring(0,breakId.length()-6);
                //To remove the technician id, timestamp from the activityId. Only break name is required for break subject.
                //eventSubject = workItem.type+'-'+breakId.substring(technicianExtId.length()+1,breakId.length()-17);
                WSCH_Provider_SP_Push_Stubs.WorkType workType = workItem.workType;
                if(workType != null & workType.name != null){
                    eventSubject = workItem.type+'-'+workType.name; 
                }
            }else{
                activityId = workItem.id;
                eventSubject = workItem.type+'-'+activityId;
            }

            //Retrieving existing optimizer object
            SVMXC__SVMX_Optimizer__c optimizerObj = WSCH_CommonUtils.fetchOptimizerByExtId(activityId);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents()::optimizerObj...'+optimizerObj);
                       
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            if(isSFEvent) {
                Event sfEvent;
                if(optimizerObj != null){
                    String eventId = optimizerObj.SVMXC__WhatId__c;
                    /*Commented and added the below code as per Defect#013844*/
                    //sfEvent = WSCH_CommonUtils.fetchSFEventObjectById(eventId);
                    sfEvent = WSCH_CRUD_Helper.fetchSFEventObjectById(eventId);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents()::sfEvent...'+sfEvent);
                    if(sfEvent == null){
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents()::Skip the SF Event update due to permission issue for site user. Schedule Batch Apex will update this event...');
                        return resultSObj;
                    }
                }
                if(sfEvent == null){
                    sfEvent = new Event();
                }
                if(sfEvent != null) {
                    Datetime pushMsgDatetime;
                    //changeTime format: 2015-02-09 15:00
                    //convert the string datetime coming from Push message to Datetime object
                    if(String.isNotBlank(changeTime)) {
                        pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(changeTime);
                    }
                    
                    eventMsgDatetime = sfEvent.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c;
                    
                    //check to see if the push message timestamp > timestamp on Work Order field SVMXC__SM_Optimizer_Message_Creation_Date_Time__c.
                    //if not skip the processing of that message
                    if(eventMsgDatetime !=  null && pushMsgDatetime != null && eventMsgDatetime > pushMsgDatetime) {
                        WSCH_AuditLogger.debug('Timestamp received from Push notification is older than Event timestamp. So skipping this Push message from processing');
                        return null;                                            
                    }
                    
                    sfEvent.OwnerId = lstTechs[0].SVMXC__Salesforce_User__c;
                    //Check if relatedTo is not enabled then skip the what id update.
                    if('True' == WSCH_CommonUtils.getSettingValue('DCON005','SET001')){         
                        sfEvent.WhatId = lstTechs[0].Id;
                    }
                    if(sfEvent.Subject == null)
                        sfEvent.Subject = eventSubject;
                    sfEvent.StartDateTime = eventStartDateTime;
                    sfEvent.EndDateTime = eventEndDateTime;
                    sfEvent.ActivityDate = eventStartDateTime.date();
                    sfEvent.ActivityDateTime = eventStartDateTime;
                    sfEvent.DurationInMinutes = integer.valueOf(serviceDuration);
                    sfEvent.SVMXC__Service_Duration__c=integer.valueOf(serviceDuration)* 60;
                    sfEvent.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = pushMsgDatetime;
                    if('break'.equalsIgnoreCase(workItem.type)){
                        updateDripFeedBreakEvents(sfEvent);
                    }
                    //upsert sfEvent;
                    WSCH_CRUD_Helper.upsertEvents(sfEvent);
                    resultSObj = sfEvent;
                    if(optimizerObj == null){
                        optimizerObj = getOptimizerObject(sfEvent.id, activityId, workItem.type);
                        //insert optimizerObj;
                        // -CRUD
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObj, COMM_SecurityUtils.Access.Createable ) ) {
                            insert optimizerObj;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
                }
            } else {
                SVMXC__SVMX_Event__c svmxEvent;
                if(optimizerObj != null){
                    String eventId = optimizerObj.SVMXC__WhatId__c;
                    svmxEvent = WSCH_CommonUtils.fetchSVMXEventObjectById(eventId);                    
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents()::svmxEvent...'+svmxEvent);
                }
                if(svmxEvent == null){
                    svmxEvent = new SVMXC__SVMX_Event__c();
                }
                if(svmxEvent != null ){
                    Datetime pushMsgDatetime;
                    //changeTime format: 2015-02-09 15:00
                    //convert the string datetime coming from Push message to Datetime object
                    if(String.isNotBlank(changeTime)) {
                        pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(changeTime);
                    }
                    
                    eventMsgDatetime = svmxEvent.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c;
                    
                    //check to see if the push message timestamp > timestamp on Work Order field SVMXC__SM_Optimizer_Message_Creation_Date_Time__c.
                    //if not skip the processing of that message
                    if(eventMsgDatetime !=  null && pushMsgDatetime != null && eventMsgDatetime > pushMsgDatetime) {
                        WSCH_AuditLogger.debug('Timestamp received from Push notification is older than Event timestamp. So skipping this Push message from processing');
                        return null;                                            
                    }
                    
                    if(svmxEvent.Name == null)
                        svmxEvent.Name = eventSubject;
                    svmxEvent.SVMXC__WhoId__c = lstTechs[0].Id;
                    svmxEvent.SVMXC__Technician__c = lstTechs[0].Id;
                    svmxEvent.SVMXC__StartDateTime__c = eventStartDateTime;
                    svmxEvent.SVMXC__EndDateTime__c = eventEndDateTime;
                    svmxEvent.SVMXC__ActivityDate__c = eventStartDateTime.date();
                    svmxEvent.SVMXC__ActivityDateTime__c = eventStartDateTime;
                    svmxEvent.SVMXC__DurationInMinutes__c = integer.valueOf(serviceDuration);
                    svmxEvent.SVMXC__Service_Duration__c = integer.valueOf(serviceDuration)* 60;
                    svmxEvent.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = pushMsgDatetime;
                    //upsert svmxEvent;
                    // -CRUD
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( svmxEvent, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert svmxEvent;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    resultSObj = svmxEvent;
                    if(optimizerObj == null){
                        optimizerObj = getOptimizerObject(svmxEvent.id, activityId, workItem.type);
                        //insert optimizerObj;
                        // -CRUD
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObj, COMM_SecurityUtils.Access.Createable ) ) {
                            insert optimizerObj;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
                }
            }
            //handling drip feed for activity pulled through GetChangedWorkItems call.
            WSCH_AuditLogger.debug('WORKITEM.TYPE: ' + workItem.type + ' WORKITEM.LENGTH: ' + (workItem.type).length() + ' workItem.pullState: ' + workItem.pullState);
            if('activity'.equalsIgnoreCase(workItem.type) && null != workItem.pullState){
                if ('notified'.equalsIgnoreCase(workItem.pullState)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents():(PULL)Earmarked Activity, update the drip feed....');
                    updateDripFeedEvents(resultSObj, true);
                } else {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents():(PULL)Tentative Activity, remove the drip feed if drip is set already...');                  
                    updateDripFeedEvents(resultSObj, false);
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::doProcessEvents::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return null;
        }       
        return resultSObj;
    }    
    
    public static WSCH_WorkOrderResponse mapBookingRequest(WSCH_Provider_SP_Push_Stubs.WorkItem workItem,String workOrderId,String dispatchStatus) {
        
        WSCH_Provider_SP_Push_Stubs.Booking booking = workItem.booking;
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        List<WSCH_TechnicianEvent>  lstTechEvent = new List<WSCH_TechnicianEvent>();
        WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
        techEvent.setWorkOrderID(workOrderId);
        techEvent.setTechnicianExternalID(booking.tech);
        if(String.isNotBlank(booking.start)){
            techEvent.setStartDateTime(WSCH_DateUtils.parseSPDateTimeGmt(booking.start));
        }
        if(String.isNotBlank(booking.arr)){
            techEvent.setArrivalDateTime(WSCH_DateUtils.parseSPDateTimeGmt(booking.arr));
        }
        if(String.isNotBlank(booking.end_x)){
            techEvent.setFinishDateTime(WSCH_DateUtils.parseSPDateTimeGmt(booking.end_x));
        }
        techEvent.setDispatchStatus(dispatchStatus.toLowerCase());
        
        //Updating violation details into technician event
        WSCH_Provider_SP_Push_Stubs.AtRisk atRisk = workItem.AtRisk;
        if(atRisk != null && atRisk.type != null)
            techEvent.setViolationMessage(atRisk.type);

        //Updating is forcefix job or not
        WSCH_Provider_SP_Push_Stubs.Task task = workItem.task;
        if(task != null){
            Boolean isFixed = task.tied;
            techEvent.setIsFixed(isFixed);       
        }

        lstTechEvent.add(techEvent);
        woResponse.getLstTechEvent().addAll(lstTechEvent);
        return woResponse;
    }
    
    //Method returns Optimizer object
    private static SVMXC__SVMX_Optimizer__c getOptimizerObject(string eventId, string actId, String itemType) 
    {
        SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
        optimizer.SVMXC__Optimizer_External_ID__c = actId;
        if('Activity'.equalsIgnoreCase(itemType)){
            optimizer.SVMXC__WhatType__c = 'NON_WO_EVENT';    
        }else if('Break'.equalsIgnoreCase(itemType)) {
            optimizer.SVMXC__WhatType__c = 'BREAK';
        }
        optimizer.SVMXC__WhatId__c = eventId;
        optimizer.SVMXC__Optimizer_Status__c='OPT_COMPLETED';
        optimizer.SVMXC__Optimizer_Change_Token__c='CHANGE_CREATE';
        optimizer.SVMXC__Optimizer_Error_Text__c='This Event created by PUSH Broker Service';
        return optimizer;
    }
    
    /*
        Following method updates the drip field to true mentioned in the Drip settings SET002.
        Description for SET002 :
        "Comma separated list of fields used to determine when records are sent to mobile devices, if Drip Feed is enabled.
        Check box fields from any objects can be used. The Object and Fields should be specified using their API names (Object.Field notation).
        This is applicable when "Enable Drip Feed" is true."

        For example value of SET002 as : SVMXC__Service_Order__c.SVMXC__Drip__c
    */
    public static void updateDripFeedEvents(SObject sObjEvent,boolean dripFeedFlag) {
        
        String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
        //String dripObjFields = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
        if (!('TRUE'.equalsIgnoreCase(WSCH_CommonUtils.getSettingValue('DCON002','SET001')) && String.isNotBlank(dripObjFields))) {
            return;
        }
        
        String objType = String.valueOf(sObjEvent.getSObjectType());
        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::updateDripFeedEvents()::objType '+objType);
        String sfdcId;
        if('Event'.equalsIgnoreCase(objType)){
            Event event = (Event)sObjEvent;
            sfdcId = event.Id;
        }else if('SVMXC__SVMX_Event__c'.equalsIgnoreCase(objType)){
            SVMXC__SVMX_Event__c svmxEvent = (SVMXC__SVMX_Event__c) sObjEvent;
            sfdcId = svmxEvent.Id;
        }
        Map<String,String> objectCriteriaMap = new Map<String,String> {'Event'=>'id','SVMXC__SVMX_Event__c'=>'id'};
        String[] listDripFields = dripObjFields.split(',',-1);
        for(String dripField : listDripFields) {
            dripField = dripField.trim();
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::updateDripFeedEvents()::dripField '+dripField);           
            String[] objFields =  dripField.split('\\.',2);
            if(objFields[0].trim().equalsIgnoreCase(objType))
            {
                List<Sobject> sObjects = new List<Sobject>();
                String criteria = objectCriteriaMap.get(objFields[0]);
                try {
                    if(String.isNotBlank(criteria)) {
                        //String query = 'SELECT Id,' + objFields[1] + ' FROM ' + objFields[0] + ' WHERE ' + criteria +'=:sfdcId';
                        //sObjects = DataBase.query(query);
                        sObjects = WSCH_CRUD_Helper.fetchSObject(sfdcId, objFields[1], objFields[0]);
                        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::updateDripFeedEvents()::sObjects SIZE '+sObjects.size());
                        for (Integer index = sObjects.size() - 1; index >= 0 ; index-- ) {
                            Sobject sObj = sObjects[index];
                            Boolean currentDripFieldFlag = Boolean.valueOf(sObj.get(objFields[1].trim()));
                            if(dripFeedFlag != currentDripFieldFlag ) {
                                sObj.put(objFields[1].trim(),dripFeedFlag);
                            } else {
                                sObjects.remove(index);
                            }
                        }
                        //if(sObjects.size() > 0){update sObjects;}
                        if(sObjects.size() > 0){WSCH_CRUD_Helper.upsertListEvents( sObjects);}
                    }
                } catch (Exception ex) {
                    WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::updateDripFeedEvents():: Exception : ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                }
            }
        }
    }
    
    //This method include the update the drip field for SF event when creation itself. This is comes with job notifications.
    public static void updateDripFeedBreakEvents(Event sfEvent){
        try {
            String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
            //String dripObjFields = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
            if (!('TRUE'.equalsIgnoreCase(WSCH_CommonUtils.getSettingValue('DCON002','SET001')) && String.isNotBlank(dripObjFields))) {
                return;
            }
            String[] listDripFields = dripObjFields.split(',',-1);
            for(String dripField : listDripFields) {
                WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::updateDripFeedBreakEvents()::dripField '+dripField);          
                String[] objFields =  dripField.split('\\.',2);
                if(objFields[0].trim().equalsIgnoreCase('Event'))
                {
                    sfEvent.put(objFields[1].trim(),true);
                }
            }
        } catch (Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems_Helper::updateDripFeedBreakEvents():: Exception : ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    public static void deAllocateJobs(WSCH_Provider_SP_Push_Stubs.PushRequest req){
        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::deAllocateJobs:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
        for(WSCH_Provider_SP_Push_Stubs.WorkItem workItem :req.workItems){
            if('job'.equalsIgnoreCase(workItem.type)){
                //get workOrder from workItem.id
                String workOrderId = WSCH_CommonUtils.getWorkItemIds('Name', new List<String>{workItem.id}).get(workItem.id);
                //Retrieving the WorkOrder using work order Id.
                SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(workOrderId);
                workOrder.SVMXC__Scheduling_Change_Token__c = 'FORCE_SCHEDULE';
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                WSCH_WorkOrderEventHelper.unscheduleWorkOrder(workOrder);
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                //update workOrder;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(workOrder, COMM_SecurityUtils.Access.Updateable)){
					update workOrder;
				}
            }
        }       
    }
    
    public static void doDeleteBreak(SObject sObjEvent){
        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doDeleteBreak::sObjEvent - '+sObjEvent);
        //Retrieving existing optimizer object
        SVMXC__SVMX_Optimizer__c optimizerObj = WSCH_CommonUtils.fetchSVMXOptimizerByWhatId(sObjEvent.Id);
        WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems_Helper::doDeleteBreak()::optimizerObj...'+optimizerObj);
        if(optimizerObj !=null) {
        	if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Optimizer__c')){
				delete optimizerObj;
			}
        }
            
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        /*Commented and added the below code as per Defect#013844*/
        //delete sObjEvent;
        WSCH_CRUD_Helper.deleteEvents(sObjEvent);
    }
    
}