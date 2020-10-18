public with sharing class WSCH_EventTriggerHandler 
{
    public class SVMXException extends Exception {} 
    
    //Method to create optimizer object realated to SF event 
    public static void handleSFEventInsert(List<Event> events)
    {
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        //Retrieving all technician associated with the events
        map<id,String> technicianMap = getTechniciansSFEvent(events);
        
        //Checking whether technician exist in SP(Technician External Id)
        for(Event objEvent: events) 
        {
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSFEventInsert::Insert SF Event: '+objEvent);
            if(isNonWOSFEvent(objEvent) && technicianMap.containskey(objEvent.ownerId)) 
                optimizerObjects.add(getOptimizerObject(objEvent.id,'CHANGE_CREATE'));
        }
        //Creating SVMX Optimizer      
        if(optimizerObjects.size() > 0) 
        {
            //insert optimizerObjects;
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<ID> optimizerIds = new List<ID>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects)
                optimizerIds.add(optimizer.ID);
            //invoking future call to create events in SP gantt
            manageNonWorkOrderEvents(optimizerIds, null);
        }
        WSCH_AuditLogger.finish();
    }
    
    //Method to create optimizer object realated to SF event 
    public static void handleSVMXEventInsert(list<SVMXC__SVMX_Event__c> lstevent)
    {
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        map<id,SVMXC__Service_Group_Members__c> mapIdTechObj = new map<id,SVMXC__Service_Group_Members__c>();
        //Retrieving all technician associated with the events
        mapIdTechObj = getTechniciansSVMXEvent(lstevent);
        for(SVMXC__SVMX_Event__c objEvent: lstevent) 
        {
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSVMXEventInsert::Insert SVMX Event: '+objEvent);
            //Checking whether technician exist in SP(Technician External Id)
            if(isNonWOSVMXEvent(objEvent) && mapIdTechObj.containskey(objEvent.SVMXC__Technician__c)) 
                optimizerObjects.add(getOptimizerObject(objEvent.id,'CHANGE_CREATE'));      
        }
        //Creating SVMX Optimizer      
        if(optimizerObjects.size() > 0)
        {
            //insert optimizerObjects;
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<ID> optimizerIds = new List<ID>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects)
                optimizerIds.add(optimizer.ID);
            //invoking future call to create events in SP gantt
            manageNonWorkOrderEvents(optimizerIds, null);
        }
        WSCH_AuditLogger.finish();
    }
    
    //Method to update the Event what id as Technician id for Linx for SP integration.
    public static void handleSFEventBeforeInsert(List<Event> lstevent){
        for(Event objEvent: lstevent) 
        {
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSFEventBeforeInsert:: SF Event: '+objEvent);
            if(objEvent.WhatId == null){
                SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.fetchSFUserTechnicianId(objEvent.OwnerId);
                //validate technician is service power technician or not
                if(technician != null && technician.SVMXC__Optimizer_External_ID__c != null){
                    objEvent.WhatId = technician.Id;        
                }               
            }
        }       
    }   
    
    //Method to return technicians associated with SF event
    private static map<id,String> getTechniciansSFEvent(List<Event> lstevent) {
        
        List<String> users = new List<String>();
        //Building event owner(SF user) list
        for(Event objEvent: lstevent)
        {
            if(isNonWOSFEvent(objEvent)) 
                users.add(objEvent.ownerId);
        }
        //Retrieving all technicians associated with event owner(SF user)
        map<id,SVMXC__Service_Group_Members__c> mapIdTechObj = new map<id,SVMXC__Service_Group_Members__c>([select SVMXC__Salesforce_User__c, Optimizer_External_ID__c  from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c in: users and Optimizer_External_ID__c != null]);
        map<id,String> mapSFUserId_OptExternalId = new map<id,String>();
        for(id techId :mapIdTechObj.keyset())
        {
            //Building mapIdTechObj is a map of Salesforce user id and optimizer external id of technician 
            if(mapIdTechObj.get(techId).Optimizer_External_ID__c != null)                  
                mapSFUserId_OptExternalId.put(mapIdTechObj.get(techId).SVMXC__Salesforce_User__c,mapIdTechObj.get(techId).Optimizer_External_ID__c);
        }
        return mapSFUserId_OptExternalId;
    }
    //Method to return technicians associated with SVMX event
    private static Map<ID, SVMXC__Service_Group_Members__c> getTechniciansSVMXEvent(list<SVMXC__SVMX_Event__c> lstevent) 
    {
        list<string> lstTech = new list<string>();
        for(SVMXC__SVMX_Event__c objevent : lstevent)
        {
            //Validating whether the event is Non WO event
            if( isNonWOSVMXEvent(objevent) && objevent.SVMXC__Technician__c != null)
                lstTech.add(objevent.SVMXC__Technician__c);  
        }
        map<id,SVMXC__Service_Group_Members__c> mapIdTechObj = new map<id,SVMXC__Service_Group_Members__c>();
        //Retrieving all technician associated with the events        
        return (new map<id,SVMXC__Service_Group_Members__c> ([select id, Optimizer_External_ID__c  from SVMXC__Service_Group_Members__c where id in: lstTech and Optimizer_External_ID__c != null]));
    }
    
    //Method returns Optimizer object
    public static SVMXC__SVMX_Optimizer__c getOptimizerObject(string eventid, string changeToken) 
    {
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        obj.SVMXC__WhatType__c = 'NON_WO_EVENT';
        obj.SVMXC__WhatId__c = eventid;
        obj.SVMXC__Optimizer_Change_Token__c = changeToken;
        return obj;
    }
    
    public static void handleSFEventUpdate(List<Event> newEvents, List<Event> oldEvents)
    {
        List<SVMXC__SVMX_Optimizer__c> updateEvents = new List<SVMXC__SVMX_Optimizer__c> ();
        List<Event> insertEvents = new List<Event>();
        //Retrieving existing optimizer object associated with the events
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = getSFEventOptimizers(newEvents);
        integer index = 0;
        for(Event objEvent : newEvents)
        {
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSFEventUpdate::Update SF Event: '+objEvent);
            if(isNonWOSFEvent(objEvent))
            {
                Event oldEvent = oldEvents.get(index);
                //checking whether optimizer object alredy exist, then update
                if(mapIdOptimizer.size() > 0 && mapIdOptimizer.containskey(objEvent.id))
                {  
                    String token = 'CHANGE_UPDATE';
                    
                    if(oldEvent.ownerId != objEvent.ownerId)
                    {
                        //Updating SVMX Optimizer object to reflect change of Owner(Techinician) of the associated event
                        token = 'CHANGE_UPDATE_TECH';
                    }                     
                    updateEvents.add(updateOptimizerObject(mapIdOptimizer.get(objEvent.Id), token));
                } 
                else
                {
                    // If optimizer object doesn't  exist, then create
                    insertEvents.add(objEvent);
                }
            }
            index++;
        }
        
        //Updatiing optimizer object
        if(updateEvents.size() > 0) {     
            //update updateEvents; 
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( updateEvents, COMM_SecurityUtils.Access.Updateable) ) {		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update updateEvents;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<String> lstSVMXOptimizerID = new List<String> ();                  
            for(SVMXC__SVMX_Optimizer__c objSVMXOpt : updateEvents)
                lstSVMXOptimizerID.add(objSVMXOpt.id);
            //invoking future call to update events in SP gantt
            manageNonWorkOrderEvents(lstSVMXOptimizerID, null);
        }
        
        if(insertEvents.size() > 0) {     
            System.debug(logginglevel.warn,'List of SVMX Optimizer object to be created '+insertEvents);
            handleSFEventInsert(insertEvents);
        }
        WSCH_AuditLogger.finish();
    }
    public static void handleSVMXEventUpdate(List<SVMXC__SVMX_Event__c> newEvents, List<SVMXC__SVMX_Event__c> oldEvents) {
        List<SVMXC__SVMX_Optimizer__c> updateEvents = new List<SVMXC__SVMX_Optimizer__c> ();
        List<SVMXC__SVMX_Event__c> insertEvents = new List<SVMXC__SVMX_Event__c>();
        //Retrieving existing optimizer object associated with the events
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = getSVMXEventOptimizers(newEvents);
        integer index = 0;
        for(SVMXC__SVMX_Event__c objEvent : newEvents)
        {
            //logging WO oldEvents and NewEvents details
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSVMXEventUpdate::Update SVMX Event: '+objEvent);
            if(isNonWOSVMXEvent(objEvent)) {
                SVMXC__SVMX_Event__c oldEvent = oldEvents.get(index);
                //checking whether optimizer object alredy exist, then update
                if(mapIdOptimizer.size() > 0 && mapIdOptimizer.containskey(objEvent.id))
                {  
                    String token = 'CHANGE_UPDATE';
                    if(oldEvent.SVMXC__Technician__c != objEvent.SVMXC__Technician__c)
                    {
                        //Updating SVMX Optimizer object to reflect change of Owner(Techinician) of the associated event
                        token = 'CHANGE_UPDATE_TECH';
                    }                     
                    updateEvents.add(updateOptimizerObject(mapIdOptimizer.get(objEvent.Id), token));
                }
                else
                {
                    // If optimizer object doesn't  exist, then create
                    insertEvents.add(objEvent);
                }
            }
            index++;
        }
        
        //Updatiing optimizer object
        if(updateEvents.size() > 0) {     
            //update updateEvents; 
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( updateEvents, COMM_SecurityUtils.Access.Updateable) ) {		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update updateEvents;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<String> lstSVMXOptimizerID = new List<String> ();                  
            for(SVMXC__SVMX_Optimizer__c objSVMXOpt : updateEvents)
                lstSVMXOptimizerID.add(objSVMXOpt.id);
            //invoking future call to update events in SP gantt
            manageNonWorkOrderEvents(lstSVMXOptimizerID, null);
        }
        
        if(insertEvents.size() > 0) {     
            System.debug(logginglevel.warn,'List of SVMX Optimizer object to be created '+insertEvents);
            handleSVMXEventInsert(insertEvents);
        }
        WSCH_AuditLogger.finish();
    }
    
    //Method to update Optimizer object when SF events are deleted
    public static void handleSFEventDelete(List<Event> lstEvents)
    {
        List<SVMXC__SVMX_Optimizer__c> updateEvents = new List<SVMXC__SVMX_Optimizer__c> ();
        //Retrieving existing optimizer object associated with the events
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = getSFEventOptimizers(lstEvents);
        
        for(Event objEvent : lstEvents)
        {
            mapTechCon.put(String.valueOf(objEvent.OwnerId), String.valueOf(objEvent.Id));
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSFEventDelete::Delete SF Event: '+objEvent);   
            if(mapIdOptimizer.size() > 0 && mapIdOptimizer.containskey(objEvent.id)) {                            
                updateEvents.add(updateOptimizerObject(mapIdOptimizer.get(objEvent.Id), 'CHANGE_DELETE'));
            }
        }
        
        //Updating optimizer object
        if(updateEvents.size() > 0) {     
            //update updateEvents; 
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( updateEvents, COMM_SecurityUtils.Access.Updateable) ) {		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update updateEvents;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
            List<String> lstSVMXOptimizerID = new List<String> ();                  
            for(SVMXC__SVMX_Optimizer__c objSVMXOpt : updateEvents)
                lstSVMXOptimizerID.add(objSVMXOpt.id);
            //invoking future call to update events in SP gantt
            manageNonWorkOrderEvents(lstSVMXOptimizerID, mapTechCon);
        }
        WSCH_AuditLogger.finish();
    }
    //Method to update SVMX Optimizer object when SVMX events are deleted
    public static void handleSVMXEventDelete(List<SVMXC__SVMX_Event__c> lstEvents) 
    {
        List<SVMXC__SVMX_Optimizer__c> updateEvents = new List<SVMXC__SVMX_Optimizer__c> ();
        //Retrieving existing optimizer object associated with the events
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = getSVMXEventOptimizers(lstEvents);
        
        for(SVMXC__SVMX_Event__c objEvent : lstEvents)
        {
            mapTechCon.put(String.valueOf(objEvent.SVMXC__Technician__c), String.valueOf(objEvent.Id));
            WSCH_AuditLogger.debug('WSCH_EventTriggerHandler::handleSVMXEventDelete::Delete SVMX Event: '+objEvent);
            if(mapIdOptimizer.size() > 0 && mapIdOptimizer.containskey(objEvent.id))                            
                updateEvents.add(updateOptimizerObject(mapIdOptimizer.get(objEvent.Id), 'CHANGE_DELETE'));      
        }
        
        //Updating optimizer object
        if(updateEvents.size() > 0) {     
            //update updateEvents; 
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( updateEvents, COMM_SecurityUtils.Access.Updateable) ) {		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update updateEvents;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<String> lstSVMXOptimizerID = new List<String> ();                  
            for(SVMXC__SVMX_Optimizer__c objSVMXOpt : updateEvents)
                lstSVMXOptimizerID.add(objSVMXOpt.id);
            //invoking future call to update events in SP gantt
            manageNonWorkOrderEvents(lstSVMXOptimizerID, mapTechCon);
        }
        WSCH_AuditLogger.finish();
    }
    
    //Method to check whether the given Salesforce event object is Non WO event
    private static boolean isNonWOSFEvent(Event objEvent)
    {
        try
        {
            if(objEvent.WhatId != null){
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //Technician key prefix
                String techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
                //Event's whatid key prefix
                String objectPrefix = String.valueOf(objEvent.WhatId).substring(0,3);
                
                if(woKeyPrefix.equals(objectPrefix)){
                    return false;
                }else if(techKeyPrefix.equals(objectPrefix)){
                    if(objEvent.Subject != null && objEvent.Subject.length() > 5 && objEvent.Subject.substring(0,6).contains('BREAK-')){
                        return false;   
                    }else{
                        return true;
                    }
                }               
            } else  {
                if(objEvent.Subject != null && objEvent.Subject.length() > 5 && objEvent.Subject.substring(0,6).contains('BREAK-')){
                    return false;   
                }else{
                    return true;
                }
            }
            return false;           
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.error('Exception caught:WSCH_EventTriggerHandler:isNonWOSFEvent() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;
        }
    }
    
    //Method to check whether the given SVMX event object is Non WO event
    private static boolean isNonWOSVMXEvent(SVMXC__SVMX_Event__c objEvent)
    {
        try
        {
            if(objEvent.SVMXC__WhatId__c != null){
                //WO key prefix
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //Event's whatid key prefix
                //Technician key prefix
                String techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
                
                String objectPrefix = String.valueOf(objEvent.SVMXC__WhatId__c).substring(0,3);
                if(woKeyPrefix.equals(objectPrefix)){
                    return false;
                }else if(techKeyPrefix.equals(objectPrefix)){
                    //if event name is related to break then skip the call out
                    if(objEvent.Name != null && objEvent.Name.length() > 5 && objEvent.Name.substring(0,6).contains('BREAK-')){
                        return false;   
                    }else{
                        return true;
                    }
                }               
            }else{
                //if event name is related to break then skip the call out
                if(objEvent.Name != null && objEvent.Name.length() > 5 && objEvent.Name.substring(0,6).contains('BREAK-')){
                    return false;   
                }else{
                    return true;
                }
            }
            return false;    
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.error('Exception caught:WSCH_EventTriggerHandler:isNonWOSVMXEvent() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;
        }
    }
    //Get optimizer objects related to SF events 
    private static map<String,SVMXC__SVMX_Optimizer__c> getSFEventOptimizers(list<Event> lstEvent)
    { 
        list<String> lstEventID= new list<String> ();           
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = new list<SVMXC__SVMX_Optimizer__c> ();
        for(Event objEvent : lstEvent)
            lstEventID.add(objEvent.id);
        lstSVMXOptimizerToExisting = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__Optimizer_External_ID__c,SVMXC__WhatId__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstEventID];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = new map<String,SVMXC__SVMX_Optimizer__c>();   
        for(SVMXC__SVMX_Optimizer__c objOptimizer : lstSVMXOptimizerToExisting)
            mapIdOptimizer.put(objOptimizer.SVMXC__WhatId__c,objOptimizer);
        return mapIdOptimizer;
    }
    //Get optimizer objects related to SVMX events 
    private static map<String,SVMXC__SVMX_Optimizer__c> getSVMXEventOptimizers(list<SVMXC__SVMX_Event__c> lstEvent)
    { 
        list<String> lstEventID= new list<String> ();    
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = new list<SVMXC__SVMX_Optimizer__c> ();
        for(SVMXC__SVMX_Event__c objEvent : lstEvent)
            lstEventID.add(objEvent.id);
        lstSVMXOptimizerToExisting = [Select id, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_External_ID__c, SVMXC__WhatId__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstEventID];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = new map<String,SVMXC__SVMX_Optimizer__c>();       
        for(SVMXC__SVMX_Optimizer__c objOptimizer : lstSVMXOptimizerToExisting)
            mapIdOptimizer.put(objOptimizer.SVMXC__WhatId__c,objOptimizer);     
        
        return mapIdOptimizer;
    }
    //Update optimizer objects
    private static SVMXC__SVMX_Optimizer__c updateOptimizerObject(SVMXC__SVMX_Optimizer__c objSVMXOptimizer, string changeToken) {
        if(String.isBlank(objSVMXOptimizer.SVMXC__Optimizer_External_ID__c)){
            objSVMXOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        }else{
            objSVMXOptimizer.SVMXC__Optimizer_Change_Token__c = changeToken;    
        }
        
        return objSVMXOptimizer;
    }
    public static Map<String,String> mapTechCon = new  Map<String,String>();
    @future(callout=true)
    public static void manageNonWorkOrderEvents(List<String> objSVMX_OtimizerIds, Map<String,String> mapTchCon)
    {
        String strEventId;
        /*Calling Abstract services method */
        try
        {
            if((mapTchCon != null) && (!mapTchCon.isEmpty())){
                for(String techId: mapTchCon.keySet()){
                    strEventId = mapTchCon.get(techId);
                    WSCH_Provider_SP_RealTimeOptimizer.mapEventTech.put(techId, strEventId);
                    if('00U'.equalsIgnoreCase(strEventId.left(3))){
                        WSCH_Provider_SP_RealTimeOptimizer.setSfOwner.add(techId);
                    }else if(strEventId != null){
                        WSCH_Provider_SP_RealTimeOptimizer.setSvmxTech.add(techId);
                    }
                    
                } 
            }
            System.debug('Set of SVMX Optimizer : '+ objSVMX_OtimizerIds);
            list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerById(objSVMX_OtimizerIds);
            System.debug('List of SVMX Optimizer : '+ lstSVMXOptimizer);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(lstSVMXOptimizer);
        }catch(Exception ex)
        {
            WSCH_AuditLogger.error('Exception caught:WSCH_EventTriggerHandler:manageNonWorkOrderEvents() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    }