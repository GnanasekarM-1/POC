/**
    Will contains Dispatch Client API implementation methods.
**/

public with sharing class WSCH_Provider_SP_DispatchClientHelper {

    /*
        ProcessDispatchedWorkOrder does the following.

        1. Checks if the earmark is for a Work Order. If it is for Stand alone breaks of Standard Activity , it does nothing.
        2. If the Earmark type is UnEarmark , checks if existing status is Dispatched. If existing status of work order is Dispatched , it changes it to tentative.
        If drip field is enabled for the org.
        3. In Case of Earmark type is UnEarmark , the drip fields are set to false.
        4. If the Earmark type is UnEarmark or ReEarmark , the drip field are set to true, and Scheduling status changed to earmarked.
    */
    public static Integer processDispatchedWorkOrder(WSCH_Provider_SP_DispatchClient.DispJobEarmarked dispJobEarmarked) {

        try {
            
           if(dispJobEarmarked.Breaks != null && dispJobEarmarked.Breaks.Size() > 0) 
               createEventsForBreakTimes(dispJobEarmarked.Breaks,dispJobEarmarked.empId);
                        
            if(dispJobEarmarked != null && dispJobEarmarked.jobID != null) {

                //Checks if earmark type is Non WO (Standard Activity type). If yes does nothing.
                Set<String> saEarMarkTypes = new Set<String> {'SA-Earmark','SA-UnEarmark','SA-ReEarmark'};
                if (saEarMarkTypes.contains(dispJobEarmarked.earmarkType)) {
                    return 0;
                }

                //  In case of work order is deleted from Servicemax , dispJobEarmarked.earmarkType will be unearmark and workOrder will not be available in ServiceMax.
                //  Also if the mentioned Id is not Job type (Stand Alone Break) , work order will be null and workOrderId will null below.
                String workOrderId = WSCH_CommonUtils.getWorkItemIds('Name', new List<String>{dispJobEarmarked.jobID}).get(dispJobEarmarked.jobID);
                if (String.isBlank(workOrderId)) {
                    return 0;
                }

                //Retrieving the WorkOrder using work order Id.
                SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(workOrderId);

                //If events for the work order is not created, it returns error to sp dispatch client , hence sp dispatch client will retry later.
                //Following is to handle scenario , when job got dispatched just after booking and Dispatch client send request before GetChangedWorkItems create the event.
                List<Event> sfEvents = WSCH_CommonUtils.fetchSFEventByWhatId(new Set<String>{workOrder.Id});
                List<SVMXC__SVMX_Event__c> svmxEvents = WSCH_CommonUtils.fetchSVMXEventByWhatId(new Set<String>{workOrder.Id});
                if(sfEvents.size() != 0 || svmxEvents.size() != 0) {

                    WSCH_WorkOrderResponse workOrderResponse = new WSCH_WorkOrderResponse();
                    if ('Unearmark'.equalsIgnoreCase(dispJobEarmarked.earmarkType)) {
                        //If Earmark type is UnEarmark , getting the current status of work order in Sp and updating the same in Servicemax.
                        //If Current Status not found in SP (In case of cancel job), updates the status as tentetive in Servicemax.
                        WSCH_IRealTimeOptimizer spRealTimeOptimizer = new WSCH_Provider_SP_RealTimeOptimizer();
                        String currentStatus = spRealTimeOptimizer.getJobStatus(workOrder);
                        if(String.isNotBlank(currentStatus)) {
                            workOrderResponse = WSCH_Provider_SP_DataMapper.mapDispOutputRequest(dispJobEarmarked,workOrderId,currentStatus);
                        } else {
                            workOrderResponse = WSCH_Provider_SP_DataMapper.mapDispOutputRequest(dispJobEarmarked,workOrderId,'Tentative');
                        }
                    } else {
                        workOrderResponse = WSCH_Provider_SP_DataMapper.mapDispOutputRequest(dispJobEarmarked,workOrderId,'Earmarked');
                    }
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_WorkOrderEventHelper.processWorkOrderResponse(workOrderResponse);
                }

                //  Setting the drip feed check box as true in case of earmark and reearmark.
                //  And Setting drip feed check box as false in case of unearmark.
                if ('UnEarmark'.equalsIgnoreCase(dispJobEarmarked.earmarkType)) {
                    updateDripFeed(workOrder,false);
                } else {
                    //Getting the updated WorkOrder.
                    WSCH_AuditLogger.debug('Update drip feed from dispatch client Called');
                    workOrder = WSCH_CommonUtils.fetchWorkOrderById(workOrderId);
                    updateDripFeed(workOrder,true);
                }

                return 0;
            } else {
                return 1;
            }
        }catch (Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_SP_DispatchClientHelper : ProcessDispatchedWorkOrder : '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return 1;
        }
    }

    /*
        Following method updates the drip field to true mentioned in the Drip settings SET002.
        Description for SET002 :
        "Comma separated list of fields used to determine when records are sent to mobile devices, if Drip Feed is enabled.
        Check box fields from any objects can be used. The Object and Fields should be specified using their API names (Object.Field notation).
        This is applicable when "Enable Drip Feed" is true."

        For example value of SET002 as : SVMXC__Service_Order__c.SVMXC__Drip__c
    */
    public static void updateDripFeed(SVMXC__Service_Order__c workOrder,boolean dripFeedFlag) {

        String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
        //String dripObjFields = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
        if (!('TRUE'.equalsIgnoreCase(WSCH_CommonUtils.getSettingValue('DCON002','SET001')) && String.isNotBlank(dripObjFields))) {
            return;
        }

        //Updating the drip field to true if found work order scheduling status is dispatched.
        if (dripFeedFlag && !('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c))) {
            //return;
        }
        String Id = workOrder.Id;
        Map<String,String> objectCriteriaMap = new Map<String,String> {'SVMXC__Service_Order__c'=>'Id','Event'=>'WhatId','SVMXC__SVMX_Event__c'=>'SVMXC__WhatId__c'};
        String[] listDripFields = dripObjFields.split(',',-1);
        for(String dripField : listDripFields) {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper::updateDripFeed()::dripField '+dripField);            
            String[] objFields =  dripField.split('\\.',2);
            List<Sobject> sObjects = new List<Sobject>();
            String criteria = objectCriteriaMap.get(objFields[0]);
            try {
                /*
                    Only Work Order , Event or SVMXC__SVMX_Event__c objects will be fetched if mentioned in the SET002 based on the referece to the Work order.
                    Here the relation of these onjects to the work order Id is mentioned in the map objectCriteriaMap.
                */
                if(String.isNotBlank(criteria)) {
                    String query = 'SELECT Id,' + objFields[1] + ' FROM ' + objFields[0] + ' WHERE ' + criteria +'=:Id';
                    sObjects = DataBase.query(query);
                    for (Integer index = sObjects.size() - 1; index >= 0 ; index-- ) {
                        Sobject sObj = sObjects[index];
                        Boolean currentDripFieldFlag = Boolean.valueOf(sObj.get(objFields[1]));
                        if(dripFeedFlag != currentDripFieldFlag ) {
                            sObj.put(objFields[1],dripFeedFlag);
                        } else {
                            sObjects.remove(index);
                        }
                    }
                    if(sObjects.size() > 0){
                    	if( COMM_SecurityUtils.getInstance().verifyFieldAccess( sObjects, COMM_SecurityUtils.Access.Updateable) ) {
		                    Database.update(sObjects); 
		            	}
                    }
                }
            } catch (Exception ex) {
                WSCH_AuditLogger.error('WSCH_Provider_SP_DispatchClientHelper : updateDripFeed : Exception : ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }
        }
    }
    
    /*
        Method for creating Events for the Break Times
    */
    public static boolean createEventsForBreakTimes(WSCH_Provider_SP_DispatchClient.BreakTimes[] breaks, String technicianExtId){
        WSCH_WorkOrderResponse workOrderResponse = new WSCH_WorkOrderResponse();
        List<WSCH_TechnicianEvent> lstTechEvents = new List<WSCH_TechnicianEvent>();
        List<Event> lstSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        if(breaks == null || breaks.size() == 0 || technicianExtId == null)
            return true;
        
        try{
            List<SVMXC__Service_Group_Members__c> lstTechs = [Select Id, SVMXC__Service_Group__c, SVMXC__Optimizer_External_ID__c, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Optimizer_External_ID__c =: technicianExtId];
            
            if(lstTechs == null || lstTechs.size() == 0)
                return true;
            
            for(WSCH_Provider_SP_DispatchClient.BreakTimes BT: breaks){
                DateTime eventEndDateTime, eventStartDateTime;
                eventStartDateTime = WSCH_DateUtils.parseSPDateTime(BT.BreakStart);
                eventEndDateTime = eventStartDateTime.addMinutes(integer.valueOf(BT.BreakDuration));
                
                if(lstTechs[0].SVMXC__Salesforce_User__c != null){
                    Event sfEvent = new Event();
                    sfEvent.OwnerId = lstTechs[0].SVMXC__Salesforce_User__c;
                    sfEvent.Subject = BT.BreakName;
                    sfEvent.StartDateTime = eventStartDateTime;
                    sfEvent.EndDateTime = eventEndDateTime;
                    sfEvent.ActivityDate = eventStartDateTime.date();
                    sfEvent.ActivityDateTime = eventStartDateTime;
                    sfEvent.DurationInMinutes = integer.valueOf(BT.BreakDuration);
                    lstSFEvents.add(sfEvent);
                }else{
                    SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
                    svmxEvent.Name = BT.BreakName;
                    svmxEvent.SVMXC__WhoId__c = lstTechs[0].Id;
                    svmxEvent.SVMXC__Technician__c = lstTechs[0].Id;
                    svmxEvent.SVMXC__StartDateTime__c = eventStartDateTime;
                    svmxEvent.SVMXC__EndDateTime__c = eventEndDateTime;
                    svmxEvent.SVMXC__ActivityDate__c = eventStartDateTime.date();
                    svmxEvent.SVMXC__ActivityDateTime__c = eventStartDateTime;
                    svmxEvent.SVMXC__DurationInMinutes__c = integer.valueOf(BT.BreakDuration);
                    lstSVMXEvents.add(svmxEvent);
                }
            }
            
            if(lstSFEvents != null && lstSFEvents.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstSFEvents, COMM_SecurityUtils.Access.Createable) ) {
                    insert lstSFEvents; 
            	}
            }
                
            if(lstSVMXEvents != null && lstSVMXEvents.size() > 0) {
            	if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstSVMXEvents, COMM_SecurityUtils.Access.Createable) ) {
                    insert lstSVMXEvents; 
            	}
            }
        }catch(exception ex){
            WSCH_AuditLogger.error('Error while creating Break Times and the error is: WSCH_Provider_SP_DispatchClientHelper::createEventsForBreakTimes: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;
        }
        return true;
    }
    public static void updateDripFeedList(List<SVMXC__Service_Order__c> inpWoList,Boolean dripFeedFlag) {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList : DRIP START Processing ');

        String dripObjFields = WSCH_CommonUtils.getSettingValue('DCON002','SET002');
        //String dripObjFields = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
        if (!('TRUE'.equalsIgnoreCase(WSCH_CommonUtils.getSettingValue('DCON002','SET001')) && String.isNotBlank(dripObjFields))) {
                WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper :Drip Feed Setting: ' + WSCH_CommonUtils.getSettingValue('DCON002','SET001'));
            return;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper :Drip Feed Fields: ' + dripObjFields);
        Set<ID> woIDs = new Set<ID>();
        List<String> eventFields= new List<String> ();
        List<String> svmxEventFields= new List<String> ();
        List<String> woFields= new List<String> ();
        
        List<Event> dripEvent = new List<Event>();
        List<SVMXC__SVMX_Event__c> dripSvmxEvent= new List<SVMXC__SVMX_Event__c>();
        
        String eventDripFlds='';
        String svmxEventDripFld='';
        String woDripFld='';

        try{
            //Updating the drip field to true if found work order scheduling status is dispatched.
            /*if (dripFeedFlag && !('Dispatched'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c))) {
                return;
            }*/
            
            eventFields= fetchQueryFields('Event');
            svmxEventFields= fetchQueryFields('SVMXC__SVMX_Event__c');
            woFields= fetchQueryFields('SVMXC__Service_Order__c');
            /*Create a comma-separated string of fields of EVENT Object*/
            for(String strKey : eventFields){
                if(dripObjFields.containsIgnoreCase('Event.' + strKey)){
                    if(eventDripFlds.length() > 0)
                        {eventDripFlds += ', ';}
                    eventDripFlds += strKey;
                }
            }
            eventFields = eventDripFlds.split(',',0);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList ::Event Object Fields: ' + eventDripFlds);
            /*Create a comma-separated string of fields of SVMX EVENT Object*/
            for(String strKey : svmxEventFields){
                if(dripObjFields.containsIgnoreCase('SVMXC__SVMX_Event__c.' + strKey)){
                    if(svmxEventDripFld.length() > 0)
                        {svmxEventDripFld += ', ';}
                    svmxEventDripFld += strKey;
                }
            }
            svmxEventFields= svmxEventDripFld.split(',',0);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList :SVMX_Event Object Fields: ' + svmxEventDripFld);
            /*Create a comma-separated string of fields of Work Order Object*/
            for(String strKey : woFields){
                if(dripObjFields.containsIgnoreCase('SVMXC__Service_Order__c.' + strKey)){
                    if(woDripFld.length() > 0)
                        {woDripFld += ', ';}
                    woDripFld += strKey;
                }
            }
            woFields=woDripFld.split(',',0);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList :WO Object Fields: ' + woDripFld);
            
            String qry;
            
            /*Fetch EVENT and SVMX-EVENT data only if Drip is enabled on Work Order*/
            if(!inpWoList.isEmpty()){
            
                /*Add the Work Orders to a list to fetch their IDs*/
                for(SVMXC__Service_Order__c lstWO: inpWoList){
                        woIDs.add(lstWO.ID);
                }
                WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList : WO Ids ' + woIDs);
                
                /*Set DripFeed as true as Status is DISPATCHED*/
                //dripFeedFlag = true;
                /*Update the WorkOrders with DripFeed as True*/
                //updateObject(woFields, dripFeedFlag, inpWoList);
                if(!woFields.isEmpty()){
                    updateObject(woFields, dripFeedFlag, inpWoList);
                }
                
                /*Update the SVMX_Event__c with DripFeed as True*/
                if(String.isNotBlank(eventDripFlds)){
                    eventDripFlds = ', ' + eventDripFlds;

                    qry = 'SELECT ID ' + eventDripFlds + ' FROM Event WHERE WhatId in :woIDs';
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList : Event query  ' + qry);             
                    dripEvent = Database.query(qry);
                    
                    updateObject(eventFields, dripFeedFlag, dripEvent);
                }
                
                /*Update the SVMX_Event__c with DripFeed as True*/
                if(String.isNotBlank(svmxEventDripFld)){
                    svmxEventDripFld = ', ' + svmxEventDripFld;
                
                    qry = 'SELECT ID ' + svmxEventDripFld + ' FROM SVMXC__SVMX_Event__c WHERE SVMXC__WhatId__c in :woIDs';
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList : SVMX_Event query  ' + qry);
                    dripSvmxEvent = Database.query(qry);
                    
                    updateObject(svmxEventFields, dripFeedFlag, dripSvmxEvent);
                }

            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_DispatchClientHelper : updateDripFeedList : Exception : ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        finally{
            dripEvent.clear();
            dripSvmxEvent.clear();
        }
    
    }
    /*Generic method to update Work Order, Event or SVMX_Event objects*/
    public static void updateObject(List<String> objFld, Boolean dripFlag, List<sObject> sObj){
        Boolean currentDripFieldFlag;
        List<sObject> updateObject = new List<sObject>();
        String strErrorField ;
        try{
            for(sObject updObj: sObj){
                for(String strKey : objFld){
                        strKey= strKey.trim();
                        strErrorField = strKey;
                        currentDripFieldFlag = Boolean.valueOf(updObj.get(strKey));
                        if(dripFlag != currentDripFieldFlag){
                            updObj.put(strKey,dripFlag);
                        }
                }
                updateObject.add(updObj);
            }
            
            if(updateObject != null && updateObject.size() > 0) {
	            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( updateObject, COMM_SecurityUtils.Access.Updateable) ) {
	                    Database.update(updateObject); 
	            }
            }
            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper : updateObject : updateObject:  ' + updateObject);
            //WSCH_CRUD_Helper.upsertListEvents(updateObject);
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_Provider_SP_DispatchClientHelper :: updateObject() :: Update Field: ' +  strErrorField;
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    /*Method to generate List of All Boolean/Checkbox Type Fields of an Object*/
    public static List<String> fetchQueryFields(String objName){
        List<String> strFlds = new List<String>();
        try {
            Map<String, Schema.SObjectType> gblDesc = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> mapOfFields = gblDesc.get(objName).getDescribe().fields.getMap();
            for(String key : mapOfFields.keySet())  
            {  
                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
                if(fieldResult.isAccessible() && (fieldResult.getType()== Schema.DisplayType.Boolean))  
                {
                    strFlds.add(fieldResult.getName().trim());
                }  
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_Provider_SP_DispatchClientHelper :: fetchQueryFields() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return strFlds;
    }
    //This method updates the Drip Feed fields on Work Order and its event, without using SOQL or any DML
    public static void updateDripValues(sObject dripEvent, String dripObjFields, Boolean boolDrip){
        try{
            //Get the Type of Object. WorkOrder or SF Event or SVMX_Event.
            String strEventType = String.valueOf(dripEvent.getSObjectType()).trim();
            //Create a list of Drip Feed Fields.
            List<String> lstDripFields = dripObjFields.split(',', 0);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_DispatchClientHelper:updateDripValues: DripEvent Object: ' + strEventType + ' : DripValue: ' + boolDrip + ' : DripFields Settings: ' + dripObjFields);
            //Loop through Drip Feed fields and update the Drip Value on the fields.
            for(String strField: lstDripFields){
                //Ensure proper drip feed field value (ObjectName.FieldName) is provided in the setting
                if(strField.containsIgnoreCase('.')){
                    //Check for Work Order or Event or SVMX_Event type Field in Drip Feed Field, and update the same with Drip Value
                    if(((strEventType.equalsIgnoreCase('SVMXC__Service_Order__c')) ||
                    (strEventType.equalsIgnoreCase('SVMXC__SVMX_Event__c')) ||
                    (strEventType.equalsIgnoreCase('Event'))) &&
                    (strField.trim().split('\\.',0)[0].equalsIgnoreCase(strEventType))){
                        dripEvent.put(strField.subStringAfter('.').trim(), boolDrip);
                    }
                }
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_Provider_SP_DispatchClientHelper :: updateDripValues() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
}