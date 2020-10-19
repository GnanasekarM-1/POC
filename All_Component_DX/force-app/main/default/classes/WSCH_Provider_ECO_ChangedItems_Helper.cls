/**
    Class to process the push messages received from Optimax ECO.
**/
public with sharing class WSCH_Provider_ECO_ChangedItems_Helper {
    
    public static Boolean doProcessRequest(WSCH_Provider_ECO_Push_Stubs.PushRequest req){
        Boolean result = false;
        WSCH_WorkOrderResponse workOrderResponse = new WSCH_WorkOrderResponse();
        List<WSCH_TechnicianEvent>  lstTechEvent = new List<WSCH_TechnicianEvent>();
        Map<Id,WSCH_TechnicianEvent> mapTechIdObj = new Map<Id,WSCH_TechnicianEvent>();
        Datetime pushMsgDatetime;
        List<String> woListforLogs = new List<String>();
        //WSCH_AuditLogger.rca('The Workorders in the push request are :- '+req.state); 
        //on dispatch workOrderResponse.IsDispatched() is used for Constraints Violation, and setting it as false here
        workOrderResponse.setIsDispatched(false);
        //convert the string datetime coming from Push message to Datetime object
        if(String.isNotBlank(req.changeTime)) {
                pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(req.changeTime);
        }
        if('NON_OPTIMIZABLE'.equalsIgnoreCase(req.state)){
            processNoneOptimizableItems(req);
            return true;
        }
        
        //Create map of work order
        List<String> woNames = new List<String>();
        List<String> lstWhatId = new List<String>();
        //boolean isActivityType = false;
        boolean isJobType = false;
        try{        
            for(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem : req.workItems){
                if(workItem.id.startsWith('WO-'))
                    woNames.add(workItem.id);
                //collecting activities for create optimizer transactions
                if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_ACTIVITY.equalsIgnoreCase(workItem.type) && !(workItem.id.startsWith('WO-'))){
                        //isActivityType = true;
                        String strWhatId = (workItem.id).split('_')[1]+'_'+(workItem.id).split('_')[2];
                        lstWhatId.add(strWhatId);
                }
                if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_JOB.equalsIgnoreCase(workItem.type)){                        
                        isJobType = true;
                }
                //This is a special case wherein when the forcefix WO gets unassigned, the push notification
                // sends it as an ACTIVITY and NOT as a JOB and the workItem.id field contains WO name like 'WO-111111'
                else if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_ACTIVITY.equalsIgnoreCase(workItem.type) && workItem.id.startsWith('WO-')) {
                        isJobType = true;
                }
            }

            //Process un assigned work orders and delete the corresponding events.
            if(req.state == 'ON_UNASSIGNED' && isJobType){
                processUnAssignedWorkOrders(req);
                return true;
            }

            if(lstWhatId != null && lstWhatId.size() > 0) {
                List<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__SM_Work_Order__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstWhatId];
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest()::Existing Optimizer transaction for Events size.. : ' + lstSVMXOptimizerToExisting.size());

                if(req.state == 'ON_UNASSIGNED'){
                    if(lstSVMXOptimizerToExisting != null && lstSVMXOptimizerToExisting.size() > 0) {
                        delete lstSVMXOptimizerToExisting;
                    }
                    return true;                        
                }

                if(lstSVMXOptimizerToExisting.size()==0) {
                    if(req.state.equals('ON_FAILURE')) {
                        createOptimizerTrnForEvent(req,'OPT_ERROR');
                    } else if((req.state == 'ON_TENTATIVE') || (req.state == 'ON_DISPATCH')) {
                        createOptimizerTrnForEvent(req,'OPT_COMPLETED');
                    }
                }
            }
        }catch(Exception ex){
                WSCH_AuditLogger.error('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        try{
            // on dispatch workOrderResponse.IsDispatched() is used for Constraints Violation, and setting it as true here
            if(req.state == 'ON_DISPATCH') {
                    workOrderResponse.setIsDispatched(true);    
            }

            Datetime dateTimeBeforeCall = Datetime.now();
            //WSCH_AuditLogger.debug('dateTimeBeforeCall : ' + dateTimeBeforeCall);

            Map<String, SVMXC__Service_Order__c> mapWONameObj = new Map<String, SVMXC__Service_Order__c>();
            if(woNames != null && woNames.size() > 0){
                    //Below query commented due to object describe was used.
                    // List<SVMXC__Service_Order__c> lstWOs = WSCH_CommonUtils.fetchWorkOrdersByName(woNames);
                    List<SVMXC__Service_Order__c> lstWOs =[Select Id,Name,SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__OptiMax_Status__c, SVMXC__Scheduling_Change_Token__c,SVMXC__Work_Order_Scheduling_Status__c,SVMXC__SM_Lock_Appointment_Schedule__c,SVMXC__Locked_By_DC__c,SVMXC__SM_Appointment_Type__c from SVMXC__Service_Order__c where Name IN : woNames];
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest()::lstWOs : ' + lstWOs.size());
                    for(SVMXC__Service_Order__c wo : lstWOs){
                            mapWONameObj.put(wo.Name,wo);
                    }
            }

            for(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem : req.workItems){
                WSCH_AuditLogger.setLogContext(workItem.id);
                
                if(String.isNotBlank(req.state) && WSCH_ECO_Constants.PUSHREQUEST_TYPE_JOB.equalsIgnoreCase(workItem.type) && req.state != 'ON_UNASSIGNED'){
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Processing job when req.state is : ' + req.state);
                    if(mapWONameObj == null){
                        continue;
                    }
            
                    SVMXC__Service_Order__c workOrder = mapWONameObj.get(workItem.id);

                    //If the work order id is not found, skip to the next work order.
                    //String workOrderId = WSCH_CommonUtils.getWorkItemIds('Name', new List<String>{workItem.id}).get(workItem.id);  
                    if(workOrder == null) {
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Work Item with Id : ' + workItem.id + ' not found in mapWONameObj');
                        continue;
                    }
                    //check to see if the push message timestamp > timestamp on Work Order field SVMXC__SM_Optimizer_Message_Creation_Date_Time__c.
                    //if not skip the processing of that message
                    if(workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c != null && pushMsgDatetime != null &&
                                        (pushMsgDatetime < workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c)) {
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Work Item with Id : ' + workItem.id + ' Timestamp received from Push notification is older than Work order timestamp. So skipping this Push message from processing');
                        continue;                                           
                    }

                    if(!req.state.equals('ON_FAILURE') && workOrder.SVMXC__Scheduling_Change_Token__c == null && workOrder.SVMXC__OptiMax_Status__c == null && workOrder.SVMXC__SM_Appointment_Type__c == null){
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Work Item with Id : ' + workItem.id + ' is already cancelled so skip the scheduling.');
                        continue;
                    }
                    // if('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)){
                    //     WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Work Item with Id : ' + workItem.id + ' is already dispatched so skip the scheduling.');
                    //     continue;
                    // }
                    //skip force fix work orders //need to comment the below code as fixed work order required driving time update...
                    // if('OPT_COMPLETED'.equalsIgnoreCase(workOrder.SVMXC__OptiMax_Status__c) && (WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE.equalsIgnoreCase(workOrder.SVMXC__SM_Lock_Appointment_Schedule__c) || workOrder.SVMXC__Locked_By_DC__c )){
                    //     WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Work Item with Id : ' + workItem.id + ' is already fixed so skip the scheduling.');
                    //     continue;
                    // }
                    String workOrderId = workOrder.Id;     
                    WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Current Status:'+req.state);
                    if(req.state.equals('ON_FAILURE')){
                        techEvent.setWorkOrderID(workOrderId);
                        if(workItem.errorMsg != null){
                            techEvent.setErrorMsg(workItem.errorMsg);
                        }else if(req.errorcode != null){
                            techEvent.setErrorMsg(req.errorcode);
                        } 
                    }else{
                        techEvent = mapBookingRequest(workItem,workOrderId,req.state);
                    }
                    lstTechEvent.add(techEvent);                         
                }
                
                //Process the non work order response if the workitem type is Activity
                WSCH_TechnicianEvent technicianEvent = new WSCH_TechnicianEvent();
                if(String.isNotBlank(req.state) && WSCH_ECO_Constants.PUSHREQUEST_TYPE_ACTIVITY.equalsIgnoreCase(workItem.type)){
                    //WSCH_AuditLogger.rca('Processing Non WorkOrder Events ');
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Processing Activity' + workItem);
                    if(workItem.id != null){
                        technicianEvent = mapBookingRequest(workItem,null,req.state);
                        if(req.state.equals('ON_FAILURE')){
                            if(workItem.errorMsg != null){
                                technicianEvent.setErrorMsg(workItem.errorMsg);
                            }else if(req.errorcode != null){
                                technicianEvent.setErrorMsg(req.errorcode);
                            }
                        }
                        lstTechEvent.add(technicianEvent);                                                      
                    }
                }
                
                //Process the non work order response if the workitem type is Resource(Technician)
                if(String.isNotBlank(req.state) && WSCH_ECO_Constants.PUSHREQUEST_TYPE_RESOURCE.equalsIgnoreCase(workItem.type)){
                    //WSCH_AuditLogger.rca('Processing the Technicians ');
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Processing Resource' + workItem);
                    WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
                    String techId = (workItem.id.split('_'))[0];
                    if(req.state.equals('ON_FAILURE')){
                        techEvent.setTechnicianID(workItem.id);
                        if(workItem.errorMsg != null){
                            techEvent.setErrorMsg(workItem.errorMsg);
                        }else if(req.errorcode != null){
                            techEvent.setErrorMsg(req.errorcode);
                        }                       
                    }else{
                        techEvent.setTechnicianID(workItem.id);
                        if(workItem.resolvedLatitude != 0.0 && workItem.resolvedLongitude != 0.0){
                            techEvent.setDblLatitude(workItem.resolvedLatitude);
                            techEvent.setDblLongitude(workItem.resolvedLongitude);
                        }
                    }
                    mapTechIdObj.put(techId,techEvent);
                }
            }

            try{
                if(pushMsgDatetime != null){
                    workOrderResponse.setChangeTime(pushMsgDatetime);
                }
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::'+lstTechEvent);
                if(lstTechEvent !=null && lstTechEvent.size() > 0){
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    workOrderResponse.getLstTechEvent().addAll(lstTechEvent);
                    WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(workOrderResponse);
                    // if(WSCH_AuditLogger.isLinxMetricLogEnabled) {
                    //    updateWOintoMetrics(woListforLogs);
                    //}
                }
                if(mapTechIdObj !=null && mapTechIdObj.size() > 0){
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    processTechnicianResponse(mapTechIdObj);
                }
                result = true;
            }catch(Exception ex){
                WSCH_AuditLogger.error('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }
            //if result is failure(false) then insert the optimizers record.
            if(!result){
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Failure Transaction so inserting json request into Optimizer Transaction...');
            }
        }catch(Exception ex){
                WSCH_AuditLogger.error('WSCH_Provider_ECO_ChangedItems_Helper::doProcessRequest::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
        return result;
    }
    
    public static WSCH_TechnicianEvent mapBookingRequest(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem,String workOrderId,String dispatchStatus) {
        
             WSCH_Provider_ECO_Push_Stubs.Booking booking = workItem.booking;
             WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
             if(workOrderId != null)
                      techEvent.setWorkOrderID(workOrderId);
             String techId;
             if(booking != null){
                techId = (booking.tech.split('_'))[0];
                techEvent.setTechnicianID(techId);
                if(String.isNotBlank(booking.start)){
                        techEvent.setStartDateTime(WSCH_DateUtils.parseSPDateTimeGmt(booking.start));
                }
                if(String.isNotBlank(booking.arr)){
                        techEvent.setArrivalDateTime(WSCH_DateUtils.parseSPDateTimeGmt(booking.arr));
                }
                if(String.isNotBlank(booking.end_x)){
                        techEvent.setFinishDateTime(WSCH_DateUtils.parseSPDateTimeGmt(booking.end_x));
                }
                if(booking.idleDuration != null && booking.idleDuration != 0.0){
                        techEvent.setIdleDuration(booking.idleDuration);
                }
                if(booking.driveDuration != null && booking.driveDuration != 0.0){
                        techEvent.setDriveDuration(booking.driveDuration);
                }
                if(booking.visitDuration != null && booking.visitDuration != 0.0){
                        techEvent.setVisitDuration(booking.visitDuration);
                }
                if(booking.returnHomeDrivingTime != null && booking.returnHomeDrivingTime != 0.0){
                        techEvent.setReturnHomeDrivingTime(booking.returnHomeDrivingTime);
                }                                   
                techEvent.setDispatchStatus(dispatchStatus.toLowerCase());
             }
        
             if(workItem.id !=null && workItem.id.startsWith('Event_')){ 
                      techEvent.setEventId((workItem.id).split('_')[1]);
             }        
        
             if(workItem.resolvedLatitude != 0.0 && workItem.resolvedLongitude != 0.0){
                      techEvent.setDblLatitude(workItem.resolvedLatitude);
                      techEvent.setDblLongitude(workItem.resolvedLongitude);
             }   
             if(workItem.errorMsg != null){
                      techEvent.setErrorMsg(workItem.errorMsg);
             }
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::mapBookingRequest()::Constructed Tech Event :- ' + techEvent);
             return techEvent;
    }
    
    
    //This method is used to update the technician object with resolved address information and
    //also update the optimizer transaction records for the technician with error details
    public static void processTechnicianResponse(Map<Id,WSCH_TechnicianEvent> mapTechIdObj) {
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processTechnicianResponse::mapTechIdObj'+mapTechIdObj);
             List<SVMXC__SVMX_Optimizer__c> lstOptimizer = new List<SVMXC__SVMX_Optimizer__c> ();
             List<SVMXC__Service_Group_Members__c> lstTechForLatLngUpdate = [Select Id, Name, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c from SVMXC__Service_Group_Members__c where Id IN :mapTechIdObj.keySet()];
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processTechnicianResponse::lstTechForLatLngUpdate'+lstTechForLatLngUpdate);
             Map<String, String> mapWhatIdErrorMsg = new Map<String, String>();
             list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer;
             for(WSCH_TechnicianEvent techEvent : mapTechIdObj.values()) {
             String techId = (techEvent.getTechnicianID().split('_'))[0];
             for(SVMXC__Service_Group_Members__c tech : lstTechForLatLngUpdate)
             {
                      if(techId == tech.Id){
                               tech.SVMXC__Latitude_Home__c = techEvent.getDblLatitude();
                               tech.SVMXC__Longitude_Home__c = techEvent.getDblLongitude();
                      }
             }
             if(techEvent.getErrorMsg()!= null)
                      mapWhatIdErrorMsg.put(techEvent.getTechnicianID(),techEvent.getErrorMsg());     
             }
             if(mapWhatIdErrorMsg != null && mapWhatIdErrorMsg.size() > 0){
                      List<String> lstOptimizerWhatId = new List<String>(mapWhatIdErrorMsg.keySet());
                      WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processTechnicianResponse::lstOptimizerWhatId'+lstOptimizerWhatId);
                      lstSVMXOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerByWhatId(lstOptimizerWhatId);
                      WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processTechnicianResponse::lstSVMXOptimizer'+lstSVMXOptimizer);
             
                      for(SVMXC__SVMX_Optimizer__c optimizer : lstSVMXOptimizer){
                               optimizer.SVMXC__Optimizer_Status__c = WSCH_ECO_Constants.STATUS_OPT_ERROR;
                               optimizer.SVMXC__Optimizer_Error_Text__c = mapWhatIdErrorMsg.get(optimizer.SVMXC__WhatId__c);
                      }
             }
        
             if(lstTechForLatLngUpdate.size() > 0) {
                      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstTechForLatLngUpdate, COMM_SecurityUtils.Access.Updateable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                               update lstTechForLatLngUpdate; 
                      }else {
                               WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processTechnicianResponse:'+System.label.COMM001_TAG142);
                               return;
                      }
             }
            
             if(lstSVMXOptimizer != null && lstSVMXOptimizer.size() > 0) {
                      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstSVMXOptimizer, COMM_SecurityUtils.Access.Updateable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                              update lstSVMXOptimizer; 
                      }else {
                               WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processTechnicianResponse:'+System.label.COMM001_TAG142);
                               return;
                      }
             }
        
    }  
    
    //Process the Un assgined work orders 
    public static void processUnAssignedWorkOrders(WSCH_Provider_ECO_Push_Stubs.PushRequest req){
             WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders');

             //capturing the timestamps before call
             Datetime dateTimeBeforeCall = Datetime.now();
             WSCH_AuditLogger.debug('dateTimeBeforeCall : ' + dateTimeBeforeCall);

             Datetime pushMsgDatetime;
             //convert the string datetime coming from Push message to Datetime object
             if(String.isNotBlank(req.changeTime)) {
                      pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(req.changeTime);
             }

             //Fetch the workorderids
             List<String> workOrderNames = new List<String>();
             set<String> dispatchedWOName = new set<String>();
             map<String, String> mapWoIderrMsg = new map<String, String>();
             for(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem : req.workItems){
                if(workItem.id != null){
                        workOrderNames.add(workItem.id.trim()); 
                }else{
                        workOrderNames.add(workItem.id); 
                }   
                //filer the workorderid which is need to update as dispatched instead un assinged.
                if(workItem.ignored)
                        dispatchedWOName.add(workItem.id);
                //capture error message for unassinged work orders
                mapWoIderrMsg.put(workItem.id,workItem.errorMsg);
             }
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders::workOrderNames'+workOrderNames);
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders::dispatchedWOName'+dispatchedWOName);
             //Below query commented due to object describe was used.         
             //List<SVMXC__Service_Order__c> lstWorkOrder = WSCH_CommonUtils.fetchWorkOrdersByName(workOrderNames);
             List<SVMXC__Service_Order__c> lstWorkOrder = [Select Id,Name,SVMXC__Work_Order_Scheduling_Status__c,SVMXC__Group_Member__c,SVMXC__OptiMax_Status__c,
             SVMXC__Scheduled_Date_Time__c,SVMXC__Service_Group__c,SVMXC__Locked_By_DC__c,
             SVMXC__SM_Lock_Appointment_Schedule__c,SVMXC__Driving_Time__c,SVMXC__OptiMax_Error_Text__c,
             SVMXC__Violation_Message__c,SVMXC__Violation_Status2__c,
             SVMXC__Scheduling_Change_Token__c from SVMXC__Service_Order__c where Name IN : workOrderNames];
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders::No of Work orderss'+lstWorkOrder.size());
             //WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders::lstWorkOrder'+lstWorkOrder);

             List<String> workOrderIds = new List<String>();
             set<String> dispatchedWOId = new set<String>();
             String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
             String strOfAllWONames = '';
             //Update the workorders
             if(null != lstWorkOrder){
            
             for(SVMXC__Service_Order__c objWO : lstWorkOrder){
                      //Check if the work order is dispatched already, skip to the next work order
                      //First time work order unassinged due to no technician, There is no scheduling status
                      //NBN case sheduling status is various other status like "onsite", "complete" etc.. not like "dispatched"
                      //We need to ignore the work order where scheduling status not equals to "tentative'
                      if(objWO.SVMXC__Work_Order_Scheduling_Status__c != null && !('Tentative'.equalsIgnoreCase(objWO.SVMXC__Work_Order_Scheduling_Status__c))){
                               WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders::Skip this work order which is already dispatched...'+objWO.Name);
                               continue;
                      }

                      workOrderIds.add(objWO.id);
                      //for dispatched work order status updated as 'Dispatched' and update the drip fields.
                      if(dispatchedWOName != null && dispatchedWOName.contains(objWO.Name)){
                               dispatchedWOId.add(objWO.id);
                               objWO.SVMXC__Work_Order_Scheduling_Status__c = 'Dispatched';
                               WSCH_Provider_SP_DispatchClientHelper.updateDripValues(objWO, dripObjFields, true);
                      }else{
                               objWO.SVMXC__Group_Member__c=null;
                               objWO.SVMXC__OptiMax_Status__c='OPT_UNASSIGNED';
                               objWO.SVMXC__Scheduled_Date_Time__c=null;
                               objWO.SVMXC__Service_Group__c=null;
                               objWO.SVMXC__Locked_By_DC__c=False;
                               //below condition is added to fix defect OPT-4463
                               if(WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE.equalsIgnoreCase(objWO.SVMXC__SM_Lock_Appointment_Schedule__c)){
                                    objWO.SVMXC__SM_Lock_Appointment_Schedule__c=null;
                                }  
                               objWO.SVMXC__Driving_Time__c=null;
                               objWO.SVMXC__OptiMax_Error_Text__c=null;
                               objWO.SVMXC__Violation_Message__c=null;
                               //update error message for unassinged work orders
                               if(mapWoIderrMsg != null && mapWoIderrMsg.size() >0 ){
                                        objWO.SVMXC__Violation_Message__c = mapWoIderrMsg.get(objWO.Name);
                               }                    
                               objWO.SVMXC__Violation_Status2__c='Unresourced';
                               objWO.SVMXC__Scheduling_Change_Token__c='CHANGE_CREATE_WO';
                               objWO.SVMXC__Work_Order_Scheduling_Status__c=null;
                      }
                      //strOfAllWONames = strOfAllWONames + objWO.Name + ',';
             }
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            //update lstWorkOrder;
            if(lstWorkOrder.size() > 0) {
                     if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWorkOrder, COMM_SecurityUtils.Access.Updateable) ) {        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                         update lstWorkOrder; 
                         //WSCH_AuditLogger.rca('Updated the workorders as New');
                         
                     }else {
                         WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders:- '+System.label.COMM001_TAG142);
                         //WSCH_AuditLogger.rca(System.label.COMM001_TAG142);
                         return;
                     }
             }
            
            WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders:: Work Order after update :- '+lstWorkOrder);
            
            //Fetch the SF Events of the workorders and delete
            List<Event> woSFEvents = new List<Event>([Select Id,WhatId from Event where WhatId in:workOrderIds ]); 
            WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders::woSFEvents :- '+woSFEvents.size());
            
            //Fetch the Servicemax Events of the workorders and delete
            List<SVMXC__SVMX_Event__c> woSVMXEvents = new List<SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c in:workOrderIds OR SVMXC__Service_Order__c in: workOrderIds]); 
            WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::woSVMXEvents :- '+woSVMXEvents.size());
            
            List<Event> woSFEventsForUpdate= new List<Event>();
            List<Event> woSFEventsForDelete= new List<Event>();
            for(Event sfEvent : woSFEvents){
                //for dispatched work orders, event drip fields are updated here
                if(dispatchedWOId != null && dispatchedWOId.contains(sfEvent.WhatId)){
                    woSFEventsForUpdate.add(sfEvent);
                    WSCH_Provider_SP_DispatchClientHelper.updateDripValues(sfEvent, dripObjFields, true);
                }else{
                    woSFEventsForDelete.add(sfEvent);
                }           
            }
            
            //delete woSFEvents;
            if(woSFEventsForDelete != null) {
                     WSCH_OptimizedSchedulingService.triggerExecuted = true;
                     WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                     //WSCH_AuditLogger.rca('Deleting the  Events of UnAssigned WorkOrders');
                     WSCH_CRUD_Helper.deleteListEvents(woSFEventsForDelete);
            }
                
            //update drip fields in evevnts
            if(woSFEventsForUpdate != null) {
                     WSCH_OptimizedSchedulingService.triggerExecuted = true;
                     WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                     //WSCH_AuditLogger.rca('Updating the Drip Values of  Events');
                     WSCH_CRUD_Helper.upsertListEvents(woSFEventsForUpdate);
            }
            
            List<SVMXC__SVMX_Event__c> woSVMXEventsForUpdate= new List<SVMXC__SVMX_Event__c>();
            List<SVMXC__SVMX_Event__c> woSVMXEventsForDelete= new List<SVMXC__SVMX_Event__c>();
            for(SVMXC__SVMX_Event__c svmxEvent : woSVMXEvents){
                //for dispatched work orders, event drip fields are updated here
                if(dispatchedWOId != null && dispatchedWOId.contains(svmxEvent.SVMXC__WhatId__c)){
                    woSVMXEventsForUpdate.add(svmxEvent);
                    WSCH_Provider_SP_DispatchClientHelper.updateDripValues(svmxEvent, dripObjFields, true);
                }else{
                    woSVMXEventsForDelete.add(svmxEvent);
                }           
            }
            
            if(woSVMXEventsForUpdate != null && woSVMXEventsForUpdate.size() > 0) {
                     WSCH_OptimizedSchedulingService.triggerExecuted = true;
                     WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                     //WSCH_AuditLogger.rca('Updating the Drip Values of  ServiceMax Events');
                     
                     if( COMM_SecurityUtils.getInstance().verifyFieldAccess(woSVMXEventsForUpdate, COMM_SecurityUtils.Access.Updateable)) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                         update woSVMXEventsForUpdate; 
                     }else {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                         return;
                     }
            }
            
            if(woSVMXEventsForDelete != null){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c')){ //SDL-SVMX-DELETE-FLS-ENFORCED
                         WSCH_OptimizedSchedulingService.triggerExecuted = true;
                         WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                         //WSCH_AuditLogger.rca('Deleting the Service Max Events of UnAssigned WorkOrders');
                    delete woSVMXEventsForDelete;   
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        }
        
       //If Linx performance metric collection is enabled, then collect metrics for push messages.
        //if(WSCH_AuditLogger.isLinxMetricLogEnabled) {
        //    createPerformanceMetricsUnassignedWO(workOrderNames,dateTimeBeforeCall,pushMsgDatetime,'UNASSIGNED',null);
        //    updateWOintoMetrics(workOrderNames);
       // }
      WSCH_AuditLogger.debug('End  WSCH_Provider_ECO_ChangedItems_Helper::processUnAssignedWorkOrders');
      //WSCH_AuditLogger.rca('All UnAssigned work orders are processed');
    }   

    public static void createOptimizerTrnForEvent(WSCH_Provider_ECO_Push_Stubs.PushRequest req, String optimizerStatus){
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::createOptimizerTrnForEvent::optimizer status...'+optimizerStatus);
             List<SVMXC__SVMX_Optimizer__c> lstoptimizerForEvent = new List<SVMXC__SVMX_Optimizer__c>();
             for(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem : req.workItems){
                      if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_ACTIVITY.equalsIgnoreCase(workItem.type)){
                               String strWhatId = (workItem.id).split('_')[1]+'_'+(workItem.id).split('_')[2]; //EventId_TechnicianName
                               String connectionId = req.jobId;//DispatchProcessId_TerritoryId
                               if(workItem.booking != null){
                                        String technicianId = workItem.booking.tech.split('_')[0];
                                        connectionId = req.jobId+'_'+technicianId;
                               }
                      SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
                               optimizerObj.SVMXC__WhatType__c = 'NON_WO_EVENT';
                               optimizerObj.SVMXC__WhatId__c = strWhatId;
                               optimizerObj.SVMXC__Optimizer_Connection_ID__c=connectionId;
                               optimizerObj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_EVENT';
                               optimizerObj.SVMXC__Optimizer_Status__c = optimizerStatus;
                               optimizerObj.SVMXC__Optimizer_Error_Text__c='This technician event created during initJob call';
                               lstoptimizerForEvent.add(optimizerObj);
                      }
             }
                      WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::createOptimizerTrnForEvent::lstoptimizerForEvent size...'+lstoptimizerForEvent.size());
             if(lstoptimizerForEvent != null && lstoptimizerForEvent.size()>0){
                      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstoptimizerForEvent, COMM_SecurityUtils.Access.Createable)){       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                               insert lstoptimizerForEvent;
                      } else {
                               throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                      }
             }
    }
            
    public static void createPerformanceMetricsLog(String workitemId,DateTime dateTimeBeforeCall,DateTime pushMsgDatetime,String woStatus,String failureMsg){
             //logging the PUSH_PROCESSTIME
             WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::createPerformanceMetricsLog :- '+workitemId);
             String trimStatus = woStatus.split('_').get(1).trim();
             WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper:: :- trimStatus '+trimStatus+'WorderOrder'+workitemId);
             WSCH_AuditLogger.appendMetrics(workitemId, '"PUSH"_"Change"_"Time"', pushMsgDatetime, null,null);
             WSCH_AuditLogger.appendMetrics(workitemId, '"PUSH"_"WO"_"STATUS"', null, null ,trimStatus);
             if(failureMsg == null){
                      WSCH_AuditLogger.appendMetrics(workitemId, '"PUSH"_"WO"_"ERROR"', null,null,'');
             }else{
                      WSCH_AuditLogger.appendMetrics(workitemId, '"PUSH"_"WO"_"ERROR"', null,null,failureMsg);
             }
        
    }
    
    public static void createPerformanceMetricsUnassignedWO(List<String> workitemIds,DateTime dateTimeBeforeCall,DateTime pushMsgDatetime,String woStatus,String failureMsg){
        //logging the PUSH_PROCESSTIME
        WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::createPerformanceMetricsLog :- '+workitemIds);
        
        for(String wo : workitemIds){
            WSCH_AuditLogger.appendMetrics(wo, 'changetime', pushMsgDatetime, null,null);
            WSCH_AuditLogger.appendMetrics(wo, '"PUSH"_"WO"_"STATUS"', null, null ,woStatus);
            if(failureMsg == null){
                        WSCH_AuditLogger.appendMetrics(wo, '"PUSH"_"WO"_"ERROR"', null,null,'');
                }else{
                        WSCH_AuditLogger.appendMetrics(wo, '"PUSH"_"WO"_"ERROR"', null,null,failureMsg);
             }
        
        }
        
    }
    
    

    public static void  updateWOintoMetrics(List<String> woList){
        WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::updateWOintoMetrics :- '+woList);
        Map<Id,SVMXC__Service_Order__c> woOrdersMap = new Map<Id,SVMXC__Service_Order__c>(
        [Select Name, Id,CreatedDate, SVMXC__Work_Order_Scheduling_Status__c,SVMXC__Group_Member__c,SVMXC__Service_Duration__c, SVMXC__Preferred_Start_Time__c, 
        SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Preferred_Technician__c,SVMXC__Preferred_Business_Hours__c,
        SVMXC__Scheduling_Change_Token__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Dispatch_Process__c,
        SVMXC__Driving_Time__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c from SVMXC__Service_Order__c where Name IN : woList]);
            
        for(SVMXC__Service_Order__c woOrder : woOrdersMap.values()){
            Integer  woTentativeResultVersion = 1;
            list<aggregateResult> aggResults = [SELECT MAX(SVMXC__Client_Version__c)maxIteration FROM SVMXC__SVMX_Job_Logs__c WHERE SVMXC__LOG_CONTEXT__C =:woOrder.Name AND SVMXC__Type__c = 'ECOPerformanceMetrics'];
            Object msg = aggResults[0].get('maxIteration');
            if(msg != null){
                    woTentativeResultVersion = (Integer.valueOf(msg)) +1; 
            }
            WSCH_AuditLogger.appendMetrics(woOrder.Name,'woResutltVersion' , null,null,String.valueOf(woTentativeResultVersion));

            WSCH_AuditLogger.appendMetrics(woOrder.Name,'woDispatchProcess' , null,null,woOrder.SVMXC__Dispatch_Process__c);
            WSCH_AuditLogger.appendMetrics(woOrder.Name,'"PUSH"_"WO"_"CREATEDDATE"', woOrder.CreatedDate, null);

            if(woOrder.SVMXC__Preferred_Start_Time__c !=null)
                    WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"SLASTARTTIME"', woOrder.SVMXC__Preferred_Start_Time__c, null) ;
            if(woOrder.SVMXC__Preferred_End_Time__c !=null)
                    WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"SLAENDTIME"',woOrder.SVMXC__Preferred_End_Time__c, null);
            if(woOrder.SVMXC__Scheduled_Date_Time__c !=null)
                    WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"SCHEDULEDTIME"',woOrder.SVMXC__Scheduled_Date_Time__c, null);

            if(woOrder.SVMXC__Driving_Time__c == null){
                    WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"DRIVETIME"',null,null,'');
            }else{
                    WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"DRIVETIME"',null,null,String.valueOf(woOrder.SVMXC__Driving_Time__c));
            }
                    
            //Capture the SLA Met or no for a workorder
            String woSLAMet='';
            if(woOrder.SVMXC__Scheduled_Date_Time__c !=null && woOrder.SVMXC__Preferred_Start_Time__c !=null && woOrder.SVMXC__Preferred_End_Time__c != null){
                    if(woOrder.SVMXC__Scheduled_Date_Time__c >= woOrder.SVMXC__Preferred_Start_Time__c 
                            && woOrder.SVMXC__Scheduled_Date_Time__c <= woOrder.SVMXC__Preferred_End_Time__c){
                    woSLAMet = 'true';      
                    }else if(woOrder.SVMXC__Scheduled_Date_Time__c <= woOrder.SVMXC__Preferred_Start_Time__c 
                            || woOrder.SVMXC__Scheduled_Date_Time__c >= woOrder.SVMXC__Preferred_End_Time__c){
                    woSLAMet = 'false'; 
                    }
            }
            WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"SLAMET"', null, null ,woSLAMet);

            String preferredTechnicianMet = '';
            if(woOrder.SVMXC__Preferred_Technician__c != null && woOrder.SVMXC__Group_Member__c !=null){
                    if(woOrder.SVMXC__Preferred_Technician__c == woOrder.SVMXC__Group_Member__c){
                    preferredTechnicianMet = 'true';
                    }else{
                    preferredTechnicianMet = 'false';
                    }
            }
            WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"WO"_"TECHMET"', null, null ,preferredTechnicianMet);

            String woDatefromMap = WSCH_AuditLogger.getPreformancMetricsMap().get(woOrder.Name);
            WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::updateWOintoMetrics :- '+woDatefromMap);
            String pushMsgDatetimestr = woDatefromMap.split(',').get(0).split(':',2).get(1).remove('"');
            WSCH_AuditLogger.debug('Begin WSCH_Provider_ECO_ChangedItems_Helper::updateWOintoMetrics :- '+pushMsgDatetimestr);
            DateTime pushMsgDatetime = WSCH_DateUtils.parseSPDateTimeGmt(pushMsgDatetimestr);

            WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"CHANGETIME"', pushMsgDatetime, null);

            if(pushMsgDatetime != null) {
                WSCH_AuditLogger.appendMetrics(woOrder.Name, '"PUSH"_"TIMEDIFF"',null, (pushMsgDatetime.getTime()-woOrder.CreatedDate.getTime())/1000);
            }
        }
        WSCH_AuditLogger.savePerformanceMetricsForECO();
        WSCH_AuditLogger.initPerfomanceMetrics();                 
    } 
    
    public static void processNoneOptimizableItems(WSCH_Provider_ECO_Push_Stubs.PushRequest req){
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processNoneOptimizableItems...');
        List<Event> sfEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
        List<String> sfEventIds = new List<String>();
        List<String> svmxEventIds = new List<String>();
        List<String> lstWOIds = new List<String>();
        List<String> lstJobIds = new List<String>();
        Set<Id> setWOids = new Set<Id>();
        map<string, string> mapOptimizerWhatIdErrorMsg = new map<string, string>();
        Map<Id,SVMXC__Service_Order__c> woOrdersMap = new Map<Id,SVMXC__Service_Order__c>();
        List<SVMXC__SVMX_Optimizer__c> lstOptimizerObj = new List<SVMXC__SVMX_Optimizer__c>();
        Map<String,String> mapWONameId = new Map<String,String>();
        String strDateTime = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm');
        Boolean isNonOptimizableWO = false;
        for(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem : req.workItems){
            if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_ACTIVITY.equalsIgnoreCase(workItem.type)){
                if(workItem.id !=null && workItem.id.startsWith('Event_')){ 
                    List<String> lstStr= workItem.id.split('_');
                    if(lstStr != null && !lstStr.isEmpty()){
                        String strOptimizerWhatId = lstStr[1].trim()+'_'+lstStr[2].trim();
                        mapOptimizerWhatIdErrorMsg.put(strOptimizerWhatId,workItem.errorMsg);    
                    }
                    String eventId = workItem.id.split('_')[1].trim();
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processNoneOptimizableItems()::eventId - : ' +eventId);
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processNoneOptimizableItems()::Error Message -: ' +workItem.errorMsg);
                    if(Schema.Sobjecttype.Event.getKeyPrefix() == eventId.substring(0,3)){
                        sfEventIds.add(eventId);
                    }else if(Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix() == eventId.substring(0,3)){
                        svmxEventIds.add(eventId);
                    }
                } else if(workItem.id !=null && workItem.id.startsWith('WO')){
                    String strWhatId = workItem.id;
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::processNoneOptimizableItems()::strWhatId - : ' +strWhatId);
                    lstWOIds.add(strWhatId);
                    mapOptimizerWhatIdErrorMsg.put(strWhatId,workItem.errorMsg);
                }                 
            }else if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_JOB.equalsIgnoreCase(workItem.type)){
                isNonOptimizableWO = true;
                lstWOIds.add(workItem.id);
                lstJobIds.add(workItem.id);
            }
        }

        if(!lstWOIds.isEmpty()){
            //woOrdersMap = new Map<Id,SVMXC__Service_Order__c>([Select Id,Name,SVMXC__OptiMax_Error_Text__c from SVMXC__Service_Order__c where Name IN : lstWOIds]);            
            //setWOids = woOrdersMap.keySet();
            List<SVMXC__Service_Order__c> lstWOs = [Select Id,Name,SVMXC__OptiMax_Error_Text__c from SVMXC__Service_Order__c where Name IN : lstWOIds];
            //Map<Id,SVMXC__Service_Order__c> woOrdersMap = new Map<Id,SVMXC__Service_Order__c>();
            for(SVMXC__Service_Order__c wo : lstWOs){
                woOrdersMap.put(wo.Id,wo);
                setWOids.add(wo.Id);
                mapWONameId.put(wo.Name,wo.Id);
            }
        }

        if(isNonOptimizableWO && mapWONameId != null && !mapWONameId.isEmpty()){
            for(WSCH_Provider_ECO_Push_Stubs.WorkItem workItem : req.workItems){
                if(WSCH_ECO_Constants.PUSHREQUEST_TYPE_JOB.equalsIgnoreCase(workItem.type)){
                    WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
                    List<WSCH_TechnicianEvent>  lstTechEvent = new List<WSCH_TechnicianEvent>();
                    WSCH_WorkOrderResponse workOrderResponse = new WSCH_WorkOrderResponse();
                    workOrderResponse.setIsDispatched(false);
                    String workOrderId = mapWONameId.get(workItem.id);     
                    techEvent = mapBookingRequest(workItem,workOrderId,req.state);
                    lstTechEvent.add(techEvent);
                    //to avoid duplicate work order update.
                    woOrdersMap.keySet().remove(workOrderId);
                    if(lstTechEvent !=null && lstTechEvent.size() > 0){
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                        workOrderResponse.getLstTechEvent().addAll(lstTechEvent);
                        WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(workOrderResponse);
                    }                
                }
            }
        }

        if(mapOptimizerWhatIdErrorMsg != null && !mapOptimizerWhatIdErrorMsg.isEmpty()){
            lstOptimizerObj = [select id,SVMXC__WhatId__c,SVMXC__Optimizer_Error_Text__c,SVMXC__SM_Work_Order__c,SVMXC__SM_Work_Order__r.Name from SVMXC__SVMX_Optimizer__c where SVMXC__WhatId__c in : mapOptimizerWhatIdErrorMsg.keySet()];
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems_Helper::lstOptimizerObj size- : ' +lstOptimizerObj.size());        

        //set error text in optimizer transaction for event
        if(lstOptimizerObj != null && !lstOptimizerObj.isEmpty()){
            for(SVMXC__SVMX_Optimizer__c optimizer : lstOptimizerObj){
                if(mapOptimizerWhatIdErrorMsg.containsKey(optimizer.SVMXC__WhatId__c)){
                    optimizer.SVMXC__Optimizer_Error_Text__c = strDateTime+' - '+mapOptimizerWhatIdErrorMsg.get(optimizer.SVMXC__WhatId__c);
                    //Pillar created for force fix work order and update the work order error text.
                    if(optimizer.SVMXC__SM_Work_Order__c != null){
                        lstWOIds.add(optimizer.SVMXC__SM_Work_Order__r.Name);
                        mapOptimizerWhatIdErrorMsg.put(optimizer.SVMXC__SM_Work_Order__r.Name,mapOptimizerWhatIdErrorMsg.get(optimizer.SVMXC__WhatId__c));
                    }
                }
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstOptimizerObj, COMM_SecurityUtils.Access.Upsertable)){      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update lstOptimizerObj;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        
        if(sfEventIds!=null && sfEventIds.size() > 0 || !setWOids.isEmpty()){
            sfEvents = [Select Id,SVMXC__SM_Status__c from EVENT where Id in : sfEventIds OR WhatId in :setWOids];
        }
        if(svmxEventIds!=null && svmxEventIds.size() > 0 || !setWOids.isEmpty()){
            svmxEvents  = [Select Id,SVMXC__SM_Status__c from SVMXC__SVMX_Event__c where Id in : svmxEventIds OR SVMXC__Service_Order__c in : setWOids];
        }

        //set status of the events
        if(sfEvents!= null && sfEvents.size() > 0){
            for(Event sfEvent : sfEvents){
                sfEvent.SVMXC__SM_Status__c = 'Non-optimizable';
            }
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_CRUD_Helper.upsertListEvents(sfEvents);
        }
        if(svmxEvents!=null && svmxEvents.size()>0){
            for(SVMXC__SVMX_Event__c svmxEvent : svmxEvents){
                svmxEvent.SVMXC__SM_Status__c = 'Non-optimizable';
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( svmxEvents, COMM_SecurityUtils.Access.Upsertable) ){        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                upsert svmxEvents;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }

        //set error text in work order
        if(woOrdersMap != null && !woOrdersMap.isEmpty()){
            List<SVMXC__Service_Order__c> lstWOs = woOrdersMap.values();
            for(SVMXC__Service_Order__c wo :lstWOs){
                if(mapOptimizerWhatIdErrorMsg.containsKey(wo.Name)){
                    wo.SVMXC__OptiMax_Error_Text__c = strDateTime+' - '+mapOptimizerWhatIdErrorMsg.get(wo.Name);
                }
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOs, COMM_SecurityUtils.Access.Upsertable)){       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update lstWOs;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }

        }
    }
}