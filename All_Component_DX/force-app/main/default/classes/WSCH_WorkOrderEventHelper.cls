/**
@ Name WSCH_WorkOrderEventHelper
@ Author Anantha Kumar
@ Description API method to update Work Order fields and technician events
*/
public with sharing class WSCH_WorkOrderEventHelper {

    Map<String, WSCH_TechnicianEvent> mapAssignedInfo = new Map<String, WSCH_TechnicianEvent>();
    Map<Id, String> mapWOIdTechId = new Map<Id, String>();
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();

    /**
     * Method to process the work order response
     */
    public static void processWorkOrderResponse(WSCH_WorkOrderResponse response) {
        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
        List<SVMXC__Service_Order__c> requestWOs = response.getLstWorkOrder();
        List<WSCH_TechnicianEvent> techEvents = response.getLstTechEvent();
        List<WSCH_Provider_SP_Push_Stubs.WorkItem> lstWorkItem = response.getLstWorkItem();
        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse::Start-No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse: WOs to be processed: '+requestWOs);
        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse: Technicians to be processed: '+techEvents);
        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse: Standard Activities to be processed: '+lstWorkItem);
        // Initialize Data sets
        Map<String, SVMXC__Service_Group_Members__c> techniciansMap = new Map<String, SVMXC__Service_Group_Members__c>();
        Map<String, SVMXC__Service_Order__c> workOrdersMap = new Map<String, SVMXC__Service_Order__c>();
        Map<String, Event> sfEventsMap = new Map<String, Event>();
        Map<String, SVMXC__SVMX_Event__c> smaxEventsMap = new Map<String, SVMXC__SVMX_Event__c>();
        List<Event> sfEventsToUpsert = new List<Event>();
        List<SVMXC__SVMX_Event__c> svmxEventsToUpsert = new List<SVMXC__SVMX_Event__c>();
        List<SVMXC__Service_Order__c> dripFeedWOList = new   List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> unDripFeedWOList = new   List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstUpdateWos;
        try {
            //create set of workorder ids from requestWOs list
            Set<String> workOrderIdset = new Set<String>();
            for(SVMXC__Service_Order__c requestWO : requestWOs){
                workOrderIdset.add(requestWO.Id);
            }
            if(null != techEvents && techEvents.size() > 0) {

                populateTechsAndWOs(techniciansMap, workOrdersMap, techEvents); // Populate Technician & WorkOrder objects
                populateEvents(sfEventsMap, smaxEventsMap, workOrdersMap.keySet());

                String workOrderId = null, techExtId = null;
                SVMXC__Service_Order__c workOrder = null;
                SVMXC__Service_Group_Members__c technician = null;
       
                for(WSCH_TechnicianEvent techEvent : techEvents) {
                    WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse::Technician Events Iteration Start -No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
                    workOrderId = techEvent.getWorkOrderID();
                    techExtId = techEvent.getTechnicianExternalID();
                    technician = techniciansMap.get(techExtId);
                    workOrder = workOrdersMap.get(workOrderId);
                    /*
                       Below logic is added for storing the JeoPardy Error Message to the work order Violation Field
                    */
                    if (workOrder != null) {
                        if(techEvent.getViolationMessage() !=null && !techEvent.getViolationMessage().equals('')) {
                            workOrder.SVMXC__Violation_Message__c = techEvent.getViolationMessage();
                            workOrder.SVMXC__Violation_Status2__c = 'Jeopardy';
                        }else {
                            workOrder.SVMXC__Violation_Message__c = '';
                            workOrder.SVMXC__Violation_Status2__c = '--None--';
                        }
                    }

                    if(workOrder != null && technician == null) {
                        if(String.isNotBlank(techExtId)) {
                            // If technician is null Notify admin/dispatcher
                            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR;
                            String errorText ='The technician scheduled in ServicePower is not configured in ServiceMax. Please create/update a technician with Optimization External Id '+techExtId;
                            WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
                        } else {
                            //if the work order is already scheduled then remove the scheduling
                            unscheduleWorkOrder(workOrder);
                        }
                        continue;
                    }
                    
                    //update the changeTime stamp coming from Push message onto the Work Order
                    if(workOrder != null && response.getChangeTime() != null) {
                        workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = response.getChangeTime();
                    }

                    if((workOrder == null && technician != null) || (workOrder == null && technician == null)) {
                        continue;
                    }
                    WSCH_AuditLogger.debug('BEFORE updateWorkOrder - ' + workOrder);
                    boolean eventUpdated = updateWorkOrder(workOrder, technician, techEvent);
                    WSCH_AuditLogger.debug('AFTER updateWorkOrder - ' + workOrder);
                    /*if ('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)) {
                        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse:: DRIP: WokOrderID : ' + workOrder.id + ' Status '+ workOrder.SVMXC__Work_Order_Scheduling_Status__c);
                        //dripFeedWOList.add(workOrder);
                    }
                    else if ('Tentative'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)){
                        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse:: UNDRIP: WokOrderID : ' + workOrder.id + ' Status '+ workOrder.SVMXC__Work_Order_Scheduling_Status__c);
                        //unDripFeedWOList.add(workOrder);
                    }*/
                    WSCH_AuditLogger.debug('eventUpdated - ' + eventUpdated);
                    if(!eventUpdated) continue; // No event updates continue
                    // Event update logic
                    boolean isSFEvent = false;
                    String technicianId = technician.Id;
                    if(technician.SVMXC__Salesforce_User__c != null){
                        isSFEvent = true;
                        technicianId = technician.SVMXC__Salesforce_User__c;
                    }
                    SVMXC__SVMX_Event__c svmxEvent = null;
                    Event event = null;

                    //adding this code for calls have only tech event no workorders.
                    if(workOrderIdset.size() == 0) {
                        workOrderIdset.add(workOrderId);
                    }

                    if(isSFEvent) {
                        WSCH_AuditLogger.debug('This is SF Event');
                        event = sfEventsMap.get(workOrderId);
                        if(event == null && workOrderIdset.contains(techEvent.getWorkOrderID())) {
                            event = new Event();
                            //after creating an SF event for this WO, check if there is already a SVMX Event created for this WO.
                            //if so, then delete that SVMX Event from this WO
                            WSCH_AuditLogger.debug('workOrderId - ' + workOrderId);
                            WSCH_AuditLogger.debug('smaxEventsMap.containsKey(workOrderId) - ' + smaxEventsMap.containsKey(workOrderId));
                            if(smaxEventsMap.containsKey(workOrderId)) {
                                WSCH_AuditLogger.debug('This WO ' + workOrderId + ' also contains SMAX Event. Hence deleting it.');
                                SVMXC__SVMX_Event__c smaxEvent = smaxEventsMap.get(workOrderId);
                                WSCH_AuditLogger.debug('smaxEvent - ' + smaxEvent);
                                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){	//SDL-SVMX-DELETE-FLS-ENFORCED
                                    delete smaxEvent;
                                } else {
                                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                                }
                                smaxEventsMap.remove(workOrderId);
                                WSCH_AuditLogger.debug('smaxEventsMap.containsKey(workOrderId) - ' + smaxEventsMap.containsKey(workOrderId));
                            }
                        }
                    } else {
                        WSCH_AuditLogger.debug('This is SMAX Event');
                        svmxEvent = smaxEventsMap.get(workOrderId);
                        if(svmxEvent == null && workOrderIdset.contains(techEvent.getWorkOrderID())) {
                            svmxEvent = new SVMXC__SVMX_Event__c();
                            //after creating an SVMX event for this WO, check if there is already a SF Event created for this WO.
                            //if so, then delete that SF Event from this WO
                            WSCH_AuditLogger.debug('workOrderId - ' + workOrderId);
                            WSCH_AuditLogger.debug('smaxEventsMap.containsKey(workOrderId) - ' + smaxEventsMap.containsKey(workOrderId));
                            if(sfEventsMap.containsKey(workOrderId)) {
                                WSCH_AuditLogger.debug('This WO ' + workOrderId + ' also contains SF Event. Hence deleting it.');
                                Event sfEvent = sfEventsMap.get(workOrderId);
                                WSCH_AuditLogger.debug('sfEvent - ' + sfEvent);
                                //delete sfEvent;
                                //calling CRUD_Helper method instead of deleting the SF event directly
                                WSCH_CRUD_Helper.deleteEvents(sfEvent);
                                sfEventsMap.remove(workOrderId);
                                WSCH_AuditLogger.debug('sfEventsMap.containsKey(workOrderId) - ' + sfEventsMap.containsKey(workOrderId));
                            }
                        }
                    }
                    String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
                    //check if Drip is enabled or Drip feed Fields List is Not Null, else do not process Drip Logic
                    if (('TRUE'.equalsIgnoreCase(WSCH_CommonUtils.getSettingValue('DCON002','SET001')) && String.isNotBlank(dripObjFields))) {
                        if ('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)) {
                            WSCH_Provider_SP_DispatchClientHelper.updateDripValues(workOrder, dripObjFields, true);
                            if(isSFEvent){
                                WSCH_Provider_SP_DispatchClientHelper.updateDripValues(event, dripObjFields, true);
                            }else if(svmxEvent != null){
                                WSCH_Provider_SP_DispatchClientHelper.updateDripValues(svmxEvent, dripObjFields, true);
                            }
                        }
                        else if ('Tentative'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)){
                            WSCH_Provider_SP_DispatchClientHelper.updateDripValues(workOrder, dripObjFields, false);
                            if(isSFEvent){
                                WSCH_Provider_SP_DispatchClientHelper.updateDripValues(event, dripObjFields, false);
                            }else if(svmxEvent != null){
                                WSCH_Provider_SP_DispatchClientHelper.updateDripValues(svmxEvent, dripObjFields, false);
                            }
                        }
                        
                    }else{
                        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper :Drip Feed Setting: ' + WSCH_CommonUtils.getSettingValue('DCON002','SET001'));
                    }
                    
                    if(event != null) {
                        mapSFEvent(event, techEvent, workOrder, technicianId);
                        sfEventsToUpsert.add(event);
                    }
                    if(svmxEvent != null ){
                        mapSVMXEvent(svmxEvent, techEvent, workOrder, technicianId);
                        svmxEventsToUpsert.add(svmxEvent);
                    }
                }
                
                WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse::Technician Events Iteration End -No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());                
            }
            //below code is executed only when pull is enabled
            if('True' != WSCH_CommonUtils.getSettingValue('DCON004','SET010')){
                //Process the standard activites details
                WSCH_Provider_SP_Push_Stubs.PushRequest req = new WSCH_Provider_SP_Push_Stubs.PushRequest();
                req.workItems=lstWorkItem;
                WSCH_Provider_SP_ChangedItems_Helper.doProcessRequest(req);
            }
        } catch (Exception ex) {
            WSCH_AuditLogger.error('Exception occured while processing work order response'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } finally {
            // Update ALL
            WSCH_CommonUtils.getWorkorderFields();
            if((WSCH_CommonUtils.strSetOfUpdateableFields != null) && (!WSCH_CommonUtils.strSetOfUpdateableFields.isEmpty())){
                lstUpdateWos = new   List<SVMXC__Service_Order__c>();
                lstUpdateWos.addAll(requestWOs);
                requestWOs = new   List<SVMXC__Service_Order__c>();
                requestWOs.addAll(WSCH_CommonUtils.getMapOfWorkOrders(WSCH_CommonUtils.strSetOfUpdateableFields, lstUpdateWos).values());
            }else{
                WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper:requestWOs:strSetOfUpdateableFields: ' + WSCH_CommonUtils.strSetOfUpdateableFields);
            }
            if(null != requestWOs && requestWOs.size() > 0){
                if (!securityUtils.verifyFieldAccess(requestWOs, COMM_SecurityUtils.Access.Updateable, false))	//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {
                        update requestWOs;
                    }
            }
            
            if(workOrdersMap.size() > 0){
                WSCH_CommonUtils.getWorkorderFields();
                if((WSCH_CommonUtils.strSetOfUpdateableFields != null) && (!WSCH_CommonUtils.strSetOfUpdateableFields.isEmpty())){
                    lstUpdateWos = new   List<SVMXC__Service_Order__c>();
                    lstUpdateWos.addAll(workOrdersMap.values());
                    workOrdersMap = new Map<String, SVMXC__Service_Order__c>(WSCH_CommonUtils.getMapOfWorkOrders(WSCH_CommonUtils.strSetOfUpdateableFields, lstUpdateWos)); 
                }else{
                    WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper:workOrdersMap:strSetOfUpdateableFields: ' + WSCH_CommonUtils.strSetOfUpdateableFields);
                }
                if (!securityUtils.verifyFieldAccess(workOrdersMap.values(), COMM_SecurityUtils.Access.Updateable, false))	//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {
                        update workOrdersMap.values();
                    }
            } 
            /*
            if(workOrdersMap.size() > 0){
                update workOrdersMap.values();
            } */
            
            if(sfEventsToUpsert.size() > 0){
                //WSCH_CRUD_Helper.upsertListEvents(sfEventsToUpsert);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( sfEventsToUpsert, COMM_SecurityUtils.Access.Upsertable) ) {	//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert sfEventsToUpsert;
	            } else {
					throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}
            }
            if(svmxEventsToUpsert.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( svmxEventsToUpsert, COMM_SecurityUtils.Access.Upsertable) ) {	//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert svmxEventsToUpsert;
	            } else {
					throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}
            }
            if(!dripFeedWOList.isEmpty()){
                //WSCH_Provider_SP_DispatchClientHelper.updateDripFeedList(dripFeedWOList, true);
            }
            if(!unDripFeedWOList.isEmpty()){
                //WSCH_Provider_SP_DispatchClientHelper.updateDripFeedList(unDripFeedWOList,false);
            }
         
            WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::processWorkOrderResponse::End-No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
            WSCH_AuditLogger.error('WSCH_WorkOrderEventHelper::processWorkOrderResponse:: End of processWorkOrderResponse method');            
        }
    }

    public static void updateNonWoEvents(List<SVMXC__SVMX_Optimizer__c> events) {
        if(events != null && events.size() > 0) 
            {
                if (!securityUtils.verifyFieldAccess(events, COMM_SecurityUtils.Access.Updateable, true))
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {
                        update events;  
                    }
            }
        }

    /* Method to popuate the technician and work orders map */
    private static void populateTechsAndWOs(Map<String, SVMXC__Service_Group_Members__c> techniciansMap,
        Map<String, SVMXC__Service_Order__c> workOrdersMap, List<WSCH_TechnicianEvent> techEvents) {
        try{
            Set<String> techExtIds = new Set<String>();
            Set<String> workOrderIds = new Set<String>();
            for(WSCH_TechnicianEvent techEvent : techEvents) {
                if(techEvent.getWorkOrderID() != null){
                    workOrderIds.add(techEvent.getWorkOrderID());
                }
                if(techEvent.getTechnicianExternalID()!= null){
                    techExtIds.add(techEvent.getTechnicianExternalID());
                }
            }
            techniciansMap.putAll(fetch_ServiceGrp_Technicians(techExtIds));
            workOrdersMap.putAll(fetch_WorkOrders(workOrderIds));
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_WorkOrderEventHelper:populateTechsAndWOs() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    private static Map<String, SVMXC__Service_Group_Members__c> fetch_ServiceGrp_Technicians(set<String> techIds){
        Map<String, SVMXC__Service_Group_Members__c> mapServiceGrp = new Map<String, SVMXC__Service_Group_Members__c>();
        try{
            List<SVMXC__Service_Group_Members__c> lstTechs = [Select Id, SVMXC__Service_Group__c, SVMXC__Optimizer_External_ID__c, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c
                where SVMXC__Optimizer_External_ID__c in: techIds];

            for(SVMXC__Service_Group_Members__c currGrp : lstTechs){
                mapServiceGrp.put(currGrp.SVMXC__Optimizer_External_ID__c, currGrp);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_WorkOrderEventHelper:fetch_ServiceGrp_Technicians() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return mapServiceGrp;
    }

    private static Map<String, SVMXC__Service_Order__c> fetch_WorkOrders(set<String> workOrderIds){
        Map<String, SVMXC__Service_Order__c> mapServiceOrders = new Map<String, SVMXC__Service_Order__c>();
        try{
            List<String> woIdList = new List<String>(workOrderIds);
            List<SVMXC__Service_Order__c> lstWorkOrders = WSCH_CommonUtils.fetchWorkOrders(woIdList);
            for(SVMXC__Service_Order__c currWo : lstWorkOrders){
                mapServiceOrders.put(currWo.Id, currWo);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_WorkOrderEventHelper:fetch_WorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return mapServiceOrders;
    }

    /* Method to popuate the salesforce events and servicemax events map */
    private static void populateEvents(Map<String, Event> sfEventsMap, Map<String, SVMXC__SVMX_Event__c> smaxEventsMap,
        Set<String> workOrderIds) {

        List<Event> lstSFEvents = WSCH_CommonUtils.fetchSFEventByWhatId(workOrderIds);
        if(lstSFEvents != null && lstSFEvents.size() > 0){
            for(Event event : lstSFEvents){
                sfEventsMap.put(event.get('WhatId') + '', event);
            }
        }
        //fetch the existing servicemax evnets for the workorder
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = WSCH_CommonUtils.fetchSVMXEventByWhatId(workOrderIds);
        if(lstSVMXEvents != null && lstSVMXEvents.size() > 0){
            for(SVMXC__SVMX_Event__c event : lstSVMXEvents){
                smaxEventsMap.put(event.get('SVMXC__WhatId__c') + '', event);
            }
        }
    }

    /* Method which updates the work order and also validates if the event should be updated? */
    private static boolean updateWorkOrder(SVMXC__Service_Order__c workOrder, SVMXC__Service_Group_Members__c technician,
        WSCH_TechnicianEvent techEvent) {
        boolean eventUpdated = false;
        Set<String> setSpStatus = new Set<String>{'planned', 'notified'};
        try{
            DateTime arrivalDateTime = techEvent.getArrivalDateTime();
            DateTime startDateTime = techEvent.getStartDateTime();
            DateTime finishDateTime = techEvent.getFinishDateTime();
            Integer driveTime =  WSCH_DateUtils.getDurationInMinutes(startDateTime, arrivalDateTime);
            Double serviceDuration = WSCH_DateUtils.getDurationInMinutes(arrivalDateTime,finishDateTime) * 60;
            WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::updateWorkOrder::ServiceTime in seconds :'+serviceDuration);
            
            if(techEvent.getVisitDuration() != null){
                WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::updateWorkOrder::Visit Duration in minutes :'+techEvent.getVisitDuration() /60);
                serviceDuration = techEvent.getVisitDuration();
            }
            
            if(techEvent.getDriveDuration() != null){
                WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::updateWorkOrder::Drive Duration in minutes :'+techEvent.getDriveDuration() / 60);
                driveTime =  Integer.valueOf(techEvent.getDriveDuration() / 60);
            }           
            
            if(techEvent.getIdleDuration() != null){
                WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::updateWorkOrder::Idle Duration in minutes :'+techEvent.getIdleDuration() / 60);              
            }
            
            if(workOrder.SVMXC__Service_Duration__c != serviceDuration){
                workOrder.SVMXC__Service_Duration__c=serviceDuration;
                eventUpdated = true;
            }

            if(workOrder.SVMXC__Driving_Time__c != driveTime) {
                workOrder.SVMXC__Driving_Time__c = driveTime;
                eventUpdated = true;
            }

            if(workOrder.SVMXC__Scheduled_Date_Time__c != arrivalDateTime) {
                workOrder.SVMXC__Scheduled_Date_Time__c = arrivalDateTime;
                eventUpdated = true;
            }

            if(null != technician){
                if(workOrder.SVMXC__Group_Member__c != technician.Id) {
                    workOrder.SVMXC__Service_Group__c = technician.SVMXC__Service_Group__c;
                    workOrder.SVMXC__Group_Member__c = technician.Id;
                    eventUpdated = true;
                }
            }

            WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::updateWorkOrder::techEvent.getIsFixed(): ' + techEvent.getIsFixed());
            if(techEvent.getIsFixed() != null){ 
                workOrder.SVMXC__Locked_By_DC__c = techEvent.getIsFixed();
            }
            //new check to update WorkOrder Events, if Dispatch Status changes to Tentative or Earmarked
            if((workOrder.SVMXC__Work_Order_Scheduling_Status__c != null) && 
            (techEvent.getDispatchStatus()!= null) && 
            (setSpStatus.contains(techEvent.getDispatchStatus())) &&
            (workOrder.SVMXC__Work_Order_Scheduling_Status__c != WSCH_CommonUtils.getServiceMaxJobStatus(techEvent.getDispatchStatus()))
            ){
                eventUpdated = true;
            }
            workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(techEvent.getDispatchStatus());
            if(workOrder.SVMXC__OptiMax_Status__c != null){
                workOrder.SVMXC__OptiMax_Status__c = resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c);    
            }
            //Enableing drip feed fields to true if scheduling status is dispatched.
            /*if ('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)) {
                WSCH_Provider_SP_DispatchClientHelper.updateDripFeed(workOrder, true);
            }*/
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_WorkOrderEventHelper:updateWorkOrder() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return eventUpdated;
    }

    /* Map WSCH_TechnicianEvent object to salesforce event object */
    private static void mapSFEvent(Event event, WSCH_TechnicianEvent techEvent, SVMXC__Service_Order__c workOrder, String techId) {
        DateTime arrivalDateTime = techEvent.getArrivalDateTime();
        DateTime startDateTime = techEvent.getStartDateTime();
        DateTime endDateTime = techEvent.getFinishDateTime();
        Integer duration = WSCH_DateUtils.getDurationInMinutes(startDateTime, endDateTime);
        Integer driveTime =  WSCH_DateUtils.getDurationInMinutes(startDateTime, arrivalDateTime);
        
        Integer idleTime;
        
        if(techEvent.getVisitDuration() != null)
           event.SVMXC__Service_Duration__c = techEvent.getVisitDuration();
            
        if(techEvent.getDriveDuration() != null)    
            driveTime =  Integer.valueOf(techEvent.getDriveDuration() / 60);
            
        if(techEvent.getIdleDuration() != null){                
            idleTime = Integer.valueOf(techEvent.getIdleDuration() / 60);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: idleTime: '+idleTime);
            startDateTime = startDateTime.addMinutes(idleTime);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: New StartDateTime after adding idle time: '+startDateTime);
        }

        event.Subject = createSubject(workOrder);
        event.WhatId = workOrder.Id;
        event.OwnerId = techId;
        event.StartDateTime = startDateTime;
        event.EndDateTime = endDateTime;
        event.ActivityDate = startDateTime.date();
        event.ActivityDateTime = startDateTime;
        event.DurationInMinutes = duration;
        event.SVMXC__Driving_Time__c=driveTime;
        event.SVMXC__SM_Idle_Time__c = idleTime;
    }

    /* Map WSCH_TechnicianEvent object to servicemax event object */
    private static void mapSVMXEvent(SVMXC__SVMX_Event__c event, WSCH_TechnicianEvent techEvent, SVMXC__Service_Order__c workOrder, String techId) {
        DateTime arrivalDateTime = techEvent.getArrivalDateTime();
        DateTime startDateTime = techEvent.getStartDateTime();
        DateTime endDateTime = techEvent.getFinishDateTime();
        Integer duration = WSCH_DateUtils.getDurationInMinutes(startDateTime, endDateTime);
        Integer driveTime =  WSCH_DateUtils.getDurationInMinutes(startDateTime, arrivalDateTime);
        Integer idleTime;
       
        if(techEvent.getVisitDuration() != null)
           event.SVMXC__Service_Duration__c = techEvent.getVisitDuration();
            
        if(techEvent.getDriveDuration() != null)    
            driveTime =  Integer.valueOf(techEvent.getDriveDuration() / 60);
            
        if(techEvent.getIdleDuration() != null){                
            idleTime = Integer.valueOf(techEvent.getIdleDuration() / 60);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: idleTime: '+idleTime);
            startDateTime = startDateTime.addMinutes(idleTime);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: New StartDateTime after adding idle time: '+startDateTime);
        }

        event.Name = createSubject(workOrder);
        event.SVMXC__WhatId__c = workOrder.Id;
        event.SVMXC__Technician__c = techId;
        event.SVMXC__WhoId__c = techId;
        event.SVMXC__StartDateTime__c = startDateTime;
        event.SVMXC__EndDateTime__c = endDateTime;
        event.SVMXC__ActivityDate__c = startDateTime.date();
        event.SVMXC__ActivityDateTime__c = startDateTime;
        event.SVMXC__DurationInMinutes__c = duration;
        event.SVMXC__Driving_Time__c = driveTime;
        event.SVMXC__SM_Idle_Time__c = idleTime;
    }

    private static String parseDateTimeFormat(String SPDateTime){
        //as the return stirng from service power is in format '2013-11-27T08:00' where salesforce requires '2013-11-27 08:00:00'
        //if any other solution we can replace this method
        SPDateTime = SPDateTime.replace('T',' ');
        SPDateTime = SPDateTime + ':00';
        return SPDateTime;
    }

    private static String createSubject(SVMXC__Service_Order__c wo){
        String strSubject = '';
        try{
            strSubject = strSubject + (wo.Name != null ? wo.Name : '');
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_WorkOrderEventHelper:createSubject() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return strSubject;
    }

    public static void unscheduleWorkOrder(SVMXC__Service_Order__c workOrder) {
        boolean unschedule = false;
        List<Event> sfEvents = WSCH_CommonUtils.fetchSFEventByWhatId(new Set<String>{workOrder.Id});
        if(sfEvents.size() > 0 ) {
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            //delete sfEvents;
            WSCH_CRUD_Helper.deleteListEvents(sfEvents);
            unschedule = true;
        } else {
            List<SVMXC__SVMX_Event__c> svmxEvents = WSCH_CommonUtils.fetchSVMXEventByWhatId(new Set<String>{workOrder.Id});
            if(svmxEvents.size() >0) {
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){	//SDL-SVMX-DELETE-FLS-ENFORCED
                    delete svmxEvents;
                }else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                unschedule = true;
            }
        }
        if(unschedule){
            WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::unscheduleWorkOrder: Events deleted due to FORCE BOOK WO No: '+workOrder.Name);
        
            if(workOrder.SVMXC__Group_Member__c != NULL){
                workOrder.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
            }
            if(workOrder.SVMXC__Group_Member__c == NULL && workOrder.SVMXC__Service_Group__c != NULL){
                workOrder.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
            }
            workOrder.SVMXC__Service_Group__c = NULL;
            workOrder.SVMXC__Group_Member__c = NULL;
            workOrder.SVMXC__Scheduled_Date_Time__c = NULL;
            workOrder.SVMXC__Scheduled_Date__c = NULL;
            workOrder.SVMXC__Work_Order_Scheduling_Status__c = NULL;
            String errorText ='Assignment removed for this work order due to de-allocated/unscheduled on ServicePower';
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
        }
    }

    /**
        Following method decides, a work order status will be updated to OPT_COMPLETED, if and only if the WO status
        is in ?OPT_PENDING? or ?OPT_TENTATIVE? or 'OPT_DATA_SYNC_ERROR' or 'OPT_FAIL'.
    **/
    private static String resolveOptimaxStatus(String oldStatus) {
        WSCH_AuditLogger.debug('WSCH_WorkOrderEventHelper::resolveOptimaxStatus: Old Optimax Status: '+oldStatus);
        if (oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_TENTATIVE) || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_PENDING) || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR) || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_FAIL)|| oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_QUEUED)) {
            return WSCH_Constants.STATUS_OPT_COMPLETED;
        }

        return oldStatus;
    }
}