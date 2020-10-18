public with sharing class WSCH_LTP_SchedulingService_Handler {

    public class SVMXException extends Exception{}

    public static String strSfEventKeyPrefix;
    //public static String strSvmxEventKeyPrefix;
    public static String strTechKeyPrefix;


    public static boolean processRoutes(List<WSCH_LTP_Scheduling_Stubs.Route_WP> routes){
        // Variable definitions
        Map<String, String> mapTechIdSFUserId = new Map<String, String>();
        Map<String, String> mapTechIdServTeamId = new Map<String, String>();
        Map<String, Boolean> mapTechIdIsSchedulingEnabled = new Map<String, Boolean>();
        Map<String, double> mapWOTechIdLat = new Map<String, double>();
        Map<String, double> mapWOTechIdLong = new Map<String, double>();
        Map<String, double> mapWrkOrdIdServDuration = new Map<String, double>();
        Map<String, SVMXC__Service_Order__c> mapScheduledWO = new Map<String, SVMXC__Service_Order__c>();
        Map<String, String> mapTechEmail = new Map<String, String>();
        Map<String, String> mapTeamEmail = new Map<String, String>();
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        Map<String, String> mapTechTimeZone = new Map<String, String>();

        set<String> setSFEventsToBeDeleted = new set<String>();
        set<String> setSvmxEventsToBeDeleted = new set<String>();
        //this is for identify external work order events
        set<String> setNonWOSFEvents = new set<String>();
        set<String> setNonWOSvmxEvents = new set<String>();
                
        set<String> setScheduledWOs = new set<String>();
        set<String> setScheduledTechs = new set<String>();
        set<string> setExternalWOs = new set<string>();            
        

        List<Event> lstSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSvmxEvents = new List<SVMXC__SVMX_Event__c>();
        List<SVMXC__Service_Order__c> lstOptiMaxOPWrkOrds = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Group_Members__c> lstOptiMaxOPTechs= new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Order__c> lstWOToBeUpdated = new List<SVMXC__Service_Order__c>();
            
        Event objSFEvent;
        SVMXC__SVMX_Event__c objSvmxEvent;
        SVMXC__Service_Order__c objWorkOrder;
        BusinessHours objDefTerritoryBH;
        Map<String,String> mapWOIdNAddress = new  Map<String,String>();
        set<string> setUpdatedWorkOrder = new set<string>();
        String TAG007 = System.Label.OMAX002_TAG007; // Work Order
        
        String strDeletedWorkOrderDetails = 'Work Order ID , Technician Id , Arrival Time , Departure Time , Driving Time\n';
        Integer intMissingWorkOrderCount = 0;
        
        // Get the unique 3 character key prefix for Technician object
        // Get the unique 3 character key prefix for SF Event object - Used to check if Work Order event is SF event or SVMX Event
        Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
        strSfEventKeyPrefix = descEventObj.getKeyPrefix();
        Schema.Describesobjectresult descTechnicianObj = descAllObjs.get('SVMXC__Service_Group_Members__c').getDescribe();
        strTechKeyPrefix = descTechnicianObj.getKeyPrefix();

        // Retrieve all global, group, and user level settings for OptiMax Engine submodule
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX001_SET011');
        lstSettings.add('OMAX002_SET003');
        lstSettings.add('OMAX002_SET004');
        lstSettings.add('OMAX003_SET004');
        lstSettings.add('OMAX003_SET018');
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('GLOB001_GBL025');
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);

    
        for(WSCH_LTP_Scheduling_Stubs.Route_WP route : routes)
        {
            if(route.resourceId.contains('_'))
            {
                List<String> lstTechIdOriginal = route.resourceId.split('_');
                route.resourceId = lstTechIdOriginal[0];
            }
            setScheduledTechs.add(route.resourceId);

            List<WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP> scheduledElements = route.scheduledElements;
            for(WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP scheduleElement : scheduledElements)
            {
                if((scheduleElement.type).equals('WORK_ORDER')){
                    setScheduledWOs.add(scheduleElement.id);
                    mapWOTechIdLat.put(scheduleElement.id,scheduleElement.resolvedLatitude);
                    mapWOTechIdLong.put(scheduleElement.id,scheduleElement.resolvedLongitude);
                }else if((scheduleElement.type).equals('EVENT')){
                    String techEvntId = scheduleElement.id.split('_')[2];
                    if(techEvntId.contains(strSfEventKeyPrefix)){
                        setSFEventsToBeDeleted.add(techEvntId);
                        setNonWOSFEvents.add(techEvntId);
                    }else{
                        setSvmxEventsToBeDeleted.add(techEvntId);
                        setNonWOSvmxEvents.add(techEvntId);
                    }
                    mapWOTechIdLat.put(techEvntId,scheduleElement.resolvedLatitude);
                    mapWOTechIdLong.put(techEvntId,scheduleElement.resolvedLongitude);

                }else if((scheduleElement.type).equals('RESOURCE')){
                    String techId = scheduleElement.id.split('_')[0];
                    setScheduledTechs.add(techId);
                    mapWOTechIdLat.put(techId,scheduleElement.resolvedLatitude);
                    mapWOTechIdLong.put(techId,scheduleElement.resolvedLongitude);
                }
            }
        }
        WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():setScheduledWOs.size() - ' + setScheduledWOs.size() + '\n');
        
        // Get the default Work Order Service Duration
        Double dblDefaultWOServiceDuration = 0;
        if(mapSettingValues.containsKey('OMAX003_SET004') == TRUE)
            dblDefaultWOServiceDuration = decimal.valueof(mapSettingValues.get('OMAX003_SET004'));
        if (dblDefaultWOServiceDuration < 1)
            dblDefaultWOServiceDuration = 3600;
        
        try{
            lstOptiMaxOPWrkOrds = [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__OptiMax_status__c, SVMXC__Skill_Set__c, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Group_Member__c, SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Qualified_Technicians__c, SVMXC__Scheduled_Date_Time__c,
                                SVMXC__Driving_Time__c, SVMXC__Idle_Time__c, SVMXC__Member_Email__c, SVMXC__Group_Email__c, SVMXC__Last_Dispatch_Event__c, SVMXC__Service_Duration__c,
                                SVMXC__Service_Group__c,SVMXC__Violation_Message__c,SVMXC__Violation_Status2__c,SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Group_Member__r.SVMXC__Working_Hours__c, 
                                SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Preferred_Business_hours__c,SVMXC__Street__c,SVMXC__City__c, SVMXC__Dependency_Group__c from SVMXC__Service_Order__c
                                where Name in : setScheduledWOs];     
            WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():lstOptiMaxOPWrkOrds.size() - ' + lstOptiMaxOPWrkOrds.size() + '\n');
            //collect work order id for querying corresponding events for update the schedules
            set<Id> setWOId = new set<Id>(); 
            if(lstOptiMaxOPWrkOrds != NULL && lstOptiMaxOPWrkOrds.size() > 0)
            {
                for(SVMXC__Service_Order__c omaxOpWO : lstOptiMaxOPWrkOrds)
                {
                    if(omaxOpWO.SVMXC__Service_Duration__c == NULL)
                        omaxOpWO.SVMXC__Service_Duration__c = dblDefaultWOServiceDuration;
                    //Below code commented because we are using WO name instead id.
                    //if(setScheduledWOs.contains(omaxOpWO.Id))// Scheduled work orders
                    if(setScheduledWOs.contains(omaxOpWO.Name))// Scheduled work orders
                    {
                        mapWrkOrdIdServDuration.put(omaxOpWO.Name, omaxOpWO.SVMXC__Service_Duration__c);
                        mapScheduledWO.put(omaxOpWO.Name, omaxOpWO);
                        if(omaxOpWO.SVMXC__Latitude__c != NULL)
                            mapWOTechIdLat.put(omaxOpWO.Name, omaxOpWO.SVMXC__Latitude__c);
                        if(omaxOpWO.SVMXC__Longitude__c != NULL)
                            mapWOTechIdLong.put(omaxOpWO.Name, omaxOpWO.SVMXC__Longitude__c);
                            
                        mapWOIdNAddress.put(omaxOpWO.Name,omaxOpWO.SVMXC__Street__c+', '+omaxOpWO.SVMXC__City__c);
                    }
                    setWOId.add(omaxOpWO.Id);
                }
            }
            WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():mapScheduledWO.size() - ' + mapScheduledWO.size() + '\n');
                
           //create two maps of WOid-> Event and WOid-> SMAXEvent
            Map<String, Event> sfEventsMap = new Map<String, Event>();
            Map<String, SVMXC__SVMX_Event__c> smaxEventsMap = new Map<String, SVMXC__SVMX_Event__c>();
            Map<String, Event> sfNonWOEventsMap = new Map<String, Event>();
            Map<String, SVMXC__SVMX_Event__c> smaxNonWOEventsMap = new Map<String, SVMXC__SVMX_Event__c>();
            
            List<Event> lstUnassignedWOSFEvents = new List<Event>();
            List<SVMXC__SVMX_Event__c> lstUnassignedWOSVMXEvents = new List<SVMXC__SVMX_Event__c>();
            //TODO 
            //below code execute only when routes have events
            if((setSFEventsToBeDeleted != null && setSFEventsToBeDeleted.size() >0 ) || (setWOId != null && setWOId.size() >0)){
                List<Event> lstSFEventsToDelete = [SELECT id, WhatId, Subject, OwnerId, startDateTime, EndDateTime, Location, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c,SVMXC__SM_Status__c, Type from event where (id IN :setSFEventsToBeDeleted OR whatId in :setWOId) and isDeleted = false];
                if(lstSFEventsToDelete != null && lstSFEventsToDelete.size() > 0){
                    for(Event event : lstSFEventsToDelete){
                        if(event.WhatId != null && !String.valueOf(event.get('WhatId')).contains(strTechKeyPrefix) && !setNonWOSFEvents.contains(event.Id))
                            sfEventsMap.put(event.get('WhatId') + '', event);   
                        else
                            sfNonWOEventsMap.put(event.get('Id') + '', event);
                    }
                }
                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():sfEventsMap.size() - ' + sfEventsMap.size() + '\n');
                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():sfNonWOEventsMap - ' + sfNonWOEventsMap + '\n');
            }

            if((setSvmxEventsToBeDeleted !=null && setSvmxEventsToBeDeleted.size() > 0) || (setWOId != null && setWOId.size() >0)){
                //fetch the existing servicemax events for the workorder
                List<SVMXC__SVMX_Event__c> lstSVMXEventsToDelete = [SELECT id, SVMXC__WhatId__c, Name, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Status__c, SVMXC__Type__c from SVMXC__SVMX_Event__c where ( id IN :setSvmxEventsToBeDeleted  OR SVMXC__WhatId__c in :setWOId ) and isDeleted = false];
                if(lstSVMXEventsToDelete != null && lstSVMXEventsToDelete.size() > 0){
                    for(SVMXC__SVMX_Event__c event : lstSVMXEventsToDelete){
                        if(event.SVMXC__WhatId__c != null && !setNonWOSvmxEvents.contains(event.Id))
                            smaxEventsMap.put(event.get('SVMXC__WhatId__c') + '', event);
                        else
                            smaxNonWOEventsMap.put(event.get('Id') + '', event);
                    }
                }
                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():smaxEventsMap.size() - ' + smaxEventsMap.size() + '\n');
            }


            lstOptiMaxOPTechs = [Select Id, Name, SVMXC__Working_Hours__c, SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Salesforce_User__c, SVMXC__Enable_Scheduling__c,
                                SVMXC__Service_Group__c, SVMXC__Email__c, SVMXC__Street__c, SVMXC__City__c
                                from SVMXC__Service_Group_Members__c
                                where Id IN :setScheduledTechs AND SVMXC__Active__c = TRUE];
            WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():lstOptiMaxOPTechs.size() - ' + lstOptiMaxOPTechs.size() + '\n');
                        
            Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills = new Map<Id, List<SVMXC__Service_Group_Skills__c>>();
            SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViltnUtls = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
            mapTechIdSkills = omaxViltnUtls.skillsPerTech(setScheduledTechs);
            
            Map<Id, String> mapTechIdProduct = new  Map<Id, String>();
            mapTechIdProduct = omaxViltnUtls.expertisePerTech(setScheduledTechs);
            if(lstOptiMaxOPTechs != NULL && lstOptiMaxOPTechs.size() > 0)
            {
                for(SVMXC__Service_Group_Members__c opTech : lstOptiMaxOPTechs)
                {
                    //strLogger += system.now() + ': opTech.name-----'+opTech.name+'\n';
                    mapTechIdSFUserId.put(opTech.Id, opTech.SVMXC__Salesforce_User__c);
                    mapTechIdIsSchedulingEnabled.put(opTech.Id, opTech.SVMXC__Enable_Scheduling__c);
                    mapTechIdServTeamId.put(opTech.Id, opTech.SVMXC__Service_Group__c);
                    mapTechEmail.put(opTech.Id, opTech.SVMXC__Email__c);
                    mapTeamEmail.put(opTech.Id, opTech.SVMXC__Service_Group__r.SVMXC__Email__c);
                    if(opTech.SVMXC__Working_Hours__c != NULL && mapBusinessHours.containsKey(opTech.SVMXC__Working_Hours__c))
                    {
                        mapTechTimeZone.put(opTech.Id, mapBusinessHours.get(opTech.SVMXC__Working_Hours__c).timeZoneSidKey);
                    }
                    else if(objDefTerritoryBH != null)
                        mapTechTimeZone.put(opTech.Id, objDefTerritoryBH.timeZoneSidKey);
                }
            }
            WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():mapTechIdIsSchedulingEnabled.size() - ' + mapTechIdIsSchedulingEnabled.size() + '\n');

            List<Datetime> listHorizontalDateTime = new List<Datetime>();
            for(WSCH_LTP_Scheduling_Stubs.Route_WP route: routes)
            {
                Integer intDrivingTimeBeforeEvent = 0;
                List<WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP> scheduledElements = route.scheduledElements; 
                integer i=1;
            
                List<SVMXC__SVMX_Event__c> lstSmaxEventsToDel = new List<SVMXC__SVMX_Event__c>();
                List<Event> lstSFEventsToDel = new List<Event>();
            
                //Added the below logic to check if the setting GBL025 is set to smaxEvent or SalesforceEvent
                //Based on this setting either create a smaxEvent or salesforceEvent
                boolean isSFEvent = false;
                String strGBL025;
                if(mapSettingValues.containsKey('GLOB001_GBL025')) {
                    strGBL025 = mapSettingValues.get('GLOB001_GBL025');
                }
                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():The setting value of strGBL025 - ' + strGBL025 + '\n');
                if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('ServiceMax Event')) {
                    isSFEvent = false;
                } else if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('Salesforce Event')) {
                    isSFEvent = true;
                }
                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():isSFEvent : ' + isSFEvent + '\n');            
                // Tech associated with Salesforce User
                if(mapTechIdSFUserId.containsKey(route.ResourceId) && mapTechIdSFUserId.get(route.ResourceId)!=NULL)
                {
                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes(): Setting up events and updating work orders for SF technician: ' + route.ResourceId + '\n');
                    for(WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP scheduledElement : route.scheduledElements)
                    {
                        WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():destNode - ' + scheduledElement + '\n');
                        WSCH_LTP_Scheduling_Stubs.Booking_WP booking = scheduledElement.booking;
                        if((scheduledElement.type).equals('WORK_ORDER'))
                        {
                            //WSCH_AuditLogger.debug( ':mapScheduledWO....: ' + mapScheduledWO + '\n');
                            //WSCH_AuditLogger.debug( ':scheduledElement.id....: ' + scheduledElement.id + '\n');
                            // If the work order doesn't exist, skip the event creation 
                            if(!mapScheduledWO.containsKey(scheduledElement.id))
                            {
                                intMissingWorkOrderCount++;
                                strDeletedWorkOrderDetails += scheduledElement.id + ',' + route.resourceId +',' + booking.arrivalTime + ',' + booking.endTime + ',' + booking.driveDuration + '\n';
                                i++;
                                continue;
                            }
                                
                            if(isSFEvent) {
                                //if this WO already has a SMAXEvent, delete it before creating a new SFEvent
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():smaxEventsMap.containsKey(mapScheduledWO.get(scheduledElement.workorderId).Id) - ' + smaxEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id) + '\n');
                                if(smaxEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id)) {
                                    WSCH_AuditLogger.debug( ' This WO ' + scheduledElement.id + ' also contains SMAX Event. Hence deleting it.' + '\n');
                                    SVMXC__SVMX_Event__c smaxEvent = smaxEventsMap.get(mapScheduledWO.get(scheduledElement.id).Id);
                                    WSCH_AuditLogger.debug( ' smaxEvent - ' + smaxEvent.Id + '\n');
                                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){  //SDL-SVMX-DELETE-FLS-ENFORCED
                                        lstSmaxEventsToDel.add(smaxEvent); //add the SmaxEvent to the list. This list will be deleted below
                                    } else {
                                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                                    }
                                    smaxEventsMap.remove(mapScheduledWO.get(scheduledElement.id).Id);
                                }
                                
                                //Calculate Drivetime
                                Double dblDrivingTimeMins = (booking.driveDuration + intDrivingTimeBeforeEvent) / 60;
                                //WSCH_AuditLogger.debug( ':Before setting subject for the event....WO ID: ' + scheduledElement.id + '\n'); 
                                
                                // Set up the event
                                //if the WO already has a SFEvent, update it
                                objSFEvent = sfEventsMap.get(mapScheduledWO.get(scheduledElement.id).Id);
                                WSCH_AuditLogger.debug( ' Does the event already exists - objSFEvent : ' + objSFEvent + '\n');
                                //If it a new event, then instantiate one.
                                if(objSFEvent == null) {
                                    WSCH_AuditLogger.debug( 'This is a new event. Hence creating it' + '\n');
                                    objSFEvent = new Event();
                                }
                                objSFEvent.Subject = TAG007 + ' ' + mapScheduledWO.get(scheduledElement.id).Name;
                                objSFEvent.OwnerId = mapTechIdSFUserId.get(route.ResourceId);
                                //objSFEvent.WhatId = scheduledElement.workorderId;
                                objSFEvent.WhatId = mapScheduledWO.get(scheduledElement.id).Id;
                                WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processRoutes():: booking.arrivalTime: ' +booking.arrivalTime + ' , booking.arrivalTime.getTime(): '+booking.arrivalTime.getTime()+ ' , booking.driveDuration: '+booking.driveDuration);
                                objSFEvent.startDateTime = datetime.newInstance(booking.arrivalTime.getTime() - ((booking.driveDuration + intDrivingTimeBeforeEvent) * 1000));
                                objSFEvent.EndDateTime =booking.endTime;
                                //Server side calculation is Date startDateTime = new Date (destination.getArrivalTime().getTime() - (long)(Math.floor(destination.getDrivingTime()) * 1000));
                                
                                if(mapWOTechIdLat.get(scheduledElement.id) != NULL && mapWOTechIdLong.get(scheduledElement.id) != NULL){
                                    objSFEvent.SVMXC__SM_Latitude__c = mapWOTechIdLat.get(scheduledElement.id); 
                                    objSFEvent.SVMXC__SM_Longitude__c = mapWOTechIdLong.get(scheduledElement.id);
                                }
                                objSFEvent.ActivityDateTime = objSFEvent.startDateTime;
                                objSFEvent.ActivityDate = objSFEvent.startDateTime.dateGMT();
                                objSFEvent.SVMXC__Driving_Time__c=dblDrivingTimeMins;
                                objSFEvent.SVMXC__SM_Idle_Time__c = Integer.valueOf(booking.idleDuration / 60);
                                if(booking.returnDriveDuration > 0 ){
                                    objSFEvent.SVMXC__Driving_Time_Home__c=Integer.valueOf(booking.returnDriveDuration / 60);
                                    //Double dblReturnTime = booking.returnDriveDuration * 3600; // in seconds
                                    objSFEvent.EndDateTime = datetime.newInstance(booking.endTime.getTime() + ((booking.returnDriveDuration) * 1000));
                                }
                                lstSFEvents.add(objSFEvent);
                            } else {
                                    //if this WO already has a SFEvent, delete it before creating a new SMAXEvent
                                    WSCH_AuditLogger.debug( ' WSCH_LTP_SchedulingService_Handler::processRoutes():sfEventsMap.containsKey(mapScheduledWO.get(scheduledElement.workorderId).Id) - ' + sfEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id) + '\n');
                                    if(sfEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id)) {
                                        WSCH_AuditLogger.debug( ' This WO ' + scheduledElement.id + ' also contains SF Event. Hence deleting it.' + '\n');
                                        Event sfEvent = sfEventsMap.get(mapScheduledWO.get(scheduledElement.id).Id);
                                        WSCH_AuditLogger.debug( ' sfEvent - ' + sfEvent.Id + '\n');
                                        lstSFEventsToDel.add(sfEvent); //add the SFEvent to the list. This list will be deleted below
                                        sfEventsMap.remove(mapScheduledWO.get(scheduledElement.id).Id);
                                    }
                                    
                                    //Calculate Drivetime
                                    Double dblDrivingTimeMins = (booking.driveDuration + intDrivingTimeBeforeEvent) / 60;
                                    //WSCH_AuditLogger.debug( 'SMAX_Complete_OptiMax_Job_WS dblDrivingTimeMins' + dblDrivingTimeMins+'\n');
                                    
                                    // Set up the event
                                    //if the WO already has a SMAXEvent, update it
                                    //WSCH_AuditLogger.debug( 'Before creating smaxEvent, : scheduledElement.workorderId' + scheduledElement.id + '\n');
                                    //system.debug('Before creating smaxEvent, : scheduledElement.workorderId - ' + scheduledElement.id);
                                    objSvmxEvent = smaxEventsMap.get(mapScheduledWO.get(scheduledElement.id).Id);
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():Does the event already exists - objSvmxEvent : ' + objSvmxEvent + '\n');
                                    //system.debug('Does the event already exists - objSvmxEvent : ' + objSvmxEvent);
                                    //If it a new event, then instantiate one.
                                    if(objSvmxEvent == null) {
                                        WSCH_AuditLogger.debug( 'This is a new event. Hence creating it' + '\n');
                                        objSvmxEvent = new SVMXC__SVMX_Event__c();
                                    }
                                    objSvmxEvent.Name = TAG007+ ' ' + mapScheduledWO.get(scheduledElement.id).Name;
                                    objSvmxEvent.SVMXC__Technician__c = route.resourceId;
                                    //objSvmxEvent.SVMXC__WhatId__c = scheduledElement.workorderId;
                                    objSvmxEvent.SVMXC__WhatId__c = mapScheduledWO.get(scheduledElement.id).Id;
                                    WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processRoutes(): booking.arrivalTime: ' +booking.arrivalTime + ' , booking.arrivalTime.getTime(): '+booking.arrivalTime.getTime()+ ' , scheduledElement.driveDuration: '+booking.driveDuration + '\n');
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():SMAX_Complete_OptiMax_Job_WS drivetime to minus from arrival time' + ((booking.driveDuration + intDrivingTimeBeforeEvent) * 1000) +'\n');
                                    objSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(booking.arrivalTime.getTime() - ((booking.driveDuration + intDrivingTimeBeforeEvent) * 1000));
                                    WSCH_AuditLogger.debug( 'SWSCH_LTP_SchedulingService_Handler::processRoutes():MAX_Complete_OptiMax_Job_WS Calculated Start Time' +  objSvmxEvent.SVMXC__StartDateTime__c+'\n');
                                     
                                    objSvmxEvent.SVMXC__EndDateTime__c = booking.endTime;
                                    
                                    if(mapWOTechIdLat.get(scheduledElement.id) != NULL && mapWOTechIdLong.get(scheduledElement.id) != NULL){
                                        //update the lattitude and longitude fields for the technician event additional details
                                        objSvmxEvent.SVMXC__SM_Latitude__c = mapWOTechIdLat.get(scheduledElement.id);
                                        objSvmxEvent.SVMXC__SM_Longitude__c = mapWOTechIdLong.get(scheduledElement.id);
                                    }
                                    objSvmxEvent.SVMXC__ActivityDateTime__c = objSvmxEvent.SVMXC__StartDateTime__c;
                                    objSvmxEvent.SVMXC__ActivityDate__c = objSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                    objSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                    objSvmxEvent.SVMXC__SM_Idle_Time__c = Integer.valueOf(booking.idleDuration / 60);
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():: SMAX_Complete_OptiMax_Job_WS SF SvmxEvent idle time :- '+ objSvmxEvent.SVMXC__SM_Idle_Time__c+'\n');
                                    objSvmxEvent.SVMXC__Driving_Time_Home__c=0;
                                    if(booking.returnDriveDuration > 0 ){
                                        objSvmxEvent.SVMXC__Driving_Time_Home__c=Integer.valueOf(booking.returnDriveDuration / 60);
                                        WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes()::Return drivetime for the last work order event in the route....: ' + scheduledElement.id + ' is: '+objSvmxEvent.SVMXC__Driving_Time_Home__c+'[min.] \n');
                                        //Double dblReturnTime = booking.returnDriveDuration * 3600; //in seconds
                                        WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes()::End datetime for the last work order event in the route....: ' + scheduledElement.id + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n');
                                        objSvmxEvent.SVMXC__EndDateTime__c = datetime.newInstance(booking.endTime.getTime() + ((booking.returnDriveDuration) * 1000));
                                        WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes()::End datetime for the last work order event after adding return drivetime....: ' + scheduledElement.id + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n');
                                    }                                   
                                    lstSvmxEvents.add(objSvmxEvent);
                                }
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():ALL SF Events added to list ' +lstSFEvents.size()+ ' \n');
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():ALL SVMX Events added to list in case if GBL025 is set to smaxEvents' +lstSvmxEvents.size()+ ' \n');
                                // Ensure that a work order is updated only once. Also prevent externally scheduled work orders from getting upated.
                                if(!setUpdatedWorkOrder.contains(scheduledElement.id) && !setExternalWOs.contains(scheduledElement.id) && mapScheduledWO.containsKey(scheduledElement.id))
                                {
                                    setUpdatedWorkOrder.add(scheduledElement.id);
                                    objWorkOrder = new SVMXC__Service_Order__c();
                                    objWorkOrder = mapScheduledWO.get(scheduledElement.id);
                                    objWorkOrder.SVMXC__OptiMax_status__c = 'Processing Complete';
                                    //objWorkOrder.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                                    objWorkOrder.SVMXC__Group_Member__c = route.resourceId;
                                    objWorkOrder.SVMXC__OptiMax_Error_Text__c='';
                                    
                                    //sync Locked by DC and SVMXC__SM_Lock_Appointment_Schedule__c field 
                                    if(objWorkOrder.SVMXC__Locked_By_DC__c == true){
                                        objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c =WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                                    }else if(objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE){
                                        objWorkOrder.SVMXC__Locked_By_DC__c = true;
                                    }
        
                                    if(mapSettingValues.get('OMAX002_SET003').toUpperCase() == 'TRUE') {
                                        //added the below check to ensure that this part of code gets executed
                                        //only in case of SFEvent when SET025 is set to SFEvent
                                        objWorkOrder.OwnerId = mapTechIdSFUserId.get(route.ResourceId);
                                    }
                                        //objWorkOrder.OwnerId = objSFEvent.OwnerId;
                                    if(mapTechIdServTeamId.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Service_Group__c = mapTechIdServTeamId.get(route.ResourceId);
                                    if(mapTeamEmail.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Group_Email__c = mapTeamEmail.get(route.resourceId);
                                    if(mapTechEmail.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Member_Email__c = mapTechEmail.get(route.resourceId);
                                    if(objWorkOrder.SVMXC__Latitude__c == NULL && mapWOTechIdLat.get(objWorkOrder.Name) != NULL)
                                        objWorkOrder.SVMXC__Latitude__c = mapWOTechIdLat.get(objWorkOrder.Name);
                                    if(objWorkOrder.SVMXC__Longitude__c == NULL && mapWOTechIdLong.get(objWorkOrder.Name) != NULL)
                                        objWorkOrder.SVMXC__Longitude__c = mapWOTechIdLong.get(objWorkOrder.Name);                                    
                                        
                                    Double dblDrivingTimeMins = (booking.driveDuration + intDrivingTimeBeforeEvent) / 60;
                                    objWorkOrder.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                    objWorkOrder.SVMXC__Scheduled_Date_Time__c = booking.arrivalTime;
                                    
                                    //Following case occurs when the WO which was scheduled earlier with violation msg. We need to clear
                                    //the msg for next run.
                                    if(objWorkOrder.SVMXC__Violation_Message__c != null || objWorkOrder.SVMXC__Violation_Status2__c != null) {
                                        objWorkOrder.SVMXC__Violation_Message__c = '';
                                        objWorkOrder.SVMXC__Violation_Status2__c = null;
                                    }
                                    lstWOToBeUpdated.add(objWorkOrder);
                                }
                                // Reseting the driving time before event
                                intDrivingTimeBeforeEvent = 0;
                            }
                            i++;
                        }
                        
                        //Deleting the SMAXEvents that were added to the list above
                        if(lstSmaxEventsToDel != null && lstSmaxEventsToDel.size() > 0) {
                            if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){   //SDL-SVMX-DELETE-FLS-ENFORCED
                               delete lstSmaxEventsToDel;
                            } else {
                               throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                            }
                        }
                    }
                else // Tech not associated with Salesforce User
                {
                    if(mapTechIdIsSchedulingEnabled.get(route.ResourceId) == TRUE) // Scheduling enabled for tech
                    {
                        WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes(): Setting up events and updating work orders for SVMX technician: ' + route.ResourceId + '\n');
                        for(WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP scheduledElement : route.scheduledElements)
                        {
                            WSCH_LTP_Scheduling_Stubs.Booking_WP booking = scheduledElement.booking;
                            if((scheduledElement.type).equals('WORK_ORDER'))
                            {
                                // If the work order doesn't exist, skip the event creation 
                                if(!mapScheduledWO.containsKey(scheduledElement.id))
                                {
                                    intMissingWorkOrderCount++;
                                    strDeletedWorkOrderDetails += scheduledElement.id + ',' + route.resourceId +',' + booking.arrivalTime + ',' + booking.endTime + ',' + booking.driveDuration + '\n';
                                    i++;
                                    continue;
                                }
                                //if this WO already has a SFEvent, delete it before creating a new SMAXEvent
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes(): sfEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id) - ' + sfEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id) + '\n');
                                if(sfEventsMap.containsKey(mapScheduledWO.get(scheduledElement.id).Id)) {
                                    WSCH_AuditLogger.debug( ' WSCH_LTP_SchedulingService_Handler::processRoutes():This WO ' + scheduledElement.id + ' also contains SF Event. Hence deleting it.' + '\n');
                                    Event sfEvent = sfEventsMap.get(mapScheduledWO.get(scheduledElement.id).Id);
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes(): sfEvent - ' + sfEvent.Id + '\n');
                                    lstSFEventsToDel.add(sfEvent); //add the SFEvent to the list. This list will be deleted below
                                    sfEventsMap.remove(mapScheduledWO.get(scheduledElement.id).Id);
                                }
                                
                                //Calculate Drivetime
                                Double dblDrivingTimeMins = (booking.driveDuration + intDrivingTimeBeforeEvent) / 60;
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes(): dblDrivingTimeMins' + dblDrivingTimeMins+'\n');
                                 
                                // Set up the event
                                //if the WO already has a SMAXEvent, update it
                                //WSCH_AuditLogger.debug( 'Before creating smaxEvent, : scheduledElement.workorderId' + scheduledElement.id + '\n');
                                objSvmxEvent = smaxEventsMap.get(mapScheduledWO.get(scheduledElement.id).Id);
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():Does the event already exists - objSvmxEvent : ' + objSvmxEvent + '\n');
                                //If it a new event, then instantiate one.
                                if(objSvmxEvent == null) {
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():This is a new event. Hence creating it' + '\n');
                                    objSvmxEvent = new SVMXC__SVMX_Event__c();
                                }
                                objSvmxEvent.Name = TAG007+ ' ' + mapScheduledWO.get(scheduledElement.id).Name;
                                objSvmxEvent.SVMXC__Technician__c = route.resourceId;
                                //objSvmxEvent.SVMXC__WhatId__c = scheduledElement.workorderId;
                                objSvmxEvent.SVMXC__WhatId__c = mapScheduledWO.get(scheduledElement.id).Id;
                                WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processRoutes():: booking.arrivalTime: ' +booking.arrivalTime + ' , booking.arrivalTime.getTime(): '+booking.arrivalTime.getTime()+ ' , booking.driveDuration: '+booking.driveDuration + '\n');
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():' + ((booking.driveDuration + intDrivingTimeBeforeEvent) * 1000) +'\n');
                                objSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(booking.arrivalTime.getTime() - ((booking.driveDuration + intDrivingTimeBeforeEvent) * 1000));
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes(): Calculated Start Time' +  objSvmxEvent.SVMXC__StartDateTime__c+'\n');
                                objSvmxEvent.SVMXC__EndDateTime__c = booking.endTime;
                                
                                if(mapWOTechIdLat.get(scheduledElement.id) != NULL && mapWOTechIdLong.get(scheduledElement.id) != NULL){
                                    objSvmxEvent.SVMXC__SM_Latitude__c = mapWOTechIdLat.get(scheduledElement.id);
                                    objSvmxEvent.SVMXC__SM_Longitude__c = mapWOTechIdLong.get(scheduledElement.id);
                                }
                                objSvmxEvent.SVMXC__ActivityDateTime__c = objSvmxEvent.SVMXC__StartDateTime__c;
                                objSvmxEvent.SVMXC__ActivityDate__c = objSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                
                                objSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                objSvmxEvent.SVMXC__SM_Idle_Time__c = Integer.valueOf(booking.idleDuration / 60);
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():: SF SvmxEvent idle time :- '+ objSvmxEvent.SVMXC__SM_Idle_Time__c+'\n');
                                objSvmxEvent.SVMXC__Driving_Time_Home__c=0;

                                if(booking.returnDriveDuration > 0 ){
                                    objSvmxEvent.SVMXC__Driving_Time_Home__c=Integer.valueOf(booking.returnDriveDuration / 60);
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes()::Return drivetime for the last work order event in the route....: ' + scheduledElement.id + ' is: '+objSvmxEvent.SVMXC__Driving_Time_Home__c+'[min.] \n');

                                    //Double dblReturnTime = booking.returnDriveDuration * 3600; //in seconds
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes()::End datetime for the last work order event in the route....: ' + scheduledElement.id + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n');
                                    objSvmxEvent.SVMXC__EndDateTime__c = datetime.newInstance(booking.endTime.getTime() + (booking.returnDriveDuration) * 1000);
                                    WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes()::End datetime for the last work order event after adding return drivetime....: ' + scheduledElement.id + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n');
                                }
                                lstSvmxEvents.add(objSvmxEvent);
                                WSCH_AuditLogger.debug( 'WSCH_LTP_SchedulingService_Handler::processRoutes():ALL SVMX Events added to list ' +lstSvmxEvents+ ' \n');
                                
                                // Ensure that a work order is updated only once. Also prevent externally scheduled work orders from getting upated.
                                if(!setUpdatedWorkOrder.contains(scheduledElement.id) && !setExternalWOs.contains(scheduledElement.id) && mapScheduledWO.containsKey(scheduledElement.id))
                                {
                                    setUpdatedWorkOrder.add(scheduledElement.id);
                                    objWorkOrder = new SVMXC__Service_Order__c();
                                    objWorkOrder = mapScheduledWO.get(scheduledElement.id);
                                    objWorkOrder.SVMXC__OptiMax_status__c = 'Processing Complete'; // Processing Complete
                                    //objWorkOrder.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                                    objWorkOrder.SVMXC__Group_Member__c = route.resourceId;
                                    objWorkOrder.SVMXC__OptiMax_Error_Text__c='';
                                    
        
                                    //sync Locked by DC and SVMXC__SM_Lock_Appointment_Schedule__c field 
                                    if(objWorkOrder.SVMXC__Locked_By_DC__c == true){
                                        objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c =WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                                    }else if(objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE){
                                        objWorkOrder.SVMXC__Locked_By_DC__c = true;
                                    }
                                
                                    if(mapTechIdServTeamId.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Service_Group__c = mapTechIdServTeamId.get(route.ResourceId);
                                    if(mapTeamEmail.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Group_Email__c = mapTeamEmail.get(route.resourceId);
                                    if(mapTechEmail.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Member_Email__c = mapTechEmail.get(route.resourceId);
        
                                    if(objWorkOrder.SVMXC__Latitude__c == NULL && mapWOTechIdLat.get(objWorkOrder.Name) != NULL)
                                        objWorkOrder.SVMXC__Latitude__c = mapWOTechIdLat.get(objWorkOrder.Name);
                                    if(objWorkOrder.SVMXC__Longitude__c == NULL && mapWOTechIdLong.get(objWorkOrder.Name) != NULL)
                                        objWorkOrder.SVMXC__Longitude__c = mapWOTechIdLong.get(objWorkOrder.Name);
                                    objWorkOrder.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                    objWorkOrder.SVMXC__Scheduled_Date_Time__c = booking.arrivalTime;
                                    if(objWorkOrder.SVMXC__FirstScheduledDateTime__c == NULL)
										objWorkOrder.SVMXC__FirstScheduledDateTime__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
										
									//Following case occurs when the WO which was scheduled earlier with violation msg. We need to clear
                                    //the msg for next run.
                                    if(objWorkOrder.SVMXC__Violation_Message__c != null || objWorkOrder.SVMXC__Violation_Status2__c != null) {
                                        objWorkOrder.SVMXC__Violation_Message__c = '';
                                        objWorkOrder.SVMXC__Violation_Status2__c = null;
                                    }	
                                    
                                    lstWOToBeUpdated.add(objWorkOrder);
                                }
                                // Reseting the driving time before event
                                intDrivingTimeBeforeEvent = 0;
                            }
                            i++;
                        }
                    }
                    //Deleting the SFEvents that were added to the list above
                    if(lstSFEventsToDel != null && lstSFEventsToDel.size() > 0) {
                        //calling CRUD_Helper method instead of deleting the SF event directly
                        //WSCH_CRUD_Helper.deleteListEvents(lstSFEventsToDel);
                        delete lstSFEventsToDel;
                    }
                }
            }
            try
            {
                // Create the events and update the work orders with schedule information
                if(lstSFEvents.size() > 0) {
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    //insert lstSFEvents;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSFEvents, COMM_SecurityUtils.Access.Upsertable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstSFEvents;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                
                if(lstSvmxEvents.size() > 0) {
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    //insert lstSvmxEvents;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSvmxEvents, COMM_SecurityUtils.Access.Upsertable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstSvmxEvents;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                 
                if(lstWOToBeUpdated.size() > 0) {
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOToBeUpdated, COMM_SecurityUtils.Access.Updateable)){ //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstWOToBeUpdated;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                } 
    
            }
            catch(Exception e)
            {
                //WSCH_AuditLogger.debug( ': Error: while updating SFDC with OptiMax CompleteJob WS response:\n' + ex.getMessage();
                WSCH_AuditLogger.debug('Error: while updating SFDC with OptiMax CompleteJob WS response::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n');
                throw new SVMXException(e.getMessage());
            }
        } catch(Exception e) {
            WSCH_AuditLogger.debug('Fetching and updating status of unassigned events ::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n');    
        }                      
        return true;
    }

    public static boolean processStatistics(List<WSCH_LTP_Scheduling_Stubs.SchedulingJobStatistic_WP> schedulingJobStatistic, String svmxJobId){
        // Variable definitions
        SVMXC__SVMX_Job_Stats__c objSvmxJobStats;
        List<SVMXC__SVMX_Job_Stats__c> lstSvmxJobStats = new List<SVMXC__SVMX_Job_Stats__c>();
        for(WSCH_LTP_Scheduling_Stubs.SchedulingJobStatistic_WP jobStats : schedulingJobStatistic)
        {
                //WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processStatistics(): HorizondatateTime jobStats.statName=='+jobStats.name+'\n');
                //WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processStatistics():: HorizondatateTime jobStats.value=='+jobStats.value+'\n');               
            if(!String.isBlank(jobStats.value))
            {
                if(jobStats.value.length() > 255)
                {
                    jobStats.value = jobStats.value.replace(jobStats.value.substring(0,3),'');
                    if(jobStats.value.length() > 255)
                        jobStats.value = jobStats.value.substring(0, 255);
                }
            }                        
            objSvmxJobStats = new SVMXC__SVMX_Job_Stats__c(Name = jobStats.name, SVMXC__SVMX_Job__c = svmxJobId, SVMXC__Value__c = jobStats.value, SVMXC__Units__c = jobStats.type);
            lstSvmxJobStats.add(objSvmxJobStats);
        }
        if(lstSvmxJobStats.size() > 0) insert lstSvmxJobStats;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    
        return true;
    }

    public static boolean processUnAssignedElements(List<WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP> unscheduledElements){
        WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processUnAssignedElements(): unscheduledElements size'+unscheduledElements.size()+'\n');
        Map<String, String> mapUnassignedWorkOrders = new Map<String, String>();
        Map<String, String> mapUnassignedSFEvents = new Map<String, String>();
        Map<String, String> mapUnassignedSMAXEvents = new Map<String, String>();
        Map<String, String> mapUnassignedResources = new Map<String, String>();
        List<SVMXC__Service_Order__c> lstOptiMaxOPWrkOrds = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstWOToBeUpdated = new List<SVMXC__Service_Order__c>();
        Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
        String strSfEventKeyPrefix = descEventObj.getKeyPrefix();
        List<Event> lstSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSvmxEvents = new List<SVMXC__SVMX_Event__c>();

        for(WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP unscheduledElement : unscheduledElements){
            if(unscheduledElement.unscheduledElementType.equalsIgnoreCase('UNASSIGNED_WORK_ORDER')){
                mapUnassignedWorkOrders.put(unscheduledElement.id,unscheduledElement.reason);
            }else if(unscheduledElement.unscheduledElementType.equalsIgnoreCase('UNASSIGNED_EVENT')){
                String techEvntId = unscheduledElement.id.split('_')[2];
                if(techEvntId.startsWith(strSfEventKeyPrefix)){
                    mapUnassignedSFEvents.put(techEvntId,unscheduledElement.reason);
                }else{
                    mapUnassignedSMAXEvents.put(techEvntId,unscheduledElement.reason);
                }               
            }else if(unscheduledElement.unscheduledElementType.equalsIgnoreCase('UNASSIGNED_RESOURCE')){
                String techId = unscheduledElement.id.split('_')[0];
                mapUnassignedResources.put(techId,unscheduledElement.reason);
            }
        }
        //Query the work order and update the corresponding error text in work order
        lstOptiMaxOPWrkOrds = [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__OptiMax_status__c, SVMXC__Skill_Set__c, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Group_Member__c, SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Qualified_Technicians__c, SVMXC__Scheduled_Date_Time__c,
                                SVMXC__Driving_Time__c, SVMXC__Idle_Time__c, SVMXC__Member_Email__c, SVMXC__Group_Email__c, SVMXC__Last_Dispatch_Event__c, SVMXC__Service_Duration__c,
                                SVMXC__Service_Group__c,SVMXC__Violation_Message__c,SVMXC__Violation_Status2__c,SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Group_Member__r.SVMXC__Working_Hours__c, 
                                SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Preferred_Business_hours__c,SVMXC__Street__c,SVMXC__City__c, SVMXC__Dependency_Group__c, SVMXC__First_Assigned_DateTime__c, SVMXC__FirstScheduledDateTime__c from SVMXC__Service_Order__c
                                where Name in : mapUnassignedWorkOrders.keySet()];     
        
        Set<Id> unAssingedWOIds = new Set<Id>();
        // Build separate lists of scheduled and unassigned work orders, with relevant details
        if(lstOptiMaxOPWrkOrds != NULL && lstOptiMaxOPWrkOrds.size() > 0)
        {
            for(SVMXC__Service_Order__c omaxOpWO : lstOptiMaxOPWrkOrds)
            {
                omaxOpWO.SVMXC__OptiMax_status__c = NULL;
                omaxOpWO.SVMXC__Group_Member__c = NULL;
                omaxOpWO.SVMXC__Scheduled_Date_Time__c = NULL;
                omaxOpWO.SVMXC__Driving_Time__c = NULL;
                omaxOpWO.SVMXC__Idle_Time__c = NULL;
                omaxOpWO.SVMXC__Member_Email__c = NULL;
                omaxOpWO.SVMXC__Group_Email__c = NULL;
                omaxOpWO.SVMXC__Last_Dispatch_Event__c = NULL;
                omaxOpWO.SVMXC__Service_Group__c = NULL;
                omaxOpWO.SVMXC__Locked_By_DC__c = false;
                omaxOpWO.SVMXC__SM_Lock_Appointment_Schedule__c = NULL;
                //if(omaxOpWO.SVMXC__Last_Dispatch_Event__c == 'Scheduled')
                //    omaxOpWO.SVMXC__Last_Dispatch_Event__c = 'UnScheduled';
                        
                //reset violations
                omaxOpWO.SVMXC__Violation_Message__c = mapUnassignedWorkOrders.get(omaxOpWO.Name);
                omaxOpWO.SVMXC__OptiMax_Error_Text__c = mapUnassignedWorkOrders.get(omaxOpWO.Name);
                omaxOpWO.SVMXC__Violation_Status2__c ='Unresourced';                                                
                lstWOToBeUpdated.add(omaxOpWO);
            }
        }
        if(lstWOToBeUpdated.size() > 0) update lstWOToBeUpdated;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        //Query the Events and Update the event type field as Un Optimizable
        try{
            List<Event> lstUnAssignedSFEvents = [SELECT id, SVMXC__SM_Status__c, WhatId, Subject, OwnerId, startDateTime, EndDateTime, Location, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from event where id IN :mapUnassignedSFEvents.keySet() and isDeleted = false];
            if(lstUnAssignedSFEvents != null && lstUnAssignedSFEvents.size() > 0){
                for(Event eventobj :lstUnAssignedSFEvents){
                    eventobj.SVMXC__SM_Status__c='Un Optimizable';
                    lstSFEvents.add(eventobj);
                }
            }
            
            List<SVMXC__SVMX_Event__c> lstUnAssignedSMAXEvents = [SELECT id, SVMXC__SM_Status__c, SVMXC__WhatId__c, Name, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from SVMXC__SVMX_Event__c where id IN :mapUnassignedSMAXEvents.keySet() and isDeleted = false];
            if(lstUnAssignedSMAXEvents != null && lstUnAssignedSMAXEvents.size() > 0){
                for(SVMXC__SVMX_Event__c smaxEventobj :lstUnAssignedSMAXEvents){
                    smaxEventobj.SVMXC__SM_Status__c='Un Optimizable';
                    lstSvmxEvents.add(smaxEventobj);
                }
            }
            
        } catch(Exception e) {
            WSCH_AuditLogger.error('WSCH_LTP_SchedulingService_Handler::processUnAssignedElements():Fetching and updating status of unassigned events ::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n');    
        }       
        if(lstSFEvents.size() > 0) update lstSFEvents;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        if(lstSvmxEvents.size() > 0) update lstSvmxEvents;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        //TODO: Resource unassignment processing
        //Log the resource id and name with proper error message.
        WSCH_AuditLogger.debug('WSCH_LTP_SchedulingService_Handler::processUnAssignedElements(): UnAssigned Technicians '+mapUnassignedResources.keySet()+'\n');

        return true;
    }

    public static boolean processBadElements(List<WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP> badSchedulingElements){
        Map<String, String> mapBadScheduledWorkOrders = new Map<String, String>();
        List<SVMXC__Service_Order__c> lstOptiMaxOPWrkOrds = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstWOToBeUpdated = new List<SVMXC__Service_Order__c>();
        Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
        String strSfEventKeyPrefix = descEventObj.getKeyPrefix();
        List<Event> lstSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSvmxEvents = new List<SVMXC__SVMX_Event__c>();

        for(WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP badScheduledElement : badSchedulingElements){
            if(badScheduledElement.unscheduledElementType.equalsIgnoreCase('BAD_WORK_ORDER')){
                mapBadScheduledWorkOrders.put(badScheduledElement.id,badScheduledElement.reason);
            }
        }
        
        //Query the work order and update the corresponding error text in work order
        lstOptiMaxOPWrkOrds = [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__OptiMax_status__c, SVMXC__Skill_Set__c, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Group_Member__c, SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Qualified_Technicians__c, SVMXC__Scheduled_Date_Time__c,
                                SVMXC__Driving_Time__c, SVMXC__Idle_Time__c, SVMXC__Member_Email__c, SVMXC__Group_Email__c, SVMXC__Last_Dispatch_Event__c, SVMXC__Service_Duration__c,
                                SVMXC__Service_Group__c,SVMXC__Violation_Message__c,SVMXC__Violation_Status2__c,SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Group_Member__r.SVMXC__Working_Hours__c, 
                                SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Preferred_Business_hours__c,SVMXC__Street__c,SVMXC__City__c, SVMXC__Dependency_Group__c, SVMXC__First_Assigned_DateTime__c, SVMXC__FirstScheduledDateTime__c from SVMXC__Service_Order__c
                                where Name in : mapBadScheduledWorkOrders.keySet()];     
        
        Set<Id> unAssingedWOIds = new Set<Id>();
        // Build separate lists of scheduled and unassigned work orders, with relevant details
        if(lstOptiMaxOPWrkOrds != NULL && lstOptiMaxOPWrkOrds.size() > 0)
        {
            for(SVMXC__Service_Order__c omaxOpWO : lstOptiMaxOPWrkOrds)
            {
                omaxOpWO.SVMXC__OptiMax_status__c = NULL;
                omaxOpWO.SVMXC__Group_Member__c = NULL;
                omaxOpWO.SVMXC__Scheduled_Date_Time__c = NULL;
                omaxOpWO.SVMXC__Driving_Time__c = NULL;
                omaxOpWO.SVMXC__Idle_Time__c = NULL;
                omaxOpWO.SVMXC__Member_Email__c = NULL;
                omaxOpWO.SVMXC__Group_Email__c = NULL;
                //omaxOpWO.SVMXC__Last_Dispatch_Event__c = NULL;
                omaxOpWO.SVMXC__Service_Group__c = NULL;
                omaxOpWO.SVMXC__Locked_By_DC__c = false;
                omaxOpWO.SVMXC__SM_Lock_Appointment_Schedule__c = NULL;
                //if(omaxOpWO.SVMXC__Last_Dispatch_Event__c == 'Scheduled')
                //    omaxOpWO.SVMXC__Last_Dispatch_Event__c = 'UnScheduled';
                        
                //reset violations
                omaxOpWO.SVMXC__Violation_Message__c = mapBadScheduledWorkOrders.get(omaxOpWO.Name);
                omaxOpWO.SVMXC__OptiMax_Error_Text__c = mapBadScheduledWorkOrders.get(omaxOpWO.Name);
                omaxOpWO.SVMXC__Violation_Status2__c ='Unscheduled - Bad Data';                                                
                lstWOToBeUpdated.add(omaxOpWO);
            }
        }
        
        if(lstWOToBeUpdated.size() > 0) update lstWOToBeUpdated;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        return true;
    }
}