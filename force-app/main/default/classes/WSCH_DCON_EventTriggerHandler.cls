public with sharing class WSCH_DCON_EventTriggerHandler 
{
    public class SVMXException extends Exception {} 
    public static Map<String,String> mapTechSFUser = new Map<String,String>();
    public class techSFSVMXEvents
    {
        public String techId {get; set;}
        public List<Event> lstSFEvents {get; set;}
        public List<SVMXC__SVMX_Event__c> lstSVMXEvents {get; set;}
        
        public techSFSVMXEvents(String techId, List<Event> lstSFEvents, List<SVMXC__SVMX_Event__c> lstSVMXEvents)
        {
            this.techId = techId;
            this.lstSFEvents = lstSFEvents;
            this.lstSVMXEvents = lstSVMXEvents;
        }
        public techSFSVMXEvents() {}   
    }
    public class techSFEvents
    {
        public String techId {get; set;}
        public List<Event> lstSFEvents {get; set;}
                
        public techSFEvents(String techId, List<Event> lstSFEvents)
        {
            this.techId = techId;
            this.lstSFEvents = lstSFEvents;
        }
        public techSFEvents() {}   
    }
    public class techSVMXEvents
    {
        public String techId {get; set;}
        public List<SVMXC__SVMX_Event__c> lstSVMXEvents {get; set;}
        
        public techSVMXEvents(String techId,List<SVMXC__SVMX_Event__c> lstSVMXEvents)
        {
            this.techId = techId;
            this.lstSVMXEvents = lstSVMXEvents;
        }
        public techSVMXEvents() {}   
    }
    public class SVMXEventWrapper  implements Comparable 
    {
        public SVMXC__SVMX_Event__c svmxevent;
        public SVMXEventWrapper (SVMXC__SVMX_Event__c svmxevt) {
        svmxevent = svmxevt;
        }
        public Integer compareTo(Object compareTo) 
        {
            SVMXEventWrapper compareToOppy = (SVMXEventWrapper)compareTo;
            Integer returnValue = 0;
            if (svmxevent.SVMXC__StartDateTime__c > compareToOppy.svmxevent.SVMXC__StartDateTime__c) 
            {
                returnValue = 1;
            } 
            else if (svmxevent.SVMXC__StartDateTime__c < compareToOppy.svmxevent.SVMXC__StartDateTime__c) 
            {
                returnValue = -1;
            }
            return returnValue;      
        }
    }
    public class EventWrapper  implements Comparable 
    {
        public Event sfevent;
        public EventWrapper (Event sfevt) {
        sfevent = sfevt;
        }
        public Integer compareTo(Object compareTo) 
        {
            EventWrapper compareToOppy = (EventWrapper)compareTo;
            Integer returnValue = 0;
            if (sfevent.StartDateTime > compareToOppy.sfevent.StartDateTime) 
            {
                returnValue = 1;
            } 
            else if (sfevent.StartDateTime < compareToOppy.sfevent.StartDateTime) 
            {
                returnValue = -1;
            }
            return returnValue;      
        }
    }
    /***** START: JDM field calculation logic - Updating WorkOder's Schedule Duration *****/
        
        /**
         * Method Name      :   handleSFEventOnInsert
         * Parameters       :   lstSFEvents - List of Salesforce events
         *                      orderStatusValue - SET013 setting value(Module:Dispatch Management Sub Module: Event        Management) which contains order status value for workorder
         * Description      :   This method will update the 'WorkOrder's Scheduled Duration' field upon inserting Salesforce events excluding amount of time getting overlapped.
         * Return Value     :   None
         */
        public static void handleSFEventOnInsert(List<Event> lstSFEvents, String orderStatusValue)
        {
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            Map<String, List<Event>> mapWOSFEvents = new Map<String, List<Event>>();
            System.debug('Initial lstSFEvents:'+ lstSFEvents);
            
            try
            {
                boolean isFieldExist = false;
                //grouping Salesforce Events based on Workorder Ids
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                for(Event evt: lstSFEvents)
                {
                    if(String.valueOf(evt.WhatId) != null && !String.isBlank(String.valueOf(evt.WhatId)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(evt.WhatId).substring(0,3)))
                        {
                            if(mapWOSFEvents.containsKey(evt.WhatId))
                            {
                                mapWOSFEvents.get(evt.WhatId).add(evt);
                            }
                            else
                            {
                                List<Event> tempevt = new List<Event>();
                                tempevt.add(evt);
                                mapWOSFEvents.put(evt.WhatId,tempevt);
                            }
                        }
                    }   
                }
                System.debug('mapWOSFEvents:'+ mapWOSFEvents);
                List<String> lstWoIds = new List<String>();
                lstWoIds.addAll(mapWOSFEvents.keySet());
                /*WOTechSFSVMXEvents having list of salesforce events and servicemax events based on technician for individual Workorder which are available in database.
                Ex: Workorder1  - Technician1 - list of salesforce events, list of servicemax events
                                  Technician2 - list of salesforce events, list of servicemax events    
                    Workorder2  - Technician3 - list of salesforce events, list of servicemax events
                                  Technician4 - list of salesforce events, list of servicemax events */
                
                Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>();
                
                WOTechSFSVMXEvents = getListOfTechSFSVMXEvents(lstWoIds,null);
                                
                Set<String> setownerIds = new Set<String>();
                for(List<Event> lstevt: mapWOSFEvents.values())
                {
                    for(Event evt: lstevt)
                        setownerIds.add(evt.OwnerId);   
                } 
                List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
                lsttech = [Select Id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds];
                                                      
                for(SVMXC__Service_Group_Members__c tech: lsttech)  
                {
                    mapTechSFUser.put(tech.SVMXC__Salesforce_User__c,tech.Id);  
                }
                
                Map<Id,SVMXC__Service_Order__c> WoDetails = new Map<Id,SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
                lstWorkOrders = [SELECT Id, SVMXC__SM_Scheduled_Duration__c,
                                                                SVMXC__SM_Scheduling_Options__c,SVMXC__SM_Unscheduled_Duration__c, SVMXC__SM_Revised_Duration__c,SVMXC__SM_Estimated_Duration__c 
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :mapWOSFEvents.keySet()];
                for(SVMXC__Service_Order__c Wo: lstWorkOrders)
                {
                    WoDetails.put(Wo.Id, Wo);   
                }                   
                //looping thru workorders                                           
                for(String WoId: mapWOSFEvents.keySet())
                {
                    if((WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                          (WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                    {
                    String tempEventObj = JSON.serialize(mapWOSFEvents.get(WoId)[0]);
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(tempEventObj);
                    if(m.keySet().contains('SVMXC__Service_Duration__c'))
                        isFieldExist = true;

                    /*//Check if the WO is having a prefix to verify if it is a valid WOId
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix(); */
                    String objectPrefix = '';
                    if(mapWOSFEvents.get(WoId)[0].WhatId != null)
                        objectPrefix = String.valueOf(mapWOSFEvents.get(WoId)[0].WhatId).substring(0,3);

                    //Check if the WO Id having required prefix - this is to verify that the passed WOId is a salesforce WOId
                    //and check if the event passed is having 'Service_Duration' field, this is to avoid exceptions in the below logic
                    if(woKeyPrefix.equals(objectPrefix) && isFieldExist)
                    {
                        if(WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == 0.0 || WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == null)
                        {
                            throw new SVMXException(system.label.DCON005_TAG071);   
                        }
                        List<techSFSVMXEvents> techExistingEvts = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts1 = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts2 = new List<techSFSVMXEvents>();
                        List<techSFEvents> techIncomingSFEvents = new List<techSFEvents>();
                        Map<String, List<Event>> techIncomingEvents = new Map<String, List<Event>>();
                        if(WOTechSFSVMXEvents != null && WOTechSFSVMXEvents.containsKey(WoId) && WOTechSFSVMXEvents.get(WoId) != null && (WOTechSFSVMXEvents.get(WoId)).size() >0)
                        {
                            techExistingEvts1 = WOTechSFSVMXEvents.get(WoId);
                        }   
                        /*getListTechSFEvents contains salesforce events(which are going to insert) splitted based on technician Ids
                        Ex: Technician1 - list of salesforce events, list of servicemax events
                            Technician2 - list of salesforce events, list of servicemax events  */
                        
                        techIncomingSFEvents = getListTechSFEvents(mapWOSFEvents.get(WoId));
                            
                        for(techSFEvents sfevt: techIncomingSFEvents)
                        {
                            techIncomingEvents.put(sfevt.techId,sfevt.lstSFEvents);
                        } 
                        
                        System.debug('techExistingEvts1:' + techExistingEvts1);
                        System.debug('techIncomingSFEvents:' + techIncomingSFEvents);
                        System.debug('techIncomingEvents:' + techIncomingEvents);
                        //looping thru all techinician having both salesforce and servicemax events from database for workorder.
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {
                            //For workorder,if technician has already events and also new event is inserting for same technician, we will append incoming event to same technicians.
                            if(techIncomingEvents.containsKey(techId_old.techId))
                            {
                                List<SVMXC__SVMX_Event__c> tempsvmx = new List<SVMXC__SVMX_Event__c>();
                                List<Event> tempsf = new List<Event>();
                                if(techId_old.lstSVMXEvents != null && techId_old.lstSVMXEvents.size()>0)
                                    tempsvmx.addAll(techId_old.lstSVMXEvents);
                                if(techId_old.lstSFEvents != null && techId_old.lstSFEvents.size()>0)
                                    tempsf.addAll(techId_old.lstSFEvents);
                                if((techIncomingEvents.get(techId_old.techId)) != null && (techIncomingEvents.get(techId_old.techId)).size() >0 )
                                    tempsf.addAll(techIncomingEvents.get(techId_old.techId));
                                
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,tempsf,tempsvmx);
                                techExistingEvts2.add(tempevt);
                                
                            }
                            //For workorder, if techinician has events in database and which are not inserting events.
                            else
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,techId_old.lstSVMXEvents);
                                techExistingEvts2.add(tempevt);
                            }
                        }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        techExistingEvts.addAll(techExistingEvts2);
                        //For workorder, if technician doesn't have events in database and which are new events to be inserted
                        for(String t1: techIncomingEvents.keySet())
                        {
                            Boolean isFound = false;
                            for(techSFSVMXEvents techId_old: techExistingEvts2)
                            {
                                if(techId_old.techId.equals(t1))
                                {
                                    isFound = true;
                                    System.debug('I am inside');
                                    continue;
                                }
                            }
                            if(!isFound)
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(t1,techIncomingEvents.get(t1),null);
                                techExistingEvts.add(tempevt);
                            }   
                        }
                        //techExistingEvts having all existing and newly inserting events based on technician for WORKORDER
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        //sorting salesforce and servicemax events seperatly based on startdatetime based on technicians for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<Event> sortedSFEvents = sortSFEventbyStartdatetime(t1.lstSFEvents);
                            List<SVMXC__SVMX_Event__c> sortedSVMXEvents = sortSVMXEventbyStartdatetime(t1.lstSVMXEvents);
                            if(t1.lstSFEvents != null && t1.lstSFEvents.size()>0)
                            {
                                t1.lstSFEvents.clear();
                                t1.lstSFEvents.addAll(sortedSFEvents);
                            }   
                            if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size()>0)
                            {
                                t1.lstSVMXEvents.clear();
                                t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                            }   
                        }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        Map<String, List<DCON_AES_Event_WS.StartEndTime>> lstTechEventStartEndtime= new Map<String, List<DCON_AES_Event_WS.StartEndTime>>();
                        //merging both salesforce and servicemax event startdatetime and enddatetime based on technician for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<DCON_AES_Event_WS.StartEndTime> lsEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
                            if(mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents) != null && mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents).size() > 0)
                            {   
                                lsEventStartEndTime = mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents);
                            }   
                            lstTechEventStartEndtime.put(t1.techId,lsEventStartEndTime);
                        }
                        /*lstTechEventStartEndtime having technician and its events(both salesforce and servicemax events) start datetime & end datetime
                        Ex: Technician1 - event1 startdatetime,event1 enddatetime
                                          event2 startdatetime,event2 enddatetime   
                            Technician2 - event3 startdatetime,event1 enddatetime  */
                                                        
                        System.debug('lstTechEventStartEndtime:' + lstTechEventStartEndtime);
                        
                        Map<String, Integer> techSTwithoverlap = new Map<String, Integer>();  
                        //summing the service duration of all events of technician excluding overlapping time for workorder
                        for(String techId: lstTechEventStartEndtime.keySet()) 
                        {   Integer actualdurationfortech = 0;
                            Datetime startDatetime = lstTechEventStartEndtime.get(techId)[0].startTime;
                            Datetime endDatetime = lstTechEventStartEndtime.get(techId)[0].endTime;
                            //looping thru all events to get exact service duration excluding time between two successive events if there is any gap
                            for(DCON_AES_Event_WS.StartEndTime times: lstTechEventStartEndtime.get(techId))
                            {
                                //logic to get actual values
                                if((times.startTime >= startDatetime && times.startTime <= endDatetime) && (times.endTime >= startDatetime))
                                {
                                    if(times.endTime >= endDatetime)
                                    {
                                        endDatetime = times.endTime;
                                    }
                                }
                                else if((times.startTime >= startDatetime && times.startTime >= endDatetime) && (times.endTime >= startDatetime && times.endTime >= endDatetime))
                                {
                                    actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                    startDatetime = times.startTime;
                                    endDatetime = times.endTime;
                                }
                            }
                            //append last service duration                              
                            actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                            
                            techSTwithoverlap.put(techId,actualdurationfortech);
                        }
                        system.debug('techSTwithoverlap:' + techSTwithoverlap);
                                            
                        Integer STforWOwithoverlap = 0; //contains sum of service duration of all events for workorder excluding overlapping time
                        for(String techId: techSTwithoverlap.keySet()) 
                        {
                            STforWOwithoverlap = STforWOwithoverlap + techSTwithoverlap.get(techId);    
                        }
                        SVMXC__Service_Order__c workOrder = WoDetails.get(WoId);
                        
                        if(workOrder.SVMXC__SM_Revised_Duration__c < STforWOwithoverlap)
                        {
                            Integer hrs = Integer.valueOf((STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c)/60);
                            Integer mins = Math.mod(Integer.valueOf(STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c),60);
                            String formattedMins = '';
                            if((String.valueOf(mins)).length() == 1)
                            {
                                formattedMins = '0' + String.valueOf(mins);                         
                            }   
                            else
                            {
                                formattedMins = String.valueOf(mins);   
                            }
                            throw new SVMXException('@' + system.label.DCON005_TAG064 + hrs + ':' + formattedMins + ' '+ system.label.DCON001_TAG494 + system.label.DCON005_TAG032+'@');        
                        }
                        
                        //updating WO's order status field if the WO is changed from fully scheduled to under-scheduled (or less than fully scheduled)
                               
                        if(!String.isBlank(orderStatusValue))
                            {
                                if((workOrder.SVMXC__SM_Unscheduled_Duration__c <= 0) &&
                                        (workOrder.SVMXC__SM_Scheduled_Duration__c > STforWOwithoverlap))
                                    {
                                        workOrder.SVMXC__Order_Status__c = orderStatusValue;
                                    }
                            }
                        if(workOrder.SVMXC__SM_Scheduled_Duration__c == null)
                                workOrder.SVMXC__SM_Scheduled_Duration__c = 0.0;
                        //updating Workorder Scheduled Duration field with sum of all events service duration excluding overlapping time.   
                        workOrder.SVMXC__SM_Scheduled_Duration__c = Double.valueOf(STforWOwithoverlap);
                        lstWO.add(workOrder);
                    }   
                    }
                }
                //while calculating exact service duration of events for workorder, Drive times & overhead times are removed, Since <List> in salesforce all 'Call by reference', we have to add all Drive times & overhead times to events to remains events same. appendDriveTimeOverheadTimeToEvents method adds Drive times & overhead times to events.  
                List<Event> impactedEvents = new List<Event>();
                for(Event evt: lstSFEvents)
                {
                     if(String.valueOf(evt.WhatId) != null && !String.isBlank(String.valueOf(evt.WhatId)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(evt.WhatId).substring(0,3)))
                        {
                            if((WoDetails.get(evt.whatId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                            (WoDetails.get(evt.whatId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                            {
                                impactedEvents.add(evt);    
                            }
                        }
                    }           
                }
                appendDriveTimeOverheadTimeToEvents(impactedEvents,null);  
                System.debug('lstSFEvents after append:' + lstSFEvents);
                //upsert lstWO;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO,COMM_SecurityUtils.Access.Upsertable))   
                {
                    upsert lstWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + 
                ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }
        
        /**
         * Method Name      :   handleSFEventOnUpdate
         * Parameters       :   lstSFEventsNew - List of New Salesforce events to be updated
                                lstSFEventsOld - List of Old Salesforce events updating with new values
         * Description      :   This method will update the 'WorkOrder's Scheduled Duration' field on updating Salesforce events
         * Return Value     :   None
         */
       public static void handleSFEventOnUpdate(List<Event> lstSFEvents, List<Event> lstSFEventsOld, String orderStatusValue)
        {
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            Map<String, List<Event>> mapWOSFEvents = new Map<String, List<Event>>();
            try
            {            
                boolean isFieldExist = false;
                //Check if the WO is having a prefix to verify if it is a valid WOId
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //grouping Salesforce Events based on Workorder Ids
                for(Event evt: lstSFEvents)
                {
                    if(String.valueOf(evt.WhatId) != null && !String.isBlank(String.valueOf(evt.WhatId)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(evt.WhatId).substring(0,3)))
                        {
                            if(mapWOSFEvents.containsKey(evt.WhatId))
                            {
                                mapWOSFEvents.get(evt.WhatId).add(evt);
                            }
                            else
                            {
                                List<Event> tempevt = new List<Event>();
                                tempevt.add(evt);
                                mapWOSFEvents.put(evt.WhatId,tempevt);
                            }
                        }
                    }   
                }
                System.debug('mapWOSFEvents:'+ mapWOSFEvents);
                Set<String> setownerIds = new Set<String>();
                Set<String> toBeupdatedEventIds = new Set<String>();
                for(List<Event> lstevt: mapWOSFEvents.values())
                {
                    for(Event evt: lstevt)
                    {
                        setownerIds.add(evt.OwnerId);
                        toBeupdatedEventIds.add(evt.Id);    
                    
                    }   
                } 
                List<String> lstWoIds = new List<String>();
                lstWoIds.addAll(mapWOSFEvents.keySet());
                /*WOTechSFSVMXEvents having list of salesforce events and servicemax events based on technician for individual Workorder which are available in database EXCLUDING EVENTS GETTING UPDATED.
                Ex: Workorder1  - Technician1 - list of salesforce events, list of servicemax events
                                  Technician2 - list of salesforce events, list of servicemax events    
                    Workorder2  - Technician3 - list of salesforce events, list of servicemax events
                                  Technician4 - list of salesforce events, list of servicemax events */
                
                Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>(); 
                
                WOTechSFSVMXEvents = getListOfTechSFSVMXEvents(lstWoIds,toBeupdatedEventIds);
                
                for(List<Event> lstevt: mapWOSFEvents.values())
                {
                    for(Event evt: lstevt)
                        setownerIds.add(evt.OwnerId);   
                } 
                List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>(); 
                lsttech = [Select Id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds];
                                                      
                for(SVMXC__Service_Group_Members__c tech: lsttech)  
                {
                    mapTechSFUser.put(tech.SVMXC__Salesforce_User__c,tech.Id);  
                }
                
                Map<Id,SVMXC__Service_Order__c> WoDetails = new Map<Id,SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>(); 
                lstWorkOrders = [SELECT Id, SVMXC__SM_Scheduled_Duration__c,
                                                                SVMXC__SM_Scheduling_Options__c,SVMXC__SM_Unscheduled_Duration__c,SVMXC__SM_Revised_Duration__c,SVMXC__SM_Estimated_Duration__c 
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :mapWOSFEvents.keySet()];
                for(SVMXC__Service_Order__c Wo: lstWorkOrders)
                {
                    WoDetails.put(Wo.Id, Wo);   
                }
                                                                
                //looping thru workorders                           
                for(String WoId: mapWOSFEvents.keySet())
                {
                    if((WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                          (WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                    {     
                    String tempEventObj = JSON.serialize(mapWOSFEvents.get(WoId)[0]);
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(tempEventObj);
                    if(m.keySet().contains('SVMXC__Service_Duration__c'))
                        isFieldExist = true;

                    String objectPrefix = '';
                    if(mapWOSFEvents.get(WoId)[0].WhatId != null)
                        objectPrefix = String.valueOf(mapWOSFEvents.get(WoId)[0].WhatId).substring(0,3);

                    //Check if the WO Id having required prefix - this is to verify that the passed WOId is a salesforce WOId
                    //and check if the event passed is having 'Service_Duration' field, this is to avoid exceptions in the below logic
                    if(woKeyPrefix.equals(objectPrefix) && isFieldExist)
                    {
                        if(WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == 0.0 || WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == null)
                        {
                            throw new SVMXException(system.label.DCON005_TAG071);   
                        }
                        List<techSFSVMXEvents> techExistingEvts = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts1 = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts2 = new List<techSFSVMXEvents>();
                        List<techSFEvents> techUpdatingSFEvents = new List<techSFEvents>();
                        Map<String, List<Event>> techUpdatingEvents = new Map<String, List<Event>>();
                        if(WOTechSFSVMXEvents != null && WOTechSFSVMXEvents.containsKey(WoId) && WOTechSFSVMXEvents.get(WoId) != null && (WOTechSFSVMXEvents.get(WoId)).size() > 0)
                        {
                            techExistingEvts1 = WOTechSFSVMXEvents.get(WoId);
                        }   
                        /*getListTechSFEvents contains salesforce events(which are going to update) splitted based on technician Ids
                        Ex: Technician1 - list of salesforce events, list of servicemax events
                            Technician2 - list of salesforce events, list of servicemax events  */
                        
                        techUpdatingSFEvents = getListTechSFEvents(mapWOSFEvents.get(WoId));
                        
                        for(techSFEvents sfevt: techUpdatingSFEvents)
                        {
                            techUpdatingEvents.put(sfevt.techId,sfevt.lstSFEvents);
                        }
                        System.debug('techExistingEvts1:' + techExistingEvts1);
                        System.debug('techUpdatingSFEvents:' + techUpdatingSFEvents);
                        System.debug('techUpdatingEvents:' + techUpdatingEvents);
                        
                        //looping thru all techinician having both salesforce and servicemax events from database for workorder.
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {   
                            //For workorder,if technician has already events and another event is getting upadted for same technician, we will append updating event to same technicians.
                            if(techUpdatingEvents.containsKey(techId_old.techId))
                            {
                                List<SVMXC__SVMX_Event__c> tempsvmx = new List<SVMXC__SVMX_Event__c>();
                                List<Event> tempsf = new List<Event>();
                                if(techId_old.lstSVMXEvents != null && techId_old.lstSVMXEvents.size()>0)
                                    tempsvmx.addAll(techId_old.lstSVMXEvents);
                                if(techId_old.lstSFEvents != null && techId_old.lstSFEvents.size()>0)
                                    tempsf.addAll(techId_old.lstSFEvents);
                                if((techUpdatingEvents.get(techId_old.techId)) != null && (techUpdatingEvents.get(techId_old.techId)).size() >0 )
                                    tempsf.addAll(techUpdatingEvents.get(techId_old.techId));   
                                
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,tempsf,tempsvmx);
                                techExistingEvts2.add(tempevt);
                            }
                            //For workorder, if techinician has events in database and which are not in updating events.
                            else
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,techId_old.lstSVMXEvents);
                                techExistingEvts2.add(tempevt);
                            }
                        }
                        System.debug('techExistingEvts2:' + techExistingEvts2);
                        techExistingEvts.addAll(techExistingEvts2);
                        //For workorder, if technician doesn't have events in database and which are events to be updated
                        for(String t1: techUpdatingEvents.keySet())
                        {
                            Boolean isFound = false;
                            for(techSFSVMXEvents techId_old: techExistingEvts2)
                            {
                                if(techId_old.techId.equals(t1))
                                {
                                    isFound = true;
                                    System.debug('I am inside');
                                    continue;
                                }
                            }
                            if(!isFound)
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(t1,techUpdatingEvents.get(t1),null);
                                techExistingEvts.add(tempevt);
                            }   
                        }
                        //techExistingEvts having all existing and newly upadting events based on technician for WORKORDER
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        //sorting salesforce and servicemax events seperatly based on startdatetime based on technicians for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                            {
                                List<Event> sortedSFEvents = sortSFEventbyStartdatetime(t1.lstSFEvents);
                                List<SVMXC__SVMX_Event__c> sortedSVMXEvents = sortSVMXEventbyStartdatetime(t1.lstSVMXEvents);
                                if(t1.lstSFEvents != null && t1.lstSFEvents.size() > 0)
                                {
                                    t1.lstSFEvents.clear();
                                    t1.lstSFEvents.addAll(sortedSFEvents);  
                                }
                                if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size() > 0)
                                {
                                    t1.lstSVMXEvents.clear();
                                    t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                                }
                            }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        Map<String, List<DCON_AES_Event_WS.StartEndTime>> lstTechEventStartEndtime= new Map<String, List<DCON_AES_Event_WS.StartEndTime>>();
                        //merging both salesforce and servicemax event startdatetime and enddatetime based on technician for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<DCON_AES_Event_WS.StartEndTime> lsEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
                            if(mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents) != null && mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents).size() > 0)
                            {   
                                lsEventStartEndTime = mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents);
                            }
                            lstTechEventStartEndtime.put(t1.techId,lsEventStartEndTime);
                        }
                        /*lstTechEventStartEndtime having technician and its events(both salesforce and servicemax events) start datetime & end datetime
                        Ex: Technician1 - event1 startdatetime,event1 enddatetime
                                          event2 startdatetime,event2 enddatetime   
                            Technician2 - event3 startdatetime,event1 enddatetime  */
                        System.debug('lstTechEventStartEndtime:' + lstTechEventStartEndtime);   
                        
                        //summing the service duration of all events of technician excluding overlapping time for workorder
                        Map<String, Integer> techSTwithoverlap = new Map<String, Integer>();  
                            for(String techId: lstTechEventStartEndtime.keySet()) 
                            {   Integer actualdurationfortech = 0;
                                Datetime startDatetime = lstTechEventStartEndtime.get(techId)[0].startTime;
                                Datetime endDatetime = lstTechEventStartEndtime.get(techId)[0].endTime;
                                //looping thru all events to get exact service duration excluding time between two successive events if there is any gap
                                for(DCON_AES_Event_WS.StartEndTime times: lstTechEventStartEndtime.get(techId))
                                {
                                    if((times.startTime >= startDatetime && times.startTime <= endDatetime) && (times.endTime >= startDatetime))
                                    {
                                        if(times.endTime >= endDatetime)
                                        {
                                            endDatetime = times.endTime;
                                        }
                                    }
                                    else if((times.startTime >= startDatetime && times.startTime >= endDatetime) && (times.endTime >= startDatetime && times.endTime >= endDatetime))
                                    {
                                        actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                        startDatetime = times.startTime;
                                        endDatetime = times.endTime;
                                    }
                                }   
                                 //append last service duration
                                actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                techSTwithoverlap.put(techId,actualdurationfortech);
                            }
                            system.debug('techSTwithoverlap:' + techSTwithoverlap);
                            
                            Integer STforWOwithoverlap = 0; //contains sum of service duration of all events for workorder excluding overlapping time
                            
                            for(String techId: techSTwithoverlap.keySet()) 
                            {
                                STforWOwithoverlap = STforWOwithoverlap + techSTwithoverlap.get(techId);    
                            }
                            SVMXC__Service_Order__c workOrder = WoDetails.get(WoId);
                            //ADDED fix for defect 047483 : Is there any changes in work order field for event then only update the WO
                            Boolean isWoInclude = false;   
                            if(workOrder.SVMXC__SM_Revised_Duration__c < STforWOwithoverlap)
                            {
                                Integer hrs = Integer.valueOf((STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c)/60);
                                Integer mins = Math.mod(Integer.valueOf(STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c),60);
                                String formattedMins = '';
                                if((String.valueOf(mins)).length() == 1)
                                {
                                    formattedMins = '0' + String.valueOf(mins);                         
                                }   
                                else
                                {
                                    formattedMins = String.valueOf(mins);   
                                }
                                throw new SVMXException('@' + system.label.DCON005_TAG064 + hrs + ':' + formattedMins + ' '+ system.label.DCON001_TAG494 + system.label.DCON005_TAG032+'@');
                            }
                            //updating WO's order status field if the WO is changed from fully scheduled to under-scheduled (or less than fully scheduled)
                               
                            if(!String.isBlank(orderStatusValue))
                                {
                                    if((workOrder.SVMXC__SM_Unscheduled_Duration__c <= 0) &&
                                        (workOrder.SVMXC__SM_Scheduled_Duration__c > STforWOwithoverlap))
                                    {
                                        workOrder.SVMXC__Order_Status__c = orderStatusValue;
                                        isWoInclude = true;
                                    }
                                }
                            if(workOrder.SVMXC__SM_Scheduled_Duration__c == null){
                                workOrder.SVMXC__SM_Scheduled_Duration__c = 0.0;
                                isWoInclude = true;
                                }
                            //updating Workorder Scheduled Duration field with sum of all events service duration excluding overlapping time.   
                            if(workOrder.SVMXC__SM_Scheduled_Duration__c != Double.valueOf(STforWOwithoverlap)){
                             workOrder.SVMXC__SM_Scheduled_Duration__c = Double.valueOf(STforWOwithoverlap); 
                             isWoInclude = true;
                            }
                            if(isWoInclude)
                            {
                                lstWO.add(workOrder);
                            }
                            
                    }
                    }   
                }
                //while calculating exact service duration of events for workorder, Drive times & overhead times are removed, Since <List> in salesforce all 'Call by reference', we have to add all Drive times & overhead times to events to remains events same. appendDriveTimeOverheadTimeToEvents method adds Drive times & overhead times to events.     
                List<Event> impactedEvents = new List<Event>();
                for(Event evt: lstSFEvents)
                {
                     if(String.valueOf(evt.WhatId) != null && !String.isBlank(String.valueOf(evt.WhatId)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(evt.WhatId).substring(0,3)))
                        {
                            if((WoDetails.get(evt.whatId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                            (WoDetails.get(evt.whatId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                            {
                                impactedEvents.add(evt);    
                            }
                        }
                    }           
                }
                appendDriveTimeOverheadTimeToEvents(impactedEvents,null);  
                System.debug('lstSFEvents after append:' + lstSFEvents);
                // -CRUD
               if(!lstWO.isEmpty())
               {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO,COMM_SecurityUtils.Access.Upsertable))   
                {
                    upsert lstWO;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
               } 

            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }
        
        /**
         * Method Name      :   handleSFEventOnDelete
         * Parameters       :   List of Salesforce events
         * Description      :   This method will update the 'WorkOrder's Scheduled Duration' field upon deleting Salesforce events
         * Return Value     :   None
         */
        public static void handleSFEventOnDelete(List<Event> lstSFEvents, String orderStatusValue)
        {
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            Map<String, List<Event>> mapWOSFEvents = new Map<String, List<Event>>();
            
            try
            {
                boolean isFieldExist = false;
                //Check if the WO is having a prefix to verify if it is a valid WOId
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //grouping Salesforce Events based on Workorder Ids
                for(Event evt: lstSFEvents)
                {
                    if(String.valueOf(evt.WhatId) != null && !String.isBlank(String.valueOf(evt.WhatId)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(evt.WhatId).substring(0,3)))
                        {       
                            if(mapWOSFEvents.containsKey(evt.WhatId))
                            {
                                mapWOSFEvents.get(evt.WhatId).add(evt);
                            }
                            else
                            {
                                List<Event> tempevt = new List<Event>();
                                tempevt.add(evt);
                                mapWOSFEvents.put(evt.WhatId,tempevt);
                            }
                        }
                    }
                }
                System.debug('mapWOSFEvents:'+ mapWOSFEvents);
                List<String> lstWoIds = new List<String>();
                lstWoIds.addAll(mapWOSFEvents.keySet());
                /*WOTechSFSVMXEvents having list of salesforce events and servicemax events based on technician for individual Workorder which are available in database.
                Ex: Workorder1  - Technician1 - list of salesforce events, list of servicemax events
                                  Technician2 - list of salesforce events, list of servicemax events    
                    Workorder2  - Technician3 - list of salesforce events, list of servicemax events
                                  Technician4 - list of salesforce events, list of servicemax events */
                
                Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>(); 
                
                WOTechSFSVMXEvents = getListOfTechSFSVMXEvents(lstWoIds,null);
                
                Set<String> setownerIds = new Set<String>();
                for(List<Event> lstevt: mapWOSFEvents.values())
                {
                    for(Event evt: lstevt)
                        setownerIds.add(evt.OwnerId);   
                } 
                List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
                lsttech = [Select Id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds];
                                                      
                for(SVMXC__Service_Group_Members__c tech: lsttech)  
                {
                    mapTechSFUser.put(tech.SVMXC__Salesforce_User__c,tech.Id);  
                }
                
                Map<Id,SVMXC__Service_Order__c> WoDetails = new Map<Id,SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
                lstWorkOrders = [SELECT Id, SVMXC__SM_Scheduled_Duration__c,
                                                                SVMXC__SM_Scheduling_Options__c,SVMXC__SM_Unscheduled_Duration__c,SVMXC__SM_Revised_Duration__c,SVMXC__SM_Estimated_Duration__c 
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :mapWOSFEvents.keySet()];
                for(SVMXC__Service_Order__c Wo: lstWorkOrders)
                {
                    WoDetails.put(Wo.Id, Wo);   
                }
                //looping thru workorders                                                   
                for(String WoId: mapWOSFEvents.keySet())
                {
                    if((WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                          (WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                    {     
                    String tempEventObj = JSON.serialize(mapWOSFEvents.get(WoId)[0]);
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(tempEventObj);
                    if(m.keySet().contains('SVMXC__Service_Duration__c'))
                        isFieldExist = true;

                    String objectPrefix = '';
                    if(mapWOSFEvents.get(WoId)[0].WhatId != null)
                        objectPrefix = String.valueOf(mapWOSFEvents.get(WoId)[0].WhatId).substring(0,3);

                    //Check if the WO Id having required prefix - this is to verify that the passed WOId is a salesforce WOId
                    //and check if the event passed is having 'Service_Duration' field, this is to avoid exceptions in the below logic
                    if(woKeyPrefix.equals(objectPrefix) && isFieldExist)
                    {
                        List<techSFSVMXEvents> techExistingEvts = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts1 = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts2 = new List<techSFSVMXEvents>();
                        List<techSFEvents> techdeletingSFEvents = new List<techSFEvents>();
                        Map<String, List<Event>> techdeletingEvents = new Map<String, List<Event>>();
                        if(WOTechSFSVMXEvents != null && WOTechSFSVMXEvents.containsKey(WoId) && WOTechSFSVMXEvents.get(WoId) != null && (WOTechSFSVMXEvents.get(WoId)).size() >0)
                        {
                            techExistingEvts1 = WOTechSFSVMXEvents.get(WoId);
                        }
                        
                        /*getListTechSFEventsForDelete contains salesforce events(which are going to delete) splitted based on technician Ids
                        Ex: Technician1 - list of salesforce events, list of servicemax events
                            Technician2 - list of salesforce events, list of servicemax events  */
                        
                        techdeletingSFEvents = getListTechSFEventsForDelete(mapWOSFEvents.get(WoId));
                                                
                        for(techSFEvents sfevt: techdeletingSFEvents)
                        {
                            techdeletingEvents.put(sfevt.techId,sfevt.lstSFEvents);
                        }
                        System.debug('techExistingEvts1:' + techExistingEvts1);
                        System.debug('techdeletingSFEvents:' + techdeletingSFEvents);
                        System.debug('techdeletingEvents:' + techdeletingEvents);
                        //looping thru all techinician having both salesforce and servicemax events from database for workorder.
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {   
                            List<Event> existingEvents = new List<Event>();
                            List<Event> deletingEvents = new List<Event>();
                            List<Event> tempsf = new List<Event>();
                            List<Event> tempsf1 = new List<Event>();
                            if(techdeletingEvents.containsKey(techId_old.techId))
                            {
                                existingEvents.addAll(techId_old.lstSFEvents);
                                deletingEvents.addAll(techdeletingEvents.get(techId_old.techId));
                                //For workorder,if technician has already events and event is deleting for same technician, we will remove that event which is going to delete for same technicians.
                                for(Event existingevt: existingEvents)
                                {
                                    Boolean isFound = false;
                                    for(Event deletingevt: deletingEvents)
                                    {   
                                        if(existingevt.Id == deletingevt.Id) 
                                        {
                                            //if((String.valueOf(existingevt.Id)).equals(String.valueOf(deletingevt.Id)))
                                            System.debug('I am in delete event');   
                                            isFound = true; 
                                            continue;
                                        }
                                    }
                                    if(!isFound)
                                    {
                                        tempsf.add(existingevt);    
                                    }
                                }
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,tempsf,techId_old.lstSVMXEvents);
                                techExistingEvts2.add(tempevt);
                            }
                        }
                        System.debug('techExistingEvts2:' + techExistingEvts2);
                        techExistingEvts.addAll(techExistingEvts2);
                        //For workorder, if technician have events in database and which are not in deleting list
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {
                            Boolean isFoundTech = false;
                            for(techSFSVMXEvents techId_upt: techExistingEvts2)
                            {
                                if(techId_old.techId.equals(techId_upt.techId))
                                {
                                    isFoundTech = true;
                                    System.debug('I am inside delete tech event');
                                    continue;   
                                }
                            }
                            If(!isFoundTech)
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,techId_old.lstSVMXEvents);
                                techExistingEvts.add(tempevt);  
                            }
                        }
                        //techExistingEvts having all existing and excluding deleting events based on technician for WORKORDER
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        //sorting salesforce and servicemax events seperatly based on startdatetime based on technicians for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                            {
                                List<Event> sortedSFEvents = new List<Event>();
                                List<SVMXC__SVMX_Event__c> sortedSVMXEvents = new List<SVMXC__SVMX_Event__c>();
                                if(t1.lstSFEvents != null && t1.lstSFEvents.size()>0)
                                {
                                    sortedSFEvents.addAll(sortSFEventbyStartdatetime(t1.lstSFEvents));
                                    t1.lstSFEvents.clear();
                                    t1.lstSFEvents.addAll(sortedSFEvents);
                                }
                                if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size()>0)
                                {   
                                    sortedSVMXEvents.addAll(sortSVMXEventbyStartdatetime(t1.lstSVMXEvents));
                                    t1.lstSVMXEvents.clear();
                                    t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                                }   
                            }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        Map<String, List<DCON_AES_Event_WS.StartEndTime>> lstTechEventStartEndtime= new Map<String, List<DCON_AES_Event_WS.StartEndTime>>();
                        //merging both salesforce and servicemax event startdatetime and enddatetime based on technician for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<DCON_AES_Event_WS.StartEndTime> lsEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
                            if(mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents) != null && mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents).size() > 0)
                            {   
                                lsEventStartEndTime = mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents);
                            }
                            lstTechEventStartEndtime.put(t1.techId,lsEventStartEndTime);
                        }
                        /*lstTechEventStartEndtime having technician and its events(both salesforce and servicemax events) start datetime & end datetime
                        Ex: Technician1 - event1 startdatetime,event1 enddatetime
                                          event2 startdatetime,event2 enddatetime   
                            Technician2 - event3 startdatetime,event1 enddatetime  */
                        System.debug('lstTechEventStartEndtime:' + lstTechEventStartEndtime);   
                                                
                        Map<String, Integer> techSTwithoverlap = new Map<String, Integer>();  
                        //summing the service duration of all events of technician excluding overlapping time for workorder
                            for(String techId: lstTechEventStartEndtime.keySet()) 
                            {   Integer actualdurationfortech = 0;
                                if(lstTechEventStartEndtime.get(techId) != null && lstTechEventStartEndtime.get(techId).size() > 0)
                                {
                                    Datetime startDatetime = lstTechEventStartEndtime.get(techId)[0].startTime;
                                    Datetime endDatetime = lstTechEventStartEndtime.get(techId)[0].endTime;
                                    //looping thru all events to get exact service duration excluding time between two successive events if there is any gap
                                    for(DCON_AES_Event_WS.StartEndTime times: lstTechEventStartEndtime.get(techId))
                                    {
                                        //logic to get actual values
                                        if((times.startTime >= startDatetime && times.startTime <= endDatetime) && (times.endTime >= startDatetime))
                                        {
                                            if(times.endTime >= endDatetime)
                                            {
                                                endDatetime = times.endTime;
                                            }
                                        }
                                        else if((times.startTime >= startDatetime && times.startTime >= endDatetime) && (times.endTime >= startDatetime && times.endTime >= endDatetime))
                                        {
                                            actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                            startDatetime = times.startTime;
                                            endDatetime = times.endTime;
                                        }
                                    }   
                                    //append last service duration      
                                    actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                }
                                techSTwithoverlap.put(techId,actualdurationfortech);
                            }
                            system.debug('techSTwithoverlap:' + techSTwithoverlap);
                            
                            
                            Integer STforWOwithoverlap = 0;//contains sum of service duration of all events for workorder excluding overlapping time
                            for(String techId: techSTwithoverlap.keySet()) 
                            {
                                STforWOwithoverlap = STforWOwithoverlap + techSTwithoverlap.get(techId);    
                            }
                            SVMXC__Service_Order__c workOrder = WoDetails.get(WoId);
                            //updating WO's order status field if the WO is changed from fully scheduled to under-scheduled (or less than fully scheduled)
                               
                            if(!String.isBlank(orderStatusValue))
                                {
                                    if((workOrder.SVMXC__SM_Unscheduled_Duration__c <= 0) &&
                                        (workOrder.SVMXC__SM_Scheduled_Duration__c > STforWOwithoverlap))
                                    {
                                        workOrder.SVMXC__Order_Status__c = orderStatusValue;
                                    }
                                }
                            if(workOrder.SVMXC__SM_Scheduled_Duration__c == null)
                                workOrder.SVMXC__SM_Scheduled_Duration__c = 0.0;
                            //updating Workorder Scheduled Duration field with sum of all events service duration excluding overlapping time.
                            workOrder.SVMXC__SM_Scheduled_Duration__c = Double.valueOf(STforWOwithoverlap); 
                            lstWO.add(workOrder);                       
                    }
                    }
                }   
                //upsert lstWO;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO,COMM_SecurityUtils.Access.Upsertable))   
                {
                    upsert lstWO;//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }   
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }

        /**
         * Method Name      :   handleSMAXEventOnInsert
         * Parameters       :   List of ServiceMax events
         * Description      :   This method will update the 'WorkOrder's Scheduled Duration' field upon inserting ServiceMax events
         * Return Value     :   None
         */
        public static void handleSMAXEventOnInsert(List<SVMXC__SVMX_Event__c> lstSVMXEvents, String orderStatusValue)
        {
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            Map<String, List<SVMXC__SVMX_Event__c>> mapWOSVMXEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
            
            try
            {
                boolean isFieldExist = false;
                //Check if the WO is having a prefix to verify if it is a valid WOId
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //grouping ServiceMax Events based on Workorder Ids
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    if(String.valueOf(svmxevt.SVMXC__Service_Order__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__Service_Order__c)) && String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                        {
                            if(mapWOSVMXEvents.containsKey(svmxevt.SVMXC__WhatId__c))
                            {
                                mapWOSVMXEvents.get(svmxevt.SVMXC__WhatId__c).add(svmxevt);
                            }
                            else
                            {
                                List<SVMXC__SVMX_Event__c> tempsvmxevt = new List<SVMXC__SVMX_Event__c>();
                                tempsvmxevt.add(svmxevt);
                                mapWOSVMXEvents.put(svmxevt.SVMXC__WhatId__c,tempsvmxevt);
                            }
                        }
                    }
                }
                System.debug('mapWOSVMXEvents:'+ mapWOSVMXEvents);
                List<String> lstWoIds = new List<String>();
                lstWoIds.addAll(mapWOSVMXEvents.keySet());
                /*WOTechSFSVMXEvents having list of salesforce events and servicemax events based on technician for individual Workorder which are available in database.
                Ex: Workorder1  - Technician1 - list of salesforce events, list of servicemax events
                                  Technician2 - list of salesforce events, list of servicemax events    
                    Workorder2  - Technician3 - list of salesforce events, list of servicemax events
                                  Technician4 - list of salesforce events, list of servicemax events */
                
                Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>(); 
                
                WOTechSFSVMXEvents = getListOfTechSFSVMXEvents(lstWoIds,null);
                
                Map<Id,SVMXC__Service_Order__c> WoDetails = new Map<Id,SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
                lstWorkOrders = [SELECT Id, SVMXC__SM_Scheduled_Duration__c,
                                                                SVMXC__SM_Scheduling_Options__c,SVMXC__SM_Unscheduled_Duration__c,SVMXC__SM_Revised_Duration__c,SVMXC__SM_Estimated_Duration__c 
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :mapWOSVMXEvents.keySet()];
                System.debug('wo details before update:' + lstWorkOrders);                                              
                for(SVMXC__Service_Order__c Wo: lstWorkOrders)
                {
                    WoDetails.put(Wo.Id, Wo);   
                }
                
                //looping thru workorders           
                for(String WoId: mapWOSVMXEvents.keySet())
                {
                    if((WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                          (WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                    {
                    String tempEventObj = JSON.serialize(mapWOSVMXEvents.get(WoId)[0]);
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(tempEventObj);
                    if(m.keySet().contains('SVMXC__Service_Duration__c'))
                        isFieldExist = true;

                    String objectPrefix = '';
                    if(mapWOSVMXEvents.get(WoId)[0].SVMXC__WhatId__c != null)
                        objectPrefix = String.valueOf(mapWOSVMXEvents.get(WoId)[0].SVMXC__WhatId__c).substring(0,3);

                    //Check if the WO Id having required prefix - this is to verify that the passed WOId is a salesforce WOId
                    //and check if the event passed is having 'Service_Duration' field, this is to avoid exceptions in the below logic
                    if(woKeyPrefix.equals(objectPrefix) && isFieldExist)
                    {
                        if(WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == 0.0 || WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == null)
                        {   
                            throw new SVMXException(system.label.DCON005_TAG071);   
                        }
                        List<techSFSVMXEvents> techExistingEvts = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts1 = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts2 = new List<techSFSVMXEvents>();
                        List<techSVMXEvents> techIncomingSVMXEvents = new List<techSVMXEvents>();
                        Map<String, List<SVMXC__SVMX_Event__c>> techIncomingEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
                        if(WOTechSFSVMXEvents != null && WOTechSFSVMXEvents.containsKey(WoId) && WOTechSFSVMXEvents.get(WoId) != null && (WOTechSFSVMXEvents.get(WoId)).size() > 0)
                        {
                            techExistingEvts1 = WOTechSFSVMXEvents.get(WoId);
                        }   
                        /*getListtechSVMXEvents contains servicemax events(which are going to insert) splitted based on technician Ids
                        Ex: Technician1 - list of salesforce events, list of servicemax events
                            Technician2 - list of salesforce events, list of servicemax events  */
                        
                        techIncomingSVMXEvents = getListtechSVMXEvents(mapWOSVMXEvents.get(WoId));
                        
                        for(techSVMXEvents svmxevt: techIncomingSVMXEvents)
                        {
                            techIncomingEvents.put(svmxevt.techId,svmxevt.lstSVMXEvents);
                        } 
                        
                        System.debug('techExistingEvts1:' + techExistingEvts1);
                        System.debug('techIncomingSVMXEvents:' + techIncomingSVMXEvents);
                        System.debug('techIncomingEvents:' + techIncomingEvents);
                        //looping thru all techinician having both salesforce and servicemax events from database for workorder.
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                            {
                                //For workorder,if technician has already events and also new event is inserting for same technician, we will append incoming event to same technicians.
                                if(techIncomingEvents.containsKey(techId_old.techId))
                                {
                                    List<SVMXC__SVMX_Event__c> tempsvmx = new List<SVMXC__SVMX_Event__c>();
                                    List<Event> tempsf = new List<Event>();
                                    if(techId_old.lstSVMXEvents != null && techId_old.lstSVMXEvents.size()>0)
                                        tempsvmx.addAll(techId_old.lstSVMXEvents);
                                    if(techId_old.lstSFEvents != null && techId_old.lstSFEvents.size()>0)
                                        tempsf.addAll(techId_old.lstSFEvents);
                                    if((techIncomingEvents.get(techId_old.techId)) != null && (techIncomingEvents.get(techId_old.techId)).size() >0 )
                                        tempsvmx.addAll(techIncomingEvents.get(techId_old.techId));
                                        
                                    techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,tempsf,tempsvmx);
                                    techExistingEvts2.add(tempevt);
                                }   
                                //For workorder, if techinician has events in database and there is no inserting events.
                                else
                                {
                                    techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,techId_old.lstSVMXEvents);
                                    techExistingEvts2.add(tempevt);
                                }
                            }   
                        System.debug('techExistingEvts2:' + techExistingEvts2);
                        techExistingEvts.addAll(techExistingEvts2);
                        //For workorder, if technician doesn't have events in database and there are new events to be inserted
                        for(String t1: techIncomingEvents.keySet())
                        {
                            Boolean isFound = false;
                            for(techSFSVMXEvents techId_old: techExistingEvts2)
                            {
                                if(techId_old.techId.equals(t1))
                                {
                                    isFound = true;
                                    System.debug('I am inside');
                                    continue;
                                }
                            }
                            if(!isFound)
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(t1,null,techIncomingEvents.get(t1));
                                techExistingEvts.add(tempevt);
                            }   
                        }
                        //techExistingEvts having all existing and newly inserting events based on technician for WORKORDER
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        //sorting salesforce and servicemax events seperatly based on startdatetime based on technicians for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<Event> sortedSFEvents = sortSFEventbyStartdatetime(t1.lstSFEvents);
                            List<SVMXC__SVMX_Event__c> sortedSVMXEvents = sortSVMXEventbyStartdatetime(t1.lstSVMXEvents);
                            if(t1.lstSFEvents != null && t1.lstSFEvents.size()>0)
                            {
                                t1.lstSFEvents.clear();
                                t1.lstSFEvents.addAll(sortedSFEvents);
                            }   
                            if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size()>0)
                            {
                                t1.lstSVMXEvents.clear();
                                t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                            }
                        }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        Map<String, List<DCON_AES_Event_WS.StartEndTime>> lstTechEventStartEndtime= new Map<String, List<DCON_AES_Event_WS.StartEndTime>>();
                        //merging both salesforce and servicemax event startdatetime and enddatetime based on technician for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<DCON_AES_Event_WS.StartEndTime> lsEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
                            if(mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents) != null && mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents).size() > 0)
                            {   
                                lsEventStartEndTime = mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents);
                            }
                            lstTechEventStartEndtime.put(t1.techId,lsEventStartEndTime);
                        }
                        /*lstTechEventStartEndtime having technician and its events(both salesforce and servicemax events) start datetime & end datetime
                        Ex: Technician1 - event1 startdatetime,event1 enddatetime
                                          event2 startdatetime,event2 enddatetime   
                            Technician2 - event3 startdatetime,event1 enddatetime  */
                        System.debug('lstTechEventStartEndtime:' + lstTechEventStartEndtime);
                        
                        Map<String, Integer> techSTwithoverlap = new Map<String, Integer>();  
                        //summing the service duration of all events of technician excluding overlapping time for workorder
                        for(String techId: lstTechEventStartEndtime.keySet()) 
                        {   Integer actualdurationfortech = 0;
                            Datetime startDatetime = lstTechEventStartEndtime.get(techId)[0].startTime;
                            Datetime endDatetime = lstTechEventStartEndtime.get(techId)[0].endTime;
                            //looping thru all events to get exact service duration excluding time between two successive events if there is any gap
                            for(DCON_AES_Event_WS.StartEndTime times: lstTechEventStartEndtime.get(techId))
                            {
                                //logic to get actual values
                                if((times.startTime >= startDatetime && times.startTime <= endDatetime) && (times.endTime >= startDatetime))
                                {
                                    if(times.endTime >= endDatetime)
                                    {
                                        endDatetime = times.endTime;
                                    }
                                }
                                else if((times.startTime >= startDatetime && times.startTime >= endDatetime) && (times.endTime >= startDatetime && times.endTime >= endDatetime))
                                {
                                    actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                    startDatetime = times.startTime;
                                    endDatetime = times.endTime;
                                    System.debug('actualdurationfortech***:'+ actualdurationfortech);
                                }
                            }   
                            //append last service duration  
                            actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                            System.debug('actualdurationfortech&&&:'+ actualdurationfortech);
                            techSTwithoverlap.put(techId,actualdurationfortech);
                        }
                        system.debug('techSTwithoverlap:' + techSTwithoverlap);
                        
                        Integer STforWOwithoverlap = 0;  //contains sum of service duration of all events for workorder excluding overlapping time
                        for(String techId: techSTwithoverlap.keySet()) 
                        {
                            STforWOwithoverlap = STforWOwithoverlap + techSTwithoverlap.get(techId);    
                        }
                        SVMXC__Service_Order__c workOrder = WoDetails.get(WoId);
                        
                        if(workOrder.SVMXC__SM_Revised_Duration__c < STforWOwithoverlap)
                        {
                            Integer hrs = Integer.valueOf((STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c)/60);
                            Integer mins = Math.mod(Integer.valueOf(STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c),60);
                            String formattedMins = '';
                            if((String.valueOf(mins)).length() == 1)
                            {
                                formattedMins = '0' + String.valueOf(mins);                         
                            }   
                            else
                            {
                                formattedMins = String.valueOf(mins);   
                            }
                            throw new SVMXException('@' + system.label.DCON005_TAG064 + hrs + ':' + formattedMins + ' '+ system.label.DCON001_TAG494 + system.label.DCON005_TAG032+'@');
                        }
                        //updating WO's order status field if the WO is changed from fully scheduled to under-scheduled (or less than fully scheduled)
                                
                        if(!String.isBlank(orderStatusValue))
                            {
                                if((workOrder.SVMXC__SM_Unscheduled_Duration__c <= 0) &&
                                        (workOrder.SVMXC__SM_Scheduled_Duration__c > STforWOwithoverlap))
                                    {
                                        workOrder.SVMXC__Order_Status__c = orderStatusValue;
                                    }
                            }
                            
                        if(workOrder.SVMXC__SM_Scheduled_Duration__c == null)
                                workOrder.SVMXC__SM_Scheduled_Duration__c = 0.0;
                        //updating Workorder Scheduled Duration field with sum of all events service duration excluding overlapping time.       
                        workOrder.SVMXC__SM_Scheduled_Duration__c = Double.valueOf(STforWOwithoverlap);
                        lstWO.add(workOrder);
                    }   
                    }
                }
                //while calculating exact service duration of events for workorder, Drive times & overhead times are removed, Since <List> in salesforce all 'Call by reference', we have to add all Drive times & overhead times to events to remains events same. appendDriveTimeOverheadTimeToEvents method adds Drive times & overhead times to events. 
                List<SVMXC__SVMX_Event__c> impactedEvents = new List<SVMXC__SVMX_Event__c>();
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    if(String.valueOf(svmxevt.SVMXC__Service_Order__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__Service_Order__c)) && String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                        {
                            if((WoDetails.get(svmxevt.SVMXC__WhatId__c).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                            (WoDetails.get(svmxevt.SVMXC__WhatId__c).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                                {
                                    impactedEvents.add(svmxevt);    
                                }   
                        }
                    }       
                }
                appendDriveTimeOverheadTimeToEvents(null,impactedEvents);  
                System.debug('lstSVMXEvents after append:' + lstSVMXEvents);    
                //upsert lstWO;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO,COMM_SecurityUtils.Access.Upsertable))   
                {
                    upsert lstWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + 
                ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }
        
        /**
         * Method Name      :   handleSMAXEventOnUpdate
         * Parameters       :   lstSMEventsNew - List of New ServiceMax events to be updated
                                lstSMEventsOld - List of Old ServiceMax events updating with new values
         * Description      :   This method will update the 'WorkOrder's Scheduled Duration' field on updating ServiceMax events
         * Return Value     :   None
         */
        public static void handleSMAXEventOnUpdate(List<SVMXC__SVMX_Event__c> lstSVMXEvents, List<SVMXC__SVMX_Event__c> lstSMEventsOld, String orderStatusValue)
        {
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            Map<String, List<SVMXC__SVMX_Event__c>> mapWOSVMXEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
            try
            {            
                boolean isFieldExist = false;
                //Check if the WO is having a prefix to verify if it is a valid WOId
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //grouping servicemax Events based on Workorder Ids
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    if(String.valueOf(svmxevt.SVMXC__Service_Order__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__Service_Order__c)) && String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                        {
                            if(mapWOSVMXEvents.containsKey(svmxevt.SVMXC__WhatId__c))
                            {
                                mapWOSVMXEvents.get(svmxevt.SVMXC__WhatId__c).add(svmxevt);
                            }
                            else
                            {
                                List<SVMXC__SVMX_Event__c> tempsvmxevt = new List<SVMXC__SVMX_Event__c>();
                                tempsvmxevt.add(svmxevt);
                                mapWOSVMXEvents.put(svmxevt.SVMXC__WhatId__c,tempsvmxevt);
                            }
                        }
                    }
                }
                System.debug('mapWOSVMXEvents:'+ mapWOSVMXEvents);
                List<String> lstWoIds = new List<String>();
                lstWoIds.addAll(mapWOSVMXEvents.keySet());
                
                Set<String> toBeupdatedEventIds = new Set<String>();
                for(List<SVMXC__SVMX_Event__c> lstsvmxevt: mapWOSVMXEvents.values())
                {
                    for(SVMXC__SVMX_Event__c svmxevt: lstsvmxevt)
                    {
                        toBeupdatedEventIds.add(svmxevt.Id);    
                    
                    }   
                } 
                /*WOTechSFSVMXEvents having list of salesforce events and servicemax events based on technician for individual Workorder which are available in database EXCLUDING EVENTS GETTING UPDATED.
                Ex: Workorder1  - Technician1 - list of salesforce events, list of servicemax events
                                  Technician2 - list of salesforce events, list of servicemax events    
                    Workorder2  - Technician3 - list of salesforce events, list of servicemax events
                                  Technician4 - list of salesforce events, list of servicemax events */
                
                Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>();
                
                WOTechSFSVMXEvents = getListOfTechSFSVMXEvents(lstWoIds,toBeupdatedEventIds);
                
                Map<Id,SVMXC__Service_Order__c> WoDetails = new Map<Id,SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
                lstWorkOrders = [SELECT Id, SVMXC__SM_Scheduled_Duration__c,
                                                                SVMXC__SM_Scheduling_Options__c,SVMXC__SM_Unscheduled_Duration__c, SVMXC__SM_Revised_Duration__c,SVMXC__SM_Estimated_Duration__c 
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :mapWOSVMXEvents.keySet()];
                for(SVMXC__Service_Order__c Wo: lstWorkOrders)
                {
                    WoDetails.put(Wo.Id, Wo);   
                }
                                                                
                //looping thru workorders                                                   
                for(String WoId: mapWOSVMXEvents.keySet())
                {
                    if((WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                          (WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                    {     
                    String tempEventObj = JSON.serialize(mapWOSVMXEvents.get(WoId)[0]);
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(tempEventObj);
                    if(m.keySet().contains('SVMXC__Service_Duration__c'))
                        isFieldExist = true;

                    String objectPrefix = '';
                    if(mapWOSVMXEvents.get(WoId)[0].SVMXC__WhatId__c != null)
                        objectPrefix = String.valueOf(mapWOSVMXEvents.get(WoId)[0].SVMXC__WhatId__c).substring(0,3);

                    //Check if the WO Id having required prefix - this is to verify that the passed WOId is a salesforce WOId
                    //and check if the event passed is having 'Service_Duration' field, this is to avoid exceptions in the below logic
                    if(woKeyPrefix.equals(objectPrefix) && isFieldExist)
                    {
                        if(WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == 0.0 || WoDetails.get(WoId).SVMXC__SM_Estimated_Duration__c == null)
                        {
                            throw new SVMXException(system.label.DCON005_TAG071);   
                        }
                        List<techSFSVMXEvents> techExistingEvts = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts1 = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts2 = new List<techSFSVMXEvents>();
                        List<techSVMXEvents> techUpdatingSVMXEvents = new List<techSVMXEvents>();
                        Map<String, List<SVMXC__SVMX_Event__c>> techUpdatingEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
                        if(WOTechSFSVMXEvents != null && WOTechSFSVMXEvents.containsKey(WoId) && WOTechSFSVMXEvents.get(WoId) != null && (WOTechSFSVMXEvents.get(WoId)).size() > 0)
                        {
                            techExistingEvts1 = WOTechSFSVMXEvents.get(WoId);
                        }   
                        /*getListTechSVMXEvents contains servicemax events(which are going to update) splitted based on technician Ids
                        Ex: Technician1 - list of salesforce events, list of servicemax events
                            Technician2 - list of salesforce events, list of servicemax events  */
                        
                        techUpdatingSVMXEvents = getListTechSVMXEvents(mapWOSVMXEvents.get(WoId));
                                                
                        for(techSVMXEvents sfevt: techUpdatingSVMXEvents)
                        {
                            techUpdatingEvents.put(sfevt.techId,sfevt.lstSVMXEvents);
                        }
                        System.debug('techExistingEvts1:' + techExistingEvts1);
                        System.debug('techUpdatingSVMXEvents:' + techUpdatingSVMXEvents);
                        System.debug('techUpdatingEvents:' + techUpdatingEvents);
                        //looping thru all techinician having both salesforce and servicemax events from database for workorder.
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {   
                            //For workorder,if technician has already events and another event is getting upadted for same technician, we will append updating event to same technicians.
                            if(techUpdatingEvents.containsKey(techId_old.techId))
                            {
                                List<SVMXC__SVMX_Event__c> tempsvmx = new List<SVMXC__SVMX_Event__c>();
                                List<Event> tempsf = new List<Event>();
                                if(techId_old.lstSVMXEvents != null && techId_old.lstSVMXEvents.size()>0)
                                    tempsvmx.addAll(techId_old.lstSVMXEvents);
                                if(techId_old.lstSFEvents != null && techId_old.lstSFEvents.size()>0)
                                    tempsf.addAll(techId_old.lstSFEvents);
                                if((techUpdatingEvents.get(techId_old.techId)) != null &&   (techUpdatingEvents.get(techId_old.techId)).size() >0 )
                                        tempsvmx.addAll(techUpdatingEvents.get(techId_old.techId));
                                        
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,tempsf,tempsvmx);
                                techExistingEvts2.add(tempevt);
                            }
                            //For workorder, if techinician has events in database and which are not in updating events.
                            else
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,techId_old.lstSVMXEvents);
                                techExistingEvts2.add(tempevt);
                            }
                        }
                        System.debug('techExistingEvts2:' + techExistingEvts2);
                        techExistingEvts.addAll(techExistingEvts2);
                        //For workorder, if technician doesn't have events in database and which are events to be updated                       
                        for(String t1: techUpdatingEvents.keySet())
                        {
                            Boolean isFound = false;
                            for(techSFSVMXEvents techId_old: techExistingEvts2)
                            {
                                if(techId_old.techId.equals(t1))
                                {
                                    isFound = true;
                                    System.debug('I am inside');
                                    continue;
                                }
                            }
                            if(!isFound)
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(t1,null,techUpdatingEvents.get(t1));
                                techExistingEvts.add(tempevt);
                            }   
                        }
                        //techExistingEvts having all existing and newly upadting events based on technician for WORKORDER
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        //sorting salesforce and servicemax events seperatly based on startdatetime based on technicians for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                            {
                                List<Event> sortedSFEvents = sortSFEventbyStartdatetime(t1.lstSFEvents);
                                List<SVMXC__SVMX_Event__c> sortedSVMXEvents = sortSVMXEventbyStartdatetime(t1.lstSVMXEvents);
                                if(t1.lstSFEvents != null && t1.lstSFEvents.size()>0)
                                {
                                    t1.lstSFEvents.clear();
                                    t1.lstSFEvents.addAll(sortedSFEvents);
                                }
                                if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size()>0)
                                {   
                                    t1.lstSVMXEvents.clear();
                                    t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                                }
                            }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        Map<String, List<DCON_AES_Event_WS.StartEndTime>> lstTechEventStartEndtime= new Map<String, List<DCON_AES_Event_WS.StartEndTime>>();
                        //merging both salesforce and servicemax event startdatetime and enddatetime based on technician for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<DCON_AES_Event_WS.StartEndTime> lsEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
                            if(mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents) != null && mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents).size() > 0)
                            {   
                                lsEventStartEndTime = mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents);
                            }
                            lstTechEventStartEndtime.put(t1.techId,lsEventStartEndTime);
                        }
                        /*lstTechEventStartEndtime having technician and its events(both salesforce and servicemax events) start datetime & end datetime
                        Ex: Technician1 - event1 startdatetime,event1 enddatetime
                                          event2 startdatetime,event2 enddatetime   
                            Technician2 - event3 startdatetime,event1 enddatetime  */
                        System.debug('lstTechEventStartEndtime:' + lstTechEventStartEndtime);   
                        
                        //summing the service duration of all events of technician excluding overlapping time for workorder
                        Map<String, Integer> techSTwithoverlap = new Map<String, Integer>();  
                            for(String techId: lstTechEventStartEndtime.keySet()) 
                            {   Integer actualdurationfortech = 0;
                                Datetime startDatetime = lstTechEventStartEndtime.get(techId)[0].startTime;
                                Datetime endDatetime = lstTechEventStartEndtime.get(techId)[0].endTime;
                                //looping thru all events to get exact service duration excluding time between two successive events if there is any gap
                                for(DCON_AES_Event_WS.StartEndTime times: lstTechEventStartEndtime.get(techId))
                                {
                                    //logic to get actual values
                                    if((times.startTime >= startDatetime && times.startTime <= endDatetime) && (times.endTime >= startDatetime))
                                    {
                                        if(times.endTime >= endDatetime)
                                        {
                                            endDatetime = times.endTime;
                                        }
                                    }
                                    else if((times.startTime >= startDatetime && times.startTime >= endDatetime) && (times.endTime >= startDatetime && times.endTime >= endDatetime))
                                    {
                                        actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                        startDatetime = times.startTime;
                                        endDatetime = times.endTime;
                                    }
                                }   
                                //append last service duration
                                actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                techSTwithoverlap.put(techId,actualdurationfortech);
                            }
                            system.debug('techSTwithoverlap:' + techSTwithoverlap);
                            
                            Integer STforWOwithoverlap = 0; //contains sum of service duration of all events for workorder excluding overlapping time
                            for(String techId: techSTwithoverlap.keySet()) 
                            {
                                STforWOwithoverlap = STforWOwithoverlap + techSTwithoverlap.get(techId);    
                            }
                            SVMXC__Service_Order__c workOrder = WoDetails.get(WoId);
                            
                            if(workOrder.SVMXC__SM_Revised_Duration__c < STforWOwithoverlap)
                            {
                                Integer hrs = Integer.valueOf((STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c)/60);
                                Integer mins = Math.mod(Integer.valueOf(STforWOwithoverlap - workOrder.SVMXC__SM_Revised_Duration__c),60);
                                String formattedMins = '';
                                if((String.valueOf(mins)).length() == 1)
                                {
                                    formattedMins = '0' + String.valueOf(mins);                         
                                }   
                                else
                                {
                                    formattedMins = String.valueOf(mins);   
                                }
                                throw new SVMXException('@' + system.label.DCON005_TAG064 + hrs + ':' + formattedMins + ' '+ system.label.DCON001_TAG494 + system.label.DCON005_TAG032+'@');
                            }
                            //updating WO's order status field if the WO is changed from fully scheduled to under-scheduled (or less than fully scheduled)
                                
                            if(!String.isBlank(orderStatusValue))
                                {
                                    if((workOrder.SVMXC__SM_Unscheduled_Duration__c <= 0) &&
                                        (workOrder.SVMXC__SM_Scheduled_Duration__c > STforWOwithoverlap))
                                    {
                                        workOrder.SVMXC__Order_Status__c = orderStatusValue;
                                    }
                                }
                            if(workOrder.SVMXC__SM_Scheduled_Duration__c == null)
                                workOrder.SVMXC__SM_Scheduled_Duration__c = 0.0;
                            //updating Workorder Scheduled Duration field with sum of all events service duration excluding overlapping time.   
                            workOrder.SVMXC__SM_Scheduled_Duration__c = Double.valueOf(STforWOwithoverlap); 
                            lstWO.add(workOrder);
                    }
                    }   
                }   
                //while calculating exact service duration of events for workorder, Drive times & overhead times are removed, Since <List> in salesforce all 'Call by reference', we have to add all Drive times & overhead times to events to remains events same. appendDriveTimeOverheadTimeToEvents method adds Drive times & overhead times to events. 
                 List<SVMXC__SVMX_Event__c> impactedEvents = new List<SVMXC__SVMX_Event__c>();
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    if(String.valueOf(svmxevt.SVMXC__Service_Order__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__Service_Order__c)) && String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                        {
                            if((WoDetails.get(svmxevt.SVMXC__WhatId__c).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                            (WoDetails.get(svmxevt.SVMXC__WhatId__c).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                                {
                                    impactedEvents.add(svmxevt);    
                                }   
                        }
                    }       
                }
                appendDriveTimeOverheadTimeToEvents(null,impactedEvents);  
                System.debug('lstSVMXEvents after append:' + lstSVMXEvents);
                //upsert lstWO;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO,COMM_SecurityUtils.Access.Upsertable))   
                {
                    upsert lstWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
            
        }
        
        /**
         * Method Name      :   handleSMAXEventOnDelete
         * Parameters       :   List of ServiceMax events
         * Description      :   This method will update the 'WorkOrder's Scheduled Duration' field upon deleting ServiceMax events
         * Return Value     :   None
         */
        public static void handleSMAXEventOnDelete(List<SVMXC__SVMX_Event__c> lstSVMXEvents, String orderStatusValue)
        {
            System.debug('orderStatusValue:' + orderStatusValue);
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            Map<String, List<SVMXC__SVMX_Event__c>> mapWOSVMXEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
            
            try
            {
                boolean isFieldExist = false;
                //Check if the WO is having a prefix to verify if it is a valid WOId
                String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                //grouping Servicemax Events based on Workorder Ids
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    if(String.valueOf(svmxevt.SVMXC__Service_Order__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__Service_Order__c)) && String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                    {
                        if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                        {
                            if(mapWOSVMXEvents.containsKey(svmxevt.SVMXC__WhatId__c))
                            {
                                mapWOSVMXEvents.get(svmxevt.SVMXC__WhatId__c).add(svmxevt);
                            }
                            else
                            {
                                List<SVMXC__SVMX_Event__c> tempevt = new List<SVMXC__SVMX_Event__c>();
                                tempevt.add(svmxevt);
                                mapWOSVMXEvents.put(svmxevt.SVMXC__WhatId__c,tempevt);
                            }
                        }   
                    }
                }
                System.debug('mapWOSVMXEvents:'+ mapWOSVMXEvents);
                List<String> lstWoIds = new List<String>();
                lstWoIds.addAll(mapWOSVMXEvents.keySet());
                /*WOTechSFSVMXEvents having list of salesforce events and servicemax events based on technician for individual Workorder which are available in database.
                Ex: Workorder1  - Technician1 - list of salesforce events, list of servicemax events
                                  Technician2 - list of salesforce events, list of servicemax events    
                    Workorder2  - Technician3 - list of salesforce events, list of servicemax events
                                  Technician4 - list of salesforce events, list of servicemax events */
                
                Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>(); 
                
                WOTechSFSVMXEvents = getListOfTechSFSVMXEvents(lstWoIds,null);
                
                Map<Id,SVMXC__Service_Order__c> WoDetails = new Map<Id,SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
                lstWorkOrders = [SELECT Id, SVMXC__SM_Scheduled_Duration__c,
                                                                SVMXC__SM_Scheduling_Options__c,SVMXC__SM_Unscheduled_Duration__c,SVMXC__SM_Revised_Duration__c,SVMXC__SM_Estimated_Duration__c
                                                                FROM SVMXC__Service_Order__c WHERE Id IN :mapWOSVMXEvents.keySet()];
                for(SVMXC__Service_Order__c Wo: lstWorkOrders)
                {
                    WoDetails.put(Wo.Id, Wo);   
                }
                                                                
                //looping thru workorders           
                for(String WoId: mapWOSVMXEvents.keySet())
                {
                    if((WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM Enabled, LJS Disabled') || 
                          (WoDetails.get(WoId).SVMXC__SM_Scheduling_Options__c == 'JDM and LJS Enabled'))
                    {     
                    String tempEventObj = JSON.serialize(mapWOSVMXEvents.get(WoId)[0]);
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(tempEventObj);
                    if(m.keySet().contains('SVMXC__Service_Duration__c'))
                        isFieldExist = true;

                    String objectPrefix = '';
                    if(mapWOSVMXEvents.get(WoId)[0].SVMXC__WhatId__c != null)
                        objectPrefix = String.valueOf(mapWOSVMXEvents.get(WoId)[0].SVMXC__WhatId__c).substring(0,3);

                    //Check if the WO Id having required prefix - this is to verify that the passed WOId is a salesforce WOId
                    //and check if the event passed is having 'Service_Duration' field, this is to avoid exceptions in the below logic
                    if(woKeyPrefix.equals(objectPrefix) && isFieldExist)
                    {
                        List<techSFSVMXEvents> techExistingEvts = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts1 = new List<techSFSVMXEvents>();
                        List<techSFSVMXEvents> techExistingEvts2 = new List<techSFSVMXEvents>();
                        List<techSVMXEvents> techdeletingSVMXEvents = new List<techSVMXEvents>();
                        Map<String, List<SVMXC__SVMX_Event__c>> techdeletingEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
                        if(WOTechSFSVMXEvents != null && WOTechSFSVMXEvents.containsKey(WoId) && WOTechSFSVMXEvents.get(WoId) != null && (WOTechSFSVMXEvents.get(WoId)).size() >0 )
                        {
                            techExistingEvts1 = WOTechSFSVMXEvents.get(WoId);   
                        }
                        
                        /*getListTechSVMXEventsForDelete contains salesforce events(which are going to delete) splitted based on technician Ids
                        Ex: Technician1 - list of salesforce events, list of servicemax events
                            Technician2 - list of salesforce events, list of servicemax events  */
                        
                        techdeletingSVMXEvents = getListTechSVMXEventsForDelete(mapWOSVMXEvents.get(WoId));
                                                
                        for(techSVMXEvents sfevt: techdeletingSVMXEvents)
                        {
                            techdeletingEvents.put(sfevt.techId,sfevt.lstSVMXEvents);
                        }
                        System.debug('techExistingEvts1:' + techExistingEvts1);
                        System.debug('techdeletingSVMXEvents:' + techdeletingSVMXEvents);
                        System.debug('techdeletingEvents:' + techdeletingEvents);
                        
                        //looping thru all techinician having both salesforce and servicemax events from database for workorder.
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {   
                            List<SVMXC__SVMX_Event__c> existingEvents = new List<SVMXC__SVMX_Event__c>();
                            List<SVMXC__SVMX_Event__c> deletingEvents = new List<SVMXC__SVMX_Event__c>();
                            List<SVMXC__SVMX_Event__c> tempsvmx = new List<SVMXC__SVMX_Event__c>();
                            List<SVMXC__SVMX_Event__c> tempsvmx1 = new List<SVMXC__SVMX_Event__c>();
                            if(techdeletingEvents.containsKey(techId_old.techId))
                            {
                                existingEvents.addAll(techId_old.lstSVMXEvents);
                                deletingEvents.addAll(techdeletingEvents.get(techId_old.techId));
                                //For workorder,if technician has already events and event is deleting for same technician, we will remove that event which is going to delete for same technicians.
                                for(SVMXC__SVMX_Event__c existingevt: existingEvents)
                                {
                                    Boolean isFound = false;
                                    for(SVMXC__SVMX_Event__c deletingevt: deletingEvents)
                                    {   
                                        if(existingevt.Id == deletingevt.Id) 
                                        {
                                            //if((String.valueOf(existingevt.Id)).equals(String.valueOf(deletingevt.Id)))
                                            System.debug('I am in delete event');   
                                            isFound = true; 
                                            continue;
                                        }
                                    }
                                    if(!isFound)
                                    {
                                        tempsvmx.add(existingevt);  
                                    }
                                }
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,tempsvmx);
                                techExistingEvts2.add(tempevt);
                            }
                        }
                        System.debug('techExistingEvts2:' + techExistingEvts2);
                        
                        techExistingEvts.addAll(techExistingEvts2);
                        //For workorder, if technician have events in database and which are not in deleting list
                        for(techSFSVMXEvents techId_old: techExistingEvts1)
                        {
                            Boolean isFoundTech = false;
                            for(techSFSVMXEvents techId_upt: techExistingEvts2)
                            {
                                if(techId_old.techId.equals(techId_upt.techId))
                                {
                                    isFoundTech = true;
                                    System.debug('I am inside delete tech event');
                                    continue;   
                                }
                            }
                            If(!isFoundTech)
                            {
                                techSFSVMXEvents tempevt = new techSFSVMXEvents(techId_old.techId,techId_old.lstSFEvents,techId_old.lstSVMXEvents);
                                techExistingEvts.add(tempevt);  
                            }
                        }
                        //techExistingEvts having all existing and excluding deleting events based on technician for WORKORDER
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        //sorting salesforce and servicemax events seperatly based on startdatetime based on technicians for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                            {
                                List<Event> sortedSFEvents = new List<Event>();
                                List<SVMXC__SVMX_Event__c> sortedSVMXEvents = new List<SVMXC__SVMX_Event__c>();
                                
                                if(t1.lstSFEvents != null && t1.lstSFEvents.size()>0)
                                {
                                    sortedSFEvents.addAll(sortSFEventbyStartdatetime(t1.lstSFEvents));
                                    t1.lstSFEvents.clear();
                                    t1.lstSFEvents.addAll(sortedSFEvents);
                                }
                                if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size()>0)
                                {
                                    sortedSVMXEvents.addAll(sortSVMXEventbyStartdatetime(t1.lstSVMXEvents));
                                    t1.lstSVMXEvents.clear();
                                    t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                                }   
                            }
                        System.debug('techExistingEvts:' + techExistingEvts);
                        
                        Map<String, List<DCON_AES_Event_WS.StartEndTime>> lstTechEventStartEndtime= new Map<String, List<DCON_AES_Event_WS.StartEndTime>>();
                        //merging both salesforce and servicemax event startdatetime and enddatetime based on technician for workorder
                        for(techSFSVMXEvents t1 : techExistingEvts) 
                        {
                            List<DCON_AES_Event_WS.StartEndTime> lsEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
                            if(mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents) != null && mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents).size() > 0)
                            {   
                                lsEventStartEndTime = mergeSFSVMXEvents(t1.lstSFEvents,t1.lstSVMXEvents);
                            }                           
                            lstTechEventStartEndtime.put(t1.techId,lsEventStartEndTime);
                        }
                        /*lstTechEventStartEndtime having technician and its events(both salesforce and servicemax events) start datetime & end datetime
                        Ex: Technician1 - event1 startdatetime,event1 enddatetime
                                          event2 startdatetime,event2 enddatetime   
                            Technician2 - event3 startdatetime,event1 enddatetime  */
                        System.debug('lstTechEventStartEndtime:' + lstTechEventStartEndtime);   
                        
                        //summing the service duration of all events of technician excluding overlapping time for workorder
                        Map<String, Integer> techSTwithoverlap = new Map<String, Integer>();  
                            for(String techId: lstTechEventStartEndtime.keySet()) 
                            {   Integer actualdurationfortech = 0;
                                If(lstTechEventStartEndtime.get(techId) != null && lstTechEventStartEndtime.get(techId).size() > 0)
                                {
                                    Datetime startDatetime = lstTechEventStartEndtime.get(techId)[0].startTime;
                                    Datetime endDatetime = lstTechEventStartEndtime.get(techId)[0].endTime;
                                    //looping thru all events to get exact service duration excluding time between two successive events if there is any gap
                                    for(DCON_AES_Event_WS.StartEndTime times: lstTechEventStartEndtime.get(techId))
                                    {
                                        //logic to get actual values
                                        if((times.startTime >= startDatetime && times.startTime <= endDatetime) && (times.endTime >= startDatetime))
                                        {
                                            if(times.endTime >= endDatetime)
                                            {
                                                endDatetime = times.endTime;
                                            }
                                        }
                                        else if((times.startTime >= startDatetime && times.startTime >= endDatetime) && (times.endTime >= startDatetime && times.endTime >= endDatetime))
                                        {
                                            actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                            startDatetime = times.startTime;
                                            endDatetime = times.endTime;
                                        }
                                    }   
                                    //append last service duration  
                                    actualdurationfortech = actualdurationfortech + Integer.valueOf((endDateTime.getTime() - startDateTime.getTime())/(1000*60));   
                                }
                                techSTwithoverlap.put(techId,actualdurationfortech);
                            }
                            system.debug('techSTwithoverlap:' + techSTwithoverlap);
                            
                            Integer STforWOwithoverlap = 0; //contains sum of service duration of all events for workorder excluding overlapping time
                            for(String techId: techSTwithoverlap.keySet()) 
                            {
                                STforWOwithoverlap = STforWOwithoverlap + techSTwithoverlap.get(techId);    
                            }
                            SVMXC__Service_Order__c workOrder = WoDetails.get(WoId);
                            //updating WO's order status field if the WO is changed from fully scheduled to under-scheduled (or less than fully scheduled)
                              
                            if(!String.isBlank(orderStatusValue))
                                {
                                    if((workOrder.SVMXC__SM_Unscheduled_Duration__c <= 0) &&
                                        (workOrder.SVMXC__SM_Scheduled_Duration__c > STforWOwithoverlap))
                                    {
                                        workOrder.SVMXC__Order_Status__c = orderStatusValue;
                                    }
                                }
                            if(workOrder.SVMXC__SM_Scheduled_Duration__c == null)
                                workOrder.SVMXC__SM_Scheduled_Duration__c = 0.0;
                            //updating Workorder Scheduled Duration field with sum of all events service duration excluding overlapping time.
                            workOrder.SVMXC__SM_Scheduled_Duration__c = Double.valueOf(STforWOwithoverlap); 
                            lstWO.add(workOrder);                       
                    }
                    }
                }   
                //upsert lstWO;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWO,COMM_SecurityUtils.Access.Upsertable))   
                {
                    upsert lstWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } 
                else 
                {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }  
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }
        
       /**
         * Method Name      :   getListOfTechSFSVMXEvents
         * Parameters       :   workorder Id
         *                      set of Event Ids(which are going to be updated)
         * Description      :   This method will return all salesforce and service max events for workorder group by technician. If there is any events are in updated list whose events will be excluded.
                                ServiceMax and Salesforce events
         * Return Value     :   all salesforce and service max events for workorder group by technician
         */
        
        public static Map<String, List<techSFSVMXEvents>> getListOfTechSFSVMXEvents(List<String> lstworkOrderId, Set<String> toBeupdatedEventIds)
        {
            Map<String, List<techSFSVMXEvents>> WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>();
            List<techSFSVMXEvents> lsttechevts = new List<techSFSVMXEvents>(); 
            if(lstworkOrderId != null && lstworkOrderId.size()>0)
            {
                List<Event> lstEvents = new List<Event>();
                if(toBeupdatedEventIds != null && toBeupdatedEventIds.size() > 0)
                {
                    lstEvents = [Select Id,DurationInMinutes,IsAllDayEvent,OwnerId,StartDateTime,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c,EndDateTime,SVMXC__Overhead_Time_After__c,SVMXC__Overhead_Time_Before__c,SVMXC__Service_Duration__c,WhatId from Event where (WhatId IN :lstworkOrderId AND Id NOT IN: toBeupdatedEventIds)];
                }
                else
                {
                    lstEvents = [Select Id,DurationInMinutes,IsAllDayEvent,OwnerId,StartDateTime,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c,EndDateTime,SVMXC__Overhead_Time_After__c,SVMXC__Overhead_Time_Before__c,SVMXC__Service_Duration__c,WhatId from Event where WhatId IN :lstworkOrderId]; 
                }
                
                List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
                if(toBeupdatedEventIds != null && toBeupdatedEventIds.size() > 0)
                {
                    lstSVMXEvents = [Select Id,SVMXC__DurationInMinutes__c,SVMXC__IsAllDayEvent__c,OwnerId,SVMXC__StartDateTime__c,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c,SVMXC__EndDateTime__c,SVMXC__Overhead_Time_After__c,SVMXC__Overhead_Time_Before__c,SVMXC__Service_Duration__c,SVMXC__Technician__c,SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (SVMXC__WhatId__c IN :lstworkOrderId OR SVMXC__Service_Order__c IN :lstworkOrderId) AND (Id NOT IN: toBeupdatedEventIds)];
                }
                else
                {
                    lstSVMXEvents = [Select Id,SVMXC__DurationInMinutes__c,SVMXC__IsAllDayEvent__c,OwnerId,SVMXC__StartDateTime__c,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c,SVMXC__EndDateTime__c,SVMXC__Overhead_Time_After__c,SVMXC__Overhead_Time_Before__c,SVMXC__Service_Duration__c,SVMXC__Technician__c,SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :lstworkOrderId OR SVMXC__Service_Order__c IN :lstworkOrderId];   
                }
                            
                System.debug('lstEvents:' + lstEvents);
                System.debug('lstSVMXEvents:' + lstSVMXEvents);
                set<String> setownerIds = new set<String>();
                Map<String,String> techSFUser = new Map<String,String>();
                for(Event evt: lstEvents)
                {
                    setownerIds.add(evt.OwnerId);   
                }
                
                List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
                lsttech = [Select Id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds];
                
                for(SVMXC__Service_Group_Members__c tech: lsttech)  
                {
                    techSFUser.put(tech.SVMXC__Salesforce_User__c,tech.Id); 
                }
                Map<String, List<Event>> WOSFEvents = new Map<String, List<Event>>();
                Map<String, List<SVMXC__SVMX_Event__c>> WOSVMXEvents = new Map<String, List<SVMXC__SVMX_Event__c>>();
                
                for(Event evt: lstEvents)
                {
                    if(WOSFEvents.containsKey(evt.WhatId))
                    {
                        WOSFEvents.get(evt.WhatId).add(evt);
                    }
                    else
                    {
                        List<Event> tempevt = new List<Event>();
                        tempevt.add(evt);
                        WOSFEvents.put(evt.WhatId,tempevt);
                    }
                }
                
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    if(WOSVMXEvents.containsKey(svmxevt.SVMXC__WhatId__c))
                    {
                        WOSVMXEvents.get(svmxevt.SVMXC__WhatId__c).add(svmxevt);
                    }
                    else
                    {
                        List<SVMXC__SVMX_Event__c> tempevt = new List<SVMXC__SVMX_Event__c>();
                        tempevt.add(svmxevt);
                        WOSVMXEvents.put(svmxevt.SVMXC__WhatId__c,tempevt);
                    }
                }
                //storing woId and related SF Events and SVMX Events in WoSFSVMXEvents
                List<techSFSVMXEvents> lstWoSFSVMXEvents = new List<techSFSVMXEvents>();
                for(String woId: lstworkOrderId)
                {
                    techSFSVMXEvents WoSFSVMXEvent = new techSFSVMXEvents(woId,WOSFEvents.get(woId),WOSVMXEvents.get(woId));
                    lstWoSFSVMXEvents.add(WoSFSVMXEvent);
                }
                
                for(techSFSVMXEvents woEvent: lstWoSFSVMXEvents)
                {
                    set<String> setTechIds = new set<String>();
                    if(woEvent.lstSVMXEvents != null && (woEvent.lstSVMXEvents).size()>0)
                    {
                        for(SVMXC__SVMX_Event__c svmxevt: woEvent.lstSVMXEvents)
                        {
                            setTechIds.add(svmxevt.SVMXC__Technician__c);
                        }
                    }   
                    
                    if(woEvent.lstSFEvents != null && (woEvent.lstSFEvents).size()>0)
                    {
                        for(Event sfevt: woEvent.lstSFEvents)
                        {
                            if(techSFUser.containsKey(sfevt.OwnerId))
                            {
                                setTechIds.add(techSFUser.get(sfevt.OwnerId));
                            }   
                        }
                    }   
                
                    techSFSVMXEvents techevts;
                    for(String techId: setTechIds)
                    {
                        List<Event> lsttempEvts = new List<Event>();
                        List<SVMXC__SVMX_Event__c> lsttempSVMXEvts = new List<SVMXC__SVMX_Event__c>();
                        
                        for(Event evt: lstEvents)   
                        {
                            //Defect fixed : 044768 :DNS-2342: Overscheduling hours calculation for salesforce event
                            if(techSFUser.containsKey(evt.OwnerId) && techId.equals(techSFUser.get(evt.OwnerId)))
                            {
                                Event tempevt = evt;
                                if(!evt.IsAllDayEvent)
                                {
                                    tempevt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes));
                                    tempevt.StartDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.SVMXC__Driving_Time__c) + Integer.valueof(evt.SVMXC__Overhead_Time_Before__c));
                                    tempevt.EndDateTime = tempevt.EndDateTime.addMinutes(-(Integer.valueof(evt.SVMXC__Driving_Time_Home__c) + Integer.valueof(evt.SVMXC__Overhead_Time_After__c)));
                                }
                                else
                                {
                                    tempevt.StartDateTime = evt.StartDateTime;
                                    tempevt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes)); 
                                }
                                lsttempEvts.add(tempevt);
                            }
                        }
                        for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                        {       
                            if(techId.equals(String.valueOf(svmxevt.SVMXC__Technician__c)))
                            {
                                SVMXC__SVMX_Event__c tempsvmxevt = svmxevt;
                                if(!svmxevt.SVMXC__IsAllDayEvent__c)
                                {
                                    tempsvmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));
                                    tempsvmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__Driving_Time__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_Before__c));
                                    tempsvmxevt.SVMXC__EndDateTime__c = tempsvmxevt.SVMXC__EndDateTime__c.addMinutes(-(Integer.valueof(svmxevt.SVMXC__Driving_Time_Home__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_After__c)));
                                }
                                else
                                {
                                    tempsvmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c;
                                    tempsvmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));   
                                }
                                lsttempSVMXEvts.add(tempsvmxevt);
                            }
                        }   
                        
                        techevts = new techSFSVMXEvents(techId,lsttempEvts,lsttempSVMXEvts);
                        lsttechevts.add(techevts);
                    }
                    System.debug('lsttechevts:' + lsttechevts);
                    //here techId is not technician Id, it is Work Order Id.
                    WOTechSFSVMXEvents.put(woEvent.techId,lsttechevts);
                }
                return  WOTechSFSVMXEvents; 
            }
            else{
                WOTechSFSVMXEvents = new Map<String, List<techSFSVMXEvents>>();
                return  WOTechSFSVMXEvents; 
            }
        }
        /**
         * Method Name      :   getListTechSFEvents
         * Parameters       :   list of salesforce events
         * Description      :   This method will return list of salesforce events group by technician
         * Return Value     :   list of salesforce events group by technician
         */
        
        public static List<techSFEvents> getListTechSFEvents(List<Event> lstSFEvents)
        {
            List<techSFEvents> techIdevts = new List<techSFEvents>();
            If(lstSFEvents != null && lstSFEvents.size()>0)
            {
                System.debug('lstSFEvents:' + lstSFEvents);
                set<String> setTechIds = new set<String>();
                
                for(Event evt: lstSFEvents) 
                {
                    if(!String.isBlank(mapTechSFUser.get(evt.OwnerId)))
                    {
                        setTechIds.add(mapTechSFUser.get(evt.OwnerId));
                    }   
                }

                techSFEvents temptechIdevts;
                for(String techId: setTechIds)
                {
                    List<Event> lsttempEvts = new List<Event>();
                    for(Event evt: lstSFEvents) 
                    {
                        if(mapTechSFUser.containsKey(evt.OwnerId))
                        {
                            Event tempevt = evt;
                            if(!evt.IsAllDayEvent)
                            {
                                tempevt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes));
                                tempevt.StartDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.SVMXC__Driving_Time__c) + Integer.valueof(evt.SVMXC__Overhead_Time_Before__c));
                                tempevt.EndDateTime = tempevt.EndDateTime.addMinutes(-(Integer.valueof(evt.SVMXC__Driving_Time_Home__c) + Integer.valueof(evt.SVMXC__Overhead_Time_After__c)));
                            }
                            else
                            {
                                tempevt.StartDateTime = evt.StartDateTime;
                                tempevt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes)); 
                            }
                            lsttempEvts.add(tempevt);
                        }
                    }
                    temptechIdevts = new techSFEvents(techId,lsttempEvts);
                    techIdevts.add(temptechIdevts);
                }
                System.debug('techIdevts:' + techIdevts);
                return techIdevts;
            }
            else
            {   
                techIdevts = new List<techSFEvents>();
                return techIdevts;
            }   
        }
        /**
         * Method Name      :   getListTechSFEventsForDelete
         * Parameters       :   list of salesforce events
         * Description      :   This method will return list of salesforce events group by technician
         * Return Value     :   list of salesforce events group by technician
         */
        
        public static List<techSFEvents> getListTechSFEventsForDelete(List<Event> lstSFEvents)
        {
            List<techSFEvents> techIdevts = new List<techSFEvents>();
            If(lstSFEvents != null && lstSFEvents.size()>0)
            {
                System.debug('lstSFEvents:' + lstSFEvents);
                set<String> setTechIds = new set<String>();
                                                                              
                for(Event evt: lstSFEvents) 
                {
                    if(!String.isBlank(mapTechSFUser.get(evt.OwnerId)))
                    {
                        setTechIds.add(mapTechSFUser.get(evt.OwnerId));
                    }
                }

                techSFEvents temptechIdevts;
                for(String techId: setTechIds)
                {
                    List<Event> lsttempEvts = new List<Event>();
                    for(Event evt: lstSFEvents) 
                    {
                        if(mapTechSFUser.containsKey(evt.OwnerId))
                            {
                            Event tempevt = new Event();
                            if(!evt.IsAllDayEvent)
                            {
                                tempevt.Id = evt.Id;
                                tempevt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes));
                                tempevt.StartDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.SVMXC__Driving_Time__c) + Integer.valueof(evt.SVMXC__Overhead_Time_Before__c));
                                tempevt.EndDateTime = tempevt.EndDateTime.addMinutes(-(Integer.valueof(evt.SVMXC__Driving_Time_Home__c) + Integer.valueof(evt.SVMXC__Overhead_Time_After__c)));
                            }
                            else
                            {
                                tempevt.Id = evt.Id;
                                tempevt.StartDateTime = evt.StartDateTime;
                                tempevt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes)); 
                            }
                            lsttempEvts.add(tempevt);
                        }
                    }
                    temptechIdevts = new techSFEvents(techId,lsttempEvts);
                    techIdevts.add(temptechIdevts);
                }
                System.debug('techIdevts:' + techIdevts);
                return techIdevts;
            }
            else
            {
                techIdevts = new List<techSFEvents>();  
                return techIdevts;
            }
        }
        /**
         * Method Name      :   getListTechSVMXEvents
         * Parameters       :   list of servicemax events
         * Description      :   This method will return list of servicemax events group by technician
         * Return Value     :   list of servicemax events group by technician
         */
        public static List<techSVMXEvents> getListTechSVMXEvents(List<SVMXC__SVMX_Event__c> lstSVMXEvents)
        {
            List<techSVMXEvents> techIdsvmxevts = new List<techSVMXEvents>();
            If(lstSVMXEvents != null && lstSVMXEvents.size()>0)
            {
                System.debug('lstSVMXEvents:' + lstSVMXEvents);
                techSVMXEvents temptechIdsvmxevts;
                set<String> setTechIds = new set<String>();

                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    setTechIds.add(svmxevt.SVMXC__Technician__c);
                }

                for(String techId: setTechIds)
                {
                    List<SVMXC__SVMX_Event__c> lsttempSVMXEvts = new List<SVMXC__SVMX_Event__c>();
                    for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                    {       
                        if(techId.equals(String.valueOf(svmxevt.SVMXC__Technician__c)))
                        {
                            SVMXC__SVMX_Event__c tempsvmxevt = svmxevt;
                            //SVMXC__SVMX_Event__c tempsvmxevt = new SVMXC__SVMX_Event__c();
                            if(!svmxevt.SVMXC__IsAllDayEvent__c)
                            {
                                System.debug('In non all day event');
                                tempsvmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));
                                tempsvmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__Driving_Time__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_Before__c));
                                tempsvmxevt.SVMXC__EndDateTime__c = tempsvmxevt.SVMXC__EndDateTime__c.addMinutes(-(Integer.valueof(svmxevt.SVMXC__Driving_Time_Home__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_After__c)));
                            }
                            else
                            {
                                tempsvmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c;
                                tempsvmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));   
                            }
                            lsttempSVMXEvts.add(tempsvmxevt);
                        }
                    }
                    temptechIdsvmxevts = new techSVMXEvents(techId,lsttempSVMXEvts);
                    techIdsvmxevts.add(temptechIdsvmxevts); 

                }
                System.debug('techIdsvmxevts:' + techIdsvmxevts);
                return techIdsvmxevts;
            }
            else
            {   
                techIdsvmxevts = new List<techSVMXEvents>();
                return techIdsvmxevts;
            }   
        }
        /**
         * Method Name      :   getListTechSVMXEventsForDelete
         * Parameters       :   list of servicemax events
         * Description      :   This method will return list of servicemax events group by technician
         * Return Value     :   list of servicemax events group by technician
         */
        public static List<techSVMXEvents> getListTechSVMXEventsForDelete(List<SVMXC__SVMX_Event__c> lstSVMXEvents)
        {
            List<techSVMXEvents> techIdsvmxevts = new List<techSVMXEvents>();
            If(lstSVMXEvents != null && lstSVMXEvents.size()>0)
            {
                System.debug('lstSVMXEvents:' + lstSVMXEvents);
                techSVMXEvents temptechIdsvmxevts;
                set<String> setTechIds = new set<String>();

                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    setTechIds.add(svmxevt.SVMXC__Technician__c);
                }

                for(String techId: setTechIds)
                {
                    List<SVMXC__SVMX_Event__c> lsttempSVMXEvts = new List<SVMXC__SVMX_Event__c>();
                    for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                    {       
                        if(techId.equals(String.valueOf(svmxevt.SVMXC__Technician__c)))
                        {
                            //SVMXC__SVMX_Event__c tempsvmxevt = svmxevt;
                            SVMXC__SVMX_Event__c tempsvmxevt = new SVMXC__SVMX_Event__c();
                            if(!svmxevt.SVMXC__IsAllDayEvent__c)
                            {
                                System.debug('In non all day event');
                                tempsvmxevt.Id = svmxevt.Id;
                                tempsvmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));
                                tempsvmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__Driving_Time__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_Before__c));
                                tempsvmxevt.SVMXC__EndDateTime__c = tempsvmxevt.SVMXC__EndDateTime__c.addMinutes(-(Integer.valueof(svmxevt.SVMXC__Driving_Time_Home__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_After__c)));
                            }
                            else
                            {
                                tempsvmxevt.Id = svmxevt.Id;
                                tempsvmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c;
                                tempsvmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));   
                            }
                            lsttempSVMXEvts.add(tempsvmxevt);
                        }
                    }
                    temptechIdsvmxevts = new techSVMXEvents(techId,lsttempSVMXEvts);
                    techIdsvmxevts.add(temptechIdsvmxevts); 

                }
                System.debug('techIdsvmxevts:' + techIdsvmxevts);
                return techIdsvmxevts;
            }   
            else
            {
                techIdsvmxevts = new List<techSVMXEvents>();
                return techIdsvmxevts;
            }   
        }
        /**
         * Method Name      :   sortSFSVMXEventForTech
         * Parameters       :   List<techSFSVMXEvents>
         * Description      :   This method sorts salesforce and servicemax events based on startdatetiem of event
         * Return Value     :   returns sorted salesforce and servicemax events group by technician
         */
        public static List<techSFSVMXEvents> sortSFSVMXEventForTech(List<techSFSVMXEvents> techEvents)
        {
            for(techSFSVMXEvents t1 : techEvents) 
                {
                    List<Event> sortedSFEvents = sortSFEventbyStartdatetime(t1.lstSFEvents);
                    List<SVMXC__SVMX_Event__c> sortedSVMXEvents = sortSVMXEventbyStartdatetime(t1.lstSVMXEvents);
                    if(t1.lstSFEvents != null && t1.lstSFEvents.size() > 0)
                    {
                        t1.lstSFEvents.clear();
                        t1.lstSFEvents.addAll(sortedSFEvents);  
                    }
                    if(t1.lstSVMXEvents != null && t1.lstSVMXEvents.size() > 0)
                    {
                        t1.lstSVMXEvents.clear();
                        t1.lstSVMXEvents.addAll(sortedSVMXEvents);
                    }
                }
            System.debug('techEvents:' + techEvents);   
            return techEvents;
        }
        /**
         * Method Name      :   sortSVMXEventbyStartdatetime
         * Parameters       :   List of servicemax events
         * Description      :   This method sorts servicemax events based on startdatetime of event
         * Return Value     :   returns sorted servicemax events
         */
        public static List<SVMXC__SVMX_Event__c> sortSVMXEventbyStartdatetime(List<SVMXC__SVMX_Event__c> lstsvmxevts)
        {
            List<SVMXC__SVMX_Event__c> SVMXEvtList= new List<SVMXC__SVMX_Event__c>();
            List<SVMXEventWrapper> SVMXEvtWrapperList = new List<SVMXEventWrapper>();
            if(lstsvmxevts != null && lstsvmxevts.size()>0 )
            {
                for(SVMXC__SVMX_Event__c evt: lstsvmxevts) 
                {
                    SVMXEvtWrapperList.add(new SVMXEventWrapper(evt));  
                }
                for(SVMXEventWrapper evt1: SVMXEvtWrapperList) 
                {
                    System.debug('Before sort:' + evt1.svmxevent.SVMXC__StartDateTime__c);
                }
                
                SVMXEvtWrapperList.sort();

                for(SVMXEventWrapper evt1: SVMXEvtWrapperList) 
                {
                    System.debug('After sort:' + evt1.svmxevent.SVMXC__StartDateTime__c);
                    SVMXEvtList.add(evt1.svmxevent);
                }
                return SVMXEvtList;
            }
            else
            {
                SVMXEvtList= new List<SVMXC__SVMX_Event__c>();
                return SVMXEvtList;
            }
        }
        /**
         * Method Name      :   sortSFEventbyStartdatetime
         * Parameters       :   List of salesforce events
         * Description      :   This method sorts salesforce events based on startdatetime of event
         * Return Value     :   returns sorted salesforce events
         */
        public static List<Event> sortSFEventbyStartdatetime(List<Event> lstsfevts)
        {
            List<EventWrapper> SFEvtWrapperList = new List<EventWrapper>();
            List<Event> SFEvtList= new List<Event>();
            if(lstsfevts != null && lstsfevts.size()>0 )
            {
                for(Event evt: lstsfevts) 
                {
                    SFEvtWrapperList.add(new EventWrapper(evt));    
                }
                for(EventWrapper evt1: SFEvtWrapperList) 
                {
                    System.debug('Before sort:' + evt1.sfevent.StartDateTime);
                }
                
                SFEvtWrapperList.sort();

                for(EventWrapper evt1: SFEvtWrapperList) 
                {
                    System.debug('After sort:' + evt1.sfevent.StartDateTime);
                    SFEvtList.add(evt1.sfevent);
                }
                return SFEvtList;
            }
            else
            {
                SFEvtList= new List<Event>();
                return SFEvtList;
            }
        }
        /**
         * Method Name      :   mergeSFSVMXEvents
         * Parameters       :   List of salesforce events
         *                      List of servicemax events
         * Description      :   This method merges salesforce event's and servicemax event's startdatetime & enddatetime
         * Return Value     :   returns merged salesforce & servicemax events
         */
        public static list<DCON_AES_Event_WS.StartEndTime> mergeSFSVMXEvents(List<Event> lstEvents, List<SVMXC__SVMX_Event__c> lstSVMXEvents)
        {
            List<DCON_AES_Event_WS.StartEndTime> lstSFEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
            List<DCON_AES_Event_WS.StartEndTime> lstSVMXEventStartEndTime = new List<DCON_AES_Event_WS.StartEndTime>();
            List<DCON_AES_Event_WS.StartEndTime> lstdates = new List<DCON_AES_Event_WS.StartEndTime>();
            if((lstEvents != null && lstEvents.size() > 0) || (lstSVMXEvents != null && lstSVMXEvents.size() >0))
            { 
                System.debug('lstEvents:'+ lstEvents);
                System.debug('lstSVMXEvents:'+ lstSVMXEvents);
            //Note: If event is All day Event irrespective of timezone, it will display in gantt same date without shifting. 
            if(lstEvents != null && lstEvents.size() > 0)   
            {   
                for(Event sfevt: lstEvents)
                {
                    DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(sfevt.StartDateTime,sfevt.EndDateTime);
                    lstSFEventStartEndTime.add(tempdate);
                }
                System.debug('lstSFEventStartEndTime:' + lstSFEventStartEndTime);
            }
            if(lstSVMXEvents != null && lstSVMXEvents.size() > 0)   
            {   
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(svmxevt.SVMXC__StartDateTime__c,svmxevt.SVMXC__EndDateTime__c);
                    lstSVMXEventStartEndTime.add(tempdate);
                }
                System.debug('lstSVMXEventStartEndTime:' + lstSVMXEventStartEndTime);
            }   
                    
            Integer i = 0, j = 0, k = 0;
            
            if((lstSFEventStartEndTime != null && lstSFEventStartEndTime.size()>0) && (lstSVMXEventStartEndTime != null && lstSVMXEventStartEndTime.size()>0))
            { 
                System.debug(' in both check');
                while(i < lstSFEventStartEndTime.size() && j < lstSVMXEventStartEndTime.size())
                {
                    if (lstSFEventStartEndTime[i].starttime < lstSVMXEventStartEndTime[j].starttime)
                    {
                        DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                        lstdates.add(tempdate);
                        i++;
                    }
                    else
                    {
                        DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(lstSVMXEventStartEndTime[j].starttime,lstSVMXEventStartEndTime[j].endtime);
                        lstdates.add(tempdate);
                        j++;
                    }
                    System.debug('lstdates:'+lstdates);
                }
                
                while (i < lstSFEventStartEndTime.size())
                {
                    DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                    System.debug('tempdate1:'+tempdate);
                    lstdates.add(tempdate);
                    i++;
                }
                
                while (j < lstSVMXEventStartEndTime.size())
                {
                    DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(lstSVMXEventStartEndTime[j].starttime,lstSVMXEventStartEndTime[j].endtime);
                    System.debug('tempdate2:'+tempdate);
                    lstdates.add(tempdate);
                    j++;
                }
                
                //for loop is for testing , we can remove later
                for(Integer m = 0; m < lstdates.size(); m++)    
                    System.debug('lstdates:'+ lstdates.get(m));
            }
            else if((lstSFEventStartEndTime != null && lstSFEventStartEndTime.size()>0) && (lstSVMXEventStartEndTime.isEmpty() && lstSVMXEventStartEndTime.size() == 0))
            {
                System.debug(' in SF  check');
                while(i < lstSFEventStartEndTime.size())
                {
                    DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                    lstdates.add(tempdate);
                    i++;    
                }
            }
            else if((lstSFEventStartEndTime.isEmpty() && lstSFEventStartEndTime.size() == 0) && (lstSVMXEventStartEndTime != null && lstSVMXEventStartEndTime.size() > 0))
            {
                System.debug(' in SVMX  check');
                while(i < lstSVMXEventStartEndTime.size())
                {
                    DCON_AES_Event_WS.StartEndTime tempdate = new DCON_AES_Event_WS.StartEndTime(lstSVMXEventStartEndTime[i].starttime,lstSVMXEventStartEndTime[i].endtime);
                    lstdates.add(tempdate);
                    i++;    
                }
            }
            return lstdates;
            }
            else
            {
                lstdates = new List<DCON_AES_Event_WS.StartEndTime>();
                return lstdates;
            }   
        }
        /**
         * Method Name      :   appendDriveTimeOverheadTimeToEvents
         * Parameters       :   List of salesforce events
         *                      List of servicemax events
         * Description      :   This method appends drive times and overhead times to events
         * Return Value     :   returns salesforce & servicemax events
         */
        public static void appendDriveTimeOverheadTimeToEvents(List<Event> lstEvents, List<SVMXC__SVMX_Event__c> lstSVMXEvents)
        {
            if(lstEvents != null && lstEvents.size()>0 )    
            {
                for(Event evt: lstEvents)
                {
                    if(!evt.IsAllDayEvent)
                        {
                            evt.StartDateTime = evt.StartDateTime.addMinutes(-(Integer.valueof(evt.SVMXC__Driving_Time__c) + Integer.valueof(evt.SVMXC__Overhead_Time_Before__c)));
                            evt.EndDateTime = evt.StartDateTime.addMinutes(Integer.valueof(evt.DurationInMinutes));
                        }
                }       
            }
            if(lstSVMXEvents != null && lstSVMXEvents.size()>0 )    
            {
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)    
                {
                    if(!svmxevt.SVMXC__IsAllDayEvent__c && svmxevt.SVMXC__Driving_Time__c != null && svmxevt.SVMXC__Overhead_Time_Before__c != null && svmxevt.SVMXC__DurationInMinutes__c != null)
                        {
                            svmxevt.SVMXC__StartDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(-(Integer.valueof(svmxevt.SVMXC__Driving_Time__c) + Integer.valueof(svmxevt.SVMXC__Overhead_Time_Before__c)));
                            svmxevt.SVMXC__EndDateTime__c = svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(svmxevt.SVMXC__DurationInMinutes__c));
                        }
                }
            }   
            
        }
        /***** END: JDM fields calculation logic - Updating WorkOder's Schedule Duration *****/
    }