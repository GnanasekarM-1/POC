public with sharing class WSCH_ECO_EventTriggerHandler {
    public static Boolean isSmaxQEnabled = false;
    static {
        String setVal = WSCH_CommonUtils.getSettingValue('OMAX004','SET004');
        if(String.isNotBlank(setVal)){
            isSmaxQEnabled = Boolean.valueOf(setVal);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::static(): isSmaxQEnabled ' + isSmaxQEnabled);        
    }
         
    public static void handleSFECOEventInsertNew(List<Event> events){
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::Entered');
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::events : '+events);
        map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSFEvent(events);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::technicianMap.size(): '+technicianMap.size());
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        list<Event> listCompleteEcoSFEvents = new list<Event>();
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
            listCompleteEcoSFEvents = ecoSFEventsInsert(events, technicianMap, mapTeritoryEcoJobs); 
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::listCompleteEcoSFEvents.size() : '+listCompleteEcoSFEvents.size());
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::technicianMap : '+technicianMap);
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::mapTeritoryEcoJobs : '+mapTeritoryEcoJobs);
        if(listCompleteEcoSFEvents != null && listCompleteEcoSFEvents.size() > 0){    
            Map<String, BusinessHours> mapOfIdBussHr = getBusinessHour(technicianMap, mapTeritoryEcoJobs);
            Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = getDispatchProcess(mapTeritoryEcoJobs); 
            List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
            for(Event objEvent: listCompleteEcoSFEvents){
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::SF Event: '+objEvent);
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.OwnerId);
                SVMXC__SVMX_Jobs__c ecoJob;
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    Id terrId = technician.SVMXC__Service_Territory__c;
                    ecoJob = mapTeritoryEcoJobs.get(terrId);}   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::ecoJob: '+ecoJob);
                if(ecoJob != null && !isSkippedSFEvnt(ecoJob, objEvent, mapOfIdDispatchProcess, mapOfIdBussHr)){
                    optimizerObjects.add(createOptimizerObject(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.WhatId));
                }
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::optimizerObjects.size() : '+optimizerObjects.size());
            //Creating Optimizer records      
            if(optimizerObjects != null && optimizerObjects.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                    insert optimizerObjects;
                }else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                map<String, String> mapOptimizerIdToken = new Map<String, String>();
                List<ID> optimizerIds = new List<ID>();
                for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                    optimizerIds.add(optimizer.ID);
                    if(isSmaxQEnabled){
                        mapOptimizerIdToken.put(optimizer.ID, WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE);
                    }
                }   

                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::optimizerIds.size() : '+optimizerIds.size());    
                if(isSmaxQEnabled){
                    //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                    createMaxQTrans(mapOptimizerIdToken);                  

                }else{
                    manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
                }
                
            }
        }
        WSCH_AuditLogger.finish();
    }

    public static void handleSVMXECOEventInsertNew(list<SVMXC__SVMX_Event__c> lstevent){
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::Entered');
        map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSVMXEvent(lstevent);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::technicianMap.size(): '+technicianMap.size());
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        list<SVMXC__SVMX_Event__c> listCompleteEcoSVMXEvents = new list<SVMXC__SVMX_Event__c>();
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
            listCompleteEcoSVMXEvents = ecoSVMXEventsInsert(lstevent, technicianMap, mapTeritoryEcoJobs);   
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::listCompleteEcoSVMXEvents.size() : '+listCompleteEcoSVMXEvents.size());
        if(listCompleteEcoSVMXEvents != null && listCompleteEcoSVMXEvents.size() > 0)
        {  
            Map<String, BusinessHours> mapOfIdBussHr = getBusinessHour(technicianMap, mapTeritoryEcoJobs);
            Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = getDispatchProcess(mapTeritoryEcoJobs);  
            List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
            for(SVMXC__SVMX_Event__c objEvent: listCompleteEcoSVMXEvents){
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::SVMX SVMXC__SVMX_Event__c: '+objEvent);
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.SVMXC__Technician__c);
                SVMXC__SVMX_Jobs__c ecoJob;
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);}   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecoJob: '+ecoJob);
                if(ecoJob != null && !isSkippedSVMXEvnt(ecoJob, objEvent, mapOfIdDispatchProcess, mapOfIdBussHr)){
                    optimizerObjects.add(createOptimizerObject(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.SVMXC__WhatId__c));}
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::optimizerObjects.size() : '+optimizerObjects.size());
            //Creating Optimizer records      
            if(optimizerObjects != null && optimizerObjects.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                    insert optimizerObjects;
                }else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                map<String, String> mapOptimizerIdToken = new Map<String, String>();
                List<ID> optimizerIds = new List<ID>();
                for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                    optimizerIds.add(optimizer.ID);
                    if(isSmaxQEnabled){
                        optimizer.SVMXC__Optimizer_Status__c = 'OPT_QUEUED';
                        mapOptimizerIdToken.put(optimizer.ID, WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE);
                    }
                }   
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::optimizerIds.size() : '+optimizerIds.size());    
                if(isSmaxQEnabled){
                    //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                    createMaxQTrans(mapOptimizerIdToken);                  

                }else{
                    manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
                }
            }
        }
        WSCH_AuditLogger.finish();
    }
  
    public static void handleSFECOEventUpdateNew(List<Event> newEvents, List<Event> oldEvents)
    {
        Map<id,SVMXC__Service_Group_Members__c> allTechnicianMap = getTechniciansSFEvent(oldEvents, newEvents);
        Map<id,SVMXC__Service_Group_Members__c> technicianMap = new Map<id,SVMXC__Service_Group_Members__c>();
        Map<id,SVMXC__Service_Group_Members__c> newTechnicianMap = new Map<id,SVMXC__Service_Group_Members__c>();

        map<String,String> mapOldEvntIdTechId = new map<String,String>();
        for(Event objOldEvent: oldEvents) {
            if(allTechnicianMap.get(objOldEvent.OwnerId) != null) {
                mapOldEvntIdTechId.put(objOldEvent.Id, objOldEvent.OwnerId);
                //prepare the oldTechnician map using all tech map created above.
                technicianMap.put(objOldEvent.OwnerId, allTechnicianMap.get(objOldEvent.OwnerId));
            }
        }
        if(mapOldEvntIdTechId != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::mapOldEvntIdTechId size: '+mapOldEvntIdTechId.size());
        }
        map<String,String> mapEvntIdDiffrnTechId = new map<String,String>();
        List<String> users = new List<String>();
        String strTechTerrTimeZone;
        for(Event objNewEvent: newEvents) {
            if(allTechnicianMap.get(objNewEvent.OwnerId) != null) {
                if(objNewEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew ::This is full day event so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                strTechTerrTimeZone = allTechnicianMap.get(objNewEvent.OwnerId).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(objNewEvent.StartDateTime, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(objNewEvent.EndDateTime, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew:intDays - ' + intDays);
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                if(mapOldEvntIdTechId != null && mapOldEvntIdTechId.get(objNewEvent.Id) != null){
                    if(!mapOldEvntIdTechId.get(objNewEvent.Id).equalsIgnoreCase(objNewEvent.OwnerId)){
                        mapEvntIdDiffrnTechId.put(objNewEvent.Id, objNewEvent.OwnerId);  
                        //users.add(objNewEvent.ownerId);
                        newTechnicianMap.put(objNewEvent.ownerId, allTechnicianMap.get(objNewEvent.OwnerId));    
                    }
                } 
            }
        }
        if(mapEvntIdDiffrnTechId != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::mapEvntIdDiffrnTechId: size::'+mapEvntIdDiffrnTechId.size());
        }

        if(newTechnicianMap != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::newTechnicianMap: size:: '+newTechnicianMap.size());
        }

        //map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSFEvent(oldEvents);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::technicianMap.size(): '+technicianMap.size());
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd = new Map<String,SVMXC__SVMX_Optimizer__c>();
        set<String> setMultiEvntWOIds = new set<String>();
        set<String> setExternalWOIds = new set<String>();
        set<String> setTechWhatIds = new set<String>();
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
            map<String, List<Event>> mapWOIdListSFEvnts;
            list<String> listWOEventWhatIds = new List<String>();
            list<String> listSinleEventWhatIds = new List<String>();
            for(Event objEvent: oldEvents){
                if(objEvent.WhatId != null){
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                    String techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
                    String objectPrefix = String.valueOf(objEvent.WhatId).substring(0,3);
                    if(woKeyPrefix.equals(objectPrefix)){   
                        listWOEventWhatIds.add(objEvent.WhatId);
                    }else if(techKeyPrefix.equals(objectPrefix)){
                        setTechWhatIds.add(objEvent.WhatId);
                    }
                }
            }
            if(listWOEventWhatIds != null && listWOEventWhatIds.size() > 0){
                mapWOIdListSFEvnts = checkSingleOrMultiSFEvents(listWOEventWhatIds,strTechTerrTimeZone);
            }
            if(mapWOIdListSFEvnts != null){    
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::mapWOIdListSFEvnts.size():: '+mapWOIdListSFEvnts.size());
            }
            if(mapWOIdListSFEvnts != null && mapWOIdListSFEvnts.size() > 0){
                for(String woId : mapWOIdListSFEvnts.keySet()){
                    if(mapWOIdListSFEvnts.get(woId).size() > 1){ //If the workorder has multiple events. 
                        setMultiEvntWOIds.add(woId);
                    }else if(mapWOIdListSFEvnts.get(woId).size() == 1){ //If the workorder has sinle event then check whether it is an external workorder event.
                        listSinleEventWhatIds.add(woId);
                    }
                }
            }
            if(listSinleEventWhatIds != null && listSinleEventWhatIds.size() > 0){
                setExternalWOIds = checkForExternalWOs(listSinleEventWhatIds,mapTeritoryEcoJobs);
            }
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(technicianMap, oldEvents, null, false);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::mapEventIdOptimizerRecrd.size(): '+mapEventIdOptimizerRecrd.size());
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        for(Event objEvent: oldEvents) {
            // Skip the workorder event update if it is not mult-event or external workorder event.   
            if(objEvent.WhatId != null){
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::objEvent.WhatId: '+objEvent.WhatId);
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::setMultiEvntWOIds: '+setMultiEvntWOIds+' - setTechWhatIds....'+setTechWhatIds+' - setExternalWOIds...'+setExternalWOIds);
                if((setMultiEvntWOIds != null && !setMultiEvntWOIds.contains(objEvent.WhatId)) && (setExternalWOIds != null && !setExternalWOIds.contains(objEvent.WhatId)) && (setTechWhatIds != null && !setTechWhatIds.contains(objEvent.WhatId))){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew:: Continueue...');
                    continue;
                } 
            }
            
            //To handle the multi technician for the same event scenario
            if(mapEvntIdDiffrnTechId != null && mapEvntIdDiffrnTechId.size() > 0 && mapEvntIdDiffrnTechId.containsKey(objEvent.Id)){
                SVMXC__Service_Group_Members__c technicianNew = newTechnicianMap.get(mapEvntIdDiffrnTechId.get(objEvent.Id));
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.OwnerId);
                SVMXC__SVMX_Jobs__c ecoJob;
                
                if(technicianMap != null && technicianMap.size() > 0){
                    mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
                    if(mapTeritoryEcoJobs.isempty()){
                        return;
                    }
                }   

                // Update the old event optimizer record with Delete token
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::mapTeritoryEcoJobs: '+mapTeritoryEcoJobs);
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);
                }   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::ecoJob: '+ecoJob);
                if(ecoJob != null && mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.containsKey(objEvent.id)){
                    String optChangeToken;
                    if((mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR)){
                        optChangeToken = mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Change_Token__c;
                    }else{
                        optChangeToken = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE;
                    }
                    optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician, objEvent.WhatId)); 
                    //optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician));              
                }
                
                // Create the new event optimizer record
                Map<String, BusinessHours> mapOfIdBussHr = getBusinessHour(newTechnicianMap, mapTeritoryEcoJobs);
                Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = getDispatchProcess(mapTeritoryEcoJobs);  
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technicianNew != null){
                    ecoJob = mapTeritoryEcoJobs.get(technicianNew.SVMXC__Service_Territory__c);
                }   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecoJob: '+ecoJob);
                if(ecoJob != null && !isSkippedSFEvnt(ecoJob, objEvent, mapOfIdDispatchProcess, mapOfIdBussHr)){
                    optimizerObjects.add(createOptimizerObject(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technicianNew,objEvent.WhatId));
                }
                                
            }else{
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::SF Event: '+objEvent);
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.OwnerId);
                SVMXC__SVMX_Jobs__c ecoJob;
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);}   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::ecoJob: '+ecoJob);
                if(ecoJob != null && mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.containsKey(objEvent.id)){
                    String optChangeToken;
                    if((mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR)){
                        optChangeToken = mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Change_Token__c;
                    }else{
                        optChangeToken = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_UPDATE;
                    }
                    optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.WhatId));   
                }
            }
        }
        //Updating Optimizer records      
        if(optimizerObjects != null && optimizerObjects.size() > 0){
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                upsert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::optimizerObjects.size():: '+optimizerObjects.size());
            map<String,String> mapOptimizerIdToken = new map<String,String>();
            List<ID> optimizerIds = new List<ID>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                optimizerIds.add(optimizer.ID);
                if(isSmaxQEnabled){
                    mapOptimizerIdToken.put(optimizer.ID, optimizer.SVMXC__Optimizer_Change_Token__c);
                }
            }   
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew::optimizerIds.size() : '+optimizerIds.size());    
            if(isSmaxQEnabled){
                //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                createMaxQTrans(mapOptimizerIdToken);                  
            }else{
                manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
            }
        }
        WSCH_AuditLogger.finish();
    }

    public static void handleSVMXECOEventUpdateNew(List<SVMXC__SVMX_Event__c> newEvents, List<SVMXC__SVMX_Event__c> oldEvents){
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::newEvents: '+newEvents+' , oldEvents: '+oldEvents);
        Map<id,SVMXC__Service_Group_Members__c> allTechnicianMap = getTechniciansSVMXEvent(oldEvents, newEvents);
        Map<id,SVMXC__Service_Group_Members__c> technicianMap = new Map<id,SVMXC__Service_Group_Members__c>();
        Map<id,SVMXC__Service_Group_Members__c> newTechnicianMap = new Map<id,SVMXC__Service_Group_Members__c>();

        map<String,String> mapOldEvntIdTechId = new map<String,String>();
        for(SVMXC__SVMX_Event__c objOldEvent: oldEvents) {
            if(allTechnicianMap.get(objOldEvent.SVMXC__Technician__c) != null) {
                mapOldEvntIdTechId.put(objOldEvent.Id, objOldEvent.SVMXC__Technician__c);
                //prepare the oldTechnician map using all tech map created above.
                technicianMap.put(objOldEvent.SVMXC__Technician__c, allTechnicianMap.get(objOldEvent.SVMXC__Technician__c));
            }
        }
        if(mapOldEvntIdTechId != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::mapOldEvntIdTechId: size :: '+mapOldEvntIdTechId.size());
        }
        map<String,String> mapEvntIdDiffrnTechId = new map<String,String>();
        String strTechTerrTimeZone;
        for(SVMXC__SVMX_Event__c objNewEvent: newEvents) {
            if(allTechnicianMap.get(objNewEvent.SVMXC__Technician__c) != null) {
                if(objNewEvent.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: handleSVMXECOEventUpdateNew :: This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                strTechTerrTimeZone = allTechnicianMap.get(objNewEvent.SVMXC__Technician__c).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(objNewEvent.SVMXC__StartDateTime__c, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(objNewEvent.SVMXC__EndDateTime__c, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew:intDays - ' + intDays);
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: handleSVMXECOEventUpdateNew ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                if(mapOldEvntIdTechId != null && mapOldEvntIdTechId.get(objNewEvent.Id) != null){
                    if(!mapOldEvntIdTechId.get(objNewEvent.Id).equalsIgnoreCase(objNewEvent.SVMXC__Technician__c)){
                        mapEvntIdDiffrnTechId.put(objNewEvent.Id, objNewEvent.SVMXC__Technician__c);
                        newTechnicianMap.put(objNewEvent.SVMXC__Technician__c, allTechnicianMap.get(objNewEvent.SVMXC__Technician__c));       
                    }
                } 
            }
        }
        if(mapEvntIdDiffrnTechId != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::mapEvntIdDiffrnTechId: size:: '+mapEvntIdDiffrnTechId.size());
        }
        //commented the below code as already we have the newTechnicianMap created above.
        /*map<id,SVMXC__Service_Group_Members__c> newTechnicianMap = new map<id,SVMXC__Service_Group_Members__c>();
        if(mapEvntIdDiffrnTechId != null && mapEvntIdDiffrnTechId.size() > 0){
            newTechnicianMap = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id,SVMXC__Salesforce_User__c,SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Working_Hours__c, name, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey From SVMXC__Service_Group_Members__c where Id in : mapEvntIdDiffrnTechId.values()]);
        }*/
        if(newTechnicianMap != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::newTechnicianMap: size:: '+newTechnicianMap.size());
        }

        //map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSVMXEvent(oldEvents);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::technicianMap.size():: '+technicianMap.size());
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd;
        //List<SVMXC__SVMX_Event__c> lstFinalSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        set<String> setMultiEvntWOIds = new set<String>();
        set<String> setExternalWOIds = new set<String>();
        set<String> setTechWhatIds = new set<String>();
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
            map<String, List<SVMXC__SVMX_Event__c>> mapWOIdListSVMXEvnts;
            list<String> listWOEventWhatIds = new List<String>();
            list<String> listSinleEventWhatIds = new List<String>();
            for(SVMXC__SVMX_Event__c objEvent: oldEvents){
                if(objEvent.SVMXC__WhatId__c != null){
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                    String techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
                    String objectPrefix = String.valueOf(objEvent.SVMXC__WhatId__c).substring(0,3);
                    if(woKeyPrefix.equals(objectPrefix)){
                        listWOEventWhatIds.add(objEvent.SVMXC__WhatId__c);
                    }else if(techKeyPrefix.equals(objectPrefix)){
                        setTechWhatIds.add(objEvent.SVMXC__WhatId__c);
                    }
                }
            }
            if(listWOEventWhatIds != null && listWOEventWhatIds.size() > 0){
                mapWOIdListSVMXEvnts = checkSingleOrMultiSVMXEvents(listWOEventWhatIds,strTechTerrTimeZone);
            }
            if(mapWOIdListSVMXEvnts != null){    
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::mapWOIdListSVMXEvnts: size:: '+mapWOIdListSVMXEvnts.size());
            }
            if(mapWOIdListSVMXEvnts != null && mapWOIdListSVMXEvnts.size() > 0){
                for(String woId : mapWOIdListSVMXEvnts.keySet()){
                    if(mapWOIdListSVMXEvnts.get(woId).size() > 1){ //If the workorder has multiple events. 
                        setMultiEvntWOIds.add(woId);
                    }else if(mapWOIdListSVMXEvnts.get(woId).size() == 1){ //If the workorder has sinle event then check whether it is an external workorder event.
                        listSinleEventWhatIds.add(woId);
                    }
                }
            }
            if(listSinleEventWhatIds != null && listSinleEventWhatIds.size() > 0){
                setExternalWOIds = checkForExternalWOs(listSinleEventWhatIds,mapTeritoryEcoJobs);
            }
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::setExternalWOIds: '+setExternalWOIds+' , setMultiEvntWOIds: '+setMultiEvntWOIds);
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(technicianMap, null, oldEvents, false);
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::mapTeritoryEcoJobs: '+mapTeritoryEcoJobs);
        if(mapEventIdOptimizerRecrd != null){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::mapEventIdOptimizerRecrd: size:: '+mapEventIdOptimizerRecrd.size());
        }
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        for(SVMXC__SVMX_Event__c objEvent: oldEvents) {
            // Skip the workorder event update if it is not mult-event , external workorder event or It's what_Id is not Tech.   
            if(objEvent.SVMXC__WhatId__c != null){
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::objEvent.SVMXC__WhatId__c: '+objEvent.SVMXC__WhatId__c);
                if((setMultiEvntWOIds != null && !setMultiEvntWOIds.contains(objEvent.SVMXC__WhatId__c)) && (setExternalWOIds != null && !setExternalWOIds.contains(objEvent.SVMXC__WhatId__c)) && (setTechWhatIds != null && !setTechWhatIds.contains(objEvent.SVMXC__WhatId__c))){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew:: Continueue...');
                    continue;
                } 
            }
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::SVMX Event: '+objEvent);

           //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::mapEvntIdDiffrnTechId: '+mapEvntIdDiffrnTechId);
            //To handle the multi technician for the same event scenario
            if(mapEvntIdDiffrnTechId != null && mapEvntIdDiffrnTechId.size() > 0 && mapEvntIdDiffrnTechId.containsKey(objEvent.Id)){
                SVMXC__Service_Group_Members__c technicianNew = newTechnicianMap.get(mapEvntIdDiffrnTechId.get(objEvent.Id));
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.SVMXC__Technician__c);
                SVMXC__SVMX_Jobs__c ecoJob;
                
                if(technicianMap != null && technicianMap.size() > 0){
                    mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
                    if(mapTeritoryEcoJobs.isempty()){
                        return;
                    }
                }   

                // Update the old event optimizer record with Delete token
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::mapTeritoryEcoJobs: '+mapTeritoryEcoJobs);
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);
                }   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::ecoJob: '+ecoJob);
                if(ecoJob != null && mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.containsKey(objEvent.id)){
                    String optChangeToken;
                    if((mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR)){
                        optChangeToken = mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Change_Token__c;
                    }else{
                        optChangeToken = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE;
                    }
                    optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician, objEvent.SVMXC__WhatId__c)); 
                    //optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician));              
                }

                /*if(newTechnicianMap != null && newTechnicianMap.size() > 0){
                    mapTeritoryEcoJobs = checkForEcoTerritory(newTechnicianMap);
                    if(mapTeritoryEcoJobs.isempty()){
                        return;
                    }
                }*/   
                // Create the new event optimizer record
                Map<String, BusinessHours> mapOfIdBussHr = getBusinessHour(newTechnicianMap, mapTeritoryEcoJobs);
                Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = getDispatchProcess(mapTeritoryEcoJobs);  
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technicianNew != null){
                    ecoJob = mapTeritoryEcoJobs.get(technicianNew.SVMXC__Service_Territory__c);
                }   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecoJob: '+ecoJob);
                if(ecoJob != null && !isSkippedSVMXEvnt(ecoJob, objEvent, mapOfIdDispatchProcess, mapOfIdBussHr)){
                    optimizerObjects.add(createOptimizerObject(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technicianNew,objEvent.SVMXC__WhatId__c));
                }
                /*if(optimizerObjects != null){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::optimizerObjects: size :: '+optimizerObjects.size());
                }*/
                
            }else{
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.SVMXC__Technician__c);
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::technician: '+technician);
                SVMXC__SVMX_Jobs__c ecoJob;
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);}   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::ecoJob: '+ecoJob);
                if(ecoJob != null && mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.containsKey(objEvent.id)){
                    //Check if the same event id has different Tech id in the new evnt.
                    //If yes then take the new Tech id from the new event and fetch the technician object from the technicianMap and pass to the optimizer record.
                    String optChangeToken;
                    if((mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR)){
                        optChangeToken = mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Change_Token__c;
                    }else{
                        optChangeToken = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_UPDATE;
                    }
                    optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.SVMXC__WhatId__c));  
                }
            }
        }
        //Updating Optimizer records      
        if(optimizerObjects != null && optimizerObjects.size() > 0){
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                upsert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::optimizerObjects : size:: '+optimizerObjects.size());
            map<String,String> mapOptimizerIdToken = new map<String,String>();
            List<ID> optimizerIds = new List<ID>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                optimizerIds.add(optimizer.ID);
                if(isSmaxQEnabled){
                    mapOptimizerIdToken.put(optimizer.ID, optimizer.SVMXC__Optimizer_Change_Token__c);
                }
            }   
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventUpdateNew::optimizerIds.size() : '+optimizerIds.size());    
            if(isSmaxQEnabled){
                //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                createMaxQTrans(mapOptimizerIdToken);                  
            }else{
                manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
            }
        }
        WSCH_AuditLogger.finish();
    }

    //Method to update Optimizer record when SF events are deleted
    public static void handleSFECOEventDeleteNew(List<Event> oldEvents){
        map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSFEvent(oldEvents);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventDeleteNew::technicianMap.size() : '+technicianMap.size());   
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd = new Map<String,SVMXC__SVMX_Optimizer__c>();
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(technicianMap, oldEvents, null, false);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventDeleteNew::mapEventIdOptimizerRecrd.size() : '+mapEventIdOptimizerRecrd.size()); 
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        Map<String, String> mapOptWhatIdStatus = new Map<String, String>();
        for(Event objEvent: oldEvents) {
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventDeleteNew::SF Event: '+objEvent);
            SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.OwnerId);
            SVMXC__SVMX_Jobs__c ecoJob;
            if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);
            }   
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventDeleteNew::ecoJob: '+ecoJob);
            if(ecoJob != null && mapEventIdOptimizerRecrd != null){
                if(mapEventIdOptimizerRecrd.containsKey(objEvent.id)){
                    String optChangeToken;
                    if((mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR && mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Change_Token__c == WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE)){
                        optChangeToken = WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE;
                        mapOptWhatIdStatus.put(objEvent.Id+'_'+technician.name, WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE);
                    }else{
                        optChangeToken = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE;
                    }
                    optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.WhatId));       
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventDeleteNew::optimizerObjects.size() : '+optimizerObjects.size());
        //Updating Optimizer records      
        if(optimizerObjects != null && optimizerObjects.size() > 0){
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                upsert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            map<String,String> mapOptimizerIdToken = new map<String,String>();
            List<ID> optimizerIds = new List<ID>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                if(mapOptWhatIdStatus.get(optimizer.SVMXC__WhatId__c) != null && mapOptWhatIdStatus.get(optimizer.SVMXC__WhatId__c).equals(WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE)){
                    continue;
                }
                optimizerIds.add(optimizer.ID);
                if(isSmaxQEnabled){
                    mapOptimizerIdToken.put(optimizer.ID, optimizer.SVMXC__Optimizer_Change_Token__c);  
                }
            }   
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventDeleteNew::optimizerIds.size() : '+optimizerIds.size());    
            if(optimizerIds.size() > 0){
                if(isSmaxQEnabled){
                    //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                    createMaxQTrans(mapOptimizerIdToken);                  
                }else{
                    manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
                }
            }
        }
        WSCH_AuditLogger.finish();
    }
    
    //Method to update Optimizer record when SVMX events are deleted
    public static void handleSVMXECOEventDeleteNew(List<SVMXC__SVMX_Event__c> oldEvents){
        map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSVMXEvent(oldEvents);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::technicianMap.size() : '+technicianMap.size());  
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd = new Map<String,SVMXC__SVMX_Optimizer__c>();
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            //if(mapTeritoryEcoJobs == null){
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(technicianMap, null, oldEvents, false);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::mapEventIdOptimizerRecrd.size() : '+mapEventIdOptimizerRecrd.size());  
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        Map<String, String> mapOptWhatIdStatus = new Map<String, String>();
        for(SVMXC__SVMX_Event__c objEvent: oldEvents) {
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::SVMX Event: '+objEvent);
            SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.SVMXC__Technician__c);
            SVMXC__SVMX_Jobs__c ecoJob;
            if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);
            }   
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::ecoJob: '+ecoJob);
            if(ecoJob != null && mapEventIdOptimizerRecrd != null){
                if(mapEventIdOptimizerRecrd.containsKey(objEvent.id)){
                    String optChangeToken;
                    if((mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR && mapEventIdOptimizerRecrd.get(objEvent.Id).SVMXC__Optimizer_Change_Token__c == WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE)){
                        optChangeToken = WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE;
                        mapOptWhatIdStatus.put(objEvent.Id+'_'+technician.name, WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE);
                    }else{
                        optChangeToken = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE;
                    }
                    optimizerObjects.add(updateOptimizerObject(objEvent.Id,mapEventIdOptimizerRecrd.get(objEvent.Id),optChangeToken,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician, objEvent.SVMXC__WhatId__c)); 
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::optimizerObjects.size() : '+optimizerObjects.size());
        //Updating Optimizer records      
        if(optimizerObjects != null && optimizerObjects.size() > 0){
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                upsert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            map<String,String> mapOptimizerIdToken = new map<String,String>();
            List<ID> optimizerIds = new List<ID>();
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                if(mapOptWhatIdStatus.get(optimizer.SVMXC__WhatId__c) != null && mapOptWhatIdStatus.get(optimizer.SVMXC__WhatId__c).equals(WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE)){
                    continue;
                }    
                optimizerIds.add(optimizer.ID);
                if(isSmaxQEnabled){
                    mapOptimizerIdToken.put(optimizer.ID, optimizer.SVMXC__Optimizer_Change_Token__c);
                }
            }   
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventDeleteNew::optimizerIds.size() : '+optimizerIds.size());    
            if(optimizerIds.size() > 0){
                if(isSmaxQEnabled){
                    //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                    createMaxQTrans(mapOptimizerIdToken);                  
                }else{
                    manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
                }
            }
        }
        WSCH_AuditLogger.finish();   
    }
  
    //Method returns Optimizer object
    public static SVMXC__SVMX_Optimizer__c createOptimizerObject(String eventid, String changeToken,String eventType,String dProcess,String teritory,SVMXC__Service_Group_Members__c technician, String workorderId) 
    {
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createOptimizerObject::workorderId : '+workorderId);  
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
        obj.SVMXC__WhatType__c = eventType;
        obj.SVMXC__WhatId__c = eventid+'_'+technician.name;
        obj.SVMXC__Optimizer_Change_Token__c = changeToken;
        obj.SVMXC__Optimizer_Connection_ID__c = dProcess+'_'+teritory+'_'+technician.id;
        if(isSmaxQEnabled){
            obj.SVMXC__Optimizer_Status__c = 'OPT_QUEUED';
        }else{
            obj.SVMXC__Optimizer_Status__c = 'OPT_PENDING';
        }
        if((workorderId != null && woKeyPrefix.equals(workorderId.substring(0,3)))){
            obj.SVMXC__SM_Work_Order__c = workorderId;
        }else{
            obj.SVMXC__SM_Work_Order__c = null;
        }
        return obj;
    }
    
    //Update optimizer objects
    public static SVMXC__SVMX_Optimizer__c updateOptimizerObject(String eventid,SVMXC__SVMX_Optimizer__c objSVMXOptimizer, String changeToken,String dProcess,String teritory,SVMXC__Service_Group_Members__c technician, String workorderId) {
         //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler  : updateOptimizerObject '+changeToken);
         //WSCH_AuditLogger.debug('Updating the Optimizer Object to :  '+changeToken+' for territory '+teritory+' Technician : '+technician.Id+' Dispatch Process : '+dProcess);
         objSVMXOptimizer.SVMXC__WhatId__c = eventid+'_'+technician.name;
         objSVMXOptimizer.SVMXC__Optimizer_Change_Token__c = changeToken; 
         objSVMXOptimizer.SVMXC__Optimizer_Connection_ID__c = dProcess+'_'+teritory+'_'+technician.Id;
         if(objSVMXOptimizer.SVMXC__Optimizer_Status__c == WSCH_ECO_Constants.ECO_OPT_ERROR && changeToken.equals(WSCH_ECO_Constants.ECO_OPT_ERROR+'_'+WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE)){
            objSVMXOptimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
            objSVMXOptimizer.SVMXC__Optimizer_Change_Token__c = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE; 
         }else{
            if(isSmaxQEnabled){
                objSVMXOptimizer.SVMXC__Optimizer_Status__c = 'OPT_QUEUED';
            }else{
                objSVMXOptimizer.SVMXC__Optimizer_Status__c = 'OPT_PENDING';
            }  
         }
         if(WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE.equalsIgnoreCase(changeToken)){
            objSVMXOptimizer.SVMXC__SM_Work_Order__c = null;
         }else{
            String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
            //if(woKeyPrefix.equals(workorderId)){
            if((workorderId != null && woKeyPrefix.equals(workorderId.substring(0,3)))){    
                objSVMXOptimizer.SVMXC__SM_Work_Order__c = workorderId;
            }else{
                objSVMXOptimizer.SVMXC__SM_Work_Order__c = null;
            }            
         }
         return objSVMXOptimizer;
    }
    
    // WebService Call
    @future(callout=true)
    public static void manageNonWorkOrderECOEvents(List<String> objSVMX_OtimizerIds)
    {
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler manageNonWorkOrderECOEvents '+objSVMX_OtimizerIds);
        //WSCH_AuditLogger.rca('Optimizer Objetcs are created for the events '+objSVMX_OtimizerIds);
        try
        {
            if(null == objSVMX_OtimizerIds || objSVMX_OtimizerIds.size()==0){
                 WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : Alert !! The Events do not qualify for ECO, No Call out will be made  ');
                 //WSCH_AuditLogger.rca('WSCH_ECO_EventTriggerHandler : Alert !! The Events do not qualify for ECO, No Call out will be made  ');
            }else{
                 list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerById(objSVMX_OtimizerIds);
                 WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : List of SVMX Optimizer : '+ lstSVMXOptimizer);
                
                if(lstSVMXOptimizer != null && lstSVMXOptimizer.size() != 0){
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(lstSVMXOptimizer);
                }
            }
           
        }catch(Exception ex)
        {
            WSCH_AuditLogger.error('Exception caught:WSCH_EventTriggerHandler:manageNonWorkOrderECOEvents() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.rca('Exception caught:WSCH_EventTriggerHandler:manageNonWorkOrderECOEvents() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
  
  
   public static List<String> saveOptimizerList(List<SVMXC__SVMX_Optimizer__c> optimizerObjects){
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler The Optimizer Objets to save :- '+optimizerObjects.size());
        List<String> optimizerIdsList = new List<String>();
        if(optimizerObjects.size() > 0) 
        {
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(optimizerObjects, COMM_SecurityUtils.Access.Upsertable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert optimizerObjects;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            
            //add the saved optimizer object into into the info object
            for(SVMXC__SVMX_Optimizer__c savedOptimizer : optimizerObjects)
            {
                //WSCH_AuditLogger.debug('savedOptimizer:- '+savedOptimizer);
                optimizerIdsList.add(savedOptimizer.id);
            }
       }
       WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler Finished Constructing the SVMXC__SVMX_Optimizer__c optimizerIdsList.size() :- '+optimizerIdsList.size()); 
        return optimizerIdsList;
     }    
    
    /*public static List<SVMXC__SVMX_Optimizer__c> createDeleteOptimizerList( Map<String,SVMXC__SVMX_Optimizer__c> eventAndOptimizerMap ){
       //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler createDeleteOptimizerList :- '+eventAndOptimizerMap);
       SVMXC__ServiceMax_Processes__c dispatchProcess = new SVMXC__ServiceMax_Processes__c();
       SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
       List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
       
       List<String> dispatchProcessIds = new List<String>();
        for(String connectionId : eventAndOptimizerMap.keySet()){
            if(null != connectionId && connectionId != '' && connectionId.contains('_')){
                dispatchProcessIds.add(connectionId.split('_')[0]);
            }
        } 
        Map<Id,SVMXC__ServiceMax_Processes__c> dispatchProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>([SELECT Id, SVMXC__Dispatch_Method__c FROM SVMXC__ServiceMax_Processes__c  where  SVMXC__Record_Type_Name__c='Dispatch Process' and id in : dispatchProcessIds]) ;
       for(String connectionId : eventAndOptimizerMap.keySet()){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler createDeleteOptimizerList: connectionId '+connectionId); 
            if(null != connectionId && connectionId != '' && connectionId.contains('_')){
                optimizer =  eventAndOptimizerMap.get(connectionId);
                dispatchProcess = dispatchProcessMap.get(connectionId.split('_')[0]);
            
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler createDeleteOptimizerList: optimizer '+optimizer); 
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler createDeleteOptimizerList: dispatchProcess '+dispatchProcess); 
            
                if(null != dispatchProcess &&  dispatchProcess.SVMXC__Dispatch_Method__c == WSCH_ECO_Constants.OPT_DISPATCH_PROCES_ECO){
                    optimizer.SVMXC__Optimizer_Change_Token__c = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE; 
                    optimizerObjects.add(optimizer);
                }   
            }
       }
        return optimizerObjects;
    }*/
    
    public static boolean checkEventForSLA(Datetime evStartTime, Datetime evEndTime, DateTime dtmSchedulingHorizonStartDateTime, 
                                DateTime dtmSchedulingHorizonEndDateTime, String strTimeZone) {
        Boolean isEventSkipped = false;
        DateTime dtmSchedulingHorizonStartDateTimeGMT = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, strTimeZone, 'GMT');
        DateTime dtmSchedulingHorizonEndDateTimeGMT = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, strTimeZone, 'GMT');
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::evStartTime:'+evStartTime);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::evEndTime:'+evEndTime);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::dtmSchedulingHorizonStartDateTimeGMT:'+dtmSchedulingHorizonStartDateTimeGMT);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::dtmSchedulingHorizonEndDateTimeGMT:'+dtmSchedulingHorizonEndDateTimeGMT);
        if(evStartTime < dtmSchedulingHorizonStartDateTimeGMT && evEndTime < dtmSchedulingHorizonStartDateTimeGMT) {
            //both the event start and end datetime are in the past. So skip the creation of opt_trans records'
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::Event is in past date. Hence could not be sent to server');
            isEventSkipped = true;
        
        } else if(evStartTime > dtmSchedulingHorizonEndDateTimeGMT && evEndTime > dtmSchedulingHorizonEndDateTimeGMT) {
            //both the event start and end datetimes are in future. So skip the creation of opt_trans records'.
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::Event is out of Horizon. Hence it is skipped for now');
            isEventSkipped = true;
            
        } else if(evStartTime < dtmSchedulingHorizonStartDateTimeGMT && evEndTime > dtmSchedulingHorizonEndDateTimeGMT) {
            //Event start datetime is in the past and end datetime is in future. So skip the creation of opt_trans records'
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkEventForSLA::Event is out of Horizon. Hence it is skipped for now');
            isEventSkipped = true;
        }
        return isEventSkipped;
    }
    
    //Update the lat long of the new events created during Multi-resource and Multi-appointment
    public static void updateSVMXEventLatLong(list<String> listWOEventWhatIds, List<SVMXC__SVMX_Event__c> listSVMXEvents){
        Map<Id, SVMXC__Service_Order__c> mapEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
        mapEventWorkOrders.putAll([Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c from SVMXC__Service_Order__c where Id IN: listWOEventWhatIds]);
        Map<Id, List<Double>> mapWoIdLatLong = new Map<Id, List<Double>>();
        if(mapEventWorkOrders != null){
            for(Id woId : listWOEventWhatIds){
                List<Double> lstLatLong = new List<Double>();
                if(mapEventWorkOrders.get(woId) != null){
                    lstLatLong.add(mapEventWorkOrders.get(woId).SVMXC__Latitude__c);
                    lstLatLong.add(mapEventWorkOrders.get(woId).SVMXC__Longitude__c);
                    mapWoIdLatLong.put(woId,lstLatLong);
                }
            }
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::updateSVMXEventLatLong::mapWoIdLatLong: '+mapWoIdLatLong);
        for(SVMXC__SVMX_Event__c svmxEvnt : listSVMXEvents){
            if(mapWoIdLatLong != null && mapWoIdLatLong.get(svmxEvnt.SVMXC__WhatId__c) != null){
                if(svmxEvnt.SVMXC__SM_Latitude__c == null || svmxEvnt.SVMXC__SM_Longitude__c == null){
                   svmxEvnt.SVMXC__SM_Latitude__c = mapWoIdLatLong.get(svmxEvnt.SVMXC__WhatId__c)[0];
                   svmxEvnt.SVMXC__SM_Longitude__c = mapWoIdLatLong.get(svmxEvnt.SVMXC__WhatId__c)[1];   
                }
            }
        }
    
    }
    
    //Update the lat long of the new events created during Multi-resource and Multi-appointment
    public static void updateSFEventLatLong(List<Event> listSFvents){
        list<String> listWOEventWhatIds = new list<String>();
        for(Event evnt : listSFvents){
            listWOEventWhatIds.add(evnt.WhatId);
        }       
        
        Map<Id, SVMXC__Service_Order__c> mapEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
        mapEventWorkOrders.putAll([Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c from SVMXC__Service_Order__c where Id IN: listWOEventWhatIds]);
        
        Map<Id, List<Double>> mapWoIdLatLong = new Map<Id, List<Double>>();
        if(mapEventWorkOrders != null){
            for(Id woId : listWOEventWhatIds){
                List<Double> lstLatLong = new List<Double>();
                if(mapEventWorkOrders.get(woId) != null){
                    lstLatLong.add(mapEventWorkOrders.get(woId).SVMXC__Latitude__c);
                    lstLatLong.add(mapEventWorkOrders.get(woId).SVMXC__Longitude__c);
                    mapWoIdLatLong.put(woId,lstLatLong);
                }
            }
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::updateSFEventLatLong::mapWoIdLatLong: '+mapWoIdLatLong);
        for(Event sfEvn : listSFvents){
            if(mapWoIdLatLong != null && mapWoIdLatLong.get(sfEvn.WhatId) != null){
                if(sfEvn.SVMXC__SM_Latitude__c == null && sfEvn.SVMXC__SM_Longitude__c == null){
                   sfEvn.SVMXC__SM_Latitude__c = mapWoIdLatLong.get(sfEvn.WhatId)[0];
                   sfEvn.SVMXC__SM_Longitude__c = mapWoIdLatLong.get(sfEvn.WhatId)[1];   
                }
            }
        }
    }
    
    //Create a pillar when the workorder locked by DC is made from false to true and the workorder has only one event
    public static void createPillar(List<String> listWOIds){
        //TODO: Pass only the list of ECO workorders from the WSCH_ECO_TriggerHandler to this method. 
        //For SVMX events
        List<SVMXC__SVMX_Event__c> listSVMXEvents =  [Select Id, SVMXC__WhatId__c, SVMXC__IsAllDayEvent__c, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c In : listWOIds];
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillar listSVMXEvents.size(): '+listSVMXEvents.size());
        map<String, List<SVMXC__SVMX_Event__c>> mapWOIdSvmxEvnt = new map<String, list<SVMXC__SVMX_Event__c>>();
        if(listSVMXEvents != null && listSVMXEvents.size() > 0){
            for(SVMXC__SVMX_Event__c svmxEvnt : listSVMXEvents){
                list<SVMXC__SVMX_Event__c> listSVMXEvnt = new list<SVMXC__SVMX_Event__c>();
                if(mapWOIdSvmxEvnt.containsKey(svmxEvnt.SVMXC__WhatId__c)){
                    list<SVMXC__SVMX_Event__c> tmpLstSvmxEvnt = mapWOIdSvmxEvnt.get(svmxEvnt.SVMXC__WhatId__c);
                    tmpLstSvmxEvnt.add(svmxEvnt);
                    mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,tmpLstSvmxEvnt);
                }else{
                    listSVMXEvnt.add(svmxEvnt);
                    mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,listSVMXEvnt);
                }
            }
        }
        List<SVMXC__SVMX_Event__c> listSingleSVMXEvnts = new List<SVMXC__SVMX_Event__c>();
        if(mapWOIdSvmxEvnt != null && mapWOIdSvmxEvnt.size() > 0){
            for(String woId : mapWOIdSvmxEvnt.keySet()){
                if(mapWOIdSvmxEvnt.get(woId).size() == 1){
                    listSingleSVMXEvnts.add(mapWOIdSvmxEvnt.get(woId)[0]);
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillar listSingleSVMXEvnts.size(): '+listSingleSVMXEvnts.size());
        if(listSingleSVMXEvnts != null && listSingleSVMXEvnts.size() > 0){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillar for SVMX single event');
            createPillarSVMXECOSingleEventNew(listSingleSVMXEvnts);
        }
        // For SF events
        List<Event> listSFEvents =  [Select Id, WhatId, IsAllDayEvent, ownerId, StartDateTime, EndDatetime from Event where WhatId In : listWOIds];
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillar listSFEvents.size(): '+listSFEvents.size());
        map<String, List<Event>> mapWOIdSFEvnt = new map<String, list<Event>>();
        if(listSFEvents != null && listSFEvents.size() > 0){
            for(Event sfEvnt : listSFEvents){
                list<Event> listSFEvnt = new list<Event>();
                if(mapWOIdSFEvnt.containsKey(sfEvnt.WhatId)){
                    list<Event> tmpLstSvmxEvnt = mapWOIdSFEvnt.get(sfEvnt.WhatId);
                    tmpLstSvmxEvnt.add(sfEvnt);
                    mapWOIdSFEvnt.put(sfEvnt.WhatId,tmpLstSvmxEvnt);
                }else{
                    listSFEvnt.add(sfEvnt);
                    mapWOIdSFEvnt.put(sfEvnt.WhatId,listSFEvnt);
                }
            }
        }
        List<Event> listSingleSFEvnts = new List<Event>();
        if(mapWOIdSFEvnt != null && mapWOIdSFEvnt.size() > 0){
            for(String woId : mapWOIdSFEvnt.keySet()){
                if(mapWOIdSFEvnt.get(woId).size() == 1){
                    listSingleSFEvnts.add(mapWOIdSFEvnt.get(woId)[0]);
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillar :: listSingleSFEvnts.size() :: '+listSingleSFEvnts.size());
        if(listSingleSFEvnts != null && listSingleSFEvnts.size() > 0){
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillar for SF single event');
            //createPillarSFECOSingleEvent(listSingleSFEvnts);
            createPillarSFECOSingleEventNew(listSingleSFEvnts);
        }
    } 
    
    public static void createPillarSVMXECOSingleEventNew(list<SVMXC__SVMX_Event__c> lstevent){
        List<SVMXC__SVMX_Event__c> lstValidSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        Map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSVMXEvent(lstevent);
        for(SVMXC__SVMX_Event__c svmxEvent : lstevent){
            if(technicianMap.get(svmxEvent.SVMXC__Technician__c) != null) {
                if(svmxEvent.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                String strTechTerrTimeZone = technicianMap.get(svmxEvent.SVMXC__Technician__c).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvent.SVMXC__StartDateTime__c, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvent.SVMXC__EndDateTime__c, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew:intDays - ' + intDays);
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                lstValidSVMXEvents.add(svmxEvent); 
            }
        }
        if(lstValidSVMXEvents.size() == 0){
            //WSCH_AuditLogger.finish();
            return;
        }
        //commented the below code as it has been moved above
        //map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSVMXEvent(lstValidSVMXEvents);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::technicianMap.size() : '+technicianMap.size());
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
        }    
        list<SVMXC__SVMX_Event__c> listFinalEcoSingleSVMXEvents = singleEvntListSvmxCreatePillar(lstValidSVMXEvents, technicianMap);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::listFinalEcoSingleSVMXEvents.size() : '+listFinalEcoSingleSVMXEvents.size());
        if(listFinalEcoSingleSVMXEvents != null && listFinalEcoSingleSVMXEvents.size() > 0){   
            Map<String, BusinessHours> mapOfIdBussHr = getBusinessHour(technicianMap, mapTeritoryEcoJobs);
            Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = getDispatchProcess(mapTeritoryEcoJobs); 
            List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
            for(SVMXC__SVMX_Event__c objEvent: listFinalEcoSingleSVMXEvents){
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::SVMX SVMXC__SVMX_Event__c: '+objEvent);
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.SVMXC__Technician__c);
                SVMXC__SVMX_Jobs__c ecoJob;
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);}   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::ecoJob: '+ecoJob);
                if(ecoJob != null && !isSkippedSVMXEvnt(ecoJob, objEvent, mapOfIdDispatchProcess, mapOfIdBussHr)){
                    optimizerObjects.add(createOptimizerObject(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.SVMXC__WhatId__c));}
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::optimizerObjects.size() : '+optimizerObjects.size());
            //Creating Optimizer records      
            if(optimizerObjects != null && optimizerObjects.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                    insert optimizerObjects;
                }else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );}
                List<ID> optimizerIds = new List<ID>();
                for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                    optimizerIds.add(optimizer.ID);
                }   
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSVMXECOSingleEventNew::optimizerIds.size() : '+optimizerIds.size());    
                manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
            }
        }
        //WSCH_AuditLogger.finish();
    }
    
    public static void createPillarSFECOSingleEventNew(list<Event> lstevent){
        List<Event> lstValidSFEvents = new List<Event>();
        Map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSFEvent(lstevent);
        for(Event sfEvent : lstevent){
            if(technicianMap.get(sfEvent.ownerId) != null) {
                if(sfEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                String strTechTerrTimeZone = technicianMap.get(sfEvent.ownerId).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(sfEvent.StartDateTime, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(sfEvent.EndDateTime, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew:intDays - ' + intDays);
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                lstValidSFEvents.add(sfEvent); 
            }
        }
        if(lstValidSFEvents.size() == 0){
            //WSCH_AuditLogger.finish();
            return;
        }
        //commented the below code as it has been moved above
        //map<id,SVMXC__Service_Group_Members__c> technicianMap = getTechniciansSFEvent(lstValidSFEvents);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::technicianMap.size() : '+technicianMap.size());
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs;
        if(technicianMap != null && technicianMap.size() > 0){
            mapTeritoryEcoJobs = checkForEcoTerritory(technicianMap);
            if(mapTeritoryEcoJobs.isempty()){
                return;
            }
        }    
        list<Event> listFinalEcoSingleSFEvents = singleEvntListSFCreatePillar(lstValidSFEvents, technicianMap);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::listFinalEcoSingleSFEvents.size() : '+listFinalEcoSingleSFEvents.size());
        if(listFinalEcoSingleSFEvents != null && listFinalEcoSingleSFEvents.size() > 0){   
            Map<String, BusinessHours> mapOfIdBussHr = getBusinessHour(technicianMap, mapTeritoryEcoJobs);
            Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = getDispatchProcess(mapTeritoryEcoJobs); 
            List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
            for(Event objEvent: listFinalEcoSingleSFEvents){
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::SF Event: '+objEvent);
                SVMXC__Service_Group_Members__c technician = technicianMap.get(objEvent.OwnerId);
                SVMXC__SVMX_Jobs__c ecoJob;
                if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0 && technician != null){
                    ecoJob = mapTeritoryEcoJobs.get(technician.SVMXC__Service_Territory__c);}   
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::ecoJob: '+ecoJob);
                if(ecoJob != null && !isSkippedSFEvnt(ecoJob, objEvent, mapOfIdDispatchProcess, mapOfIdBussHr)){
                    optimizerObjects.add(createOptimizerObject(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,ecoJob.SVMXC__SVMX_Process__c,ecoJob.SVMXC__Territory__c,technician,objEvent.WhatId));}
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::optimizerObjects.size() : '+optimizerObjects.size());
            //Creating Optimizer records      
            if(optimizerObjects != null && optimizerObjects.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Createable ) ) {
                    insert optimizerObjects;
                }else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );}
                List<ID> optimizerIds = new List<ID>();
                for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                    optimizerIds.add(optimizer.ID);
                }   
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::createPillarSFECOSingleEventNew::optimizerIds.size() : '+optimizerIds.size());    
                manageNonWorkOrderECOEvents(optimizerIds); //Manage callout
            }
        }
        //WSCH_AuditLogger.finish();
    }

   //Method to return technicians associated with the SF events
   public static map<id,SVMXC__Service_Group_Members__c> getTechniciansSFEvent(List<Event> lstevent) 
   {
        List<String> users = new List<String>();
        List<String> lstUsersAllDayMultiDay = new List<String>();
        //Building event owner(SF user) list
        for(Event objEvent: lstevent){
            if(objEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSFEvent ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                lstUsersAllDayMultiDay.add(objEvent.ownerId); 
                continue;
            }
            users.add(objEvent.ownerId);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent::users.size() : '+users.size());
        //Retrieving all technicians associated with event owner(SF user)
        map<id,SVMXC__Service_Group_Members__c> mapSFuserIdTechObj = new map<id,SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        if(users != null && users.size() > 0){
            lstTechnicians = [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c, SVMXC__Working_Hours__r.IsActive, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey  From SVMXC__Service_Group_Members__c WHERE SVMXC__Service_Territory__c != null AND SVMXC__Salesforce_User__c IN :users];
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent::lstTechnicians.size(): '+lstTechnicians.size());
        for(SVMXC__Service_Group_Members__c tech :lstTechnicians){
            mapSFuserIdTechObj.put(tech.SVMXC__Salesforce_User__c, tech);
        }

        for(Event objEvent: lstevent){
            if(mapSFuserIdTechObj != null && mapSFuserIdTechObj.size() > 0){
                String strTechTerrTimeZone = mapSFuserIdTechObj.get(objEvent.ownerId).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(objEvent.StartDateTime, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(objEvent.EndDateTime, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent:intDays - ' + intDays);
                    //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSFEvent ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    lstUsersAllDayMultiDay.add(objEvent.ownerId);  
                    continue;
                }
            }
        }

        if(lstUsersAllDayMultiDay != null && lstUsersAllDayMultiDay.size() > 0){
            List<SVMXC__Service_Group_Members__c> lstTechAllDayMultiDay = new List<SVMXC__Service_Group_Members__c>();
            lstTechAllDayMultiDay = [Select Id, Name  From SVMXC__Service_Group_Members__c WHERE SVMXC__Service_Territory__c != null AND SVMXC__Salesforce_User__c IN :lstUsersAllDayMultiDay];
            List<String> lstWhatId = new List<String>();
            for(SVMXC__Service_Group_Members__c tech : lstTechAllDayMultiDay){
                lstWhatId.add(tech.Id+'_'+tech.Name);
            }
            if(lstWhatId != null && lstWhatId.size() > 0){
                allDayMultiDayEvntCallout(lstWhatId);
            }
        } 

        return mapSFuserIdTechObj;
   }

   public static map<id,SVMXC__Service_Group_Members__c> getTechniciansSFEvent(List<Event> lstOldEvents, List<Event> lstNewEvents) 
   {
        Set<String> users = new Set<String>();
        //Building event owner(SF user) list
        for(Event objEvent: lstOldEvents){
            //commenting the below code as this check is not required for the OldEvents
            /*if(objEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSFEvent ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }*/
            users.add(objEvent.ownerId);
        }
        for(Event objEvent: lstNewEvents){
            if(objEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSFEvent ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }
            users.add(objEvent.ownerId);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent::users.size() : '+users.size());
        //Retrieving all technicians associated with event owner(SF user)
        map<id,SVMXC__Service_Group_Members__c> mapSFuserIdTechObj = new map<id,SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        if(users != null && users.size() > 0){
            lstTechnicians = [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c, SVMXC__Working_Hours__r.IsActive, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey  From SVMXC__Service_Group_Members__c WHERE SVMXC__Service_Territory__c != null AND SVMXC__Salesforce_User__c IN :users];
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSFEvent::lstTechnicians.size(): '+lstTechnicians.size());
        for(SVMXC__Service_Group_Members__c tech :lstTechnicians){
            mapSFuserIdTechObj.put(tech.SVMXC__Salesforce_User__c, tech);
        }
        return mapSFuserIdTechObj;
   }
    
   //Method to return technicians associated with the SVMX events
   public static map<id,SVMXC__Service_Group_Members__c> getTechniciansSVMXEvent(List<SVMXC__SVMX_Event__c> svmxEvents) 
   {
        List<String> technicianIds = new List<String>();
        String  woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
        String  techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
        List<String> lstTechIdAllDayMultiDay = new List<String>();
        for(SVMXC__SVMX_Event__c svmxEvent : svmxEvents ){
            if(svmxEvent.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSVMXEvent ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                if(svmxEvent.SVMXC__Technician__c != null){
                    lstTechIdAllDayMultiDay.add(svmxEvent.SVMXC__Technician__c);
                }
                continue;
            }
            
            //To allow both workorder and non workorder events
            //if(svmxEvent.SVMXC__WhatId__c == null || (woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){  
            if(svmxEvent.SVMXC__WhatId__c == null || (svmxEvent.SVMXC__WhatId__c != null && techKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3))) || (svmxEvent.SVMXC__WhatId__c != null && woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){      
                if(svmxEvent.SVMXC__Technician__c != null){
                    technicianIds.add(svmxEvent.SVMXC__Technician__c);
                }
            }
        }
        
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSVMXEvent::technicianIds.size() : '+technicianIds.size());
        Map<Id,SVMXC__Service_Group_Members__c> techniciansMap = new Map<Id,SVMXC__Service_Group_Members__c>();
        if(technicianIds != null && technicianIds.size() > 0){
             techniciansMap = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id,SVMXC__Salesforce_User__c,SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Working_Hours__c, name, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey From SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__c != null AND Id in : technicianIds]);
        }

        for(SVMXC__SVMX_Event__c svmxEvnt : svmxEvents ){
            if(techniciansMap != null && techniciansMap.size() > 0){
                String strTechTerrTimeZone = techniciansMap.get(svmxEvnt.SVMXC__Technician__c).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSVMXEvent:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSVMXEvent:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvnt.SVMXC__StartDateTime__c, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvnt.SVMXC__EndDateTime__c, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSVMXEvent:intDays - ' + intDays);
                    //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSVMXEvent ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    if(svmxEvnt.SVMXC__Technician__c != null){
                        lstTechIdAllDayMultiDay.add(svmxEvnt.SVMXC__Technician__c);
                    }
                    continue;
                }
            }
        }     
        
        if(lstTechIdAllDayMultiDay != null && lstTechIdAllDayMultiDay.size() > 0){
            List<SVMXC__Service_Group_Members__c> lstTechAllDayMultiDay = new List<SVMXC__Service_Group_Members__c>();
            lstTechAllDayMultiDay = [Select Id,Name From SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__c != null AND Id in : lstTechIdAllDayMultiDay];
            List<String> lstWhatId = new List<String>();
            for(SVMXC__Service_Group_Members__c tech : lstTechAllDayMultiDay){
                lstWhatId.add(tech.Id+'_'+tech.Name);
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSVMXEvent::lstWhatId : '+lstWhatId +' , lstTechAllDayMultiDay.size() : '+lstTechAllDayMultiDay.size());
            if(lstWhatId != null && lstWhatId.size() > 0){
                allDayMultiDayEvntCallout(lstWhatId);
            }
        }

        return techniciansMap;
   }

   public static map<id,SVMXC__Service_Group_Members__c> getTechniciansSVMXEvent(List<SVMXC__SVMX_Event__c> oldSvmxEvents, List<SVMXC__SVMX_Event__c> newSvmxEvents) 
   {
        Set<String> technicianIds = new Set<String>();
        String  woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
        String  techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
        for(SVMXC__SVMX_Event__c svmxEvent : oldSvmxEvents ){
            //commenting the below code as this check is not required for the OldEvents
            /*if(svmxEvent.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSVMXEvent ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }*/
            //To allow both workorder and non workorder events
            //if(svmxEvent.SVMXC__WhatId__c == null || (woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){  
            if(svmxEvent.SVMXC__WhatId__c == null || (svmxEvent.SVMXC__WhatId__c != null && techKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3))) || (svmxEvent.SVMXC__WhatId__c != null && woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){       
                if(svmxEvent.SVMXC__Technician__c != null){
                    technicianIds.add(svmxEvent.SVMXC__Technician__c);
                }
            }
        }

        for(SVMXC__SVMX_Event__c svmxEvent : newSvmxEvents ){
            if(svmxEvent.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: getTechniciansSVMXEvent ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }
            //To allow both workorder and non workorder events
            //if(svmxEvent.SVMXC__WhatId__c == null || (woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){  
            if(svmxEvent.SVMXC__WhatId__c == null || (svmxEvent.SVMXC__WhatId__c != null && techKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3))) || (svmxEvent.SVMXC__WhatId__c != null && woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){     
                if(svmxEvent.SVMXC__Technician__c != null){
                    technicianIds.add(svmxEvent.SVMXC__Technician__c);
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::getTechniciansSVMXEvent::technicianIds.size() : '+technicianIds.size());
        Map<Id,SVMXC__Service_Group_Members__c> techniciansMap = new Map<Id,SVMXC__Service_Group_Members__c>();
        if(technicianIds != null && technicianIds.size() > 0)
             techniciansMap = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id,SVMXC__Salesforce_User__c,SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Working_Hours__c, name, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey From SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__c != null AND Id in : technicianIds]);

        return techniciansMap;
   }
    
    //Method to check whether the given Salesforce event object is Non WO event
    public static boolean isNonWOSFEvent(Event objEvent)
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
                        return true;
                }               
            } else  {
                    return true;
            }
            return false;           
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_EventTriggerHandler:isNonWOSFEvent() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;
        }
    }
    
    // Creates a map of ECO workorders i.e 
    // a) if the workorder has DP then checks if the dispatch method of the DP is 'Real Time Optimization'
    // b) If the workorder doesnt have DP but has territory then check if the territory is associated with any ECo jobs.
    public static Map<Id, SVMXC__Service_Order__c> checkForEcoWOs(list<String> listWOEventWhatIds, Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs){
        Map<Id, SVMXC__Service_Order__c> mapWoIdWoObj = new Map<Id, SVMXC__Service_Order__c>();
        mapWoIdWoObj.putAll([Select Id, Name, SVMXC__Locked_By_DC__c, SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c, SVMXC__Primary_Territory__c,SVMXC__Group_Member__c,SVMXC__Group_Member__r.SVMXC__Service_Territory__c from SVMXC__Service_Order__c where Id IN: listWOEventWhatIds]);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkForEcoWOs:: mapWoIdWoObj.size() : ' + mapWoIdWoObj.size());     
        list<String> listECOWOEventWhatIds = new List<String>();
        Map<Id,Id> mapWoIdTerrId = new Map<Id,Id>();
        //To check if the workorder/external wo is an ECO workorder
        Map<Id, SVMXC__Service_Order__c> mapECOWoIdWoObj = new Map<Id, SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c woObj : mapWoIdWoObj.values()){
            // if(woObj.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c != null && woObj.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c == 'Real Time Optimization'){
            //     mapECOWoIdWoObj.put(woObj.Id, woObj);//For the workorder events with workorder having DP
            // }else if(woObj.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c == null && woObj.SVMXC__Primary_Territory__c != null && mapTeritoryEcoJobs.containsKey(woObj.SVMXC__Primary_Territory__c)){
            //     mapECOWoIdWoObj.put(woObj.Id, woObj); //For the workorder events with workorder not having DP but workorder having territory
            // }
            String territoryId;
            if(woObj.SVMXC__Group_Member__c != null && woObj.SVMXC__Group_Member__r.SVMXC__Service_Territory__c != null){
                territoryId = woObj.SVMXC__Group_Member__r.SVMXC__Service_Territory__c;
            }else{
                territoryId = woObj.SVMXC__Primary_Territory__c;
            }        
            if(mapTeritoryEcoJobs.containsKey(territoryId)){
                mapECOWoIdWoObj.put(woObj.Id, woObj);
            }            
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew()::checkForEcoWOs:: mapECOWoIdWoObj : ' + mapECOWoIdWoObj); 
        return mapECOWoIdWoObj;
    }

    //Create a map of territories which are associated with the ECO jobs
    public static Map<Id,SVMXC__SVMX_Jobs__c> checkForEcoTerritory(map<id,SVMXC__Service_Group_Members__c> technicianMap){
        Set<Id> setTerritory = new Set<Id>();
        Map<Id, String> mapTechTerr = new Map<Id, String>(); 
        for(SVMXC__Service_Group_Members__c technician: technicianMap.values()){
            if(technician.SVMXC__Service_Territory__c != null)
                setTerritory.add(technician.SVMXC__Service_Territory__c);
        }   
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkForEcoTerritory()::checkForEcoTerritory:: setTerritory : ' + setTerritory);          
        //query the svmx jobs records for the territoryIds
        list<SVMXC__SVMX_Jobs__c> lstSVMXEcoJob = new list<SVMXC__SVMX_Jobs__c>();
        if(setTerritory != null && setTerritory.size() > 0){
            lstSVMXEcoJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c, SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c In :setTerritory and SVMXC__Type__c = 'ECO' and SVMXC__OptiMax_Message__c != 'IDLE'];
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkForEcoTerritory():: lstSVMXEcoJob.size() : ' + lstSVMXEcoJob.size());           
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs = new Map<Id,SVMXC__SVMX_Jobs__c>();
        for(SVMXC__SVMX_Jobs__c objEcoJob : lstSVMXEcoJob){
            mapTeritoryEcoJobs.put(objEcoJob.SVMXC__Territory__c, objEcoJob);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkForEcoTerritory():: mapTeritoryEcoJobs.size() : ' + mapTeritoryEcoJobs.size());  
        return mapTeritoryEcoJobs;
    }
    
    //Multi-resource and Multi-appointment
    //When someone assign one more technician to a workorder in the DC
    //Check if the event has any corresponding Optimizer transaction available, If no then allow to create a piller.
    public static List<Event> multiRsrcEcoSFCreatePillar(Map<Id, SVMXC__Service_Order__c> mapWoIdWoObj, map<id,SVMXC__Service_Group_Members__c> techniciansMap, Map<Id, List<Event>> mapWoIdListSFEvent){   
        List<Event> listSFvents =  [Select Id, WhatId, OwnerId, StartDateTime, EndDateTime from Event where WhatId In : mapWoIdWoObj.keySet()];
        map<String, List<Event>> mapWOIdSFEvnt = new map<String, list<Event>>();
        for(Event sfEvnt : listSFvents){
            list<Event> listSFEvnt = new list<Event>();
            if(mapWOIdSFEvnt.containsKey(sfEvnt.WhatId)){
                list<Event> tmpLstSFEvnt = mapWOIdSFEvnt.get(sfEvnt.WhatId);
                tmpLstSFEvnt.add(sfEvnt);
                mapWOIdSFEvnt.put(sfEvnt.WhatId,tmpLstSFEvnt);
            }else{
                listSFEvnt.add(sfEvnt);
                mapWOIdSFEvnt.put(sfEvnt.WhatId,listSFEvnt);
            }
        }
        List<Event> listSingleSFEvnts = new List<Event>();
        List<Event> listMultiSFEvnts = new List<Event>();
        if(mapWOIdSFEvnt != null && mapWOIdSFEvnt.size() > 0){
            for(String woId : mapWOIdSFEvnt.keySet()){
                if(mapWOIdSFEvnt.get(woId).size() == 1 && mapWoIdWoObj.get(woId).SVMXC__Locked_By_DC__c == true){
                    listSingleSFEvnts.add(mapWOIdSFEvnt.get(woId)[0]);
                }else{
                    listMultiSFEvnts.addAll(mapWOIdSFEvnt.get(woId));
                }
            }
        }
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd;
        if(listMultiSFEvnts != null && listMultiSFEvnts.size() > 0){ 
            //mapEventIdOptimizerRecrd = getEventIdAndOptimizerRcrd(listMultiSFEvnts,null);
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(techniciansMap, listMultiSFEvnts, null, true);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::multiSFPiller::mapEventIdOptimizerRecrd:'+mapEventIdOptimizerRecrd);
        }else if(listSingleSFEvnts != null && listSingleSFEvnts.size() > 0){
            //TODO: Need to handle external workorder event inserted from DC
            //TODO: Need to make pillar callout
            //mapEventIdOptimizerRecrd = getEventIdAndOptimizerRcrd(listSingleSFEvnts,null);
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(techniciansMap, listSingleSFEvnts, null, true);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::multiSFMXPiller:: The workorder has single event and corresponding workorder Locked By DC is true mapEventIdOptimizerRecrd.size(): '+mapEventIdOptimizerRecrd.size());
        }
        List<Event> newEventListForPillar = new List<Event>();
        if(mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.size() > 0){
            for(Event event : listMultiSFEvnts){
                if(!mapEventIdOptimizerRecrd.containsKey(event.id)){
                    newEventListForPillar.add(event); 
                }
            }
        }else{
            if(listMultiSFEvnts != null && listMultiSFEvnts.size() > 0){
                newEventListForPillar = listMultiSFEvnts;
            }else if(listSingleSFEvnts != null && listSingleSFEvnts.size() > 0){
                newEventListForPillar = listSingleSFEvnts;
            }
        }
        
       return newEventListForPillar;
    }

    //Multi-resource and Multi-appointment
    //When someone assign one more technician to a workorder in the DC
    //Check if the event has any corresponding Optimizer transaction available, If no then allow to create a piller.
    public static List<SVMXC__SVMX_Event__c> multiRsrcEcoSvmxCreatePillar(Map<Id, SVMXC__Service_Order__c> mapWoIdWoObj, map<id,SVMXC__Service_Group_Members__c> techniciansMap, Map<Id, List<SVMXC__SVMX_Event__c>> mapWoIdListSvmxEvent){   
        List<SVMXC__SVMX_Event__c> listSVMXEvents =  [Select Id, SVMXC__WhatId__c, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c In : mapWoIdWoObj.keySet()];
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : multiRsrcEcoSvmxCreatePillar : listSVMXEvents.size() : '+listSVMXEvents.size());
        map<String, List<SVMXC__SVMX_Event__c>> mapWOIdSvmxEvnt = new map<String, list<SVMXC__SVMX_Event__c>>();
        for(SVMXC__SVMX_Event__c svmxEvnt : listSVMXEvents){
            list<SVMXC__SVMX_Event__c> listSVMXEvnt = new list<SVMXC__SVMX_Event__c>();
            if(mapWOIdSvmxEvnt.containsKey(svmxEvnt.SVMXC__WhatId__c)){
                list<SVMXC__SVMX_Event__c> tmpLstSvmxEvnt = mapWOIdSvmxEvnt.get(svmxEvnt.SVMXC__WhatId__c);
                tmpLstSvmxEvnt.add(svmxEvnt);
                mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,tmpLstSvmxEvnt);
            }else{
                listSVMXEvnt.add(svmxEvnt);
                mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,listSVMXEvnt);
            }
        }
        List<SVMXC__SVMX_Event__c> listSingleSVMXEvnts = new List<SVMXC__SVMX_Event__c>();
        List<SVMXC__SVMX_Event__c> listMultiSVMXEvnts = new List<SVMXC__SVMX_Event__c>();
        if(mapWOIdSvmxEvnt != null && mapWOIdSvmxEvnt.size() > 0){
            for(String woId : mapWOIdSvmxEvnt.keySet()){
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::multiRsrcEcoSvmxCreatePillar::mapWoIdWoObj.get(woId).SVMXC__Locked_By_DC__c: '+mapWoIdWoObj.get(woId).SVMXC__Locked_By_DC__c);
                if(mapWOIdSvmxEvnt.get(woId).size() == 1 && mapWoIdWoObj.get(woId).SVMXC__Locked_By_DC__c == true){
                    listSingleSVMXEvnts.add(mapWOIdSvmxEvnt.get(woId)[0]);
                }else{
                    listMultiSVMXEvnts.addAll(mapWOIdSvmxEvnt.get(woId));
                }
            }
        }
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd;
        if(listMultiSVMXEvnts != null && listMultiSVMXEvnts.size() > 0){ 
            //mapEventIdOptimizerRecrd = getEventIdAndOptimizerRcrd(null,listMultiSVMXEvnts);
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(techniciansMap, null, listMultiSVMXEvnts, true);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::multiRsrcEcoSvmxCreatePillar::mapEventIdOptimizerRecrd:'+mapEventIdOptimizerRecrd);
        }else if(listSingleSVMXEvnts != null && listSingleSVMXEvnts.size() > 0){
            //TODO: Need to handle external workorder event inserted from DC
            //TODO: Need to make pillar callout
            //mapEventIdOptimizerRecrd = getEventIdAndOptimizerRcrd(null,listSingleSVMXEvnts);
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(techniciansMap, null, listSingleSVMXEvnts, true);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::multiRsrcEcoSvmxCreatePillar:: The workorder has single event and corresponding workorder Locked By DC is true mapEventIdOptimizerRecrd.size(): '+mapEventIdOptimizerRecrd.size());
        }
        List<SVMXC__SVMX_Event__c> newEventListForPillar = new List<SVMXC__SVMX_Event__c>();
        if(mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.size() > 0){
            for(SVMXC__SVMX_Event__c event : listMultiSVMXEvnts){
                if(!mapEventIdOptimizerRecrd.containsKey(event.id)){
                    newEventListForPillar.add(event); 
                }
            }
        }else{
            if(listMultiSVMXEvnts != null && listMultiSVMXEvnts.size() > 0){
                newEventListForPillar = listMultiSVMXEvnts;
            }else if(listSingleSVMXEvnts != null && listSingleSVMXEvnts.size() > 0){
                newEventListForPillar = listSingleSVMXEvnts;
            }
        }
                
        return newEventListForPillar;
    }

    //Multi-resource and Multi-appointment
    //Get optimizer objects related to the events 
    public static map<String,SVMXC__SVMX_Optimizer__c> getECOEventIdAndOptimizerRcrd(map<id,SVMXC__Service_Group_Members__c> techniciansMap, list<Event> sfEvents, List<SVMXC__SVMX_Event__c> svmxEvents, Boolean insertContext){ 
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : getECOEventIdAndOptimizerRcrd : insertContext : '+insertContext);
        Map<Id,SVMXC__Service_Group_Members__c> mapOwnerIDTechId = new Map<Id,SVMXC__Service_Group_Members__c>();
        map<String,SVMXC__SVMX_Optimizer__c> mapEvtIdOptimizer = new map<String,SVMXC__SVMX_Optimizer__c>(); 
        //create ownerId map
        for(SVMXC__Service_Group_Members__c tech : techniciansMap.values()){
            if(tech.SVMXC__Salesforce_User__c != null)
                mapOwnerIDTechId.put(tech.SVMXC__Salesforce_User__c, tech);}        
        SVMXC__Service_Group_Members__c technician;
        list<String> lstEventID= new list<String> (); 
        if(sfEvents != null && sfEvents.size() > 0){
            for(Event objEvent : sfEvents){
                technician = mapOwnerIDTechId.get(objEvent.OwnerId);
                if(null != technician){
                    lstEventID.add(objEvent.id+'_'+technician.name);}
            }
        }else if (svmxEvents != null && svmxEvents.size() > 0){
            for(SVMXC__SVMX_Event__c objEvent : svmxEvents){
                technician = techniciansMap.get(objEvent.SVMXC__Technician__c);
                if(null != technician){
                    lstEventID.add(objEvent.id+'_'+technician.name);}
            }
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : getECOEventIdAndOptimizerRcrd : lstEventID.size() : '+lstEventID.size());  
        list<SVMXC__SVMX_Optimizer__c> lstExistingOptimizer = new list<SVMXC__SVMX_Optimizer__c> ();  
        if(lstEventID != null && lstEventID.size() > 0){
            lstExistingOptimizer = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__Optimizer_External_ID__c,SVMXC__WhatId__c,SVMXC__Optimizer_Status__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstEventID];
        }    
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : getECOEventIdAndOptimizerRcrd :: Optimizer Objects lstExistingOptimizer.size() : '+lstExistingOptimizer);
        String optEvntId;
        for(SVMXC__SVMX_Optimizer__c objOptimizer : lstExistingOptimizer){
            //If any optimizer record is already available (even if it's status is OPT_PENDING) we should not create one more duplicate record and callout should not happen with it.  
            //So incase of insert context need to skip the 'Continue' condition and need to add to the mapEvtIdOptimizer to exclude those events in future callout. 
            
            if(('OPT_PENDING'.equalsIgnoreCase(objOptimizer.SVMXC__Optimizer_Status__c) || 'OPT_QUEUED'.equalsIgnoreCase(objOptimizer.SVMXC__Optimizer_Status__c)) && !(insertContext)){
                continue;
            }
            if(null != objOptimizer.SVMXC__WhatId__c || objOptimizer.SVMXC__WhatId__c !=''){
                optEvntId = objOptimizer.SVMXC__WhatId__c.split('_')[0];
            }
            mapEvtIdOptimizer.put(optEvntId,objOptimizer);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler :getECOEventIdAndOptimizerRcrd :: mapEvtIdOptimizer.size() '+mapEvtIdOptimizer.size());
        return mapEvtIdOptimizer;
    }

    //It returns a complete list of ECO SF events which associated with ECO jobs.
    public static List<Event> ecoSFEventsInsert(List<Event> events, map<id,SVMXC__Service_Group_Members__c> technicianMap, Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs){
        list<String> listWOEventWhatIds = new List<String>();
        List<Event> lstNonWOEvents = new List<Event>();
        Map<Id, List<Event>> mapWoIdListSFEvent= new Map<Id, List<Event>>();
        list<Event> listECOWOEvents = new List<Event>();
        for(Event sfEvent : events){
            if(technicianMap.get(sfEvent.ownerId) != null) {
                if(sfEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: ecoSFEventsInsert ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                String strTechTerrTimeZone = technicianMap.get(sfEvent.ownerId).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(sfEvent.StartDateTime, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(sfEvent.EndDateTime, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert:intDays - ' + intDays);
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: ecoSFEventsInsert ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert: sfEvent.WhatId - ' + sfEvent.WhatId);
                if(sfEvent.WhatId != null){
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                    String techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert: techKeyPrefix - ' + techKeyPrefix);
                    String objectPrefix = String.valueOf(sfEvent.WhatId).substring(0,3);                
                    if(woKeyPrefix.equals(objectPrefix)){
                        listWOEventWhatIds.add(sfEvent.WhatId);
                        list<Event> listSFEvnt = new list<Event>();
                        if(mapWoIdListSFEvent.containsKey(sfEvent.WhatId)){
                            list<Event> tmpLstSFEvnt = mapWoIdListSFEvent.get(sfEvent.WhatId);
                            tmpLstSFEvnt.add(sfEvent);
                            mapWoIdListSFEvent.put(sfEvent.WhatId,tmpLstSFEvnt);
                        }else{
                            listSFEvnt.add(sfEvent);
                            mapWoIdListSFEvent.put(sfEvent.WhatId,listSFEvnt);}
                    }else if(techKeyPrefix.equals(objectPrefix)){
                        lstNonWOEvents.add(sfEvent);
                    }
                }else{
                    lstNonWOEvents.add(sfEvent);
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert: lstNonWOEvents - ' + lstNonWOEvents);
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::ecoSFEventsInsert :: technicianMap: '+technicianMap);
        Map<Id, SVMXC__Service_Order__c> mapECOWoIdWoObj = new Map<Id, SVMXC__Service_Order__c>();
        if(listWOEventWhatIds != null && listWOEventWhatIds.size() > 0 && mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0){
           mapECOWoIdWoObj = checkForEcoWOs(listWOEventWhatIds, mapTeritoryEcoJobs);
        }   
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSFEventsInsert :: mapECOWoIdWoObj.size(): '+mapECOWoIdWoObj.size());
        list<Event> listCompleteEcoSFEvents = new List<Event>();
        List<Event> finalListWOEvent = new List<Event>();
        if(mapECOWoIdWoObj != null && mapECOWoIdWoObj.size() > 0){
            finalListWOEvent = multiRsrcEcoSFCreatePillar(mapECOWoIdWoObj, technicianMap, mapWoIdListSFEvent);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::ecoSFEventsInsert :: finalListWOEvent: '+finalListWOEvent);
            if(finalListWOEvent != null && finalListWOEvent.size() > 0){
                listCompleteEcoSFEvents.addAll(finalListWOEvent);}   
        }
        if(lstNonWOEvents != null && lstNonWOEvents.size() > 0){
            List<Event> lstEcoNonWOEvents = new List<Event>();
            SVMXC__Service_Group_Members__c techObj = null;
            for(Event objEvent: lstNonWOEvents){
                techObj = technicianMap.get(objEvent.ownerId);
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew:: ecoSFEventsInsert :: techObj: '+techObj);
                //Check if the technician of the Non workorder event is associated with the ECO jobs.
                if(techObj != null && techObj.SVMXC__Service_Territory__c != null && mapTeritoryEcoJobs.containsKey(techObj.SVMXC__Service_Territory__c)){
                    lstEcoNonWOEvents.add(objEvent);}
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew:: ecoSFEventsInsert :: lstEcoNonWOEvents.size() :: '+lstEcoNonWOEvents.size());
            //Make a complete list of events both workorder and non workorder events 
            if(lstEcoNonWOEvents != null && lstEcoNonWOEvents.size() > 0){
                listCompleteEcoSFEvents.addAll(lstEcoNonWOEvents);
            }else{
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew:: ecoSFEventsInsert :: Non Workorder events associated with the ECO jobs are not available hence skipping the Non workorder event creation');
            }
        } 
       return listCompleteEcoSFEvents;
    }

    //It returns a complete list of ECO SVMX events which associated with ECO jobs.
    public static List<SVMXC__SVMX_Event__c> ecoSVMXEventsInsert(List<SVMXC__SVMX_Event__c> svmxEvents, map<id,SVMXC__Service_Group_Members__c> technicianMap, Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs){
        list<String> listWOEventWhatIds = new List<String>();
        List<SVMXC__SVMX_Event__c> lstNonWOEvents = new List<SVMXC__SVMX_Event__c>();
        Map<Id, List<SVMXC__SVMX_Event__c>> mapWoIdListsvmxEvnt= new Map<Id, List<SVMXC__SVMX_Event__c>>();
        list<Event> listECOWOEvents = new List<Event>();
        for(SVMXC__SVMX_Event__c svmxEvnt : svmxEvents){
            if(technicianMap.get(svmxEvnt.SVMXC__Technician__c) != null) {
                if(svmxEvnt.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: ecosvmxEvntsInsert ::This is all day event so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                String strTechTerrTimeZone = technicianMap.get(svmxEvnt.SVMXC__Technician__c).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                if(String.isEmpty(strTechTerrTimeZone)) {
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSVMXEventsInsert:territory does not have businessHours. Hence skipping it');
                    continue;
                }
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSVMXEventsInsert:strTechTerrTimeZone - ' + strTechTerrTimeZone);
                DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvnt.SVMXC__StartDateTime__c, 'GMT', strTechTerrTimeZone);
                DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvnt.SVMXC__EndDateTime__c, 'GMT', strTechTerrTimeZone);
                integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
                if(intDays > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::ecoSVMXEventsInsert:intDays - ' + intDays);
                    WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler:: ecosvmxEvntsInsert ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                    continue;
                }
                if(svmxEvnt.SVMXC__WhatId__c != null){
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                    String techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
                    String objectPrefix = String.valueOf(svmxEvnt.SVMXC__WhatId__c).substring(0,3);                
                    if(woKeyPrefix.equals(objectPrefix)){
                        listWOEventWhatIds.add(svmxEvnt.SVMXC__WhatId__c);
                        list<SVMXC__SVMX_Event__c> listSvmxEvnt = new list<SVMXC__SVMX_Event__c>();
                        if(mapWoIdListsvmxEvnt.containsKey(svmxEvnt.SVMXC__WhatId__c)){
                            list<SVMXC__SVMX_Event__c> tmpLstSVMXFEvnt = mapWoIdListsvmxEvnt.get(svmxEvnt.SVMXC__WhatId__c);
                            tmpLstSVMXFEvnt.add(svmxEvnt);
                            mapWoIdListsvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,tmpLstSVMXFEvnt);
                        }else{
                            listSvmxEvnt.add(svmxEvnt);
                            mapWoIdListsvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,listSvmxEvnt);}
                    }else if(techKeyPrefix.equals(objectPrefix)){
                        lstNonWOEvents.add(svmxEvnt);
                    }
                }else{
                    lstNonWOEvents.add(svmxEvnt);
                }
            }
        }
        
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecosvmxEvntsInsert :: lstNonWOEvents.size() : '+lstNonWOEvents.size());
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecosvmxEvntsInsert :: technicianMap: '+technicianMap);
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecosvmxEvntsInsert :: mapWoIdListsvmxEvnt: '+mapWoIdListsvmxEvnt);
        Map<Id, SVMXC__Service_Order__c> mapECOWoIdWoObj = new Map<Id, SVMXC__Service_Order__c>();
        if(listWOEventWhatIds != null && listWOEventWhatIds.size() > 0 && mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0){
            mapECOWoIdWoObj = checkForEcoWOs(listWOEventWhatIds, mapTeritoryEcoJobs);
        }   
        list<SVMXC__SVMX_Event__c> listCompleteEcoSvmxEvnts = new List<SVMXC__SVMX_Event__c>();
        List<SVMXC__SVMX_Event__c> finalListWOEvent = new List<SVMXC__SVMX_Event__c>();
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecosvmxEvntsInsert :: mapECOWoIdWoObj.size() : '+mapECOWoIdWoObj.size());
        if(mapECOWoIdWoObj != null && mapECOWoIdWoObj.size() > 0){
            finalListWOEvent = multiRsrcEcoSvmxCreatePillar(mapECOWoIdWoObj, technicianMap, mapWoIdListsvmxEvnt);
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::ecosvmxEvntsInsert :: finalListWOEvent: '+finalListWOEvent);
            if(finalListWOEvent != null && finalListWOEvent.size() > 0){
                listCompleteEcoSvmxEvnts.addAll(finalListWOEvent);}   
        }
        if(lstNonWOEvents != null && lstNonWOEvents.size() > 0){
            List<SVMXC__SVMX_Event__c> lstEcoNonWOEvents = new List<SVMXC__SVMX_Event__c>();
            SVMXC__Service_Group_Members__c techObj = null;
            for(SVMXC__SVMX_Event__c objEvent: lstNonWOEvents){
                techObj = technicianMap.get(objEvent.SVMXC__Technician__c);
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew:: ecosvmxEvntsInsert :: techObj: '+techObj);
                //Check if the technician of the Non workorder event is associated with the ECO jobs.
                if(techObj != null && techObj.SVMXC__Service_Territory__c != null && mapTeritoryEcoJobs.containsKey(techObj.SVMXC__Service_Territory__c)){
                    lstEcoNonWOEvents.add(objEvent);}
            }
            WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew:: ecosvmxEvntsInsert :: lstEcoNonWOEvents.size() :: '+lstEcoNonWOEvents.size());
            //Make a complete list of events both workorder and non workorder events 
            if(lstEcoNonWOEvents != null && lstEcoNonWOEvents.size() > 0){
                listCompleteEcoSvmxEvnts.addAll(lstEcoNonWOEvents);
            }else{
                //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew:: ecosvmxEvntsInsert :: Non Workorder events associated with the ECO jobs are not available hence skipping the Non workorder event creation');
            }
        } 
        return listCompleteEcoSvmxEvnts;
    }

    //Check if the workorder is an ECO workorder
    public static List<String> checkForEcoWOIds(List<SVMXC__Service_Order__c> lstWO){
        List<String> lstTerritory = new List<String>();
        for(SVMXC__Service_Order__c woObj : lstWO){
            lstTerritory.add(woObj.SVMXC__Primary_Territory__c);
        }
        list<SVMXC__SVMX_Jobs__c> lstSVMXEcoJob = new list<SVMXC__SVMX_Jobs__c>();
        if(lstTerritory != null && lstTerritory.size() > 0){
            lstSVMXEcoJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c In :lstTerritory and SVMXC__Type__c = 'ECO' and SVMXC__OptiMax_Message__c != 'IDLE'];
        }
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs = new Map<Id,SVMXC__SVMX_Jobs__c>();
        Set<String> setEcoTrritory = new Set<String>();
        for(SVMXC__SVMX_Jobs__c objEcoJob : lstSVMXEcoJob){
            setEcoTrritory.add(objEcoJob.SVMXC__Territory__c);
        }
        //To check if the workorder/external wo is an ECO workorder
        Map<Id, SVMXC__Service_Order__c> mapECOWoIdWoObj = new Map<Id, SVMXC__Service_Order__c>();
        List<String> listEcoWOIds = new List<String>();
        for(SVMXC__Service_Order__c woObj : lstWO){
            if(woObj.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c != null && woObj.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c == 'Real Time Optimization'){
                listEcoWOIds.add(woObj.Id);//For the workorder events with workorder having DP
            }else if(woObj.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c == null && woObj.SVMXC__Primary_Territory__c != null && setEcoTrritory.contains(woObj.SVMXC__Primary_Territory__c)){
                listEcoWOIds.add(woObj.Id); //For the workorder events with workorder not having DP but workorder having territory
            }
        }
        return listEcoWOIds;
    }

    //Check if the svmx event has any corresponding Optimizer transaction record available, If no then allow to create a piller.
    public static List<SVMXC__SVMX_Event__c> singleEvntListSvmxCreatePillar(List<SVMXC__SVMX_Event__c> listSingleSVMXEvnts, map<id,SVMXC__Service_Group_Members__c> technicianMap){   
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd;
        if(listSingleSVMXEvnts != null && listSingleSVMXEvnts.size() > 0){
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(technicianMap, null, listSingleSVMXEvnts, true);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::singleEvntListSvmxCreatePillar:: The workorder has single event and corresponding workorder Locked By DC is true mapEventIdOptimizerRecrd.size(): '+mapEventIdOptimizerRecrd.size());
        }
        List<SVMXC__SVMX_Event__c> newEventListForPillar = new List<SVMXC__SVMX_Event__c>();
        if(mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.size() > 0){
            for(SVMXC__SVMX_Event__c event : listSingleSVMXEvnts){
                if(!mapEventIdOptimizerRecrd.containsKey(event.id)){
                    newEventListForPillar.add(event);}
            }
        }else{
            if(listSingleSVMXEvnts != null && listSingleSVMXEvnts.size() > 0){
                newEventListForPillar = listSingleSVMXEvnts;}
        }
        return newEventListForPillar;
    }

    //Check if the svmx event has any corresponding Optimizer transaction record available, If no then allow to create a piller.
    public static List<Event> singleEvntListSFCreatePillar(List<Event> listSingleSFEvnts, map<id,SVMXC__Service_Group_Members__c> technicianMap){   
        Map<String,SVMXC__SVMX_Optimizer__c> mapEventIdOptimizerRecrd;
        if(listSingleSFEvnts != null && listSingleSFEvnts.size() > 0){
            mapEventIdOptimizerRecrd = getECOEventIdAndOptimizerRcrd(technicianMap, listSingleSFEvnts, null, true);
            //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::singleEvntListSFCreatePillar:: The workorder has single event and corresponding workorder Locked By DC is true mapEventIdOptimizerRecrd.size(): '+mapEventIdOptimizerRecrd.size());
        }
        List<Event> newEventListForPillar = new List<Event>();
        if(mapEventIdOptimizerRecrd != null && mapEventIdOptimizerRecrd.size() > 0){
            for(Event event : listSingleSFEvnts){
                if(!mapEventIdOptimizerRecrd.containsKey(event.id)){
                    newEventListForPillar.add(event);}
            }
        }else{
            if(listSingleSFEvnts != null && listSingleSFEvnts.size() > 0){
                newEventListForPillar = listSingleSFEvnts;}
        }
        return newEventListForPillar;
    }

    //Returns map of worokrderId and list of SVMX events
    public static map<String, List<SVMXC__SVMX_Event__c>> checkSingleOrMultiSVMXEvents(List<String> listWOIds, String strTechTerrTimeZone){
        map<String, List<SVMXC__SVMX_Event__c>> mapWOIdSvmxEvnt = new map<String, list<SVMXC__SVMX_Event__c>>();
        List<SVMXC__SVMX_Event__c> listSVMXEvents =  [Select Id, SVMXC__WhatId__c, SVMXC__Technician__c, SVMXC__IsAllDayEvent__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c In : listWOIds];
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler: checkSingleOrMultiSVMXEvents : listSVMXEvents : ' + listSVMXEvents);   
        for(SVMXC__SVMX_Event__c svmxEvnt : listSVMXEvents){
            if(svmxEvnt.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkSingleOrMultiSVMXEvents ::This is full day event so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }
            DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvnt.SVMXC__StartDateTime__c, 'GMT', strTechTerrTimeZone);
            DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(svmxEvnt.SVMXC__EndDateTime__c, 'GMT', strTechTerrTimeZone);
            integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());            
            if(intDays > 0){
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkSingleOrMultiSVMXEvents ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }
            list<SVMXC__SVMX_Event__c> listSVMXEvnt = new list<SVMXC__SVMX_Event__c>();
            if(mapWOIdSvmxEvnt.containsKey(svmxEvnt.SVMXC__WhatId__c)){
                list<SVMXC__SVMX_Event__c> tmpLstSvmxEvnt = mapWOIdSvmxEvnt.get(svmxEvnt.SVMXC__WhatId__c);
                tmpLstSvmxEvnt.add(svmxEvnt);
                mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,tmpLstSvmxEvnt);
            }else{
                listSVMXEvnt.add(svmxEvnt);
                mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,listSVMXEvnt);
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler: checkSingleOrMultiSVMXEvents : mapWOIdSvmxEvnt.size() : ' + mapWOIdSvmxEvnt.size());     
        return mapWOIdSvmxEvnt;
    }   
    //Returns map of worokrderId and list of SF events
    public static map<String, List<Event>> checkSingleOrMultiSFEvents(List<String> listWOIds, String strTechTerrTimeZone){
        map<String, List<Event>> mapWOIdSFEvnt = new map<String, list<Event>>();
        List<Event> listSFEvents =  [select Id, WhatId, IsAllDayEvent, ownerId, StartDateTime, EndDateTime from Event where WhatId In : listWOIds];
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler: checkSingleOrMultiSFEvents : listSFEvents : ' + listSFEvents); 
        for(Event sfEvent : listSFEvents){
            if(sfEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkSingleOrMultiSFEvents ::This is full day event so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }
            DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(sfEvent.StartDateTime, 'GMT', strTechTerrTimeZone);
            DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(sfEvent.EndDateTime, 'GMT', strTechTerrTimeZone);
            integer intDays =  startDateTimeTerrTZ.DateGMT().daysBetween(endDateTimeTerrTZ.DateGMT());
            if(intDays > 0){
                WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::checkSingleOrMultiSFEvents ::This event span over more than 1 day so skipping callout. Technician work hours needs to be adjusted:');
                continue;
            }

            list<Event> listSFEvnt = new list<Event>();
            if(mapWOIdSFEvnt.containsKey(sfEvent.WhatId)){
                list<Event> tmpLstSFEvnt = mapWOIdSFEvnt.get(sfEvent.WhatId);
                tmpLstSFEvnt.add(sfEvent);
                mapWOIdSFEvnt.put(sfEvent.WhatId,tmpLstSFEvnt);
            }else{
                listSFEvnt.add(sfEvent);
                mapWOIdSFEvnt.put(sfEvent.WhatId,listSFEvnt);
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler: checkSingleOrMultiSFEvents : mapWOIdSFEvnt.size() : ' + mapWOIdSFEvnt.size());       
        return mapWOIdSFEvnt;
    } 
    // Check for external workorders i.e if the workorder doesnt have DP but has Territory.
    public static Set<String> checkForExternalWOs(list<String> listWOEventWhatIds, Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs){
        List<SVMXC__Service_Order__c> listWoObj = new List<SVMXC__Service_Order__c>();
        if(listWOEventWhatIds != null && listWOEventWhatIds.size() > 0)
            listWoObj = [Select Id, Name, SVMXC__Locked_By_DC__c, SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Method__c, SVMXC__Primary_Territory__c,SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Service_Territory__c from SVMXC__Service_Order__c where Id IN: listWOEventWhatIds];
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew()::checkForExternalWOs:: listWoObj : ' + listWoObj);     
        Set<String> setExternalWOIds = new Set<String>();
        for(SVMXC__Service_Order__c woObj : listWoObj){
            Id territoryId;
            if(woObj.SVMXC__Group_Member__c != null && woObj.SVMXC__Group_Member__r.SVMXC__Service_Territory__c != null ){
                territoryId = woObj.SVMXC__Group_Member__r.SVMXC__Service_Territory__c;
            }else{
                territoryId = woObj.SVMXC__Primary_Territory__c;
            }
            if(territoryId != null && mapTeritoryEcoJobs.containsKey(territoryId)){
                setExternalWOIds.add(woObj.Id); //For the forcefix workorders.
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventUpdateNew()::checkForExternalWOs:: setExternalWOIds.size() : ' + setExternalWOIds.size()); 
        return setExternalWOIds;
    }      

    public static boolean isSkippedSVMXEvnt(SVMXC__SVMX_Jobs__c ecoJob, SVMXC__SVMX_Event__c svmxEvent, Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess, Map<String, BusinessHours> mapOfIdBussHr)
    {
        BusinessHours horizonBH =  new BusinessHours();
        if(mapOfIdBussHr != null && ecoJob.SVMXC__Territory__c != null && ecoJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c != null){
            horizonBH = mapOfIdBussHr.get(ecoJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c);
        }
        List<DateTime> lstHorizonStartAndEndDateTime;
        if(mapOfIdDispatchProcess != null && ecoJob.SVMXC__SVMX_Process__c != null && horizonBH != null){
            lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(mapOfIdDispatchProcess.get(ecoJob.SVMXC__SVMX_Process__c), horizonBH);
        }
    
        DateTime dtmSchedulingHorizonStartDateTime;
        DateTime dtmSchedulingHorizonEndDateTime;
        if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
            dtmSchedulingHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
            dtmSchedulingHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::isSkippedSVMXEvnt: dtmSchedulingHorizonStartDateTime : '+dtmSchedulingHorizonStartDateTime + ' , dtmSchedulingHorizonEndDateTime : '+dtmSchedulingHorizonEndDateTime);
        Boolean isEventSkipped = WSCH_ECO_EventTriggerHandler.checkEventForSLA(svmxEvent.SVMXC__StartDateTime__c, svmxEvent.SVMXC__EndDateTime__c, dtmSchedulingHorizonStartDateTime, dtmSchedulingHorizonEndDateTime, horizonBH.timeZoneSidKey);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSVMXECOEventInsertNew::isSkippedSVMXEvnt: isEventSkipped: '+isEventSkipped);
        return isEventSkipped;
    }

    public static boolean isSkippedSFEvnt(SVMXC__SVMX_Jobs__c ecoJob, Event sfEvent, Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess, Map<String, BusinessHours> mapOfIdBussHr)
    {
        BusinessHours horizonBH =  new BusinessHours();
        if(mapOfIdBussHr != null && ecoJob.SVMXC__Territory__c != null && ecoJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c != null){
            horizonBH = mapOfIdBussHr.get(ecoJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c);
        }
        List<DateTime> lstHorizonStartAndEndDateTime;
        if(mapOfIdDispatchProcess != null && ecoJob.SVMXC__SVMX_Process__c != null && horizonBH != null){
            lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(mapOfIdDispatchProcess.get(ecoJob.SVMXC__SVMX_Process__c), horizonBH);
        }
    
        DateTime dtmSchedulingHorizonStartDateTime;
        DateTime dtmSchedulingHorizonEndDateTime;
        if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
            dtmSchedulingHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
            dtmSchedulingHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
        }
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::isSkippedSFEvnt: dtmSchedulingHorizonStartDateTime : '+dtmSchedulingHorizonStartDateTime + ' , dtmSchedulingHorizonEndDateTime : '+dtmSchedulingHorizonEndDateTime);
        Boolean isEventSkipped = WSCH_ECO_EventTriggerHandler.checkEventForSLA(sfEvent.StartDateTime, sfEvent.EndDatetime, dtmSchedulingHorizonStartDateTime, dtmSchedulingHorizonEndDateTime, horizonBH.timeZoneSidKey);
        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::handleSFECOEventInsertNew::isSkippedSFEvnt: isEventSkipped: '+isEventSkipped);
        return isEventSkipped;
    }

    public static Map<String, BusinessHours> getBusinessHour(map<id,SVMXC__Service_Group_Members__c> technicianMap, Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs)
    {
        List<String> lstOfTerrBHIds = new List<String>();
        if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0){
            for(SVMXC__SVMX_Jobs__c terJob : mapTeritoryEcoJobs.values()){
            lstOfTerrBHIds.add(terJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c);
            }
        }
        List<String> lstOfTechBHIds = new List<String>();
        if(technicianMap != null && technicianMap.size() > 0){
            for(SVMXC__Service_Group_Members__c techObj : technicianMap.values()){
                lstOfTechBHIds.add(techObj.SVMXC__Working_Hours__c);
            }
        }
        List<String> lstOfTechAndTerrBHIds = new List<String>();
        lstOfTechAndTerrBHIds.addAll(lstOfTechBHIds);
        lstOfTechAndTerrBHIds.addAll(lstOfTerrBHIds);

        List<BusinessHours> lstOfBh = new List<BusinessHours>();
        if(lstOfTechAndTerrBHIds != null && lstOfTechAndTerrBHIds.size() > 0){
            lstOfBh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                                WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, 
                                SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE AND 
                                Id in: lstOfTechAndTerrBHIds ];
        }                    
        
        //Create a map of BHid and BusinessHours
        Map<String, BusinessHours> mapOfIdBussHr = new Map<String, BusinessHours>();
        for(BusinessHours eachBH : lstOfBh) {
            mapOfIdBussHr.put(eachBH.Id, eachBH);           
        }
        return mapOfIdBussHr;
    }

    public static Map<String, SVMXC__ServiceMax_Processes__c> getDispatchProcess(Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs)
    {
         Map<String,String> mapOfTeritoryAndProcess = new  Map<String,String>();
         if(mapTeritoryEcoJobs != null && mapTeritoryEcoJobs.size() > 0){
            for(SVMXC__SVMX_Jobs__c terJob : mapTeritoryEcoJobs.values()){
                mapOfTeritoryAndProcess.put(terJob.SVMXC__Territory__c,terJob.SVMXC__SVMX_Process__c);
            }
         }
         List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = new List<SVMXC__ServiceMax_Processes__c>();
         if(mapOfTeritoryAndProcess != null && mapOfTeritoryAndProcess.size() > 0 ) {
             List<String> dispatchProcessIdsList =  new List<String>(mapOfTeritoryAndProcess.values());
             lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c from SVMXC__ServiceMax_Processes__c 
                                                                 where RecordType.Name = 'Dispatch Process' AND Id in:mapOfTeritoryAndProcess.values()];
         }
         Map<String, SVMXC__ServiceMax_Processes__c> mapOfIdDispatchProcess = new Map<String, SVMXC__ServiceMax_Processes__c>();
         for(SVMXC__ServiceMax_Processes__c eachDp : lstOfDPProcessObj) {
             mapOfIdDispatchProcess.put(eachDp.Id, eachDp);
         }
         return mapOfIdDispatchProcess;
     }

     public static void createMaxQTrans(Map<String,String> mapOptimizerIdToken){
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
        try{
            for (String optimizerId : mapOptimizerIdToken.keySet()) {
                SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                optimizer.SVMXC__WhatId__c = optimizerId;                   
                optimizer.SVMXC__WhatType__c = 'ECO_EVENT';
                optimizer.SVMXC__Optimizer_Change_Token__c = mapOptimizerIdToken.get(optimizerId);
                optimizer.SVMXC__Optimizer_Status__c = 'BATCH_QUEUED';
                optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
                lstSVMXOptimizer.add(optimizer);
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXOptimizer, COMM_SecurityUtils.Access.Upsertable)){
                Database.upsert(lstSVMXOptimizer);
            }
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_EventTriggerHandler:createMaxQTrans() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        
    }     

    //When there is an AllDay Or Multiday Event created Callout should happen to update in the server side 
    public static void allDayMultiDayEvntCallout(List<String> lstWhatId){
        list<SVMXC__SVMX_Optimizer__c> lstOptimizerRcrdForAllDayMultiDayEvntTech = new list<SVMXC__SVMX_Optimizer__c> ();  
        if(lstWhatId != null && lstWhatId.size() > 0){
            lstOptimizerRcrdForAllDayMultiDayEvntTech = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__Optimizer_External_ID__c,SVMXC__WhatId__c,SVMXC__Optimizer_Status__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c = 'TECHNICIAN' AND SVMXC__WhatId__c in: lstWhatId];
        }
        List<ID> optimizerIds = new List<ID>();
        for(SVMXC__SVMX_Optimizer__c optimizer : lstOptimizerRcrdForAllDayMultiDayEvntTech){
            optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
            optimizer.SVMXC__Optimizer_Status__c =WSCH_ECO_Constants.STATUS_OPT_PENDING;
            optimizerIds.add(optimizer.ID);
        }
        update lstOptimizerRcrdForAllDayMultiDayEvntTech;

        WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler::allDayMultiDayEvntCallout:: optimizerIds: '+optimizerIds);
        if(optimizerIds != null && optimizerIds.size() > 0){
            WSCH_TechnicianTriggerHandler.manageTechnicians(optimizerIds);
        }
    }


}