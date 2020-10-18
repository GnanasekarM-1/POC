/**
@ Name WSCH_ECO_WorkOrderEventHelper
@ API methods to update Work Order fields and technician events for ECO implementations.
*/
public with sharing class WSCH_ECO_WorkOrderEventHelper {
    
     /* 
     *Type : Extension class
     *Used : "WSCH_ECO_WorkOrderEventHelper" Class
     *Desc : Used to return exception where ever required
     */
    public class SVMXException extends Exception{}
    
    Map<String, WSCH_TechnicianEvent> mapAssignedInfo = new Map<String, WSCH_TechnicianEvent>();
    Map<Id, String> mapWOIdTechId = new Map<Id, String>();
    
     //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    public static boolean eventUpdated = false;
    public static set<String> setBhId = new set<String>();
    
    /**
     * Method to process the work order response
     */
    public static void processWorkOrderResponse(WSCH_WorkOrderResponse response) {
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse:: Profile :'+Userinfo.getFirstName()+' '+Userinfo.getLastName());
        //WSCH_AuditLogger.rca('Processing Work Orders');
        List<SVMXC__Service_Order__c> requestWOs = response.getLstWorkOrder();
        List<WSCH_TechnicianEvent> techEvents = response.getLstTechEvent();
        //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::Start-No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse: WOs to be processed size: '+requestWOs.size());
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse: Technicians to be processed:size '+techEvents.size());
        
        
        //Initialize Data sets
        Map<String, SVMXC__Service_Group_Members__c> techniciansMap = new Map<String, SVMXC__Service_Group_Members__c>();
        Map<String, SVMXC__Service_Order__c> workOrdersMap = new Map<String, SVMXC__Service_Order__c>();
        Map<String, Event> sfEventsMap = new Map<String, Event>();
        Map<String, SVMXC__SVMX_Event__c> smaxEventsMap = new Map<String, SVMXC__SVMX_Event__c>();
        List<Event> sfEventsToUpsert = new List<Event>();
        List<SVMXC__SVMX_Event__c> svmxEventsToUpsert = new List<SVMXC__SVMX_Event__c>();
        List<SVMXC__Service_Order__c> dripFeedWOList = new   List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> unDripFeedWOList = new   List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstUpdateWos;        
        
        // Constraints Violation       
        List<SVMXC__SM_Scheduling_Violation__c> lstViolationDetails = new List<SVMXC__SM_Scheduling_Violation__c>();
        List<SVMXC__SM_Scheduling_Violation__c> lstOfViolations = new List<SVMXC__SM_Scheduling_Violation__c>();
        Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills = new Map<Id, List<SVMXC__Service_Group_Skills__c>>();
        SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViltnUtls = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
        Map<Id, String> mapTechIdProduct = new  Map<Id, String>();
        SVMXC__ServiceMax_Processes__c objSvmxProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__SVMX_Jobs__c job = new SVMXC__SVMX_Jobs__c();
        List<SVMXC__Service_Order__c> lstLimitedFieldWOs = new List<SVMXC__Service_Order__c>();
        
        Map<String,WSCH_TechnicianEvent> eventIdAndTechEvents = new Map<String,WSCH_TechnicianEvent>();
        Set<SVMXC__Service_Order__c> workOrderSet = new Set<SVMXC__Service_Order__c>();
        try {
            //create set of workorder ids from requestWOs list
             //WSCH_AuditLogger.debug('requestWOs'+requestWOs);
            Set<String> workOrderIdset = new Set<String>();
            for(SVMXC__Service_Order__c requestWO : requestWOs){
                WSCH_AuditLogger.debug('requestWO::'+requestWO.id);
                workOrderIdset.add(requestWO.Id);
                workOrderSet.add(requestWO);
            }
             WSCH_AuditLogger.debug('workOrderIdset from request wo::'+workOrderIdset);
            if(null != techEvents && techEvents.size() > 0) {
                
                populateTechsAndWOs(techniciansMap, workOrdersMap, techEvents); // Populate Technician & WorkOrder objects
                populateEvents(sfEventsMap, smaxEventsMap, workOrdersMap.keySet());
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: processWorkOrderResponse :: techniciansMap size(): '+techniciansMap.size() +' , techniciansMap: '+techniciansMap); 
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: processWorkOrderResponse :: workOrdersMap size(): '+workOrdersMap.size()); 
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: response.isDispatched() :: '+response.isDispatched()); 

                if(response.isDispatched() && workOrdersMap != null && !workOrdersMap.isempty()) {
                    mapTechIdSkills = omaxViltnUtls.skillsPerTech(techniciansMap.keySet());
                    mapTechIdProduct = omaxViltnUtls.expertisePerTech(techniciansMap.keySet());
                    objSvmxProcess = getSVMXProcess(workOrdersMap);
                    if(objSvmxProcess != null && objSvmxProcess.id != null)             
                        job = getSVMXJob(objSvmxProcess);   
                }               
                
                for(Id eachWOId : workOrdersMap.keySet()){
                   SVMXC__Service_Order__c eachWO = workOrdersMap.get(eachWOId);
                   if(eachWO.SVMXC__Preferred_Business_Hours__c != null && eachWO.SVMXC__Preferred_Business_Hours__r.IsActive)
                    setBhId.add(eachWO.SVMXC__Preferred_Business_Hours__c);
                   if(eachWO.SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c != NULL)
                    setBhId.add(eachWO.SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c);
                }
                
                for(Id eachTechId : techniciansMap.keySet()){
                    SVMXC__Service_Group_Members__c eachTech = techniciansMap.get(eachTechId);
                    if(eachTech.SVMXC__Working_Hours__c != null && eachTech.SVMXC__Working_Hours__r.IsActive)
                     setBhId.add(eachTech.SVMXC__Working_Hours__c);
                }

                for(WSCH_TechnicianEvent techEvent : techEvents) {
                    WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::Technician Events Iteration Start -No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
                    String workOrderId = techEvent.getWorkOrderID();
                    String techId = techEvent.getTechnicianID();
                    SVMXC__Service_Group_Members__c technician = techniciansMap.get(techId);
                    SVMXC__Service_Order__c workOrder = workOrdersMap.get(workOrderId);
                    //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::technician '+technician);
                    //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::workOrder '+workOrder);
                  
                    if(techEvent.getEventId() != null){     
                      eventIdAndTechEvents.put(techEvent.getEventId(),techEvent);
                    }

                    //update the changeTime stamp coming from Push message onto the Work Order
                    if(workOrder != null && response.getChangeTime() != null) {
                        workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = response.getChangeTime();
                    }
                    
                    //update latitude and longitude only
                    if(workOrder != null && techEvent.getDblLatitude() != null && techEvent.getDblLongitude() != null) {
                        workOrder.SVMXC__Latitude__c = techEvent.getDblLatitude();
                        workOrder.SVMXC__Longitude__c = techEvent.getDblLongitude();
                    }
                    
                    if(workOrder != null && technician == null) {
                        //updating work order error status with its error details received from run
                        if(techEvent.getErrorMsg() != null){
                            WSCH_CommonUtils.setOptimizerErrorText(workOrder,techEvent.getErrorMsg()); 
                            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        }  
                        if(String.isNotBlank(techId)) {
                            // If technician is null Notify admin/dispatcher
                            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR;
                            String errorText ='The technician scheduled in Optimax ECO is not configured in ServiceMax. Tech Id sent from Optimax ECO is : ' +techId;
                            WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
                        } 
                        
                        //updating the list with the WO that has failed
                        lstLimitedFieldWOs.add(workOrder);
                        continue;
                    }
                    
                    if((workOrder == null && technician != null) || (workOrder == null && technician == null)) {
                        continue;
                    }
                    WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::BEFORE updateWorkOrder - ' + workOrder);
                    
                     
                    SVMXC__Service_Order__c limitedFieldWorkOrder = updateWorkOrder(workOrder, technician, techEvent);
                    //WSCH_AuditLogger.debug('AFTER updateWorkOrder - ' + workOrder);
                    WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::AFTER updateWorkOrder, limitedFieldWorkOrder - ' + limitedFieldWorkOrder);
                    //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper.eventUpdated - ' + WSCH_ECO_WorkOrderEventHelper.eventUpdated);
                  
                    
                    if(!WSCH_ECO_WorkOrderEventHelper.eventUpdated) continue; // No event updates continue
                    
                    // Event update logic
                    boolean isSFEvent = false;
                    String technicianId = technician.Id;
                    if(technician.SVMXC__Salesforce_User__c != null){
                        String strGBL025 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL025');
                        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse: strGBL025 - ' + strGBL025);
                        if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('ServiceMax Event')) {
                            isSFEvent = false;
                        } else if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('Salesforce Event')) {
                            isSFEvent = true;
                            technicianId = technician.SVMXC__Salesforce_User__c;
                        }
                    }
                    
                    WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse: isSFEvent - ' + isSFEvent);
                    SVMXC__SVMX_Event__c svmxEvent = null;
                    Event event = null;

                    workOrderIdset.add(workOrderId);
                   
                    if(isSFEvent) {
                        //WSCH_AuditLogger.debug('This is SF Event');
                        event = sfEventsMap.get(workOrderId);
                        if(event == null && workOrderIdset.contains(techEvent.getWorkOrderID())) {
                            event = new Event();
                 
                            if(smaxEventsMap.containsKey(workOrderId)) {
                                //WSCH_AuditLogger.debug('This WO ' + workOrderId + ' also contains SMAX Event. Hence deleting it.');
                                SVMXC__SVMX_Event__c smaxEvent = smaxEventsMap.get(workOrderId);
                                //WSCH_AuditLogger.debug('smaxEvent - ' + smaxEvent);
                                
                             
                                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){       //SDL-SVMX-DELETE-FLS-ENFORCED
                                    delete smaxEvent;
                                } else {
                                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                                }
                                smaxEventsMap.remove(workOrderId);
                                //WSCH_AuditLogger.debug('smaxEventsMap.containsKey(workOrderId) - ' + smaxEventsMap.containsKey(workOrderId));
                              
                            }
                        }
                    } else {
                        //WSCH_AuditLogger.debug('This is SMAX Event');
                        svmxEvent = smaxEventsMap.get(workOrderId);
                         //WSCH_AuditLogger.debug('svmxEvent from smaxEventsMap'+svmxEvent);
                         
                        if(svmxEvent == null && workOrderIdset.contains(techEvent.getWorkOrderID())) {
                            svmxEvent = new SVMXC__SVMX_Event__c();
                       
                            if(sfEventsMap.containsKey(workOrderId)) {
                                //WSCH_AuditLogger.debug('This WO ' + workOrderId + ' also contains SF Event. Hence deleting it.');
                                Event sfEvent = sfEventsMap.get(workOrderId);
                                //WSCH_AuditLogger.debug('sfEvent - ' + sfEvent);
                           
                                //delete sfEvent;
                                //calling CRUD_Helper method instead of deleting the SF event directly
                                WSCH_CRUD_Helper.deleteEvents(sfEvent);
                                sfEventsMap.remove(workOrderId);
                                //WSCH_AuditLogger.debug('sfEventsMap.containsKey(workOrderId) - ' + sfEventsMap.containsKey(workOrderId));
                               
                            }
                        }
                    }
                    
                    //Drip field related updates
                    String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
                    //check if Drip is enabled or Drip feed Fields List is Not Null, else do not process Drip Logic
                    if (('TRUE'.equalsIgnoreCase(WSCH_CommonUtils.getSettingValue('DCON002','SET001')) && String.isNotBlank(dripObjFields))) {
                        if ('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)) {
                            WSCH_Provider_SP_DispatchClientHelper.updateDripValues(limitedFieldWorkOrder, dripObjFields, true);
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
                        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper :Drip Feed Setting: ' + WSCH_CommonUtils.getSettingValue('DCON002','SET001'));
                        
                    }
                    
                    if(event != null) {
                        mapSFEvent(event, techEvent, workOrder, technicianId);
                        sfEventsToUpsert.add(event);
                    }
                    if(svmxEvent != null ){
                        mapSVMXEvent(svmxEvent, techEvent, workOrder, technicianId);
                        svmxEventsToUpsert.add(svmxEvent);
                    }
                    
                    //Constraints Violation 
                    if ('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c) && job != null) { 
                        lstViolationDetails = constraintsViolationECO(job, objSvmxProcess, workOrder, mapTechIdSkills, mapTechIdProduct, techniciansMap, lstViolationDetails, lstOfViolations);        
                        //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::Violation message..'+workOrder.SVMXC__Violation_Message__c);
                        //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::Violation status..'+workOrder.SVMXC__Violation_Status2__c); 
                        if(workOrder.SVMXC__Violation_Status2__c != null){
                            limitedFieldWorkOrder.SVMXC__Violation_Status2__c = workOrder.SVMXC__Violation_Status2__c;
                            limitedFieldWorkOrder.SVMXC__Violation_Message__c = workOrder.SVMXC__Violation_Message__c;
                        }   
                        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse : in dispatched lstViolationDetails : '+lstViolationDetails.size());                
                    }
                    //adding the WO with limited fields to a list.This list is created to fix the issue where the Push notification 
                    //is overwriting certain WO fields as during Push notification is coming very fast such that the WO 
                    //query is happening even before the promise slot and other info is assigned on the WO
                    lstLimitedFieldWOs.add(limitedFieldWorkOrder);
                }
                
                //Constraints Violation                
                if(lstViolationDetails != null && lstViolationDetails.size() > 0) {
                    //upsert lstViolationDetails;
                    
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstViolationDetails, COMM_SecurityUtils.Access.Upsertable)){      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstViolationDetails;
                    } else {
                        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse : lstViolationDetails field level access' + System.label.COMM001_TAG142);
                        
                        
                        return; 
                    }
                    lstViolationDetails.clear();
                    lstOfViolations.clear();
                }
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::Handle Non-WO-Tech-Events'+eventIdAndTechEvents);
            
                //Handle the Techevents if the event ids are present in the techevents
                if(eventIdAndTechEvents != null && eventIdAndTechEvents.size() > 0){
                    updateSFAndSVMXEventsToUpsert(eventIdAndTechEvents, sfEventsToUpsert, svmxEventsToUpsert);
                     //WSCH_AuditLogger.rca('Events and Servicemax Events are updated');
                }
                
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::Technician Events Iteration End -No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
            }
        } catch (Exception ex){
            WSCH_AuditLogger.error('Exception occured while processing work order response'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
              
        } finally {
            //added the below code to fix the issue where the callout response is overwriting the Push response. This is a special case
            //where Push reponse are coming faster than the callout response. So only updating the fields(SVMXC__OptiMax_Status__c and 
            //SVMXC__OptiMax_Error_Text__c) required during callout response and ignoring all other WO fields. Other fields are redundant checkbox fields
            //which are added without which the WO will not be updated
            lstUpdateWos = new   List<SVMXC__Service_Order__c>();
            for(SVMXC__Service_Order__c eachWO:workOrderSet) {    //commented the above iteration of list to handle duplicate Id in list in case of multiple dependency objects
                SVMXC__Service_Order__c newWO = new SVMXC__Service_Order__c();
                newWO.Id = eachWO.Id;
                newWO.SVMXC__OptiMax_Status__c = eachWO.SVMXC__OptiMax_Status__c;
                newWO.SVMXC__OptiMax_Error_Text__c = eachWO.SVMXC__OptiMax_Error_Text__c;
                newWO.SVMXC__Scheduling_Retry_Count__c = eachWO.SVMXC__Scheduling_Retry_Count__c;
                newWO.SVMXC__Appointment_Promised_Time_Slot__c = eachWO.SVMXC__Appointment_Promised_Time_Slot__c;
                if ('CHANGE_CANCEL_WO'.equalsIgnoreCase(eachWO.SVMXC__Scheduling_Change_Token__c)) {
                    newWO.SVMXC__Work_Order_Scheduling_Status__c = eachWO.SVMXC__Work_Order_Scheduling_Status__c;
                    newWO.SVMXC__Scheduling_Change_Token__c = null;
                    newWO.SVMXC__OptiMax_Status__c = eachWO.SVMXC__OptiMax_Status__c;
                    newWO.SVMXC__Locked_By_DC__c = false;
                    newWO.SVMXC__SM_Lock_Appointment_Schedule__c = null;
                    newWO.SVMXC__Driving_Time__c = null;              
                }
                //newWO.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = eachWO.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c;
                lstUpdateWos.add(newWO);
            }
            if(null != lstUpdateWos && lstUpdateWos.size() > 0){
                if (!securityUtils.verifyFieldAccess(lstUpdateWos, COMM_SecurityUtils.Access.Updateable, false))        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {   //added the below check to ensure that it will not run in Test mode. Test mode expects all boolean/checkbox fields to be there on the
                        //WO before updating it. This check bypasses the redundant addition of all those boolean fields on the WO.
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                            update lstUpdateWos;
                    }
            }
            
            if(null != lstLimitedFieldWOs && lstLimitedFieldWOs.size() > 0){
                if (!securityUtils.verifyFieldAccess(lstLimitedFieldWOs, COMM_SecurityUtils.Access.Updateable, false))      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                      
           
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {
                        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::update workordersMap in finally: '+ lstLimitedFieldWOs);
                  
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                        update lstLimitedFieldWOs;
                    }
            } 
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::sfEventsToUpsert::'+sfEventsToUpsert);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::svmxEventsToUpsert::'+svmxEventsToUpsert);
            
      
            if(sfEventsToUpsert.size() > 0){
                // Guest user needs to run in system mode in order to access sf events hence removing field access check.
                /*if( COMM_SecurityUtils.getInstance().verifyFieldAccess( sfEventsToUpsert, COMM_SecurityUtils.Access.Upsertable) ) {
                    upsert sfEventsToUpsert;
                }*/
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                WSCH_CRUD_Helper.upsertListEvents(sfEventsToUpsert);
            }
            if(svmxEventsToUpsert.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( svmxEventsToUpsert, COMM_SecurityUtils.Access.Upsertable) ){        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    upsert svmxEventsToUpsert;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::processWorkOrderResponse::End-No of Queries used in this transaction so far: ' + Limits.getQueries()+' Out of '+Limits.getLimitQueries());
         }
    }
    
    /* Method to popuate the technician and work orders map */
    private static void populateTechsAndWOs(Map<String, SVMXC__Service_Group_Members__c> techniciansMap,
        Map<String, SVMXC__Service_Order__c> workOrdersMap, List<WSCH_TechnicianEvent> techEvents) {
        try{
            Set<String> techIds = new Set<String>();
            Set<String> workOrderIds = new Set<String>();
            for(WSCH_TechnicianEvent techEvent : techEvents) {
                if(techEvent.getWorkOrderID() != null){
                    workOrderIds.add(techEvent.getWorkOrderID());
                }
                if(techEvent.getTechnicianID()!= null){
                    techIds.add(techEvent.getTechnicianID());
                }
            }
            techniciansMap.putAll(fetch_ServiceGrp_Technicians(techIds));
            workOrdersMap.putAll(fetch_WorkOrders(workOrderIds));
            
            List<SVMXC__SM_Scheduling_Violation__c> listSV = [select id from SVMXC__SM_Scheduling_Violation__c where SVMXC__SM_Work_Order__c IN: workOrderIds];
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::populateTechsAndWOs : before deletion sheduling violation : '+listSV.size());
            if(listSV != null && listSV.size() > 0 && COMM_SecurityUtils.getInstance().verifyFieldAccess(listSV, COMM_SecurityUtils.Access.Upsertable)){
                delete listSV;
            }
                        
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_WorkOrderEventHelper:populateTechsAndWOs() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    private static Map<String, SVMXC__Service_Group_Members__c> fetch_ServiceGrp_Technicians(set<String> techIds){
        Map<String, SVMXC__Service_Group_Members__c> mapServiceGrp = new Map<String, SVMXC__Service_Group_Members__c>();
        try{
            List<SVMXC__Service_Group_Members__c> lstTechs = [Select Id, SVMXC__Service_Group__c, SVMXC__Optimizer_External_ID__c, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c, SVMXC__Working_Hours__r.IsActive from SVMXC__Service_Group_Members__c
                where Id in: techIds];

            for(SVMXC__Service_Group_Members__c currGrp : lstTechs){
                mapServiceGrp.put(currGrp.Id, currGrp);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_WorkOrderEventHelper:fetch_ServiceGrp_Technicians() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return mapServiceGrp;
    }
    
    /* Method which updates the work order and also validates if the event should be updated? */
    private static SVMXC__Service_Order__c updateWorkOrder(SVMXC__Service_Order__c workOrder, SVMXC__Service_Group_Members__c technician,
        WSCH_TechnicianEvent techEvent) {
        //boolean eventUpdated = false;
        SVMXC__Service_Order__c workOrderClone = new SVMXC__Service_Order__c();
        workOrderClone.id = workOrder.id;
        workOrderClone.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c;
        try{
            DateTime arrivalDateTime = techEvent.getArrivalDateTime();
            DateTime startDateTime = techEvent.getStartDateTime();
            DateTime finishDateTime = techEvent.getFinishDateTime();
            //Integer driveTime =  WSCH_DateUtils.getDurationInMinutes(startDateTime, arrivalDateTime);
            Double driveTime = 0;
            Double serviceDuration = WSCH_DateUtils.getDurationInMinutes(arrivalDateTime,finishDateTime) * 60;
            //Due to service duration change, Event required to update. so set eventUpdated is true always
            WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            if(techEvent.getVisitDuration() != null){
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateWorkOrder::Visit Duration in minutes :'+techEvent.getVisitDuration() /60);
                serviceDuration = techEvent.getVisitDuration();
            }
            
            if(techEvent.getDriveDuration() != null){
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateWorkOrder::Drive Duration in minutes :'+techEvent.getDriveDuration() / 60);
                driveTime =  Integer.valueOf(techEvent.getDriveDuration() / 60);
            }
            
            //idle time added in event start dattime due to DC view and the same added into scheduled datetime in work order view.
            /*if(techEvent.getIdleDuration() != null){                
                arrivalDateTime = arrivalDateTime.addMinutes(Integer.valueOf(techEvent.getIdleDuration() / 60));
                WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateWorkOrder: New arrivalDateTime after adding idle time: '+arrivalDateTime);
            }*/          
            
            if(workOrder.SVMXC__Service_Duration__c != serviceDuration){
                workOrder.SVMXC__Service_Duration__c = serviceDuration;
                workOrderClone.SVMXC__Service_Duration__c = serviceDuration;
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }

            if(workOrder.SVMXC__Driving_Time__c != driveTime) {
                workOrder.SVMXC__Driving_Time__c = driveTime;
                workOrderClone.SVMXC__Driving_Time__c = driveTime;
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }

            if(workOrder.SVMXC__Scheduled_Date_Time__c != arrivalDateTime) {
                workOrder.SVMXC__Scheduled_Date_Time__c = arrivalDateTime;
                workOrderClone.SVMXC__Scheduled_Date_Time__c = arrivalDateTime;
                //clearing the status unresourced if the work order get re assinged.
                workOrder.SVMXC__Violation_Status2__c = null;
                workOrderClone.SVMXC__Violation_Status2__c = null;
                workOrder.SVMXC__Violation_Message__c = null;
                workOrderClone.SVMXC__Violation_Message__c = null;
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }

            if(null != technician){
                if(workOrder.SVMXC__Group_Member__c != technician.Id) {
                    workOrder.SVMXC__Service_Group__c = technician.SVMXC__Service_Group__c;
                    workOrderClone.SVMXC__Service_Group__c = technician.SVMXC__Service_Group__c;
                    
                    workOrder.SVMXC__Group_Member__c = technician.Id;
                    workOrderClone.SVMXC__Group_Member__c = technician.Id;
                    //based on the OMAX002_SET003, Assign work order owner id from technician FF user id.
                    String strSET003 = WSCH_CommonUtils.getSettingValue('OMAX002', 'SET003');
                    //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateWorkOrder: strSET003 - ' + strSET003);
                    if(String.isNotEmpty(strSET003) && strSET003.equalsIgnoreCase('TRUE') && technician.SVMXC__Salesforce_User__c != null) {
                        workOrder.OwnerId = technician.SVMXC__Salesforce_User__c;
                        workOrderClone.OwnerId = technician.SVMXC__Salesforce_User__c;
                    }
                    WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
                }
            }
            if(workOrder.SVMXC__Scheduling_Change_Token__c != null){
                if(workOrder.SVMXC__Scheduling_Change_Token__c.equals('CHANGE_JOB_FIXED')){
                    workOrder.SVMXC__Locked_By_DC__c = true;
                    workOrderClone.SVMXC__Locked_By_DC__c = true;
                    workOrder.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                    workOrderClone.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                //In case of unfix WO using locked by DC set to false, need to reset this pick list.
                }else if(! workOrder.SVMXC__Scheduling_Change_Token__c.equals('CHANGE_SCHEDULE_LOCK') && 
                //added another condition: when appointment is booked and lockApptSchedule picklist is already set to a value
                //'Lock to arrival window', do not reset it to null
                workOrder.SVMXC__Scheduling_Change_Token__c.equals('CHANGE_CREATE_WO') && workOrder.SVMXC__SM_Lock_Appointment_Schedule__c == null){ 
                    //commented the below two lines. Because of this the push notification is overwriting the lock_to_arrival_window to
                    //null in case of appt booking WO. This was happening because PUSH notification context is querying this WO
                    //even before the lock_to_Arrival_window value is updated after the bookAppt callout. And hence later overwriting it to null
                    /*workOrder.SVMXC__SM_Lock_Appointment_Schedule__c = null;
                    workOrderClone.SVMXC__SM_Lock_Appointment_Schedule__c = null;*/
                    workOrder.SVMXC__Locked_By_DC__c = false;
                    workOrderClone.SVMXC__Locked_By_DC__c = false;
                }
            }
            
            //new check to update WorkOrder Events, if Dispatch Status changes to Tentative or Earmarked
            if((workOrder.SVMXC__Work_Order_Scheduling_Status__c != null) && 
            (techEvent.getDispatchStatus()!= null)  &&
            (workOrder.SVMXC__Work_Order_Scheduling_Status__c != getEcoJobStatus(techEvent.getDispatchStatus()))
            ){
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }
            workOrder.SVMXC__Work_Order_Scheduling_Status__c = getEcoJobStatus(techEvent.getDispatchStatus());
            workOrderClone.SVMXC__Work_Order_Scheduling_Status__c = getEcoJobStatus(techEvent.getDispatchStatus());
            
            if(workOrder.SVMXC__OptiMax_Status__c != null){
                //workOrder.SVMXC__OptiMax_Status__c = resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c);
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
                workOrderClone.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
            }else if(workOrder.SVMXC__SM_Appointment_Type__c != null){ 
                //fix for book appointment work order race condition scenarios.
                //during book appointment 'OPT_TENTATIVE' status was not. so directly set the status here.
                workOrderClone.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_COMPLETED;
            }
            
            if(techEvent.getDblLatitude() != null && techEvent.getDblLongitude() != null){
                workOrder.SVMXC__Latitude__c = techEvent.getDblLatitude();
                workOrder.SVMXC__Longitude__c = techEvent.getDblLongitude();
                
                workOrderClone.SVMXC__Latitude__c = techEvent.getDblLatitude();
                workOrderClone.SVMXC__Longitude__c = techEvent.getDblLongitude();
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }
            //reset the Promised Arrival Window field and Lock Appointment Schedule field to null when we loose the appointment due to fields related to optimization get changed.
            if(WSCH_ECO_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                workOrder.SVMXC__Appointment_Promised_Time_Slot__c=null;
                workOrderClone.SVMXC__Appointment_Promised_Time_Slot__c=null;
                workOrder.SVMXC__SM_Lock_Appointment_Schedule__c = null;
                workOrderClone.SVMXC__SM_Lock_Appointment_Schedule__c = null;
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }
            //non optimizable work order, Capacity reservation violation work orders are required to update the error message to optimax error text
            //and not required to update the optimax status to error.
            //if('NON_OPTIMIZABLE'.equalsIgnoreCase(techEvent.getDispatchStatus()) && techEvent.getErrorMsg() != null){
            if(techEvent.getErrorMsg() != null){
                WSCH_CommonUtils.setOptimizerErrorText(workOrder,techEvent.getErrorMsg());
                workOrderClone.SVMXC__OptiMax_Error_Text__c = workOrder.SVMXC__OptiMax_Error_Text__c;
                WSCH_ECO_WorkOrderEventHelper.eventUpdated = true;
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_WorkOrderEventHelper:updateWorkOrder() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return workOrderClone;
    }
    
    /**
        Following method decides, a work order status will be updated to OPT_COMPLETED, if and only if the WO status
        is in ?OPT_PENDING? or ?OPT_TENTATIVE? or 'OPT_DATA_SYNC_ERROR' or 'OPT_FAIL'.
    **/
    /*private static String resolveOptimaxStatus(String oldStatus) {
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::resolveOptimaxStatus: Old Optimax Status: '+oldStatus);
        if (oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_TENTATIVE) || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_PENDING)
             || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR) || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_FAIL) 
                || oldStatus.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_ERROR) || oldStatus.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_QUEUED) 
                    || oldStatus.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_INITIATED) || oldStatus.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_SKIPPED) 
                        || oldStatus.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_UNASSIGNED) || oldStatus.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_BATCH)) {
            return WSCH_Constants.STATUS_OPT_COMPLETED;
        }
        return oldStatus;
    }*/
    
    /*
        Temp code and will be removed once proper state flows from the optimax
    */
    private static String getEcoJobStatus(String ecoDispatchStatus){
        
        ecoDispatchStatus  = ecoDispatchStatus.toUpperCase();
        
        Map<String, String> dispatchStatus = new Map<String, String>();
        dispatchStatus.put('ON_INTERMEDIATE', 'Tentative');
        dispatchStatus.put('ON_TENTATIVE', 'Tentative');
        dispatchStatus.put('TENTATIVE', 'Tentative');
        dispatchStatus.put('ON_REQUEST', 'Tentative');
        dispatchStatus.put('DISPATCHED', 'Dispatched');
        dispatchStatus.put('ON_DISPATCH', 'Dispatched');
         
        return dispatchStatus.get(ecoDispatchStatus);
    }
    
    /* Map WSCH_TechnicianEvent object to salesforce event object */
    private static void mapSFEvent(Event event, WSCH_TechnicianEvent techEvent, SVMXC__Service_Order__c workOrder, String techId) {
        DateTime arrivalDateTime = techEvent.getArrivalDateTime();
        DateTime startDateTime = techEvent.getStartDateTime();
        DateTime endDateTime = techEvent.getFinishDateTime();
        //Integer driveTime =  WSCH_DateUtils.getDurationInMinutes(startDateTime, arrivalDateTime);
        Double driveTime =0;
        Integer idleTime;
        //Integer returnHomeDrivingTime;
        Double returnHomeDrivingTime = 0.0;
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent getVisitDuration '+techEvent.getVisitDuration());
        if(techEvent.getVisitDuration() != null)
             event.SVMXC__Service_Duration__c = techEvent.getVisitDuration();
            
        if(techEvent.getDriveDuration() != null){
            driveTime =  Integer.valueOf(techEvent.getDriveDuration() / 60);
        }    
            
        if(techEvent.getIdleDuration() != null){                
            idleTime = Integer.valueOf(techEvent.getIdleDuration() / 60);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: idleTime: '+idleTime);
            //startDateTime = startDateTime.addMinutes(idleTime);
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: New StartDateTime after adding idle time: '+startDateTime);
        }
        
        if(techEvent.getReturnHomeDrivingTime() != null){
            //returnHomeDrivingTime = Integer.valueOf(techEvent.getReturnHomeDrivingTime() / 60);
            Decimal dmlReturnDrivingTimeSec = techEvent.getReturnHomeDrivingTime();
            returnHomeDrivingTime = dmlReturnDrivingTimeSec.divide(60,3);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: ReturnHomeDrivingTime: '+returnHomeDrivingTime);
            //endDateTime = endDateTime.addMinutes(returnHomeDrivingTime);
            endDateTime = endDateTime.addSeconds(Integer.valueOf(dmlReturnDrivingTimeSec));
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: New endDateTime after adding return drive time: '+endDateTime); 
        }
        
        Integer duration=0;
        if(startDateTime != null && endDateTime != null)
            duration = WSCH_DateUtils.getDurationInMinutes(startDateTime, endDateTime);

        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent duration '+duration);
        if(workOrder != null){
            event.Subject = createSubject(workOrder);
            event.WhatId = workOrder.Id;
            event.OwnerId = techId;
            if(workOrder.SVMXC__Latitude__c != null) {
                event.SVMXC__SM_Latitude__c = workOrder.SVMXC__Latitude__c;
            }
            if(workOrder.SVMXC__Longitude__c != null) {
                event.SVMXC__SM_Longitude__c = workOrder.SVMXC__Longitude__c;
            }
        }
        if(techEvent.getDblLatitude() != null) {
            event.SVMXC__SM_Latitude__c = techEvent.getDblLatitude();
        }
        if(techEvent.getDblLongitude() != null) {
            event.SVMXC__SM_Longitude__c = techEvent.getDblLongitude();
        }
        if(startDateTime != null && endDateTime != null){
            event.StartDateTime = startDateTime;
            event.EndDateTime = endDateTime;
            event.ActivityDate = startDateTime.dateGMT();
            event.ActivityDateTime = startDateTime;
            event.DurationInMinutes = duration;
            //if non optimizable work order event than need to update the status to non-optizable.
            //else reset status to none.
            if('NON_OPTIMIZABLE'.equalsIgnoreCase(techEvent.getDispatchStatus())){
                event.SVMXC__SM_Status__c = 'Non-optimizable';
            }else{
                event.SVMXC__SM_Status__c = 'None';
            }
        }
        event.SVMXC__Driving_Time__c=driveTime;
        event.SVMXC__SM_Idle_Time__c = idleTime;
        event.SVMXC__Driving_Time_Home__c = returnHomeDrivingTime;
    }

    /* Map WSCH_TechnicianEvent object to servicemax event object */
    private static void mapSVMXEvent(SVMXC__SVMX_Event__c event, WSCH_TechnicianEvent techEvent, SVMXC__Service_Order__c workOrder, String techId) {
        DateTime arrivalDateTime = techEvent.getArrivalDateTime();
        DateTime startDateTime = techEvent.getStartDateTime();
        DateTime endDateTime = techEvent.getFinishDateTime();
        //Integer driveTime =  WSCH_DateUtils.getDurationInMinutes(startDateTime, arrivalDateTime);
        Double driveTime = 0;
        Integer idleTime;
        //Integer returnHomeDrivingTime;
        Double returnHomeDrivingTime=0.0;
       
        if(techEvent.getVisitDuration() != null)
            event.SVMXC__Service_Duration__c = techEvent.getVisitDuration();
            
        if(techEvent.getDriveDuration() != null){
            driveTime =  Integer.valueOf(techEvent.getDriveDuration() / 60);
        }    
            
        if(techEvent.getIdleDuration() != null){                
            idleTime = Integer.valueOf(techEvent.getIdleDuration() / 60);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: idleTime: '+idleTime);
            //startDateTime = startDateTime.addMinutes(idleTime);
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: New StartDateTime after adding idle time: '+startDateTime);
        }

        if(techEvent.getReturnHomeDrivingTime() != null){                
            //returnHomeDrivingTime = Integer.valueOf(techEvent.getReturnHomeDrivingTime() / 60);
            Decimal dmlReturnDrivingTimeSec = techEvent.getReturnHomeDrivingTime();
            returnHomeDrivingTime = dmlReturnDrivingTimeSec.divide(60,3);
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: returnHomeDrivingTime: '+returnHomeDrivingTime);
            //endDateTime = endDateTime.addMinutes(returnHomeDrivingTime);
            endDateTime = endDateTime.addSeconds(Integer.valueOf(dmlReturnDrivingTimeSec));
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSFEvent: New EndDateTime after adding return drive time: '+endDateTime);
        }
        
        Integer duration=0;
        if(startDateTime != null && endDateTime != null)
            duration = WSCH_DateUtils.getDurationInMinutes(startDateTime, endDateTime);
            
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::mapSVMXEvent duration '+duration);
        if(workOrder != null){
            event.Name = createSubject(workOrder);
            event.SVMXC__WhatId__c = workOrder.Id;
            event.SVMXC__Technician__c = techId;
            event.SVMXC__WhoId__c = techId;
            if(workOrder.SVMXC__Latitude__c != null) {
                event.SVMXC__SM_Latitude__c = workOrder.SVMXC__Latitude__c;
            }
            if(workOrder.SVMXC__Longitude__c != null) {
                event.SVMXC__SM_Longitude__c = workOrder.SVMXC__Longitude__c;
            }
        }
        
        if(techEvent.getDblLatitude() != null) {
            event.SVMXC__SM_Latitude__c = techEvent.getDblLatitude();
        }
        if(techEvent.getDblLongitude() != null) {
            event.SVMXC__SM_Longitude__c = techEvent.getDblLongitude();
        }
        if(startDateTime != null && endDateTime != null){
            event.SVMXC__StartDateTime__c = startDateTime;
            event.SVMXC__EndDateTime__c = endDateTime;
            event.SVMXC__ActivityDate__c = startDateTime.dateGMT();
            event.SVMXC__ActivityDateTime__c = startDateTime;    
            event.SVMXC__DurationInMinutes__c = duration;
            //if non optimizable work order event than need to update the status to non-optizable.
            //else reset status to none.            
            if('NON_OPTIMIZABLE'.equalsIgnoreCase(techEvent.getDispatchStatus())){
                event.SVMXC__SM_Status__c = 'Non-optimizable';
            }else{
                event.SVMXC__SM_Status__c = 'None';
            }
        }
        event.SVMXC__Driving_Time__c = driveTime;
        event.SVMXC__SM_Idle_Time__c = idleTime;
        event.SVMXC__Driving_Time_Home__c = returnHomeDrivingTime;
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
    
    private static Map<String, SVMXC__Service_Order__c> fetch_WorkOrders(set<String> workOrderIds){
        Map<String, SVMXC__Service_Order__c> mapServiceOrders = new Map<String, SVMXC__Service_Order__c>();
        try{
            List<String> woIdList = new List<String>(workOrderIds);
            List<SVMXC__Service_Order__c> lstWorkOrders = WSCH_CommonUtils.fetchWorkOrders(woIdList);
            for(SVMXC__Service_Order__c currWo : lstWorkOrders){
                mapServiceOrders.put(currWo.Id, currWo);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_WorkOrderEventHelper:fetch_WorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return mapServiceOrders;
    }
    
    private static String createSubject(SVMXC__Service_Order__c wo){
        String strSubject = '';
        try{
            strSubject = strSubject + (wo.Name != null ? wo.Name : '');
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_WorkOrderEventHelper:createSubject() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return strSubject;
    }
    
    public static void updateTechnicianOptimizer(List<SVMXC__SVMX_Optimizer__c> techOptimizer) {
        if(techOptimizer != null && techOptimizer.size() > 0) 
            {
                if (!securityUtils.verifyFieldAccess(techOptimizer, COMM_SecurityUtils.Access.Updateable, true))
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                else
                    {
                        update techOptimizer;  
                    }
            }
    }  
    
     public static void updateSFAndSVMXEventsToUpsert(Map<String,WSCH_TechnicianEvent> eventIdAndTechEvents, List<Event> sfEventsToUpsert,
                     List<SVMXC__SVMX_Event__c> svmxEventsToUpsert ){
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::eventIdAndTechEvents: size'+eventIdAndTechEvents.size());
        List<Event> sfEvents;
        List<SVMXC__SVMX_Event__c> svmxEvents ;
        List<String> sfEventIds = new List<String>();
        List<String> svmxEventIds = new List<String>();
        WSCH_TechnicianEvent techEventToUpdate;
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting;
        List<String> errorEventIds = new List<String>();
        WSCH_TechnicianEvent techEvent;
        for(String eventId : eventIdAndTechEvents.keySet()){
            techEvent = eventIdAndTechEvents.get(eventId);
            // If the event is a failure , update the opt transaction object with error msg
            if(techEvent.getErrorMsg() != null){
                errorEventIds.add(eventId+'%');
            }else{
                if(Schema.Sobjecttype.Event.getKeyPrefix() == eventId.substring(0,3)){
                    sfEventIds.add(eventId);
                }else if(Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix() == eventId.substring(0,3)){
                    svmxEventIds.add(eventId);
                }
            }
        }
        //Handle Failure Scenarios 
        //Get the opt tran object from event id
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::event ids with failure: ' +errorEventIds);
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::sfEventIds(): ' +sfEventIds);
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::svmxEventIds(): ' +svmxEventIds);
        
          if(errorEventIds!=null && errorEventIds.size() > 0){
            String[] eventIds = new List<String>(errorEventIds);
            lstSVMXOptimizerToExisting = 
                    [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__Optimizer_External_ID__c,SVMXC__WhatId__c ,SVMXC__Optimizer_Status__c,SVMXC__Optimizer_Error_Text__c
                            from SVMXC__SVMX_Optimizer__c where SVMXC__WhatId__c like : eventIds];
          }
          //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert:: Opt transaction Objects to udpate :- ' +lstSVMXOptimizerToExisting);
          
          if(null!= lstSVMXOptimizerToExisting && lstSVMXOptimizerToExisting.size() > 0){
             for(SVMXC__SVMX_Optimizer__c errOpt : lstSVMXOptimizerToExisting){
                //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::what/event id from opt' +errOpt.SVMXC__WhatId__c);
                techEventToUpdate = eventIdAndTechEvents.get(errOpt.SVMXC__WhatId__c.substring(0,18));
                errOpt.SVMXC__Optimizer_Status__c = WSCH_ECO_Constants.ECO_OPT_ERROR;
                errOpt.SVMXC__Optimizer_Error_Text__c = techEventToUpdate.getErrorMsg();
             }
              //update lstSVMXOptimizerToExisting;
             if(lstSVMXOptimizerToExisting != null && lstSVMXOptimizerToExisting.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXOptimizerToExisting, COMM_SecurityUtils.Access.Updateable) ) {    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update lstSVMXOptimizerToExisting; 
                }else {
                    WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::sfEventIds(): ' + System.label.COMM001_TAG142);
                    return;
                }
            }
          }
          WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert:: Opt transaction Objects after udpate :- ' +lstSVMXOptimizerToExisting);
           
          if(null == errorEventIds || errorEventIds.size()==0){
            if(sfEventIds!=null && sfEventIds.size() > 0){
                //sfEvents = [Select Id,StartDateTime,EndDateTime,SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Idle_Time__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from EVENT where Id in : sfEventIds];
                sfEvents = WSCH_CRUD_Helper.fetchListSFEvent(new Set<String>(sfEventIds));
            }
            if(svmxEventIds!=null && svmxEventIds.size() > 0){
                svmxEvents  = [Select Id,SVMXC__StartDateTime__c,SVMXC__EndDateTime__c,SVMXC__Technician__c,SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Idle_Time__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__SM_Status__c from SVMXC__SVMX_Event__c where Id in : svmxEventIds];
            }
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::sfEventIds(): ' +sfEvents);
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper::updateSFAndSVMXEventsToUpsert::svmxEventIds(): ' +svmxEvents);
          
            if(sfEvents!= null && sfEvents.size() > 0){
                for(Event sfEvent : sfEvents){
                    techEventToUpdate = eventIdAndTechEvents.get(sfEvent.Id);
                    mapSFEvent(sfEvent, techEventToUpdate, null, null);
                    sfEventsToUpsert.add(sfEvent);
                }
            }
            if(svmxEvents!=null && svmxEvents.size()>0){
                for(SVMXC__SVMX_Event__c svmxEvent : svmxEvents){
                    techEventToUpdate = eventIdAndTechEvents.get(svmxEvent.Id);
                    mapSVMXEvent(svmxEvent, techEventToUpdate, null, null);
                    svmxEventsToUpsert.add(svmxEvent);                
                }
            }
        }
    }    
    
    public static SVMXC__ServiceMax_Processes__c getSVMXProcess(Map<String, SVMXC__Service_Order__c> workOrdersMap){    
        SVMXC__ServiceMax_Processes__c objSvmxProcess = new SVMXC__ServiceMax_Processes__c();
        if(workOrdersMap != null && workOrdersMap.size() > 0){
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXProcess :: workOrdersMap :: '+ workOrdersMap);
            SVMXC__Service_Order__c woObj = workOrdersMap.values()[0];
            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXProcess :: woObj :: '+ woObj); 
            
            // Retrieve the process definition record from ServiceMax_Processes__c by matching the ID with the given dispatch process ID
            try {
                    if(woObj.SVMXC__Dispatch_Process__r.Id != null) {
                        objSvmxProcess = [Select Id, SVMXC__Tolerance__c, SVMXC__Product_Match_Enabled__c from SVMXC__ServiceMax_Processes__c where Id =:woObj.SVMXC__Dispatch_Process__r.Id];
                        //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXProcess :: objSvmxProcess :: '+objSvmxProcess);
                    } else {
                        /* Fetching the dispatch process from the Primary Territory on WO in case of appointment booking WO where DP is not calculated*/
                        List<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
                                        SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
                                        SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
                                        SVMXC__Territory__c = :woObj.SVMXC__Primary_Territory__c and SVMXC__Type__c = 'ECO' and 
                                        SVMXC__OptiMax_Message__c !='FAILED'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
                        Id dispatchProcessId;
                        if(lstSVMXJob != null && lstSVMXJob.size() > 0) {
                            dispatchProcessId = lstSVMXJob.get(0).SVMXC__SVMX_Process__c;
                            objSvmxProcess = [Select Id, SVMXC__Tolerance__c, SVMXC__Product_Match_Enabled__c from SVMXC__ServiceMax_Processes__c where Id =:dispatchProcessId];
                            //WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXProcess :: objSvmxProcess in case of appointment WO :: '+objSvmxProcess);
                        }
                    } 
            }
            catch(Exception ex) {
                throw new SVMXException('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXProcess :: Invalid dispatch process Id found.');
            }
        }
        
        return objSvmxProcess;
    }
    
    public static SVMXC__SVMX_Jobs__c getSVMXJob(SVMXC__ServiceMax_Processes__c objSvmxProcess){    
        SVMXC__SVMX_Jobs__c job = new SVMXC__SVMX_Jobs__c();
        try {
            job = [Select id from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c =: objSvmxProcess.Id and SVMXC__Type__c = 'ECO'];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA            
            WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXJob :: job ::'+job); 
            
        }
        catch(Exception ex) {
            throw new SVMXException('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: getSVMXJob :: workOrdersMap :: Invalid job id.');
        }
        return job;
    }
        
    public static List<SVMXC__SM_Scheduling_Violation__c> constraintsViolationECO(SVMXC__SVMX_Jobs__c job, SVMXC__ServiceMax_Processes__c objSvmxProcess, SVMXC__Service_Order__c workOrder, Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills, Map<Id, String> mapTechIdProduct, Map<String, SVMXC__Service_Group_Members__c> techniciansMap, List<SVMXC__SM_Scheduling_Violation__c> lstViolationDetails, List<SVMXC__SM_Scheduling_Violation__c> lstOfViolations) {
    
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: constraintsViolationECO :: STARTS');
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        String strDefaultBHourId;
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        lstBusinessHours = [Select Id, Name, IsDefault,IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
        ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
        from BusinessHours
        where Id in : setBhId OR IsDefault = TRUE]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: constraintsViolationECO :: setBhId.size => '+setBhId.size()+' , setBhId => '+setBhId + '\n' + ' lstBusinessHours => '+lstBusinessHours + ' ,\n workOrder => '+workOrder);
        
        lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
        for(BusinessHours bh : lstBusinessHours) {
            //strLogger += system.now() + ': BH---in SMAX_Complete_OptiMax_Job_WS---- ' + bh.name + '\n';
            mapBusinessHours.put(bh.Id, bh);
            if(bh.IsDefault == TRUE)
            strDefaultBHourId=bh.Id;
        }
        
        List<SVMXC__Service_Group_Members__c> lstTechs = (List<SVMXC__Service_Group_Members__c>) techniciansMap.values();
        
        SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViolationUtils = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
        String strViolationMsg = '';
        strViolationMsg += omaxViolationUtils.checkQTLViolations(workOrder,'','');
        strViolationMsg += omaxViolationUtils.checkAccessHourViolations(workOrder,'', mapBusinessHours, objSvmxProcess, '');
        strViolationMsg += omaxViolationUtils.checkWorkingHourViolations(workOrder,'', mapBusinessHours, objSvmxProcess, lstTechs, '', strDefaultBHourId);
        
        //Following case occurs when the WO which was scheduled earlier with violation msg. We need to clear
        //the msg for next run.
        if(workOrder.SVMXC__Violation_Message__c != null && workOrder.SVMXC__Violation_Status2__c != null) {
            workOrder.SVMXC__Violation_Message__c = '';
            workOrder.SVMXC__Violation_Status2__c = null;
        } 
        
        if(strViolationMsg!=null && strViolationMsg.length()>0 && !strViolationMsg.equalsIgnoreCase('null')) {
            strViolationMsg = strViolationMsg.replace(';','\n');
            workOrder.SVMXC__Violation_Message__c = strViolationMsg;
            workOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
        }
        
        
        if(workOrder.SVMXC__Skill_Set__c != null) {
            lstOfViolations = omaxViolationUtils.checkSkillViolations(mapTechIdSkills, workOrder, '', job.id);                                     
            if(lstOfViolations != null && lstOfViolations.size() > 0)
            lstViolationDetails.addAll(lstOfViolations);
        }
        
        if(workOrder.SVMXC__Preferred_Start_Time__c != null && workOrder.SVMXC__Preferred_End_Time__c != null){
            lstOfViolations = omaxViolationUtils.checkSLAViolations(workOrder, mapBusinessHours, job.id, '');
            if(lstOfViolations != null && lstOfViolations.size() > 0)
            lstViolationDetails.addAll(lstOfViolations); 
        }
        
        //Product expertise details not sent with technician callout. So violation logic not required.
        /*if(workOrder.SVMXC__Product__c != null) {                              
            lstOfViolations = omaxViolationUtils.checkProductExprtseViolations(mapTechIdProduct, workOrder, job.id, '');
            
            if(lstOfViolations != null && lstOfViolations.size() > 0)
            lstViolationDetails.addAll(lstOfViolations);
        }*/
        
        if(workOrder.SVMXC__Qualified_Technicians__c != null) { 
            lstOfViolations = omaxViolationUtils.checkEligibilityRuleViolations(workOrder, job.id, '');
            if(lstOfViolations != null && lstOfViolations.size() > 0)
            lstViolationDetails.addAll(lstOfViolations);
            
        lstOfViolations = omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(workOrder, job.id, '', workOrder.SVMXC__Group_Member__r.name);
        if(lstOfViolations != null && lstOfViolations.size() > 0)
            lstViolationDetails.addAll(lstOfViolations);
        }
        
        lstOfViolations.clear();
        WSCH_AuditLogger.debug('WSCH_ECO_WorkOrderEventHelper:: Constraints Violation :: constraintsViolationECO :: ENDS '); 
        
        
        return lstViolationDetails;
    }
}